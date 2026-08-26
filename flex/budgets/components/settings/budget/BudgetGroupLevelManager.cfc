<!---
Name: 			BudgetGroupLevelManager.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget
Date Created:	08/14/2006
--->

<cfcomponent displayname="BudgetGroupLevelManager" hint="Budget Group Level Manager">

	<!------ properties ----->
	<cfset this.budgetGroupLevels = ArrayNew(1) />
	
	<cffunction name="init" access="public" returntype="flex.budgets.components.settings.budget.BudgetGroupLevelManager">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	<cfinclude template="BudgetGroupLevelManager/getBudgetGroupLevel.cfm" />
		
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
		
</cfcomponent>