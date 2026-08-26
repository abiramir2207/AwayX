<cfset useLakebaseForsave = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options_map_to_menu_tab")>
<cfif useLakebaseForsave>
	<cftry>
		<cfset application.oLakebase.insertRow("program_control_panel_options_map_to_menu_tab", {
			"program_control_panel_option_column_name" = "#FORM.newField#",
			"menu_tab_id" = "0"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsave = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsave>
<cfquery name="save" datasource="#application.datasource#">
	INSERT INTO Program_Control_Panel_Options_MAP_TO_Menu_Tab
	(Program_Control_Panel_Option_Column_Name,Menu_Tab_ID)
	VALUES
	('#FORM.newField#',0)
</cfquery>
</cfif>
<cflocation url="AssignOptionToTab.cfm">