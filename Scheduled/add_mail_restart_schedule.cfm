<!---
Name         : 		add_mail_restart_schedule.cfm
Copyright    : 		(c) 2005 Blacksmith Applications, Inc.
Created Date : 		03/13/2012
Created By   : 		Tim Ford
Description  : 		File used to add the CF mail restart scheduled task
Parameters   : 		N/A
Usage        : 		N/A
--->

<cfset url_domain = "http://#CGI.SERVER_NAME#" />
<!---
	D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
	Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
	"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
--->
<cfschedule action = "update"
    task = "Restart Mail Service (#CGI.SERVER_NAME#)" 
    operation = "HTTPRequest"
    url = "#url_domain#/scheduled/restart_mail_service.cfm"
    startDate = "#DateFormat(Now(), "mm/dd/yyyy")#"
    startTime = "07:00 AM"
		endtime="11:00 PM"
    interval = "14400"
    requestTimeOut = "600"
    resolveURL = "yes"
    publish = "yes"
    file = "restart_mail_service.log"	<!--- D57544 --->
    path = "#request.APPLICATIONPATH#\Scheduled\"> 
	