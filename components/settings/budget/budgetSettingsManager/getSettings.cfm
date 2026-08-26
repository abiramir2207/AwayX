	<!--- Return Default Selections and Control Levels --->
	<cffunction name="getSettings" output="false" hint="returns Budget Control Panel Settings" returntype="query">
		<cfquery name="qGetControlPanelSettings" datasource="#application.datasource#">
			select * from budget_control_panel_settings
		</cfquery>
		
		<cfreturn qGetControlPanelSettings />
	</cffunction>
	

	