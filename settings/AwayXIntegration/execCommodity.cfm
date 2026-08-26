<!-----execCommodity.cfm------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<CFIF NOT isDefined("ADI_IncludeFile")>
	<CFINCLUDE template="adiInclude.cfm">
</CFIF>
<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cftry>
<cfstoredproc procedure="ExecCommodity"  datasource="#application.datasource#">
</cfstoredproc>
	<cfcatch>
			<cfrethrow>
			<cfabort>
	</cfcatch>	
</cftry>
<BR><BR>
<CENTER>
<SPAN CLASS="title2" ALIGN="CENTER">
The Commodity process has been started.
</SPAN>
</CENTER>
<script language="JavaScript">
function seeya()
{
	window.location.href="<CFOUTPUT>#mainPage#</CFOUTPUT>";
}
setTimeout('seeya()',2000); 
</script>

</body>
</html>
