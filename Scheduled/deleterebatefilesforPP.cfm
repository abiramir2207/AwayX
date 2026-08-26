<!---clear_rebate_files.cfm--->
<!---file will delete all cached rebate files--->

<!---get the app path--->
<cfparam name="displayClearRebateFilesStatus" 	default="1">
<cfset appPath = request.app_general_functions.Get_Application_Path() />
<cfset Application.Doc_Path = request.app_general_functions.Get_Document_Path() />

<!---set the full path--->
<cfset fileDir = "#Application.Doc_Path#\data_Files\created\contracts\RebateData\" />

<!---loop over the dir and delete all the files--->
<cfset useLakebaseForgetrebatefilestodelete = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_protection_schedule_contracts")>
<cfif useLakebaseForgetrebatefilestodelete>
	<cftry>
		<cfset getrebatefilestodelete = application.oLakebase.toQuery(
			application.oLakebase.selectRows("price_protection_schedule_contracts", {
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetrebatefilestodelete = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetrebatefilestodelete>
<cfquery name="getrebatefilestodelete" datasource="#application.datasource#">
	 select distinct PROGRAM_ID
	from Price_Protection_Schedule_Contracts 
</cfquery>
</cfif>
<cfoutput query="getrebatefilestodelete"> 
	
	<cftry>
	
		<cffile action = "delete" file = "#fileDir##PROGRAM_ID#.xml">
	
	<cfcatch type="any">
		<cfif displayClearRebateFilesStatus>
		<b><font color="##FF0000">Error deleting file #PROGRAM_ID#!</font></b>
		</cfif>
	</cfcatch>

	</cftry>
	<cfif displayClearRebateFilesStatus>
	<b><font color="##00CC00">#PROGRAM_ID# deleted successfully!</font></h2></b>
	</cfif>
	<cfflush>
	
</cfoutput>


