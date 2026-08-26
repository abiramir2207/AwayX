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
<tr><th colspan="2"><strong>Project Administration -- Sponsors</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_proj_sponsors.gif"></td></tr>

<tr><td valign="top"> &nbsp;</td><td>
Like the other areas, you can see existing sponsors on the left side of the screen and edit their information on the right.  The amount of information is different, however.  You will be asked to provide a name (first and last name), a title, phone number, email address and availability for a sponsor.  You must create at least a first and last name for the record to be saved.  If you do not enter a first and last name, you will not get an error message, but the user you are creating will not be saved when you click [save data].
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
