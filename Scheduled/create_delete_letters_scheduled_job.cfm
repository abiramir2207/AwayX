/******
	This is the file which adds the job to delete the previous versions of a letter.
*******/

<!--- Initialize the Java Service Factory --->
<cfobject type="JAVA" action="Create" name="factory" class="coldfusion.server.ServiceFactory">

<!--- Get all the cf jobs from the JAVA service factory --->
<cfset allTasks = factory.CronService.listAll()>   

<cfset create_job = 1>

<!--- Find the "delete letters" job in the list --->
<CFOUTPUT>
<cfloop from="1" to="#Arraylen(allTasks)#" index="i">
	
	<cfif find("scheduled/delete_letters.cfm",allTasks[i].url) neq 0>
			<cfset create_job = 0>
			<cfbreak>
	</cfif>

</cfloop>

<!--- If the "delete letters" job does not exist, then create the job --->
<cfif create_job eq 1>

<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/scheduled/delete_letters.cfm">	

<cfschedule action = "update"
  task = "Delete letter previous versions" 
  operation = "HTTPRequest"
  url = "#scURL#"
	<!--- Start Date is one hour from the time the job is added --->
  startDate = "#DateFormat(DateAdd("h", 1, Now()),"mm/dd/yyyy")#"
	<!--- Start time is one hour from the time the job is added  --->
  startTime = "#TimeFormat(DateAdd("h", 1, Now()), "short")#"
	<!--- every 6 minutes ---->
  interval = "360"
  resolveURL = "Yes"
	publish = "Yes"
	path = "#expandPath('/Scheduled/')#"
	file = "Delete_Letters_Log.htm"
  requestTimeOut = "600">

</cfif>
</CFOUTPUT>