<!---
Name: 			getBudgetGroups.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting multiple budget group data
Parameters:		N/A
Usage:			N/A
--->
<!------ 
<cffunction name="getBudgetGroups" access="public" returntype="query" output="no" hint="I am responsible for getting multiple budget group data">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = "" />
			
	<cfset useLakebaseForvar_returnVal = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_group")>
<cfif useLakebaseForvar_returnVal>
	<cftry>
		<cfset var_returnVal = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_group", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvar_returnVal = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvar_returnVal>
<cfquery name="var_returnVal" datasource="#application.datasource#">
		SELECT	*
		FROM	Budget_Group
		WHERE	Deleted = 0
	</cfquery>
</cfif>
	
	<cfreturn var_returnVal />	
		
</cffunction>

 ----->


 
<cffunction name="getBudgetGroups" access="public" returntype="array" output="no" hint="I am responsible for getting the budget group members">
	
	<!--- Initialize variables --->
	<cfset var arBudgetGroups = ArrayNew(1) />
	
	<!------ do query ----->
	<cfquery name="qGetBudgetGroups" datasource="#application.datasource#">
		SELECT	Budget_Group.*, Budget_Group_Type.Budget_Group_Type_Code
		FROM	Budget_Group
		LEFT JOIN 	Budget_Group_Type
					ON Budget_Group.Budget_Group_Type_ID = Budget_Group_Type.Budget_Group_Type_ID
		WHERE	Budget_Group.Deleted = 0
	</cfquery>
	
	<cfloop query="qGetBudgetGroups">
	
		<cfset BudgetGroup = CreateObject("component", "components.budget.BudgetGroup").init() />

		<cfset BudgetGroup.budgetGroupId 		= Budget_Group_ID />
		<cfset BudgetGroup.budgetGroupCode 		= Budget_Group_Code />
		<cfset BudgetGroup.budgetGroupName 		= Budget_Group_Name />
		<cfset BudgetGroup.budgetGroupValue 	= Budget_Group_Value />
		<cfset BudgetGroup.budgetGroupUOM 		= Budget_Group_UOM />
		<cfset BudgetGroup.budgetGroupStartDate = Budget_Group_Start_Date />
		<cfset BudgetGroup.budgetGroupEndDate 	= Budget_Group_End_Date />
		<cfset BudgetGroup.budgetGroupTypeCode		= Budget_Group_Type_Code />
		<cfset BudgetGroup.getBudgetGroupMembers(BudgetGroup.budgetGroupId) />
		
		<cfset ArrayAppend(arBudgetGroups, BudgetGroup) />
		
	</cfloop>
		
	<cfreturn arBudgetGroups />	
		
</cffunction>
