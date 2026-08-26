<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Approving a New Program</title>
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
<cfinclude template="viewprogram_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Programs -- Approving a New Program</strong></th></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_approve.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>You can review the details for the program you are thinking about approving.  You can only view, not change, this information.  To change this information go back to the program detail and select "Revise".</td></tr>

<tr><td valign="top"><img src="../../images/2.gif"></td><td>If you would like to view the <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> adjustment, click on the number shown in blue.  The <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> adjustment screen will pop up.  <A href="tradeadjustment.cfm">Click here</A> to view help files on <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> adjustment information.</td></tr>

<tr><td valign="top"><img src="../../images/3.gif"></td><td>If you have permission to view margins, you will be able to see information about Rated Margins, <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s and Margins.  </td></tr>

<tr><td valign="top"><img src="../../images/4.gif"></td><td>If the program margin is within your approval level, you will be given the option to "Pay the Brokerage" or "Do Not Pay Brokerage". Make your selection and then click "Approve This Program". Once the program is approved - if the start date is before or equal to the current date, the program will become active. Otherwise, it will become Pre Active until its start date.</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="viewprogram_toc.cfm">
<cfinclude template="viewprogram_updated.cfm">
</body>
</html>
