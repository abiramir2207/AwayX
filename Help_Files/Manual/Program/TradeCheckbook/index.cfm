<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbook</title>
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
<cfinclude template="tradecheckbook_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong><CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbook</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook1.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">Begin by selecting either a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> or a program to view the checkbook for (<CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbooks are only available for Distributor <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter programs). </td></tr>

<cfoutput><Tr><td colspan="2" align="Center">
<HR COLOR="Navy" width="80%"></td></TR>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_distributor_searc.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2"> If you choose to search for a #application.returned_customer_setting.distributor_label_singular# first, you will view the distributor search screen.   </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
You can choose to sort your returns by the criteria listed, either ascending or descending.  The more criteria you select, the fewer results will be returned.  The sort by and order are not search criteria.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Once you have selected your criteria, click on [ search #application.returned_customer_setting.distributor_label_plural# ] to execute your search and view results.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
If you have already selected a #application.returned_customer_setting.distributor_label_singular#, it will be displayed here.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
A list of returned #application.returned_customer_setting.distributor_label_plural# will be displayed. You can sort the list by clicking on the blue link headings.  If you are sorting by a particular piece of information, a blue arrow will appear showing whether you are sorting ascending or descending.  Clicking again on the heading will change the sort order.  To select a #application.returned_customer_setting.distributor_label_singular#, click on the circle next to the #application.returned_customer_setting.distributor_label_singular#'s name. You can only select one #application.returned_customer_setting.distributor_label_singular#.</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
If you have more than one page of results returned, you can view the other pages by clicking on the numbers.  </td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
When you have finished making your selection, click on [ import selected #application.returned_customer_setting.distributor_label_singular# ].  </td></tr>

<Tr><td colspan="2" align="Center">
<HR COLOR="Navy" width="80%"></td></TR>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_program_list.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">
Once you have selected a #application.returned_customer_setting.distributor_label_singular#, you will be shown a list of all active or expiring programs.  If you would like to pick an expired program, click on the [Show Expired ] link at the bottom of the page.  Once you make a selection, you will be automatically directed to the checkbook screen.
</td></tr>

<Tr><td colspan="2" align="Center">
<HR COLOR="Navy" width="80%"></td></TR>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_program_search.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
You can search for programs by numerous criteria. Refer to the search program help section.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Once you have selected your criteria, click on the [search programs] link.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
A list of matching programs will be displayed.  You can sort the programs by Number, Title, Start Date or End Date.  The currently selected sort mechanism will have an arrow next to it. Clicking on the link again will switch whether the results are ascending or descending.  Select only one program from the list.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
When you have made your selection, click on [import selected program].</td></tr>

<Tr><td colspan="2" align="Center">
<HR COLOR="Navy" width="80%"></td></TR>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/checkbook_distribuor_list.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">
Once you have selected a program, you will be shown a list of #application.returned_customer_setting.distributor_label_plural# on the program. The list may be sorted by clicking on the blue headers (the addresses are sorted by state). Clicking on each row will pull up additional details about the #application.returned_customer_setting.distributor_label_singular#. Once you click on a radial button, you will automatically be directed to the checkbook.</td></tr></cfoutput>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="tradecheckbook_toc.cfm">
<cfinclude template="tradecheckbook_updated.cfm">

</body>
</html>
