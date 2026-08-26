<!---
Name: 			saveBudgetGroupMembers.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for saving the budgets inside each budget group
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="saveBudgetGroupMembers" access="public" returntype="void" output="no" hint="I am responsible for saving the budgets inside each budget group">
	
	<cfargument name="arBudget" type="array" required="true">
	
	<!--- Initialize variables --->
	<cfset var var_arrayLength = 0 />
	
	<cfset var_arrayLength = ArrayLen(arguments.arBudget) />
	
	<cfloop from="1" to="#var_arrayLength#" index="i">
		
		<cfset arguments.arBudget[i].saveBudget() />
		
	</cfloop>
		
</cffunction>
