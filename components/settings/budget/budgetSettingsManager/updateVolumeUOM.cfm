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
		
		<cfquery name="updateVolumeUOM" datasource="#application.datasource#">
			Update Budget_Volume_UOM
			SET volume_include = #arguments.include#,
				Updated_On = getDate()
			WHERE volume_uom_id = #arguments.volume_uom_id#
		</cfquery>
	</cffunction>