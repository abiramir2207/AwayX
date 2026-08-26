<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: Claim/Performance Requirements </title>
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
<tr><th colspan="2"><strong>Programs -- Claim/Performance Requirements</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_prog_performance.gif"></td></tr>

<tr><td colspan="2">
The claim/performance requirements above represent a set of options available to the program type.  The claim/performance requirement options as of this writing are: Invoice/Billback, Claim Period, Item #s w/Quantity and Rates, Total Dollars and Pounds, Menu Listing, Branded Point of Sale, Mandated Specification, Optional Specification.  By selecting the "Include" box next to each claim/performance requirement, you are making it available to the program type you are creating.  You must select at least one requirement type.
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
