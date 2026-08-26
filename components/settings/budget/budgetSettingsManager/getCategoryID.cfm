	<!--- Return Budget Categories --->
	<cffunction name="getCategoryID" output="false" returntype="query">
		<cfset useLakebaseForbudgetCategories = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_group_classification")>
<cfif useLakebaseForbudgetCategories>
	<cftry>
		<cfset budgetCategories = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_group_classification", {
				"deleted" = "eq.0",
				"order" = "budget_group_classification_id.asc",
				"select" = "budget_group_classification_id as "category_id",budget_group_classification_desc as "category_desc""
			}), "budget_group_classification_id as "category_id",budget_group_classification_desc as "category_desc""
		)>
		<cfcatch type="any">
			<cfset useLakebaseForbudgetCategories = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbudgetCategories>
<cfquery name="budgetCategories" datasource="#application.datasource#">
			select budget_group_classification_id AS "category_id", budget_group_classification_desc AS "category_desc"
			from budget_group_classification
			where deleted = 0
			order by budget_group_classification_id ASC
		</cfquery>
</cfif>
		<cfreturn budgetCategories />
	</cffunction>