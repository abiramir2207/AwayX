<CFSET PAGE_TITLE="What's New">
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
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Formula Pricing</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>
A new discount type for programs that allows you to build <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> pricing rules based on commodity data
<UL>
	<LI>Establish pricing periods and corresponding future release dates  </LI>
	<LI>Determine whether future pricing periods will require individual approval or be automatically released</LI>
	<LI>Create pricing rules that account for commodity market movement and "overage" rates</LI>
</UL>  
To see this feature in action, you need to first create a program
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Trade-Adjusted Margins</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

An enhancement to the profit calculation, this new feature adjusts the available margin for programs involving <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> and items with existing Trade rates
<UL>
	<LI>For each program, users assign a weight to each <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, with the weight reflecting the approximate percentage of the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> business managed by that <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></LI>
	<LI>From the "View Margin" window, users can now view a new calculation for the Trade Program Adjustment [TPA] for each product within the program </LI>
</UL>
To see this feature in action, you need to first create a program
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Margin Reports</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

Based on Product or Program, these reports detail the margin net of trade
<UL>
	<LI>The tool provides for three levels of detail as it relates to costs and #application.returned_customer_setting.Trade_Label# adjustments</LI>
	<LI>Reports can be run against varying margin levels, ie, greater than, less than, etc.</LI>
</UL>

<CFIF Get_Profile_Settings.Report_Scheduler EQ 1>
To see the Margin Reports in action go <A HREF="/ReportWriter/margin_Analysis.cfm"><B>here</B></A>
</CFIF>
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;Project Management</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

These tools continue the <CFOUTPUT>#application.CompanyName#</CFOUTPUT> evolution towards a single-source of information and focus for the user by allowing you to create and manage Projects that relate to <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>, <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, Products, and Brokers
<UL>
	<LI>Settings for Priority, Status, Phase, Sponsorship, and other related fields</LI>
	<LI>User-managed content such as Volume, Budget, Timing, and Resources</LI>
	<LI>Access from the Home Page link under "Deployment" with new home page scorecard to quickly access your Projects by Priority</LI>
</UL>


<CFIF Get_Profile_Settings.PM_Access EQ 1>
	To see Project Management in action go <A HREF="/ReportWriter/PM/index.cfm"><B>here</B></A>
</CFIF>

<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;XMessenger</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

This new feature facilitates instant messaging between users to enable more rapid collaboration, reducing the need for additional email and voice mail
<UL>
	<LI>Open the XM by clicking the <IMG SRC="/images/xmessenger_icon.gif"> icon on the header</LI>
	<LI>If the icon blinks red - yellow it indicates that you have a message waiting</LI>
	<LI>Select the user you wish to "XM with" and click on "Connect To User"</LI>
	<LI>A window will display a history of the messages between you and the user you are connected to</LI>
	<LI>Type your new message here and click "Send Message"</LI>
</UL>
Get a virtual tour of the XMessenger <A HREF="xmessenger_help.cfm" onclick="NewWindow(this.href,'name','500','350','No', 'No');return false;"><B>here</B></A>.
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE WIDTH="90%" CELLPADDING="3" CELLSPACING="0"> 
<TR>
	<TD NOWRAP STYLE="border-bottom: 2px solid #FF8C00; color: #1B731C; font: bold 16px;"><IMG SRC="/images/active.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0">&nbsp;On-line help</TD>
	<TD WIDTH="100%" STYLE="border-bottom: 2px solid #FF8C00;">&nbsp;</TD>
</TR>
</TABLE>
<BR>

Detailed, on-line help is now available at all times by clicking on the question mark icon in the top right hand corner of your screen. A window will open which will show you information about the entire application.
<p></p>
In addition, you will often see a <FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue">read me first</FONT><FONT SIZE="2" COLOR="Red">]</FONT> as you move through the site.  Clicking on one of those links will bring you to a help section which has information specific to the page you found the link on.
<p></p>
New help sections include:
<ul>
<li>Right click menus <FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/rightclick.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Right click menus...">read me first</a></FONT><FONT SIZE="2" COLOR="Red">]</FONT></li>
<li>Commodity pricing wizard <FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				<A HREF="/help_files/manual/pricingrules/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Commodity Pricing Wizard...">
					read me first
				</A>
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT> </li>
<li>Projects - viewing, creating, editing and searching <FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/projects/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Projects...">read me first</a></FONT><FONT SIZE="2" COLOR="Red">]</FONT></li>
<li>Program creation <FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				<A HREF="/help_files/manual/createprogram/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Create Program...">
					read me first
				</A>
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT></li>
<li>Program scorecard and details <FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/program/scorecard/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Program Scorecard...">read me first</a></FONT><FONT SIZE="2" COLOR="Red">]</FONT></li>
<li>Report creation and scheduling<FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/reports/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Reports...">read me first</a></FONT><FONT SIZE="2" COLOR="Red">]</FONT></li>
<li>Control panel settings: projects, programs, users, system administration and users <FONT SIZE="2" COLOR="Red">[</FONT><FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/administration/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Control Panel Settings...">read me first</a></FONT><FONT SIZE="2" COLOR="Red">]</FONT></li>
</ul>
You can download a complete version of all help files by <a href="/help_files/user_guide_11_27_02.pdf">clicking here</a>, or by downloading it from the main help page.

<BR>&nbsp; <br>

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
	<LI>Multi-assignment of volume - quickly and easily select multiple products and assign weekly volumes [similar to the original multi-rating tool]</LI>
	<LI>Resetting to Work In Progress - for Programs requiring additional work before qualifying for Approval, users can reset the status to Work In Progress</LI>
	<LI>Browser Settings - accessed via a link from the Home Page under Settings, this is a quick-reference guide for the appropriate Internet Explorer settings that will insure the <CFOUTPUT>#application.CompanyName#</CFOUTPUT> product is performing correctly. To review your Browser Settings, go <A HREF="/BrowserSettings/index.cfm"><B>here</B></A></LI>
	<LI>You can now sort your scorecard results by clicking on the column headers at the top of the page.</LI> 
	<LI>Sorting capabilities installed in all major search tools: products, brokers, <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> and <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>.</LI> 



</UL>


</DIV>

<BR><BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



