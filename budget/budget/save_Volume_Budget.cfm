<!---
	Name: saveTradeBudget.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Description: Save BudgetBasicInfo
--->	

<cfquery name="saveTradeBudget" datasource="#application.datasource#">
Update 	Budget
Set		budget_name = '#BudgetBasicInfo.budgetName#',
		budget_start_date = '#BudgetBasicInfo.budgetStartDate#',
		budget_end_date = '#BudgetBasicInfo.budgetEndDate#',
		control_level_1 = '#BudgetBasicInfo.controlLevel1#',
		control_level_2 = '#BudgetBasicInfo.controlLevel2#',
		Control_Level_1_Filter_On = '#BudgetBasicInfo.controlLevel1FilterOn#',
		Control_Level_2_Filter_On = '#BudgetBasicInfo.controlLevel2FilterOn#',
		allocation_type_id = '#BudgetBasicInfo.Allocation_Type.id#',
		updated_by = '#request.accessstructure.user_id#',
		updated_date = getdate(),
		calc_method_id	  = '#BudgetBasicInfo.Allocation_Type.calculation_method.id#',
		calc_method_level = '#BudgetBasicInfo.Allocation_Type.calculation_method.levels#',
		calc_method_start_date = '#BudgetBasicInfo.Allocation_Type.calculation_method.start_date#',
		calc_method_end_date = '#BudgetBasicInfo.Allocation_Type.calculation_method.end_date#',
		calc_method_budget_reference = '#BudgetBasicInfo.Allocation_Type.calculation_method.budgetreference#'
WHERE	budget_id = #BudgetBasicInfo.budgetId#
</cfquery>

<!------ save the list of filter group ids for Control levels ----->
<cfset BudgetBasicInfo.saveBudgetControlLevelFilter(controlLevelIndex = 1) />
<cfset BudgetBasicInfo.saveBudgetControlLevelFilter(controlLevelIndex = 2) />
