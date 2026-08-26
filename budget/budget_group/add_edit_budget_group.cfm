<!---      
	Name:          	add_edit_budget_group.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will handle the logic for add edit budget group
	Parameters:    	command - keyword for the current action,
					id - ID for teh current budget group, if command = add, id = 0
	Usage:         	command=addEditBudgetGroup,saveBudgetGroup
					id=6
--->
<cfif form.command eq "saveBudgetGroup">

	<!------ add the save logic ----->
	
	<!------ set defaults ----->
	<cfparam name="form.Budget_Group_Code" 			default="">
	<cfparam name="form.Budget_Group_Name" 			default="">
	<cfparam name="form.Budget_Group_Value" 		default="">
	<cfparam name="form.Budget_Group_UOM" 			default="">
	<cfparam name="form.Budget_Group_Start_Date" 	default="">
	<cfparam name="form.Budget_Group_End_Date" 		default="">
	<cfparam name="form.Budget_Group_Type" 			default="">
	
	<!------ 1. do dummy get ----->
	<cfset BudgetGroup = BudgetGroupManager.getBudgetGroup(0) />
	
	<!------ 2. do the sets from form scope ----->
	<cfset BudgetGroup.budgetGroupId 		= form.id />
	<cfset BudgetGroup.budgetGroupCode 		= form.Budget_Group_Code />
	<cfset BudgetGroup.budgetGroupName 		= form.Budget_Group_Name />
	<cfset BudgetGroup.budgetGroupValue 	= form.Budget_Group_Value />
	<cfset BudgetGroup.budgetGroupUOM 		= form.Budget_Group_UOM />
	<cfset BudgetGroup.budgetGroupStartDate = form.Budget_Group_Start_Date />
	<cfset BudgetGroup.budgetGroupEndDate 	= form.Budget_Group_End_Date />
	<cfset BudgetGroup.budgetGroupTypeId 	= form.Budget_Group_Type />
	
	<!------ 3. call the save ----->
	<cfset BudgetGroupManager.saveBudgetGroup(BudgetGroup) />
	
	<!------ 4. redirect ----->
	<cflocation addtoken="No" url="index.cfm" />
	
<cfelse>

	<!------ add the add/edit logic and display ----->
	
	<!------ 1. all get calls here ----->
	<cfset BudgetGroup = BudgetGroupManager.getBudgetGroup(form.id) />
	<cfset BudgetGroupTypeManager = CreateObject("component", "components.budget.BudgetGroupTypeManager").init() />
	<cfset arBudgetGroupTypes = BudgetGroupTypeManager.getBudgetGroupTypes() />
	
	<cfset bAdd = 1 />
	<cfif form.id neq 0>
		<cfset bAdd = 0 />
	</cfif>
	
	<!------ 2. include display logic ----->
	<cfinclude template="view/add_edit_budget_group.cfm" />
	

</cfif>