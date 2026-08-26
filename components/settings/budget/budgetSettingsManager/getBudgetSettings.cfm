<!---
	Name: getBudgetSettings.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		Get All Budget Settings in a Struct.
	Tip:
		<gotchas>
--->	

	<cffunction name="getBudgetSettings" output="false" access="remote" returntype="struct">
		<cfset var strBudgetSettings = StructNew() />
		
	 	<cfset temp = StructInsert(strBudgetSettings, "budgetTradeSalesGroupMaster", this.getactivebudgetmasterdata(1,1)) />
		<cfset temp = StructInsert(strBudgetSettings, "budgetTradeCustomerGroupMaster", this.getactivebudgetmasterdata(2,1)) />
		<cfset temp = StructInsert(strBudgetSettings, "budgetTradeProductGroupMaster", this.getactivebudgetmasterdata(3,1)) />
	 	<cfset temp = StructInsert(strBudgetSettings, "budgetVolumeSalesGroupMaster", this.getactivebudgetmasterdata(1,2)) />
		<cfset temp = StructInsert(strBudgetSettings, "budgetVolumeCustomerGroupMaster", this.getactivebudgetmasterdata(2,2)) />
		<cfset temp = StructInsert(strBudgetSettings, "budgetVolumeProductGroupMaster", this.getactivebudgetmasterdata(3,2)) />
	 	<cfset temp = StructInsert(strBudgetSettings, "budgetTradeAllocationType", this.getActiveAllocationTypes(1)) />
	 	<cfset temp = StructInsert(strBudgetSettings, "budgetVolumeAllocationType", this.getActiveAllocationTypes(2)) />
	 	<cfset temp = StructInsert(strBudgetSettings, "budgetVolumeUOM", this.getVolumeUOM()) />
		<cfset temp = StructInsert(strBudgetSettings, "budgetSettings", this.getSettings()) />
		
		<cfreturn strBudgetSettings />
	</cffunction>