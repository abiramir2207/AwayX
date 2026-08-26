<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Programs :: Billbacks :: Search</title>
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
<cfinclude template="search_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Billback Search</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/billback_search.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
These links allow you to view the Billback Scorecard, create a new Billback, or view communications sent to you in the inbox.   </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
There are a number of options presented to you in the billback search criteria area:
<ul>
<li><em>Hide Billback Search:</em> You can hide the criteria area in order to view more search results.</li>
<li><em>Title:</em> Search for the billback by Title.</li>  
<li><em>Payable #:</em> The Payable Number is generated for each billback. </li> 
<li><em>Billback #:</em> From the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> or <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>. </li> 
<li><em>Status:</em> Return only billbacks which are: Work in Progress, Request for Approval, Approved or Paid by selecting the appropriate value from the pulldown.</li>
<li><em>Billback Date, Start Date, End Date:</em> For every date you wish to search by, there are three components. Furthest on the left is a pull down with the characters >=, =, and <=.  These signify in order "Greater than or equal to", "Equal to" and "Less than or equal to".  You can qualify the date you are entering by selecting one of these. The next component of the search is the area where you enter the date.  Be sure to enter four digits for the year.  The third and final component brings up a calendar options when you click on it.</li>  
<li><em>Amount:</em>  You can find any billback with a billback amount greater than or equal to, equal to, or less than or equal to the amount you enter by selecting one of the options from the pulldown and entering the amount in question in the field.</li>
<li><em>Aging:</em> After a certain number of days (controlled by administrators) billbacks are marked as aging.  If you wish to search either for billbacks that are aging or are not aging, you can do so by selecting the appropriate value from this pulldown menu.</li>
<li><em><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name:</em> Enter the name of the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> from the billback here.</li>
<li><em>Broker Name:</em> Select the name of the broker from the billback.</li>
<li><em><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</em> Enter the name of the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> from the billback.</li>
<li><em>Program Status: </em>You can search billbacks that include a program of a certain status by making a selection from this list.  </li>
<li><em>Program Type:</em> You can search for billbacks that have a program of a certain type by selecting the type from this pulldown.</li>

<li><em>Reset Form:</em> Click this link will remove all values you have entering into the search.</li>
<li><em>Search Billbacks:</em> Submit your search by clicking on this link.</li>
</ul>
</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
You will be able to see search results below.  The options shown will be similar to or the same as those shown in the scorecard. Click here to read about the information displayed.  You can view details on a particular billback by clicking on the payable number (shown in blue). </td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
At the bottom of the search screen you can see at the left how many pages worth of results have been returned.  If there is more than one page, you can click on the page number to view that page.  On the right you can view the total number of billbacks returned.</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="search_toc.cfm">
<cfinclude template="search_updated.cfm">

</body>
</html>
