<!---
	FILE:
	FILENAME: 	components/programs/program.cfc
	CREATED: 		? / ? / ? = ???
	EDITED:			03/18/2008 - RBL

--->

<cfcomponent>
	<cfset appSettings = application.appSettingsGet />
	<CFQUERY NAME="qGetContractInfo" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SELECT	*,
				dbo.Contract_Main_Aux_Data.*
		FROM	dbo.Contract_Main INNER JOIN
				dbo.Contract_Main_Aux_Data ON dbo.Contract_Main.Contract_Main_ID = dbo.Contract_Main_Aux_Data.Contract_Main_ID
		WHERE 	0<>0
	</CFQUERY>

	<cfloop index="index" list="#qGetContractInfo.columnList#">
		<cfset "this.#index#" = "" />
	</cfloop>

	<cffunction name="new" output="false">

		<cfargument name="title" type="string" required="false" default="">
    <cfargument name="notes" type="string" required="false" default="">
		<cfargument name="startDate" type="string" required="false" default="">
		<cfargument name="endDate" type="string" required="false" default="">
		<cfargument name="qty" type="string" required="false" default="">
		<cfargument name="uom" type="string" required="false" default="">
		<cfargument name="dailyVol" type="string" required="false" default="">
		<cfargument name="forecastId" type="string" required="false" default="">

    <cfset this.Contract_Title = arguments.title>
		<cfset this.Notes = arguments.notes>
		<cfset this.CONTRACT_START_DATE = arguments.startDate>
		<cfset this.CONTRACT_END_DATE = arguments.endDate>
		<cfset this.CONTRACT_QUANTITY = arguments.qty>
		<cfset this.CONTRACT_QUANTITY_UOM_IDX = arguments.uom>
		<cfset this.CONTRACT_DAILY_VOLUME = arguments.dailyVol />
		<cfset this.FORECAST_ID = arguments.forecastId />

  	</cffunction>

	<cffunction name="getDiscountTypes" output="false" returntype="query">

		<cfargument name="programId" required="false" default="" />

		<cfquery name="qGetDiscountTypes" datasource="#application.datasource#">
			SELECT 	Distinct Contract_Products.Product_Type_ID AS Product_Type_ID, Contract_Products.Product_Type_ID as Discount_Type_ID,
					Discount_Type.Discount_Type_Desc
			FROM 	Contract_Products
					INNER JOIN Discount_Type
					ON
					Discount_Type.Discount_Type_ID = Contract_Products.Product_Type_ID
					AND
					Discount_Type.Deleted = 0
			WHERE  	Contract_Products.Contract_Main_ID = #arguments.programId#
					AND
					Contract_Products.deleted = 0

			UNION

			SELECT TOP 1 3 AS Product_Type_ID, 3 as Discount_Type_ID,
					Discount_Type.Discount_Type_Desc
			FROM	Program_Lump_Sums

			INNER JOIN Discount_Type
			ON		Discount_Type.Discount_Type_ID = 3

			WHERE	Program_Lump_Sums.Deleted = 0
			AND		Program_Lump_Sums.Program_ID = #arguments.programId#
		</cfquery>

		<cfreturn qGetDiscountTypes />

	</cffunction>

	<cffunction name="getStatusDesc" output="false" returntype="string">

		<cfargument name="statusId" required="false" default="" />

		<cfset statusDesc = "">

		<cfset useLakebaseForqGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_status_types")>
<cfif useLakebaseForqGetStatus>
	<cftry>
		<cfset qGetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_status_types", {
				"contract_status_type_id" = "eq.#arguments.statusId#",
				"select" = "contract_status_type_desc"
			}), "contract_status_type_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetStatus>
<cfquery name="qGetStatus" datasource="#application.datasource#">
			SELECT 	Contract_Status_Type_Desc
			FROM 	Contract_Status_Types
			WHERE
					Contract_Status_Type_ID = #arguments.statusId#
		</cfquery>
</cfif>

		<cfloop query="qGetStatus">
			<cfset statusDesc = Contract_Status_Type_Desc>
		</cfloop>

		<cfreturn statusDesc />

	</cffunction>

	<cffunction name="getProgramInfo" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="calculateTimeZoneDiff" required="false" default="0" />
		<cfargument name="fromBillback" type="numeric" required="false" default="0" />
		<cfargument name="fromProgramLetters" type="numeric" required="false" default="0" />

		<cfscript>
			variables.settingsService = createObject("component","mvc.Models.SettingsService");
			variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		</cfscript>

		<!--- Deduct time difference between UTC and EST from the localtimezone passed to flex. This will give us the difference between
		      localtimezone and EST (in minutes)
		--->
		<cfset DiffLocalTimeZoneAndEST = variables.settingsService.DiffLocalTimeZoneAndEST()>
		<cfset useDST = 0>

		<cfif IsDefined("request.AccessStructure.useDayLightSavingsTime")>
			<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement below. --->
			<cfset useDST = int(request.AccessStructure.useDayLightSavingsTime)>
		</cfif>

		<!------ Get program Info ----->

		<cfquery name="qDropEffDates" datasource="#application.datasource#">
		if object_id('tempdb..##tmp_Effective_Dates_1') is not null
		drop table ##tmp_Effective_Dates_1
		</cfquery>

		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

			DECLARE @DateWithTimeZoneDiff int,
			@useDayLightSavingsTime bit

			SET @DateWithTimeZoneDiff = #DiffLocalTimeZoneAndEST#
			SET @useDayLightSavingsTime = #useDST#

			Create  table ##tmp_Effective_Dates_1
			(
			  Contract_Number varchar(50) not null,
			  Effective_Start_Date datetime,
			  Effective_End_Date datetime
			)

			<!--- Dev Note:38050 (Milan) - Get the minimum "Effective_Start_Date" and maximum "Effective_End_Date" per program (contract_number).
			Note: We need this logic for the following reason:
			When we do a price increase for a client, the affected programs get revised and the new rates are valid for the
			new revision with the start and/or end date of the revision changing based on the date when the price change needs
			to be effective. By doing this, we only show the start and end dates for the new revision on the program.
			By looking at the dates, the users do not know what is the complete date span of the program. The effective dates
			have the actual date span, provided we get the minimum effective start date and maximum effective end date. This
			way the users will see the complete start date and end date for a program and will not be revision dependant.
			On the program summary, we show show both - version dates and delivery dates.
			--->
			<cfif variables.appSettings.getProgram_search_dates() and arguments.fromProgramLetters eq 1>
			INSERT INTO ##tmp_Effective_Dates_1(Contract_Number,Effective_Start_Date,Effective_End_Date)
			SELECT Contract_Main.Contract_Number, MIN(Contract_Main.Effective_Start_Date) As Effective_Start_Date,
			MAX(Contract_Main.Effective_End_Date) As Effective_End_Date
			FROM Contract_Main
			WHERE Contract_Main.Approved = 1
			AND Contract_Main.effective_start_date IS NOT NULL
			AND Contract_Main.effective_end_Date IS NOT NULL
			GROUP BY Contract_Main.Contract_Number
			</cfif>

			SELECT	Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, Contract_Main.Contract_Title,
					<!--- Here the request is for getting the dates with the timezone offset. This will happen when the request is from flex and the
					dates being returned to flex are in "date" datatype. If the dates are being returned in string datatype or if the request
					is not from flex, then timezone offset is not needed.
					--->
					<cfif arguments.calculateTimeZoneDiff eq 1 AND arguments.fromBillback EQ 0>
					dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Contract_Start_Date,
					dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Contract_End_Date,
					<cfelseif arguments.calculateTimeZoneDiff eq 1 AND arguments.fromBillback EQ 1>
						dbo.get_TimeZoneOffset_Date((select MIN(cm.Effective_Start_Date) from Contract_Main cm where cm.Contract_Number = Contract_Main.Contract_Number and cm.Approved = 1 and cm.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as Contract_Start_Date,
						dbo.get_TimeZoneOffset_Date((select MAX(cm.Effective_End_Date) from Contract_Main cm where cm.Contract_Number = Contract_Main.Contract_Number and cm.Approved = 1 and cm.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as Contract_End_Date,
					<cfelse>
					IsNull(##tmp_Effective_Dates_1.Effective_Start_Date,Contract_Main.Contract_Start_Date) As Contract_Start_Date, IsNull(##tmp_Effective_Dates_1.Effective_End_Date,Contract_Main.Contract_End_Date) As Contract_End_Date,
					</cfif>
					dbo.get_TimeZoneOffset_Date((select MIN(Effective_Start_Date) from Contract_Main cm where cm.Contract_Number = Contract_Main.Contract_Number and cm.Approved = 1 and cm.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as EffectiveStartDate,
					dbo.get_TimeZoneOffset_Date((select MAX(Effective_End_Date) from Contract_Main cm where cm.Contract_Number = Contract_Main.Contract_Number and cm.Approved = 1 and cm.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as EffectiveEndDate,
					Convert(varchar,dbo.get_TimeZoneOffset_Date(Contract_Main.Price_protection_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1),101) As Price_protection_Date,
					Contract_Main.Fiscal_Year,
					Contract_Main.Contract_Reference_Number,
					Contract_Main.Contract_Quantity, Contract_Main.Contract_Quantity_UOM_IDX,
					Contract_Main.Contract_Status_Type_IDX,
					Contract_Main.programtype_id,
					Contract_Main.Responsible_User_ID,
					Contract_Main.Approved_By_User_ID, Contract_Main.Approval_Date,
					Contract_Main.Contract_Is_Locked, Contract_Main.Contract_Locked_By_User_ID,
					ISNULL(Contract_Main_Aux_Data.Program_Spend, 0) as Program_Spend,
					Program_Control_Panel_Options.Template_Parent_ID,
					Program_Control_Panel_Options.First_Parent_ID,
					Program_Control_Panel_Options.Created_Type,
					Program_Control_Panel_Options.Generic_Type,
					Contract_Main.Approved,
					Contract_Main.Is_A_Revision,
					Contract_Main.Revision_Version,<!--- D29497: Automated Letters Subject Change Added this column--->
					Contract_Main.Creating_User_Position_ID,
					Contract_Main_Aux_Data.Simple_Budget_ID,
					Contract_Main_Aux_Data.Freight_Component_Type,
					Program_Control_Panel_Options.Freight_Approval_Required,
					Contract_Main_Aux_Data.Freight_Approved,
					Contract_Main_Aux_Data.Freight_Approved_By,
					Contract_Main_Aux_Data.Freight_Approved_Date,
					Contract_Main_Aux_Data.Freight_Contract_Start_Date,
					Contract_Main_Aux_Data.Freight_Contract_End_Date,
					Contract_Main_Aux_Data.Fuel_Surcharge_ON,
					Contract_Main_Aux_Data.Fuel_Surcharge_Amount,
					Contract_Main_Aux_Data.Fuel_Surcharge_Expiration_Date,
					<!--- BJF: 13044 add data for pullbacks --->
					Contract_Main.Applied_Pullbacks,
					Program_Control_Panel_Options.Pullbacks_On,
					Program_Control_Panel_Options.Pullback_Template_Type,
					Program_Control_Panel_Options.is_pullback_corporate_deal,
					Program_Control_Panel_Options.pullback_from_corporate,
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID,
					CASE WHEN Program_Control_Panel_Options.Fixed_Type = 0 THEN
						'Guaranteed'
					ELSE
						'Variable'
					END
						As Fixed_Type,
					Contract_Main_Aux_Data.Freight_Notes,Contract_Main.Notes,
					Program_Control_Panel_Options.ByPass_Margin_Evaluation,
					Program_Control_Panel_Options.EZButton_On,
					Program_Control_Panel_Options.EzButton_Auto_Approve_On,
					Program_Control_Panel_Options.Freight_Program,
					Contract_Main_Aux_Data.Freight_Component_Type,
					Program_Control_Panel_Options.Email_Letters_On_Approval, <!---25704--->
					Program_Control_Panel_Options.Generate_Letters_On_Approval,
					Program_Control_Panel_Options.Discount_Fixed_Prices,
					Program_Control_Panel_Options.Discount_Rebates,
					Program_Control_Panel_Options.Discount_Lump_Sums,
					Program_Control_Panel_Options.Program_Qualifications_Doc_Attach_Req,
					Program_Control_Panel_Options.Program_Qualifications_Doc_Msg,
					Program_Control_Panel_Options.Manual_Selection_Of_Approvers
					<!--- D50326 --->
					,Program_Control_Panel_Options.Manual_Committed_Equal_Actual
					,Contract_Main_Aux_Data.Set_Committed_Equal_Actual
					,Contract_Main_Aux_Data.Set_Committed_Actual_Updated_By
					,Contract_Main_Aux_Data.Set_Committed_Actual_Updated_Date
					 <!--- D50326 --->
					 ,Program_Control_Panel_Options.BB_Dont_Count_Volume_Select
					 ,Contract_Main.Revision_of_Contract_Main_ID
					 ,Contract_Main_Aux_Data.Program_Approved_Date
			FROM	Contract_Main
			INNER JOIN	Contract_Main_Aux_Data
			ON 		Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
			INNER JOIN Program_Control_Panel_Options
			ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			LEFT JOIN ##tmp_Effective_Dates_1
			ON ##tmp_Effective_Dates_1.Contract_Number = Contract_Main.Contract_Number

			WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn qGetProgramInfo />

	</cffunction>

	<cffunction name="getDeletedProgramInfo" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />

		<!------ Get program Info ----->

		<cfquery name="qDeletedGetProgramInfo" datasource="#application.datasource#">

			SELECT	Contract_Main_ID, Contract_Number, Contract_Title,
					Contract_Start_Date, Contract_End_Date,
					Contract_Quantity, Contract_Quantity_UOM_IDX,
					Contract_Status_Type_IDX,
					programtype_id,
					Responsible_User_ID
			FROM	Contract_Main
			WHERE	Deleted = 1
			AND 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

		</cfquery>

		<cfreturn qDeletedGetProgramInfo />

	</cffunction>

	<cffunction name="setLockStatus" output="false" returntype="numeric">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="lockBit" required="true" type="numeric" />
		<cfargument name="userId" required="false" type="string" default="" />

		<cfset returnValue = 0>

		<cfif arguments.lockBit>

			<cfset canLock = false>

			<!------ check any other person has locked this program within the session timeout time ----->
			<cfquery name="qCheckLockStatus" datasource="#application.datasource#">

				SELECT	Contract_Is_Locked,
						Contract_Locked_By_User_ID,
						Session_ID,
						(CAST(DateDiff(s, Session_Date_Time_Stamp, GetDate()) AS FLOAT)/(24.00*60.00*60.00)) AS User_Session,
						Session_Expiration_Length
				FROM	Contract_Main
						LEFT JOIN Session_Tracker
						ON
						Session_Tracker.Session_User_ID = Contract_Main.Contract_Locked_By_User_ID
						INNER JOIN General_Settings
						ON 1=1
				WHERE
						Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
						AND
						Deleted = 0
			</cfquery>

			<cfif qCheckLockStatus.recordCount>

				<cfif
						qCheckLockStatus.Contract_Is_Locked EQ 0
						OR
						(
							qCheckLockStatus.Contract_Is_Locked EQ 1
							AND
							(
								qCheckLockStatus.Session_ID EQ ""
								OR
								qCheckLockStatus.User_Session GT qCheckLockStatus.Session_Expiration_Length
								OR
								qCheckLockStatus.Contract_Locked_By_User_ID EQ arguments.userId
							)
						)>

					<cfset canLock = true>

				<cfelse>

					<cfset returnValue = 3><!------ program is locked by someone else ----->

				</cfif>

			<cfelse>

				<cfset returnValue = 2><!------ program not found ----->

			</cfif>

			<cfif canLock>
				<!------ Unlock other programs locked by this user and lock this program ----->
				<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
					<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#arguments.userId#">
					<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
					<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="1">
					<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="#arguments.programId#">
					<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
					<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
					<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
				</cfstoredproc>

				<cfset returnValue = 1>

			</cfif>

		<cfelse>

			<!------ Un Lock it, if it already locked ----->
			<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#arguments.userId#">
				<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
				<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
				<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
				<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="#arguments.programId#">
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
			</cfstoredproc>

			<cfset returnValue = 1>

		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="deleteProgram" output="true" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="lockedByUserId" required="true" type="string" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="plannerProgram" required="false" type="boolean" default="0" />

		<cfset returnValue = false>

		<cftransaction action="BEGIN" isolation="READ_COMMITTED">

			<cftry>

				<cfquery name="qDeleteProgram" datasource="#application.datasource#">

					SET NOCOUNT ON

					UPDATE	Contract_Main
					SET		Deleted = 1,
								Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
								Deleted_Date = GetDate()
					WHERE
							--Contract_Status_Type_IDX <= 2
							--AND
							Deleted = 0
							AND Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
							AND Contract_Is_Locked = 1
							AND Contract_Locked_By_User_ID = <cfqueryparam value="#arguments.lockedByUserId#" cfsqltype="CF_SQL_VARCHAR">

					SELECT Rows_Count = @@ROWCOUNT
					SET NOCOUNT OFF

				</cfquery>

				<cfif qDeleteProgram.Rows_Count>

					<cfset returnValue = true>

				</cfif>

				<cftransaction action="COMMIT"/>

				<cfcatch>

					<cftransaction action="ROLLBACK"/>
					<cfrethrow>

				</cfcatch>

			</cftry>

		</cftransaction>
                    
        <cfif arguments.plannerProgram>
            <!--- Remove lift from planner volume plan if there are no other programs for those weks/products --->
            <cfstoredproc procedure="Planner_Program_Date_Change_Update_Volume_Plan" datasource="#application.datasource#" returnCode = "yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	value="#arguments.programId#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_date"    	null="yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_date"    	null="yes">
				<cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	value="DELETE">
			</cfstoredproc>
        </cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="approvePullback" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />


		<cfquery NAME="qApprovePullback" datasource="#application.datasource#">
			UPDATE 	Contract_Main_Aux_Data
			Set 	Pullback_Approved_Date = getDate(),
					Pullback_Approved = 1,
					Pullback_Approved_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfquery name="qInsertPullbackApprovalHostory" datasource="#application.datasource#">
			INSERT INTO Program_Pullback_Approval_History (Program_ID, Pullback_Approved_By, Pullback_Approved_Date, Current_Action)
			VALUES (<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
					getDate(),
					'Insert')
		</cfquery>


	</cffunction>

	<cffunction name="deletePullbackApproval" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />

		<cfquery name="qGetPullbackApproval" datasource="#application.datasource#">
			SELECT	Pullback_Approved, Pullback_Approved_Date, Pullback_Approved_By
			FROM	Contract_Main_Aux_Data
			WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfset Pullback_Approved = qGetPullbackApproval.Pullback_Approved />
		<cfset Pullback_Approved_Date = qGetPullbackApproval.Pullback_Approved_Date />
		<cfset Pullback_Approved_By = qGetPullbackApproval.Pullback_Approved_By />

		<cfif Pullback_Approved>
			<cfquery NAME="qDeletePullbackApproval" datasource="#application.datasource#">
				UPDATE 	Contract_Main_Aux_Data
				Set 	Pullback_Approved_Date = NULL,
						Pullback_Approved = 0,
						Pullback_Approved_By = NULL
				WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfquery name="qInsertPullbackApprovalHostory" datasource="#application.datasource#">
				INSERT INTO Program_Pullback_Approval_History (Program_ID, Pullback_Approved_By, Pullback_Approved_Date, Pullback_Approval_Deleted_By, Current_Action)
				VALUES (<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
						<cfqueryparam value="#Pullback_Approved_By#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#Pullback_Approved_Date#" cfsqltype="CF_SQL_DATE">,
						<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
						'Delete')
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="approveProgram" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="Pay_Brokerage" required="true" type="string" />
		<cfargument name="BidRequestStatusOn" required="false" type="numeric" default="1">
		<cfargument name="BidRequestStatusChangePgmStatus" required="false" type="numeric" default="1">
		<cfargument name="approvalDate" required="false" type="date" default="#Now()#">

		<cfscript>
		    var loc  = {};
            var htmk = {};          // huhtamaki private structure
            var bProgramHasLockComps = 0;
        </cfscript>

		<!--- START 87013: Remove duplicates from contracts product table / Anand Rao / 18-May-2021 --->
		<cfstoredproc procedure="CheckFor_Dups_CP_CD" datasource="#application.datasource#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value="#arguments.programId#" null="no">
		</cfstoredproc>
		<!--- END 87013 --->
		<cfset appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init() />

		<cfif arguments.BidRequestStatusOn EQ 0 AND arguments.BidRequestStatusChangePgmStatus EQ 0>
				<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
				<cfset bidReqTemp = bidRequestManager.applyStatus(programId=#arguments.programid#,statusId=2)>
		</cfif>

		<!------ set the special revision flag if applicable ----->
		<cfif appSettings.getProgramSpecialRevisionFlag()>
			<cfset CreateObject("component", "components.programs.Display_Program.revision_settings").setSpecialRevisionFlag(arguments.programId) />
		</cfif>

		<cfquery name="qGetInitialProgramInfo" datasource="#application.datasource#">

			SELECT	Contract_Main.Is_A_Revision, Contract_Main.Revision_Of_Contract_Main_ID, Contract_Main.Contract_Start_Date
			FROM	Contract_Main
			WHERE	Contract_Main.Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

		</cfquery>

		<cfset revisionOfProgramWithOtherRevisions = 0 />
		<cfif qGetInitialProgramInfo.Is_A_Revision>
			<cfset revisionOfProgramWithOtherRevisions = programManager.getParentHasPreviousRevisions(
						parentProgramId = qGetInitialProgramInfo.Revision_Of_Contract_Main_ID,
						currentProgramId = arguments.programId) />
		</cfif>

		<cfif revisionOfProgramWithOtherRevisions>
			<cfquery name="qGetParentProgramInfo" datasource="#application.datasource#">
				SELECT	Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date, ISNULL(Revision_Grand_Parent_ID, Contract_Main_ID) as Revision_Grand_Parent_ID
				FROM	Contract_Main
				WHERE	Contract_Main.Contract_Main_Id = <cfqueryparam value="#qGetInitialProgramInfo.Revision_Of_Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
    	<!--- ngt --->
        <cfscript>
        // Unique handling for Huhtamaki environment:
        if ( application.util.query.get_Setting('Custom_RFP_Process', 0 ) eq 1 ) {
            // refresh tables flag :: true = execute the stored procedure
            htmk.refresh_tables = false;
            htmk.write_dump     = cgi.server_name contains ".stage.";

            htmk.qFixed = queryExecute( "SELECT COUNT(*) AS Rows_Count
                                           FROM PROGRAM_FIXED_COMPONENT pfc
                                          WHERE pfc.Program_Id = #arguments.programId# AND pfc.Deleted = 0", [], { datasource = application.datasource } );

            if (htmk.qFixed.rows_count) {
                htmk.qPriceChanges = queryExecute( "SELECT COUNT(*) AS Rows_Count
                                                      FROM Program_Fixed_Freight_Rates fr
                                                            JOIN Program_Fixed_Price_Product_Data d
                                                                ON fr.Program_ID = d.Program_ID AND fr.Contract_Products_ID = d.Contract_Products_ID
                                                     WHERE fr.Program_ID = #arguments.programId#
                                                            AND fr.Deleted = 0
                                                            AND d.Fixed_Price_Value > 0
                                                            AND fr.FOB_Price <> d.Fixed_Price_Value", [], { datasource = application.datasource } );
                if (htmk.write_dump) {
                    writeDump( output="console", var="[Program ID #arguments.programId#] - htmk.qPriceChanges.rows_count = #htmk.qPriceChanges.rows_count#" );
                }

                // found changed prices
                if (htmk.qPriceChanges.Rows_Count gt 0) {
                    htmk.refresh_tables = true;
                }
                else {
                    // detect other changed items/distributors
                    htmk.qOtherChanges = queryExecute( "SELECT SUM(tmp.rows_count) AS Total_Rows_Count
                                                        FROM (
                                                                SELECT count(*) AS Rows_Count
                                                                  FROM Contract_Products
                                                                 WHERE contract_Main_ID = #arguments.programId#
                                                                        AND Deleted = 0
                                                                        AND Contract_Products_ID NOT IN ( SELECT Contract_Products_ID
                                                                                                            FROM Program_Fixed_Freight_Rates pffr
                                                                                                           WHERE pffr.Deleted = 0 AND pffr.program_ID = #arguments.programId#)
                                                                UNION ALL
                                                                SELECT count(*) AS Rows_Count
                                                                  FROM Program_Fixed_Freight_Rates
                                                                 WHERE program_ID = #arguments.programId#
                                                                        AND Deleted = 0
                                                                        AND Contract_Products_ID NOT IN ( SELECT Contract_Products_ID
                                                                                                            FROM Contract_Products cp
                                                                                                           WHERE cp.Deleted = 0 AND cp.contract_main_id = #arguments.programId#)
                                                                UNION ALL
                                                                SELECT count(*) AS Rows_Count
                                                                  FROM Contract_Distributors cd
                                                                 WHERE contract_Main_ID = #arguments.programId#
                                                                        AND cd.Deleted = 0
                                                                        AND NOT EXISTS ( SELECT 1
                                                                                           FROM Program_Fixed_Freight_Rates fr
                                                                                          WHERE fr.program_ID = cd.Contract_Main_ID
                                                                                                    AND fr.Customer_id = cd.BSA_Foodservice_Customers_ID
                                                                                                    AND fr.Deleted = 0 )
                                                                UNION ALL
                                                                SELECT count(*) AS Rows_Count
                                                                  FROM Program_Fixed_Freight_Rates fr
                                                                 WHERE program_ID = #arguments.programId#
                                                                        AND fr.Deleted = 0
                                                                        AND NOT EXISTS ( SELECT 1
                                                                                           FROM Contract_Distributors cd
                                                                                          WHERE fr.program_ID = cd.Contract_Main_ID
                                                                                                    AND fr.Customer_id = cd.BSA_Foodservice_Customers_ID
                                                                                                    AND cd.Deleted = 0 )
                                                            ) AS tmp
                                                ", [], {datasource = application.datasource } );
                    htmk.refresh_tables = htmk.qOtherChanges.Total_Rows_Count gt 0;
                    if (htmk.write_dump) {
                        writeDump( output="console", var="[Program ID #arguments.programId#] - htmk.qOtherChanges.Total_Rows_Count = #htmk.qOtherChanges.Total_Rows_Count#" );
                    }
                }

                if (htmk.write_dump) {
                    writeDump( output="console", var="[Program ID #arguments.programId#] - htmk.refresh_tables = #htmk.refresh_tables#" );
                }

                // found changed prices/items/distributors - refresh tables
                if (htmk.refresh_tables) {
                    if (htmk.write_dump) {
                        writeDump( output="console", var="[Program ID #arguments.programId#] - Executing Populate_Program_Fixed_Freight_Rates_RFP" );
                    }
                    queryExecute( "EXEC Populate_Program_Fixed_Freight_Rates_RFP #arguments.programId#", [], { datasource = application.datasource } );
                }
            }
        }
        </cfscript>


		<cfquery NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE 	Contract_Main
			Set 	Approval_Date = <cfqueryparam value="#arguments.approvalDate#" cfsqltype="cf_sql_timestamp">,
					Approved = 1,
					Approved_By_User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
					<CFIF arguments.Pay_Brokerage NEQ "EMPTY">
					Pay_Brokerage = <cfqueryparam value="#arguments.Pay_Brokerage#" cfsqltype="CF_SQL_VARCHAR">,
					</CFIF>
					<cfif revisionOfProgramWithOtherRevisions>
					<!--- If this version is a revision of a parent program with other revision we will not allow users to chnage dates --->
					Contract_Start_Date = <cfqueryparam value="#qGetParentProgramInfo.Contract_Start_Date#" cfsqltype="cf_sql_date">,
					Contract_End_Date = <cfqueryparam value="#qGetParentProgramInfo.Contract_End_Date#" cfsqltype="cf_sql_date">,
					Parent_Has_Previous_Revision = 1,
					Revision_Grand_Parent_ID = <cfqueryparam value="#qGetParentProgramInfo.Revision_Grand_Parent_ID#" cfsqltype="cf_sql_integer">,
					</cfif>
					Is_Manual_Revision = Is_A_Revision
			WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<!--- Tim Ford - WR 48045 - Workflow Issue - Timestamp Incorrect & Out of Order:
			RFA is using the date from the DB server and approve is using the date from the Application server.
			This is causing an issue with workflow because if the clocks are off by a second the approval datetime will be before the RFA.
			Adding code below to check if RFA datetime is after approval datetime and adjust accordingly.
		--->
		<cfquery NAME="qAdjustApprovalDate" datasource="#application.datasource#">
			UPDATE 	Contract_Main
			SET 	Approval_Date = DATEADD(MI, DATEDIFF(MI, Approval_Date, Broker_Approved_Date) + 1, Approval_Date)
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			AND		Approved = 1
			AND		DATEDIFF(d, Broker_Approved_Date, Approval_Date) = 0
			AND		CAST(Approval_Date AS TIME) < CAST(Broker_Approved_Date AS TIME)
		</cfquery>

		<!---if the lock type is not Do not lock and the program has claim mechanics with locks on...
		then set the program lock type id in contract_main_aux_data    **************************************--->
		<cfset programManager.setProgramLockType(arguments.programId) />


		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">

			SELECT	Contract_Main.Contract_Number, Contract_Main.Is_A_Revision, Contract_Main.Auto_Renew,Program_Control_Panel_Options.Generic_Type,
			Program_Control_Panel_Options.ByPass_Margin_Evaluation, Program_Control_Panel_Options.EZButton_On,D.Discount_Identifier_Number
			FROM	Contract_Main INNER JOIN Program_Control_Panel_Options
			ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			LEFT JOIN Discount_Identifier D ON
				D.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID AND
				D.Active = 1
			WHERE	Contract_Main.Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

		</cfquery>
		<cfset Discount_Identifier_Number = qGetProgramInfo.Discount_Identifier_Number>
		<!----- check if the current program was a revision, and also if it had auto renew flag on ----->
		<cfif qGetProgramInfo.Is_A_Revision AND qGetProgramInfo.Auto_Renew>
			<!----- we will need to make the auto renew entry for this program to be the active record if applicable ----->
			<cfif getAutoRenewStatus(qGetProgramInfo.Contract_Number) EQ 0>
				<!----- if no other version of this program already auto renewed, activate current program record ----->
				<cfquery name="qUpdateProgramAutoRenewToActive" datasource="#application.datasource#">
					--- update old version programs to inactive
					UPDATE	Program_Auto_Renew
					SET		Active = 0
					FROM	Program_Auto_Renew
					INNER JOIN Contract_Main
					ON		Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
					AND		Contract_Main.Contract_Number = <cfqueryparam value="#qGetProgramInfo.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
					WHERE	Program_Auto_Renew.Deleted = 0
					AND		Program_Auto_Renew.Active = 1
					AND		Program_Auto_Renew.Renewed = 0

					--- update current program to active
					UPDATE	Program_Auto_Renew
					SET		Active = 1
					WHERE	Program_Auto_Renew.Deleted = 0
					AND		Program_Auto_Renew.Active = 0
					AND		Program_Auto_Renew.Renewed = 0
					AND		Program_Auto_Renew.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
			</cfif>
		</cfif>

		<cfset qGetProgramInfo = getProgramInfo(arguments.programId) />
		<!------ get the template id ----->
		<cfset templateId = qGetProgramInfo.programtype_id />

		<cfif appSettings.getPgmPostApprovalStatus() EQ 1>

			<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
			<cfset ProgramPostApprovalStatusManager.setProgramPostApprovalStatusOnApproval(
						programId = arguments.programId,
						templateId = templateId,
						userId = arguments.userId) />
		</cfif>

		<!------ if program is a bid and is a revision, and if the bid status is not pending, set the bid status for any new products which do not have bid status ----->
		<cfif qGetProgramInfo.Is_A_Revision>
			<!---check if it's a bid request--->
			<cfquery name="qCheckIfBidRequest" datasource="#application.datasource#">
				SELECT	Bid_Request_Status_ID
				FROM 	Program_Bid_Request
				WHERE	Deleted = 0
				AND		Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif qCheckIfBidRequest.RecordCount>
			<!--- D33022 competitive data page Issue on Revision
			Added OR in IF statement --->
				<cfif qCheckIfBidRequest.Bid_Request_Status_ID neq 1 AND qCheckIfBidRequest.Bid_Request_Status_ID neq 3><!--- pending ---->
					<cfset createObject("component", "components.programs.bid_request.BidRequestProductStatusManager").setStatusOnRevision(arguments.programId) />
				</cfif>
			</cfif>
		</cfif>

		<!------ update effective dates for all versions of the program ----->
		<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#arguments.programId#" null="no">
		</cfstoredproc>

		<!--- Call the "BB_Update_Count_Flag" SP --->
		<cfif qGetProgramInfo.BB_Dont_Count_Volume_Select EQ 1 and appSettings.getAllow_BB_Dont_Count_From_Program() NEQ 0>
			<cfstoredproc procedure="BB_Update_Count_Flag_For_All_BB_Program_Versions" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@ContractNumber" value = "#qGetProgramInfo.Contract_Number#" null="no">
			</cfstoredproc>
		</cfif>

		<!--- START: 47231: Program LH link called EZ Rate/Anand Rao/31-Dec-2014
							Insert the EZ template values into the Program_Template_EZ_Rate Table after approval
		--->
			<cfif isDefined("qGetProgramInfo.EZButton_On") and qGetProgramInfo.EZButton_On EQ 1>
				<cfset programManager.updEZProgramProducts(arguments.programId) />
			</cfif>
		<!--- END: 47231: Program LH link called EZ Rate/Anand Rao/31-Dec-2014	--->


		<!--- Dev Note: KAL; D21684: Functionality of View Margins Screen
			Copy the margin from Contract_Product_Margin when program is approved into Contract_Product_Margin_Approved table,
			only if there is no entry for the program in the Contract_Product_Margin_Approved table.
		--->
        <cfset programManager.setApprovedMarginData(arguments.programId) />
		<!--- End Note: KAL; D21684: Functionality of View Margins Screen --->

		<cfif appSettings.getBudgetsFunctionalityOn() EQ 1>
			<!---
			25715: Budgeting
			No longer needed for advanced budget
			<cfset BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init() />
			<!---- should be called after effective dates are updated ---->
			<cfset BudgetManager.addCommittedProgram(
					templateParentId = qGetProgramInfo.First_Parent_ID,
					programId = arguments.programId,
					contractNumber = qGetProgramInfo.Contract_Number,
					programSpend = qGetProgramInfo.Program_Spend,
					qProgram = qGetProgramInfo,
					ByPass_Margin_Evaluation = qGetProgramInfo.ByPass_Margin_Evaluation) />
			--->
			<cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').refreshCommittedForProgram(programId = arguments.programId) />

		</cfif>

		<!--- 	BB Auto report Processing.  Insert new program into Auto BB Processing
				SP will recognize if it is an auto pay deal or not.
				--->
		<cfif appSettings.getBBAutoReport()>
			<!--- Update the Program Level Claim_Mechanics Flag based on the existance of a component level Auto Pay Component --->
			<!--- <cfif appSettings.getClaims_at_Comp_Level()>
				<cfset tmp = CreateObject("component","components.Billback.BBAutoReportUpdate").UpdPrgClaimMechanic(arguments.programId) />
			</cfif> --->
			<cfif NOT appSettings.getBBAutoReportisManuallyConfigured() ><!--- ONLY FOR FULL AUTO PAY: getBBAutoReportisManuallyConfigured() = 0 --->

				<!--- CHECK to see if a previous revision of this program is on an Auto pay report That has not run yet --->
				<cfquery name="qGetAutoPayPeriodStatus" datasource="#application.datasource#">
					SELECT TOP 1 BB_Auto_Program_Pay_Period_Id FROM BB_Auto_Program_Pay_Period BAP
					INNER JOIN Contract_Main C ON
						C.Contract_Main_Id = BAP.Program_Id
					WHERE C.Contract_Number = (SELECT Contract_Number
												FROM Contract_Main
												WHERE Contract_Main_Id = #arguments.programId#)
					AND BAP.BB_Auto_Report_ID IS NOT NULL
					AND BAP.Status = 1 --calculate
					AND BAP.Deleted = 0
				</cfquery>
				<!--- Only Update Pay Periods If Auto Pay is not Running.  Scheduled Auto Pay Process will pick up missing programs on Next run. --->
				<CFIF NOT ISNUMERIC(qGetAutoPayPeriodStatus.BB_Auto_Program_Pay_Period_Id)>
					<!--- **NOTE: DBVARNAME is Ignored in JDBC Driver.  Vars must be passed in correct Order!! --->
					<cfstoredproc procedure="BB_Auto_Populate_Program_Pay_Periods" datasource="#application.datasource#">
						<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value ="#arguments.programId#" null="no" />
					</cfstoredproc>
				</CFIF>
				<!--- Handle for LS auto pay
				<cfquery name="GetAutoPayLS" datasource="#application.datasource#">
					SELECT	Program_Lump_Sums.Program_Lump_Sum_ID,
							Program_Lump_Sums.Split_For_Auto_Pay
					FROM 	Program_Lump_Sums
						INNER JOIN Payment_Type
						ON 	Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
						AND	Payment_Type.Is_Auto_Pay = 1
					WHERE 	Program_Lump_Sums.Program_ID = '#arguments.programId#'
						AND	Program_Lump_Sums.Deleted = 0
				</cfquery>

				<cfif GetAutoPayLS.Recordcount GT 0>
					<cfset AutoPayLS = CreateObject("component","components.Billback.BillbackAutoManager").AutoPayLS(arguments.programId,request.AccessStructure.User_ID) />
				</cfif> --->
			</cfif>
		</cfif>

		<!--- If any of the fixed or rebate components has a claim mechanism, that has the bit "Include_Claim_Rates_Report"
		 or "Include_Pricing_Report" ON AND the paid to is either distributor (1) or operator/distributor(4) AND
		the "claim rates report" setting on the template is not OFF.
		--->
		<cfquery name="setReportStatus" datasource="#application.datasource#">
			EXEC Update_Report_Status_Nightly #arguments.programId#
		</cfquery>
<!---D60956 :: Version Specific Payment History: When prg is revised $ shows on new version with no payments START--->
<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 0>
		<cfquery name="setPaymentHistory" datasource="#application.datasource#">
			UPDATE CONTRACT_MAIN_AUX_DATA
			   SET Payment_History = ( CASE
			                             WHEN PAYMENT_HISTORY_DETAILS.Contract_Number IS NOT NULL THEN 1
			                             ELSE 0
			                           END )
			  FROM CONTRACT_MAIN
			       INNER JOIN CONTRACT_MAIN_AUX_DATA ON CONTRACT_MAIN_AUX_DATA.Contract_Main_Id = CONTRACT_MAIN.Contract_Main_Id
			       LEFT JOIN PAYMENT_HISTORY_DETAILS ON CONTRACT_MAIN.Contract_Number = PAYMENT_HISTORY_DETAILS.Contract_Number
			 WHERE CONTRACT_MAIN.Contract_Main_Id = '#arguments.programId#'
		</cfquery>
</cfif>
<!---D60956 :: Version Specific Payment History: When prg is revised $ shows on new version with no payments START--->
		<!--- D26612: Link to freight missing for DST's(Lbl 25165)
		Call freight routine if freight program does not have entry in freight table
		--->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight() eq 1
				AND qGetProgramInfo.Freight_Program EQ 1
				AND qGetProgramInfo.Freight_Component_Type NEQ 0
				>
			<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight").init() />
			<cfif NOT objProgramFreight.verifyValidFreight(arguments.programId)>
				<cfset objProgramFreight.PopulateProgramDistributorFreight(arguments.programId, 0) />
			</cfif>

			<cfif CreateObject("component","components.freight.FreightBracketSetting").getFreightVersionItem()>
				<cfquery name="runFreightProce" datasource="#application.datasource#">
					EXEC Populate_Program_Freight_Version_CC #arguments.programId#
				</cfquery>
			</cfif>

		</cfif>

		<!------
			xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
			xxxxxxx update priceListSpecial if it is a valid Discount Type.  This is based on the discount Identifier used for Sabert   xxxxxxxxx
			xxxxxxx      'ZSCP'     This value is also Hardcoded in the Stored Proc: Populate_Price_List_Special                        xxxxxxxxx
			XXXXXXX		'FS' and 'N' And Generic_Type = 'Distributor Trade/Shelter' For Simplot
			xxxxxxx     need to Update this if we deploy it anywhere else                                                               xxxxxxxxx ----->
		<!---  Dev Note:  MarkS D11024 --->
		<!---  Dev Note:  MarkS D16209 Commented out since Nightly routine handles this process --->
		<!--- <CFQUERY NAME="qGetPricelistDiscount" datasource="#application.datasource#">
			SELECT	PCPO.ProgramControl_Panel_Options_ID
			FROM	Contract_Main C
					INNER JOIN Program_Control_Panel_Options PCPO
						ON PCPO.ProgramControl_Panel_Options_ID = C.ProgramType_ID
					INNER JOIN Program_Fixed_Component PC
						ON PC.Program_ID = #arguments.programId#
						AND PC.DELETED = 0
			WHERE
					C.Contract_Main_ID = #arguments.programId# AND
		            PCPO.Fixed_Price_Populates_Price_List_Special = 1
		</CFQUERY>
		<cfif qGetPricelistDiscount.recordcount GT 0>
			<cfstoredproc procedure="Populate_Price_List_Special" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Program_ID" value = "#arguments.programId#" null="no">
			</cfstoredproc>
		</cfif> --->
		<!--- xxxxxxxxxx            END Special Price List Handling          xxxxxxxxxxxxxxxxxxxxxxxxx --->

    <!---25704 - external contacts--->
    <!--- For "standard letters" and "custom 3 letters" (KraftHeinz) app setting,
    we have "Generate_Letters_On_Approval" template setting.
    For "custom 1 letters" app setting, we have "Email_Letters_On_Approval" template setting.
    In other words, some clients (GM) want letters to be generated and emailed on approval and others want
    letters to be generated on approval. There is no automatic emailing of letters.
    In the future, this may change - we might have both the template settings available.
    --->
    <!--- Note: "Email_Letters_On_Approval" template setting is not being used anymore, but hasn't been removed, just in case
    we need to use it again in the future.
    --->
    <cfif qGetProgramInfo.Email_Letters_On_Approval eq 1 OR qGetProgramInfo.Generate_Letters_On_Approval eq 1>
	  <cfset loc.startDateTime = DateAdd('n', 1, now())>
	  <cfset loc.endDate = dateAdd("d",2,dateFormat(now(),'mm/dd/yyyy'))>
      <cfschedule
	  action = "update"
	  task = "#application.returned_customer_setting.Company_Name# Letter_#arguments.programId#"
	  interval = "28800"
	  operation = "HTTPRequest"
	  startDate = #loc.startDateTime#
	  endDate = "#loc.endDate#"
	  startTime = #TimeFormat(loc.startDateTime,'short')#
	  url = "#application.HTTPVar##cgi.server_name#/Scheduled/approvalLetter.cfm?Contract_Main_ID=#arguments.programId#"
      >
    </cfif>
	<!--- D32683 Price Protection - Ongoing Solution - Call Price protection SP --->
	<cfstoredproc procedure="Price_Protection_Update" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID_To_Process" value = "#arguments.programId#" null="no">
		<cfprocparam type="In" CFSQLType="cf_SQL_DATE" dbVarName = "@As_Of_Date" value = "#qGetInitialProgramInfo.Contract_Start_Date#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Allow_Revise" value = "0" null="no">
	</cfstoredproc>
	<!--- D30357:Today's Price Wrong on Revision History START--->
	<cfif appsettings.getUseFixedPriceType()>
		<cfset UpdateContractProductsBaseSalesCS(arguments.programId)>
	</cfif>
	<!--- D30357:Today's Price Wrong on Revision History END--->
		<cfif appsettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND Discount_Identifier_Number EQ "CPA">
			<cfquery NAME="updChildFomParent" datasource="#application.datasource#">
					EXEC Update_CPA_Child_Program #arguments.programId#
			</cfquery>
		</cfif>

	</cffunction>






	<cffunction name="storeProgramApprovalInfo" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />

		<cfquery NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE 	Contract_Main_Aux_Data
			Set 	Program_Approved = 1,
					Program_Approved_Date = GetDate(),
					Program_Approved_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

	</cffunction>

	<cffunction name="getProgramApprovalInfo" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />

		<cfquery NAME="qGetProgramApprovalInfo" datasource="#application.datasource#">
			SELECT	Program_Approved,
					Program_Approved_Date,
					Program_Approved_By
			FROM	Contract_Main_Aux_Data
			WHERE 	Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn qGetProgramApprovalInfo />

	</cffunction>

	<cffunction name="saveInternalComments" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="internalComments" required="true" type="string" />

		<CFQUERY NAME="saveBusinessConsiderations" datasource="#application.datasource#">
			UPDATE 	Contract_Main_Aux_Data
			SET		Comments = <cfqueryparam value="#arguments.internalComments#" cfsqltype="CF_SQL_LONGVARCHAR">
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>

	</cffunction>

	<cffunction name="saveContractReferenceNumber" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="sContractReferenceNumber" required="true" type="string" />

		<CFQUERY NAME="qSaveContractReferenceNumber" datasource="#application.datasource#">
			UPDATE 	Contract_Main
			SET		Contract_Reference_Number = <cfqueryparam value="#arguments.sContractReferenceNumber#" cfsqltype="CF_SQL_LONGVARCHAR">
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>

	</cffunction>

	<cffunction name="cancelProgram" output="false">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="cancelallprogramversions" required="true" type="boolean" />
		<cfargument name="Date_Exclusions_ON" required="true" type="boolean" />
		<cfargument name="IS_Date_Exclusions_child" required="true" type="boolean" />
		<cfargument name="cancelOption" required="false" type="numeric" default="0" />

		<cfset appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfset qGetProgramInfo = getProgramInfo(arguments.programId) />

		<!------ Find the contract_number ----->
		<cfset Contract_Number = "" />
		<cfset contract_status = ""/>
		<cfset preactiveversionsfound = 0>
		<cfset newEndDate = "" />
		<cfif arguments.cancelOption EQ 1>
			<cfset newEndDate = DateFormat(Now(), "mm/dd/yyyy") />
		</cfif>

		<cfquery name="qGetContractNumber" datasource="#application.datasource#">
			SELECT	Contract_Number,contract_status_type_idx,Contract_Start_Date
			FROM	Contract_Main
			WHERE	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qGetContractNumber.recordCount>
			<cfset Contract_Number = qGetContractNumber.Contract_Number />
			<cfset contract_status = qGetContractNumber.contract_status_type_idx />
		</cfif>

		<cfif Contract_Number NEQ "" and arguments.IS_Date_Exclusions_child EQ 0>
			<cfquery name="getpreactiveversions" datasource="#application.datasource#">
				SELECT	contract_main_id
				FROM	Contract_Main
				WHERE	contract_number = <cfqueryparam value="#contract_number#" cfsqltype="nvarchar">
				and deleted = 0
				and (contract_status_type_idx > 3 AND  contract_status_type_idx < 7)
				and force_expiration_flag = 0
				and contract_main_id != <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
				<cfif arguments.Date_Exclusions_ON EQ 1>
				and contract_main_id not in (select revision_program_id from
				program_exclusions inner join contract_main on contract_main.contract_main_id =
				program_exclusions.revision_program_id where contract_main.contract_number  = '#contract_number#')
				</cfif>
			</cfquery>
			<cfset preactiveversionsfound = getpreactiveversions.recordcount>
		</cfif>

		<cfquery name="qCancelProgram" datasource="#application.datasource#">

			UPDATE 	Contract_Main
			SET 	Force_Expiration_Flag = 1,
					Manual_Cancel = 1,
					Cancelled_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
					Cancelled_Date = GetDate()
					<cfif arguments.cancelOption EQ 1>
					,End_Date_Changed_On_Cancel = CASE WHEN (DateDiff(d,getdate(),Contract_End_Date) > 0) THEN 1 ELSE 0 END,
					Contract_End_Date = <cfqueryparam value="#newEndDate#" cfsqltype="CF_SQL_DATE">,
					Cancel_And_End_Dated = 1
					<cfif dateDiff("d", Now(), qGetContractNumber.Contract_Start_Date) GT 0>
						,Contract_Start_Date = <cfqueryparam value="#newEndDate#" cfsqltype="CF_SQL_DATE">
					</cfif>
					</cfif>
					<cfif arguments.IS_Date_Exclusions_child EQ 0>
						<cfif preactiveversionsfound and not arguments.cancelallprogramversions>
							,deleted = 1
						</cfif>
					<cfelse>
						,deleted = 1
					</cfif>
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

		</cfquery>
		<!--- 	GV - label D9405 If the progam is set to auto-renew and it is cancelled, the auto-renewed version of the program should not be generated.  If the program has already auto-renewed, leave the auto-renewed version in the application. --->
		<cfquery name="removeautorenewprgs" datasource="#application.datasource#">
			update 	Program_Auto_Renew
			set 	deleted = 1
			WHERE 	Program_Auto_Renew.Renewed = 0
			and 	Program_Auto_Renew.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			and 	deleted = 0
		</cfquery>
	<!--- End GV - label D9405 --->
		<cfif arguments.cancelallprogramversions EQ 1>
		<!------ If there are any children cancel that too ----->
		<cfif Contract_Number NEQ "" >
			<cfquery name="qCancelProgram" datasource="#application.datasource#">
				UPDATE 	Contract_Main
				SET 	Force_Expiration_Flag = 1,
						Manual_Cancel = 1,
						Cancelled_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
						Cancelled_Date = GetDate(),
						<cfif arguments.cancelOption EQ 1>
						End_Date_Changed_On_Cancel = CASE WHEN (DateDiff(d,getdate(),Contract_End_Date) > 0) THEN 1 ELSE 0 END,
						Contract_End_Date = <cfqueryparam value="#newEndDate#" cfsqltype="CF_SQL_DATE">,
						Cancel_And_End_Dated = 1,
						</cfif>
						Deleted =   (CASE  WHEN contract_status_type_idx = 7 THEN Deleted ELSE  1 END),
						Deleted_By =   (CASE WHEN contract_status_type_idx = 7 THEN Deleted_By ELSE    <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR"> END),
						Deleted_Date = (CASE WHEN contract_status_type_idx = 7 THEN Deleted_Date ELSE GetDate() END)
				WHERE 	Contract_Number = <cfqueryparam value="#Contract_Number#" cfsqltype="CF_SQL_VARCHAR">
						AND Contract_Main_ID <> <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
						<!--- AND Force_Expiration_Flag = 0<!------ If there are parent, it will already be Force_Expiration_Flag=1 for the current program to be active ----->
						AND Deleted = 0 --->
			</cfquery>
		</cfif>
		</cfif>

		<!------ if end date is changing, update effective dates for all versions of the program ----->
		<!------ if the program is cancelled as it never existed, the effective dates should be NULL ----->
		<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">

			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#arguments.programId#" null="no">

		</cfstoredproc>

		<!------ now the dates have changed the trade spend also might change ----->
		<cfstoredproc procedure="PROGRAM_TRADE_SPEND_UPDATE" datasource="#application.datasource#">

			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#arguments.programId#" null="no">

		</cfstoredproc>

		<cfif appSettings.getBudgetsFunctionalityOn() EQ 1>
			<cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').refreshCommittedForProgram(programId = arguments.programId) />
		</cfif>
            
        <!--- Remove lift from planner volume plan if there are no other programs for those weks/products --->
        <cfstoredproc procedure="Planner_Program_Date_Change_Update_Volume_Plan" datasource="#application.datasource#" returnCode = "yes">
            <cfprocparam type="in" 	cfsqltype="cf_sql_integer" 	value="#arguments.programId#">
            <cfprocparam type="in" 	cfsqltype="cf_sql_date"    	null="yes">
            <cfprocparam type="in" 	cfsqltype="cf_sql_date"    	null="yes">
            <cfprocparam type="in" 	cfsqltype="cf_sql_varchar" 	value="DELETE">
        </cfstoredproc>

	</cffunction>
	<!--- Dev Note: KAL; 8266 --->
	<cffunction name="CancelProgramInERP" output="False">
		<cfargument name="programId" required="true" type="numeric" />
		<cfquery name="qCancelProgramERP" datasource="#application.datasource#">
			UPDATE 	Contract_Main
			SET		Cancel_Sent_to_Client = 1,
					Sending_To_External_Client = 0,
					Sent_To_External_Client = 1,<!---D28127: Manual cancelations are not working --->
					External_Client_Cancel_Ack_Date = getdate()
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>
	<!--- End Note: KAL; 8266 --->
	<cffunction name="purgeProgram" output="false">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<CFQUERY NAME="PurgeContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Flagged_As_Purged = 1,
				Purged_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
				Purged_Date = GetDate(),
				Deleted = 1,
				Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
				Deleted_Date = GetDate()
			WHERE Contract_Main_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
	</cffunction>

  	<cffunction name="discountIsGroup" output="false" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="discountTypeId" required="true" type="numeric" />

		<!------ Get program Info ----->

		<cfquery name="qCheckGroups" datasource="#application.datasource#">

			SELECT 	*
			FROM 	Contract_Products
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			AND 	Deleted = 0
			AND 	Product_Type_ID = #arguments.discountTypeId#
			AND		Is_Group = 1

		</cfquery>

		<cfreturn qCheckGroups.RecordCount />

	</cffunction>

	<cffunction name="isARevision" output="false" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />

		<cfset returnValue = 0 />

		<!------ Check to see if it's a revision----->
		<cfquery name="qCheckRevision" datasource="#application.datasource#">

			SELECT 	Is_A_Revision
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

		</cfquery>

		<cfif qCheckRevision.recordCount>
			<cfset returnValue = qCheckRevision.Is_A_Revision />
		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="isALimitedRevision" output="false" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />

		<cfset returnValue = 0 />

		<!------ Check to see if it's a Limited Revision----->
		<cfquery name="qCheckRevision" datasource="#application.datasource#">
			SELECT 	Limited_Revise
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qCheckRevision.recordCount>
			<cfset returnValue = qCheckRevision.Limited_Revise />
		</cfif>

		<cfreturn returnValue />

	</cffunction>


	<cffunction name="hasAnApprovedRevision" output="false" returntype="boolean">

		<cfargument name="programId" required="true" type="numeric" />

		<cfset returnValue = 0 />

		<!------ Check to see if it has a revision----->
		<cfquery name="qCheckHasAnApprovedRevision" datasource="#application.datasource#">
			SELECT 	1
			FROM 	Contract_Main
			WHERE 	Revision_of_Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			AND Approved = 1
		</cfquery>

		<cfif qCheckHasAnApprovedRevision.recordCount>
			<cfset returnValue = 1 />
		</cfif>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="makeRFA" output="true" returntype="void">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="groupProcessed" required="false" type="numeric" default="0" />

		<cfquery name="qMakeRFA" datasource="#application.datasource#">

			UPDATE 	Contract_Main
			SET 	Broker_Approved = 1,
<!--- 					<cfif arguments.groupProcessed>
					group_processed = 1,
					</cfif> --->
					Broker_Approved_Date = getdate(),
					Broker_User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			WHERE 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">

		</cfquery>

		<!------ Store All Approvable Positions ----->
		<cfquery name="qUpdateApprovablePositions" datasource="#application.datasource#">
			EXEC Populate_Program_Approvable_Positions #arguments.programId#
		</cfquery>

		<cfscript>
			objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
			getSettings = objProgramTemplateManager.getSettings(arguments.programID);
		</cfscript>

		<cfif getSettings.Custom_Fixed_Price_Options EQ 1>
			<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.programID#" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "0" null="no">
			</cfstoredproc>
		</cfif>

		<!--- Milan; 16966 - If it's a revision then call the SP_Revision_Report_Nightly SP just for this Program asynchronously --->
		<!--- Dev Note: 23171 - We do not need this code anymore --->
		<!---
		<cfif isARevision(arguments.programId)>

		<script type='text/javascript'>
			_ajaxConfig = {	'_cfscriptLocation':'/components/Programs/ProgramAJAX.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
		</script>
		<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
		<script type="text/javascript">
			function CallRevisionReportNightly(programId)
			{
				DWREngine.setAsync(true);
				DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'CallRevisionReportNightly', programId, doNothing);
			}

			// This function is required for the execute signature but does nothing
			function doNothing(r){

				return void(0);
			}
			<cfoutput>
			CallRevisionReportNightly(#arguments.programId#);
			</cfoutput>
		</script>
		</cfif>
		--->

		<!--- BJF 13044: Pullback default should be saved if user makes no detailed decision for operator --->
		<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()> --->

		<cfif application.appSettingsGet.getPullbacksOn() EQ 1 >
			<CFTHREAD ACTION="RUN" NAME="#arguments.programId#" p="#arguments.programId#" u="#arguments.userId#" >
				<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") >
				<cfset tmp = PullbackManager.InsertDefaultsonRFA(p,u) >
			</CFTHREAD>
		</cfif>

		<!--- 113075: Program Search - Display Estimated Trade for RFA / Anand Rao / 08-Mar-2022
					Code change to calculate the Trade $ when the program goes into RFA status.
		---> 
		<cfstoredproc procedure="PROGRAM_TRADE_SPEND_UPDATE" datasource="#application.datasource#">
		    <cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#arguments.programID#" null="no">
		</cfstoredproc>
		
	</cffunction>

	<cffunction name="getprogramDiscounttypes" returntype="string">

		<cfargument name="programId" required="true" type="string" />
		<cfquery name="qgetprogramDiscounttypes" datasource="#application.datasource#">
			select distinct product_type_id from contract_products
			WHERE 	Contract_Main_ID IN (#PreserveSingleQuotes(arguments.programId)#)
			and deleted = 0
		</cfquery>
		<cfreturn valuelist(qgetprogramDiscounttypes.product_type_id) />
	</cffunction>

	<cffunction name="checkProductUOMMatch" returntype="array">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="checkVolumeUOM" required="false" type="boolean" default="1" />
		<cfargument name="checkRateUOM" required="false" type="boolean" default="1" />

		<cfset checkArray = ArrayNew(1) />

		<!------ Check volume UOM ----->
		<cfif arguments.checkVolumeUOM>


		</cfif>

		<!------ Check rate UOM ----->
		<cfif arguments.checkRateUOM>
			<!------
			Rate UOM match
				- Rate UOM = %
				- Rate UOM = LB or CS, and Rate UOM = Product UOM
			 ----->
			<cfset applicationSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>

			<!------ Get the list of discount Types ----->
			<cfset discountTypeList = getprogramDiscounttypes(arguments.programId) />

			<cfloop list="#discountTypeList#" index="discountId">

				<!--- Call the Program_Product_UOM_Check stored proc to find if there are mismatch UOM products --->
				<cfstoredproc procedure="Program_Product_UOM_Check" datasource="#application.datasource#">

					<!--- cfprocparam tags --->
				   	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@@CONTRACT_MAIN_ID" value="#arguments.programId#" />
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@@Discount_Type_ID" value="#discountId#" />

					<cfprocresult name="qProductMismatch_#discountId#" />

				</cfstoredproc>
				<cfoutput>

				<cfif isDefined("qProductMismatch_#discountId#")>
				<cfset qProductMismatch = Evaluate("qProductMismatch_#discountId#") />
				<table cellpadding="2" cellspacing="0" border="1" width="90%" align="center">
				<caption style="font-size:14px; font-weight:bold;">#applicationSettingsManager.getDiscountTypeDesc(discountId)#</caption>
				<tr style="font-weight:bold;" align="center">
					<td>#application.returned_customer_setting.item_label#</td>
					<td>Description</td>
					<td>Unit Of Measure</td>
				</tr>
				<cfloop query="qProductMismatch_#discountId#">
					<tr>
						<td>#Item#</td>
						<td>#Product_Description#</td>
						<td>#Product_UOM#</td>
					</tr>
				</cfloop>
				</table>
				</cfif>
				</cfoutput>
			</cfloop>
		</cfif>

		<cfreturn checkArray />

	</cffunction>

	<cffunction name="getprogramsettings" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />
		<cfquery name="qgetprogramsettings" datasource="#application.datasource#">
		SELECT Date_Exclusions_ON
		FROM Contract_Main
		INNER JOIN	Program_Control_Panel_Options
		ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
		WHERE Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		--and Contract_Main.deleted = 0
		</cfquery>

		<cfreturn qgetprogramsettings />
	</cffunction>

	<cffunction name="getAutoRenewDatesJSON" returnformat="JSON" access="remote">
		<cfargument name="autoRenewType" required="true" type="numeric" />
		<cfargument name="programDateType" required="true" type="numeric" hint="2=fiscal date, else=free form date" />
		<cfargument name="startDate" required="true" type="string" />
		<cfargument name="endDate" required="true" type="string" />

		<cfset AutoRenewDates = getAutoRenewDates(arguments.autoRenewType,0,arguments.programDateType,arguments.startDate,arguments.endDate)>

		<cfreturn serializeJSON(AutoRenewDates.AR_Start_Date) />

	</cffunction>

	<cffunction name="getAutoRenewDates" returntype="struct">

		<cfargument name="autoRenewType" required="true" type="numeric" />	<!--- 1=annual/2=concurrent/3=Monthly/4=Fiscal --->
		<cfargument name="autoRenewalLeadTime" required="true" type="numeric" />
		<cfargument name="programDateType" required="true" type="numeric" hint="2=fiscal date, else=free form date" />
		<cfargument name="startDate" required="true" type="string" />
		<cfargument name="endDate" required="true" type="string" />
		<!--- <cfargument name="dateMethod" required="true" type="numeric" hint="this argument is applicable only if programDateType = 2 (Fiscal date);values(1:Monthly,2:Quarterly,3:Yearly)" /> --->

		<cfset var Program_Span = 0 />
		<cfset var stAutoRenewDates = StructNew() />
		<cfset stAutoRenewDates.AR_Start_Date = "" />
		<cfset stAutoRenewDates.AR_Start_Period = "0" /> 			<!--- Dev Note: Kal; D43268/42956: AutoRenew with program fiscal date feature --->
		<cfset stAutoRenewDates.AR_End_Date = "" />
		<cfset stAutoRenewDates.AR_End_Period = "0" /> 				<!--- Dev Note: Kal; D43268/42956: AutoRenew with program fiscal date feature --->
		<cfset stAutoRenewDates.AR_Fiscal_Year = "" /> 				<!--- Dev Note: Kal; D43268/42956: AutoRenew with program fiscal date feature --->
		<cfset stAutoRenewDates.AR_Notification_Date = "" />

		<!--- Dev Note: Kal; D43268/42956: AutoRenew with program fiscal date feature --->
		<!--- Fiscal Date OR Free Form Date --->
		<cfset fiscalPeriodManager = createObject('component','mvc.Models.Settings.FiscalPeriodManager') /><!--- 60410 --->
		<cfif arguments.programDateType EQ 2> 	<!--- fiscal date --->
			<cfset startPeriod = fiscalPeriodManager.getFiscalPeriodforDate(fiscalDate=arguments.startDate) />
			<cfset endPeriod = fiscalPeriodManager.getFiscalPeriodforDate(fiscalDate=arguments.endDate) />
			<cfset periodSpan = (endPeriod - startPeriod)+1 />			<!--- Program Span --->
			<cfset CurrentFiscalYear = fiscalPeriodManager.getFiscalYearforDate(fiscalDate=arguments.startDate) />		<!--- Current Prg Fiscal Year --->
			<cfset ARFiscalYear = fiscalPeriodManager.getNextFiscalYear(fiscalYear=CurrentFiscalYear) />		<!--- Auto Renew Fiscal Year --->

			<cfif arguments.autoRenewType IS 1>
				<!--- Annual Renewal --->
				<cfset stAutoRenewDates.AR_Start_Period = startPeriod />		<!--- Start Period --->
				<cfset stAutoRenewDates.AR_End_Period = endPeriod /> 				<!--- End Period --->
				<cfset stAutoRenewDates.AR_Fiscal_Year = ARFiscalYear /> 		<!--- Fiscal Year --->
			<cfelseif arguments.autoRenewType IS 2>
				<!--- Renew Concurrently --->
				<!---
					Concurrent is not used for fiscal dates now; Right now make concurrent same as Annual.
					If the periods go past the dates then confirm if to roll it into next year or end at current year.
				--->
				<cfset stAutoRenewDates.AR_Start_Period = startPeriod />		<!--- Start Period --->
				<cfset stAutoRenewDates.AR_End_Period = endPeriod />				<!--- End Period --->
				<cfset stAutoRenewDates.AR_Fiscal_Year = ARFiscalYear /> 		<!--- Fiscal Year --->
			</cfif>
			<!--- Notification Date from current end date --->
			<cfset stAutoRenewDates.AR_Notification_Date = DateAdd('d', -1 * arguments.autoRenewalLeadTime, arguments.endDate)>

		<cfelse> 	<!--- free form date --->

			<cfif arguments.autoRenewType IS 1 OR arguments.autoRenewType IS 2>
				<cfset Program_Span = abs(DateDiff('d', arguments.endDate, arguments.startDate))>			<!--- Program Span --->
				<!--- Start Date --->
				<cfif arguments.autoRenewType IS 1>
					<cfset stAutoRenewDates.AR_Start_Date = DateAdd('yyyy', 1, arguments.startDate)>		<!--- Annual Renewal --->
				<cfelseif arguments.autoRenewType IS 2>
					<cfset stAutoRenewDates.AR_Start_Date = DateAdd('d', 1, arguments.endDate)>					<!--- Renew Concurrently --->
				</cfif>
				<!--- End Date --->
				<!---66117 - Update Auto Renew - Concurrent month --->
				<!---If auto renew type is concurrent, the start date is the first day of the month and the end date is the last day of the month then we can set the end date by month ---->
				<cfset dDiff = DaysInMonth(arguments.endDate) - Day(arguments.endDate) />
				<cfif arguments.autoRenewType eq 2 and Day(arguments.startDate) eq 1 and dDiff eq 0>
					<cfset Number_Of_Months = DateDiff("m", arguments.startDate, arguments.endDate) + 1 />
					<cfset stAutoRenewDates.AR_End_Date = DateAdd('m', Number_Of_Months, stAutoRenewDates.AR_Start_Date) - 1>
				<cfelse>
					<cfset stAutoRenewDates.AR_End_Date = DateAdd('d', Program_Span, stAutoRenewDates.AR_Start_Date)>
				</cfif>

			</cfif>

			<cfif arguments.autoRenewType IS 3>
				<!--- First find the month of the end date.
				Then find the month after that.
				Autorenew start date will be the first day of that month.
				Autorenew end date will be the last day of that month.
				--->
				<cfset nextmonthdate = dateadd("m", 1, arguments.endDate) />
				<cfset nextmonth = Month(nextmonthdate) />
				<cfset nextmonthyear = Year(nextmonthdate) />

				<!--- Get start date --->
				<cfset stAutoRenewDates.AR_Start_Date = CreateDate(nextmonthyear, nextmonth, 1) >

				<!--- Get end date - add 1 month and subtract a day --->
				<cfset stAutoRenewDates.AR_End_Date = dateadd("d", -1, dateadd("m", 1, stAutoRenewDates.AR_Start_Date)) />
			</cfif>
				<!---60410 :  Fiscal Year Selection and Auto Renew START--->
				<cfif  arguments.autoRenewType IS 4>
					<cfset fiscalYear = fiscalPeriodManager.getFiscalPeriodforDateRange(arguments.endDate)>
					<cfset nextFiscalYear = fiscalPeriodManager.getNextFiscalYear(fiscalYear)>
					<cfset nextFiscalYearDates = fiscalPeriodManager.getFiscalDatesforYear(nextFiscalYear)>
					<cfset stAutoRenewDates.AR_Start_Date = nextFiscalYearDates.startDate>
					<cfset stAutoRenewDates.AR_End_Date = nextFiscalYearDates.endDate>
				</cfif>
				<!---60410 :  Fiscal Year Selection and Auto Renew END--->
			<!--- Notification Date from start date --->
			<cfset stAutoRenewDates.AR_Notification_Date = DateAdd('d', -1 * arguments.autoRenewalLeadTime, stAutoRenewDates.AR_Start_Date)>


		</cfif>

		<cfreturn stAutoRenewDates />

	</cffunction>

	<cffunction name="getAutoRenewStatus" returntype="numeric" hint="return 0=has not auto renewed, 1=has already auto renewed">

		<cfargument name="contractNumber" required="true" type="string" />

		<cfquery name="qGetAutoRenewStatus" datasource="#application.datasource#">

			SELECT	Contract_Main.Contract_Main_ID
			FROM	Program_Auto_Renew
			INNER JOIN Contract_Main
			ON		Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
			AND		Contract_Main.Contract_Number = <cfqueryparam value="#arguments.contractNumber#" cfsqltype="CF_SQL_VARCHAR">
			WHERE	Program_Auto_Renew.Deleted = 0 <!--- D29623: Program did not auto renew Modified this statement from Program_Auto_renew.Delete to Contract_main.Delete---->
			AND		Program_Auto_Renew.Active = 1
			AND		Program_Auto_Renew.Renewed = 1

		</cfquery>

		<cfif qGetAutoRenewStatus.recordCount>
			<cfreturn 1 />
		<cfelse>
			<cfreturn 0 />
		</cfif>

	</cffunction>

	<cffunction name="getParentProgramDistributors" returntype="query">

		<cfargument name="contractMainId" required="true" type="string" />

		<CFQUERY NAME="qGetParentProgramDistributors" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Customers_ID
			FROM 	Contract_Distributors
			WHERE 	Contract_Main_ID =
					(SELECT Revision_of_contract_main_id
					FROM 	Contract_Main
					WHERE 	Contract_Main_ID =	<cfqueryparam value="#arguments.contractMainId#" cfsqltype="cf_sql_integer">
					)
			AND Deleted = 0
			AND	Captured_From_Group = 0
		</CFQUERY>


		<cfreturn qGetParentProgramDistributors />

	</cffunction>

	<cffunction name="getProgramUserSettings" returntype="query">

		<cfset useLakebaseForqGetProgramUserSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqGetProgramUserSettings>
	<cftry>
		<cfset qGetProgramUserSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.accessstructure.company_Main_Id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramUserSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramUserSettings>
<cfquery name="qGetProgramUserSettings" datasource="#application.datasource#">
			Select		*
			From		_Users_Settings
			Where		User_ID = '#request.accessstructure.company_Main_Id#'
		</cfquery>
</cfif>

		<cfreturn qGetProgramUserSettings />

	</cffunction>

	<cffunction name="resetProgram" output="true" returntype="void">
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="userId" required="true" type="string" />
		<cfargument name="Mode" required="true" type="numeric" />
		<cfargument name="LSAutoPay" required="false" type="numeric" default="0" />

		<cfif arguments.Mode EQ 3 OR arguments.Mode EQ 9>
			<cfquery name="deleteagreedtypecodes" datasource="#application.datasource#">
				DELETE from Program_Type_Code_Approval_Info
				where program_id = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</CFQUERY>

			<CFQUERY NAME="resetprogramagreements" datasource="#application.datasource#">
				DELETE from Program_agree
				where 	programid = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				delete from Program_agree_All_Group
				where 	programid = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</CFQUERY>

			<CFQUERY NAME="resetprogramagreements" datasource="#application.datasource#">
				update 	Contract_Main_Aux_Data
				set 	program_revisiontype_executed = 0
				where 	Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</CFQUERY>

			<!---<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight").init() />
			<cfset objProgramFreight.resetFreightApproval(programID =#arguments.programId#,userId =#arguments.userId#,comments = 'Reset Program to WIP')>--->

			<CFQUERY NAME="kickbackToWIP" datasource="#application.datasource#">
				UPDATE contract_main
				SET
				Broker_Approved 	= 0,
				Broker_Approved_Date 	= NULL,
				Broker_User_ID 		= NULL,
				<cfif arguments.LSAutoPay EQ 1>
					Approved		= 0,
					Approval_Date		= NULL,
					Approved_By_User_ID	= NULL,
				</cfif>
				Contract_Status_Type_IDX 	= 1,
				edit_agreed_program  =  0,
				modifying_program = 0,
				modifying_user_id = NULL,
				<cfif arguments.Mode EQ 3>
					Reset_Date = GetDate(),
					Reset_User_ID =  <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				<cfelseif arguments.Mode EQ 9>
					Reset_Date = NULL,
					Reset_User_ID =  NULL,
					Disagreed_Date = GetDate(),
				Disagreed_User_ID =  <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</CFQUERY>
		</cfif>
	</cffunction>

	<cffunction Name="saveProgramProductRate" access="public" output="false" returntype="array">
	  <!--- 27063 - CF 9 puts the passing Ajax array argument in position 2, CF 8 puts in position 1!!
	        Replaced the hard-coded of arguments[1] with a call to getArrayArgument() to find
	        the array data needed to process --->
		<cfargument name="fixedArray" type="array" required="true">
		<cfargument name="rebateArray" type="array" required="true">
		<!---<cfset var argArray = getArrayArgument( arguments ) />--->

		<cfif ArrayLen(arguments.fixedArray)>
			<cfset CreateObject("component", "components.programs.fixed.FixedComponentRate").saveFixedPriceRate(arguments.fixedArray) />
		</cfif>
		<cfif ArrayLen(arguments.rebateArray)>
			<cfset CreateObject("component", "components.programs.rebates.Rebate").saveProdRate_all(arguments.rebateArray) />
		</cfif>

		<cfset retArray = ArrayNew(1) />
		<cfset retArray[1] = arguments.fixedArray />
		<cfset retArray[2] = arguments.rebateArray />

		<cfreturn retArray />
	</cffunction>

	<cffunction Name="saveProgramProductRateRemote" access="remote" output="false" returnFormat="json">
	  <!---  ACCESS = REMOTE --->
		<cfargument name="fixedArray" type="any" required="false">
		<cfargument name="rebateArray" type="any" required="false">
		<cfargument name="isRebate" type="any" required="false">
		<cfargument name="isFixed" type="any" required="false">

		<cfif isFixed EQ 1 AND isDefined("arguments.fixedArray") AND arguments.fixedArray NEQ "">
			<cfset  strFixed = DeserializeJSON(arguments.fixedArray) />
			<cfset CreateObject("component", "components.programs.fixed.FixedComponentRate").saveFixedPriceRate(strFixed) />
		<cfelse>
			<cfset 	arguments.fixedArray = ArrayNew(1) />
		</cfif>
		<cfif isRebate EQ 1 AND isDefined("arguments.rebateArray") AND arguments.rebateArray NEQ ""> <!--- AND ArrayLen(arguments.rebateArray)> --->
			<cfset  strRebate = DeserializeJSON(arguments.rebateArray) />
			<cfset CreateObject("component", "components.programs.rebates.Rebate").saveProdRate_all(strRebate) />
		<cfelse>
			<cfset 	arguments.rebateArray = ArrayNew(1) />
		</cfif>
		<cfset retArray = ArrayNew(1) />
		<cfset retArray[1] = arguments.fixedArray />
		<cfset retArray[2] = arguments.rebateArray />
		<cfreturn serializeJSON(retArray,"struct") />
	</cffunction>


	<cffunction Name="saveProgramPriceListID" access="public" output="false" returntype="boolean">
	  	<cfargument name="programID" type="numeric" required="true">
	  	<cfargument name="Base_Sales_Equal_To_Lowest_Bracket" type="boolean" required="true">

	  	<!--- Do not update Price_List_ID if it has been already overridden --->
		<cfquery name="qUpdatePriceListID" datasource="#application.datasource#">
			update	contract_main_aux_data
			set		Price_List_ID = DBO.udf_GetProgramDefaultPriceBracket(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programID#" />, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.Base_Sales_Equal_To_Lowest_Bracket#" />)
			where 	contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programID#" />
			and		PriceBracket_Update = 0
		</cfquery>

		<cfreturn true />

	</cffunction>
	<!--- D29824:New Settings.. --->
	<cffunction NAME="ConvertProgramsTemplate" returntype="boolean" hint="Conert programs from one template to another template">
		<cfargument name="ThisForm" 				type="struct" 	required="yes">
		<cfargument name="username" 			type="string" 		required="true">
		<cfargument name="newtemplate" 	type="string" 		required="true">
	<cfloop list="#arguments.ThisForm.main_id#" index="CMID">

		<cfquery name="qGetOldTemplateInfo" datasource="#application.datasource#">
			SELECT	Contract_Number,PCPO.Created_Type
			FROM 	Contract_Main
			LEFT JOIN Program_Control_Panel_Options PCPO
			ON PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE 	Contract_Main_ID = #CMID#
		</cfquery>

		<cfquery name="qUpdatePriceListID" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET 	ProgramType_ID = #arguments.ThisForm.control_panel_id#
			<cfif arguments.ThisForm.Business_Segment_Enable>
			,Business_Segment_ID = #evaluate('arguments.ThisForm.businesssegmentid_#CMID#')#
				</cfif>
				WHERE 	Contract_Number in (SELECT	Contract_Number FROM Contract_main WHERE Contract_Main_ID = #CMID#)
			</cfquery>
		<!--- Tim Ford - Label 33917 - Program #1016340 - No Products: Add code to update the Template Filter ID in Contract_Main --->
		<cfquery name="qUpdateTemplateFilterId" datasource="#application.datasource#">
		<!--- D34767: EVENT ERROR 2993:  REASSIGNING PROGRAM TEMPLATES--->
			UPDATE	CM
			SET		CM.Template_Filters_Id = TF.Template_Filters_Id,
					CM.Pullback_From_This_Program = CASE WHEN PCPO.Pullbacks_On = 1 and PCPO.is_pullback_corporate_deal = 1
					THEN 1
					ELSE 0 END
			FROM	Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO ON
				PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			INNER JOIN Template_Filters  TF ON
				TF.parent_template_id = PCPO.first_parent_id AND
				TF.Deleted = 0
			WHERE	CM.Contract_Number IN (SELECT	Contract_Number FROM Contract_main WHERE Contract_Main_ID = #CMID#)
		</cfquery>

		<cfquery name="qUpdatePriceListID" datasource="#application.datasource#">
			INSERT INTO contract_evaluation_notes	(
								Entered_By,
								Eval_Action,
								Notes,
								Contract_Number,
								Contract_Notes_Type)
			VALUES(
								'#arguments.username#',
								'Template Change',
								'FROM: #qGetOldTemplateInfo.Created_Type#     TO: #arguments.newtemplate#',
								'#qGetOldTemplateInfo.Contract_Number#',
								'2')
		</cfquery>
		  	<!---D41760 :: GM Stabilization - Template & Segment Reassign --->
			<cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').save_budgets(arguments.ThisForm)>
	</cfloop>
	<cfreturn true />

	</cffunction>
	<cffunction NAME="TemplateChangeHistory" returntype="query" hint="Pulls Template change information from contract_evaluation_notes">
		<cfargument name="Contract_number" type="string" required="true">
	<cfquery name="qGetTemplateChangeInfo" datasource="#application.datasource#">
		SELECT *
		FROM contract_evaluation_notes
		WHERE contract_number = <cfqueryparam value="#arguments.Contract_number#" cfsqltype="CF_SQL_VARCHAR">
		AND   Eval_Action = 'Template Change'<!--- D30421 : Event error when viewing program History START --->
	</cfquery>
	<cfreturn qGetTemplateChangeInfo />
	</cffunction>
	<!--- D29824:New Settings.. --->
	<!--- D30233: Today's Price vs Requested Price START --->
	<cffunction name="setprice" returntype="void" output="true" hint="Update Request Price with Todays Price">
		<cfargument name="Contract_Main_ID" type="numeric" required="true" >
			<cfquery name="qGetTemplateChangeInfo" datasource="#application.datasource#">
					declare @price_list_header_id uniqueidentifier

					select @price_list_header_id = price_list_header.price_list_header_id
					from   Contract_Main_Aux_Data aux
					inner join price_list_header
					on    price_list_header.Price_List_ID = aux.Price_List_ID
					where aux.Contract_Main_ID = #arguments.Contract_Main_ID#

					UPDATE Program_Fixed_Price_Product_Data
					SET Fixed_Price_Value = CASE f.Unit_Of_Measure_ID WHEN 1 THEN CAST(ISNULL(price_list_detail.CS_FOB_Price, 0) as decimal(20, 3))
						ELSE CAST(ISNULL(price_list_detail.LB_FOB_Price, 0) as decimal(20, 3)) END
					FROM 	contract_products cp
					inner join Program_Fixed_Price_Product_Data f
					on    	f.Contract_Products_ID = cp.Contract_Products_ID
					and   	f.Deleted = 0
					INNER JOIN price_list_detail
					ON    	price_list_detail.price_list_header_id = @price_list_header_id
					and   	price_list_detail.Product_ID = cp.BSA_Foodservice_Items_Master_ID
					AND   	price_list_detail.deleted = 0
					WHERE 	cp.Contract_Main_ID = #arguments.Contract_Main_ID#
					and     cp.Deleted = 0
					and     cp.Product_Type_ID = 1 -- fixed price

					<!--- D30357:Today's Price Wrong on Revision History START--->
					UPDATE contract_products
					SET Base_Sales_CS = NULL
					WHERE Contract_Main_ID = #arguments.Contract_Main_ID#
					<!--- D30357:Today's Price Wrong on Revision History END--->
			</cfquery>
	</cffunction>
	<!--- D30233: Today's Price vs Requested Price END --->
	<!--- D30357:Today's Price Wrong on Revision History START--->
	<cffunction name="UpdateContractProductsBaseSalesCS" returntype="void" output="true" hint="Update Request Price with Todays Price">
		<cfargument name="Contract_Main_ID" type="numeric" required="true" >
			<cfquery name="qGetTemplateChangeInfo" datasource="#application.datasource#">
					declare @price_list_header_id uniqueidentifier

					SELECT 		@price_list_header_id = price_list_header.price_list_header_id
					FROM   		Contract_Main_Aux_Data aux
					INNER JOIN 	price_list_header
					ON    		price_list_header.Price_List_ID = aux.Price_List_ID
					WHERE 		aux.Contract_Main_ID = #arguments.Contract_Main_ID#

					UPDATE 	contract_products
					SET		Base_Sales_CS = CAST(ISNULL(price_list_detail.CS_FOB_Price, 0) as decimal(20, 3))
					FROM 	contract_products cp
					INNER JOIN price_list_detail
					ON    	price_list_detail.price_list_header_id = @price_list_header_id
					AND   	price_list_detail.Product_ID = cp.BSA_Foodservice_Items_Master_ID
					AND   	price_list_detail.deleted = 0
					WHERE 	cp.Contract_Main_ID = #arguments.Contract_Main_ID#
					AND     cp.Deleted = 0
					AND     cp.Product_Type_ID in (1, 2) -- fixed price

			</cfquery>
	</cffunction>
	<!--- D30357:Today's Price Wrong on Revision History END--->

<!--- D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months START--->
		<cffunction name="getProgramsNoBB" returntype="query">
			<cfargument name="numberOfMonths" required="true" type="numeric" />
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			<cfquery name="getPrograms" datasource="#application.datasource#">
					DECLARE 	@settingsvalue int,
									  	@daterangestart datetime
					SET	@settingsvalue = #appSettings.getCancelPgmNoBBMonths()#
					SET	@daterangestart = DATEADD(m, @settingsvalue*-1, CAST(CONVERT(CHAR(10), GETDATE(), 101) as datetime))

					IF OBJECT_ID('tempdb..##tmp_program_list') IS NOT NULL
					DROP TABLE ##tmp_program_list

					-- Get initial list of programs
					-- Find programs they were not updated in last X months

					SELECT	cm.Contract_Number, cm.Contract_Main_ID
					INTO		##tmp_program_list
					FROM		Contract_Main cm
					WHERE	cm.Approved = 1
					AND		cm.Deleted = 0
					AND		cm.Manual_Cancel = 0
					/* non-expired programs only (first check) */
					AND		cm.Contract_Status_Type_IDX <> 7
					/* non-expired programs only (second check) */
					AND		CAST(cm.Contract_End_Date As Date) > CAST(getDate() As Date)
					AND		cm.Contract_Created_Date < @daterangestart

					-- Remove programs with revisions in progress within X months
					DELETE	##tmp_program_list
					WHERE	EXISTS (
					SELECT	1
					FROM		Contract_Main cm
					WHERE	cm.Contract_Number = ##tmp_program_list.Contract_Number
					AND		cm.Deleted = 0
					AND		cm.Contract_Created_Date >= @daterangestart
					)

					-- Find programs that don't have a billback within X months
					SELECT	*
					FROM		##tmp_program_list t1
					WHERE	NOT EXISTS (
															SELECT	1
															FROM				contract_main cm
															INNER JOIN 	Billback_Program bpg
															ON					bpg.Program_ID = cm.Contract_Main_ID
															AND				bpg.Deleted = 0
															INNER JOIN 	Billback b
															ON					b.Billback_ID = bpg.Billback_ID
															AND				b.Deleted = 0
															AND				b.Created_Date >= @daterangestart
															WHERE			cm.Contract_Number = t1.Contract_Number
													)
			</cfquery>
			<cfreturn getPrograms>
		</cffunction>
<!--- D35165 :: LW ENHANCEMENT REQUEST:  Auto Close programs with no claims for 5 months END--->

	<cffunction name="getProgramCompleteSpan" output="false" returntype="query">

		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="contractNumber" required="true" type="string" />

		<!---
		 Find program complete span
		 If program is approved, use effective dates alone
		 If program is not approved, user currect version dates along with effective dates from previous versions
		 --->
		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">

			declare @start datetime,
					@end datetime,
					@versionstart datetime,
					@versionend datetime,
					@versionapproved bit,
					@contract_number varchar(20),
					@program_id int

			select	@program_id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">,
					@contract_number = <cfqueryparam value="#arguments.contractNumber#" cfsqltype="cf_sql_varchar">

			select	@versionstart = cm.Contract_Start_Date, @versionend = cm.Contract_End_Date, @contract_number = cm.Contract_Number, @versionapproved = cm.Approved
			from	Contract_Main cm
			where	cm.Contract_Main_ID = @program_id

			select	@start = Min(cm.Effective_Start_Date), @end = Max(cm.Effective_End_Date)
			from	Contract_Main cm
			where	cm.Contract_Number = @contract_number

			if (@versionend > @end and @versionapproved = 0) or @end is null
			set @end = @versionend

			if (@versionstart < @start and @versionapproved = 0) or @start is null
			set @start = @versionstart

			<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getPreActiveReplaceParent()>
			<!--- When app setting "Pre-active program replaces parent version - except for Price Protection programs" is ON, use date from latest non-approved version if there is one
			When that version is approved, that will be the dates for the whole program --->

				select	@versionstart = null, @versionend = null

				select	@versionstart = cm.Contract_Start_Date, @versionend = cm.Contract_End_Date
				from	Contract_Main cm
				where	cm.Contract_Number = @contract_number
				and		cm.Deleted = 0
				and		cm.Approved = 0

				if @versionstart is not null and @versionend is not null
				select @start = @versionstart, @end = @versionend

			</cfif>

			select	@start as Program_Start, @end as Program_End

		</cfquery>

		<cfreturn qGetProgramInfo />

	</cffunction>

		<!--- Dev Note: Kal; D42585: fiscal periods as program dates --->
		<cffunction name="getProgramGL" output="false" returntype="string">
			<cfargument name="programId" type="numeric" required="true" />

			<cfset programGLList = "" />
			<cfquery name="qGetProgramGL" datasource="#application.datasource#">
				SELECT 	DISTINCT GL_Account_ID
				FROM 		Program_Fixed_Component
				WHERE 	Deleted = 0
				AND 		Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" />
				UNION
				SELECT 	DISTINCT GL_Account_ID
				FROM 		Program_Rebates_Component
				WHERE 	Deleted = 0
				AND 		Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" />
				UNION
				SELECT 	DISTINCT GL_Account_ID
				FROM 		Program_Lump_Sums
				WHERE 	Deleted = 0
				AND 		Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" />
				UNION
				SELECT 	DISTINCT GL_Account_ID
				FROM 		Program_Growth_Components
				WHERE 	Deleted = 0
				AND 		Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" />
			</cfquery>

			<cfset programGLList = valueList(qGetProgramGL.GL_Account_ID) />
			<cfreturn programGLList />

		</cffunction>

		<cffunction name="getInvalidProgramGL" output="false" returntype="query">
			<cfargument name="programGLList" type="string" required="true" />
			<cfargument name="fiscalStartDate" type="string" required="true" />
			<cfargument name="fiscalEndDate" type="string" required="true" />

			<cfquery name="qGetInvalidProgramGL" datasource="#application.datasource#">
				SELECT 	DISTINCT GL_Account_ID,
								Gl_Account,
								GL_Account_Desc
				FROM GL_Account
				WHERE Deleted = 0
					AND GL_Account_ID IN (<cfqueryparam value="#arguments.programGLList#" cfsqltype="cf_sql_varchar" list="true">)
					AND (DateDiff(d, Start_Date, '#arguments.fiscalEndDate#') < 0
							 OR DateDiff(d, End_Date, '#arguments.fiscalStartDate#') > 0 )
			</cfquery>

			<cfreturn qGetInvalidProgramGL />

		</cffunction>

		<cffunction name="updProgramGL" output="false" returntype="void">
			<cfargument name="programID" type="numeric" required="true" />
			<cfargument name="fiscalStartDate" type="string" required="true" />

			<cfquery name="qUpdProgramGL" datasource="#application.datasource#">
				declare @Start_Date datetime, @Contract_Main_ID int
				select 	@Contract_Main_ID = #arguments.programID#,
						@Start_Date = '#arguments.fiscalStartDate#'

				IF OBJECT_ID('tempdb..##tmp_component_gl') IS NOT NULL
				DROP TABLE ##tmp_component_gl

				SELECT 	DISTINCT 1 as Discount_Type_ID, Program_Fixed_Component_ID as Program_Component_ID, Program_Fixed_Component_Name_ID as Component_Name_ID, GL_Account_ID
				INTO	##tmp_component_gl
				FROM 	Program_Fixed_Component
				WHERE 	Deleted = 0
				AND 	Program_ID = @Contract_Main_ID
				UNION
				SELECT 	DISTINCT 2 as Discount_Type_ID, Program_Rebates_Component_ID as Program_Component_ID, Program_Rebates_Component_Name_ID as Component_Name_ID, GL_Account_ID
				FROM 	Program_Rebates_Component
				WHERE 	Deleted = 0
				AND 	Program_ID = @Contract_Main_ID
				UNION
				SELECT 	DISTINCT 3 as Discount_Type_ID, Program_Lumps_Sum_Ext_Id as Program_Component_ID, Program_Lump_Sum_Name_ID as Component_Name_ID, GL_Account_ID
				FROM 	Program_Lump_Sums
				WHERE 	Deleted = 0
				AND 	Program_ID = @Contract_Main_ID
				UNION
				SELECT 	DISTINCT 4 as Discount_Type_ID, Growth_Component_Name_Id as Program_Component_ID, Program_Growth_Components_Name_Id as Component_Name_ID, GL_Account_ID
				FROM 	Program_Growth_Components
				WHERE 	Deleted = 0
				AND 	Program_ID = @Contract_Main_ID


				-- Find gl where program start date is outside gl dates
				IF OBJECT_ID('tempdb..##tmp_component_gl_date_mismatch') IS NOT NULL
				DROP TABLE ##tmp_component_gl_date_mismatch

				select	t.*
				into	##tmp_component_gl_date_mismatch
				from	##tmp_component_gl t
				inner join GL_Account
				on		GL_Account.GL_Account_ID = t.GL_Account_ID
				AND		(DateDiff(d, Start_Date, @Start_Date) < 0 OR DateDiff(d, End_Date, @Start_Date) > 0 )

				-- Get gl based on program start date from the component
				IF OBJECT_ID('tempdb..##tmp_component_new_gl') IS NOT NULL
				DROP TABLE ##tmp_component_new_gl

				select	t.*, GL_Account.GL_Account_ID as New_GL_Account_ID, COUNT(*) OVER (PARTITION BY t.Discount_Type_ID, t.Program_Component_ID) as GL_Per_Component
				into	##tmp_component_new_gl
				from	##tmp_component_gl_date_mismatch t
				INNER JOIN GL_Component_Mapping
				ON		GL_Component_Mapping.Component_Name_ID = t.Component_Name_ID
				AND		GL_Component_Mapping.Discount_Type_ID = t.Discount_Type_ID
				INNER JOIN GL_Account
				ON		GL_Account.GL_Account_ID = GL_Component_Mapping.GL_Account_ID
				AND		GL_Account.Deleted = 0
				AND		@Start_Date BETWEEN GL_Account.Start_Date AND GL_Account.End_Date

				-- Update component with new GL if current GL is invalid based o program dates and there is a single GL per component available based on program dates
				UPDATE	c
				SET		GL_Account_ID = t.New_GL_Account_ID
				FROM	##tmp_component_new_gl t
				INNER JOIN Program_Fixed_Component c
				ON		c.Program_Fixed_Component_ID = t.Program_Component_ID
				WHERE	t.GL_Per_Component = 1
				AND		t.Discount_Type_ID = 1

				UPDATE	c
				SET		GL_Account_ID = t.New_GL_Account_ID
				FROM	##tmp_component_new_gl t
				INNER JOIN Program_Rebates_Component c
				ON		c.Program_Rebates_Component_ID = t.Program_Component_ID
				WHERE	t.GL_Per_Component = 1
				AND		t.Discount_Type_ID = 2

				UPDATE	c
				SET		GL_Account_ID = t.New_GL_Account_ID
				FROM	##tmp_component_new_gl t
				INNER JOIN Program_Lump_Sums c
				ON		c.Program_Lumps_Sum_Ext_Id = t.Program_Component_ID
				WHERE	t.GL_Per_Component = 1
				AND		t.Discount_Type_ID = 3


				UPDATE	c
				SET		GL_Account_ID = t.New_GL_Account_ID
				FROM	##tmp_component_new_gl t
				INNER JOIN Program_Growth_Components c
				ON		c.Growth_Component_Name_Id = t.Program_Component_ID
				WHERE	t.GL_Per_Component = 1
				AND		t.Discount_Type_ID = 4

			</cfquery>

		</cffunction>

		<!--- Get a list of documents attached to "program qualifications". --->
		<cffunction name="getProgramQualificationDocs" output="false" returntype="query">
			<cfargument name="programId" type="numeric" required="true" />

			<cfquery name="qgetProgramQualificationDocs" datasource="#application.datasource#">
				SELECT Document_Details.Doc_File_Name, convert(varchar(10),Document_Details.Uploaded_Date,101) As Uploaded_Date, _Users.Name_First + ' ' + _Users.Name_Last As fullName
					 ,Document_Details.Doc_Uni_Name, Document_Details.Doc_ID, Document_Details.Doc_Size
				FROM Document_Details
					INNER JOIN Contract_Attachments
				ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
					INNER JOIN _Users
				ON Document_Details.Uploaded_By = _Users.User_ID
				WHERE Contract_Attachments.Program_ID = '#arguments.programId#'
				AND Document_Details.deleted = 0
				AND Contract_Attachments.deleted = 0
			</cfquery>

			<cfreturn qgetProgramQualificationDocs />
		</cffunction>

		<!--- Get programs details. --->
		<cffunction name="getProgramDetails" output="false" returntype="query">
			<cfargument name="programList" type="string" required="true" />

			<cfquery name="qgetProgramDetails" datasource="#application.datasource#">
				SELECT
					CM.Contract_Main_ID
					,Replace(CM.Contract_Number, '000-', '') +
						(CASE WHEN CM.Contract_Status_Type_IDX > 2
							THEN '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END
							ELSE ''
						END)
						As Contract_Number
					,CM.Contract_Number As Contract_Number_Short_Version					,
					(
					SELECT 1
					FROM Contract_Main
					WHERE Contract_Main_ID IN (<cfqueryparam value="#arguments.programList#" cfsqltype="cf_sql_varchar" list="true">)
					AND Revision_of_contract_Main_ID = CM.Contract_Main_ID
					/* revision can be approved or unapproved */
					AND (Approved = 1 OR Deleted = 0)
					)
					As Is_Parent
					,
					(
					SELECT contract_Main_ID
					FROM Contract_Main
					WHERE Contract_Main_ID IN (<cfqueryparam value="#arguments.programList#" cfsqltype="cf_sql_varchar" list="true">)
					AND Revision_of_contract_Main_ID = CM.Contract_Main_ID
					AND (Approved = 1 OR Deleted = 0)
					)
					As Child_Contract_Main_ID
					,CM.Contract_Title
					,CM.Is_A_Revision
					,CONVERT(char(10),CM.Contract_Start_Date,101) As Contract_Start_Date
					,CONVERT(char(10),CM.Contract_End_Date,101) As Contract_End_Date
					,CONVERT(char(10),CM.Effective_Start_Date,101) As Effective_Start_Date
					,CONVERT(char(10),CM.Effective_End_Date,101) As Effective_End_Date
					,PCPO.Created_Type
					,CST.Contract_Status_Type_Desc
					,U1.Name_First + ' ' + U1.Name_Last As RSP

				FROM Contract_Main CM
					INNER JOIN Program_Control_Panel_Options PCPO
				ON CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
					INNER JOIN Contract_Status_Types CST
				ON CST.Contract_Status_Type_ID = CM.Contract_Status_Type_IDX
					INNER JOIN _Users U1
				ON U1.User_ID = CM.Responsible_User_ID

				<!---
				Need to show all the versions of the program, so that the user is aware
				of the other versions too before making a date change.
				--->
				WHERE CM.Contract_Number IN
				(
					SELECT Contract_Number
					FROM Contract_Main
					WHERE Contract_Main_ID IN (<cfqueryparam value="#arguments.programList#" cfsqltype="cf_sql_varchar" list="true">)
				)
				<!--- The status should be preactive only. --->
				AND CM.Contract_Status_Type_IDX =  4
				<!--- Just get the valid pre-active versions --->
				AND  CM.deleted = 0
				<!--- Get all the preactive versions of the program where effective date is not null --->
				<!---
				AND CM.Effective_Start_Date IS NOT NULL
				AND CM.Effective_End_Date IS NOT NULL
				--->
				ORDER BY CM.Contract_Number
			</cfquery>

			<cfreturn qgetProgramDetails />
		</cffunction>

		<!--- update program start date from the "modify pre-active dates" tool. --->
		<cffunction name="updProgramStartDate" output="false" returntype="void">
			<cfargument name="programId" type="numeric" required="true" />
			<cfargument name="contractNumber" type="string" required="true" />
			<cfargument name="userId" type="string" required="true" />
			<cfargument name="originalStartDate" type="date" required="true" />
			<cfargument name="modifiedStartDate" type="date" required="true" />
			<cfargument name="batchNumber" type="numeric" required="true" />

			<!--- update program start date -
			Note: We are already adding the date change in a log table (Contract_Start_Date_Change_History) below.
			The purpose of adding a bit column "Change_Start_Date_Preactive_Version" below is following -
				By looking at this column, we will know that there is a process that actually updates the start date
				for preactive programs.
			--->
			<cfquery name="qUpdProgramInfo" datasource="#application.datasource#">
				UPDATE Contract_Main
				SET Contract_Start_Date = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.modifiedStartDate#" />,
					Change_Start_Date_Preactive_Version = 1
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#"  />
			</cfquery>

			<!--- updates the end date for a version prior to the preactive version for which the start date was modified.
			End date is set to the new start date minus 1 day.
			--->
			<cfquery name="qUpdProgramInfoPreviousVersion" datasource="#application.datasource#">
				UPDATE Contract_Main
				SET	Contract_End_Date = DateAdd(d,-1,'#arguments.modifiedStartDate#')
				WHERE Contract_Main_ID =
				(
				SELECT Revision_of_contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#"  />
				<!--- Previous version needs to be approved.--->
				AND Approved = 1
				)
			</cfquery>

			<!--- Re-run "effective dates" SP. --->
			<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#arguments.programId#" null="no">
			</cfstoredproc>

			<!--- log entry --->
			<cfquery name="qInsertLog" datasource="#application.datasource#">
				INSERT INTO Contract_Start_Date_Change_History(Contract_Main_ID, Contract_Number, User_ID, Original_Start_Date, Modified_Start_Date, Batch_Number)
				VALUES(#arguments.programId#, '#arguments.contractNumber#', '#arguments.userId#', '#arguments.originalStartDate#', '#arguments.modifiedStartDate#', #arguments.batchNumber#)
			</cfquery>
		</cffunction>

		<!--- get the number of times user has modified start dates from the  "modify pre-active dates" tool. --->
		<cffunction name="getMaxEntryForContractStartDateChangeHistory" output="false" returntype="numeric">

			<cfset var batchNumber = 0>

			<cfquery name="qgetMaxEntryForContractStartDateChangeHistory" datasource="#application.datasource#">
				SELECT Max(Batch_Number) As Max_Batch_Number
				FROM Contract_Start_Date_Change_History
			</cfquery>

			<cfif qgetMaxEntryForContractStartDateChangeHistory.Max_Batch_Number GT 0>
				<cfset batchNumber = qgetMaxEntryForContractStartDateChangeHistory.Max_Batch_Number>
			</cfif>

			<cfset batchNumber = batchNumber + 1>

			<cfreturn batchNumber />
		</cffunction>

		<!--- Get list of programs for the last batch of programs for which start or end dates were modified.
		Since we are modifying the dates of programs from the "modify pre-active dates" tool,
		the user needs to know what impact it has on the effective dates.
		The objective here is to show all the versions of the programs where the effective date is
		populated (for the "modify pre-active" tool)
		For "delete pre-active" tool, we cannot use effective date not being null, because then the
		deleted version version will not show up.
		--->
		<cffunction name="getContractDateChangeHistory" output="false" returntype="query">
			<cfargument name="reportType" type="numeric" required="true" />

			<cfquery name="qGetContractDateChangeHistory" datasource="#application.datasource#">
				SELECT
					CST.Contract_Status_Type_Desc
					,Replace(CM.Contract_Number, '000-', '') +
						(CASE WHEN CM.Contract_Status_Type_IDX > 2
							THEN '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END
							ELSE ''
						END)
						As Contract_Number
					,PCPO.Created_Type
					,CM.Contract_Title
					,CONVERT(char(10),CM.Contract_Start_Date,101) As Contract_Start_Date
					,CONVERT(char(10),CM.Contract_End_Date,101) As Contract_End_Date
					,CONVERT(char(10),CM.Effective_Start_Date,101) As Effective_Start_Date
					,CONVERT(char(10),CM.Effective_End_Date,101) As Effective_End_Date
					,U1.Name_First + ' ' + U1.Name_Last As RSP
				FROM

				<cfif arguments.reportType eq 0>
				Contract_Start_Date_Change_History CSDCH
				<cfelseif arguments.reportType eq 1>
				Contract_End_Date_Change_History CSDCH
				</cfif>

					INNER JOIN	Contract_Main CM
				ON	CSDCH.Contract_Number = CM.Contract_Number
					INNER JOIN Program_Control_Panel_Options PCPO
				ON CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
					INNER JOIN Contract_Status_Types CST
				ON CST.Contract_Status_Type_ID = CM.Contract_Status_Type_IDX
						INNER JOIN _Users U1
				ON U1.User_ID = CM.Responsible_User_ID
				<!--- For the "modify preactive dates" report, check for effective dates not being NULL. --->
				<cfif arguments.reportType eq 0>
				WHERE CM.Effective_Start_Date IS NOT NULL
				AND CM.Effective_End_Date IS NOT NULL
				AND
				<!--- For "delete pre-active" tool, we cannot use effective date not being null, because then the
				deleted version version will not show up --->
				<cfelseif arguments.reportType eq 1>
				WHERE
				</cfif>

				CSDCH.Batch_Number =
				(
					SELECT Max(Batch_Number)
					FROM
					<cfif arguments.reportType eq 0>
					Contract_Start_Date_Change_History
					<cfelseif arguments.reportType eq 1>
					Contract_End_Date_Change_History
					</cfif>
				)
				ORDER BY CM.Contract_Number
			</cfquery>

			<cfreturn qGetContractDateChangeHistory />
		</cffunction>

			<!--- update program end date from the "delete pre-active dates" tool. --->
		<cffunction name="updProgramEndDate" output="false" returntype="void">
			<cfargument name="programId" type="numeric" required="true" />
			<cfargument name="contractNumber" type="string" required="true" />
			<cfargument name="userId" type="string" required="true" />
			<cfargument name="originalEndDate" type="date" required="true" />
			<cfargument name="modifiedEndDate" type="date" required="true" />
			<cfargument name="batchNumber" type="numeric" required="true" />

			<!--- update program end date -
			Note: We are already adding the date change in a log table (Contract_End_Date_Change_History) below.
			The purpose of adding a bit column "Change_End_Date_Delete_Preactive_Versionn" below is following -
				By looking at this column, we will know that there is a process that actually updates the end date
				for a version prior to the preactive version for which the end date was modified.
			--->
			<cfquery name="qUpdProgramInfoPreviousVersion" datasource="#application.datasource#">
				UPDATE Contract_Main
				SET	Contract_End_Date = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.modifiedEndDate#" />,
						Change_End_Date_Delete_Preactive_Version = 1
				WHERE Contract_Main_ID =
				(
				SELECT Revision_of_contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#"  />
				<!--- Previous version needs to be approved.--->
				AND Approved = 1
				)
			</cfquery>

			<!---- Delete the pre-active version for which the end date was changed from the application.
			The end date is actually applied for the version prior to tthe version where the end date was applied (see above query)
			--->
			<cfquery name="qUpdProgramInfo" datasource="#application.datasource#">
				UPDATE Contract_Main
				SET	Approved = 0,
					Deleted = 1,
					Revision_Version = 1
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.programId#"  />
			</cfquery>

			<!--- Re-run "effective dates" SP. --->
			<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#arguments.programId#" null="no">
			</cfstoredproc>

			<!--- log entry --->
			<cfquery name="qInsertLog" datasource="#application.datasource#">
				INSERT INTO Contract_End_Date_Change_History(Contract_Main_ID, Contract_Number, User_ID, Original_End_Date, Modified_End_Date, Batch_Number)
				VALUES(#arguments.programId#, '#arguments.contractNumber#', '#arguments.userId#', '#arguments.originalEndDate#', '#arguments.modifiedEndDate#', #arguments.batchNumber#)
			</cfquery>
		</cffunction>

		<!--- get the number of times user has modified end dates from the  "delete pre-active dates" tool. --->
		<cffunction name="getMaxEntryForContractEndDateChangeHistory" output="false" returntype="numeric">
			<cfset var batchNumber = 0>

			<cfquery name="qgetMaxEntryForContractEndDateChangeHistory" datasource="#application.datasource#">
				SELECT Max(Batch_Number) As Max_Batch_Number
				FROM Contract_End_Date_Change_History
			</cfquery>

			<cfif qgetMaxEntryForContractEndDateChangeHistory.Max_Batch_Number GT 0>
				<cfset batchNumber = qgetMaxEntryForContractEndDateChangeHistory.Max_Batch_Number>
			</cfif>

			<cfset batchNumber = batchNumber + 1>

			<cfreturn batchNumber />
		</cffunction>

		<!--- Get program revision details. --->
		<cffunction name="getProgramRevisions" output="false" returntype="query">
			<cfargument name="programList" type="string" required="true" />

			<cfquery name="qgetProgramRevisions" datasource="#application.datasource#">
				SELECT
					CST.Contract_Status_Type_Desc
					,Replace(CM.Contract_Number, '000-', '') +
						(CASE WHEN CM.Contract_Status_Type_IDX > 2
							THEN '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END
							ELSE ''
						END)
						As Contract_Number
					,PCPO.Created_Type
					,CM.Contract_Title
					,CONVERT(char(10),CM.Contract_Start_Date,101) As Contract_Start_Date
					,CONVERT(char(10),CM.Contract_End_Date,101) As Contract_End_Date
					,CONVERT(char(10),CM.Effective_Start_Date,101) As Effective_Start_Date
					,CONVERT(char(10),CM.Effective_End_Date,101) As Effective_End_Date
					,U1.Name_First + ' ' + U1.Name_Last As RSP

				FROM Contract_Main CM
					INNER JOIN Program_Control_Panel_Options PCPO
				ON CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
					INNER JOIN Contract_Status_Types CST
				ON CST.Contract_Status_Type_ID = CM.Contract_Status_Type_IDX
					INNER JOIN _Users U1
				ON U1.User_ID = CM.Responsible_User_ID

				<!--- Get all the revisions of the program.
				Before changing the start or end date, it is good to know the program's existing revisions.
				Note: Even WIP revisions are revisions.
				--->
				WHERE CM.Revision_of_contract_Main_ID IN
							(
								SELECT Contract_Main_ID
								FROM Contract_Main
								WHERE Contract_Main_ID IN (<cfqueryparam value="#arguments.programList#" cfsqltype="cf_sql_varchar" list="true">)
								/* revision can be approved or unapproved */
								AND
								(Approved = 1
								OR
								deleted = 0)
							 )

				<!--- Do not include selected program versions. --->
				AND CM.Contract_Main_ID NOT IN (<cfqueryparam value="#arguments.programList#" cfsqltype="cf_sql_varchar" list="true">)
				ORDER BY CM.Contract_Number
			</cfquery>

			<cfreturn qgetProgramRevisions />
		</cffunction>

		<!---- Check whether any of the distributors - group or single added on the program is not a planning group. (REBATE) --->
		<cffunction name="checkProgramDistributorsWithoutPlanningGroupForRebate" output="false" returntype="query">
		   <cfargument name="programID" type="numeric" required="true" />
				<!--- Note: Since the "Distributor_Group_Level_ID" of distributors is 0, we did a left join
				on Distributor_Group_Level below to also catch any distributors (not group members) which
				exist on the program. IsNull(Distributor_Group_Level.Is_PG,0) will make sure that null entries get caught.
				 Distributors  (not group members) have a null entry.
				--->
				<cfquery name="qryProgramDistributorsWithoutPlanningGroupForRebate" datasource="#application.datasource#">
					SELECT DISTINCT BSA_Foodservice_Customers.Shr_Ship_To, BSA_Foodservice_Customers.Name
					FROM Program_Rebates_Component
					INNER JOIN Contract_Distributors
					ON    Contract_Distributors.Contract_Main_ID = Program_Rebates_Component.Program_ID
					INNER JOIN BSA_Foodservice_Customers
					ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
					LEFT JOIN Distributor_Group_Level
					ON Contract_Distributors.Distributor_Group_Level_ID = Distributor_Group_Level.Distributor_Group_Level_ID
					WHERE Contract_Distributors.Contract_Main_ID = '#arguments.programID#'
					AND Contract_Distributors.Deleted = 0
					/* Is not a planning group */
					AND IsNull(Distributor_Group_Level.Is_PG,0) <> 1
					/* No need to check members of the group */
					AND Contract_Distributors.Captured_From_Group = 0
					AND Program_Rebates_Component.deleted = 0
					/* Payee option is "Payee from planing groups" */
					AND Program_Rebates_Component.Vendor_Selection = 3
				</cfquery>
		       <cfreturn qryProgramDistributorsWithoutPlanningGroupForRebate />
		</cffunction>

		<!--- Check whether the planning group has a payee (distributor and vendor)  (REBATE) ---->
		<cffunction name="checkPlanningGroupWithoutPayeeForRebate" output="false" returntype="query">
		   <cfargument name="programID" type="numeric" required="true" />
				<cfquery name="qryPlanningGroupWithoutPayeeForRebate" datasource="#application.datasource#">
				SELECT  DISTINCT PG_Customer_Category.PG_Customer_Category_Name, 'Distributor' As PayeeType
				FROM Program_Rebates_Component
				INNER JOIN Payment_Type ON
				Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
				INNER JOIN Contract_Distributors
				ON    Contract_Distributors.Contract_Main_ID = Program_Rebates_Component.Program_ID
				INNER JOIN PG_Customer_Category
				ON PG_Customer_Category.PG_Customer_Category_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
				LEFT JOIN BSA_Foodservice_Customers
				ON    BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = PG_Customer_Category.distributor_id
				WHERE Contract_Distributors.Contract_Main_ID = '#arguments.programID#'
				AND Contract_Distributors.Deleted = 0
				AND Contract_Distributors.Is_Group = 1
				/* planning group without a "distributor" payee */
				AND PG_Customer_Category.distributor_id IS NULL
				AND Program_Rebates_Component.deleted = 0
				/* payee is a "distributor". */
				AND isnull(nullif(Program_Rebates_Component.Payee_Type,''),0) = 1
				/* "Auto pay" must be ON for the claim mechanism. */
				AND Payment_Type.Is_Auto_Pay = 1
				/* Payee option is "Payee from planing groups" */
				AND Program_Rebates_Component.Vendor_Selection = 3

				UNION

				SELECT  DISTINCT PG_Customer_Category.PG_Customer_Category_Name, 'Vendor' As PayeeType
				FROM Program_Rebates_Component
				INNER JOIN Payment_Type ON
				Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
				INNER JOIN Contract_Distributors
				ON    Contract_Distributors.Contract_Main_ID = Program_Rebates_Component.Program_ID
				INNER JOIN PG_Customer_Category
				ON PG_Customer_Category.PG_Customer_Category_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
				LEFT JOIN Vendor_Master
				ON Vendor_Master.vendor_master_id = PG_Customer_Category.vendor_master_id
				WHERE Contract_Distributors.Contract_Main_ID = '#arguments.programID#'
				AND Contract_Distributors.Deleted = 0
				AND Contract_Distributors.Is_Group = 1
				/* planning group without a "vendor" payee */
				AND   PG_Customer_Category.vendor_master_id IS NULL
				AND Program_Rebates_Component.deleted = 0
				/* payee is a "vendor". */
				AND isnull(nullif(Program_Rebates_Component.Payee_Type,''),0) = 5
				/* "Auto pay" must be ON for the claim mechanism. */
				AND Payment_Type.Is_Auto_Pay = 1
				/* Payee option is "Payee from planing groups" */
				AND Program_Rebates_Component.Vendor_Selection = 3
				</cfquery>
		       <cfreturn qryPlanningGroupWithoutPayeeForRebate />
		</cffunction>

		<!---- Check whether any of the distributors - group or single added on the program is not a planning group. (GROWTH) --->
		<cffunction name="checkProgramDistributorsWithoutPlanningGroupForGrowth" output="false" returntype="query">
		   <cfargument name="programID" type="numeric" required="true" />
				<!--- Note: Since the "Distributor_Group_Level_ID" of distributors is 0, we did a left join
				on Distributor_Group_Level below to also catch any distributors (not group members) which
				exist on the program. IsNull(Distributor_Group_Level.Is_PG,0) will make sure that null entries get caught.
				 Distributors  (not group members) have a null entry.
				--->
				<cfquery name="qryProgramDistributorsWithoutPlanningGroupForGrowth" datasource="#application.datasource#">
					SELECT DISTINCT BSA_Foodservice_Customers.Shr_Ship_To, BSA_Foodservice_Customers.Name
					FROM Program_Growth_Components
					INNER JOIN Contract_Distributors
					ON    Contract_Distributors.Contract_Main_ID = Program_Growth_Components.Program_ID
					INNER JOIN BSA_Foodservice_Customers
					ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
					LEFT JOIN Distributor_Group_Level
					ON Contract_Distributors.Distributor_Group_Level_ID = Distributor_Group_Level.Distributor_Group_Level_ID
					WHERE Contract_Distributors.Contract_Main_ID = '#arguments.programID#'
					AND Contract_Distributors.Deleted = 0
					/* Is not a planning group */
					AND IsNull(Distributor_Group_Level.Is_PG,0) <> 1
					/* No need to check members of the group */
					AND Contract_Distributors.Captured_From_Group = 0
					AND Program_Growth_Components.deleted = 0
					/* Payee option is "Payee from planing groups" */
					AND Program_Growth_Components.Vendor_Selection = 3
				</cfquery>
		       <cfreturn qryProgramDistributorsWithoutPlanningGroupForGrowth />
		</cffunction>

		<!--- Check whether the planning group has a payee (distributor and vendor)  (GROWTH) ---->
		<cffunction name="checkPlanningGroupWithoutPayeeForGrowth" output="false" returntype="query">
		   <cfargument name="programID" type="numeric" required="true" />
				<cfquery name="qryPlanningGroupWithoutPayeeForGrowth" datasource="#application.datasource#">
				SELECT  DISTINCT PG_Customer_Category.PG_Customer_Category_Name, 'Distributor' As PayeeType
				FROM Program_Growth_Components
				INNER JOIN Payment_Type ON
				Payment_Type.Payment_Type_ID = Program_Growth_Components.Claim_Mechanics
				INNER JOIN Contract_Distributors
				ON    Contract_Distributors.Contract_Main_ID = Program_Growth_Components.Program_ID
				INNER JOIN PG_Customer_Category
				ON PG_Customer_Category.PG_Customer_Category_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
				LEFT JOIN BSA_Foodservice_Customers
				ON    BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = PG_Customer_Category.distributor_id
				WHERE Contract_Distributors.Contract_Main_ID = '#arguments.programID#'
				AND Contract_Distributors.Deleted = 0
				AND Contract_Distributors.Is_Group = 1
				/* planning group without a "distributor" payee */
				AND PG_Customer_Category.distributor_id IS NULL
				AND Program_Growth_Components.deleted = 0
				/* payee is a "distributor". */
				AND isnull(nullif(Program_Growth_Components.Payee_Type,''),0) = 1
				/* "Auto pay" must be ON for the claim mechanism. */
				AND Payment_Type.Is_Auto_Pay = 1
				/* Payee option is "Payee from planing groups" */
				AND Program_Growth_Components.Vendor_Selection = 3

				UNION

				SELECT  DISTINCT PG_Customer_Category.PG_Customer_Category_Name, 'Vendor' As PayeeType
				FROM Program_Growth_Components
				INNER JOIN Payment_Type ON
				Payment_Type.Payment_Type_ID = Program_Growth_Components.Claim_Mechanics
				INNER JOIN Contract_Distributors
				ON    Contract_Distributors.Contract_Main_ID = Program_Growth_Components.Program_ID
				INNER JOIN PG_Customer_Category
				ON PG_Customer_Category.PG_Customer_Category_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
				LEFT JOIN Vendor_Master
				ON Vendor_Master.vendor_master_id = PG_Customer_Category.vendor_master_id
				WHERE Contract_Distributors.Contract_Main_ID = '#arguments.programID#'
				AND Contract_Distributors.Deleted = 0
				AND Contract_Distributors.Is_Group = 1
				/* planning group without a "vendor" payee */
				AND   PG_Customer_Category.vendor_master_id IS NULL
				AND Program_Growth_Components.deleted = 0
				/* payee is a "vendor". */
				AND isnull(nullif(Program_Growth_Components.Payee_Type,''),0) = 5
				/* "Auto pay" must be ON for the claim mechanism. */
				AND Payment_Type.Is_Auto_Pay = 1
				/* Payee option is "Payee from planing groups" */
				AND Program_Growth_Components.Vendor_Selection = 3
				</cfquery>
		       <cfreturn qryPlanningGroupWithoutPayeeForGrowth />
		</cffunction>
	<!----  D50074 :: Viewing and Editing prior program versions START --->
		<cffunction name="ModifyDeletedProgram" output="false" returntype="numeric">
			<cfargument name="programID" type="numeric" required="true" />
			<cfargument name="Profile_Modify_Expired_Programs" type="numeric" required="true" />
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			<cfset var batchNumber = 0>
			<cfif appSettings.getModifyExpiredPrograms() AND arguments.Profile_Modify_Expired_Programs>
				<cfquery name="qModifyDeletedProgram" datasource="#application.datasource#">
					SELECT 	*
					FROM contract_main
					WHERE contract_main_id = <cfqueryparam value="#arguments.programID#" cfsqltype="cf_sql_integer">
					AND Revision_version != 0
					AND Approved = 1
					AND Deleted = 1
					AND Effective_Start_Date is not null
					-----AND Contract_Status_Type_IDX = 7 WE NO LONGER RESTRICT USER BASED ON STATUS D57639
				</cfquery>
				<cfset batchNumber = qModifyDeletedProgram.recordcount>
			</cfif>

			<cfreturn batchNumber />
		</cffunction>
	<!---  D50074 :: Viewing and Editing prior program versions END --->


		<cffunction name="getTypeCodesFromPaymentHistory" output="false" returntype="query">
		   <cfargument name="contractNumber" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfargument name="plannerID" required="false" type="string" default="0" />

			<cfquery name="qGetTypeCodesFromPaymentHistory" datasource="#application.datasource#">
				SELECT DISTINCT tcd.Type_Code_Desc,tcd.Type_Code_Legacy,
					bfim.Type_Code_Desc_ID
				FROM Payment_History_Item_Details phd
				INNER JOIN
					BSA_Foodservice_Items_Master bfim
				ON phd.Product_ID = bfim.BSA_Foodservice_Items_Master_ID
				INNER JOIN
					Type_Code_Desc tcd
				ON bfim.Type_Code_Desc_ID = tcd.Type_Code_Desc_ID

				<cfif val(arguments.plannerID)>
				WHERE phd.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phd.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE phd.contract_number = '#arguments.contractNumber#'
				</cfif>
				AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')
				ORDER BY tcd.Type_Code_Desc
			</cfquery>

			<cfreturn qGetTypeCodesFromPaymentHistory />
		</cffunction>

		<cffunction name="getDistributorsFromPaymentHistory" output="false" returntype="query">
		   <cfargument name="contractNumber" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfargument name="plannerID" required="false" type="string" default="0" />

			<cfquery name="qGetDistributorsFromPaymentHistory" datasource="#application.datasource#">
			SELECT DISTINCT bfc.Name,bfc.Shr_ship_to,
					bfc.BSA_Foodservice_Customers_ID,df.Family_Name

				FROM Payment_History_Details phd
				INNER JOIN
					BSA_Foodservice_Customers bfc
				ON phd.payee_unique_id = bfc.BSA_Foodservice_Customers_ID
				INNER JOIN
					Distributor_Family df
				ON df.Family_ID = bfc.Family_ID

				<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phd.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE phd.contract_number = '#arguments.contractNumber#'
				</cfif>
				AND phd.payee_type = 1
				AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')

				UNION

				SELECT DISTINCT bfc.Name,bfc.Shr_ship_to,
					bfc.BSA_Foodservice_Customers_ID,df.Family_Name

				FROM Payment_History_Operator_Offinvoice_Details phd
				INNER JOIN
					BSA_Foodservice_Customers bfc
				ON phd.BSA_Foodservice_Customers_ID = bfc.BSA_Foodservice_Customers_ID
				INNER JOIN
					Distributor_Family df
				ON df.Family_ID = bfc.Family_ID

				<cfif val(arguments.plannerID)>
				WHERE phd.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phd.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE phd.contract_number = '#arguments.contractNumber#'
				</cfif>
				ORDER BY df.Family_Name, bfc.Name
			</cfquery>

			<cfreturn qGetDistributorsFromPaymentHistory />
		</cffunction>

		<cffunction name="getOperatorsFromPaymentHistory" output="false" returntype="query">
		   <cfargument name="contractNumber" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfargument name="plannerID" required="false" type="string" default="0" />

			<cfquery name="qGetOperatorsFromPaymentHistory" datasource="#application.datasource#">
				SELECT DISTINCT bsaop.Operator_Name,
					case when ISNULL(bsaop.legacy_id, '0') != '0'
						then legacy_id
					else
					cast(bsaop.BSA_Operator_id as varchar(50))
					end
				as payee_id,
				bsaop.BSA_Operator_ID

				FROM Payment_History_Details phd
				INNER JOIN
					BSA_Operator bsaop
				ON phd.payee_unique_id = bsaop.BSA_Operator_ID

				<cfif val(arguments.plannerID)>
				WHERE phd.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phd.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE phd.contract_number = '#arguments.contractNumber#'
				</cfif>
				AND phd.payee_type = 2
				AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')
				ORDER BY bsaop.Operator_Name
			</cfquery>

			<cfreturn qGetOperatorsFromPaymentHistory />
		</cffunction>

		<cffunction name="getBrokersFromPaymentHistory" output="false" returntype="query">
		   <cfargument name="contractNumber" type="string" required="true" />
			<cfargument name="contractMainID" required="true" type="string" />
			<cfargument name="plannerID" required="false" type="string" default="0" />

			<cfquery name="qGetBrokersFromPaymentHistory" datasource="#application.datasource#">
				SELECT DISTINCT bsafb.Broker_Name,
					bsafb.broker_shard,
					bsafb.BSA_Foodservice_Brokers_ID

				FROM Payment_History_Details phd
				INNER JOIN
					BSA_Foodservice_Brokers bsafb
				ON phd.payee_unique_id = bsafb.BSA_Foodservice_Brokers_ID

				<cfif val(arguments.plannerID)>
				WHERE phd.Planner_ID = #val(arguments.plannerID)#
				<cfelseif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
				WHERE phd.contract_main_id = #arguments.contractMainID#
				<cfelse>
				WHERE phd.contract_number = '#arguments.contractNumber#'
				</cfif>
				AND phd.payee_type = 3
				AND phd.billback_id NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000001')
				ORDER BY bsafb.Broker_Name
			</cfquery>
			<cfreturn qGetBrokersFromPaymentHistory />
		</cffunction>


		<cffunction name="getProgramPaidToType" output="false" returntype="string">
		   <cfargument name="contractNumber" type="string" required="true" />

		   <cfset var listPaidTo = "">

			<cfquery name="qGetProgramPaidToType" datasource="#application.datasource#">
			SELECT DISTINCT pfc.fixed_component_paid_to As component_paid_to
			FROM Program_Fixed_Component pfc
			WHERE pfc.Program_ID IN
			(
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Number = '#arguments.contractNumber#'
				AND Approved = 1
				AND Effective_Start_Date IS NOT NULL
				AND Effective_End_Date IS NOT NULL
			)
			AND pfc.Deleted = 0

			UNION

			SELECT DISTINCT prc.component_paid_to As component_paid_to
			FROM Program_Rebates_Component prc
			WHERE prc.Program_ID IN
			(
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Number = '#arguments.contractNumber#'
				AND Approved = 1
				AND Effective_Start_Date IS NOT NULL
				AND Effective_End_Date IS NOT NULL
			)
			AND prc.Deleted = 0

			UNION

			SELECT DISTINCT pgp.component_paid_to As component_paid_to
			FROM Program_Growth_Components pgp
			WHERE pgp.Program_ID IN
			(
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Number = '#arguments.contractNumber#'
				AND Approved = 1
				AND Effective_Start_Date IS NOT NULL
				AND Effective_End_Date IS NOT NULL
			)
			AND pgp.Deleted = 0


			UNION

			SELECT DISTINCT pls.component_paid_to As component_paid_to
			FROM Program_Lump_Sums pls
			WHERE pls.Program_ID IN
			(
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Contract_Number = '#arguments.contractNumber#'
				AND Approved = 1
				AND Effective_Start_Date IS NOT NULL
				AND Effective_End_Date IS NOT NULL
			)
			AND pls.Deleted = 0
			</cfquery>

			<cfset listPaidTo = ValueList(qGetProgramPaidToType.component_paid_to)>

			<cfreturn listPaidTo />

		</cffunction>

		<cffunction name="getEmailLog" output="false" returntype="struct">
			<cfargument name="ContractId" required="false" default="" />
			<cfargument name="listOfWords" type="string" required="false" default="" />
			<cfargument name="startRow" type="numeric" required="false" default="0" />
			<cfargument name="endRow" type="numeric" required="false" default="0" />
			<cfargument name="sType" required="false" type="string" default="" />
			<cfargument name="column_sequence_number" type="string" required="false" default="0"/>
			<cfargument name="sort_order" type="string" required="false" default="asc" />

			<cfset iType = 0 />
			<cfif arguments.sType EQ "Letters">
				<cfset iType = 15 />
			<cfelseif arguments.sType EQ "Claim Rates">
				<cfset iType = 16 />
			<cfelseif arguments.sType EQ "Claim Rates & Letters">
				<cfset iType = 17 />
			</cfif>

			<cfset var returnStruct = StructNew()>
			<cfquery name="qGetContractNumber" datasource="#application.datasource#">
				SELECT Contract_Number FROM Contract_Main WHERE Contract_main_ID = '#arguments.ContractId#'
			</cfquery>
			<cfquery name="delTmpTblEmailLogData" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpTblEmailLogData') IS NOT NULL
			DROP TABLE ##tmpTblEmailLogData

			IF OBJECT_ID('tempdb..##tmpTblEmailAllLogData') IS NOT NULL
			DROP TABLE ##tmpTblEmailAllLogData

			CREATE TABLE ##tmpTblEmailAllLogData (
				rowIDInt INT IDENTITY(1, 1),
				Message_Log_ID VARCHAR (MAX),
				Message_To VARCHAR (MAX),
				Message_From VARCHAR (MAX),
				Message_Subject VARCHAR (MAX),
				Message VARCHAR (MAX),
				Message_Generated_By_ID VARCHAR (MAX),
				App_Area_ID VARCHAR (MAX),
				App_Area_Identifier VARCHAR (MAX),
				Sent_Date VARCHAR (MAX),
				App_Area_Sub_Identifier VARCHAR (MAX),
				Created_Date VARCHAR (MAX),
				Letter_Name VARCHAR (MAX),
				Letter_Type VARCHAR (MAX),
				Letter_Path VARCHAR (MAX),
				Contract_Number VARCHAR (MAX),
				Contract_Main_ID VARCHAR (MAX),
				Contract_Revision_Number VARCHAR (MAX)
 			)
			</cfquery>

			<!--- Insert the rows into the temp table --->
			<cfquery name="qGetEmailLogData" datasource="#application.datasource#">
				INSERT INTO ##tmpTblEmailAllLogData(
					Message_Log_ID,
					Message_To,
					Message_From ,
					Message_Subject ,
					Message ,
					Message_Generated_By_ID ,
					App_Area_ID ,
					App_Area_Identifier ,
					Sent_Date ,
					App_Area_Sub_Identifier,
					Created_Date,
					Letter_Name ,
					Letter_Type ,
					Letter_Path ,
					Contract_Number ,
					Contract_Main_ID ,
					Contract_Revision_Number
				)
					SELECT
						ML.Message_Log_ID,
						CAST(ML.Message_To AS varchar(250)) AS Message_To,
						CAST(ML.Message_From AS varchar(250)) AS Message_From,
						ML.Message_Subject,
						ML.Message,
						ML.Message_Generated_By_ID,
						ML.App_Area_ID,
						ML.App_Area_Identifier,
						ML.Sent_Date,
						ML.App_Area_Sub_Identifier,
						ML.Created_Date,
						ISNULL(PL.Letter_Name,'-NONE-') AS Letter_Name,
						ISNULL(cast(PL.Letter_Type AS nvarchar(15)),'-NONE-') AS Letter_Type,
						ISNULL(PL.Letter_Path,'-NONE-') AS Letter_Path,
						ISNULL(CM.Contract_Number,'-NONE-') AS Contract_Number,
						ISNULL(cast(CM.Contract_Main_ID AS nvarchar(15)),'-NONE-') AS Contract_Main_ID,
						isnull((CM.contract_number + '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END), '') AS Contract_Revision_Number
					FROM Message_log ML
						LEFT JOIN Program_Letters PL on PL.Program_letters_ID = ML.App_Area_Sub_Identifier
						LEFT JOIN contract_main CM ON cm.contract_main_id = PL.Program_ID
					WHERE (ML.App_Area_ID = 15 OR ML.App_Area_ID = 17)
					AND ML.App_Area_Identifier IN
                    (
	                    SELECT Contract_Main_ID
	                    FROM Contract_Main
	                    WHERE Contract_number IN ('#qGetContractNumber.Contract_Number#') AND revision_version != 0 AND approved = 1
                    )
					/*
					AND CM.Contract_number IN (SELECT Contract_Number FROM contract_main WHERE  revision_version != 0 AND approved = 1)
					AND CM.Contract_main_ID = '#arguments.ContractId#'
					*/

				INSERT INTO ##tmpTblEmailAllLogData(
					Message_Log_ID,
					Message_To,
					Message_From ,
					Message_Subject ,
					Message ,
					Message_Generated_By_ID ,
					App_Area_ID ,
					App_Area_Identifier ,
					Sent_Date ,
					App_Area_Sub_Identifier,
					Created_Date,
					Letter_Name ,
					Letter_Type ,
					Letter_Path ,
					Contract_Number ,
					Contract_Main_ID ,
					Contract_Revision_Number
				)
				SELECT
					ML.Message_Log_ID,
					CAST(ML.Message_To AS varchar(250)) AS Message_To,
					CAST(ML.Message_From AS varchar(250)) AS Message_From,
					ML.Message_Subject,
					ML.Message,
					ML.Message_Generated_By_ID,
					ML.App_Area_ID,
					ML.App_Area_Identifier,
					ML.Sent_Date,
					ML.App_Area_Sub_Identifier,
					ML.Created_Date,
						-- MA.Message_Attachment,
					'' AS Letter_Name,
					'' AS Letter_Type,
					'' AS Letter_Path,
						CM.Contract_Number,
						CM.Contract_Main_ID,
						isnull((CM.contract_number + '-' + CASE
									WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
									WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
								END), '') AS Contract_Revision_Number

						FROM Message_log ML
						INNER JOIN Message_Log_Multiple_App_Area_Identifier MLM ON MLM.Message_Log_ID = ML.Message_Log_ID
						INNER JOIN contract_main CM ON cm.contract_main_id = MLM.App_Area_Identifier
					WHERE ML.App_Area_ID = 16
					AND MLM.App_Area_Identifier
                    IN
					(
						SELECT CONTRACT_MAIN_ID
						FROM CONTRACT_MAIN
						WHERE Contract_number IN ('#qGetContractNumber.Contract_Number#') AND revision_version != 0 AND approved = 1
					)
					/*
					AND CM.Contract_number IN (SELECT Contract_Number FROM contract_main WHERE  revision_version != 0 AND approved = 1)
					AND CM.Contract_main_ID = '#arguments.ContractId#'
					*/

				SELECT count(Message_Log_Id) As recordTotalCount
				FROM ##tmpTblEmailAllLogData
			</cfquery>

			<cfquery name="qGetEmailLogDataFiltered" datasource="#application.datasource#">
				SELECT count(Message_Log_Id) As recordFilteredCount
				FROM ##tmpTblEmailAllLogData
				WHERE 1 = 1

				<!--- keyword filter --->
				<cfif arguments.listOfWords neq "">
				AND
				(
					Message_From like '%#arguments.listOfWords#%'
					OR
					Message_To like '%#arguments.listOfWords#%'
					OR
					Message_Subject like '%#arguments.listOfWords#%'
					OR
					Message like '%#arguments.listOfWords#%'
				)
				</cfif>
				<cfif iType neq 0>
					AND App_Area_ID = #iType#
				</cfif>
			</cfquery>

			<cfquery name="qGetEmailLogDataFilteredResults" datasource="#application.datasource#">
				SELECT * FROM ##tmpTblEmailAllLogData
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
					Message_From like '%#arguments.listOfWords#%'
					OR
					Message_To like '%#arguments.listOfWords#%'
					OR
					Message_Subject like '%#arguments.listOfWords#%'
					OR
					Message like '%#arguments.listOfWords#%'
				)
				</cfif>
				<cfif iType neq 0>
					AND App_Area_ID = #iType#
				</cfif>

				<cfswitch expression="#arguments.column_sequence_number#">
					 <cfcase value=0>ORDER BY Message_Log_ID</cfcase>
					 <cfcase value=2>ORDER BY Message_From</cfcase>
					 <cfcase value=3>ORDER BY Message_To</cfcase>
					 <cfcase value=4>ORDER BY Message_Subject</cfcase>
	 				 <cfcase value=7>ORDER BY Created_Date</cfcase>
					 <cfcase value=8>ORDER BY Contract_Revision_Number</cfcase>
				</cfswitch>
				<cfif arguments.column_sequence_number NEQ "">
					#arguments.sort_order#
				</cfif>
			</cfquery>

				<cfset returnStruct.recordTotal = qGetEmailLogData.recordTotalCount>

				<!--- Filtered records query (after filter) --->
				<cfset returnStruct.filteredResults = qGetEmailLogDataFilteredResults>

				<!--- Filtered records (after filter) --->
				<cfset returnStruct.filteredTotal = qGetEmailLogDataFiltered.recordFilteredCount>

			<cfreturn returnStruct />

	</cffunction>
		<!---66079	Ability to delete 1 version & keep another version alive START --->
		<cffunction name="deleteProgramVersion" output="true" returntype="boolean">
			<cfargument name="ContractNumber" required="true" type="string" />
			<cfargument name="ContractMainID" required="true" type="numeric" />
			<cfargument name="ParentprogramId" required="true" type="numeric" default="0" />

			<cfset programupdate = 0>
			<cfquery name="check4Parent" datasource="#application.datasource#" >
				SELECT Contract_Main_ID
				FROM Contract_Main
				WHERE Revision_of_Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
				AND Contract_Number = <cfqueryparam value="#arguments.ContractNumber#" cfsqltype="cf_sql_varchar" >
				AND Approved = 1
				ORDER BY Parent_Has_Previous_Revision
			</cfquery>

			<CFTRANSACTION ACTION="Begin">

			<cfif check4Parent.recordcount>
				<cfset childContractMainID = check4Parent.Contract_Main_ID>
				<cfquery name="updateProgram" datasource="#application.datasource#" >
					<!--- HISTORY TABLE --->
					INSERT INTO Deleted_Version_History (Contract_Number,Contract_Main_ID,Revision_Version,Contract_Start_Date,Contract_End_Date,New_Contract_Start_Date,New_Contract_End_Date,Date_Change,Notes)
					SELECT P.Contract_Number, P.Contract_Main_ID, P.Revision_Version, P.Contract_Start_Date, P.Contract_End_Date, C.Contract_Start_Date, C.Contract_End_Date, 1, 'This version Dates are updated with child version and flagged deleted'
					FROM Contract_main AS P
					INNER JOIN Contract_main C
					ON C.Revision_of_Contract_Main_ID = P.Contract_Main_ID
					WHERE P.Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
					AND C.Approved = 1

					UPDATE P
					SET P.Contract_Start_Date = C.Contract_Start_Date
						, P.Contract_End_Date = C.Contract_End_Date
						, P.Deleted = 1
						, P.Deleted_By = 'Administrator used LHS link to delete'
						, P.Deleted_Date = GetDate()
						, P.Approved = 0
						, P.Revision_Version = 1
					FROM Contract_main AS P
					INNER JOIN Contract_main C
					ON C.Revision_of_Contract_Main_ID = P.Contract_Main_ID
					WHERE P.Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
					AND C.Approved = 1
				</cfquery>

				<cfquery name="check4unDeletedRevisions" datasource="#application.datasource#" >
					SELECT *
					FROM Contract_main
					WHERE Contract_Number = <cfqueryparam value="#arguments.ContractNumber#" cfsqltype="cf_sql_varchar" >
					AND Deleted = 0
					AND Approved = 1
				</cfquery>
				<!---IF THERE ARE NO VERSIONS DELETED = 0 THEN WE SET CHILD VERSION DELETED = 0 --->
				<cfif check4unDeletedRevisions.RecordCount EQ 0>
					<cfquery name="updateProgram" datasource="#application.datasource#" >
						<!--- HISTORY TABLE --->
						INSERT INTO Deleted_Version_History (Contract_Number,Contract_Main_ID,Revision_Version,Contract_Start_Date,Contract_End_Date,Notes)
						SELECT Contract_Number, Contract_Main_ID, Revision_Version, Contract_Start_Date, Contract_End_Date, 'There are no versions for this contract deleted 0 so we are un-deleting this version'
						FROM Contract_Main
						WHERE Contract_main_id = <cfqueryparam value="#childContractMainID#" cfsqltype="cf_sql_numeric" >

						UPDATE Contract_main
						SET 		 Deleted = 0
									,Deleted_By = NULL
									,Deleted_Date = NULL
									,Force_Expiration_Flag = 0
						WHERE Contract_main_id = <cfqueryparam value="#childContractMainID#" cfsqltype="cf_sql_numeric" >
					</cfquery>
				</cfif>
			<CFELSE>

				<cfquery name="updateProgram" datasource="#application.datasource#" >
					<!--- HISTORY TABLE --->
					INSERT INTO Deleted_Version_History (Contract_Number,Contract_Main_ID,Revision_Version,Contract_Start_Date,Contract_End_Date,Notes)
					SELECT Contract_Number, Contract_Main_ID, Revision_Version, Contract_Start_Date, Contract_End_Date, 'Deleting this Version'
					FROM Contract_Main
					WHERE Contract_main_id = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >

					<!---DELETE CHILD VERISON--->
					UPDATE Contract_main
					SET 		 Deleted = 1
								,Deleted_By = 'Administrator used LHS link to delete'
								,Deleted_Date = GetDate()
								,Approved = 0
								,Revision_Version = 1
					WHERE Contract_main_id = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
					<!---UN-DELETE PARENT VERISON--->

					<!--- HISTORY TABLE --->
					INSERT INTO Deleted_Version_History (Contract_Number,Contract_Main_ID,Revision_Version,Contract_Start_Date,Contract_End_Date,Notes)
					SELECT Contract_Number, Contract_Main_ID, Revision_Version, Contract_Start_Date, Contract_End_Date, 'Un-Deleting this Version'
					FROM Contract_Main
					WHERE Contract_main_id = <cfqueryparam value="#arguments.ParentprogramId#" cfsqltype="cf_sql_numeric" >

					UPDATE Contract_main
					SET 		 Deleted = 0
								,Deleted_By = NULL
								,Deleted_Date = NULL
								,Force_Expiration_Flag = 0
					WHERE Contract_main_id = <cfqueryparam value="#arguments.ParentprogramId#" cfsqltype="cf_sql_numeric" >
				</cfquery>
			</cfif>

				<cfquery name="deleteChild" datasource="#application.datasource#" >
					<!---DELETE ALL WIP/RFA PROGRAM WHICH ARE REVISIONS OF THE CHILD --->

					<!--- HISTORY TABLE --->
					INSERT INTO Deleted_Version_History (Contract_Number,Revision_Version,Contract_Start_Date,Contract_End_Date,Contract_Main_ID,Notes)
					SELECT Contract_Number, Revision_Version,Contract_Start_Date, Contract_End_Date, Contract_Main_ID, 'Deleting non-approved versions as parent version is deleted'
					FROM Contract_Main
					WHERE Revision_of_Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
					AND Approved = 0

					UPDATE Contract_main
					SET 		 Deleted = 1
								,Deleted_By = 'Administrator used LHS link to delete'
								,Deleted_Date = GetDate()
								,Revision_Version = 1
					WHERE Revision_of_Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
					AND Approved = 0
				</cfquery>


				<cfquery name="updateEffDates" datasource="#application.datasource#" >
					<!---BELOW UPDATE IS ADD IN THIS QUERY JUST TO TRIGGER THE TRIGGER WHICH SET PROGRAM STATUS --->
					UPDATE Contract_main
					SET 		 Deleted = 0
					WHERE Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
					AND Deleted = 0
				</cfquery>

				<CFSTOREDPROC PROCEDURE="PROGRAM_EFFECTIVE_DATES_UPDATE" DATASOURCE="#application.datasource#" >
				  <CFPROCPARAM  VALUE="#arguments.ContractMainID#" CFSQLTYPE="cf_sql_numeric">
				</CFSTOREDPROC>

			<CFTRANSACTION action = "commit">

			</CFTRANSACTION>

			<cfset programupdate = 1>
			<cfreturn programupdate/>
		</cffunction>
		<!---66079	Ability to delete 1 version & keep another version alive END --->
<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List START--->
	<cffunction name="PerformanceRequirements" output="false" returntype="query">
		<cfargument name="templateID" type="numeric" required="true" />
		<cfargument name="contractMainID" type="numeric" required="true" />
		<cfargument name="Form" type="struct" required="true" />

		<cfquery name="qPerformanceRequirements" datasource="#application.datasource#">
			SELECT DISTINCT PPRL.Perf_Req_Label
			FROM 	Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR
			ON PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
			INNER Join Program_Perf_Req_Labels PPRL
			ON PPRL.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
			AND PPRL.Perf_Req_Label_ID = PPM.Program_Perf_Req_Checked
			WHERE PPM.Template_ID = '#arguments.templateID#'
			AND PPR.List_Features <>0
		</cfquery>
	<cfquery name="DeletePrior" datasource="#application.datasource#">
		DELETE FROM One_Program_Perf_Mapping
		WHERE Contract_Main_ID = <cfqueryparam value="#arguments.contractMainID#" cfsqltype="CF_SQL_INTEGER" />
	</cfquery>
<cfif qPerformanceRequirements.Recordcount>
	<cfset PRlist = valuelist(qPerformanceRequirements.Perf_Req_Label)>
	<cfloop index = "Requirement" list = "#PRlist#"  delimiters = ",">

		<cfquery name="All_PRS" datasource="#application.datasource#">
			select *
			from Program_Perf_Req_Labels
            where Perf_Req_Label in( <cfqueryparam value='#Requirement#' list="yes">)
		</cfquery>

		<cfset AllPrsForThisLabel = valuelist(All_PRS.program_perf_req_id)>
		<cfset SelectedPRList = #arguments.Form[Requirement]#>

		<cfloop index="currentPR" list="#AllPrsForThisLabel#" delimiters = ",">
			<cfset Checked = 0>
			<cfif ListFind(SelectedPRList,currentPR,',')>
				<cfset Checked = 1>
			</cfif>

			<cfquery name="InsertPerfReq" datasource="#application.datasource#">
				INSERT INTO One_Program_Perf_Mapping(
					Contract_Main_ID,
					Program_Perf_Req_ID,
					Checked,
					Program_Perf_Req_Label,
					Created_Date
				)VALUES(
				<cfqueryparam value="#arguments.contractMainID#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#currentPR#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#Checked#" cfsqltype="CF_SQL_BIT" />,
				<cfqueryparam value="#Requirement#" cfsqltype="CF_SQL_VARCHAR" />,
				getdate()
				)
			</cfquery>

		</cfloop>
	</cfloop>
</cfif>
  <cfreturn qPerformanceRequirements/>
	</cffunction>
<!---71858 Perm Req Enh V2 - Search bar within Lists, & Min. Requirement on each List END--->

<!--- Dev Note: WR 78635 - Check if vendor is the only payee on the template.
Note: We insert vendors into customer master table for client(s) who want "vendor" as a payee.
--->
<cffunction name="IsVendorOnlyPayeeOnTemplate" access="public" returntype="boolean" output="false">
	<cfargument name="templateID" required="true" type="numeric">

	<cfset local.bAllowVendorOnly = 0>

	<CFIF application.appSettingsGet.get_Setting('Lump_Sums_Programs_Paid_To_Vendor') eq '1'>
		<cfset useLakebaseForqAllowVendorOnly = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqAllowVendorOnly>
	<cftry>
		<cfset qAllowVendorOnly = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#arguments.templateID#",
				"allow_vendor_only" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqAllowVendorOnly = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAllowVendorOnly>
<CFQUERY NAME="qAllowVendorOnly" datasource="#application.datasource#">
			SELECT 1
			FROM Program_Control_Panel_Options
			WHERE ProgramControl_Panel_Options_ID = '#arguments.templateID#'
			AND Allow_Vendor_Only = 1
		</CFQUERY>
</cfif>

		<cfif qAllowVendorOnly.recordcount GT 0>
			<cfset local.bAllowVendorOnly = 1>
		</cfif>
	</CFIF>

	<cfreturn local.bAllowVendorOnly>
</cffunction>

<!--- Dev Note: WR 78635 - Check if vendors exist on a program.
Note: We insert vendors into customer master table for client(s) who want "vendor" as a payee.
--->
<cffunction name="getVendorsExistOnProgram" access="public" returntype="boolean" output="false">
	<cfargument name="contractMainID" type="numeric" required="true" />

	<cfset local.bVendorsExist = 0>

	<cfquery name="qgetVendorsExistOnProgram" datasource="#application.datasource#">
	SELECT 1
	FROM BSA_Foodservice_Customers
			INNER JOIN Vendor_Master
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Master.Vendor_Master_ID
			INNER JOIN Contract_Distributors
		ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	WHERE	Contract_Distributors.Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
	AND Contract_Distributors.deleted = 0
	</cfquery>

	<cfif qgetVendorsExistOnProgram.recordcount GT 0>
		<cfset local.bVendorsExist = 1>
	</cfif>

	<cfreturn local.bVendorsExist>
</cffunction>

<!--- Dev Note: WR 78635 - Get select vendors in the program.
Note: We insert vendors into customer master table for client(s) who want "vendor" as a payee.
--->
<cffunction name="getSelectedVendorsOnProgram" access="public" returntype="query" output="false">
	<cfargument name="contractMainID" type="numeric" required="true" />

	<cfquery name="qgetSelectedVendorsOnProgram" datasource="#application.datasource#">
	SELECT Vendor_Master.Vendor_Master_ID
	FROM BSA_Foodservice_Customers
			INNER JOIN Vendor_Master
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Master.Vendor_Master_ID
			INNER JOIN Contract_Distributors
		ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	WHERE	Contract_Distributors.Contract_Main_ID = <cfqueryparam value="#arguments.ContractMainID#" cfsqltype="cf_sql_numeric" >
	AND Contract_Distributors.deleted = 0
	</cfquery>

	<cfreturn qgetSelectedVendorsOnProgram>
</cffunction>

<!--- Dev Note: WR 78635 - Insert vendors.
Note: We insert vendors into customer master table for client(s) who want "vendor" as a payee.
--->
<cffunction name="saveProgramVendors" access="public" returntype="void" output="false">
	<cfargument name="programId" required="true" type="string">

	<CFQUERY NAME="qDeleteProgramVendors" datasource="#application.datasource#">
		DELETE FROM Contract_Distributors
		WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
	</CFQUERY>

	<cfif ListLen(form.SelectedVendorList) GT 0>
		<cfset local.programWeight = NumberFormat(100/ListLen(form.SelectedVendorList),'9.99')>

		<CFQUERY NAME="qsaveProgramVendors" datasource="#application.datasource#">
		<cfloop list="#form.SelectedVendorList#" index="i">
			INSERT INTO Contract_Distributors
				(BSA_Foodservice_Customers_ID, Contract_Main_ID, Program_Weight, Is_Group)
			VALUES('#i#', '#arguments.programId#', '#local.programWeight#', 0)
		</cfloop>
		</CFQUERY>

		<CFQUERY NAME="qGetTotalDistributorWeight" datasource="#application.datasource#">
			SELECT SUM(cast(Program_Weight as decimal(18,2))) As TotalWeight
			FROM Contract_Distributors
			WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
			AND deleted = 0
		</CFQUERY>

		<cfif qGetTotalDistributorWeight.TotalWeight neq "100.00">
			<!--- Allocate the balance weight for a random distributor --->
			<CFQUERY NAME="qSetBalanceWeight" datasource="#application.datasource#">
				UPDATE Contract_Distributors
				SET Program_Weight = Program_Weight + (100 - #qGetTotalDistributorWeight.TotalWeight#)
				WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
				AND deleted = 0
				AND Contract_Distributors_ID =
				(
					SELECT MAX(Contract_Distributors_ID)
					FROM Contract_Distributors
					WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
					AND deleted = 0
				)
			</CFQUERY>
		</cfif>
	</cfif>
</cffunction>
	<!---77408 Product Group sequencing START--->
	<cffunction name="UpdateProductsPricingLevel" output="false" hint="this function will update pricing level for planning groups">
		<cfargument name="contract_main_id"	type="numeric"	required="true">
		<cfargument name="Product_Type_ID"	type="numeric"	required="true">

		<CFQUERY NAME="getProductGroupLevels" datasource="#application.datasource#">
			SELECT DISTINCT PGL.*
			FROM Product_Group_Level PGL
			INNER JOIN Contract_Products CP
			ON CP.Product_Group_Level_ID = PGL.Product_Group_Level_ID
			WHERE PGL.Display_Sequence <> 0
			AND CP.Contract_Main_ID = #arguments.contract_main_id#
			AND CP.Product_Type_ID = #arguments.Product_Type_ID#
			AND CP.is_group = 1
			ORDER BY PGL.Display_Sequence
		</CFQUERY>

		<cfset PricingLevelID = 1>
		<cfloop query="getProductGroupLevels">
			<cfset useLakebaseForupPricingLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForupPricingLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.contract_main_id#",
				"product_type_id" = "eq.#arguments.Product_Type_ID#",
				"product_group_level_id" = "eq.#getProductGroupLevels.Product_Group_Level_ID#",
				"is_group" = "eq.1"
			},
			{
				"pricing_level_id" = "#PricingLevelID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupPricingLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupPricingLevel>
<cfquery name="upPricingLevel" datasource="#application.datasource#">
				UPDATE Contract_Products
				SET Pricing_Level_ID = #PricingLevelID#
				WHERE Deleted = 0
				AND contract_main_id = #arguments.contract_main_id#
				AND Product_Type_ID = #arguments.Product_Type_ID#
				AND Product_Group_Level_ID = #getProductGroupLevels.Product_Group_Level_ID#
				AND  is_group = 1
			</cfquery>
</cfif>
			<cfset PricingLevelID = PricingLevelID + 1>
		</cfloop>

			<cfset useLakebaseForupItemPricingLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForupItemPricingLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.contract_main_id#",
				"product_type_id" = "eq.#arguments.Product_Type_ID#",
				"is_group" = "eq.0",
				"captured_from_group" = "eq.0"
			},
			{
				"pricing_level_id" = "#PricingLevelID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupItemPricingLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupItemPricingLevel>
<cfquery name="upItemPricingLevel" datasource="#application.datasource#">
				UPDATE Contract_Products
				SET Pricing_Level_ID = #PricingLevelID#
				WHERE Deleted = 0
				AND contract_main_id = #arguments.contract_main_id#
				AND Product_Type_ID = #arguments.Product_Type_ID#
				AND  is_group = 0
				AND Captured_From_Group = 0
			</cfquery>
</cfif>

	</cffunction>
	<!---77408 Product Group sequencing END--->

	<cffunction name="getBlanketBidInfo" output="false" returntype="query">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="uom_type" type="numeric" required="true">
		<cfargument name="margin_version" type="string" required="false" default="current">
		<cfargument name="contract_status" type="string" required="true">

		<cfquery name="getBlanketBidInfo" datasource="#application.datasource#">
		SELECT	Product_Id
				,Contract_Main_ID
				,BSA.Item
				,BSA.description
				,TCD.Type_Code_Desc
				,TGD.Type_Group_Desc
				,BSA.Prod_Var_A_ID
				,BSA.Type_Code_Desc_ID
				,BSA.Type_Group_Desc_ID
				,BSA.Brand_ID
				,BSA.Q_Brand_ID
				<cfif arguments.UOM_Type EQ 1>
				,CPMA.Base_Sales_CS As List_Price
				,CPMA.FPR_CS As Program_Price
				,CPMA.Blanket_Bid_CS As Blanket_Bid_Price
				,(CPMA.FPR_CS - CPMA.Blanket_Bid_CS) As Blanket_Variance
				,
				CASE
					WHEN CPMA.FPR_CS = 0 AND CPMA.Blanket_Bid_CS = 0 THEN 0
					WHEN CPMA.FPR_CS = 0 AND CPMA.Blanket_Bid_CS > 0 THEN -100
				ELSE
				(((CPMA.FPR_CS - CPMA.Blanket_Bid_CS) /CPMA.FPR_CS) * 100)
				END
				As Blanket_Variance_Percent
				,(CPMA.FPR_CS - CPMA.Base_Sales_CS) As List_Variance
				,
				CASE
					WHEN CPMA.FPR_CS = 0 AND CPMA.Base_Sales_CS = 0 THEN 0
					WHEN CPMA.FPR_CS = 0 AND CPMA.Base_Sales_CS > 0 THEN -100
				ELSE
				(((CPMA.FPR_CS - CPMA.Base_Sales_CS) /CPMA.FPR_CS) * 100)
				END
				As List_Variance_Percent
				<cfelse>
				,Base_Sales_LB As List_Price
				,CPMA.FPR_LB As Program_Price
				,CPMA.Blanket_Bid_LB As Blanket_Bid_Price
				,(CPMA.FPR_LB- CPMA.Blanket_Bid_LB) As Blanket_Variance
				,
				CASE
					WHEN CPMA.FPR_LB = 0 AND CPMA.Blanket_Bid_LB = 0 THEN 0
					WHEN CPMA.FPR_LB = 0 AND CPMA.Blanket_Bid_LB > 0 THEN -100
				ELSE
				(((CPMA.FPR_LB - CPMA.Blanket_Bid_LB) /CPMA.FPR_LB) * 100)
				END
				As Blanket_Variance_Percent
				,(CPMA.FPR_LB - CPMA.Base_Sales_LB) As List_Variance
				,
				CASE
					WHEN CPMA.FPR_LB = 0 AND CPMA.Base_Sales_LB = 0 THEN 0
					WHEN CPMA.FPR_LB = 0 AND CPMA.Base_Sales_LB > 0 THEN -100
				ELSE
				(((CPMA.FPR_LB - CPMA.Base_Sales_LB) /CPMA.FPR_LB) * 100)
				END
				As List_Variance_Percent
				</cfif>
		<cfif arguments.Contract_Status GTE 3 AND arguments.margin_version eq "Approved">
		FROM Contract_Product_Margin_Approved CPMA
		<cfelse>
		FROM   Contract_Product_Margin CPMA
		</cfif>
		INNER JOIN BSA_Foodservice_Items_Master BSA
		ON BSA.BSA_Foodservice_Items_Master_ID = CPMA.Product_Id

		LEFT JOIN Type_Code_Desc TCD
		ON TCD.Type_Code_Desc_ID = BSA.Type_Code_Desc_ID

		LEFT JOIN Type_Group_Desc TGD
		ON TGD.Type_Group_Desc_ID = BSA.Type_Group_Desc_ID

		WHERE  CPMA.Contract_Main_ID = '#arguments.Contract_Main_ID#'
		</cfquery>

		<cfreturn getBlanketBidInfo>
	</cffunction>

	<cffunction name="getBlanketBidInfoCSV" output="false" returntype="string">
			<cfargument name="qryBidInfo" required="true">

			<cfoutput>
				<cfscript>
				local.buffer  = createObject( "java", "java.lang.StringBuffer" ).Init();
				local.newLine = chr(13) & chr(10);

				local.buffer.append(javaCast("string", "#application.returned_customer_setting.item_label# ##, Description, Blanket Bid Price, List Price, Program Price,"));
				local.buffer.append(javaCast("string", "Blanket Variance, Blanket Variance %, List Variance, List Variance %" & local.newLine));
				</cfscript>
			</cfoutput>

			<!--- body content --->
			<cfloop query="arguments.qryBidInfo">
			<!--- append row with comma delimiter, wrap columns in double quotes to avoid extra commas problem --->
			<cfset local.buffer.append(javaCast("string",   '="' & Item & '"'
												& ',"' & Description & '"'
												& ',"' & NumberFormat(Blanket_Bid_Price, '(__.__)') & '"'
												& ',"' & NumberFormat(List_Price, '(__.__)') & '"'
												& ',"' & NumberFormat(Program_Price, '(__.__)') & '"'
												& ',"' & NumberFormat(Blanket_Variance, '(__.__)') & '"'
												& ',"' & NumberFormat(Blanket_Variance_Percent, '(__.__)') & '"'
												& ',"' & NumberFormat(List_Variance, '(__.__)') & '"'
												& ',"' & NumberFormat(List_Variance_Percent, '(__.__)') & '"'
												& local.newLine  ))>
			</cfloop>

			<cfreturn local.buffer>
	</cffunction>
</cfcomponent>