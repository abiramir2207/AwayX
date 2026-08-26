<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Approval</title>
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
<cfinclude template="approval_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Approval -- Details</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_approve_details.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">If the text appears indicating you do not have permission to approve the billback amount (#2), you will not see the option to approve the billback amount (#4).</td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
<em>Amount Selected:</em> This number is a running tally of the dollar amounts you are selecting. </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
<em>Deviations:</em> You can still view deviation details to help you understand exactly why and how the expected amounts are calculated.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
<em>Program Level Selects:</em> If you want to select one type of payment for an entire program, click on the blue link with the check next to it. You will need to make a selection for each program in the billback. You can still make different detailed choices - for example if you want most of the program to be approved at the billback rate, except for the growth and <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>. Click on the top "billback", and then make your selections for growth and <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> separately.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
<em>Billback:</em> You can select to pay the amount entered in the billback. For <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>, notice that you can pick any number of the components to approve.</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
<em>Expected:</em> You can elect to pay the amount the system has calculated. </td></tr>

<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
<em>None:</em> You can choose to pay nothing instead of the billback or expected amounts. </td></tr>
<tr><td valign="top"><img src="../../images/7.gif"></td><td valign="top">
<em>Next:</em> If the deviated amount of the billback (the difference between what you are choosing to approve and the expected amount) is less than your approval level, you will be able to go to the next screen. Clicking "Next" does not finalize the approval. </td></tr>

<tr><td colspan="2">
NOTE: Rates are rounded to two digits. It is possible for a number to show as $.00 and still have a very small value. The real value will be used to calculate payment.</td>
</tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="approval_toc.cfm">
<cfinclude template="approval_updated.cfm">

</body>
</html>
