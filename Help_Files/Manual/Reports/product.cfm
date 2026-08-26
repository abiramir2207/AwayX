<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Reports :: Product Summary Report</title>
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
<tr><th colspan="2"><strong>Reports -- Product Summary Report</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/rep_product.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>


<tr><td valign="top"><img src="../images/1.gif"></td><td> 
<em>Status:</em> You can create a report that only displays programs of a certain status.  If you wish to select multiple statuses, hold down the CTRL key as you make your selections. If you wish to select all statuses, choose the "All" option.
</td></tr>

<tr><td valign="top"><img src="../images/2.gif"></td><td> 
<em>Program Types:</em>  You can create a report that only displays programs of a certain program type.  If you wish to select multiple program types, hold down the CTRL key as you make your selections. If you wish to select all program types, choose the "All" option.
</td></tr>

<tr><td valign="top"><img src="../images/3.gif"></td><td> 
<em>Product Filter:</em> Results for the report can be filtered by one of the following: Q Brand, Type Group, Type Code or Brand.  You can also choose not to filter by any of these by selecting None.  You cannot select a column heading (#6) unless you have chosen a product filter.
</td></tr>

<tr><td valign="top"><img src="../images/4.gif"></td><td> 
<em>Report type:</em> You can choose to have this report generate an html page, an Excel document or a CSV (comma delimited file).
</td></tr>

<tr><td valign="top"><img src="../images/5.gif"></td><td> 
<em>Group By:</em> Select whether you would like the report grouped by Status, then Program Type, by Program Type then Status, or by only one of the options.
</td></tr>

<tr><td valign="top"><img src="../images/6.gif"></td><td> 
<em>Select Column Headers:</em> If you are not filtering by customer or by geography, you may select column headers by projected volume, projected expense or projected margin.  That information will appear when you generate the report.
</td></tr>

<tr><td valign="top"><img src="../images/7.gif"></td><td> 
<em>Save As Report Schedule:</em> If you would like to save the report, <A href="savereport.cfm">click here</A>.  
</td></tr>

<tr><td valign="top"><img src="../images/8.gif"></td><td> 
<em>Show Report:</em> Once you are finished crafting your report, click here to view it.  Showing the report does not save it or schedule it.  <A href="report.cfm">Click here</A> to see information on the results returned.
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
