<!---
Name: 			getClaimAllocationMethods.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the claim allocation method data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getClaimAllocationMethods" access="public" returntype="array" output="no" hint="I am responsible for getting the claim allocation method data">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = ArrayNew(1) />
	<cfset var var_claimAllocationMethod = "" />
			
	<!------ do query ----->
	
	<!------ loop and populate var_budgetGroupType and add to the array  ----->
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	
	<cfif appSettings.getClaimAllocationMethodItem() EQ 1>
		<cfset var_claimAllocationMethod = CreateObject("component", "components.budget.ClaimAllocationMethod").init() />
		<cfset var_claimAllocationMethod.claimAllocationMethodId 	= 1 />
		<cfset var_claimAllocationMethod.claimAllocationMethodCode 	= "Item" />
		<cfset var_claimAllocationMethod.claimAllocationMethodName 	= "Item" />
		<cfset ArrayAppend(var_returnVal, var_claimAllocationMethod) />
	</cfif>
	
	<cfif appSettings.getClaimAllocationMethodFixed() EQ 1>
		<cfset var_claimAllocationMethod = CreateObject("component", "components.budget.ClaimAllocationMethod").init() />
		<cfset var_claimAllocationMethod.claimAllocationMethodId 	= 2 />
		<cfset var_claimAllocationMethod.claimAllocationMethodCode 	= "Fixed" />
		<cfset var_claimAllocationMethod.claimAllocationMethodName 	= "Fixed" />
		<cfset ArrayAppend(var_returnVal, var_claimAllocationMethod) />
	</cfif>

	<cfif appSettings.getClaimAllocationMethodFund() EQ 1>
		<cfset var_claimAllocationMethod = CreateObject("component", "components.budget.ClaimAllocationMethod").init() />
		<cfset var_claimAllocationMethod.claimAllocationMethodId 	= 3 />
		<cfset var_claimAllocationMethod.claimAllocationMethodCode 	= "Fund" />
		<cfset var_claimAllocationMethod.claimAllocationMethodName 	= "Fund" />
		<cfset ArrayAppend(var_returnVal, var_claimAllocationMethod) />
	</cfif>
	
	<cfreturn var_returnVal />	
		
</cffunction>
