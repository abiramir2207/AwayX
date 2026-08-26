<!------ 
	Name:          	edit_trade_budget.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/11/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will handle the logic for edit basic info page for budget
	Parameters:    	command - keyword for the current action,
					id - ID for the current budget
	Usage:         	command=editTradeBudget,saveTradeBudget
					id=6
----->

<cfset BudgetBasicInfo = CreateObject("component", "components.budget.BudgetBasicInfo").init() />

<cfif form.command eq "saveTradeBudget">
	<cfset BudgetBasicInfo = BudgetBasicInfo.getBudgetFromForm(form) />
	<cfinclude template="save_Trade_Budget.cfm">
	<cflocation url="index.cfm?command=editTradeBudget&id=#form.id#" />
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
	<cfinclude template="view/edit_trade_budget.cfm" />
	
	<input type="Hidden" name="formReload" value="1" />

</cfif>