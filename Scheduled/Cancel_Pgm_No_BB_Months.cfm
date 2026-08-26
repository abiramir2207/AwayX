<!---
	Copyright (c)2014 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\Cancel_Pgm_No_BB_Months.cfm
	Created:		3/3/2014
	Developer:		drachala
	Description:	This scheduled task files is used to cancel the programs with out any Billbacks for duration specified in app setting "Auto cancel programs with no claims for period of:"
--->
<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />

<cfif appSettings.getCancelPgmNoBBMonths()>
	<cfset getProgramsList = CreateObject("component", "components.programs.Program").getProgramsNoBB(appSettings.getCancelPgmNoBBMonths()) />
	<cfset getSystemAdministrator = CreateObject("component", "components.User.UserManager").getCurrentSystemAdmin() />
	<cfset cancelProgram = CreateObject("component", "components.Programs.Program")/>
	<cfset SystemAdministratorName = getSystemAdministrator.name_first &' '&getSystemAdministrator.name_last/>

	<cfloop query="getProgramsList">
				<cfquery name="updateEndDate" datasource="#application.datasource#">
					UPDATE 	Contract_Main
					SET 	Contract_End_date =  CAST(GETDATE() As Date)
					WHERE	Contract_Main_ID = #getProgramsList.contract_main_id#
				</cfquery>
				<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#getProgramsList.contract_main_id#" null="no">
				</cfstoredproc>
				<cfset useLakebaseForupdateNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_evaluation_notes")>
<cfif useLakebaseForupdateNotes>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_evaluation_notes", {
			"contract_number" = "#getProgramsList.Contract_Number#",
			"entered_by" = "#SystemAdministratorName#",
			"eval_action" = "Program Expired",
			"notes" = "Program End-date was updated due to a level of inactivity that satisfied the Auto Cancel rules at the time",
			"contract_notes_type" = "2"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForupdateNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateNotes>
<cfquery name="updateNotes" datasource="#application.datasource#">
					INSERT INTO contract_evaluation_notes (
															Contract_Number,
															Entered_By,
															Eval_Action,
															Notes,
															Contract_Notes_Type
														)
					VALUES('#getProgramsList.Contract_Number#', 
									'#SystemAdministratorName#',
									'Program Expired',
									'Program End-date was updated due to a level of inactivity that satisfied the Auto Cancel rules at the time',
									2
									) 
				</cfquery>
</cfif>													
	</cfloop>
	
</cfif>