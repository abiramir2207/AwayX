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
<tr><th colspan="2"><strong>Project -- Summary View</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/proj_summary.gif"></td></tr>

<tr><td valign="top"><img src="../images/1.gif"></td><td>No matter whether you clicked on a priority from the scorecard, searched for a project, or decided to view all projects, you will see this screen.  The information at the top, under "Criteria used", you can see the criteria used to show the projects you see.  In this instance, the records shown all have the priority "Top 3 By Owner".  If the records all resulted for a search for the sponsor Brenda Flynn, then next to "Sponsor" would be the value "Brenda Flynn".</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>If you wish to see more information about each project shown, click on the [detailed view] link.  You will be taken to another screen.  <A href="details.cfm">Click here</A> to see information about that option.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>Information about various programs is shown here.  You can click on the program name or by the priority name to see and modify information about a project.  Clicking on the envelope icon next to a sponsor's name will launch an email window to that sponsor.</td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td>If more than one page of results is shown, you will see these numbers at the bottom of the screen.  To go to the next page of results, click on either the number of the page you'd like to see, or on the arrows pointing right for the next page and left to return to the previous page.  You can identify the current page because the page number will be shown in black and surrounded by brackets.</td></tr>
<tr><td valign="top"><img src="../images/5.gif"></td><td>You can create a new project by clicking on the [create a new project] link or find an existing project by clicking on [search projects].  You can export the list of projects to an Excel spreadsheet by clicking on the [export projects to XL].</td></tr>

</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<cfinclude template="projects_updated.cfm">
</body>
</html>
