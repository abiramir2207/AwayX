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

td.td1
{
	border-bottom:solid #FFCE84 1px; font-size:11px; font:bold; text-align:left;background-color: #FFCE84; 
}
</style>
<cfparam name="form.Billback_ID" default="0" />
<cfparam name="form.User_ID_List" default="0" />

<cfset objBBWorkflowManager = createObject("component", "components.workflow.BillbackWorkFlowManager") />
<cfset objBillback = createObject('component','components.Match_Central.MatchCentral').init() />

<cfset qGetAnalysisData = objBBWorkflowManager.getBBCRAAnalysisReport(form.Billback_ID, form.User_ID_List) />
<cfset qGetBillbackData = objBillback.getBBInfo(form.Billback_ID) />
<cfset displayAuthoritySequence = objBBWorkflowManager.displayAuthoritySequence() />
<cfoutput>

<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="100%" bgcolor="">
			<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
			#application.returned_customer_setting.company_name#</DIV>
			<B><font size="+1" color="Navy">[#qGetBillbackData.BB_Code#] - #qGetBillbackData.BB_Title#</FONT></B>
		</td>
		<td align="right" valign="top">
			<CF_smallLink 
				title = "workflow" 
				url = "BB_Workflow.cfm?Billback_ID=#form.Billback_ID#"
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
			Profile:<br>Approval
		</TH>
		<TH>
			Template:<br>Access/App
		</TH>	
 		<TH>
			Action Needed<br> By User
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
 		<TD><span style="display:none">#Profile_Approval_Rights#</span>
			<cfif Profile_Approval_Rights eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
 		<TD><span style="display:none">#Template_Access_Approve_Rights#</span>
			<cfif Template_Access_Approve_Rights eq 1><img src="/Images/yes_small.gif" width="12" height="12"><cfelse><img src="/Images/no_small.gif" width="12" height="12"></cfif>
		</TD>
		
		
		<td title="<cfif Users_Above_Agreed eq 1>another user at the same position or higher has already agreed/approved the prog<cfelse>user should agree/approve the prog</cfif>">
			<cfif Users_Above_Agreed eq 1>No<cfelse>Yes</cfif>
		</td>
	</tr>
	</CFOUTPUT>
</TABLE>

</body>
</html>