<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Billbacks :: Entering Billback Information :: Payee</title>
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
<cfinclude template="capture_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Billback Information -- Request Approval</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td colspan="2">&nbsp; </td></tr>
<tr><td colspan="2">Once you have entered the billback information, you can mark the billback as "Ready for Approval" by clicking the link at the top right hand corner of the summary screen.
<br>
<img src="../../images/bb_readyforapproval.gif">
<br>
When you check the box, a window will appear asking for confirmation. Press the "OK" button to confirm that the billback is ready for approval.
<p></p>
 If you have permission to approve billbacks, you can do so either by clicking on the "Deviations" link in the left menu, or by clicking on the "Begin Approval Process" tab in the upper right hand corner of the Summary screen.
<br>
<img src="../../images/bb_approvebillback.gif">
<br>
The billback will not actually be listed as approved until you complete the process of checking for deviations and approving payment amounts.
</td></tr>

</table>
<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="capture_toc.cfm">
<cfinclude template="capture_updated.cfm">

</body>
</html>
