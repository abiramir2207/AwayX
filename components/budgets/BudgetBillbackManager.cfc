<cfcomponent displayname="BudgetBillbackManager" hint="Budget Billback Manager" extends="components.Base">

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Budget Billback ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cffunction name="init" returntype="components.budgets.BudgetBillbackManager" output="false">
		<cfset this.budgetFunctionalityOnVar = application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBillbackBudgetSelection" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true" />
		
		<cfquery name="qGetBillbackBudgetSelection" datasource="#application.datasource#">
			SELECT	Billback.BB_Code, Billback.BB_Title,
					Billback.Billback_Status_ID,
					Billback_Program.Billback_Program_ID, Contract_Main.Contract_Number, Contract_Main.Contract_Title,
					Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class.Simple_Budget_Class_Desc,
					Simple_Budget.Simple_Budget_Number, Simple_Budget.Simple_Budget_Desc, 
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_ID, Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
					Allocated_Percent, Actual_Dollar, *
			FROM	Billback
			
			LEFT JOIN Billback_Program
			ON	Billback_Program.Deleted = 0
			AND	Billback_Program.Billback_ID = Billback.Billback_ID
			
			LEFT JOIN Contract_Main
			ON	Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			
			LEFT JOIN Simple_Budget_Actual_Billback_Detail
			ON	Simple_Budget_Actual_Billback_Detail.Billback_ID = Billback.Billback_ID
			AND	Simple_Budget_Actual_Billback_Detail.Billback_Program_ID = Billback_Program.Billback_Program_ID
			
			LEFT JOIN Simple_Budget
			ON	Simple_Budget.Simple_Budget_ID = Simple_Budget_Actual_Billback_Detail.Simple_Budget_ID
			
			LEFT JOIN Simple_Budget_Class
			ON	Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Actual_Billback_Detail.Simple_Budget_Class_ID
						
			LEFT JOIN Simple_Budget_Class_Association
			ON	Simple_Budget_Class_Association.Simple_Budget_ID = Simple_Budget.Simple_Budget_ID
			AND	Simple_Budget_Class_Association.Simple_Budget_Class_ID = Simple_Budget_Class.Simple_Budget_Class_ID
			
			WHERE	Billback.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
			
			ORDER BY Contract_Main.Contract_Number, Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number
		</cfquery>
		
		<cfreturn qGetBillbackBudgetSelection />
	</cffunction>
		
	<cffunction name="getBudgetsForBillback" output="false" returntype="query">
		<cfargument name="billbackId" type="string" required="true" />
		
		<cfstoredproc procedure="BUDGET_FOR_BILLBACK" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_varchar" value = "#arguments.billbackId#" null="no">
			
			<cfprocresult name="qBudgetsForBillback" resultSet="2" />
		
		</cfstoredproc>
		
		<cfreturn qBudgetsForBillback />
	</cffunction>
	
	<cffunction name="getBudgetDetailsForBillback" output="false" returntype="array">
		<cfargument name="billbackId" type="string" required="true" />
		
		<cfstoredproc procedure="BUDGET_FOR_BILLBACK" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_varchar" value = "#arguments.billbackId#" null="no">
			
			<cfprocresult name="qBudgetDetailsForBillback" resultSet="1" />
			<cfprocresult name="qBudgetsForBillback" resultSet="2" />
		
		</cfstoredproc>
		
		<cfset qArray = ArrayNew(1)>
		<cfset qArray[1] = qBudgetDetailsForBillback />
		<cfset qArray[2] = qBudgetsForBillback />
		
		<cfreturn qArray />
	</cffunction>	
	
	<cffunction name="saveBudgetBillback" output="true" returntype="numeric">
		<cfargument name="billbackID" type="string" required="true" />
		<cfargument name="oForm" type="struct" required="true" />
		<cfargument name="userID" type="string" required="true" />
		
		
		<cfset qBudgetsForBillback = getBudgetsForBillback(billbackID = arguments.billbackID) />
		<cfset anyBudgetOverLimit = 0 />
		<cfset sendEmail = 0 />
		<cftransaction action="begin">
			<cftry>
				<!--- insert into history table ---->
				<cfquery name="qDeleteActualBillbackBudget" datasource="#application.datasource#">
					DELETE
					FROM	Simple_Budget_Actual_Billback_Detail
					WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				
				<cfparam name="oForm.Billback_Program_ID_List" default="">
				<cfparam name="oForm.Budget_Billback_Payee_Type_ID" default="">
				<cfparam name="oForm.Budget_Billback_Payee_ID" default="">
				<cfset Billback_Payee_Type_ID = oForm.Budget_Billback_Payee_Type_ID />
				<cfset Payee_ID = oForm.Budget_Billback_Payee_ID />
				<cfloop list="#oForm.Billback_Program_ID_List#" index="currentBillbackProgramID">
					<cfset currentBillbackProgramIDRe = replace(currentBillbackProgramID, "-", "_", "all") />
					<cfparam name="oForm.Simple_Budget_Class_Association_ID_#currentBillbackProgramIDRe#" default="">
					<cfparam name="oForm.Billback_Program_Dollar_#currentBillbackProgramIDRe#" default="0">
					
					<cfset Simple_Budget_Class_Association_ID_List = Evaluate("oForm.Simple_Budget_Class_Association_ID_#currentBillbackProgramIDRe#") />
					<cfset Billback_Program_Dollar = Evaluate("oForm.Billback_Program_Dollar_#currentBillbackProgramIDRe#") />
					
					<cfloop list="#Simple_Budget_Class_Association_ID_List#" index="budgetClassAssociationID">
						<!--- get budget and class id ----->
						<cfquery name="qGetBudgetClassAssociation" datasource="#application.datasource#">
							SELECT	*
							FROM	Simple_Budget_Class_Association
							WHERE	Simple_Budget_Class_Association_ID = <cfqueryparam value="#budgetClassAssociationID#" cfsqltype="cf_sql_integer">
						</cfquery>
						
						<cfparam name="oForm.billback_budget_percent_#currentBillbackProgramIDRe#_#budgetClassAssociationID#" default="0">
						<cfset budgetID = qGetBudgetClassAssociation.Simple_Budget_ID />
						<cfset budgetClassID = qGetBudgetClassAssociation.Simple_Budget_Class_ID />
						<cfset budgetPercent = Evaluate("oForm.billback_budget_percent_#currentBillbackProgramIDRe#_#budgetClassAssociationID#") />
						<cfif IsNumeric(budgetPercent) and budgetPercent neq 0>
							<cfset budgetDollar = budgetPercent * 0.01 * Billback_Program_Dollar />
							
							<cfquery name="qGetBudgetBalance" dbtype="query">
								SELECT	Budget_Balance
								FROM	qBudgetsForBillback
								WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
								AND		Billback_Program_ID = <cfqueryparam value="#currentBillbackProgramID#" cfsqltype="cf_sql_varchar">
								AND		Simple_Budget_Class_ID = <cfqueryparam value="#budgetClassID#" cfsqltype="cf_sql_integer">
								AND		Simple_Budget_ID = <cfqueryparam value="#budgetID#" cfsqltype="cf_sql_integer">
							</cfquery>
							
							<cfset Current_Budget_Balance = Val(qGetBudgetBalance.Budget_Balance) />
							<cfif budgetDollar GT Current_Budget_Balance AND budgetDollar GT 0>
								<cfset anyBudgetOverLimit = 1 />
							</cfif>
							
							<cfquery name="qInsertActualBillbackBudgetSelection" datasource="#application.datasource#">
								INSERT INTO Simple_Budget_Actual_Billback_Detail (Simple_Budget_Class_ID, Simple_Budget_ID, Billback_ID, Billback_Program_ID, Billback_Payee_Type_ID, Payee_ID, 
									Allocated_Percent, Actual_Dollar, Created_By)
								VALUES (
								<cfqueryparam value="#budgetClassID#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#budgetID#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#currentBillbackProgramID#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#Billback_Payee_Type_ID#" cfsqltype="cf_sql_integer" null="#not IsNumeric(Billback_Payee_Type_ID)#">,
								<cfqueryparam value="#Payee_ID#" cfsqltype="cf_sql_varchar" null="#Not Len(Payee_ID)#">,
								<cfqueryparam value="#budgetPercent#" cfsqltype="cf_sql_decimal">,
								<cfqueryparam value="#budgetDollar#" cfsqltype="cf_sql_decimal">,
								<cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_varchar">
								)
							</cfquery>
							
						</cfif>
					</cfloop>
					
				</cfloop>
				
				<!--- insert into history table ---->
				<cfquery name="qInsertActualBillbackBudgetHistory" datasource="#application.datasource#">
					INSERT INTO Simple_Budget_Actual_Billback_Detail_History (Simple_Budget_Actual_Billback_Detail_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Billback_ID, Billback_Program_ID, Billback_Payee_Type_ID, Payee_ID, Allocated_Percent, Actual_Dollar, Created_By, Created_Date)
					SELECT	Simple_Budget_Actual_Billback_Detail_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Billback_ID, Billback_Program_ID, Billback_Payee_Type_ID, Payee_ID, Allocated_Percent, Actual_Dollar, Created_By, Created_Date
					FROM	Simple_Budget_Actual_Billback_Detail
					WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				
				<!---- set/reset billback status from/to pending fund update ----->
				<cfset bSetToPendingFundUpdate = 0 />
				<cfif anyBudgetOverLimit eq 1>
					<cfset profile = CreateObject("component","components.user.Profile").init() />
					<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
					<cfif Get_Profile_Settings.Approve_BB_Beyond_Budget eq 0><!---- user cannot approve beyond budget ---->
						<cfset bSetToPendingFundUpdate = 1 />
					</cfif>
				</cfif>

				<cfset updateBillbackStatus(
							billbackID = arguments.billbackID, 
							setToPendingFundUpdate = bSetToPendingFundUpdate) />
							
				<cfif bSetToPendingFundUpdate eq 0>
				
					<cfset updateProgramActualDollar(billbackID = arguments.billbackID) />
					
					 <cfif anyBudgetOverLimit eq 1>
						<cfset sendEmail = 1 />
					</cfif>
					
				</cfif>
				
				<cftransaction action="commit" />
				<cfcatch>
					<cftransaction action="rollback" />
					<cfrethrow>
				</cfcatch>
			
			</cftry>
		</cftransaction>
		
		<!---- email need to be outside the cftransaction, as cfc does not support nested transaction
		MessageLog.cfc has another cftransaction which is called from the email function billbackApproveEmail / email wrapper
		 ---->
		<cfif sendEmail>
			<!--- send out email --->
			<cfset billbackApproveEmail(billbackId = arguments.billbackID) />
		</cfif>
		
		<cfreturn bSetToPendingFundUpdate />
	</cffunction>
	
	<cffunction name="billbackApproveEmail" output="false" returntype="void">
	
		<cfargument name="billbackId" type="string" required="true" />
		
		<cfinclude template="/settings/budgets/budget_billback_approve_email.cfm" />
		
	</cffunction>
	
	<cffunction name="updateProgramActualDollar" output="true" returntype="void">
		<cfargument name="billbackID" type="string" required="true" />
		
		<cfstoredproc procedure="BUDGET_PROGRAM_ACTUAL_UPDATE" datasource="#application.datasource#">
						
			<cfprocparam type="In" CFSQLType="CF_SQL_varchar" value = "#arguments.billbackId#" null="no">
			
		</cfstoredproc>
		
	</cffunction>
	
	<cffunction name="updateBillbackStatus" output="true" returntype="void">
		<cfargument name="billbackID" type="string" required="true" />
		<cfargument name="setToPendingFundUpdate" type="boolean" required="true" />
		
		<CFQUERY NAME="qCheckBillbackStatus" DATASOURCE="#application.datasource#">
			SELECT	Billback_Status_ID
			FROM	Billback
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>
		
		<cfif arguments.setToPendingFundUpdate eq 1><!--- set to pending fund update ---->
			<cfif qCheckBillbackStatus.Billback_Status_ID neq 6><!--- set only if teh billback is not already in pending fund update ---->
				<CFQUERY NAME="UpdateBillbackStatusPendingFundUpdate" DATASOURCE="#application.datasource#">
					UPDATE 	Billback
					SET 	Billback_Status_ID = 6
					WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
				</CFQUERY>
			</cfif>
		<cfelse><!--- set to be not pending fund update ---->
			<cfif qCheckBillbackStatus.Billback_Status_ID eq 6><!--- set only if the billback is already in pending fund update ---->
				<CFQUERY NAME="UpdateBillbackStatusApproved" DATASOURCE="#application.datasource#">
					UPDATE 	Billback
					SET 	Billback_Status_ID = 3
					WHERE 	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
				</CFQUERY>
			</cfif>
		</cfif>
		
		
	</cffunction>
	
	<!----
	<cffunction name="saveBudgetBillback" output="false" returntype="void">
		<cfargument name="billbackID" type="string" required="true" />
		<cfargument name="budgetClassAssociationID" type="numeric" required="true" />
		<cfargument name="actualDollar" type="numeric" required="true" />
		<cfargument name="userID" type="string" required="true" />
		
		<cftransaction action="begin">
			<cftry>
				<!--- insert into history table ---->
				<cfquery name="qDeleteActualBillbackBudget" datasource="#application.datasource#">
					DELETE
					FROM	Simple_Budget_Actual_Billback_Detail
					WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				
				<cfif arguments.budgetClassAssociationID neq 0>
					
					<!--- get budget and class id ----->
					<cfquery name="qGetBudgetClassAssociation" datasource="#application.datasource#">
						SELECT	*
						FROM	Simple_Budget_Template_Mapping
						WHERE	Simple_Budget_Template_Mapping_ID = <cfqueryparam value="#arguments.budgetClassAssociationID#" cfsqltype="cf_sql_integer">
					</cfquery>
					
					<cfset budgetID = qGetBudgetClassAssociation.Simple_Budget_ID />
					<cfset budgetClassID = qGetBudgetClassAssociation.Simple_Budget_Class_ID />
					
					<cfquery name="qInsertActualBillbackBudgetSelection" datasource="#application.datasource#">
						INSERT INTO Simple_Budget_Actual_Billback_Detail (Simple_Budget_Class_ID, Simple_Budget_ID, Billback_ID, Actual_Dollar, Created_By)
						VALUES (
						<cfqueryparam value="#budgetClassID#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#budgetID#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.actualDollar#" cfsqltype="cf_sql_decimal">,
						<cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_varchar">
						)
					</cfquery>
					
					<!--- insert into history table ---->
					<cfquery name="qInsertActualBillbackBudgetHistory" datasource="#application.datasource#">
						INSERT INTO Simple_Budget_Actual_Billback_Detail_History (Simple_Budget_Actual_Billback_Detail_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Billback_ID, Actual_Dollar, Created_By, Created_Date)
						SELECT	Simple_Budget_Actual_Billback_Detail_ID, Simple_Budget_Class_ID, Simple_Budget_ID, Billback_ID, Actual_Dollar, Created_By, Created_Date
						FROM	Simple_Budget_Actual_Billback_Detail
						WHERE	Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					
				</cfif>
		
				<cftransaction action="commit" />
				<cfcatch>
					<cftransaction action="rollback" />
					<cfrethrow>
				</cfcatch>
			
			</cftry>
		</cftransaction>
		
	</cffunction>
	---->
	
</cfcomponent>