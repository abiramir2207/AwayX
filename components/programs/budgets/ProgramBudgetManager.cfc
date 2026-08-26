<!---  
       Name:    	  Program_Budget_Manager.cfc                   
       Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
       Created Date:  9/11/2006
       Created By:    Clarence Morse
       Description:   Contains functions for working with budgets in a program.
--->

<cfcomponent displayname="" hint="">
	<cffunction name="init" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<!--- Get Budgets Related to Program Template--->
		<cffunction name="getBudgetsFromTemplate" output="false" returntype="any" hint="Returns All Budgets assigned to Template">
			<cfargument name="template_id" type="numeric" required="true" />
			
			<!--- TODO: Move this to Template's CFC and replace this with call to that function. Get First Parent ID --->
			<cfquery name="qGetTemplateInfo" datasource="#application.datasource#">
				select first_parent_id 
				from program_control_panel_options
				where programcontrol_panel_options_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.template_id#">
			</cfquery>
						
			<cfquery name="qGetBudgets" datasource="#application.datasource#">
				SELECT budget_template_mappings.budget_reference_id, budget_name 
				FROM budget_template_mappings 
				LEFT JOIN budget on budget_template_mappings.budget_reference_id = budget.budget_reference_id
				WHERE template_parent_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#qGetTemplateInfo.first_Parent_ID#">
				and budget_template_mappings.deleted = 0
			</cfquery>
		
			<cfreturn qGetBudgets />
			
		</cffunction>
	
	<!--- Get Budget Assigned to Discount Type --->
		<cffunction name="getBudgetByDiscount" output="false" returntype="numeric" hint="Returns All Budgets assigned to Template">
			<cfargument name="program_id" type="numeric" required="true"/>
			<cfargument name="discount_type_id" type="numeric" required="true">
			
			<cfquery name="qGetBudgets" datasource="#application.datasource#">
				SELECT	budget_reference_id
				FROM	budget_program
				WHERE	program_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.program_id#">
				AND		discount_type_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.discount_type_id#">
			 	AND 	deleted = 0
			</cfquery>
			
			<cfif qGetBudgets.RecordCount GT 0>
				<cfreturn qGetBudgets.Budget_Reference_ID />
			<cfelse>
				<cfreturn 0 />
			</cfif>
		</cffunction>
		
	<!--- Set Budget Assigned to Discount Type --->
		<cffunction name="setBudgetsByDiscount" output="false" returntype="void" hint="Returns All Budgets assigned to Template">
			<cfargument name="program_id" type="numeric" required="true"/>
			<cfargument name="discount_type_id" type="numeric" required="true">
			<cfargument name="budget_reference_id" type="numeric" required="true">
			
			<cfquery name="checkBudgetRelationship" datasource="#application.datasource#">
				SELECT count(budget_program_id) As "bp_count"
				FROM  BUDGET_PROGRAM
				WHERE program_id = #arguments.program_id#
					  AND discount_type_id = #arguments.discount_type_id#
					  AND deleted = 0
			</cfquery>
			
			<cfif checkBudgetRelationship.bp_count GT 0>
				<cfquery name="updateBudgets" datasource="#application.datasource#">
					UPDATE BUDGET_PROGRAM
					SET	DELETED = 1
					WHERE PROGRAM_ID = #arguments.program_id#
					  AND discount_type_id = #arguments.discount_type_id#
					  AND DELETED = 0
				</cfquery>
			</cfif>
				
			<cfquery name="insertBudgets" datasource="#application.datasource#">
				INSERT INTO BUDGET_PROGRAM (program_id, discount_type_id, budget_reference_id,created_date,deleted)
							VALUES		   (#arguments.program_id#, #arguments.discount_type_id#, #arguments.budget_reference_id#,getDate(),0)
			</cfquery>
		</cffunction>
		
	<!--- Get Budget Assigned to Program --->
		<cffunction name="getProgramBudget" output="false" returntype="query" hint="Return Budgets assigned to Program">
			<cfargument name="program_id" required="true" type="numeric">
			
			<cfquery name="qGetBudgets" datasource="#application.datasource#">
				SELECT		contract_main.budget_reference_id, budget_name
				FROM		contract_main
				LEFT JOIN 	budget on contract_main.budget_reference_id = budget.budget_reference_id
				WHERE 		contract_main_id = '#arguments.program_id#'
							AND budget.deleted = 0
			</cfquery>
			
			<cfreturn qGetBudgets />
		</cffunction>
		
</cfcomponent>

