<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Approval</title>
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
<cfinclude template="scorecard_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Scorecard -- Details</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/billback_scorecard.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>
<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
You can view the scorecard for each status by clicking on the tab at the top of the screen. Information displayed varies slightly from one status type to another.</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
From the scorecard screen there are links to other billback functions. Clicking on [search billack] will bring you to the billback search screen. [create new] will open a new billback, and [inbox] will bring you to your billback message screen.</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
You can sort the returned billbacks by a number of criteria, highlighted in blue at the top of the screen. Click on the title to sort the billbacks by that criteria. Click on it a second time to reverse the order of the sorting. An arrow will appear next to the criteria used to sort the list showing what order the billbacks will be sorted if you click the link again.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
Each line shows information on a billback. 
<p></p>
<ul>
<li><em>Colored dot: </em>The colored dot the far side of the screen indicates the status of the billback.  Gray indicates a Work in Progress billback, yellow outlined with green is Request for Approval, green is approved, and black is paid.  </li>
<li><em>Lock icon:</em> If another user is currently modifying a billback, the lock will appear next to the status marker. Keeping your mouse over the lock icon will show the name of the person locking the billback.</li>
<li><em>UP:</em> UP stands for unknown payee. A program that has a payee who is an unknown <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, unknown <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, unknown broker, or completely unknown is marked as UP.  A green check in the scorecard indicates that the payee is known. A red x shows that the payee is not known, and the billback is critically deviated.</li>
<li><em>PNF:</em> PNF stands for Program Not Found. A billback with a program not in the system is critically deviated. Even if only one program out of many in the billback is not found, the entire billback will be marked as PNF. A green check shows that a billback is NOT PNF, while a red x indicates that the program is not found.</li>
<li><em>Payable #:</em> This is the number the system assigns to each billback. Clicking on this number will bring you to a page showing a summary of the billback.</li>
<li><em>Date:</em> The date entered as the billback date. If the billback is in danger of being deducted (the number of days since the billback date required to be "in danger" is a setting created by administrators), the billback will be highlighted in red.</li>
<li><em>Billback #:</em> From the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> or <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></li>.
<li><em>Title/Payee:</em> The name of the organization and title for the billback are displayed at the top and bottom lines.</li>
<li><em>Start/End:</em> The start and end date of the period the billback is claiming payment for.</li>
<li><em>$ Claimed:</em> The amount claimed for the billback is shown here.</li>
</ul>
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
The number of pages in the scorecard for the billback status are shown on the left. Clicking on a number will bring you to that page. The total number of billbacks for the status is displayed on the right.</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="scorecard_toc.cfm">
<cfinclude template="scorecard_updated.cfm">

</body>
</html>
