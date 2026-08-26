<!---
	Name: updateAllocationTypes.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: Clarence Morse         
	Description:
		Updates Allocation Types for Budgets
	Input: allocation_id - integer
		   include - bit
		   budget_type - 1 for Trade, 2 for Volume
--->	
<cffunction name="updateAllocationTypes" output="No">
		<cfargument name="allocation_id" required="Yes">
		<cfargument name="include" required="Yes">
		<cfargument name="budget_type" required="Yes" type="numeric">
		
		<cfquery name="updateAllocation" datasource="#application.datasource#">
			Update budget_allocation_type 
			SET Updated_On = getDate(),
			<cfif arguments.budget_type EQ 1>
				trade_include = #arguments.include#
			<cfelseif budget_type EQ 2>
				volume_include = #arguments.include#	
			</cfif>
			WHERE allocation_id = #arguments.allocation_id#
		</cfquery>
	</cffunction>