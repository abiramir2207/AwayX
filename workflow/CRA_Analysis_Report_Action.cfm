<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Workflow</title>
	<script type="text/javascript" src="/script/javascript/sortable.js"></script>

</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">

<style>
TABLE.sortable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
TABLE.sortable TH 
{
	border-bottom:solid #93BEE2 1px; font-size:11px; font:bold; text-align:left; 
}

.odd {background-color: #FFFFFF;}
.even {background-color: #CCFFCC;}
image{border:none}
</style>
<cfparam name="form.Program_ID" default="0" />
<cfparam name="form.User_ID_List" default="0" />

<cfset objWorkflowManager = createObject("component", "components.workflow.WorkFlowManager") />
<cfset objProgram = createObject("component", "components.programs.Program") />

<cfset qGetAnalysisData = objWorkflowManager.getCRAAnalysisReport(form.Program_ID, form.User_ID_List) />
<cfset qGetProgramData = objProgram.getProgramInfo(form.Program_ID) />
<cfset displayAuthoritySequence = objWorkflowManager.displayAuthoritySequence() />
<cfset appsettings = application.appSettingsGet />
<cfoutput>
<!---check to see if business segments are enabled--->
<cfquery name="qIsEnabled" datasource="#application.datasource#">			
	SELECT	Enabled, Distributor_Enabled, Product_Enabled
	FROM	Business_Segment_Enabled
	WHERE	Deleted = 0		
</cfquery>

<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="100%" bgcolor="">
			<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
			#application.returned_customer_setting.company_name#</DIV>
			<B><font size="+1" color="Navy">[#qGetProgramData.Contract_Number#] - #qGetProgramData.Contract_Title#</FONT></B>
		</td>
		<td align="right" valign="top">
			<CF_smallLink 
				title = "workflow" 
				url = "workflow.cfm?Program_ID=#form.Program_ID#"
				parameters = ""
			>
			<CF_smallLink 
				title = "close window" 
				url = "JavaScript:window.close();"
				parameters = ""
			>
		</td>
	</tr>	
</table>
</cfoutput>
<br>
<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">CRA Analysis Report</FONT></B>&nbsp;<HR COLOR="Navy"></CAPTION>
<TABLE width="100%" BORDER="0" CELLPADDING="2" CELLSPACING="0" class="sortable" id="sortabletable">
	<!---- HEAD ----->
	<THEAD BGCOLOR="#FFCE84">
		<TH>
			User
		</TH>
		<TH>
			Position
		</TH>
		<TH>
			Profile
		</TH>
		<cfif displayAuthoritySequence>
		<TH>
			Auth Seq
		</TH>
		</cfif>
		<TH>
			User Acct:<br>Elig RSP
		</TH>
		<TH>
			Profile:<br> View Margin
		</TH>
		<TH>
			Profile:<br>Approval
		</TH>
		<TH>
			Profile:<br>Rev Type App
		</TH>
		<TH>
			Profile:<br>Group Prg App
		</TH>
		<TH>
			Template:<br>Access/App
		</TH>
		<cfif qIsEnabled.enabled IS 1>
			<TH>
				Program:<br>Segment
			</TH>
		</cfif>
		<TH>
			Position<br>Eligible
		</TH>
	</THEAD>
	<CFOUTPUT QUERY="qGetAnalysisData">

	<TR>
		<TD>
			#UName#	
		</TD>
		<TD>
			#Position_Label#	
		</TD>
		<TD>
			#Profile_Desc#	
		</TD>
		<cfif displayAuthoritySequence>
		<TD>
			<cfif len(trim(Authority_Sequence_Name))>#Authority_Sequence_Name#<cfelse>N/A</cfif>
		</TD>
		</cfif>
		<TD><span style="display:none">#Is_Eligible_RSP#</span>
			<cfif Is_Eligible_RSP eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		<TD><span style="display:none">#Profile_View_Margin_Rights#</span>
			<cfif Profile_View_Margin_Rights eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		<TD><span style="display:none">#Profile_Approval_Rights#</span>
			<cfif Profile_Approval_Rights eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		<TD><span style="display:none">#Revision_Type_Approval_Permission#</span>
			<cfif Revision_Type_Approval_Permission eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		<TD><span style="display:none">#Group_Approval_Permission#</span>
			<cfif Group_Approval_Permission eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		<TD><span style="display:none">#Template_Access_Approve_Rights#</span>
			<cfif Template_Access_Approve_Rights eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		<cfif qIsEnabled.enabled IS 1>
			<TD><span style="display:none">#User_Has_Template_Segment#</span>
				<cfif User_Has_Template_Segment eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
			</TD>
		</cfif>
		<td title="<cfif Users_Above_Agreed eq 1>another user at the same position or higher has already agreed/approved the prog<cfelse>user position is eligible to agree/approve</cfif>">
			<cfif Users_Above_Agreed eq 1>No<cfelse>Yes</cfif>
		</td>
	</tr>
	</CFOUTPUT>
</TABLE>

</body>
</html>