<!------ Billback_Batch_Print.cfm ----->
<cfparam name="URL.pageTitle" 	default="CLAIMS REPORT">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<style>
	p { font-size:1.15em; }
	</style>
</head>

<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset printNow = 0>
<cfset thisFormName = "frmBillbackPrint">
<cfparam name="form.runDate" 	default="#Now()#">

<cfoutput>
<!------ Get the distinct printed dates ----->
<cfquery name="qGetPrintedDates" datasource="#application.datasource#">
	SELECT DISTINCT TOP 5 CONVERT( VARCHAR(10), Pay_Print_Date, 111 ) AS printDate
	  FROM BILLBACK_ALLIED
	 WHERE Pay_Print_Over = 1
	       AND Pay_Print_Date IS NOT NULL
	 ORDER BY printDate DESC 
</cfquery>

<p>Click on one of the options below to generate a claims report for the selected date and place it on the FTP outbound location.</p>
<ul>
	<li><a href="/scheduled/approved_billback_print.cfm?printdate=#dateformat(now(),'m/d/yyyy')#" target="_blank"><B>Generate today's claims</B></a><hr></li>
	<cfloop query="qGetPrintedDates">
		<li><a href="/scheduled/approved_billback_print.cfm?printdate=#dateformat(printDate,'m/d/yyyy')#"><B>Regenerate claims processed on #DateFormat(PrintDate,'mmm d yyyy')#</B></a></li>
	</cfloop>
</ul>
</cfoutput>
</body>
</html>
