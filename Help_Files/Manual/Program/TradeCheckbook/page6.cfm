<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbook</title>
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
<cfinclude template="tradecheckbook_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong><CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbook</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_growth.gif"></td></tr>
<tr><td colspan="2"><p>&nbsp; </p></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
For growth, multi rate and single rate components have different algorithms to calculate how much has been earned. Each component in a program is shown separately. Item information and calculations for the component can be shown by clicking on the [Details for this Component] link.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
Single Rate Component: The total volume for all items is calculated in order to determine which growth tiers have been attained. For example, if the volume of all items is 600 cases, and the tiers are 50 - 200, 201 - 350 and 351 - 500, the third tier would have been attained.  So for single rate, all items would be multiplied by their third tier rates.  In addition, the distributor would have earned all <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s for the first, second and third tiers.
<p></p>
In the above example, however, not all the total volume is eligible. Only 451 cases are - between 50 and 500 (inclusive). Also, the program calculates what percentage of the total component volume each item represents. In this case, Item 1 is 66.66% and Item 2 is 33.33% of the total item volume of 600 cases. The contribution percentage is used to determine how much volume for each item is allocated to each tier.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif">  </td><td>
Multi Rate Components: Multi rate components pay the rate for each tier attained, for the volume allocated to each tier.  
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif">  </td><td>
Billbacks: In order to calculate growth accurately, the volume of all items must be considered together. For that reason, each billback with growth only has one line item, representing the total amount billed back for all items for growth. <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> amounts earned by growth are billed back under <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s - see the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> help files above for details.
</td></tr>
</table>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="tradecheckbook_toc.cfm">
<cfinclude template="tradecheckbook_updated.cfm">
</body>
</html>
