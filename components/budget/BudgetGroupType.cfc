<!---
Name: 			BudgetGroupType.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget Group Manager
Date Created:	05/09/2006
--->

<cfcomponent displayname="BudgetGroupType" hint="Budget Group Type">

	<!------ properties ----->
	<cfset this.budgetGroupTypeId = 0 />
	<cfset this.budgetGroupTypeCode = "" />
	<cfset this.budgetGroupTypeName = "" />
	
	<cffunction name="init" access="public" returntype="components.budget.BudgetGroupType">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	
</cfcomponent>