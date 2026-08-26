<cfif isDefined("form.ID")>

<cfset useLakebaseForSetToNotDominant = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForSetToNotDominant>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"programcontrol_panel_options_id" = "eq.#ID#"
			},
			{
				"isdominant" = "0",
				"deletedby" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSetToNotDominant = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSetToNotDominant>
<cfquery name="SetToNotDominant" datasource="#application.datasource#">
UPDATE Program_Control_Panel_Options
SET IsDominant = 0, 
	DeletedBy = '#request.AccessStructure.User_ID#'
WHERE ProgramControl_Panel_Options_ID= #ID#
</cfquery>
</cfif>

<cflocation url="index.cfm">

</cfif>