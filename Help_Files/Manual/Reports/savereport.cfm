<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Reports :: Schedule a Report</title>
	<script language="JavaScript">
<!--
function change(html){
  description.innerHTML=html
  description2.innerHTML=html
}
//-->
</script>
</head>

<body>
<strong><div id="description">&nbsp; </div></strong>
<cfinclude template="reports_toc.cfm">

<!---Orange bar--->
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Reports -- Schedule a Report</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/rep_schedule.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>
<Tr><td colspan="2">
You can schedule reports to be emailed to specified users on a regular basis.
</td></TR>
<Tr><td valign="top"><img src="../images/1.gif"></td><td>If you wish to save a report as a scheduled event, you can establish the start dates and end dates the program should run from and to.  You may either type in the dates, click on the calendar icon to see a calendar to help you select the dates, or use the red up and down arrows to increment or decrement the dates by one day.</td></TR>
<Tr><td valign="top"><img src="../images/2.gif"></td><td><em>Time:</em> Select the time you would like the report to run. The arrows to the left of the box change the hour.  The inner set of arrows on the right change the minute, and the arrows to the far left change whether the time shown is AM or PM.</td></TR>
<Tr><td valign="top"><img src="../images/3.gif"></td><td><em>Interval:</em> Select the frequency with which you would like the report to run. Options are: Once, Daily, Weekly, Monthly.</td></TR>
<Tr><td valign="top"><img src="../images/4.gif"></td><td><em>Email Address:</em> The email addresses to whom the saved reports should be sent.  Multiple email addresses should be separated with semi-colons.</td></TR><br>
<Tr><td valign="top"><img src="../images/5.gif"></td><td>You can select email recipients from a list of registered recipients in the application.  To select, find the email address and click on it. You will notice that it has been automatically added to the Email Address field.</td></TR>


</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="reports_toc.cfm">
<cfinclude template="reports_updated.cfm">
</body>
</html>
