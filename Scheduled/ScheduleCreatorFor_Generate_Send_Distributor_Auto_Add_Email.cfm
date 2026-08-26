<!-----------------------------------------------------------------------------

FILE NAME: 		ScheduleCreatorFor_Generate_Send_Distributor_Auto_Add_Email.cfm
DESCRIPTION:	This file will create a scheduled task for the 
				Generate_sent_Distributor_Auto_Add_Email
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	12-Oct-2011	Added 

------------------------------------------------------------------------------> 



	<cfset StartDate = dateformat(now(), "mm/dd/yyyy")>
	<cfset addminutes = DateAdd("n", "10", now())>
	<cfset StartTime = TimeFormat(addminutes, "hh:mm:ss")>
	<cfset thisPath="#Application.Doc_Path#\data_files\created\Letters\Output\">
	<cfquery name="getDBName" datasource="#application.datasource#">
		DECLARE @dbName NVARCHAR(500)
		SET @dbName = (select TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES)
		SELECT @dbName AS DBName
	</cfquery>
	
		<cfschedule action = "update"
  		task = "#getDBName.DBName# - Distributors Auto Added to Programs" 
  		operation = "HTTPRequest"
  		url =	"#application.HTTPVar##CGI.HTTP_HOST#/scheduled/Generate_Send_Distributor_Auto_Add_Email.cfm"
  		startDate = "#StartDate#"
  		enddate = ""
  		startTime = "4:03 AM"
  		interval = "Daily"
  		requestTimeOut = "600"> 

<br>

*****************************************************************		
	Scheduled Task Created successfully!	
*****************************************************************		
	