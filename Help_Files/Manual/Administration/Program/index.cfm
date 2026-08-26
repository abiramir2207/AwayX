<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Programs </title>
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
<cfinclude template="programs_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Programs -- Main Page</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><Td colspan="2">
The program wizard allows you to create program templates for users. These templates govern the options available to the user creating the template.</TD></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/pw_mainpage.gif"></td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>
<strong>Generic Type:</strong> The generic type is the larger family that the program template belongs to.  The five generic types have unique aspects.
<ul>
<li>Distributor Off-Invoice: Distributor Off-Invoice programs allow you to change the invoice price a <cfoutput>#application.returned_customer_setting.distributor_label_singular# or #application.returned_customer_setting.distributor_label_plural#</cfoutput> will pay for an item. There are fewer available options in this program type, since there is no payment, and <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> must be selected. When creating a Distributor Off-Invoice program there are no different discount types - only the ability to increase and decrease the prices on items.</li>
<li>Distributor <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter: When creating a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter program the only difference you will notice is that <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> are not available (they are required for the program type). Distributor <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter programs are dealt with in a specific way when calculating billbacks.</li>
<li>Field Execution: Field Execution programs are those that are neither <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> nor <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> specific. </li>
<li>Operator Direct or HQ Programs: Operator Direct or HQ Programs have all options available. </li>
<li>Operator-Deviated Pricing: All options are available for Operator Deviated pricing. </li>
</ul>
</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td>
<strong>Create New:</strong> New program templates are created when you click on the [create new] link next to the generic type name. 
</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td>
Once a program is created you have four options.
<ul>
<li>Activate: A template will not be available to users until you activate it. A template that is not activated with have a gray background, and will display the [activate] link. When you click on the activate link and activate the program template, it will become available to users.</li>
<li>View: You can view the summary of all the program as it is now by clicking on the [view] link.</li>
<li>Edit: If you would like to change something about the program type, click on the [edit] link. Changing information on a template will only affect new programs created with the template. Old programs created with the template before it was changed will continue to have the options available at the time it was created. You can renew or revise old templates and they will retain the settings of the program type as of the time the program was created.</li>
<li>Delete: If you no longer want users to be able to create programs with the template, click on the [delete] link. Any programs already created with that template will continue to exists, and can be updated or revised.</li>
</ul>
</td></tr>
</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="programs_toc.cfm">
<CFINCLUDE TEMPLATE="programs_updated.cfm">
</body>
</html>
