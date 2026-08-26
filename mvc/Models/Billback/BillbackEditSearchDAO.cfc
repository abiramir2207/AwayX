<!---
Name: 			BillbackEditSearchDAO.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/23/2011
Created By:    	Tim Ford
Description:	I am responsible DB edit search access for billback data.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackEditSearchDAO" displayname="BillbackEditSearchDAO">

	<!--- get program data--->
	<cffunction name="searchProgramList" output="false" access="public" returntype="query">

		<cfargument name="userId"			required="true"		type="string" />
		<cfargument name="startDate" 		required="true" 	type="date" />
		<cfargument name="endDate" 			required="true" 	type="date" />
		<cfargument name="payee" 			required="true" 	type="struct" />
		<cfargument name="programNumber"	required="false"	type="string" />
		<cfargument name="distributorId"	required="false"	type="string" />
		<cfargument name="operatorId"		required="false"	type="string" />
		<cfargument name="profileId"		required="false"	type="string" />


		<cfscript>
			//set local variables
			var strUserID		= "";
			var dtStartDate		= "";
			var dtEndDate		= "";
			var payeeId			= "";
			var nPayeeTypeId	= "";
			var strProgNumber	= "";
			var strDistNumber	= "";
			var strOperNumber	= "";
			var strProfileId	= "";
			var qSearch			= "";
			var qReturn			= "";
			var HQUser			= 0;

			//assign local variables
			strUserID		= arguments.userId;
			dtStartDate		= arguments.startDate;
			dtEndDate		= arguments.endDate;
			payeeId			= arguments.payee.payeeId;
			nPayeeTypeId	= arguments.payee.payeeTypeId;
			strProgNumber	= arguments.programNumber;
			strDistNumber	= arguments.distributorId;
			strOperNumber	= arguments.operatorId;
			strProfileId	= arguments.profileId;


		/**** TODO: Move this code out of the DAO and wrap it up in another function to be called from ****/
		if (not isDefined("request.AccessStructure"))
		{
			request.AccessStructure = structNew();
			request.AccessStructure.user_id = strUserID;
			request.AccessStructure.profiles_id = strProfileId;
		}

		variables.settingsService = createObject("component","mvc.Models.SettingsService");
		</cfscript>

		<!--- Deduct time difference between UTC and EST from the localtimezone passed to flex. This will give us the difference between
		      localtimezone and EST (in minutes)
		--->
		<cfset DiffLocalTimeZoneAndEST = variables.settingsService.DiffLocalTimeZoneAndEST()>

		<cfinclude template="/Scorecard/access_permissions.cfm" />

		<cfquery name="qSearch" datasource="#application.datasource#">

			DECLARE
			@Payee_Type_ID 					INT,
			@Expired_Number_Of_Days_Span 	INT,
			@Use_Operator_Legacy_ID			BIT,
			@Forbid_Type 					INT,
			@Bus_Seg_Enabled				BIT,
			@Restrict_Created_By_RSP		BIT,
			@User_Number_Restrict			BIT,
			@User_Number					NVARCHAR(50),
			@DateWithTimeZoneDiff int,
			@useDayLightSavingsTime bit

			SET @DateWithTimeZoneDiff = #DiffLocalTimeZoneAndEST#
			<!--- Without using "INT", the value is 'YES' without single quotes, causing issues in the "SET" Statement. --->
			SET @useDayLightSavingsTime = #int(request.AccessStructure.useDayLightSavingsTime)#


			SET @User_Number = ''

			<cfif not HQUser>
      			DECLARE
	  			@Positions_Below_Me table
	  			(
	  				Below_User_Positions_ID int NOT NULL
      			)

	  			INSERT INTO @Positions_Below_Me(Below_User_Positions_ID)
	  			SELECT	DISTINCT Below_User_Positions_ID
	  			FROM 	Positions_Below_Me
	  			WHERE 	User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
    		</cfif>

			SET @Payee_Type_ID  = #nPayeeTypeId#

			SELECT	@Restrict_Created_By_RSP = ISNULL(Profiles_Settings.Program_Scorecard_Restrict_Created_By, 0)
			FROM	Profiles_Settings
					INNER JOIN Profiles ON
					Profiles.Profiles_Id = Profiles_Settings.Profiles_id AND
					Profiles.Deleted = 0
			WHERE	Profiles_Settings.Profiles_ID = '#strProfileId#'

			SELECT	@Expired_Number_Of_Days_Span = ISNULL(Search_Expired_Program_Within, 0) FROM Billback_Settings

			SELECT @Bus_Seg_Enabled = Distributor_Enabled FROM Business_Segment_Enabled WHERE Deleted = 0

			SELECT 	@Forbid_Type = ForbidAllowProfilesInTemplates,
					@User_Number_Restrict = ISNULL(User_Number_Restrict, 0)
			FROM 	_Application_Settings

			IF (@User_Number_Restrict = 1 AND @Restrict_Created_By_RSP = 1)
			BEGIN
				SELECT @User_Number = ISNULL(User_Number, '') FROM _Users WHERE User_ID = '#strUserID#'
			END

			DECLARE @Profile_Forbidden_Template table
			(
				Template_ID int NOT NULL,
				Forbid_Access_Type int NOT NULL
			)

			INSERT 	INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
			SELECT 	DISTINCT Template_ID, Forbid_Access_Type
			FROM 	Profile_Forbidden_Template
			WHERE 	Deleted = 0
			AND 	Forbid_Type = @Forbid_Type
			AND 	profile_id = '#strProfileId#'


			IF OBJECT_ID('tempdb..##TMP_Billback_Edit_Search_Payee_IDs') IS NOT NULL
			DROP TABLE ##TMP_Billback_Edit_Search_Payee_IDs

			CREATE  TABLE ##TMP_Billback_Edit_Search_Payee_IDs
			(
				Contract_Main_ID INT NOT NULL
			)

			<!--- Determine whether or not to use Operator Legacy ID --->
			SELECT @Use_Operator_Legacy_ID = ISNULL(Operator_Legacy_ID_On, 0) FROM CUSTOMER_SETTINGS

			IF @Payee_Type_ID = 1
			BEGIN

				INSERT	INTO ##TMP_Billback_Edit_Search_Payee_IDs
				SELECT	DISTINCT Contract_Main.Contract_Main_ID
				FROM	Contract_Main
						INNER JOIN Contract_Distributors ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID AND Contract_Distributors.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
						INNER JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID AND BSA_Foodservice_Customers.Shr_Ship_To = '#payeeId#'
						AND
						(
							(@Bus_Seg_Enabled = 0)
							OR
							(@Bus_Seg_Enabled = 1 AND ISNULL(BSA_Foodservice_Customers.Business_Segment_ID, 0) = Contract_Main.Business_Segment_ID)
						)
				WHERE	Contract_Main.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
				AND		Contract_Main.Approved = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
				AND		Contract_Main.Manual_Cancel = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />

			END
			ELSE IF @Payee_Type_ID = 2
			BEGIN

				INSERT	INTO ##TMP_Billback_Edit_Search_Payee_IDs
				SELECT	DISTINCT Contract_Main.Contract_Main_ID
				FROM	Contract_Main
						INNER JOIN Contract_Operators ON Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID AND Contract_Operators.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
						INNER JOIN BSA_Operator ON BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID AND
						CASE WHEN @Use_Operator_Legacy_ID = 0 THEN CAST(BSA_Operator.BSA_Operator_ID AS NVARCHAR(50)) ELSE CAST(BSA_Operator.Legacy_ID AS NVARCHAR(50)) END  = '#payeeId#'
						<!---
						AND
						(
							(@Bus_Seg_Enabled = 0)
							OR
							(@Bus_Seg_Enabled = 1 AND ISNULL(BSA_Operator.Business_Segment_ID, 0) = Contract_Main.Business_Segment_ID)
						)
						--->
				WHERE	Contract_Main.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
				AND		Contract_Main.Approved = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
			END
			ELSE IF @Payee_Type_ID = 3
			BEGIN

				INSERT	INTO ##TMP_Billback_Edit_Search_Payee_IDs
				SELECT	DISTINCT Contract_Main.Contract_Main_ID
				FROM	Contract_Main
						INNER JOIN Contract_Brokers ON Contract_Brokers.Contract_Main_ID = Contract_Main.Contract_Main_ID AND Contract_Brokers.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
						INNER JOIN BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = '#payeeId#'
						AND
						(
							(@Bus_Seg_Enabled = 0)
							OR
							(@Bus_Seg_Enabled = 1 AND ISNULL(BSA_Foodservice_Brokers.Business_Segment_ID, 0) = Contract_Main.Business_Segment_ID)
						)
				WHERE	Contract_Main.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
				AND		Contract_Main.Approved = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
			END

			<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				Tim Ford - Label 38420 Flex BB with program versions: Dump data into a temp table to be used at the end of this function
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
			IF OBJECT_ID('tempdb..##TMP_Contract_Data') IS NOT NULL
			DROP TABLE ##TMP_Contract_Data

			SELECT	DISTINCT
					Contract_Main.Contract_Main_ID AS programId,
					Contract_Main.Contract_Number AS number,
					Contract_Main.Contract_Title AS title,
					dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As startDate,
					dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) As endDate,
					dbo.get_TimeZoneOffset_Date((select MIN(Effective_Start_Date) from Contract_Main cm1 where cm1.Contract_Number = Contract_Main.Contract_Number and cm1.Approved = 1 and cm1.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as effectiveStartDate,
					dbo.get_TimeZoneOffset_Date((select MAX(Effective_End_Date) from Contract_Main cm2 where cm2.Contract_Number = Contract_Main.Contract_Number and cm2.Approved = 1 and cm2.Effective_Start_Date IS NOT NULL),@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1) as effectiveEndDate,
					CASE WHEN Contract_Main.Deleted = 1 THEN 0 ELSE 1 END AS bIsLatestVersion
			INTO	##TMP_Contract_Data
			FROM	Contract_Main
					INNER JOIN ##TMP_Billback_Edit_Search_Payee_IDs ON ##TMP_Billback_Edit_Search_Payee_IDs.Contract_Main_ID = Contract_Main.Contract_Main_ID
					INNER JOIN Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					LEFT JOIN _Users RSP_Users ON RSP_Users.User_ID = Contract_Main.Responsible_User_ID AND RSP_Users.Deleted = 0
			WHERE 	Contract_Main.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
			AND		Contract_Main.Approved = <cfqueryparam cfsqltype="cf_sql_bit" value="1" />
			AND		(
						(Contract_Main.Contract_Status_Type_IDX >= <cfqueryparam cfsqltype="cf_sql_integer" value="4"> AND Contract_Main.Contract_Status_Type_IDX < <cfqueryparam cfsqltype="cf_sql_integer" value="7">)
						OR
						(Contract_Main.Contract_Status_Type_IDX = <cfqueryparam cfsqltype="cf_sql_integer" value="7"> AND DATEDIFF(d, dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1), getDate()) <= @Expired_Number_Of_Days_Span)
					)
			<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				Tim Ford - Label 38420 Flex BB with program versions: Modified the code to validate Billback delivery start and end dates against the programs effective start and end dates.
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---
			AND		DATEDIFF(d, dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_Start_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1),  <cfqueryparam cfsqltype="cf_sql_date" value="#dtEndDate#" />) >= 0
			AND		DATEDIFF(d, dbo.get_TimeZoneOffset_Date(Contract_Main.Contract_End_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 0, 1), <cfqueryparam cfsqltype="cf_sql_date" value="#dtStartDate#" />) <= 0
			--->

			AND		(
						Contract_Main.Contract_Main_ID IN (SELECT DISTINCT Program_ID FROM Program_Rebates_Component PRC INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PRC.Claim_Mechanics AND PT.Restrict_From_Billback = 0  WHERE PRC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" /> AND Component_Paid_To = '#nPayeeTypeId#')
						OR
						Contract_Main.Contract_Main_ID IN (SELECT DISTINCT Program_ID FROM Program_Fixed_Component PFC INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PFC.Claim_Mechanics AND PT.Restrict_From_Billback = 0 WHERE PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" /> AND Fixed_Component_Paid_to = '#nPayeeTypeId#')
						OR
						Contract_Main.Contract_Main_ID IN (SELECT DISTINCT Program_ID FROM Program_Lump_Sums PLS INNER JOIN Payment_Type PT ON PT.Payment_Type_ID = PLS.Claim_Mechanics AND PT.Restrict_From_Billback = 0 WHERE PLS.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />   AND Component_Paid_to = '#nPayeeTypeId#')
					)

			<!--- filter on program number if one was passed --->
			<cfif len(trim(strProgNumber))>
			AND 	Contract_Main.Contract_Number LIKE '%#strProgNumber#%'
			</cfif>

			<!--- filter on distributor number if one was passed --->
			<cfif len(trim(strDistNumber))>
			AND EXISTS
			(
				SELECT	TOP 1 Contract_Distributors.Contract_Main_ID
				FROM 	Contract_Distributors
		      			INNER JOIN BSA_Foodservice_Customers ON
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID AND
						BSA_Foodservice_Customers.Deleted = 0 AND
						BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#strDistNumber#%'
				WHERE 	Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND 	Contract_Distributors.Deleted = 0
			)
			</cfif>

			<!--- filter on operator number if one was passed --->
			<cfif len(trim(strOperNumber))>
			AND EXISTS
			(
				SELECT	TOP 1 Contract_Operators.Contract_Main_ID
				FROM 	Contract_Operators
		      			INNER JOIN BSA_Operator ON
						Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID AND
						BSA_Operator.Deleted = 0 AND
						CASE WHEN @Use_Operator_Legacy_ID = 0 THEN BSA_Operator.BSA_Operator_ID ELSE BSA_Operator.Legacy_ID END LIKE '%#strOperNumber#%'
				WHERE 	Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND 	Contract_Operators.Deleted = 0
			)
			</cfif>

			<cfif not HQUser AND Get_Profile_Settings.BB_Add_Payee_Any_Position NEQ 1>
				AND
				(
					(Creating_User_Position_ID IN(#PreserveSingleQuotes(UserPositionList)#))
					OR
					(Creating_User_Position_ID IN (#preserveSingleQuotes(GP_Position_List_From_My_Position_Down)#))
				<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
					OR (Contract_Main.Contract_Main_ID IN(#PreserveSingleQuotes(ProgramsWithDistUnderMe)#))
					OR (Contract_Main.Contract_Main_ID IN(#PreserveSingleQuotes(ProgramsWithBrokerUnderMe)#))
				</cfif>
				)
			</cfif>
			AND	(
					(@Forbid_Type = 1 AND Contract_Main.ProgramType_ID NOT IN (SELECT Template_ID FROM @Profile_Forbidden_Template WHERE Forbid_Access_Type = 1))
					OR
					(@Forbid_Type != 1 AND Contract_Main.ProgramType_ID IN (SELECT Template_ID FROM @Profile_Forbidden_Template WHERE Forbid_Access_Type = 1))
				)
			AND	(
					(@Restrict_Created_By_RSP = 0)
					OR
					(@Restrict_Created_By_RSP = 1 AND
						(
							RSP_Users.User_ID = '#strUserID#'
							OR
							(@User_Number_Restrict = 1 AND RSP_Users.User_Number = @User_Number)
						)
					)
				)
			AND Program_Control_Panel_Options.Generic_Type NOT LIKE 'Distributor Off-Invoice'
			IF OBJECT_ID('tempdb..##TMP_Billback_Edit_Search_Payee_IDs') IS NOT NULL
			DROP TABLE ##TMP_Billback_Edit_Search_Payee_IDs

			<!---/////////////////////////////////////////////////////////////////////////////////////////////////////
				Tim Ford - Label 38420 Flex BB with program versions: Now return programs bassed on effective dates.
			//////////////////////////////////////////////////////////////////////////////////////////////////////--->
			SELECT	programId,
					number,
					title,
					startDate,
					endDate,
					effectiveStartDate,
					effectiveEndDate,
					bIsLatestVersion
			FROM	##TMP_Contract_Data
			WHERE	DATEDIFF(d, ##TMP_Contract_Data.effectiveStartDate,  '#dtEndDate#' ) >= 0
			AND		DATEDIFF(d, ##TMP_Contract_Data.effectiveEndDate,  '#dtStartDate#' ) <= 0


			IF OBJECT_ID('tempdb..##TMP_Contract_Data') IS NOT NULL
			DROP TABLE ##TMP_Contract_Data

		</cfquery>

        <cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get vendor data--->
	<cffunction name="searchVendorData" output="false" access="public" returntype="query">

		<cfargument name="vendorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strVendorId		= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			strVendorId	= arguments.vendorId;
		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	Vendor_Name AS name,
					CAST(Vendor_ID as VARCHAR(20)) AS payeeId,
					Address_1 AS addressLine1,
					Address_2 AS addressLine2,
					City AS city,
					State AS state,
					Zipcode AS zipCode
			FROM	Vendor_Master
			WHERE	Vendor_ID = '#strVendorId#'
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- search payee list--->
	<cffunction name="searchPayeeList" output="false" access="public" returntype="query">

		<cfargument name="vendorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strVendorId		= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			strVendorId	= arguments.vendorId;
		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			DECLARE
			@Use_Operator_Legacy_ID	BIT

			SELECT @Use_Operator_Legacy_ID = ISNULL(Operator_Legacy_ID_On, 0) FROM CUSTOMER_SETTINGS

			SELECT	CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN BSA_Foodservice_Customers.Name
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN BSA_Operator.Operator_Name
					END AS name,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN CAST(BSA_Foodservice_Customers.Shr_Ship_To AS VARCHAR(20))
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN
							CASE WHEN @Use_Operator_Legacy_ID = 0 THEN  CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(20))
							ELSE CAST(BSA_Operator.Legacy_ID AS VARCHAR(20))
							END
					END AS payeeId,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN 1
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN 2
					END AS payeeTypeId,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN BSA_Foodservice_Customers.Address_1
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN BSA_Operator.Operator_Address
					END AS addressLine1,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN BSA_Foodservice_Customers.Address_2
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN BSA_Operator.Operator_Address2
					END AS addressLine2,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN BSA_Foodservice_Customers.City
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN BSA_Operator.Operator_City
					END AS City,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN BSA_Foodservice_Customers.State
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN BSA_Operator.Operator_State
					END AS state,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN BSA_Foodservice_Customers.ZipCode
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN BSA_Operator.Operator_Zip
					END AS zipCode,
					CASE
						WHEN BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL THEN CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS NVARCHAR(50))
						WHEN BSA_Operator.BSA_Operator_ID IS NOT NULL THEN CAST(BSA_Operator.BSA_Operator_ID AS NVARCHAR(50))
					END AS payeeUUId
			FROM 	Vendor_Dist_Oper
					INNER JOIN Vendor_Master ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID AND Vendor_Master.Active_Code = 'A' AND Vendor_Master.Deleted = 0
					LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Dist_Oper.Distributor_ID AND BSA_Foodservice_Customers.Deleted = 0
					LEFT JOIN BSA_Operator ON BSA_Operator.BSA_Operator_ID = Vendor_Dist_Oper.Operator_ID
			WHERE 	Vendor_Dist_Oper.Deleted = 0
			AND		Vendor_Master.Vendor_ID = '#strVendorId#'
			AND		(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IS NOT NULL OR BSA_Operator.BSA_Operator_ID IS NOT NULL)
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get distributor data--->
	<cffunction name="searchDistributorData" output="false" access="public" returntype="query">

		<cfargument name="distributorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strDistributorId		= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			strDistributorId	= arguments.distributorId;
		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	DISTINCT
					Shr_Ship_To AS shipTo,
					Name AS name,
					BSA_Foodservice_Customers_ID AS customerId,
					Address_1 AS addressLine1,
					Address_2 AS addressLine2,
					City AS city,
					State AS state,
					ZipCode AS zipCode
			FROM	BSA_Foodservice_Customers
			WHERE	Deleted = 0
			AND		(
						cast(BSA_Foodservice_Customers_ID as varchar(36)) = <cfqueryparam value="#strDistributorId#" cfsqltype="cf_sql_varchar" >
						OR
						Shr_Ship_To = <cfqueryparam value="#strDistributorId#" cfsqltype="cf_sql_varchar">
					)
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get operator data--->
	<cffunction name="searchOperatorData" output="false" access="public" returntype="query">

		<cfargument name="operatorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strOperatorId	= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			strOperatorId	= arguments.operatorId;
		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			DECLARE
			@Use_Operator_Legacy_ID	BIT

			-- Determine whether or not to use Operator Legacy ID
			SELECT @Use_Operator_Legacy_ID = ISNULL(Operator_Legacy_ID_On, 0) FROM CUSTOMER_SETTINGS

			SELECT	CASE WHEN @Use_Operator_Legacy_ID = 0 THEN BSA_Operator_ID ELSE Legacy_ID END AS ID,
					BSA_Operator_ID,
					Legacy_ID,
					Operator_Name AS name,
					Operator_Address AS addressLine1,
					Operator_Address2 AS addressLine2,
					Operator_City AS city,
					Operator_State AS state,
					Operator_Zip AS zipCode
			FROM	BSA_Operator
			WHERE	Deleted = 0
			AND	 	CASE WHEN @Use_Operator_Legacy_ID = 0 THEN CAST(BSA_Operator_ID AS NVARCHAR(50)) ELSE Legacy_ID END = '#strOperatorId#'
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get product data--->
	<cffunction name="searchProductData" output="false" access="public" returntype="query">

		<cfargument name="lItemGuids" required="false" default="" />

		<cfscript>
			//set local variables
			var lItemMasterIds	= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			lItemMasterIds = arguments.lItemGuids;

		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	DISTINCT
					BSA_Foodservice_Items_Master_ID  AS itemGuid,
					Rtrim(Ltrim(Item)) AS itemNumber,
					Rtrim(Ltrim(Description)) AS itemDescription,
					Rtrim(Ltrim(Net_Weight)) AS netWeight
			FROM	BSA_Foodservice_Items_Master
			WHERE	Deleted = 0
			AND		Item IS NOT NULL
			AND		Active_Code = 'A'
			<cfif len(trim(lItemMasterIds))>
			AND		BSA_Foodservice_Items_Master_ID IN (<cfqueryparam value="#lItemMasterIds#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfif>
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get product list--->
	<cffunction name="searchProductList" output="false" access="public" returntype="query">

		<cfscript>
			//set local variables
			var qSearch			= "";
			var qReturn			= "";

		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	DISTINCT
					BSA_Foodservice_Items_Master_ID  AS itemGuid,
					Rtrim(Ltrim(Item)) AS itemNumber,
					Rtrim(Ltrim(Description)) AS itemDescription,
					Rtrim(Ltrim(Net_Weight)) AS netWeight
			FROM	BSA_Foodservice_Items_Master
			WHERE	Deleted = 0
			AND		Item IS NOT NULL
			AND		Active_Code = 'A'
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get distributor list--->
	<cffunction name="searchDistributorList" output="false" access="public" returntype="query">

		<cfscript>
			//set local variables
			var qSearch			= "";
			var qReturn			= "";

		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	DISTINCT
					Shr_Ship_To AS shipTo,
					Name AS name,
					BSA_Foodservice_Customers_ID AS customerId,
					Address_1 AS addressLine1,
					Address_2 AS addressLine2,
					City AS city,
					State AS state,
					ZipCode AS zipCode
			FROM	BSA_Foodservice_Customers
			WHERE	Deleted = 0
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get bill to data--->
	<cffunction name="searchBillToData" output="false" access="public" returntype="query">

		<cfargument name="distributorId" required="true" type="string" />

		<cfscript>
			//set local variables
			var strDistributorId		= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			strDistributorId	= arguments.distributorId;
		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	DISTINCT Distributor_Bill_To.Bill_To AS billTo,
					Distributor_Bill_To.Name AS name,
					Distributor_Bill_To.Distributor_Bill_To_ID AS billToId,
					Distributor_Bill_To.Address1 AS addressLine1,
					Distributor_Bill_To.Address2 AS addressLine2,
					Distributor_Bill_To.City AS city,
					Distributor_Bill_To.State AS state,
					Distributor_Bill_To.Zip AS zipCode,
					BSA_Foodservice_Customers.Ship_To AS shipTo,
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS shipToId
			FROM	BillTo_ShipTo_Relations
					INNER JOIN Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = BillTo_ShipTo_Relations.Distributor_Bill_To_ID AND Distributor_Bill_To.Deleted = 0
					INNER JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BillTo_ShipTo_Relations.BSA_Foodservice_Customers_ID AND BSA_Foodservice_Customers.Deleted = 0
			WHERE	BillTo_ShipTo_Relations.Deleted = 0
			AND		(
						CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID as varchar(36)) = <cfqueryparam value="#strDistributorId#" cfsqltype="cf_sql_varchar" >
						OR
						BSA_Foodservice_Customers.Shr_Ship_To = <cfqueryparam value="#strDistributorId#" cfsqltype="cf_sql_varchar">
					)
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

	<!--- get program product data--->
	<cffunction name="searchProgramProductData" output="false" access="public" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID		= "";
			var qSearch			= "";
			var qReturn			= "";

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;

		</cfscript>

		<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	DISTINCT
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID  AS itemGuid,
					Rtrim(Ltrim(BSA_Foodservice_Items_Master.Item)) AS itemNumber,
					Rtrim(Ltrim(BSA_Foodservice_Items_Master.Description)) AS itemDescription,
					Rtrim(Ltrim(BSA_Foodservice_Items_Master.Net_Weight)) AS netWeight,
					Contract_Main.Contract_Number AS number
			FROM	Billback
					INNER JOIN Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND Billback_Program.Deleted = 0
					INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN Contract_Products ON Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID AND Contract_Products.Deleted = 0
					INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			WHERE	Billback.Billback_ID_Int = <cfqueryparam value="#nBillbackID#" cfsqltype="CF_SQL_INTEGER" />
			AND		Billback.Deleted = 0
		</cfquery>

		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>

	</cffunction>

</cfcomponent>