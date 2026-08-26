<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Product Right Click Options</title>
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

<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Product Right Click Options</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2">When you are looking at products (in the program scorecard, for example), you may notice a small question mark next to your mouse cursor.  This is an indication that more information is available using your right click.  If you click on the right mouse button at that point, you will see the following options:</td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="images/rightclickproduct.gif"></td></tr>

<tr><td colspan="2">Product Summary: Clicking on the product summary option will open a new screen with the following information:</td></tr>
<tr><td colspan="2" align="center"><img src="images/rc_productdetails.gif"></td></tr>
<tr><td colspan="2">Price List: Selecting price list option will also open a screen with information about the prices for the product you are hovering over as below:</td></tr>
<tr><td colspan="2" align="center"><img src="images/rc_pricelist.gif"></td></tr>
<tr><td colspan="2">Home: Clicking on the home option will take you to the home page of the application.</td></tr>
<tr><td colspan="2">Logoff: Clicking logoff will end your session and redirect you to the login page.</td></tr>

</table>
<p></p>
</div>




<HR COLOR="Orange">
 
<CFINCLUDE TEMPLATE="click_updated.cfm">
</body>
</html>
