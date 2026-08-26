<CFSET PAGE_TITLE="What's New August 2003">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>What's New August 2003</TITLE>
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
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Component <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
You can now create <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s based on multiple components. You may create as many as 8 components per program -- including percent <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s, <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s per case and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s per pound.  You can assign multiple components to a product, or pick which products each component applies to. This tool gives users increased flexibility to enter some of the more complex <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s.
<br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Search Programs by Position</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
The program search tool has been updated to offer you the ability to search for programs according to the position of the user who created, requested approval for, or approved the program.
<br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Ship-To Clarification</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
When searching for products by invoice, the ship-to for a particular <cfoutput>
#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> is included along with the <cfoutput>
#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> name to help make the correct selection in looking for products.
<br><br>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Invoice Search Tool</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
Invoices information is now available. You can search for an invoice using <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> information, or by entering information about the invoice itself (such as the invoice date and number).  Once you have found the invoice you wish to view we provide invoice details. You can email, fax and print the prices and volumes for all products in an invoice -- along with the basic information such as the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> invoiced and the invoice dates.
<br><br>

<cfif application.returned_customer_setting.customer_keyword IS "Resers">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Price List Tools</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
You may now search for prices lists by entering information on the price list. You will be able to view, print, email and fax the price lists.
<br><br>
</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Copy Projects</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
Tired of recreating similar projects over and over? Have no fear -- we have now created a project copying tool. You can now use an existing project as a template for a new project.
<br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;"What If" Tool for the <CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel# </CFOUTPUT></TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
We have added a quick and easy tool to the <CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel# </CFOUTPUT>that maps out the impact cost, margin percent and margin dollars have on each other. If you change one of the criteria (for example, entering the margin percent you need to approve a <cfoutput>#Application.PlannerPrgLabel#</cfoutput>) it will tell you what the associated costs and margin dollars will be.
<br><br>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Prior "What's New"</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
What's New Archive:
<ul>
<li><a href="index_7-28.cfm">July</a></li>
<li><a href="index_7-9.cfm">June</a></li>
<li><a href="whatsnew_may2003.cfm">May</a></li>
<li><a href="zzz_index.cfm">First Quarter</a></li>
</ul>
<br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
