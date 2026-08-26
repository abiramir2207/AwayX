<!----
	Filename:	C:\Work\Code\base\AwayX\settings\reactivate_programs.cfm
	Created:	12/22/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		we use this page to reactive cancelled programs.
---->
<CFPARAM NAME="URL.DOSEARCH" default="0">
<CFPARAM NAME="URL.Program_Desc" DEFAULT="">
<CFPARAM NAME="URL.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="URL.Start_date" DEFAULT="">
<CFPARAM NAME="URL.End_date" DEFAULT="">
<cfparam NAME="URL.Sort_by" 	default="Contract_Number">
<cfparam NAME="URL.Sort_by_previous" 	default="Contract_Number">
<cfparam NAME="URL.Sort_Order" 	default="DESC">
<cfoutput>
<CFPARAM NAME="Form.DOSEARCH" default="#URL.DOSEARCH#">
<CFPARAM NAME="FORM.Program_Desc" DEFAULT="#URL.Program_Desc#">
<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="#URL.Start_date_Operator#">
<CFPARAM NAME="FORM.Start_date" DEFAULT="#URL.Start_date#">
<CFPARAM NAME="FORM.End_date" DEFAULT="#URL.End_date#">
<CFSET Input_Select_Width = 150>
</cfoutput>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset programManager = CreateObject("component", "components.programs.program") />
<cfif isDefined("url.ProgramID") and URL.ProgramID NEQ "">
	<cfoutput>	
	<cfset useLakebaseForLatestContractMain = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForLatestContractMain>
	<cftry>
		<cfset LatestContractMain = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#URL.ProgramID#",
				"order" = "contract_main_id.desc",
				"limit" = "1",
				"select" = "contract_main_id,contract_number"
			}), "contract_main_id,contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLatestContractMain = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLatestContractMain>
<cfquery name="LatestContractMain" datasource="#application.datasource#">
		SELECT TOP 1 Contract_Main_ID, Contract_Number FROM Contract_Main WHERE Contract_Main_ID = '#URL.ProgramID#'
		ORDER BY Contract_Main_ID Desc
	</cfquery>
</cfif>
	
	<cfquery name="UndeleteProgram" datasource="#application.datasource#">
		UPDATE Contract_Main
		SET 	Deleted = 0,
			Force_Expiration_Flag = 0,
			Flagged_As_Purged = 0,
			Manual_Cancel = 0,
			Cancelled_By = NULL,
			Cancelled_Date = NULL,
			UnDeleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
			UnDeleted_On = GetDate(),
			Available_In_RDE = 0
		WHERE Contract_Main_ID = <cfqueryparam value="#URL.ProgramID#" cfsqltype="cf_sql_integer" >
	</cfquery>

	<cfquery name="UnCancelProgram" datasource="#application.datasource#">
		UPDATE 	Contract_Main
		SET 	Manual_Cancel = 0,
				Cancelled_By = NULL,
				Cancelled_Date = NULL,
				End_Date_Changed_On_Cancel = 0,
				Cancel_And_End_Dated = 0,
				UnDeleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
				UnDeleted_On = GetDate()
		WHERE 	Contract_Number = <cfqueryparam value="#LatestContractMain.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
		AND		Manual_Cancel = 1
	</cfquery>

	<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#LatestContractMain.Contract_Main_ID#" null="no">

	</cfstoredproc>
	
	<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() EQ 1>
		<cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').refreshCommittedForProgram(programId = LatestContractMain.Contract_Main_ID) />
	</cfif>
<!--- Dev Note: Milan; D8508 (Unlock the program after undeleting it) --->
	<cfset programManager.setLockStatus(URL.ProgramID,0,request.AccessStructure.User_ID)>
<!--- End Note: Milan; D8508 --->

	</cfoutput>

</cfif>

<HTML>

<BODY>
<CFSET URL.PageTitle="Reactivate Programs">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<STYLE TYPE="text/css">
Body, 
TD
{
	font: 12px Arial;
},
a 
{
	color: Blue;
	text-decoration: none;
}
</STYLE>

<script>
function viewContract(program_id)
{
NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id,'ViewProgram','800','600','Yes', 'Yes');
}

function doReactivate(contractNumber,contractMainID)
{
	var bContinue = true;

		bContinue = window.confirm("Do you want to reactivate program " + contractNumber + " ?") ;

	if(bContinue)
	{
		var sURL = "Reactivate_programs.cfm?ProgramID=" + contractMainID;
		window.location.href = sURL;
	}
	
	return false;
}
function enableEndDate(thisObj)
{
	var spName = "SP_End_date";
	var bDis = (thisObj.selectedIndex != 3) ? true: false;
	disableDiv(spName,bDis,false);
}
function disableEndDate()
{
		enableEndDate(document.all.Start_date_Operator);
		document.all.Start_date.style.fontSize=10;
		document.all.End_date.style.fontSize=10;
		document.all.Start_date.style.width = "<CFOUTPUT>#Evaluate("#Input_Select_Width#-50")#</CFOUTPUT>px";
		document.all.End_date.style.width = "<CFOUTPUT>#Evaluate("#Input_Select_Width#-50")#</CFOUTPUT>px";
}

document.body.onload=new Function ("disableEndDate();")

function doSearchNow()
{
	var isError = 0;
	var selected_index = SearchForm.elements["Start_date_Operator"].selectedIndex; 
	var selected_option_value = SearchForm.elements["Start_date_Operator"].options[selected_index].value;
	if (SearchForm.Program_Desc.value == "" && SearchForm.Start_date.value == "")
	{
		alert("Please enter at least one search criterion.");
		isError = 1; 
	}
	if (isError == 0)
			{
				SearchForm.submit();
				//statusHandler();
			}
	return false;
}
</script>

<FORM ACTION="reactivate_programs.cfm" METHOD="post" NAME="SearchForm" target="mainwindow">
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="90%">
  <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Reactivate Programs Search</LEGEND>
	<center>
	<TABLE  CELLPADDING="1" CELLSPACING="0" >
	<TR>
		<TD valign="bottom">
			<CF_SmallHelp
					width="200"
					displayShifyX = "-20"
					imgPath="/images/help_small.gif"
					imgWidth="14"
					imgHeight="13"
					dropdownCheck="0"
					>
					<center>Search Program #, Title.</center>
			</CF_SmallHelp>
			<span ID="searchItemLabel">Program</span>
		</TD>
		<TD valign="bottom">
			<span ID="searchItemLabel">Cancelled Date</span>
		</TD>
		<TD valign="bottom"></TD>
	</TR>
	<TR>
		<TD valign="top" nowrap="nowrap">
			<input type="text" SIZE="40" Name="Program_Desc" value="<cfoutput>#form.Program_Desc#</cfoutput>">&nbsp;	
		</TD>
		<CFSET Date_Operators="Equal,Less_Or_Equal,Greater_Or_Equal,between">
		<CFSET Date_Operator_Symbols="=,<,>,between">
		<TD valign="top" nowrap="nowrap">
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD><cfoutput>
						<SELECT OnChange="JavaScript: enableEndDate(this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:68px">
							<CFSET cnt=0>
							<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
								<CFSET cnt=cnt+1>
								<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
							</CFLOOP>
						</SELECT>
						</cfoutput>
					</TD>
					<TD>
						<SPAN ID="SP_Start_date">
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
						</SPAN>
					</TD>
					<TD>&nbsp;&nbsp;&nbsp;</TD>
					<TD>
						<SPAN ID="SP_End_date">
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
						</SPAN>
					</TD>
				</TR>
			</TABLE>
		</TD>
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
		<TD ALIGN="left" valign="bottom" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search programs</a><FONT COLOR="#FF0000">]</FONT></B>&nbsp;&nbsp;
		<B><FONT COLOR="#FF0000">[</FONT><a href="reactivate_programs.cfm" target="mainwindow">reset</a><FONT COLOR="#FF0000">]</FONT></B>
		</TD>
	</TR>
  </TABLE>
  </center>
</FIELDSET>
</FORM>
	
<CFIF Form.DOSEARCH EQ 1>
	<cfif Sort_by NEQ Sort_by_previous>
		<cfif Sort_by EQ "Contract_Number" OR Sort_by EQ "Approved" OR Sort_by EQ "Contract_Main.Contract_Created_Date"  OR Sort_by EQ "Contract_Main.Deleted_Date">
			<cfset Sort_Order = "DESC"/>
		</cfif>
		<cfset Sort_by_previous = #Sort_by#>
	</cfif>

	<cfquery name="GetReactivatePrograms" datasource="#application.datasource#">
	SELECT Contract_Main.contract_main_id,Contract_Main.Contract_Number, Contract_Main.Contract_Title, Contract_Main.Approved,Approval_Date,revision_version, 
	Contract_Main.Contract_Created_Date,Contract_Main.cancelled_Date, Contract_Main.Cancelled_By, Contract_Main.Approval_Date, Contract_Main.Contract_Lock_Date, Contract_Main.Contract_Status_Type_IDX, 
	UC.Name_First + ' ' + UC.Name_Last AS User_Created, UE.Name_First + ' ' + UE.Name_Last AS User_Edited, UA.Name_First +  ' ' + UA.Name_Last AS User_Approved, 
	UL.Name_First +  ' ' +UL.Name_Last AS User_Locked, UCD.Name_First + UCD.Name_Last User_Cancelled, Contract_Main.Contract_Lock_Date, Contract_Main.Deleted_Date,
	Contract_Main.Flagged_As_Purged
	FROM Contract_Main
	LEFT JOIN _Users UA
	ON UA.User_ID = Contract_Main.Approved_By_User_ID
	INNER JOIN _Users UC
	ON UC.User_ID = Contract_Main.Creator_ID
	INNER JOIN _Users UE
	ON UE.User_ID = Contract_Main.Editor_ID
	LEFT JOIN _Users UL
	ON UL.User_ID = Contract_Main.Contract_Locked_By_User_ID
	LEFT JOIN _Users UCD
	ON UCD.User_ID = Contract_Main.Cancelled_By
	WHERE Contract_Main.Deleted = 0
	AND Contract_Main.Force_Expiration_Flag = 1
	AND Contract_Main.Manual_Cancel = 1
	<CFIF FORM.Program_Desc NEQ "">
		AND (Contract_Main.Contract_Number like '%#FORM.Program_Desc#%'
		OR Contract_Main.Contract_Title like '%#FORM.Program_Desc#%' )
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Greater_Or_Equal" and FORM.Start_date NEQ "">
		AND Contract_Main.cancelled_Date > '#FORM.Start_date#'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Equal" and FORM.Start_date NEQ "">
		AND Contract_Main.cancelled_Date > '#FORM.Start_date# 00:00:00.000' 
		AND Contract_Main.cancelled_Date < '#FORM.Start_date# 23:59:59.000'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Less_Or_Equal" and FORM.Start_date NEQ "">
		AND Contract_Main.cancelled_Date < '#FORM.Start_date#'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Between" and FORM.Start_date NEQ "" and FORM.End_date NEQ "">
		AND Contract_Main.cancelled_Date >= '#FORM.Start_date#'
		AND Contract_Main.cancelled_Date <= '#FORM.End_date#'
	</CFIF>
	ORDER BY #Sort_by# #Sort_Order#, contract_main_id DESC
	</cfquery>

	<cfif FindNoCase("DESC", "#Sort_Order#")>
		<cfset Sort_Img = "up_1.gif">
		<cfset Sort_Order =""/>
	<cfelse>
		<cfset Sort_Img = "down_1.gif">
		<cfset Sort_Order ="DESC"/>
	</cfif>

	<table width="100%" cellpadding="2" cellspacing="0" border="0" class="maintable">
	<tr>
		<cfoutput>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=Contract_Number&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Contract Number</strong><cfif sort_by EQ "Contract_Number"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A> </td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=revision_version&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Version</strong><cfif sort_by EQ "revision_version"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=Contract_Title&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Contract Title</strong><cfif sort_by EQ "Contract_Title"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=Approved&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Approved</strong><cfif sort_by EQ "Approved"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=User_Approved&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Approved By</strong><cfif sort_by EQ "User_Approved"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=User_Created&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Created By<cfif sort_by EQ "User_Created"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
			<br><A HREF="Reactivate_programs.cfm?Sort_by=Contract_Main.Contract_Created_Date&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#">Created On<cfif sort_by EQ "Contract_Main.Contract_Created_Date"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></strong></td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=User_Edited&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Edited By</strong><cfif sort_by EQ "User_Edited"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Reactivate_programs.cfm?Sort_by=User_Deleted&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Cancelled By<cfif sort_by EQ "User_Deleted"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
			<br><A HREF="Reactivate_programs.cfm?Sort_by=Contract_Main.Deleted_Date&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#">Cancelled On<cfif sort_by EQ "Contract_Main.Deleted_Date"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></strong></td>
	<td bgcolor="orange" align="center"><strong>Reactivate</strong></td>
		</cfoutput>
	</tr>

	<cfoutput query="GetReactivatePrograms">
		<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<cf_cryp type="en" string ="#GetReactivatePrograms.contract_main_id#" key="#request.key#">
			<cfset ContractID = cryp.value>
			<td nowrap><A STYLE="cursor:pointer;" ONCLICK="viewContract('#ContractID#')">#Contract_Number#</A></td>
			<td>&nbsp;&nbsp;<cfif Approved IS 1>#revision_version#<cfelse>0</cfif></td>
			<td width='200'>#Contract_Title#&nbsp;</td>
			<td><cfif Approved IS 1>Yes<cfelse>No</cfif></td>
			<td>#User_Approved#&nbsp; <br> #dateformat(Approval_Date, 'mm/dd/yy')#</td>
			<td nowrap>#User_Created#<br>#dateformat(Contract_Created_Date, 'mm/dd/yy')#</td>
			<td>#User_Edited#&nbsp;</td>
			<td><Cfif len(trim(User_Cancelled)) GT 0>#User_Cancelled#<cfelse>NA</CFIF><br>
			<cfif len(trim(cancelled_Date)) GT 0>#dateformat(cancelled_Date, 'mm/dd/yy')#<cfelse>NA</cfif></td>
			<td align="center"><a href="##" onclick="javaScript: return doReactivate('#contract_Number#','#contract_main_id#');"><img src="/images/checkmark.gif" border="0" style="cursor: pointer;"></a></td>
		</tr>
	</cfoutput>
	</table>
	<BR>
	<cfif GetReactivatePrograms.recordcount GT 0>
		<FONT COLOR="Red" SIZE="2"><B>There are <cfoutput>#GetReactivatePrograms.recordcount#</cfoutput> programs that match the specified criteria</B></FONT>
	<cfelse>
		<FONT COLOR="Red" SIZE="2"><B>There are no programs that match the specified criteria</B></FONT>
	</cfif>		
</CFIF>

</body>
</html>




