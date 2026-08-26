<CFPARAM NAME="URL.Type" 	DEFAULT="">
<CFIF URL.Type EQ "excel">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=programList.xls">
	<CFINCLUDE template="All_Programs.cfm">
	<CFABORT>
</CFIF>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>All Programs</title>
</head>

<body>

<cfinclude template="/Includes/call_please_wait.cfm">
<!------ Show_All_Programs.cfm ----->
<cfset showlinks = true>
<CFPARAM NAME="URL.SORT_BY" 	DEFAULT="Position">
<CFOUTPUT>
<a href="Show_All_programs.cfm?type=excel&SORT_BY=#URL.SORT_BY#" onclick="return window.confirm('It will take some time. Do you want to continue?');">Excel</a>
</CFOUTPUT>
<CFINCLUDE template="All_Programs.cfm">


</body>
</html>
