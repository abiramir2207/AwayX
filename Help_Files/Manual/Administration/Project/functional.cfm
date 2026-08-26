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
<tr><th colspan="2"><strong>Project Administration -- Functional Areas</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_proj_functional.gif"></td></tr>

<tr><td valign="top"> &nbsp;</td><td>
All functional areas available to projects are listed on the left side of the screen.  If you would like to edit a functional area, click on its description.  You can then edit the description and availability on the right side, and save your changes by clicking [save data].  You can create a new entry by clicking on the [create new entry] link, entering the information in the field on the right, and clicking [save data].


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
