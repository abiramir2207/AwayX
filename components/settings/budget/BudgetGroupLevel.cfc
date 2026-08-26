<!---
Name: 			BudgetGroupLevel.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget
Date Created:	08/14/2006
--->

<cfcomponent displayname="BudgetGroupLevel" hint="Budget Group Level">

	<!------ properties ----->
	<cfset this.budgetGroupLevelId = 0 />
	<cfset this.groupLevelId = 0 />
	<cfset this.budgetcategoryGroupId = "" />
	<cfset this.tableName = "" />
	<cfset this.description = "" />
	<cfset this.internalDescription = "" />
	<cfset this.masterIDField = "" />
	<cfset this.iDField = "" />
	<cfset this.numberField = "" />
	<cfset this.nameField = "" />

	<cffunction name="init" access="public" returntype="components.settings.budget.BudgetGroupLevel">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
		
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
		
</cfcomponent>