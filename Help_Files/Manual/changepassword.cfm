<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Change Password</title>
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

<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Change Password</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="images/user_change_password.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">It is recommended that you change your password on a regular basis.  </td></tr>
<tr><td valign="top"> <img src="images/1.gif"></td><td>
When selecting a new password, you need to find a password that is 8 or more characters long.  We suggest that your password be a mix of numbers and letters, and that it be difficult for others to guess. 
</td></tr>
<tr><td valign="top" nowrap> <img src="images/2.gif"></td><td>
Enter your old password - the same way you would when you log in.
</td></tr>
<tr><td valign="top" nowrap> <img src="images/3.gif"></td><td>
Enter your new password twice.
<p></p>
You will immediately be logged out of your account, and will need to log in again. You will receive an email confirming that your password has changed.
</td></tr>
</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="changepassword_updated.cfm">

</body>
</html>
