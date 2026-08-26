<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Create a New Program</title>
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
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Create a New Program -- Off Invoice</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2">Off invoice programs are only available through he Distributor Off-Invoice program type. If a Distributor Off-Invoice program is created, it is the only discount type available.  Off Invoice programs increase or decrease the invoice price by the amount entered.</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_offinvoice.gif"></td></tr>
<tr><td valign="top" align="center"> <img src="../images/1.gif"></td><td>If you would like to enter the same adjustment to multiple products, enter the amount, click on the box to the right of the product, and click [apply]. You may still manually change the information.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td><em>Pricing Periods:</em> When you arrive at the formula page you will first need to create pricing periods.  You can do so by clicking on the [Click here to establish new pricing periods].  The following window will open.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>This section displays the items you have selected. You can get information on the products and price lists using the right click menu. You can also change any value.  
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
