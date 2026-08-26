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
<tr><th colspan="2"><strong>Create a New Program -- Growth</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<a name="ac">
<table>

<tr><th colspan="2"><em>Add Component</em></th></tr>

<tr><td colspan="2" align="Center"><img src="../images/cp_growth_component.gif"></td></tr>
	<tr><td colspan="2">The first step of creating a growth component is to establish the basic information for the component.</td></tr>
	<tr><td valign="top"> <img src="../images/1.gif"></td><td>Enter the name of the growth component.
	</td></tr>
	<tr><td valign="top"> <img src="../images/2.gif"></td><td>Enter a description for what the component is intended to do.
	</td></tr>
	<tr><td valign="top"> <img src="../images/3.gif"></td><td><em>Single Rate:</em> Describes a growth component where the rate for the highest tier the client has earned dictates the rate for all volume. For example, if you have a single rate component with two tiers - the first from 1 case to 200 cases offering a $.20 a case <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, and the second from 201 cases on up offering $.30 a case <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>. If the client buys 170 cases, they will all earn $.20 each. If the client buys 270 cases, each will earn $.30.
<p></p>
<em>Multi Rate:</em> In a multi rate component, the volume which falls in a particular tier earns the rate for that tier. With the same tier structure as above, in a multi rate program if a client buys 270 cases, 200 of them will earn $.20 a case and 70 of them will earn $.30.
	</td></tr>

	<tr><td valign="top"> <img src="../images/4.gif"></td><td><em>Component UOM:</em> This indicates what the range end and start for the tiers are. If you select pounds or cases, then the tiers will be actual cases or pounds purchased. If you select percent it indicates a percent of volume.  
	</td></tr>
	<tr><td valign="top"> <img src="../images/5.gif"></td><td><em>Volume Comparison Period:</em> You will only see this if you select % as your component UOM. This helps you select what period you are going to compare volumes to. For example, if you have a tier which runs from 100% to 105% you need to be able to find out how much volume the customer purchased for a certain amount of time. 
Same Period, Prior Year: If you select same period, prior year, then the amount of time is the span of the program you are currently creating, minus one year. So if the program runs from September 1, 2003 until September 30, 2003 then the comparison period would be from September 1, 2002 until September 30, 2002.
Days Before Program Start Date: This will create a comparison period immediately prior to the start date of the program. The length of that comparison period will be however many days you enter.  
	</td></tr>
	<tr><td valign="top"> <img src="../images/6.gif"></td><td><em>Tiers:</em> The number of tiers you want the component to have.
	</td></tr>
	<tr><td valign="top"> <img src="../images/7.gif"></td><td>Once you have entered the number of tiers you wish to have, this section will appear. You should enter the start and end values for each tier you want to create. Please note that the start of one tier (except for the first tier) should be one more than the end of the prior tier. So if Tier 1 goes from 1 - 100, Tier 2 needs to start at 101. If your component UOM is percent, please be aware that 1% would be 1% of the purchases the client made in the comparison period. If you want to create a tier that requires a customer to buy more of your product than they did in the comparison period, your tiers need to start at 100% or greater.  
	</td></tr>

	</table>

	<table>

<tr><th colspan="2"><em>Component Products</em></th></tr>

<tr><td colspan="2" align="Center"><img src="../images/cp_growth.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>You can apply the same rate to a tier for all products by selecting the tier, and entering the rate you want to apply. Then click on [apply rate].
	</td></tr>
	<tr><td valign="top"> <img src="../images/2.gif"></td><td>Initially, you will be forced to select products. Once you have made your selection, you can add additional products by clicking on the select products button. Be sure to save your work before exiting.
	</td></tr>
	<tr><td valign="top"> <img src="../images/3.gif"></td><td>You can change the unit of measure for all tiers of multiple products by checked the right hand box of the product, selecting the desired UOM, and clicking [apply].
	</td></tr>
	<tr><td valign="top"> <img src="../images/4.gif"></td><td>Each product will display basic information, and show the tiers. You can enter a different rate/uom for different tiers of the same product, if you wish. You can easily delete a product by clicking on the scissors in the upper left hand corner, and restore the product by clicking again.
	</td></tr>

</table>
	
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
