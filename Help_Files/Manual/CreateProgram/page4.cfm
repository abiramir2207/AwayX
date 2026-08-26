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
<tr><th colspan="2"><strong>Create a New Program -- <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_operator.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>The search function allows you to find an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> or <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> you wish to add to your program.  You can search for an operator by their name, the name they do business as, the city they operate in, the type of operation they run, the location type, and their state of business.  Clicking on "Search <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>" will return a list of <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> that you can review.  The more areas of information you provide, the fewer results will be returned.  For example, if you only select the State of Washington, 269 <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> are returned.  If you select a "Non-traditional <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>" as an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> type in addition to selecting the State of Washington, only 4 operators will match your criteria.
<p></p>
You MUST make a selection in the middle row. You must select at least one of Type of <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, Doing business as, or City.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>If the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> you would like to add to a program is not available through searching, you can add a new <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>.  Click on the [create <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>] link.  You will be asked to enter information about the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>.  When you are finished, click on "save data".  A confirmation screen will appear verifying the information you entered, and the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> will now be available to you when you search for them.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td><em>Currently Selected <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>: </em>When you first view this field, it will be say: "None" for the currently selected operators.  Once you have added and selected <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>, they will appear in this area.  In order to remove an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> you have selected, search for the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> or <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>, and uncheck the box next to the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> name.  Then click save.  The <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> will be removed.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>To select an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, check the box next to the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>'s name.  If you wish to select all <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> returned by a search, simply check the box in the left hand side of the orange header. To remove an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> you have previously selected, uncheck the box next to the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> name.  You can see additional pages of results (if more than one page is returned) by clicking on the red numbers at the bottom of the screen.  You can save your changes by clicking on the "Save" button.  Although you will be taken to the next screen, you can change your <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> selections by clicking on the "<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>" tab in the top navigation.
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
