<!------ 
	Name:          	edit_volume_budget.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	9/08/2006
	Created By:    	Clarence Morse
	Description:   	This page will handle the logic for edit basic info page for budget
	Parameters:    	command - keyword for the current action,
					id - ID for the current budget
	Usage:         	command=editVolumeBudget,saveVolumeBudget
					id=6
----->

<cfset BudgetBasicInfo = CreateObject("component", "components.budget.BudgetBasicInfo").init() />

<cfif form.command eq "saveVolumeBudget">
	<cfset BudgetBasicInfo = BudgetBasicInfo.getBudgetFromForm(form) />
	<cfinclude template="save_Volume_Budget.cfm">
	<cflocation url="index.cfm?command=editVolumeBudget&id=#form.id#" />
<cfelse>
	
	<cfparam name="form.formReload" 	default="0">
	<SCRIPT SRC="/budget/budget/budget_basic_info.js"></SCRIPT>

	<!------ 1. all the get calls go here ----->
	<cfif form.formReload eq 0>		
		<cfset BudgetBasicInfo = BudgetBasicInfo.getBudget(form.id) />
	<cfelse>
		<cfset BudgetBasicInfo = BudgetBasicInfo.getBudgetFromForm(form) />
	</cfif>
	<cfset ClaimAllocationMethodManager = CreateObject("component", "components.budget.ClaimAllocationMethodManager").init() />
	<cfset arClaimAllocationMethods = ClaimAllocationMethodManager.getClaimAllocationMethods() />
	<cfset arBudgetGroups = BudgetGroupManager.getBudgetGroups() />
			
	<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getBudgetSettings" returnvariable="StrBudgetSettings">
	<cfif NOT isdefined("BudgetBasicInfo.Allocation_Type.id") OR len(BudgetBasicInfo.Allocation_Type.id) EQ 0>
		<cfset BudgetBasicInfo.Allocation_Type.id = StrBudgetSettings.budgetSettings.trade_allocation_type_selection />
	</cfif>
	
	
	<!------ 2. include display logic ----->
	<cfinclude template="view/edit_volume_budget.cfm" />

	<input type="Hidden" name="formReload" value="1" />
	
</cfif>