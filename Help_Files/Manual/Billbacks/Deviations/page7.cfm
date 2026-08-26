<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations :: Volume</title>
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
<tr><th colspan="2"><strong>Deviations -- Volume Deviation</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_volume_deviation.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">Items are checked to see if they are included in the program with the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type being claimed for them.</td></tr>
<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Billback, Program and Product information is displayed at the top of the screen.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
The date match verifies how much of the billback is actually within the delivery period.  Days not within the span of the program are not counted. </td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
Billback Overlaps: Approved or paid billbacks with the same payee, program, item and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type are shown in the billback overlap section. The black lines represent other approved or paid billbacks. The red portion of the billback is deviated, and the blue portion is not deviated.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
This algorithm helps determine how much volume for the item was previously approved/paid. The amount each prior billback overlaps the current billback is calculated by dividing the overlapping amount by the total amount of the prior billback. This percentage is then multiplied by the volume paid/approved in the prior billback.  The weighted volumes calculated that way are then added together from all the billbacks. This is the total volume from overlapped billbacks, which is not available to be claimed by this billback.  You can hide or display this information by clicking at link at the top.
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
Invoices: Invoices are gathered between the beginning of the program or billback, whichever comes last, and the end of the program or billback, whichever comes first.  Whether the qualifying date for inclusion of an invoice is the invoice date or the ship date depends upon a setting chosen by the administrator of the system. The total volume for all the invoices in the period is collected as the total available volume. You can hide or display this information by clicking at link at the top.
</td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
A summary of the information shows:
<ul>
<li><em>Delivery Period:</em> The period during which invoices were considered eligible to be counted towards the expected volume.</li>
<li><em>Total Pounds/Cases Invoiced:</em> The total volume of the item purchased, in both cases and pounds.</li>
<li><em>Total Pounds/Cases in Previous Billbacks:</em> The total amount already claimed in previously paid/approved billbacks.</li>
<li><em>Expected Volume Pounds/Cases: </em>The expected volume is the invoiced volume minus the previously paid/approved billback volume.</li>
</ul>
</td></tr>
<tr><td valign="top"><img src="../../images/7.gif"></td><td valign="top">
Volume Deviation Calculation: 
<ul>
<li><em>Total Claimed:</em> The amount, volume and rate claimed are displayed in the top three lines.</li>
<li><em>Expected Volume:</em> The expected volume as calculated in bullet 6 is displayed.</li>
<li><em>Volume Tolerance:</em> The volume tolerance is a setting established by the administrator as a percentage.</li>
<li><em>Adjusted Expected Volume:</em> Reflects the extra volume allowed by the tolerance.</li>
<li><em>Deviated Volume:</em> The deviated volume is the difference between the Adjusted Expected Volume and the Total Volume Claimed.</li>
<li><em>Effective Deviated Volume:</em> If the Deviated Volume is positive, the Effective Deviated Volume will be 0. Otherwise the Effective Deviated Volume is the Deviated Volume.</li>
<li><em>Volume Deviated Percentage:</em> The Effected Deviated Volume divided by the Total Volume claimed is the Volume Deviation percentage.</li>
<li><em>Deviated Amount:</em> The deviated dollar amount is the Volume Deviation Percentage multiplied by the Total Volume claimed.</li>
</ul>
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
