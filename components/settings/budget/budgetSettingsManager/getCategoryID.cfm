	<!--- Return Budget Categories --->
	<cffunction name="getCategoryID" output="false" returntype="query">
		<cfquery name="budgetCategories" datasource="#application.datasource#">
			select budget_group_classification_id AS "category_id", budget_group_classification_desc AS "category_desc"
			from budget_group_classification
			where deleted = 0
			order by budget_group_classification_id ASC
		</cfquery>
		<cfreturn budgetCategories />
	</cffunction>