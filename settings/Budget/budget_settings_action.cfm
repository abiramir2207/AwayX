<!---
	Name: 			budget_settings_action         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
    Author: 		Clarence Morse         
	Description:	Handler for Budget Control Panel Settings Page
--->	

		<!--- Get Budget Categories --->
		<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getCategoryID" budgetcategory_id="1" returnvariable="budgetCategories">  

		<!--- Control Levels --->
		<cfparam name="form.tradeControlLevels"	default="2"/>
		<cfparam name="form.volumeControlLevels" default="2"/>

		<!--- Allocation Types --->
		<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getAllocationTypes" budget_type="1" returnvariable="tradeBudgetAllocationType">    	
		<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getAllocationTypes" budget_type="2" returnvariable="volumeBudgetAllocationType">
		
		<cfloop from="1" to="#tradeBudgetAllocationType.Recordcount#" step="1" index="allocationIndex">
			<cfparam name="form.tradeAllocationType_#allocationIndex#" default="0"/>

			<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="updateAllocationTypes">
				<cfinvokeargument name="allocation_id" value="#allocationIndex#">
				<cfinvokeargument name="budget_type" value="1">
				<cfinvokeargument name="include" value="#evaluate("form.tradeAllocationType_#allocationIndex#")#">
			</cfinvoke>
		</cfloop>
		<cfparam name="form.tradeallocationtypeselection" default="0"/>	
			
		
		<cfloop from="1" to="#volumeBudgetAllocationType.Recordcount#" step="1" index="allocationIndex">
			<cfparam name="form.volumeAllocationType_#allocationIndex#" default="0"/>
			
			<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="updateAllocationTypes">
				<cfinvokeargument name="allocation_id" value="#allocationIndex#">
				<cfinvokeargument name="budget_type" value="2">
				<cfinvokeargument name="include" value="#evaluate("form.volumeAllocationType_#allocationIndex#")#">
			</cfinvoke>
		</cfloop>
		
		<cfparam name="form.volumeallocationtypeselection" default="0"/>	
		
		<!--- Volume UOM --->
		<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="getVolumeUOM" returnvariable="volumeUOM"> 	
		
		<cfloop from="1" to="#volumeUOM.RecordCount#" step="1" index="allocationIndex">
			<cfparam name="form.volumeuom_#allocationIndex#" default="0"/>
			
			<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="updateVolumeUOM">
				<cfinvokeargument name="volume_uom_id" value="#allocationIndex#">
				<cfinvokeargument name="include" value="#evaluate("form.volumeuom_#allocationIndex#")#">
			</cfinvoke>
		
		</cfloop>
		
		<cfparam name="form.volumeuomselection" default="0"/>
		
		<!--- Groups ---->
		<cfloop query="budgetCategories">
			<cfset sectionheader = trim(budgetCategories.Category_Desc) />
			<cfinvoke component="components.settings.budget.budgetsettingsmanager" 
			  method="getBudgetMasterData" 
			  budgetcategory_id="#budgetCategories.Category_ID#"
			  returnvariable="masterDataGroup">	
			
			<cfoutput query="masterDataGroup">
				<cfparam name="form.trade#sectionheader#group_#masterDataGroup.Budget_Group_Level_ID#" default="0"/> 
				<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="updateGroups">
				<cfinvokeargument name="budget_group_level_id" value="#masterDataGroup.Budget_Group_Level_ID#">
				<cfinvokeargument name="active" value="#evaluate("form.trade#sectionheader#group_#masterDataGroup.Budget_Group_Level_ID#")#">
				<cfinvokeargument name="budget_type" value="1">
				<cfinvokeargument name="user_id" value="#request.accessstructure.user_id#">
			</cfinvoke>
		</cfoutput>
			

			
			<cfparam name="form.trade#sectionheader#groupselection" default="0" />
		</cfloop>
		
		<cfloop query="budgetCategories">
			<cfset sectionheader = trim(budgetCategories.Category_Desc) />
			<cfinvoke component="components.settings.budget.budgetsettingsmanager" 
			  method="getBudgetMasterData" 
			  budgetcategory_id="#budgetCategories.Category_ID#"
			  returnvariable="masterDataGroup">	
			
			<cfoutput query="masterDataGroup">
				<cfparam name="form.volume#sectionheader#group_#masterDataGroup.Budget_Group_Level_ID#" default="0"/>
				<cfinvoke component="components.settings.budget.budgetsettingsmanager" method="updateGroups">
					<cfinvokeargument name="budget_group_level_id" value="#masterDataGroup.Budget_Group_Level_ID#">
					<cfinvokeargument name="active" value="#evaluate("form.volume#sectionheader#group_#masterDataGroup.Budget_Group_Level_ID#")#">
					<cfinvokeargument name="budget_type" value="2">
					<cfinvokeargument name="user_id" value="#request.accessstructure.user_id#">
				</cfinvoke> 
			</cfoutput>
			
			<cfparam name="form.volume#sectionheader#groupselection" default="0" />
		</cfloop>

		<cfinvoke component="components.settings.budget.budgetsettingsmanager" 
			  method="setSettings">
			<cfinvokeargument name="trade_control_levels" value="#form.tradecontrollevels#">
			<cfinvokeargument name="volume_control_levels" value="#form.volumecontrollevels#">
			<cfinvokeargument name="trade_allocation_type_selection" value="#form.tradeallocationtypeselection#">
			<cfinvokeargument name="volume_allocation_type_selection" value="#form.volumeallocationtypeselection#">
			<cfinvokeargument name="volume_uom_selection" value="#form.volumeuomselection#">
			<cfinvokeargument name="trade_product_group_selection" value="#form.tradeproductgroupselection#">
			<cfinvokeargument name="volume_product_group_selection" value="#form.volumeproductgroupselection#">
			<cfinvokeargument name="trade_sales_group_selection" value="#form.tradesalesgroupselection#">
			<cfinvokeargument name="volume_sales_group_selection" value="#form.volumesalesgroupselection#">
			<cfinvokeargument name="trade_customer_group_selection" value="#form.tradecustomergroupselection#">
			<cfinvokeargument name="volume_customer_group_selection" value="#form.volumecustomergroupselection#">
			<cfinvokeargument name="user_id" value="#request.accessstructure.user_id#">
		</cfinvoke>
		
		<cflocation url="budget_settings.cfm">