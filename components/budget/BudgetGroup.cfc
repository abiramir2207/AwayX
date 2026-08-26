<!---
Name: 			BudgetGroup.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget Group
Date Created:	05/08/2006
--->

<cfcomponent displayname="BudgetGroup" hint="Budget Group">

	<!------ properties ----->
	<cfset this.budgetGroupId = 0 />
	<cfset this.budgetGroupCode = "" />
	<cfset this.budgetGroupName = "" />
	<cfset this.budgetGroupValue = 0 />
	<cfset this.budgetGroupUOM = 0 />
	<cfset this.budgetGroupStartDate = "" />
	<cfset this.budgetGroupEndDate = "" />
	<cfset this.budgetGroupTypeId = 0 />
	
	<cfset this.budgetGroupMembers = ArrayNew(1) />
	

	<cffunction name="init" access="public" returntype="components.budget.BudgetGroup">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	<cfinclude template="BudgetGroup/getBudgetGroup.cfm" />
	<cfinclude template="BudgetGroup/getBudgetGroupMembers.cfm" />
	
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	<cfinclude template="BudgetGroup/saveBudgetGroup.cfm" />
	
</cfcomponent>