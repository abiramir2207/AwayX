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
<tr><th colspan="2"><strong>Project Administration -- Phases</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_proj_phases.gif"></td></tr>

<tr><td valign="top"> &nbsp;</td><td>
A listing of existing phases is shown on the left hand side.  If you wish to edit one of the stored records, click on the description.  Information will appear on the right hand side, which you can then edit.  Click on [save data] to save your changes.  If you wish to create a new phase, click on [create new entry], enter the data for the new entry on the right, and click on [save data].
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
