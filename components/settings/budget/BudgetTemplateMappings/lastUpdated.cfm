<!---
	Name: lastUpdated.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		When and by whom were the settings last updated?
	Usage:
		function within BudgetTemplateMappings.cfc
--->	
	
	<cffunction name="lastUpdated" returntype="query" hint="Returns Date & User Information from Last Update">
		<cfquery name="qGetLastUpdated" datasource="#application.datasource#">
			select top 1 created_by, created_on from budget_template_mappings
			where deleted = 0 order by created_on DESC
		</cfquery>
		
		<cfreturn qGetLastUpdated />
	</cffunction>