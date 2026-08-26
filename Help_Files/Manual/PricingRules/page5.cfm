<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Pricing Rules</title>
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
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">

<HR COLOR="Orange">



<div align="center">


<p></p>
<table>
<tr><th colspan="2"><strong>Pricing Rule: Step 4 of 4</strong></th></tr>
<tr><td colspan="2"><div align="center"><img src="../images/pricingrule6.gif"></div></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Selected Options:</em> Review the information you entered here.  Clicking on "View/Hide Products" will display your product list if it is currently not shown, and hide it if it is currently shown.  </td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>You can change any of the information displayed here by clicking on [revise these values].</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td><em>Commodity Formula Cost (including lag):</em> This shows the commodity formula cost including the lag you indicated on the previous page.  </td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td><em>Commodity Formula Cost (as of today):</em> This shows the commodity formula cost calculated from today.  This number is the result of all the information you have entered, and will be used to calculate the margin for a program.  To save this formula and make it available to others to use in creating programs, click on "save the data".  You will now be able to see your pricing rule when creating a new program.</td></tr>


</table>

</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="pricingrules_toc.cfm">
<CFINCLUDE TEMPLATE="pricingrule_updated.cfm">
</body>
</html>
