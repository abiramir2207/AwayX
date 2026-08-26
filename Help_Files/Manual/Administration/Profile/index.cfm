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
<tr><th colspan="2"><strong>User Management -- Profile</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/user_profiles.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
The user profiles are displayed across the top bar.  The check boxes below the profiles show the settings for the profiles.  The names of these profiles may vary from what you see displayed, but the number of profiles and ability to apply permissions to them does not.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
Clicking on the Group number to the left opens up a screen which allows you to edit the assignments.
</td></tr>


<tr><td colspan="2">
<blockquote>
	<table>
	<tr><td colspan="2" align="center"><img src="../../images/ad_user_typecode.gif"></td></tr>
	
	<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Type codes can only belong in one group.  If a type code is selected for one group, it is not available for the other groups.  For example, here in Group 1, if you were to uncheck "Cheddar", it will now be available to all groups. If Group 5 selects "Cheddar" it will no longer appear as an option for Group 1.
	</td></tr>

	</td></tr>
	</table>
</blockquote>

<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
You can select whether a profile has approval rights and the right to view margins by click the top and bottom box.  If they have approval rights, you can edit information about what margin they need for each group in order to be able to approve a program.  If you enter an asterisk, there is no upper limit on the margin.
</td></tr>
	
Billbacks: You can establish whether users can create, delete, view deviations, and approve billbacks.   You can also establish a maximum amount of deviation a user can approve and whether the user can approve critically deviated billbacks (where the payee is unknown or the program is not found).
</td></tr>
<tr><td valign="top"> <img src="../../images/5.gif"></td><td>
Checking the box gives that permission to the user above access to that permission. Note that the approval amount is the amount of deviation that can be approved, not the amount of the total billback.
</td></tr>
<tr><td valign="top"> <img src="../../images/6.gif"></td><td>
Specify which controls you would like profiles to have access to.
</td></tr>
<tr><td valign="top"> <img src="../../images/7.gif"></td><td>
Checking the box under a user title give that profile permission to view and change the settings.
</td></tr>

</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="profile_updated.cfm">
</body>
</html>
