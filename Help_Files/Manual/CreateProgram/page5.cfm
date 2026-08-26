<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Create a New Program</title>
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
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Create a New Program -- Broker</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_broker.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>You can search for brokers to add to your program by five criteria: Zone, Region, Line of Business, Status, and Name.  As with <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> and <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, selecting more criteria narrows the number of search results.
<p></p>
You can sort your search results returned by Zone, Region, Line of Business, Status and Name. You can choose to have returned results shown ascending or descending.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td><em>Currently Selected Brokers:</em> The first time you view this page, the "Currently selected brokers" will display as "none".  Once you have selected and added brokers to the program, they will appear in the "Currently selected brokers" area.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td><em>Automated Broker Selection:</em> If you have selected <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> for the program, the brokers for those <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> will automatically appear in this area. You cannot remove or add automatically selected brokers - you can only do so by removing the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> they serve. You may see fewer brokers selected than <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>. If several <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> are served by the same broker, that broker will only appear once.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>The brokers in this list are returned by your search. You can select a broker to add to the program by clicking selecting the check box next to the broker's name. If you wish to select all the brokers on a page, click on the check box in the top of the list. You can view details on a broker by clicking anywhere in the broker information. A screen will pop up with additional details.
</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
