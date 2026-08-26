<!---
Name: 			getBudgetGroup.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget group data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetGroup" access="public" returntype="components.budget.BudgetGroup" output="no" hint="I am responsible for getting the budget group data">
	
	<cfargument name="id" type="numeric" required="true">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = "" />
			
	<cfset var_returnVal = createObject("component", "components.budget.BudgetGroup").getBudgetGroup(id = arguments.id) />
	
	<cfreturn var_returnVal />	
		
</cffunction>
