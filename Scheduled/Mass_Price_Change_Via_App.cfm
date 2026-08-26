<!----------------------------------------------------------------------------------
Name         :  AwayX/Scheduled/Mass_Price_Change_Via_App.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  4/10/2017
Created By   :  KAL
Description  :  This file is scheduled from the application via mass price change function.
				Programs & Items are already sorted out before this file scheduled.
				This file only updates small batches of programs, 25 at a time, to eliminate updates stopping beacuse of deadlocks.
---------------------------------------------------------------------------------->

	<cfquery name="qGetMPPrograms" datasource="#application.datasource#">
		SELECT 		TOP 25
					Contract_Main_ID, Contract_Number, New_Start_Date, New_End_Date, Mod_End_Date, Responsible_User_ID
		FROM  		Mass_Price_Program_List
		WHERE 		Killed = 0 AND Skip = 0 AND Completed = 0
		ORDER BY  	Contract_Number, Contract_Main_ID
	</cfquery>



	<!--- run this process only if programs exist to change --->
	<cfif qGetMPPrograms.recordCount>

		<!--- Initiate the CFC --->
		<cfset MPCManager = createObject("component","mvc.Models.Program.Upload.MassPriceChange") />

		<!--- get effective date --->
		<cfquery name="qGetEffectiveDate" datasource="#application.datasource#">
			Select top 1 Effective_Date from Mass_Price_Products
		</cfquery>

		<!--- get user ID --->
		<cfquery name="qGetScheduledUser" datasource="#application.datasource#" >
			SELECT 		_Users.User_Id, _Users.User_Code, _Users.User_Email
			FROM   		Mass_Price_Schedule
			INNER JOIN 	_Users
			ON 			_Users.User_Id = Mass_Price_Schedule.User_Id
			WHERE  		Mass_Price_Schedule.Deleted   = 0
			AND 		Mass_Price_Schedule.Scheduled = 1
			ORDER BY	Mass_Price_Schedule.Created_Date DESC
		</cfquery>

		<cfset effDate   = qGetEffectiveDate.Effective_Date />
		<cfset userID    = qGetScheduledUser.User_ID/>
		<cfset userEmail = qGetScheduledUser.User_Email />
		<cfset userCode  = qGetScheduledUser.User_Code />


		<cfset commentNotes = " - (Price Change Applied - " & DateFormat(effDate, "mm/dd/yyyy") & ")" />

		<cfloop query="qGetMPPrograms">

			<cfset local.Program_ID_To_Replicate = Contract_Main_ID />
			<cfset local.Renewed_Program_ID = 0 />
			<cfset local.Is_Group_Deal = 0 />

			<cfquery name="qCurrentProgramUserIDs" datasource="#application.datasource#">
				SELECT	Creator_ID,
						Approved_By_User_ID,
						Broker_User_ID
				FROM	Contract_Main
				WHERE	Contract_Main_ID = <cfqueryparam value="#local.Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</cfquery>

			<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#local.Program_ID_To_Replicate#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@New_Contract_Number"			VALUE="">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="1">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ISROLLOVER"						VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ForceFreightOnAutoCopy"			VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@User_Position_ID"				VALUE="0" null="true">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Responsible_User_ID"			VALUE="" null="true">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="#userID#">
				<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Contract_Main_ID"				VARIABLE="local.Renewed_Program_ID">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_Mass_Copy"					VALUE="0">
				<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Is_Group_Deal"					VARIABLE="local.Is_Group_Deal">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@From_EZ_Template"				VALUE="0">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_AutoRenew"					VALUE="0">
			</CFSTOREDPROC>

			<cfquery name="qUpdateNewProgramUserIDs" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET		Contract_Start_Date = <cfqueryparam value="#qGetMPPrograms.New_Start_Date#" cfsqltype="cf_sql_date" />,
						Contract_End_Date = <cfqueryparam value="#qGetMPPrograms.New_End_Date#" cfsqltype="cf_sql_date" />,
						Broker_Approved = 1,
						Broker_User_ID = <cfqueryparam value="#qCurrentProgramUserIDs.Broker_User_ID#" cfsqltype="cf_sql_idstamp">,
						Broker_Approved_Date = Contract_Created_Date,
						Approved = 1,
						Approved_By_User_ID = <cfqueryparam value="#qCurrentProgramUserIDs.Approved_By_User_ID#" cfsqltype="cf_sql_idstamp">,
						Approval_Date = Contract_Created_Date,
						Notes = Notes + '#commentNotes#'
				WHERE	Contract_Main_ID = <cfqueryparam value="#local.Renewed_Program_ID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- get the max revision --->
			<cfquery name="qGetRevisionVersion" datasource="#application.datasource#">
				SELECT	ISNULL(max(ISNULL(revision_version, 0)), 0) AS revisionversion
				FROM	contract_main
				WHERE	contract_number LIKE <cfqueryparam value="%#qGetMPPrograms.Contract_Number#%" cfsqltype="cf_sql_varchar">
				AND		contract_main.Approved = 1
				AND		contract_main_id != <cfqueryparam value="#local.Renewed_Program_ID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- Update the revision verison --->
			<cfquery name="UpdateRevisionVersion" datasource="#application.datasource#">
				UPDATE 	Contract_Main
				SET 	revision_version = #qGetRevisionVersion.revisionversion# + 1
				WHERE 	Contract_Main_Id = <cfqueryparam value="#local.Renewed_Program_ID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- Dev Note: Kal; Add Business Considerations, Date on Notes to Mass Price Change --->
			<cfquery name="qInsertBizCon" datasource="#application.datasource#">
				INSERT INTO Contract_Evaluation_Notes (Contract_Number, Entered_By, Eval_Action, Notes, Created_Date, Contract_Notes_Type)
				VALUES	(	<cfqueryparam value="#Contract_Number#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="System" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="Pricing Update" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#commentNotes#" cfsqltype="cf_sql_varchar">,
							GETDATE(),
							<cfqueryparam value="2" cfsqltype="cf_sql_integer">
						)
			</cfquery>

			<!--- Update the price for the products. --->
			<cfquery name="qUpdatePrice" datasource="#application.datasource#">
				Update	PROGRAM_FIXED_PRICE_PRODUCT_DATA
				SET		Fixed_Price_Value = PPPC.New_Price
				FROM 	Contract_Main CM
				INNER JOIN CONTRACT_PRODUCTS CP ON CM.CONTRACT_MAIN_ID = CP.CONTRACT_MAIN_ID AND CP.DELETED = 0 and CP.Product_Type_ID = 1
				INNER JOIN PROGRAM_FIXED_PRICE_PRODUCT_DATA FX ON FX.PROGRAM_ID = CP.CONTRACT_MAIN_ID AND CP.CONTRACT_PRODUCTS_ID = FX.CONTRACT_PRODUCTS_ID  AND FX.DELETED = 0
				INNER JOIN Mass_Price_Program_Products PPPC ON PPPC.CONTRACT_MAIN_ID = CM.Revision_Of_Contract_Main_ID
					AND PPPC.CONTRACT_NUMBER = CM.CONTRACT_NUMBER
					AND PPPC.BSA_FOODSERVICE_ITEMS_MASTER_ID = CP.BSA_FOODSERVICE_ITEMS_MASTER_ID
					AND PPPC.Change_Completed = 0
				WHERE 	CM.DELETED = 0
				AND	CM.CONTRACT_MAIN_ID = <cfqueryparam value="#local.Renewed_Program_ID#" cfsqltype="cf_sql_integer">
				AND	PPPC.CONTRACT_MAIN_ID = <cfqueryparam value="#local.Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- Dev Note: Kal: 41715; Revisions are not copying the updated rate to group members of fixed price  --->
			<cfstoredproc procedure="capture_fixed_group_items" datasource="#application.datasource#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer"	dbvarname="@@contract_main_id"	value="#local.Renewed_Program_ID#">
			</cfstoredproc>

			<!---  Mark the Program as Completed when the price is updated. --->
			<cfquery name="qUpdateChangedFlag" datasource="#application.datasource#">
				Update	Mass_Price_Program_Products
				SET		Change_Completed = 1
				WHERE 	CONTRACT_MAIN_ID = <cfqueryparam value="#local.Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- Dev Note: Kal;  Update the temp table and set 1 if revision created succesfully --->
			<cfquery name="qSetProcessed" datasource="#application.datasource#">
				UPDATE 	Mass_Price_Program_List
				SET 	COMPLETED = 1,
						NEW_CONTRACT_MAIN_ID = <cfqueryparam value="#local.Renewed_Program_ID#" cfsqltype="cf_sql_integer">,
						New_Start_Date = <cfqueryparam value="#New_Start_Date#" cfsqltype="cf_sql_date">,
						New_End_Date =  <cfqueryparam value="#New_End_Date#" cfsqltype="cf_sql_date">
				WHERE 	CONTRACT_NUMBER = <cfqueryparam value="#Contract_Number#" cfsqltype="cf_sql_varchar">
				AND 	CONTRACT_MAIN_ID = <cfqueryparam value="#local.Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- Dev Note: Kal;  Update the end date on the previous program so it expires before the new programs starts --->
			<cfquery name="qUpdatePreviousProgramEndDate" datasource="#application.datasource#">
				Update	Contract_Main
				Set		Contract_Main.Contract_End_Date = Mod_End_Date,
						Contract_Is_Locked = 0,
						Contract_Lock_Date = null,
						Contract_Locked_By_User_ID = null
				From	Contract_Main
				INNER JOIN Mass_Price_Program_List On Contract_Main.Contract_Main_ID = Mass_Price_Program_List.Contract_Main_ID
				and		(DateDiff(d, Contract_Main.Contract_Start_Date, #CreateODBCDatetime(New_Start_Date)#) > 0)
				and		Contract_Main.Contract_Main_ID = <cfqueryparam value="#local.Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!---  Tim Ford - 42302 - Call effective dates to adjust them as soon as the Price Change has been applied  --->
			<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer"	dbvarname="@contract_main_id"	value="#local.Renewed_Program_ID#">
			</cfstoredproc>

			<cfstoredproc procedure="Update_Report_Status_Nightly" datasource="#application.datasource#">
				<cfprocparam type="in" 	cfsqltype="cf_sql_integer"	dbvarname="@programID"	value="#local.Renewed_Program_ID#">
			</cfstoredproc>

		</cfloop>

		<!--- get the current program status into Mass_Price_Program_List --->
		<cfquery name="qUpdateStatus" datasource="#application.Datasource#">
			UPDATE 	Mass_Price_Program_List
			SET		New_Version = Revision_Version,
					New_Contract_Status_ID = Contract_Status_Type_IDX,
					New_Contract_Status = Contract_Status_Type_Desc
			FROM	Mass_Price_Program_List, Contract_Main, Contract_Status_Types
			WHERE	Mass_Price_Program_List.New_Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND		Mass_Price_Program_List.Contract_Main_ID = Contract_Main.Revision_of_Contract_Main_ID
			AND		Contract_Status_Types.Contract_Status_Type_ID = Contract_Status_Type_IDX
		</cfquery>

		<!--- check if all the programs were revised --->
		<cfquery name="qCheckAllRevised" datasource="#application.datasource#">
			SELECT 		COUNT(*) as counts
			FROM  		Mass_Price_Program_List
			WHERE 		Killed = 0 AND Skip = 0 AND Completed = 0
		</cfquery>


		<cfif NOT (qCheckAllRevised.counts)>
			<!--- unloack programs --->
			<cfset temp =  MPCManager.unlockMassPrograms() />
			<!--- insert processed data into history tables --->
			<cfset temp =  MPCManager.insertHistoryLog() />
			<!--- clear upload tables when all prgs are revised --->
			<cfset temp =  MPCManager.clearData() />
			<!--- clear schedule when all prgs are revised --->
			<cfset temp =  MPCManager.clearSchedule() />
			<cfinclude template="/settings/Mass_Price_Change/emailReport.cfm" />
		</cfif>


	</cfif> <!---end:qGetMPPrograms.recordCount --->
