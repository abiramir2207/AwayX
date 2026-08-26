<!------ show_approvable_users.cfm ----->
<cfparam name="URL.CID" 	default="">
<cfparam name="URL.businessSegmentsOn" 	default="0">
<cfparam name="URL.ResponsibleUser" 	default="">

<cfif isNumeric(URL.CID)>
<cfset ProgramManager = CreateObject("component", "components.programs.ProgramManager").init() />
<cfset qGetApprovableUsers = ProgramManager.getApprovableUsers(URL.CID, URL.businessSegmentsOn, URL.ResponsibleUser) />
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program - Users Currently Responsible for Approval</title>
</head>

<body>

<table bgcolor="cccccc" cellpadding="2" cellspacing="2" width="80%" align="center">
	<cfif NOT qGetApprovableUsers.recordCount>
	<tr bgcolor="ffffff">
		<td>No user found</td>
	</tr>
	<cfelse>
	<tr>
		<td><strong>Name</strong></td>
		<td width="25%"><strong>Authority Sequence</strong></td>
		<td width="25%"><strong>Profile</strong></td>
	</tr>
	<cfloop query="qGetApprovableUsers">	
	<tr bgcolor="ffffff">
		<td>#User_Full_Name#</td>
		<td>#Authority_Sequence_Name#</td>
		<td>#Profiles_Desc#</td>
	</tr>
	</cfloop>
	</cfif>
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