<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Main Page</title>
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
<tr><th colspan="2"><strong>Main Navigation</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2">

When you log in to the application, you will always arrive at the home page. The home page allows you to get quickly and easily to most functionality in the application with just a click or two.
<p></p>
You will notice that the top and bottom of the screen do not move when you scroll down, and that when you hit the "refresh" button, you are always brought back to the home page. The persistence of this navigation is designed to help you always quickly and easily transfer between areas of the application.

</td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="manual/images/mainpage1.gif"></td></tr>

<tr><td colspan="2">
The center of the home screen shows the four basic areas. If a link is gray, that indicates that either it is inactive (like PDA exports under number 3 above), your company has chosen not to install it or has not installed it yet, or you do not have permission to access that link. (For example, only administrators can click on the "settings" link.)</td></tr>

<tr><td valign="top"><img src="manual/images/1.gif"></td><td><strong>Programs:</strong> All links regarding programs are shown here. They include create, commodity costs, approval matrix, search, <CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#</CFOUTPUT> and reassign. You may be able to click on some of these (such as create and search) and not others (like reassign and commodity costs) depending on your permissions.</td></tr>
<tr><td valign="top"><img src="manual/images/2.gif"></td><td><strong>Billbacks:</strong> Functionality regarding billbacks is shown here, including create, search and the <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> checkbook.</td></tr>
<tr><td valign="top"><img src="manual/images/3.gif"></td><td><strong>Deployment:</strong> Currently deployment is largely project-oriented, but may include other deployment functionality in the future.</td></tr>
<tr><td valign="top"><img src="manual/images/4.gif"></td><td><strong>Tools:</strong> Application related tools are shown here, including settings for administrators, reports, change password (for everyone), information on required browser settings, news headlines (world, industry, etc.) and an update of the most recent new functionality on the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>.</td></tr>
</table>

<hr width="80%" align="Center" color="orange">

<table align="center" width="90%">
<tr><th colspan="2"><strong>Scorecards</strong></th></tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="manual/images/mainpage2.gif"></td></tr>

<tr><td colspan="2">
Scorecards are also shown on the home page for programs, projects and billbacks. You can switch between scorecards by clicking on the links at the top, and see details by clicking on the status type of the scorecard.
<p></p>
The numbers you see in the scorecard will reflect the programs/projects/billbacks you or someone under you in the permission structure created - not the total number in the system.</td></tr>

</table>

<hr width="80%" align="Center" color="orange">

<table align="center" width="90%">
<tr><th colspan="2"><strong>Top Icons</strong></th></tr>

<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="manual/images/mainpage3.gif"></td></tr>

<tr><td colspan="2">
Wherever you are in the application, you will see a navigation bar at the top of the screen. This bar gives you basic information, such as your name and the date.  There are also a number of navigation elements.
<p></p>
Throughout the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>, the options available to you will depend upon your permission level.  If you do not have permission to view or change an area, you will not be able to click on it, and the link or image will appear gray.  If, for some reason, you need access to that area, please contact an administrator.</td></tr>

<tr><td><img src="../Images/icon_chat.gif" width="35" height="24" alt="" border="0"></td><td>  <em>Xmessenger:</em> Clicking on this image will bring up the Xmessenger, a instant messaging machine which allows you to communicate simultaneously with other users of the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>.  </td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_home.gif" width="29" height="29" alt="" border="0"></td><td> <em> Home:</em> Wherever you are in the application, clicking on this icon will bring you back to the home page.</td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_todo.gif" width="29" height="29" alt="" border="0"></td><td>    <em>To Do List:</em> When you click on this icon, the window for your To Do list will appear.  </td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_programs.gif" width="29" height="29" alt="" border="0"></td><td>  <em>Program Scorecard:</em> This link connects to the Program Scorecard, and automatically displays all active programs.  </td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_projects.gif" width="29" height="29" alt="" border="0"></td><td>  <em>Project Management:</em> This icon brings you to the project management page, where you can create, view or search for a project.   </td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_billbacks.gif" width="29" height="29" alt="" border="0"></td><td>  <em>Billback Scorecard: </em>You can view Work in Progress billbacks by clicking on this icon. </td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_settings.gif" width="29" height="29" alt="" border="0"></td><td>  <em>Settings:</em> To view or change settings, click on this icon.  </td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_help.gif" width="14" height="31" alt="" border="0"></td><td>   <em>Help:</em> Help files can be accessed at any point by clicking on the question mark icon.  This will give you access to all the help files for the entire application.  If you simply want to know about the page you are on, clicking on the [read me first] link will bring up specific help for that page.</td></tr>

<tr><td><img src="../Images/Header_Footer_New/icon_logoff.gif" width="29" height="29" alt="" border="0"></td><td>  <em>Logoff:</em> When you are done using the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>, click on this icon to log off. You will be directed back to our login screen.</td></tr>

</table>

<p></p>
</div>
<HR COLOR="Orange">

</body>
</html>
