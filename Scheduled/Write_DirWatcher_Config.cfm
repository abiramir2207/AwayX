<!---
	Copyright (c)2010 Blacksmith Applications, Inc.
	Filename:		C:\Users\kvangapalli\Work\AwayX\Scheduled\Write_DirWatcher_Config.cfm
	Created:		7/26/2010
	Developer:		kvangapalli
	Description:	This file outputs the directoryWatcher config and creates a scheduled task to run manage documents daily.
	Usage:			The files created are used by the directory watcher gateway and scheduled task
	Tip:			<gotchas>
--->

<!--- Create a scheduled task for the ManageAttachments.cfm to run every day --->
<!---
	D57544: Invalid extension of the file name. Valid extensions are : log,txt.
	Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10.
	"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
--->

<!--- Writes the configuration file for the directory watcher --->
<cfset variable.FTPPath = Application.oApplicationAppSettingsManager.getApplicationAppSettings().getFTPDocumentPath() />
<cfset variable.FTPPath = Replace(variable.FTPPath, "\", "\\", "ALL")/>

<!--- Remove existing  job for attachements when FTP path is not defined. --->
<cfif !len(variable.FTPPath) AND (listfirst(Server.ColdFusion.ProductVersion) GT 9) >
	<cfschedule action="list" result="scheduledTasks">
	<cfloop query="scheduledTasks">
		<cfif findNoCase("#application.returned_customer_setting.Company_Name# - Manage Attachments", "#task#") >
			<cfschedule action="delete" task="#task#">
		</cfif>
	</cfloop>
</cfif>

<!--- Run this scrit only when the FTP path is defined --->
<cfif len(variable.FTPPath) >

	<cfschedule action = "update"
		task = "#application.returned_customer_setting.Company_Name# - Manage Attachments"
		operation = "HTTPRequest"
		url = "http://#HTTP_HOST#/Scheduled/ManageAttachments.cfm"
		startDate = "#DateFormat(Now(),"mm/dd/yyyy")#"
		startTime = "#TimeFormat("06:00", "short")#"
		interval = "Daily"
		resolveURL = "Yes"
		publish = "Yes"
		path = "#expandPath('/Scheduled/')#"
		file = "ManageAttachments.log" <!--- D57544 --->
		requestTimeOut = "600">


	<cfsavecontent variable="DirWatcherConfig">
	<cfoutput>
	##												#Chr(13)##Chr(10)#
	## DirectoryWatcherGateway configuration file	#Chr(13)##Chr(10)#
	##												#Chr(13)##Chr(10)#
	directory=#variable.FTPPath#					#Chr(13)##Chr(10)#
	recurse=no										#Chr(13)##Chr(10)#
	interval=60000									#Chr(13)##Chr(10)#
	extensions=*									#Chr(13)##Chr(10)#
	changeFunction=onChange							#Chr(13)##Chr(10)#
	addFunction=onAdd								#Chr(13)##Chr(10)#
	deleteFunction=onDelete							#Chr(13)##Chr(10)#
	</cfoutput>
	</cfsavecontent>

	<!--- Write the file to the location --->
	<cffile action="write" file="#application.apppath#/Gateway_Config/DirectoryWatcher.cfg" output="#DirWatcherConfig#" />

</cfif>