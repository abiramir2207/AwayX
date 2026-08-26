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
<tr><th colspan="2"><strong>Create a New Program -- Fixed Price</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_fixedprice.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>If you want to apply a price to numerous items, make sure the items you want have the box on the right checked (uncheck items you do not want to include). Enter the price you want, and then click [apply price]. You can still change the price for each individual products. 
<p></p>
The left hand options on this are the same as on the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> weighting, except that this sets a volume in pounds instead of percentages, and does not have to equal 100%.  The program does, however, calculate the number of units that need to be moved each week in order for you to meet your program volume goal set in the very first "Basic Information" screen.  If you select the third option, the correct amount will automatically be entered in all selected products.  The right hand options are to apply rates.  If you wish to enter the same rate for multiple products, enter the rate in the box next to option one.  If you want to include all products in one rate, click on the box inside the sentence.  Other wise, check the boxes of the products you are applying the rate to and click on the [click here] to the right of the second element.

</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>When you are done assigning fixed prices, click save. If you wish to add products to the list, click "select products".
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>Select whether the rate you are selecting is delivered or FOB. 
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>If you want to apply a unit of measure to multiple products, select the unit of measure of choice, and click on [apply].
</td></tr>
<tr><td valign="top"> <img src="../images/5.gif"></td><td>Throughout the application, we offer information that you can access by using your right mouse button. In this case, when you right click while your mouse is on top of a product, you will see two options: Product Summary and Price List. Product summary offers you information about the product, such as general information, category alignment and weight. The price list details will show you any price lists available for the product, as well as the different prices for various shipping options. While this is particularly helpful for fixed price, this information is often available wherever products are displayed. If this information is available, the cursor will appear with a question mark next to it.
</td></tr>
<tr><td valign="top"> <img src="../images/6.gif"></td><td>Basic information on the product is displayed. You may remove a product from the program by clicking on the scissors to the right, and bring it back by clicking again. You should be sure to enter a fixed price for each product, and make sure the unit of measure you have selected is the appropriate one.
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
