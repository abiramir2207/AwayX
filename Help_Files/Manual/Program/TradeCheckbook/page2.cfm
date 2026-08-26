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
<tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_collapsed.gif"></td></tr>
<tr><td colspan="2"><p>&nbsp; </p></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
<cfoutput>Choose Another: You can pick a whole new #application.returned_customer_setting.distributor_label_singular#/program combination by clicking on the [Choose Another #application.returned_customer_setting.distributor_label_singular#/Program]. If you want to view a different #application.returned_customer_setting.distributor_label_singular# on the same program, click on the [Choose Another #application.returned_customer_setting.distributor_label_singular#] to be taken to the #application.returned_customer_setting.distributor_label_singular# list. Likewise, if you would like to see another program for the same #application.returned_customer_setting.distributor_label_singular#, clicking on [Choose Another Program] will take you to the program list.</cfoutput>

</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
<cfoutput>Information and Progress: Information about the #application.returned_customer_setting.distributor_label_singular# and program are shown. In red you can see how complete the program is.</cfoutput>
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif">  </td><td>
Show/Hide All Details: Details on the items, invoices and billbacks which make up the checkbook is hidden by default. If you want to see all of the information available, click on the [Show All Details] link in the main screen. If you are only interested in one of the discount types, click on the name of the discount type to view more information about the transactions.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif">  </td><td>
Credits, Debits and Balance: The credits represent the amount earned (with all but <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>, this is the total volume of invoices for the products in the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> types multiplied by the calculated rate). Debits are created by billbacks.  The balance is calculated by subtracting the debits from the credits and reflects the amount earned that has not been billed back. If the balance is positive (the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> has earned more than they have billed back), the balance is displayed in green. If the balance is negative (the <cfoutput>#application.returned_customer_setting.distributor_label_singular# </cfoutput>has billed back more than they have earned) the balance is displayed in red.
</td></tr>
<tr><td valign="top"> <img src="../../images/5.gif">  </td><td>
<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> Types:  You can view the amount earned in each <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type. Clicking on the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> name will display details about the debits and credits for the particular discount type.


<ul>
<li><A href="page3.cfm"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT></A></li>
<li><A href="page4.cfm"><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT></A></li>
<li><A href="page5.cfm">Fixed Price</A></li>
<li><A href="page5.cfm#Formula">Formula Price</A></li>
<li><A href="page6.cfm">Growth</A></li>
</ul>
</td></tr>

<tr><td valign="top"> <img src="../../images/6.gif">  </td><td>Totals: The totals earned, paid and difference is shown at the bottom of the checkbook. This represents the current status of the program for the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>.
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
