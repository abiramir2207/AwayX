<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Project Administration </title>
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
<tr><th colspan="2"><strong>Project Administration -- Priorities</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_proj_priorities.gif"></td></tr>

<tr><td valign="top"> &nbsp;</td><td>
You can see a list of existing priorities under the heading "Stored Records".  As in statuses, clicking on the description of a priority will allow you to edit it to the right.  To create a new priority, click on the [create new entry] link, enter the information to the right, and click on [save data]. 
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<CFINCLUDE TEMPLATE="project_updated.cfm">
</body>
</html>
