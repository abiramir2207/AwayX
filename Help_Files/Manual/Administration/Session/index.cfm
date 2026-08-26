<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Session Management </title>
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
<tr><th colspan="2"><strong>Session Management</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_session.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
You can choose whether user sessions will log off after an amount of time (which you can specify) or whether you do not wish user sessions to ever be logged off.  We strongly suggest that for security reasons, you choose to have sessions expire after an amount of time that your users find convenient.
</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="session_updated.cfm">
</body>
</html>
