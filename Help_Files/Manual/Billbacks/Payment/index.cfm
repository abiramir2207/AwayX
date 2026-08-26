<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Payment</title>
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
<cfinclude template="payment_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Payment</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td colspan="2">When a billback has been locked, marked as Ready for Approval, and deviations have been run (you must run deviations again every time you leave the billback and come back to it), you may begin the approval process by clicking on the [continue] link in the deviation screen. </td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_payment_new.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">If the text appears indicating you do not have permission to approve the billback amount (#2), you will not see the option to approve the billback amount (#4).</td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
<em>Transaction date:</em> This simply notes the date the transaction is taking place. </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
<em>Memo Field:</em> The memo field is pre-populated with information about the billback, payee, and billback period.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
<em>Transaction Type:</em> This option will depend upon how your company has arranged to make payments..</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
If you have started the transaction by paying a billback, the amount you have approved will automatically be populated as the amount to be paid. You cannot edit this amount.</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
This option will depend upon how your company has arranged to make payments. </td></tr>
</tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="payment_toc.cfm">
<cfinclude template="payment_updated.cfm">

</body>
</html>
