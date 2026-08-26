<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Data Integration</title>
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
<CFINCLUDE TEMPLATE="data_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Data Integration -- Basic Information</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_data_basic.gif"></td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
The navigation at the top of the screen allows you to manage all the internal data feeds.
<p></p>
<em><A href="#">Basic Info:</A></em> Manage basic information about all the data feeds.  <br>
<em><A href="page2.cfm">Brokers:</A></em> Data feeds that supply broker information.<br>
<em><A href="page3.cfm"><cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>:</A></em> Data that supplies <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> information.<br>
<em><A href="page4.cfm">Products:</A></em> Information about products.<br>
<em><A href="page5.cfm">Log:</A></em>  The logs keep a record of any failures in the data feed, allow you to view the failures, and create a text file about the failures.

</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
The person who most recently changed the basic settings, and the date and time on which they did so are recorded at the top of the screen.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
<em>Server Name:</em> The file server to which the data feeds are sent.  This information is displayed for your reference only - you cannot edit it.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif"></td><td>
<em>Path:</em> The directory path to which the files are sent. This information cannot be changed.
</td></tr><br>
<tr><td valign="top"> <img src="../../images/5.gif"></td><td>
<em>Email Addresses:</em> The email addresses to which notifications should be sent.  Multiple addresses should be separated by semi-colons.  You can edit or change this information.
</td></tr>
<tr><td valign="top"> <img src="../../images/6.gif"></td><td>
<em>Text File Creation Time:</em>  Select the time the file should be created.  There is an available interval listed in red.  For example, if it says "Select a time in the interval from 05:20:00 AM to 04:40:00 AM" you can select any time in a 23 hour 20 minute period.  The only period you must avoid is between 4:40 AM and 5:20 AM.  That time is reserved for another process.
</td></tr>
<tr><td colspan="2">When you are satisfied with you choices, click on "Save Settings". Settings will not be saved unless you save.  If you go to another screen without saving, your settings will be lost.</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="data_toc.cfm">
<CFINCLUDE TEMPLATE="data_updated.cfm">
</body>
</html>
