<!---
Name: 			Budget.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget
Date Created:	05/08/2006
--->

<cfcomponent displayname="Budget" hint="Budget">

	<!------ properties ----->
	<cfset this.budgetId = 0 />
	<cfset this.budgetReferenceId = 0 />
	<cfset this.revisionOfBudgetId = 0 />
	<cfset this.budgetGroupId = 0 />
	<cfset this.budgetCode = "" />
	<cfset this.budgetName = "" />
	<cfset this.budgetValue = 0 />
	<cfset this.budgetUOM = 0 />
	<cfset this.budgetStartDate = "" />
	<cfset this.budgetEndDate = "" />
	<cfset this.userId = "" />

	<cffunction name="init" access="public" returntype="components.budget.Budget">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
		
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	<cfinclude template="Budget/saveBudget.cfm" />
	
</cfcomponent>