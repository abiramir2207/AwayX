<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Scorecard</title>
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
<cfinclude template="scorecard_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Scorecard</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td colspan="2">From the homepage, you can see a quick overview of billbacks. </td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_scorecard.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">If the text appears indicating you do not have permission to approve the billback amount (#2), you will not see the option to approve the billback amount (#4).</td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Billbacks have four possible status types: Work in Progress, Request for Approval, Approved and Paid. The number of billbacks in each status type is shown on the right. Clicking on the name of the status will bring you to the scorecard details screen for that status. </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
In addition to displaying information about billbacks, you will also see communications regarding the billbacks.  You will see the number of communications in your inbox, and can click on the link to view them. You may also view your acknowledged billbacks by clicking on that link.</td></tr>
</table>

<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="scorecard_toc.cfm">
<cfinclude template="scorecard_updated.cfm">

</body>
</html>
