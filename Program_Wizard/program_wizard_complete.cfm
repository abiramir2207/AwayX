<!------ program_wizard_complete.cfm ----->


<!------ set active=0 id active=null ----->
<cfquery name="setComplete" datasource="#application.datasource#">
	UPDATE	Program_Control_Panel_Options
	SET		Active = 0
	WHERE
			ProgramControl_Panel_Options_ID = #id#
			AND Active IS NULL
</cfquery>
