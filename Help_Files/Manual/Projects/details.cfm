<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Projects </title>
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
<cfinclude template="project_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Project -- Detailed View</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/proj_detailed.gif"></td></tr>

<tr><td valign="top"><img src="../images/1.gif"></td><td>The criteria used to determine which projects to display is the same is in the project summary view.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>If you wish to see a summary of projects instead of more detail about them, click on the [summary view] link.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>In addition to the information displayed in the summary view, the detailed view also shows information such as the Qbrands, Brokers, <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> and Programs involved in the project, and the Next Steps for the project.</td></tr>

</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<cfinclude template="projects_updated.cfm">
</body>
</html>
