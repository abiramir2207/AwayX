<CFSET PAGE_TITLE="#application.CompanyName# Documentation">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Give this window a name so that popup based forms can return data to it						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<script language="JavaScript">
	<!--
		this.window.name="mywindowname";
	//-->
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR>
<div align="center">
<b><font size="+2">Help Files and Information</font></b>
<p></p>


<TABLE ALIGN="CENTER" CELLSPACING="0" CELLPADDING="0" width="90%" border="0">
  <TR>
    <TD VALIGN="top" align="center">
	<table><tr><td>
	<ul>
	<b>General Information:</b>
	<br>
	<li><A href="/help_files/index.cfm?ID=1" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="General Information">General Application Information</A></li>
<p></p>
<li><strong>Right Click Menus</strong></li>
	<ul>
		<li><A href="/help_files/manual/rightclick.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Main Right Click Menu">Main Application Right Click Menu</a></li>
<li><A href="/help_files/manual/prodright.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Main Right Click Menu">Product Right Click Menu</a></li>
	</ul>

	<p>
	<b>Programs:</b>
	<br>
	<li><A href="/help_files/manual/createprogram/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Create Program">Create Program</A></li>
	<li><A href="/help_files/manual/pricingrules/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Commodity Pricing">Commodity Pricing</A></li>

	<p>
	<b>Reports:</b>
	<br>
	<li><A href="/help_files/manual/reports/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Create and Schedule Reports">Create and Schedule Reports</A></li>
	<p>
	<!--- <b>Deployment:</b>
	<li><A href="#"></A>PDA Exports</li>
	<br> --->
	<b>Settings:</b>
	<br>
		<ul>
		<br>
		<b>Administration:</b>
		<br>
		<!--- 	<ul>
			<br>
			<b>Broker:</b>
			<li><A href="#"></A>Add Broker</li>
			<li><A href="#"></A>List Broker</li>
			<li><A href="#"></A>Market Area Maintenance</li>
			</ul> --->
			
			<!--- <ul>
			<br>
			<b>Personal Settings:</b>
			<li><A href="#"></A>Change Password</li>
			</ul> --->
			
			<ul>
			<br>
			<b>Projects:</b>
			<br>
			<li><A href="/help_files/manual/administration/project/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Status">Status</a></li>
			<li><A href="/help_files/manual/administration/project/priorities.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Priorites">Priorities</a></li>
			<li><A href="/help_files/manual/administration/project/phases.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Phases">Phases</li>
			<li><A href="/help_files/manual/administration/project/functional.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Functional Areas">Functional Areas</a></li>
			<li><A href="/help_files/manual/administration/project/sponsors.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Sponsors">Sponsors</a></li>
			</ul>
			
			<ul>
			<br>
			<b>Programs:</b>
			<br>
			<li><A href="/help_files/manual/administration/program/expiring.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Program Expirations">Expiring Age</A></li>
			<li><A href="/help_files/manual/administration/program/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Program Wizard">Program Wizard</A></li>
			</ul>
			
			<ul>
			<br>
			<b>System Administration:</b>
			<br>
			<li><A href="/help_files/manual/administration/data/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Data Integration">Data Integration</A></li>
			<li><A href="/help_files/manual/administration/data/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="<CFOUTPUT>#application.CompanyName#</CFOUTPUT> Data Integration"><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Data Integration</A></li>
		<!--- 	<li><A href="#"></A>Data Purging</li> --->
			<li><A href="/help_files/manual/administration/fiscal/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Fiscal Year">Fiscal Year</A></li>
			<!--- <li><A href="#"></A>Purge Queue</li> --->
			<li><A href="/help_files/manual/administration/session/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Session Management">Session Management</A></li>
			</ul>
			
			<ul>
			<br>
			<b>Users:</b>
			<br>
			<li><A href="/help_files/manual/administration/adduser/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Add User">Add User</A></li>
			<li><A href="/help_files/manual/administration/listuser/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="List User">List User</A></li>
			<li><A href="/help_files/manual/administration/profile/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="User Profiles">User Profiles</A></li>
			<li><A href="/help_files/manual/administration/positions/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="User Positions">User Positions</A></li>
			</ul>
<!--- 		<Br>
		<strong>Change Password:</strong>	
		<li><A href="#"></A>Change Password</li>
		<br>
		<strong>Browser Settings:</strong>
		<li><A href="#"></A>Browser Version</li>
		<li><A href="#"></A>Security Settings</li>
		<li><A href="#"></A>Advanced Settings</li> --->
		</ul>
		<br>
	<b><A href="/help_files/manual/program/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Programs">Programs:</A></b>
	<li><A href="/help_files/manual/program/scorecard/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Program Scorecard">Scorecard</A></li>
	<li><A href="/help_files/manual/program/viewprogram/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="View Programs">View Programs</A></li>
	<p>
	<b>Projects:</b>
	<br>
	<li><A href="/help_files/manual/projects/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Scorecard">Project Scorecard</a></li>
	<li><A href="/help_files/manual/projects/summary.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Summary">Project Summary</a></li>
	<li><A href="/help_files/manual/projects/details.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Detail">Project Detail</a></li>
	<li><A href="/help_files/manual/projects/new.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Create Project">Create or Edit Project</a></li>
	<li><A href="/help_files/manual/projects/search.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Search Projects">Search Projects</a></li>
	<p>
	<b>Miscellaneous Functions:</b>
	<br>
	<li><A href="/help_files/manual/todo/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="To Do List">To Do List</a></li>
	<li><A href="/help_files/manual/xmessenger.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="To Do List">XMessenger</A></li>
	</ul>
	
	
	</td></tr></table>
	</TD>
  </TR>
</TABLE>

</div>

<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
