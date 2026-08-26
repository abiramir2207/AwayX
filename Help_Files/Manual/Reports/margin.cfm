<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Reports :: Margin Analysis Report</title>
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
<tr><th colspan="2"><strong>Reports -- Margin Analysis Report</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/rep_margin.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>


<tr><td valign="top"><img src="../images/1.gif"></td><td> 
Select whether you would like your margin report to be based on the margins for a product, or for a program.
</td></tr>

<tr><td valign="top"><img src="../images/2.gif"></td><td> 
<em>Status:</em> You can create a report that only displays programs of a certain status.  If you wish to select multiple statuses, hold down the CTRL key as you make your selections. If you wish to select all statuses, choose the "All" option.
</td></tr>

<tr><td valign="top"><img src="../images/3.gif"></td><td> 
<em>Program Types:</em>  You can create a report that only displays programs of a certain program type.  If you wish to select multiple program types, hold down the CTRL key as you make your selections. If you wish to select all program types, choose the "All" option.
</td></tr>

<tr><td valign="top"><img src="../images/4.gif"></td><td> 
<em>Product Filter:</em> Results for the report can be filtered by one of the following: Q Brand, Type Group, Type Code or Brand.  You must select one to filter by.
</td></tr>

<tr><td valign="top"><img src="../images/5.gif"></td><td> 
<em>Customer Filter.</em>  Report results must be filtered by Family, Buying Group or <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>.
</td></tr>

<tr><td valign="top"><img src="../images/6.gif"></td><td> 
<em>Margin: </em> You may choose to return results for margins using different parameters:
<ul>
<li><em>All:</em> Shows you all margins</li>
<li><em>Between:</em> When you select between, you are given two parameters to enter - the low parameter and the high parameter. The report will return margins between those two parameters.</li>
<li><em>Greater Than or Equal To:</em> You can select all margins greater than or equal to an amount you enter.</li>
<li><em>Less Than or Equal To:</em> You can select all margins less than or equal to an amount you enter.</li>
</ul>
</td></tr>

<tr><td valign="top"><img src="../images/7.gif"></td><td> 
<em>Sort by:</em> For margin reports you can select the order the three pieces of information (Status, Program Type, and Margin) will be sorted by.
</td></tr>

<tr><td valign="top"><img src="../images/8.gif"></td><td> 
<em>Report Output Type:</em> You can choose to have this report generate an html page, an Excel document or a CSV (comma delimited file).
</td></tr>

<tr><td valign="top"><img src="../images/9.gif"></td><td> 
<em>Report Output Format:</em> Select what information you would like to be included in your report.  You can select Product and Margin Only, Cost Detail, and Full Trade Detail.
</td></tr>

<tr><td valign="top"><img src="../images/10.gif"></td><td> 
<em>Save As Report Schedule: </em>If you would like to save the report, click here.  Help information on report scheduling can be found <A href="saved.cfm">here</A>.
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
