<!---      
	Name:          	list_budget_group.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will handle the logic to display the list of budget groups and budgets
	Parameters:    	command - keyword for the current action,
					id - ID for teh current budget group, if command = add, id = 0
	Usage:         	command=listActiveBudgetGroup,listInActiveBudgetGroup
					id=6
--->


<!------ add the add/edit logic and display, need to handle for active/inactive ----->


<!------ dummy logic ----->
<!------ <cfset qGetBudgetGroups = BudgetGroupManager.getBudgetGroups() /> ----->
<cfset arBudgetGroups = BudgetGroupManager.getBudgetGroups() />
<!------ <cfset arBudgets = BudgetGroup.getBudgetGroupMembers(BudgetGroup.budgetGroupId) /> ----->

<!------ display code ----->
<cfinclude template="view/list_budget_group.cfm" />