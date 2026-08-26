<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations</title>
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
<cfinclude template="deviations_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Deviations</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td colspan="2">You must run the deviations routine before being approving a billback. If you run the routine and then leave the process, to account for changes in the data over time, you must re-run the deviations routine before being allowed to proceed. </td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_deviations_survey.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Deviations are processed using multiple steps, with each step represented by a block in the upper right hand corner of the window.  During the process, you can choose to move forward to the next calculation using the [next] link, backwards to the prior calculation using the [previous link] or click on [run all] to have all the calculations made at once. PLEASE NOTE: Calculating all the deviations can take some time. If you have a slower internet connection, you might choose to use the [next] link to process the deviations. 
<p></p>
Once you have reviewed all the deviations, click on the [continue] link to select the amounts to approve for payment.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Information entered in the "Program" section of the billback is shown on the left hand side in black.  </td></tr>

<tr><td colspan="2"><strong>Deviation Details:</strong>
<p></p>
Details for <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> and Growth are shown separately for each program, and for each item with Fixed, Formula and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>.  
</td></tr>

<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
<A href="page2.cfm"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Deviation</A></td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
<A href="page3.cfm">Growth Deviation</A></td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
<A href="page4.cfm">Item Deviation</A> </td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
<A href="page6.cfm">Rate Deviation</A> </td></tr>
<tr><td valign="top"><img src="../../images/7.gif"></td><td valign="top">
<A href="page7.cfm">Volume</A> </td></tr>
<tr><td valign="top" nowrap><img src="../../images/8.gif"> - <img src="../../images/9.gif"></td><td valign="top">
The total amount of deviation for a <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>/item combination is shown both in dollar values and in percentages. An item cannot be more than 100% deviated, or deviated for a dollar value greater than the claimed dollar amount. </td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="deviations_toc.cfm">
<cfinclude template="deviations_updated.cfm">

</body>
</html>
