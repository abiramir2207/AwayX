<cfparam name="url.report_id" default="">
<cfparam name="StartDate" default="">
<cfparam name="EndDate" default="">
<cfparam name="EmailAddress" default="">
<cfparam name="ReportName" default="">
<cfparam name="Interval" default="">
<cfparam name="StartTime" default="">
<cfparam name="reportschedulepath" default="">


<cfif url.report_id NEQ "">
<cfset useLakebaseForgetReportDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("management_report_details")>
<cfif useLakebaseForgetReportDetails>
	<cftry>
		<cfset getReportDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("management_report_details", {
				"report_id" = "eq.#url.report_id#",
				"deleted" = "eq.0",
				"select" = "report_name,report_interval,report_start_date,report_end_date,report_start_time,report_users_email,report_path,report_schedule_path"
			}), "report_name,report_interval,report_start_date,report_end_date,report_start_time,report_users_email,report_path,report_schedule_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetReportDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetReportDetails>
<cfquery name="getReportDetails" datasource="#application.datasource#">
select 
Report_Name,Report_Interval,Report_Start_Date,Report_End_Date,Report_Start_Time,
Report_Users_Email,report_path,report_schedule_path
from management_report_details
where report_id = #url.report_id#
and deleted = 0
</cfquery>
</cfif>

<cfset StartDate = getReportDetails.Report_Start_Date>
<cfset EndDate = getReportDetails.Report_End_Date>
<cfset EmailAddress = getReportDetails.Report_Users_Email>
<cfset ReportName = getReportDetails.Report_Name>
<CFSET Interval = getReportDetails.Report_Interval>
<CFSET starttime = getReportDetails.Report_Start_Time>
<CFSET reportpath = getReportDetails.report_path>
<CFSET reportschedulepath = getReportDetails.report_schedule_path>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CF_schedule_report
	rvStartDate="#StartDate#" 
	rvEndDate="#EndDate#" 
	starttime="#starttime#"
	rEmailAddress="#EmailAddress#" 
	rName="#ReportName#"
	rInterval="#Interval#"
	actionpage="save_management_report.cfm"
	report_id = "#url.report_id#"
	report_schedule_path= "#reportschedulepath#">
<cfelse>
<div align="center">Data insufficient.</div>
</cfif>