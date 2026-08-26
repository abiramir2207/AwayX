<!---
Name: 			CalculationMethod.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	AllocationType
Date Created:	05/08/2006
--->

<cfcomponent displayname="CalculationMethod" hint="CalculationMethod">

	<!------ properties ----->
	<cfset this.id = 0 />
	<cfset this.levels = 0 />
	<cfset this.start_date = "" />
	<cfset this.end_date = "" />
	<cfset this.budgetreference = "" />

	<cffunction name="init" access="public" returntype="components.budget.CalculationMethod">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
		
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
		
</cfcomponent>