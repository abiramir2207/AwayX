<cfcomponent hint="Price Protection Manager" extends="components.Base">

	<cffunction name="saveScheduledJob" output="false">
	<cfargument name="formScope" required="true" type="struct" />
	<cfset useLakebaseForqsavejobsscheduled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("noi_month_end_reports_schedule")>
<cfif useLakebaseForqsavejobsscheduled>
	<cftry>
		<cfset application.oLakebase.insertRow("noi_month_end_reports_schedule", {
			"job_name" = "#arguments.formScope.monthend_report_job_name#",
			"invoice_start_date" = "#dateformat(arguments.formScope.start_date,"mm/dd/yyyy")#",
			"invoice_end_date" = "#dateformat(arguments.formScope.end_date,"mm/dd/yyyy")#",
			"job_scheduled_date" = "#dateformat(arguments.formScope.Schedule_Date,"mm/dd/yyyy")#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqsavejobsscheduled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqsavejobsscheduled>
<cfquery name="qsavejobsscheduled" datasource="#application.datasource#">
	Insert Into NOI_Month_End_Reports_Schedule
	(job_name,invoice_start_date,invoice_end_date,Job_scheduled_Date)
	values ('#arguments.formScope.monthend_report_job_name#','#dateformat(arguments.formScope.start_date,"mm/dd/yyyy")#','#dateformat(arguments.formScope.end_date,"mm/dd/yyyy")#','#dateformat(arguments.formScope.Schedule_Date,"mm/dd/yyyy")#')
	</cfquery>
</cfif>
	</cffunction>
	
	<cffunction name="checkifjobschedule" output="false" returntype="query">
	<cfquery name="qcheckifjobschedule" datasource="#application.datasource#">
	select * from
	NOI_Month_End_Reports_Schedule
	where Job_scheduled_Date = '#dateformat(now(), "mm/dd/yyyy")#'
	and deleted = 0
	and job_finished = 0
	</cfquery>
	<cfreturn qcheckifjobschedule>
	</cffunction>
	
	
	<cffunction name="getscheduledjobs" output="false" returntype="query">
	<cfquery name="qgetscheduledjobs" datasource="#application.datasource#">
	select * from
	NOI_Month_End_Reports_Schedule
	where Job_scheduled_Date >= #dateformat(now(), "mm/dd/yyyy")#
	and deleted = 0
	</cfquery>
	<cfreturn qgetscheduledjobs>
	</cffunction>
	
	<cffunction name="deleteScheduledJob" output="false">
	<cfargument name="JobId" required="true" type="numeric" />
	<cfset useLakebaseForqdeleteScheduledJob = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("noi_month_end_reports_schedule")>
<cfif useLakebaseForqdeleteScheduledJob>
	<cftry>
		<cfset application.oLakebase.updateRows("noi_month_end_reports_schedule",
			{
				"noi_month_end_reports_schedule_id" = "eq.#arguments.jobId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqdeleteScheduledJob = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqdeleteScheduledJob>
<cfquery name="qdeleteScheduledJob" datasource="#application.datasource#">
		update NOI_Month_End_Reports_Schedule
		set deleted = 1
		where NOI_Month_End_Reports_Schedule_id = #arguments.jobId#
	</cfquery>
</cfif>
	</cffunction>
	
</cfcomponent>