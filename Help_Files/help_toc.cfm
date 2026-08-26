<!---
Document Name:	help_toc.cfm
Directory:		/help_files
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	November 27, 2002

Description: The table of contents for the help files frame

Includes:
--->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Help Files Table of Contents</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!---Set variables--->
<CFSCRIPT>
	Border="No";
	BorderSize=0;
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=8;
	IsClosed="No";
	Width=160;
</CFSCRIPT>

<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="General Information"
	TitleClosed="General Information"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<!---General Application Information--->
		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/1.cfm" TARGET="mainwindow">Application Information</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/rightclick.cfm" TARGET="mainwindow">Main Right Click Menu</A><BR>
		<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/prodright.cfm" TARGET="mainwindow">Product Right Click Menu</A><BR>

</CF_openLayer>

	<!---Projects--->
	<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Projects"
	TitleClosed="Projects"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/projects/index.cfm" TARGET="mainwindow">Project Scorecard</A><BR>
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/projects/summary.cfm" TARGET="mainwindow">Project Summary</A><BR>
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/projects/details.cfm" TARGET="mainwindow">Project Detail</A><BR>
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/projects/new.cfm" TARGET="mainwindow">Create or Edit Project</A><BR>
<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/projects/search.cfm" TARGET="mainwindow">Search Projects</A><BR>

	</CF_openLayer>

<!---Programs--->
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Programs"
	TitleClosed="Programs"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">


		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/createprogram/index.cfm" TARGET="mainwindow">Create Program</A><BR>
		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/pricingrules/index.cfm" TARGET="mainwindow">Commodity Pricing</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/program/scorecard/index.cfm" TARGET="mainwindow">Scorecard</A><BR>
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/program/viewprogram/viewprogram.cfm" TARGET="mainwindow">View Programs</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/program/tradecheckbook/index.cfm" TARGET="mainwindow"><CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Checkbook</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/program/tradeplanner/index.cfm" TARGET="mainwindow"><CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#</CFOUTPUT></A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/reassign.cfm" TARGET="mainwindow">Reassign Programs</A><BR>
<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/program/programsearch/index.cfm" TARGET="mainwindow">Search Programs</A><BR>
</CF_openLayer>

<!---Billbacks--->
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Billbacks"
	TitleClosed="Billbacks"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">


		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/billbacks/capture/index.cfm" TARGET="mainwindow">Enter Billback Info</A><BR>
		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/billbacks/deviations/index.cfm" TARGET="mainwindow">Deviations</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/billbacks/Approval/index.cfm" TARGET="mainwindow">Approving</A><BR>
	<!--- <IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/billbacks/Payment/index.cfm" TARGET="mainwindow">Payment</A><BR> --->
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/billbacks/scorecard/index.cfm" TARGET="mainwindow">Billbacks Scorecard</A><BR>
<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/billbacks/search/index.cfm" TARGET="mainwindow">Billback Search</A><BR>
</CF_openLayer>


<!---Search Functions--->
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Search Screens"
	TitleClosed="Search Screens"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">


		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/createprogram/page8.cfm" TARGET="mainwindow">Product Search</A><BR>
		<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/projects/search.cfm" TARGET="mainwindow">Project Search</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/program/programsearch/index.cfm" TARGET="mainwindow">Program Search</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/createprogram/page4.cfm" TARGET="mainwindow"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Search</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/createprogram/page5.cfm" TARGET="mainwindow">Broker Search</A><BR>
	<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/createprogram/page6.cfm" TARGET="mainwindow"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Search</A><BR>
</CF_openLayer>


<!---Reports--->
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Reports"
	TitleClosed="Reports"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">


		<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/reports/program.cfm" TARGET="mainwindow">Create/Schedule Reports</A><BR>
</CF_openLayer>


	<!---Misc Functions--->
	<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Miscellaneous Functions"
	TitleClosed="Miscellaneous Functions"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/todo/index.cfm" TARGET="mainwindow">To Do List</A><BR>
	<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/changepassword.cfm" TARGET="mainwindow">Change Password</A><BR>
	<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/xmessenger.cfm" TARGET="mainwindow">XMessenger</A><BR>
	</CF_openLayer>



<!---Settings -- Administration--->
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Settings -- Administration"
	TitleClosed="Settings -- Administration"
	TitleTooltip="Click here to colapse selections"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">

		<!---Projects--->
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"
			BorderColor="#BorderColor#"
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="Project Settings"
			TitleClosed="Project Settings"
			TitleTooltip="Click here to colapse selections"
			TitleColor="#TitleColor#"
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/project/index.cfm" TARGET="mainwindow">Status</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/project/priorities.cfm" TARGET="mainwindow">Priorities</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/project/phases.cfm" TARGET="mainwindow">Phases</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/project/functional.cfm" TARGET="mainwindow">Functional Areas</A><BR>
			<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/project/sponsors.cfm" TARGET="mainwindow">Sponsors</A><BR>
			</CF_openLayer>

			<!---Programs--->
			<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"
			BorderColor="#BorderColor#"
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="Program Settings"
			TitleClosed="Program Settings"
			TitleTooltip="Click here to colapse selections"
			TitleColor="#TitleColor#"
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/program/expiring.cfm" TARGET="mainwindow">Expiring Age</A><BR>
			<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/program/index.cfm" TARGET="mainwindow">Program Wizard</A><BR>

			</CF_openLayer>

			<!---System Administration--->
			<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"
			BorderColor="#BorderColor#"
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="System Administration"
			TitleClosed="System Administration"
			TitleTooltip="Click here to colapse selections"
			TitleColor="#TitleColor#"
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/data/index.cfm" TARGET="mainwindow">Data Integration</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/AwayXData/index.cfm" TARGET="mainwindow"><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Data Integration</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/fiscal/index.cfm" TARGET="mainwindow">Fiscal Year</A><BR>
			<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/session/index.cfm" TARGET="mainwindow">Session Management</A><BR>
			</CF_openLayer>

			<!---Users--->
			<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"
			BorderColor="#BorderColor#"
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="Users"
			TitleClosed="Users"
			TitleTooltip="Click here to colapse selections"
			TitleColor="#TitleColor#"
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/adduser/index.cfm" TARGET="mainwindow">Add User</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/listuser/index.cfm" TARGET="mainwindow">List User</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/unlockuser/index.cfm" TARGET="mainwindow">Unlock User</A><BR>
<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/loginattempts/index.cfm" TARGET="mainwindow">Login Attempts</A><BR>
			<IMG SRC="/images/tree.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/profile/index.cfm" TARGET="mainwindow">User Profiles</A><BR>
			<IMG SRC="/images/tree2.gif" ALIGN="absmiddle">&nbsp;<A HREF="/help_files/manual/administration/positions/index.cfm" TARGET="mainwindow">User Positions</A><BR>
			</CF_openLayer>

</CF_openLayer>

</BODY>
</HTML>
