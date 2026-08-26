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
<tr><th colspan="2"><strong>Create a New Program -- <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT></strong></th></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_lumpsum.gif"></td></tr>
<tr><td valign="top" colspan="2"> 
	<CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> discounts allow you to set aside money in a bulk format.
</td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td>Enter the name of the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> component you are creating. Programs may have more than one <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> component.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>The dollar amount of the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>Volume is used to help calculate the margin for various products. Enter the total volume for all products whose margins should be adjusted to take this <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> component into consideration.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>You may enter a longer description of the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> component here.
</td></tr>
<tr><td valign="top"> <img src="../images/5.gif"></td><td>Other <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> components for the program are displayed below. You can see the information entered to the left.
</td></tr>
<tr><td valign="top"> <img src="../images/6.gif"></td><td>You should add the products whose volume you are reflecting in #3. You can see which products have been added by clicking on [view products]. If you wish to change the component information, click on [edit component]. The information will appear in the area at the top. Click on the scissors to remove a component. Click again to restore it.
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
