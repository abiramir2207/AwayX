<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Programs </title>
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


<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Programs -- Expiring Age</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_prog_expiring.gif"></td></tr>

<tr><td colspan="2">
You can set the number of weeks before a programs end date that it will be considered to be expiring.  In this example, 8 weeks before the end date of a program, it will be moved from having an Active status to having an Expiring status.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="programs_updated.cfm">
</body>
</html>
