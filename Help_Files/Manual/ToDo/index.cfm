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
<tr><th colspan="2"><strong>To Do List -- View List</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/td_view.gif"></td></tr>

<tr><td valign="top"><img src="../images/1.gif"></td><td>You can choose to close the window at any time.  Click on this link and the window will automatically close itself.  You can reopen the To Do List by clicking on the icon in the upper right hand corner of your screen.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>If you wish to add a new task to your list, click on "add todo".</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td>Your list can be emailed to the recipient or recipients of your choice by clicking on the "email list" link.</td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td>Once you have completed a task, click on the box to the left of the task description.  When you check a box, a pop-up alert will appear saying "Click OK to Delete Item".  If you choose "OK" the item will be permanently deleted from your list.  If you choose "Cancel" the task will not be deleted.</td></tr>
<tr><td valign="top"><img src="../images/5.gif"></td><td>The priority of the tasks is shown as a number.  Highest priority tasks are marked with a 5, lowest priority tasks are marked with a 1. The list of your tasks is sorted in order of importance, with 5/highest priority tasks at the top and 1/lowest priority tasks at the bottom.</td></tr>
<tr><td valign="top"><img src="../images/6.gif"></td><td>You can see the description of the task to the right.</td></tr>
</table>
<p></p>
</div>




<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="todo_toc.cfm">
<cfinclude template="todo_updated.cfm">
</body>
</html>
