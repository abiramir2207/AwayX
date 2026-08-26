<cfsetting enablecfoutputonly="Yes" showdebugoutput="Yes">
<cftry>
<cfparam name="Url.username" 	default="">
<cfparam name="Url.password" 	default="">
<cfparam name="Form.username" 	default="#Url.username#">
<cfparam name="Form.password" 	default="#Url.password#">

<cfset thisPath="#GetDirectoryFromPath(GetBaseTemplatePath())#">
<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/Common_Files/contracts/program_releaser/poller_to_release_programs.cfm">

<cfset dStartDate=DateFormat(Now(),"MM/DD/YYYY")>
<!---
	D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
	Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
	"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
--->
<cfschedule action = "update"
  task = "Formula Pricing Program Releaser" 
  operation = "HTTPRequest"
  url = "#scURL#"
  startDate = "#dStartDate#"
  enddate = ""
  startTime = "00:00:00"
  endTime = "23:59:00"
  interval = "60"
  resolveURL = "Yes"
  publish = "Yes"
  file = "releaser_output.log"	<!--- D57544 --->
  path = "#thisPath#"
  username = "#Form.UserName#"
  password = "#Form.password#"
  requestTimeOut = "600">

 <cfset thisPath="#GetDirectoryFromPath(ExpandPath("../Delete_Temp_Files/"))#">
<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/Common_Files/Contracts/Delete_Temp_Files/Delete_Temp_Files.cfm">  
<cfschedule action = "update"
  task = "Delete Temporary Files" 
  operation = "HTTPRequest"
  url = "#scURL#"
  startDate = "#dStartDate#"
  enddate = ""
  startTime = "01:00:00"
  interval = "daily"
  resolveURL = "Yes"
  publish = "Yes"
  file = "delete_temp_files_output.log"	<!--- D57544 --->
  path = "#thisPath#"
  username = "#Form.UserName#"
  password = "#Form.password#"
  requestTimeOut = "600">
  
<cfparam name="Url.AppPath" 	default="">
<cfparam name="Form.AppPath" 	default="#Url.AppPath#">

<CFIF Len(Form.AppPath) GT 0>
	<CFIF DirectoryExists(Form.AppPath)>
	<CFQUERY datasource="#application.datasource#" NAME="addAppPathToDatabase">
		UPDATE 	General_Settings
		SET		Application_Installation_Root_Location = '#Form.AppPath#'
	</CFQUERY>
	<CFELSE>
<CFOUTPUT>Failure.
Invalid Application Path '#Form.AppPath#'. 
Path not found</CFOUTPUT>
<CFABORT>
	</CFIF>
<CFELSE>
<CFOUTPUT>Failure
Invalid Application Path</CFOUTPUT>
	<CFABORT>
</CFIF>
  
  <cfcatch>
  	<CFOUTPUT>failure</CFOUTPUT>
	<CFOUTPUT>CFCATCH.Message</CFOUTPUT>
	<cfabort>
  </cfcatch>
 </cftry>
<CFOUTPUT>success</CFOUTPUT>