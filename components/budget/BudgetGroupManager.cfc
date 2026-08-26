<!---
Name: 			BudgetGroupManager.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Budget Group Manager
Date Created:	05/08/2006
--->

<cfcomponent displayname="BudgetGroupManager" hint="Budget Group Manager">

	<cffunction name="init" access="public" returntype="components.budget.BudgetGroupManager">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	<cfinclude template="BudgetGroupManager/getBudgetGroup.cfm" />
	<cfinclude template="BudgetGroupManager/getBudgetGroups.cfm" />
	
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	<cfinclude template="BudgetGroupManager/saveBudgetGroup.cfm" />	
	<cfinclude template="BudgetGroupManager/saveBudgetGroupMembers.cfm" />	
	
</cfcomponent>