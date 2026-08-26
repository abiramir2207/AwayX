<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
	.no_access
	{
		color:gray;
	}
	.subButton
	{
		font-size: 11px;
		WIDTH: 122px;
		background-color : transparent;
		color : blue;
		border-style : none none none none;
		font-weight : bold;
	}
	.subButtonOver
	{
		font-size: 11px;
		WIDTH: 122px;
		background-color : transparent;
		color : red;
		border-style : none none none none;
		font-weight : bold;
		text-decoration : underline;
		cursor:pointer;
	}
	</STYLE>
</HEAD>

<BODY>

<DIV STYLE="position: absolute; width: 100px; height: 510px; z-index: 1; left: 35px; top: 20px" ID="layer1">
	<IMG SRC="../Images/reports_main.gif" ALT="" WIDTH="64" HEIGHT="64" BORDER="0">
	<IMG SRC="../Images/reports_banner.gif" ALT="" WIDTH="64" HEIGHT="377" BORDER="0">
</DIV>

<DIV STYLE="position: absolute; width: 400px; height: 510px; z-index: 2; left: 120px; top: 20px" ID="layer2">

<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<div class="customContainer" style="display:none;width:800px"></div>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfparam name="url.maint" default="0">

<cfif Get_Profile_Settings.Reports_Access_Level GTE 4 and Url.maint eq 1><form method="post" name="RCAForm" action="RCAFormAction.cfm"></cfif>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

		<cfif Get_Profile_Settings.Reports_Access_Level GTE 4>
			<cfif Url.maint eq 0>
					<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="index_main.CFM?maint=1">Maintain Access Rights</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
			<cfelse>
					<FONT COLOR="Red" style="font-weight : bold; font-size: 12px;">[</FONT>&nbsp;<input type="Submit" value="Update Access Rights" name="submit" class="subbutton" onmouseover="this.className='subbuttonover'" onmouseout="this.className='subbutton'">&nbsp;<FONT COLOR="Red" style="font-weight : bold;font-size: 12px;">]</FONT>
			</cfif>
		</cfif>
<BR><BR>

<cfset RCA = CreateObject("component", "components.user.ReportsCentralAccess").init() />
<cfset RCA_GROUPS = RCA.getReportGroups()>

	<CFLOOP QUERY="RCA_GROUPS" STARTROW="1" ENDROW="3">
		<cfset Get_Report_List = RCA.getReports(RCA_GROUPS.GROUP_ID)>
		<cfif Get_Report_List.recordCount>
			<TABLE BORDER="0" WIDTH="100%" CELLPADDING="0" CELLSPACING="10">
				<TR>
					<TD style="border-right: 1px solid #000080;" VALIGN="top">
					<CFIF RCA_GROUPS.ICON_USED EQ "1" >
						<IMG SRC="<cfoutput>#rca_groups.group_icon#</cfoutput>" ALT="" BORDER="0">
					</CFIF></TD>
					<TD VALIGN="top" WIDTH="100%">
						<FONT SIZE="2"><B><cfoutput>#rca_groups.group_label#</cfoutput></B></FONT><br/>
						<CFLOOP query="Get_Report_List">
						    <!---D26247 2/9/2011 - ChrisN Skip Programs Approved Via Email if its setting is not enabled --->
						    <cfset variables.includeThisReport = true>
		                    <cfif FindNoCase("ProgramsApprovedViaEmail.cfm", Get_Report_List.Report_url)>
							   <cfif application.appSettingsGet.getApprovalViaEmail()>
		                            <cfset variables.includeThisReport = true>
							   <cfelse>
		                            <cfset variables.includeThisReport = false>
							   </cfif>
		                    </cfif>
							<cfif variables.includeThisReport>
		                        <cf_RALCaller reportID="#Get_Report_List.Report_ID#" RAC="#Get_Profile_Settings.Reports_Access_Level#"/><br/>
							</cfif>
						</CFLOOP>
					</TD>
				</TR>
			</TABLE>
			<BR><BR>
		</cfif>
	</CFLOOP>
</DIV>

<DIV STYLE="position: absolute; width: 400px; height: 510px; z-index: 2; left: 540px; top: 20px" ID="layer3">
	<div style="height:60px"></div>

	<CFLOOP QUERY="RCA_GROUPS" STARTROW="4" ENDROW="#RCA_GROUPS.RECORDCOUNT#">
		<cfset Get_Report_List = RCA.getReports(RCA_GROUPS.GROUP_ID)>
		<cfif Get_Report_List.recordCount>
			<TABLE BORDER="0" WIDTH="100%" CELLPADDING="0" CELLSPACING="10">
				<TR>
					<TD style="border-right: 1px solid #000080;" VALIGN="top">
					<CFIF RCA_GROUPS.ICON_USED EQ "1" >
						<IMG SRC="<cfoutput>#rca_groups.group_icon#</cfoutput>" ALT="" BORDER="0">
					</CFIF></TD>
					<TD VALIGN="top" WIDTH="100%">
						<FONT SIZE="2"><B><cfoutput>#rca_groups.group_label#</cfoutput></B></FONT><br/>

						<CFLOOP query="Get_Report_List">
							<cf_RALCaller reportID="#Get_Report_List.Report_ID#" RAC="#Get_Profile_Settings.Reports_Access_Level#"/><br/>
						</CFLOOP>
					</TD>
				</TR>
			</TABLE>
			<BR><BR>
		</cfif>
	</CFLOOP>

</DIV>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->
<SCRIPT language="JavaScript">
	function CellOn(CellName){
		eval("CellName.bgColor = '#4169E1'")
	}
	function CellOff(CellName){
		eval("CellName.bgColor = '#FFFFFF'")
	}
	function showrevisiondetails(contract_number,status){
		NewWindow('/reportwriter/performance_reports/revisionreport.cfm','ProgramRevisionDetails','1200','550','Yes', 'Yes')
	}
	function showoperators(){
		NewWindow('/Billbacks/search_screens/PM_select_operators.cfm?searchoperator=1','SearchOperators','850','550','Yes', 'Yes')
	}
</SCRIPT>

</BODY>
</HTML>
