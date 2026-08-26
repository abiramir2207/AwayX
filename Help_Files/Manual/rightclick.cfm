<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Right Click Menu</title>
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


<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Application Wide Right Click Options</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2">When you click the right button of your mouse in the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>, you will see the following list of options appear:</td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="images/rightclick.gif"></td></tr>

<tr><td valign="top" colspan="2"><em>Back: </em>Clicking on the "Back" arrow will take you to the previous page you visited.  This is very similar to the "Back" arrow your web browser provides, but it can be used on pages where the web browser options are not available.</td></tr>
<tr><td valign="top" colspan="2"><em>Forward:</em> The forward option operates the same way it does on your web browser.</td></tr>
<tr><td valign="top" colspan="2"><em>Programs:</em> Clicking on the programs option will take you to the program creation area.</td></tr>
<tr><td valign="top" colspan="2"><em>Reports:</em> If you click on the reports option, you will be directed to the report writer.</td></tr>
<tr><td valign="top" colspan="2"><em>Projects:</em> If you wish to create a new project, clicking on the "Projects" option will bring you to a new project.  From that point you can also search for projects.</td></tr>
<tr><td valign="top" colspan="2"><em>Add ToDo:</em> Clicking on "Add ToDo" will bring up a window allowing you to add tasks to your "ToDo" list.</td></tr>
<tr><td valign="top" colspan="2"><em>View ToDo:</em> View ToDo will show you the tasks on your list.</td></tr>
<tr><td valign="top" colspan="2"><em>Home: </em>If you click on home, you will be taken back to the home page of the application.</td></tr>
<tr><td valign="top" colspan="2"><em>Logoff:</em> Clicking Logoff will log out of the system and direct you to the login page..</td></tr>
<tr><td valign="top" colspan="2">NOTE: If you wish to access the regular right click menu, hold down the CTRL key on the left hand side of your screen while clicking on the right mouse button.</td></tr>
</table>
<p></p>
</div> 


<HR COLOR="Orange">
<CFINCLUDE TEMPLATE="click_updated.cfm">
</body>
</html>
