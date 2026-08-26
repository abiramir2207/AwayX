<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Fiscal Year </title>
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
<CFINCLUDE TEMPLATE="fiscal_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Fiscal Year</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_fiscal1.gif"></td></tr>
<tr><td colspan="2">This section of the administration allows you to establish the number and range of periods in your fiscal year.</td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Information at the top of the screen shows when the settings were last changed, and who changed them.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
<em>Current Saved Settings:</em> Information about your existing periods is shown.  
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
If you wish to change this information, select the number of periods you would like in your fiscal year, and click on "Next Step".  
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="fiscal_toc.cfm">
<CFINCLUDE TEMPLATE="fiscal_updated.cfm">
</body>
</html>
