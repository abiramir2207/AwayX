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
<tr><th colspan="2"><strong>Create a New Program -- <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_distributor.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>You can search for a <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> by Family Name, Buying Group, Line of Business, Status, Zone, Region, Broker or name.  The more criteria you include about the <cfoutput>#application.returned_customer_setting.distributor_label_singular# or #application.returned_customer_setting.distributor_label_plural#</cfoutput> you are looking for, the fewer results will be returned.
<p></p>
You can sort your search results by Family Name, Buying Group, Line of Business, Status, Zone, Region, Broker or Name.  You can also choose whether you want the results shown ascending or descending.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>The first time you view this page, the "Currently selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput>" will display as "none".  Once you have selected and added brokers to the program, they will appear in the "Currently selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput>" area.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>To add <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> to your program from the results returned by your search, simply click on the check box next to the broker's name. If you wish to select all the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> on a result page click on the check box in the orange header.  To save your choices, click on the "save" button.  If you wish to modify your choices, choose the "<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>" tab from the top navigation.  When you click save, you will automatically be taken to the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> weighting screen.
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
