<cfset variables.expandedPath = ExpandPath("*.*") />
<cfset variables.getPath = GetDirectoryFromPath(variables.expandedPath) />
<!---
	D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
	Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
	"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
--->
<cfschedule action="update"
  task = "Pricing_ZDeal_Invalid_Hierarchy_Ack" 
  operation = "HTTPRequest"
  url = "http://#cgi.http_host#/scheduled/Invalid_Hierarchy_Notification.cfm"
  startDate = "#DateFormat(now(),'mm/dd/yyyy')#"
  startTime = "8:30 AM"
  endtime="5:30 PM"
  interval = "10800"
  resolveURL = "Yes"
  publish = "no"
  file = "Invalid_Hierarchy_Notification.log"	<!--- D57544 --->
  path = "#variables.getPath#"
  requestTimeOut = "600">