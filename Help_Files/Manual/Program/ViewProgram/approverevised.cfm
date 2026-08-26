<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Approving a Revised Program</title>
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
<tr><th colspan="2"><strong>Programs -- Approving a Revised Program</strong></th></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top" colspan="2"> 
If you have permission to view pricing rules, when you view program, you may notice that "Price" as a link shown in blue.  Clicking on one of the numbers will bring up the above screen, which shows the pricing rules for the product price you clicked on.  These pricing rules are set by administrators, and can be set or changed in Programs -> Commodity Pricing.
</td></tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_approve.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>You can review information on the program here.  The amount of information shown here will vary depending on how much information the program contains.</td></tr>

<tr><td valign="top"><img src="../../images/2.gif"></td><td>If you would like to view the <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> adjustment, click on the number shown in blue.  The <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> adjustment screen will pop up.  <A href="tradeadjustment.cfm">Click here</A> to view help files on <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> adjustment information.</td></tr>

<tr><td valign="top"><img src="../../images/3.gif"></td><td>You need to enter the dates the revision will be effective for.  You cannot set the start date any earlier than the day you are approving the revision, and you cannot set the date any later than the end of the original program.  </td></tr>


</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="viewprogram_toc.cfm">
<cfinclude template="viewprogram_updated.cfm">
</body>
</html>
