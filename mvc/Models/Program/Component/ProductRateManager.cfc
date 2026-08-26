<cfcomponent name="ProductRateManager" displayname="ProductRateManager" extends="mvc.Models.SettingsService">

	<cffunction name="getTemplateMultiPrdAttrGroups" returntype="boolean">

		<cfreturn application.appSettingsGet.getTemplateMultipleProductAttrGroups()>
	</cffunction>
	<cffunction name="getProductRate"output="false" returntype="query" hint="function to return all product rates for a given program product type">

		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="type" type="Numeric" required="true" hint="1 for Fixed Price. 2 for Rebate" />
		<cfargument name="includeGroupMembers" type="Numeric" required="false" default="0" />
		<cfargument name="payeeType" type="string" required="false" default="" />
		<cfargument name="fromBillback" type="numeric" required="false" default="0" />

		<cfscript>
			//set local variables
			var nProgramID				= "";
			var nType					= "";
			var qGetRateData			= "";
			var qRetData				= "";
			var strPayeeType			= "";
			var nRetToBillback			= 0;

			//assign local variables
			nProgramID		= arguments.programId;
			nType			= arguments.type;
			strPayeeType	= arguments.payeeType;
			nRetToBillback	= arguments.fromBillback;

			//if product rate type is 1 (Fixed Price) then assign qGetRateData to the results from getFixedProductRateData()
			if (nType eq 1)
			{
				qGetRateData	= getFixedProductRateData(nProgramID);
				//this.dmp(qGetRateData);

			}
			//if product rate type is 2 (Rebate) then assign qGetRateData to the results from getRebateProductRateData()
			else if (nType eq 2)
			{
				qGetRateData	= getRebateProductRateData(nProgramID, arguments.includeGroupMembers, strPayeeType);
			}
			//if product rate type is 3 (Lump Sum) then assign qGetRateData to the results from getLumpSumProductRateData()
			else if(nType eq 3)
			{
				qGetRateData	= getLumpSumProductRateData(nProgramID, strPayeeType, nRetToBillback);
			}

			qRetData = qGetRateData;

			return qRetData;

		</cfscript>

	</cffunction>

	<cffunction name="getFixedProductRateData"output="false" returntype="query" hint="function to return fixed price rate product data">

		<cfargument name="programId" type="Numeric" required="true" />

		<cfscript>
			//set local variables
			var nProgramID	= "";
			var qGetData	= "";
			var qRetData	= "";
			var sLeftJoin	= "";
			var	sCustRate	= "";
			var	sCustRateCol	= "";
			var objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
			var iMPId = objMarketPriceManager.getProgramActiveMPList(arguments.ProgramId);
			//assign local variables
			nProgramID 			= arguments.programId;
		</cfscript>
		<cfquery name="qGetFixedCompProfileRestriction" datasource="#application.datasource#">
			SELECT	Program_Fixed_Component_Name_ID
			FROM Program_Fixed_Component_Profile PFCP
			WHERE
				PFCP.Profiles_ID = #request.accessStructure.PROFILES_ID# AND
				DELETED = 0
		</cfquery>

		<cfset VARIABLES.qGetCustomersForFreight = queryNew('x') />
		<cfif this.getTemplateMultiPrdAttrGroups() EQ 1 >
			<cfset objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager") />
			<cfset bFixedFreight = objProgramTemplateManager.getSettings(arguments.programId).Discount_Fixed_Prices_Freight />
			<cfif bFixedFreight >
				<cfset VARIABLES.qGetCustomersForFreight = objProgramTemplateManager.getDistributors(arguments.programId, 0, 0,1,1) /> <!--- variable scopE -> used in getProductRateDataStruct()...why call twice? --->
				<cfoutput query="qGetCustomersForFreight">
					<cfset custId = qGetCustomersForFreight.BSA_Foodservice_Customers_ID />
					<cfset sPFFR = " PFFR_" & qGetCustomersForFreight.Shr_Ship_To />
					<cfset sCustRateCol = "rateCust_" & qGetCustomersForFreight.Shr_Ship_To />
					<cfset sLeftJoin = sLeftJoin & " LEFT JOIN Program_Fixed_Freight_Rates " & sPFFR & " ON " & sPFFR & ".Product_Id = BSAFIM.BSA_Foodservice_Items_Master_ID AND " & sPFFR & ".Customer_Id = '" & custId & "' AND " & sPFFR & ".Program_Id = " &  nProgramID & "  "  & " AND " & sPFFR & ".Component_Name_Id = FCN.Program_Fixed_Component_Name_ID"/>
					<cfset sCustRate = sCustRate & " , ISNULL(" & sPFFR & ".Delivered_Price,0) AS " & sCustRateCol />
				</cfoutput>
			</cfif>
		</cfif>

		<cfquery name="qGetData" datasource="#application.datasource#">

			DECLARE @Span INT

			SELECT	@Span = DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">

			SELECT DISTINCT	BSAFIM.BSA_Foodservice_Items_Master_ID AS itemGuid,
					BSAFIM.Item AS itemNumber,
					BSAFIM.Description AS itemDescription,
					BSAFIM.Net_Weight AS netWeight,
					UOM.Unit_Of_Measure_ID AS uomId,
					UOM.Unit_Of_Measure_Desc AS description,
					UOM.Abbreviation_Singular AS abbreviation,
					FPPD.Fixed_Price_Value AS rate,
					FCN.Program_Fixed_Component_Name_ID AS componentId,
					FCN.Program_Fixed_Component_Name AS name,
					FCN.Fixed_Component_Type AS fixedType,
					PFC.Fixed_Component_Paid_To AS paidTo,
					PFC.Program_Fixed_Component_ID AS programComponentId,
					PFC.Claim_Mechanics AS claimMechanicId,
					'' AS compDescription,
					ISNULL(NULLIF(BCM.Payee_Type,''),0) AS claimMechPayeeTypeId,
					ISNULL(NULLIF(PFC.Payee_Type,''),0) AS payeeTypeId,
					CASE
						WHEN ISNULL(NULLIF(PFC.Payee_Type,''),0) = 1 THEN BSA_Foodservice_Customers.Name
						WHEN ISNULL(NULLIF(PFC.Payee_Type,''),0) = 5 THEN Vendor_Master.Vendor_Name
						ELSE NULL
					END AS payeeName,
					--PFC.Vendor_Master_ID AS payeeId,
					CASE
						WHEN ISNULL(NULLIF(PFC.Payee_Type,''),0) = 1 THEN BSA_Foodservice_Customers.Ship_To
						WHEN ISNULL(NULLIF(PFC.Payee_Type,''),0) = 5 THEN Vendor_Master.Vendor_Id
						ELSE NULL
					END AS payeeId,
					Payment_Type.Payment_Type_Name AS claimMechanicDesc,
					Payment_Type.Restrict_From_Billback AS restrictBB,
					Payment_Type.Is_Auto_Pay AS bAutoPay,
					GL_Account.GL_Account_ID AS glAccountId,
					GL_Account.GL_Account AS glDescription,
					CASE WHEN Contract_Quantity_UOM_IDX = 1 THEN
						(ISNULL(Program_Product_Volume.Volume_CS, 0) / 7) * @Span
					ELSE
						(ISNULL(Program_Product_Volume.Volume_LB, 0) / 7) * @Span
					END AS volume,
					CM.Contract_Number AS programNumber,
					CM.Contract_Title AS programTitle,
					IsNull(CM.Currency_Conversion_Factor,1) AS Currency_Conversion_Factor,
					<cfif iMPId>
						IsNull(FPPD.Market_Price_Rate,0) AS Market_Price_Rate,
						FPPD.Market_Price_Rate_Orig AS Market_Price_Rate_Orig,
						CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))  AS DECIMAL(12,2)) AS New_Market_Price_Rate,
						CP.Contract_Products_ID AS contractProductsID,
						ISNULL(MPPA.Variance,0) AS MPApprovalVariance,
						CASE
							WHEN MPR.Uom_Id = 2 THEN CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0)) * BSAFIM.Net_Weight AS DECIMAL(18,4))
							ELSE ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))
						END AS New_Market_Price_Rate_CS,
						CASE
							WHEN MPR.Uom_Id = 1 THEN CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0)) / BSAFIM.Net_Weight AS DECIMAL(18,4))
							ELSE ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))
						END AS New_Market_Price_Rate_LB,
						CASE
							WHEN FPPD.Unit_Of_Measure_Id = 2 THEN CAST(IsNull(FPPD.Market_Price_Rate,0) * BSAFIM.Net_Weight AS DECIMAL(18,4))
							ELSE FPPD.Market_Price_Rate
						END AS Market_Price_Rate_CS,
						CASE
							WHEN FPPD.Unit_Of_Measure_Id = 1 THEN CAST(IsNull(FPPD.Market_Price_Rate,0) / BSAFIM.Net_Weight AS DECIMAL(18,4))
							ELSE FPPD.Market_Price_Rate
						END AS Market_Price_Rate_LB,
						MPR.Uom_Id AS Market_Price_UOM,
					<cfelse>
						'' AS Market_Price_Rate,
						'' AS New_Market_Price_Rate,
						 0 AS Market_Price_Rate_Orig,
						'' AS contractProductsID,
						'' AS MPApprovalVariance,
						0 AS Market_Price_Rate_CS,
						0 AS Market_Price_Rate_LB,
						0 AS New_Market_Price_Rate_CS,
						0 AS New_Market_Price_Rate_LB,
						'' AS Market_Price_UOM,
					</cfif>
					CASE BSAFIM.Active_Code
						When 'A' then 1
					ELSE 0
					END AS bActive
					<cfif this.getTemplateMultiPrdAttrGroups() EQ 1>
						#sCustRate#
					</cfif>
			FROM	Program_Fixed_Price_Product_Data FPPD
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_ID = FPPD.Program_Fixed_Component_ID
			INNER JOIN Program_Fixed_Component_Name FCN ON
					FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			<!--- PROFILE RESTRICTION --->
			<cfif qGetFixedCompProfileRestriction.recordcount>
				AND FCN.Program_Fixed_Component_Name_ID NOT IN (#ValueList(qGetFixedCompProfileRestriction.Program_Fixed_Component_Name_ID)#)
			</cfif>
			INNER JOIN Units_Of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = FPPD.Unit_Of_Measure_ID
			INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = FPPD.Contract_Products_ID AND
					CP.Contract_Main_ID = FPPD.Program_ID
			INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON
					BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			INNER JOIN Contract_Main CM ON
					CM.Contract_Main_ID = CP.Contract_Main_ID
			<cfif iMPId>
				LEFT JOIN Market_Price_List MP ON
					MP.Market_Price_List_Id = #iMPId#
				LEFT JOIN Market_Price_Product_Rates MPR ON
					MP.Market_Price_List_Id = MPR.Market_Price_List_Id AND
					MPR.BSA_Foodservice_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_ID
				LEFT JOIN Market_Price_Program_Approvals MPPA ON
					MPPA.Contract_Main_Id = CP.Contract_Main_ID AND
					MPPA.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_FoodService_Items_Master_ID AND
					MPPA.Component_Name_Id = PFC.Program_Fixed_Component_Name_ID
			</cfif>
			LEFT JOIN GL_Account ON
					GL_Account.GL_Account_ID = PFC.GL_Account_ID
			LEFT JOIN Payment_Type ON
					Payment_Type.Payment_Type_ID = PFC.Claim_Mechanics
			LEFT JOIN Billback_Closing_Methods BCM ON
						BCM.iBillback_Closing_Method_ID = Payment_Type.Billback_Closing_Method_ID
			LEFT JOIN Vendor_Master ON
					Vendor_Master.Vendor_Master_ID = PFC.Vendor_Master_ID
			LEFT JOIN BSA_Foodservice_Customers ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = PFC.Vendor_Master_ID
			LEFT JOIN Program_Product_Volume ON
					Program_Product_Volume.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID AND
					Program_Product_Volume.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
					AND 	Program_Product_Volume.Deleted = 0
			<cfif this.getTemplateMultiPrdAttrGroups() EQ 1>
				#PreserveSingleQuotes(sLeftJoin)#
			</cfif>
			WHERE	FPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			AND		FPPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
			AND		CP.Captured_From_Group = 0
		<!---	<cfif iMPId>
				AND FPPD.Market_Price_Rate != 0
			</cfif>--->

			ORDER BY FCN.Program_Fixed_Component_Name_ID
		</cfquery>

		<cfset qRetData = qGetData />

		<cfreturn qRetData />

	</cffunction>

	<cffunction name="getRebateProductRateData"output="false" returntype="query" hint="function to return rebate rate product data">

		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="includeGroupMembers" type="Numeric" required="false" default="0" />
		<cfargument name="payeeType" type="string" required="false" default="" />
		<cfargument name="includeGroups" type="Numeric" required="false" default="0" />
		<cfargument name="componentNameID" type="Numeric" required="false" default="0" />

		<cfscript>
			//set local variables
			var nProgramID		= "";
			var qGetData		= "";
			var qRetData		= "";
			var strPayeeType	= "";
			var nComponentNameID = "";

			//assign local variables
			nProgramID 			= arguments.programId;
			strPayeeType		= arguments.payeeType;
			nComponentNameID    = arguments.componentNameID;
		</cfscript>

		<!--- PROFILE RESTRICTION --->
		<cfquery name="qGetRebateCompProfileRestriction" datasource="#application.datasource#">
			SELECT	Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component_Profile PRCP
			WHERE
				PRCP.Profiles_ID = #request.accessStructure.PROFILES_ID# AND
				DELETED = 0
		</cfquery>

		<cfquery name="qGetData" datasource="#application.datasource#">

			DECLARE @Span INT

			SELECT	@Span = DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">

			SELECT	BSAFIM.BSA_Foodservice_Items_Master_ID  AS itemGuid,
					BSAFIM.Item AS itemNumber,
					BSAFIM.Description AS itemDescription,
					BSAFIM.Net_Weight AS netWeight,
					UOM.Unit_Of_Measure_ID AS uomId,
					UOM.Unit_Of_Measure_Desc AS description,
					UOM.Abbreviation_Singular AS abbreviation,
					Program_Rebates_Component_Data.Rate AS rate,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID AS componentId,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name AS name,
					Program_Rebates_Component.Component_Paid_To AS paidTo,
					Program_Rebates_Component.Program_Rebates_Component_ID AS programComponentId,
					Program_Rebates_Component.Claim_Mechanics  AS claimMechanicId,
					'' AS compDescription,
					ISNULL(NULLIF(BCM.Payee_Type,''),0) AS claimMechPayeeTypeId,
					ISNULL(NULLIF(Program_Rebates_Component.Payee_Type,''),0) AS payeeTypeId,
					CASE
						WHEN ISNULL(NULLIF(Program_Rebates_Component.Payee_Type,''),0) = 1 THEN BSA_Foodservice_Customers.Name
						WHEN ISNULL(NULLIF(Program_Rebates_Component.Payee_Type,''),0) = 5 THEN Vendor_Master.Vendor_Name
						ELSE NULL
					END AS payeeName,
					--Program_Rebates_Component.Vendor_Master_ID AS payeeId,
					CASE
						WHEN ISNULL(NULLIF(Program_Rebates_Component.Payee_Type,''),0) = 1 THEN BSA_Foodservice_Customers.Ship_To
						WHEN ISNULL(NULLIF(Program_Rebates_Component.Payee_Type,''),0) = 5 THEN Vendor_Master.Vendor_Id
						ELSE NULL
					END AS payeeId,
					Payment_Type.Payment_Type_Name AS claimMechanicDesc,
					Payment_Type.Restrict_From_Billback AS restrictBB,
					Payment_Type.Is_Auto_Pay AS bAutoPay,
					GL_Account.GL_Account_ID AS glAccountId,
					GL_Account.GL_Account AS glDescription,
					CASE WHEN Contract_Quantity_UOM_IDX = 1 THEN
						(ISNULL(Program_Product_Volume.Volume_CS, 0) / 7) * @Span
					ELSE
						(ISNULL(Program_Product_Volume.Volume_LB, 0) / 7) * @Span
					END AS volume,

					'' AS Market_Price_Rate,
					'' AS New_Market_Price_Rate,
					0 AS Market_Price_Rate_Orig,
					'' AS MPApprovalVariance,
					0 AS Market_Price_Rate_CS,
					0 AS Market_Price_Rate_LB,
					0 AS New_Market_Price_Rate_CS,
					0 AS New_Market_Price_Rate_LB,
					'' AS Market_Price_UOM,
					CP.Contract_Products_ID AS contractProductsID,
					CM.Contract_Number AS programNumber,
					CM.Contract_Title AS programTitle,
					IsNull(CM.Currency_Conversion_Factor,1) AS Currency_Conversion_Factor,
					CASE BSAFIM.Active_Code
						When 'A' then 1
					ELSE 0
					END AS bActive
			FROM	Program_Rebates_Component_Data
					INNER JOIN Program_Rebates_Product_Data ON
					Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
					INNER JOIN Program_Rebates_Component ON
					Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
					INNER JOIN Program_Rebates_Component_Name ON
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
					<!--- PROFILE RESTRICTION --->
					<cfif qGetRebateCompProfileRestriction.recordcount>
						AND Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID NOT IN (#ValueList(qGetRebateCompProfileRestriction.Program_Rebates_Component_Name_ID)#)
					</cfif>
					INNER JOIN Units_Of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = Program_Rebates_Component_Data.Unit_Of_Measure_ID
					INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID AND
					CP.Contract_Main_ID = Program_Rebates_Product_Data.Program_ID
					INNER JOIN Contract_Main CM ON
					CM.Contract_Main_ID = CP.Contract_Main_ID
					INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON
					BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
					LEFT JOIN GL_Account
					ON GL_Account.GL_Account_ID = Program_Rebates_Component.GL_Account_ID
					LEFT JOIN Payment_Type ON
					Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
					LEFT JOIN Billback_Closing_Methods BCM ON
						BCM.iBillback_Closing_Method_ID = Payment_Type.Billback_Closing_Method_ID
					LEFT JOIN Vendor_Master ON
					Vendor_Master.Vendor_Master_ID = Program_Rebates_Component.Vendor_Master_ID
					LEFT JOIN BSA_Foodservice_Customers ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Program_Rebates_Component.Vendor_Master_ID
					LEFT JOIN Program_Product_Volume ON
					Program_Product_Volume.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID AND
					Program_Product_Volume.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
					AND 	Program_Product_Volume.Deleted = 0
			WHERE	Program_Rebates_Component_Data.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		Program_Rebates_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			AND		Program_Rebates_Product_Data.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		Program_Rebates_Component.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			<cfif nComponentNameID NEQ "0">
				AND  Program_Rebates_Component.Program_Rebates_Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nComponentNameID#">
			</cfif>
			AND		Program_Rebates_Component.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="2">
			<cfif this.getTemplateMultiPrdAttrGroups() EQ 0 AND arguments.includeGroups eq 0>
			 AND		CP.Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0">
			</cfif>
			<cfif arguments.includeGroupMembers eq 0>
			 AND		CP.Captured_From_Group = 0
			</cfif>
			<!--- if a payeeType was passed then filter on that --->
			<cfif len(trim(strPayeeType)) and trim(strPayeeType) neq 0>
			AND Program_Rebates_Component.Component_Paid_To = '#strPayeeType#'
			</cfif>
			<!---AND		CAST(Program_Rebates_Component_Data.Rate AS FLOAT) != 0--->

			ORDER BY Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
		</cfquery>

		<cfset qRetData = qGetData />

		<cfreturn qRetData />

	</cffunction>

	<cffunction name="getLumpSumProductRateData"output="false" returntype="query" hint="function to return lump sum rate product data">

		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="payeeType" type="string" required="false" default="" />
		<cfargument name="fromBillback" type="numeric" required="false" default="0" />

		<cfscript>
			//set local variables
			var nProgramID		= "";
			var qGetData		= "";
			var qRetData		= "";
			var strPayeeType	= "";
			var nRetToBillback	= 0;

			//assign local variables
			nProgramID 			= arguments.programId;
			strPayeeType		= arguments.payeeType;
			nRetToBillback		= arguments.fromBillback;
		</cfscript>

		<cfquery name="qGetData" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##TMP_Lump_Sum_Product_Rate_Data') IS NOT NULL
			DROP TABLE ##TMP_Lump_Sum_Product_Rate_Data

			DECLARE @Span INT

			SELECT	@Span = DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">

			SELECT	<cfif nRetToBillback eq 0>DISTINCT</cfif>
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AS itemGuid,
					BSA_Foodservice_Items_Master.Item AS itemNumber,
					BSA_Foodservice_Items_Master.Description AS itemDescription,
					BSA_Foodservice_Items_Master.Net_Weight AS netWeight,
					'' uomId,
					'' AS description,
					'' AS abbreviation,
					Program_Lump_Sums.Lump_Sum_Amount AS rate,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID AS componentId,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name AS name,
					Program_Lump_Sums.Component_Paid_To AS paidTo,
					Program_Lump_Sums.Program_Lump_Sum_ID AS programComponentId,
					Program_Lump_Sums.Claim_Mechanics AS claimMechanicId,
					Program_Lump_Sums.Lump_Sum_Description AS compDescription,
					ISNULL(NULLIF(Billback_Closing_Methods.Payee_Type,''),0) AS claimMechPayeeTypeId,
					0 AS payeeTypeId,
					'' AS payeeName,
					NULL AS payeeId,
					Payment_Type.Payment_Type_Name AS claimMechanicDesc,
					Payment_Type.Restrict_From_Billback AS restrictBB,
					Payment_Type.Is_Auto_Pay AS bAutoPay,
					GL_Account.GL_Account_ID AS glAccountId,
					GL_Account.GL_Account AS glDescription,
					CASE WHEN Contract_Quantity_UOM_IDX = 1 THEN
						(ISNULL(Program_Product_Volume.Volume_CS, 0) / 7) * @Span
					ELSE
						(ISNULL(Program_Product_Volume.Volume_LB, 0) / 7) * @Span
					END AS volume,
					'' AS Market_Price_Rate,
					'' AS New_Market_Price_Rate,
					0 AS Market_Price_Rate_Orig,
					'' AS contractProductsID,
					'' AS MPApprovalVariance,
					0 AS Market_Price_Rate_CS,
					0 AS Market_Price_Rate_LB,
					0 AS New_Market_Price_Rate_CS,
					0 AS New_Market_Price_Rate_LB,
					'' AS Market_Price_UOM,
					Contract_Main.Contract_Number AS programNumber,
					Contract_Main.Contract_Title AS programTitle,
					IsNull(Contract_Main.Currency_Conversion_Factor,1) AS Currency_Conversion_Factor,
					CASE BSA_Foodservice_Items_Master.Active_Code
						When 'A' then 1
					ELSE 0
					END AS bActive
			INTO	##TMP_Lump_Sum_Product_Rate_Data
			FROM	Program_Lump_Sums
					INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Program_Lump_Sums.Program_ID
					INNER JOIN Program_Lump_Sum_Name ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
					LEFT JOIN Program_Lump_Sum_Product_Data ON Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID AND Program_Lump_Sum_Product_Data.Deleted = 0
					LEFT JOIN Contract_Products ON Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID AND Contract_Products.Product_Type_ID = 3 AND Contract_Products.Deleted = 0 AND  Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
					LEFT JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					LEFT JOIN GL_Account ON GL_Account.GL_Account_ID = Program_Lump_Sums.GL_Account_ID
					LEFT JOIN Payment_Type ON Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
					LEFT JOIN Billback_Closing_Methods ON Billback_Closing_Methods.iBillback_Closing_Method_ID = Payment_Type.Billback_Closing_Method_ID
					LEFT JOIN Vendor_Master ON Vendor_Master.Vendor_Master_ID = Program_Lump_Sums.Vendor_Master_ID
					LEFT JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Program_Lump_Sums.Vendor_Master_ID
					LEFT JOIN Program_Product_Volume ON Program_Product_Volume.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND Program_Product_Volume.Deleted = 0 AND Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID
			WHERE	Program_Lump_Sums.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			AND		Program_Lump_Sums.Deleted = 0
			AND		Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			<!--- if a payeeType was passed then filter on that --->
			<cfif len(trim(strPayeeType)) and trim(strPayeeType) neq 0>
			AND 	Program_Lump_Sums.Component_Paid_To = '#strPayeeType#'
			</cfif>

			<!--- if a payeeType was passed then just return component data, not product data --->
			<cfif len(trim(strPayeeType))>
				SELECT	DISTINCT '' AS itemGuid,
						'' AS itemNumber,
						'' AS itemDescription,
						'' AS netWeight,
						'' uomId,
						'' AS description,
						'' AS abbreviation,
						rate,
						componentId,
						name,
						paidTo,
						programComponentId,
						claimMechanicId,
						compDescription,
						claimMechPayeeTypeId,
						payeeTypeId,
						payeeName,
						payeeId,
						claimMechanicDesc,
						restrictBB,
						bAutoPay,
						glAccountId,
						glDescription,
						volume,
						Market_Price_Rate,
						New_Market_Price_Rate,
                        Market_Price_Rate_Orig,
						contractProductsID,
						MPApprovalVariance,
						Market_Price_Rate_CS,
						Market_Price_Rate_LB,
						New_Market_Price_Rate_CS,
						New_Market_Price_Rate_LB,
						Market_Price_UOM,
						programNumber,
						programTitle,
						bActive
				FROM	##TMP_Lump_Sum_Product_Rate_Data
			<cfelse>
				SELECT * FROM ##TMP_Lump_Sum_Product_Rate_Data
			</cfif>

		</cfquery>

		<cfset qRetData = qGetData />

		<cfreturn qRetData />

	</cffunction>

	<cffunction name="getProductRateDataStruct" output="false" returntype="array">

		<cfargument name="productRateData" type="query" required="true">
		<cfargument name="componentId" type="Numeric" required="true">
		<cfargument name="bItemDesc" type="Boolean" required="false" default="0" />
		<cfargument name="bNewRateMP" type="Boolean" required="false" default="0" />
		<cfargument name="compUUIDId" type="string" required="false" default="" />
		<cfargument name="compType" type="string" required="false" default="0" />
		<cfargument name="programId" type="string" required="false" default="0" />

		<cfscript>
			//set local variables
			var qProductRateData	= "";
			var nCompID				= "";
			var arrRetData			= ArrayNew(1);
			var strCompId			= "";
			var nCompType			= 0;
			var nMarketPrice		= 0;
			var nNewMarketPrice		= 0;
			var custRate			= 0;

			//assign local variables
			qProductRateData	= arguments.productRateData;
			nCompID				= arguments.componentId;
			strCompId			= arguments.compUUIDId;
			nCompType			= arguments.compType;
			//this.dmp(qProductRateData);

			/*	VARIABLES.qGetCustomersForFreight set in caller getFixedProductRateData()
			if(this.getTemplateMultiPrdAttrGroups() EQ 1 AND nCompType EQ 1){
				objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
				qGetCustomersForFreight = objProgramTemplateManager.getDistributors(arguments.programId, 0, 0, 0);
			}*/

			//this.dmp(productRateData);
			//Loop over query object and build the prodRate object
			for (idxRow = 1; idxRow LTE qProductRateData.RecordCount; idxRow = (idxRow + 1))
			{
				if(qProductRateData["componentId"][idxRow] eq nCompID and (nCompType neq 3 or qProductRateData["programComponentId"][idxRow] eq strCompId))
				{
					stUom = structNew();
					stUomData = structNew();
					stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
					stUomData["uomId"] = trim(qProductRateData["uomId"][idxRow]);
					stUomData["description"] = trim(qProductRateData["description"][idxRow]);
					stUomData["abbreviation"] = trim(qProductRateData["abbreviation"][idxRow]);
					stUom = stUomData;

					stData = structNew();
					stData["__type__"] = "mvc.Models.Program.Component.vos.ProdRate";
					stData["itemGuid"] = trim(qProductRateData["itemGuid"][idxRow]);
					stData["itemNumber"] = trim(qProductRateData["itemNumber"][idxRow]);
					//for groups, item is empty '', so use guid
					if(qProductRateData["itemNumber"][idxRow] == ''){
						stData["itemNumber"] = trim(qProductRateData["itemGuid"][idxRow]);
					}
					stData["netWeight"] = trim(qProductRateData["netWeight"][idxRow]);
					stData["rate"] = trim(qProductRateData["rate"][idxRow]);
					if(this.getTemplateMultiPrdAttrGroups() EQ 1 AND nCompType == 1){
						//VARIABLES.qGetCustomersForFreight is set in getFixedProductRateData()
						for (idx = 1; idx LTE VARIABLES.qGetCustomersForFreight.RecordCount; idx = (idx + 1))
						{
							custRate = trim(qProductRateData["rateCust_" & VARIABLES.qGetCustomersForFreight.Shr_Ship_to[idx]][idxRow]);
							stData["rateCust_" & VARIABLES.qGetCustomersForFreight.Shr_Ship_to[idx]] = custRate;
							stData["rateCustConverted_" & VARIABLES.qGetCustomersForFreight.Shr_Ship_to[idx]] = (custRate * trim(qProductRateData["Currency_Conversion_Factor"][idxRow]));
						}
					}
					stData["description"] = trim(qProductRateData["itemDescription"][idxRow]);
					stData["bActive"] = trim(qProductRateData["bActive"][idxRow]);
					stData["compDescription"] = trim(qProductRateData["compDescription"][idxRow]);
					if(len(arguments.bItemDesc)){
						stData["description"] = trim(qProductRateData["itemDescription"][idxRow]);
						//for MPUP we compare the new rate and old rate
						if(bNewRateMP){
							// handle for different uoms
							if(stUom.uomId eq 2){
								nMarketPrice = trim(qProductRateData["Market_Price_Rate_LB"][idxRow]);
								nNewMarketPrice = trim(qProductRateData["New_Market_Price_Rate_LB"][idxRow]);
							}
							else if(stUom.uomId eq 1){
								nMarketPrice = trim(qProductRateData["Market_Price_Rate_CS"][idxRow]);
								nNewMarketPrice = trim(qProductRateData["New_Market_Price_Rate_CS"][idxRow]);
							}

							stData["rateMP"] = nMarketPrice;
							stData["rateMPOrig"] = trim(qProductRateData["Market_Price_Rate_Orig"][idxRow]);
							stData["newRateMP"] = nNewMarketPrice;
							stData["contractProductsID"] = trim(qProductRateData["contractProductsID"][idxRow]);
							stData["MPApprovalVariance"] = trim(qProductRateData["MPApprovalVariance"][idxRow]);
							stData["rateMPCS"] = trim(qProductRateData["Market_Price_Rate_CS"][idxRow]);
							stData["rateMPLB"] = trim(qProductRateData["Market_Price_Rate_LB"][idxRow]);
							stData["rateMPUom"] = trim(qProductRateData["Market_Price_UOM"][idxRow]);
						}
						//for prodrate tool get method always populate  rateMP with latest from MP list (not from value stored in Program_Fixed_Price_Product_Data)
						else{
							// handle for different uoms
							if (stUom.uomId neq trim(qProductRateData["Market_Price_UOM"][idxRow])){
								if(stUom.uomId eq 2){
									nNewMarketPrice = trim(qProductRateData["New_Market_Price_Rate_LB"][idxRow]);
								}
								else if(stUom.uomId eq 1){
									nNewMarketPrice = trim(qProductRateData["New_Market_Price_Rate_CS"][idxRow]);
								}
							}
							else{
								nNewMarketPrice = trim(qProductRateData["New_Market_Price_Rate"][idxRow]);
							}
							stData["rateMP"] = nNewMarketPrice;
							stData["rateMPOrig"] = trim(qProductRateData["Market_Price_Rate_Orig"][idxRow]);
							stData["MPApprovalVariance"] = trim(qProductRateData["MPApprovalVariance"][idxRow]);
							//stData["newRateMP"] = trim(qProductRateData["New_Market_Price_Rate"][idxRow]);
							stData["rateMPCS"] = trim(qProductRateData["New_Market_Price_Rate_CS"][idxRow]);
							stData["rateMPLB"] = trim(qProductRateData["New_Market_Price_Rate_LB"][idxRow]);
							stData["rateMPUom"] = trim(qProductRateData["Market_Price_UOM"][idxRow]);
						}
					}
					stData["uom"] = stUom;
					stData["volume"] = trim(qProductRateData["volume"][idxRow]);
	            	ArrayAppend(arrRetData, duplicate(stData));
	            }
			}
			//this.dmp(arrRetData);
			return arrRetData;
		</cfscript>

	</cffunction>

	<cffunction name="getProgramProductRate" output="false" hint="function to return a product rate for a given program discount type product">

		<cfargument name="programId"	type="Numeric" 	required="true" />
		<cfargument name="type"			type="Numeric" 	required="true" />
		<cfargument name="itemGuid"		type="string" 	required="true" />
		<cfargument name="compNameIDList" type="any" 	required="false" />

		<cfscript>
			//set local variables
			var nProgramID				= "";
			var nType					= "";
			var strItemId				= "";
			var strRate					= "";
			var strRetRate				= "";
			var lsCompNameID			= "";

			//assign local variables
			nProgramID		= arguments.programId;
			nType			= arguments.type;
			strItemId		= arguments.itemGuid;
			lsCompNameID	= arguments.compNameIDList;

			//if product rate type is 1 (Fixed Price) then get the rate from getProgramProductFixedRate()
			if (nType eq 1)
			{
				strRate	= getProgramProductFixedRate(nProgramID, strItemId);
			}
			//if product rate type is 2 (Rebate) then get the rate from getProgramProductRebateRate()
			else
			{
				strRate	= getProgramProductRebateRate(nProgramID, strItemId, lsCompNameID);
			}

			strRetRate = strRate;

			return strRetRate;

		</cfscript>

	</cffunction>

	<cffunction name="getProgramProductFixedRate"output="false" hint="function to return a fixed product rate for a given program product">

		<cfargument name="programId"	type="Numeric" 	required="true" />
		<cfargument name="itemGuid"		type="string" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID				= "";
			var strItemId				= "";
			var qGetRateData			= "";
			var strRetRate				= "";

			//assign local variables
			nProgramID		= arguments.programId;
			strItemId		= arguments.itemGuid;

		</cfscript>

		<cfquery name="qGetRateData" datasource="#application.datasource#">

			SELECT	DISTINCT
					FPPD.Fixed_Price_Value AS rate
			FROM	Program_Fixed_Price_Product_Data FPPD
					INNER JOIN Program_Fixed_Component PFC ON PFC.Program_Fixed_Component_ID = FPPD.Program_Fixed_Component_ID
					INNER JOIN Program_Fixed_Component_Name FCN ON FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
					INNER JOIN Contract_Products CP ON CP.Contract_Products_ID = FPPD.Contract_Products_ID AND CP.Contract_Main_ID = FPPD.Program_ID
					INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			WHERE	FPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			AND		FPPD.Deleted = 0
			AND		PFC.Deleted = 0
			AND		CP.Deleted = 0
			AND		CP.Product_Type_ID = 1
			AND		CAST(BSAFIM.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) = '#strItemId#'

		</cfquery>

		<cfset strRetRate = qGetRateData.rate />

		<cfreturn strRetRate />

	</cffunction>

	<cffunction name="getProgramProductRebateRate"output="false" hint="function to return a rebate product rate for a given program product">

		<cfargument name="programId"	type="Numeric" 	required="true" />
		<cfargument name="itemGuid"		type="string" 	required="true" />
		<cfargument name="compNameIDList" type="any" 		required="false" />

		<cfscript>
			//set local variables
			var nProgramID				= "";
			var strItemId				= "";
			var qGetRateData			= "";
			var strRetRate				= "";
			var lsCompNameID			= "";

			//assign local variables
			nProgramID		= arguments.programId;
			strItemId		= arguments.itemGuid;
			lsCompNameID	= arguments.compNameIDList;
		</cfscript>
		<!---
				34789:Prog Rates� button doubling rates/Anand Rao
				Added the lsCompNameID in the join so that only the rate for the components are are in the list will be returned
		--->
		<cfquery name="qGetRateData" datasource="#application.datasource#">
			SELECT
						-- DISTINCT TOP 1
						Program_Rebates_Component_Data.Rate AS rate, CP.Is_Group, CP.Captured_From_Group
			FROM		Program_Rebates_Component_Data
						INNER JOIN Program_Rebates_Product_Data ON Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
						INNER JOIN Program_Rebates_Component ON Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
						INNER JOIN Program_Rebates_Component_Name ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
						<cfif lsCompNameID NEQ "" >
							AND 	Program_Rebates_Component.Program_Rebates_Component_name_ID in (#lsCompNameID#)
						</cfif>
						INNER JOIN Contract_Products CP ON CP.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID AND CP.Contract_Main_ID = Program_Rebates_Product_Data.Program_ID
						INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			WHERE		Program_Rebates_Component_Data.Deleted = 0
			AND			Program_Rebates_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			AND			Program_Rebates_Product_Data.Deleted = 0
			AND			Program_Rebates_Component.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">
			AND			Program_Rebates_Component.Deleted = 0
			AND			CP.Deleted = 0
			AND			CP.Product_Type_ID = 2
			AND			CAST(BSAFIM.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) = '#strItemId#'
			ORDER BY	CP.Is_Group, CP.Captured_From_Group
		</cfquery>
		<!---
			When there are muliple records, it means there are muliple components and
			it should be the sum of the rate from all the components.
			-Anand Rao/12-Jun-2012/32420-Deviation Grid is not Populating Correctly
		--->
		<cfif qGetRateData.RecordCount GTE 2>
			<cfset intRetRate = 0 />
			<cfloop query="qGetRateData">
				<cfset intRetRate = intRetRate + qGetRateData.rate />
			</cfloop>
			<cfset strRetRate = intRetRate />
		<cfelse>
			<cfset strRetRate = qGetRateData.rate />
		</cfif>

		<cfreturn strRetRate />

	</cffunction>

</cfcomponent>