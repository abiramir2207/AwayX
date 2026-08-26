<!---
Name: 			ClaimAllocationMethod.cfc
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description: 	Claim Allocation Method
Date Created:	05/16/2006
--->

<cfcomponent displayname="ClaimAllocationMethod" hint="Claim Allocation Method">

	<!------ properties ----->
	<cfset this.claimAllocationMethodId = 0 />
	<cfset this.claimAllocationMethodCode = "" />
	<cfset this.claimAllocationMethodName = "" />
	
	<cffunction name="init" access="public" returntype="components.budget.ClaimAllocationMethod">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	
</cfcomponent>