<!---      
	Name:          	index.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page is the controller for budgets
	Parameters:    	command - keyword for the current action
	Usage:         	command=addEditBudgetGroup
--->

<!------ initialise variables ----->
<cfparam name="url.command" 	default="listActiveBudgetGroup">
<cfparam name="url.id" 	default="0">

<cfparam name="form.command" 	default="#url.command#">
<cfparam name="form.id" 	default="#url.id#">


<!------ load the primary objects ----->
<cfset BudgetGroupManager = CreateObject("component", "components.budget.BudgetGroupManager").init() />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Budgets</title>
	<!------ <LINK REL="STYLESHEET" TYPE="text/css" HREF="/budget/budget_style.css"> ----->
</head>

<body>

<style>
<cfinclude template="/budget/budget_style.css" />
<cfinclude template="/budget/budget_allocation.css" />
</style>


<cfinclude template="header.cfm" />

<form action="" method="post" name="frmBudget">

<cfswitch expression="#form.command#">

	<cfcase value="addEditBudgetGroup,saveBudgetGroup" delimiters=",">
		<cfinclude template="budget_group/add_edit_budget_group.cfm" />
	</cfcase>
	
	<cfcase value="listActiveBudgetGroup,listInActiveBudgetGroup" delimiters=",">
		<cfinclude template="budget_group/list_budget_group.cfm" />
	</cfcase>
	
	<cfcase value="createBudget,saveBudget" delimiters=",">
		<cfinclude template="budget_group/create_budget.cfm" />
	</cfcase>
	
	<cfcase value="editTradeBudget,saveTradeBudget" delimiters=",">
		<cfinclude template="budget/edit_trade_budget.cfm" />
	</cfcase>
	
	<cfcase value="editVolumeBudget,saveVolumeBudget" delimiters=",">
		<cfinclude template="budget/edit_volume_budget.cfm" />
	</cfcase>
	
	
	<cfcase value="generateBudgetAllocation" delimiters=",">
		<cfinclude template="budget/generate_budget_data.cfm" />
	</cfcase>
		
	<cfcase value="saveBudgetAllocation,editBudgetAllocation" delimiters=",">
		<cfinclude template="budget/allocateBudget.cfm" />
	</cfcase>
	
</cfswitch>

<cfoutput>
<input type="Hidden" name="command" value="#form.command#" />
</cfoutput>

</form>

</body>
</html>
