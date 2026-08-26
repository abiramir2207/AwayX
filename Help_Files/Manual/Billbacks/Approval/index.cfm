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
<tr><th colspan="2"><strong>Approval</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td colspan="2">When a billback has been locked, marked as Ready for Approval, and deviations have been run (you must run deviations again every time you leave the billback and come back to it), you may begin the approval process by clicking on the [continue] link in the deviation screen. </td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_approve_1.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">If the text appears indicating you do not have permission to approve the billback amount (#2), you will not see the option to approve the billback amount (#4).</td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
<em>Critical Deviations:</em> There are two ways a billback can be critically deviated. If the payee is unknown (not selected from a search, but typed in) the billback will be critically deviated. Likewise, if even one of the programs in the billback is not known (typed in instead of found by a search) the billback will be critically deviated. </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
<em>Billback Deviation Amount Exceeds Approval Amount:</em> If the amount of deviation on the billback exceeds your approval amount, you will not be able to choose to pay the billback amount. You may still choose to pay the expected amount (if it is not negative), nothing (if it is), or make detailed decisions on what amounts to approve.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
<em>Approve Expected Amount of $$:</em> You can always choose to pay the expected amount as calculated by the application.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
<em>Approve Billback Amount of $$: </em>If the billback deviation amount is within your authority to pay, you can choose to pay the entire amount of the billback.</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
<em>Make Detailed Decisions on What Amount to Approve:</em> This option allows you to select exactly what you will be paying. <a href="page2.cfm">Click here</a> to read more about making detailed payment choices.  </td></tr>


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
