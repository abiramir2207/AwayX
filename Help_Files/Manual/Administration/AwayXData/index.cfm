<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: <CFOUTPUT>#application.CompanyName#</CFOUTPUT> Data Integration</title>
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
<tr><th colspan="2"><strong><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Data Integration -- Commodities</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_data_awayx.gif"></td></tr>
<tr><td colspan="2">The only information currently being transmitted from <CFOUTPUT>#application.CompanyName#</CFOUTPUT> is Commodity data.</td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
<em>Destination Server:</em> The current destination server. This information is for reference only, and cannot be modified through this screen.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
<em>Destination Path:</em> The location to which files will be transferred on the destination server.  This information cannot be modified in this console.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
<em>File Name:</em> The name of the file being transferred. This information cannot be modified.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif"></td><td>
<em>Last Update Date: </em>The most recent date the information transfer occurred.
</td></tr><br>

<tr><td valign="top"> <img src="../../images/5.gif"></td><td>
Click on the "Start Commodity Process" to integrate the data manually.  Clicking on this is not usually necessary - the commodity integration process is scheduled. The option should only be used when the process encountered a problem, of if an update needs to occur between scheduled updates.
</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="awayx_updated.cfm">
</body>
</html>
