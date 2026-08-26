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
<tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_fixed.gif"></td></tr>
<tr><td colspan="2"><p>&nbsp; </p></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Fixed price invoices are gathered using the same criteria as <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> invoices. The rate for items in the fixed price is also calculated on a nightly process.  In fixed and formula price, the invoice price paid minus the program rate is multiplied by the volume to calculate the amount earned. The algorithm would look like this: 
<Br>
(Invoice Price - Program Cost) * Volume = Amount Earned
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
Rates for <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, Fixed Price, and Formula Price items are calculated nightly. This means that on the day a program is created, the rates may not have been calculated for the distributor/item. In that case, the rate will be shown as $.00.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
Billbacks are dealt with the same way in <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, Fixed Price and Formula price discount types.
</td></tr>
<tr><td colspan="2"><hr width="85%" color="navy"></td></tr>
<tr><td colspan="2"><strong><a name="Formula">Formula Price</a></strong></td></tr>
<tr><td colspan="2">Formula price debits and credits are calculated the same way fixed price credits and debits are.</td></tr>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="tradecheckbook_toc.cfm">
<cfinclude template="tradecheckbook_updated.cfm">
</body>
</html>
