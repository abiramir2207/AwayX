<!---
Name: 			saveBudgetGroup.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for saving the budget group data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="saveBudgetGroup" access="public" returntype="void" output="no" hint="I am responsible for saving the budget group data">
	
	<cfargument name="BudgetGroup" type="components.budget.BudgetGroup" required="true">
	
	<cfset arguments.BudgetGroup.saveBudgetGroup() />
		
</cffunction>
