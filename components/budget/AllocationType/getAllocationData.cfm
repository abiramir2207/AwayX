<!---
Name: 			getAllocationData.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the allocation data for top down
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getAllocationData" access="public" returntype="query" output="no" hint="I am responsible for getting the allocation data for top down">
	
	<cfargument name="budgetId" type="numeric" required="true">
	
	<!--- Initialize variables --->

	<cfquery name="qGetControlLevelMetaData" datasource="#application.datasource#">
		SELECT	Control_Level_1, Control_Level_2
		FROM	Budget
		WHERE	Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

	<cfset BudgetGroupLevelManager = CreateObject("component", "components.settings.budget.BudgetGroupLevelManager").init() />
	<cfset controlLevel1MetaData = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = qGetControlLevelMetaData.Control_Level_1, active = -1) /> 
	<cfset controlLevel2MetaData = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = qGetControlLevelMetaData.Control_Level_2, active = -1) /> 
	
	<cfif ArrayLen(controlLevel1MetaData) AND ArrayLen(controlLevel2MetaData)>
	<!------ TODO: handle for the case where there is no level 2 selected ----->
		<cfset BudgetGroupLevel_1 = controlLevel1MetaData[1] />
		<cfset BudgetGroupLevel_2 = controlLevel2MetaData[1] />
		<!------ do query ----->
		<cfquery name="qGetAllocationData" datasource="#application.datasource#">
			SELECT	Control_Level_1.#BudgetGroupLevel_1.numberField# as Control_Level_1_Number, 
					Control_Level_1.#BudgetGroupLevel_1.nameField# as Control_Level_1_Name, 
					Control_Level_2.#BudgetGroupLevel_2.numberField# as Control_Level_2_Number, 
					Control_Level_2.#BudgetGroupLevel_2.nameField# as Control_Level_2_Name,
					Budget_Detail_Final.Level_Value
			FROM	Budget_Detail_Final
			
			LEFT JOIN #BudgetGroupLevel_1.tableName# as Control_Level_1
			ON	Control_Level_1.#BudgetGroupLevel_1.iDField# = Budget_Detail_Final.Control_Level_1_ID
			
			LEFT JOIN #BudgetGroupLevel_2.tableName# as Control_Level_2
			ON	Control_Level_2.#BudgetGroupLevel_2.iDField# = Budget_Detail_Final.Control_Level_2_ID
			
			WHERE	Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			
			ORDER BY	Control_Level_1.#BudgetGroupLevel_1.nameField#, Control_Level_2.#BudgetGroupLevel_2.nameField#
		</cfquery>

		<cfreturn qGetAllocationData />	
				
	</cfif>
	
	
</cffunction>