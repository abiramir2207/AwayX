<!------ program_wizard_complete.cfm ----->


<!------ set active=0 id active=null ----->
<cfset useLakebaseForsetComplete = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForsetComplete>
	<cftry>
		<cfset application.oLakebase.updateRows("program_control_panel_options",
			{
				"programcontrol_panel_options_id" = "eq.#id#",
				"active" = "is.null"
			},
			{
				"active" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsetComplete = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsetComplete>
<cfquery name="setComplete" datasource="#application.datasource#">
	UPDATE	Program_Control_Panel_Options
	SET		Active = 0
	WHERE
			ProgramControl_Panel_Options_ID = #id#
			AND Active IS NULL
</cfquery>
</cfif>
