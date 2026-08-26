<!---
	Name: lastUpdated.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		When and by whom were the settings last updated?
	Usage:
		function within BudgetTemplateMappings.cfc
--->	
	
	<cffunction name="lastUpdated" returntype="query" hint="Returns Date & User Information from Last Update">
		<cfset useLakebaseForqGetLastUpdated = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_template_mappings")>
<cfif useLakebaseForqGetLastUpdated>
	<cftry>
		<cfset qGetLastUpdated = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_template_mappings", {
				"deleted" = "eq.0",
				"order" = "created_on.desc",
				"limit" = "1",
				"select" = "created_by,created_on"
			}), "created_by,created_on"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLastUpdated = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLastUpdated>
<cfquery name="qGetLastUpdated" datasource="#application.datasource#">
			select top 1 created_by, created_on from budget_template_mappings
			where deleted = 0 order by created_on DESC
		</cfquery>
</cfif>
		
		<cfreturn qGetLastUpdated />
	</cffunction>