<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<CFPARAM NAME="m" DEFAULT="#datepart("m",now())#">
<CFPARAM NAME="d" DEFAULT="#datepart("d",now())#">
<CFPARAM NAME="y" DEFAULT="#datepart("yyyy",now())#">

<!--- <cfparam name="num" default="1"> --->
<cfparam name="ymd" default="#dateFormat(CreateDate(y, m, d),"ddd. mmmm d, yyyy")#">
	<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

</head>
Missed Start *********<br>
<cfparam name="ymd" default="#dateFormat(now(),"ddd. mmmm d, yyyy")#">
	<title>Last Data Integration Job Run  ::  <cfoutput>#ymd# #TimeFormat(now(), 'h:mm:ss tt')#</cfoutput></title>
</head>

<body>

<cfquery name="qGetAlertEmails" datasource="#application.datasource#">
Select Send_Job_Status_Email
From general_Settings
</cfquery>

<cfset elist = qGetAlertEmails.Send_Job_Status_Email>

<CFSET EmailDetails = "">

<cfquery datasource="#application.datasource#" name="qAllJobs">

		DECLARE @dbname varchar(35)

    SET @dbname = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)

		SELECT     distinct dij.job_name, isInbox, intra_id, jh.run_status --, j.job_id, max(instance_id)
		FROM         Data_integration_Jobs DIJ
			Join msdb.dbo.sysjobs j on dij.job_name = j.name
			Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
			where 
			-- jh.run_date = 20050104  <!--- #rd# testing --->
			--and 
			step_id = 0
			and run_status = 1
			and send_alert = 1
			and alert_time > 0
			and j.name LIKE '%' + @DBName + '%'
			--and not exists
           --(select top 1 Instance_id from DataInt_Alerts_Log dl where dl.Instance_id = jh.instance_id)
		order by jh.run_status
</cfquery>

<CFSET EmailDetails = "">	
<cfif qAllJobs.recordcount gt 0>
		<cfset i = 1>
			<cfloop query="qAllJobs">
			   <cfset Send = "no">
				<cfquery datasource="#application.datasource#" name="qGetInstance">
						DECLARE @dbname varchar(35)

						SET @dbname = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)

						SELECT     top 1 jh.instance_id,
							j.job_id, js.freq_type, 
							js.freq_interval, 
							jh.run_date, 
							LEFT(RIGHT('000000' + CAST(jh.run_time AS VARCHAR(10)),6),2)+ 
 								SUBSTRING(RIGHT('000000' + CAST(jh.run_time AS VARCHAR(10)),6),3,2)+ 
 								RIGHT(RIGHT('000000' + CAST(run_time AS VARCHAR(10)),6),2) as run_time,
							js.active_start_time, 
							send_alert, 
							alert_time,
							Action_To_Take_On_Error
						FROM         Data_integration_Jobs DIJ
							Join msdb.dbo.sysjobs j on dij.job_name = j.name
							Join msdb.dbo.sysjobhistory jh on jh.job_id = j.job_id
							Join msdb.dbo.sysjobschedules sjs on sjs.job_id = j.job_id
              join msdb.dbo.sysschedules js on js.schedule_id = sjs.schedule_id				                       
						where 
						-- jh.run_date = 20050104  <!--- #rd# testing --->
						-- and 
						step_id = 0
						--and run_status = 1
						and intra_id = <cfoutput>#qAllJobs.intra_id#</cfoutput>
						and j.name LIKE '%' + @DBName + '%'
						and not exists
			         (select top 1 Instance_id from DataInt_Alerts_Log dl where dl.Instance_id = jh.instance_id and Type = 'S')
					    and instance_id = (select max(instance_id) FROM         Data_integration_Jobs DIJ2
																					Join msdb.dbo.sysjobs j2 on dij2.job_name = j2.name
																					Join msdb.dbo.sysjobhistory jh2 on jh2.job_id = j2.job_id
																					where intra_id = <cfoutput>#qAllJobs.intra_id#</cfoutput>)
					  group by jh.instance_id,j.job_id, js.freq_type, js.freq_interval, jh.run_date, jh.run_time, js.active_start_time, send_alert, alert_time, jh.run_status, Action_To_Take_On_Error
					  order by jh.run_status, jh.instance_id desc
				</cfquery>


    ^^^^^^^^^^^^^^^^^^^^^<cfoutput>#qAllJobs.intra_id#  @@ #qGetInstance.freq_type#  ** </cfoutput>^^^^^^^^^^^^^^^^^^^^
		<cfset AlertTime = qGetInstance.alert_time>
			<cfif qGetInstance.freq_type eq 8>  <!--- this is a "weekly" schedule --->
			 <!---   Build run date and run time values from integer field in DB --->
				<cfif len(qGetInstance.run_time) eq 5>
				<cfset rtime1 = CreateTime(left(qGetInstance.run_time,1), mid(qGetInstance.run_time,2,2), right(qGetInstance.run_time,2))>
			  <cfelse>
				<cfset rtime1 = CreateTime(left(qGetInstance.run_time,2), mid(qGetInstance.run_time,3,2), right(qGetInstance.run_time,2))>
			  </cfif>
			  <cfset rdate1 = CreateDate(left(qGetInstance.run_date,4), mid(qGetInstance.run_date,5,2), right(qGetInstance.run_date,2))>
			     <!--- the whole dealio --->
			  <cfset rTime = "#dateformat(rdate1)# #timeformat(rtime1)#">
			  
			  <cfset nowT = "#dateformat(now())# #timeformat(now())#">
			  <cfoutput>#qGetInstance.active_start_time#</cfoutput>
			  <cfif len(qGetInstance.active_start_time) eq 5>
			    <cfset h = left(qGetInstance.active_start_time,1)>
				<cfset m = mid(qGetInstance.active_start_time,2,2)>
			  <cfelse>
			    <cfset h = left(qGetInstance.active_start_time,2)>
				<cfset m = mid(qGetInstance.active_start_time,3,2)>
			  </cfif>
			  <cfset s = right(qGetInstance.active_start_time,2)>
			  <cfset x = CreateTime(h, m, s)>
			  
			  <cfset schedT = "#dateformat(now())# #timeformat(x)#">
			  
			  <cfset comp = DateCompare(nowT, schedT, "n")>
			  
			 <!--- <cfoutput> #comp# || #schedT# || #nowT# $!$  <br>RTime:  #rtime#  $!$|*| #x#</cfoutput> --->
			 
			 <cfif comp lt 1> <!--- Sched time is gt than now...see if it was scheduled yesterday--->
			 	  <cfset scheddt =  "#dateformat(now() - 1)# #timeformat(x)#">
				  <cfif DayOfWeek(now()) eq 1>
				     <cfset dayNum = 7>
				  <cfelse>
				     <cfset dayNum = DayOfWeek(now()) - 1>
				  </cfif>
			 <cfelse>  <!--- Sched time is lt now...see if scheduled today--->
			     <cfset dayNum = DayOfWeek(now())>
				 <cfset scheddt =  "#dateformat(now())# #timeformat(x)#">
			 </cfif>
				
					<cfquery name="qGetSched" datasource="#application.datasource#">
					    IF (#qGetInstance.freq_interval# & POWER(2, #dayNum# - 1) = POWER(2, #dayNum# - 1))
						  Begin
					        Select 1 as dNum
						  End
						Else 
							Begin
					          Select 0 as dNum
						     End 
					</cfquery>
					
						<cfif qGetSched.dNum gt 0><!--- it was scheduled...see if it ran --->
				        <cfset comp2 = DateDiff("n", rtime, scheddt)>
						<cfset comp3 = DateDiff("n", scheddt, now())> <!--- compare current time to scheduled time...current time must be outside buffer time in order to send alert --->
						<cfif (comp2 gt (AlertTime * 60)) and (comp3 gt (AlertTime * 60))><!--- comp2 is - if rtime is after the sched...as long as it ran ok... alert Time is buffer set in DataIntJobs table--->
							<cfset Send = "yes">
						<cfelse>
							<cfset Send = "no">no send..
						</cfif>
				        <cfoutput><br>^^comp2 -->  #comp2#  ::  comp3 --> #comp3#  **  <br>SchedT:  ^#DayOfWeekAsString(dayNum)#^#scheddt#</cfoutput>
				   <cfelse><!---  not scheduled...No alert --->
				        <cfset Send = "no"><br><cfoutput>NO SEND..Not sched #DayOfWeekAsString(dayNum)#****time:#schedT#</cfoutput>
				   </cfif>
			
			
			</cfif> 
  <cfif send eq "Yes" AND qGetInstance.Recordcount neq 0>
		<cfset useLakebaseForQInsertLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dataint_alerts_log")>
		<cfif useLakebaseForQInsertLog>
			<cftry>
				<cfset application.oLakebase.insertRow("dataint_alerts_log", {
					"instance_id" = qGetInstance.instance_id,
					"sent_time" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"elist" = trim(left(elist,1999)),
					"type" = "S"
				})>
				<cfcatch type="any">
					<cfset useLakebaseForQInsertLog = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForQInsertLog>
			<cfquery name="qInsertLog" datasource="#application.datasource#">
			 Insert into DataInt_Alerts_Log
			 	(instance_id, sent_time, elist, type)
				Values (#qGetInstance.instance_id#, #now()#, '#trim(left(elist,1999))#', 'S')
			</cfquery>
		</cfif>
  </cfif>
<cfif send eq "Yes" and trim(elist) neq "">
	<br><cfoutput>#qAllJobs.Job_name#</cfoutput> Overdue Job  ::  Recipients -> <cfoutput>#elist#  #send#</cfoutput><br>
	
				<cfquery datasource="#application.datasource#" name="qRunningJob">
						SELECT      max(instance_id) as instance_id
						FROM   msdb.dbo.sysjobhistory sh
						Join msdb.dbo.sysjobs j on sh.job_id = j.job_id
						where name = '#qAllJobs.job_name#'
				</cfquery>
				<cfset inst_id = "#qRunningJob.instance_id#">
				<cfquery datasource="#application.datasource#" name="qJobDetail">
						SELECT     *
						FROM   msdb.dbo.sysjobhistory sh
						Join msdb.dbo.sysjobs j on sh.job_id = j.job_id
						where instance_id  = #inst_id#
				</cfquery>
				<cfset num = (qJobDetail.instance_id - 1)>
				<cfquery datasource="#application.datasource#" name="qFailedstep">
					SELECT      step_name
					FROM    msdb.dbo.sysjobhistory
					WHERE	instance_id = <cfqueryparam value="#num#">
				</cfquery> 
				<cfset nextstep = qJobDetail.step_id + 1>
				<cfquery datasource="#application.datasource#" name="qRunStep">
					SELECT      j.step_name
					FROM   msdb.dbo.sysjobsteps j
						Join msdb.dbo.sysjobhistory sh on sh.job_id = j.job_id
					WHERE	instance_id = <cfqueryparam value="#inst_id#">
					and j.step_id = #nextstep#
				</cfquery>
				<cfset isinbox = qAllJobs.isinbox>
				<cfoutput query="qJobDetail">
						
						<!--- <cfif qJobDetail.run_date eq ""><cfset run_date = now()></cfif> --->
						 <cfif len(run_time) eq 5>
						 	<cfset rtime = CreateTime(left(qJobDetail.run_time,1), mid(qJobDetail.run_time,2,2), right(qJobDetail.run_time,2))>
						 <cfelse>
						 	<cfset rtime = CreateTime(left(qJobDetail.run_time,2), mid(qJobDetail.run_time,3,2), right(qJobDetail.run_time,2))>
						 </cfif>
						 <cfset rdate = CreateDate(left(qJobDetail.run_date,4), mid(qJobDetail.run_date,5,2), right(qJobDetail.run_date,2))>
						 <cfset rdatetime = "#dateformat(rdate)# #timeformat(rtime)#">

	<cfif qGetInstance.recordcount neq 0>

			<cfif qAllJobs.currentrow neq 1>
				<CFSET EmailDetails = EmailDetails & "<br /><br />">
			</cfif>
			
				<CFSET EmailDetails = EmailDetails & "Job - #qJobDetail.name#<br />">
						 
				<CFSET EmailDetails = EmailDetails & "In/Out/Maintenance -">	

				<cfif isinbox eq 1>

				<CFSET EmailDetails = EmailDetails & "#cgi.HTTP_HOST# In">

				<cfelseif isinbox eq 0>

				<CFSET EmailDetails = EmailDetails & "#cgi.HTTP_HOST# Out">

				<cfelse>
				
				<CFSET EmailDetails = EmailDetails & "Maintenance">

				</cfif>
				
				<CFSET EmailDetails = EmailDetails & "<br />">

				<CFSET EmailDetails = EmailDetails & "Last Run - #dateFormat(rdate,'ddd. mmmm d, yyyy')# #TimeFormat(rTime, 'h:mm:ss tt')#<br />">

				<CFSET EmailDetails = EmailDetails & "Outcome - #qJobDetail.message#<br />">

				<CFSET EmailDetails = EmailDetails & "Scheduled - #DayOfWeekAsString(dayNum)# #scheddt#<br />">

			<!--- If the job failed --->
			<cfif qAllJobs.run_status eq 0>
				<CFSET EmailDetails = EmailDetails & "Actions - #qGetInstance.Action_To_Take_On_Error#">
			</cfif>

		</cfif>
				</cfoutput>
				<cfset i = i +1>

	   </cfif> <!--- if send ok --->
		
		</cfloop>  

<cfif EmailDetails neq "">
<cfoutput>
	 <CF_EMAILWRAPPER TO		=	"#elist#"
		        FROM		=	"#Contact_Admin_Email_Address#"
		        SUBJECT		=	"#cgi.HTTP_HOST# Missed Schedule List"
				messagetype="1" 
				generatedby="1" 
				apparea="3" >

			Last Data Integration Job Run  ::  #ymd# #TimeFormat(now(), 'h:mm:ss tt')#<br /><br />

			#EmailDetails#

	</CF_EMAILWRAPPER>
</cfoutput>
</cfif>
<cfelse>
None sent
</cfif><!---  if Jobs recordcount --->

<br>Missed End *********
</body>
</html>
