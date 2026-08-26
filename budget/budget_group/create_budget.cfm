<!---      
	Name:          	create_budget.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will handle the logic for adding and editing high level information about budgets belonging to this budget group
	Parameters:    	command - keyword for the current action,
					id - ID for teh current budget group
	Usage:         	command=createBudget,saveBudget
					id=6
--->
<cfif form.command eq "saveBudget">

	<!------ add the save logic ----->
	
	<!------ 1. set defaults ----->
	<cfparam name="form.Budget_Count" 	default="">
	<cfset budgetGroupId = form.id />
		
	<cfset arBudgets = ArrayNew(1) />
	<!------ 2. loop and populate array of budget objects ----->
	<cfloop list="#form.Budget_Count#" index="i">
	
		<cfparam name="form.Budget_ID_#i#" 			default="0">
		<cfparam name="form.Budget_Code_#i#" 		default="">
		<cfparam name="form.Budget_Name_#i#" 		default="">
		<cfparam name="form.Budget_Value_#i#" 		default="">
		<cfparam name="form.Budget_UOM_#i#" 		default="0">
		<cfparam name="form.Budget_Start_Date_#i#" 	default="">
		<cfparam name="form.Budget_End_Date_#i#" 	default="">
		
		<cfset budgetID 		= Evaluate("form.Budget_ID_#i#") />
		<cfif budgetID eq "">
			<cfset budgetID 	= 0 />
		</cfif>
		<cfset budgetCode 		= Evaluate("form.Budget_Code_#i#") />
		<cfset budgetName 		= Evaluate("form.Budget_Name_#i#") />
		<cfset budgetValue 		= Evaluate("form.Budget_Value_#i#") />
		<cfset budgetUOM 		= Evaluate("form.Budget_UOM_#i#") />
		<cfset budgetStartDate 	= Evaluate("form.Budget_Start_Date_#i#") />
		<cfset budgetEndDate 	= Evaluate("form.Budget_End_Date_#i#") />
		
		<cfif trim(budgetName) neq "">
			<cfset Budget = CreateObject("component", "components.budget.Budget").init() />
			
			<cfset Budget.budgetId 			= budgetID />
			<cfset Budget.budgetGroupId 	= budgetGroupId />
			<cfset Budget.budgetCode 		= budgetCode />
			<cfset Budget.budgetName 		= budgetName />
			<cfset Budget.budgetValue 		= budgetValue />
			<cfset Budget.budgetUOM 		= budgetUOM />
			<cfset Budget.budgetStartDate 	= budgetStartDate />
			<cfset Budget.budgetEndDate 	= budgetEndDate />
			<cfset Budget.userId 			= request.AccessStructure.User_ID />
			
			<cfset ArrayAppend(arBudgets, Budget) />
		</cfif>
		
	</cfloop>
	
	<!------ 3. call budgetGroupManager save budget group members ----->
	<cfset BudgetGroupManager.saveBudgetGroupMembers(arBudgets) />
	
	<!------ #. redirect ----->
	<cflocation addtoken="No" url="index.cfm" />
	
<cfelse>

	<!------ add the create/edit logic and display ----->
	
	<!------ 1. all get calls here ----->
	<cfset BudgetGroup = BudgetGroupManager.getBudgetGroup(form.id) />
	<cfset arBudgets = BudgetGroup.getBudgetGroupMembers(BudgetGroup.budgetGroupId) />
	
	<!------ create dummy entries ----->
	<cfset arLen = ArrayLen(arBudgets) />
	<cfloop from="#Evaluate("arLen + 1")#" to="#Evaluate("arLen + 1")#" index="i">
		<cfset Budget = CreateObject("component", "components.budget.Budget").init() />
		<cfset Budget.budgetId 			= 0 />
		<cfset Budget.budgetGroupId 	= BudgetGroup.budgetGroupId />
		<cfset Budget.budgetCode 		= BudgetGroup.BudgetGroupCode + i />
		<cfset Budget.budgetName 		= "" />
		<cfset Budget.budgetValue 		= "" />
		<cfset Budget.budgetUOM 		= BudgetGroup.budgetGroupUOM />
		<cfset Budget.budgetStartDate 	= BudgetGroup.budgetGroupStartDate />
		<cfset Budget.budgetEndDate 	= BudgetGroup.budgetGroupEndDate />
		<cfset ArrayAppend(arBudgets, Budget) />
	</cfloop>
			
	<!------ 2. include display logic ----->
	<cfinclude template="view/create_budget.cfm" />
	

</cfif>