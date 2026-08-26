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
<tr><th colspan="2"><strong>Program Wizard -- Details</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/pw_details.gif"></td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>
The program template name and type is displayed at the top.
</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td>
<strong>Rate Types:</strong> Select whether programs created with this template can include per pound, per case and percent. If you include a rate type, you can also set it as default (automatically selected when a program is created. PLEASE NOTE: You must select either Per Pound or Per Case. Rate types are the only ones available if you are creating a Distributor Off-Invoice program template.
</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td>
<strong>Claim Mechanics:</strong> Select the options available to users creating programs with the template. You must select at least one.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td>
<strong>Payment Frequency:</strong> The selections you make here will appear as options to users creating program using this program template. You must select at least one.
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td>
<strong>Discount Types:</strong> If you check on a box, users creating programs with this program type will be able to see the tab for that option. Otherwise, it will not be available. You must select at least one discount type.
</td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td>
<strong>Claim/Performance Requirement:</strong> Select options for what the entity billing back must show in order to receive payment. You do not need to make any selections from this list.
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
