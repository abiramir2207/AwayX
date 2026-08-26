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
<tr><th colspan="2"><strong>Create a New Program -- General Items</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2">At this point, there are a number of navigational elements that appear.  The first is a list of the pages available to help you set up your program.</td></tr>
<tr><td colspan="2" align="center"><img src="../images/cp_navigation.gif">
</td></tr>
<tr><td colspan="2">Possible navigation elements are: View Program, Basic Info, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, Broker, <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, Fixed Price, <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>, Growth and Formula.   The elements you will have access to are dependent upon the program type you selected.  If you do not see an option you need, select a different program type. You can view or edit information from any screen at any point.  Additionally, the contract number for the program you are editing is displayed at the top of every screen.
<p></p>
You will also see a lock image.

</td></tr>
<tr><td valign="top" colspan="2" align="center"> <img src="../images/cp_lock.gif">
</td></tr>
<tr><td valign="top" colspan="2"> The program is locked while you are editing it so that no one else can make edits at the same time.  If you choose to unlock the program, you can view the information you have entered, but you cannot change any of it.  In order to make changes, the program must be locked.
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
