<!---
Name: 			saveBudgetControlLevelFilter.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for saving the budget control level filter
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="saveBudgetControlLevelFilter" access="public" returntype="void" output="no" hint="I am responsible for saving the budget control level filter">

	<cfargument name="controlLevelIndex" type="numeric" required="true">
		
	<cfquery name="deleteControlLevelFilterList" datasource="#application.datasource#">
		DELETE	Budget_Control_Level_Filter
		WHERE	Budget_ID = <cfqueryparam value="#this.budgetId#" cfsqltype="CF_SQL_INTEGER">
		AND		Control_Level_Index = <cfqueryparam value="#arguments.controlLevelIndex#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset controlLevelFilterList = Evaluate("this.controlLevel#arguments.controlLevelIndex#_filterlist") />
	<cfset controlLevel = Evaluate("this.controlLevel#arguments.controlLevelIndex#") />
	<cfloop list="#controlLevelFilterList#" index="groupId">
		<cfquery name="insertControlLevelFilterList" datasource="#application.datasource#">
			INSERT INTO Budget_Control_Level_Filter (Budget_ID, Control_Level_Index, Budget_Group_Level_ID, Group_ID)
			VALUES	(
					<cfqueryparam value="#this.budgetId#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.controlLevelIndex#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#controlLevel#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#groupId#" cfsqltype="CF_SQL_VARCHAR">
					)
		</cfquery>
	</cfloop>

		
</cffunction>
