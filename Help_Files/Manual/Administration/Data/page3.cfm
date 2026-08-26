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
<tr><th colspan="2"><strong>Data Integration -- <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput></strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_data_distributors.gif"></td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
Information on who made the latest changes to the brokers, and when those changes were made is available at the top of the screen.
</td></tr>

<tr><td valign="top"> <img src="../../images/2.gif"></td><td>
<em>Integration Option:</em> Select whether you would like the data integration to be a daily or weekly process.  If you select daily, you see the screen as above. If you select weekly, you are asked to additionally select which day of the week the operation should take place.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"></td><td>
<em>Specify Date:</em> You can specify a start date and end date for the data integration.  If, for example, you want the process to run only for the month of December, you could choose 12/01/2002 as your start date and 12/31/2002 as your end date.  If you wish to have the data integration be an ongoing process with no start or end date, simply leave the fields blank.
</td></tr>
<tr><td valign="top"> <img src="../../images/4.gif"></td><td>
<em>Start Time:</em> Enter the time of day the process should take place. The red text next to the start time will specify the available window. If it says "Always specify time in the interval 05:50:00 to 05:00:00 AM" then you have a window of 23 hours and 10 minutes to specify the operation should run.  You will also see text asking you to create a start time so that if the start date you selected is the current date, the process will run at least one hour in the future from the current time.
</td></tr><br>
<tr><td valign="top"> <img src="../../images/5.gif"></td><td>
<em>Filenames:</em> The five files that provide information for the <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> are shown here.  You can change the names of the files.
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
