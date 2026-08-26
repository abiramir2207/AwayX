<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Formula Price Details</title>
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
<!---Orange bar--->
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Programs -- Formula Price Details</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_ratecalc.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>
<tr><td colspan="2"></td></tr>
<tr><td valign="top"><img src="../../images/1.gif"></td><td> 
If you have permission to view pricing rules, when you view program, you may notice that "Price" as a link shown in blue.  Clicking on one of the numbers will bring up the above screen, which shows the pricing rules for the product price you clicked on.  These pricing rules are set by administrators, and can be set or changed in Programs -> Commodity Pricing.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="viewprogram_toc.cfm">
<cfinclude template="viewprogram_updated.cfm">
</body>
</html>
