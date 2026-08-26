<!------ show_approvable_users.cfm ----->
<cfparam name="URL.BBID" 	default="">
<cfparam name="URL.businessSegmentsOn" 	default="0">

<cfif Len(URL.BBID) GT 0>
<cfset BillbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
<cfset qGetApprovableUsers = BillbackManager.getApprovableUsers(URL.BBID) />
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Billback - Users Currently Responsible for Approval</title>
</head>

<body>

<table bgcolor="cccccc" cellpadding="2" cellspacing="2" width="80%" align="center">
	<cfif NOT qGetApprovableUsers.recordCount>
	<tr bgcolor="ffffff">
		<td>No user found</td>
	</tr>
	</cfif>
	<cfloop query="qGetApprovableUsers">
	<tr bgcolor="ffffff">
		<td>#User_Full_Name#</td>
	</tr>
	</cfloop>
</table>

<center>
<CF_smallLink 
	title = "close window" 
	url = "##"
	parameters = "onClick=""javascript: window.close();return false;"""
>
</center>
</body>
</html>
</cfoutput>
</cfif>