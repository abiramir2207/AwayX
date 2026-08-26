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
<tr><th colspan="2"><strong>Create a New Program -- <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT></strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_rebate.gif"></td></tr>
<tr><td valign="top" colspan="2">
<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s have been changed so that instead of entering only one <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> per product, you may now enter many <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s (which, of course, will all add up to a certain amount off the final product).  Each separate <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> you enter for a product is called a component.
<p></p>
You have many options when you are beginning to build your <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s. You can pick either your component (name and amount off) first, or your products first (by clicking on the [add products] link). Not all products need to have all <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s.
</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Components:</em> Each component has a name (which you select from a list created by administrators), and rate, and the unit of measure for the rate.  If you have already selected products, check the boxes of the products which should be included in this component. Enter the amount of the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, and select the unit of measure. Click on [include this component], and the component will appear in the lower section.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td><em>Rates:</em> If you have already created a component, but wish to change the rate for a number of products in the component, click on the box to the left to select the products, enter the rate, select the UOM and click on [apply this rate/uom] to make the change to all selected products.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td><em>Products:</em> A necessary step of creating the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> is selecting the product. At any time, you can add products by clicking on the [add products] link. You can remove products by clicking on their left box, and then clicking on [remove selected products].
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>The components and products are laid out in a grid. You can manually establish a price for each product in each component. It could be that you do not wish to include a product in a component (or include a component in a product - however you wish to think about it). In that case make the rate 0/UOM.
</td></tr>
<tr><td valign="top" colspan="2">When you are satisfied with your choices, be sure to save. Your work will not be saved unless you click on the "save" button.
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
