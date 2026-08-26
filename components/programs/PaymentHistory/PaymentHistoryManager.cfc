	<cfcomponent>
	<cfset appSettings = application.appSettingsGet />
	<cffunction name="getcontractInfo" output="true">
		<cfargument name="contractID" required="true" type="string" />
			<cfquery name="qgetcontractInfo" datasource="#application.datasource#">
				SELECT contract_number,contract_start_date,contract_end_date,contract_title,
					Discount_Identifier_Desc,Generic_Type,contract_status_type_desc,Program_Control_Panel_Options.created_type,
					contract_reference_number,CONVERT(VARCHAR(10),Approval_Date, 101) AS Approval_Date,
					_Users.Name_First + ' ' + _Users.Name_Last As RSP,contract_main.Released,
					ReleasedProgram.Name_First + ' ' + ReleasedProgram.Name_Last As ReleasedBy,
					CONVERT(VARCHAR(10),contract_main.Released_Date, 101) AS Released_Date
				FROM  contract_main
				INNER JOIN 	dbo.Program_Control_Panel_Options
				ON dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				INNER JOIN 	_Users
				ON contract_main.Responsible_User_ID = _Users.User_ID
				 /* ON SUBSTRING(contract_main.Responsible_User_ID,(LEN(contract_main.Responsible_User_ID)-35+1),LEN(contract_main.Responsible_User_ID)) = _Users.User_ID */
				LEFT JOIN 	_Users ReleasedProgram
				ON contract_main.Released_By = ReleasedProgram.User_ID
				LEFT JOIN dbo.Discount_Identifier
				ON dbo.Program_Control_Panel_Options.Discount_Identifier_ID = dbo.Discount_Identifier.Discount_Identifier_ID
				INNER JOIN 	contract_status_types
				ON contract_status_types.contract_status_type_id = contract_main.contract_status_type_idx
				where contract_main_id = '#arguments.contractID#'
			</cfquery>
		<cfreturn qgetcontractInfo />
	</cffunction>
	<cffunction name="getEffectiveDateInfo" output="true">
		<cfargument name="contractNumber" required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
				<cfquery name="qgetEffectiveDateInfo" datasource="#application.datasource#">
				select Min(contract_main.Effective_Start_Date) as Start_Date, Max(contract_main.Effective_End_Date) as End_Date,
					_users.Name_First + ' ' + _users.Name_Last As Cancelled_By,
					CONVERT(char(10),contract_main.Cancelled_Date,101) As cancelled_Date
				from contract_main
				LEFT JOIN _users
				ON contract_main.Cancelled_By = _users.user_id
				where
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				contract_main_id = #arguments.contractMainID#
				<cfelse>
				contract_number = '#arguments.contractnumber#'
				</cfif>
				GROUP BY _users.Name_First, _users.Name_Last,contract_main.Cancelled_Date
			</cfquery>
		<cfreturn qgetEffectiveDateInfo />
	</cffunction>
	<!--- D32973:Dates on Payment History START--->
	<cffunction name="getdateInfo" output="true">
		<cfargument name="contractNumber" required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

			<!---If planner id is passed then get date info from planner tables---->
			<cfif val(arguments.plannerID)>
				<cfquery name="qgetdateInfo" datasource="#application.datasource#">
					select	pt.Planner_Start_Date as Start_Date,
							pt.Planner_End_Date	As End_Date,
							DateDiff(day, pt.Planner_Start_Date, pt.Planner_End_Date) As DaysElapsed,
								CASE WHEN DateDiff(day,getDate(),pt.Planner_End_Date) < 0
							THEN 0
						ELSE
							DateDiff(day,getDate(),pt.Planner_End_Date)
						END
							As DaysRemaining,
							DateDiff(day, pt.Planner_Start_Date, pt.Planner_End_Date) As TotalDays,
						CASE WHEN DateDiff(day,getDate(),pt.Planner_End_Date) < 0
							THEN 0
						ELSE
						CAST((CAST(DateDiff(day,getDate(),pt.Planner_End_Date) AS DECIMAL(10,2)) / CAST(DateDiff(day,pt.Planner_Start_Date,pt.Planner_End_Date) + 1
							AS DECIMAL(10,2)))  * 100  AS DECIMAL(10,2))
						END
							As DaysReminingPercent
					from	Planners p
							inner join Planner_Template pt on pt.Planner_Template_ID = p.Planner_Template_ID
					where	p.Planner_ID = '#val(arguments.plannerID)#'


				</cfquery>
			<cfelse>

				<cfset qgetEffectiveDates = getEffectiveDateInfo(arguments.contractNumber,arguments.contractMainID)>

				<cfif qgetEffectiveDates.Start_Date neq "" AND qgetEffectiveDates.End_Date neq "">
					<!--- Dev Note (75544) - If the effective dates are not blank (this should be fired for most programs) --->
					<cfquery name="qgetdateInfo" datasource="#application.datasource#">
						select Min(Effective_Start_Date) as Start_Date, Max(Effective_End_Date) as End_Date,
						DateDiff(day,Min(Effective_Start_Date),getDate()) As DaysElapsed,
						CASE WHEN DateDiff(day,getDate(),Max(Effective_End_Date)) < 0
							THEN 0
						ELSE
							DateDiff(day,getDate(),Max(Effective_End_Date))
						END
							As DaysRemaining,
							DateDiff(day,Min(Effective_Start_Date),Max(Effective_End_Date)) + 1 As TotalDays,
						CASE WHEN DateDiff(day,getDate(),Max(Effective_End_Date)) < 0
							THEN 0
						ELSE
						CAST((CAST(DateDiff(day,getDate(),Max(Effective_End_Date)) AS DECIMAL(10,2)) / CAST(DateDiff(day,Min(Effective_Start_Date),Max(Effective_End_Date)) + 1
							AS DECIMAL(10,2)))  * 100  AS DECIMAL(10,2))
						END
							As DaysReminingPercent
						from		contract_main
						where
						<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
						contract_main_id = #arguments.contractMainID#
						<cfelse>
						contract_number = '#arguments.contractnumber#'
						</cfif>
						</cfquery>
				<cfelse>
					<!--- Dev Note (75544) - If the effective dates  blank. This is for a cancelled program --->
					<cfquery name="qgetdateInfo" datasource="#application.datasource#">
						select Min(Contract_Start_Date) as Start_Date,
						<!--- A program can be created and cancelled on the same day. In that case, "end date" would be the cancelled date,
						else "end date" would be one day before the cancelled date.
						--->
						CASE WHEN DateDiff(day, Min(Contract_Start_Date),  DateAdd(day,-1,MAX(Cancelled_Date))) < 0
							THEN
								MAX(Cancelled_Date)
						ELSE
								DateAdd(day,-1,MAX(Cancelled_Date))
						END
							As End_Date,
						<!--- Dev Note (75544); For "elapsed days", "end date" would be the "cancelled date". --->
						DateDiff(day, Min(Contract_Start_Date), MAX(Cancelled_Date)) As DaysElapsed,
						0
							As DaysRemaining,
						DateDiff(day, Min(Contract_Start_Date), MAX(Cancelled_Date)) As TotalDays,
						0
							As DaysReminingPercent
						from		contract_main
						where
						<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
							contract_main_id = #arguments.contractMainID#
						<cfelse>
							contract_number = '#arguments.contractnumber#'
						</cfif>
					</cfquery>
				</cfif>

			</cfif>
		<cfreturn qgetdateInfo />
	</cffunction>
	<!--- Get Fiscal date ranges which are within the program date span --->
	<cffunction name="getFiscalDateInfo" output="true">
		<cfargument name="contractNumber" required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfset var qgetdateInfo = getdateInfo(arguments.contractNumber,arguments.contractMainID, arguments.plannerID)>

		<cfquery name="qdropTmpTbl" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_fiscal_period') IS NOT NULL
		DROP TABLE ##tmp_fiscal_period
		</cfquery>

		<cfquery name="qgetFiscalDateInfo" datasource="#application.datasource#">
			SELECT CAST(Start_Date As Date) As Dt_Start_Date, CAST(End_Date As Date) As Dt_End_Date,
					CONVERT(char(10),fy.Start_Date,101) As Start_Date,CONVERT(char(10),fy.End_Date,101) As End_Date
			INTO ##tmp_fiscal_period
			FROM Fiscal_Year fy
			<!--- Do not use cfqueryparam, THis function needs to be called from another function which uses temp tables.
			By using cfqueryparam,##tmp_fiscal_period cannot be accessed.
			--->
			WHERE fy.Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
			AND fy.deleted = 0
			AND fy.Start_Date <= #createodbcdatetime(qgetdateInfo.End_Date)#
			AND fy.End_Date >= #createodbcdatetime(qgetdateInfo.Start_Date)#
			ORDER BY fy.Start_Date,fy.End_Date DESC

			SELECT Start_Date,End_Date FROM ##tmp_fiscal_period
		</cfquery>

		<cfreturn qgetFiscalDateInfo />
	</cffunction>
	<cffunction name="getProductGroupLevelForAccrual" output="false" returntype="query">
			<cfset useLakebaseForqgetProductGroupLevelForAccrual = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings") AND application.oLakebase.isTableMigrated("product_group_level")>
<cfif useLakebaseForqgetProductGroupLevelForAccrual>
	<cftry>
		<cfset qgetProductGroupLevelForAccrual = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("_users_settings", {
				"select" = "accrual_product_group_level_id"
			}, "accrual_product_group_level_id", "product_group_level", "product_group_level_id", "group_level_desc,product_group_level_id"), "group_level_desc,product_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetProductGroupLevelForAccrual = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetProductGroupLevelForAccrual>
<cfquery name="qgetProductGroupLevelForAccrual" datasource="#application.datasource#">
				SELECT pgl.Product_Group_Level_ID,pgl.Group_level_Desc
					FROM _users_settings us
				INNER JOIN Product_Group_Level pgl
				ON us.Accrual_Product_group_Level_ID = pgl.Product_group_Level_ID
			</cfquery>
</cfif>
		<cfreturn qgetProductGroupLevelForAccrual />
	</cffunction>
	<!--- D32973:Dates on Payment History END--->
	<cffunction name="getcontractIds" output="true">
		<cfargument name="contractNum" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

			<cfquery name="qdropTmpTbl" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpContractMainID') IS NOT NULL
			DROP TABLE ##tmpContractMainID
			</cfquery>


			<cfquery name="qgetcontractIds" datasource="#application.datasource#">
				select contract_main_id
				into ##tmpContractMainID
				from
				contract_main
				<cfif val(arguments.plannerID)>
				where Planner_ID = #val(arguments.plannerID)#
				<cfelse>
				where contract_number like '#arguments.contractNum#'
				</cfif>

				SELECT * FROM ##tmpContractMainID
			</cfquery>
		<cfreturn qgetcontractIds />
	</cffunction>

	<cffunction name="getTotalAccruedAndSpentDollars" output="true">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfquery name="delTmpTblTotalAccruedAndSpentDollars" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
		</cfquery>

		<cfquery name="qGetTotalAccruedAndSpentDollars" datasource="#application.datasource#">
		<cfif val(arguments.plannerID)>
			DECLARE @Total_Accrued_Dollars DECIMAL(20, 2),
					@Total_Spent_Dollars DECIMAL(20, 2)
			<!--- Get sepnt dollars --->
			SELECT 	@Total_Spent_Dollars = SUM(cmad.Total_Spent_Dollars)
			FROM Contract_Main_Aux_Data cmad
			INNER JOIN  Contract_Main cm
			ON cmad.Contract_Main_ID = cm.Contract_Main_ID
			INNER JOIN Planners p
			ON  p.Planner_ID = cm.Planner_ID
			WHERE	CASE WHEN ISNULL(p.Parent_Planner_ID, 0) != 0 THEN ISNULL(p.Parent_Planner_ID, 0) ELSE cm.Planner_ID END = #val(arguments.plannerID)#
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					<!--- No extra filter needed --->
				<cfelse>
					<!--- If there are multiple versions, we do not want to sum the value from all versions and cause duplication --->
					AND cm.Deleted = 0
					AND cm.Approved = 1
				</cfif>

			<!--- Get accrual dollars --->
			SELECT	Contract_Main_ID, Contract_Number
			INTO	##tmp_plnrAcc_pgm
			FROM	GLA_Planner_Accrual_Programs gla
			WHERE	Planner_ID = #val(arguments.plannerID)#

			DECLARE @Planner_Template_ID INT,
					@Planner_Start_Date DATE,
					@Planner_End_Date DATE,
					@Planner_Template_Filter bit

			SELECT	@Planner_Template_ID = p.Planner_Template_ID,
					@Planner_Start_Date = pt.Planner_Start_Date,
					@Planner_End_Date = pt.Planner_End_Date
			FROM	Planners p
			INNER JOIN Planner_Template pt
			ON		pt.Planner_Template_ID = p.Planner_Template_ID
			WHERE	p.Planner_ID = #val(arguments.plannerID)#

			SELECT	TOP 1 @Planner_Template_Filter = 1
			FROM	dbo.Planner_Template_Filters ptf
			WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
			AND		ptf.Allow_Filter = 1
			AND		ptf.PG_Group_Type = 1

			SELECT	Product_ID
			INTO	##tmp_plnrAcc_prod
			FROM	GLA_Planner_Template_Products
			WHERE	Planner_Template_ID = @Planner_Template_ID

			-- If planner has individual distributor
			select	DISTINCT Customer_ID as Distributor_ID
			INTO	##tmp_plnrAcc_dist
			from	Planners p
			where	p.Planner_ID = #val(arguments.plannerID)#
			and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

			-- If planner has group distributor
			INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
			SELECT DISTINCT Distributor_ID
			FROM   Planner_Customer_Group_Members p
			WHERE  p.Planner_ID = #val(arguments.plannerID)#

			SELECT	@Total_Accrued_Dollars = SUM(Amount)
			FROM 	GLA_Combined gla
			WHERE 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla.Contract_Main_ID)
			AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla.Product_ID))
			AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla.Distributor_ID)
			AND		gla.Fiscal_End >= @Planner_Start_Date
			AND		gla.Fiscal_Start <= @Planner_End_Date

			SELECT	ISNULL(@Total_Accrued_Dollars, 0) as Total_Accrued_Dollars, ISNULL(@Total_Spent_Dollars, 0) as Total_Spent_Dollars,
					(ISNULL(@Total_Accrued_Dollars, 0) - ISNULL(@Total_Spent_Dollars, 0)) As Total_Remaining_Dollars,
					CASE ISNULL(@Total_Accrued_Dollars, 0)
					WHEN 0
						THEN 0.00
					ELSE
						CEILING(((ISNULL(@Total_Accrued_Dollars, 0) - ISNULL(@Total_Spent_Dollars, 0))/ISNULL(@Total_Accrued_Dollars, 0)) * 100)
					END
					As Total_Remaining_Percent


		<cfelse>

			SELECT DISTINCT ISNULL(cmad.Total_Accrued_Dollars, 0) as Total_Accrued_Dollars, ISNULL(cmad.Total_Spent_Dollars, 0) as Total_Spent_Dollars,
					ISNULL((cmad.Total_Accrued_Dollars - cmad.Total_Spent_Dollars), 0) As Total_Remaining_Dollars,
					CASE cmad.Total_Accrued_Dollars
					WHEN 0
						THEN 0.00
					ELSE
						ISNULL(CEILING((((cmad.Total_Accrued_Dollars - cmad.Total_Spent_Dollars)/cmad.Total_Accrued_Dollars) * 100)), 0)
					END
					As Total_Remaining_Percent
			FROM Contract_Main_Aux_Data cmad
			INNER JOIN  Contract_Main cm
			ON cmad.Contract_Main_ID = cm.Contract_Main_ID
			WHERE
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					cm.contract_main_id = #arguments.contractMainID#
				<cfelse>
					cm.contract_number = '#arguments.contract_number#'
			</cfif>
		</cfif>
		</cfquery>

		<cfreturn qGetTotalAccruedAndSpentDollars />
	</cffunction>

	<cffunction name="getpaymentdetails" output="false" returntype="struct">
		<cfargument name="contract_number" required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="type_code_desc_id" type="string" required="false" default="" />
		<cfargument name="payee" type="string" required="false" default="" />
		<cfargument name="start_date_operator" type="string" required="false" default="" />
		<cfargument name="end_date_operator" type="string" required="false" default="" />
		<cfargument name="date_criteria_start" type="string" required="false" default="" />
		<cfargument name="date_criteria_end" type="string" required="false" default="" />
		<cfargument name="settlement_id" type="string" required="false" default="" />
		<cfargument name="billback_search" type="string" required="false" default="" />
		<cfargument name="productID" type="string" required="false" default="" />
		<!--- "column_sequence_number" default has been set below for the Excel report.
		Default of "7" below is "CHECK_NUMBER", the first column on the grid --->
		<cfargument name="column_sequence_number" type="string" required="false" default="7" />
		<cfargument name="sort_order" type="string" required="false" default="asc" />
		<cfargument name="startRow" type="numeric" required="false" default="0" />
		<cfargument name="endRow" type="numeric" required="false" default="0" />
		<cfargument name="filteredBB" type="string" required="false" default="" />
		<cfargument name="SelectedMonths" type="string" required="false" default="" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfquery name="delTmpTblPaymentDetailsData" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##TmpTblPaymentDetailsData') IS NOT NULL
		DROP TABLE ##TmpTblPaymentDetailsData

		CREATE TABLE ##TmpTblPaymentDetailsData (
			 rowIDInt int
			,Billback_ID uniqueidentifier
			,BB_Code varchar (50)
			,BB_Start_Date datetime
			,BB_End_Date datetime
			,BB_Reference nvarchar(100)
			,Payee_ID nvarchar(50)
			,Payee_Name nvarchar(255)
			,Payee_Unique_ID nvarchar(50)
			,Check_Date datetime
			,Date_Approved datetime
			,Actual_Check_Date datetime
			,BB_Received_Ack_Date datetime
			,Volume_CS decimal(20,4)
			,Volume_LB decimal(20,4)
			,Paid_Amount decimal(20,4)
			,Avg_Rate_CS float
			,Avg_Rate_LB float
			,Check_Number varchar(50)
			,BB_Title nvarchar(100)
			,City varchar(30)
			,State varchar(4)
			)
		</cfquery>

		<cfset returnStruct = StructNew()>

		<cfset productSearch = 0>
		<cfif (arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "") or arguments.productID neq "">
			<cfset productSearch = 1>
		</cfif>
		<!---
		Note: In the below query, we are summing up the values from the "payment_history_item_details"
		table, rather than getting the summed up values from the "Payment_history_details" table. This is
		because when we view the details of the totals from "payment_history_item_details", the totals should match exactly.
		--->
		<cfquery name="qgetpaymentdetails" datasource="#application.datasource#">
		INSERT INTO ##TmpTblPaymentDetailsData
			SELECT DISTINCT
					---ROW_NUMBER() OVER(ORDER BY phd.Check_Date ASC) AS rowIDInt,
					ROW_NUMBER() OVER(
			<cfswitch expression="#arguments.column_sequence_number#">
				<cfcase value=1>ORDER BY PHD.BB_Reference</cfcase>
				<cfcase value=2>ORDER BY PHD.BB_Code</cfcase>
				<cfcase value=3>ORDER BY PHD.Payee_Name</cfcase>
				<cfcase value=4>ORDER BY PHD.BB_Start_Date</cfcase>
				<cfcase value=5>ORDER BY PHD.BB_End_Date</cfcase>
				<cfcase value=6>ORDER BY PHID.Rate</cfcase>
				<cfcase value=7>ORDER BY BBA.Date_Approved</cfcase>
				<cfcase value=8>ORDER BY PHID.Volume_LB</cfcase>
				<cfcase value=9>ORDER BY PHID.Volume_CS</cfcase>
			</cfswitch> #arguments.sort_order#) AS rowIDInt,
					phd.Billback_ID,
					phd.BB_Code,
					phd.BB_Start_Date,
					phd.BB_End_Date,
					phd.BB_Reference,
					phd.Payee_ID,
					phd.Payee_Name,
					phd.Payee_Unique_ID,
					phd.Check_Date,
					BBA.Date_Approved,
					BBA.Check_Date AS Actual_Check_Date,
					BB.BB_Received_Ack_Date,
					<!---
					phd.Rate_CS,
					phd.Rate_LB,
					--->
				<cfif productSearch eq 1>
				<!--- Item level info --->
					ROUND(phid.Volume_CS,0) As Volume_CS,
					ROUND(phid.Volume_LB,0) As Volume_LB,
					phid.Rate As Paid_Amount,
					CASE WHEN phid.volume_cs = 0 then 0 else  phid.Rate / NULLIF(ROUND(phid.volume_cs,0), 0)  end as Avg_Rate_CS,
					CASE WHEN phid.volume_lb = 0 then 0 else 	phid.Rate / NULLIF(ROUND(phid.volume_lb,0), 0)  end as Avg_Rate_LB,
				<cfelse>
				<!--- Billback level info --->
					SUM(ROUND(phid.Volume_CS,0)) As Volume_CS,
					SUM(ROUND(phid.Volume_LB,0)) As Volume_LB,
					SUM(phid.Rate) As Paid_Amount,
				        --phd.Avg_Rate_CS AS Avg_Rate_CS,
				        --phd.Avg_Rate_LB AS Avg_Rate_LB,
					SUM(phd.Avg_Rate_CS) AS Avg_Rate_CS,
				        SUM(phd.Avg_Rate_LB) AS Avg_Rate_LB,
				</cfif>
					phd.Check_Number,
					phd.BB_Title,
					CASE WHEN phd.Payee_Type = 1
					THEN
						BSAFC.City
					WHEN phd.Payee_Type = 2
					THEN
						BSAO.Operator_City
					WHEN phd.Payee_Type = 3
					THEN
						BSAFB.City
					END
					AS City,
					CASE WHEN phd.payee_type = 1
					THEN
						BSAFC.State
					WHEN phd.payee_type = 2
					THEN
						BSAO.Operator_State
					WHEN phd.payee_type = 3
					THEN
						BSAFB.State
					END
					AS State
			---INTO ##TmpTblPaymentDetailsData
			FROM Payment_history_details phd
			INNER JOIN
					payment_history_item_details phid
			ON phd.Contract_Number = phid.Contract_Number
			AND phd.billback_id = phid.billback_id
			<!--- We need to find out whether there is at least one item on the billback "payment_history_item_details" table
			which matches the "type code" search criteria.If yes, then return the billback from the "Payment_history_details" table.

			We could have used another technique but it is not being used. The other technique involves getting SUM of the items
			from the "payment_history_item_details" table, for the items which matches the "type code" search criteria.
			--->
			<cfif productSearch eq 1>
				INNER JOIN
						bsa_foodservice_Items_Master bsaifm
				ON phid.product_id = bsaifm.bsa_foodservice_Items_Master_ID
				<cfif arguments.productID neq "">
				AND bsaifm.bsa_foodservice_Items_Master_ID = '#arguments.productID#'
				</cfif>
			</cfif>
			INNER JOIN Billback BB ON BB.Billback_ID = phd.Billback_ID AND BB.Deleted = 0
			INNER JOIN BB_Approved BBA ON BB.Billback_ID = BBA.Billback_ID
			LEFT JOIN BSA_Foodservice_Customers BSAFC ON
				CAST(BSAFC.BSA_Foodservice_Customers_ID As varchar(50)) = phd.payee_unique_id
			LEFT JOIN BSA_Operator BSAO
				ON CAST(BSAO.BSA_Operator_ID As varchar(100)) = phd.payee_unique_id
			LEFT JOIN BSA_Foodservice_Brokers BSAFB
				ON CAST(BSAFB.BSA_Foodservice_Brokers_ID As varchar(50)) = phd.payee_unique_id
			WHERE
			<cfif val(arguments.plannerID)>
			phd.Planner_ID = #val(arguments.plannerID)#
			<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			phd.contract_main_id = #arguments.contractMainID#
			<cfelse>
			phd.Contract_Number  = '#arguments.contract_number#'
			</cfif>

			<cfif (application.appSettingsGet.DISPLAY_ONLY_BILLBACK_PARENT)>
			AND BB.BB_Split_Number IS NULL AND BB.BB_Parent_ID IS NULL
			</cfif>
			AND phd.Billback_ID NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')
			<cfif len(arguments.filteredBB) AND arguments.filteredBB NEQ 'ALL'>
			AND phd.Billback_ID IN (<cfqueryparam value="#arguments.filteredBB#" cfsqltype="CF_SQL_NVARCHAR" list="yes"/>)
			</cfif>

			<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
				AND ((1=2)
			<cfif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "D">
			OR (phd.payee_type = 1 AND phd.payee_id = '#request.AccessStructure.External_Customer_Profile_Access_CustNum#')
			<cfelseif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "O">
			OR (phd.payee_type = 2 AND phd.payee_id = '#request.AccessStructure.External_Customer_Profile_Access_CustNum#')
			</cfif>
				)
			</cfif>

			<!--- Filter records. Send "billbackRecords" as an argument to "getPaymentHistoryFilters". --->
			<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID=arguments.contractMainID,type_code_desc_id=arguments.type_code_desc_id,start_date_operator=arguments.start_date_operator,
													end_date_operator=arguments.end_date_operator,date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
													payee=arguments.payee,settlement_id=arguments.settlement_id,type='billbackRecords',plannerID=arguments.plannerID)>


			<cfoutput>
			#PreserveSingleQuotes(qryDilters)#
			</cfoutput>

			<cfif arguments.billback_search neq "">
			AND
			(
			BB.bb_reference like '%#arguments.billback_search#%'
			OR
			BB.bb_code like '%#arguments.billback_search#%'
			OR
			BB.bb_title like '%#arguments.billback_search#%'
			)
			</cfif>

			<cfif len(arguments.filteredBB) EQ 0 AND len(arguments.SelectedMonths) and arguments.SelectedMonths NEQ 'ALL'>
				AND
				   (1 = 0
					<cfloop list="#arguments.SelectedMonths#" index="M" delimiters=",">
						<cfset startDate = dateformat(createDate(left(M,4), Replace(Right(M,2),"-",""), 1), 'mm/dd/yyyy')>
						<!--- Since the date does not include tume, increase the date by one day. That way. we can get correct data, which includes time as well - "23:59:59". --->
						<cfset endDate = DateAdd("d",1,dateformat(createDate(left(M,4), Replace(Right(M,2),"-",""), daysInMonth(startDate)), 'mm/dd/yyyy'))>
						<!--- Handle for multiple dates --->
						OR
						(
						phd.Check_date >= '#startDate#'
						AND phd.Check_date < #endDate#
						)
					</cfloop>
				   )
			</cfif>

			<cfif productSearch eq 0>
			GROUP BY
				phd.Billback_ID,
				phd.BB_Code,
				phd.BB_Start_Date,
				phd.BB_End_Date,
				phd.BB_Reference,
				phd.Payee_ID,
				phd.Payee_Name,
				phd.Payee_Unique_ID,
				phd.Check_Date,
				<cfif productSearch eq 1>
				PHID.Rate,
				PHID.Volume_CS,
				PHID.Volume_LB,
				</cfif>
				BBA.Date_Approved,
				BBA.Check_Date,
				BB.BB_Received_Ack_Date,
				phd.Check_Number,
				phd.BB_Title,
				phd.Payee_Type,
				<cfif productSearch eq 1>
				phd.Avg_Rate_CS,
				phd.Avg_Rate_LB,
				</cfif>
				BSAFC.City,
				BSAO.Operator_City,
				BSAFB.City,
				BSAFC.State,
				BSAO.Operator_State,
				BSAFB.State
			</cfif>

			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<cfswitch expression="#arguments.column_sequence_number#">
				<cfcase value=1>ORDER BY BB_Reference</cfcase>
				<cfcase value=2>ORDER BY BB_Code</cfcase>
				<cfcase value=3>ORDER BY Payee_Name</cfcase>
				<cfcase value=4>ORDER BY BB_Start_Date</cfcase>
				<cfcase value=5>ORDER BY BB_End_Date</cfcase>
				<cfcase value=6>ORDER BY Paid_Amount</cfcase>
				<cfcase value=7>ORDER BY Date_Approved</cfcase>
				<cfcase value=8>ORDER BY Volume_LB</cfcase>
				<cfcase value=9>ORDER BY Volume_CS</cfcase>
			</cfswitch>
			#arguments.sort_order#

			<!--- Total number of records --->
			SELECT count(BB_Code) As recordTotalCount
			FROM ##TmpTblPaymentDetailsData
			</cfquery>
			<cfquery name="qgetpaymentdetailsData" datasource="#application.datasource#">
			SELECT *
			FROM ##TmpTblPaymentDetailsData
			<!--- Query usng a range to return what is needed for paging. --->
			<cfif arguments.startRow eq 0>
			WHERE 1 = 1
			<cfelse>
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#
			<cfswitch expression="#arguments.column_sequence_number#">
				<cfcase value=1>ORDER BY BB_Reference</cfcase>
				<cfcase value=2>ORDER BY BB_Code</cfcase>
				<cfcase value=3>ORDER BY Payee_Name</cfcase>
				<cfcase value=4>ORDER BY BB_Start_Date</cfcase>
				<cfcase value=5>ORDER BY BB_End_Date</cfcase>
				<cfcase value=6>ORDER BY Paid_Amount</cfcase>
				<cfcase value=7>ORDER BY Date_Approved</cfcase>
				<cfcase value=8>ORDER BY Volume_LB</cfcase>
				<cfcase value=9>ORDER BY Volume_CS</cfcase>
			</cfswitch>
			#arguments.sort_order#
			</cfif>
			</cfquery>

			<cfquery name="qgetTotalpaymentdetailsData" datasource="#application.datasource#">
			SELECT SUM(Volume_LB) As Total_Volume_LB, SUM(Volume_CS) As Total_Volume_CS
			FROM ##TmpTblPaymentDetailsData
			</cfquery>
			<!--- Total records --->
			<cfset returnStruct.recordTotal = qgetpaymentdetails.recordTotalCount>

			<!--- query (for records to be displayed) --->
			<cfset returnStruct.queryResults = qgetpaymentdetailsData>

			<!--- "Total data" variables --->
			<cfset returnStruct.TotalPoundsInvoiced = qgetTotalpaymentdetailsData.Total_Volume_LB>
			<cfset returnStruct.TotalCasesInvoiced = qgetTotalpaymentdetailsData.Total_Volume_CS>

		<cfreturn returnStruct />
	</cffunction>

	<!---<cffunction name="getlumpsumpaymentdetails" output="true">
			<cfargument name="contract_number" required="true" type="string" />
			<cfquery name="qgetlumpsumpaymentdetails" datasource="#application.datasource#">
				select ISNULL(SUM(cast(amount as decimal(20,4))),0) as lumpsum_amount
				from
				Billback_Program_Lumpsum_Component
				inner join Billback_Program on
				Billback_Program.Billback_Program_id = Billback_Program_Lumpsum_Component.Billback_Program_id
				where Billback_Program_Lumpsum_Component.deleted = 0 and
				Billback_Program.deleted = 0
				and Billback_Program_Lumpsum_Component.Component_type_id = 1
				and Billback_Program.program_id in (select contract_main_id from contract_main
				where contract_number like '%#arguments.contract_number#%')
			</cfquery>
		<cfreturn qgetlumpsumpaymentdetails />
	</cffunction>
	--->

	<cffunction name="getsummarypaymentdetails" output="true">
		<cfargument name="contract_number" required="true" type="string" />
		<cfargument name="formCopy" type="struct" required="false"/>
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="offinvoice" required="false" type="boolean" default="0">
		<cfargument name="plannerID" required="false" type="string" default="0" />

			<!---
			Note: In the below query, we are summing up the values from the "payment_history_item_details"
			table, rather than getting the summed up values from the "Payment_history_details" table. This is
			because when we view the details of the totals from "payment_history_item_details", the totals should match exactly.
			--->
			<cfquery name="qgetsummarypaymentdetails" datasource="#application.datasource#">
				SELECT 	DISTINCT
						ISNULL(SUM(ROUND(CASE phd.billback_id WHEN '00000000-0000-0000-0000-000000000000' THEN phd.volume_cs ELSE phid.volume_cs END, 0)), 0) AS volume_cs,
       			ISNULL(SUM(ROUND(CASE phd.billback_id WHEN '00000000-0000-0000-0000-000000000000' THEN phd.volume_lb ELSE phid.volume_lb END, 0)), 0) AS volume_lb,
						ISNULL(SUM(phd.rate_cs), 0) as rate_cs,
						ISNULL(SUM(phd.rate_lb), 0) as rate_lb,
						ISNULL(SUM(CASE phd.billback_id WHEN '00000000-0000-0000-0000-000000000000' THEN phd.Paid_amount ELSE phid.Rate END), 0) AS paid_amount,
						count(*) as count
						,count(distinct phd.billback_id) as bb_count
				FROM Payment_history_details phd
				LEFT JOIN Payment_history_item_details phid
				ON phd.Contract_Number = phid.Contract_Number
				AND phd.billback_id = phid.billback_id
				WHERE
				<cfif val(arguments.plannerID)>
					phd.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					<cfif isdefined('arguments.formCopy.contract_main_id')>
						phd.contract_main_id = #arguments.formCopy.contract_main_id#
					<cfelse>
						phd.contract_main_id = #arguments.contractMainID#
					</cfif>
				<cfelse>
				phd.contract_number like '%#arguments.contract_number#%'
				</cfif>
				<cfif appSettings.getPymtHistoryDollarsIncludeOffInvoiceDollars() eq 0>
				AND phd.billback_id <cfif arguments.offinvoice> = <cfelse> <> </cfif> '00000000-0000-0000-0000-000000000000'
				</cfif>
				<cfif isdefined('arguments.formCopy.START_DATE') AND arguments.formCopy.START_DATE NEQ "">
				AND phd.check_date >= '#arguments.formCopy.START_DATE#'
				</cfif>
				<cfif isdefined('arguments.formCopy.END_DATE') AND arguments.formCopy.END_DATE NEQ "">
				AND phd.check_date <= '#arguments.formCopy.END_DATE#'
				</cfif>
				<cfif isdefined('arguments.formCopy.payee_name') AND arguments.formCopy.payee_name NEQ "">
				AND phd.payee_name like '%#arguments.formCopy.payee_name#%'
				</cfif>
				<cfif isdefined('arguments.formCopy.payee_id') AND arguments.formCopy.payee_id NEQ "">
				AND phd.payee_id like '%#arguments.formCopy.payee_id#%'
				</cfif>
				<cfif isdefined('arguments.formCopy.payee_type') AND arguments.formCopy.payee_type NEQ "" and arguments.formCopy.payee_type NEQ 0>
				AND phd.payee_type = '#arguments.formCopy.payee_type#'
				</cfif>
				<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
					AND ((1=2)
					<cfif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "D">
					OR (phd.payee_type = 1 AND phd.payee_id = '#request.AccessStructure.External_Customer_Profile_Access_CustNum#')
					<cfelseif request.AccessStructure.External_Customer_Profile_Access_CustType EQ "O">
					OR (phd.payee_type = 2 AND phd.payee_id = '#request.AccessStructure.External_Customer_Profile_Access_CustNum#')
					</cfif>
					)
				</cfif>
			</cfquery>
		<cfreturn qgetsummarypaymentdetails />
	</cffunction>
<!--- D36686 Actual Adjustment - Green $ Sign --->
	<cffunction name="getbudgetactual" output="true">
		<cfargument name="contract_number" required="true" type="string" />
		<cfargument name="formCopy" type="struct" required="false"/>
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" type="string" default="0" />

		<cfquery name="qGetBudgetActual" datasource="#application.datasource#">
			SELECT SUM(adjustment_dollar) AS paid_amount
				FROM Budget_Actual_Adjustment
			<cfif val(arguments.plannerID)>
			WHERE Contract_Main_Id
			IN
			(
			SELECT Contract_Main_ID
			FROM Contract_Main
			WHERE Planner_ID = #val(arguments.plannerID)#
			UNION
			SELECT Contract_Main_ID
			FROM Contract_Main cm
			INNER JOIN Planners p ON p.Planner_ID = cm.Planner_ID
			WHERE p.Parent_Planner_ID = #val(arguments.plannerID)#
			)
			<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE Contract_Main_Id
			IN
			(
			SELECT Contract_Main_ID
			FROM Contract_Main
			WHERE Contract_Number = '#arguments.contract_number#'
			)
			</cfif>
		</cfquery>
		<cfreturn qGetBudgetActual />
	</cffunction>
<!--- D36686 Actual Adjustment - Green $ Sign --->
	<cffunction name="getpaymentitemleveldetails" output="true">
		<cfargument name="paymentIds" required="true" type="string" />
		<cfargument name="payeeIds" type="string" required="false" default=""/>
		<cfargument name="contract_number" type="string" required="false" default=""/>
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" type="string" default="0" />

		<cfquery name="qgetpaymentitemleveldetails" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##getpaymentitemleveldetails') IS NOT NULL
			DROP TABLE ##getpaymentitemleveldetails

			DECLARE
			@total_rate decimal(18,2),
			@total_vol_lb decimal(18,0),
			@total_vol_cs decimal(18,0)

			select item,description,
					ISNULL(cast(sum(ROUND(volume_cs,0)) as decimal(20,0)),0) as volume_cs,
					ISNULL(cast(sum(ROUND(volume_lb,0)) as decimal(20,0)),0) as volume_lb,
					ISNULL(cast(SUM(rate) as decimal(20,4)),0) as rate
			into	##getpaymentitemleveldetails
			from 	payment_history_item_details
			<cfif Listlen(arguments.paymentIds) NEQ 0>
			where billback_id  IN (#ListQualify(arguments.paymentIds, "'", ",")#)
			</cfif>
			<cfif Listlen(arguments.payeeIds) NEQ 0>
			and 	payee_unique_id IN (#ListQualify(arguments.payeeIds, "'", ",")#)
			</cfif>

			<cfif val(arguments.plannerID)>
			and		Planner_ID = #val(arguments.plannerID)#
			<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			and 	contract_main_id = #arguments.contractMainID#
			<cfelse>
				<cfif len(trim(arguments.contract_number))>
				and 	contract_number = '#arguments.contract_number#'
				</cfif>
			</cfif>

			group by product_id, item, description

			select @total_rate = SUM(rate), @total_vol_lb = SUM(volume_lb), @total_vol_cs = SUM(volume_CS)
			from ##getpaymentitemleveldetails

			select	item, description, ROUND(volume_cs,0) As volume_cs, ROUND(volume_lb,0) As volume_lb, rate,
					SUM(rate) as total_rate,
					CASE
						WHEN @total_rate > 0 THEN (rate / @total_rate) * 100
						ELSE 0
					END AS rate_percent,
					SUM(volume_lb) as total_vol_lb,
					CASE
						WHEN @total_vol_lb > 0 THEN (volume_lb / @total_vol_lb) * 100
						ELSE 0
					END AS volume_lb_percent,
					SUM(volume_CS) as total_vol_cs,
					CASE
						WHEN @total_vol_cs > 0 THEN (volume_CS / @total_vol_cs) * 100
						ELSE 0
					END AS volume_cs_percent
			from	##getpaymentitemleveldetails
			group by item, description, volume_cs, volume_lb, rate
			order by item desc

		</cfquery>

		<cfreturn qgetpaymentitemleveldetails />

	</cffunction>

	<!---<cffunction name="getPaymentSummaryDetailsforItemPage" output="true">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="billback_id" 		default="0" 	type="string" />

		<cfquery name="local.qgetBBInfoForProdDetails" datasource="#application.datasource#">
			SELECT 	DISTINCT
			        phd.billback_id
			       ,BB.BB_Code
			       ,BB.BB_Start_Date
			       ,BB.BB_End_Date
			       ,BB.BB_Reference
			       ,payee_id
			       ,payee_name
			       ,payee_unique_id
			       ,check_date
			       ,volume_cs
			       ,volume_lb
			       ,rate_cs
			       ,rate_lb
			       ,paid_amount
			       ,avg_rate_cs
			       ,avg_rate_lb
			FROM    Payment_History_Details phd
			        INNER JOIN Billback BB ON BB.Billback_ID = phd.billback_id
			        INNER JOIN Billback_Closing_Methods BCM ON BB.BB_Closing_Method = BCM.iBillback_Closing_Method_ID
			WHERE   phd.contract_number LIKE '%#arguments.contract_number#%'
			        AND BCM.Exclude_From_Payment_History = 0
					<cfif arguments.billback_id neq "0" AND len(trim(arguments.billback_id)) GT 0>
						AND	Payment_history_details.billback_id = '#arguments.billback_id#'
					</cfif>
		</cfquery>

		<cfreturn local.qgetBBInfoForProdDetails />
	</cffunction>--->

	<!---
	Seeme like "contractMainID" should not be passed as an argument for the below function(unlike other functions which check for version level data)
	because this function is being  used to show/hide "purge" link for the program. So, just using "contract_number" as an argument is fine.
	--->
	<cffunction name="getPaymentHistoryExist" output="true">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="plannerID" required="false" type="string" default="0" />

		<cfset var IsPaymentHistoryExist = 0>

		<cfquery name="qgetPaymentHistoryExist" datasource="#application.datasource#">
			select 	TOP 1 BB_Code
			from 	Payment_history_details
			<cfif val(arguments.plannerID)>
			WHERE	Planner_ID = #val(arguments.plannerID)#
			<cfelse>
			where 	contract_number like '%#arguments.contract_number#%'
			</cfif>
		</cfquery>

			<cfif qgetPaymentHistoryExist.recordcount>
				<cfset IsPaymentHistoryExist = 1>
			</cfif>

		<cfreturn IsPaymentHistoryExist />
	</cffunction>

	<cffunction name="getOffInvoiceExist" output="false" returntype="boolean">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" type="string" default="0" />

		<cfset var IsOffInvoiceExist = 0>

		<cfquery name="qGetOffInvoiceExist" datasource="#application.datasource#">
			select 	1
			from 	Payment_History_Operator_Offinvoice_Details
			<cfif val(arguments.plannerID)>
			WHERE	Planner_ID = #val(arguments.plannerID)#
			<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE contract_number = '#arguments.contract_number#'
			</cfif>
		</cfquery>

			<cfif qGetOffInvoiceExist.recordcount>
				<cfset IsOffInvoiceExist = 1>
			</cfif>

		<cfreturn IsOffInvoiceExist />
	</cffunction>

	<cffunction name="getAccrualExist" output="false" returntype="boolean">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
            DROP TABLE ##tmp_plnrAcc_pgm

            IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
            DROP TABLE ##tmp_plnrAcc_prod

            IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
            DROP TABLE ##tmp_plnrAcc_dist
        </cfquery>

        <cfquery name="local.qGetAccrualExist" datasource="#application.datasource#">
            <cfif val(arguments.plannerID)>
                SELECT	Contract_Main_ID, Contract_Number
                INTO	##tmp_plnrAcc_pgm
                FROM	GLA_Planner_Accrual_Programs gla
                WHERE	Planner_ID = #val(arguments.plannerID)#

                DECLARE @Planner_Template_ID INT,
							@Planner_Start_Date DATE,
							@Planner_End_Date DATE,
							@Planner_Template_Filter BIT

					SELECT	@Planner_Template_ID = p.Planner_Template_ID,
							@Planner_Start_Date = pt.Planner_Start_Date,
							@Planner_End_Date = pt.Planner_End_Date
					FROM	Planners p
					INNER JOIN Planner_Template pt
					ON		pt.Planner_Template_ID = p.Planner_Template_ID
					WHERE	p.Planner_ID = #val(arguments.plannerID)#

					SELECT	TOP 1 @Planner_Template_Filter = 1
					FROM	dbo.Planner_Template_Filters ptf
					WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
					AND		ptf.Allow_Filter = 1
                AND		ptf.PG_Group_Type = 1

                SELECT	Product_ID
                INTO	##tmp_plnrAcc_prod
                FROM	GLA_Planner_Template_Products
                WHERE	Planner_Template_ID = @Planner_Template_ID

					-- If planner has individual distributor
                select	DISTINCT Customer_ID as Distributor_ID
                INTO	##tmp_plnrAcc_dist
                from	Planners p
                where	p.Planner_ID = #val(arguments.plannerID)#
                and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

					-- If planner has group distributor
                INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
                SELECT DISTINCT Distributor_ID
                FROM   Planner_Customer_Group_Members p
                WHERE  p.Planner_ID = #val(arguments.plannerID)#
            </cfif>

            /* Rebate */
            SELECT TOP 1 1
            from 	GLA_Combined gla
            <cfif val(arguments.plannerID)>
                WHERE 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla.Contract_Main_ID)
                AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla.Product_ID))
                AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla.Distributor_ID)
                AND		gla.Fiscal_End >= @Planner_Start_Date
                AND		gla.Fiscal_Start <= @Planner_End_Date
				<cfelse>
					<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
                WHERE contract_main_id = #arguments.contractMainID#
                <cfelse>
                WHERE contract_number = '#arguments.contract_number#'
                </cfif>
            </cfif>
        </cfquery>

        <cfreturn local.qGetAccrualExist.recordcount ? 1 : 0>

		<cfreturn IsAccrualExist />
	</cffunction>

	<cffunction name="getDeductionAccountExist" output="false" returntype="boolean">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfset var IsDeductionAccountExist = 0>

		<cfquery name="delTmpTblGetDeductionAccountExist" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
		</cfquery>

		<cfquery name="qGetDeductionAccountExist" datasource="#application.datasource#">
			<cfif val(arguments.plannerID)>
				SELECT	Contract_Main_ID, Contract_Number
				INTO	##tmp_plnrAcc_pgm
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter BIT

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				SELECT	Product_ID
				INTO	##tmp_plnrAcc_prod
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				select	DISTINCT Customer_ID as Distributor_ID
				INTO	##tmp_plnrAcc_dist
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

			SELECT 1
			FROM GLA_Combined gla_rebate
			WHERE
			<cfif val(arguments.plannerID)>
						EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
				AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
				AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
				AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
				AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
			<cfelse>
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					gla_rebate.contract_main_id = #arguments.contractMainID#
				<cfelse>
					gla_rebate.contract_number = '#arguments.contract_number#'
				</cfif>
			</cfif>
			AND LEN(LTRIM(RTRIM(gla_rebate.Deduction_Account))) > 0
		</cfquery>

		<cfif qGetDeductionAccountExist.recordcount>
			<cfset IsDeductionAccountExist = 1>
		</cfif>

		<cfreturn IsDeductionAccountExist />
	</cffunction>

	<cffunction name="getPaymentAccountExist" output="false" returntype="boolean">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfset var IsPaymentAccountExist = 0>

		<cfquery name="delTmpTblGetPaymentAccountExist" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
		</cfquery>

		<cfquery name="qGetPaymentAccountExist" datasource="#application.datasource#">
			<cfif val(arguments.plannerID)>
				SELECT	Contract_Main_ID, Contract_Number
				INTO	##tmp_plnrAcc_pgm
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter BIT

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				SELECT	Product_ID
				INTO	##tmp_plnrAcc_prod
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				select	DISTINCT Customer_ID as Distributor_ID
				INTO	##tmp_plnrAcc_dist
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

			SELECT 1
			FROM GLA_Combined gla_rebate
			WHERE
			<cfif val(arguments.plannerID)>
						EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
				AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
				AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
				AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
				AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
			<cfelse>
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					gla_rebate.contract_main_id = #arguments.contractMainID#
				<cfelse>
					gla_rebate.contract_number = '#arguments.contract_number#'
				</cfif>
			</cfif>
			AND LEN(LTRIM(RTRIM(gla_rebate.Payment_Account))) > 0
		</cfquery>

		<cfif qGetPaymentAccountExist.recordcount>
			<cfset IsPaymentAccountExist = 1>
		</cfif>

		<cfreturn IsPaymentAccountExist />
	</cffunction>

	<cffunction name="getGLAccountExist" output="false" returntype="boolean">
		<cfargument name="contract_number" 	required="true" type="string" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfset var IsGLAccountExist = 0>

		<cfquery name="delTmpTblGetGLAccountExist" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
		</cfquery>

		<cfquery name="qGetGLAccountExist" datasource="#application.datasource#">
			<cfif val(arguments.plannerID)>
				SELECT	Contract_Main_ID, Contract_Number
				INTO	##tmp_plnrAcc_pgm
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter BIT

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				SELECT	Product_ID
				INTO	##tmp_plnrAcc_prod
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				select	DISTINCT Customer_ID as Distributor_ID
				INTO	##tmp_plnrAcc_dist
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

			SELECT 1
			FROM GLA_Combined gla_rebate
			WHERE
			<cfif val(arguments.plannerID)>
						EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
				AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
				AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
				AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
				AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
			<cfelse>
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					gla_rebate.contract_main_id = #arguments.contractMainID#
				<cfelse>
					gla_rebate.contract_number = '#arguments.contract_number#'
				</cfif>
			</cfif>
			AND LEN(LTRIM(RTRIM(gla_rebate.GL_Account_Name))) > 0
		</cfquery>

		<cfif qGetGLAccountExist.recordcount>
			<cfset IsGLAccountExist = 1>
		</cfif>

		<cfreturn IsGLAccountExist />
	</cffunction>

	<cffunction name="getDistributorsFromAccrual" output="false" returntype="query">
		<cfargument name="contractNumber" type="string" required="true" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="distributorComponentList" required="true" type="string" />
		<cfargument name="plannerID" required="false" default="0" />

			<cfquery name="delTmpTblDistributorsFromAccrual" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##DistList') IS NOT NULL
			DROP TABLE ##DistList

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
			</cfquery>

			<cfquery name="qGetDistributorsFromAccrual" datasource="#application.datasource#">
				CREATE TABLE ##DistList
				(
					distributor_Id varchar(50)
				)
			<cfloop from="1" to="#ListLen(arguments.distributorComponentList)#" index="i">
				<cfset distributorId = ListFirst(ListGetAt(arguments.distributorComponentList,i),"_")>

				INSERT INTO ##DistList(distributor_Id)
				VALUES('#distributorId#')
			</cfloop>

			<cfif val(arguments.plannerID)>
				SELECT	Contract_Main_ID, Contract_Number
				INTO	##tmp_plnrAcc_pgm
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter BIT

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				SELECT	Product_ID
				INTO	##tmp_plnrAcc_prod
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				select	DISTINCT Customer_ID as Distributor_ID
				INTO	##tmp_plnrAcc_dist
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

				SELECT DISTINCT gla_rebate.Ship_To_Name as Name, gla_rebate.Ship_To as Shr_ship_to,
					gla_rebate.Distributor_ID as BSA_Foodservice_Customers_ID, gla_rebate.Family_Name
				FROM GLA_Combined gla_rebate

				<cfif val(arguments.plannerID)>
					WHERE 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
					AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
					AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
					AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
					AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
				<cfelse>
					<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
						WHERE gla_rebate.contract_main_id = #arguments.contractMainID#
					<cfelse>
						WHERE gla_rebate.contract_number = '#arguments.contractNumber#'
					</cfif>
				</cfif>

				AND EXISTS
				(
					SELECT 1
					FROM ##DistList
					WHERE distributor_Id = gla_rebate.Distributor_ID
				)

				ORDER BY gla_rebate.Family_Name, gla_rebate.Ship_To_Name
			</cfquery>

			<cfreturn qGetDistributorsFromAccrual />
	</cffunction>

	<cffunction name="getOperatorOffInvoiceByDate" output="true" returntype="query">
		<cfargument name="contract_number" type="string" required="false" default=""/>
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="start_date_operator" type="string" required="false" />
		<cfargument name="end_date_operator" type="string" required="false" />
		<cfargument name="date_criteria_start" type="string" required="false" />
		<cfargument name="date_criteria_end" type="string" required="false" />
		<cfargument name="payee" type="string" required="false" />
		<cfargument name="offinvoice_number" type="string" required="false" />
		<cfargument name="item_number" type="string" required="false" />
		<cfargument name="SelectedMonths" type="string" required="false" default="" />
		<cfargument name="plannerID" required="false" default="0" />

		<cfquery name="qGetOperatorOffInvoiceByDate" datasource="#application.datasource#">
			SELECT	SUM(Sales_Dollars) As Sales_Dollars,SUM(ROUND(Cases_Invoiced,0)) As Volume_CS,
					SUM(ROUND(Pounds_Invoiced,0)) As Volume_LB,DATENAME(MM,Invoice_date) As Date_Month,
					YEAR(Invoice_date) As Date_Year,MONTH(Invoice_date) As DateMonth
			FROM Payment_History_Operator_Offinvoice_Details phid

			<cfif arguments.item_number neq "">
			INNER JOIN
					bsa_foodservice_Items_Master bsaifm
			ON phid.bsa_foodservice_Items_Master_ID = bsaifm.bsa_foodservice_Items_Master_ID
			</cfif>

			<cfif val(arguments.plannerID)>
			WHERE phid.planner_id = #val(arguments.plannerID)#
			<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE contract_number = '#arguments.contract_number#'
			</cfif>

			<cfif len(arguments.SelectedMonths) and arguments.SelectedMonths NEQ 'ALL'>
                <cfif arguments.SelectedMonths contains ",">
                    <cfloop list="#arguments.SelectedMonths#" index="M" delimiters=",">
                        <cfset startDate = createDate(left(M,4), Right(M,1), 1)>
                        <cfset endDate = createDate(left(M,4), Right(M,1), daysInMonth(startDate))>
                        AND phid.Invoice_Date Between '#dateformat(startDate, 'mm/dd/yyyy')#' AND '#dateformat(endDate, 'mm/dd/yyyy')#'
                    </cfloop>

                <cfelseif arguments.SelectedMonths contains "-">
                    <cfset local.selected_year = listFirst(arguments.selectedMonths, '-')>
                    /* validate year filter and apply */
                    <cfif isNumeric(local.selected_year) and local.selected_year gt 1900 and local.selected_year lt 3000>
                        AND YEAR(phid.Invoice_Date) = #local.selected_year#
                    </cfif>
                    <cfif listLen(arguments.selectedMonths, '-') gt 1>
                        /* validate month filter and apply */
                        <cfset local.selected_month = listGetAt(arguments.selectedMonths, 2, '-')>
                        <cfif isNumeric(local.selected_month) and local.selected_month gt 0 and local.selected_month lt 13>
                            AND MONTH(phid.Invoice_Date) = #local.selected_month#
                        </cfif>
                    </cfif>
                </cfif>
			</cfif>
			<!--- Filter records. Send "OffInvoiceByDate" as an argument to "getPaymentHistoryFilters". --->
			<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID=arguments.contractMainID,
													start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
													date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
													payee=arguments.payee,type='OffInvoiceByDate',plannerID=arguments.plannerID)>


			<cfif arguments.item_number neq "">
			AND phid.item like '%#arguments.item_number#%'
			</cfif>

			<cfif arguments.offinvoice_number neq "">
			AND phid.invoice_number like '%#arguments.offinvoice_number#%'
			</cfif>

			<cfoutput>
			#PreserveSingleQuotes(qryDilters)#
			</cfoutput>

			GROUP BY YEAR(Invoice_date), MONTH(Invoice_date), DATENAME(MM,Invoice_date)
			ORDER BY Date_Year desc, DateMonth desc
		</cfquery>

		<cfreturn qGetOperatorOffInvoiceByDate />
	</cffunction>

	<cffunction name="getOperatorOffInvoiceDataDetails" output="true" returntype="struct">
		<cfargument name="contract_number" type="string" required="false" default="" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="yearMonthList" type="string" required="false" default="" />
		<cfargument name="payee" type="string" required="false"  default=""/>/>
		<cfargument name="offinvoice_number" type="string" required="false"  default="" />
		<cfargument name="item_number" type="string" required="false" default="" />
		<cfargument name="listOfWords" type="string" required="false" default="" />
		<!--- "column_sequence_number" default has been set below for the Excel report.
		Default of "0" below is "INVOICE_NUMBER", the first column on the grid --->
		<cfargument name="column_sequence_number" type="string" required="false" default="0" />
		<cfargument name="sort_order" type="string" required="false" default="" />
		<cfargument name="startRow" type="numeric" required="false" default="0" />
		<cfargument name="endRow" type="numeric" required="false" default="0" />
		<!--- These 4 arguments below are for the csv report which gets created from the OffInvoice history
		summary report screen (main offinvoice screen).
		--->
		<cfargument name="start_date_operator" type="string" required="false" default=""  />
		<cfargument name="end_date_operator" type="string" required="false" default=""  />
		<cfargument name="date_criteria_start" type="string" required="false" default=""  />
		<cfargument name="date_criteria_end" type="string" required="false" default=""  />
		<cfargument name="filteredInvoices" type="string" required="false" default="" />
		<cfargument name="plannerID" required="false" default="0" />
		<!--- DO NOT USE CFQUERYPARAM ON THIS FUNCTION, AS WE NEED TO ACCESS A TEMP TABLE ACROSS MULTIPLE QUERIES.
		TEMP TABLE WILL NOT BE AVAILABLE TO ANOTHER QUERY, IF WE USE CFQUERYPARAM.
		--->

		<cfset var searchDateStart = "">
		<cfset var searchDateEnd = "">

		<cfquery name="delTmpTblOffInvoiceDetails" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpOffinvoiceDetails') IS NOT NULL
			DROP TABLE ##tmpOffinvoiceDetails
		</cfquery>

		<cfset returnStruct = StructNew()>

		<!--- This "rowIDInt" field creates a incremental integer. Since we only want to retrieve selected records using a range, eg: 100-200, 300-400 etc,
		"rowIDInt" can be used for that purpose. Please leave this column as the first column.
		So that "rowIDInt" increments integers properly, the second column in the below query should not have any blank or null value.
		--->
		<cfquery name="qGetOperatorOffInvoice" datasource="#application.datasource#">
			SELECT	identity(INT) As rowIDInt,phid.Invoice_number,CONVERT(char(10),phid.Invoice_Date,101) As Invoice_Date,phid.Item,
					phid.Description,phid.Sales_Dollars, ROUND(phid.Cases_Invoiced,0) As Volume_CS, ROUND(phid.Pounds_Invoiced,0) As Volume_LB,phid.Shr_ship_to,
					phid.Name As Ship_to_name
			INTO ##tmpOffinvoiceDetails
			FROM Payment_History_Operator_Offinvoice_Details phid

			<cfif arguments.item_number neq "">
			INNER JOIN 	bsa_foodservice_Items_Master bsaifm
			ON phid.bsa_foodservice_Items_Master_ID = bsaifm.bsa_foodservice_Items_Master_ID
			</cfif>

			<cfif val(arguments.plannerID)>
			WHERE phid.planner_id = #val(arguments.plannerID)#
			<cfelseif  val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE contract_number = '#arguments.contract_number#'
			</cfif>

			<cfif len(arguments.filteredInvoices)>
			<cfset loopNum = 0>
			AND
				(
                        <cfloop list="#arguments.filteredInvoices#" index="local.year_month" delimiters=",">
                            <cfset loopNum = loopNum + 1>
                            <cfif loopNum GT 1>OR</cfif>
                            (
                            <cfset local.selected_year = listFirst(local.year_month, '-')>
                            /* validate year filter and apply */
                            <cfif isNumeric(local.selected_year) and local.selected_year gt 1900 and local.selected_year lt 3000>
                                YEAR(phid.Invoice_Date) = #local.selected_year#
                            </cfif>
                            <cfif listLen(local.year_month, '-') gt 1>
                                /* validate month filter and apply */
                                <cfset local.selected_month = listGetAt(local.year_month, 2, '-')>
                                <cfif isNumeric(local.selected_month) and local.selected_month gt 0 and local.selected_month lt 13>
                                    AND MONTH(phid.Invoice_Date) = #local.selected_month#
                                </cfif>
                            </cfif>
                            )
                        </cfloop>
				)
			</cfif>

			<!--- Search by date (multiple dates) --->
			<cfif arguments.yearMonthList neq "">
				<cfset loopNum = 0>
				AND
				(
				<cfloop list="#arguments.yearMonthList#" index="i">
				<cfset loopNum = loopNum + 1>
					<cfset searchYear = ListFirst(i, "-")>
					<cfset searchMonth = ListLast(i, "-")>
					<cfset searchDateStart = CreateODBCDate(searchMonth & "/1" & "/" & searchYear)>
					<cfset searchDateEnd = CreateODBCDate(DateAdd("m",1, searchDateStart))>
					<!--- From the second entry onwards in the list, use the keyword "OR" as we need to query for multiple months. --->
					<cfif loopNum GT 1>
					OR
					</cfif>
					(
					 phid.Invoice_Date >= #searchDateStart#
					 AND phid.Invoice_Date < #searchDateEnd#
					)
				</cfloop>
				)
			</cfif>

			<!--- Request is NOT from csv report --->
			<cfif arguments.yearMonthList neq "">
				<cfif arguments.payee neq "null" and arguments.payee neq "">
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,
															payee=arguments.payee,type='OffInvoiceDetails',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
				</cfif>
			<cfelse>
			<!--- Below code gets executed for the csv report which gets created from the OffInvoice history
			summary report screen (main offinvoice screen).
			--->
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractmainid=arguments.contractMainID,
											start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
											date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
											payee=arguments.payee,type='OffInvoiceByDate',plannerID=arguments.plannerID)>
					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
			</cfif>

			<cfif arguments.offinvoice_number neq "">
			AND phid.invoice_number like '%#arguments.offinvoice_number#%'
			</cfif>

			<cfif arguments.item_number neq "">
			AND phid.item like '%#arguments.item_number#%'
			</cfif>

			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<cfswitch expression="#arguments.column_sequence_number#">
				 <cfcase value=0>ORDER BY phid.Invoice_number</cfcase>
				 <cfcase value=1>ORDER BY CONVERT(char(10),phid.Invoice_Date,101)</cfcase>
				 <cfcase value=2>ORDER BY phid.Item</cfcase>
				 <cfcase value=3>ORDER BY phid.Description</cfcase>
				 <cfcase value=4>ORDER BY phid.Sales_Dollars</cfcase>
				 <cfcase value=5>ORDER BY phid.Cases_Invoiced</cfcase>
				 <cfcase value=6>ORDER BY phid.Pounds_Invoiced</cfcase>
				 <cfcase value=7>ORDER BY phid.Shr_ship_to</cfcase>
				 <cfcase value=8>ORDER BY phid.Name</cfcase>
			</cfswitch>
			#arguments.sort_order#

			<!--- Total number of records before filter --->
			SELECT count(Item) As recordTotalCount
			FROM ##tmpOffinvoiceDetails
		</cfquery>

		<cfquery name="qGetOperatorOffInvoiceFiltered" datasource="#application.datasource#">
			<!--- Total number of records after filter --->
			SELECT count(Invoice_number) As recordFilteredCount
			FROM ##tmpOffinvoiceDetails
			<cfif arguments.listOfWords neq "">
			WHERE
			(
			item like '%#arguments.listOfWords#%'
			OR
			Description like '%#arguments.listOfWords#%'
			OR
			invoice_number like '%#arguments.listOfWords#%'
			OR
			Shr_ship_to like '%#arguments.listOfWords#%'
			OR
			Ship_to_name like '%#arguments.listOfWords#%'
			)
			</cfif>
		</cfquery>

		<cfquery name="qGetOperatorOffInvoiceFilteredResults" datasource="#application.datasource#">
			SELECT * FROM ##tmpOffinvoiceDetails
			<!--- Query usng a range to return what is needed for paging. --->
			<cfif arguments.startRow eq 0>
			WHERE 1 = 1
			<cfelse>
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#
			</cfif>

			<cfif arguments.listOfWords neq "">
			AND
			(
			item like '%#arguments.listOfWords#%'
			OR
			Description like '%#arguments.listOfWords#%'
			OR
			invoice_number like '%#arguments.listOfWords#%'
			OR
			Shr_ship_to like '%#arguments.listOfWords#%'
			OR
			Ship_to_name like '%#arguments.listOfWords#%'
			)
			</cfif>

			<cfswitch expression="#arguments.column_sequence_number#">
				 <cfcase value=0>ORDER BY Invoice_number</cfcase>
				 <cfcase value=1>ORDER BY Invoice_Date</cfcase>
				 <cfcase value=2>ORDER BY Item</cfcase>
				 <cfcase value=3>ORDER BY Description</cfcase>
				 <cfcase value=4>ORDER BY Sales_Dollars</cfcase>
				 <cfcase value=5>ORDER BY Volume_CS</cfcase>
				 <cfcase value=6>ORDER BY Volume_LB</cfcase>
				 <cfcase value=7>ORDER BY Shr_ship_to</cfcase>
				 <cfcase value=8>ORDER BY Ship_to_name</cfcase>
			</cfswitch>
			#arguments.sort_order#
		</cfquery>

		<cfquery name="qgetTotalpaymentdetailsData" datasource="#application.datasource#">
			SELECT SUM(Sales_Dollars) AS TotalAmount, SUM(Volume_LB) As Total_Volume_LB, SUM(Volume_CS) As Total_Volume_CS
			FROM ##tmpOffinvoiceDetails
		</cfquery>

		<!--- Total records (before filter) --->
		<cfset returnStruct.recordTotal = qGetOperatorOffInvoice.recordTotalCount>

		<!--- Filtered records query (after filter) --->
		<cfset returnStruct.filteredResults = qGetOperatorOffInvoiceFilteredResults>

		<!--- Filtered records (after filter) --->
		<cfset returnStruct.filteredTotal = qGetOperatorOffInvoiceFiltered.recordFilteredCount>

		<!--- "Total data" variables --->
		<cfset returnStruct.TotalAmount = qgetTotalpaymentdetailsData.TotalAmount>
		<cfset returnStruct.TotalCasesInvoiced = qgetTotalpaymentdetailsData.Total_Volume_CS>
		<cfset returnStruct.TotalPoundsInvoiced = qgetTotalpaymentdetailsData.Total_Volume_LB>

		<cfreturn returnStruct />
	</cffunction>

	<cffunction name="getPaymentHistoryByDate" output="true" returntype="query">
		<cfargument name="contract_number" type="string" required="true" />
		<cfargument name="contractMainID" required="true" type="string" />
		<cfargument name="type_code_desc_id" type="string" required="false" />
		<cfargument name="type" type="string" required="false" />
		<cfargument name="start_date_operator" type="string" required="false" />
		<cfargument name="end_date_operator" type="string" required="false" />
		<cfargument name="date_criteria_start" type="string" required="false" />
		<cfargument name="date_criteria_end" type="string" required="false" />
		<cfargument name="payee" type="string" required="false" />
		<cfargument name="settlement_id" type="string" required="false" />
		<cfargument name="plannerID" required="false" type="string" default="0" />

		<cfquery name="qDropTempTables" datasource="#application.datasource#">
		IF object_id('tempdb..##paymentHistoryData') is not null
		DROP TABLE ##paymentHistoryData
		</cfquery>

		<cfquery name="qGetPaymentHistoryByDate" datasource="#application.datasource#">
			CREATE TABLE ##paymentHistoryData
			(
				Sales_Dollars decimal(20,4) NULL,
				Volume_CS decimal(20,0) NULL,
				Volume_LB  decimal(20,0) NULL,
				payment_date datetime NULL
			)

			INSERT INTO ##paymentHistoryData(Sales_Dollars,Volume_CS,Volume_LB,payment_date)

			<!--- 1. billbacks --->
			<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,1) neq 0>
				SELECT	phid.Rate As Sales_Dollars, ROUND(phid.Volume_Cs,0), ROUND(phid.Volume_Lb,0),phd.Check_date
					FROM		payment_history_details phd
					INNER JOIN 	payment_history_item_details phid
					ON phd.Contract_Number = phid.Contract_Number
					AND phd.billback_id = phid.billback_id
					<cfif arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "">
					INNER JOIN 	bsa_foodservice_Items_Master bsaifm
					ON phid.product_id = bsaifm.bsa_foodservice_Items_Master_ID
					</cfif>

					<cfif val(arguments.plannerID)>
					WHERE phd.Planner_ID = #val(arguments.plannerID)#
					<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					WHERE phd.contract_main_id = #arguments.contractMainID#
					<cfelse>
					WHERE phd.contract_number = '#arguments.contract_number#'
					</cfif>

					AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')

					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractmainid = arguments.contractMainID,type_code_desc_id=arguments.type_code_desc_id,
															start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
															date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
															payee=arguments.payee,settlement_id=arguments.settlement_id,type='billback',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>


				<!--- Making sure that at least one more query will follow this one. --->
				<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,2) neq 0 or ListFind(arguments.type,3) neq 0>
				UNION ALL
				</cfif>
			</cfif>

			<!--- 2. off-Invoice --->
			<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,2) neq 0>
				SELECT	phid.Sales_Dollars, ROUND(phid.Cases_Invoiced,0) As Volume_Cs, ROUND(phid.Pounds_Invoiced,0) As Volume_Lb,phid.Invoice_date
					FROM		Payment_History_Operator_Offinvoice_Details phid
					<cfif arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "">
					INNER JOIN 	bsa_foodservice_Items_Master bsaifm
					ON phid.bsa_foodservice_Items_Master_ID = bsaifm.bsa_foodservice_Items_Master_ID
					</cfif>

					<cfif val(arguments.plannerID)>
					WHERE phid.Planner_ID = #val(arguments.plannerID)#
					<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					WHERE phid.contract_main_id = #arguments.contractMainID#
					<cfelse>
					WHERE phid.contract_number = '#arguments.contract_number#'
					</cfif>

					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractmainid = arguments.contractMainID,type_code_desc_id=arguments.type_code_desc_id,
															start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
															date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
															payee=arguments.payee,settlement_id=arguments.settlement_id,type='offInvoice',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>

				<!--- Making sure that at one more query will follow this one. --->
				<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,3) neq 0>
				UNION ALL
					</cfif>
			</cfif>

			<!--- 3. Budget actual Adjustment --->
			<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,3) neq 0>
				SELECT	phid.Adjustment_Dollar As Sales_Dollars,0 As Volume_Cs,0 As Volume_Lb,phid.Adjustment_Date
					FROM		Budget_Actual_Adjustment phid
					<cfif val(arguments.plannerID)>
					WHERE Contract_Main_Id
					IN
					(
					SELECT Contract_Main_ID
					FROM Contract_Main
					WHERE Planner_ID = #val(arguments.plannerID)#
					UNION
					SELECT Contract_Main_ID
					FROM Contract_Main cm
					INNER JOIN Planners p ON p.Planner_ID = cm.Planner_ID
					WHERE p.Parent_Planner_ID = #val(arguments.plannerID)#
					)
					<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
					WHERE contract_main_id = #arguments.contractMainID#
					<cfelse>
					WHERE Contract_Main_Id
					IN
					(
					SELECT Contract_Main_ID
					FROM Contract_Main
					WHERE Contract_Number = '#arguments.contract_number#'
					)
					</cfif>

					<!--- "budget actual adjustment" does not use type ocde, settlement id. --->
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractMainID,
															start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
															date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
															payee=arguments.payee,type='budgetAdjustment',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
			</cfif>

				SELECT  SUM(Sales_Dollars) As Sales_Dollars,SUM(Volume_CS) As Volume_CS,SUM(Volume_LB) As Volume_LB,
						DATENAME(MM,payment_date) As Date_Month,YEAR(payment_date) As Date_Year,MONTH(payment_date) As DateMonth
				FROM ##paymentHistoryData
				GROUP BY YEAR(payment_date), MONTH(payment_date), DATENAME(MM,payment_date)

				ORDER BY Date_Year desc, DateMonth desc
		</cfquery>
		<cfreturn qGetPaymentHistoryByDate />

	</cffunction>

	<cffunction name="getPaymentHistoryItemLevelData" output="false" returntype="query">
		<cfargument name="contract_number" type="string" required="true" />
		<cfargument name="contractId" type="string" required="true" />
		<cfargument name="yearMonthList" type="string" required="false" default="" />
		<cfargument name="type_code_desc_id" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="payee" type="string" required="false" default="" />
		<cfargument name="settlement_id" type="string" required="false" default="" />
		<!---  These 4 arguments below are for the csv report which gets created from the
		main payment history summary report screen (default payment hostory screen).
		--->
		<cfargument name="start_date_operator" type="string" required="false" default=""  />
		<cfargument name="end_date_operator" type="string" required="false" default=""  />
		<cfargument name="date_criteria_start" type="string" required="false" default=""  />
		<cfargument name="date_criteria_end" type="string" required="false" default=""  />
		<cfargument name="plannerID" required="false" type="string" default="0" />

		<cfset var searchDateStart = "">
		<cfset var searchDateEnd = "">
		<cfset var qryDilters = "">

			<cfquery name="qDropTempTables" datasource="#application.datasource#">
			IF object_id('tempdb..##paymentHistoryData') is not null
			DROP TABLE ##paymentHistoryData
			</cfquery>

			<cfquery name="qGetPaymentHistoryItemLevelData" datasource="#application.datasource#">
			CREATE TABLE ##paymentHistoryData
			(
				Item varchar(50) NOT NULL,
				Description varchar(255) NOT NULL,
				Sales_Dollars decimal(20,4) NULL,
				Volume_CS decimal(20,0) NULL,
				Volume_LB  decimal(20,0) NULL,
				Item_not_On_program bit NOT NULL
			)

			INSERT INTO ##paymentHistoryData(Item,Description,Sales_Dollars,Volume_CS,Volume_LB,Item_not_On_program)

			<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,1) neq 0>
				<!--- billbacks --->
				SELECT	phid.Item,phid.Description,phid.Rate As Sales_Dollars, ROUND(phid.Volume_Cs,0), ROUND(phid.Volume_Lb,0),phid.Item_not_On_program
					FROM		payment_history_details phd
				INNER JOIN
							payment_history_item_details phid
				ON phd.Contract_Number = phid.Contract_Number
				AND phd.billback_id = phid.billback_id

				<cfif arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "">
				INNER JOIN
						bsa_foodservice_Items_Master bsaifm
				ON phid.product_id = bsaifm.bsa_foodservice_Items_Master_ID
				</cfif>

				<cfif val(arguments.plannerID)>
				WHERE phd.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phd.contract_main_id = #arguments.contractId#
				<cfelse>
				WHERE phd.contract_number = '#arguments.contract_number#'
				</cfif>

				AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')

				<!--- Search by date (multiple dates) --->
				<cfif arguments.yearMonthList neq "">
					<cfset loopNum = 0>
					AND
					(
					<cfloop list="#arguments.yearMonthList#" index="i">
					<cfset loopNum = loopNum + 1>
						<cfset searchYear = ListFirst(i, "-")>
						<cfset searchMonth = ListLast(i, "-")>
						<cfset searchDateStart = CreateODBCDate(searchMonth & "/1" & "/" & searchYear)>
						<cfset searchDateEnd = CreateODBCDate(DateAdd("m",1, searchDateStart))>
						<!--- From the second entry onwards in the list, use the keyword "OR" as we need to query for multiple months. --->
						<cfif loopNum GT 1>
						OR
						</cfif>
						(
						 phd.Check_date >= #searchDateStart#
						 AND
						 phd.Check_date < #searchDateEnd#
						)
					</cfloop>
					)
				</cfif>

				<cfif arguments.yearMonthList neq "">
					<!--- No need to pass dates. The date filter is already being done above --->
					<cfset qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,type_code_desc_id=arguments.type_code_desc_id,
														payee=arguments.payee,settlement_id=arguments.settlement_id,type='billbackItems',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
				<!--- Below code gets executed for the csv report which gets created from the payment history summary
				summary report screen (main payment history screen).
				--->
				<cfelse>
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,
																type_code_desc_id=arguments.type_code_desc_id,
																start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
																date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
																payee=arguments.payee,settlement_id=arguments.settlement_id,type='billback',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
				</cfif>

				<!--- Making sure that at least one more query will follow this one. --->
				<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,2) neq 0 or ListFind(arguments.type,3) neq 0>
				UNION ALL
				</cfif>
			</cfif>

			<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,2) neq 0>
				<!--- offInvoice --->
				SELECT	phid.Item,phid.Description,phid.Sales_Dollars, ROUND(phid.Cases_Invoiced,0) As Volume_Cs,
						ROUND(phid.Pounds_Invoiced,0) As Volume_Lb,phid.Item_not_On_program
					FROM		Payment_History_Operator_Offinvoice_Details phid
				<cfif arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "">
				INNER JOIN
						bsa_foodservice_Items_Master bsaifm
				ON phid.bsa_foodservice_Items_Master_ID = bsaifm.bsa_foodservice_Items_Master_ID
				</cfif>

				<cfif val(arguments.plannerID)>
				WHERE phid.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phid.contract_main_id = #arguments.contractId#
				<cfelse>
				WHERE phid.contract_number = '#arguments.contract_number#'
				</cfif>

				<!--- Search by date (multiple dates) --->
				<cfif arguments.yearMonthList neq "">
					<cfset loopNum = 0>
					AND
					(
					<cfloop list="#arguments.yearMonthList#" index="i">
					<cfset loopNum = loopNum + 1>
						<cfset searchYear = ListFirst(i, "-")>
						<cfset searchMonth = ListLast(i, "-")>
						<cfset searchDateStart = CreateODBCDate(searchMonth & "/1" & "/" & searchYear)>
						<cfset searchDateEnd = CreateODBCDate(DateAdd("m",1, searchDateStart))>
						<!--- From the second entry onwards in the list, use the keyword "OR" as we need to query for multiple months. --->
						<cfif loopNum GT 1>
						OR
						</cfif>
						(
						 phid.Invoice_Date >= #searchDateStart#
						 AND
						 phid.Invoice_Date < #searchDateEnd#
						)
					</cfloop>
					)
				</cfif>
				<cfif arguments.yearMonthList neq "">
					<!--- No need to pass dates. The date filter is already being done above --->
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,type_code_desc_id=arguments.type_code_desc_id,
															payee=arguments.payee,settlement_id=arguments.settlement_id,type='offInvoiceItems',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
				<!--- Below code gets executed for the csv report which gets created from the payment history summary
				report screen (main payment history screen).
				--->
				<cfelse>
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,
															type_code_desc_id=arguments.type_code_desc_id,
															start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
															date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
															payee=arguments.payee,settlement_id=arguments.settlement_id,type='offInvoice',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
				</cfif>

				<!--- Making sure that at least one more query will follow this one. --->
				<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,3) neq 0>
				UNION ALL
				</cfif>
			</cfif>

			<cfif arguments.type eq "null" or arguments.type eq "" or ListFind(arguments.type,3) neq 0>
				<!--- budget actual adjustment  --->
				SELECT 'budget actual adjustment' as item, '' as  Description, phid.Adjustment_Dollar As Sales_Dollars,0 As Volume_Cs,0 As Volume_Lb,
					'' As Item_not_On_program
				FROM		Budget_Actual_Adjustment phid
				<cfif val(arguments.plannerID)>
				WHERE Contract_Main_Id
				IN
				(
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Planner_ID = #val(arguments.plannerID)#
				UNION
				SELECT Contract_Main_ID
				FROM Contract_Main cm
				INNER JOIN Planners p ON p.Planner_ID = cm.Planner_ID
				WHERE p.Parent_Planner_ID = #val(arguments.plannerID)#
				)
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE Contract_Main_Id = #arguments.contractId#
				<cfelse>
				WHERE Contract_Main_Id
				IN
				(
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Number = '#arguments.contract_number#'
				)
				</cfif>

				<!--- Search by date (multiple dates) --->
				<cfif arguments.yearMonthList neq "">
					<cfset loopNum = 0>
					AND
					(
					<cfloop list="#arguments.yearMonthList#" index="i">
					<cfset loopNum = loopNum + 1>
						<cfset searchYear = ListFirst(i, "-")>
						<cfset searchMonth = ListLast(i, "-")>
						<cfset searchDateStart = CreateODBCDate(searchMonth & "/1" & "/" & searchYear)>
						<cfset searchDateEnd = CreateODBCDate(DateAdd("m",1, searchDateStart))>
						<!--- From the second entry onwards in the list, use the keyword "OR" as we need to query for multiple months. --->
						<cfif loopNum GT 1>
						OR
						</cfif>
						(
						phid.Adjustment_Date >= #searchDateStart#
						AND
						phid.Adjustment_Date < #searchDateEnd#
						)
					</cfloop>
					)
				</cfif>

				<cfif arguments.yearMonthList neq "">
					<!--- "budget adjustment" does not use type code, settlement id. No need to pass dates. The date filter is already being done above. --->
					<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,
															payee=arguments.payee,type='budgetAdjustmentItems',plannerID=arguments.plannerID)>

					<cfoutput>
					#PreserveSingleQuotes(qryDilters)#
					</cfoutput>
				<!--- Below code gets executed for the csv report which gets created from the payment history summary
				summary report screen (main payment history screen).
				--->
				<cfelse>
						<!--- "budget actual adjustment" does not use type code, settlement id. --->
						<cfset var qryDilters = getPaymentHistoryFilters(contract_number=arguments.contract_number,contractMainID = arguments.contractId,
																start_date_operator=arguments.start_date_operator,end_date_operator=arguments.end_date_operator,
																date_criteria_start=arguments.date_criteria_start,date_criteria_end=arguments.date_criteria_end,
																payee=arguments.payee,type='budgetAdjustment',plannerID=arguments.plannerID)>

						<cfoutput>
						#PreserveSingleQuotes(qryDilters)#
						</cfoutput>
				</cfif>

			</cfif>


			SELECT  Item,Description,Item_not_On_program,SUM(Sales_Dollars) As Sales_Dollars,
					SUM(Volume_CS) As Volume_CS,SUM(Volume_LB) As Volume_LB
			FROM ##paymentHistoryData
			GROUP BY Item,Description,Item_not_On_program
			</cfquery>

			<cfreturn qGetPaymentHistoryItemLevelData />
		</cffunction>

		<cffunction name="getPaymentHistoryItemsClaimedNotOnProgram" output="false" returntype="query">
			<cfargument name="contract_number" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfquery name="qDropTempTables" datasource="#application.datasource#">
			IF object_id('tempdb..##paymentHistoryData') is not null
			DROP TABLE ##paymentHistoryData
			</cfquery>

			<cfquery name="qGetPaymentHistoryItemsClaimedNotOnProgram" datasource="#application.datasource#">
			CREATE TABLE ##paymentHistoryData
			(
				Item varchar(50) NOT NULL,
				Description varchar(255) NOT NULL,
				Sales_Dollars decimal(20,4) NULL,
				Volume_CS decimal(20,0) NULL,
				Volume_LB  decimal(20,0) NULL,
				BSA_foodservice_Items_Master_ID uniqueidentifier NOT NULL
			)

			INSERT INTO ##paymentHistoryData(Item,Description,Sales_Dollars,Volume_CS,Volume_LB,BSA_foodservice_Items_Master_ID)

			<!--- billbacks --->
			SELECT	phid.Item,phid.Description,phid.Rate As Sales_Dollars, ROUND(phid.Volume_Cs,0) , ROUND(phid.Volume_Lb,0),
							bsaifm.bsa_foodservice_Items_Master_ID

				FROM		payment_history_details phd
			INNER JOIN
						payment_history_item_details phid
			ON phd.Contract_Number = phid.Contract_Number
			AND phd.billback_id = phid.billback_id

			INNER JOIN
					bsa_foodservice_Items_Master bsaifm
			ON phid.product_id = bsaifm.bsa_foodservice_Items_Master_ID

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phd.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phd.contract_number = '#arguments.contract_number#'
			</cfif>
			AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')


			<cfset qryDilters = getPaymentHistoryFilters(contract_number = arguments.contract_number,contractMainID = arguments.contractMainID,type_code_desc_id = '00000000-0000-0000-0000-000000000000')>

			<cfoutput>
			#PreserveSingleQuotes(qryDilters)#
			</cfoutput>

			SELECT  Item,Description,bsa_foodservice_Items_Master_ID,SUM(Sales_Dollars) As Sales_Dollars,
					SUM(Volume_CS) As Volume_CS,SUM(Volume_LB) As Volume_LB
			FROM ##paymentHistoryData
			GROUP BY Item,Description,bsa_foodservice_Items_Master_ID

			<!--- No need to add "OffInvoice", as we need to get data on "items claimed", which is billback. Off-Invoice would also be included,
				if we needed to get data on "items purchased" too.
			--->
			</cfquery>

			<cfreturn qGetPaymentHistoryItemsClaimedNotOnProgram />

		</cffunction>

		<cffunction name="getItemsOnProgramNotClaimedOrPurchased" output="false" returntype="query">
			<cfargument name="contract_number" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfquery name="delTmpTblPaymentHistoryProducts" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblPaymentHistoryProducts') IS NOT NULL
			DROP TABLE ##tmpTblPaymentHistoryProducts
			</cfquery>

			<cfquery name="qGetItemsOnProgramNotClaimedOrPurchased" datasource="#application.datasource#">
			CREATE TABLE ##tmpTblPaymentHistoryProducts
			(
				BSA_Foodservice_Items_Master_ID varchar(50)
			)

			INSERT INTO ##tmpTblPaymentHistoryProducts
			<!--- billback --->
			SELECT DISTINCT phid.product_ID
			FROM payment_history_item_details phid

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phid.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phid.contract_number = '#arguments.contract_number#'
			</cfif>

			INSERT INTO ##tmpTblPaymentHistoryProducts
			<!--- off-invoice --->
			SELECT DISTINCT phod.bsa_foodservice_Items_Master_ID
			FROM Payment_History_Operator_Offinvoice_Details phod

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phod.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phod.contract_number = '#arguments.contract_number#'
			</cfif>
			<!--- NO DUPLICATES --->
			AND NOT EXISTS
			(
			 SELECT 1
			 FROM ##tmpTblPaymentHistoryProducts php
			 WHERE phod.bsa_foodservice_Items_Master_ID = php.BSA_Foodservice_Items_Master_ID
			)

			SELECT DISTINCT bsaifm.Item,bsaifm.Description
				FROM Contract_products cp
			INNER JOIN
				Contract_Main cm
			ON cm.Contract_Main_ID = cp.Contract_Main_ID
			INNER JOIN
					bsa_foodservice_Items_Master bsaifm
			ON cp.bsa_foodservice_Items_Master_ID = bsaifm.bsa_foodservice_Items_Master_ID

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE cm.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE cm.contract_number = '#arguments.contract_number#'
			</cfif>
			AND cm.approved = 1
			<!--- When we need to look for program items that do not exist on the program payment history table, then the logic should
			include additional filter criteria (Effective date logic) below. If we needed to look for items in program history table
			which is not in the program, then it may be better to exclude the effective date logic, as the logic should not be restrictive.
			--->
			AND cm.Effective_Start_Date IS NOT NULL
			AND cm.Effective_End_Date IS NOT NULL
			AND cp.Is_Group = 0
			AND cp.deleted = 0
			<!--- Exclude lumpsum and growth records:
				payment history table does not store item records for lumpsum and growth.
			--->
			AND cp.product_type_id NOT IN (3,4)

			AND NOT EXISTS
			(
				SELECT 1
				FROM ##tmpTblPaymentHistoryProducts
				WHERE BSA_Foodservice_Items_Master_ID = cp.bsa_foodservice_Items_Master_ID
			 )
			</cfquery>

			<cfreturn qGetItemsOnProgramNotClaimedOrPurchased />

		</cffunction>

		<cffunction name="getProgramPayeesNotClaimingOrPurchasing" output="false" returntype="query">
			<cfargument name="contract_number" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfset var oProgram = CreateObject("component", "components.programs.program") />

			<!--- Get "paid to" list for the program components --->
			<cfset var qGetProgramPaidToType = oProgram.getProgramPaidToType('#arguments.contract_number#')>

			<cfquery name="delTmpTblProgramPayeesNotClaimimg" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblProgramPayeesNotClaimingOrPurchasing') IS NOT NULL
			DROP TABLE ##tmpTblProgramPayeesNotClaimingOrPurchasing
			</cfquery>

			<cfquery name="qGetProgramPayeesNotClaimingOrPurchasing" datasource="#application.datasource#">
			CREATE TABLE ##tmpTblProgramPayeesNotClaimingOrPurchasing
			(
				BSA_Foodservice_customers_ID varchar(50)
			)

			INSERT INTO ##tmpTblProgramPayeesNotClaimingOrPurchasing
			<!--- billback --->
			SELECT DISTINCT cast(phid.payee_unique_id as varchar(100))
			FROM payment_history_item_details phid

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phid.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phid.contract_number = '#arguments.contract_number#'
			</cfif>
			AND phid.payee_type = 1 <!--- distributor --->

			INSERT INTO ##tmpTblProgramPayeesNotClaimingOrPurchasing
			<!--- off-invoice --->
			SELECT DISTINCT cast(phod.bsa_foodservice_customers_ID as varchar(50))
			FROM Payment_History_Operator_Offinvoice_Details phod
			<!--- Seems like all the records are distributor records in the "Payment_History_Operator_Offinvoice_Details" table.
			The name of table ("Payment_History_Operator_Offinvoice_Details") with "operator" as a part of the name is a little misleading.
			--->

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phod.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phod.contract_number = '#arguments.contract_number#'
			</cfif>
			/* NO DUPLICATES */
			AND NOT EXISTS
			(
			 SELECT 1
			 FROM ##tmpTblProgramPayeesNotClaimingOrPurchasing php
			 WHERE phod.BSA_Foodservice_customers_ID = php.BSA_Foodservice_customers_ID
			)

			<!--- If "paid to' is  distributor --->
			<cfif ListFind(qGetProgramPaidToType,1) neq 0>
			SELECT	DISTINCT bfc.shr_ship_to As payee_id,
					bfc.name As payee_name,
					'#application.util.string.fcase(application.returned_customer_setting.distributor_label_singular)#'
					As payee_type

				FROM Contract_distributors cd
			INNER JOIN
				Contract_Main cm
			ON cm.Contract_Main_ID = cd.Contract_Main_ID
			INNER JOIN
					BSA_Foodservice_Customers bfc
			ON cd.bsa_foodservice_customers_ID = bfc.bsa_foodservice_customers_ID
			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE  cm.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE  cm.contract_number = '#arguments.contract_number#'
			</cfif>
			AND cm.approved = 1
			<!--- When we need to look for program payees that do not exist on the program payment history table, then the logic should
			include additional filter criteria (Effective date logic) below. If we needed to look for payees in program payment history table
			which is not in the program, then it may be better to exclude the effective date logic, as the logic should not be restrictive.
			--->
			AND cm.Effective_Start_Date IS NOT NULL
			AND cm.Effective_End_Date IS NOT NULL
			AND cd.Is_Group = 0
			AND cd.deleted = 0
			AND bfc.bsa_foodservice_customers_ID NOT IN
			(
				SELECT bsa_foodservice_customers_ID
				FROM  ##tmpTblProgramPayeesNotClaimingOrPurchasing
				WHERE bsa_foodservice_customers_ID = cd.bsa_foodservice_customers_ID
			)

			<!--- If "paid to" is operator --->
			<cfif ListFind(qGetProgramPaidToType,2) neq 0>
			UNION ALL
			</cfif>

			</cfif>

			<cfif ListFind(qGetProgramPaidToType,2) neq 0>
  			SELECT	DISTINCT
  				CASE WHEN
  						ISNULL(bsaop.legacy_id, '0') != '0'
					THEN
						legacy_id
				ELSE
					CAST(bsaop.BSA_Operator_id as varchar(50))
				END
				As payee_id,
				bsaop.Operator_Name	 As payee_name	,
					'#application.util.string.fcase(application.returned_customer_setting.operator_label_singular)#'
					As payee_type

				FROM Contract_operators co
			INNER JOIN
				Contract_Main cm
			ON cm.Contract_Main_ID = co.Contract_Main_ID
			INNER JOIN
					BSA_Operator bsaop
			ON co.BSA_Operator_id = bsaop.BSA_Operator_id
			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE cm.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE cm.contract_number = '#arguments.contract_number#'
			</cfif>
			AND cm.approved = 1
			AND cm.Effective_Start_Date IS NOT NULL
			AND cm.Effective_End_Date IS NOT NULL
			AND co.deleted = 0
			<!--- bsa_operator_id exists as "phid.payee_unique_id" in the "payment_history_item_details" table --->
			AND cast(bsaop.BSA_Operator_id as varchar(50)) NOT IN
			(
				SELECT phid.payee_unique_id
				FROM payment_history_item_details phid
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phid.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE phid.Contract_Number = '#arguments.contract_number#'
				</cfif>
			)
			</cfif>

			<cfif ListFind(qGetProgramPaidToType,1) neq 0 OR ListFind(qGetProgramPaidToType,2)>
			ORDER BY payee_type,payee_name
			</cfif>
			</cfquery>

			<cfreturn qGetProgramPayeesNotClaimingOrPurchasing />

		</cffunction>

		<cffunction name="getPaymentHistoryFilters" output="true" returntype="string">
			<cfargument name="contract_number" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfargument name="type_code_desc_id" type="string" required="false" default="" />
			<cfargument name="start_date_operator" type="string" required="false"default="" />
			<cfargument name="end_date_operator" type="string" required="false" default="" />
			<cfargument name="date_criteria_start" type="string" required="false" default="" />
			<cfargument name="date_criteria_end" type="string" required="false" default="" />
			<cfargument name="payee" type="string" required="false" default="" />
			<cfargument name="settlement_id" type="string" required="false" default="" />
			<cfargument name="type" type="string" required="false" default="" />
			<cfargument name="plannerID" required="false" type="string" default="0" />

			<cfoutput>
			<cfsavecontent variable="var_GetPaymentHistoryFilters">

				<!--- type code filter --->
				<cfif arguments.type neq "budgetAdjustment" and arguments.type neq "budgetAdjustmentItems" and arguments.type neq "OffInvoiceByDate"
					and arguments.type neq "OffInvoiceDetails">
					<cfif arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "">
					AND
					(
						(
						 <cfif arguments.type_code_desc_id neq "00000000-0000-0000-0000-000000000000">
						 bsaifm.type_code_desc_id IN (#LISTQUALIFY(arguments.type_code_desc_id,"'",",","All")#)
						 <cfelse>
						 1 = 1
						 </cfif>
						)
					<!--- The query was supposed to find any PROGRAM records on the payment history (payment_history_item_details) table,
						where the item's type oode is not on the program. We actually cannot do that as once we JOIN using
						"bsa_foodservice_Items_Master_ID" on item master (bsa_foodservice_Items_Master) table, JOIN on "Type_Code_Desc_ID"
						is no longer needed, as "Type_Code_Desc_ID" will be the same. So, we can search for mismatch on items, but not
						type code
						A QUESTION ARISES:
						IF TWO ITEMS ON payment_history_item_details BELONGING TO THE SAME PROGRAM HAVE THE SAME TYPE CODE. ONE EXISTS ON THE PROGRAM
						AND THE OTHER DOES NOT. WELL, IF WE INCLUDE "TYPE CODE NOT ON PROGRAM" ON THE SEARCH DROPDOWN, THEN IT IS AN ISSUE, BECAUSE WE
						DO NOT KNOW WHETHER TO INCLUDE THAT TYPE CODE ON THE SEARCH RESULTS.
						THIS IS THE REASON WHY, WE LOOK FOR "PRODUCTS NOT ON PROGRAM" AND NOT "TYPE CODE NOT ON PROGRAM".
					--->
						<!--- "item not on program" filter. --->
						<cfif ListFind(arguments.type_code_desc_id,'00000000-0000-0000-0000-000000000000') gt 0>
						<!--- If the "type code" search criteria also has a filter on "type code", then user "OR".
						If it only has "item not on program" filter,then use "AND".
						--->
						<cfif ListLen(arguments.type_code_desc_id,",") GT 1>OR<cfelse>AND</cfif>
						NOT EXISTS
						(
							SELECT 1
							FROM contract_products cp
							INNER JOIN
								contract_main cm
							ON cp.contract_main_id = cm.contract_main_id
							<!---INNER JOIN
								bsa_foodservice_Items_Master bsa_ifm
							ON cp.bsa_foodservice_Items_Master_ID = bsa_ifm.bsa_foodservice_Items_Master_ID--->
							<cfif val(arguments.plannerID)>
							INNER JOIN Planners p ON p.Planner_ID = cm.Planner_ID
							WHERE CASE WHEN ISNULL(p.Parent_Planner_ID, 0) != 0 THEN ISNULL(p.Parent_Planner_ID, 0) ELSE cm.Planner_ID END = #arguments.plannerID#
							<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
							WHERE cm.contract_main_id = #arguments.contractMainID#
							<cfelse>
							WHERE cm.contract_number = '#arguments.contract_number#'
							</cfif>
							<!---AND bsa_ifm.Type_Code_Desc_ID = bsaifm.Type_Code_Desc_ID--->
							AND cm.approved = 1
							AND cp.Is_Group = 0
							AND cp.deleted = 0
							AND cp.bsa_foodservice_Items_Master_ID = bsaifm.bsa_foodservice_Items_Master_ID
						)
						</cfif>
					)
					</cfif>
				<cfelse>
					<cfif arguments.type_code_desc_id neq "null" and arguments.type_code_desc_id neq "">
					AND 1 = 0
					</cfif>
				</cfif>

				<!--- payee filter --->
				<cfif arguments.payee neq "null" and arguments.payee neq "">
				AND
				(
					<cfif arguments.payee neq "0">
						<cfif arguments.type eq "billback" or arguments.type eq "billbackItems" or arguments.type eq "billbackRecords">
						phid.payee_unique_id IN (#LISTQUALIFY(arguments.payee,"'",",","All")#)

						<cfelseif arguments.type eq "offInvoice" or arguments.type eq "OffInvoiceItems" or arguments.type eq "budgetAdjustment" or arguments.type eq "budgetAdjustmentItems"
								or arguments.type eq "OffInvoiceByDate" or arguments.type eq "OffInvoiceDetails">
						<!--- "arguments.payee" includes distributor and operator. "Offinvoice" and  "budget actual adjustment" only has distributor as payee
						and so we will only look for distributor payees. Distributor id is a guid  and has 36 characters.
						operator is is bsa_operator id and is not a guid. We use "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA" for operators,
						since we do not want operator search to to return records for "Off-Invoice" or "budget actual adjustment".
						--->
						<cfset payeeIDList = "">
						<cfloop from="1" to="#Listlen(arguments.payee)#" index="i">
						<cfset payeeID = ListGetAt(arguments.payee,i)>
							<cfif Len(payeeID) eq 36>
								<cfset payeeIDList = ListAppend(payeeIDList,payeeID)>
							<cfelse>
								<cfset payeeIDList = ListAppend(payeeIDList,'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA')>
							</cfif>
						</cfloop>

						phid.bsa_foodservice_customers_id IN (#LISTQUALIFY(payeeIDList,"'",",","All")#)
						</cfif>
					<cfelse>
					1 = 1
					</cfif>

					<!--- "payee not on program" filter. --->
					<cfif ListFind(arguments.payee,'0') gt 0>
					<!--- If the "payee" search criteria also has a filter on "dist id" or "operator id", then user "OR".
					If it only has "payee not on program" filter,then use "AND".
					--->
					<cfif ListLen(arguments.payee,",") GT 1>OR<cfelse>AND</cfif>
					NOT EXISTS
					(
						SELECT 1
						FROM contract_distributors cd
						INNER JOIN contract_main cm
						ON cd.contract_main_id = cm.contract_main_id
						<cfif val(arguments.plannerID)>
						INNER JOIN Planners p ON p.Planner_ID = cm.Planner_ID
						WHERE CASE WHEN ISNULL(p.Parent_Planner_ID, 0) != 0 THEN ISNULL(p.Parent_Planner_ID, 0) ELSE cm.Planner_ID END = #arguments.plannerID#
						<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
						WHERE cm.contract_main_id = #arguments.contractMainID#
						<cfelse>
						WHERE cm.contract_number like '%#arguments.contract_number#%'
						</cfif>
						<cfif arguments.type eq "billback" or arguments.type eq "billbackItems" or arguments.type eq "billbackRecords">
						AND CAST(cd.BSA_Foodservice_Customers_ID as varchar(50)) = phid.payee_unique_id
						<cfelseif arguments.type eq "offInvoice" or arguments.type eq "OffInvoiceItems" or arguments.type eq "budgetAdjustment" or arguments.type eq "budgetAdjustmentItems"
						or arguments.type eq "OffInvoiceByDate"  or arguments.type eq "OffInvoiceDetails">
						AND cd.BSA_Foodservice_Customers_ID = phid.bsa_foodservice_customers_id
						</cfif>
						AND cm.approved = 1
						AND cd.Is_Group = 0
						AND cd.deleted = 0
					)
					</cfif>
				)
				</cfif>

				<!--- settlement ID filter --->
				<cfif arguments.type neq "budgetAdjustment" and arguments.type neq "budgetAdjustmentItems" and arguments.type neq "OffInvoiceByDate"
					and arguments.type neq "OffInvoiceDetails">
					<cfif arguments.settlement_id neq "">
						<cfset settlement_id_keyword = trim(arguments.settlement_id)>
						<cfif arguments.type eq "billback" or arguments.type eq "billbackItems" or arguments.type eq "billbackRecords">
						AND 	phd.check_number like '%#settlement_id_keyword#%'
						<cfelseif arguments.type eq "offInvoice" or arguments.type eq "OffInvoiceItems">
						AND 	phid.invoice_number like '%#settlement_id_keyword#%'
						</cfif>
					</cfif>
				<cfelse>
					<cfif arguments.settlement_id neq "">
					AND 1 = 0
					</cfif>
				</cfif>

				<!--- date criteria filter (start date) --->
				<cfif arguments.type neq "billbackItems" AND arguments.type neq "OffInvoiceItems" AND arguments.type neq "budgetAdjustmentItems"
					and arguments.type neq "OffInvoiceDetails">
					<cfif trim(arguments.date_criteria_start) neq "">
						<cfif arguments.type eq "billback" or arguments.type eq "billbackRecords">
						AND phd.Check_date #arguments.start_date_operator# '#trim(arguments.date_criteria_start)#'
						<cfelseif arguments.type eq "offInvoice" or arguments.type eq "OffInvoiceByDate">
						AND phid.Invoice_date #arguments.start_date_operator# '#trim(arguments.date_criteria_start)#'
						<cfelseif arguments.type eq "budgetAdjustment">
						AND phid.Adjustment_Date #arguments.start_date_operator# '#trim(arguments.date_criteria_start)#'
						</cfif>
					</cfif>


					<!--- date criteria filter (end date) --->
					<cfif trim(arguments.date_criteria_end) neq "">
						<cfif arguments.type eq "billback" or arguments.type eq "billbackRecords">
						AND phd.Check_date #arguments.end_date_operator# '#trim(arguments.date_criteria_end)#'
						<cfelseif arguments.type eq "offInvoice" or arguments.type eq "OffInvoiceByDate">
						AND phid.Invoice_date #arguments.end_date_operator# '#trim(arguments.date_criteria_end)#'
						<cfelseif arguments.type eq "budgetAdjustment">
						AND phid.Adjustment_Date #arguments.start_date_operator# '#trim(arguments.date_criteria_start)#'
						</cfif>
					</cfif>
				</cfif>

			</cfsavecontent>
			</cfoutput>

			<cfreturn var_GetPaymentHistoryFilters />
		</cffunction>

		<cffunction name="getTotalProgramEstimatedAndForecastedToGoVolume" output="false" returntype="query">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="ContractId" required="true" type="string" />

			<!--- No need to set to a variable. This populates the "##LOST_PRODUCTS_LIST" table. --->
			<cfset getBidLostProducts(arguments.ContractId,1)>

			<cfquery name="qGetTotalProgramEstimatedAndForecastedToGoVolume" datasource="#application.datasource#">
				SELECT
					SUM(
					CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 1
						THEN
							CAST((IsNull(v.Estimated_Volume_CS,v.Volume_CS)
								    *
								    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
								    / 7
								    ) as decimal(20, 0))
					WHEN Units_of_Measure.Unit_Of_Measure_ID = 2
						THEN
							CAST((IsNull(v.Estimated_Volume_LB,v.Volume_LB)
							    *
							    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
							    / 7
							    ) as decimal(20, 0))
					END
					)
						As Total_Estimated_Volume,
					SUM(
					<!--- CASES --->
					CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 1
						THEN
							<!--- PROGRAM VERSION IS ALREADY COMPLETED --->
							CASE WHEN CM.Effective_End_Date < Getdate()
								THEN 0
							<!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED VOLUME IS ALSO THE FORECASTED TO GO VOLUME --->
							WHEN  CM.Effective_Start_Date >= Getdate()
								THEN
								CAST((v.Volume_CS
							    *
							    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
							    / 7
							    ) as decimal(20, 0))
							<!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO VOLUME IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
							ELSE
								CAST((v.Volume_CS
								*
								CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as decimal(20, 4))
								/ 7
								) as decimal(20, 0))
							END
					<!--- POUNDS --->
					WHEN Units_of_Measure.Unit_Of_Measure_ID = 2
						THEN
							<!--- PROGRAM VERSION IS ALREADY COMPLETED --->
							CASE WHEN CM.Effective_End_Date < Getdate()
								THEN 0
							<!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED VOLUME IS ALSO THE FORECASTED TO GO VOLUME --->
							WHEN  CM.Effective_Start_Date >= Getdate()
								THEN
								CAST((v.Volume_LB
							    *
							    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
							    / 7
							    ) as decimal(20, 0))
							<!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO VOLUME IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
							ELSE
								CAST((v.Volume_LB
								*
								CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as decimal(20, 4))
								/ 7
								) as decimal(20, 0))
							END
					END
					)
						As Total_Forecasted_To_Go_Volume

				FROM Contract_Main CM
				INNER JOIN Program_Product_Volume v
				ON	CM.Contract_Main_ID = v.Program_ID
				INNER JOIN
					Units_of_Measure ON ISNULL(CM.Contract_Quantity_UOM_IDX, 1) = Units_of_Measure.Unit_Of_Measure_ID
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE CM.contract_main_id = #arguments.ContractId#
				<cfelse>
				WHERE CM.contract_number = '#arguments.contractnumber#'
				</cfif>
				<!--- approved only --->
				AND CM.Approved = 1
				<!--- Where effective dates are populated --->
				AND CM.Effective_Start_Date IS NOT NULL
				AND v.deleted = 0
				AND	v.Is_Group = 0
				AND   EXISTS (
					SELECT      1
					FROM  Contract_Products CP
					WHERE CP.Contract_Main_ID = v.Program_ID
					AND         CP.BSA_Foodservice_Items_Master_ID = v.BSA_Foodservice_Items_Master_ID
					AND         CP.Deleted = 0
					)

				AND v.BSA_Foodservice_Items_Master_ID not in
				(
				SELECT PRODUCT_ID FROM ##LOST_PRODUCTS_LIST
				WHERE ##LOST_PRODUCTS_LIST.PROGRAM_ID = v.Program_ID
				)
			</cfquery>

			<cfreturn qGetTotalProgramEstimatedAndForecastedToGoVolume />
		</cffunction>

		<cffunction name="getBidLostProducts" output="false" returntype="void">
			<cfargument name="ContractId" required="true" type="string" />
			<cfargument name="type" required="true" type="string" />

			<cfquery name="deltmp_program_settings" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_program_settings_list') IS NOT NULL
			DROP TABLE  ##tmp_program_settings_list

			IF OBJECT_ID('tempdb..##LOST_PRODUCTS_LIST') IS NOT NULL
			DROP TABLE  ##LOST_PRODUCTS_LIST
			</cfquery>

			<cfquery name="qGetBidLostProducts" datasource="#application.datasource#">
			SELECT	contract_main.Contract_Main_ID,
					program_control_panel_options.BidRequestStatusOn,
					program_control_panel_options.ItemMarked_Lost_Program_Volume_Automation,
					program_control_panel_options.Itemmarked_Lost_Budget_Committed_Dollars
			INTO ##tmp_program_settings_list
			FROM	contract_main
			INNER JOIN  program_control_panel_options
			ON	program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
			WHERE contract_main_id = '#arguments.ContractId#'

			SELECT  distinct   PROGRAM_BID_REQUEST.PROGRAM_ID,PROGRAM_PRODUCT_BID_INFO.PRODUCT_ID
			INTO	##LOST_PRODUCTS_LIST
			FROM	##tmp_program_settings_list tmp_prog
			INNER JOIN PROGRAM_BID_REQUEST
			ON tmp_prog.Contract_Main_ID = PROGRAM_BID_REQUEST.PROGRAM_ID
			INNER JOIN PROGRAM_PRODUCT_BID_INFO
			ON		PROGRAM_PRODUCT_BID_INFO.Program_ID = PROGRAM_BID_REQUEST.Program_ID
			AND		PROGRAM_PRODUCT_BID_INFO.WON =0 <!--- LOST ITEMS --->
			AND		PROGRAM_PRODUCT_BID_INFO.DELETED = 0
			AND		PROGRAM_BID_REQUEST.Deleted = 0
			AND		PROGRAM_BID_REQUEST.BID_REQUEST_STATUS_ID != 1
			AND		tmp_prog.BidRequestStatusOn = 1
			<!--- VOLUME --->
			<cfif arguments.type eq 1>
			AND		tmp_prog.ItemMarked_Lost_Program_Volume_Automation = 0
			<!--- TRADE SPEND --->
			<cfelseif arguments.type eq 2>
			AND		tmp_prog.Itemmarked_Lost_Budget_Committed_Dollars = 0
			</cfif>
			</cfquery>
			<!--- NO NEED TO RETURN DATA. DATA IS POPULATED IN A TEMP TABLE, WHICH CAN BE USED --->

		</cffunction>

		<cffunction name="getProgramUOM" output="false" returntype="query">
			<cfargument name="ContractId" required="true" type="string" />

			<cfquery name="qGetProgramUOM" datasource="#application.datasource#">
			SELECT Units_of_Measure.Unit_Of_Measure_ID ,Units_of_Measure.Abbreviation As program_uom,
				Units_of_Measure.Unit_Of_Measure_Desc
				FROM Contract_Main CM
						INNER JOIN
					Units_of_Measure ON ISNULL(CM.Contract_Quantity_UOM_IDX, 1) = Units_of_Measure.Unit_Of_Measure_ID
			WHERE CM.Contract_Main_ID = '#arguments.ContractId#'
			</cfquery>

			<cfreturn qGetProgramUOM />
		</cffunction>

		<cffunction name="getTotalProgramActualVolume" output="false" returntype="query">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="contractId" required="true" type="string" />

			<cfset var qGetProgramUOM = getProgramUOM(arguments.contractId)>

			<cfquery name="delTmpTblTotalProgramActualVolume" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblTotalProgramActualVolume') IS NOT NULL
			DROP TABLE ##tmpTblTotalProgramActualVolume
			</cfquery>

			<cfquery name="qGetTotalProgramActualVolume" datasource="#application.datasource#">
			CREATE TABLE ##tmpTblTotalProgramActualVolume
			(
				Total_Actual_Volume decimal(20, 0)
			)
			INSERT INTO ##tmpTblTotalProgramActualVolume(Total_Actual_Volume)
			SELECT <cfif qGetProgramUOM.Unit_Of_Measure_ID eq 1>SUM(ROUND(IsNull(phd.Volume_CS,0),0))<cfelseif qGetProgramUOM.Unit_Of_Measure_ID eq 2>SUM(ROUND(IsNull(phd.Volume_LB,0),0))</cfif>
			FROM	payment_history_item_details phd

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phd.contract_main_id = #arguments.ContractId#
			<cfelse>
			WHERE phd.contract_number = '#arguments.contractnumber#'
			</cfif>

			INSERT INTO ##tmpTblTotalProgramActualVolume(Total_Actual_Volume)
			SELECT <cfif qGetProgramUOM.Unit_Of_Measure_ID eq 1>SUM(ROUND(IsNull(phod.Cases_Invoiced,0),0))<cfelseif qGetProgramUOM.Unit_Of_Measure_ID eq 2>SUM(ROUND(IsNull(phod.Pounds_Invoiced,0),0))</cfif>
			FROM	Payment_History_Operator_Offinvoice_Details phod

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phod.contract_main_id = #arguments.ContractId#
			<cfelse>
			WHERE phod.contract_number = '#arguments.contractnumber#'
			</cfif>

			SELECT SUM(Total_Actual_Volume) As Total_Actual_Volume
			FROM ##tmpTblTotalProgramActualVolume
			</cfquery>

			<cfreturn qGetTotalProgramActualVolume />
		</cffunction>

		<cffunction name="getProgramEstimatedAndForecastedToGoAndActualVolumeItems" output="false" returntype="struct">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="contractId" required="true" type="string" />
			<cfargument name="listOfWords" type="string" required="false" default="" />
			<!--- "column_sequence_number" default has been set below for the Excel report.
			Default of "2" below is "Estimated_Volume", the third column on the grid --->
			<cfargument name="column_sequence_number" type="string" required="false" default="2" />
			<cfargument name="sort_order" type="string" required="false" default="asc" />
			<cfargument name="startRow" type="numeric" required="false" default="0" />
			<cfargument name="displayLength" type="numeric" required="false" default="0" />
			<!--- DO NOT USE CFQUERYPARAM ON THIS FUNCTION, AS WE NEED TO ACCESS A TEMP TABLE ACROSS MULTIPLE QUERIES.
			TEMP TABLE WILL NOT BE AVAILABLE TO ANOTHER QUERY, IF WE USE CFQUERYPARAM.
			--->

			<cfset var returnStruct = StructNew()>
			<cfset var qGetProgramUOM = getProgramUOM(arguments.contractId)>

			<!--- No need to set to a variable. This populates the "##LOST_PRODUCTS_LIST" table. --->
			<cfset getBidLostProducts(arguments.ContractId,1)>

			<cfquery name="delTmpTblProgramVolumeItems" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblProgramActualVolumeItems') IS NOT NULL
			DROP TABLE ##tmpTblProgramActualVolumeItems

			IF OBJECT_ID('tempdb..##tmpTblTotalProgramActualVolumeItems') IS NOT NULL
			DROP TABLE ##tmpTblTotalProgramActualVolumeItems

			IF OBJECT_ID('tempdb..##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems') IS NOT NULL
			DROP TABLE ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems

			IF OBJECT_ID('tempdb..##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeAllItems') IS NOT NULL
			DROP TABLE ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeAllItems
			</cfquery>

			<cfquery name="qGetProgramEstimatedAndForecastedToGoAndActualVolumeItems" datasource="#application.datasource#">
			CREATE TABLE ##tmpTblProgramActualVolumeItems
			(
				Item varchar(50),
				BSA_Foodservice_Items_Master_ID varchar(50),
				Description varchar(255),
				Actual_Volume decimal(20, 0)
			)

			CREATE TABLE ##tmpTblTotalProgramActualVolumeItems
			(
				Item varchar(50),
				BSA_Foodservice_Items_Master_ID varchar(50),
				Description varchar(255),
				Actual_Volume decimal(20, 0)
			)

			CREATE TABLE ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems
			(
				Item varchar(50),
				BSA_Foodservice_Items_Master_ID varchar(50),
				Description varchar(255),
				Estimated_Volume decimal(20, 0) NULL DEFAULT (0),
				Forecasted_To_Go_Volume decimal(20, 0) NULL DEFAULT (0),
				Actual_Volume decimal(20, 0) NULL DEFAULT (0),
				Variance decimal(20, 0) NULL DEFAULT (0)
			)

			<!--- Get the "Estimated" and "Forecasted" volume --->
			INSERT INTO ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems(Item,BSA_Foodservice_Items_Master_ID,Description,Estimated_Volume,Forecasted_To_Go_Volume)
			SELECT bfim.Item,bfim.BSA_Foodservice_Items_Master_ID,bfim.Description,
				SUM(
					<!--- CASES --->
					CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 1
							THEN
								CAST((IsNull(v.Estimated_Volume_CS,v.Volume_CS)
									    *
									    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
									    / 7
									    ) as decimal(20, 0))
						<!--- POUNDS --->
						WHEN Units_of_Measure.Unit_Of_Measure_ID = 2
							THEN
								CAST((IsNull(v.Estimated_Volume_LB,v.Volume_LB)
									    *
									    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
									    / 7
									    ) as decimal(20, 0))
					END
				)
					As Estimated_Volume,
				SUM(
					<!--- CASES --->
					CASE WHEN Units_of_Measure.Unit_Of_Measure_ID = 1
							THEN
								<!--- PROGRAM VERSION IS ALREADY COMPLETED --->
								CASE WHEN CM.Effective_End_Date < Getdate()
									THEN 0
								<!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED VOLUME IS ALSO THE FORECASTED TO GO VOLUME --->
								WHEN  CM.Effective_Start_Date >= Getdate()
									THEN
										CAST((v.Volume_CS
									    *
									    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
									    / 7
									    ) as decimal(20, 0))
								<!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO VOLUME IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
								ELSE
									CAST((v.Volume_CS
									*
									CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as decimal(20, 4))
									/ 7
									) as decimal(20, 0))
								END
					<!--- POUNDS --->
					WHEN Units_of_Measure.Unit_Of_Measure_ID = 2
							THEN
								<!--- PROGRAM VERSION IS ALREADY COMPLETED --->
								CASE WHEN CM.Effective_End_Date < Getdate()
										THEN 0
								<!--- PROGRAM VERSION WILL START IN THE FUTURE - THE FULL ESTIMATED VOLUME IS ALSO THE FORECASTED TO GO VOLUME --->
								WHEN  CM.Effective_Start_Date >= Getdate()
										THEN
										CAST((v.Volume_LB
									    *
									    CAST(DATEDIFF(D, CM.Effective_Start_Date, CM.Effective_End_Date) + 1 as decimal(20, 4))
									    / 7
									    ) as decimal(20, 0))
								<!--- WE ARE IN-BETWEEN A PROGRAM VERSION - FORECASTED TO GO VOLUME IS CALCULATED BASED ON THE REMAINING DAYS OF THE VERSION  --->
								ELSE
										CAST((v.Volume_LB
										*
										CAST(DATEDIFF(D, getDate(), CM.Effective_End_Date) + 1 as decimal(20, 4))
										/ 7
										) as decimal(20, 0))
								END
					END
				)
					As Forecasted_To_Go_Volume

				FROM Contract_Main CM
				INNER JOIN Program_Product_Volume v
					ON CM.Contract_Main_ID = v.Program_ID
				INNER JOIN
					Units_of_Measure ON ISNULL(CM.Contract_Quantity_UOM_IDX, 1) = Units_of_Measure.Unit_Of_Measure_ID
				INNER JOIN BSA_Foodservice_Items_Master bfim
					ON v.BSA_Foodservice_Items_Master_ID = bfim.BSA_Foodservice_Items_Master_ID
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE CM.contract_main_id = #arguments.ContractId#
				<cfelse>
				WHERE CM.Contract_Number = '#arguments.contractNumber#'
				</cfif>
				AND v.deleted = 0
				AND	v.Is_Group = 0
				<!--- approved only --->
				AND CM.Approved = 1
				<!--- Where effective dates are populated --->
				AND CM.Effective_Start_Date IS NOT NULL
				AND   EXISTS (
					SELECT      1
					FROM  Contract_Products CP
					WHERE CP.Contract_Main_ID = v.Program_ID
					AND         CP.BSA_Foodservice_Items_Master_ID = v.BSA_Foodservice_Items_Master_ID
					AND         CP.Deleted = 0
					)
				AND v.BSA_Foodservice_Items_Master_ID NOT IN
				(
				SELECT PRODUCT_ID FROM ##LOST_PRODUCTS_LIST
				WHERE ##LOST_PRODUCTS_LIST.PROGRAM_ID = v.Program_ID
				)
				GROUP BY bfim.Item,bfim.BSA_Foodservice_Items_Master_ID,bfim.Description

				<!--- Get the "actual" volume --->

				<!--- get actual volume from billback --->
				INSERT INTO ##tmpTblProgramActualVolumeItems(Item,BSA_Foodservice_Items_Master_ID,Description,Actual_Volume)
				SELECT Item,Product_ID,Description,<cfif qGetProgramUOM.Unit_Of_Measure_ID eq 1>ROUND(Volume_CS,0)<cfelseif qGetProgramUOM.Unit_Of_Measure_ID eq 2>ROUND(Volume_LB,0)</cfif>
				FROM	payment_history_item_details
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE contract_main_id = #arguments.ContractId#
				<cfelse>
				WHERE Contract_Number = '#arguments.contractNumber#'
				</cfif>

				<!--- get actual volume from off-invoice  --->
				INSERT INTO ##tmpTblProgramActualVolumeItems(Item,BSA_Foodservice_Items_Master_ID,Description,Actual_Volume)
				SELECT phod.Item,phod.BSA_Foodservice_Items_Master_ID,phod.Description,<cfif qGetProgramUOM.Unit_Of_Measure_ID eq 1>ROUND(phod.Cases_Invoiced,0)
					<cfelseif qGetProgramUOM.Unit_Of_Measure_ID eq 2>ROUND(phod.Pounds_Invoiced,0)</cfif>
				FROM	Payment_History_Operator_Offinvoice_Details phod
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phod.contract_main_id = #arguments.ContractId#
				<cfelse>
				WHERE phod.Contract_Number = '#arguments.contractNumber#'
				</cfif>

				<!--- SUM up the actual volume --->
				INSERT INTO ##tmpTblTotalProgramActualVolumeItems(Item,BSA_Foodservice_Items_Master_ID,Description,Actual_Volume)
				SELECT Item,BSA_Foodservice_Items_Master_ID,Description,SUM(Actual_Volume)
				FROM ##tmpTblProgramActualVolumeItems
				GROUP BY BSA_Foodservice_Items_Master_ID,Item,Description

				UPDATE tmp_EFAV
					SET Actual_Volume = tmp_AV.Actual_Volume
				FROM	##tmpTblTotalProgramActualVolumeItems tmp_AV
				INNER JOIN ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems tmp_EFAV
				ON tmp_AV.BSA_Foodservice_Items_Master_ID = tmp_EFAV.BSA_Foodservice_Items_Master_ID

				<!--- If there are any products which exist in the "actual volume data", which are not already in the "Estimated/Forecasted" volume, then insert those records. --->
				INSERT INTO ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems(Item,BSA_Foodservice_Items_Master_ID,Description,Actual_Volume)
				SELECT tbl_AV.Item,tbl_AV.BSA_Foodservice_Items_Master_ID,tbl_AV.Description,tbl_AV.Actual_Volume
				FROM ##tmpTblTotalProgramActualVolumeItems tbl_AV
				LEFT JOIN ##tmpTblProgramEstimatedAndForecastedtoGoAndActualVolumeItems tbl_EFAV
				ON tbl_AV.bsa_foodservice_Items_Master_ID = tbl_EFAV.bsa_foodservice_Items_Master_ID
				WHERE NOT EXISTS
				(
					SELECT 1
					FROM ##tmpTblProgramEstimatedAndForecastedtoGoAndActualVolumeItems
					WHERE BSA_Foodservice_Items_Master_ID = tbl_AV.bsa_foodservice_Items_Master_ID
				 )

				UPDATE tmp_EFAV
				SET Variance = (tmp_EFAV.Actual_Volume + tmp_EFAV.Forecasted_To_Go_Volume) - tmp_EFAV.Estimated_Volume
				FROM	##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems tmp_EFAV

				<!--- Total number of records before filter --->
				SELECT count(Item) As recordTotalCount
				FROM ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems
			</cfquery>
			<!--- This "rowIDInt" field creates a incremental integer. Since we only want to retrieve selected records using a range, eg: 100-200, 300-400 etc,
			"rowIDInt" can be used for that purpose. Please leave this column as the first column.
			So that "rowIDInt" increments integers properly, the second column in the below query should not have any blank or null value.
			--->
			<cfquery name="qNewTblProgramEstimatedAndForecastedToGoAndActualVolumeItemsFiltered" datasource="#application.datasource#">
			SELECT identity(INT) As rowIDInt,*
			INTO ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeAllItems
			FROM ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems
				<cfif arguments.listOfWords neq "">
				WHERE
				(
				Item like '%#arguments.listOfWords#%'
				OR
				Description like '%#arguments.listOfWords#%'
				)
				</cfif>

			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<cfswitch expression="#arguments.column_sequence_number#">
				 <cfcase value=0>ORDER BY Item</cfcase>
				 <cfcase value=1>ORDER BY Description</cfcase>
				 <cfcase value=2>ORDER BY Estimated_Volume</cfcase>
				 <cfcase value=3>ORDER BY Actual_Volume</cfcase>
				 <cfcase value=4>ORDER BY Forecasted_To_Go_Volume</cfcase>
				 <cfcase value=5>ORDER BY Variance</cfcase>
			</cfswitch>
			#arguments.sort_order#
			</cfquery>

			<cfquery name="qGetProgramEstimatedAndForecastedToGoAndActualVolumeItemsFiltered" datasource="#application.datasource#">
			<!--- Total number of records after filter --->
			SELECT count(Item) As recordFilteredCount
			FROM ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeAllItems
			</cfquery>

			<!--- Below query could have used the following logic, but did not.
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#

			Using the "SET ROWCOUNT" method to retrieve a range of records might be a litle faster.
			--->
			<cfquery name="qGetProgramEstimatedAndForecastedToGoAndActualVolumeItemsFilteredResults" datasource="#application.datasource#">
			<!--- How many rows to retrieve --->
			SET ROWCOUNT #arguments.displayLength#

			SELECT *
			FROM ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeAllItems
			<!--- Query to return what is needed for paging. In this case, since we are using "ROWCOUNT", below condition
			will return records starting from "#arguments.startRow#" record and fetch the next "ROWCOUNT" records.
			--->
			WHERE rowIDInt >= #arguments.startRow#

			<!--- Seting this is important. This is resetting the count. --->
			SET ROWCOUNT 0
			</cfquery>

			<!--- Get the "Total" for the data --->
			<cfquery name="qGetProgramTotalVolumeItemsFiltered" datasource="#application.datasource#">
				SELECT SUM(tmp_EFAV.Estimated_Volume) As Total_Estimated_Volume,SUM(tmp_EFAV.Actual_Volume) As Total_Actual_Volume,
						SUM(tmp_EFAV.Forecasted_To_Go_Volume) As Total_Forecasted_To_Go_Volume,SUM(Variance) As Total_Variance_Volume
				FROM ##tmpTblProgramEstimatedAndForecastedToGoAndActualVolumeItems tmp_EFAV
				<cfif arguments.listOfWords neq "">
				WHERE
				(
				Item like '%#arguments.listOfWords#%'
				OR
				Description like '%#arguments.listOfWords#%'
				)
				</cfif>
			</cfquery>

				<!--- Total records (before filter) --->
				<cfset returnStruct.recordTotal = qGetProgramEstimatedAndForecastedToGoAndActualVolumeItems.recordTotalCount>

				<!--- Filtered records query (after filter) --->
				<cfset returnStruct.filteredResults = qGetProgramEstimatedAndForecastedToGoAndActualVolumeItemsFilteredResults>

				<!--- Filtered records (after filter) --->
				<cfset returnStruct.filteredTotal = qGetProgramEstimatedAndForecastedToGoAndActualVolumeItemsFiltered.recordFilteredCount>

				<!--- "Total data" variables --->
				<cfset returnStruct.TotalFilteredEstimatedVolume = qGetProgramTotalVolumeItemsFiltered.Total_Estimated_Volume>
				<cfset returnStruct.TotalFilteredActualVolume = qGetProgramTotalVolumeItemsFiltered.Total_Actual_Volume>
				<cfset returnStruct.TotalFilteredForecastedToGoVolume = qGetProgramTotalVolumeItemsFiltered.Total_Forecasted_To_Go_Volume>
				<cfset returnStruct.TotalFilteredVarianceVolume = qGetProgramTotalVolumeItemsFiltered.Total_Variance_Volume>

			<cfreturn returnStruct />
		</cffunction>

		<cffunction name="getTotalProgramActualTradeSpend" output="false" returntype="query">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="contractMainID" required="true" type="string" />

			<cfquery name="delTmpTblTotalProgramActualTradeSpend" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblTotalProgramActualTradeSpend') IS NOT NULL
			DROP TABLE ##tmpTblTotalProgramActualTradeSpend
			</cfquery>

			<cfquery name="qGetTotalProgramActualTradeSpend" datasource="#application.datasource#">
			CREATE TABLE ##tmpTblTotalProgramActualTradeSpend
			(
				Total_Actual_TradeSpend decimal(20, 0)
			)
			<!--- Get billback data --->
			INSERT INTO ##tmpTblTotalProgramActualTradeSpend(Total_Actual_TradeSpend)
			SELECT SUM(phd.rate)
			FROM	payment_history_item_details phd

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phd.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phd.contract_number = '#arguments.contractnumber#'
			</cfif>

			<!--- Get off-invoice data --->
			INSERT INTO ##tmpTblTotalProgramActualTradeSpend(Total_Actual_TradeSpend)
			SELECT SUM(IsNull(phod.Sales_Dollars,0))
			FROM	Payment_History_Operator_Offinvoice_Details phod

			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE phod.contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE phod.contract_number = '#arguments.contractnumber#'
			</cfif>

			<!--- Get budget adjustment data --->
			INSERT INTO ##tmpTblTotalProgramActualTradeSpend(Total_Actual_TradeSpend)
			SELECT SUM(IsNull(phid.Adjustment_Dollar,0))
			FROM	Budget_Actual_Adjustment phid
			<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
			WHERE contract_main_id = #arguments.contractMainID#
			<cfelse>
			WHERE Contract_Main_Id
			IN
			(
			SELECT Contract_Main_ID
			FROM Contract_Main
			WHERE Contract_Number = '#arguments.contractnumber#'
			)
			</cfif>

			SELECT SUM(Total_Actual_TradeSpend) As Total_Actual_TradeSpend
			FROM ##tmpTblTotalProgramActualTradeSpend
			</cfquery>

			<cfreturn qGetTotalProgramActualTradeSpend />
		</cffunction>

			<cffunction name="getProgramAccrualData" output="false" returntype="struct">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfargument name="listOfWords" type="string" required="false" default="" />
			<!--- "column_sequence_number" default has been set below for the Excel report.
			Default of "2" below is "Ship_To_Name", the third column on the grid --->
			<cfargument name="column_sequence_number" type="string" required="false" default="1"/>
			<cfargument name="sort_order" type="string" required="false" default="asc" />
			<cfargument name="startRow" type="numeric" required="false" default="0" />
			<cfargument name="endRow" type="numeric" required="false" default="0" />
			<cfargument name="deductionAccount" required="false" type="string" default="" />
			<cfargument name="paymentAccount" required="false" type="string" default="" />
			<cfargument name="glAccount" required="false" type="string" default="" />
			<cfargument name="externalID" required="false" type="string" default="" />
			<cfargument name="componentName" required="false" type="string" default="" />
			<cfargument name="plannerID" required="false" default="0" />
			<cfargument name="contractNumberFilter" required="false" type="string" default="" />
			<cfargument name="shipTo" required="false" type="string" default="" />
			<cfargument name="shipToText" required="false" type="string" default="" />



			<!--- DO NOT USE CFQUERYPARAM ON THIS FUNCTION, AS WE NEED TO ACCESS A TEMP TABLE ACROSS MULTIPLE QUERIES.
			TEMP TABLE WILL NOT BE AVAILABLE TO ANOTHER QUERY, IF WE USE CFQUERYPARAM.
			--->
			<cfset var returnStruct = StructNew()>
			<cfset getDeductionAccountExist = getDeductionAccountExist(arguments.contractNumber, arguments.contractMainID)>

			<cfset var lAccrualExcludeDocumentTypes =  appSettings.get_Setting('Accrual_Exclude_Document_Types') />

			<cfquery name="delTmpTblProgramAccrualData" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblTop1Component') IS NOT NULL
			DROP TABLE ##tmpTblTop1Component

			IF OBJECT_ID('tempdb..##tmpTblProgramAccrualData') IS NOT NULL
			DROP TABLE ##tmpTblProgramAccrualData

			IF OBJECT_ID('tempdb..##tmpTblProgramDiscountTypeAccrualData') IS NOT NULL
			DROP TABLE ##tmpTblProgramDiscountTypeAccrualData

			IF OBJECT_ID('tempdb..##tmpTblProgramAllAccrualData') IS NOT NULL
			DROP TABLE ##tmpTblProgramAllAccrualData

			IF OBJECT_ID('tempdb..##tmpTblProgramAllAccrualDataWithFilter') IS NOT NULL
			DROP TABLE ##tmpTblProgramAllAccrualDataWithFilter

			IF OBJECT_ID('tempdb..##tmpTblProgramAccrualDollars') IS NOT NULL
			DROP TABLE ##tmpTblProgramAccrualDollars

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
			</cfquery>

			<cfset getcontractIds('#arguments.contractnumber#', arguments.plannerID)>

			<!--- This "rowIDInt" field creates a incremental integer. Since we only want to retrieve selected records using a range, eg: 100-200, 300-400 etc,
			"rowIDInt" can be used for that purpose. Please leave this column as the first column.
			So that "rowIDInt" increments integers properly, the second column in the below query should not have any blank or null value.
			--->
			<cfquery name="qGetProgramAccrualData" datasource="#application.datasource#">
			CREATE TABLE ##tmp_plnrAcc_pgm
			(
				Contract_Main_ID int,
				Contract_Number varchar(20)
			)
			CREATE TABLE ##tmp_plnrAcc_prod
			(
				Product_ID uniqueidentifier
			)
			CREATE TABLE ##tmp_plnrAcc_dist
			(
				Distributor_ID uniqueidentifier
			)
			<cfif val(arguments.plannerID)>
				INSERT INTO ##tmp_plnrAcc_pgm (Contract_Main_ID, Contract_Number)
				SELECT	Contract_Main_ID, Contract_Number
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter bit

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				INSERT INTO ##tmp_plnrAcc_prod (Product_ID)
				SELECT	Product_ID
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				insert into ##tmp_plnrAcc_dist (Distributor_ID)
				select	DISTINCT Customer_ID
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

			<!--- Rebate data from the "rebate acrual" table --->
			SELECT contract_number, Discount_Type_ID As Discount_Type,ROUND(gla_rebate.Cases_Invoiced,0) As Cases_Invoiced,gla_rebate.Amount As Amount,IsNull(gla_rebate.Deduction_Account,'') As Deduction_Account,
			IsNull(gla_rebate.Payment_Account,'') As Payment_Account, gla_rebate.Distributor_ID, gla_rebate.Component_Name_ID, gla_rebate.Component_Name, gla_rebate.External_ID,
			gla_rebate.GL_Account_Name as GL_Account_Desc
			INTO ##tmpTblProgramAccrualDollars
			FROM GLA_Combined gla_rebate
			WHERE
				<cfif val(arguments.plannerID)>
						EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
				AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
				AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
				AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
				AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
				<cfelse>
					<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
						gla_rebate.contract_main_id = #arguments.contractMainID#
					<cfelse>
						gla_rebate.contract_number = '#arguments.contractnumber#'
					</cfif>
				</cfif>

				<!---Tim Ford WR D82535 - Accrual Records Overview in FORGE
					If the Accrual_Exclude_Document_Types setting is FS then we exclude records where Document_Type = FS
				 --->
				<cfif ListFindNoCase(lAccrualExcludeDocumentTypes, 'FS') or ListFindNoCase(lAccrualExcludeDocumentTypes, 'FC')>
					AND ISNULL(gla_rebate.Document_Type,'') NOT IN (#ListQualify(lAccrualExcludeDocumentTypes,"'")#)
				</cfif>



			<!--- Get "Total Accrual" Data --->
			SELECT contract_number, Discount_Type,SUM(ROUND(gla.Cases_Invoiced,0)) As Cases_Invoiced,SUM(gla.Amount) As Amount,gla.Deduction_Account,gla.Payment_Account,
					gla.Distributor_ID, gla.Component_Name_ID, gla.Component_Name, gla.External_ID, GL_Account_Desc, 0 as Spent_Dollars
			INTO ##tmpTblProgramAccrualData
			FROM ##tmpTblProgramAccrualDollars gla
			GROUP BY contract_number, gla.Discount_Type,gla.Deduction_Account,gla.Payment_Account,gla.Distributor_ID, gla.Component_Name_ID,  gla.Component_Name, gla.External_ID,gla.GL_Account_Desc


			IF OBJECT_ID('tempdb..##tmpTblTop1Component') IS NOT NULL
			DROP TABLE ##tmpTblTop1Component

			SELECT top 1 Discount_Type, Deduction_Account, Payment_Account, Component_Name_ID, Component_Name, External_ID, GL_Account_Desc
			INTO ##tmpTblTop1Component
			FROM ##tmpTblProgramAccrualData gla_rebate

			<!---  This is query number 2. Here the JOINS are being used to populate the complete data set for rebate --->
			SELECT gla_rebate.contract_number, bsafc.Ship_To As Ship_To, bsafc.Name As Ship_To_Name, bsafc.BSA_Foodservice_Customers_ID, ROUND(gla_rebate.Cases_Invoiced,0) As Cases_Invoiced,
				gla_rebate.Amount, gla_rebate.Spent_Dollars, gla_rebate.Deduction_Account, gla_rebate.Payment_Account, gla_rebate.External_ID,
				gla_rebate.Component_Name,gla_rebate.Component_Name_ID,gla_rebate.GL_Account_Desc
			INTO ##tmpTblProgramDiscountTypeAccrualData
			FROM	##tmpTblProgramAccrualData gla_rebate
			INNER JOIN BSA_Foodservice_Customers bsafc <!--- We will join and get data as we may have some records from payment history table ---->
				ON gla_rebate.Distributor_ID = bsafc.BSA_Foodservice_Customers_ID

			<!---  Complete data set (SUMMED) --->
			SELECT RIGHT(Contract_Number, 7) as contract_number, Ship_To, Ship_To_Name,BSA_Foodservice_Customers_ID,SUM(Cases_Invoiced) As Cases_Invoiced,SUM(Amount) As Amount,SUM(Spent_Dollars) As Spent_Dollars,
				  Deduction_Account,Payment_Account,External_ID,Component_Name,Component_Name_ID,GL_Account_Desc,(gla.Amount - gla.Spent_Dollars) As Remaining_Dollars,
				CASE WHEN gla.Amount = 0 AND gla.Spent_Dollars > 0
					THEN -100
					WHEN gla.Amount = 0 AND gla.Spent_Dollars = 0
					THEN 0
					ELSE
					CEILING((((gla.Amount - gla.Spent_Dollars)/gla.Amount) * 100))
				END
				As Remaining_Percent
			INTO ##tmpTblProgramAllAccrualData
			FROM ##tmpTblProgramDiscountTypeAccrualData gla
			GROUP BY contract_number, Ship_To, Ship_To_Name,BSA_Foodservice_Customers_ID,Deduction_Account,Payment_Account,External_ID,Component_Name,Component_Name_ID,GL_Account_Desc,
			gla.Amount,gla.Spent_Dollars

			<!--- get filtered dataset --->
			SELECT identity(INT) As rowIDInt, *, RIGHT(Contract_Number, 7) as Contract_Number_Key
			INTO ##tmpTblProgramAllAccrualDataWithFilter
			FROM ##tmpTblProgramAllAccrualData
			WHERE 1 = 1
				<!--- keyword filter --->
				<cfif arguments.listOfWords neq "">
				AND
				(
				Ship_To like '%#arguments.listOfWords#%'
				OR
				Ship_To_Name like '%#arguments.listOfWords#%'
				)
				</cfif>

				<!--- dropdown filters --->
				<cfif arguments.deductionAccount neq "">
				AND Deduction_Account = '#arguments.deductionAccount#'
				</cfif>

				<cfif arguments.paymentAccount neq "">
				AND Payment_Account = '#arguments.paymentAccount#'
				</cfif>

				<cfif arguments.externalID neq "">
				AND External_ID = '#arguments.externalID#'
				</cfif>

				<cfif arguments.componentName neq "">
				AND Component_Name = '#arguments.componentName#'
				</cfif>

				<cfif arguments.glAccount neq "">
				AND GL_Account_Desc = '#arguments.glAccount#'
				</cfif>

				<cfif arguments.contractNumberFilter neq "">
				AND contract_number = '#arguments.contractNumberFilter#'
				</cfif>

				<cfif arguments.shipTo neq "">
				AND Ship_To = '#arguments.shipTo#'
				</cfif>

				<cfif arguments.shipToText neq "">
				AND Ship_To_Name like '%#arguments.shipToText#%'
				</cfif>


			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<cfif getDeductionAccountExist eq 1>
				<cfswitch expression="#arguments.column_sequence_number#">
					<cfcase value=0>ORDER BY Contract_Number</cfcase>
					<cfcase value=1>ORDER BY Ship_To</cfcase>
					<cfcase value=2>ORDER BY Ship_To_Name</cfcase>
					<cfcase value=7>ORDER BY Cases_Invoiced</cfcase>
					<cfcase value=8>ORDER BY Amount</cfcase>
				</cfswitch>
			<cfelse>
				<cfswitch expression="#arguments.column_sequence_number#">
					<cfcase value=0>ORDER BY Contract_Number</cfcase>
					<cfcase value=1>ORDER BY Ship_To</cfcase>
					<cfcase value=2>ORDER BY Ship_To_Name</cfcase>
					<cfcase value=7>ORDER BY Cases_Invoiced</cfcase>
					<cfcase value=8>ORDER BY Amount</cfcase>
				</cfswitch>
			</cfif>

			#arguments.sort_order#

			<!--- Total number of records before filter --->
			SELECT count(Ship_To) As recordTotalCount
			FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<!--- Queries to populate dropdown data for filtering (START) --->
			<cfquery name="qGetUniqueDeductionAccount" datasource="#application.datasource#">
				SELECT DISTINCT Deduction_Account
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<cfquery name="qGetUniquePaymentAccount" datasource="#application.datasource#">
				SELECT DISTINCT Payment_Account
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<cfquery name="qGetUniqueExternalID" datasource="#application.datasource#">
				SELECT DISTINCT External_ID
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<cfquery name="qGetUniqueComponentName" datasource="#application.datasource#">
				SELECT DISTINCT Component_Name
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<cfquery name="qGetUniqueGLAccount" datasource="#application.datasource#">
				SELECT DISTINCT GL_Account_Desc
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<cfquery name="qGetUniqueContractNumber" datasource="#application.datasource#">
				SELECT DISTINCT contract_number
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>

			<cfquery name="qGetUniqueShipTo" datasource="#application.datasource#">
				SELECT DISTINCT Ship_To
				FROM ##tmpTblProgramAllAccrualData
			</cfquery>
			<!--- Queries to populate dropdown data for filtering (END) --->

			<cfquery name="qGetProgramAccrualDataFiltered" datasource="#application.datasource#">
			<!--- Total number of records after filter --->
			SELECT count(Ship_To) As recordFilteredCount
			FROM ##tmpTblProgramAllAccrualDataWithFilter
			</cfquery>

			<cfquery name="qGetProgramAccrualDataFilteredResults" datasource="#application.datasource#">
			SELECT * FROM ##tmpTblProgramAllAccrualDataWithFilter
			<!--- Query usng a range to return what is needed for paging. --->
			<cfif arguments.startRow eq 0>
			WHERE 1 = 1
			<cfelse>
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#
			</cfif>
			Order By rowIDInt
			</cfquery>

			<!--- Get the "Total" for the data --->
			<cfquery name="qGetProgramTotalAccrualDataFiltered" datasource="#application.datasource#">
				SELECT ISNULL(SUM(Cases_Invoiced), 1) As Total_Cases_Invoiced,SUM(Amount) As Total_Amount,
						CASE
							WHEN SUM(Spent_Dollars) = 0 THEN 1
							ELSE SUM(Spent_Dollars)
						END  AS Total_Spent_Dollars,
						SUM(Remaining_Dollars) As Total_Remaining_Dollars,
						CASE
							WHEN SUM(Amount) * 100 != 0 THEN CEILING((((SUM(Amount) - SUM(Spent_Dollars))/SUM(Amount)) * 100))
							ELSE 0
							END  AS Total_Remaining_Percent
				FROM ##tmpTblProgramAllAccrualDataWithFilter
			</cfquery>

				<!--- Total records (before filter) --->
				<cfset returnStruct.recordTotal = qGetProgramAccrualData.recordTotalCount>

				<!--- Filtered records query (after filter) --->
				<cfset returnStruct.filteredResults = qGetProgramAccrualDataFilteredResults>

				<!--- Filtered records (after filter) --->
				<cfset returnStruct.filteredTotal = qGetProgramAccrualDataFiltered.recordFilteredCount>

				<!--- "Total data" variables --->
				<cfset returnStruct.TotalFilteredCasesInvoiced = qGetProgramTotalAccrualDataFiltered.Total_Cases_Invoiced>
				<cfset returnStruct.TotalFilteredAmount = qGetProgramTotalAccrualDataFiltered.Total_Amount>
				<cfset returnStruct.TotalFilteredSpentDollars = qGetProgramTotalAccrualDataFiltered.Total_Spent_Dollars>
				<cfset returnStruct.TotalFilteredRemainingDollars = qGetProgramTotalAccrualDataFiltered.Total_Remaining_Dollars>
				<cfset returnStruct.TotalFilteredRemainingPercent = qGetProgramTotalAccrualDataFiltered.Total_Remaining_Percent>

				<!--- Queries to populate dropdown data for filtering --->
				<cfset returnStruct.qGetUniqueDeductionAccount = qGetUniqueDeductionAccount>
				<cfset returnStruct.qGetUniquePaymentAccount = qGetUniquePaymentAccount>
				<cfset returnStruct.qGetUniqueGLAccount = qGetUniqueGLAccount>
				<cfset returnStruct.qGetUniqueExternalID = qGetUniqueExternalID>
				<cfset returnStruct.qGetUniqueComponentName = qGetUniqueComponentName>
				<cfset returnStruct.qGetUniqueContractNumber = qGetUniqueContractNumber>
				<cfset returnStruct.qGetUniqueShipTo = qGetUniqueShipTo>
			<cfreturn returnStruct />
		</cffunction>

		<cffunction name="getProgramAccrualDistributorItemData" output="false" returntype="struct">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="contractMainID" required="true" />
			<cfargument name="distributorComponentList" required="true" type="string" />
			<cfargument name="listOfWords" type="string" required="false" default="" />
			<!--- "column_sequence_number" default has been set below for the Excel report.
			Default of "1" below is "Ship_To_Name", the second column on the grid --->
			<cfargument name="column_sequence_number" type="string" required="false" default="1"/>
			<cfargument name="sort_order" type="string" required="false" default="asc" />
			<cfargument name="startRow" type="numeric" required="false" default="0" />
			<cfargument name="endRow" type="numeric" required="false" default="0" />
			<cfargument name="deductionAccount" required="false" type="string" default="" />
			<cfargument name="paymentAccount" required="false" type="string" default="" />
			<cfargument name="glAccount" required="false" type="string" default="" />
			<cfargument name="externalID" required="false" type="string" default="" />
			<cfargument name="componentName" required="false" type="string" default="" />
			<cfargument name="rateUOM" required="false" type="string" default="" />
			<cfargument name="productAttribute" required="false" type="string" default="" />
			<cfargument name="selectedProductAttribute" required="false" type="string" default="0" />
			<cfargument name="plannerID" required="false" default="0" />
			<cfargument name="contractNumberFilter" required="false" type="string" default="" />
			<cfargument name="shipTo" required="false" type="string" default="" />
			<cfargument name="shipToText" required="false" type="string" default="" />
			<cfargument name="item" required="false" type="string" default="" />
			<cfargument name="itemDescription" required="false" type="string" default="" />

			<cfset var returnStruct = StructNew()>
			<cfset var FilterDataStruct = StructNew()>

			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
			<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
			<!---
				77724: Payment History Accrual detail data does not show products
				The FORM.Product_Group_Level_ID is Null as all the Group level records in the Product_Group_Level table
				were set to active = 0. So the function arugment was throwing an error as the value was null. In earlier WR
				the product_group_Level_id was defaulted to 12(Type_Code) using a one time script. So if the product_group_level_ID
				is null, the below code will set it to 12 and also will not pass the active =1 flag.
			--->
			<cfif ((arguments.selectedProductAttribute EQ '' or arguments.selectedProductAttribute EQ '0' or arguments.selectedProductAttribute EQ 'null') OR NOT isDefined('arguments.selectedProductAttribute'))>
				<cfset arguments.selectedProductAttribute = '12' />
				<cfset qProductAttribute = ProductGroupAttributeManager.getProductGroupAttributes(groupLevelId=arguments.selectedProductAttribute,includePG=0)><!--- active=1, --->
			<cfelse>
				<cfset qProductAttribute = ProductGroupAttributeManager.getProductGroupAttributes(groupLevelId=arguments.selectedProductAttribute,active=1,includePG=0)>
			</cfif>
			<cfset getDeductionAccountExist = getDeductionAccountExist(arguments.contractNumber, arguments.contractMainID)>

			<!--- DO NOT USE CFQUERYPARAM ON THIS FUNCTION, AS WE NEED TO ACCESS A TEMP TABLE ACROSS MULTIPLE QUERIES.
			TEMP TABLE WILL NOT BE AVAILABLE TO ANOTHER QUERY, IF WE USE CFQUERYPARAM.
			--->
			<cfquery name="delTmpTblProgramAccrualDistributorItemData" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblProgramInitialAccrualDistributorItemData') IS NOT NULL
			DROP TABLE ##tmpTblProgramInitialAccrualDistributorItemData

			IF OBJECT_ID('tempdb..##tmpTblProgramAllAccrualDistributorItemData') IS NOT NULL
			DROP TABLE ##tmpTblProgramAllAccrualDistributorItemData

			IF OBJECT_ID('tempdb..##tmpTblProgramAllAccrualDistributorItemDataWithFilter') IS NOT NULL
			DROP TABLE ##tmpTblProgramAllAccrualDistributorItemDataWithFilter

			IF OBJECT_ID('tempdb..##DistCompList') IS NOT NULL
			DROP TABLE ##DistCompList

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
			</cfquery>

			<cfset getcontractIds('#arguments.contractnumber#', arguments.plannerID)>

			<cfset var lAccrualExcludeDocumentTypes =  appSettings.get_Setting('Accrual_Exclude_Document_Types') />

			<!--- This "rowIDInt" field creates a incremental integer. Since we only want to retrieve selected records using a range, eg: 100-200, 300-400 etc,
			"rowIDInt" can be used for that purpose. Please leave this column as the first column.
			So that "rowIDInt" increments integers properly, the second column in the below query should not have any blank or null value.
			--->
			<cfquery name="qGetProgramAccrualDistributorItemData" datasource="#application.datasource#">
			CREATE TABLE ##tmp_plnrAcc_pgm
			(
				Contract_Main_ID int,
				Contract_Number varchar(20)
			)
			CREATE TABLE ##tmp_plnrAcc_prod
			(
				Product_ID uniqueidentifier
			)
			CREATE TABLE ##tmp_plnrAcc_dist
			(
				Distributor_ID uniqueidentifier
			)
			<cfif val(arguments.plannerID)>
				INSERT INTO ##tmp_plnrAcc_pgm (Contract_Main_ID, Contract_Number)
				SELECT	Contract_Main_ID, Contract_Number
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter bit

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				INSERT INTO ##tmp_plnrAcc_prod (Product_ID)
				SELECT	Product_ID
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				insert into ##tmp_plnrAcc_dist (Distributor_ID)
				select	DISTINCT Customer_ID
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

			<!--- Rebate data from the "rebate acrual" table --->
			SELECT *
			INTO ##tmpTblProgramInitialAccrualDistributorItemData
			FROM GLA_Combined gla_rebate
			<cfif val(arguments.plannerID)>
				WHERE 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
				AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
				AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
				AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
				AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
			<cfelse>
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE gla_rebate.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE gla_rebate.contract_number = '#arguments.contractnumber#'
				</cfif>
			</cfif>

			<!---Tim Ford WR D82535 - Accrual Records Overview in FORGE
				If the Accrual_Exclude_Document_Types setting is FS then we exclude records where Document_Type = FS
			--->
			<cfif ListFindNoCase(lAccrualExcludeDocumentTypes, 'FS') or ListFindNoCase(lAccrualExcludeDocumentTypes, 'FC')>
				AND ISNULL(gla_rebate.Document_Type,'') NOT IN (#ListQualify(lAccrualExcludeDocumentTypes,"'")#)
			</cfif>

			<!--- Total Accrual Data --->
			<!--- Complete data set (SUMMED) --->
			SELECT 	RIGHT(gla.Contract_Number, 7) as contract_number, ROUND(SUM(gla.Cases_Invoiced), 0) As Cases_Invoiced, SUM(gla.Amount) As Amount, gla.Rate,
					gla.Deduction_Account, gla.Payment_Account, gla.Distributor_ID as BSA_Foodservice_Customers_ID,
					gla.GL_Account_Name as GL_Account_Desc,
					gla.Ship_To, gla.Ship_To_Name, gla.Item, gla.Item_Description, gla.Product_ID,
					<!---REPLACE(gla.Product_Group,',','') As SelectedProductAttribute,  --->
					CAST('' as varchar(100)) as SelectedProductAttribute,
					gla.External_ID, gla.Component_Name, gla.Rate_UOM_Desc As Rate_UOM
			INTO ##tmpTblProgramAllAccrualDistributorItemData
			FROM ##tmpTblProgramInitialAccrualDistributorItemData gla
			GROUP BY gla.Contract_Number, gla.Rate,gla.Deduction_Account, gla.Payment_Account, gla.Distributor_ID,
			gla.GL_Account_Name,
			gla.Ship_To, gla.Ship_To_Name, gla.Item, gla.Item_Description, gla.Product_ID,
			gla.External_ID, gla.Component_Name, gla.Rate_UOM_Desc

			UPDATE	t
			SET		SelectedProductAttribute = REPLACE(attr.#qProductAttribute.Product_Group_Attribute_Name_Field#,',','')
			FROM	##tmpTblProgramAllAccrualDistributorItemData t
			INNER JOIN BSA_Foodservice_Items_Master bfim
			ON	bfim.BSA_Foodservice_Items_Master_ID = t.Product_ID
			LEFT JOIN #qProductAttribute.Product_Group_Attribute_Table# as attr
			ON	attr.#qProductAttribute.Product_Group_Attribute_ID_Field# = bfim.#qProductAttribute.Product_Group_Attribute_Master_ID_Field#

			<!--- get filtered dataset --->
			SELECT identity(INT) As rowIDInt, *
			INTO ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			FROM  ##tmpTblProgramAllAccrualDistributorItemData
			WHERE 1 = 1
				<!--- keyword filter --->
				<cfif arguments.listOfWords neq "">
				AND
				(
				Ship_To like '%#arguments.listOfWords#%'
				OR
				Ship_To_Name like '%#arguments.listOfWords#%'
				OR
				Item like '%#arguments.listOfWords#%'
				OR
				Item_Description like '%#arguments.listOfWords#%'
				)
				</cfif>

				<!--- dropdown filters --->
				<cfif arguments.rateUOM neq "">
				AND Rate_UOM = '#arguments.rateUOM#'
				</cfif>

				<cfif arguments.deductionAccount neq "">
				AND Deduction_Account = '#arguments.deductionAccount#'
				</cfif>

				<cfif arguments.paymentAccount neq "">
				AND Payment_Account = '#arguments.paymentAccount#'
				</cfif>

				<cfif arguments.externalID neq "">
				AND External_ID = '#arguments.externalID#'
				</cfif>

				<cfif arguments.componentName neq "">
				AND Component_Name = '#arguments.componentName#'
				</cfif>

				<cfif arguments.productAttribute neq "">
				AND SelectedProductAttribute = '#arguments.productAttribute#'
				</cfif>

				<cfif arguments.glAccount neq "">
				AND GL_Account_Desc = '#arguments.glAccount#'
				</cfif>

				<cfif arguments.contractNumberFilter neq "">
				AND contract_number = '#arguments.contractNumberFilter#'
				</cfif>

				<cfif arguments.shipTo neq "">
				AND Ship_To = '#arguments.shipTo#'
				</cfif>

				<cfif arguments.shipToText neq "">
				AND Ship_To_Name like '%#arguments.shipToText#%'
				</cfif>

				<cfif arguments.item neq "">
				AND Item = '#arguments.item#'
				</cfif>

				<cfif arguments.itemDescription neq "">
				AND Item_Description = '#arguments.itemDescription#'
				</cfif>



			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<cfif getDeductionAccountExist eq 1>
				<cfif val(arguments.plannerID)>
					<cfswitch expression="#arguments.column_sequence_number#">
						<cfcase value=0>ORDER BY Contract_Number</cfcase>
						<cfcase value=1>ORDER BY Ship_To</cfcase>
						<cfcase value=2>ORDER BY Ship_To_Name</cfcase>
						<cfcase value=3>ORDER BY Item</cfcase>
						<cfcase value=4>ORDER BY Item_Description</cfcase>
						<cfcase value=9>ORDER BY Cases_Invoiced</cfcase>
						<cfcase value=10>ORDER BY Amount</cfcase>
						<cfcase value=11>ORDER BY Rate</cfcase>
						<cfcase value=13>ORDER BY SelectedProductAttribute</cfcase>
					</cfswitch>
				<cfelse>
					<cfswitch expression="#arguments.column_sequence_number#">
						<cfcase value=0>ORDER BY Ship_To</cfcase>
						<cfcase value=1>ORDER BY Ship_To_Name</cfcase>
						<cfcase value=2>ORDER BY Item</cfcase>
						<cfcase value=3>ORDER BY Item_Description</cfcase>
						<cfcase value=6>ORDER BY Cases_Invoiced</cfcase>
						<cfcase value=7>ORDER BY Amount</cfcase>
						<cfcase value=8>ORDER BY Rate</cfcase>
						<cfcase value=13>ORDER BY SelectedProductAttribute</cfcase>
					</cfswitch>
				</cfif>
			<cfelse>
				<cfif val(arguments.plannerID)>
					<cfswitch expression="#arguments.column_sequence_number#">
						<cfcase value=0>ORDER BY Contract_Number</cfcase>
						<cfcase value=1>ORDER BY Ship_To</cfcase>
						<cfcase value=2>ORDER BY Ship_To_Name</cfcase>
						<cfcase value=3>ORDER BY Item</cfcase>
						<cfcase value=4>ORDER BY Item_Description</cfcase>
						<cfcase value=7>ORDER BY Cases_Invoiced</cfcase>
						<cfcase value=8>ORDER BY Amount</cfcase>
						<cfcase value=9>ORDER BY Rate</cfcase>
						<cfcase value=13>ORDER BY SelectedProductAttribute</cfcase>
					</cfswitch>
				<cfelse>
					<cfswitch expression="#arguments.column_sequence_number#">
						<cfcase value=0>ORDER BY Ship_To</cfcase>
						<cfcase value=1>ORDER BY Ship_To_Name</cfcase>
						<cfcase value=2>ORDER BY Item</cfcase>
						<cfcase value=3>ORDER BY Item_Description</cfcase>
						<cfcase value=8>ORDER BY Cases_Invoiced</cfcase>
						<cfcase value=9>ORDER BY Amount</cfcase>
						<cfcase value=10>ORDER BY Rate</cfcase>
						<cfcase value=13>ORDER BY SelectedProductAttribute</cfcase>
					</cfswitch>
				</cfif>
			</cfif>
			#arguments.sort_order#

			<!--- Total number of records before filter --->
			SELECT count(Ship_To) As recordTotalCount
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<!--- Queries to populate dropdown data for filtering (START) --->
			<cfquery name="qGetUniqueRateUOM" datasource="#application.datasource#">
			SELECT DISTINCT Rate_UOM
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<!--- Queries to populate dropdown data for filtering (START) --->
			<cfquery name="qGetUniqueDeductionAccount" datasource="#application.datasource#">
			SELECT DISTINCT Deduction_Account
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniquePaymentAccount" datasource="#application.datasource#">
			SELECT DISTINCT Payment_Account
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueExternalID" datasource="#application.datasource#">
			SELECT DISTINCT External_ID
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueComponentName" datasource="#application.datasource#">
			SELECT DISTINCT Component_Name
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueGLAccount" datasource="#application.datasource#">
			SELECT DISTINCT GL_Account_Desc
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueProductAttribute" datasource="#application.datasource#">
			SELECT DISTINCT SelectedProductAttribute
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueContractNumber" datasource="#application.datasource#">
				SELECT DISTINCT contract_number
				FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueItem" datasource="#application.datasource#">
				SELECT DISTINCT Item
				FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueItemDescription" datasource="#application.datasource#">
				SELECT DISTINCT Item_Description
				FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>
			<!--- Queries to populate dropdown data for filtering (END) --->

			<cfquery name="qGetProgramAccrualDistributorItemDataFiltered" datasource="#application.datasource#">
			<!--- Total number of records after filter --->
			SELECT count(Ship_To) As recordFilteredCount
			FROM ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			</cfquery>

			<cfquery name="qGetProgramAccrualDistributorItemDataFilteredResults" datasource="#application.datasource#">
			SELECT * FROM ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			<!--- Query usng a range to return what is needed for paging. --->
			<cfif arguments.startRow eq 0>
			WHERE 1 = 1
			<cfelse>
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#
			</cfif>
			Order By rowIDInt
			</cfquery>

			<!--- Get the "Total" for the data --->
			<cfquery name="qGetProgramAccrualTotalDistributorItemDataFiltered" datasource="#application.datasource#">
				SELECT ISNULL(SUM(Cases_Invoiced), 1) As Total_Cases_Invoiced,SUM(Amount) As Total_Amount
				FROM ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			</cfquery>

				<!--- Total records (before filter) --->
				<cfset returnStruct.recordTotal = qGetProgramAccrualDistributorItemData.recordTotalCount>

				<!--- Filtered records query (after filter) --->
				<cfset returnStruct.filteredResults = qGetProgramAccrualDistributorItemDataFilteredResults>

				<!--- Filtered records (after filter) --->
				<cfset returnStruct.filteredTotal = qGetProgramAccrualDistributorItemDataFiltered.recordFilteredCount>

				<!--- "Total data" variables --->
				<cfset returnStruct.TotalFilteredCasesInvoiced = qGetProgramAccrualTotalDistributorItemDataFiltered.Total_Cases_Invoiced>
				<cfset returnStruct.TotalFilteredAmount = qGetProgramAccrualTotalDistributorItemDataFiltered.Total_Amount>

				<!--- Queries to populate dropdown data for filtering --->
				<cfset returnStruct.qGetUniqueRateUOM = qGetUniqueRateUOM>
				<cfset returnStruct.qGetUniqueDeductionAccount = qGetUniqueDeductionAccount>
				<cfset returnStruct.qGetUniquePaymentAccount = qGetUniquePaymentAccount>
				<cfset returnStruct.qGetUniqueGLAccount = qGetUniqueGLAccount>
				<cfset returnStruct.qGetUniqueExternalID = qGetUniqueExternalID>
				<cfset returnStruct.qGetUniqueComponentName = qGetUniqueComponentName>
				<cfset returnStruct.qGetUniqueProductAttribute = qGetUniqueProductAttribute>
				<cfset returnStruct.qGetUniqueContractNumber = qGetUniqueContractNumber>
				<cfset returnStruct.qGetUniqueItem = qGetUniqueItem>
				<cfset returnStruct.qGetUniqueItemDescription = qGetUniqueItemDescription>


			<cfreturn returnStruct />
		</cffunction>

		<cffunction name="getProgramAccrualDistributorFiscalPeriodData" output="false" returntype="struct">
			<cfargument name="contractNumber" required="true" type="string" />
			<cfargument name="contractMainID" required="true" />
			<cfargument name="distributorComponentList" required="true" type="string" />
			<!--- "column_sequence_number" default has been set below for the Excel report.
			Default of "0" below is "Fiscal_Period", the first column on the grid --->
			<cfargument name="column_sequence_number" type="string" required="false" default="0"/>
			<cfargument name="sort_order" type="string" required="false" default="asc" />
			<cfargument name="startRow" type="numeric" required="false" default="0" />
			<cfargument name="endRow" type="numeric" required="false" default="0" />
			<cfargument name="deductionAccount" required="false" type="string" default="" />
			<cfargument name="paymentAccount" required="false" type="string" default="" />
			<cfargument name="glAccount" required="false" type="string" default="" />
			<cfargument name="externalID" required="false" type="string" default="" />
			<cfargument name="componentName" required="false" type="string" default="" />
			<cfargument name="rateUOM" required="false" type="string" default="" />
			<cfargument name="fiscalPeriod" required="false" type="string" default="" />
			<cfargument name="distributorIdList" required="false" type="string" default="" />
			<cfargument name="plannerID" required="false" default="0" />
			<cfargument name="contractNumberFilter" required="false" type="string" default="" />
			<cfargument name="shipTo" required="false" type="string" default="" />
			<cfargument name="shipToText" required="false" type="string" default="" />

			<cfset var returnStruct = StructNew()>
			<cfset var FilterDataStruct = StructNew()>

			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

			<cfset fiscalStartPeriod = Trim(ListFirst(arguments.fiscalPeriod,"-"))>
			<cfset fiscalEndPeriod = Trim(ListLast(arguments.fiscalPeriod,"-"))>

			<cfset getDeductionAccountExist = getDeductionAccountExist(arguments.contractNumber, arguments.contractMainID)>

			<!--- DO NOT USE CFQUERYPARAM ON THIS FUNCTION, AS WE NEED TO ACCESS A TEMP TABLE ACROSS MULTIPLE QUERIES.
			TEMP TABLE WILL NOT BE AVAILABLE TO ANOTHER QUERY, IF WE USE CFQUERYPARAM.
			--->
			<cfquery name="delTmpTblProgramAccrualDistributorItemData" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblProgramInitialAccrualDistributorItemData') IS NOT NULL
			DROP TABLE ##tmpTblProgramInitialAccrualDistributorItemData

			IF OBJECT_ID('tempdb..##tmpTblProgramAccrualDistributorItemData') IS NOT NULL
			DROP TABLE ##tmpTblProgramAccrualDistributorItemData

			IF OBJECT_ID('tempdb..##tmpTblProgramAllAccrualDistributorItemData') IS NOT NULL
			DROP TABLE ##tmpTblProgramAllAccrualDistributorItemData

			IF OBJECT_ID('tempdb..##tmpTblProgramAllAccrualDistributorItemDataWithFilter') IS NOT NULL
			DROP TABLE ##tmpTblProgramAllAccrualDistributorItemDataWithFilter

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_pgm') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_pgm

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_prod') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_prod

			IF OBJECT_ID('tempdb..##tmp_plnrAcc_dist') IS NOT NULL
			DROP TABLE ##tmp_plnrAcc_dist
			</cfquery>

			<cfset getcontractIds('#arguments.contractnumber#', arguments.plannerID)>

			<cfquery name="qGetProgramAccrualDistributorItemData" datasource="#application.datasource#">


			CREATE TABLE ##tmp_plnrAcc_pgm
			(
				Contract_Main_ID int,
				Contract_Number varchar(20)
			)
			CREATE TABLE ##tmp_plnrAcc_prod
			(
				Product_ID uniqueidentifier
			)
			CREATE TABLE ##tmp_plnrAcc_dist
			(
				Distributor_ID uniqueidentifier
			)
			<cfif val(arguments.plannerID)>
				INSERT INTO ##tmp_plnrAcc_pgm (Contract_Main_ID, Contract_Number)
				SELECT	Contract_Main_ID, Contract_Number
				FROM	GLA_Planner_Accrual_Programs gla
				WHERE	Planner_ID = #val(arguments.plannerID)#

				DECLARE @Planner_Template_ID INT,
						@Planner_Start_Date DATE,
						@Planner_End_Date DATE,
						@Planner_Template_Filter bit

				SELECT	@Planner_Template_ID = p.Planner_Template_ID,
						@Planner_Start_Date = pt.Planner_Start_Date,
						@Planner_End_Date = pt.Planner_End_Date
				FROM	Planners p
				INNER JOIN Planner_Template pt
				ON		pt.Planner_Template_ID = p.Planner_Template_ID
				WHERE	p.Planner_ID = #val(arguments.plannerID)#

				SELECT	TOP 1 @Planner_Template_Filter = 1
				FROM	dbo.Planner_Template_Filters ptf
				WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
				AND		ptf.Allow_Filter = 1
				AND		ptf.PG_Group_Type = 1

				INSERT INTO ##tmp_plnrAcc_prod (Product_ID)
				SELECT	Product_ID
				FROM	GLA_Planner_Template_Products
				WHERE	Planner_Template_ID = @Planner_Template_ID

				-- If planner has individual distributor
				insert into ##tmp_plnrAcc_dist (Distributor_ID)
				select	DISTINCT Customer_ID
				from	Planners p
				where	p.Planner_ID = #val(arguments.plannerID)#
				and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				-- If planner has group distributor
				INSERT INTO ##tmp_plnrAcc_dist (Distributor_ID)
				SELECT DISTINCT Distributor_ID
				FROM   Planner_Customer_Group_Members p
				WHERE  p.Planner_ID = #val(arguments.plannerID)#
			</cfif>

			<!--- Rebate data from the "rebate acrual" table --->
			SELECT gla_rebate.contract_number, Discount_Type_ID As Discount_Type,ROUND(gla_rebate.Cases_Invoiced,0) As Cases_Invoiced, gla_rebate.Amount,
				gla_rebate.Deduction_Account,gla_rebate.Payment_Account, GL_Account_Name as GL_Account_Desc,
				Distributor_ID, Ship_To, Ship_To_Name,
				Component_Name_ID, Component_Name, External_ID, gla_rebate.Unit_Of_Measure_ID,
				CONVERT(char(10), Fiscal_Start, 101) + ' - ' + CONVERT(char(10), Fiscal_End, 101) As Fiscal_Period, 0 As Outside_Program_Dates, CAST(null As datetime) As Adjustment_Created_Date

			INTO ##tmpTblProgramInitialAccrualDistributorItemData
			FROM GLA_Combined gla_rebate
			<cfif val(arguments.plannerID)>
				WHERE 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_pgm p WHERE p.Contract_Main_ID = gla_rebate.Contract_Main_ID)
				AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_plnrAcc_prod prod WHERE prod.Product_ID = gla_rebate.Product_ID))
				AND 	EXISTS (SELECT 1 FROM ##tmp_plnrAcc_dist prod WHERE prod.Distributor_ID = gla_rebate.Distributor_ID)
				AND		gla_rebate.Fiscal_End >= @Planner_Start_Date
				AND		gla_rebate.Fiscal_Start <= @Planner_End_Date
			<cfelse>
				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE gla_rebate.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE gla_rebate.contract_number = '#arguments.contractnumber#'
				</cfif>
			</cfif>


			<!--- Total Accrual Data --->
			SELECT gla.Discount_Type, SUM(gla.Cases_Invoiced) As Cases_Invoiced, SUM(gla.Amount) As Amount,
					gla.Deduction_Account, gla.Payment_Account, gla.GL_Account_Desc<cfif arguments.distributorIdList neq "" AND arguments.distributorIdList neq "null">, gla.Distributor_ID as BSA_Foodservice_Customers_ID, Ship_To, Ship_To_Name </cfif>,
					gla.Component_Name_ID, Component_Name, External_ID,gla.Unit_Of_Measure_ID, 'CS' as Rate_UOM,gla.Fiscal_Period,gla.Outside_Program_Dates,gla.Adjustment_Created_Date

			INTO ##tmpTblProgramAccrualDistributorItemData
			FROM ##tmpTblProgramInitialAccrualDistributorItemData gla

			GROUP BY gla.Discount_Type, gla.Deduction_Account, gla.Payment_Account,gla.GL_Account_Desc
			<cfif arguments.distributorIdList neq "" AND arguments.distributorIdList neq "null">, gla.Distributor_ID, Ship_To, Ship_To_Name </cfif>,
			gla.Component_Name_ID, Component_Name, External_ID,gla.Unit_Of_Measure_ID, gla.Fiscal_Period,gla.Outside_Program_Dates,gla.Adjustment_Created_Date

			<!--- Complete data set (SUMMED) --->
			SELECT		<cfif arguments.distributorIdList neq "" AND arguments.distributorIdList neq "null">
						Ship_To, Ship_To_Name, BSA_Foodservice_Customers_ID,
						</cfif>
						SUM(Cases_Invoiced) As Cases_Invoiced, SUM(Amount) As Amount,
						CAST(CASE WHEN SUM(Cases_Invoiced) = 0 THEN 0 ELSE SUM(Amount) / SUM(Cases_Invoiced) END as decimal(20, 4)) As Rate, 'CS' as Rate_UOM,
						Fiscal_Period,Outside_Program_Dates,Adjustment_Created_Date

			INTO ##tmpTblProgramAllAccrualDistributorItemData
			FROM ##tmpTblProgramAccrualDistributorItemData
			WHERE 1 = 1
				<!--- There are no keyword filters --->

				<!--- dropdown filters --->
                <!---
				<cfif arguments.rateUOM neq "">
				AND Rate_UOM = '#arguments.rateUOM#'
				</cfif>
                --->

				<cfif arguments.deductionAccount neq "">
				AND Deduction_Account = '#arguments.deductionAccount#'
				</cfif>

				<cfif arguments.paymentAccount neq "">
				AND Payment_Account = '#arguments.paymentAccount#'
				</cfif>

				<cfif arguments.externalID neq "">
				AND External_ID = '#arguments.externalID#'
				</cfif>

				<cfif arguments.componentName neq "">
				AND Component_Name = '#arguments.componentName#'
				</cfif>

				<cfif arguments.glAccount neq "">
				AND GL_Account_Desc = '#arguments.glAccount#'
				</cfif>

				<cfif arguments.fiscalPeriod neq "">
				AND trim(LEFT(fiscal_period,CHARINDEX('-',fiscal_period) -1)) = CONVERT(char(10),#createodbcdate(fiscalStartPeriod)#,101)
				AND trim(RIGHT(fiscal_period,CHARINDEX('-',fiscal_period) -1)) = CONVERT(char(10),#createodbcdate(fiscalEndPeriod)#,101)
				</cfif>

				<cfif arguments.distributorIdList neq "" AND arguments.distributorIdList neq "null">
				AND BSA_Foodservice_Customers_ID IN (#ListQualify(arguments.distributorIdList, "'", ",")#)
				</cfif>
			GROUP BY
			<cfif arguments.distributorIdList neq "" AND arguments.distributorIdList neq "null">
			Ship_To,Ship_To_Name,BSA_Foodservice_Customers_ID,
			</cfif>
			GL_Account_Desc,Fiscal_Period,Outside_Program_Dates,Adjustment_Created_Date

			<!--- get filtered dataset --->
			<!--- This "rowIDInt" field creates a incremental integer. Since we only want to retrieve selected records using a range, eg: 100-200, 300-400 etc,
			"rowIDInt" can be used for that purpose. Please leave this column as the first column.
			So that "rowIDInt" increments integers properly, the second column in the below query should not have any blank or null value.
			--->
			SELECT identity(INT) As rowIDInt, *
			INTO ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			FROM  ##tmpTblProgramAllAccrualDistributorItemData
			<!--- Ordering here is important. This way we can assign correct "rowIDInt" values, which can then be used for getting correct records when paging. --->
			<!--- If "Deduction Acct" and "Distributor" and "Distributor Name" columns exist on the datagrid --->
			<cfswitch expression="#arguments.column_sequence_number#">
					 <cfcase value=0>ORDER BY Fiscal_Period</cfcase>
					 <cfcase value=1>ORDER BY Cases_Invoiced</cfcase>
					 <cfcase value=2>ORDER BY Amount</cfcase>
					 <cfcase value=3>ORDER BY Rate</cfcase>
				</cfswitch>
			#arguments.sort_order#

			<!--- Total number of records before filter --->
			SELECT count(Rate) As recordTotalCount
			FROM ##tmpTblProgramAllAccrualDistributorItemData
			</cfquery>

			<!--- Queries to populate dropdown data for filtering (START) --->
			<cfquery name="qGetUniqueRateUOM" datasource="#application.datasource#">
			SELECT DISTINCT Rate_UOM
			FROM ##tmpTblProgramAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueComponentName" datasource="#application.datasource#">
			SELECT DISTINCT Component_Name
			FROM ##tmpTblProgramAccrualDistributorItemData
			</cfquery>

			<cfquery name="qGetUniqueFiscalPeriod" datasource="#application.datasource#">
			SELECT DISTINCT Fiscal_Period
			FROM ##tmpTblProgramAccrualDistributorItemData
			</cfquery>
			<!--- Queries to populate dropdown data for filtering (END) --->

			<cfquery name="qGetProgramAccrualDistributorItemDataFiltered" datasource="#application.datasource#">
			<!--- Total number of records after filter --->
			SELECT count(Rate) As recordFilteredCount
			FROM ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			</cfquery>

			<cfquery name="qGetProgramAccrualDistributorItemDataFilteredResults" datasource="#application.datasource#">
			SELECT * FROM ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			<!--- Query usng a range to return what is needed for paging. --->
			<cfif arguments.startRow eq 0>
			WHERE 1 = 1
			<cfelse>
			WHERE rowIDInt >= #arguments.startRow#
			AND rowIDInt <= #arguments.endRow#
			</cfif>
			Order By rowIDInt
			</cfquery>

			<!--- Get the "Total" for the data --->
			<cfquery name="qGetProgramAccrualTotalDistributorItemDataFiltered" datasource="#application.datasource#">
				SELECT CASE
						WHEN ISNULL(SUM(Cases_Invoiced), 1) = 0.00 then 1
						ELSE  ISNULL(SUM(Cases_Invoiced), 1)
						END As Total_Cases_Invoiced,SUM(Amount) As Total_Amount,SUM(Amount) As Total_Amount
				FROM ##tmpTblProgramAllAccrualDistributorItemDataWithFilter
			</cfquery>

			<!--- Total records (before filter) --->
			<cfset returnStruct.recordTotal = qGetProgramAccrualDistributorItemData.recordTotalCount>

			<!--- Filtered records query (after filter) --->
			<cfset returnStruct.filteredResults = qGetProgramAccrualDistributorItemDataFilteredResults>

			<!--- Filtered records (after filter) --->
			<cfset returnStruct.filteredTotal = qGetProgramAccrualDistributorItemDataFiltered.recordFilteredCount>

			<!--- "Total data" variables --->
			<cfset returnStruct.TotalFilteredCasesInvoiced = qGetProgramAccrualTotalDistributorItemDataFiltered.Total_Cases_Invoiced>
			<cfset returnStruct.TotalFilteredAmount = qGetProgramAccrualTotalDistributorItemDataFiltered.Total_Amount>

			<!--- Queries to populate dropdown data for filtering --->
			<cfset returnStruct.qGetUniqueRateUOM = qGetUniqueRateUOM>
			<cfset returnStruct.qGetUniqueComponentName = qGetUniqueComponentName>
			<cfset returnStruct.qGetUniqueFiscalPeriod = qGetUniqueFiscalPeriod>

			<cfreturn returnStruct />
		</cffunction>


</cfcomponent>