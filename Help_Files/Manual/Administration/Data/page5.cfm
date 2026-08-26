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
<tr><th colspan="2"><strong>Data Integration -- Log</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_data_log.gif"></td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
If you want to create a text file of all the recorded errors, click on [create text file].  You will then be shown the information in the dialogue box shown by number 5.  You may then save this file wherever you choose, and refer to it as you find necessary.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
<em>Log Name:</em>  The name of the log.  If there are any errors, the name becomes a link you can click on to view details about the errors.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
<em>Start date</em>: The date that the import began being run on.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif"></td><td>
Count: The number of errors recorded for a particular data import.  It will also become a link to details if there are any errors.
</td></tr><br>
<tr><td valign="top" colspan="2"> 
If you click on a link, you will see the following page:<p></p></td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_log2.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Clicking on [create text file] will create a text file the item you selected.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
You can return to the previous page by clicking on [back].
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
A brief description of what the error numbers mean for the errors returned to you is provided here.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif"></td><td>
The item number, description, case_upc and error number are displayed.  You can click on the text to see details about the error.
</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_data_log3.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Information about the problem that caused the error is shown in red.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
Details about the item involved in the problem are shown.  In this case, the error is created because there is no existing data, so the existing data is not available to be shown.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="data_toc.cfm">
<CFINCLUDE TEMPLATE="data_updated.cfm">
</body>
</html>
