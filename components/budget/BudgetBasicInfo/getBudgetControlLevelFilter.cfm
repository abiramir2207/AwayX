<!---
Name: 			getBudgetControlLevelFilter.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget control level filter
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetControlLevelFilter" access="public" returntype="query" output="no" hint="I am responsible for getting the budget control level filter">

	<cfargument name="controlLevelIndex" type="numeric" required="true">
	<cfargument name="budgetGroupLevelId" type="numeric" required="true">
		
	<cfquery name="getControlLevelFilterList" datasource="#application.datasource#">
		SELECT	DISTINCT Group_ID
		FROM	Budget_Control_Level_Filter
		WHERE	Deleted = 0
		AND		Budget_ID = <cfqueryparam value="#this.budgetId#" cfsqltype="CF_SQL_INTEGER">
		AND		Control_Level_Index = <cfqueryparam value="#arguments.controlLevelIndex#" cfsqltype="CF_SQL_INTEGER">
		AND		Budget_Group_Level_ID = <cfqueryparam value="#arguments.budgetGroupLevelId#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

	<cfreturn getControlLevelFilterList />
		
</cffunction>
