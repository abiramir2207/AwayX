<!---
Name: 			getBudgetGroupMembers.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget group members
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetGroupMembers" access="public" returntype="array" output="no" hint="I am responsible for getting the budget group members">
	
	<cfargument name="id" type="numeric" required="true">
	
	<!--- Initialize variables --->
	
			
	<cfif arguments.id>
		<cfset this.budgetGroupMembers = ArrayNew(1) />
		
		<!------ do query ----->
		<cfquery name="qGetBudgetGroupMembers" datasource="#application.datasource#">
			SELECT	*
			FROM	Budget
			WHERE	Budget_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfloop query="qGetBudgetGroupMembers">
		
			<cfset Budget = CreateObject("component", "components.budget.Budget").init() />

			<cfset Budget.budgetId 			= Budget_ID />
			<cfset Budget.budgetReferenceId = Budget_Reference_ID />
			<cfset Budget.revisionOfBudgetId= Revision_Of_Budget_ID />			
			<cfset Budget.budgetGroupId 	= Budget_Group_ID />
			<cfset Budget.budgetCode 		= Budget_Code />
			<cfset Budget.budgetName 		= Budget_Name />
			<cfset Budget.budgetValue 		= Budget_Value />
			<cfset Budget.budgetUOM 		= Budget_UOM />
			<cfset Budget.budgetStartDate 	= Budget_Start_Date />
			<cfset Budget.budgetEndDate 	= Budget_End_Date />
			<cfset Budget.createdBy 		= Created_By />
			
			<cfset ArrayAppend(this.budgetGroupMembers, Budget) />
			
		</cfloop>
		
	</cfif>
	
	<cfreturn this.budgetGroupMembers />	
		
</cffunction>
