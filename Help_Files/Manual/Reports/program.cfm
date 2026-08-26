<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Reports :: Program Summary Report</title>
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
<cfinclude template="reports_toc.cfm">

<!---Orange bar--->
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Reports -- Program Summary Report</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/rep_program.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>


<tr><td valign="top"><img src="../images/1.gif"></td><td> 
There are three different types of reports that can be generated: Program Summary Reports, Product Summary Reports, and Margin Analysis Reports.  You can create a new report of one of these types by clicking on the appropriate tab. You can view saved programs of these three types by clicking on "Saved Reports".
</td></tr>

<tr><td valign="top"><img src="../images/2.gif"></td><td> 
<em>Status:</em> You can create a report that only displays programs of a certain status.  If you wish to select multiple statuses, hold down the CTRL key as you make your selections. If you wish to select all statuses, choose the "All" option.
</td></tr>

<tr><td valign="top"><img src="../images/3.gif"></td><td> 
<em>Program Types:  </em>You can create a report that only displays programs of a certain program type.  If you wish to select multiple program types, hold down the CTRL key as you make your selections. If you wish to select all program types, choose the "All" option.
</td></tr>

<tr><td valign="top"><img src="../images/4.gif"></td><td> 
<em>Geographic Filter:</em> You can select one geographic filter.  You must select whether this filter is by zone, by region or by broker.  If make a selection in zone, you cannot select by region or broker, and programs which have no zone will not appear in the results.  If you choose to filter by geography or customer, you cannot select column headings (#8).
</td></tr>

<tr><td valign="top"><img src="../images/5.gif"></td><td> 
<em>Customer Filter:</em> You can select one customer filter.  You must select whether this filter is by family, buying group or <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>.  If make a selection in buying group, you cannot select a filter by family or <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, and programs which have no buying group will not appear in the results.  
</td></tr>

<tr><td valign="top"><img src="../images/6.gif"></td><td> 
<em>Report type:</em> You can choose to have this report generate an html page, an Excel document or a CSV (comma delimited file).  If you choose HTML, a window will appear with the information. If you select Excel or CSV, you will be asked whether you would like the save the file or view it.  Answer according to your preference.
</td></tr>

<tr><td valign="top"><img src="../images/7.gif"></td><td> 
<em>Group by:</em> Results of your survey can be grouped either primarily by Status and secondarily by Program Type, primarily by Program Type and secondarily by Status, only by one or the other, or by neither.
</td></tr>

<tr><td valign="top"><img src="../images/8.gif"></td><td> 
<em>Select Column Headers:</em> If you are not filtering by customer or by geography, you may select column headers by projected volume, projected expense or projected margin.  That information will appear when you generate the report.  
</td></tr>

<tr><td valign="top"><img src="../images/9.gif"></td><td> 
<em>Save As Report Schedule:</em> If you would like to save the report, <A href="savereport.cfm">click here</A>.  
</td></tr>

<tr><td valign="top"><img src="../images/10.gif"></td><td> 
<em>Show Report:</em> Once you are finished crafting your report, click here to view it.  Showing the report does not save it or schedule it.  <a href="report.cfm">Click here</a> to see information on the results returned.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="reports_toc.cfm">
<cfinclude template="reports_updated.cfm">
</body>
</html>

