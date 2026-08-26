<!-----------------------------------------------------------------------------

FILE NAME: 	ScheduleCreatorFor_WR_Scheduled_DailyJob_ForLevel3Client.cfm
DESCRIPTION:	update data in work_request table
				
------------------------------------------------------------------------------> 



	<cfset StartDate = dateformat(now(), "mm/dd/yyyy")>
	<cfset addminutes = DateAdd("n", "10", now())>
	<cfset StartTime = TimeFormat(addminutes, "hh:mm:ss")>
	
	<cfquery name="getDBName" datasource="#application.datasource#">
		DECLARE @dbName NVARCHAR(500)
		SET @dbName = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)
		SELECT @dbName AS DBName
	</cfquery>
	
		<cfschedule action = "update"
  		task = "#getDBName.DBName# - Update data for WR" 
  		operation = "HTTPRequest"
  		url =	"#application.HTTPVar##CGI.HTTP_HOST#/scheduled/WR_Scheduled_DailyJob_ForLevel3Client.cfm"
  		startDate = "#StartDate#"
  		enddate = ""
  		startTime = "10:12 AM"
  		interval = "Daily"
  		requestTimeOut = "600"> 

<br>

*****************************************************************		
	Scheduled Task :: <cfoutput>#getDBName.DBName#</cfoutput> - Update data for WR Created successfully!	
*****************************************************************		
	