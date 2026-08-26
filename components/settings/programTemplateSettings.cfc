<!---------------------------------------------------------------------------------------------------------------------
   Template:\components\settings\programTemplateSettings.cfc
   Date:     2017 March
   Author:   Chris Nguyen
   Purpose:  Return program template settings
---------------------------------------------------------------------------------------------------------------------->

<cfcomponent output="false">

	<cffunction name="get_Setting" access="public" output="false" hint="Return a single program template setting value.">
		<cfargument name="contract_main_id" required="true">
		<cfargument name="setting_input_name" required="true" type="string" hint="this is the setting input name in the database">

		<cfquery name="local.setting" datasource="#application.datasource#">
			SELECT #arguments.setting_input_name# AS return_value
			  FROM CONTRACT_MAIN
			  INNER JOIN PROGRAM_CONTROL_PANEL_OPTIONS 
					ON PROGRAM_CONTROL_PANEL_OPTIONS.ProgramControl_Panel_Options_ID = CONTRACT_MAIN.ProgramType_ID
			  WHERE Contract_Main_ID = <cfqueryparam value="#arguments.contract_main_id#">
		</cfquery>

		<cfreturn local.setting.return_value>
	</cffunction>

</cfcomponent>