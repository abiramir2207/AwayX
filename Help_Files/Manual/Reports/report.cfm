<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Reports :: View Report</title>
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
<tr><th colspan="2"><strong>Reports -- View Report</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/rep_report.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">The information presented in the report depends very much on the selections you made.  In the above example of a Product Summary Report you can see the Type Group in the top level in goldenrod.  The Status is shown in green.  The Program Type is shown in red.  The programs themselves are displayed in white.  This report also shows the projected margin.  The information shown and the order it is shown in will depend on your selections.</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="reports_toc.cfm">
<cfinclude template="reports_updated.cfm">
</body>
</html>
