<!---
	Name: updateGroups.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: Clarence Morse         
	Description:
		Update the Group Levels to include in Budgets
	Input:
		budget_group_level_id (from <instance_db>.budget_group_level.
		active - bit
		user_id - UUID for the user
		budget_type - 1 for Trade, 2 for Volume
--->	
	
	<cffunction name="updateGroups" output="No">
		<cfargument name="budget_group_level_id" required="yes" type="numeric">
		<cfargument name="active" required="Yes" type="numeric">
		<cfargument name="budget_type" required="Yes" type="numeric">
		<cfargument name="user_id" required="Yes" type="string">
		
		<cfquery name="updateGroup" datasource="#application.datasource#">
			update budget_group_level 
			Set Updated_By = '#arguments.user_id#',
			Updated_Date = getDate(),
			<cfif arguments.budget_type EQ 1>
			trade_active = #arguments.active#
			<cfelseif budget_type EQ 2>
			volume_active = #arguments.active#	
			</cfif>
			where budget_group_level_id = #arguments.budget_group_level_id#
		</cfquery>
	</cffunction>