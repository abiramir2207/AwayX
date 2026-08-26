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
<tr><th colspan="2"><strong>Pricing Rule: Step 2 of 4</strong></th></tr>
<tr><td colspan="2"><div align="center"><img src="../images/pricingrule4.gif"></div></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Please Select the Exchange and Commodity:</em> Select the exchange which deals with the commodity you are interested in adding to the pricing rule.  What you select for an exchange will change what will be available for you to select in the commodity list.  For example, selecting the Chicago Mercantile Exchange will provide a commodity list including Milk Grade A, Butter, and Feeding Cattle.  If you select the Minneapolis Grain Exchange, commodity options include white wheat, cottonseed, and durum wheat.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>Once you have selected the appropriate exchange on the left, you can choose the commodity you are selecting from the pull-down menu on the right.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>Please enter how many weeks you would like to select data for:  This allows you to choose the sample size you wish to have analyzed to create the price rule. If you would like a 12 week period analyzed, enter 12 here.</td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td><em>Please select how far back in time the sample window should be:</em> The number of weeks entered here indicates how many weeks ago the sample should be taken. If you were to enter 6 weeks for this, then the data that would be used in evaluating the pricing rule would be 12 weeks worth of data, starting 18 weeks ago and ending 6 weeks ago.</td></tr>
<tr><td colspan="2" align="center"><img src="../images/timeline1.gif"></td></tr>

<tr><td valign="top"><img src="../images/5.gif"></td><td><em>Compounded Calculations: </em> Compound calculations are dependent upon each other.  For example, if a commodity price is $10, and the first component of the calculation is 10%, then the price for that component is  $1.  The second component might have a calculation of 10% as well, but the price for it is $1.10 - it is 10% of the commodity $1 and 10% of the $1 that the first calculation added.  The total price for these two components would be $2.10.

<p>
Compounded Calculation #1:<br>
$10 x 10% = $1<br>
Compounded Calculation #2:<br>
($10 + $1) x 10% = $1.10<br>
Total Additional Cost from Compounded Calculations:<br>
$1 + $1.10 = $2.10<p></p>

</p>

</td></tr>
<tr><td valign="top"><img src="../images/6.gif"></td><td><em>Independent Calculations:</em> Independent calculations are separate from each other.  If the commodity price being modified is $10 and the first component of the calculation is 10%, then the cost for that component is $1.  If the second component is also 10% the cost for the component is $1.  The total price for these two components would be $2.

<p>
Independent Calculation #1:<br>
$10 x 10% = $1<br>
Independent Calculation #2:<br>
$10 x 10% = $1<br>
Total Additional Cost from Independent Calculations:<br>
$1 + $1 = $2<p></p>
</p>


</td></tr>
<tr><td valign="top"><img src="../images/7.gif"></td><td>Steps 1-6 are repeated for each commodity you selected.</td></tr>

</table>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">
<CFINCLUDE TEMPLATE="pricingrule_updated.cfm">
</body>
</html>
