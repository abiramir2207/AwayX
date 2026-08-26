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
<tr><th colspan="2"><strong>Pricing Rule: Step 3 of 4</strong></th></tr>
<tr><td colspan="2"><div align="center"><img src="../images/pricingrule5.gif"></div></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Selected Options:</em> The selected options pane shows you the entries you have made to date. You can see the name of your rule.  Clicking on the "View/Hide Products" link will show the products if they are not visible, and hide the products you selected if they are shown.  You can change the values shown by clicking on [revise these values].</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td><em>Commodity Pricing Weight:</em> Here you can enter the percentage of the pricing rule the commodity comprises.  For example, your price rule might use 70% Milk Grade and 27% CME Milk. The total of all the percentages for the commodities you are creating the price rule around must equal 100%.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td><em>Current Cost Lag:</em>  This indicates the number of weeks in the past you want information generated for.  If you were to enter 6 here, then it would begin calculations from 6 weeks back.  In our example, we already have a 6 week lag, and a 12 week period specified.  Entering 6 for the current cost lag would produce information about a 12 week period that occurred beginning 24 weeks ago and ending 12 weeks ago (6 weeks for the current cost lag and 6 weeks for the lag entered in 3.4).</td></tr>
<tr><td colspan="2" align="center"><img src="../images/timeline2.gif"></td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td><em>Final Adjustments - Compounded Calculations:</em>  The compounded calculations used here work in exactly the same manner they did on the previous page.  The difference is that at this point you can run the same calculation on the final cost - not just on the different commodities.  Please note that these calculations are on top of the calculations already made on a commodity basis.  So if you take the previous example where the commodity price was $10, the cost of compounded calculations was $2.10 and the cost of independent calculations was $2, then the beginning cost used in these calculations will be $14.10.

<p>
Compounded Calculation #1:<br>
$14.10 x 10% = $1.41<br>
Compounded Calculation #2:<br>
($14.10 + $1.41) x 10% = $1.551<br>
Total Additional Cost from Compounded Calculations:<br>
$1.41 + $1.551 = $2.961<Br>
<p></p>

</p>
</td></tr>

<tr><td valign="top"><img src="../images/5.gif"></td><td><em>Final Adjustments - Independent Calculations:</em>  These calculations work the same as on the earlier screen, except with beginning price difference noted above.

<p>
Independent Calculation #1:<br>
$14.10 x 10% = $1.41<br>
Independent Calculation #2:<br>
$14.10 x 10% = $1.41<br>
Total Additional Cost from Independent Calculations:<br>
$1.41 + $1.41 = $2.82<p></p>
</p>

</td></tr>

</table>

</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">
<CFINCLUDE TEMPLATE="pricingrule_updated.cfm">
</body>
</html>
