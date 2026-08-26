<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Program Options</title>
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
<tr><th colspan="2"><strong>Programs -- Program Options</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/prog_buttons.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">The following buttons appear on every program:</td></tr>

<tr><td valign="top"><em> Print:</em></td><td>
Allows you to print the program.  The following dialogue box will appear.  Click on [print document] to print the document, [close help] to close the help window while keeping the printable screen open, and [close document] to close both windows.
<p align="center">
<img src="../../images/print.gif">
</p>
</td></tr>

<tr><td valign="top"><em> Email:</em></td><td>
You may email the program to various mail recipients.  You will need to provide the following information.
<p align="center">
<img src="../../images/email.gif">
</p>
</td></tr>

<tr><td valign="top"><em> Fax:</em></td><td>
Allows you to fax the program. You will need to enter the following information.
<p align="center">
<img src="../../images/prog_fax.gif">
</p>
</td></tr>

<tr><td colspan="2">The options below depend on the status of the program and your permissions.</td></tr>

<tr><td valign="top"><em> History:</em></td><td>
The history tab is available only for programs that have been approved.  Clicking on it will bring up the following screen:
<p align="center">
<img src="../../images/prog_history.gif">
</p>
You can see when a change was made, who made it, what the new value is, what the old value was, and what portion of the program was changed.
</td></tr>

<tr><td valign="top"><em> Renew:</em></td><td>
You may renew a program in any status. When you choose to renew a program, an alert will ask you "Are You Positive You Want to Renew This Program?". If you wish to renew the program, click "OK".  You will then be able to edit the program.
</td></tr>

<tr><td valign="top"><em> Cancel:</em></td><td>
After a program is approved, it is available to be cancelled.  When you click on cancel, an alert will appear asking you "Are You Positive You Want to Cancel This Program?"  If you are positive, click "OK".  You will be brought back to the home page.  At that point, the program you cancelled will marked as "Expired" and will appear in the Expired section.
</td></tr>

<tr><td valign="top"><em>Delete:</em></td><td>
Programs can only be deleted when they are a Work in Progress or Ready For Approval.  After that point they need to be cancelled and purged.  When you click on "Delete" and alert will appear asking you "Are You Positive You Want to Delete This Program?"  If you want to delete it, press on "OK".  The program will be permanently deleted, and will not be available anywhere.
</td></tr>

<tr><td valign="top"><em>Purge:</em></td><td>
Purging is only available for expired documents.  If you wish to remove a program from the list of expired programs, click on "Purge".  An alert will appear asking "Are you Positive You Want to Purge This Program?"  Click on "OK" if you do.  The program will be removed from the list of expired programs.
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
