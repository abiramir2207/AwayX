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
<tr><th colspan="2"><strong>Project Administration -- Status</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_proj_status.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
<em>Stored Records:</em>  You can view the status types that already exist on the left hand side, and whether the status type (the stored record) is active or inactive.  An active record will be available for project creation, an inactive record will not.  If you wish to edit a record, click on the description.  The information will then appear in the text field on the right side.  
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
<em>Create New Entry:</em> If you want to add a new entry to the available records, click on the [create new entry] link.  When you enter information in the fields to the right and click on [save data] a new entry will be created.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
Whether you create a new entry or are editing an existing one, enter the information for the new status in the text box marked "Description" and select what availability you would like the status type to have, active or inactive, by selecting the option next to availability.  When you are satisfied with your changes, click on the [save data] link.  Your changes will not be registered unless you save the data.
<p></p>
If you cannot select "inactive" as an option because it is disabled (grayed out) that is because there is at least one active project with the status.
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
