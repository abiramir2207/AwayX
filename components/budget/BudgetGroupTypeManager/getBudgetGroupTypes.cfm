<!---
Name: 			getBudgetGroupTypes.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget group type data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetGroupTypes" access="public" returntype="array" output="no" hint="I am responsible for getting the budget group type data">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = ArrayNew(1) />
	<cfset var var_budgetGroupType = "" />
			
	<!------ do query ----->
	<cfset useLakebaseForqGetBudgetGroupTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("budget_group_type")>
<cfif useLakebaseForqGetBudgetGroupTypes>
	<cftry>
		<cfset qGetBudgetGroupTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("budget_group_type", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBudgetGroupTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBudgetGroupTypes>
<cfquery name="qGetBudgetGroupTypes" datasource="#application.datasource#">
		SELECT	*
		FROM	Budget_Group_Type
		WHERE	Deleted = 0
	</cfquery>
</cfif>
	
	<!------ loop and populate var_budgetGroupType and add to the array  ----->
	<cfloop query="qGetBudgetGroupTypes">
		<cfset var_budgetGroupType = CreateObject("component", "components.budget.BudgetGroupType").init() />
		<cfset var_budgetGroupType.budgetGroupTypeId 	= Budget_Group_Type_ID />
		<cfset var_budgetGroupType.budgetGroupTypeCode 	= Budget_Group_Type_Code />
		<cfset var_budgetGroupType.budgetGroupTypeName 	= Budget_Group_Type_Name />
		<cfset ArrayAppend(var_returnVal, var_budgetGroupType) />
	</cfloop>
	
	<cfreturn var_returnVal />	
		
</cffunction>
