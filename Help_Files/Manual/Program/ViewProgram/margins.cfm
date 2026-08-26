<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: View Margins</title>
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
<cfinclude template="viewprogram_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Programs -- View Margins</strong></th></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_margin.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">
On Pre Active, Active, Expiring and Expired programs, once you have locked a program, if you have permission to view margins, you will see a yellow bar in the upper right hand margin which will allow you to view margins.  This information cannot be modified or edited from this screen.
</td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>You can review information about the products which comprise your program.</td></tr>

<tr><td valign="top"><img src="../../images/2.gif"></td><td>Clicking on the blue number for #application.returned_customer_setting.Trade_Label# Adjustment will open the #application.returned_customer_setting.Trade_Label# adjustment screen. <A href="tradeadjustment.cfm">Click here</A> to view the help file for the #application.returned_customer_setting.Trade_Label# Adjustment.</td></tr>

<tr><td valign="top"><img src="../../images/3.gif"></td><td>If you have permission to view margins, you will be able to see information about Rated Margins, <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s and Margins.   </td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="viewprogram_toc.cfm">
<cfinclude template="viewprogram_updated.cfm">
</body>
</html>
