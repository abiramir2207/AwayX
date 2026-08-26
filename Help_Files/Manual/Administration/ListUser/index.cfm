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
<tr><th colspan="2"><strong>User Management -- List Users</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_user_list.gif"></td></tr>
<tr><td>
You can view a list of all users.  Clicking on any part of the users profile will bring up a screen like the "Add user" screen with the information for the user already filled in.  You can edit the user's information from that screen.
</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="listuser_updated.cfm">
</body>
</html>
