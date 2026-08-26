<cfcomponent hint="Price Protection Manager" extends="components.Base">

	<cffunction name="saveScheduledJob" output="false">
	<cfargument name="formScope" required="true" type="struct" />
	<cfquery name="qsavejobsscheduled" datasource="#application.datasource#">
	Insert Into NOI_Month_End_Reports_Schedule
	(job_name,invoice_start_date,invoice_end_date,Job_scheduled_Date)
	values ('#arguments.formScope.monthend_report_job_name#','#dateformat(arguments.formScope.start_date,"mm/dd/yyyy")#','#dateformat(arguments.formScope.end_date,"mm/dd/yyyy")#','#dateformat(arguments.formScope.Schedule_Date,"mm/dd/yyyy")#')
	</cfquery>
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
	<cfquery name="qdeleteScheduledJob" datasource="#application.datasource#">
		update NOI_Month_End_Reports_Schedule
		set deleted = 1
		where NOI_Month_End_Reports_Schedule_id = #arguments.jobId#
	</cfquery>
	</cffunction>
	
</cfcomponent>