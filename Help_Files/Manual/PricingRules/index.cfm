<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Pricing Rules</title>
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
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">

<HR COLOR="Orange">

<div align="center">


<p></p>
<table>
<tr><th colspan="2"><strong>Pricing Rule: Step 1 of 4</strong></th></tr>
<tr><td colspan="2"><div align="center"><img src="../images/pricingrule2.gif"></div></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Rule Name:</em>  Enter the name for your rule here.  This name is how you can  refer to the rule in order to change, modify or delete it.  </td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td><em>Product Selector</em> - click here to select products: Clicking on this link will open a new page (see #2 below).</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>The products you selected using the pop up window in step two will be displayed here.  Double check that these are the products you want to be used in your pricing rule.</td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td><em>Number of Commodities:</em> Select the number of commodities that will play a role in your pricing rule.  You can choose between 0 and 4 commodities.  </td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">

<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">
<CFINCLUDE TEMPLATE="pricingrule_updated.cfm">
</body>
</html>
