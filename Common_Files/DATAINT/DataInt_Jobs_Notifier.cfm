<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
	<CFINCLUDE TEMPLATE="/Vantage_DataSource.cfm">
<html>
<head>
<CFPARAM NAME="m" DEFAULT="#datepart("m",now())#">
<CFPARAM NAME="d" DEFAULT="#datepart("d",now())#">
<CFPARAM NAME="y" DEFAULT="#datepart("yyyy",now())#">

<!--- <cfparam name="num" default="1"> --->
<cfparam name="ymd" default="#dateFormat(CreateDate(y, m, d),"ddd. mmmm d, yyyy")#">

</head>

<cfquery name="qGetAlertEmails" datasource="#application.datasource#">
Select Send_Job_Status_Email
From general_Settings
</cfquery>

<cfset elist = qGetAlertEmails.Send_Job_Status_Email>

<body>
<cfquery datasource="#application.datasource#" name="qFailedJobs">

		DECLARE @dbname varchar(35)

    SET @dbname = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)

		SELECT    jh.job_id, 
			name as Job_name, 
			jh.instance_id, 
			LEFT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2)+ 
 				SUBSTRING(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),3,2)+ 
 				RIGHT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) as run_time, 
			ISNULL(CAST(IsInbox AS int), 3)  as IsInbox, 
			run_date, 
			message,
			isnull(send_alert,1) as send_alert,
			jh.run_status, 
			Action_To_Take_On_Error

			FROM    msdb.dbo.sysjobs j    
			inner join  Data_integration_Jobs DIJ on dij.job_name = j.name
			inner Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
			-- left Outer Join DataInt_Alerts_Log dl on dl.sysjob_id = jh.job_id
		WHERE	-- jh.run_date = 20050104  <!--- #rd# testing --->
			-- and 
			step_id = 0
			and isnull(send_alert,1) = 1
			and isnull(alert_time,1) > 0
			and j.name LIKE '%' + @DBName + '%'
			and not exists
            (select top 1 Instance_id from DataInt_Alerts_Log dl where dl.Instance_id = jh.instance_id and type = 'F')
		order by jh.run_status,jh.instance_id
</cfquery>

<CFSET EmailDetailsFailure = "">
<CFSET EmailDetailsSuccess = "">
<CFSET Job_Failure = 0>
<CFSET Job_Success = 0>

<cfoutput query="qFailedJobs">
	      
	 <cfset useLakebaseForQGetIntra = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_jobs")>
	 <cfif useLakebaseForQGetIntra>
		 <cftry>
			 <cfset qGetIntra = application.oLakebase.toQuery(
				 application.oLakebase.selectRows("data_integration_jobs", {
					 "job_name" = "eq.#qFailedJobs.Job_name#",
					 "select" = "intra_id",
					 "order" = "intra_id.asc",
					 "limit" = "1"
				 })
			 )>
			 <cfcatch type="any">
				 <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				 <cfset useLakebaseForQGetIntra = false>
			 </cfcatch>
		 </cftry>
	 </cfif>
	 <cfif NOT useLakebaseForQGetIntra>
		 <cfquery datasource="#application.datasource#" name="qGetIntra">
				SELECT     top 1 intra_id
				FROM         Data_integration_Jobs DIJ
				WHERE	Job_name = '#qFailedJobs.Job_name#'
				order by intra_id asc
		</cfquery>
	 </cfif>

	<!--- <cfif qGetAlertEmails.recordcount gt 0> --->
		<cfset useLakebaseForQInsertLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dataint_alerts_log")>
		<cfif useLakebaseForQInsertLog>
			<cftry>
				<cfset application.oLakebase.insertRow("dataint_alerts_log", {
					"instance_id" = qFailedJobs.instance_id,
					"sent_time" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"elist" = trim(left(elist,1999)),
					"type" = "F"
				})>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForQInsertLog = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForQInsertLog>
			<cfquery name="qInsertLog" datasource="#application.datasource#">
			 Insert into DataInt_Alerts_Log
			 	(instance_id, sent_time, elist, type)
				Values (#qFailedJobs.instance_id#, #now()#, '#trim(left(elist,1999))#' ,'F')
			</cfquery>
		</cfif>
	<!--- </cfif> --->
				#qFailedJobs.Job_name# Job  ::  Recipients -> #elist#<br><br>

	   
<cfif qGetAlertEmails.recordcount gt 0> 

			 <cfset num = (qFailedJobs.instance_id - 1)>
			 <cfif len(qFailedJobs.run_time) eq 5>
			 	<cfset rtime = CreateTime(left(qFailedJobs.run_time,1), mid(qFailedJobs.run_time,2,2), right(qFailedJobs.run_time,2))>
			 <cfelseif len(qFailedJobs.run_time) eq 6>
			 	<cfset rtime = CreateTime(left(qFailedJobs.run_time,2), mid(qFailedJobs.run_time,3,2), right(qFailedJobs.run_time,2))>
			 </cfif>
			<cfquery datasource="#application.datasource#" name="qFailedstep">
					SELECT      *
					FROM    msdb.dbo.sysjobhistory
					WHERE	instance_id = <cfqueryparam value="#num#">
			</cfquery> 

		<cfif qFailedJobs.currentrow neq 1 AND qFailedJobs.run_status EQ 0>					
					<CFSET EmailDetailsFailure = EmailDetailsFailure & "<br /><br />">
		</cfif>

		<cfif qFailedJobs.currentrow neq 1 AND qFailedJobs.run_status EQ 1>	
					<CFSET EmailDetailsSuccess = EmailDetailsSuccess & "<br /><br />">
		</cfif>

		<cfif qFailedJobs.run_status eq 0 and Job_Failure eq 0>
			<CFSET EmailDetailsFailure = EmailDetailsFailure & "JOB FAILURES<br /><br />">
			<CFSET Job_Failure = 1>
		</cfif>

		<cfif qFailedJobs.run_status eq 1 and Job_Success eq 0>
			<CFSET EmailDetailsSuccess  = EmailDetailsSuccess & "<br /><br />JOB SUCCESSES<br /><br />">
			<CFSET Job_Success = 1>
		</cfif>

		<cfif qFailedJobs.run_status eq 0>
			<CFSET EmailDetailsFailure = EmailDetailsFailure & "Job - #job_name#<br />">
			
			<CFSET  EmailDetailsFailure= EmailDetailsFailure & "In/Out/Maintenance - ">

			<cfif qFailedJobs.isinbox eq 1>

			<CFSET  EmailDetailsFailure= EmailDetailsFailure & "#cgi.HTTP_HOST# In">
			
			<cfelseif qFailedJobs.isinbox eq 0>
			
			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "#cgi.HTTP_HOST# Out">

			<cfelse>

			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "Maintenance">

			</cfif>
			
			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "<br />"> 

			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "Run Date - #dateFormat(CreateDate(left(run_date,4), mid(run_date,5,2), right(run_date,2)),'ddd. mmmm d, yyyy')# #TimeFormat(rTime, 'h:mm:ss tt')#<br />"> 

			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "Last Step - #qFailedstep.step_name#<br /> ">

			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "Outcome - #message#<br />">
			
			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "Last Step Outcome - #qFailedstep.message#<br />">

			<CFSET  EmailDetailsFailure = EmailDetailsFailure & "Actions: - #Action_To_Take_On_Error#">

		<cfelse>

			<CFSET EmailDetailsSuccess = EmailDetailsSuccess & "Job - #job_name#<br />">
			
			<CFSET  EmailDetailsSuccess= EmailDetailsSuccess & "In/Out/Maintenance - ">

			<cfif qFailedJobs.isinbox eq 1>

			<CFSET  EmailDetailsSuccess= EmailDetailsSuccess & "#cgi.HTTP_HOST# In">
			
			<cfelseif qFailedJobs.isinbox eq 0>
			
			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "#cgi.HTTP_HOST# Out">

			<cfelse>

			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "Maintenance">

			</cfif>
			
			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "<br />"> 

			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "Run Date - #dateFormat(CreateDate(left(run_date,4), mid(run_date,5,2), right(run_date,2)),'ddd. mmmm d, yyyy')# #TimeFormat(rTime, 'h:mm:ss tt')#<br />"> 

			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "Last Step - #qFailedstep.step_name#<br /> ">

			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "Outcome - #message#<br />">
			
			<CFSET  EmailDetailsSuccess = EmailDetailsSuccess & "Last Step Outcome - #qFailedstep.message#<br />">

			</cfif>

		 </cfif><!--- if emails...recordcount --->
	 </cfoutput> 


<cfif appsettings.getIsVantageOn() eq 1>

<CFSET Job_Failure_Vantage = 0>
<CFSET Job_Success_Vantage = 0>
<CFSET EmailDetailsVantageFailure = "">
<CFSET EmailDetailsVantageSuccess = "">

	 <cfquery datasource="#VantageDatasource#" name="qFailedJobs">
	 	DECLARE @dbname varchar(35)

    SET @dbname = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)

		SELECT    jh.job_id, 
			name as Job_name, 
			jh.instance_id, 
			LEFT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2)+ 
 			SUBSTRING(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),3,2)+ 
 			RIGHT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) as run_time, 
			run_date, 
			message,
			jh.run_status, 
			Action_To_Take_On_Error

			FROM    msdb.dbo.sysjobs j    
			Inner Join  Data_integration_Jobs DIJ on dij.job_name = j.name
			Inner Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
			-- left Outer Join DataInt_Alerts_Log dl on dl.sysjob_id = jh.job_id
		WHERE	-- jh.run_date = 20050104  <!--- #rd# testing --->
			-- and 
			step_id = 0
			and j.name LIKE '%' + @DBName + '%'
			and not exists
            (select top 1 Instance_id from DataInt_Alerts_Log dl where dl.Instance_id = jh.instance_id and type = 'F')
		order by jh.run_status,jh.instance_id
	 	 </cfquery>

<cfoutput query="qFailedJobs">
	      
	 <cfquery datasource="#VantageDatasource#" name="qGetIntra">
			SELECT     top 1 intra_id
			FROM         Data_integration_Jobs DIJ
			WHERE	Job_name = '#qFailedJobs.Job_name#'
			order by intra_id asc
	</cfquery>

	<!--- <cfif qGetAlertEmails.recordcount gt 0> --->
		<cfquery name="qInsertLog" datasource="#VantageDatasource#">
		 Insert into DataInt_Alerts_Log
		 	(instance_id, sent_time, elist, type)
			Values (#qFailedJobs.instance_id#, #now()#, '#trim(left(elist,1999))#' ,'F')
		</cfquery>
	<!--- </cfif> --->
		#qFailedJobs.Job_name# Job  ::  Recipients -> <cfoutput>#elist#</cfoutput>#chr(13)##chr(10)#
	   
		<cfif qFailedJobs.recordcount neq 0>  
			 <cfset num = (qFailedJobs.instance_id - 1)>
			 <cfif len(qFailedJobs.run_time) eq 5>
			 	<cfset rtime = CreateTime(left(qFailedJobs.run_time,1), mid(qFailedJobs.run_time,2,2), right(qFailedJobs.run_time,2))>
			 <cfelseif len(qFailedJobs.run_time) eq 6>
			 	<cfset rtime = CreateTime(left(qFailedJobs.run_time,2), mid(qFailedJobs.run_time,3,2), right(qFailedJobs.run_time,2))>
			 </cfif>
			<cfquery datasource="#VantageDatasource#" name="qFailedstep">
					SELECT      *
					FROM    msdb.dbo.sysjobhistory
					WHERE	instance_id = <cfqueryparam value="#num#">
			</cfquery> 


		<cfif qFailedJobs.run_status eq 0 and Job_Failure eq 0>
			<CFSET Job_Failure = 1>
		</cfif>

		<cfif qFailedJobs.run_status eq 1 and Job_Success eq 0>
			<CFSET Job_Success = 1>
		</cfif>

		<cfif qFailedJobs.run_status eq 0>
			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "<br /><br />">

			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Job - #job_name#<br />">
			
			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Report - Vantage<br />">

			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Run Date - #dateFormat(CreateDate(left(run_date,4), mid(run_date,5,2), right(run_date,2)),'ddd. mmmm d, yyyy')# #TimeFormat(rTime, 'h:mm:ss tt')#<br />"> 

			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Last Step - #qFailedstep.step_name#<br /> ">

			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Outcome - #message#<br />">
			
			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Last Step Outcome - #qFailedstep.message#<br />">

			<CFSET EmailDetailsVantageFailure = EmailDetailsVantageFailure & "Actions - #Action_To_Take_On_Error#">

		<cfelse>

			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "<br /><br />">

			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "Job - #job_name#<br />">
			
			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "Report - Vantage<br />">

			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "Run Date - #dateFormat(CreateDate(left(run_date,4), mid(run_date,5,2), right(run_date,2)),'ddd. mmmm d, yyyy')# #TimeFormat(rTime, 'h:mm:ss tt')#<br />"> 

			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "Last Step - #qFailedstep.step_name#<br /> ">

			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "Outcome - #message#<br />">
			
			<CFSET EmailDetailsVantageSuccess = EmailDetailsVantageSuccess & "Last Step Outcome - #qFailedstep.message#<br />">

		</cfif>
		 </cfif><!--- if emails...recordcount --->
	 </cfoutput> 

</cfif>
<cfoutput>

<cfif EmailDetailsSuccess neq "" OR EmailDetailsVantageSuccess neq "" 
OR EmailDetailsFailure neq "" OR EmailDetailsVantageFailure neq "">

		 <CF_EMAILWRAPPER TO		=	"#elist#"
			        FROM		=	"#Contact_Admin_Email_Address#"
			        SUBJECT		=	"#cgi.HTTP_HOST# Integration Status"
					messagetype="1" 
					generatedby="1" 
					apparea="3" >

		Integration Status ::  Today is #ymd#<br /><br />

		#EmailDetailsFailure#
		<cfif EmailDetailsVantageFailure neq "">
		#EmailDetailsVantageFailure#
		</cfif>
		#EmailDetailsSuccess#
		<cfif EmailDetailsVantageSuccess neq "">
		#EmailDetailsVantageSuccess#
		</cfif>
		 </CF_EMAILWRAPPER>

</cfif></cfoutput>
 !!!!!!!!<br>
</body>
</html>