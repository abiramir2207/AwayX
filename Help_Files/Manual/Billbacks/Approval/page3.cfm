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
<cfinclude template="approval_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Approval -- Adjustments and Exclusions</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

 <tr><td valign="top" colspan="2" align="center"><img src="../../images/bb_approval_payment.gif"></td></tr>
<tr><td colspan="2">&nbsp; </td></tr>

<tr><td valign="top"><img src="../../images/1.gif"></td><td valign="top">
You will always see the amount you have selected to pay.  If the selected amount is greater than the expected amount, an adjustment will be created. You will see the expected amount and the amount of adjustment that will be created if you choose to approve this billback. </td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td><td valign="top">
For both adjustments and exclusions, you have three choices. 
<ul>
<li><em>Ignore:</em> If you do nothing, the "ignore" option will be selected. In this case, the adjustment or exclusion will be available to subsequent billbacks to apply.  This is the default option.  </li>
	<li><em>Apply:</em> Choosing apply will apply the adjustment or exclusion to the billback you are currently paying. </li> 
<li><em>Remove:</em> Clicking remove will remove the exclusion or adjustment from the list for the payee without paying for it.</li> </ul></td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td valign="top">
<em>Adjustments:</em> Adjustments are created when a billback is approved with a amount greater than the expected amount. The adjustment is the difference between the expected amount and approved amount.</td></tr>
<tr><td valign="top"><img src="../../images/4.gif"></td><td valign="top">
<em>Exclusions:</em> Exclusions are created by operator deviated programs that exclude trade. If a billback is for one of those programs, product volumes approved will be multiplied by the item's eligible trade rates for that <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>. 
<p></p>
You can view details on exclusions by clicking on the [details] link.
<p>
<img src="../../images/bb_approval_exclusions_deta.gif"></p>
<p>
1)	Information on the program, billback and payee that created the exclusion is shown at the top.<br>
2)	The item information, rate, volume, and total dollar amount of exclusion are displayed.
<br>
3)	Clicking on the [show] link will display information on previous programs and revisions of programs that help calculate the exclusion

</p>
</td></tr>
<tr><td valign="top"><img src="../../images/5.gif"></td><td valign="top">
Exclusions have two separate levels. You can choose to apply or hide all exclusions for a billback by clicking on the top, white section.  If you wish to apply or hide only one of the programs in a billback, click on the appropriate choice in the gray tab. </td></tr>

<tr><td valign="top"><img src="../../images/6.gif"></td><td valign="top">
As you make selections, the running tally of the amount to be paid to the payee appears at the bottom of the screen. </td></tr>
<tr><td valign="top"><img src="../../images/7.gif"></td><td valign="top">
When you are satisfied with your choices, click [Approve This Billback] to see a summary of your choices and begin the payment process.  Once you click this button, the billback will be marked as approved. If you would like to select a different amount to pay for the billback, click on the [Select Different Payment Amounts] link to be taken back to the Approval Summary Screen. </td></tr>

</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="approval_toc.cfm">
<cfinclude template="approval_updated.cfm">

</body>
</html>
