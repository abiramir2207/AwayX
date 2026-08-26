<!---
Name: 			getBudgetGroup.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget group data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetGroup" access="public" returntype="components.budget.BudgetGroup" output="no" hint="I am responsible for getting the budget group data">
	
	<cfargument name="id" type="numeric" required="true">
	
	<!--- Initialize variables --->
	
			
	<cfif arguments.id>
		<!------ do query ----->
		<cfquery name="qGetBudgetGroup" datasource="#application.datasource#">
			SELECT	Budget_Group.*, Budget_Group_Type.Budget_Group_Type_Code
			FROM	Budget_Group
					LEFT JOIN 	Budget_Group_Type
					ON Budget_Group.Budget_Group_Type_ID = Budget_Group_Type.Budget_Group_Type_ID
			WHERE	Budget_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfloop query="qGetBudgetGroup">
			<cfset this.budgetGroupId 			= Budget_Group_ID />
			<cfset this.budgetGroupCode 		= Budget_Group_Code />
			<cfset this.budgetGroupName 		= Budget_Group_Name />
			<cfset this.budgetGroupValue 		= Budget_Group_Value />
			<cfset this.budgetGroupUOM 			= Budget_Group_UOM />
			<cfset this.budgetGroupStartDate 	= Budget_Group_Start_Date />
			<cfset this.budgetGroupEndDate 		= Budget_Group_End_Date />
			<cfset this.budgetGroupTypeId 		= Budget_Group_Type_ID />
			<cfset this.budgetGroupTypeCode		= Budget_Group_Type_Code />
		</cfloop>
		
	</cfif>
	
	<cfreturn this />	
		
</cffunction>
