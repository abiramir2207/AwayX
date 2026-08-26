<!---
Name: 			getBudgetGroupLevelValues.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget group level data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetGroupLevelValues" access="public" returntype="query" output="no" hint="I am responsible for getting the budget group level values">
	
	<cfargument name="BudgetGroupLevel" type="components.settings.budget.BudgetGroupLevel" required="true" />
	<cfargument name="groupId" type="string" required="false" default="" />
	<cfargument name="cachedwithin" required="false" default="#CreateTimeSpan(0, 0, 0, 0)#" />

	<cfset BudgetGroupLevel = arguments.BudgetGroupLevel />

	<cfquery name="qGetBudgetGroupValues" datasource="#application.datasource#" cachedwithin="#arguments.cachedwithin#">
		SELECT	#BudgetGroupLevel.NameField# As Group_Name, 
				#BudgetGroupLevel.IDField# As Group_ID					
		FROM	#BudgetGroupLevel.tableName#					
		WHERE	#BudgetGroupLevel.tableName#.Deleted = 0
		AND 	#BudgetGroupLevel.NameField# IS NOT NULL
		AND		Len(#BudgetGroupLevel.NameField#) > 0
		<cfif arguments.groupId NEQ "">
		AND		#BudgetGroupLevel.tableName#.#BudgetGroupLevel.IDField# IN (#ListQualify(arguments.groupId, "'")#)
		</cfif>
		Order By #BudgetGroupLevel.NameField#
	</cfquery>
	

	<cfreturn qGetBudgetGroupValues />	
		
</cffunction>