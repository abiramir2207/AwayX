<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations :: Rate</title>
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
<tr><th colspan="2"><strong>Deviations -- Rate Deviation</strong></th></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">Volumes and approved items are calculated the same way for Fixed Price, Formula Price and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> discounts. Rate, however, is calculated in different ways for each of them.
<p></p>
<strong>Fixed/Formula Price</strong>
<p></p>
Although the rate for fixed and formula price <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s is calculated differently, once the rate is calculated, they are treated the same way in billbacks.
<p></p>
The rate is calculated differently depending on whether the program is a trade program or an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> program.
</td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_ff_rate.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Information on the Billback, Program and Product is displayed at the top.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Date span: The date span is calculated by taking the complete span of the program (through all revisions).  It is then matched up with the billback span - so the beginning is whichever is later, the billback start date or the program start date, and the end is whichever one is earlier, the program end date or the billback end date. </td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
Expected rates are calculated by finding the weighted average of the invoices by taking the total amount paid and dividing it by the total volume purchased. The expected rate is the average revenue minus the expected program rate. That difference is the expected rate used to calculate expected amounts.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
The rate deviation calculation is calculated the same way for fixed and formula price as for <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s.  
</td></tr>

<tr><td colspan="2">
<strong><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT></strong></td></tr>

<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_rate_deviation_rebate.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Information on the billback, program and product are shown at the top of the screen.<Br>
<em>Billback:</em> Shows the billback code, title, span, and the number of days in the span.<br>
<em>Program:</em> Displays the number, type and name of the program.<br>
<em>Product:</em> Shows the product number, description, net weight (used to calculate how many pounds are in a case) and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type in question.</td></tr>

<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
To calculate an averaged (weighted) rate, the span during which each revision is active is divided by the total time the program was active until the end of the billback period.  This produces what percent of the time being billed back each rate was applicable for.  That percent is then multiplied by the rate in force at that time to create a weighted rate. The weighted rates from all revisions are added together. That final number is the expected rate.</td></tr>

<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
Deviations are calculated from this expected rate.
<ul>
<li><em>Total Amount Claimed:</em> The dollar amount claimed for the item in the billback.</li>
<li><em>Total Volume Claimed:</em> The volume of the item claimed for the item in the billback.</li>
<li><em>Rate Claimed:</em> The rate claimed is calculated by dividing the volume claimed by the amount claimed.</li>
<li><em>Expected Rate:</em> The expected rate as calculated in #2.</li>
<li><em>Rate Tolerance:</em> The rate tolerance is set by administrators. It is the percent by which a rate may differ and still not be considered deviated. For example, if the Expected Rate is $.95 and the Rate Claimed is $1.00, if the Rate Tolerance is 10%, the item will not be deviated.</li> 
<li><em>Adjusted Expected Rate:</em> The expected rate plus the additional amount added by the rate tolerance.</li>
<li><em>Deviated Rate:</em> The difference between the Rate Claimed and the Adjusted Expected Rate.</li>
<li><em>Effective Deviated Rate:</em> If the Adjusted Expected Rate is greater than the Rate Claimed, the Effective Deviated Rate will be 0. Otherwise, it will be the deviate rate as shown.</li>
<li><em>Rate Deviation Percentage:</em> The percentage of the rate which is deviated is calculated by dividing the Rate Claimed by the Effective Deviated Rate. </li> 
<li><em>Deviated Amount:</em> The dollar amount of deviation.</li></td></tr>
</ul>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="deviations_toc.cfm">
<cfinclude template="deviations_updated.cfm">

</body>
</html>
