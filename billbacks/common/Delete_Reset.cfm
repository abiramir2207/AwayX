<cfparam name="FromFlex" default="0">
<cfparam name="IsAutoBB" default="0">

<CFSET upd_This_Billback = 1>

<CFIF NOT isDefined("URL.BBID")>
	<CFSET upd_This_Billback = 0>
</CFIF>

<CFSET variables.BBMan = CreateObject("component", "components.billback.BillbackManager") />

<CFSET tempString = CGI.HTTP_REFERER>
<CFSET tempString = reverse(tempString)>

<CFSET tempString = listtoarray(tempString, "/")>
<CFSET tempString = tempString[1]>
<CFSET tempString = reverse(tempString)>

<CFIF listlen(tempString, "?") GT 1>
	<CFSET tempString = listtoarray(tempString, "?")>
	<CFSET tempString = tempString[1]>
</CFIF>
<CFSET HTTP_REFERER_FileName = tempString>

<CFIF lcase(HTTP_REFERER_FileName) NEQ lcase("index.cfm") AND FromFlex eq 0>
	<CFSET upd_This_Billback = 0>
</CFIF>
<cfset appSettings = application.appSettingsGet />
<CFIF upd_This_Billback>
	<CFSET Billback_ID = URL.BBID>
	
	<CFQUERY name="BB_Info" datasource="#Application.Datasource#">
		SELECT	BB_Code, 
				BB_Title, 
				Billback_Status_ID,
				BB_Payment_Request_Sent,
				BB_Received_Ack_Type,
				BB_Approved_Void_Ack_Type,
				DD_Closure_Sent_On
		FROM	Billback
		WHERE
				Billback.Billback_ID = '#Billback_ID#' AND
				Billback.Deleted = 0
	</CFQUERY>
	<CFQUERY name="GetAssociatedDD" datasource="#Application.Datasource#">
		SELECT 	Deductions.Deduction_ID, 
				Deductions.DD_DedID_SP_Number 
		FROM 	DD_Closure_Detail 
		INNER JOIN Deductions 
		ON 		Deductions.Deduction_ID = DD_Closure_Detail.Deduction_ID 
		AND		DD_Closure_Detail.DD_Closure_ID = '#Billback_ID#' 
		AND 	DD_Closure_Detail.Deleted = 0 
		AND		Deductions.Deleted = 0
	</CFQUERY>
	<cfquery name="checkifpullbackfromthisprg" datasource="#application.datasource#">
					select Pullback_applied_Amount,
							BB_pullbacks_applied 
					from
					BB_Approved
					where billback_id = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<CFIF BB_Info.recordCount GT 0>
		<HTML>
		<HEAD>
		</HEAD>
		<BODY>
		<BLOCKQUOTE>
			<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
			</SCRIPT>
			<SCRIPT LANGUAGE="JavaScript">

				document.body.onload=new Function ("popupInit();")
				
				function initTheTooltip()
				{
					popUp(-1)
				}
				
				
				function Delete_Goto_NextPage()
				{
					var formObj = document.all.MyForm;
					if(formObj.DeleteBillback.checked)
					{
						if(window.confirm("Once you delete this billback, you won't be able to bring it back.\nDo you want to delete anyway?"))
						{
							formObj.submit();
						}
					}
				}
				function Reset_Goto_NextPage()
				{
					var formObj = document.all.MyForm;
					if(formObj.ResetBillback.checked)
					{
						NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=3&Formname=MyForm&BBID='+document.all.Billback_ID.value+'&EDIT=1','BB_BusiConsi','800','400','Yes', 'Yes')		
						//formObj.submit();
					}
				}
			</SCRIPT>
<!--- The height for the div (tooltip) below works only for IE 10. I removed the height below as even without the height, the tooltip can be seen.
The other option is to add the height which will work for IE 10 onwards.
--->				
<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: F5F5DC; z-index: 5000;width:230;border:1px solid black;">
<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0">
 	<TR>
		<TD>
			<IMG SRC="/images/wip.gif" TITLE="Work in progress.">&nbsp;Work In Progress
		</TD>
		<TD>
			<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">&nbsp;Ready For Approval
		</TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/preactive.gif" TITLE="Approved.">&nbsp;Approved
		</TD>
	<CFIF LCase(application.returned_customer_setting.customer_keyword) EQ "conagra">
		<TD>
			<IMG SRC="/images/active.gif" TITLE="Payment Request">&nbsp;Payment Request
		</TD>
	</TR>
	<TR>
	</CFIF>
		<TD>
			<IMG SRC="/images/expired.gif" TITLE="Paid">&nbsp;Paid
		</TD>
	</TR>
	
</TABLE>
</DIV>
			<BR>
			<CENTER>
			<h2><CFOUTPUT>
			Billback: 
			<CFSWITCH EXPRESSION="#BB_Info.Billback_Status_ID#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>				
				<CFCASE VALUE="3">
					<!--- Active Programs --->
					<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Archived/Expired --->
					<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>																	
			</CFSWITCH>
			[#(BB_Info.BB_Code)#] #BB_Info.BB_Title#</CFOUTPUT></h2>
			</CENTER>
			<CENTER>
				<FONT COLOR="#FF0000" SIZE="+1">
				<CFSET AllowUpd = 1>
				<!-----------------------------------------------------------
				Find the Payee
				Billback_Payee_Type_ID
				Payee_ID
				------------------------------------------------------------->				
				<!--- <CFINCLUDE TEMPLATE="/Billbacks/Deviation/BB_Payee.cfm">
				<CFIF NOT IsDefined("INC_Deviation_Constants")>
					<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Constants.CFM">
				</CFIF> --->
				<!--- <CFSET variables.Get_Affected_Billbacks = variables.BBMan.getAffectedBillbacks(Billback_ID,
																								Payee_ID,
																								DEVIATION_CONSTANTS_Trade_Shelter,
																								DEVIATION_CONSTANTS_Operator_Deviated,
																								Billback_Payee_Type_ID) />
				<CFIF variables.Get_Affected_Billbacks.recordcount GT 0>
					<CFSET AllowUpd = 0>
				</CFIF> --->
				
				<CFSET variables.qGetReferencedBillbacks = BBMan.getReferencedBillbacks(Billback_ID) />
				<CFIF variables.qGetReferencedBillbacks.recordcount GT 0>
					<CFSET AllowUpd = 0>
				</CFIF>
				
				<CFIF BB_Info.Billback_Status_ID EQ 4 AND (BB_Info.BB_Payment_Request_Sent EQ 1 AND BB_Info.BB_Received_Ack_Type NEQ 2)>
					<CFSET AllowUpd = 0>
					This billback has been interfaced to the accounting system, Can't delete this.				
				</CFIF>
				
				<!------
				D16732: JRS - On Reset/Delete send reversing entries in interface 
				do not allow delete if this billback has already interfaced in the deduction (1510/900) interface ------->
				<CFIF variables.Action EQ "Delete" AND BB_Info.DD_Closure_Sent_On NEQ "">
					<CFSET AllowUpd = 0>
					This billback has been interfaced to the accounting system, can't delete this.				
				</CFIF>
				
				<!------
				D16732: JRS - On Reset/Delete send reversing entries in interface 
				do not allow reset 
					if this billback has already interfaced in the deduction (1510/900) interface
					and the app switch ""Allow reset after it has interfaced in deduction (1510/900) interface" is OFF 
				------->
				<cfif 	variables.Action EQ "Reset" 
					AND BB_Info.DD_Closure_Sent_On NEQ "" 
					AND	appSettings.getBBAllowResetAfterDEDInterface() EQ 0>
					<CFSET AllowUpd = 0>
					This billback has been interfaced to the accounting system, can't reset this.
				</cfif>
				
				<CFIF GetAssociatedDD.recordCount gt 0>
					<CFSET AllowUpd = 0>
					<cfoutput>
						This billback is associated to deduction #GetAssociatedDD.DD_DedID_SP_Number#.<br>
						Please remove the association and #variables.Action# the billback.
					</cfoutput>
				</CFIF>
				
				<CFIF AllowUpd EQ 1>
					Are you sure you want to <cfoutput>#uCase(variables.Action)#</cfoutput> this billback?
				</CFIF>
				
				</FONT>
				<BR>
				<BR>
				<CFIF AllowUpd EQ 1>
				Please check the "check box" to confirm, and click the "<cfoutput>#variables.Action#</cfoutput> this billback" button 
				</CFIF>
			</CENTER>
			<CFIF AllowUpd EQ 1>
			
				<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" ALIGN="CENTER" WIDTH="50%">
				  <TR>
				<FORM ACTION="bb_<cfoutput>#variables.Action#</cfoutput>2.cfm" METHOD="post" ID="MyForm" NAME="MyForm">
					<TD ALIGN="CENTER">
						<INPUT NAME="<cfoutput>#variables.Action#</cfoutput>Billback" TYPE="checkbox" VALUE="1">
						Yes, I want to <cfoutput>#variables.Action#</cfoutput> this billback.
					</TD>
				</TR>
				<TR>
					<TD ALIGN="CENTER">
				<INPUT NAME="IsAutoBB" TYPE="hidden" VALUE="<CFOUTPUT>#IsAutoBB#</CFOUTPUT>">
				<INPUT NAME="Billback_ID" TYPE="hidden" VALUE="<CFOUTPUT>#Billback_ID#</CFOUTPUT>">
				<input type="hidden" name="removepullbacksapplied" value="<cfoutput>#checkifpullbackfromthisprg.BB_pullbacks_applied#</cfoutput>">
				</FORM>
				<!--- <cfif variables.Action EQ 'Delete'><cfset tmpVar = 'delete'><cfelse><cfset tmpVar = 'reset'></cfif> --->
					<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"#variables.Action# this billback"
					BUTTON_ACTION	=	"javascript:#variables.Action#_Goto_NextPage();"
					BUTTON_TYPE		=	"link"
					BUTTON_WIDTH	=	"125"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">				
					</TD>
				  </TR>
				</TABLE>
			<CFELSE>
				<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;border-top:">
						Not Available for <B STYLE="font-size:14px;color: red;"><cfoutput>#uCase(variables.Action)#</cfoutput></B>.
						</TD>
					</TR>
				</TABLE>	
			</CFIF>
			<CFIF BB_Info.Billback_Status_ID GT 2>
				<CFQUERY name="BB_Approved_Info" datasource="#Application.Datasource#">
					SELECT	Date_Approved, _Users.Name_First + ' ' + _Users.Name_Last AS Approved_User, BB_Approved.Paid_Amount
					FROM	BB_Approved
							LEFT JOIN _Users
							ON
							_Users.User_ID = BB_Approved.User_Approved
							AND
							_Users.Deleted = 0
					WHERE
							BB_Approved.Billback_ID = '#Billback_ID#'								
				</CFQUERY>
				<CFOUTPUT>
				<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;border-top:2px orange solid;border-bottom:2px orange solid;">
						This billback approved on <B>#DateFormat(BB_Approved_Info.Date_Approved, "mm/dd/yyyy")#</B> by <B>#BB_Approved_Info.Approved_User#</B> for amount <B>#DollarFormat(BB_Approved_Info.Paid_Amount)#</B>
						</TD>
					</TR>
				</TABLE>
				</CFOUTPUT>
				
				<CFOUTPUT>
				<!--- <CFIF variables.Get_Affected_Billbacks.RecordCOunt GT 0>
					<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0" CLASS="MainTable">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12 px;border:none;"><B>The expected values for the following approved billbacks have been adjusted by this billback.</B></TD>
					</TR>
					<!--- <TR BGCOLOR="FFCE84">
						<TD>&nbsp;&nbsp;</TD>
						<TD>&nbsp;</TD>
						<TD COLSPAN="2" ID="header"><B>Billback</B></TD>
						<TD ID="header"><B>Span</B></TD>
						<TD ID="header"><B>Date Approved</B>&nbsp;<IMG SRC="/Images/down_1.gif"></TD>
					</TR> --->
					<CFLOOP QUERY="variables.Get_Affected_Billbacks">
						<TR>
							<TD>&nbsp;</TD>
							<TD>
							<CFSWITCH EXPRESSION="#Billback_Status_ID#">
								<CFCASE VALUE="1">
									<!--- WIP --->
									<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="2">
									<!--- Ready For Approval --->
									<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>				
								<CFCASE VALUE="3">
									<!--- Active Programs --->
									<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="4">
									<!--- Archived/Expired --->
									<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="5">
									<!--- Archived/Expired --->
									<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>																	
							</CFSWITCH>
							</TD>
							<TD WIDTH="70">[#BB_Code#]</TD>
							<TD>#BB_Title#</TD>
							<TD>#DateFormat(BB_Start_Date, "mm/dd/yyyy")# - #DateFormat(BB_End_Date, "mm/dd/yyyy")#</TD>
							<TD>#DateFormat(Date_Approved, "mm/dd/yyyy")#</TD>
						</TR>
					</CFLOOP>
					</TABLE>
				</CFIF>
				 --->
				
				
				<CFIF variables.qGetReferencedBillbacks.RecordCOunt GT 0>
					<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0" CLASS="MainTable">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;border:none;">
						<B>The approved amount of the following billbacks were adjusted to reflect the adjustments/exclusions created by this billback.</B>
						</TD>
					</TR>
					<TR BGCOLOR="FFCE84">
						<TD>&nbsp;&nbsp;</TD>
						<TD>&nbsp;</TD>
						<TD COLSPAN="2" ID="header"><B>Billback</B></TD>
						<TD ID="header"><B>Span</B></TD>
						<TD ID="header"><B>Date Approved</B>&nbsp;<IMG SRC="/Images/down_1.gif"></TD>
					</TR>
					<CFLOOP QUERY="variables.qGetReferencedBillbacks">
						<TR>
							<TD>&nbsp;</TD>
							<TD>
							<CFSWITCH EXPRESSION="#Billback_Status_ID#">
								<CFCASE VALUE="1">
									<!--- WIP --->
									<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="2">
									<!--- Ready For Approval --->
									<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>				
								<CFCASE VALUE="3">
									<!--- Active Programs --->
									<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="4">
									<!--- Archived/Expired --->
									<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="5">
									<!--- Archived/Expired --->
									<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>																	
							</CFSWITCH>
							</TD>
							<TD WIDTH="70">[#BB_Code#]</TD>
							<TD>#BB_Title#</TD>
							<TD>#DateFormat(BB_Start_Date, "mm/dd/yyyy")# - #DateFormat(BB_End_Date, "mm/dd/yyyy")#</TD>
							<TD>#DateFormat(Date_Approved, "mm/dd/yyyy")#</TD>
						</TR>
					</CFLOOP>
					</TABLE>
				</CFIF>
				
				</CFOUTPUT>
				<cfif appSettings.getPullbacksOn()>
				<cfif checkifpullbackfromthisprg.BB_pullbacks_applied EQ 1>
				<TABLE WIDTH="90%" BORDER="0" CELLPADDING="4" CELLSPACING="0" CLASS="MainTable">
				<TR>
				<TD STYLE="font-size:12px">
				<B><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> amount applied to this
				 	Billback:</B>&nbsp;&nbsp;<cfoutput>
					#dollarformat(checkifpullbackfromthisprg.Pullback_applied_Amount)#</cfoutput>
				</TD>	
				<TD COLSPAN="100%" STYLE="font-size:12px" align="left">
				 <A HREF="##" onClick="javaScript: submitfordetails();" TITLE="View #appsettings.getPullbackLabel()# Details">
				View Details</A>
				</TD>
				</TR>	
				</table>
				</cfif>
				</CFIF>
			</CFIF>
		</BLOCKQUOTE>
		</BODY>
		</HTML>
	<CFELSE>
		<CFSET upd_This_Billback = 0>
	</CFIF>
	
</CFIF>

<script>
function submitfordetails()
{
NewWindow('/billbacks/approval/viewappliedpullbacks.cfm?BB_ID=<cfoutput>#Billback_Id#</cfoutput>&fromdeletepage=1','pullbackdetails','870','620','Yes', 'No');
}
try { window.parent.dyniframesize(); } catch (err) { };
</script>
