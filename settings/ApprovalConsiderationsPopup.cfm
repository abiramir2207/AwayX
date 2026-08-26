<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>..::Approval Considerations::..</title>
</head>
<cfparam name="URL.acid" default="-1" />

<body>
	<cfif (URL.acid NEQ -1)>
		<cfset objApprovalConsiderations 	= CreateObject("component","mvc.Models.Program.ApprovalConsiderationsManager") />
		<cfset qGetCurrentApprovalConsiderations = objApprovalConsiderations.getApprovalConsiderations(approvalConsiderationsID=URL.acid, IncludeDeleted=0) />
	
		
		<cfif (isDefined("qGetCurrentApprovalConsiderations.RecordCount") AND qGetCurrentApprovalConsiderations.RecordCount GTE 1)> 
		<cfoutput><strong>#qGetCurrentApprovalConsiderations.Approval_Considerations_Name#:</strong>
		<br>
		<br>
		#qGetCurrentApprovalConsiderations.Approval_Considerations_Text#
		</cfoutput>
		</cfif>
		
	<cfelse>
	<br>
	<br>
		<strong>Invalid Argument passed...	</strong>
	</cfif>
<br>
<br>
<center>
	 <input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
</center>
</body>
</html>
