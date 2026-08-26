<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations :: Growth</title>
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
<tr><th colspan="2"><strong>Deviations -- Growth Deviations</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_growth_deviation.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Billback and Program: Information about the billback making a claim and the programs being claimed against is displayed here along with the delivery period of the billback and date range of the program.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Volume of Incentive for Program:  The beginning date of the period for calculating growth volume is the program's start date - regardless of when the billback request is made. The end of the period is either the end of the program or the end of the billback, whichever one comes first.  Depending on the settings, if the ship date or invoice date of the invoice falls within the period above, the volume for the item will be counted.  </td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
Calculating amounts earned: The calculations for amounts earned varies depending on whether the growth component is multi rate or single rate.
<p></p>
<strong>Single Rate: </strong>For a single rate component, the volume of all the items in the component is added together. The total volume is then compared to the tiers and the rate for each tier attained is applied.  
<p></p>

<table>
<tr><td valign="top"><em>Example:</em></TD> 	<Td>Item1 has 600 cases <Br>(according to invoices for the payee)</td></tr>
		<tr><td>&nbsp; </td><Td>Item2 has 600 cases </TD></tr>
<tr><td>Tier 1: 1-1000 </td><td> (Item 1 rate: $.10/case, Item 2 rate: $.12)</td></tr>
<tr><td>Tier 2: 1001 - 2000</td><td> (Item 1 rate: $.20/case, Item 2 rate: $.14)</td></tr>
<tr><td>Tier 3: 2001 - 3000 </TD><Td>(Item 1 rate: $.30/case, Item 2 rate: $.16)</td></tr>
</table>
Tier 2 has been attained.  Item 1 volume (600 cs) multiplied by Tier 2 Rate ($.20) is $120.  Item 2 volume (600 cs) multiplied by Tier 2 Rate ($.14) is $84. The payee has earned $204 in this component.
<p></p>
<strong>Multi Rate:</strong> The tier attained for multi rate components is calculated as in single rate components.  However instead of applying the rate for the tier attained to the total volume, the volume of each item for each tier is calculated, and an appropriate amount of volume is multiplied by each rate.  If the example above was a multi rate component, it would be calculated like this: 
<p></p>
<table>
<tr><td valign="top"><em>Example:</em> </td><td>	Item1 has 600 cases</td></tr>
	<tr><Td>&nbsp; </TD><td>	Item2 has 600 cases </td></tr>
<Tr><td>Tier 1: 1-1000 </td><td> (Item 1 rate: $.10/case, Item 2 rate: $.12)</td></TR>
<Tr><td>Tier 2: 1001 - 2000 </td><td>(Item 1 rate: $.20/case, Item 2 rate: $.14)</td></TR>
<tr><td>Tier 3: 2001 - 3000 </td><td>(Item 1 rate: $.30/case, Item 2 rate: $.16)</td></tr>
</table>
1.	Calculate what percentage of the total each item comprises.  <br>
&nbsp; &nbsp; &nbsp; 600 (item total) / 1200 (total volume) = .50 = 50%<Br>
2.	Calculate what volume of each item is for each tier and multiply for the rate for that tier.
<p></p>
Item 1:<br>
Tier 1 Volume: Item Percent (50% as above) * Volume per Tier ((1000 - 0) = 1000 cs) = 499.5 cs<br>
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Tier 1 Volume (499.5) * Tier 1 Rate ($.10) = <Br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; $49.95 (Tier 1 Total)<br>
Tier 2 Volume: Item Percent (50%) * Volume per Tier ((1200 (total item volume) - 1001 = 199)  = 99.5 cs<br>
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Tier 2 Volume (99.5) * Tier 2 Rate ($.20) = 
	<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; $19.90 (Tier 2 Total)
<p></p>
Item 2:<Br>
Tier 1 Volume: Item Percent (50% as above) * Volume per Tier ((1000 - 0) = 1000 cs) = 499.5 cs<br>
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Tier 1 Volume (499.5) * Tier 1 Rate ($.12) = 
	<Br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 	$59.84 Tier 1<Br>
Tier 2 Volume: Item Percent (50%) * Volume per Tier ((1200 (total item volume) - 1001 = 199)  = 99.5 cs<br>
	&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Tier 2 Volume (99.5) * Tier 2 Rate ($.14) = 
	<Br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; $13.93 Tier 2
<p></p>
Total Expected For Component: Item 1 Tier 1 ($49.95) + Item 1 Tier 2 ($19.90) + Item 2 Tier 1 ($59.84) + Item 2 Tier 2 ($13.93) = $2113.72.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
All previous billbacks which have claimed against the growth section of the program are shown here. </td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
The final amount available is the growth amount earned (#3 above) minus the growth amount already paid/approved (#4). </td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
The final deviation amount and percentages are figured by subtracting the amount available from the amount claimed. If the amount available is greater than the amount claimed, there is no deviation. Otherwise, the difference between the two is set as the deviated amount. The deviation percentage is what percentage of the billback amount the difference is between the billback and expected amounts. </td></tr>
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
