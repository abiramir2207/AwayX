<CFSET PAGE_TITLE="What's New in May 2003">
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
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Billbacks</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<br>
The biggest new piece of functionality in the new version of the application is the ability to record billbacks, compare them to programs and invoices, approve amounts to be paid, and pay them.  You can now:
<ul>
<li>Enter new information about a billback</li>
<li>View the ways the billback entered is different than the programs and invoices </li>
<li>Choose exact amounts to approve for payment</li>
<li>View adjustments from previously overpaid billbacks and exclusions from programs that exclude trade</li>
<li>Make payments online</li>
<li>Easily communicate to other <CFOUTPUT>#application.CompanyName#</CFOUTPUT> users about billbacks using our new routing system</li>
</ul>
You can also search for billbacks using the new billback search function, or view the Billback scorecard!
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;<CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbook</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

To help monitor the progress of your trade programs, we have created a <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> checkbook. Select the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> and program you want and voila! You can see how much a <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> has already earned and how much they have billed back. Print out a copy and take it to your next <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> meeting to show them how they're doing!
<Br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;<CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Planner</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>


A quick and easy tool which allows you to see the impact and final margin of giving a discount on an item, without having to create an entire program. Change the rate and volume, and immediatly view the impact on the bottom line!
<Br><br>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;News Headlines</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>


The latest headlines on what's happening in the foodservice industry are displayed moving across the top of the home page. To read a story in the new ticker, you can simply click on the link, and open a window with the full story.
<br><br>
If you want more than just foodservice news, or want to go more in-depth than the headlines, the "news headlines" link lets you read about the latest top stories, food and beverage coverage, business, technology and even "off-beat" news.
<br><br>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Programs</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>


In addition to tons of new functionality, we have also made upgrades to some of existing areas. 
<ul class="none">
<li><em>Search Programs:</em> You can now search for programs using the program's title, number, code <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, broker, dates, status and type. Use the search to find the program you're interested easily and quickly!</li>
<li><em>Invoice Search:</em> When adding items to a program, you can now select items purchased by a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> in a time period you specify. Create a program based on what was actually purchased!</li>
<li><em>Item carry-over:</em> Want to have multiple discounts for the same set of items? Tired of having to search for the items separately each time?  Now you can simply select the <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> type that has the items you are looking for, click search, and select the items!</li>
<li><em>New Scorecard:</em> The new program scorecard loads faster and lets you sort the results quickly and easily.</li>
</ul>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Project Management</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
Many improvements and additions have been made to project management. Among them:
<ul>
	<li><em>Lock:</em> A locking mechanism for projects has been created. As in programs, the lock helps to make sure only one person can make changes to a project at one time.</li>
	<li><em>Next Step/Update:</em> Now previously entered updates are saved, so you can see the whole history of communication.</li>
	<li><em>Glossary:</em> The glossary provides a quick explanation of the phases, priorities and statuses used in Project Management.</li>
	<li><em>Owners:</em> A project can now have multiple owners!</li>
	<li><em>Owner Position Search:</em> You can now search for various owner positions instead of trying to find the owner you need from a list.</li>
	<li><em>Finished Projects Hidden:</em> Don't want to see a project in your list? Check the "hide from scorecard" option, and the project will not appear in your scorecard view. Of course, you can still find hidden projects by searching for them, and reveal them by unchecking the "hide" option.</li>
	<li><em>Back to Search Results:</em> You can return to a search result screen after viewing details on a project by simply clicking on the "back to search results" link. This allows you to view all the projects that fit your search criteria with ease.</li>
</ul>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Increased Security</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>


In order to keep the application secure, we have made some changes to the way accounts are handled.
<ul>
<li>In order to change a password, users need to provide their old password. </li>
<li>Too many unsuccessful logins will lock a users account, and require an administrator to unlock it.</li> 
<li>Users have to change their password the first time they log in after being created, having their password reset, or being locked out.</li>
</ul>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Additional Enhancements</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

Other enhancements include:
<UL>
	<LI>New lists sorts throughout the application</LI>
<!--- 	<LI>Projects now "remember" your previous searches</LI> --->

</UL>


</DIV>

<BR><BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



