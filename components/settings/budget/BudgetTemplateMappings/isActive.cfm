<!---
	Name: isActive.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		Returns whether the budget and template relationship is active.
	Usage:
		function within BudgetTemplateMappings.cfc
--->	
	<cffunction name="isActive" returntype="boolean" hint="Is This Budget-Template Relationship Active?">
		<cfargument name="templateParentId" required="Yes" type="numeric">
		<cfargument name="budgetReferenceId" required="Yes" type="numeric">
		<cfset var boolIsActive = false />
		
		<cfquery name="qGetActive" datasource="#application.datasource#">
			select 	active 
			from 	budget_template_mappings
			where 	budget_reference_id = #arguments.budgetReferenceId#
			and 	template_parent_id = #arguments.templateParentId#
			and 	deleted = 0
		</cfquery>
		
		<cfif qGetActive.RecordCount GTE 1>
			<cfset boolIsActive = qGetActive.Active />
		</cfif>
		
		<cfreturn boolIsActive />
	</cffunction>