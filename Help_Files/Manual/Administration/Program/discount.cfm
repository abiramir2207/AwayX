<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Discount Types </title>
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
<cfinclude template="programs_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Program Wizard -- Summary</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/pw_summary.gif"></td></tr>

<Tr><td colspan="2">Information on what you entered is shown on the summary page (which can also be reached by clicking on the [view] link from the main page. If the program template you are viewing has not been activated, there will also be an [activate] button.</td></TR>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>
You can see which elements from basic information you have chosen to include in the program template.
</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td>
Rate types selected will be shown. If you have selected a default value, the word default will appear on the right side of the line.
</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td>
The claim mechanics you have selected are displayed.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td>
All available payment periods you have selected are shown.
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td>
Discount types available are shown.
</td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td>
If you have selected any claim/performance requirements, they will be displayed.
</td></tr>


</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="programs_toc.cfm">
<CFINCLUDE TEMPLATE="programs_updated.cfm">
</body>
</html>
