<!---
Name: 			AllocationType.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	AllocationType
Date Created:	05/08/2006
--->

<cfcomponent displayname="AllocationType" hint="AllocationType:1=Top Down, 2=Bottom Up, 3=Accrual, 4=Rate * Volume, 5=Percent of Revenue">

	<!------ properties ----->
	<cfset this.id = 0 />
	<cfset this.desc = "" />
	<cfset this.calculation_method = CreateObject("component", "components.budget.CalculationMethod") />

	<cffunction name="init" access="public" returntype="components.budget.AllocationType">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
		<cfinclude template="AllocationType/getAllocationData.cfm" />
		
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
		
</cfcomponent>