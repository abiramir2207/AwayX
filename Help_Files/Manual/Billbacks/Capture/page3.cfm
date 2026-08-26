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
<table align="center" width="90%" border="0">
<tr><th colspan="2"><strong>Billback Information -- Programs, Items and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td colspan="2">Once you have created a billback and assigned a payee to it, you need to include details about which programs and items the billback includes.
<p></p>
You can add a program one of three ways:
</td></tr>
<tr><td valign="top"><img src="../../images/1.gif"></td><td>
Add a program that includes the payee you have selected <br>
<img src="../../images/bb_add_program_wpayee.gif" width="139" height="34" alt="" border="0">
</td></tr>
<tr><td valign="top"><img src="../../images/2.gif"></td>
<td>
Add a program that does not include the payee, but, that already exists in the application

<img src="../../images/bb_add_program_nopayee.gif" width="91" height="36" alt="" border="0">
<p></p>
Clicking on either of these options will bring up the program search screen.  If you choose "Add Program with Payee" it will automatically return search results for payee you have selected.  If you have entered an unknown payee, no results will be returned.  You can only add programs that are Pre-Active, Approved, Expiring, or Expired.
<p></p></td></tr>
<tr><td valign="top"><img src="../../images/3.gif"></td><td>You can also choose an unknown program:<br>
<img src="../../images/bb_add_program_unknown.gif" width="139" height="37" alt="" border="0">
<p></p>

Choosing this option will display the following:<br>
<img src="../../images/bb_add_program_unknownprogr.gif" width="409" height="193" alt="" border="0">
<blockquote>
<em>Program Number:</em> Enter the program number for the unknown program (required).<br>
<em>Program Title:</em> Enter the title for the program (required).<br>
<em>Notes:</em>  You must enter some notes about the program.<br>
<br>
PLEASE NOTE: If you have an unknown program, it will be marked as 100% deviated.  It will also make the entire billback critically deviated - a higher level of permission is required to approve a critically deviated billback. 
</blockquote>
</td></tr>
<tr><td colspan="2">
Once you have selected a program or programs, you will be able to add products and <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> components. 
<p></p>
 <div align="center"><img src="../../images/bb_add_rebates.gif" width="540" height="404" alt="" border="0"></div>
<p></p>
You may have multiple programs displayed on each page.  Each program can have a variety of components.
</td></tr>
<tr><td valign="top"> <img src="../../images/1.gif"> </td>
<td>Information about the program appears here.  Colored dots indicate the status of the program. You are also shown the program number, title, span dates, and total volume.
</td></tr>
<tr><td valign="top"> <img src="../../images/2.gif"> </td>
<td>You will see this "Payee Program" only if the payee you have selected belongs in the program you have selected.
</td></tr>
<tr><td valign="top"> <img src="../../images/3.gif"> </td>
<td>These four icons allow you to do four different things:
<p></p>
<table width="100%" cellpadding="0" cellspacing="3" border="0"><tr><td valign="top"><img src="../../../../Images/on_the_program_item.jpg" width="19" height="19" alt="" border="0"></td><td> This will bring you to a list of all the items that belong to this program.  You can select as many items as you like from this list.  You can choose to import only selected items, import all returned items, or to remove checked items from the list.</td></tr>
<tr><td valign="top"><img src="../../../../Images/not_on_the_program_item.jpg" width="16" height="16" alt="" border="0"></td><td> Clicking on the magnifying glass icon will open the full product search screen.</td></tr>
  <tr><td valign="top"><img src="../../../../Images/unknown_item.jpg" width="19" height="16" alt="" border="0"></td><td>  If the item you wish to add to the program cannot be found using the program search, you can create an unknown product.  Clicking on this will open the following screen:</td></tr>
	<tr><td colspan="2">
<img src="../../images/bb_add_item_unknown.gif" width="405" height="237" alt="" border="0">
<p></p>
You must enter an item number, a brief item description, and some notes regarding the item.
	</td></tr>
	<tr><td><img src="../../../../Images/no_small.jpg" width="48" height="48" alt="" border="0"></td><td>Clicking on this icon will remove the program from the billback, including all items and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s associated with the program.</td></tr>
</table>
</td></tr>

<tr><td valign="top"> <img src="../../images/4.gif"> </td>
<td>For every item you have selected, information will be displayed.  You need to enter the volume and unit of measure the billback claims for the item. 
</td></tr>
<tr><td valign="top"> <img src="../../images/5.gif"> </td>
<td>Enter the total dollar amount claimed for each item.  If a discount type is shown as red, then the item does not have that discount type in the program you are working on.  If it is green, the item has the discount type shown.  You should enter the total dollar amount for the discount type - not the rate for the item.  For example, if the billback says that 10 pounds of cheese were sold and that each should get a $2 <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, you should enter 10 pounds for the item volume, and $20 in the "<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>" box.
<p></p>
PLEASE NOTE: Growth lumps sums should be entered in the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> area, and not included in the total in the "Growth" box.
</td></tr>
<tr><td valign="top"> <img src="../../images/6.gif"> </td>
<td>If the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> you wish to add is not reflected in the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> components available, click on the "add" link.  
</td></tr>
<tr><td valign="top"> <img src="../../images/7.gif"> </td>
<td>If you have added a new <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> component, you need to include the name of the component, and the total amount claimed.
</td></tr>
<tr><td colspan="2">
The total amount of the billback, as entered through its components needs to equal the amount entered in the "Basic Information" area of the billback. If the two amounts do not match, you will not be able to approve the billback.
<p></p>
To help you keep track of the running tally of information entered in the programs screen, there is a helpful summary window:
<p></p>
 <img src="../../images/bb_summary_layer.gif">
<p></p>
When you first enter the screen, it is minimized on the top left hand corner of the screen. Click on the [view summary] link to see the details above. You can minimize the window by clicking on [minimize this window]. You may also move the window by clicking on the blue bar at the top and moving the mouse while holding the mouse button down. 
<p></p>
The details shown in this window are:<br>
<em>Pounds: </em>The volume in pounds claimed for the billback<br>
<em>Cases:</em> The volume in cases claimed for the billback<br>
<em>Itemized Total: </em>The total dollar amount from all Fixed Price, <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>, Growth and Formula price entries.<br>
<em>Billback Total:</em> The amount entered in the "Basic Information" screen of the billback.<br>
<em>Variance:</em> The amount the Itemized total is different from the Billback total. The variance must be 0 for you to be able to approve the billback.<br>
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
