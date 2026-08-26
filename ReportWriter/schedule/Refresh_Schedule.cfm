<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Refresh Schedules</title>
</head>

<body>

<CFSET PREFIX = "#Replace(CGI.SERVER_NAME, ".", "_", "ALL")#_">
<!--- <cfset thisPath="#GetDirectoryFromPath(ExpandPath("schedule/saveReports/"))#"> --->
<cfset thisPath="#Application.Doc_Path#\data_files\created\reportwriter\schedule\saveReports\">


<CFQUERY NAME="Get_InActive_Schedules" DATASOURCE="#application.datasource#">
	SELECT 	Report_Type.Report_Type_ID,
			Report_Type.Report_Type,
			Report_Template.Report_Name,
			Report_Template.Report_StartDate,
			Report_Template.Report_EndDate,
			Report_Template.Report_StartTime,
			Report_Template.Report_Interval
		FROM	Report_Type ,Report_Template
		WHERE	Report_Type.Report_Type_ID = Report_Template.Report_Type_ID
			AND
			(
				(Report_Template.Report_EndDate IS NULL AND DATEDIFF(d, GetDate(), Report_Template.Report_StartDate) < 0)
				OR
				DATEDIFF(d, GetDate(), Report_Template.Report_EndDate) < 0
			)
			
</CFQUERY>

<CFOUTPUT QUERY="Get_InActive_Schedules">
	Delete task #PREFIX##Report_Type##Report_Type_ID#<BR><BR>
	<cfschedule action = "delete"
		task = "#PREFIX##Report_Type##Report_Type_ID#">
</CFOUTPUT>


<CFQUERY NAME="Get_Active_Schedules" DATASOURCE="#application.datasource#">
	SELECT 	Report_Type.Report_Type_ID,
			Report_Type.Report_Type,
			Report_Template.Report_Name,
			Report_Template.Report_StartDate,
			Report_Template.Report_EndDate,
			Report_Template.Report_StartTime,
			Report_Template.Report_Interval
		FROM	Report_Type ,Report_Template
		WHERE	Report_Type.Report_Type_ID = Report_Template.Report_Type_ID
			AND
			(
				(Report_Template.Report_EndDate IS NULL AND DATEDIFF(d, GetDate(), Report_Template.Report_StartDate) >= 0)
				OR
				DATEDIFF(d, GetDate(), Report_Template.Report_EndDate) >= 0
			)
			
</CFQUERY>


<CFOUTPUT QUERY="Get_Active_Schedules">
	Update task #PREFIX##Report_Type##Report_Type_ID#<BR><BR>
	<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/ReportWriter/schedule/schReport.cfm?rID=#Report_Type_ID#">	
	<!---
		D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
		Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
		"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
	--->
	<cfschedule action = "update"
		  task = "#PREFIX##Report_Type##Report_Type_ID#" 
		  operation = "HTTPRequest"
		  url = "#scURL#"
		  startDate = "#Report_StartDate#"
		  enddate = "#Report_EndDate#"
		  startTime = "#Report_StartTime#"
		  interval = "#Report_Interval#"
		  resolveURL = "Yes"
		  publish = "Yes"
		  file = "scReport#Report_Type_ID#.log"	<!--- D57544 --->
		  path = "#thisPath#"
		  requestTimeOut = "600">
</CFOUTPUT>

</body>
</html>
