<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations :: Product</title>
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
<cfinclude template="deviations_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Deviations -- Product Deviation</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_product_deviation.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">Items are checked to see if they are included in the program with the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type being claimed for them.</td></tr>
<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Information on the claims made by the billback is shown here, including which program the product is claimed on, which product has been claimed, and what discount type is being claimed for the product.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
The same screen for authorization is shown for Fixed Price, Formula Price and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>. You can verify which discount type is being considered by looking to the left of the screen. </td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
A list of all products included in the discount type for the program is displayed.  If the product claimed is in the list, it is highlighted in yellow.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
The deviation amounts are calculated for each discount type on each item. 
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="deviations_toc.cfm">
<cfinclude template="deviations_updated.cfm">

</body>
</html>
