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
<tr><th colspan="2"><strong>Create a New Program -- Formula</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_fixed_formula.gif"></td></tr>
<tr><td valign="top" align="center"> <img src="../images/1.gif"></td><td><em>Program Status on Release:</em>  Select whether the program you are creating will be ready to go through the approval process (Read for Approval) or whether it will bypass the approval process and automatically become Pre-Active.  The program will then become active on its start date.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td><em>Pricing Periods:</em> When you arrive at the formula page you will first need to create pricing periods.  You can do so by clicking on the [Click here to establish new pricing periods].  The following window will open.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>Pricing Rules: Pricing rules establish the commodities and overages involved. You can select from a list of pre-established pricing rules. If you do not see the rule you need, contact an administrator. 
</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_fixed_period.gif"></td></tr>
<tr><td valign="top" colspan="2"> Enter the number of periods you will be establishing in the formula. Click on continue.
</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_fixed_period2.gif">
</td></tr><tr><td colspan="2">
This screen asks you to define information about the pricing periods.</p>
</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>Please define the first day of the first period:  Enter the day your first period would begin.  A logical choice would be the first day of your program.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>Select the duration of each period.  The dates the periods run from start at the first day you entered, and then are incremented by the number of days you enter in duration.  The last day of the last period needs to be the last day of the program.  You will receive an error message and not be able to save your periods unless that is true.  You may also select the date at which commodity prices will be sampled to set the prices for the period in the Release Date field.
<p></p>
You may either enter the release date in the field, or click on the calendar icon to the right.  If you click on the calendar icon, you can select the month and year of the release date.  The window will close when you click on the date. The red arrows to the right of the calendar icon can be used to increment or decrement the date of the release by one day.
<p></p>
You can delete a pricing period by clicking on the scissor icon.
</td></tr>


<tr><th colspan="2"><strong><A name="pr">&nbsp;</A><br>Pricing Rules</strong></th></tr>
<tr><td valign="top" colspan="2"> Once you have established the pricing periods, you can set the pricing rules by clicking on the [Click here to add rule] link.  
</td></tr>


<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_fixed_period3.gif">
</td></tr><tr><td colspan="2">
Administrators establish pricing rules. If you do not find the pricing rule you need, contact an administrator to create one.</p>
</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>You can search for pricing rules by a number of criteria, including exchange type, exchange, rule name, number of commodities, and the commodity involved. The more criteria you select, the fewer results will be returned. 
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>A list of matching pricing rules will be returned. You can view details on a pricing rule by clicking anywhere on the rule name, and a window will appear with details. Make your selection, and click on [add rule] to continue.
</td></tr>

<tr><td colspan="2"><hr></td></tr>


<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_fixed_period4.gif">
</td></tr><tr><td colspan="2">
Click on select products and go through the product selection process as outlined in the beginning of the chapter.
</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>You can apply the same overage to multiple products by clicking on the check box for the products, entering your desired overage, and clicking on [apply overage]. You may still manually update the overage amounts if you want.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>At any time you can select additional products by clicking on the "select products" button. When you have completed setting overages, click on "continue"
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td><em>Rate Type: </em> Select whether this pricing rule is for Delivered or FOB orders.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td><em>Global UOM:</em> To apply one unit of measure to multiple products overages, make a selection here, click on the boxes of the products in question, and click on [apply].
</td></tr>
<tr><td valign="top"> <img src="../images/5.gif"></td><td>You can see basic information about each product (right clicking will also show you price list and product information). You can manually enter an overage amount and select a uom. To remove a product, click on the scissors to the right. Clicking again will restore the product.
</td></tr>

<tr><td colspan="2"><hr></td></tr>


<tr><td valign="top" colspan="2" align="center"><a name="products"><img src="../images/cp_fixed_formula.gif"></td></tr><tr><td colspan="2">
Once you have selected pricing periods and pricing rules, you are brought to a page that summarizes your choices. At this point, however, you can consider the formula pricing done, and continue on if you desire.
</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>If you would like to create new pricing periods, or edit the current ones, you can click on the appropriate links..
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>Information is displayed for the pricing periods you entered.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>You may add an additional new pricing rule by clicking on [Click here to add a rule]. If you would prefer to edit the rule you already created, click on [edit]. You can delete the rule by clicking on [delete].
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
