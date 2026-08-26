<!---
Name: 			getBudget.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget basic information data
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudget" access="public" returntype="components.budget.BudgetBasicInfo" output="no" hint="I am responsible for getting the budget basic information data">
	
	<cfargument name="id" type="numeric" required="true">
	
	<!--- Initialize variables --->
	
			
	<cfif arguments.id>
		<!------ do query ----->
		<cfquery name="qGetBudget" datasource="#application.datasource#">
			SELECT	*
			FROM	Budget
			WHERE	Budget_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfloop query="qGetBudget">
		
			<!------ set budget properties ----->
			<cfset this.budgetId 				= Budget_ID />
			<cfset this.budgetCode 				= Budget_Code />
			<cfset this.budgetName 				= Budget_Name />
			<cfset this.budgetValue 			= Budget_Value />
			<cfset this.budgetUOM 				= Budget_UOM />
			<cfset this.budgetStartDate 		= Budget_Start_Date />
			<cfset this.budgetEndDate 			= Budget_End_Date />
			<cfset this.claimAllocationMethod 	= Claim_Allocation_Method />	
					
			<!------ set budget basic info properties ----->
			<cfset this.planningTolerance 		= Planning_Tolerance />
			<cfset this.settlementTolerance 	= Settlement_Tolerance />
			
			<!------ selected BudgetGroups ---->
			
			<cfset this.controlLevel1 			= Val(Control_Level_1) />
			<cfset this.controlLevel2 			= Val(Control_Level_2) />
			<cfset this.controlLevel1FilterOn 	= Val(Control_Level_1_Filter_On) />
			<cfset this.controlLevel2FilterOn 	= Val(Control_Level_2_Filter_On) />
			<cfset qBudgetControlLevelFilter1 	= getBudgetControlLevelFilter(controlLevelIndex = 1, budgetGroupLevelId = this.controlLevel1) />
			<cfset this.controlLevel1_filterList= ValueList(qBudgetControlLevelFilter1.Group_ID) />
			<cfset qBudgetControlLevelFilter2 	= getBudgetControlLevelFilter(controlLevelIndex = 2, budgetGroupLevelId = this.controlLevel2) />
			<cfset this.controlLevel2_filterList= ValueList(qBudgetControlLevelFilter2.Group_ID) />

			<!------ if filter = off, make the list empty,a nd also if teh list iis empty, make filter = off ----->
			<cfif this.controlLevel1FilterOn eq 0>
				<cfset this.controlLevel1_filterlist= "" />
			</cfif>
			<cfif len(this.controlLevel1_filterlist) eq 0>
				<cfset this.controlLevel1FilterOn = 0 />
			</cfif>
			<cfif this.controlLevel2FilterOn eq 0>
				<cfset this.controlLevel2_filterlist= "" />
			</cfif>
			<cfif len(this.controlLevel2_filterlist) eq 0>
				<cfset this.controlLevel2FilterOn = 0 />
			</cfif>			
			
			<cfset BudgetGroupLevelManager = CreateObject("component", "components.settings.budget.BudgetGroupLevelManager").init() />
			<cfif this.controlLevel1FilterOn>
				<cfset BudgetGroupLevel_1 = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = this.controlLevel1) />
				<cfset this.controlLevel1_filterListValues = BudgetGroupLevelManager.getBudgetGroupLevelValues(BudgetGroupLevel = BudgetGroupLevel_1[1], groupId = this.controlLevel1_filterList) />
			</cfif>
			<cfif this.controlLevel2FilterOn>
				<cfset BudgetGroupLevel_2 = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = this.controlLevel2) />
				<cfset this.controlLevel2_filterListValues = BudgetGroupLevelManager.getBudgetGroupLevelValues(BudgetGroupLevel = BudgetGroupLevel_2[1], groupId = this.controlLevel2_filterList) />
			</cfif>
			
			<!----- Allocation Type Data ----->
			
			<cfset this.allocation_type.id 		= Allocation_Type_ID />
			
			<!----- Calculation Method ----->
			<cfset this.allocation_type.calculation_method.id = Calc_Method_ID />
			<cfset this.allocation_type.calculation_method.levels			= Calc_Method_Level />
			<cfset this.allocation_type.calculation_method.start_date = Calc_Method_Start_Date>
			<cfset this.allocation_type.calculation_method.end_date = Calc_Method_End_Date>
			<cfset this.allocation_type.calculation_method.budgetreference = calc_method_budget_reference />
		</cfloop>
		
	</cfif>
	
	<cfreturn this />	
		
</cffunction>
