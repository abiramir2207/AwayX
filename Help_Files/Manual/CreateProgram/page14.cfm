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
<tr><th colspan="2"><strong>Create a New Program -- Review</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_final.gif"></td></tr>
<tr><td valign="top"><img src="../images/1.gif"></td><td><em>Ready for Approval:</em>  When the program you have created is ready to be approved, click on the "Ready for Approval" check box.  A dialogue box will appear and ask you to confirm that the program is ready to begin the approval process.  The program will then be moved from the "Work in Progress" area to the "Request for Approval" area.
<p></p>
<em>Volume:</em> Click on this to calculate the volume you wish to apply to various items in the program. You need to set volumes before you can approve the program. If you try to approve without setting a volume, you will be redirected to the volume area. Details on volume are in the "Volume" section.
<p></p>
<em>Margin Calculation:</em> You can view the margin on the program before you approve it. The calculation will be more accurate if you establish volume before you check the margin.</td></tr>
<tr><td valign="top"><img src="../images/2.gif"></td><td>This displays basic information about the program you have created.  To edit this information click on "Basic Information" in the top navigation. Please notice that the "comments" section is not displayed here. Comments are for internal use only, and this summary can be sent to non-users using email, fax and print.</td></tr>
<tr><td valign="top"><img src="../images/3.gif"></td><td><em><cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>, <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> and Brokers:</em> The eligible groups in the program are shown here. You can find additional information on each <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> and broker by using your right mouse button when the question mark appears, and clicking on the link for [… summary].</td></tr>
<tr><td valign="top"><img src="../images/4.gif"></td><td><em>Fixed Pricing:</em>  View the fixed pricing you have established. Edit this information by clicking on "Fixed Price" in the top navigation.</td></tr>
<tr><td valign="top"><img src="../images/5.gif"></td><td><em><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s:</em> View the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s for this program. Edit the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> by clicking on "<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>" in the navigation.</td></tr>
<tr><td valign="top"><img src="../images/6.gif"></td><td><em>Growth Rates:</em> Information about the program growth rates is shown here.  Click on "Growth" in the navigation to change this information.</td></tr>
<tr><td valign="top"><img src="../images/7.gif"></td><td><em><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Incentives:</em> The <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> incentives you created for this program are shown here.  Click on "<CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>" to modify this information.</td></tr>
<tr><td valign="top"><img src="../images/8.gif"></td><td><em>Formula Pricing: </em>The formula you established.  Choose "formula" from the navigation to change this information.</td></tr>
<tr><td valign="top"><img src="../images/9.gif"></td><td><em>Attached Documents:</em> You may review the documents you attached to the program. In addition to showing all the information about each document, you can also open the document by clicking on the blue name of the document.</td></tr>
<tr><td valign="top"><img src="../images/10.gif"></td><td><em>Program Volume:</em>  You can review the volume you set in program volume here. (Please refer to the program volume section for more details on volume.) The blue text for the volume is a link. Clicking on it will bring up a window that shows invoices that help build up the displayed volume.</td></tr>
<tr><td valign="top"><font color="red">(11)</font></td><td>This disclaimer is to help people who might have had the program summary emailed, printed, or faxed to them understand what the legal information about the program is.</td></tr>
<tr><td valign="top"><font color="red">(12)</font></td><td>You can print, email, fax or delete this information. You can also copy this program. Copying the program will create a new program with all the same information as the current one. However, any changes made to the new program will not be reflected in the one you made the copy from, and vice versa. You will still be able to copy after you approve the program.</td></tr>
</table>
<p></p>
</div>
	 

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
