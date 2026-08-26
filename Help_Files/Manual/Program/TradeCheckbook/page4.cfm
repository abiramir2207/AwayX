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
<tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_rebate.gif"></td></tr>
<tr><td colspan="2"><p>&nbsp; </p></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
You can show or hide item level details by clicking on [Show/Hide All Details]. In this instance, item level details are shown. If they were hidden, the green and orange bars would be the only information displayed.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
Rates for <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, Fixed Price, and Formula Price items are calculated nightly. This means that on the day a program is created, the rates may not have been calculated for the distributor/item. In that case, the rate will be shown as $.00.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif">  </td><td>
Credits:  Invoices are gathered for items in the program for the distributor. Any invoices from the beginning of the program date to the end of the program date or the current date (whichever comes first) are shown. Whether the invoice ship date or invoice date qualifies an invoice is set by administrators.  The rate used to calculate the total amount earned is the rate in force on the invoice date. If a program was revised and the rate changed, the item may display two different rates.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif">  </td><td>
Debits: Billbacks against the program/distributor have an orange background, and contain information including the billback date, number and amount paid. Only approved or paid billbacks are shown as debits. 
<p></p>
The exact volume and dollar amount paid for each item is displayed in the billback details.  Clicking on an item will open a window that displays information about the item.
</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="tradecheckbook_toc.cfm">
<cfinclude template="tradecheckbook_updated.cfm">
</body>
</html>
