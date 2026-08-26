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
<cfoutput><table align="center" width="90%">
<tr><th colspan="2"><strong>Create a New Program -- #application.returned_customer_setting.distributor_label_singular# Weights</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/distributor1.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>If you wish to assign a particular weight to all #application.returned_customer_setting.distributor_label_plural#, enter the percent in the box, and click on [click here to apply entered weight]. You can then still manually change the weighting.
<p></p>
Otherwise, you can select the calculated weight, which is an equal distribution among all the #application.returned_customer_setting.distributor_label_plural#. (For example, if you have 4 #application.returned_customer_setting.distributor_label_plural# the calculated weight would be 25% for each. If you had three, the calculated weight would be 33.33% -- you would need to make one of the #application.returned_customer_setting.distributor_label_plural# 33.34% in order to have all the #application.returned_customer_setting.distributor_label_plural# equal 100%")
<p></p>
You can apply a weight only to some #application.returned_customer_setting.distributor_label_plural# by un-selecting their check-boxes on the right.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>Each line shows the #application.returned_customer_setting.distributor_label_singular#'s name, number, address, broker, family name and buying group. You can easily delete a #application.returned_customer_setting.distributor_label_singular# by clicking on the scissors to the left. You can bring back a #application.returned_customer_setting.distributor_label_singular# by clicking on the left icon again. You can manually adjust the weight for a #application.returned_customer_setting.distributor_label_singular# simply by changing the amount in the "weight" box.
</td></tr>
<tr><td valign="top">NOTE:</td><td>All #lcase(application.returned_customer_setting.distributor_label_singular)# weights added together must equal 100%.  If you assign weights that do not equal 100% you will receive an error message when you try to save.
</td></tr>
</table></cfoutput>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
