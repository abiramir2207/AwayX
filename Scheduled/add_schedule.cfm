<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Scheduled\add_schedule.cfm
      Date:     June 2005
      Author:   Deepa
      Purpose:  Set up common scheduled tasks
----------------------------------------------------------------------------------------------------------------------->

<cfset url_domain = "#application.HTTPVar##CGI.SERVER_NAME#" />
<!---
	D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
	Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
	"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
--->
<cfschedule action = "update"
    task = "Nightly Scheduled Task (#CGI.SERVER_NAME#)" 
    operation = "HTTPRequest"
    url = "#url_domain#/scheduled/scheduled_tasks.cfm"
    startDate = "#DateFormat(Now(), "mm/dd/yyyy")#"
    startTime = "03:00 AM"
    interval = "Daily"
    resolveURL = "Yes"
    publish = "Yes"
    file = "scheduled_tasks.log"	<!--- D57544 --->
    path = "#application.stmvcAppinfo.applicationPath#\scheduled\"
    requestTimeOut = "600"> 

<!---- Claims Report for Heinz ---->
<cfif application.returned_customer_setting.Company_Name contains "Heinz">
	<cfschedule 
		action = "update"
		task = "Claims Report (#cgi.server_name#)"
		interval = "Daily" 
		operation = "HTTPRequest"
		startDate = "#DateFormat(Now(), "mm/dd/yyyy")#"
	  startTime = "02:00 AM"
	  url = "#url_domain#/scheduled/approved_billback_print.cfm?ftp=1"	
	  requestTimeOut = "1800"  <!---30 mins---> > 
</cfif>

          
<br><br><br><br>
<center>
<font color="#0000ff" size="+1">
	The common ColdFusion schedule tasks have been added ...
</font>
</center>