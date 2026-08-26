<cfparam name="StartDate" default="">
<cfparam name="EndDate" default="">
<cfparam name="EmailAddress" default="">
<cfparam name="ReportName" default="">
<cfparam name="Interval" default="">
<cfparam name="StartTime" default="">

<cfset rIntervals="Once,Daily,Weekly,Monthly">

<cfset useLakebaseForgetReportDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForgetReportDetails>
	<cftry>
		<cfset getReportDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "report_name,report_interval,report_start_date,report_end_date,report_start_time,send_report_to"
			}), "report_name,report_interval,report_start_date,report_end_date,report_start_time,send_report_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetReportDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetReportDetails>
<cfquery name="getReportDetails" datasource="#application.datasource#">
select 
Report_Name,Report_Interval,Report_Start_Date,Report_End_Date,
Report_Start_Time,Send_Report_To
from _application_settings
</cfquery>
</cfif>

<cfset StartDate = getReportDetails.Report_Start_Date>
<cfset EndDate = getReportDetails.Report_End_Date>
<cfset StartTime = getReportDetails.Report_Start_Time>
<cfset EmailAddress = getReportDetails.Send_Report_To>
<cfset ReportName = getReportDetails.Report_Name>
<CFSET Interval = getReportDetails.Report_Interval>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CF_schedule_report
	rvStartDate="#StartDate#" 
	rvEndDate="#EndDate#" 
	starttime="#starttime#"
	rEmailAddress="#EmailAddress#" 
	rName="#ReportName#"
	rInterval="#Interval#"
	actionpage="/anything_automated/email/save_RFA_schedule.cfm">
