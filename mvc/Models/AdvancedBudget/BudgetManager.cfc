<!--------------------------------------------------------------------------------------------------------------------------------------------------------
Component: \mvc\Models\AdvancedBudget\BudgetManager.cfc
Date:      2011 July 18
Author:    Deepa

Remarks:
--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent alias="mvc.Models.AdvancedBudget.BudgetManager">


	<cffunction name="getContributionFactorTypes" returntype="query" access="public" hint="Will return a query with all Contribution Factor Types" output="false">

		<cfset var qGetContributionFactorTypes = "" />
		<cfquery name="qGetContributionFactorTypes" datasource="#application.datasource#">
			SELECT	Budget_Contribution_Factor_Type_ID, Contribution_Factor_Type, List_Order
			FROM	Budget_Contribution_Factor_Type
			WHERE	Deleted = 0
		</cfquery>

		<cfreturn qGetContributionFactorTypes />

	</cffunction>

	<cffunction name="refreshCommittedForProgram" returntype="void" access="public" hint="Will update the committed dollar based on a program" output="false">

		<cfargument name="programId" type="numeric" required="true" />

		<cfstoredproc procedure="ADV_BUDGET_COMMITTED_DOLLAR_UPDATE" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@budget_id" value = "0" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@program_id" value = "#arguments.programId#" null="no">
		</cfstoredproc>

	</cffunction>


	<cffunction name="refreshCommittedForBudget" returntype="void" access="public" hint="Will update the committed dollar based on a program" output="false">

		<cfargument name="budgetId" type="numeric" required="true" />

		<cfstoredproc procedure="ADV_BUDGET_COMMITTED_DOLLAR_UPDATE" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@budget_id" value = "#arguments.budgetId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@program_id" value = "0" null="no">
		</cfstoredproc>

	</cffunction>


	<cffunction name="getBudgetsForBillback" returntype="query" access="public" hint="Get budgets for billback" output="false">

		<cfargument name="billbackId" type="string" required="true" />

		<cfquery name="qBudgetsForBillback" datasource="#application.datasource#">
			SELECT	*
			FROM	DBO.UDF_ADV_BUDGET_GET_AVAIL_FOR_BB (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">, 1, DEFAULT) <!--- Arg 2: 1=Get details for display --->
			Order By Contract_Number
		</cfquery>

		<cfreturn qBudgetsForBillback />

	</cffunction>


	<cffunction name="isBillbackDollarWithinBudget" returntype="boolean" access="public" hint="Find out if billback approved dollar is within budget balance" output="false">

		<cfargument name="billbackId" type="string" required="true" />

		<cfscript>
			local.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		</cfscript>

		<cfquery name="qBudgetFailure" datasource="#application.datasource#">
			<cfif local.appSettings.get_Setting('Accrual_Budgets_Calculation_By_Client') eq "1">
				<!--- This will check if all of the billback money is allocated to a budget and that it is not over the budget balance
				For now we will apply this logic only when app setting Accrual_Budgets_Calculation_By_Client is ON.
				--->
				IF OBJECT_ID('tempdb..##TMP_Get_Budgets') IS NOT NULL
					DROP TABLE ##TMP_Get_Budgets

				CREATE TABLE ##TMP_Get_Budgets
				(
					Budget_ID INT,
					Budget_Contribution_Factor_Type_ID INT,
					Allocated_Amount DECIMAL(20,4),
					Program_ID INT,
					Budget_Dollar DECIMAL(20,2),
					Actual_Dollar DECIMAL(20,2),
					Billback_Approved_Amount DECIMAL(20,2)
				)

				DECLARE @BB_Claimed_Amt DECIMAL(20, 2)

				INSERT INTO ##TMP_Get_Budgets (Budget_ID, Budget_Contribution_Factor_Type_ID, Allocated_Amount, Program_ID, Budget_Dollar, Actual_Dollar, Billback_Approved_Amount)
				SELECT	Budget_ID, Budget_Contribution_Factor_Type_ID, Billback_Program_Approved_Amount, Contract_Main_ID, ISNULL(Budget_Dollar, 0), ISNULL(Actual_Dollar, 0), Billback_Approved_Amount
				FROM	DBO.UDF_ADV_BUDGET_GET_AVAIL_FOR_BB(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">, 0, DEFAULT) <!--- Arg 2: 0=Do not get details for display --->
				WHERE	Budget_Position_ID is NOT NULL
				OR		Distributor_ID is NOT NULL

				SELECT @BB_Claimed_Amt = Billback_Approved_Amount FROM ##TMP_Get_Budgets

				IF (SELECT SUM(Allocated_Amount) FROM ##TMP_Get_Budgets) < @BB_Claimed_Amt <!--- All of the billback money is not allocated to a budget --->
				OR <!--- No budget balance --->
				(
					SELECT	COUNT(*) as failure_count
					FROM	##TMP_Get_Budgets
					WHERE	Budget_Contribution_Factor_Type_ID != 3 <!--- If Variable, no need to check for balance --->
					AND		Allocated_Amount > Budget_Dollar - Actual_Dollar <!--- Budget found, but no balance --->
				) > 0
				BEGIN
					SELECT	1 as failure_count
				END
				ELSE
				BEGIN
					SELECT	0 as failure_count
				END
			<cfelse>
				<!--- This will check if there is any budget found, that the allocated billback dollar is within the budget balance
				If some of the billback days ar eoutside budget, this will not catch it.
				--->
				SELECT	COUNT(*) as failure_count
				FROM	DBO.UDF_ADV_BUDGET_GET_AVAIL_FOR_BB(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackId#">, 0, DEFAULT) <!--- Arg 2: 0=Do not get details for display --->
				WHERE	Budget_Contribution_Factor_Type_ID != 3 -- Variable
				AND		(
							(Budget_Position_ID is NULL AND Distributor_ID is NULL) <!--- No budget found for this position/distributor --->
							OR Billback_Program_Approved_Amount > Budget_Dollar - Actual_Dollar <!--- Budget found for this position/distributor, but no balance --->
						)
			</cfif>
		</cfquery>

		<cfif qBudgetFailure.failure_count>
			<cfreturn 0 />
		<cfelse>
			<cfreturn 1 />
		</cfif>

	</cffunction>



	<cffunction name="addBillbackToBudget" returntype="void" access="public" hint="Find out if billback approved dollar is within budget balance" output="false">

		<cfargument name="billbackId" type="string" required="true" />

		<cfstoredproc procedure="ADV_BUDGET_ACTUAL_ADD_BILLBACK" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value = "#arguments.billbackId#" null="no">
		</cfstoredproc>

	</cffunction>


	<cffunction name="updateProgramBillbackBudget" returntype="void" access="public" hint="Find out if billback approved dollar is within budget balance" output="false">

		<cfargument name="programId" type="numeric" required="true" />

		<cfstoredproc procedure="ADV_BUDGET_ACTUAL_ADD_BILLBACK" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="yes">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Program_ID" value = "#arguments.programId#" null="no">
		</cfstoredproc>

	</cffunction>


	<cffunction name="updateBudgetForProgramReassign" returntype="void" access="public" hint="Move program committed and actual to new position" output="false">

		<cfargument name="programId" type="numeric" required="true" />

		<cfset refreshCommittedForProgram(programId = arguments.programId) />
		<cfset updateProgramBillbackBudget(programId = arguments.programId) />

	</cffunction>

	<!---------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getActualAdjustments" access="public" returntype="query" output="no" hint="Get actual adjustment">
		<cfargument name="contractnumber" type="any" required="false" default="" />
		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT TOP 5000
			baa.Adjustment_Date
			,baa.Adjustment_Dollar
			,baa.Adjustment_Notes
			,lsname.Program_Lump_Sum_Name
			,ls.Lump_Sum_Amount
			,cm.Contract_Number
			,cm.Contract_Title
			,c.name as Distributor_Name
			,C.Shr_Ship_To
			,baa.Start_Date
			,baa.End_Date
			FROM Budget_Actual_Adjustment baa
			INNER JOIN CONTRACT_MAIN cm ON cm.Contract_Main_ID = baa.Contract_Main_ID
			INNER JOIN PROGRAM_LUMP_SUMS ls ON ls.Program_Lump_Sum_ID = baa.Program_Lump_Sum_ID
			AND ls.Deleted = 0
			LEFT JOIN PROGRAM_LUMP_SUM_NAME lsname ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
			LEFT JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = baa.BSA_Foodservice_Customers_ID
			<cfif len(arguments.contractnumber)>
				WHERE 	CM.CONTRACT_NUMBER  = '#arguments.contractnumber#'
			</cfif>
			ORDER BY baa.Created_Date DESC
		</cfquery>
		<cfreturn local.query>
	</cffunction>

	<!---------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="actAdjProgramExists" access="remote" returnFormat="json" output="no" hint="Detect if an actual adjustment exists">
		<cfargument name="adjustment_date" type="date" required="true">
		<cfargument name="adjustment_dollar" type="string" required="true">
		<cfargument name="contract_main_id" type="numeric" required="true">
		<cfargument name="lump_sum" type="string" required="true">

			<cfset local.result = {}>
			<!--- replace all commas with blank --->
			<cfset local.adjustment_dollar = replace(arguments.adjustment_dollar, ",", "", "all")>
			<!--- replace all dollar signs with blank --->
			<cfset local.adjustment_dollar = replace(arguments.adjustment_dollar, "$", "", "all")>

			<!--- look for actual adjustment with same date, dollar amt, program ID, and lump sump ID --->
			<cftry>
				<cfquery name="local.query" datasource="#application.datasource#">
					SELECT 1
					FROM Budget_Actual_Adjustment
					WHERE Adjustment_Date     = <cfqueryparam cfsqltype="cf_sql_date"    value="#arguments.adjustment_date#">
					AND Adjustment_Dollar   = <cfqueryparam cfsqltype="cf_sql_decimal" value="#local.adjustment_dollar#" scale="2">
					AND Contract_Main_ID    = <cfqueryparam cfsqltype="cf_sql_integer"     value="#arguments.contract_main_id#">
					AND Program_Lump_Sum_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lump_sum#">
				</cfquery>
				<cfcatch type="any">
					<!--- oops! error just occurred --->
					<cfset local.query = queryNew( 'foo' )>
				</cfcatch>
			</cftry>

		<cfset local.result.recordExists = (local.query.recordCount gt 0)>
		<cfreturn local.result>
	</cffunction>

	<!---------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="actAdjProgram" access="remote" returnFormat="json" output="no" hint="Process program information for actual adjustment">
		<cfargument name="program_number" type="string" required="true" hint="Program number (digits only without PRG- prefix)">
		<cfargument name="adjustment_date" type="string" required="true">

		<!--- notes: any changes in result structure would require changes in \settings\Advanced_Budget\addactadjustment.cfm --->

		<cfscript>
			result = {};
			result.errors = [];
			result.lump_sum = [];
			result.Program_Lump_Sum_ID = [];

			result.date_range = [];
			result.StartDate = [];
			result.EndDate = [];
			result.date_range_id = [];

			arguments.program_number = trim(arguments.program_number);
		</cfscript>

		<cfif len(arguments.program_number) eq 0 or not isNumeric(arguments.program_number)>
			<cfset arrayAppend(result.errors, 'Please enter a valid program number.' )>
		</cfif>

		<cfif len(arguments.adjustment_date) eq 0 or not isDate(arguments.adjustment_date)>
			<cfset arrayAppend(result.errors, 'Please enter a valid adjustment date.' )>
		</cfif>

		<cfif arrayLen(result.errors) eq 0>
			<cfoutput>
				<!--- wrap the query in try catch to prevent invalid program number (too many digits, contains alpha characters, etc..) --->
				<cftry>
					<cfquery name="local.query" datasource="#application.datasource#">
						SELECT  cm.Contract_Main_Id
								,cm.Contract_Number
								,cm.Contract_Title
								,cm.Approved
								,cm.Manual_Cancel
								,cm.business_segment_id
								,cm.Contract_Start_Date
								,cm.Contract_End_Date
								,CASE t.BillBack_Date
									WHEN 1 THEN Cast( DateAdd( d, t.BillBack_Date_Span, cm.Contract_End_Date ) AS DATETIME )
									ELSE NULL
								END AS lastDateToClaim
								,ls.Program_Lump_Sum_ID
								,lsname.Program_Lump_Sum_Name
								,ls.Lump_Sum_Amount
						FROM 	CONTRACT_MAIN cm
						INNER JOIN PROGRAM_CONTROL_PANEL_OPTIONS t ON cm.ProgramType_Id = t.ProgramControl_Panel_Options_Id
						LEFT JOIN PROGRAM_LUMP_SUMS ls ON ls.Program_Id = cm.Contract_Main_Id
							AND ls.Deleted = 0
						LEFT JOIN PROGRAM_LUMP_SUM_NAME lsname ON lsname.Program_Lump_Sum_Name_Id = ls.Program_Lump_Sum_Name_Id
						WHERE 1 = 1
						AND 	cm.Deleted = 0
						AND 	RIGHT( cm.Contract_Number, 7 ) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.program_number#">
						ORDER BY cm.Approved DESC, cm.Contract_Main_Id DESC
					</cfquery>
					<cfcatch type="any">
						<!--- oops! error just occurred --->
						<cfset local.query = queryNew( 'foo' )>
					</cfcatch>
				</cftry>
			</cfoutput>


			<!--- perform validations on entered program --->
			<cfscript>
				if ( local.query.recordCount eq 0 ) {
					arrayAppend(result.errors, 'The program you entered does not exists.' );
				}
				else {
					if ( local.query.manual_cancel neq 0 ) {
						arrayAppend(result.errors, 'Selected program has been cancelled.' );
					}
					else if ( local.query.approved neq 1 ) {
						arrayAppend(result.errors, 'Selected program has not been approved.' );
					}

					if ( local.query.Program_Lump_Sum_ID eq '' ) {
						arrayAppend(result.errors, 'Selected program does not have lump sum.' );
					}

					if ( isDate(local.query.lastDateToClaim) and local.query.lastDateToClaim lt arguments.adjustment_date ) {
						arrayAppend(result.errors, 'Selected program has last date to claim of ' & dateFormat(local.query.lastDateToClaim, 'medium'));
					}

					if (structKeyExists(request.AccessStructure, "user_business_segments") and ListFind(request.AccessStructure.user_business_segments, local.query.business_segment_id) eq 0) {
						local.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
						arrayAppend(result.errors, 'Selected program is from a ' & local.appSettings.getbusiness_segment_label() & ' you do not have access rights to.');
						arrayAppend(result.errors, 'Please select a different program or ask your administrator to adjust your access rights.');
					}
				}
			</cfscript>
		</cfif>

		<!--- found no errors in validating program, pass information from db back --->
		<cfif ( arrayLen(result.errors) eq 0 )>
			<cfscript>
				result.Contract_Main_Id 	= local.query.Contract_Main_Id;
				result.Contract_Number  	= local.query.Contract_Number;
				result.Contract_Title   	= local.query.Contract_Title;
				result.Contract_Start_Date 	= local.query.Contract_Start_Date;
				result.Contract_End_Date 	= local.query.Contract_End_Date;
			</cfscript>

			<cfloop query="local.query">
				<cfif local.query.contract_main_id eq result.contract_main_id>
					<cfscript>
						arrayAppend(result.Program_Lump_Sum_ID, local.query.Program_Lump_Sum_ID);
						arrayAppend(result.lump_sum, local.query.Program_Lump_Sum_Name & '  ' & DollarFormat(local.query.Lump_Sum_Amount));
					</cfscript>
				</cfif>
			</cfloop>

			<!--- gather distributor information --->
			<cfquery name="local.query" datasource="#application.datasource#">
				SELECT TOP 1
				C.BSA_Foodservice_Customers_ID
				,C.Shr_Ship_To
				,C.Name AS Distributor_Name
				FROM CONTRACT_MAIN cm
				INNER JOIN Contract_Distributors CD ON CD.Contract_Main_ID = cm.Contract_Main_ID
				AND CD.Deleted = 0
				AND CD.Is_Group = 0
				INNER JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
				WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#result.Contract_Main_Id#">
			</cfquery>

			<cfscript>
				result.Distributor_Name = local.query.Distributor_Name;
				result.Shr_Ship_To = local.query.Shr_Ship_To;
				result.BSA_Foodservice_Customers_ID = local.query.BSA_Foodservice_Customers_ID;
			</cfscript>

			<!--- Set the Calendar values here --->

			<cfset var oBudgetClassMgr = createObject("component","mvc.Models.AdvancedBudget.BudgetClassManager") />
			<cfset 	qryDateRange = oBudgetClassMgr.getDateRange(result.Contract_Start_Date,result.Contract_End_Date)/>
<!--- 			<cfquery name="qryDateRange" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmpDateRange') IS NOT NULL
				DROP TABLE ##tmpDateRange

				CREATE TABLE ##tmpDateRange
				(
				DateRangeID int  IDENTITY(1,1) NOT NULL,
				Start_Date [datetime],
				End_Date [datetime]
				)
				DECLARE
				@sDate datetime = '#result.Contract_Start_Date#',
				@eDate datetime = '#result.Contract_End_Date#'

				INSERT INTO ##tmpDateRange
				SELECT @sDate  AS start_Date,End_Date   from Fiscal_Year where @sDate  between start_Date AND End_Date AND Deleted = 0
				UNION
				SELECT Start_Date,End_Date  from Fiscal_Year where start_date >= @sDate AND End_Date <=@eDate AND Deleted = 0
				UNION
				SELECT Start_Date, @eDate AS End_Date  FROM Fiscal_Year WHERE @eDate BETWEEN Start_Date AND  End_Date AND Deleted = 0
				ORDER BY start_Date

				SELECT * FROM ##tmpDateRange ORDER BY Start_Date
				DROP TABLE ##tmpDateRange
			</cfquery>
 --->
			<cfloop query="qryDateRange">
				<cfscript>
					arrayAppend(result.date_range_id, qryDateRange.DateRangeID);
					arrayAppend(result.date_range, DateFormat(qryDateRange.Start_Date,"mm/dd/yyyy") & ' - ' & DateFormat(qryDateRange.End_Date,"mm/dd/yyyy"));
					arrayAppend(result.StartDate, qryDateRange.Start_Date );
					arrayAppend(result.EndDate, qryDateRange.End_Date);
				</cfscript>
			</cfloop>

		</cfif>

		<cfreturn result>
	</cffunction>

	<!---D33624:Mass Reassign - Budget Picker --->
	<cffunction name="save_budgets" output="false">
		<cfargument name="form" type="any" required="true">
		<cfargument name="recalcBudget" type="boolean" required="false" default="0">

		<cfset form = arguments.form>
		<cfloop list="#form.contract_number#" index="contract_number" delimiters="," >
			<!---D40330: Event error on reassign when there is no budget --->
			<cfif isDefined("form.class_type_#contract_number#")>

				<!--- We need to update budget on all versions --->
				  <cfquery name="vars.GetProgramList" datasource="#application.datasource#">
					SELECT 	CM.Contract_Main_ID, CM.Contract_Status_Type_IDX
					FROM 	Contract_Main
					INNER JOIN Contract_Main CM
					ON		CM.Contract_Number = Contract_Main.Contract_Number
					AND		(CM.Approved = 1 OR CM.Deleted = 0)
					WHERE 	Contract_Main.Contract_Main_ID = <cfqueryparam value="#contract_number#" cfsqltype="cf_sql_integer">
					UNION
					SELECT 	Contract_Main_ID, Contract_Status_Type_IDX
					FROM 	Contract_Main
					WHERE 	Contract_Main.Contract_Main_ID = <cfqueryparam value="#contract_number#" cfsqltype="cf_sql_integer">
				  </cfquery>

				<cfoutput query="vars.GetProgramList">

					<cfquery name="original" datasource="#application.datasource#">
						SELECT Budget_ID
						FROM Budget_Program_Selection
						WHERE Program_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfset originalBudgets = valueList(original.budget_id)>>

					<cfquery name="vars.removal" datasource="#application.datasource#">
						DELETE Budget_Program_Selection
						WHERE Program_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfset class_type = Evaluate("form.class_type_#contract_number#") />
					<cfset classlist = Evaluate("form.budget_class_list_#class_type#_#contract_number#")>

					<cfloop list="#classlist#" index="class" delimiters="," >
						<cfset budget_id = Evaluate("form.budget_#class#_#contract_number#")>
						<cfif budget_id>
							<cfset classId = class />
							<cfif classId eq 0><!--- partial budget, get class id from the budget selected --->
								<cfquery name="getBudgetClass" datasource="#application.datasource#">
									SELECT 	Budget_Class_ID
									FROM 	Budget
									WHERE 	Budget_ID = <cfqueryparam value="#budget_id#" cfsqltype="cf_sql_integer">
								</cfquery>
								<cfset classId = getBudgetClass.Budget_Class_ID />
							</cfif>
							<cfquery name="saveBudget" datasource="#application.datasource#">
								INSERT INTO Budget_Program_Selection
									( Program_ID
									, Budget_Class_ID
									, Budget_ID
									)
								VALUES
									( <cfqueryparam value="#Contract_Main_ID#" cfsqltype="cf_sql_integer">
									, <cfqueryparam value="#classId#" cfsqltype="cf_sql_integer">
									, <cfqueryparam value="#budget_id#" cfsqltype="cf_sql_integer">
									)
							</cfquery>
						</cfif>
					</cfloop>

					<cfquery name="saveOldBudget" datasource="#application.datasource#">
						INSERT INTO Budget_Program_Selection_History
							( 	Budget_Program_Selection_ID
								, Program_ID
								, Budget_Class_ID
								, Budget_ID
								, Created_Date
							)
						SELECT 	Budget_Program_Selection_ID
								, Program_ID
								, Budget_Class_ID
								, Budget_ID
								, Created_Date
						FROM  	Budget_Program_Selection
						WHERE  	Program_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif Contract_Status_Type_IDX gte 3>
						<!--- count number of newly selected budgets --->
						<cfquery name="isBudgetChanged" datasource="#application.datasource#">
							SELECT 	COUNT(1) AS rCount
							FROM 	Budget_Program_Selection
							WHERE 	Program_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="cf_sql_integer">
							<cfif len(trim(originalBudgets))>
								AND NOT Budget_ID IN (<cfqueryparam value="#originalBudgets#" list="true"/>)
							</cfif>
						</cfquery>

						<!--- refresh dollar amounts when there is newly selected budget --->
						<!--- refresh dollar amounts from reassing to reflect position changes --->
						<cfif arguments.recalcBudget OR isBudgetChanged.rCount gt 0>
							<cfset oBudgetManager = createObject('component','mvc.Models.AdvancedBudget.BudgetManager') />
							<cfset oBudgetManager.refreshCommittedForProgram(programId = Contract_Main_ID) />
							<cfset oBudgetManager.updateProgramBillbackBudget(programId = Contract_Main_ID) />
						</cfif>
					</cfif>
				</cfoutput><!--- Loop over all versions --->
			</cfif>
			<!---D40330: Event error on reassign when there is no budget --->

		</cfloop>
	</cffunction>
	<!---D33624:Mass Reassign - Budget Picker --->

</cfcomponent>