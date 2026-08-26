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
<tr><th colspan="2"><strong>Create a New Program -- Basic Information</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_basicinfo.gif"></td></tr>
<tr><td valign="top"> <img src="../images/1.gif"></td><td><em>Program Number and Program Reference Number: </em>Program Number and Program Reference Number: A program number for the program you are creating will be automatically generated.  This number will be used to refer to this program to edit or delete the program.  In addition to the automatically generated program number, you can enter a program reference number that connects this program to another system you use.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td><em>Program Title/Description:</em> Program Title/Description: To help you identify your program, you can enter a description of the program you are creating.  This is a required field.
</td></tr>

<tr><td valign="top"> <img src="../images/3.gif"></td><td><em>Delivery Period: </em>  Delivery Period: Select the period that this program will run from.  You can either enter the date in the box or click on the calendar icon to the right of the box.  Clicking on the calendar icon will show you the following screen:
<div align="center"><img src="../images/calendar.gif"></div>
<br>
	Pull down the month and year you wish to select, then click on the day.  The window will close once you have clicked on the day, and the information you have selected will be entered into the boxes.  You can also use the up and down arrows to the right of the calendar icon to increase or decrease the date you have entered by one day.  You must enter a delivery period.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td><em>Auto Renewal:</em> You can choose to have a program automatically. If you want the program to renew itself, check the box next to auto renewal. You now have two options. The first is to have the program renew annually. If you select that, then the program dates for the renewed version will be the same as the dates for this version, plus one year. So if the dates for the program you are created are August 1 - September 1 2003, the dates for the renewed program will be August 1 - Septebmer 1 2004. You can also choose to have the program renew immediately after it has completed. In this case, if you have a program that runs from August 1 - September 1 and therefore lasts for 31 days, the renewed program will run from September 2 to October 3 (31 days).
</td></tr>
<tr><td valign="top"> <img src="../images/5.gif"></td><td><em>Payment Cycle:</em> Select the payment frequency for this program.</td></tr>
<tr><td valign="top"> <img src="../images/6.gif"></td><td><em>Program Quantity:</em>  Enter the number and type of units in the program.  Program types include per pound and per case.  You must enter a program quantity.</td></tr>
<tr><td valign="top"> <img src="../images/7.gif"></td><td><em>Controllable: </em>  Check whether or not this program is controllable.</td></tr>
<tr><td valign="top"> <img src="../images/8.gif"></td><td><em>Claim Mechanics:</em>Select how <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> should claim their program benefits.  Options include: BillBack Request, Auto Payment and Auto Credit.  The program type controls these options. If you do not see the option you need, select a different program type.</td></tr>
<tr><td valign="top"> <img src="../images/9.gif"></td><td><em>Advanced Spending Amount:</em>&nbsp; Note here how much you anticipate will be spent in advance on this program.</td></tr>
<tr><td valign="top"> <img src="../images/10.gif"></td><td><em>Program Notes &amp; Comments:</em> You can enter notes you wish your clients to see in the Program Notes area. Notes that you DO NOT want your clients to be able to view may be entered in the "Comments" area.</td></tr>

<tr>
	<td colspan="2">
		<br>
		When you click on "Continue" a box will appear and say "Press OK if all program information is correct".  Click "OK" to continue. At this point, the program has been created and saved.  Although you need to continue adding information to the program, you can do so at a later time if you wish by reviewing the program in the "Work in Progress" area.
	</td>
</tr>
</table>

<p></p>
</div>


<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
