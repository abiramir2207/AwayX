<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: View One Program</title>
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
<cfinclude template="viewprogram_toc.cfm">
<HR COLOR="Orange">
<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Programs -- View one program</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_modify.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
When you first arrive at the program detail screen, the information will be for your review only.  If you wish to modify the program, click on the lock.  If someone else is currently modifying the program, the lock will appear closed and text will appear in red showing who has locked the program.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
The information in the upper right hand corner of the screen changes depending on what the status of the program you are looking at is, and what your permissions are.  You may have permission to view margins, to approve programs, both, or neither.  
<ul>
<li><em>Work in Progress:</em> There are no options for work in progress.  Once you lock the program, you can mark the program as ready for approval.</li>
<li><em>Request for Approval:</em> Once you lock the program, if you have approval permissions, you may approve it.  If you have margin permissions but not approval permissions, you will see an option to view margins.</li>
<li><em>Pre Active:</em>  If you have margin permissions, you will see the "View Margins" option.</li>
<li><em>Active:</em> If you have margin permissions, you will see the "View Margins" option.</li>
<li><em>Expiring:</em> If you have margin permissions, you will see the "View Margins" option.</li>
<li><em>Expired:</em> No option is shown.</li>
</ul>
</td></tr>
 <tr><td valign="top"> <img src="../../images/3.gif"></td><td>
Information about the program is shown here.  If you wish to edit this information, you need to lock the program.  You will then be taken to a screen which will allow you to edit the information.
</td></tr>
 <tr><td valign="top"> <img src="../../images/4.gif"></td><td>
Details about the products included in the program are shown here.  Lock the program to edit this information.
</td></tr>
 <tr><td valign="top"> <img src="../../images/5.gif"></td><td>
The number of options depends on the status of the program, your permissions and whether or not the program is locked.  View the <A href="programbuttons.cfm">Program Options help</A> for information.
</td></tr>

</td></tr>
</table>
<p></p>
</div>



<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="viewprogram_toc.cfm">
<cfinclude template="viewprogram_updated.cfm">
</body>
</html>
