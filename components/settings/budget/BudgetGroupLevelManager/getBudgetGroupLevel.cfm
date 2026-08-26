<!---
Name: 			getBudgetGroupLevel.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget group level data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetGroupLevel" access="public" returntype="array" output="no" hint="I am responsible for getting the budget group level data">
	
	<cfargument name="budgetGroupLevelId" type="numeric" required="false" default="0" />
	<cfargument name="active" type="numeric" required="false" default="-1" />
	
	<cfset this.budgetGroupLevels = ArrayNew(1) />
	
	<!------ do query ----->
	<cfquery name="qGetBudgetGroupLevel" datasource="AWAYX">
		SELECT	*
		FROM	Budget_Group_Level
		WHERE	Budget_Group_Level.Deleted = 0
		<cfif arguments.active neq -1>
		AND		Budget_Group_Level.Active = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif arguments.budgetGroupLevelId neq 0>
		AND		Budget_Group_Level_ID = <cfqueryparam value="#arguments.budgetGroupLevelId#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
	</cfquery>
	
	<cfloop query="qGetBudgetGroupLevel">
		<cfset BudgetGroupLevel = CreateObject("component", "components.settings.budget.BudgetGroupLevel").init() />

		<cfset BudgetGroupLevel.budgetGroupLevelId 	= Budget_Group_Level_ID />
		<cfset BudgetGroupLevel.groupLevelId 		= Group_Level_ID />
		<cfset BudgetGroupLevel.budgetcategoryGroupId 		= Group_ID />
		<cfset BudgetGroupLevel.tableName 			= Group_Attribute_Table />
		<cfset BudgetGroupLevel.description 		= Group_Level_Desc />
		<cfset BudgetGroupLevel.internalDescription = Group_Level_Desc_Internal />
		<cfset BudgetGroupLevel.masterIDField 		= Group_Attribute_Master_ID_Field />
		<cfset BudgetGroupLevel.iDField 			= Group_Attribute_ID_Field />
		<cfset BudgetGroupLevel.numberField 		= Group_Attribute_Number_Field />
		<cfset BudgetGroupLevel.nameField 			= Group_Attribute_Name_Field />
		
		<cfset ArrayAppend(this.budgetGroupLevels, BudgetGroupLevel) />
	</cfloop>
	
	<cfreturn this.budgetGroupLevels />	
		
</cffunction>