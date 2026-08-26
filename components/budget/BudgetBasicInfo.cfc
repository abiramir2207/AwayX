<!---
Name: 			BudgetBasicInfo.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget
Date Created:	05/16/2006
--->

<cfcomponent displayname="Budget Basic Info" hint="Budget Basic Info" extends="components.budget.Budget">

	<!------ properties ----->
	
	<cfset this.planningTolerance 		= 0 />
	<cfset this.settlementTolerance 	= 0 />
	<cfset this.budgetLevels 			= ArrayNew(1) />
	<cfset this.claimAllocationMethod 	= 0 />
	<cfset this.controlLevel1 			= "" />
	<cfset this.controlLevel2 			= "" />
	<cfset this.controlLevel1FilterOn 	= 0 />
	<cfset this.controlLevel2FilterOn 	= 0 />
	<cfset this.controlLevel1_filterlist= "" />
	<cfset this.controlLevel2_filterlist= "" />
	<cfset this.controlLevel1_filterListValues = "" />
	<cfset this.controlLevel2_filterListValues = "" />

			
	<cfset this.Allocation_Type = CreateObject("component", "components.budget.AllocationType") />
	
	<cffunction name="init" access="public" returntype="components.budget.BudgetBasicInfo">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	<cfinclude template="BudgetBasicInfo/getBudget.cfm" />
	<cfinclude template="BudgetBasicInfo/getBudgetFromForm.cfm" />
	<cfinclude template="BudgetBasicInfo/getBudgetControlLevelFilter.cfm" />
		
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	<cfinclude template="BudgetBasicInfo/saveBudgetControlLevelFilter.cfm" />
	
</cfcomponent>