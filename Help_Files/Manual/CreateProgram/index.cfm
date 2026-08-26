





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
<tr><th colspan="2"><strong>Create a New Program -- Select a Program</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/home.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>The first step in creating a new program is selecting which template you wish to model your program around.  The templates will outline which options and screens you will have access to for the program, and other basic information about the program.  Administrators can create new templates by going to the Program Wizard in the Settings Control Panel.
<p></p>
Templates are separated into different types, which may be treated differently. Off Invoice type program templates, for example, only have the "Off-Invoice" discount option, and are not available from billback functionality. Distributor <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter programs create exclusions, etc. Contact your system administrator for which program type you should use to create your programs.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>To create a program using a particular template, click on the name or description for the template.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>If you want to view details about the program before actually creating it, you may click on the [details] link, without creating a program.
</td></tr>
<tr><td valign="top" colspan="2">
Not all the pages and shown in this documentation will be available to you, depending on which template you have chosen, and what options administrators have made available through templates. 
<p></p>
Administrators can set values for the following:
<p></p> 
<strong>Basic Information:</strong>
<ul>

<li>Duration (minimum and maximum)</li>
<li>Volume (minimum and maximum)</li>
<li>Permitting retroactive programs</li>
<li>Permitting advanced spending</li>
</ul>
Administrators can choose to include or not include the following:
<p></p>
<strong>Basic Information:</strong>
<ul>
<li><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></li>
<li><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></li>
<li>Brokers</li>
</ul>
<strong>Rate Types available:</strong>
<ul>
<li>Per Pound</li>
<li>Per Case</li>
</ul>
<strong>Discount Types available:</strong>
<ul>
<li>Fixed Price</li>
<li><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s</li>
<li><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s</li>
<li>Growth</li>
<li>Formula Pricing</li>
</ul>
<strong>Claim Mechanics:</strong>
<ul>
<li>Billback Request</li>
<li>Auto payment</li>
<li>Auto credit</li>
</ul>
<strong>Payment Cycle:</strong>
<ul>
<li>Daily</li>
<li>Weekly</li>
<li>Monthly</li>
<li>Quarterly</li>
<li>Semi-Annual</li>
<li>Annual</li>
</ul>
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
