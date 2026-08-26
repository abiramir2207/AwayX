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
<tr><th colspan="2"><strong>Pricing Rule: Select Product</strong></th></tr>
<tr><td colspan="2"><div align="center"><img src="../images/pricingrule3.gif"></div></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Search Criteria: </em>There are 9 ways to search for a product or products.  You can search by: Type Group Descriptions, Q Brand Descriptions, Type Code Descriptions, Brands, Line of Business, Status, Item Number, UPC Number, and Description.  If you do not select anything, you will see all products.  If you search by more than one criteria, then you will only see products that match both selections.  For example, the twelve records returned above are what is shown when "Italian" is selected for the Type Group Description and "Private Label" is selected as the Line of Business.  There are 120 records shown when just "Italian" is selected.  If only "Private Label" is selected 287 records are displayed.  Click on [search products] to see the results of your search once you have made your selections.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td><em>Returned Records:</em> Once you have identified the records you are interested in, you need to select them in order to change whether or not they are in your pricing rule.  Click on the check box on the left hand side of the screen to select a product.  The Item Number, UPC, Description, Type Code and Brand are all displayed to help you make your selection.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>Once you are satisfied, with your selections, you can do three things.  The first is to include all the products you have checked in your pricing rule by clicking on [import selected products].  The second is to import all of the products that are returned by your search by clicking on [import all returned products] (for example, in this case clicking on [import all returned products] would make all 12 returned products part of the pricing solution).  Finally, you can remove products from your pricing rule by checking them and clicking [remove all selected products].
<p></p>
NOTE: If a product is grayed out, you cannot select it to be added to your pricing rule. It is already a part of another pricing rule.
</td></tr>


</table>


</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">
<CFINCLUDE TEMPLATE="pricingrule_updated.cfm">
</body>
</html>
