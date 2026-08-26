<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Reports :: Saved Reports</title>
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
<tr><th colspan="2"><strong>Reports -- Saved Reports</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/rep_margin1.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">When you click on the "Saved Reports" option you are presented with this screen.  These are the reports that have been saved and are scheduled to run on a regular basis.  If you click on any part of the blue text, you will be able to revise the report.  (To revise multiple reports there are arrow which will take you to the next or previous report.)  Clicking on the red X will delete the report.</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="reports_toc.cfm">
<cfinclude template="reports_updated.cfm">
</body>
</html>
