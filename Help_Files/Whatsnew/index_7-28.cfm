<CFSET PAGE_TITLE="What's New July 2003">
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
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Programs</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
We have made a number of minor and major changes to the process of creating and editing programs, including:
<ul>


<li><strong>Simplified Deletion:</strong> You can now delete products, <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> and brokers from your program by clicking on the red "x" next to the name of what you want to delete.<br><br></li>
<li><strong>Auto Renew:</strong> Programs can now be set up to renew automatically. If Auto Renew is an option for the program type you are creating, you can choose to have your program renew either concurrently (right after the one you are renewing) or annually (the same period next year). You can also choose how many days before the start date of the new program you would like the program to appear as a work in progress. You will still need to approve automatically renewed programs.<br><br></li>
<li><strong>View Margin on Work In Progress:</strong> You can now view the margin on a program you are working on - before requesting approval for it.<br><br></li>
<li><strong>Updated Multi-assignment Tool:</strong> We have streamlined the multi-assignment tool for programs. It now only appears once you have selected products, and you no longer have to click to select all products. (Although you can still select and unselect all products.)<br><br></li>
<li><strong>Revised Growth and <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>:</strong> <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> and Growth have been reorganized to make them easier to create and update.<br><br></li>
</ul><BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Commodities</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
You can now view the latest and historical Urner Barry commodity information using our commodity costs tool.
<br><br>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="10" HEIGHT="10" ALT="" BORDER="0">&nbsp;Prior "What's New"</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
View our old "What's New" entries:
<ul>
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



