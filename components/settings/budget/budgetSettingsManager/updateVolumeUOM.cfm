<!---
	Name: updateVolumeUOM.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: Clarence Morse           
	Description:
		Updates Volume UOM Settings for Budgets
	Input: volume_uom_id - integer
		   include - bit
--->	
	<cffunction name="updateVolumeUOM" output="No">
		<cfargument name="volume_uom_id" required="Yes">
		<cfargument name="include" required="Yes">
		
		<cfset useLakebaseForupdateVolumeUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_volume_uom")>
<cfif useLakebaseForupdateVolumeUOM>
	<cftry>
		<cfset application.oLakebase.updateRows("budget_volume_uom",
			{
				"volume_uom_id" = "eq.#arguments.volume_uom_id#"
			},
			{
				"volume_include" = "#arguments.include#",
				"updated_on" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateVolumeUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateVolumeUOM>
<cfquery name="updateVolumeUOM" datasource="#application.datasource#">
			Update Budget_Volume_UOM
			SET volume_include = #arguments.include#,
				Updated_On = getDate()
			WHERE volume_uom_id = #arguments.volume_uom_id#
		</cfquery>
</cfif>
	</cffunction>