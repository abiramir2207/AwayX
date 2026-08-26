<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Basics </title>
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
<tr><th colspan="2"><strong>Program Wizard -- Basics</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/pw_basicinfo.gif"></td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td>
The program type is showed in the header.
</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td>
Enter the name and description of the program template you are creating. The description should describe under what circumstances a user should use the template. 
</td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td>
<strong>Include Trade:</strong> Select whether the program should include or exclude trade. If the program excludes trade, then the volume for the program will be excluded from trade programs. So if a program excludes trade and 500 pounds of Item 1 are billed back for that program, and then a different billback from the same <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> for a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT>/Shelter program makes a claim on 1000 pounds of Item 1, 500 pounds will not be allowed - they will be excluded from the trade program.
</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td>
<strong>Duration:</strong> You can select a maximum and/or minimum durations for the programs. If you check the box, you must enter a number of days for the value.
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td>
<strong>Total Volume:</strong> Enter the minimum or maximum total volumes allowed for the program template.
</td></tr>
<tr><td valign="top"><img src="../../images/6.gif"></td><td>
<strong>Retroactive Programs:</strong> Check if you want to allow programs that start before the day they are created. You control how far in the past programs can be started by entering a number of days. If you select retroactivity, you must enter a value for the retroactive period.
</td></tr>
<tr><td valign="top"><img src="../../images/7.gif"></td><td>
<strong>Controllable Volume:</strong> Select this if the volume for the program is controllable.
</td></tr>
<tr><td valign="top"><img src="../../images/8.gif"></td><td>
<strong>Require… : </strong>If you wish to include a tab for <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> and brokers, you need to check the appropriate box. If you do not check any of them, a user creating a program of this type will not be able to assign the program to a broker, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> or <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>.
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
