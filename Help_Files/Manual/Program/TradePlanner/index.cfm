<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: <CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel# </CFOUTPUT></title>
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
<cfinclude template="tradeplanner_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong><CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#</CFOUTPUT></strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
 <tr><td valign="top" colspan="2" align="center"><img src="../../images/trade_planner_create.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td colspan="2">The <CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#</CFOUTPUT> helps users plan trade programs for distributors. </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
These links help the user navigate through trade plan creation. Click on [create] to create a new plan or [list] to view existing trade plans.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
Report Title: The name of the report you are creating.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
Distributor: Click on [get distributor] to search for a distributor.  You can only select one distributor.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
Products: You can search for and select multiple products by clicking on the [get products] link.</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
Notes: Enter notes on the report you are creating here. </td></tr>

<tr><td colspan="2"><hr width="85%" color="navy"></td></tr>
<tr><td colspan="2"><div align="center"><strong>List Plans:</strong>
<p></p>
<img src="../../images/trade_planner_list.gif">
</div>
You can see a list of all trade plans by clicking on a [list] link.
</td></tr>
<tr><td valign="top"><img src="../../images/1.gif"></td>
<td>Clicking on [display] will show you details of the plan, as above. (Amounts cannot be edited unless the user clicks [edit] on the details page.)</td>
</tr>
<tr><td valign="top"><img src="../../images/2.gif"></td>
<td>Trade Plan Title: The title of the trade plan.</td>
</tr>
<tr><td valign="top"><img src="../../images/3.gif"></td>
<td>Date Created: The date the plan was created</td>
</tr>
<tr><td valign="top"><img src="../../images/4.gif"></td>
<td>Created By: The person who initially created the plan.</td>
</tr>
<tr><td valign="top"><img src="../../images/5.gif"></td>
<td>Date Last Updated: The last time the plan was updated.</td>
</tr>
<tr><td valign="top"><img src="../../images/6.gif"></td>
<td>Updated By: The last person who updated a plan.</td>
</tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="tradeplanner_toc.cfm">
<cfinclude template="tradeplanner_updated.cfm">

</body>
</html>
