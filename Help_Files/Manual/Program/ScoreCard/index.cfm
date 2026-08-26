<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Scorecard</title>
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
<cfinclude template="scorecard_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Program Scorecard -- Main Page</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_scorecard.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">You can review information about all programs, projects and billbacks you have permission to see in the scorecard on the front page. </td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
You can toggle between viewing the scorecard for programs and for projects by clicking on the appropriate link at the top of your page.  The link will display the scorecard you selected.  If you only have permission to access programs, you will not see the projects, link, and clicking on the programs link will have no effect.
</td></tr>
<tr><td valign="top" nowrap> <img src="../../images/2.gif"></td><td>
Clicking on any one of these links shows the programs that are in that state.  An explanation of what each status means can be found on the next page.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="scorecard_toc.cfm">
<cfinclude template="scorecard_updated.cfm">

</body>
</html>
