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
<tr><th colspan="2"><strong>To Do List -- Email List</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/td_email.gif"></td></tr>

<tr><td valign="top" colspan="2">You can email your list to as many recipients as you choose.  Simply enter the email addresses you wish to send the list to, separated by semi-colons (;).  Click on "send email".  You will be returned to your to do list.</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="todo_toc.cfm">
<cfinclude template="todo_updated.cfm">
</body>
</html>
