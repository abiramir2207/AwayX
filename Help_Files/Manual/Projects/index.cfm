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
<tr><th colspan="2"><strong>Project -- Scorecard</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/proj_scorecard.gif"></td></tr>

<tr><td valign="top"><img src="../images/1.gif"></td><td>You can toggle between viewing the scorecard for projects and programs by clicking on the appropriate link at the top of the scorecard screen. If you are already displaying the scorecard whose link you are clicking on, nothing will happen.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>A summary of priorities and the number of projects for each priority is shown.  The priorities available can be changed or created in the projects section of the administration area.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>If you wish to see all projects, click on [show all projects].  If you wish to search for a particular project or projects, click on [search projects].</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<cfinclude template="projects_updated.cfm">
</body>
</html>
