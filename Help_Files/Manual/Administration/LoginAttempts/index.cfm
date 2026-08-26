<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: User Management </title>
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
<tr><th colspan="2"><strong>User Management -- Login Attempts</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/user_login_attempts.gif"></td></tr>

<tr><Td>You can establish the number of times a user can provide an incorrect password for their username before their account is locked, and an administrator is required to unlock it.  
</td></tr>

 

</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="loginattempt_updated.cfm">

</body>
</html>
