<cfparam name="url.popUp" default="0" />
<CFSET PAGE_TITLE="Program History">
<CFSET GROUP="Programs">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/Common_Files/scripts/balloonPopup.js"></SCRIPT>

	<script type="text/javascript" src="/script/javascript/prototype/prototype.js"></script>
	<script type="text/javascript" src="/script/javascript/prototype/scriptaculous.js"></script>
</HEAD>

<BODY  BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="buildHelpBalloons(); showAllBalloons();">
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<style>
	TABLE.Maintable TD
	{
		font-size : 10px;
	}
	#header
	{
		font-size: 12px;
	}

	TABLE.ChangeLog
	{
		border:1px solid black
		font-size:10px;
		font-family:Arial;
	}
	TABLE.ChangeLog TD
	{
		border-right: 1px solid black;
		border-bottom: 1px solid black;
		font-family:Arial;
	}
</style>

<cfset ColorBackground = "FFCE84">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif isdefined("URL.CID")>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<blockquote><blockquote></blockquote></blockquote>

<cfif isdefined("URL.CID")>
<cf_cryp type="de" string="#URL.CID#" key="#request.key#">
<cfset contract_main_id = cryp.value>
<cfelse>
<cfset contract_main_id = url.ProgramId>
</cfif>

<cfset qGetChangeLog = CreateObject("component", "components.programs.program_history").init() />
<!---
<cfset useLakebaseForContractHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("temp_history")>
<cfif useLakebaseForContractHistory>
	<cftry>
		<cfset ContractHistory = application.oLakebase.toQuery(
			application.oLakebase.selectRows("temp_history", {
				"temp_id" = "eq.#contract_main_id#",
				"order" = "changed_date.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForContractHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForContractHistory>
<CFQUERY NAME="ContractHistory" datasource="#application.datasource#">
	SELECT *
	FROM Temp_History
	WHERE temp_id = '#contract_main_id#'
	ORDER BY Changed_Date desc
</CFQUERY>
</cfif>
--->

<CFQUERY NAME="Get_Contract_Number" datasource="#application.datasource#">
SELECT 		Contract_Main.contract_number,Contract_Main.Revision_of_Contract_Main_ID, Revision_contract_main.Contract_Number AS Revision_contract_number
, Revision_contract_main.Contract_Title as Revision_contract_title, Revision_contract_main.Contract_start_Date as Revision_Contract_start_Date
, Revision_contract_main.Contract_End_Date as Revision_Contract_End_Date, Renewal_contract_main.Contract_Number AS Renewal_contract_number
, Renewal_contract_main.Contract_Title as Renewal_Contract_Title, Renewal_contract_main.Contract_start_Date as Renewal_Contract_start_Date
, Renewal_contract_main.Contract_End_Date as Renewal_Contract_End_Date
, Contract_Main.Revision_Version, Revision_contract_main.Revision_Version original_version
, Rolled_Over_Contract_Main.Contract_Number AS Rolled_Over_Contract_Number
, Rolled_Over_Contract_Main.Contract_Title AS Rolled_Over_Contract_Title
, Rolled_Over_Contract_Main.Contract_start_Date as Rolled_Over_Contract_Start_Date
, Rolled_Over_Contract_Main.Contract_End_Date as Rolled_Over_Contract_End_Date
, Contract_Main.Approved
, Program_Control_Panel_Options.Include_Competitive_Data_Tracking
FROM		Contract_Main
			left join contract_main AS Revision_contract_main
			ON Revision_contract_main.Contract_Main_ID = Contract_Main.Revision_of_Contract_Main_ID
			left join contract_main AS Renewal_contract_main
			ON Renewal_contract_main.Contract_Main_ID = contract_main.Renewal_Of_Contract_Main_ID
			LEFT JOIN Contract_Main AS Rolled_Over_Contract_Main
			ON Rolled_Over_Contract_Main.Contract_Main_ID = Contract_Main.Rollover_from_Contract_Main_ID
			LEFT JOIN Program_Control_Panel_Options
			ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
WHERE		Contract_Main.contract_main_id	=	'#contract_main_id#'
</CFQUERY>

<!--- Get the Program ID's of the Contract (including revisions) --->
	<cfquery name="getStoredHistory" datasource="#application.datasource#">
		SELECT * FROM Program_History
		WHERE Contract_Number IN
			(SELECT Contract_Number FROM Contract_Main
		WHERE Contract_Main_ID =	'#contract_main_id#')
		AND Deleted = 0
		ORDER BY CONTRACT_Main_ID DESC, Program_History_Action_ID DESC
	</cfquery>

	<cfif getStoredHistory.recordCount EQ 0>
		<!--- Get the persons who agreed to the program  --->
		<cfquery name="getProgramAgreed" datasource="#application.datasource#">
			SELECT 	Name_First, Name_Last, Max(Agree_DateTime) Agree_DateTime
			FROM 	Program_Agree pa INNER JOIN _Users u
			ON 		pa.User_Id = u.User_Id
			WHERE 	pa.ProgramID =
					(
					SELECT MIN (Contract_Main_ID)
					FROM Contract_Main
					WHERE Contract_Number = (SELECT Contract_Number FROM Contract_Main
											WHERE Contract_Main_ID =	'#contract_main_id#')
					)
			AND		pa.System_Agreement = 0
			GROUP BY u.User_ID,	u.Name_Last, u.Name_First
		</cfquery>

		<cfquery name="getProgramCreationInfo" datasource="#application.datasource#">
			SELECT	u1.Name_First Creator_Name_First,
					u1.Name_Last Creator_Name_Last,
					u2.Name_First Approver_Name_First,
					u2.Name_Last Approver_Name_Last,
					cm.Contract_Created_Date,
					cm.Approved_By_User_ID,
					cm.Approval_Date,
					cm.Contract_Start_Date,
					cm.Contract_End_Date,
					cm.Revision_version,
					RFA_User.Name_First RFA_User_Name_First,
					RFA_User.Name_Last AS RFA_User_Name_Last,
					cm.Broker_Approved_Date <!---- D34823:  Contract_Main.Broker_Approved_Date -� could not be bound--->
			FROM 	Contract_Main cm
					INNER JOIN _Users u1 ON cm.Creator_ID = u1.User_Id
					LEFT OUTER JOIN _Users u2 ON cm.Approved_By_User_ID = u2.User_Id
					LEFT JOIN _Users RFA_User ON RFA_User.Deleted = 0 AND RFA_User.User_ID = cm.Broker_User_ID
			WHERE 	cm.Contract_Main_ID =
					(
						SELECT MIN (Contract_Main_ID)
						FROM Contract_Main
						WHERE Contract_Number = (SELECT Contract_Number FROM Contract_Main
												WHERE Contract_Main_ID =	'#contract_main_id#')
					)
		</cfquery>
	</cfif>

<BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<HR>
<FONT SIZE="+1">Program number:<CFOUTPUT>#Get_Contract_Number.contract_number#<cfif Get_Contract_Number.Approved eq 1>- <cfif len(Get_Contract_Number.revision_version) eq 4>#right("#Get_Contract_Number.revision_version#", 4)#<cfelseif len(Get_Contract_Number.revision_version) eq 5>#right("#Get_Contract_Number.revision_version#", 5)#<cfelse>#right("000#Get_Contract_Number.revision_version#", 3)#</cfif> </cfif></CFOUTPUT></FONT>
<HR>

<cfoutput><cfif len(trim(Get_Contract_Number.Revision_contract_number)) GT 0>
<FONT SIZE="+1">Original Program: <CFOUTPUT>#Get_Contract_Number.Revision_contract_number# - #Right("000#Get_Contract_Number.original_version#", 3)#</CFOUTPUT></FONT>
<br><strong>#Get_Contract_Number.Revision_Contract_Title#</strong>
<br>#dateformat(Get_Contract_Number.Revision_Contract_start_date, 'mm/dd/yyyy')# - #dateformat(Get_Contract_Number.Revision_Contract_end_date, 'mm/dd/yyyy')#
<hr>
</cfif>
<cfif len(trim(Get_Contract_Number.Renewal_contract_number)) GT 0 and len(trim(Get_Contract_Number.Rolled_Over_Contract_Number)) eq 0>
<FONT SIZE="+1">Copied from Program: <CFOUTPUT>#Get_Contract_Number.Renewal_contract_number# - #Right("000#Get_Contract_Number.revision_version#", 3)#</CFOUTPUT></FONT>
<br><strong>#Get_Contract_Number.Renewal_Contract_Title#</strong>
<br>#dateformat(Get_Contract_Number.Renewal_Contract_start_date, 'mm/dd/yyyy')# - #dateformat(Get_Contract_Number.Renewal_Contract_end_date, 'mm/dd/yyyy')#
<hr>
</cfif>

<cfif len(trim(Get_Contract_Number.Rolled_Over_Contract_Number)) GT 0>
<FONT SIZE="+1">Rolled Over from Program: <CFOUTPUT>#Get_Contract_Number.Rolled_Over_Contract_Number#</CFOUTPUT></FONT>
<br><strong>#Get_Contract_Number.Rolled_Over_Contract_Title #</strong>
<br>#dateformat(Get_Contract_Number.Rolled_Over_Contract_Start_Date, 'mm/dd/yyyy')# - #dateformat(Get_Contract_Number.Rolled_Over_Contract_End_Date, 'mm/dd/yyyy')#
<hr>
</cfif>


</cfoutput>
</BLOCKQUOTE>
<cfif isdefined("URL.CID")>
<cfif getStoredHistory.recordCount GT 0 and url.popUp eq 0>
<DIV ALIGN="center">
	<CF_button
		button_name		=	""
		button_caption	=	"return to view program"
		button_action	=	"contract_edit_menu.cfm?CID=#URL.CID#"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"return to program summary"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	<BR>
</div>
</cfif>
</cfif>

<cfoutput query="getStoredHistory">
#Contract_Details#<br />

	<cfif Get_Contract_Number.Include_Competitive_Data_Tracking EQ 1>
		<cfset DispalyCompetitiveDataHistory(ContractMainID="#getStoredHistory.contract_Main_ID#")>
	</cfif>

<cfif getStoredHistory.recordCount EQ 0>
<TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="80%" class="ChangeLog">
	<TR>
		<TD valign="top" class="Heading" style="background-color:#ColorBackground#">Version</TD>
		<TD valign="top" class="heading" style="background-color:#ColorBackground#">Created By</TD>
		<TD valign="top"  class="heading" style="background-color:#ColorBackground#">RFA By</TD>
		<cfif getProgramAgreed.Recordcount neq 0>
		<TD valign="top" class="heading" style="background-color:#ColorBackground#">Agreed By</TD>
		</cfif>
		<TD valign="top" class="heading" style="background-color:#ColorBackground#">Approved By</TD>
		<TD valign="top" class="heading" style="background-color:#ColorBackground#">Contract Span</TD>
	</TR>
	<TR>
		<TD valign="top"><cfif len(getProgramCreationInfo.revision_version) eq 4>#right("#getProgramCreationInfo.revision_version#", 4)#<cfelseif len(getProgramCreationInfo.revision_version) eq 5>#right("#getProgramCreationInfo.revision_version#", 5)#<cfelse>#right("000#getProgramCreationInfo.revision_version#", 3)#</cfif>&nbsp;</TD>
		<TD valign="top">#getProgramCreationInfo.Creator_Name_First#&nbsp;#getProgramCreationInfo.Creator_Name_Last#&nbsp;(#DateFormat(getProgramCreationInfo.Contract_Created_Date,"M/D/YYYY")# #TimeFormat(getProgramCreationInfo.Contract_Created_Date, "short")#)&nbsp;</TD>
		<TD valign="top"><cfif getProgramCreationInfo.RFA_User_Name_First neq "">#getProgramCreationInfo.RFA_User_Name_First#&nbsp;#getProgramCreationInfo.RFA_User_Name_Last#&nbsp;(#DateFormat(getProgramCreationInfo.Broker_Approved_Date,"M/D/YYYY")# #TimeFormat(getProgramCreationInfo.Broker_Approved_Date, "short")#)</cfif>&nbsp;</TD>
		<cfif getProgramAgreed.Recordcount neq 0>
		<TD valign="top"><cfloop query="getProgramAgreed">#Name_First#&nbsp;#Name_Last#&nbsp;(#DateFormat(Agree_DateTime,"M/D/YYYY")# #TimeFormat(Agree_DateTime, "h:mm tt")#)<br/></cfloop>&nbsp;</TD>
		</cfif>
		<TD valign="top"><cfif getProgramCreationInfo.Approver_Name_First neq "">#getProgramCreationInfo.Approver_Name_First#&nbsp;#getProgramCreationInfo.Approver_Name_Last#&nbsp;(#DateFormat(getProgramCreationInfo.Approval_Date,"M/D/YYYY")# #TimeFormat(getProgramCreationInfo.Approval_Date, "short")#)</cfif>&nbsp;</TD>
		<TD valign="top">#DateFormat(getProgramCreationInfo.Contract_Start_Date,"MM/DD/YYYY")#-#DateFormat(getProgramCreationInfo.Contract_End_Date,"M/D/YYYY")#&nbsp;</TD>
	</TR>
</TABLE>
</cfif>
</cfoutput>

<cfif Get_Contract_Number.Include_Competitive_Data_Tracking EQ 1>
	<cfif getStoredHistory.recordCount EQ 0>
		<cfquery name="getContarctMainID" datasource="#application.datasource#">
			SELECT contract_main_id
			FROM contract_main
			WHERE Contract_Number IN
				(SELECT Contract_Number FROM Contract_Main
			WHERE Contract_Main_ID =	'#contract_main_id#')
			AND Deleted = 0
			ORDER BY CONTRACT_Main_ID DESC
		</cfquery>
		<cfoutput query="getContarctMainID">
			<cfset DispalyCompetitiveDataHistory(ContractMainID="#contract_main_id#")>
		</cfoutput>
	</cfif>
</cfif>

<!--- D29824:New Settings.. --->
<cfset Program = CreateObject("component","components.programs.Program")/>


<cfset template_history = Program.TemplateChangeHistory(#Get_Contract_Number.contract_number#)>
<cfoutput>
	<cfif template_history.recordcount> <!--- D30421 : Event error when viewing program History START --->
		<TABLE cellpadding="3" cellspacing="0" border="0" width="80%" align="center" class="ChangeLog">
			<TR style="font-size:12px;font-weight:bold;background-color:#ColorBackground#">
				<TD>WHAT</TD>
				<TD>FROM</TD>
				<TD>TO</TD>
				<TD>ACTION</TD>
			</TR>
	<cfloop query="template_history">
		<cfset left_postion = (#find('TO', notes)# - 3)>
		<cfset right_postion = #len(notes)# - (#left_postion# + 5)>
			<TR>
				<TD>Template  (Changed on #dateformat(created_date,'mm/dd/yyyy')#)</TD>
				<TD>#RemoveChars(left(notes, left_postion), 1,5)#</TD>
				<TD>#right(notes, right_postion)#</TD>
				<TD style="color:green;font-weight:bold;">Changed</TD>
			</TR>
	</cfloop>
		</TABLE>
	</cfif><!--- D30421 : Event error when viewing program History END --->
</cfoutput>
<!--- D29824:New Settings.. --->


<!---bid request data--->
<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
<cfset qGetUserName = createObject("component","components.user.usermanager").init()>
<cfset bidRequestObj = createObject("component", "components.programs.bid_request.BidRequestStatus")>

<!---get bid history for this program--->
<cfset lastBidHistory = bidRequestManager.getBidHistory(contract_main_id)>

<cfoutput>
<cfif lastBidHistory.recordcount>
<br>
<TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="600px" class="ChangeLog">
	<TR>
		<TD colspan="100%" style="font-size:12px;font-family:Century Gothic;font-weight:bold;background-color:#ColorBackground#;">
			PROPOSAL STATUS HISTORY
			<cfif lastBidHistory.recordcount GT 1>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<cfset linkString = "<strong><font color=red>[</font> view all <font color=red>]</font></strong>">
				<span
					id="historyLink"
					style="cursor:pointer;color:blue;font-size:10px;"
					onMouseOver="this.style.color='red'"
					onMouseOut="this.style.color='blue'"
					onclick="
						if ($('bidHistory').style.display == 'none'){
							new Effect.BlindDown($('bidHistory'),{duration:.400});
							this.innerHTML = '#linkString#';
						} else {
							new Effect.BlindUp($('bidHistory'),{duration:.200});
							this.innerHTML = '#linkString#';
						};
					">#linkString#</span>
			</cfif>
		</TD>
	</TR>
	<TR>
		<TD colspan="100%">
				<strong><a href="mailto:#lastBidHistory.user_email#">#lastBidHistory.user_full_name#</a></strong> last updated the bid status to <strong>#lastBidHistory.Status_Desc#</strong> on
				<strong>#dateformat(lastBidHistory.updated_datetime,'MMM DD, YYYY')#</strong> at <strong>#timeformat(lastBidHistory.updated_datetime,'h:mm tt')#</strong>
		</TD>
	</TR>
</TABLE>
<div id="bidHistory" style="display:none;margin-top:2px;">
	<TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="600px" style="border:1px solid black;" class="ChangeLog">
		<TR>
			<TD valign="top" class="heading" style="background-color:#ColorBackground#;font-weight:bold;">Updated By</TD>
			<TD valign="top" class="heading" style="background-color:#ColorBackground#;font-weight:bold;">Status</TD>
			<TD valign="top" class="heading" style="background-color:#ColorBackground#;font-weight:bold;">Date</TD>
		</TR>
		<cfloop query="lastBidHistory">
			<cfif currentrow mod 2>
				<cfset style = "background-color:##FFFFE0;">
			<cfelse>
				<cfset style = "">
			</cfif>
			<tr>
				<td valign="top" style="#style#">
					<a href="mailto:#lastBidHistory.user_email#">#user_full_name#</a>
				</td>
				<td valign="top" style="#style#">
					#Status_Desc#
				</td>
				<td valign="top" style="#style#">
					#dateformat(updated_datetime,'MMM DD, YYYY')# at #timeformat(updated_datetime,'h:mm tt')#<br />
				</td>
			</tr>
		</cfloop>
	</TABLE>
</div>
</cfif>
</cfoutput>

</blockquote></blockquote>
<cfif isdefined("URL.CID") and url.popUp eq 0>
<DIV ALIGN="center">
	<CF_button
		button_name		=	""
		button_caption	=	"return to view program"
		button_action	=	"contract_edit_menu.cfm?CID=#URL.CID#"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"return to program summary"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- ----------------------39231 tracking/displaying the changes to the Competitive Data page on the history page start ---------------------- --->
<cffunction name="DispalyCompetitiveDataHistory"> DispalyCompetitiveDataHistory(ContractMainID="#getStoredHistory.contract_Main_ID#">
<cfargument name="ContractMainID" type="string" required="true" default="">
<cfquery name="getHistoryPPBI" datasource="#application.datasource#">
	select 	hppbi.product_ID,hppbi.Updated_Date, Name_First, Name_Last,hppbi.Updated_By,
		ISNULL(BSA_Foodservice_Items_Master.Item,(select Group_Number from All_Product_Group_Types where Group_GUID = hppbi.product_ID)) as Item,
		BSA_Foodservice_Items_Master.Item as IsGroup,
		case hppbi.won when 1 then 'Won' when 0 then 'Loss' end as won,
		case hppbi.Shared when 1 then 'Yes' else 'No' end as Shared,
		case hppbi.Incremental when 1 then 'Yes' else 'No' end as Incremental,
		case hppbi.Specd when 1 then 'Yes' else 'No' end as Specd
	from History_Program_Product_Bid_Info hppbi
	inner join BSA_Foodservice_Items_Master on hppbi.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	inner join _Users on hppbi.Updated_By = _Users.User_ID
	where hppbi.Program_ID =  '#arguments.ContractMainID#'
	and hppbi.Updated_by is not NULL
UNION
	select 	ppbi.product_ID,ppbi.Updated_Date, Name_First, Name_Last,ppbi.Updated_By,
		ISNULL(BSA_Foodservice_Items_Master.Item,(select Group_Number from All_Product_Group_Types where Group_GUID =ppbi.product_ID)) as Item,
		BSA_Foodservice_Items_Master.Item as IsGroup,
		case ppbi.won when 1 then 'Won' when 0 then 'Loss' end as won,
		case ppbi.Shared when 1 then 'Yes' else 'No' end as Shared,
		case ppbi.Incremental when 1 then 'Yes' else 'No' end as Incremental,
		case ppbi.Specd when 1 then 'Yes' else 'No' end as Specd
	from Program_Product_Bid_Info ppbi
	inner join BSA_Foodservice_Items_Master on ppbi.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	inner join _Users on ppbi.Updated_By = _Users.User_ID
	where ppbi.Program_ID =  '#arguments.ContractMainID#'
	and ppbi.Deleted = 0
	and ppbi.Updated_by is not NULL
	order by product_ID, Updated_Date
</cfquery>

<cfset prev_won = "" />
<cfset prev_Shared = "" />
<cfset prev_Incremental = "" />
<cfset prev_Specd = "" />
<cfset prev_ProductID = "" />
<cfset CountMod = 0>
<cfif getHistoryPPBI.recordcount GT 0>
<cfoutput>
 	<TABLE cellpadding="3" align="center" cellspacing="0" border="0" width="80%" class="ChangeLog">

		<TR>
			<TD  class="heading" style="background-color:FFDE84" colspan="2">WHAT (Competitive Data)</TD>
			<TD  class="heading" style="background-color:FFDE84">FROM</TD>
			<TD  class="heading" style="background-color:FFDE84">TO</TD>
			<TD  class="heading" style="background-color:FFDE84">ACTION</TD>
		</TR>
		<cfloop query ="getHistoryPPBI">
		<cfif  #prev_ProductID#  neq  #getHistoryPPBI.product_ID#>
			<cfset prev_won = "" />
			<cfset prev_Shared = "" />
			<cfset prev_Incremental = "" />
			<cfset prev_Specd = "" />
			<cfset prev_ProductID = "" />
			<cfset TDbackgroundcolor = "" />
			<cfset CountMod = CountMod +1>
		</cfif>
		<cfif   prev_won neq getHistoryPPBI.won >
 			<TR valign="top" <cfif CountMod MOD 2>BGCOLOR="ffffff"<cfelse>BGCOLOR="eeFFee"</cfif>>
				<TD><cfif len(IsGroup) GT 0> Item :: <cfelse>Group :: </cfif><b>#Item#</b></TD>
				<TD align="right">Status &nbsp;</TD>
				<TD>#prev_won# &nbsp;</TD>
				<TD>#getHistoryPPBI.won# &nbsp;</TD>
				<TD>
				Changed by #Name_First# #Name_Last#  on #dateFormat(getHistoryPPBI.updated_Date,"mm/dd/yyyy")# #timeFormat(getHistoryPPBI.updated_Date,"hh:mm")# &nbsp;
			</TD>
			</TR>
		</cfif>
		<cfif   prev_Shared neq getHistoryPPBI.Shared >
 			<TR valign="top" <cfif CountMod MOD 2>BGCOLOR="ffffff"<cfelse>BGCOLOR="eeFFee"</cfif>>
				<TD><cfif len(IsGroup) GT 0> Item :: <cfelse>Group :: </cfif><b>#Item#</b></TD>
				<TD align="right">Shared &nbsp;</TD>
				<TD>#prev_Shared# &nbsp;</TD>
				<TD>#getHistoryPPBI.Shared# &nbsp;</TD>
				<TD>
					Changed by #Name_First# #Name_Last#  on #dateFormat(getHistoryPPBI.updated_Date,"mm/dd/yyyy")# #timeFormat(getHistoryPPBI.updated_Date,"hh:mm")# &nbsp;
				</TD>
			</TR>
		</cfif>
		<cfif   prev_Incremental neq getHistoryPPBI.Incremental >
 			<TR valign="top" <cfif CountMod MOD 2>BGCOLOR="ffffff"<cfelse>BGCOLOR="eeFFee"</cfif>>
				<TD><cfif len(IsGroup) GT 0> Item :: <cfelse>Group :: </cfif><b>#Item#</b></TD>
				<TD align="right">Incremental &nbsp;</TD>
				<TD>#prev_Incremental# &nbsp;</TD>
				<TD>#getHistoryPPBI.Incremental# &nbsp;</TD>
				<TD>
					Changed by #Name_First# #Name_Last#  on #dateFormat(getHistoryPPBI.updated_Date,"mm/dd/yyyy")# #timeFormat(getHistoryPPBI.updated_Date,"hh:mm")#&nbsp;
				</TD>
			</TR>
		</cfif>
		<cfif    prev_Specd neq getHistoryPPBI.Specd >
 		<TR valign="top" <cfif CountMod MOD 2>BGCOLOR="ffffff"<cfelse>BGCOLOR="eeFFee"</cfif>>
			<TD><cfif len(IsGroup) GT 0> Item :: <cfelse>Group :: </cfif><b>#Item# </b> </TD> <!---#getHistoryPPBI.product_ID# --->
			<TD align="right">Specd &nbsp;</TD>
			<TD>#prev_Specd# &nbsp;</TD>
			<TD>#getHistoryPPBI.Specd# &nbsp;</TD>
			<TD>
				Changed by #Name_First# #Name_Last#  on #dateFormat(getHistoryPPBI.updated_Date,"mm/dd/yyyy")# #timeFormat(getHistoryPPBI.updated_Date,"hh:mm")# &nbsp;
			</TD>
		</TR>
		</cfif>

		<cfset prev_won = "#getHistoryPPBI.won#" />
		<cfset prev_Shared = "#getHistoryPPBI.Shared#" />
		<cfset prev_Incremental = "#getHistoryPPBI.Incremental#" />
		<cfset prev_Specd = "#getHistoryPPBI.Specd#" />
		<cfset prev_ProductID = "#getHistoryPPBI.product_ID#" />
		</cfloop>
	</TABLE>
</cfoutput>
</cfif> <!--- end of <cfif getHistoryPPBI.recordcount GT 0> --->
</cffunction>
<!--- ----------------------39231 tracking/displaying the changes to the Competitive Data page on the history page end ---------------------- --->
