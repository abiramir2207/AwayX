<!---
	Name: getAllMappings.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.
	Usage:
		function within BudgetTemplateMappings
--->	
	
	
	<cffunction name="getAllMappings" returntype="query" hint="Returns All Budget/Template Mappings">
		<cfargument name="templateParentId" required="No" type="numeric" default="0" />
		<cfargument name="budgetReferenceId" required="No" type="numeric" default="0" />
		<cfargument name="sortby" required="No" type="string" default="" />
		
		<cfquery name="qGetMappings" datasource="#application.datasource#">
			select 	budget_reference_id, template_parent_id, active 
			from 	budget_template_mappings
			where 	deleted = 0
			<cfif arguments.templateParentId NEQ 0>
				and template_parent_id = '#arguments.templateParentId#'
			</cfif>
			<cfif arguments.budgetReferenceId NEQ 0>
				and budget_reference_id = #arguments.budgetReferenceId# 
			</cfif>
			<cfif Len(arguments.sortby) GT 0>
			order by #arguments.sortby#
			</cfif>
		</cfquery>
		
		<cfreturn qGetMappings />
	</cffunction>