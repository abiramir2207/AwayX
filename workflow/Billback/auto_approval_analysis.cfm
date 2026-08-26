<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>auto Approval Analysis</title>
</head>

<CFSET objBBWorkflowManager = createObject("component", "components.workflow.BillbackWorkFlowManager") />
<CFSET qgetAutoApprovalAnalysisInfo = objBBWorkflowManager.getAutoApprovalAnalysisInfo(url.bbid)>
<CFSET objSettingsService = CreateObject("component", "mvc.Models.SettingsService") />

<cfset stBBLabels = objSettingsService.getBBLabels()>

<body>

<!--- Auto Approval Analysis --->
<cfif qgetAutoApprovalAnalysisInfo.recordcount gt 0>
<br />

<TABLE width="70%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<CAPTION align="left"><B><FONT SIZE="2" COLOR="Navy">Auto Approval Analysis</FONT></B>&nbsp;<HR COLOR="Navy"></CAPTION>
		<tr ID="HEADER" BGCOLOR="#FFCE84">
			<td colspan="4"><b>Criteria</b></td>
			<td><b>Pass/Fail</b></td>
		</tr>
	<cfoutput query="qgetAutoApprovalAnalysisInfo">
		<tr>
			<td colspan="4">#reason#</td>
			<td>
				<cfif passed eq 1>Pass
				<cfelseif passed eq 0><span style="color:red">Fail</span>
				<cfelseif passed eq 2>n/a
				</cfif>
			</td>
		</tr>
	</cfoutput>
</TABLE>
<cfelse>
<div style="color:red;font-weight:bold;">
<cfoutput>
This #stBBLabels.Billback# did not qualify for the Auto Approve process. See System Administrator for reasons on why it did not qualify.
</cfoutput>
</div>

</cfif>

</body>

</html>