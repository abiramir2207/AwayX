<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Administration :: User Administration </title>
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
<tr><th colspan="2"><strong>User Administration -- Positions</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../../images/ad_user_position.gif"></td></tr>

<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
You can expand or contract zones by clicking on the - or + signs.  If you click on the - sign the menu will collapse. If you click on the + sign, the menu will expand.
</td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"></td><td>
You cannot edit position labels unless you are the system administrator.  If you are the system administrator, you will see a menu option allowing you to edit this information.
<p></p>
If you are an administrator and click on the [edit position label] link you will see the following screen:
</td></tr>
<tr><td colspan="2" align="Center"><img src="../../images/ad_user_positionlabel.gif"></td></tr>
<tr><td colspan="2"> You can change the position label in the box.  Then click save.
</td></tr>

</table>
<p></p>
</div>

<HR COLOR="Orange">

<CFINCLUDE TEMPLATE="positions_updated.cfm">
</body>
</html>
