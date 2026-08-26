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
<tr><th colspan="2"><strong>Approval -- Summary</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_approval_payment_display.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Information on the billback, including the number, date, and total (including adjustments or exclusions applied) is displayed. </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
The address and name of the payee is shown. 
</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
The programs that contribute to the total amount are shown, with how much each program adds.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
Adjustments and exclusions applied to the program are listed. They are subtracted from the tally.
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
The final amount to be paid is shown on the right. If you wish to begin the payment process, click on the [pay this amount] link on the left.
</td></tr>
</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="approval_toc.cfm">
<cfinclude template="approval_updated.cfm">

</body>
</html>
