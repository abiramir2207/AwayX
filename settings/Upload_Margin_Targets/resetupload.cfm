<cfparam name="url.filetype" default="">

<cfif url.filetype NEQ "">
 <cfset uploadmargintargetManager = CreateObject("component","components.settings.upload_margin_targets.uploadmargintargetManager") />
<cfset qAnyAliveProcess = uploadmargintargetManager.AnyAliveProcess(url.filetype)>
		
		<CFIF qAnyAliveProcess.RecordCount GT 0>
			<cfset qresetUpload = uploadmargintargetManager.resetUpload(qAnyAliveProcess.Generic_Files_Upload_ID)>
		</CFIF>
		
	<cfif url.filetype EQ 1>
		<!--- <CFQUERY NAME="StopDTS" DATASOURCE="#Application.Datasource#">
				EXEC Call_GDW4_Stop_DTS_Through_Job
			</CFQUERY> --->
		<CFLOCATION URL="index.cfm?Show_Tab=2">
	<cfelse>
			<!--- <CFQUERY NAME="StopDTS" DATASOURCE="#Application.Datasource#">
				EXEC Call_Item_Stop_DTS_Through_Job
			</CFQUERY> --->
		<CFLOCATION URL="index.cfm?Show_Tab=4">
	</cfif>
	
<cfelse>
<cflocation url="index.cfm">
</cfif>


