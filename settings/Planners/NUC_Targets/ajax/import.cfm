<!----------------------------------------------------------------------------------------------------------------------------------
  Template: \settings\Planners\NUC_Targets\import.cfm
	Author: Chris Nguyen
	  Date: 2016 December
   Purpose: Import NUC Targets from Excel XLSX file
----------------------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="No">
<cftry>
	<cfset file_path = application.doc_path & "/data_files/uploaded/">
	<cffile action="upload" destination="#file_path#" nameconflict="overwrite" result="upload"/>

	<!---send success status & uploaded file name back--->
	<cfoutput>#serializeJSON({STATUS=200, MESSAGE=file_path & upload.serverFile})#</cfoutput>
<cfcatch type="any" >
	<cfoutput>#serializeJSON({STATUS=500, MESSAGE=JSStringFormat(arguments.detail_message)})#</cfoutput>
</cfcatch>
</cftry>

