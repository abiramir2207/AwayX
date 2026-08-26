<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations :: <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT></title>
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
<tr><th colspan="2"><strong>Deviations -- <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Deviations</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_lumpsum_deviation.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Information on the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> amounts in the billback.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Displays the value of <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> components in the program.  </td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
Displays the value of the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> portions of growth components in the program.  <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> expected amounts are only calculated if growth is claimed for an item in that program in the billback.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
This shows which tier of growth the payee has earned, and what <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> accompanies that tier.</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
<CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s amounts approved or paid on other billbacks for the same program and payee are displayed here. </td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
The amount of <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> funds available to pay is calculated by adding the total program <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s available and subtracting the amount already paid or approved from other billbacks.  The end result of that calculation is the expected total for <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s.</td></tr>
<tr><td valign="top"><img src="../../images/7.gif"></td><td valign="top">
The bottom five lines sum up the deviation for <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s in the billback.
<ul>
<li><em><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Amount Claimed:</em> This is the amount the billback is requesting for payment.</li>
<li><em>Expected <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Amount:</em> The amount calculated in bullet #6 is displayed here.</li>
<li><em>Deviated Amount:</em>  Any difference between the expected <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> amount and <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> amount claimed is displayed here.</li>
<li><em>Effective Deviated Amount:</em> If the expected amount is greater than the claimed amount, the effective deviated amount is 0.</li> 
<li><em><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Deviation Percentage:</em> The <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> deviation percentage is calculated by dividing the effective deviated amount (above) by the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> amount claimed.  </li>
</ul></td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="deviations_toc.cfm">
<cfinclude template="deviations_updated.cfm">

</body>
</html>
