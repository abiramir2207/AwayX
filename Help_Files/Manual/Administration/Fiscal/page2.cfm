<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Fiscal Year </title>
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
<CFINCLUDE TEMPLATE="fiscal_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Fiscal Year</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_fiscal2.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Affirms the number of accounting periods you have chosen.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
Please define the first day of the first period.  You can either type in the date or select the calendar icon (in the calendar screen, pull down the correct month and year.  The window will close when you click on a day.) You can increment or decrement the selected date by one day by using the red up and down arrows. 
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
Please define the length of each period (in days):  Enter the number of days in each period.  The dates for that period will automatically be calculated and shown to the right of the box.  The total number of days you enter needs to equal the number of days in a year.
</td></tr>
<tr><td colspan="2">You must click on the "save" button to make these changes take effect.</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="fiscal_toc.cfm">
<CFINCLUDE TEMPLATE="fiscal_updated.cfm">
</body>
</html>
