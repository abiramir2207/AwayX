<!---  
       Name:          allocateBudget.cfm             
       Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
       Created Date:  <date>
       Created By:    Clarence Morse
       Description:   
--->

<cfset BudgetBasicInfo = CreateObject("component", "components.budget.BudgetBasicInfo").init() />
<cfset BudgetBasicInfo = BudgetBasicInfo.getBudget(form.id) />


<cfif form.command EQ "editBudgetAllocation">
	<cfif BudgetBasicInfo.Allocation_Type.ID EQ 1>
		<cfset TopDown = CreateObject("component", "components.budget.TopDown").init() />		
		<cfset qAllocationdata = TopDown.getAllocationData(budgetId = form.id) />
		<cfinclude template="view/topdown_2_levels.cfm" />
	<cfelseif BudgetBasicInfo.Allocation_Type.ID EQ 2>
		<cfinclude template="view/bottomup.cfm" />
	<cfelseif BudgetBasicInfo.Allocation_Type.ID EQ 3>
		<!--- Allocation Type: --->
		<cfset AllocationType = CreateObject("component","components.budget.AllocationType").init() />
		<cfset qAllocationData = AllocationType.getAllocationData(budgetId = form.id) />
		
		<!--- Allocation Data Total --->
		<cfquery name="qAllocationDataTotal" dbtype="query">
			select 	SUM(LEVEL_VALUE) AS LEVEL_VALUE
			from	qAllocationData
			Order By control_level_2_name
		</cfquery> 
		
		<!--- Allocation Data Summary --->
		<cfquery name="qAllocationDataSummary" dbtype="query">
			select 	Control_Level_2_Name, SUM(LEVEL_VALUE) AS LEVEL_VALUE
			from	qAllocationData
			Group By control_level_2_name
			Order By control_level_2_name
		</cfquery> 
		
		
		<cfinclude template="view/accrual.cfm" />
			
	<cfelseif BudgetBasicInfo.Allocation_Type.ID EQ 4>
		<cfinclude template="view/rate_volume.cfm" />	
	<cfelseif BudgetBasicInfo.Allocation_Type.ID EQ 5>
		<cfinclude template="view/percent_of_revenue.cfm" />	
	</cfif>
<cfelse>
    <cfdump var="#BudgetBasicInfo#" />
</cfif>



