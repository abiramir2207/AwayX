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
<tr><th colspan="2"><strong>Project -- Search</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/proj_search.gif"></td></tr>

<tr><td valign="top" colspan="2">

If you have permission as an administrator, you can click on the link at the top of this screen to add or modify statuses, priorities, phases, sponsors and functional areas.
<p></p>
You can search for a project by the following criteria:
<ul>
<li>Project name</li>
<li>CER/Acct Number</li>
<li>Sponsor (from list)</li>
<li>Owner Position (from list)</li>
<li>Functional Area Responsible (from list)</li>
<li>Priority (from list)</li>
<li>Status (from list)</li>
<li>Phase (from list)</li>
<li>Beginning date</li>
<li>End Date</li>
<li>Value in pounds - you can select whether you would like the value to be equal to (=), greater than (&gt;), less than (&lt;), greater than or equal to (&gt;=), less than or equal to (&lt;=), or not equal to (&lt;&gt;).</li>
<li>Dollar value</li>
<li>Resource cost</li>
<li>Budget</li>
<li>Actual cost</li>
<li>Support</li>
</ul>
If you select more than one criteria, the results shown will need to match both. 
<p></p>
You can sort returned results by project, name, order, records per page, and view.  The results of your search will be displayed in the summary view with the criteria for the search displayed in the top bar.

</td></tr>

</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<cfinclude template="projects_updated.cfm">
</body>
</html>
