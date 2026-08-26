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
<tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_lumpsum.gif"></td></tr>
<tr><td colspan="2"><p>&nbsp; </p></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
The total <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> available to the distributor is displayed. Each distributor on a program is eligible for the entire amount of the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>. For example, if a program has four distributors and a $1000 <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>, each distributor will show a $1000 credit.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif">  </td><td>
Billbacks against the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> are displayed as debits. The date of the billback, the payable number, billback number (from the distributor) and total amount claimed are displayed.  Since in billbacks for growth and regular <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s are grouped together, and the sum of all entered <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s can be paid, the "debit" for growth <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s is displayed in this area. In a correctly paid billback, the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> section would show a negative amount and the growth section would show a positive amount.
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
