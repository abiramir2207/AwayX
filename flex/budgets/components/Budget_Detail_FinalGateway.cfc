<cfcomponent output="false" alias="flex.budgets.components.Budgets_Detail_Final.Budget_Detail_FinalGateway">

	<cffunction name="save" output="false" access="public" returntype="void">
		<cfargument name="budgetId" required="true" type="numeric" />
 		
		<cfstoredproc procedure="BUDGET_SAVE" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Budget_ID" value="#arguments.budgetId#" null="no" />			
		</cfstoredproc>
		
	</cffunction>		

	<cffunction name="getAll" output="false" access="remote" returntype="flex.budgets.components.Budget_Detail_FinalBean[]">
		<cfargument name="budgetId" type="numeric" required="true">
		<cfset var qRead="">
		<cfset var obj="">
		<cfset var ret=arrayNew(1)>

		<cfquery name="qRead" datasource="#application.datasource#">
			select Budget_Detail_Allocation_ID
			from dbo.Budget_Detail_Allocation
			where budget_id = #arguments.budgetId#
		</cfquery>

		<cfloop query="qRead">
		<cfscript>
			obj = createObject("component", "Budget_Detail_FinalDAO").read(qRead.Budget_Detail_Allocation_ID,arguments.budgetId);
			ArrayAppend(ret, obj);
		</cfscript>
		</cfloop>
		<cfreturn ret>
	</cffunction>

	<cffunction name="getAllAsQuery" output="false" access="remote" returntype="query">
		<cfargument name="budgetId" type="numeric" required="true">
		<cfargument name="levels" type="numeric" required="true">

		<cfset var qRead = "" />
		<cfset var qGetControlLevelMetaData = "" />
		<cfset var BudgetGroupLevelManager = "" />
		<cfset var controlLevel1MetaData = "" />
		<cfset var controlLevel2MetaData = "" />
		<cfset var budgetValue = 0 />
		
		<cfquery name="qGetControlLevelMetaData" datasource="#application.datasource#">
			SELECT	Control_Level_1, Control_Level_2, Budget_Value
			FROM	Budget
			WHERE	Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfset BudgetGroupLevelManager = CreateObject("component", "components.settings.budget.BudgetGroupLevelManager").init() />
		<cfset controlLevel1MetaData = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = qGetControlLevelMetaData.Control_Level_1, active = -1) /> 
		<cfset controlLevel2MetaData = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = qGetControlLevelMetaData.Control_Level_2, active = -1) /> 
		<cfif isNumeric(qGetControlLevelMetaData.Budget_Value)>>
			<cfset budgetValue = qGetControlLevelMetaData.Budget_Value />
		</cfif>
		
		<cfif ArrayLen(controlLevel1MetaData) AND ArrayLen(controlLevel2MetaData)>
			<!------ TODO: handle for the case where there is no level 2 selected ----->
			<cfset BudgetGroupLevel_1 = controlLevel1MetaData[1] />
			<cfset BudgetGroupLevel_2 = controlLevel2MetaData[1] />

			<cfif arguments.levels EQ 2>
				<cfquery name="qRead" datasource="#application.datasource#">
					SELECT		Parent_Value, 	
								Budget_Detail_Allocation.Budget_ID, 
								#budgetValue# as Budget_Value,
								Budget_Detail_Allocation.Budget_Detail_Allocation_ID,
								Control_Level_1.#BudgetGroupLevel_1.numberField# as Control_Level_1_Number, 
								Control_Level_1.#BudgetGroupLevel_1.nameField# as Control_Level_1_Name, 
								Control_Level_2.#BudgetGroupLevel_2.numberField# as Control_Level_2_Number, 
								Control_Level_2.#BudgetGroupLevel_2.nameField# as Control_Level_2_Name,
								Budget_Detail_Allocation.Level_Value, 
								Budget_Detail_Allocation.Level_Value_Percentage,
								Budget_Detail_Allocation.New_Level_Value 
							+ Total_Manual_Quantity
							+ (Total_Manual_Percentage / 100) * #budgetValue# as New_Level_Value, 
							<cfif budgetValue NEQ 0>
								<!--- (NEW QTY / Budget Total) * 100 --->
								((Budget_Detail_Allocation.New_Level_Value 
								+ Total_Manual_Quantity
								+ (Total_Manual_Percentage / 100) * #budgetValue#) 
								/ #budgetValue#) * 100
							<cfelse>
								0
							</cfif> as New_Level_Value_Percentage,
								ISNULL(Total_Manual_Quantity,0) AS Manual_Qty, 
								ISNULL(Total_Manual_Percentage,0) AS Manual_Percentage, 
								'' AS Manual_Comments,
								'100' AS Budget_Adjustment_Change,
								#budgetValue# as BUDGET_VALUE
					FROM		Budget_Detail_Allocation
					LEFT JOIN	(SELECT CONTROL_LEVEL_1_ID, SUM(NEW_LEVEL_VALUE) AS PARENT_VALUE FROM BUDGET_DETAIL_ALLOCATION
									WHERE BUDGET_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
									GROUP BY CONTROL_LEVEL_1_ID) AS PARENT_DETAIL
								ON PARENT_DETAIL.CONTROL_LEVEL_1_ID = BUDGET_DETAIL_ALLOCATION.CONTROL_LEVEL_1_ID
					LEFT JOIN 	#BudgetGroupLevel_1.tableName# AS Control_Level_1
								ON	Control_Level_1.#BudgetGroupLevel_1.iDField# = Budget_Detail_Allocation.Control_Level_1_ID
					LEFT JOIN 	#BudgetGroupLevel_2.tableName# AS Control_Level_2
								ON	Control_Level_2.#BudgetGroupLevel_2.iDField# = Budget_Detail_Allocation.Control_Level_2_ID
					WHERE		Budget_Detail_Allocation.BUDGET_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
					ORDER BY	Control_Level_1.#BudgetGroupLevel_1.nameField#, 
								Control_Level_2.#BudgetGroupLevel_2.nameField#	
				</cfquery>
			<cfelse>
				<cfquery name="qRead" datasource="#application.datasource#">
					SELECT		Budget_Detail_Allocation.Budget_ID, 
								Budget_Detail_Allocation.Budget_Detail_Allocation_ID,
								Control_Level_1.#BudgetGroupLevel_1.numberField# as Control_Level_1_Number, 
								Control_Level_1.#BudgetGroupLevel_1.nameField# as Control_Level_1_Name, 
								Budget_Detail_Allocation.Level_Value, 
								Budget_Detail_Allocation.Level_Value_Percentage,
								Budget_Detail_Allocation.New_Level_Value, 
								Budget_Detail_Allocation.New_Level_Value_Percentage,
								ISNULL(Total_Manual_Quantity,0) AS Manual_Qty, 
								ISNULL(Total_Manual_Percentage,0) AS Manual_Percentage, 
								'' AS Manual_Comments,
								'100' AS Budget_Adjustment_Change,
								BUDGET.BUDGET_VALUE
					FROM		Budget_Detail_Allocation
					LEFT JOIN 	#BudgetGroupLevel_1.tableName# AS Control_Level_1
								ON	Control_Level_1.#BudgetGroupLevel_1.iDField# = Budget_Detail_Allocation.Control_Level_1_ID
					LEFT JOIN 	BUDGET
								ON BUDGET.BUDGET_ID = BUDGET_DETAIL_ALLOCATION.BUDGET_ID
					WHERE		Budget_Detail_Allocation.BUDGET_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
					ORDER BY	Control_Level_1.#BudgetGroupLevel_1.nameField#
				</cfquery>
			</cfif>
		</cfif>	
		
		<cfreturn qRead>
	</cffunction>

	<cffunction name="getBudgetBasicInfo" output="false" access="remote" returntype="query">
		<cfargument name="budgetid" required="true">
		<cfquery name="qGetBudgetInfo" datasource="#application.datasource#">
			select 	* 
			from 	budget 
			where 	budget_id = <cfqueryparam value="#arguments.budgetid#" cfsqltype="CF_SQL_INTEGER"> 
			and 	deleted = 0
		</cfquery>
		<cfreturn qGetBudgetInfo>
	</cffunction>
	
	<cffunction name="saveManualAdjustment" output="false" access="remote" returntype="void">
		<cfargument name="budgetId" type="numeric" required="true">
		<cfargument name="budgetAllocationId" type="numeric" required="true">
		<cfargument name="manualQuantity" type="numeric" required="true">
		<cfargument name="manualPercentage" type="numeric" required="true">
		<cfargument name="manualComment" type="string" required="true">
		<cfset var qInsertManualAdjustment="">
			
		<cfquery name="qInsertManualAdjustment" datasource="#application.datasource#">
			INSERT INTO Budget_Manual_Adjustment (Budget_ID, Budget_Detail_Allocation_ID, Manual_Quantity, Manual_Percentage, Manual_Comment)
			VALUES (<cfqueryparam value="#arguments.budgetId#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.budgetAllocationId#" cfsqltype="cf_sql_integer">,
					#arguments.manualQuantity#,
					#arguments.manualPercentage#,
					<cfqueryparam value="#arguments.manualComment#" cfsqltype="cf_sql_longvarchar">
					)
		</cfquery>

		<cfreturn />
	</cffunction>

	<cffunction name="saveWIP" output="false" access="remote" returntype="void">
		<cfargument name="budgetId" type="numeric" required="true">

		<cfstoredproc procedure="BUDGET_SAVE_WIP" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Budget_ID" value="#arguments.budgetId#" null="no" />			
		</cfstoredproc>

		<cfreturn />
		
	</cffunction>

</cfcomponent>