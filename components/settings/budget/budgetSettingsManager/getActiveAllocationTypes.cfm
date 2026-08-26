<!---
	Name: getActiveAllocationTypes.cfm                     
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: Clarence Morse                                 
	Description:                                           
		<brief description of what the file is used for>   
	Usage:                                                 
		<templates that depend on this file>               
	Tip:                                                   
		budget_type - int 1: trade, 2: volume              
--->	
	<cffunction name="getActiveAllocationTypes" output="No" returntype="array">
		<cfargument name="budget_type" required="yes">
		
		<cfquery name="getActiveAllocations" datasource="#application.datasource#">
			select 	* 
			from 	budget_allocation_type
			where	1=1
			<cfif arguments.budget_type EQ 1>
			and		trade_include = 1
			<cfelseif budget_type EQ 2>
			and		volume_include = 1
			</cfif>
		</cfquery>
		
		<cfset arAllocationTypes = ArrayNew(1) />
		<cfloop query="getActiveAllocations">
			<cfset oAllocationType = CreateObject("component", "components.budget.AllocationType") />
			<cfset oAllocationType.id = allocation_id />
			<cfset oAllocationType.desc = allocation_desc />
			<cfset ArrayAppend(arAllocationTypes, oAllocationType) />
		</cfloop>
		
		<cfreturn arAllocationTypes />
	</cffunction>
	