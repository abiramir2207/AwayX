<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: XMessenger</title>
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

<STYLE>
a:hover.prlink
	{
		text-decoration: none;
	}
</STYLE>



<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>XMessenger</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="images/xmessenger.gif"></td></tr>

<tr><td valign="top"><img src="images/1.gif"></td><td><em>Connect to User:</em> Once you have selected a user, from the drop down list, click on the "Connect to User" button. You will then be able to send the selected user text messages.</td></tr>
<tr><td valign="top"><img src="images/2.gif"></td><td>To see a list of users currently online, click on the green window at the top, or on the down arrow to the right.  You will then see a list of users who are currently online.  If your session management settings (part of the administration option) are set so that your session expires after a certain amount of time, you will only see those users whose sessions have been active in that amount of time.  For example, if your sessions are set to expire after an hour, you will not see any users who have not been active in the last hour.  Highlight the person you wish to talk to and click on their name.  Then click "Connect to User".  At that point, you will be able to communicate with the user.</td></tr>
<tr><td valign="top"><img src="images/3.gif"></td><td>The text of your incoming and outgoing messages will be displayed in the center area. New messages are displayed at the top, older messages get pushed down. If a message is gray, it indicates that it was part of a prior conversation.</td></tr>
<tr><td valign="top"><img src="images/4.gif"></td><td>Enter your comments in this text area.</td></tr>
<tr><td valign="top"><img src="images/5.gif"></td><td>When you wish to send your comments to the person you are chatting with, click "send message".  They will not be able to see your message until you click on "send message".</td></tr>
<tr><td valign="top"><img src="images/6.gif"></td><td>After you have finished your conversation, click on the "x" in the upper right hand corner of the XMessenger to close the window and stop chatting.  You will be available to other users if they wish to begin a chat to you even though you have closed XMessenger.</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="xm_updated.cfm">

</body>
</html>
