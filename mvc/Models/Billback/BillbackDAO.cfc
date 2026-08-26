<!---
Name: 			BillbackDAO.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/18/2011
Created By:    	Tim Ford
Description:	I am responsible DB access for all billback data.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackDAO" displayname="BillbackDAO" extends="mvc.Models.SettingsService">

	<cfscript>
		variables.oDeductionDAO = CreateObject("component","mvc.Models.Deduction.DeductionDAO" );
		variables.appSettings = application.appSettingsGet;
	</cfscript>

	<cffunction name="getBillbackUUID" output="false" access="public" returntype="String" hint="Function to get the Billback UUID">

		<cfargument name="billbackIDInt" required="true" type="numeric">

		<cfscript>
			//set local variables
			var nBillbackIDInt	= "";
			var qGetBillbackID	= "";
			var strRetData		= "";

			//assign local variables
			nBillbackIDInt	= arguments.billbackIDInt;

		</cfscript>

		<cfquery name="qGetBillbackID" datasource="#Application.Datasource#">
			SELECT	Billback_ID
			FROM	Billback
			WHERE 	Billback_ID_Int  = <cfqueryparam value="#nBillbackIDInt#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfscript>

			//set and return value
			strRetData = qGetBillbackID.Billback_ID;
			return strRetData;

		</cfscript>

	</cffunction>

	<cffunction name="getBBRecord" access="public" output="false" returntype="query">
		<cfargument name="billbackIDInt" type="string" required="true" />
		<cfquery name="qGetBBRecord" datasource="#application.datasource#">
			SELECT
				Billback.*,
				BBS.Billback_Status_ID,
				BBS.BB_Status_Description,
				BBS.BB_Status_Abbreviation,
				-- ,BBA.Payment_Notes,
				Billback.Special_Handling AS SpecialHandling
			FROM Billback
			LEFT JOIN
				Billback_Status BBS
				ON
				Billback.Billback_Status_ID = BBS.Billback_Status_ID
			LEFT JOIN
				BB_Approved BBA
				ON
				Billback.Billback_ID = 	BBA.Billback_ID
			WHERE Billback_ID_Int = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.billbackIDInt#" />
		</cfquery>
		<cfreturn qGetBBRecord />
	</cffunction>

	<cffunction name="getBBChildren" access="public" output="false" returntype="query">
		<cfargument name="Billback_ID" type="string" required="true" />
		<cfquery name="qGetBBChildren" datasource="#application.datasource#">
			SELECT
				Billback.*,
				BBS.Billback_Status_ID,
				BBS.BB_Status_Description,
				BBS.BB_Status_Abbreviation,
				-- BBA.Payment_Notes,
				Billback.Special_Handling AS SpecialHandling,
				BBA.Approved_Amount,
				BBA.Document_Number_1,
				BBA.Document_Number_2,
				BCM.vchBillback_Closing_Method_Desc AS Closing_Method_Description,
				BCM.Abbreviation
			FROM Billback
			LEFT JOIN
				Billback_Status BBS
				ON
				Billback.Billback_Status_ID = BBS.Billback_Status_ID
			LEFT JOIN
				Billback_Closing_Methods BCM
				ON
				Billback.BB_Closing_Method = BCM.iBillback_Closing_Method_ID AND BCM.Deleted = 0
			LEFT JOIN
				BB_Approved BBA
				ON
				Billback.Billback_ID = 	BBA.Billback_ID
				-- Billback.BB_Parent_ID = 	BBA.Billback_ID
			WHERE  Billback.BB_Is_Child = 1
			--D35191:Conversion failed when converting from a character string to uniqueidentifier
			AND CAST(Billback.BB_Parent_ID AS NVARCHAR(50)) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.Billback_ID#" />
			AND Billback.Deleted = 0
			<!---	Do not remove this "ORDER BY" clause. The closing methods should be processed in this order. If not, then closing method (payment) may
				not be retained on the settlement screen consistently on "Agree". Payment needs to be processed first. --->
			ORDER BY Billback.BB_Closing_Method <!---  Do not add "DESC" --->
		</cfquery>
		<cfreturn qGetBBChildren />
	</cffunction>

	<cffunction name="getBBLockedByID" access="public" output="false" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" />

		<cfscript>
			//set local variables
			var nBillbackID				= "";
			var qGetBillbackLocked		= "";
			var qRetQuery				= "";

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;

		</cfscript>

		<!--- check to see if the billback is locked --->
		<cfquery name="qGetBillbackLocked" datasource="#application.datasource#">
			SELECT	Billback.Billback_ID, Billback.Billback_ID_Int, Billback_Allied.BB_Locked_By_User_ID
			FROM	Billback_Allied
					INNER JOIN Billback ON Billback.Billback_ID = Billback_Allied.Billback_ID
			WHERE	Billback.Billback_ID_Int = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nBillbackID#">
			AND		Billback_Allied.BB_Is_Locked = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
		</cfquery>

		<cfscript>
			qRetQuery = qGetBillbackLocked;
			return qRetQuery;
		</cfscript>

	</cffunction>

	<cffunction name="getBBLockedByUser" access="public" output="false" returntype="query">

		<cfargument name="userId" type="string" required="true" />
		<cfargument name="billbackIDInt" type="numeric" required="false" default="0" />

		<cfscript>
			//set local variables
			var strUserID					= "";
			var qGetBillbackUserLocked		= "";
			var qRetQuery					= "";
			var nBillbackID					= 0;

			//assign local variables
			strUserID	= arguments.userId;
			nBillbackID	= trim(arguments.billbackIDInt);

		</cfscript>

		<!--- check to see if this user has a billback locked --->
		<cfquery name="qGetBillbackUserLocked" datasource="#application.datasource#">
			SELECT	Billback.Billback_ID, Billback.Billback_ID_Int, Billback_Allied.BB_Locked_By_User_ID, _Users.Name_First + ' ' + _Users.Name_Last AS Locked_By_User_Name, Billback.BB_Code
			FROM	Billback_Allied
					INNER JOIN Billback ON Billback.Billback_ID = Billback_Allied.Billback_ID AND Billback.Deleted = 0
					INNER JOIN _Users ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID
			WHERE	Billback_Allied.BB_Is_Locked = 1
			AND		_Users.User_ID = <cfqueryparam value="#strUserID#" cfsqltype="CF_SQL_VARCHAR" />
			<!--- filter on Billback_ID_Int is passed to the function --->
			<cfif nBillbackID neq 0>
			AND		Billback.Billback_ID_Int = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nBillbackID#">
			</cfif>
		</cfquery>

		<cfscript>
			qRetQuery = qGetBillbackUserLocked;
			return qRetQuery;
		</cfscript>

	</cffunction>

	<cffunction name="setBBLocked" access="public" output="false" returntype="numeric">

		<cfargument name="billbackIDInt" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />

		<cfscript>
			//set local variables
			var nBillbackID					= "";
			var strUserID					= "";
			var qSetBillbackLocked			= "";
			var strBillbackID				= "";
			var nReturnSuccess				= 1;

			//assign local variables
			nBillbackID		= arguments.billbackIDInt;
			strUserID		= arguments.userId;
			strBillbackID 	=  getBillbackUUID(nBillbackID);

		</cfscript>

		<cftry>
			<!--- set the billback locked --->
			<!---<cfquery name="qSetBillbackLocked" datasource="#application.datasource#">
				INSERT INTO Billback_Allied
					(Billback_ID, BB_Is_Locked, BB_Locked_By_User_ID)
				VALUES
					(<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strBillbackID#">, <cfqueryparam cfsqltype="cf_sql_bit" value="1">, <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strUserID#">)
			</cfquery>--->

			<cfquery name="qSetBillbackLocked" datasource="#application.datasource#">
				UPDATE Billback_Allied
				SET 	BB_Is_Locked = 1,
						BB_Locked_By_User_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strUserID#">,
						BB_Lock_Date = GetDate()
				WHERE	Billback_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strBillbackID#">
			</cfquery>

			<cfcatch type="database">
				<cfset nReturnSuccess = 0 />
			</cfcatch>
		</cftry>

		<cfreturn nReturnSuccess />

	</cffunction>

	<cffunction name="setBBUnLocked" access="public" output="false" returntype="numeric">

		<cfargument name="billbackIDInt" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="false" default="" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" required="false" default="0" />

		<cfscript>
			//set local variables
			var nBillbackID			= "";
			var strBillbackID		= "";
			var strUser			= "";
			var qSetBillbackUnLocked	= "";
			var nReturnSuccess		= 1;

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			strBillbackID 	= getBillbackUUID(nBillbackID);
			strUser		= arguments.userId;
		</cfscript>

		<cftry>
			<!--- set the billback to unlocked --->
			<cfquery name="qSetBillbackUnLocked" datasource="#application.datasource#">
				UPDATE	Billback_Allied
				SET		BB_Is_Locked =  0,
						BB_Locked_By_User_ID = NULL,
						BB_Lock_Date = NULL
				<cfif arguments.unlockExistingLockedByUser eq 0 OR strUser eq "">
				WHERE	Billback_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strBillbackID#">
				<cfelse>
				<!--- Unlock all billbacks locked by the user --->
				WHERE	BB_Locked_By_User_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strUser#">
				</cfif>
			</cfquery>

			<!--- set the deduction to unlocked for this user --->
			<cfif strUser neq "">
				<cfquery name="qSetDDUnLocked" datasource="#application.datasource#">
					UPDATE	Deductions
					SET 	Is_Locked = 0,
							Locked_By = NULL
					WHERE 	Locked_By = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strUser#">
				</cfquery>
			</cfif>

			<cfcatch type="database">
				<cfset nReturnSuccess = 0 />
			</cfcatch>
		</cftry>

		<cfreturn nReturnSuccess />

	</cffunction>

	<cffunction name="getBBProgramDistributorProductRateData" output="false" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID							= "";
			var qBillbackProgramDisItemRateData		= "";
			var qRetBillbackProgramDisItemRateData	= "";
			var DiffLocalTimeZoneAndEST = 0;
			var useDayLightSavingsTime = 0;

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST();
			useDayLightSavingsTime  = int(request.AccessStructure.useDayLightSavingsTime);
		</cfscript>

		<cfquery datasource="#application.datasource#" name="qBillbackProgramDisItemRateData">

			DECLARE
			@Billback_ID_Int		INT,
			@Billback_Payee_Type_ID INT,
			@Billback_ID 			UNIQUEIDENTIFIER,
			@DateWithTimeZoneDiff INT,
			@useDayLightSavingsTime BIT

			SET	@Billback_ID_Int = #nBillbackID#

			SET @DateWithTimeZoneDiff = #DiffLocalTimeZoneAndEST#

			<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
			SET @useDayLightSavingsTime = #useDayLightSavingsTime#

			-- Get the Billback Payee Type
			SELECT 	@Billback_Payee_Type_ID = Billback_Payee_Type_ID,
					@Billback_ID = Billback_ID
			FROM 	Billback
			WHERE 	Billback_ID_Int = @Billback_ID_Int
			<!--- TEMP TABLE FOR PERFORMANCE
				MOVE get_TimeZoneOffset_Date() calls out of main Query --->
			IF OBJECT_ID('tempdb..##TMP_CM_Offset') IS NOT NULL
			DROP TABLE ##TMP_CM_Offset

			CREATE  TABLE ##TMP_CM_Offset
			(
				Contract_Main_ID INT,
				programStartDate datetime,
				programEndDate datetime,
				effectiveStartDate datetime,
				effectiveEndDate datetime
			)
			INSERT INTO ##TMP_CM_Offset
					(Contract_Main_ID, programStartDate, programEndDate, effectiveStartDate, effectiveEndDate)
			SELECT
				CM.Contract_Main_Id,
				dbo.get_TimeZoneOffset_Date(CM.Contract_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) AS programStartDate,
					dbo.get_TimeZoneOffset_Date(CM.Contract_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) AS programEndDate,
					dbo.get_TimeZoneOffset_Date((select MIN(Effective_Start_Date) from Contract_Main cm1 where cm1.Contract_Number = cm.Contract_Number and cm1.Approved = 1 and cm1.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as effectiveStartDate,
					dbo.get_TimeZoneOffset_Date((select MAX(Effective_End_Date) from Contract_Main cm2 where cm2.Contract_Number = cm.Contract_Number and cm2.Approved = 1 and cm2.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as effectiveEndDate
			FROM Billback_Program BP
			INNER JOIN Contract_Main cm  ON BP.Program_ID = CM.Contract_Main_ID
			WHERE BP.Billback_Id = @Billback_ID AND BP.Deleted = 0
			<!--- TEMP TABLE FOR PERFORMANCE
				GET CONTRACT_PRODUCT_ID's and BSA_Foodservice_Items_Master_ID out of Main Query --->
			IF OBJECT_ID('tempdb..##TMP_Contract_products_Id') IS NOT NULL
			DROP TABLE ##TMP_Contract_products_Id

			CREATE  TABLE ##TMP_Contract_products_Id
			(
				Contract_products_Id		INT,
				Contract_Main_ID INT,
				BSA_Foodservice_Items_Master_ID UNIQUEIDENTIFIER
			)
			INSERT INTO ##TMP_Contract_products_Id
					(Contract_products_Id,Contract_Main_ID,BSA_Foodservice_Items_Master_ID)
			SELECT DISTINCT Contract_products_Id, Contract_Main_ID,BSA_Foodservice_Items_Master_ID
			FROM Billback_Product BPR
			INNER JOIN Billback_Program BP ON BP.Billback_ID = BPR.Billback_ID AND BP.Deleted = 0
			INNER JOIN  Contract_Products CP ON
				CP.Contract_Main_ID = BP.Program_ID AND
				CP.BSA_Foodservice_Items_Master_ID = BPR.Product_ID AND
				CP.Deleted = 0
			WHERE BPR.Billback_ID = @Billback_ID AND  BPR.Deleted = 0



			IF OBJECT_ID('tempdb..##TMP_Distributor_ID_From') IS NOT NULL
			DROP TABLE ##TMP_Distributor_ID_From

			CREATE  TABLE ##TMP_Distributor_ID_From
			(
				Billback_ID		UNIQUEIDENTIFIER,
				Distributor_Id	UNIQUEIDENTIFIER
			)

			IF @Billback_Payee_Type_ID = 1
			BEGIN
				INSERT INTO ##TMP_Distributor_ID_From
					(Billback_ID, Distributor_Id)
				SELECT 	DISTINCT Billback_ID, Distributor_ID_Earned
				FROM	Billback_Product_Detail
				WHERE	Billback_ID = @Billback_ID
				AND		Deleted = 0

			END
			ELSE IF @Billback_Payee_Type_ID = 2
			BEGIN
				INSERT INTO ##TMP_Distributor_ID_From
					(Billback_ID, Distributor_Id)
				SELECT 	DISTINCT Billback_ID, Distributor_ID
				FROM	Billback_Distributor_List
				WHERE	Billback_ID = @Billback_ID
				AND		Deleted = 0
			END

			SELECT 	DISTINCT
					BP.Program_ID AS programID,
					CM.Contract_Number AS programNumber,
					CM.Contract_Title AS programTitle,
					<!---  Use DateAdd to add or subtract time for the specific timezone of the user.Get the new date based on Time Zone.
					For eg: If a person logs in to the flex application from CST time zone, then the date would be one hour more than the value in the db.
					--->
					TOFF.programStartDate, TOFF.programEndDate, TOFF.effectiveStartDate, TOFF.effectiveEndDate,
					BFIM.BSA_Foodservice_Items_Master_ID AS itemGuid,
					BFIM.Item AS itemNumber,
					BFIM.Description AS description,
					BFIM.Net_Weight AS netWeight,
					BPD.BB_Rate AS amount,
					BPR.Billback_Product_ID,
					BPR.BB_Product_Quantity AS volume,
					BPR.Created_Sort_Order,
					UOM.Unit_Of_Measure_Id as uomId,
					UOM.Abbreviation as uomAbbreviation,
					UOM.unit_Of_Measure_Desc as uomDescription,
					BPD.BB_Product_Type_ID AS discountType,
					BFC.Name AS name,
					BFC.Ship_To AS shipTo,
					BFC.BSA_Foodservice_Customers_ID AS customerID,
					BFC.Address_1 AS addressLine1,
					BFC.Address_2 AS addressLine2,
					BFC.City AS city,
					BFC.State AS state,
					BFC.ZipCode AS zipCode,
					CASE WHEN CP.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN 0 ELSE 1 END AS bNotOnProgram,
					CASE WHEN CM.Deleted = 1 THEN 0 ELSE 1 END AS bIsLatestVersion
			FROM	Billback BB
					INNER JOIN Billback_Program BP ON BP.Billback_ID = BB.Billback_ID AND BP.Deleted = 0
					INNER JOIN Contract_Main CM ON CM.Contract_main_ID = BP.Program_ID
					INNER JOIN Billback_Product BPR ON BPR.Billback_ID = BB.Billback_ID AND BPR.Billback_Program_ID = BP.Billback_Program_ID AND BPR.Deleted = 0
					INNER JOIN Billback_Product_Detail BPD ON BPD.Billback_ID = BB.Billback_ID AND BPD.Billback_Product_ID = BPR.Billback_Product_ID AND BPD.Deleted = 0
					INNER JOIN BSA_Foodservice_Items_Master BFIM ON BFIM.BSA_Foodservice_Items_Master_ID = BPR.Product_ID AND BFIM.Deleted = 0
					INNER JOIN ##TMP_CM_Offset TOFF on TOFF.Contract_Main_ID = CM.Contract_Main_ID
					LEFT JOIN ##TMP_Distributor_ID_From ON ##TMP_Distributor_ID_From.Billback_ID = BB.Billback_ID AND ##TMP_Distributor_ID_From.Distributor_Id = BPD.Distributor_ID_Earned
					LEFT JOIN BSA_Foodservice_Customers BFC ON BFC.BSA_Foodservice_Customers_ID = ##TMP_Distributor_ID_From.Distributor_ID
					LEFT JOIN Units_Of_Measure UOM ON UOM.Unit_Of_Measure_Id = BPR.BB_Product_UOM
					LEFT JOIN ##TMP_Contract_products_Id CP ON CP.Contract_Main_ID = CM.Contract_Main_ID AND CP.BSA_Foodservice_Items_Master_ID = BFIM.BSA_Foodservice_Items_Master_ID
			WHERE 	BB.Billback_ID_Int = @Billback_ID_Int
			AND		BB.Deleted = 0 ORDER BY BPR.Created_Sort_Order
		</cfquery>

		<cfset qRetBillbackProgramDisItemRateData = qBillbackProgramDisItemRateData />

		<cfreturn qRetBillbackProgramDisItemRateData />

	</cffunction>

	<cffunction name="getBBData" output="false" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID			= "";
			var qBillbackData		= "";
			var qRetBillbackData	= "";
			var DiffLocalTimeZoneAndEST = 0;
			var useDayLightSavingsTime = 0;
			var strBBDefaultProgram	= "";

			//assign local variables
			nBillbackID		= arguments.billbackIDInt;
			DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST();
			useDayLightSavingsTime  = int(request.AccessStructure.useDayLightSavingsTime);
			strBBDefaultProgram = getBillbackDefaultProgram(nBillbackID);
		</cfscript>

		<cfquery datasource="#application.datasource#" name="qBillbackData">
			DECLARE
			@Billback_ID_Int		INT,
			@Billback_Payee_Type_ID INT,
			@Billback_Status_ID 	INT,
			@Use_Operator_Legacy_ID	BIT,
			@DateWithTimeZoneDiff INT,
			@useDayLightSavingsTime BIT,
			@bAutoPay BIT

			SET @DateWithTimeZoneDiff = #DiffLocalTimeZoneAndEST#

			<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
			SET @useDayLightSavingsTime = #useDayLightSavingsTime#

			<!--- App setting BB Search Flex - only display parent billback in search results --->
			<cfset var bOnlyDisplayBillbackParent = appSettings.getDisplayOnlyBillbackParent() />

			<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

			SET	@Billback_ID_Int = #nBillbackID#

			IF OBJECT_ID('tempdb..##TMP_Payee_Data') IS NOT NULL
			DROP TABLE ##TMP_Payee_Data

			CREATE  TABLE ##TMP_Payee_Data
			(
				Billback_ID_Int	INT				NOT NULL,
				Name			NVARCHAR(255)	NULL,
				Payee_Id		NVARCHAR(75)	NULL,
				AddressLine1	NVARCHAR(255)	NULL,
				AddressLine2	NVARCHAR(255)	NULL,
				City			NVARCHAR(75)	NULL,
				State			NVARCHAR(25)	NULL,
				Zip_Code		NVARCHAR(12)	NULL,
				ID				NVARCHAR(50)	NULL,
				Vendor_ID		NVARCHAR(50)	NULL
			)

			IF OBJECT_ID('tempdb..##TMP_Payee_Vendor_Data') IS NOT NULL
			DROP TABLE ##TMP_Payee_Vendor_Data

			CREATE  TABLE ##TMP_Payee_Vendor_Data
			(
				Billback_ID_Int	INT				NOT NULL,
				Name			NVARCHAR(255)	NULL,
				Payee_Id		NVARCHAR(75)	NULL,
				AddressLine1	NVARCHAR(255)	NULL,
				AddressLine2	NVARCHAR(255)	NULL,
				City			NVARCHAR(75)	NULL,
				State			NVARCHAR(25)	NULL,
				Zip_Code		NVARCHAR(12)	NULL
			)

			IF OBJECT_ID('tempdb..##TMP_BB_User_Agree') IS NOT NULL
			DROP TABLE ##TMP_BB_User_Agree

			CREATE  TABLE ##TMP_BB_User_Agree
			(
				Billback_ID_Int	INT	NOT NULL,
				UserAgreed	BIT	NULL
			)


			/* Get the Billback Payee Type */
			SELECT @Billback_Payee_Type_ID = Billback_Payee_Type_ID,
			@bAutoPay =  Auto_Billback,
			@Billback_Status_ID =  Billback_Status_ID
			FROM Billback WHERE Billback_ID_Int = @Billback_ID_Int

			/* Determine whether or not to use Operator Legacy ID */
			SELECT @Use_Operator_Legacy_ID = ISNULL(Operator_Legacy_ID_On, 0) FROM CUSTOMER_SETTINGS

			/*  Depending on the Billback Type ID populate the TMP_Payee_Data table */
			IF @Billback_Payee_Type_ID = 1
			BEGIN
				INSERT INTO ##TMP_Payee_Data (Billback_ID_Int, Name, Payee_Id, AddressLine1, AddressLine2, City, State, Zip_Code, ID, Vendor_ID)
				SELECT	DISTINCT BB.Billback_ID_Int,
						CASE WHEN VM.Vendor_ID IS NOT NULL AND @bAutoPay = 1 THEN '** Auto Pay **' ELSE BFC.Name END,
						BFC.Shr_Ship_To,
						BFC.Address_1,
						BFC.Address_2,
						BFC.City,
						BFC.State,
						BFC.ZipCode,
						CAST(BFC.BSA_Foodservice_Customers_ID AS NVARCHAR(50)),
						ISNULL(BD.Uploaded_Vendor_ID,ISNULL(VDO.Vendor_ID,VM.Vendor_ID))
				FROM Billback BB
				LEFT JOIN Billback_Distributor BD ON
					BD.Billback_ID = BB.Billback_ID AND
					BD.Deleted = 0
				LEFT JOIN BSA_Foodservice_Customers BFC ON
					BD.Distributor_ID = BFC.BSA_Foodservice_Customers_ID
				LEFT JOIN Vendor_Master VM ON
					BD.Distributor_ID = VM.Vendor_Master_Id
				LEFT JOIN Vendor_Dist_Oper VDO ON
					VDO.Distributor_ID = BFC.BSA_Foodservice_Customers_ID AND
					VDO.Deleted = 0
				WHERE BB.Billback_ID_Int = @Billback_ID_Int

			END
			ELSE IF @Billback_Payee_Type_ID = 2
			BEGIN
				INSERT INTO ##TMP_Payee_Data (Billback_ID_Int, Name, Payee_Id, AddressLine1, AddressLine2, City, State, Zip_Code, ID, Vendor_ID)
				SELECT	DISTINCT BB.Billback_ID_Int, BSAO.Operator_Name, CASE WHEN @Use_Operator_Legacy_ID = 0 THEN BSAO.BSA_Operator_ID ELSE BSAO.Legacy_ID END,
						BSAO.Operator_Address, BSAO.Operator_Address2, BSAO.Operator_City, BSAO.Operator_State, BSAO.Operator_Zip,
						CAST(BSAO.BSA_Operator_ID AS NVARCHAR(50)), CASE WHEN BO.Uploaded_Vendor_ID IS NULL THEN Vendor_Dist_Oper.Vendor_ID ELSE  BO.Uploaded_Vendor_ID END
				FROM	Billback_Operator BO
						INNER JOIN Billback BB ON BB.Billback_ID = BO.Billback_ID AND BB.Billback_ID_Int = @Billback_ID_Int
						INNER JOIN BSA_Operator BSAO ON BSAO.BSA_Operator_ID = BO.Operator_ID
						LEFT JOIN Vendor_Dist_Oper ON Vendor_Dist_Oper.Operator_ID = BSAO.BSA_Operator_ID AND Vendor_Dist_Oper.Deleted = 0
				WHERE	BO.Deleted = 0
			END
			ELSE IF @Billback_Payee_Type_ID = 3
			BEGIN
				INSERT INTO ##TMP_Payee_Data (Billback_ID_Int, Name, Payee_Id, AddressLine1, AddressLine2, City, State, Zip_Code, ID, Vendor_ID)
				SELECT	DISTINCT BB.Billback_ID_Int, BFS.Broker_Name, BFS.Broker_Legcy_Shard, BFS.Address, BFS.Address_2, BFS.City, BFS.State, BFS.Zip,
						CAST(BFS.BSA_Foodservice_Brokers_ID AS NVARCHAR(50)), NULL
				FROM	BSA_Foodservice_Brokers BFS
						INNER JOIN Billback_Broker BBB ON BBB.Broker_ID = BFS.BSA_Foodservice_Brokers_ID AND BBB.Deleted = 0
						INNER JOIN Billback BB ON BB.Billback_ID = BBB.Billback_ID AND BB.Billback_ID_Int = @Billback_ID_Int AND BB.Deleted = 0
			END

			IF @Billback_Status_ID >= 3
				BEGIN
					INSERT INTO ##TMP_Payee_Vendor_Data (Billback_ID_Int, Name, Payee_Id, AddressLine1, AddressLine2, City, State, Zip_Code)
					SELECT	DISTINCT ##TMP_Payee_Data.Billback_ID_Int, Vendor_Master.Vendor_Name, Vendor_Master.Vendor_ID, Vendor_Master.Address_1, Vendor_Master.Address_2, Vendor_Master.City, Vendor_Master.State, Vendor_Master.ZipCode
					FROM 	Vendor_Master
							INNER JOIN ##TMP_Payee_Data ON ##TMP_Payee_Data.Vendor_ID = Vendor_Master.Vendor_ID
					WHERE 	Vendor_Master.Deleted = 0
				END
			ELSE
				BEGIN
					INSERT INTO ##TMP_Payee_Vendor_Data (Billback_ID_Int, Name, Payee_Id, AddressLine1, AddressLine2, City, State, Zip_Code)
					SELECT	DISTINCT ##TMP_Payee_Data.Billback_ID_Int, Vendor_Master.Vendor_Name, Vendor_Master.Vendor_ID, Vendor_Master.Address_1, Vendor_Master.Address_2, Vendor_Master.City, Vendor_Master.State, Vendor_Master.ZipCode
					FROM 	Vendor_Master
							INNER JOIN ##TMP_Payee_Data ON ##TMP_Payee_Data.Vendor_ID = Vendor_Master.Vendor_ID
					WHERE 	Vendor_Master.Active_Code = 'A'
					AND		Vendor_Master.Deleted = 0
				END

			/* Get a list of billbacks which have been agreed to by the logged in user */
			INSERT INTO ##TMP_BB_User_Agree(Billback_ID_Int,UserAgreed)
			SELECT Billback.Billback_ID_Int, 1
			FROM BB_Agreed_Info
			INNER JOIN Billback
			ON BB_Agreed_Info.Billback_id = Billback.Billback_id
			AND BB_Agreed_Info.deleted = 0
			AND Billback.Deleted = 0
			AND BB_Agreed_Info.User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">

			if object_id('tempdb..##tmp_Approved_bb') is not null
			drop table ##tmp_Approved_bb

			CREATE TABLE ##tmp_Approved_bb
			(
				Billback_ID_Int int NOT NULL,
				BB_Closing_Method varchar(25)
			)

			<!--- If only parent billbacks are displayed in the search result, then get the closing method of the child billbacks as a comma-delimited list
			as the closing method of the parent billback. The users should be able to search on the child billbacks as these are the actual closing method
			of the billback. --->
			<cfif bOnlyDisplayBillbackParent>
			INSERT INTO ##tmp_Approved_bb(Billback_ID_Int,BB_Closing_Method)

			SELECT parent.Billback_ID_Int,
					BB_Closing_Method = REPLACE(
				(
					SELECT      child.BB_Closing_Method AS [data()]
					FROM  BILLBACK child
					WHERE child.BB_Parent_ID = parent.Billback_ID
					AND   child.Deleted = 0
					AND child.Billback_Status_ID >= 3
					FOR XML PATH ('')
				), ' ', ',')
			FROM  BILLBACK parent
			WHERE   parent.Deleted = 0
			AND   parent.BB_Parent_ID is null
			AND Billback_Status_ID >= 3
			AND parent.Billback_ID_Int = #nBillbackID#
			</cfif>

			/* Get Billback data */
			SELECT	Billback.Billback_ID,
					Billback.Billback_ID_Int,
					Billback.BB_Code,
					Billback.BB_Reference AS BB_Reference,
					Billback.referenceNum AS referenceNum,
					Billback.BB_Title,
					Billback.BB_Amount,
					Billback.Uploaded_Billback,
					BB_Approved.Approved_Amount AS Approved_Amount,
					<!---  Use DateAdd to add or subtract time for the specific timezone of the user.Get the new date based on Time Zone.
					For eg: If a person logs in to the flex application from CST time zone, then the date would be one hour more than the value in the db.
					--->
					/*
					dbo.get_TimeZoneOffset_Date(Billback.Created_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Created_Date,
					dbo.get_TimeZoneOffset_Date(Billback.BB_Request_Approval_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Request_Approval_Date,
					dbo.get_TimeZoneOffset_Date(Billback.BB_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Date,
					dbo.get_TimeZoneOffset_Date(Billback.BB_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Start_Date,
					dbo.get_TimeZoneOffset_Date(Billback.BB_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_End_Date,
					dbo.get_TimeZoneOffset_Date(BB_Approved.Date_Approved,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Date_Approved,
					dbo.get_TimeZoneOffset_Date(Billback.BB_Received_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Received_Date,
					dbo.get_TimeZoneOffset_Date(Billback.Postmark_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Postmark_Date,
					dbo.get_TimeZoneOffset_Date(BB_Approved.Check_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Check_Date,
					dbo.get_TimeZoneOffset_Date(billback.Paid_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As Paid_Date,
					*/
					Billback.Created_Date As Created_Date,
					Billback.BB_Request_Approval_Date As BB_Request_Approval_Date,
					Billback.BB_Date As BB_Date,
					Billback.BB_Start_Date As BB_Start_Date,
					Billback.BB_End_Date As BB_End_Date,
					BB_Approved.Date_Approved As Date_Approved,
					Billback.BB_Received_Date As BB_Received_Date,
					Billback.Postmark_Date As Postmark_Date,
					BB_Approved.Check_Date As Check_Date,
					billback.Paid_Date As Paid_Date,
					Billback.Payment_Notes,
					Billback.Special_Handling,
					CASE
						WHEN (SELECT COUNT(*) FROM Contract_Attachments WHERE Billback_ID = Billback.Billback_ID AND Deleted = 0) > 0 THEN 1
						ELSE 0
					END AS Document_Attached,
					BB_Approved.Check_Number AS Check_Number,
					BB_Approved.Check_Amount,
					BB_Approved.Document_Number_1,
					BB_Approved.Document_Number_2,
					Billback.Billback_Status_ID,
					Billback_Status.BB_Status_Description,
					Billback_Status.BB_Status_Abbreviation,
					Billback.BB_Closing_Method As Billback_Closing_Method_ID,
					CASE
						WHEN LEN(##tmp_Approved_bb.billback_ID_Int) > 0 AND #bOnlyDisplayBillbackParent# = 1 THEN  ##tmp_Approved_bb.BB_Closing_Method
					ELSE
						''
					END

						As Billback_Closing_Method_ID_List,
					CASE
						WHEN LEN(##tmp_Approved_bb.billback_ID_Int) > 0 AND #bOnlyDisplayBillbackParent# = 1 THEN 'MULTI'
					ELSE
						Billback_Closing_Methods.vchBillback_Closing_Method_Desc
					END

						As Billback_Closing_Method_Desc,
					CASE
					WHEN LEN(##tmp_Approved_bb.billback_ID_Int) > 0 AND #bOnlyDisplayBillbackParent# = 1 THEN 'MULTI'
					ELSE
						Billback_Closing_Methods.abbreviation
					END

						As Billback_Closing_Method_Abbreviation,
					CASE
						<!--- The order of the case statement is important. --->
						WHEN Auto_Approved = 1 AND Approval_Type = 2 THEN 5
						WHEN Auto_Billback = 1 THEN 4
						WHEN Uploaded_Billback = 0 THEN 1
						WHEN Uploaded_Billback = 2 THEN 2
						WHEN Uploaded_Billback = 3 THEN 3
					END
						AS BB_Type_ID,
					CASE
						<!--- The order of the case statement is important. --->
						WHEN Auto_Approved = 1 AND Approval_Type = 2 THEN 'Auto Approved'
						WHEN Auto_Billback = 1 THEN 'Auto Pay'
						WHEN Uploaded_Billback = 0 THEN 'Manual'
						WHEN Uploaded_Billback = 2 THEN 'Upload'
						WHEN Uploaded_Billback = 3 THEN '3rd Party'
					END AS BB_Type_Description,
					Analyst_User.Sales_Person_ID AS Analyst_User_Int,
					Analyst_User.User_ID as Analyst_User_ID,
					Analyst_User.Name_First + ' ' + Analyst_User.Name_Last AS Analyst_User,
					Creator_User.Sales_Person_ID AS Creator_User_Int,
					Creator_User.Name_First + ' ' + Creator_User.Name_Last AS Creator_User,
					Request_Approval_User.Sales_Person_ID AS Request_Approval_User_Int,
					Request_Approval_User.Name_First + ' ' + Request_Approval_User.Name_Last AS Request_Approval_User,
					Disagree_User.Sales_Person_ID AS Disagree_User_Int,
					Disagree_User.Name_First + ' ' +Disagree_User.Name_Last AS Disagree_User,
					Reset_User.Sales_Person_ID AS Reset_User_Int,
					Reset_User.Name_First + ' ' + Reset_User.Name_Last AS Reset_User,
					Approved_User.Sales_Person_ID AS Approved_User_Int,
					Approved_User.Name_First + ' ' + Approved_User.Name_Last AS Approved_User,
					Billback.Billback_Payee_Type_ID,
					##TMP_Payee_Data.Name AS Payee,
					##TMP_Payee_Data.Payee_Id,
					##TMP_Payee_Data.AddressLine1 AS address1,
					##TMP_Payee_Data.AddressLine2 AS AddressLine2,
					##TMP_Payee_Data.City,
					##TMP_Payee_Data.State,
					##TMP_Payee_Data.Zip_Code AS zipCode,
					##TMP_Payee_Data.ID AS payeeUUId,
					CASE
					WHEN
						(
						<!--- RFA and Approved --->
						billback.Billback_Status_ID IN (2,3)
						OR
							(
							<!--- Payment Request  --->
							billback.Billback_Status_ID IN (4)
									AND
									(
										(
										<!--- To allow reset, getBBAllowResetBeforePMTInterfacePRStatus is 1 and interface has not been sent --->
										(#appSettings.getBBAllowResetBeforePMTInterfacePRStatus()# = 1 AND billback.BB_Payment_Request_Sent = 0)
										AND
										<!--- To allow reset, billback.DD_Closure_Sent_On should be blank when getBBAllowResetAfterDEDInterface is 0.
										When getBBAllowResetAfterDEDInterface is 1, it is allowed --->
										(#appSettings.getBBAllowResetAfterDEDInterface()# = 1 OR billback.DD_Closure_Sent_On IS NULL)
										)
									OR
										(
										<!--- This condition has been initially added for GM. It can be used by other clients too --->
										(#appSettings.getBBAllowResetBeforePMTInterfacePRStatus()# = 1 AND billback.BB_Reversed = 0)
										AND
										(billback.BB_Payment_Request_Sent = 1 OR billback.DD_Closure_Sent_On IS NOT NULL)
										AND
										(billback.BB_Received_Ack_Type = 0)
										)
									)
							)
						)
						AND #Get_Profile_Settings.BB_Create# = 1
						<!--- When we display only parent billbacks on the bb search screen, reset is only allowed for parent billbacks and not for child billbacks (splits) --->
						<cfif bOnlyDisplayBillbackParent>
						AND Billback.BB_Parent_ID IS NULL
						<cfelse>
						<!--- When we display parent billbacks and child billbacks on the bb search screen, reset is only allowed for child billbacks (split) and not for the parent billback --->
						AND Billback.BB_Parent_ID IS NOT NULL
						</cfif>
						AND Billback.Auto_Billback = 0
						<!--- When we display only parent billbacks on the bb search screen, then the billback (parent of a split or a split of a parent or not a split bb), can be reset, even if it
						is associated to a deduction or one of its splits is associated to a deduction as the reset code unassociates the deduction.
						When we display all the billbacks (parent and split), then since we can only split the child (split) bb, the child bb cannot be reset if it is associated to a deduction. The user
						needs to manually unassociate the deduction. This is important as one deduction can be associated to multiple billbacks. --->
						<cfif bOnlyDisplayBillbackParent eq 0>
						AND Billback.BB_Associated_To_DD = 0
						</cfif>
					THEN 1
					ELSE 0
					END
					As ResetAllowed,
					CASE
					WHEN
						(
						<!--- GM does not want to delete bb in approved status --->
						<!--- WIP,RFA,Pending Fund Update,Pending Vendor ID --->
						billback.Billback_Status_ID IN (1,2,6,7)
						OR
							(
								<!--- Payment Request --->
								billback.Billback_Status_ID IN (4)
								AND
								(
								billback.BB_Payment_Request_Sent = 0
								)
							)
							<!--- Approved - VOID  --->
							<!--- GM does not want to delete bb in approved void status --->
							<!---
							OR
							(
								billback.Billback_Status_ID IN (8)
								AND
								(
								(#appSettings.getBBAllowReverse()# = 0 OR billback.BB_Approved_Void_Ack_Type = 1)
								)
							)
							--->
						)
						AND billback.DD_Closure_Sent_On IS NULL
						<!--- When we display only parent billbacks on the bb search screen, delete is only allowed for parent billbacks and not for child billbacks (splits) --->
						<cfif bOnlyDisplayBillbackParent>
						AND Billback.BB_Parent_ID IS NULL
						<cfelse>
						<!--- When we display parent billbacks and child billbacks on the bb search screen, delete is only allowed for child billbacks (split) and not for the parent billback --->
						AND Billback.BB_Parent_ID IS NOT NULL
						</cfif>
						AND #Get_Profile_Settings.BB_Delete# = 1
					THEN 1
					ELSE 0
					END
					As DeleteAllowed,
					CASE
					WHEN
					(
						(
						(#appSettings.getBBReinterfaceUnacknowledgedInterface()# = 1 AND billback.BB_Reversed = 0)
						AND
						(billback.BB_Payment_Request_Sent = 1 OR billback.DD_Closure_Sent_On IS NOT NULL)
						AND
						(billback.BB_Received_Ack_Type = 0)
						)
						OR
						(
						(#appSettings.getBBReinterfaceUnacknowledgedInterface()# = 1 AND billback.BB_Reversed = 1)
						AND
						(billback.Reversal_Sent = 1)
						AND
						(billback.BB_Received_Ack_Type = 0)
						)
					)
					THEN 1
					ELSE 0
					END

					As notAcknowledged,
					0 AS releaseAllowed,
					0 AS holdAllowed,
					CASE
						WHEN
							billback.Billback_Status_ID = 2
						THEN 1
						ELSE 0
						END
					As MassApproveAllowed,
					Billback.Claim_Cases,
					Billback.Claim_Pounds,
					SubString(Billback.BB_Code,charIndex('-',Billback.BB_Code)+1,len(Billback.BB_Code)) As Searchable_BB_Code,
					CASE WHEN
						billback.Billback_Status_ID = 2
						OR
						(
							billback.Billback_Status_ID = 3
							AND
							#appSettings.getUpdate_BB_Approve_Amt()# = 1
						)
						AND billback.DD_Closure_Sent_on IS NULL  AND billback.Auto_Billback = 0
						THEN 1
						ELSE 0
						END
					As deviationAllowed,
					Billback.BB_Creator_Notes,
					Billback.Deviated,
					##TMP_Payee_Vendor_Data.Name AS vendorPayee,
					##TMP_Payee_Vendor_Data.Payee_Id AS vendorPayeeId,
					##TMP_Payee_Vendor_Data.AddressLine1 AS vendorAddress1,
					##TMP_Payee_Vendor_Data.AddressLine2 AS vendorAddressLine2,
					##TMP_Payee_Vendor_Data.City AS vendorCity,
					##TMP_Payee_Vendor_Data.State AS vendorState,
					##TMP_Payee_Vendor_Data.Zip_Code AS vendorZipCode,
					/* If the billback has been "agreed to" by the "logged-in" user, Use 1, else 0 */
					CASE
						WHEN
							##TMP_BB_User_Agree.UserAgreed  = 1
						THEN 1
						ELSE 0
						END
					As userAgreed,
					CASE
						WHEN	billback.Billback_Status_ID IN (1,2) THEN 1
						ELSE 0
					END AS ReassignAllowed,
					Distributor_Bill_To.Bill_To AS billTo,
					Distributor_Bill_To.Name AS billToName,
					Distributor_Bill_To.Distributor_Bill_To_ID AS billToId,
					Distributor_Bill_To.Address1 AS billToAddress1,
					Distributor_Bill_To.Address2 AS billToAddress2,
					Distributor_Bill_To.City AS billToCity,
					Distributor_Bill_To.State AS billToState,
					Distributor_Bill_To.Zip AS billToZipCode,
					BSA_Foodservice_Customers.Ship_To AS billToShipTo,
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS billToShipToId,
					CASE
						WHEN Billback.Billback_Status_ID = 1 THEN 0
						WHEN Billback.Deviation_Ran_Date IS NULL THEN 0
						ELSE 1
					END AS bDisplaySettlement,
					'#strBBDefaultProgram#' AS strDefaultProgram,
					BTUHL.Upload_ID,
					Billback.BB_Upload_Dup_Group_ID
			FROM	Billback
					LEFT JOIN ##TMP_Payee_Data ON ##TMP_Payee_Data.Billback_ID_Int = Billback.Billback_ID_Int
					LEFT JOIN BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
					INNER JOIN Billback_Status ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
					INNER JOIN Billback_Closing_Methods ON Billback_Closing_Methods.iBillback_Closing_Method_ID = Billback.BB_Closing_Method
					LEFT JOIN _Users Analyst_User ON Analyst_User.User_ID = Billback.Analyst_User_ID
					LEFT JOIN _Users Creator_User ON Creator_User.User_ID = Billback.BB_Creator_ID
					LEFT JOIN _Users Request_Approval_User ON Request_Approval_User.User_ID = Billback.BB_Request_Approval_User_ID
					LEFT JOIN _Users Disagree_User ON Disagree_User.User_ID = Billback.BB_Disagree_By
					LEFT JOIN _Users Reset_User ON Reset_User.User_ID = Billback.BB_Reset_User_ID
					LEFT JOIN _Users Approved_User ON Approved_User.User_ID = BB_Approved.User_Approved
					LEFT JOIN ##TMP_Payee_Vendor_Data ON ##TMP_Payee_Vendor_Data.Billback_ID_Int = Billback.Billback_ID_Int
					LEFT JOIN ##TMP_BB_User_Agree ON ##TMP_BB_User_Agree.Billback_ID_Int = Billback.Billback_ID_Int
					LEFT JOIN BillTo_ShipTo_Relations ON BillTo_ShipTo_Relations.Distributor_Bill_To_ID = Billback.Distributor_Bill_To_ID
					LEFT JOIN Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = BillTo_ShipTo_Relations.Distributor_Bill_To_ID AND Distributor_Bill_To.Deleted = 0
					LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BillTo_ShipTo_Relations.BSA_Foodservice_Customers_ID AND BSA_Foodservice_Customers.Deleted = 0
					LEFT JOIN ##tmp_Approved_bb ON ##tmp_Approved_bb.Billback_ID_Int = Billback.Billback_ID_Int AND ##tmp_Approved_bb.BB_Closing_Method IS NOT NULL
					LEFT JOIN Billback_Txt_Upload_Header_log BTUHL
				ON BTUHL.Billback_ID = Billback.Billback_ID
			WHERE 	Billback.Billback_ID_Int = @Billback_ID_Int

		</cfquery>

		<cfset qRetBillbackData = qBillbackData />

		<cfreturn qRetBillbackData />

	</cffunction>

	<cffunction name="getBBComponentData" output="false" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID					= "";
			var qBillbackComponentData		= "";
			var qRetBillbackComponentData	= "";

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
		</cfscript>

		<cfquery datasource="#application.datasource#" name="qBillbackComponentData">
			/* Fixed */
			SELECT	DISTINCT
					Billback_Program.Program_ID AS programID,
					Billback_Program.Billback_Program_ID AS bbProgramID,
					1 AS componentTypeId,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID AS componentNameId,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name AS componentName,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name AS componentDesc,
					SUM(CAST(Billback_Product_Detail.BB_Rate AS DECIMAL(20,2))) AS componentAmount,
					Contract_Main.Contract_Number AS programNumber,
					Contract_Main.Contract_Title AS programTitle,
					Program_Fixed_Component.Fixed_Component_Paid_to AS paidTo,
					CASE
						WHEN Program_Fixed_Component.Fixed_Component_Paid_to = 1 THEN 'Distributor'
						ELSE 'Operator'
					END AS description,
					CASE WHEN Contract_Main.Deleted = 1 THEN 0 ELSE 1 END AS bIsLatestVersion,
					'' AS compDescription,
					'' AS compRate,
					CAST(Billback_Program.Program_Fixed_Component_ID AS VARCHAR(50)) AS programComponentId
			FROM Billback
			INNER JOIN Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND Billback_Program.Deleted = 0
			INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			INNER JOIN Billback_Product ON Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID AND Billback_Product.Deleted = 0
			INNER JOIN Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND Billback_Product_Detail.Deleted = 0
					AND	Billback_Product_Detail.BB_Product_Type_ID = 1
			INNER JOIN Program_Fixed_Component ON Program_Fixed_Component.Program_Fixed_Component_ID = Billback_Program.Program_Fixed_Component_ID
					AND Program_Fixed_Component.Program_ID = Contract_Main.Contract_Main_ID AND Program_Fixed_Component.Deleted = 0
			INNER JOIN Program_Fixed_Component_Name
				ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
					AND Program_Fixed_Component_Name.Deleted = 0
			WHERE	Billback.Billback_ID_Int = <cfqueryparam value="#nBillbackID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Billback.Deleted = 0
			GROUP BY
					Billback_Program.Program_ID,
					Billback_Program.Billback_Program_ID,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,
					Program_Fixed_Component_Name.Program_Fixed_Component_Name,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Program_Fixed_Component.Fixed_Component_Paid_to,
					Billback_Program.Program_Fixed_Component_ID,
					Contract_Main.Deleted

			UNION
			/* Rebate */
			SELECT	DISTINCT
					Billback_Program.Program_ID AS programID,
					Billback_Program.Billback_Program_ID AS bbProgramID,
					2 AS componentTypeId,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID AS componentNameId,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name AS componentName,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name AS componentDesc,
					SUM(CAST(Billback_Product_Detail.BB_Rate AS DECIMAL(20,2))) AS componentAmount,
					Contract_Main.Contract_Number AS programNumber,
					Contract_Main.Contract_Title AS programTitle,
					Program_Rebates_Component.Component_Paid_To AS paidTo,
					CASE
						WHEN Program_Rebates_Component.Component_Paid_To = 1 THEN 'Distributor'
						ELSE 'Operator'
					END AS description,
					CASE WHEN Contract_Main.Deleted = 1 THEN 0 ELSE 1 END AS bIsLatestVersion,
					'' AS compDescription,
					'' AS compRate,
					Billback_Program_Rebate_Component.Program_Rebates_Component_ID AS programComponentId
			FROM	Billback
					INNER JOIN Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND Billback_Program.Deleted = 0
					INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN Billback_Product ON Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID and Billback_Product.Deleted = 0
					INNER JOIN Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID AND Billback_Product_Detail.Deleted = 0
					AND	Billback_Product_Detail.BB_Product_Type_ID = 2
					INNER JOIN Billback_Program_Rebate_Component ON Billback_Program_Rebate_Component.Billback_ID = Billback_Product.Billback_ID AND Billback_Program_Rebate_Component.Deleted = 0
									AND Billback_Program.Program_ID = Billback_Program_Rebate_Component.Billback_Program_ID
					INNER JOIN Program_Rebates_Component_Name ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Billback_Program_Rebate_Component.Program_Rebates_Component_Name_ID
					INNER JOIN Program_Rebates_Component ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
									AND	Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID AND Program_Rebates_Component.Deleted = 0
			WHERE	Billback.Billback_ID_Int = <cfqueryparam value="#nBillbackID#" cfsqltype="CF_SQL_INTEGER" />
			AND		Billback.Deleted = 0
			-- AND 	Billback_Product_Detail.BB_Product_Type_ID = 2
			GROUP BY
					Billback_Program.Program_ID,
					Billback_Program.Billback_Program_ID,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Program_Rebates_Component.Component_Paid_To,
					Billback_Program_Rebate_Component.Program_Rebates_Component_ID,
					Contract_Main.Deleted

			UNION
			/* Lumpsum */
			SELECT	DISTINCT
					Billback_Program.Program_ID AS programID,
					Billback_Program.Billback_Program_ID AS bbProgramID,
					3 AS componentTypeId,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID AS componentNameId,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name AS componentName,
					Program_Lump_Sums.Lump_Sum_Description AS componentDesc,
					CAST(Billback_Program_Lumpsum_Component.Amount AS DECIMAL(20,2)) AS componentAmount,
					Contract_Main.Contract_Number AS programNumber,
					Contract_Main.Contract_Title AS programTitle,
					Program_Lump_Sums.Component_Paid_To AS paidTo,
					CASE
						WHEN Program_Lump_Sums.Component_Paid_To = 1 THEN 'Distributor'
						ELSE 'Operator'
					END AS description,
					CASE WHEN Contract_Main.Deleted = 1 THEN 0 ELSE 1 END AS bIsLatestVersion,
					Program_Lump_Sums.Lump_Sum_Description AS compDescription,
					Program_Lump_Sums.Lump_Sum_Amount AS compRate,
					CAST(Program_Lump_Sums.Program_Lump_Sum_ID AS NVARCHAR(50)) AS programComponentId
			FROM	Billback
					INNER JOIN Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND Billback_Program.Deleted = 0
					INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN Billback_Program_Lumpsum_Component ON Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID
									AND Billback_Program_Lumpsum_Component.Deleted = 0
					INNER JOIN Program_Lump_Sums ON Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID AND Program_Lump_Sums.Deleted = 0
									AND	Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Lump_Sum_Name ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE	Billback.Billback_ID_Int = <cfqueryparam value="#nBillbackID#" cfsqltype="CF_SQL_INTEGER" />
			AND		Billback.Deleted = 0

		</cfquery>

		<cfset qRetBillbackComponentData = qBillbackComponentData />

		<cfreturn qRetBillbackComponentData />

	</cffunction>

	<!--- get billback duplicates--->
	<cffunction name="getBBDuplicateData" access="public" returntype="query">

		<cfargument name="billbackIDInt" 	required="true"	type="numeric" />
		<cfargument name="billbackNumber" 	required="true" type="string">
		<cfargument name="vendorNumber" 	required="true" type="string">

		<cfscript>
			//set local variables
			var nBillbackIntId		= "";
			var strBillbackNumber	= "";
			var strVendorNumber		= "";
			var qGetDuplicates		= "";
			var qReturn				= "";
			var DiffLocalTimeZoneAndEST = 0;
			var useDayLightSavingsTime = 0;

			//assign local variables
			nBillbackIntId		= arguments.billbackIDInt;
			strBillbackNumber 	= trim(arguments.billbackNumber);
			strVendorNumber		= trim(arguments.vendorNumber);
			DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST();
			useDayLightSavingsTime  = int(request.AccessStructure.useDayLightSavingsTime);
		</cfscript>

		<cfquery name="qGetDuplicates" datasource="#application.datasource#">
		DECLARE
		@DateWithTimeZoneDiff int,
		@useDayLightSavingsTime bit

			SET @DateWithTimeZoneDiff = #DiffLocalTimeZoneAndEST#

			<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
			SET @useDayLightSavingsTime = #useDayLightSavingsTime#

			SELECT
			Billback.BB_Code, Billback.BB_Title, dbo.get_TimeZoneOffset_Date(Billback.BB_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_Start_Date,
			dbo.get_TimeZoneOffset_Date(Billback.BB_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As BB_End_Date, Billback.BB_Amount, _Users.Name_First + ' ' + _Users.Name_Last AS Created_By, Billback.Created_Date

			FROM	Billback
					INNER JOIN _Users ON _Users.User_ID = Billback.BB_Creator_ID
			WHERE	Billback_ID_Int != <cfqueryparam cfsqltype="cf_sql_integer" value="#nBillbackIntId#">
			AND		Billback.Deleted = 0
			AND		BB_Reference =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#strBillbackNumber#">
			AND
			(
				EXISTS
				(
					SELECT
					-- TOP 1
					Uploaded_Vendor_ID
					FROM	Billback_Distributor
					WHERE	Billback_Distributor.Billback_ID = Billback.Billback_ID
					AND		Billback_Distributor.Uploaded_Vendor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#strVendorNumber#">
					AND		Billback_Distributor.Deleted = 0
				)
				OR EXISTS
				(
					SELECT
					-- TOP 1
					Uploaded_Vendor_ID
					FROM	Billback_Operator
					WHERE	Billback_Operator.Billback_ID = Billback.Billback_ID
					AND		Billback_Operator.Uploaded_Vendor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#strVendorNumber#">
					AND		Billback_Operator.Deleted = 0
				)
			)
		</cfquery>
		<cfscript>
			qReturn = qGetDuplicates;
			return qReturn;
		</cfscript>

	</cffunction>

	<cffunction name="setReverseBillback" access="public" returntype="void" >

		<cfargument name="billbackID" 	required="true"	type="string" />
		<cfargument name="userId" 		required="true"	type="string" />

		<cfscript>
			//set local variables
			var sBillbackId		= "";
			var sUserId		= "";
			//assign local variables
			sBillbackId		= arguments.billbackID;
			sUserId			= arguments.userId;
		</cfscript>

		<!--- get Closing Method --->
		<cfquery name="qGetReverseBBs" datasource="#application.datasource#">
			SELECT	BB_Closing_Method, BB_Associated_To_DD, Billback_ID as reverseBBID
			FROM	Billback
			WHERE 	(Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBillbackId#"> OR
					BB_Parent_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBillbackId#">)
		</cfquery>

		<!--- Set the billback as reversed and the Status to "Approved - Void" --->
		<cfquery name="qUpdateReverseBB" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Billback_Status_ID = 8,
					BB_Void_Multiplier = -1,
					BB_Void_Notification_Sent = 0,
					BB_Void_Date = getdate(),
					/*
					-- 34998: What should show in closing details on a reversal/ Anand Rao / 29-Nov-2012
					-- BB_Associated_To_DD = 0,
					*/
					BB_Reversed = 1,
					BB_Reversed_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sUserId#">,
					BB_Reversed_Date = getdate(),
					BB_Received_Ack_Type = 0
			WHERE	(Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBillbackId#"> OR
					BB_Parent_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBillbackId#">)
		</cfquery>

		<!--- loop thru the parent and sibling BB's and reverse all budgets or DD based on the closing type --->
		<cfloop query="qGetReverseBBs">
			<!--- Closing Method = 1 [payment]; reset budgets--->
			<cfif qGetReverseBBs.BB_Closing_Method eq 1>
				<!--- D30648  - Budget changes on Billback Reset,Reversal/Anand Rao/27-Feb-2012  --->
				<!--- Earlier the SP budget_program_actual_update was getting called here // ADV_BUDGET_ACTUAL_ADD_BILLBACK --->
				<!--- <cfstoredproc procedure="ADV_BUDGET_ACTUAL_ADD_BILLBACK" datasource="#application.datasource#">
					<cfprocparam type="In" cfsqltype="cf_sql_varchar"  dbVarName = "@Billback_ID" value="#qGetReverseBBs.reverseBBID#">
				</cfstoredproc> --->
				<cfset CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").addBillbackToBudget(billbackId=qGetReverseBBs.reverseBBID) />
			<!--- Closing Method = 2 [deduction]; reopen deductions --->
			<!---
				34998: What should show in closing details on a reversal/ Anand Rao / 29-Nov-2012
			--->
			<!---
				<cfelseif qGetReverseBBs.BB_Closing_Method eq 2 and qGetReverseBBs.BB_Associated_To_DD>
				<cfset temp = variables.oDeductionDAO.qReopenDDforBB(qGetReverseBBs.reverseBBID, sUserId) />
			--->
			</cfif>
		</cfloop>

	</cffunction>

	<!--- 48779 : Manaul Credit Void --->
	<cffunction name="setBBVoidCreditReq" access="remote" returntype="void" >

		<cfargument name="billbackID" 	required="true"	type="string" />
		<cfargument name="userId" 		required="true"	type="string" />

		<cfscript>
			//set & assign local variables
			var sBillbackId		= arguments.billbackID;;
			var sUserId				= arguments.userId;
		</cfscript>

		<!--- Set the billback as reversed and the Status to "Approved - Void" --->
		<cfquery name="qSetBBVoidCreditReq" datasource="#application.datasource#">
			UPDATE	Billback
			SET			Billback_Status_ID = 8,
							BB_Void_Notification_Sent = 0,
							BB_Void_Date = getdate(),
							BB_Reversed = 1,
							BB_Reversed_Date = getdate(),
							BB_Reversed_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sUserId#">
			WHERE		Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sBillbackId#">
		</cfquery>

		<!--- loop thru the parent and sibling BB's and reverse all budgets or DD based on the closing type --->
		<!--- reset budget for all closing methods --->
		<cfset CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").addBillbackToBudget(billbackId=sBillbackId) />

	</cffunction>

	<cffunction name="getVendor" access="public" returntype="query" >
		<cfargument name="Billback_ID" 	required="true"	type="string" />

		<cfset var vars = structnew()>
		<cfquery name="vars.result" datasource="#application.datasource#">
			DECLARE @vendor_id UNIQUEIDENTIFIER

			SELECT @vendor_id = Vendor_Master_Id
			FROM BB_Approved bba
			WHERE bba.Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength=40 value="#arguments.Billback_ID#">

			IF @vendor_id IS NOT NULL
				BEGIN
					SELECT *
					FROM Vendor_Master
					WHERE Vendor_Master_Id = @vendor_id
				END
			ELSE
				<!---if billback is not approved get vendor information in different method--->
				BEGIN
					DECLARE @bb_pay_type INT

					SELECT @bb_pay_type = BillBack_Payee_Type_Id
					FROM BillBack
					WHERE BillBack_Id = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength=40 value="#arguments.Billback_ID#">

					SELECT *
					FROM Vendor_Master
					WHERE Vendor_Id = ( CASE
						WHEN @bb_pay_type = 1
						THEN
							(SELECT DISTINCT UpLoaded_Vendor_Id
							FROM BillBack_Distributor
							WHERE Deleted = 0
							AND BillBack_Id = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength=40 value="#arguments.Billback_ID#">)
						WHEN @bb_pay_type = 2
						THEN
							(SELECT DISTINCT UpLoaded_Vendor_Id
							FROM BillBack_Operator
							WHERE Deleted = 0
							AND BillBack_Id = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength=40 value="#arguments.Billback_ID#">)
						ELSE
						'-0'
						END
						)
				END
		</cfquery>

		<cfreturn vars.result>
	</cffunction>

	<cffunction name="UpdateBBForReinterface" access="public" returntype="struct">
		<cfargument name="billbackIDInt" required="true" type="numeric" />

		<cfscript>
			var oBillbackMgr = CreateObject("component","mvc.Models.Billback.BillbackManager").init();

			//set local variables
			var sBillbackId		= "";
			var stReturnData	= structNew();

			//assign local variables
			sBillbackId	= getBillbackUUID(arguments.billbackIDInt);
		</cfscript>

		<cfquery name="qGetBBForReinterface" datasource="#application.datasource#">
			SELECT BB_Reversed
			FROM Billback
			WHERE billback_ID = <cfqueryparam value="#sBillbackId#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>

		<!--- If the billback is reversed, set these values --->
		<cfif qGetBBForReinterface.BB_Reversed eq 1>
			<cfquery name="qSetBBForReinterface" datasource="#application.datasource#">
				UPDATE	Billback
				SET
					Reversal_Sent = 0,
					BB_Received_Ack_Type = 0
				WHERE
				(
					billback_ID = <cfqueryparam value="#sBillbackId#" cfsqltype="CF_SQL_VARCHAR" />
					OR
					BB_Parent_ID = <cfqueryparam value="#sBillbackId#" cfsqltype="CF_SQL_VARCHAR" />
				)
			</cfquery>
		<!--- If the billback is not reversed, set these values --->
		<cfelse>
			<cfquery name="qSetBBForReinterface" datasource="#application.datasource#">
				UPDATE	Billback
				SET
					BB_Payment_Request_Sent = 0,
					DD_Closure_Sent_On = NULL
				WHERE
				(
					billback_ID = <cfqueryparam value="#sBillbackId#" cfsqltype="CF_SQL_VARCHAR" />
					OR
					BB_Parent_ID = <cfqueryparam value="#sBillbackId#" cfsqltype="CF_SQL_VARCHAR" />
				)
			</cfquery>
		</cfif>

		<!--- Return BBHeader --->
		<cfset stReturnData = oBillbackMgr.getBBHeader(arguments.billbackIDInt)>

		<cfreturn stReturnData>

	</cffunction>

	<cffunction name="getBillbackDefaultProgram" output="false" access="public" returntype="string" hint="Function that determines if a Billback has the default program then return it">

		<cfargument name="billbackIDInt" required="true" type="numeric">

		<cfscript>
			//set local variables
			var nBillbackIDInt			= "";
			var qCheckForDefaultProgram	= "";
			var strDefaultProgram		= 0;

			//assign local variables
			nBillbackIDInt	= arguments.billbackIDInt;

		</cfscript>

		<cfquery name="qCheckForDefaultProgram" datasource="#Application.Datasource#">
			DECLARE @Contract_Number varchar(25)

			SELECT	@Contract_Number = cm.Contract_Number
			FROM	Billback_Settings bs
					INNER JOIN Contract_Main cm on cm.Contract_Main_ID = bs.Default_Program

			SELECT	DISTINCT cm.Contract_Number
			FROM	Billback b
					INNER JOIN Billback_Program bp on bp.Billback_ID = b.Billback_ID and bp.Deleted = 0
					INNER JOIN Contract_Main cm on cm.Contract_Main_ID = bp.Program_ID and cm.Contract_Number = @Contract_Number
			WHERE	b.Billback_ID_Int = <cfqueryparam value="#nBillbackIDInt#" cfsqltype="CF_SQL_INTEGER">
			AND		b.Deleted = 0

		</cfquery>

		<cfif qCheckForDefaultProgram.RecordCount>
			<cfset strDefaultProgram = qCheckForDefaultProgram.Contract_Number />
		</cfif>

		<cfscript>

			//set and return value
			return strDefaultProgram;

		</cfscript>

	</cffunction>

</cfcomponent>