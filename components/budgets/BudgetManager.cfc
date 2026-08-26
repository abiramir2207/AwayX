<cfcomponent displayname="BudgetManager" hint="Budget Manager" extends="components.Base">

	<cfset this.budgetFunctionalityOnVar = 0 />
	
	<!---- labels ---->
	<cfset this.budgetDollarLabel = "" />
	<cfset this.committedDollarLabel = "" />
	<cfset this.budgetBalanceLabel = "" />
	<cfset this.approvedPaymentDollarLabel = "" />
	<cfset this.availableBudgetDollarLabel = "" />
	<cfset this.budgetClassAssociationLabel = "" />
	
	<!---- labels ---->
	<cfset this.BudgetDescription = "" />
	<cfset this.BudgetActive = 0 />
	<cfset this.BudgetID = 0 />
	<cfset this.BudgetDollar = "" />
	<cfset this.CommittedDollar = 0 />
	<cfset this.BudgetBalance = 0 />

	<cfset this.AllocationLevel = 0 />
	
	<!--- for advanced disaply --->
	<cfset this.BudgetConsumed = 0 />
	<cfset this.TimeExpired = 0 />
	<cfset this.PacingIndex = 0 />
	
	<cfset this.AvgCommittedDollar = 0 />
	<cfset this.CommittedProgramCount = 0 />

	<cffunction name="init" returntype="components.budgets.BudgetManager" output="false">
		<cfset this.budgetFunctionalityOnVar = application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="buildBudgetDescription" access="public" output="false" return="string">
		<cfargument name="budgetClassNumber" type="string" required="true" />
		<cfargument name="budgetClassDesc" type="string" required="true" />
		<cfargument name="budgetNumber" type="string" required="true" />
		<cfargument name="budgetDesc" type="string" required="true" />
		<cfreturn "#arguments.budgetClassNumber#:#arguments.budgetClassDesc# - #arguments.budgetNumber#:#arguments.budgetDesc#" />
	</cffunction>	
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Budget Settings ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="budgetFunctionalityOn" output="false" returntype="numeric">
		
		<cfreturn this.budgetFunctionalityOnVar />
		
	</cffunction>
	

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Selects ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->


	<cffunction name="getBudgetClass" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />

		<!--- get the Operating Groups --->
		<cfquery name="qGetBudgetClass" datasource="#application.datasource#">
			SELECT 	Simple_Budget_Class.*,
					Simple_Budget_Class.Deactivated_Date, Deactivated_User.Name_First + ' ' + Deactivated_User.Name_Last as Deactivated_By_Username,
					Simple_Budget_Class.Deleted_Date, Deleted_User.Name_First + ' ' + Deleted_User.Name_Last as Deleted_By_Username
			FROM 	Simple_Budget_Class			
			
			LEFT JOIN _Users as Deactivated_User
			ON		Deactivated_User.User_ID = Simple_Budget_Class.Deactivated_By
			
			LEFT JOIN _Users as Deleted_User
			ON		Deleted_User.User_ID = Simple_Budget_Class.Deleted_By
			
			WHERE	Simple_Budget_Class.Deleted = 0
			<cfif arguments.id NEQ 0>
				AND	Simple_Budget_Class.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.active NEQ -1>
				AND	Simple_Budget_Class.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">
			</cfif>
			ORDER BY Simple_Budget_Class.Simple_Budget_Class_Number
		</cfquery>
		<cfreturn qGetBudgetClass />
	</cffunction>
	
	
	<cffunction name="getBudget" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />

		<!--- get the Operating Groups --->
		<cfquery name="qGetBudget" datasource="#application.datasource#">
			SELECT 	Simple_Budget.*, 
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Deactivated_Date, Deactivated_User.Name_First + ' ' + Deactivated_User.Name_Last as Deactivated_By_Username,
					Simple_Budget.Deleted_Date, Deleted_User.Name_First + ' ' + Deleted_User.Name_Last as Deleted_By_Username
			FROM 	Simple_Budget

			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget.Simple_Budget_Class_ID
			
			LEFT JOIN _Users as Deactivated_User
			ON		Deactivated_User.User_ID = Simple_Budget.Deactivated_By
			
			LEFT JOIN _Users as Deleted_User
			ON		Deleted_User.User_ID = Simple_Budget.Deleted_By
			
			WHERE	Simple_Budget.Deleted = 0
			<cfif arguments.id NEQ 0>
				AND	Simple_Budget.Simple_Budget_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.active NEQ -1>
				AND	Simple_Budget.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">
			</cfif>
			ORDER BY Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget.Simple_Budget_Number
		</cfquery>
		<cfreturn qGetBudget />
	</cffunction>
	
	<cffunction name="getBudgetClassAssociation" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="classId" type="numeric" required="false" default="0" />
		<cfargument name="budgetId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />

		<!--- get records --->
		<cfquery name="qGetBudgetClassAssociation" datasource="#application.datasource#">
			SELECT 	Simple_Budget_Class_Association.*,
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class.Simple_Budget_Class_Desc, Simple_Budget_Class.Start_Date, Simple_Budget_Class.End_Date, 
					Simple_Budget.Simple_Budget_Number, Simple_Budget.Simple_Budget_Desc,
					Deactivated_User.Name_First + ' ' + Deactivated_User.Name_Last as Deactivated_By_Username,
					Deleted_User.Name_First + ' ' + Deleted_User.Name_Last as Deleted_By_Username
			FROM 	Simple_Budget_Class_Association
			
			INNER JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Class_Association.Simple_Budget_Class_ID
			
			INNER JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Class_Association.Simple_Budget_ID
			
			LEFT JOIN _Users as Deactivated_User
			ON		Deactivated_User.User_ID = Simple_Budget_Class_Association.Deactivated_By
			
			LEFT JOIN _Users as Deleted_User
			ON		Deleted_User.User_ID = Simple_Budget_Class_Association.Deleted_By
			
			WHERE	Simple_Budget_Class_Association.Deleted = 0
			<cfif arguments.id NEQ 0>
				AND	Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.classId NEQ 0>
				AND	Simple_Budget_Class_Association.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.budgetId NEQ 0>
				AND	Simple_Budget_Class_Association.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.active NEQ -1>
				AND	Simple_Budget_Class_Association.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">
			</cfif>
			ORDER BY Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget.Simple_Budget_Number
		</cfquery>
		<cfreturn qGetBudgetClassAssociation />
	</cffunction>
	
	<cffunction name="getBudgetsAndAssociations" output="false" returntype="query">
		<cfargument name="classId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		<cfargument name="includeInactiveIfAssociated" type="numeric" required="false" default="0" />

		<!--- get records --->
		<cfquery name="qGetBudgetsAndAssociations" datasource="#application.datasource#">
			SELECT 	Simple_Budget.Simple_Budget_ID, Simple_Budget.Simple_Budget_Number, Simple_Budget.Simple_Budget_Desc,
					Simple_Budget.Active as Budget_Active,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
					Simple_Budget_Class_Association.Active as Simple_Budget_Class_Association_Active
			FROM 	Simple_Budget
			
			LEFT JOIN Simple_Budget_Class_Association
			ON		Simple_Budget_Class_Association.Deleted = 0
			AND		Simple_Budget_Class_Association.Simple_Budget_ID = Simple_Budget.Simple_Budget_ID
			<cfif arguments.classId NEQ 0>
			AND		Simple_Budget_Class_Association.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			
			WHERE	Simple_Budget.Deleted = 0
			<cfif arguments.active NEQ -1>
				AND	(Simple_Budget.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">
				<cfif arguments.includeInactiveIfAssociated NEQ 0>
				OR	Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID IS NOT NULL
				</cfif>
				)
			</cfif>			
			ORDER BY Simple_Budget.Simple_Budget_Number
		</cfquery>
		<cfreturn qGetBudgetsAndAssociations />
	</cffunction>
	
	<cffunction name="getClassesAndAssociations" output="false" returntype="query">
		<cfargument name="budgetId" type="numeric" required="false" default="0" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		<cfargument name="includeInactiveIfAssociated" type="numeric" required="false" default="0" />

		<!--- get records --->
		<cfquery name="qGetClassesAndAssociations" datasource="#application.datasource#">
			SELECT 	Simple_Budget_Class.Simple_Budget_Class_ID, Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class.Simple_Budget_Class_Desc,
					Simple_Budget_Class.Active as Budget_Class_Active,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
					Simple_Budget_Class_Association.Active as Simple_Budget_Class_Association_Active
			FROM 	Simple_Budget_Class
			
			LEFT JOIN Simple_Budget_Class_Association
			ON		Simple_Budget_Class_Association.Deleted = 0
			AND		Simple_Budget_Class_Association.Simple_Budget_Class_ID = Simple_Budget_Class.Simple_Budget_Class_ID
			<cfif arguments.budgetId NEQ 0>
			AND		Simple_Budget_Class_Association.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			
			WHERE	Simple_Budget_Class.Deleted = 0
			<cfif arguments.active NEQ -1>
				AND	(Simple_Budget_Class.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">
				<cfif arguments.includeInactiveIfAssociated NEQ 0>
				OR	Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID IS NOT NULL
				</cfif>
				)
			</cfif>			
			ORDER BY Simple_Budget_Class.Simple_Budget_Class_Number
		</cfquery>
		<cfreturn qGetClassesAndAssociations />
	</cffunction>	
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Template level restriction ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="loadBudgetTemplateMapping" output="false" returntype="void">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="bAdvanced" type="boolean" required="false" default="0" />
		
		<cfset qBudgetTemplateMapping = getBudgetTemplateMapping(templateParentId = arguments.templateParentId, active = 1) />
		<cfif qBudgetTemplateMapping.recordCount>
			<cfset this.BudgetDescription = buildBudgetDescription(qBudgetTemplateMapping.Simple_Budget_Class_Number, qBudgetTemplateMapping.Simple_Budget_Class_Desc, qBudgetTemplateMapping.Simple_Budget_Number, qBudgetTemplateMapping.Simple_Budget_Desc) />
			<cfset this.BudgetActive = qBudgetTemplateMapping.Active />
			<cfset this.BudgetID = qBudgetTemplateMapping.Simple_Budget_ID />
			<cfset this.BudgetDollar = qBudgetTemplateMapping.Budget_Dollar />
			<cfset this.CommittedDollar = qBudgetTemplateMapping.Committed_Dollar />
			<cfset this.BudgetBalance = this.BudgetDollar - this.CommittedDollar />
			<cfset this.AllocationLevel = qBudgetTemplateMapping.Allocation_Level />
			
			<cfif arguments.bAdvanced>
				
				<cfquery name="qGetTemplateDateSettings" datasource="#application.datasource#">
					SELECT	Program_Min_Start_Date, Program_Max_End_Date
					FROM	Program_Control_Panel_Options
					WHERE	First_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
					AND		Deleted = 0
					AND		IsDominant = 1
				</cfquery>
				
				<cfset this.BudgetConsumed = this.CommittedDollar / this.BudgetDollar />
				<cfif IsDate(qGetTemplateDateSettings.Program_Min_Start_Date) and IsDate(qGetTemplateDateSettings.Program_Max_End_Date)>
					<cfset templateSpan = DateDiff("d", qGetTemplateDateSettings.Program_Min_Start_Date, qGetTemplateDateSettings.Program_Max_End_Date) + 1 />
					<cfset spanElapsed = DateDiff("d", qGetTemplateDateSettings.Program_Min_Start_Date, Now()) + 1 />
					<cfset this.TimeExpired = spanElapsed / templateSpan />
					<cfset this.PacingIndex = (this.BudgetConsumed / this.timeExpired) * 100 />
				</cfif>
				
			</cfif>
			
		</cfif>
	</cffunction>

	<cffunction name="loadBudgetTemplatePositionAllocation" output="false" returntype="void">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="userPositionId" type="numeric" required="true" />
		<cfargument name="budgetId" type="numeric" required="true" />
		<cfargument name="bAdvanced" type="boolean" required="false" default="0" />
		
		<cfset qBudgetTemplateMapping = getBudgetTemplateMapping(templateParentId = arguments.templateParentId, active = 1) />
		
		<cfif qBudgetTemplateMapping.recordCount>
			<cfset this.BudgetDescription = buildBudgetDescription(qBudgetTemplateMapping.Simple_Budget_Class_Number, qBudgetTemplateMapping.Simple_Budget_Class_Desc, qBudgetTemplateMapping.Simple_Budget_Number, qBudgetTemplateMapping.Simple_Budget_Desc) />
			<cfset this.BudgetActive = qBudgetTemplateMapping.Active />
			<cfset this.BudgetID = qBudgetTemplateMapping.Simple_Budget_ID />
			
			<cfset qGetBudgetTemplatePositionAllocationForPosition = getBudgetTemplatePositionAllocationForPosition(templateParentId = arguments.templateParentId, budgetId = arguments.budgetId, userPositionId = arguments.userPositionId) />
			<cfif qGetBudgetTemplatePositionAllocationForPosition.recordCount>
				<cfset this.BudgetDollar = qGetBudgetTemplatePositionAllocationForPosition.Budget_Dollar />
				<cfset this.CommittedDollar = qGetBudgetTemplatePositionAllocationForPosition.Committed_Dollar />
				<cfset this.BudgetBalance = this.BudgetDollar - this.CommittedDollar />
				
				<cfif arguments.bAdvanced>
				
				<cfquery name="qGetTemplateDateSettings" datasource="#application.datasource#">
					SELECT	Program_Min_Start_Date, Program_Max_End_Date
					FROM	Program_Control_Panel_Options
					WHERE	First_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
					AND		Deleted = 0
					AND		IsDominant = 1
				</cfquery>
				
				<cfset this.BudgetConsumed = this.CommittedDollar / this.BudgetDollar />
				<cfif IsDate(qGetTemplateDateSettings.Program_Min_Start_Date) and IsDate(qGetTemplateDateSettings.Program_Max_End_Date)>
					<cfset templateSpan = DateDiff("d", qGetTemplateDateSettings.Program_Min_Start_Date, qGetTemplateDateSettings.Program_Max_End_Date) + 1 />
					<cfset spanElapsed = DateDiff("d", qGetTemplateDateSettings.Program_Min_Start_Date, Now()) + 1 />
					<cfset this.TimeExpired = spanElapsed / templateSpan />
					<cfset this.PacingIndex = (this.BudgetConsumed / this.timeExpired) * 100 />
					
					<cfset this.AvgCommittedDollar = qGetBudgetTemplatePositionAllocationForPosition.Average_Committed_Dollar />
					<cfset this.CommittedProgramCount = qGetBudgetTemplatePositionAllocationForPosition.Program_Count />
				</cfif>
				
			</cfif>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="getBudgetProgramVersionDetails" output="false" returntype="query">
		<cfargument name="contractNumber" type="string" required="true" />
		
		<cfquery name="qGetBudgetProgramVersionDetails" datasource="#application.datasource#">			
			SELECT 	Contract_Main.Contract_Main_ID, Contract_Main.Revision_Version,
					Simple_Budget_Committed_Program_Detail.Simple_Budget_Class_ID, Simple_Budget_Committed_Program_Detail.Simple_Budget_ID,  
					Simple_Budget_Committed_Program_Detail.Allocation_Percent,
					Simple_Budget_Committed_Programs.Program_Spend
			FROM 	Contract_Main
			
			--INNER JOIN Contract_Main_Aux_Data with (nolock)
			--ON	Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
	
			INNER JOIN Simple_Budget_Committed_Programs
			ON	Simple_Budget_Committed_Programs.Program_ID = Contract_Main.Contract_Main_ID
	
			INNER JOIN Simple_Budget_Committed_Program_Detail
			ON		Simple_Budget_Committed_Program_Detail.Program_ID = Contract_Main.Contract_Main_ID
			
			INNER JOIN Simple_Budget_Class_Association
			ON		Simple_Budget_Class_Association.Simple_Budget_ID = Simple_Budget_Committed_Program_Detail.Simple_Budget_ID
			AND		Simple_Budget_Class_Association.Simple_Budget_Class_ID = Simple_Budget_Committed_Program_Detail.Simple_Budget_Class_ID
			
			INNER JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Committed_Program_Detail.Simple_Budget_ID
			
			INNER JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Committed_Program_Detail.Simple_Budget_Class_ID
			
			WHERE	Contract_Main.Contract_Number = <cfqueryparam value="#arguments.contractNumber#" cfsqltype="cf_sql_varchar">			
			AND		Contract_Main.Approved = 1
			ORDER BY Contract_Main.Revision_Version
		</cfquery>
		
		<cfreturn qGetBudgetProgramVersionDetails />
		
	</cffunction>
	
	
	<cffunction name="getBudgetTemplateProgramPositionAllocation" output="false" returntype="query">
		<cfargument name="contractNumber" type="string" required="true" />
		
		<cfquery name="qGetBudgetTemplateProgramPositionAllocation" datasource="#application.datasource#">			
			select 	simple_budget_class.simple_budget_class_number, 
				simple_budget_class.simple_budget_class_desc, 
				simple_budget.simple_budget_number,
				simple_budget.simple_budget_desc,
				user_positions.position_label, 
				sum(Simple_Budget_Template_Program_Position_Allocation.committed_dollar) as committed_dollar_allocation
			from	Simple_Budget_Template_Program_Position_Allocation
			
			inner join contract_main on contract_main.contract_main_id = Simple_Budget_Template_Program_Position_Allocation.contract_main_id
			inner join simple_budget_class on simple_budget_class.simple_budget_class_id = Simple_Budget_Template_Program_Position_Allocation.simple_budget_class_id
			inner join simple_budget on simple_budget.simple_budget_id = Simple_Budget_Template_Program_Position_Allocation.simple_budget_id
			inner join user_positions on user_positions.user_positions_id = Simple_Budget_Template_Program_Position_Allocation.user_positions_id
			
			where	Simple_Budget_Template_Program_Position_Allocation.contract_number = <cfqueryparam value="#arguments.contractNumber#" cfsqltype="cf_sql_varchar">
			
			group by 
				simple_budget_class.simple_budget_class_number, 
				simple_budget_class.simple_budget_class_desc, 
				simple_budget.simple_budget_number,
				simple_budget.simple_budget_desc,
				user_positions.position_label
			
			order by 
				simple_budget_class.simple_budget_class_number, 
				simple_budget_class.simple_budget_class_desc, 
				simple_budget.simple_budget_number,
				simple_budget.simple_budget_desc,
				user_positions.position_label
		</cfquery>
		
		<cfreturn qGetBudgetTemplateProgramPositionAllocation />
		
	</cffunction>
	
	<cffunction name="getBudgetTemplateProgramCommitted" output="false" returntype="query">
		<cfargument name="templateParentID" type="numeric" required="true" />
		<cfargument name="simpleBudgetClassID" type="numeric" required="true" />
		<cfargument name="simpleBudgetID" type="numeric" required="true" />
		
		<cfquery name="qGetBudgetTemplateProgramCommitted" datasource="#application.datasource#">
			select	Template_Parent_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Contract_Number, SUM(Committed_Dollar) as Committed_Dollar
			from	Simple_Budget_Template_Program_Position_Allocation
			where	Template_Parent_ID = <cfqueryparam value="#arguments.templateParentID#" cfsqltype="cf_sql_integer">
			and		Simple_Budget_Class_ID = <cfqueryparam value="#arguments.simpleBudgetClassID#" cfsqltype="cf_sql_integer">
			and		Simple_Budget_ID = <cfqueryparam value="#arguments.simpleBudgetID#" cfsqltype="cf_sql_integer">
			group By Template_Parent_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Contract_Number
			order By Template_Parent_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Contract_Number
		</cfquery>
		
		<cfreturn qGetBudgetTemplateProgramCommitted />
		
	</cffunction>	
	
	<cffunction name="getBudgetTemplateBillbackActual" output="false" returntype="query">
		<cfargument name="templateParentID" type="numeric" required="true" />
		<cfargument name="simpleBudgetClassID" type="numeric" required="true" />
		<cfargument name="simpleBudgetID" type="numeric" required="true" />
		
		<cfquery name="qGetBudgetTemplateBillbackActual" datasource="#application.datasource#">
			select	Template_Parent_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Contract_Number, Billback.BB_Code, SUM(Actual_Dollar) as Actual_Dollar
			from	Simple_Budget_Billback_Actual_Position_Allocation
			inner join Billback
			ON		Billback.Billback_ID = Simple_Budget_Billback_Actual_Position_Allocation.Billback_ID
			where	Template_Parent_ID = <cfqueryparam value="#arguments.templateParentID#" cfsqltype="cf_sql_integer">
			and		Simple_Budget_Class_ID = <cfqueryparam value="#arguments.simpleBudgetClassID#" cfsqltype="cf_sql_integer">
			and		Simple_Budget_ID = <cfqueryparam value="#arguments.simpleBudgetID#" cfsqltype="cf_sql_integer">
			group By Template_Parent_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Contract_Number, Billback.BB_Code
			order By Template_Parent_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Contract_Number, Billback.BB_Code
		</cfquery>
		
		<cfreturn qGetBudgetTemplateBillbackActual />
		
	</cffunction>	
	
	<cffunction name="getBudgetTemplateMappingForProgram" output="false" returntype="query">
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="userPositionId" type="numeric" required="true" />
		<cfargument name="returnOnlyIfSelectedInProgram" type="numeric" required="false" default="0" />
		<cfargument name="programApproval" type="numeric" required="true" />
		
		<cfstoredproc procedure="BUDGET_FOR_PROGRAM" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Template_Parent_ID" value = "#arguments.templateParentId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#arguments.programId#" null="no">
			
			<cfprocresult name="qBudgetTemplateMapping" />
				
		</cfstoredproc>
		
		
		<cfset arPositionBudgetDollar = ArrayNew(1) />
		<cfset arPositionCommittedDollar = ArrayNew(1) />
		<cfset arPositionActualDollar = ArrayNew(1) />
		<cfset arPositionBudgetBalance = ArrayNew(1) />
		
		<cfloop query="qBudgetTemplateMapping">
			<cfset qGetBudgetClassTemplatePositionAllocationForPosition = getBudgetClassTemplatePositionAllocationForPosition(
						templateParentId = arguments.templateParentId, 
						budgetId = Simple_Budget_ID, 
						classId = Simple_Budget_Class_ID,
						userPositionId = arguments.userPositionId) />
			<cfset iPositionBudgetDollar = 0 />
			<cfset iPositionCommittedDollar = 0 />
			<cfset iPositionActualDollar = 0 />
			<cfif qGetBudgetClassTemplatePositionAllocationForPosition.recordCount>
				<cfset iPositionBudgetDollar = qGetBudgetClassTemplatePositionAllocationForPosition.Budget_Dollar />
				<cfset iPositionCommittedDollar = qGetBudgetClassTemplatePositionAllocationForPosition.Committed_Dollar />
				<cfset iPositionActualDollar = qGetBudgetClassTemplatePositionAllocationForPosition.Actual_Dollar />
			</cfif>

			<cfif arguments.programApproval>
				<cfset iPositionCommittedDollar = iPositionCommittedDollar - Prev_Version_Committed_Dollar_Diff />
			</cfif> 
					
			<cfset arPositionBudgetDollar[currentRow] = iPositionBudgetDollar />	
			<cfset arPositionCommittedDollar[currentRow] = iPositionCommittedDollar />
			<cfset arPositionActualDollar[currentRow] = iPositionActualDollar />
			<cfif iPositionActualDollar gt iPositionCommittedDollar>
				<cfset arPositionBudgetBalance[currentRow] = iPositionBudgetDollar - iPositionActualDollar />
			<cfelse>
				<cfset arPositionBudgetBalance[currentRow] = iPositionBudgetDollar - iPositionCommittedDollar />
			</cfif>
		</cfloop>
		
		<cfset QueryAddColumn(qBudgetTemplateMapping, "Position_Budget_Dollar", arPositionBudgetDollar)>
		<cfset QueryAddColumn(qBudgetTemplateMapping, "Position_Committed_Dollar", arPositionCommittedDollar)>
		<cfset QueryAddColumn(qBudgetTemplateMapping, "Position_Actual_Dollar", arPositionActualDollar)>
		<cfset QueryAddColumn(qBudgetTemplateMapping, "Position_Budget_Balance", arPositionBudgetBalance)>
		
		<!----
		<cfif qBudgetTemplateMapping.recordCount>
			<cfset this.BudgetDescription = buildBudgetDescription(qBudgetTemplateMapping.Simple_Budget_Class_Number, qBudgetTemplateMapping.Simple_Budget_Class_Desc, qBudgetTemplateMapping.Simple_Budget_Number, qBudgetTemplateMapping.Simple_Budget_Desc) />
			<cfset this.BudgetActive = qBudgetTemplateMapping.Active />
			<cfset this.BudgetID = qBudgetTemplateMapping.Simple_Budget_ID />
			
			<cfset qGetBudgetTemplatePositionAllocationForPosition = getBudgetTemplatePositionAllocationForPosition(templateParentId = arguments.templateParentId, budgetId = arguments.budgetId, userPositionId = arguments.userPositionId) />
			<cfif qGetBudgetTemplatePositionAllocationForPosition.recordCount>
				<cfset this.BudgetDollar = qGetBudgetTemplatePositionAllocationForPosition.Budget_Dollar />
				<cfset this.CommittedDollar = qGetBudgetTemplatePositionAllocationForPosition.Committed_Dollar />
				<cfset this.BudgetBalance = this.BudgetDollar - this.CommittedDollar />
				
			</cfif>
		</cfif>
		---->
		<cfreturn qBudgetTemplateMapping />
	</cffunction>	
	
	
	<cffunction name="getBudgetDescription" access="public" output="false" return="string">
		<cfreturn this.BudgetDescription />
	</cffunction>
	
	<cffunction name="getBudgetActive" access="public" output="false" return="boolean">
		<cfreturn this.BudgetActive />
	</cffunction>
	
	<cffunction name="getBudgetID" access="public" output="false" return="numeric">
		<cfreturn this.BudgetID />
	</cffunction>	
		
	<cffunction name="getBudgetDollar" access="public" output="false" return="string">
		<cfreturn this.BudgetDollar />
	</cffunction>
	
	<cffunction name="getCommittedDollar" access="public" output="false" return="numeric">
		<cfreturn this.CommittedDollar />
	</cffunction>
	
	<cffunction name="getBudgetBalance" access="public" output="false" return="numeric">
		<cfreturn this.BudgetBalance />
	</cffunction>
	
	<cffunction name="getAllocationLevel" access="public" output="false" return="numeric">
		<cfreturn this.AllocationLevel />
	</cffunction>
	
	<cffunction name="getBudgetConsumed" access="public" output="false" return="numeric">
		<cfreturn this.BudgetConsumed />
	</cffunction>
	
	<cffunction name="getTimeExpired" access="public" output="false" return="numeric">
		<cfreturn this.TimeExpired />
	</cffunction>
	
	<cffunction name="getPacingIndex" access="public" output="false" return="numeric">
		<cfreturn this.PacingIndex />
	</cffunction>
	
	<cffunction name="getAvgCommittedDollar" access="public" output="false" return="numeric">
		<cfreturn this.AvgCommittedDollar />
	</cffunction>
	
	<cffunction name="getCommittedProgramCount" access="public" output="false" return="numeric">
		<cfreturn this.CommittedProgramCount />
	</cffunction>
	
	<cffunction name="geActivetTemplateBudget" output="false" returntype="numeric">
		<cfargument name="templateParentId" type="numeric" required="true" />
		
		<cfset qGetBudgetTemplateMapping = getBudgetTemplateMapping(templateParentId = arguments.templateParentId, active = 1) />
		
		<cfreturn Val(qGetBudgetTemplateMapping.Simple_Budget_ID) />
		
	</cffunction>
	
	<!------- will be called from template ----------->
	<cffunction name="getBudgetClassAssociationsForTemplate" output="false" returntype="query">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		<cfargument name="includeInactiveIfAssociated" type="numeric" required="false" default="0" />
		<cfargument name="includeOnlySelectedInTemplate" type="numeric" required="false" default="0" />
		<cfargument name="includeExtraBudgetList" type="string" required="false" default="" />
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetClassAssociationsForTemplate" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Class_Association.Simple_Budget_ID, Simple_Budget_Class_Association.Simple_Budget_Class_ID, 
					Simple_Budget_Template_Mapping.Budget_Dollar, ISNULL(Simple_Budget_Template_Mapping.Committed_Dollar, 0) as Committed_Dollar, 
					Simple_Budget_Template_Mapping.Allocation_Level,
					Simple_Budget_Class_Association.Active as Simple_Budget_Class_Association_Active,
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget_Class_Association.Active,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number
			FROM 	Simple_Budget_Class_Association
			
			LEFT JOIN Simple_Budget_Template_Mapping
			ON		Simple_Budget_Class_Association.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			AND		Simple_Budget_Class_Association.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			AND		Simple_Budget_Template_Mapping.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Active = 1
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			
			LEFT JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Class_Association.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Class_Association.Simple_Budget_Class_ID
			
			WHERE	1=1	
			<cfif arguments.active neq -1>
			AND		Simple_Budget_Template_Mapping.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">			
			</cfif>
			AND	Simple_Budget_Class_Association.Deleted = 0
			AND	(Simple_Budget_Class_Association.Active = 1
			<cfif arguments.includeInactiveIfAssociated NEQ 0>
			OR	Simple_Budget_Template_Mapping.Simple_Budget_ID IS NOT NULL
			</cfif>
			)
			<cfif arguments.includeOnlySelectedInTemplate EQ 1>
			AND	(Simple_Budget_Template_Mapping.Template_Parent_ID IS NOT NULL
				<cfif arguments.includeExtraBudgetList neq "">
				OR	Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID IN (#arguments.includeExtraBudgetList#)
				</cfif>
			)
			</cfif>			
			ORDER BY Simple_Budget.Simple_Budget_Number, Simple_Budget_Class.Simple_Budget_Class_Number
		</cfquery>
		
		<cfreturn qGetBudgetClassAssociationsForTemplate />
		
	</cffunction>	
	
	<cffunction name="getBudgetTemplateMapping" output="false" returntype="query">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="false" default="-1" />
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetTemplateMapping" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Mapping.Simple_Budget_Template_Mapping_ID,
					Simple_Budget_Template_Mapping.Simple_Budget_ID, Simple_Budget_Template_Mapping.Simple_Budget_Class_ID, 
					Simple_Budget_Template_Mapping.Budget_Dollar, ISNULL(Simple_Budget_Template_Mapping.Committed_Dollar, 0) as Committed_Dollar, Simple_Budget_Template_Mapping.Allocation_Level,
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class.Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget.Simple_Budget_Desc, 
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID, Simple_Budget_Class_Association.Active,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number
			FROM 	Simple_Budget_Template_Mapping
			
			LEFT JOIN Simple_Budget_Class_Association
			ON		Simple_Budget_Class_Association.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			AND		Simple_Budget_Class_Association.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			
			LEFT JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			
			WHERE	Simple_Budget_Template_Mapping.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">			
			<cfif arguments.active neq -1>
			AND		Simple_Budget_Template_Mapping.Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_BIT">			
			</cfif>
		</cfquery>
		
		<cfreturn qGetBudgetTemplateMapping />
		
	</cffunction>
	
	<cffunction name="getBudgetTemplatePositionAllocation" output="false" returntype="query">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="budgetId" type="numeric" required="true" />
		<cfargument name="userPositionId" type="numeric" required="true" />
		<cfargument name="allocationLevel" type="numeric" required="false" default="-1" />
		<cfargument name="classId" type="numeric" required="true" />
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetTemplatePositionAllocation" datasource="#application.datasource#">			
			SELECT 	DISTINCT Simple_Budget_Template_Position_Allocation.Template_Parent_ID, Simple_Budget_Template_Position_Allocation.Simple_Budget_ID, Simple_Budget_Template_Position_Allocation.User_Positions_ID,
					Allocated_Budget_Dollar as Budget_Dollar, 
					ISNULL(Simple_Budget_Template_Position_Allocation.Committed_Dollar, 0) as Committed_Dollar,
					ISNULL(Simple_Budget_Template_Position_Allocation.Actual_Dollar, 0) as Actual_Dollar,
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget.Active
			FROM 	Simple_Budget_Template_Position_Allocation	
			
			INNER JOIN Simple_Budget_Template_Mapping
			ON		Simple_Budget_Template_Mapping.Template_Parent_ID = Simple_Budget_Template_Position_Allocation.Template_Parent_ID
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID
			AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID
			AND		Simple_Budget_Template_Mapping.Simple_Budget_Template_Mapping_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_Template_Mapping_ID
			<cfif arguments.allocationLevel neq -1>
			AND		Simple_Budget_Template_Mapping.Allocation_Level = <cfqueryparam value="#arguments.allocationLevel#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			
			LEFT JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			
			WHERE	Simple_Budget_Template_Position_Allocation.Deleted = 0
			AND		Simple_Budget_Template_Position_Allocation.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classId#" cfsqltype="CF_SQL_INTEGER">
			<cfif arguments.userPositionId neq 0>
			AND		Simple_Budget_Template_Position_Allocation.User_Positions_ID = <cfqueryparam value="#arguments.userPositionId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</cfquery>
		
		<cfreturn qGetBudgetTemplatePositionAllocation />
		
	</cffunction>
	
	<cffunction name="getBudgetTemplateActualDollar" output="false" returntype="query">
		<cfargument name="templateMappingId" type="numeric" required="false" default="0" />
		<cfargument name="templateParentId" type="numeric" required="false" default="0" />
		<cfargument name="budgetId" type="numeric" required="false" default="0" />
		<cfargument name="classId" type="numeric" required="false" default="0" />
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetTemplateActualDollar" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Mapping_ID, Template_Parent_ID, Simple_Budget_ID, Simple_Budget_Class_ID, SUM(ISNULL(Actual_Dollar, 0)) as Actual_Dollar
			FROM	Simple_Budget_Template_Position_Allocation
			WHERE	Deleted = 0
			<cfif arguments.templateMappingId neq 0>
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_Template_Mapping_ID = <cfqueryparam value="#arguments.templateMappingId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.templateParentId neq 0>
			AND		Simple_Budget_Template_Position_Allocation.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.budgetId neq 0>
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif arguments.classId neq 0>
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			GROUP BY Simple_Budget_Template_Mapping_ID, Template_Parent_ID, Simple_Budget_ID, Simple_Budget_Class_ID
		</cfquery>
		
		<cfreturn qGetBudgetTemplateActualDollar />
		
	</cffunction>
	
	<cffunction name="getBudgetTemplatePositionAllocationForPosition" output="false" returntype="query">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="budgetId" type="numeric" required="true" />
		<cfargument name="userPositionId" type="numeric" required="true" />
		
		<!--- get the allocation level of this budget --->
		<cfquery name="qGetBudgetTemplateMapping" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Mapping.Template_Parent_ID, Simple_Budget_Template_Mapping.Simple_Budget_ID, 
					Simple_Budget_Template_Mapping.Allocation_Level
			FROM 	Simple_Budget_Template_Mapping
			
			WHERE	Simple_Budget_Template_Mapping.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			
		</cfquery>
		
		<cfset budgetAllocationLevel = qGetBudgetTemplateMapping.Allocation_Level />
		
		<cfif budgetAllocationLevel neq 0>
			<!--- get the position allocation level --->
			<cfset positionManager = CreateObject("component", "components.geography.position").init() />
			<cfset qGetPosition = positionManager.getPosition(id = arguments.userPositionId) />
			<cfset positionLevel = positionManager.getPositionLevel(qGetPosition) />
		</cfif>
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetTemplatePositionAllocation" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Position_Allocation.Template_Parent_ID, Simple_Budget_Template_Position_Allocation.Simple_Budget_ID, 
					<cfif 	budgetAllocationLevel eq 0
						or	budgetAllocationLevel lte positionLevel>
						Simple_Budget_Template_Position_Allocation.User_Positions_ID,
						Simple_Budget_Template_Position_Allocation.Average_Committed_Dollar,
						Simple_Budget_Template_Position_Allocation.Program_Count,
					<cfelse>
						0 as User_Positions_ID,
						0 as Average_Committed_Dollar,
						0 as Program_Count,
					</cfif>
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget.Active,
					SUM(Allocated_Budget_Dollar) as Budget_Dollar, SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Committed_Dollar, 0)) as Committed_Dollar
			FROM 	Simple_Budget_Template_Mapping
			
			INNER JOIN Simple_Budget_Template_Position_Allocation
			ON		Simple_Budget_Template_Position_Allocation.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = Simple_Budget_Template_Position_Allocation.Template_Parent_ID
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID

			<cfif budgetAllocationLevel eq 0> <!--- if budget is at hq, no need to do any filters, doens't matter what level the program is at --->

			<cfelseif budgetAllocationLevel eq positionLevel>
			AND		Simple_Budget_Template_Position_Allocation.User_Positions_ID = <cfqueryparam value="#arguments.userPositionId#" cfsqltype="CF_SQL_INTEGER">
			<cfelseif budgetAllocationLevel lt positionLevel> <!--- eg: budget/template is at zone/region and program is at region/market --->
				INNER JOIN User_Positions
				ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
				<cfswitch expression="#budgetAllocationLevel#">
				<cfcase value="1"> <!--- zone --->
				AND		User_Positions.Service_Zone_ID = <cfqueryparam value="#qGetPosition.Service_Zone_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="2"> <!--- region --->
				AND		User_Positions.Service_Region_ID = <cfqueryparam value="#qGetPosition.Service_Region_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="3"> <!--- market, we would never get to this condition, but still just added to be consistent, in case in future we were to add a new level, who knows --->
				AND		User_Positions.Service_Market_ID = <cfqueryparam value="#qGetPosition.Service_Market_ID#" cfsqltype="CF_SQL_INTEGER">
				</cfcase>
				</cfswitch>
			<cfelseif budgetAllocationLevel gt positionLevel> <!--- eg: budget/template is at zone/region/market and program is at hq/zone/region --->
				INNER JOIN User_Positions
				ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
				<cfswitch expression="#positionLevel#">
				<cfcase value="0"> <!--- hq --->
				<!---- for hq no filter required, all positions are under hq, so can take teh budget value from all positions --->
				</cfcase>
				<cfcase value="1"> <!--- zone --->
				AND		User_Positions.Service_Zone_ID = <cfqueryparam value="#qGetPosition.Service_Zone_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="2"> <!--- region --->
				AND		User_Positions.Service_Region_ID = <cfqueryparam value="#qGetPosition.Service_Region_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="3"> <!--- market, we would never get to this condition, but still just added to be consistent, in case in future we were to add a new level, who knows --->
				AND		User_Positions.Service_Market_ID = <cfqueryparam value="#qGetPosition.Service_Market_ID#" cfsqltype="CF_SQL_INTEGER">
				</cfcase>
				</cfswitch>
			</cfif>
			
			LEFT JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget.Simple_Budget_Class_ID
			
			WHERE	Simple_Budget_Template_Mapping.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			
			GROUP BY Simple_Budget_Template_Position_Allocation.Template_Parent_ID, Simple_Budget_Template_Position_Allocation.Simple_Budget_ID, 
					<cfif 	budgetAllocationLevel eq 0
						or	budgetAllocationLevel lte positionLevel>
						Simple_Budget_Template_Position_Allocation.User_Positions_ID,
						Simple_Budget_Template_Position_Allocation.Average_Committed_Dollar,
						Simple_Budget_Template_Position_Allocation.Program_Count,
					</cfif>
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget.Active
		</cfquery>
		
		<cfreturn qGetBudgetTemplatePositionAllocation />
		
	</cffunction>
	
	<cffunction name="getBudgetClassTemplatePositionAllocationForPosition" output="false" returntype="query">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="budgetId" type="numeric" required="true" />
		<cfargument name="classId" type="numeric" required="true" />
		<cfargument name="userPositionId" type="numeric" required="true" />
		
		<!--- get the allocation level of this budget --->
		<cfquery name="qGetBudgetTemplateMapping" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Mapping.Template_Parent_ID, Simple_Budget_Template_Mapping.Simple_Budget_ID, 
					Simple_Budget_Template_Mapping.Allocation_Level
			FROM 	Simple_Budget_Template_Mapping
			
			WHERE	Simple_Budget_Template_Mapping.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfset budgetAllocationLevel = qGetBudgetTemplateMapping.Allocation_Level />
		
		<cfif budgetAllocationLevel neq 0>
			<!--- get the position allocation level --->
			<cfset positionManager = CreateObject("component", "components.geography.position").init() />
			<cfset qGetPosition = positionManager.getPosition(id = arguments.userPositionId) />
			<cfset positionLevel = positionManager.getPositionLevel(qGetPosition) />
		</cfif>
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetClassTemplatePositionAllocationForPosition" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Position_Allocation.Template_Parent_ID, Simple_Budget_Template_Position_Allocation.Simple_Budget_ID, 
					<cfif 	budgetAllocationLevel eq 0
						or	budgetAllocationLevel lte positionLevel>
						Simple_Budget_Template_Position_Allocation.User_Positions_ID,
						Simple_Budget_Template_Position_Allocation.Average_Committed_Dollar,
						Simple_Budget_Template_Position_Allocation.Program_Count,
					<cfelse>
						0 as User_Positions_ID,
						0 as Average_Committed_Dollar,
						0 as Program_Count,
					</cfif>
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget.Active,
					SUM(Allocated_Budget_Dollar) as Budget_Dollar, SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Committed_Dollar, 0)) as Committed_Dollar,
					SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Actual_Dollar, 0)) as Actual_Dollar 
			FROM 	Simple_Budget_Template_Mapping
			
			INNER JOIN Simple_Budget_Template_Position_Allocation
			ON		Simple_Budget_Template_Position_Allocation.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = Simple_Budget_Template_Position_Allocation.Template_Parent_ID
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID
			AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID

			<cfif budgetAllocationLevel eq 0> <!--- if budget is at hq, no need to do any filters, doens't matter what level the program is at --->

			<cfelseif budgetAllocationLevel eq positionLevel>
			AND		Simple_Budget_Template_Position_Allocation.User_Positions_ID = <cfqueryparam value="#arguments.userPositionId#" cfsqltype="CF_SQL_INTEGER">
			<cfelseif budgetAllocationLevel lt positionLevel> <!--- eg: budget/template is at zone/region and program is at region/market --->
				INNER JOIN User_Positions
				ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
				<cfswitch expression="#budgetAllocationLevel#">
				<cfcase value="1"> <!--- zone --->
				AND		User_Positions.Service_Zone_ID = <cfqueryparam value="#qGetPosition.Service_Zone_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="2"> <!--- region --->
				AND		User_Positions.Service_Region_ID = <cfqueryparam value="#qGetPosition.Service_Region_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="3"> <!--- market, we would never get to this condition, but still just added to be consistent, in case in future we were to add a new level, who knows --->
				AND		User_Positions.Service_Market_ID = <cfqueryparam value="#qGetPosition.Service_Market_ID#" cfsqltype="CF_SQL_INTEGER">
				</cfcase>
				</cfswitch>
			<cfelseif budgetAllocationLevel gt positionLevel> <!--- eg: budget/template is at zone/region/market and program is at hq/zone/region --->
				INNER JOIN User_Positions
				ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
				<cfswitch expression="#positionLevel#">
				<cfcase value="0"> <!--- hq --->
				<!---- for hq no filter required, all positions are under hq, so can take teh budget value from all positions --->
				</cfcase>
				<cfcase value="1"> <!--- zone --->
				AND		User_Positions.Service_Zone_ID = <cfqueryparam value="#qGetPosition.Service_Zone_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="2"> <!--- region --->
				AND		User_Positions.Service_Region_ID = <cfqueryparam value="#qGetPosition.Service_Region_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfcase>
				<cfcase value="3"> <!--- market, we would never get to this condition, but still just added to be consistent, in case in future we were to add a new level, who knows --->
				AND		User_Positions.Service_Market_ID = <cfqueryparam value="#qGetPosition.Service_Market_ID#" cfsqltype="CF_SQL_INTEGER">
				</cfcase>
				</cfswitch>
			</cfif>
			
			LEFT JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget.Simple_Budget_Class_ID
			
			WHERE	Simple_Budget_Template_Mapping.Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classId#" cfsqltype="CF_SQL_INTEGER">
			
			GROUP BY Simple_Budget_Template_Position_Allocation.Template_Parent_ID, Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID, Simple_Budget_Template_Position_Allocation.Simple_Budget_ID, 
					<cfif 	budgetAllocationLevel eq 0
						or	budgetAllocationLevel lte positionLevel>
						Simple_Budget_Template_Position_Allocation.User_Positions_ID,
						Simple_Budget_Template_Position_Allocation.Average_Committed_Dollar,
						Simple_Budget_Template_Position_Allocation.Program_Count,
					</cfif>
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget.Active
		</cfquery>
		
		<cfreturn qGetBudgetClassTemplatePositionAllocationForPosition />
		
	</cffunction>
	
	<cffunction name="getBudgetTemplateMappingHistory" output="false" returntype="query">
		<cfargument name="templateParentId" type="numeric" required="true" />
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetTemplateMappingHistory" datasource="#application.datasource#">			
			SELECT 	Simple_Budget_Template_Mapping_History.Simple_Budget_ID, Budget_Dollar, Simple_Budget_Template_Mapping_History.Deleted,
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc, Simple_Budget.Active,
					Simple_Budget_Template_Mapping_History.Created_Date, Created_By_User.Name_First + ' ' + Created_By_User.Name_Last as Created_By_User_Name
			FROM 	Simple_Budget_Template_Mapping_History	
			
			LEFT JOIN Simple_Budget
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Mapping_History.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget.Simple_Budget_Class_ID
			
			LEFT JOIN _Users as Created_By_User
			ON		Simple_Budget_Template_Mapping_History.Created_By = Created_By_User.User_ID
			
			WHERE	Simple_Budget_Template_Mapping_History.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">			
			
			ORDER BY Simple_Budget_Template_Mapping_History.Created_Date Desc
		</cfquery>
		
		<cfreturn qGetBudgetTemplateMappingHistory />
		
	</cffunction>
	
	<cffunction name="refreshBudgetTemplateCommitted" output="false" returntype="void">
		<cfargument name="templateParentId" type="numeric" required="true" />
		
		<cfstoredproc procedure="BUDGET_TEMPLATE_COMMITTED_UPDATE" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Template_Parent_ID" value = "#arguments.templateParentId#" null="no">
		
		</cfstoredproc>
		
		<cfstoredproc procedure="BUDGET_TEMPLATE_POSITION_COMMITTED_UPDATE" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Template_Parent_ID" value = "#arguments.templateParentId#" null="no">
		
		</cfstoredproc>
		
	</cffunction>	

	<cffunction name="editBudgetTemplateMapping" output="true" returntype="void">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="oForm" type="any" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<!--- first check if the user has selected an exiting budget in the template --->
		<!--- 
		if yes, 
			- update template mapping table (budget dollar, active - 1)
		if no, 
			- insert into template mapping table			
		in either case,
			- delete/insert the allocation table
			- update other template mappings to active = 0
			- insert into the history table
		---->
		
		<cftransaction action="BEGIN">
		
			<cftry>
		
				<cfquery name="qUpdateOtherBudgetTemplateMappingToInActive" datasource="#application.datasource#">
					UPDATE	Simple_Budget_Template_Mapping
					SET		Active = 0
					WHERE	Deleted = 0
					AND		Active = 1
					AND		Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<cfquery name="qDeleteExistingBudgetTemplatePositionAllocations" datasource="#application.datasource#">
					UPDATE	Simple_Budget_Template_Position_Allocation
					SET		Deleted = 1
					WHERE	Deleted = 0
					AND		Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<cfparam name="oForm.Simple_Budget_Class_Association_List" default="">
				<cfloop list="#oForm.Simple_Budget_Class_Association_List#" index="currentBudgetAssociationID">
					
					<cfquery name="qGetBudgetClassAssociation" datasource="#application.datasource#">
						SELECT	Simple_Budget_ID, Simple_Budget_Class_ID
						FROM	Simple_Budget_Class_Association
						WHERE	Deleted = 0
						AND		Simple_Budget_Class_Association_ID = <cfqueryparam value="#currentBudgetAssociationID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
					
					<cfparam name="oForm.Allocation_Level_#currentBudgetAssociationID#" default="">
					<cfparam name="oForm.Previous_Allocation_Level_#currentBudgetAssociationID#" default="">
					<cfparam name="oForm.Budget_Dollar_#currentBudgetAssociationID#" default="">
					<cfparam name="oForm.User_Positions_List_#currentBudgetAssociationID#" default="">
					
					<cfset currentBudgetID = qGetBudgetClassAssociation.Simple_Budget_ID />
					<cfset currentBudgetClassID = qGetBudgetClassAssociation.Simple_Budget_Class_ID />
					<cfset currentAllocationLevel = Evaluate("oForm.Allocation_Level_#currentBudgetAssociationID#") />
					<cfset PrevAllocationLevel = Evaluate("oForm.Previous_Allocation_Level_#currentBudgetAssociationID#") />
					<cfset currentBudgetDollar = Evaluate("oForm.Budget_Dollar_#currentBudgetAssociationID#") />
					<cfset currentPositionIDList = Evaluate("oForm.User_Positions_List_#currentBudgetAssociationID#") />
					
					<cfif isNumeric(currentBudgetDollar) and currentBudgetDollar neq 0> <!--- if a budget has a dollar --->
					
					
						<cfquery name="qCheckBudgetInTemplateMapping" datasource="#application.datasource#">
							SELECT	Simple_Budget_Template_Mapping_ID, Simple_Budget_ID, Active
							FROM	Simple_Budget_Template_Mapping
							WHERE	Deleted = 0
							AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
							AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#currentBudgetID#" cfsqltype="CF_SQL_INTEGER">
							AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = <cfqueryparam value="#currentBudgetClassID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						
						<cfset Simple_Budget_Template_Mapping_ID = qCheckBudgetInTemplateMapping.Simple_Budget_Template_Mapping_ID />
					
						
						<cfif qCheckBudgetInTemplateMapping.recordCount>
						
							<!--- update --->
							<cfquery name="qUpdateBudgetTemplateMapping" datasource="#application.datasource#">
								UPDATE	Simple_Budget_Template_Mapping
								SET		Budget_Dollar = <cfqueryparam value="#currentBudgetDollar#" cfsqltype="CF_SQL_FLOAT">,
										Allocation_Level = <cfqueryparam value="#currentAllocationLevel#" cfsqltype="CF_SQL_FLOAT">,
										Active = 1,
										Created_Date = GetDate(),
										Created_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
								WHERE	Deleted = 0
								AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
								AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#currentBudgetID#" cfsqltype="CF_SQL_INTEGER">
								AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = <cfqueryparam value="#currentBudgetClassID#" cfsqltype="CF_SQL_INTEGER">
							</cfquery>
						
						<cfelse>
						
							<!------ Insert ----->
							<cfquery name="qAddBudgetTemplateMapping" datasource="#application.datasource#">
								SET NOCOUNT ON
								INSERT INTO Simple_Budget_Template_Mapping 
								(
									Simple_Budget_ID,
									Simple_Budget_Class_ID,
									Template_Parent_ID,
									Budget_Dollar,
									Allocation_Level,
									Active,
									Created_By
								)
								VALUES
								(
									<cfqueryparam value="#currentBudgetID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#currentBudgetClassID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#currentBudgetDollar#" cfsqltype="CF_SQL_FLOAT">,
									<cfqueryparam value="#currentAllocationLevel#" cfsqltype="CF_SQL_FLOAT">,
									1,
									<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
								)
								SELECT Simple_Budget_Template_Mapping_ID = @@IDENTITY
								SET NOCOUNT OFF
							</cfquery>
							
							<cfset Simple_Budget_Template_Mapping_ID = qAddBudgetTemplateMapping.Simple_Budget_Template_Mapping_ID />
							
						</cfif>
						
						<!--- save allocation --->
						<cfset sPositionList = "" />
						<cfif currentAllocationLevel eq 0><!---- get the hq position --->
							<cfset sPositionList = oForm.HQPositionId />
						<cfelse>
							<cfif currentAllocationLevel eq PrevAllocationLevel><!--- only save if teh alocation level match with the display --->
								<cfset sPositionList = currentPositionIDList />
							</cfif>
						</cfif>
						
						<cfloop list="#sPositionList#" index="positionId">
							<cfif currentAllocationLevel eq 0>
								<cfset Current_Allocated_Budget_Dollar = currentBudgetDollar />
							<cfelse>
								<cfparam name="oForm.Allocated_Budget_Dollar_#currentBudgetAssociationID#_#positionId#" default="0">
								<cfset Current_Allocated_Budget_Dollar = Evaluate("Form.Allocated_Budget_Dollar_#currentBudgetAssociationID#_#positionId#") />
							</cfif>
							
							<cfif Val(Current_Allocated_Budget_Dollar) gt 0>
								<cfquery name="qAddBudgetTemplatePositionAllocation" datasource="#application.datasource#">
									INSERT INTO Simple_Budget_Template_Position_Allocation 
									(
										Simple_Budget_Template_Mapping_ID, 
										Simple_Budget_ID,
										Simple_Budget_Class_ID, 
										Template_Parent_ID, 
										User_Positions_ID, 
										Allocated_Budget_Dollar
									)
									VALUES
									(
										<cfqueryparam value="#Simple_Budget_Template_Mapping_ID#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#currentBudgetID#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#currentBudgetClassID#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#positionId#" cfsqltype="CF_SQL_INTEGER">,
										<cfqueryparam value="#Current_Allocated_Budget_Dollar#" cfsqltype="CF_SQL_FLOAT">
									)
								</cfquery>
							</cfif>
							
						</cfloop>
						
						<cfquery name="qInsertIntoHistoryTable" datasource="#application.datasource#">
							INSERT INTO Simple_Budget_Template_Mapping_History (Simple_Budget_ID, Simple_Budget_Class_ID, Template_Parent_ID, Budget_Dollar, Committed_Dollar, Created_Date, Created_By, Deleted, Deleted_By, Deleted_Date)
							SELECT	Simple_Budget_ID, Simple_Budget_Class_ID, Template_Parent_ID, Budget_Dollar, Committed_Dollar, Created_Date, Created_By, Deleted, Deleted_By, Deleted_Date
							FROM	Simple_Budget_Template_Mapping
							WHERE	Deleted = 0
							AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
							AND		Simple_Budget_Template_Mapping.Simple_Budget_ID = <cfqueryparam value="#currentBudgetID#" cfsqltype="CF_SQL_INTEGER">
							AND		Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = <cfqueryparam value="#currentBudgetClassID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						
					</cfif> <!--- if a budget is selected end --->
				
				</cfloop>
				
				<cftransaction action="COMMIT" />
				
				<cfcatch>
				
					<cftransaction action="ROLLBACK" />
					<cfrethrow />
				
				</cfcatch>
			
			</cftry>
		
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="deleteBudgetTemplateMapping" output="false" returntype="void">
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<!------ Delete ----->
		<cfquery name="qDeleteBudgetTemplateMapping" datasource="#application.datasource#">
			UPDATE	Simple_Budget_Template_Mapping
			SET		Deleted = 1,
					Deleted_Date = GetDate(),
					Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE	Deleted = 0
			AND		Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="addBudgetTemplateMapping" output="false" returntype="void">
		<cfargument name="budgetId" type="numeric" required="true" />
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="budgetDollar" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<!------ Insert ----->
		<cfquery name="qAddBudgetTemplateMapping" datasource="#application.datasource#">
			INSERT INTO Simple_Budget_Template_Mapping 
			(
				Simple_Budget_ID,
				Template_Parent_ID,
				Budget_Dollar,
				Created_By
			)
			VALUES
			(
				<cfqueryparam value="#arguments.budgetId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.templateParentId#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.budgetDollar#" cfsqltype="CF_SQL_FLOAT">,
				<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			)
		</cfquery> 
		
	</cffunction>
	
	<cffunction name="copyTemplateBudget" output="false" returntype="void">
	
		<cfargument name="fromTemplateParentId" type="numeric" 	required="no" default="0" />
		<cfargument name="toTemplateParentId" 	type="numeric" 	required="no" default="0" />
		
		<cfset var varFromParentID 	= arguments.fromTemplateParentId />
		<cfset var varToParentID 	= arguments.toTemplateParentId />
		
		<!--- Copy the Budget Template Mapping --->
		<cfquery name="copyBudgetTemplateMapping" datasource="#application.datasource#">
			INSERT INTO Simple_Budget_Template_Mapping
				(Simple_Budget_ID, Simple_Budget_Class_ID, Template_Parent_ID, Allocation_Level, Budget_Dollar)
			SELECT	Simple_Budget_ID, Simple_Budget_Class_ID, #varToParentID# AS Template_Parent_ID, Allocation_Level, Budget_Dollar
			FROM	Simple_Budget_Template_Mapping
			WHERE	Template_Parent_ID = <cfqueryparam value="#varFromParentID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
			
		<!--- Copy the Budget Template Mapping --->
		<cfquery name="copyBudgetTemplatePositionAllocation" datasource="#application.datasource#">
			INSERT INTO Simple_Budget_Template_Position_Allocation
					(Simple_Budget_Template_Mapping_ID, Simple_Budget_ID, Simple_Budget_Class_ID, Template_Parent_ID, User_Positions_ID, Allocated_Budget_Dollar)
			SELECT	Simple_Budget_Template_Mapping.Simple_Budget_Template_Mapping_ID,
					Simple_Budget_Template_Mapping.Simple_Budget_ID,
					Simple_Budget_Template_Mapping.Simple_Budget_Class_ID,
					Simple_Budget_Template_Mapping.Template_Parent_ID,
					Simple_Budget_Template_Position_Allocation.User_Positions_ID,
					Simple_Budget_Template_Position_Allocation.Allocated_Budget_Dollar
			FROM	Simple_Budget_Template_Position_Allocation
					INNER JOIN Simple_Budget_Template_Mapping ON
					Simple_Budget_Template_Mapping.Template_Parent_ID = <cfqueryparam value="#varToParentID#" cfsqltype="CF_SQL_INTEGER"> AND
					Simple_Budget_Template_Mapping.Simple_Budget_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_ID AND
					Simple_Budget_Template_Mapping.Simple_Budget_Class_ID = Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID
			WHERE	Simple_Budget_Template_Position_Allocation.Template_Parent_ID = <cfqueryparam value="#varFromParentID#" cfsqltype="CF_SQL_INTEGER">
			AND		Simple_Budget_Template_Position_Allocation.deleted = 0
		</cfquery>
				
	</cffunction>
	
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Program ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="saveCommittedProgramBudgetPercentages" output="false" returntype="void">
		<cfargument name="contractMainID" type="numeric" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfargument name="oForm" type="struct" required="true" />
		
		<cftransaction action="begin">
		
			<cftry>
				
				<!--- delete existing entries ----->
				<cfquery name="qDeleteCommittedProgramBudgetPercentages" datasource="#application.datasource#">
					DELETE 	FROM Simple_Budget_Committed_Program_Detail
					WHERE	Program_ID = <cfqueryparam value="#arguments.contractMainID#" cfsqltype="cf_sql_integer">
				</cfquery>
				
				<cfparam name="oForm.Simple_Budget_Template_Mapping_ID_List" default="">
				<cfloop list="#oForm.Simple_Budget_Template_Mapping_ID_List#" index="rowId">
					<cfparam name="oForm.program_budget_percent_#rowId#" default="">
					<cfset budgetPercent = Evaluate("oForm.program_budget_percent_#rowId#")>
					
					<!--- get budget and class id ----->
					<cfquery name="qGetBudgetClassAssociation" datasource="#application.datasource#">
						SELECT	*
						FROM	Simple_Budget_Template_Mapping
						WHERE	Simple_Budget_Template_Mapping_ID = <cfqueryparam value="#rowId#" cfsqltype="cf_sql_integer">
					</cfquery>
					
					<cfset budgetID = qGetBudgetClassAssociation.Simple_Budget_ID />
					<cfset budgetClassID = qGetBudgetClassAssociation.Simple_Budget_Class_ID />
					<cfset templateParentID = qGetBudgetClassAssociation.Template_Parent_ID />
					<cfif isNumeric(budgetPercent) and budgetPercent neq 0
							and	 isNumeric(budgetID) and isNumeric(budgetClassID)>
						<!---- save budget percentage --->
						<!--- delete existing entries ----->
						<cfquery name="qInsertCommittedProgramBudgetPercentages" datasource="#application.datasource#">
							INSERT INTO Simple_Budget_Committed_Program_Detail(Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By)
							VALUES (
							<cfqueryparam value="#arguments.contractMainID#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#budgetClassID#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#budgetID#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#templateParentID#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#budgetPercent#" cfsqltype="cf_sql_decimal">,
							<cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>
						
					</cfif>
				</cfloop>
				
				<!--- insert into history table ---->
				<cfquery name="qInsertCommittedProgramBudgetPercentageHistory" datasource="#application.datasource#">
					INSERT INTO Simple_Budget_Committed_Program_Detail_History (Simple_Budget_Committed_Program_Detail_ID, Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By, Created_Date)
					SELECT	Simple_Budget_Committed_Program_Detail_ID, Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By, Created_Date
					FROM	Simple_Budget_Committed_Program_Detail
					WHERE	Program_ID = <cfqueryparam value="#arguments.contractMainID#" cfsqltype="cf_sql_integer">
				</cfquery>
			
				<cftransaction action="COMMIT" />
					
				<cfcatch>
				
					<cftransaction action="ROLLBACK" />
					<cfrethrow />
				
				</cfcatch>
			
			</cftry>
			
		</cftransaction>
		
		
		
	</cffunction>
	
	<cffunction name="copyCommittedProgramBudgetPercentages" output="false" returntype="void">
		<cfargument name="parentContractMainID" type="numeric" required="true" />
		<cfargument name="newContractMainID" type="numeric" required="true" />
		
		<!--- delete existing entries ----->
		<cfquery name="qDeleteCommittedProgramBudgetPercentages" datasource="#application.datasource#">
			DELETE 	FROM Simple_Budget_Committed_Program_Detail
			WHERE	Program_ID = <cfqueryparam value="#arguments.newContractMainID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfquery name="qCopyCommittedProgramBudgetPercentages" datasource="#application.datasource#">
			INSERT INTO Simple_Budget_Committed_Program_Detail(Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By)
			SELECT	#arguments.newContractMainID# as Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By
			FROM 	Simple_Budget_Committed_Program_Detail
			WHERE	Program_ID = <cfqueryparam value="#arguments.parentContractMainID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<!--- insert into history table ---->
		<cfquery name="qInsertCommittedProgramBudgetPercentageHistory" datasource="#application.datasource#">
			INSERT INTO Simple_Budget_Committed_Program_Detail_History (Simple_Budget_Committed_Program_Detail_ID, Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By, Created_Date)
			SELECT	Simple_Budget_Committed_Program_Detail_ID, Program_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Template_Parent_ID, Allocation_Percent, Created_By, Created_Date
			FROM	Simple_Budget_Committed_Program_Detail
			WHERE	Program_ID = <cfqueryparam value="#arguments.newContractMainID#" cfsqltype="cf_sql_integer">
		</cfquery>
			
	</cffunction>	
	
	<cffunction name="getCommittedProgramDollar" output="false" returntype="numeric">
		<cfargument name="contractNumber" type="string" required="true" />
		
		<!--- get the committed value for the current program --->
		<cfquery name="qGetCommittedProgramDollar" datasource="#application.datasource#">			
			SELECT	ISNULL(SUM(Program_Spend), 0) as Total_Committed_Dollar

			FROM	Simple_Budget_Committed_Programs with (nolock)
			
			INNER JOIN Contract_Main with (nolock)
			ON	Contract_Main.Contract_Main_ID = Simple_Budget_Committed_Programs.Program_ID
			AND	Contract_Main.Contract_Number = <cfqueryparam value="#arguments.contractNumber#" cfsqltype="CF_SQL_VARCHAR">
			
		</cfquery>
		
		<cfreturn qGetCommittedProgramDollar.Total_Committed_Dollar />
		
	</cffunction>
	
	<cffunction name="getBudgetCommittedProgramDollar" output="false" returntype="numeric">
		<cfargument name="BudgetID" type="numeric" required="true" />
		<cfargument name="BudgetClassID" type="numeric" required="true" />
		<cfargument name="contractNumber" type="string" required="true" />
		
		<!--- get the committed value for the current program --->
		<cfquery name="qGetCommittedProgramDollar" datasource="#application.datasource#">			
			
			select	SUM(Simple_Budget_Committed_Program_Detail.Allocation_Percent * 0.01 *
				(ISNULL(Simple_Budget_Committed_Programs.Program_Spend_Distributor, 0) + 
				ISNULL(Simple_Budget_Committed_Programs.Program_Spend_Operator, 0) + 
				ISNULL(Simple_Budget_Committed_Programs.Program_Spend_Broker, 0))) as Current_Committed_Dollar
			from	Contract_Main
			
			INNER JOIN Simple_Budget_Committed_Programs
			ON	Simple_Budget_Committed_Programs.Program_ID = Contract_Main.Contract_Main_ID
			
			INNER JOIN Simple_Budget_Committed_Program_Detail
			ON	Simple_Budget_Committed_Program_Detail.Program_ID = Contract_Main.Contract_Main_ID
			
			WHERE	Contract_Main.Contract_Number = <cfqueryparam value="#arguments.contractNumber#" cfsqltype="CF_SQL_VARCHAR">
			AND		Simple_Budget_Committed_Program_Detail.Simple_Budget_ID = <cfqueryparam value="#arguments.BudgetID#" cfsqltype="cf_sql_integer">
			AND		Simple_Budget_Committed_Program_Detail.Simple_Budget_Class_ID = <cfqueryparam value="#arguments.BudgetClassID#" cfsqltype="cf_sql_integer">
			
		</cfquery>
		
		<cfreturn Val(qGetCommittedProgramDollar.Current_Committed_Dollar) />
		
	</cffunction>
	
	<cffunction name="getProgramAdjustedCommittedDollar" output="false" returntype="numeric">
		<cfargument name="contractNumber" type="string" required="true" />
		<cfargument name="newRevisionStartDate" type="string" required="true" />
		
		<cfset var newCommittedDollar = 0 />
		<!--- get the adjusted committed dollar for the current versions based on the new revision start --->
		<cfstoredproc procedure="BUDGET_GET_PROGRAM_REVISION_ADJUSTED_COMMITTED_DOLLAR" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Contract_Number" value = "#arguments.contractNumber#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@Revision_Start_Date" value = "#arguments.newRevisionStartDate#" null="no">
			<cfprocparam type="Out" CFSQLType ="CF_SQL_INTEGER" variable="newCommittedDollar" dbVarName="@Adjusted_Committed_Dollar" null="no">
		
		</cfstoredproc>	
		
		<cfreturn newCommittedDollar />
		
	</cffunction>	

	<cffunction name="refreshProgramCommittedDollar" output="false" returntype="void">
		<cfargument name="contractNumber" type="string" required="true" />
		
		<!--- get the adjusted committed dollar for the current versions based on the new revision start --->
		<cfstoredproc procedure="BUDGET_PROGRAM_COMMITTED_UPDATE" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Contract_Number" value = "#arguments.contractNumber#" null="no">
		
		</cfstoredproc>	
		
	</cffunction>	
	
	<cffunction name="addCommittedProgram" output="false" returntype="void">
	
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="contractNumber" type="string" required="true" />
		<cfargument name="programSpend" type="numeric" required="true" />
		<cfargument name="qProgram" type="query" required="true" />
		<cfargument name="ByPass_Margin_Evaluation" type="boolean" required="false" default="0" />
		
		<cfquery name="qInsertCommittedProgram" datasource="#application.datasource#">
			DELETE FROM Simple_Budget_Committed_Programs 
			WHERE 	Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			INSERT INTO Simple_Budget_Committed_Programs (Program_ID, Program_Spend)
			VALUES (<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#Round(arguments.programSpend)#" cfsqltype="CF_SQL_FLOAT">)				
		</cfquery>
		
		<cfset refreshProgramCommittedDollar(contractNumber = arguments.contractNumber) />
		
		<cfset refreshBudgetTemplateCommitted(templateParentId = arguments.templateParentId) />
		
		<!--- Dev Note: Milan (23506). When "ByPass_Margin_Evaluation" template setting is off, we do not need to 
			  send out an email for budget balances below zero, as for programs with that setting ON, no user is
			  allowed to approve programs which will make the balance below zero.
		--->
		<cfif arguments.ByPass_Margin_Evaluation eq 0>
			<cfset qGetTemplateBudgets = getBudgetTemplateMappingForProgram(
				programId = arguments.programId, 
				templateParentId = arguments.templateParentId,
				userPositionId = qProgram.Creating_User_Position_ID,
				returnOnlyIfSelectedInProgram = 1,
				programApproval = 0) />
		
				<cfquery name="qGetBudgetBalance" dbtype="query">
					select	*
					from	qGetTemplateBudgets
					where	Position_Budget_Balance < 0
				</cfquery>
				
				
				<cfif qGetBudgetBalance.recordCount>
					<!--- send out email --->
					<cfset loadBudgetLabels() />
					<cfset programApproveEmail(programId = arguments.programId, qProgram = arguments.qProgram, qBudgetBalance = qGetBudgetBalance) />			
				</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="modifyProgramCommittedDollar" output="false" returntype="void">
	
		<cfargument name="templateParentId" type="numeric" required="true" />
		<cfargument name="contractNumber" type="string" required="true" />
		
		<cfset refreshProgramCommittedDollar(contractNumber = arguments.contractNumber) />
		
		<cfset refreshBudgetTemplateCommitted(templateParentId = arguments.templateParentId) />
				
	</cffunction>
	
	<cffunction name="programApproveEmail" output="false" returntype="void">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="qProgram" type="query" required="true" />
		<cfargument name="qBudgetBalance" type="query" required="true" />
		
		<cfinclude template="/settings/budgets/budget_program_approve_email.cfm" />
		
	</cffunction>

	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Budget Settings ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<cffunction name="saveBudgetClass" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="number" type="string" required="true" />
		<cfargument name="desc" type="string" required="true" />
		<cfargument name="startDate" type="string" required="true" />
		<cfargument name="endDate" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />		
		
		<!---- make sure it is valid date ----->
		<cfif NOT isDate(arguments.startDate) or NOT isDate(arguments.endDate)>
			<cfset returnValue[1] = "You must enter a valid start and end dates in MM/DD/YYYY format" />
			<cfreturn returnValue />			
		</cfif>
		<!---- make sure the date is a valid span ----->
		<cfif datediff("d", arguments.startDate, arguments.endDate) lt 0>
			<cfset returnValue[1] = "The end date must be on or after the start date" />
			<cfreturn returnValue />			
		</cfif>
		<!---- make sure the dates do not overlap with other class dates ----->
		<cfset qGetOverlappingBudgetClass = getOverlappingBudgetClass(
				id = arguments.id,
				startDate = arguments.startDate,
				endDate = arguments.endDate) />		
		<cfif qGetOverlappingBudgetClass.recordCount>
			<cfset returnValue[1] = "Dates overlap with class ""#qGetOverlappingBudgetClass.Simple_Budget_Class_Number# #qGetOverlappingBudgetClass.Simple_Budget_Class_Desc# (#DateFormat(qGetOverlappingBudgetClass.Start_Date, "mm/dd/yyyy")#-#DateFormat(qGetOverlappingBudgetClass.End_Date, "mm/dd/yyyy")#)""" />
			<cfreturn returnValue />
		</cfif>
		
		<cfif arguments.id>
		<!------ Update ----->
			<cfquery name="qUpdateBudgetClass" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Class
				SET		Simple_Budget_Class_Number = <cfqueryparam value="#arguments.number#" cfsqltype="CF_SQL_VARCHAR">,
						Simple_Budget_Class_Desc = <cfqueryparam value="#arguments.desc#" cfsqltype="CF_SQL_VARCHAR">,
						Start_Date = <cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_date">,
						End_Date = <cfqueryparam value="#arguments.endDate#" cfsqltype="cf_sql_date">
				WHERE	Simple_Budget_Class_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfset returnValue[1] = "" />
		<cfelse>
		<!------ Insert ----->
			<cfquery name="qInsertBudgetClass" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Simple_Budget_Class (Simple_Budget_Class_Number, Simple_Budget_Class_Desc, Start_Date, End_Date)
				VALUES (
					<cfqueryparam value="#arguments.number#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#arguments.desc#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.endDate#" cfsqltype="cf_sql_date">)
				SELECT Simple_Budget_Class_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			<cfset returnValue[1] = "" />
			<cfset returnValue[2] = qInsertBudgetClass.Simple_Budget_Class_ID />			
		</cfif>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="saveBudget" output="false" returntype="numeric">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="number" type="string" required="true" />
		<cfargument name="desc" type="string" required="true" />
		
		<cfif arguments.id>
		<!------ Update ----->
			<cfquery name="qUpdateBudget" datasource="#application.datasource#">
				UPDATE	Simple_Budget
				SET		Simple_Budget_Number = <cfqueryparam value="#arguments.number#" cfsqltype="CF_SQL_VARCHAR">,
						Simple_Budget_Desc = <cfqueryparam value="#arguments.desc#" cfsqltype="CF_SQL_VARCHAR">
				WHERE	Simple_Budget_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelse>
		<!------ Insert ----->
			<cfquery name="qInsertBudget" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Simple_Budget (Simple_Budget_Number, Simple_Budget_Desc)
				VALUES (
					<cfqueryparam value="#arguments.number#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#arguments.desc#" cfsqltype="CF_SQL_VARCHAR">)
				SELECT Simple_Budget_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			<cfset arguments.id = qInsertBudget.Simple_Budget_ID />
		</cfif>
		
		<cfreturn arguments.id />
	
	</cffunction>
	
	<cffunction name="addClassBudgetAssociation" output="false" returntype="numeric">
		<cfargument name="classID" type="numeric" required="true" />
		<cfargument name="budgetID" type="numeric" required="true" />
		<cfargument name="classBudgetAssociationNumber" type="string" required="true" />
		
		<cfset returnValue = 0 />
		<!------ check if already exist ----->
		<cfquery name="qGetClassBudgetAssociation" datasource="#application.datasource#">
			select	*
			from	Simple_Budget_Class_Association
			where	Simple_Budget_Class_ID = <cfqueryparam value="#arguments.classID#" cfsqltype="cf_sql_integer">
			and		Simple_Budget_ID = <cfqueryparam value="#arguments.budgetID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfif qGetClassBudgetAssociation.recordCount>
		
			<!------ Update ----->
			<cfquery name="qUpdateClassBudgetAssociation" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Class_Association
				SET		Simple_Budget_Class_Association_Number = <cfqueryparam value="#arguments.classBudgetAssociationNumber#" cfsqltype="CF_SQL_VARCHAR">,
						Active = 1,
						Deactivated_Date = NULL,
						Deactivated_By = NULL,
						Deleted = 0,
						Deleted_Date = NULL,
						Deleted_By = NULL
				WHERE	Simple_Budget_Class_Association_ID = <cfqueryparam value="#qGetClassBudgetAssociation.Simple_Budget_Class_Association_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfset returnValue = qGetClassBudgetAssociation.Simple_Budget_Class_Association_ID />
			
		<cfelse>
		
			<!------ Insert ----->
			<cfquery name="qInsertClassBudgetAssociation" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Simple_Budget_Class_Association (Simple_Budget_Class_ID, Simple_Budget_ID, Simple_Budget_Class_Association_Number)
				VALUES (
					<cfqueryparam value="#arguments.classID#" cfsqltype="cf_sql_integer">, 
					<cfqueryparam value="#arguments.budgetID#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.classBudgetAssociationNumber#" cfsqltype="CF_SQL_VARCHAR">)
				SELECT Simple_Budget_Class_Association_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
		
			<cfset returnValue = qInsertClassBudgetAssociation.Simple_Budget_Class_Association_ID />
			
		</cfif>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="addBudgetAssociationToClass" output="false" returntype="void">
		<cfargument name="classID" type="numeric" required="true" />
		<cfargument name="oForm" type="struct" required="true" />
		
		<cfparam name="oForm.Simple_Budget_ID" default="" />
		<cfloop list="#oForm.Simple_Budget_ID#" index="currentId">
			<cfparam name="oForm.Simple_Budget_Class_Association_Number_#currentId#" default="" />
			<cfset sClassBudgetAssociationNumber = Evaluate("oForm.Simple_Budget_Class_Association_Number_#currentId#") />
			<cfset addClassBudgetAssociation(classID = arguments.classID,
						budgetID = currentId,
						classBudgetAssociationNumber = sClassBudgetAssociationNumber) />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="addClassAssociationToBudget" output="false" returntype="void">
		<cfargument name="budgetID" type="numeric" required="true" />
		<cfargument name="oForm" type="struct" required="true" />
		
		<cfparam name="oForm.Simple_Budget_Class_ID" default="" />
		<cfloop list="#oForm.Simple_Budget_Class_ID#" index="currentId">
			<cfparam name="oForm.Simple_Budget_Class_Association_Number_#currentId#" default="" />
			<cfset sClassBudgetAssociationNumber = Evaluate("oForm.Simple_Budget_Class_Association_Number_#currentId#") />
			<cfset addClassBudgetAssociation(classID = currentId,
						budgetID = arguments.budgetID,
						classBudgetAssociationNumber = sClassBudgetAssociationNumber) />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="saveBudgetClassAssociationNumber" output="false" returntype="void">
		<cfargument name="oForm" type="struct" required="true" />
		
		<cfparam name="oForm.Simple_Budget_Class_Association_ID_List" default="" />
		<cfloop list="#oForm.Simple_Budget_Class_Association_ID_List#" index="budgetClassAssocId">
			<cfparam name="oForm.Simple_Budget_Class_Association_Number_#budgetClassAssocId#" default="" />
			<cfset sClassBudgetAssociationNumber = Evaluate("oForm.Simple_Budget_Class_Association_Number_#budgetClassAssocId#") />
			<cfquery name="qUpdateClassBudgetAssociation" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Class_Association
				SET		Simple_Budget_Class_Association_Number = <cfqueryparam value="#sClassBudgetAssociationNumber#" cfsqltype="CF_SQL_VARCHAR">						
				WHERE	Simple_Budget_Class_Association_ID = <cfqueryparam value="#budgetClassAssocId#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="activateDeactivateBudgetClass" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />
		<cfset returnValue[3] = "" />
		
		<cfif arguments.id>		
		
			<!---- if activating, make sure the dates do not overlap with other class dates ----->
			<cfif arguments.active>
				<cfquery name="qGetBudgetClass" datasource="#application.datasource#">
					SELECT	Start_Date, End_Date
					FROM	Simple_Budget_Class
					WHERE	Simple_Budget_Class_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfset qGetOverlappingBudgetClass = getOverlappingBudgetClass(
						id = arguments.id,
						startDate = qGetBudgetClass.Start_Date,
						endDate = qGetBudgetClass.End_Date) />		
				<cfif qGetOverlappingBudgetClass.recordCount>
					<cfset returnValue[1] = "Dates overlap with class ""#qGetOverlappingBudgetClass.Simple_Budget_Class_Number# #qGetOverlappingBudgetClass.Simple_Budget_Class_Desc# (#DateFormat(qGetOverlappingBudgetClass.Start_Date, "mm/dd/yyyy")#-#DateFormat(qGetOverlappingBudgetClass.End_Date, "mm/dd/yyyy")#)""" />
					<cfreturn returnValue />
				</cfif>
			</cfif>
			
			<cfif NOT arguments.active>
				<!------ if deactivating, check if there are templates with no active budgets left ----->
				<cfstoredproc procedure="BUDGET_INACTIVATE_TEMPLATE_CHECK" datasource="#application.datasource#">
						
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_ID" value = "0" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_ID" value = "#arguments.id#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_Association_ID" value = "0" null="no">
					
					<cfprocresult name="qOnlyBudgetInTemplates" />
						
				</cfstoredproc>
				
				<cfif qOnlyBudgetInTemplates.recordCount>
					<cfset returnValue[1] = "This budget class is the sole available choice in 1 or more templates" />
					<cfset returnValue[3] = qOnlyBudgetInTemplates />
					<cfreturn returnValue />
				</cfif>
			</cfif>
			
			<!------ Update ----->
			<cfquery name="qUpdateBudgetClass" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Class
				SET		Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
				<cfif arguments.active EQ 0>,
						Deactivated_Date = GetDate(),
						Deactivated_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				WHERE	Simple_Budget_Class_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Active <> <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfset returnValue[1] = "" />
			
			<!------ if deactivating, deactivate budget class association also ----->
			<cfif arguments.active EQ 0>
				<cfset activateDeactivateBudgetClassAssociation(
						id = 0,
						active = 0,
						userId = arguments.userId,
						ClassId = arguments.id,
						BudgetId = 0) />				
			</cfif>
		</cfif>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="activateDeactivateBudget" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />
		<cfset returnValue[3] = "" />
		
		<cfif arguments.id>
			
			<cfif NOT arguments.active>
				<!------ if deactivating, check if there are templates with no active budgets left ----->
				<cfstoredproc procedure="BUDGET_INACTIVATE_TEMPLATE_CHECK" datasource="#application.datasource#">
						
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_ID" value = "#arguments.id#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_ID" value = "0" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_Association_ID" value = "0" null="no">
					
					<cfprocresult name="qOnlyBudgetInTemplates" />
						
				</cfstoredproc>
				
				<cfif qOnlyBudgetInTemplates.recordCount>
					<cfset returnValue[1] = "This budget is the sole available choice in 1 or more templates" />
					<cfset returnValue[3] = qOnlyBudgetInTemplates />
					<cfreturn returnValue />
				</cfif>
			</cfif>
			
			<!------ Update ----->
			<cfquery name="qUpdateBudget" datasource="#application.datasource#">
				UPDATE	Simple_Budget
				SET		Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
				<cfif arguments.active EQ 0>,
						Deactivated_Date = GetDate(),
						Deactivated_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				WHERE	Simple_Budget_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Active <> <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfset returnValue[1] = "" />
			
			<cfif arguments.active EQ 0>
				<cfset activateDeactivateBudgetClassAssociation(
						id = 0,
						active = 0,
						userId = arguments.userId,
						ClassId = 0,
						BudgetId = arguments.id) />				
			</cfif>
		</cfif>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="deleteBudget" output="false" returntype="void">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfif arguments.id>
		<!------ Update ----->
			<cfquery name="qUpdateBudget" datasource="#application.datasource#">
				UPDATE	Simple_Budget
				SET		Deleted = 1,
						Deleted_Date = GetDate(),
						Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				WHERE	Simple_Budget_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Deleted = 0
			</cfquery>
		</cfif>
	
	</cffunction>
	
	<cffunction name="activateDeactivateBudgetClassAssociation" output="false" returntype="void">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="ClassId" type="numeric" required="false" default="0" />
		<cfargument name="BudgetId" type="numeric" required="false" default="0" />
		
		<cfif arguments.id or arguments.ClassId or arguments.BudgetId>
		<!------ Update ----->
			<cfquery name="qUpdateBudgetClassAssociation" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Class_Association
				SET		Active = <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
				<cfif arguments.active EQ 0>,
						Deactivated_Date = GetDate(),
						Deactivated_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				WHERE	Active <> <cfqueryparam value="#arguments.active#" cfsqltype="CF_SQL_INTEGER">
				<cfif arguments.id>
				AND		Simple_Budget_Class_Association_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				</cfif>
				<cfif arguments.ClassId>
				AND		Simple_Budget_Class_ID = <cfqueryparam value="#arguments.ClassId#" cfsqltype="CF_SQL_INTEGER">
				</cfif>
				<cfif arguments.BudgetId>
				AND		Simple_Budget_ID = <cfqueryparam value="#arguments.BudgetId#" cfsqltype="CF_SQL_INTEGER">
				</cfif>
			</cfquery>
		</cfif>
	
	</cffunction>
	
	<cffunction name="activateDeactivateBudgetClassAssociationSingle" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="active" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
	
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "" />
		<cfset returnValue[2] = "" />
		<cfset returnValue[3] = ArrayNew(1) />
		
		<cfif NOT arguments.active>
			<!------ if deactivating, check if there are templates with no active budgets left ----->
			<cfstoredproc procedure="BUDGET_INACTIVATE_TEMPLATE_CHECK" datasource="#application.datasource#">
					
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_ID" value = "0" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_ID" value = "0" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_Association_ID" value = "#arguments.id#" null="no">
				
				<cfprocresult name="qOnlyBudgetInTemplates" />
					
			</cfstoredproc>
			
			<cfif qOnlyBudgetInTemplates.recordCount>
				<cfset returnValue[1] = "This budget class association is the sole available choice in 1 or more templates" />
				<cfset returnValue[3][ArrayLen(returnValue[3]) + 1] = qOnlyBudgetInTemplates />
				<cfreturn returnValue />				
			</cfif>
		</cfif>
		
		<cfset activateDeactivateBudgetClassAssociation(
				id = arguments.id, 
				active = arguments.active, 
				userId = arguments.userId) />
		
		<cfreturn returnValue />
		
	</cffunction>	
	
	<cffunction name="activateDeactivateBudgetClassAssociationMulti" output="false" returntype="array">
	
		<cfargument name="idList" type="string" required="true" />
		<cfargument name="active" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "" />
		<cfset returnValue[2] = "" />
		<cfset returnValue[3] = ArrayNew(1) />
		
		<cfloop list="#arguments.idList#" index="thisID">
			<cfset canContinue = 1 />
			<cfif NOT arguments.active>
				<!------ if deactivating, check if there are templates with no active budgets left ----->
				<cfstoredproc procedure="BUDGET_INACTIVATE_TEMPLATE_CHECK" datasource="#application.datasource#">
						
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_ID" value = "0" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_ID" value = "0" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Simple_Budget_Class_Association_ID" value = "#thisID#" null="no">
					
					<cfprocresult name="qOnlyBudgetInTemplates" />
						
				</cfstoredproc>
				
				<cfif qOnlyBudgetInTemplates.recordCount>
					<cfset returnValue[1] = "This budget class association is the sole available choice in 1 or more templates" />
					<cfset returnValue[3][ArrayLen(returnValue[3]) + 1] = qOnlyBudgetInTemplates />
					<cfset canContinue = 0 />
				</cfif>
			</cfif>
			<cfif canContinue>
				<cfset activateDeactivateBudgetClassAssociation(id = thisID, active = arguments.active, userId = arguments.userId) />
			</cfif>
		</cfloop>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="deleteBudgetClassAssociationMulti" output="false" returntype="void">
	
		<cfargument name="idList" type="string" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfloop list="#arguments.idList#" index="thisID">
			<cfset deleteBudgetClassAssociation(id = thisID, userId = arguments.userId) />
		</cfloop>		
	
	</cffunction>	
	
	<cffunction name="deleteBudgetClassAssociation" output="false" returntype="void">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfif arguments.id>
		<!------ Update ----->
			<cfquery name="qUpdateBudgetClassAssociation" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Class_Association
				SET		Deleted = 1,
						Deleted_Date = GetDate(),
						Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				WHERE	Simple_Budget_Class_Association_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND		Deleted = 0
			</cfquery>
		</cfif>
	
	</cffunction>
	
	<cffunction name="getOverlappingBudgetClass" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="startDate" type="string" required="true" />
		<cfargument name="endDate" type="string" required="true" />
		
		<cfquery name="qGetOverlappingBudgetClass" datasource="#application.datasource#">
			SELECT	*
			FROM	Simple_Budget_Class
			WHERE	Simple_Budget_Class_ID <> <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			AND		Deleted = 0
			AND		Active = 1
			AND		
			(-- check for any overlap between existing class dates and current class date
				(-- existing class start date is between current class dates
				datediff(d, #createodbcdate(arguments.startDate)#, Start_Date) >= 0
				and	datediff(d, Start_Date, #createodbcdate(arguments.endDate)#) >= 0
				)
				or
				(-- current class start date is between existing class dates
				datediff(d, Start_Date, #createodbcdate(arguments.startDate)#) >= 0
				and	datediff(d, #createodbcdate(arguments.startDate)#, End_Date) >= 0
				)
			)
		</cfquery>
		
		<cfreturn qGetOverlappingBudgetClass />
		
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Budget Labels ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="loadBudgetLabels" output="false" returntype="void">
	
		<cfquery name="qGetBudgetLabels" datasource="#application.datasource#">
			SELECT	*
			FROM	Simple_Budget_Labels 
		</cfquery>
	
		<cfset this.budgetDollarLabel = qGetBudgetLabels.Budget_Dollar_Label />
		<cfset this.committedDollarLabel = qGetBudgetLabels.Committed_Dollar_Label />
		<cfset this.budgetBalanceLabel = qGetBudgetLabels.Budget_Balance_Label />
		<cfset this.approvedPaymentDollarLabel = qGetBudgetLabels.Approved_Payment_Dollar_Label />
		<cfset this.availableBudgetDollarLabel = qGetBudgetLabels.Available_Budget_Dollar_Label />
		<cfset this.budgetClassAssociationLabel = qGetBudgetLabels.Budget_Class_Association_Label />
	
	</cffunction>
	
	<cffunction name="saveBudgetLabels" output="false" returntype="void">
		<cfargument name="budgetDollarLabel" type="string" required="true" />
		<cfargument name="committedDollarLabel" type="string" required="true" />
		<cfargument name="budgetBalanceLabel" type="string" required="true" />
		<cfargument name="approvedPaymentDollarLabel" type="string" required="true" />
		<cfargument name="availableBudgetDollarLabel" type="string" required="true" />
		<cfargument name="budgetClassAssociationLabel" type="string" required="true" />
		<cfargument name="userId" type="string" required="true" />
	
		<cfquery name="qGetBudgetLabels" datasource="#application.datasource#">
			SELECT	Budget_Dollar_Label, Committed_Dollar_Label, Budget_Balance_Label, Approved_Payment_Dollar_Label, Available_Budget_Dollar_Label
			FROM	Simple_Budget_Labels 
		</cfquery>
		
		<cfif qGetBudgetLabels.recordCount>
		
			<cfquery name="qUpdateBudgetLabels" datasource="#application.datasource#">
				UPDATE	Simple_Budget_Labels
				SET		Budget_Dollar_Label = <cfqueryparam value="#arguments.budgetDollarLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						Committed_Dollar_Label = <cfqueryparam value="#arguments.committedDollarLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						Budget_Balance_Label = <cfqueryparam value="#arguments.budgetBalanceLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						Approved_Payment_Dollar_Label = <cfqueryparam value="#arguments.approvedPaymentDollarLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						Available_Budget_Dollar_Label = <cfqueryparam value="#arguments.availableBudgetDollarLabel#" cfsqltype="CF_SQL_VARCHAR">,
						Budget_Class_Association_Label = <cfqueryparam value="#arguments.budgetClassAssociationLabel#" cfsqltype="CF_SQL_VARCHAR">,
						Updated_Date = GetDate(),
						Updated_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		
		<cfelse>
		
			<cfquery name="qUpdateBudgetLabels" datasource="#application.datasource#">
				INSERT INTO Simple_Budget_Labels (Budget_Dollar_Label, Committed_Dollar_Label, Budget_Balance_Label, Approved_Payment_Dollar_Label, Available_Budget_Dollar_Label, Budget_Class_Association_Label, Updated_Date, Updated_By)
				VALUES	(<cfqueryparam value="#arguments.budgetDollarLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#arguments.committedDollarLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#arguments.budgetBalanceLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#arguments.approvedPaymentDollarLabel#" cfsqltype="CF_SQL_VARCHAR">, 
						<cfqueryparam value="#arguments.availableBudgetDollarLabel#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.budgetClassAssociationLabel#" cfsqltype="CF_SQL_VARCHAR">,
						GetDate(),
						<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		
		</cfif>
		
	</cffunction>	
	
	<cffunction name="getBudgetDollarLabel" access="public" output="false" return="string">
		<cfreturn this.budgetDollarLabel />
	</cffunction>
	
	<cffunction name="getCommittedDollarLabel" access="public" output="false" return="string">
		<cfreturn this.committedDollarLabel />
	</cffunction>
	
	<cffunction name="getBudgetBalanceLabel" access="public" output="false" return="string">
		<cfreturn this.budgetBalanceLabel />
	</cffunction>
	
	<cffunction name="getApprovedPaymentDollarLabel" access="public" output="false" return="string">
		<cfreturn this.approvedPaymentDollarLabel />
	</cffunction>
	
	<cffunction name="getAvailableBudgetDollarLabel" access="public" output="false" return="string">
		<cfreturn this.availableBudgetDollarLabel />
	</cffunction>
	
	<cffunction name="getBudgetClassAssociationLabel" access="public" output="false" return="string">
		<cfreturn this.budgetClassAssociationLabel />
	</cffunction>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Reports ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cffunction name="getBudgetSummaryReport" output="false" returntype="query">
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetSummaryReport" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
			SELECT 	User_Positions_ID
			INTO	##Tmp_User_Positions
			FROM 	User_Position_Holders
			WHERE 	User_ID = '#request.AccessStructure.user_id#' 
			AND 	Deleted = 0
			AND		User_Positions_ID != 0
			
			SELECT	DISTINCT Below_User_Positions_ID as Allow_User_Positions_ID
			INTO	##Tmp_Allow_User_Positions_ID
			FROM	Positions_Below_Me
			WHERE	User_Positions_ID IN (SELECT User_Positions_ID FROM ##Tmp_User_Positions)
			UNION
			SELECT	DISTINCT Above_User_Positions_ID as Allow_User_Positions_ID
			FROM	Positions_Above_Me
			WHERE	User_Positions_ID IN (SELECT User_Positions_ID FROM ##Tmp_User_Positions)

			SELECT 	Simple_Budget.Simple_Budget_ID, Simple_Budget_Class.Simple_Budget_Class_ID, 
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
					User_Positions.User_Positions_ID, User_Positions.Position_Label,
					ISNULL(SUM(Simple_Budget_Template_Position_Allocation.Allocated_Budget_Dollar), 0) as Sum_Budget_Dollar, 
					ISNULL(SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Committed_Dollar, 0)), 0) as Sum_Committed_Dollar,
					ISNULL(SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Actual_Dollar, 0)), 0) as Sum_Actual_Dollar
			FROM 	Simple_Budget
			
			INNER JOIN Simple_Budget_Class_Association
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Class_Association.Simple_Budget_ID
			AND		Simple_Budget_Class_Association.Deleted = 0
			AND		Simple_Budget_Class_Association.Active = 1
			
			INNER JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Class_Association.Simple_Budget_Class_ID

			INNER JOIN Simple_Budget_Template_Mapping	
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			AND		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			AND		Simple_Budget_Template_Mapping.Deleted = 0
			
			INNER JOIN Simple_Budget_Template_Position_Allocation
			ON		Simple_Budget_Template_Position_Allocation.Deleted = 0
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			AND		Simple_Budget_Template_Position_Allocation.Template_Parent_ID = Simple_Budget_Template_Mapping.Template_Parent_ID
			AND		Simple_Budget_Template_Position_Allocation.User_Positions_ID IN (SELECT Allow_User_Positions_ID FROM ##Tmp_Allow_User_Positions_ID)
			
			INNER JOIN User_Positions
			ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
			
			WHERE	Simple_Budget.Deleted = 0
			
			GROUP BY 	Simple_Budget.Simple_Budget_ID, Simple_Budget_Class.Simple_Budget_Class_ID,
						Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
						Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc,
						Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
						User_Positions.User_Positions_ID, User_Positions.Position_Label
			
			ORDER BY 	Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
						Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc,
						User_Positions.Position_Label
						
			drop table ##Tmp_User_Positions
			drop table ##Tmp_Allow_User_Positions_ID
		</cfquery>
		
		<cfreturn qGetBudgetSummaryReport />
		
	</cffunction>

</cfcomponent>
