<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Deviations :: Date</title>
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
<tr><th colspan="2"><strong>Deviations -- Date Deviation</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_date_deviation.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
In order to ensure that <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s are only claimed once, for Fixed, Formula Price, and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type incentives, a date comparison is run.  All previously approved billbacks that have the same payee, programs, items, discount type and dates are displayed.  The billback currently being considered is shown in bold.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
This is a graphical representation of the information shown above. The other billbacks are shown in black. The currently considered billback is shown in red (for deviated portions) and blue (for non-deviated portions). </td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
The deviation amount is calculated by determining:
<ul>
<li>The total interval for the billback currently being considered</li>
<li>The number of days on that billback that have been claimed on a previous billback. <br> NOTE: Even if there is more than one previous billback for a span of time, the time is not "doubly deviated". Either a day is a legitimate day for the billback being considered, or it is not - whether the deviation is caused by one billback or twenty.</li>
<li>The Overlap Percentage is calculated by finding what percent of the days in the currently claimed billback are deviated.  </li>
<li>The total dollar amount claimed by the current billback, without deviations.</li>
<li>The deviated amount is the total dollar amount multiplied by the Overlap Percentage.</li>
</ul>
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="deviations_toc.cfm">
<cfinclude template="deviations_updated.cfm">

</body>
</html>
