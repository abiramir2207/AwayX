<CFSET PAGE_TITLE="What's New in June 2003">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<STYLE>
	#main
	{
		position: relative;
		top: 0px;
		left: 25px;
		z-index: 50;
		padding-top: 20px;
		padding-left: 20px;
		padding-right: 50px;
		font: 12px;
	}
</STYLE>



<DIV ID="main">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Documents</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<br>
Does your new program have a letter explaining it to <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>? Do you want to email a profitability analysis with a proposed program? You can now attach documents to programs and billbacks, and email or fax the program or billback with the document attached.
<BR><BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Reassign Programs</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

If a program needs to change owners - to go from one owner position to another - you no longer need to delete the program and create a new one. Administrators can simply reassign the program to a new owner position.
<Br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Off Invoice Program Type</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
A new program type has been created. The Distributor Off Invoice program type allows you to select a list of items and increase or reduce the invoice price of the items.
<Br><br>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;New and Improved Program Wizard</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
Administrators will be pleased to see that we have streamlined the process for creating a new program template. You can now create a program in two easy screens. Even better, we have added the ability to edit and change existing active templates, while programs created with those templates retain the original settings.
<br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Are You New?</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
...or are you coming back after a long absence? You might like to read our <A HREF="/help_files/home.cfm" onmouseover="helpicon.src='/Images/help_down3.gif';" onmouseout="helpicon.src='/Images/help_up3.gif';" onclick="NewWindow(this.href,'name','1000','700','No', 'Yes');return false;" TITLE="Helpful Information">help files</A> for an overview of the application. You might also be interested in seeing what we added in <A href="whatsnew_may2003.cfm">May</A>.
<br><br>


<BR><BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



