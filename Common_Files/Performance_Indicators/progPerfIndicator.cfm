<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset pageTitle = "Program Performance Indicators">
<cfif isDefined("sErr")>
		<BR>
		<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
			<TR BGCOLOR="White">
				<TD>		
					<CFOUTPUT><FONT SIZE="2"><B>Update failed. Some of the fields are either missing or invalid.</B></FONT></CFOUTPUT>
				</TD>
			</TR>
		</TABLE>
<cfelseif isDefined("URL.action")>
	<BR>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
			<TD><CFOUTPUT><FONT SIZE="2"><B>The report was <cfif URL.action EQ "edit">edited<cfelse>added</cfif> sucessfully.</B></FONT></CFOUTPUT></TD>
		</TR>
	</TABLE>
</cfif>
<BR>
<html>
<head>
	<title><cfoutput>#pageTitle#</cfoutput></title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<!--- background-color:F5F5F5;
			color: 006400; contract:006600--->
	<CF_MessageWindow>
	<CFIF isDefined("sErr")>
		<SCRIPT LANGUAGE="JavaScript">
			showError();		
		</SCRIPT>
	</CFIF>
</head>
<cfif Not isDefined("scheduleFlag")>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
</SPAN>
<CFFLUSH>
</cfif>
<body>
	<cfoutput>
	<cfif Not isDefined("scheduleFlag")>
		<CFINCLUDE TEMPLATE="/includes/header.cfm">
		<CFIF NOT IsDefined("reportInclude")>
			<CFINCLUDE TEMPLATE="/ReportWriter/reportInclude.cfm">
		</CFIF>
	</cfif>
	<cfparam name="Form.Sort_By" 	default="Contract_Number">
	<cfparam name="Form.Sort_Order" 	default="ASC">
	<cfif Not isDefined("scheduleFlag")>
		<cfinclude template="/get_access_profile.cfm">
	</cfif>
	<CFSET cmpHandle = CreateObject("component", "components.programs.performance_indicator.perfIndicator") />
	<cfset perfIndicPrograms = cmpHandle.getProgramsForPerfIndicator(Form.Sort_By, Form.Sort_Order) /> 
	<cfset cmpHandle.setBasicPrograms() />
	<cfset cmpHandle.setProgramsVolume() />
	<cfset cmpHandle.setActualProgramsVolume() />
	<cfset cmpHandle.setProgramCompanyID(request.AccessStructure.Company_Main_ID) />
	<cfset cmpHandle.setDefaultUOM() />
	<cfset cmpHandle.setProgramsClaims() />
		<cfsavecontent variable="reportOutput">
			<style>
				.header
				{
					background-color:FF7F50;
					color: white;
					font-size:14;
					font-weight:bold;
				}
				
				.headerWithBigFont
				{
					background-color:gray;
					color: white;
					font-size:16;
					font-weight:bold;
				}
				
				.headerWithBgColor
				{
					color: gray;
					font-size:12;
					font-weight:bold;
				}
				
				.contractInfo
				{
					background-color:white;
					color: black;
					font-size:12;
					font-weight:bold;
				}
				.contractInfoWithNoBold
				{
					background-color:white;
					color: black;
					font-size:10;
				}
				.VolPercentageInfo
				{
					background-color:white;
					color: black;
					font-size:12;
					font-weight:bold;
					text-align:center;
				}
				.TimePercentageInfo
				{
					background-color:white;
					color: black;
					font-size:12;
					font-weight:bold;
					text-align:center;
				}
				.IndexPercentageInfo
				{
					background-color:White;
					color: Red;
					font-size:12;
					font-weight:bold;
					text-align:center;
				}
				.rpthHeader
				{
					background-color:gray;
					color: white;
					font-size:12;
				}
			</style>
			<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
			<form name="perfIndForm" id="perfIndForm" method="post">
				<!--- handle for Criteria --->
				<cfif Not isDefined("scheduleFlag")>
					<cfparam name="bTitle" 		default="Volume Criteria">
					<cfparam name="showClosed" 	default="Yes">
					<CF_openLayer
						Border="yes"
						BorderSize="1"  
						BorderColor="orange"  
						Image="/images/plus2.gif"
						ImageOpen="/images/minus2.gif"
						Title="#bTitle#"  
						TitleClosed="#bTitle#"  
						TitleTooltip="#bTitle#"  
						TitleFont="font"  
						TitleColor="Blue"  
						TitleSize="9"  
						IsClosed="#showClosed#"  
						Width="85%">
						<CFINCLUDE TEMPLATE="PerfIndicatorVolCriteria.cfm">		
					</CF_openLayer>
				</cfif>
				<div align="left">
				<Table height="25" width="85%" border="0px outset gray" >
				<tr><td align="center" colspan="2" class="headerWithBigFont"><strong>Program Performance Report</strong></td></tr>
				<tr bgcolor="FF7F50">
					<td class="rpthHeader" align="left" nowrap>The report includes:<BR>							
						program templates selected by the administrator<BR>							
						programs with a status of pre-active, active, expiring or expired 							
					</td>
					<td align="right" valign="middle" class="rpthHeader" nowrap>Report Run Date: #DateFormat(now(), "mm/dd/yy")#</td>
				</tr>
				</Table>
				<Table id="oVolTable" border="0" cellpadding="1" cellspacing="1" BGCOLOR="B0C4DE" WIDTH="85%" datapagesize="50">
					<TR align="center">
						<TD width="5%" class="header" nowrap>Performance<BR>Index</TD>
						<cfset formName = "frmSort">
						<cfset sortByList = "">
						<cfset sortByList = ListAppend(sortByList, "Program:Contract_Number", ",")>
						<cfif Not isDefined("scheduleFlag")>
							<CF_Sort_Column_Headers
									formName  = "#formName#"
									sortByFieldName = "sort_by"
									sortOrderFieldName = "sort_order"
									currentSortBy = "#form.sort_by#"
									currentSortOrder = "#form.sort_order#"
									sortByList = "#sortByList#"
									TDExtraStyle = " width=""70%"" class=""header"""
									>
						<cfelse>
							<TD width="70%" class="header">Program</TD>
						</cfif>
						<TD width="20%" class="header">Volume (<cfif cmpHandle.getDefaultUOM() EQ 1>Pounds<cfelse>Cases</cfif>)</TD>
						<TD width="5%" class="header">Time </TD>
					</TR>
					<cfloop query="perfIndicPrograms">
						<cfset cmpHandle.setThisProgram(Contract_Number) /> 
						<!--- check if display the records --->
						<cfif cmpHandle.isOperatorProgram() EQ true and ( cmpHandle.getExpiredDays() LT cmpHandle.getMinimalProgramClaim().min_days or cmpHandle.getProgramClaim() LT cmpHandle.getMinimalProgramClaim().min_claims) >
						<!--- do nothing --->
						<cfelse>
						<tr>
							<td NOWRAP class="IndexPercentageInfo" valign="middle">
								#cmpHandle.getPerformanceIndex(cmpHandle.getVolumePercentage(), cmpHandle.getTimePercentage())#%
							</td>
							<Td class="contractInfo" nowrap title="#cmpHandle.getContractTitle()#">
								<cfset maxTitleLength = 60 >
								#Left(cmpHandle.getContractTitle(), maxTitleLength)#
								<cfif len(cmpHandle.getContractTitle()) GT maxTitleLength >...</cfif>
								<BR>
								<span style="background-color:white;color: black;font-size:10;">#trim(Contract_Number)#   ( #trim(programSpan)# )</span>
							</td>
							<td class="VolPercentageInfo" nowrap >
								<strong>#cmpHandle.getVolumePercentage()#</strong>%<BR>
								<span style="background-color:white;color: black;font-size:10;">#round(cmpHandle.getProgramVolume())# ( Target ) &nbsp;&nbsp; #round(cmpHandle.getCurrProgramVolume())# ( Actual )</span>
							</td>
							<td NOWRAP class="TimePercentageInfo" valign="middle">
								#cmpHandle.getTimePercentage()#%
							</td>
						</tr> 
						</cfif>
					</cfloop> 
				</table>
				</div>
			</cfsavecontent>
			<cfinclude template="progPerfIndicatorScheduleJobs.cfm">
		</form>			
		<form name="#formName#" action="progPerfIndicator.cfm" method="post">
			<input type="Hidden" name="sort_by" value="#Form.Sort_By#">
			<input type="Hidden" name="sort_order" value="#Form.Sort_Order#">
		</form>
		<cfif Not isDefined("scheduleFlag")>			
		<SCRIPT LANGUAGE="JavaScript">
			document.all.PleaseWaitMessage.style.display='none';
		</SCRIPT>
		<cfflush>
		</cfif>
	</cfoutput>
	<!--- handle for the nightly schedule job --->
	<SCRIPT LANGUAGE="JavaScript">
		findselectboxes();
	</SCRIPT>
</body>
</html>
