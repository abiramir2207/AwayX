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
	<tr>
		<th colspan="2">
			<strong>Product Search Screen</strong>
		</th>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td valign="top" colspan="2" align="center">
			<img src="../images/cp_search.gif">
		</td>
	</tr>
	<tr>
		<td valign="top">
			<img src="../images/1.gif">
		</td>
		<td>
			Products can be searched for by several criteria that describe your product catalog. You may choose to sort by these criteria ascending or descending.
<p></p>
<cfoutput>You can also search for items that a #application.returned_customer_setting.distributor_label_singular# has purchased by finding the distributor's name in the list under "Invoice Entry for" and limit the period by selecting 90, 120, 180 or 365 days in the past. For example, if you wanted to create a program based on what a #application.returned_customer_setting.distributor_label_singular# had bought in the last quarter, you would select the #application.returned_customer_setting.distributor_label_singular# and 90 days as the selection period.</cfoutput>
<p></p>
Product selections from other discount types in the same program can also be imported.  For example, if you had selected a number of products in <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, which you wanted to use in Fixed Price, you could select "<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>" from the list "Search Products From".
<p></p>
Select or enter the information you wish to search by and click on the [search products] link.   
			<p></p>
		</td>
	</tr>
	<tr>
		<td valign="top"> 
			<img src="../images/2.gif">
		</td>
		<td>
			You can select all products on a page by clicking on the check box in the upper left hand corner of the orange header.  You must do this for every page of results you wish to select.  Additional pages can be navigated to by clicking on the red page numbers at the bottom of the list of results.
<p></p>
If you wish to reorder the results you are shown, you can click on the blue titles to reorder by that criteria.  For example, if you click on "Brand" you will see the brands that come alphabetically first at the top.
			<p></p>
		</td>
	</tr>
	<tr>
		<td valign="top"> 
			<img src="../images/3.gif">
		</td>
		<td>
			You can import all check products into your program area by clicking on [import selected products]. If you wish to return all products found in a search, click on [import all returned products].  If you wish to remove products from a program, search for the products.  They will already be checked.  Then click on [remove all selected products].  You will be asked to confirm that you wish to remove the products.
		</td>
	</tr>
</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
