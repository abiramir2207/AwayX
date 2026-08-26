<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<CFQUERY NAME="get_use" DATASOURCE="hhss_db">
	SELECT      
		Vaca_Day, 
		Users_ID
	FROM         
		dbo.Test_Table
</CFQUERY>

<html>
<head>
	<title>Append vdSched to ChkID</title>
</head>

<body>
<cfparam Name="Attributes.Vaca_Day" default="1/1/2000">
<cfparam Name="Attributes.Users_ID" default="0">

<cfif Get_Use.Users_ID eq "#ATTRIBUTES.Users_ID#" AND Get_Use.Vaca_Day eq "#ATTRIBUTES.vaca_day#">
	<cfset CALLER.vdSched = 1>
<cfelse>
	<cfset CALLER.vdSched = 0>
</cfif>

</body>
</html>

