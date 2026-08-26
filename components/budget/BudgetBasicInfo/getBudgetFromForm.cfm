<!---
Name: 			getBudgetFromForm.cfm
Copyright:		(c) 2006 Blacksmith Applications, Inc.
Description:	I am responsible for getting the budget basic information data from teh form scope
Parameters:		N/A
Usage:			N/A
--->

<cffunction name="getBudgetFromForm" access="public" returntype="components.budget.BudgetBasicInfo" output="no" hint="I am responsible for getting the budget basic information data">
	
	<cfargument name="form" type="struct" required="true">

	<!------ radio, checkbox need to be paramed ----->
	<cfparam name="form.Planning_Tolerance" 	default="0">
	<cfparam name="form.Settlement_Tolerance" 	default="0">
	<cfparam name="form.Claim_Allocation_Method" 	default="0">
	
	<cfparam name="form.Control_Level_1_Filter_On" 	default="">
	<cfparam name="form.Control_Level_2_Filter_On" 	default="">	
	<cfparam name="form.levelSelection1_filter" 	default="">
	<cfparam name="form.levelSelection2_filter" 	default="">	
	
	<cfparam name="form.td_calc_method" 	default="">
	<cfparam name="form.bu_calc_method" 	default="">
	<cfparam name="form.ac_calc_method" 	default="">
	<cfparam name="form.rv_calc_method" 	default="">
	<cfparam name="form.hp_calc_method" 	default="">
	
	<!------ set budget properties ----->
	<cfset this.budgetId 				= form.id />
	<cfset this.budgetCode 				= form.Budget_Code />
	<cfset this.budgetName 				= form.Budget_Name />
	<cfset this.budgetStartDate 		= form.Budget_Start_Date />
	<cfset this.budgetEndDate 			= form.Budget_End_Date />
	<cfset this.planningTolerance 		= form.Planning_Tolerance />
	<cfset this.settlementTolerance 	= form.Settlement_Tolerance />

	<cfset this.budgetUOM 				= "" />
	
	<cfset this.controlLevel1 			= Val(form.levelSelection1) />
	<cfset this.controlLevel2 			= Val(form.levelSelection2) />
	<cfset this.controlLevel1FilterOn 	= Val(form.Control_Level_1_Filter_On) />
	<cfset this.controlLevel2FilterOn 	= Val(form.Control_Level_2_Filter_On) />
	<cfset this.controlLevel1_filterlist= form.levelSelection1_filter />
	<cfset this.controlLevel2_filterlist= form.levelSelection2_filter />

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

	<!------ get the descriptions for the selected groups ----->
	<cfset BudgetGroupLevelManager = CreateObject("component", "components.settings.budget.BudgetGroupLevelManager").init() />
	<cfif this.controlLevel1FilterOn>
		<cfset BudgetGroupLevel_1 = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = this.controlLevel1) />
		<cfset this.controlLevel1_filterListValues = BudgetGroupLevelManager.getBudgetGroupLevelValues(BudgetGroupLevel = BudgetGroupLevel_1[1], groupId = this.controlLevel1_filterList) />
	</cfif>
	<cfif this.controlLevel2FilterOn>
		<cfset BudgetGroupLevel_2 = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = this.controlLevel2) />
		<cfset this.controlLevel2_filterListValues = BudgetGroupLevelManager.getBudgetGroupLevelValues(BudgetGroupLevel = BudgetGroupLevel_2[1], groupId = this.controlLevel2_filterList) />
	</cfif>
	
	
	
	<cfset this.claimAllocationMethod 	= form.Claim_Allocation_Method />	
			
	<!----- Allocation Type Data ----->	
	<cfset this.allocation_type.id 		= form.allocation_type />

	<!----- Calculation Method ----->
	
	<cfswitch expression="#form.allocation_type#">
	
		<cfcase value="1"><!------ Top Down ----->
			
			<cfset this.budgetValue 								= form.td_dollars />
			<cfset this.allocation_type.calculation_method.id 		= form.td_calc_method />	
			<cfset this.allocation_type.calculation_method.levels	= form.td_levels />
				
			<cfif form.td_calc_method EQ "1"><!------ Invoiced Sales Dollars ----->
				<cfset this.allocation_type.calculation_method.start_date 		= form.td_Start_Date_1 />
				<cfset this.allocation_type.calculation_method.end_date 		= form.td_End_Date_1 />
			<cfelseif form.td_calc_method EQ "2"><!------ Invoiced Volume ----->
				<cfset this.allocation_type.calculation_method.start_date 		= form.td_Start_Date_2 />
				<cfset this.allocation_type.calculation_method.end_date 		= form.td_End_Date_2 />
			<cfelseif form.td_calc_method EQ "3"><!------ Prior Budget ----->
				<cfset this.allocation_type.calculation_method.budgetreference = form.td_prior_budget />
			</cfif>
		</cfcase>
	
		<cfcase value="2"><!------ Bottom Up ----->
			
			<cfset this.allocation_type.calculation_method.id 		= form.bu_calc_method />	
			
			<cfif form.bu_calc_method EQ "1"><!------ Prior Budget [available as a basis to adjust] ----->
				<cfset this.allocation_type.calculation_method.budgetreference = form.bu_prior_budget />
			<cfelseif form.bu_calc_method EQ "2"><!------ Manual ----->
				<!------ do nothing ----->
			</cfif>
		</cfcase>
	
		<cfcase value="3"><!------ Accrual ----->
			
			<cfset this.allocation_type.calculation_method.id 		= form.ac_calc_method />	
			
			<cfif form.ac_calc_method EQ "1"><!------ Invoice Volume ----->
				<cfset this.allocation_type.calculation_method.start_date 		= form.ac_start_date_1 />
				<cfset this.allocation_type.calculation_method.end_date 		= form.ac_end_date_1 />
			<cfelseif form.ac_calc_method EQ "2"><!------ Prior Budget ----->
				<cfset this.allocation_type.calculation_method.budgetreference 	= form.ac_prior_budget />
			</cfif>
		</cfcase>
	
		<cfcase value="4"><!------ Rate * Volume ----->
			
			<cfset this.allocation_type.calculation_method.id 		= form.rv_calc_method />	
			
			<cfif form.rv_calc_method EQ "1"><!------ Invoice Volume ----->
				<cfset this.allocation_type.calculation_method.start_date 		= form.rv_start_date_1 />
				<cfset this.allocation_type.calculation_method.end_date 		= form.rv_end_date_1 />
			<cfelseif form.rv_calc_method EQ "2"><!------ Prior Budget ----->
				<cfset this.allocation_type.calculation_method.budgetreference 	= form.rv_prior_budget />
			</cfif>	
		</cfcase>
	
		<cfcase value="5"><!------ Percent of Revenue ----->
			
			<cfset this.allocation_type.calculation_method.id 		= form.hp_calc_method />	
			
			<cfif form.hp_calc_method EQ "1"><!------ Historical Percent of Revenue ----->
				<cfset this.allocation_type.calculation_method.start_date 		= form.hp_start_date_1 />
				<cfset this.allocation_type.calculation_method.end_date 		= form.hp_end_date_1 />
			<cfelseif form.hp_calc_method EQ "2"><!------ Prior Budget ----->
				<cfset this.allocation_type.calculation_method.budgetreference 	= form.hp_prior_budget />
			</cfif>
		</cfcase>
		
	</cfswitch>
	
	<cfreturn this />	
		
</cffunction>



