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
<tr><th colspan="2"><strong>User Management -- Unlock User</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/unlock_user.gif"></td></tr>

<tr><Td>If a user has unsuccessfully attempted to log in more times than is allowed according to your settings, their account will become locked.  When a user's account is locked, they cannot log in even if they enter the correct user name and password.  In order for them to log in again, an administrator will need to unlock them.
<p></p>
You can view a list of all locked users from the administration screen.  To unlock a user, simply click on the "unlock this user" link next to the user's name.  The user will then receive an email with a new generated password. They will need to change the password the next time they log in.
</td></tr>

 

</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="unlockuser_updated.cfm">

</body>
</html>
