	<!---
	Name:  Budget_Active_Relationship.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Description:
		 Function to optimize query performance for querying active status of budget & template relationships 
	Tip:
--->	
	<cfinvoke component="components.settings.budget.BudgetTemplateMappings" method="getAllMappings" returnvariable="qGetMappings">
	
	<cffunction name="isActive" returntype="boolean" hint="Is This Budget-Template Relationship Active?">
		<cfargument name="templateParentId" required="Yes" type="numeric">
		<cfargument name="budgetReferenceId" required="Yes" type="numeric">
		<cfset boolIsActive = 0>
		
		<cfquery name="qGetActive" dbtype="query">
			select active from qGetMappings
			where 	budget_reference_id = #arguments.budgetReferenceId#
			and 	template_parent_id = #arguments.templateParentId#
		</cfquery>
		
		<cfif qGetActive.RecordCount GTE 1>
			<cfset boolIsActive = qGetActive.active>
		</cfif>
		
		<cfreturn boolIsActive />
	</cffunction>