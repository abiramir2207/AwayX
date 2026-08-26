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
<tr><th colspan="2"><strong>Create a New Program -- Volume</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2">The volume section is designed to help you evaluate how much volume the program is designed to accommodate. For distributor-type programs (Distributor Off-Invoice and Distributor <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter) there are three options: Automated Forecast, Prior Forecast and Manual Estimate. For other program types (<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> types) the only option is Manual Estimate.</td></tr>
<tr><td valign="top" colspan="2"><em>Automated Forecast</em></td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_volume_1.gif"></td></tr>
<tr><td colspan="2">The automated forecast page helps you select the period of time you want the volume to compare to. </td></tr>
<tr><td valign="top" align="center"> <img src="../images/1.gif"></td><td>The information in the orange bar includes details on the program, including the program number, title, and span.
<p></p>
The information below that in white is available because this program already has a forecast. It shows details for the volume forecast that already exists. (Further details available by clicking on the [prior forecast] button.)
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>You do not need to enter information in automated forecast. You can go directly to a new forecast (manual estimate) or view the previous forecast (prior forecast). If you do make a date choice, you will be directed to manual estimate.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>These pre-selected options are for your convenience. There are three basic milestones to measure from: the same period last year (year ago volume), the volume from the period immediately prior to the current date (most recent), and the volume immediately prior to the planned date of the program (program start). You must select a period that has already occurred.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>If none of the options on the left covers the date range you would like to use for your comparison period, enter the dates you want on the right. Please note: you need to select a period which has already happened, and the end date of the period needs to be after the start date.
</td></tr>

<tr><td valign="top" colspan="2"><em>Prior Forecast/Manual Estimate</em></td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_volume2.gif"></td></tr>
<tr><td valign="top" colspan="2" align="center">The prior forecast and manual estimates have the same display areas. The difference is that the prior forecast takes its information from a previously saved forecast, while the manual estimate takes its information from the dates you picked in automated forecast.</td></tr>
<tr><td valign="top" align="center"> <img src="../images/1.gif"></td><td>If you believe the volume number you entered in the very beginning of the program creation process is correct, and evenly divided between all the products, you can apply the volume entered divided by the number of items to all the products. You can also enter a volume amount and apply it to all products.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/2.gif"></td><td>You can increase either the historical value or program value for all products by a certain amount or percentage by making the correct selections in the Overage Applicator.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/3.gif"></td><td>Information about the products is shown here. You can select or deselect the items for the multi-product applicators above.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/4.gif"></td><td><em>Historical Volume:</em> This is the volume of the product for all the <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> in the period selected in the Automated Forecast.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/5.gif"></td><td><em>Annual Volume:</em> The volume for the products over the past year.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/6.gif"></td><td><em>Program Volume:</em> Enter the volume that you believe all <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> will do over the period of the program.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/7.gif"></td><td>As you enter or select volumes for all the products, the total volume for the program quantity updates to reflect your changes. If you want the calculated number to replace the number you entered in the basic information section, check the box. If you click [apply], your settings will be saved and reflected. If you click [close], the window will close without any of your changes.
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
