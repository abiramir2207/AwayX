<CFSET PAGE_TITLE="What's new...">
<HTML>

<HEAD>
	<TITLE>The Food Service Industry leader in the Trade Management Solutions arena</TITLE>
	
	<STYLE TYPE="text/css">
		Body, TD
			{
				font-size:		11px;
			}
		.maintitle
			{
				color:			Navy;
				background:		#FFFFFF;
				border-bottom:	3 solid Navy;
				border-top:		3 solid Navy;
				font-size: 		16px;
				font-weight: 	bold;
				padding : 		3px;
			}
		.sectiontitle
			{
				color:			#4169E1;
				background:		#FFFFFF;
				border-bottom:	0 dashed #CCCCCC;
				font-size: 		11px;
				font-weight: 	bold;
				padding : 		2px;
			}
	</STYLE>
	
<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">	

	
</HEAD>

<BODY LINK="#6B6DFF" VLINK="#6B6DFF" ALINK="#6B6DFF" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" MARGINWIDTH="0" MARGINHEIGHT="0" STYLE="font-family: Arial; font-size: 10pt">

<CFINCLUDE TEMPLATE="/includes/header.cfm">

<!--- <TABLE BORDER="0" CELLPADDING="10" CELLSPACING="0" WIDTH="100%">
		<TR>
			<TD ALIGN="center" WIDTH="45%"><DIV STYLE="color: #FCC00C; background: Navy; padding : 7px;"><B>400 Research Drive<BR>Wilmington, Massachusetts 01887</B></DIV></TD>
			<TD ALIGN="center" WIDTH="10%"><IMG SRC="http://demo.awayx.com/images/newsletter/awayx_logo_small.gif" WIDTH="120" HEIGHT="42" ALT="" BORDER="0"></FONT></TD>
			<TD ALIGN="center" WIDTH="45%"><DIV STYLE="color: #FCC00C; background: Navy; padding : 7px;"><B>tel 978.988.1355<BR>fax 978.988.1277</B></DIV></TD>
		</TR>
</TABLE> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Blacksmith Apps Header --->
<!--- 
<TABLE BORDER="0" CELLPADDING="10" CELLSPACING="0" WIDTH="100%">
		<TR>
			<TD ALIGN="center" WIDTH="45%"><DIV STYLE="color: #FFFFFF; background: Navy; padding : 7px;"><B>400 Research Drive, Wilmington, Massachusetts 01887</B></DIV></TD>
			<TD ALIGN="center" WIDTH="10%"><IMG BORDER="0" SRC="http://demo.awayx.com/images/newsletter/bsa_logo.gif" WIDTH="65" HEIGHT="66"></FONT></TD>
			<TD ALIGN="center" WIDTH="45%"><DIV STYLE="color: #FFFFFF; background: Navy; padding : 7px;"><B>tel 978.988.1355 fax 978.988.1277</B></DIV></TD>
		</TR>
</TABLE>
 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="10" CELLSPACING="10">
	<TR>
		<TD VALIGN="top" WIDTH="33%" STYLE="border: 1 solid #F09A09;">

			<DIV CLASS="maintitle" ALIGN="center">Welcome to<BR><CFOUTPUT>#application.CompanyName#</CFOUTPUT></DIV>

			This newsletter is intended to keep the users of the <CFOUTPUT>#application.CompanyName#</CFOUTPUT> Contract and 
			Trade Management application informed of new developments, upcoming 
			training events, maintenance schedules as well as a source of &quot;tips 
			&amp; tricks&quot; associated with the application.
			
			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle"><CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Planner &quot;What If&quot; Tool</DIV>

			We have added a quick and easy tool to the <CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> planner that 
			maps out the impact cost, margin percent and margin dollars have on each 
			other. If you change one of the criteria (for example, entering the margin 
			percent you need to approve a program) it will tell you what the associated 
			costs and margin dollars will be. 
			
			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Component <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s</DIV>

			You can now create <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s based on multiple components. You 
			may create as many as 8 components per program -- including percent <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s, 
			<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s per case and <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s per pound. You can assign multiple components 
			to a product, or pick which products each component applies to. This tool 
			gives users increased flexibility to enter some of the more complex <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s. 

			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Ship-To Clarification</DIV>

			When searching for products by invoice, the ship-to for a particular <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> 
			is included along with the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> name to help make the correct selection in 
			looking for products. 
			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Urner Barry commodity data</DIV>

			The Urner Barry commodity data pool will now includes 
			historical daily quotes going back 2 years.
			Access to commodity data, depends of the access rights that have been 
			granted to you by the application administrator within your company.
			Urner Barry specializes in the timely, accurate, and 
			unbiased reporting of market news to clients in the poultry, egg, meat, 
			seafood, and related segments of the food industry. 

		</TD>
	
		<TD VALIGN="top" WIDTH="33%" STYLE="border: 1 solid #F09A09;">

			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_deployment.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Project notes creation shortcut</DIV>
			
			Starting immediately, users of the &quot;projects&quot; section will have the ability 
			to enter notes associated with a particular project from within the project 
			list page. This will save you from having to open the project, lock it and 
			then enter the notes associated with it. Be aware that if a project is 
			currently being updated (you'll see the lock next to its description in the 
			project list...), you will not be able to add notes to it. 
			
			<BR>
					
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_deployment.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Invoice Search Tool</DIV>
			
			Invoices information is now available. You can search for an invoice using 
			<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> information, or by entering information about the invoice itself 
			(such as the invoice date and number). Once you have found the invoice you 
			wish to view we provide invoice details. You can email, fax and print the 
			prices and volumes for all products in an invoice -- along with the basic 
			information such as the <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> invoiced and the invoice dates. 
			
			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_maintenance.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">From the <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT> IT Department</DIV>
			 
			We find computers to be like finely tuned vehicles: they run great 
			as long as they are maintained. However, if you let the maintenance 
			schedule become one of convenience versus necessity, they can become 
			more trouble than they are worth. In order to avert problems, and starting on
			<B>August 23rd, on 
			Saturdays at 7:00pm est</B>, our servers will be unavailable 
			for approximately 2 hours while we perform routine maintenance. 
			Rest assured we take all precautions to protect your data and spare 
			no expense when it comes to the integrity of the service we provide.
			If you have any questions please contact us at <A HREF="mailto:support@#application.CompanyEmailSuffix#?Subject=Question">support@<CFOUTPUT>#application.CompanyEmailSuffix#</CFOUTPUT></A>
			or in the event of an emergency <I>978-404-9112</I>.

			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_security.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Application authentication process</DIV>
			
			Users sometimes attempt to use the application 
			without being authenticated. This can happen, for instance, via a bookmark to a 
			location within the application. Examples of URLs used are:
			<I>http://companyname.<CFOUTPUT>#application.CompanyOtherSuffix#</CFOUTPUT>/enter.cfm</I> or
			<I>http://companyname.<CFOUTPUT>#application.CompanyOtherSuffix#</CFOUTPUT>/home.cfm</I>.<BR>
			We recommend that users review any&nbsp; bookmark used to make sure that it points to the 
			appropriate URL. The entry point should always be:<I>http://companyname.<CFOUTPUT>#application.CompanyOtherSuffix#</CFOUTPUT></I> 

		</TD>

		<TD VALIGN="top" WIDTH="33%" STYLE="border: 1 solid #F09A09;">

			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_deployment.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Copy Projects</DIV>

			Tired of recreating similar projects over and over? We have now created a project copying tool. 
			You can now use an existing project as a template for a new project. 
		
			<BR>

			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Search Programs by Position</DIV>
			
			The program search tool has been updated to offer you the ability to 
			search for programs according to the position of the user who created, 
			requested approval for, or approved the program. 
		
			<BR>
			
			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_programs.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Programs</DIV>
			We have made a number of minor and major changes to the process of creating and editing programs, including: 
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<style>
					LI	{ list-style-image:url(http://demo.awayx.com/images/newsletter/bullet_blue.gif) }
				</style>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			
			<UL>
			<LI>Simplified Deletion: You can now delete products, <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>, <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> and brokers from your program by clicking on the red &quot;x&quot;next to the name of what you want to delete.<BR></LI>
			<LI>Auto Renew: Programs can now be set up to renew automatically. If Auto Renew is an option for the program type you are creating, you can choose to have your program renew either concurrently (right after the one you are renewing) or annually (the same period next year).<BR></LI>
			<LI>View Margin on Work In Progress: You can now view the margin on a program you are working on - before requesting approval for it.<BR></LI>
			<LI>Updated Multi-assignment Tool: We have streamlined the multi-assignment tool for programs. It now only appears once you have selected products, and you no longer have to click to select all products. (Although you can still select and unselect all products.)<BR></LI>
			<LI>Revised Growth and <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>: <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> and Growth have been reorganized to make them easier to create and update. </LI>
			</UL>

			<DIV CLASS="sectiontitle"><IMG SRC="http://demo.awayx.com/images/newsletter/icon_computer.gif" WIDTH="40" HEIGHT="40" ALT="" BORDER="0" ALIGN="absmiddle">Archives</DIV>
			You can read about the changes we've been making to our application over time by visiting the "What's New" archives: 
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<style>
					LI	{ list-style-image:url(http://demo.awayx.com/images/newsletter/bullet_blue.gif) }
				</style>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<UL>
			<li><a href="/help_files/whatsnew/index.cfm">August</a></li>
			<li><a href="/help_files/whatsnew/index_7-28.cfm">July</a></li>
			<li><a href="/help_files/whatsnew/index_7-9.cfm">June</a></li>
			<li><a href="/help_files/whatsnew/whatsnew_may2003.cfm">May</a></li>
			<li><a href="/help_files/whatsnew/zzz_index.cfm">First Quarter</a></li>
			</UL>

		</TD>
	</TR>
</TABLE>

<!--- <TABLE BORDER="0" CELLPADDING="10" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD ALIGN="center" WIDTH="100%"><DIV STYLE="color: #FCC00C; background: Navy; padding : 2px;"><B>www.awayx.com - the food service industry leader in the trade management solutions arena</B></DIV>
		If you would like not to receive this newsletter again contact <A HREF="mailto:support@awayx.com?Subject=Do not send newsletter">support@awayx.com</A>
		</TD>
	</TR>
</TABLE> --->

</BODY>

</HTML>

