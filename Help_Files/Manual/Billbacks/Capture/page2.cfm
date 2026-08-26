<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Billbacks :: Entering Billback Information :: Payee</title>
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
<cfinclude template="capture_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Billback Information -- Payee</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/billback_capture_payee.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
Once you have created the billback, basic information about it will be displayed at the top of the screen, including the billback code, the title, amount, billback date, and delivery period. </td></tr>
<tr><td valign="top" nowrap><img src="../../images/2.gif">&nbsp;-&nbsp;<img src="../../images/4.gif"></td><td valign="top">
You can select a known <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> or broker by clicking the appropriate radial button at the top of the screen and then clicking on the blue links shown at bullet 4 to open the appropriate search screen. If you cannot find the payee who issued the billback using the search screens and do not believe they are in the system, you may select an unknown <cfoutput>#application.returned_customer_setting.distributor_label_singular#, #application.returned_customer_setting.operator_label_singular#</cfoutput> or broker by checking the "Unknown" checkbox.  That will allow you to enter information regarding the payee:
<p></p>
<div align="center"><img src="../../images/billback_capture_payee2.gif"></div>
<p></p>
You must enter a name, first line of the address, city, state and postal code for unknown payees.
<p></p>
Information on broker, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> and <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> searches is available at other points in these help files. Please refer to them.
<p></p>
If you do not know whether the payee is an <cfoutput>#application.returned_customer_setting.operator_label_singular#, #application.returned_customer_setting.distributor_label_singular#</cfoutput> or broker, you can select the "Other" radial button, which will allow you to enter information about the payee.
<p></p>
PLEASE NOTE: If you enter an unknown <cfoutput>#application.returned_customer_setting.distributor_label_singular#, #application.returned_customer_setting.operator_label_singular#</cfoutput> or broker, or you select "Other" as your payee type, your billback will automatically be 100% and critically deviated.  Even if you enter information identical to the information contained in the system, unless you select the payee from the search screen, the payee will NOT be matched with the programs they are a part of, and their invoices will not be found.  You will not be able to view deviations on this billback, and expected amounts will be $0.  Some users who can approve billbacks with known payees will not be able to approve billbacks with unknown payees.
</td></tr>

<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
You may enter notes about the payee you have selected.  
<p></p>
Your selections will not be saved unless you click "Save".</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="capture_toc.cfm">
<cfinclude template="capture_updated.cfm">

</body>
</html>
