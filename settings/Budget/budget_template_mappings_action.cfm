<cfinvoke component="components.budget.budgetgroupmanager" method="getBudgetGroups" returnvariable="arBudgetGroups">
<cfinvoke component="components.programs.template.TemplateManager" method="getAll" returnvariable="qGetTemplates">


	<cfquery name="deleteMappings" datasource="#application.datasource#">
		update 	Budget_Template_Mappings 
		set 	deleted = 1, 
				deleted_on = getdate(),
				deleted_by = <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">				
		where 	deleted = 0
	</cfquery>

<cfset dumpstring = "">

<cfoutput>
	<cfset arLenBudgetGroups = ArrayLen(arBudgetGroups) />
	<!--- Loop Over Budget Groups --->
	<cfloop index="arBudgetGroupIdx" from="1" to="#arLenBudgetGroups#" step="1">
		<cfset arLenBudgetGroupMembers = ArrayLen(arBudgetGroups[arBudgetGroupIdx].budgetgroupmembers) />
			<!--- Looping Over Budget Group Members --->
			<cfloop index="arBudgetGroupMembersIdx" from="1" to="#arLenBudgetGroupMembers#" step="1">
				<cfset budget = arBudgetGroups[arBudgetGroupIdx].budgetgroupmembers[arBudgetGroupMembersIdx] />
				<!--- Loop Over Active Templates --->
				<cfloop query="qGetTemplates">
					<cfset fieldName = "form." & #PROGRAMCONTROL_PANEL_OPTIONS_ID# & "_" & #arBudgetGroups[arBudgetGroupIdx].BudgetGroupID# & "_" & #budget.budgetReferenceId# />
					<cfparam name="#fieldName#" default="0"> 					
					<cfset fieldValue = evaluate("#fieldName#") />
					<!---Insert New Mappings---->
						
						<cfquery name="insert_mappings" datasource="#application.datasource#">
							insert into budget_template_mappings
									(
									budget_reference_id, 
									template_parent_id, 
									active, 
									created_on, 
									created_by
									)
							values 	(
									<cfqueryparam value="#budget.budgetReferenceId#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#First_Parent_ID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#fieldValue#" cfsqltype="CF_SQL_BIT">,
									getdate(),
									<cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">
									)
						</cfquery>	
					
					
				</cfloop>	
			</cfloop>
		</table>
		<br>
	</cfloop>

	<cfparam name="form.viewmode" default="budget">
	
	<cflocation url="budget_template_mappings.cfm?viewmode=#form.viewmode#" addtoken="No">	
</cfoutput>
