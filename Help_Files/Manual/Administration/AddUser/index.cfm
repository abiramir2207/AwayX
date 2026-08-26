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
<tr><th colspan="2"><strong>User Management -- Add a User</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_user_adduser.gif"></td></tr>

<tr><Td>User Position:</TD><td>Select which user position this user should belong to.  The positions are in alphabetical order.  This is a required field.</td></tr>
<tr><Td>User Profile:</TD><td>Select the user profile appropriate for the user you are adding. This is a required field.</td></tr>
<tr><Td>First Name: </TD><td>The first name of the user.  This field is required.</td></tr>
<tr><Td>Last Name:</TD><td>The user's last name.  This field is required.</td></tr>
<tr><Td>Select Company:</TD><td> Select the company this user is associated with.  This is a required field.</td></tr>
<tr><Td>Title:</TD><td>Enter the title for the user you are adding. This is a required field.</td></tr>
<tr><Td>Address 1:</TD><td>Enter the first part of the users' address. This is a required field.</td></tr>
<tr><Td>Address 2:</TD><td>Enter the second part of the user's address. This is not a required field.</td></tr>
<tr><Td>City/State/Zip:</TD><td>Enter the city, the state and the postal code for the user you are adding. All three fields are required.</td></tr>
<tr><Td>Phone:</TD><td>Enter your phone number, including your area code. The three phone fields are required.  The extension is not required.</td></tr>
<tr><Td>Fax:</TD><td> Enter your fax number, including area code. These three fields are required.</td></tr>
<tr><Td>Email:</TD><td> Enter your email address. This is a required field.</td></tr>

 

</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="adduser_updated.cfm">

</body>
</html>
