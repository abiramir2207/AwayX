	<!--- Return Default Selections and Control Levels --->
	<cffunction name="getSettings" output="false" hint="returns Budget Control Panel Settings" returntype="query">
		<cfset useLakebaseForqGetControlPanelSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_control_panel_settings")>
<cfif useLakebaseForqGetControlPanelSettings>
	<cftry>
		<cfset qGetControlPanelSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_control_panel_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetControlPanelSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetControlPanelSettings>
<cfquery name="qGetControlPanelSettings" datasource="#application.datasource#">
			select * from budget_control_panel_settings
		</cfquery>
</cfif>
		
		<cfreturn qGetControlPanelSettings />
	</cffunction>
	

	