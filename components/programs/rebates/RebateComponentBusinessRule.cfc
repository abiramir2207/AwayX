<cfcomponent>

	<cffunction name="init" output="false" returntype="components.programs.rebates.RebateComponentBusinessRule">
	
		<cfreturn this />
	
	</cffunction>
	
	<cffunction name="getRules" output="false" returntype="query">
		
		<cfquery name="qGetBusinessRules" datasource="#application.datasource#">
			
			SELECT	Program_Rebates_Component_Rule_ID,
					Rebates_Component_Rule_Desc,
					Unit_Of_Measure_ID,
					Cost_Impact,
					Cost_Impact_UOM
			FROM	Program_Rebates_Component_Rule
			WHERE	Deleted = 0
			
		</cfquery>
		
		<cfreturn qGetBusinessRules />
		
	</cffunction>
	
	<cffunction name="getComponentRules" output="false" returntype="query">
	
		<cfargument name="compId" required="false" default="0" />
		<cfargument name="selectedRules" required="false" default="0" />
		
		<cfquery name="qGetBusinessRules" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,30)#">
			SELECT	Program_Rebates_Component_Rule.Program_Rebates_Component_Rule_ID,
					Program_Rebates_Component_Rule.Rebates_Component_Rule_Desc,
					Program_Rebates_Component_Rule.Unit_Of_Measure_ID,
					Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Rule_ID as Joined_Rule_Id
			FROM	Program_Rebates_Component_Rule
					LEFT OUTER JOIN Program_Rebates_Component_Name_Rule
					ON Program_Rebates_Component_Rule.Program_Rebates_Component_Rule_ID = Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Rule_ID
					AND Program_Rebates_Component_Name_Rule.Deleted = 0
					AND Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Name_ID IN (#arguments.compId#)
			WHERE	Program_Rebates_Component_Rule.Deleted = 0
			<cfif trim(arguments.selectedRules) eq 1>
			AND		Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Rule_ID IS NOT NULL
			OR		Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Rule_ID != ''
			</cfif>
			
		</cfquery>
		
		<cfreturn qGetBusinessRules />
		
	</cffunction>
	
	<cffunction name="getCompRuleUoms" output="false" returntype="query">
	
		<cfargument name="compId" required="false" default="0" />
		
		<cfquery name="qGetBusinessRuleUoms" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,30)#">
			
			SELECT	Distinct(Program_Rebates_Component_Rule.Unit_Of_Measure_ID)
			FROM 	Program_Rebates_Component_Name_Rule
					INNER JOIN Program_Rebates_Component_Rule ON
					Program_Rebates_Component_Rule.Program_Rebates_Component_Rule_ID = Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Rule_ID
					AND Program_Rebates_Component_Rule.Deleted = 0
				
			WHERE 	Program_Rebates_Component_Name_Rule.Deleted = 0
			AND 	Program_Rebates_Component_Name_Rule.Program_Rebates_Component_Name_ID = #arguments.compId#
			
		</cfquery>
		
		<cfreturn qGetBusinessRuleUoms />
		
	</cffunction>
	
	<cffunction name="applyRules" output="false">
	
		<cfargument name="componentId" required="false" default="" />
		<cfargument name="lRuleIds" required="false" default="" />
		<cfargument name="required" required="false" default="" />
		
		<cftransaction action="begin">
		
			<!---update the components name table and set whether the rule is required or not--->
			<cfquery name="qUpdateCompRules" datasource="#application.datasource#">
				
				UPDATE	Program_Rebates_Component_Name
				SET		Has_Rules = 1,		
						Rule_Required = #arguments.required#
				WHERE	Program_Rebates_Component_Name_ID = #arguments.componentId#
				AND		Deleted = 0
				
			</cfquery>
			
			<!---set deleted to 1 for all comp rules for this comp--->
			<cfquery name="qUpdateCompRules" datasource="#application.datasource#">
				
				UPDATE	Program_Rebates_Component_Name_Rule
				SET		Deleted = 1
				WHERE	Program_Rebates_Component_Name_ID = #arguments.componentId#
				AND		Deleted = 0
				
			</cfquery>
			
			<!---now loop over list of rule id's and insert--->
			<cfloop index="indx" list="#arguments.lRuleIds#">
				
				<cfquery name="qGetBusinessRules" datasource="#application.datasource#">
				
					INSERT INTO Program_Rebates_Component_Name_Rule
						(Program_Rebates_Component_Name_ID, Program_Rebates_Component_Rule_ID)
					VALUES
						(#arguments.componentId#, #indx#)
						
				</cfquery>
			
			</cfloop>
			
		<cftransaction action="commit" />
		
		</cftransaction>
		
	</cffunction>
   
   	<cffunction name="commitRule" output="false">
	
		<cfargument name="ruleData" type="struct" required="true" default="" />
		
		<cftransaction action="begin">
		
			<!---if we have a rule id then we know it's an update so update rule data--->
			<cfif trim(arguments.ruleData.ruleId) neq 0>
			
				<cfquery name="qUpdateCompRules" datasource="#application.datasource#">
				
					UPDATE	Program_Rebates_Component_Rule
					SET		Rebates_Component_Rule_Desc = '#arguments.ruleData.Rebates_Component_Rule_Desc#',		
							Unit_Of_Measure_ID = #arguments.ruleData.Unit_Of_Measure_ID#,
							Cost_Impact = '#arguments.ruleData.Cost_Impact#',
							Cost_Impact_UOM = #arguments.ruleData.Cost_Impact_UOM#
					WHERE	Program_Rebates_Component_Rule_ID = #arguments.ruleData.ruleId#
					AND		Deleted = 0
				
				</cfquery>
			
			<!---otherwise it's a new rule so insert--->
			<cfelse>
						
				<cfquery name="qUpdateCompRules" datasource="#application.datasource#">
				
					INSERT INTO Program_Rebates_Component_Rule
						(Rebates_Component_Rule_Desc, Unit_Of_Measure_ID, Cost_Impact, Cost_Impact_UOM)
					VALUES
						('#arguments.ruleData.Rebates_Component_Rule_Desc#', #arguments.ruleData.Unit_Of_Measure_ID#, '#arguments.ruleData.Cost_Impact#', #arguments.ruleData.Cost_Impact_UOM#)
				
				</cfquery>
			
			</cfif>

		<cftransaction action="commit" />
		
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="deleteRule" output="false">
	
		<cfargument name="ruleId" required="false" default="" />
		
		<cfquery name="qDeleteBusRule" datasource="#application.datasource#">
		
			UPDATE	Program_Rebates_Component_Rule
			SET		Deleted = 1
			WHERE	Program_Rebates_Component_Rule_ID = #arguments.ruleId#
			AND		Deleted = 0
		
		</cfquery>

	</cffunction>
	
</cfcomponent>