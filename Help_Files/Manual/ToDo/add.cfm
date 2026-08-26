<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: To Do List</title>
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
<cfinclude template="todo_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>To Do List -- Add To List</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/td_add.gif"></td></tr>

<tr><td valign="top"><img src="../images/1.gif"></td><td>You can close the "To Do" window at any time by clicking on the "close window" link.  If you have entered a task in the box below and have not saved the text, you will lose the information you have entered when you close the window.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>Clicking on "view todo list" will take you to your original view screen.  As in close window, if you view the todo list without saving the text you have entered, what you entered will be lost.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td><em>Enter Item Text:</em> Enter the description of the task you would like to add to your list here.</td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td>You can assign a priority to your task.  The default value is Medium.  Tasks are ordered by their priority in your list.</td></tr>
<tr><td valign="top"><img src="../images/5.gif"></td><td>Once you are satisfied with your entry and the priority you have assigned for it, click on "save text".  You will be returned to view your to do list.</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="todo_toc.cfm">
<cfinclude template="todo_updated.cfm">
</body>
</html>
