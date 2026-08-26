<!--- /mvc/Models/Program/OnePageProgramManager.cfc --->
<cfcomponent displayname="Request For Pricing" output="false" access="public">

<cffunction name="init" output="false" returntype="mvc.Models.Program.RfpManager">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfset variables.ContractId = arguments.contractId />
	<cfreturn this />
</cffunction>

<cffunction name="getDiscountIdentifier" hint="getDiscountIdentifier" access="public" output="false" returntype="string">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfset var qGetDiscountIdentifier = "" />

	<cfquery name="qGetDiscountIdentifier" datasource="#application.datasource#">
		SELECT Disc.Discount_Identifier_Number,
				Disc.Discount_Identifier_Desc
		FROM Contract_Main CM
		INNER JOIN Program_Control_Panel_Options PCPO ON
			PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
		INNER JOIN Discount_Identifier Disc ON
				Disc.Discount_Identifier_ID = PCPO.Discount_Identifier_ID
		WHERE  CM.Contract_Main_Id = #arguments.contractId#
	</cfquery>

	<cfreturn qGetDiscountIdentifier.Discount_Identifier_Number />

</cffunction>

<cffunction name="getRevisionVersion" hint="" access="public" output="false" returntype="string">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfset var qGetrev = "" />
	<cfset var bRev = 0 />

	<cfquery name="qGetrev" datasource="#application.datasource#">
		SELECT  revision_version ,Is_A_Revision
		FROM contract_main CM
		WHERE  CM.Contract_Main_Id = #arguments.contractId#
	</cfquery>
	<cfif qGetrev.revision_version GT 1 OR qGetrev.Is_A_Revision EQ 1>
		<cfset bRev = 1 />
	</cfif>

	<cfreturn bRev />

</cffunction>

<cffunction name="getHQPositionId" hint="" access="public" output="false" returntype="numeric">
	<cfset var HQ = 0 />

	<cfquery name="qGetHQ" datasource="#application.datasource#">
		SELECT User_positions_id FROM User_Positions WHERE Position_Label = 'Headquarters' and deleted = 0
	</cfquery>
	<cfif qGetHQ.recordcount GT 0 >
		<cfset HQ = qGetHQ.User_positions_id />
	</cfif>

	<cfreturn  HQ />
</cffunction>


<cffunction name="getDistributors" hint="getDistributors" access="public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfset var qGetDistributors = "" />

	<cfset useLakebaseForqGetDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForqGetDistributors>
	<cftry>
		<cfset qGetDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"program_id" = "eq.#arguments.contractId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributors>
<cfquery name="qGetDistributors" datasource="#application.datasource#">
		SELECT	*
		FROM Contract_Distributors
		WHERE Program_Id = #arguments.contractId#
	</cfquery>
</cfif>

	<cfreturn qGetDistributors />

</cffunction>

<cffunction name="getEditFreight" hint="getEditFreight" access="public" output="false" returntype="boolean">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	 <cfquery name="qGetCM" datasource="#application.datasource#">
		SELECT  revision_version , Is_A_Revision, Contract_Status_Type_Idx, Approved,
				Contract_Is_Locked, Contract_Locked_By_User_ID
		FROM contract_main CM
		WHERE  CM.Contract_Main_Id = #arguments.contractId#
	</cfquery>

	<cfscript>
		//var profileSettings   = CreateObject("component","components.user.Profile").getProfileSettings(request.AccessStructure.Profiles_ID);
		var RFP_Freight_View_Create = session.Get_Profile_Settings.RFP_Freight_View_Create;

		if(qGetCM.Contract_Status_Type_Idx < 3 && qGetCM.Approved == 0 && RFP_Freight_View_Create == 2 && qGetCM.Contract_Is_Locked and qGetCM.Contract_Locked_By_User_ID eq request.AccessStructure.User_ID){
			return true;
		}
		else{
			return false;
		}
	</cfscript>

</cffunction>

<cffunction name="getEditFOB_DEL" hint="getEditFOB_DEL" access="public" output="false" returntype="boolean">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	 <cfquery name="qGetCM" datasource="#application.datasource#">
		SELECT  revision_version , Is_A_Revision, Contract_Status_Type_Idx, Approved,
				Contract_Is_Locked, Contract_Locked_By_User_ID
		FROM contract_main CM
		WHERE  CM.Contract_Main_Id = #arguments.contractId#
	</cfquery>

	<cfscript>
		//var profileSettings   = CreateObject("component","components.user.Profile").getProfileSettings(request.AccessStructure.Profiles_ID);
		var RFP_Freight_FOB_Delivered_View_Create = session.Get_Profile_Settings.RFP_Freight_FOB_Delivered_View_Create;

		if(qGetCM.Contract_Status_Type_Idx > 3 && qGetCM.Approved == 1 && RFP_Freight_FOB_Delivered_View_Create == 2 && qGetCM.Contract_Is_Locked and qGetCM.Contract_Locked_By_User_ID eq request.AccessStructure.User_ID){
			return true;
		}
		else{
			return false;
		}
	</cfscript>

</cffunction>

<cffunction name="updContractMain" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfset useLakebaseForqSaveInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqSaveInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#arguments.contractId#"
			},
			{
				"field#" = "#arguments.val#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSaveInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSaveInfo>
<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Contract_main SET #arguments.field# = '#arguments.val#' WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>
</cfif>

	<cfreturn arguments />

</cffunction>

<cffunction name="updStockItemBracket" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="stockItemBracket" type="numeric" required="false" default="0" />
		<cfscript>
		var bracketId = stockItemBracket;
		var CustId = this.getDefaultCustomer(arguments.contractId);
		var s = '';
            switch(bracketId) {
				  case 1:s = 'TL';break;
				  case 2:s = 'LTL';break;
			}
		</cfscript>

		<cfquery name="qSaveInfo" datasource="#application.datasource#">
			--- TODO
			Update Contract_Main_Aux_Data set Data_integration_Deals_ID = #arguments.stockItemBracket# WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>

		<cfquery name="qSaveInfo2" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_Rfp_Price') IS NOT NULL
				DROP TABLE ##tmp_Rfp_Price
		</cfquery>

		<cfquery name="qSaveInfo3" datasource="#application.datasource#">
					CREATE TABLE ##tmp_Rfp_Price
						(
							[ID] [INT] IDENTITY(1,1) NOT NULL,
							Base_Sales_CS DECIMAL(16,2),
							Price_List_ID uniqueidentifier,
							End_Date DateTime,
							Item VARCHAR(25),
							Contract_Products_ID INT
						)

					SET IDENTITY_INSERT ##tmp_Rfp_Price OFF


					INSERT INTO ##tmp_Rfp_Price (Base_Sales_CS, Price_List_ID, End_Date, Item, Contract_Products_ID)
					SELECT ISNULL(DS.Price,D.Price) AS Base_Sales_CS,
							ISNULL(DS.Price_List_Detail_Special_ID,D.Price_List_Detail_ID) AS Price_List_ID,
							ISNULL(D.End_Date,DS.End_Date) AS End_Date,
							I.Item,
							CP.Contract_Products_ID
					 FROM Contract_Products Cp
					 INNER JOIN BSA_Foodservice_Items_Master I ON
					 	I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
					 INNER JOIN Contract_Main CM ON
					 	CM.Contract_Main_Id = CP.Contract_Main_ID
					 LEFT JOIN Contract_Distributors CD ON
					 	CM.Contract_Main_Id = CD.Contract_Main_ID AND CD.Deleted = 0
					 LEFT JOIN BSA_Foodservice_Customers C ON
					 	C.Bsa_FoodService_Customers_Id = CD.Bsa_FoodService_Customers_Id
					 LEFT JOIN Price_List_Region PLR ON
					 	C.Price_List_Id = PLR.Region AND
					 		PLR.Size = '#s#'
					 LEFT JOIN TBD_Item TBD ON
						TBD.BSA_Foodservice_Items_Master_ID = CP.Bsa_Foodservice_Items_Master_Id AND
						TBD.Deleted = 0
					 LEFT JOIN Price_List_Detail D ON
					  	D.Price_List_Header_Id = PLR.Price_List_Header_Id AND
					  		(D.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
					  			OR
							D.Product_Id = TBD.Base_BSA_Foodservice_Items_Master_ID) AND
					    CM.Contract_End_Date >= D.Start_Date AND
						CM.Contract_Start_Date <= D.End_Date AND
					    D.Deleted = 0
					  LEFT JOIN Price_List_Header_Special HS ON
					  	HS.Customers_Id = C.Bsa_FoodService_Customers_Id
					  LEFT JOIN Price_List_Detail_Special DS ON
					  	DS.Price_List_Header_Special_ID = HS.Price_List_Header_Special_ID AND
							(DS.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
					  			OR
								(
									DS.Product_ID = TBD.Base_BSA_Foodservice_Items_Master_ID AND
									(I.SIGNATURE_SKU_INDICATOR = 'C' OR  I.SIGNATURE_SKU_INDICATOR = '1')  ---- ONLY ASSIGN Item_Bracket_ID if it is Stock item
								)
							) AND
					 	CM.Contract_End_Date >= DS.Start_Date AND
						CM.Contract_Start_Date <= DS.End_Date
					  WHERE CP.Contract_Main_Id = #arguments.contractId#
					  	/*	AND I.SIGNATURE_SKU_INDICATOR = 0	*/
						ORDER BY I.Item, ISNULL(DS.End_Date,D.End_Date) DESC, ISNULL(DS.Price,D.Price) ASC;

					WITH DUPES as
					(
						select * , ROW_NUMBER() OVER(PARTITION BY Item ORDER BY Item, End_Date  DESC, Base_Sales_CS ASC) AS RowNum  from ##tmp_Rfp_Price
					)

					DELETE FROM DUPES
					WHERE RowNum > 1

					UPDATE CP SET Item_Bracket_ID = #bracketId# ,Base_Sales_CS = tmp.Base_Sales_CS, Price_List_ID = tmp.Price_List_ID
					FROM Contract_Products Cp
					INNER JOIN ##tmp_Rfp_Price tmp ON
					CP.Contract_Products_ID = tmp.Contract_Products_ID
        </cfquery>
	<!--- 	<cfdump var="#qSave#" output="c:\dump.log"> --->
	<cfreturn 'updStockItemBracket' />

</cffunction>

<cffunction name="updItemStockItemBracket" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="stockItemBracket" type="numeric" required="false" default="0" />
	<cfargument name="prodList" type="string" required="false" default="0" />
		<cfscript>
		var bracketId = stockItemBracket;
		var CustId = this.getDefaultCustomer(arguments.contractId);
		var s = '';
            switch(bracketId) {
				  case 1:s = 'TL';break;
				  case 2:s = 'LTL';break;
			}
		</cfscript>

		<cfquery name="qSaveInfo4" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_Rfp_Price') IS NOT NULL
					DROP TABLE ##tmp_Rfp_Price
		</cfquery>

		<cfquery name="qSaveInfo5" datasource="#application.datasource#">
					CREATE TABLE ##tmp_Rfp_Price
						(
							[ID] [INT] IDENTITY(1,1) NOT NULL,
							Base_Sales_CS DECIMAL(16,2),
							Price_List_ID uniqueidentifier,
							End_Date DateTime,
							Item VARCHAR(25),
							Contract_Products_ID INT
						)

					SET IDENTITY_INSERT ##tmp_Rfp_Price OFF


					INSERT INTO ##tmp_Rfp_Price (Base_Sales_CS, Price_List_ID, End_Date, Item, Contract_Products_ID)
					SELECT ISNULL(DS.Price,D.Price) AS Base_Sales_CS,
							ISNULL(DS.Price_List_Detail_Special_ID,D.Price_List_Detail_ID) AS Price_List_ID,
							ISNULL(D.End_Date,DS.End_Date) AS End_Date,
							I.Item,
							CP.Contract_Products_ID
					 FROM Contract_Products Cp
					 INNER JOIN BSA_Foodservice_Items_Master I ON
					 	I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
					 INNER JOIN Contract_Main CM ON
					 	CM.Contract_Main_Id = CP.Contract_Main_ID
					 INNER JOIN Contract_Distributors CD ON
					 	CM.Contract_Main_Id = CD.Contract_Main_ID AND CD.Deleted = 0
					 INNER JOIN BSA_Foodservice_Customers C ON
					 	C.Bsa_FoodService_Customers_Id = CD.Bsa_FoodService_Customers_Id
					 LEFT JOIN Price_List_Region PLR ON
					 	C.Price_List_Id = PLR.Region AND
					 	PLR.Size = '#s#'
					 LEFT JOIN TBD_Item TBD ON
						TBD.BSA_Foodservice_Items_Master_ID = CP.Bsa_Foodservice_Items_Master_Id AND
						TBD.Deleted = 0
					 LEFT JOIN Price_List_Detail D ON
					  	D.Price_List_Header_Id = PLR.Price_List_Header_Id AND
					  		(D.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
					  			OR
							D.Product_Id = TBD.Base_BSA_Foodservice_Items_Master_ID) AND
					    CM.Contract_End_Date >= D.Start_Date AND
						CM.Contract_Start_Date <= D.End_Date AND
					    D.Deleted = 0
					  LEFT JOIN Price_List_Header_Special HS ON
					  	HS.Customers_Id = C.Bsa_FoodService_Customers_Id
					  LEFT JOIN Price_List_Detail_Special DS ON
					  	DS.Price_List_Header_Special_ID = HS.Price_List_Header_Special_ID AND
							(DS.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
					  			OR
								(
									DS.Product_ID = TBD.Base_BSA_Foodservice_Items_Master_ID AND
									(I.SIGNATURE_SKU_INDICATOR = 'C' OR  I.SIGNATURE_SKU_INDICATOR = '1')
								)
							) AND
					 	CM.Contract_End_Date >= DS.Start_Date AND
						CM.Contract_Start_Date <= DS.End_Date
					  WHERE CP.Contract_Main_Id = #arguments.contractId#  and
					  	/*	I.SIGNATURE_SKU_INDICATOR = 0 AND	*/
						CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#arguments.prodList#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
						ORDER BY I.Item, ISNULL(DS.End_Date, D.End_Date)  DESC, ISNULL(DS.Price,D.Price) ASC;

					WITH DUPES as
					(
						select * , ROW_NUMBER() OVER(PARTITION BY Item ORDER BY Item, End_Date  DESC, Base_Sales_CS ASC) AS RowNum  from ##tmp_Rfp_Price
					)

					DELETE FROM DUPES
					WHERE RowNum > 1

					UPDATE CP SET Item_Bracket_ID = #bracketId# ,Base_Sales_CS = tmp.Base_Sales_CS, Price_List_ID = tmp.Price_List_ID
					FROM Contract_Products Cp
					INNER JOIN ##tmp_Rfp_Price tmp ON
					CP.Contract_Products_ID = tmp.Contract_Products_ID

		</cfquery>

	<cfreturn 'updStockItemBracket' />

</cffunction>

<cffunction name="getStockItemBracket" hint="get Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfquery name="qGetInfo" datasource="#application.datasource#">
			--- TODO
			SELECT Data_integration_Deals_ID as stockItemBracket  FROM Contract_Main_Aux_Data WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>

	<cfreturn qGetInfo.stockItemBracket />
</cffunction>

<!--- <cffunction name="updContractMainAuxData" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfif (arguments.field EQ 'Gpo_Price_List_Id' OR arguments.field EQ 'NonGpo_Price_List_Id') AND arguments.val eq '0'>
		<cfset arguments.val = 'NULL'>
	</cfif>
	<cfif arguments.val eq 'NULL'>
		<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Contract_main_Aux_Data SET #arguments.field# = NULL WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>
	<cfelse>
		<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Contract_main_Aux_Data SET #arguments.field# = '#arguments.val#' WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>
	</cfif>cfif>
	<cfreturn arguments />

</cffunction> --->

<cffunction name="updPerfReq" hint="Save perf requirements" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetPerfReq" datasource="#application.datasource#">
			Delete FROM PPM
			FROM One_Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR ON
				PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
				<cfif arguments.field EQ 'parentChild'>
					AND (PPR.Requirement_Name = 'Parent' OR PPR.Requirement_Name = 'Child')
				<cfelseif arguments.field EQ 'Acute'>
					AND (PPR.Requirement_Name = 'Acute' OR PPR.Requirement_Name = 'Non-Acute'OR PPR.Requirement_Name = 'N/A')
				<cfelse>
					AND 1=2
				</cfif>
			WHERE PPM.Contract_Main_Id = #arguments.contractId#
		</cfquery>

			<cfquery name="qInsPerfReq" datasource="#application.datasource#">
				INSERT INTO One_Program_Perf_Mapping (
					Contract_Main_ID,
					Program_Perf_Req_ID,
					checked)
				SELECT #arguments.contractId#,
					Program_Perf_Req_ID,
					1
				FROM 	Program_Perf_Req
				WHERE
				<cfif arguments.field EQ 'parentChild'>
					<cfif arguments.val EQ '1'>
						Requirement_Name = 'Parent'
					<cfelseif arguments.val EQ '2'>
						Requirement_Name = 'Child'
					<cfelse>
						1 = 2
					</cfif>
				<cfelseif arguments.field EQ 'Acute'>
					<cfif arguments.val EQ '1'>
						Requirement_Name = 'Acute'
					<cfelseif arguments.val EQ '2'>
						Requirement_Name = 'Non-Acute'
					<cfelseif arguments.val EQ '3'>
						Requirement_Name = 'N/A'
					<cfelse>
						1 = 2
					</cfif>
				</cfif>
			</cfquery>

	<cfreturn arguments />

</cffunction>

<cffunction name="getFacilities" hint="get current customers" access="public" output="false" returntype="query">
	<cfargument name="ContractMainID" type="numeric" required="false" default="0" />
	<cfscript>
		var a		= arguments;
	</cfscript>
		<cfquery name="qGetFacilities" datasource="#application.datasource#">
			SELECT	W.Warehouse_Master_Id AS Facility_Id,
					W.Warehouse_Code AS Facility_Code,
					W.Warehouse_Name AS Warehouse_Name,
					'(' + Cast(W.Warehouse_Code as varchar(25)) + ') ' + W.Warehouse_Name as facility_desc
			FROM 	Warehouse_Master W
			WHERE Deleted = 0 AND
					Active_Code = 'A'
		</cfquery>

	<cfreturn qGetFacilities />

</cffunction>


<cffunction name="getProducts" hint="Get Product Data" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfscript>
		qGetProdInfo = this.getProductsQuery(arguments.contractId);
	</cfscript>
	<cfreturn application.util.query.toAgGridJSON(qGetProdInfo, 'Item,Description,Brand,Type_Code_Desc,Q_Brand,Type_Group_Desc,BSA_Foodservice_Items_Master_ID,Contract_Products_Id,OverRide,#compIdList#') />
</cffunction>


<cffunction name="getCompIdList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCompInfo" datasource="#application.datasource#">
				SELECT  Distinct PFCN.Program_Fixed_Component_Name_Id
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				WHERE 	PFC.Program_ID = '#arguments.contractId#' AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0
		</cfquery>
		<cfset compIdList = ValueList(qGetCompInfo.Program_Fixed_Component_Name_Id) />
		<!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
	<cfreturn compIdList />
</cffunction>

<cffunction name="getRFPCompIdList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCompInfo" datasource="#application.datasource#">
				SELECT  Distinct
					PFCN.Program_Fixed_Component_Name_Id AS compnameid,
					PFC.Program_Fixed_Component_Id AS compid,
					PFCN.Program_Fixed_Component_Name AS compname,
					pfcn.formula_pricing as is_formula
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				WHERE 	PFC.Program_ID = '#arguments.contractId#' AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0
		</cfquery>
	<!--- <cfdump var="#qGetCompInfo#" output="c:/dump.log" /> --->
	<cfreturn application.util.query.toAgGridJSON(qGetCompInfo, 'compname,compid,compnameid') />
</cffunction>

<cffunction name="getRFPCompIdListQuery" hint="" access="remote" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCompInfo" datasource="#application.datasource#">
				SELECT  Distinct
					PFCN.Program_Fixed_Component_Name_Id AS compnameid,
					PFC.Program_Fixed_Component_Id AS compid,
					PFCN.Program_Fixed_Component_Name AS compname,
					pfcn.formula_pricing as is_formula
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				WHERE 	PFC.Program_ID = '#arguments.contractId#' AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0 AND
						pfcn.formula_pricing = 1
		</cfquery>
	<!--- <cfdump var="#qGetCompInfo#" output="c:/dump.log" /> --->
	<cfreturn qGetCompInfo />
</cffunction>

<cffunction name="checkFixedComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetFixed" datasource="#application.datasource#">
			SELECT Count(F.Program_Fixed_Component_ID) AS FixedCount
			FROM Program_Fixed_Component F
			WHERE F.Program_ID = #arguments.contractId# AND
				  F.Deleted = 0
		</cfquery>

	<cfreturn qGetFixed.FixedCount />
</cffunction>

	<cffunction name="getDefaultWarehouse" hint="" access="remote" output="false" returntype="numeric">
			<cfargument name="contractId" type="numeric" required="false" default="0" />
			<cfscript>
				// stuff - ngt
				var WmId = 0;
				var a = arguments;
			</cfscript>
			<!--- Get distributor with max program weight.  Can't be another with same weight or no default --->
			<cfquery name="qGetWarehouse" datasource="#application.datasource#">
				SELECT TOP 1 Warehouse_Master_ID
                  FROM Contract_Distributors
                 WHERE Contract_Main_ID = #arguments.contractId#
                        AND Deleted = 0
                        GROUP BY Warehouse_Master_ID
                        ORDER BY SUM( ISNULL (TRY_CONVERT(FLOAT, ISNULL(Program_Weight, 0) ), 0 ) ) DESC

                /*

                SELECT TOP 1 W.Warehouse_Master_ID
				FROM contract_distributors CD
				INNER JOIN BSA_Foodservice_Customers C ON
					C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
				INNER JOIN Warehouse_Master W ON
						W.Warehouse_Master_Id = C.Warehouse_Master_Id
				WHERE Contract_Main_ID = #a.contractId# AND CD.Program_Weight = (SELECT MAX(Program_Weight) FROM contract_distributors cdmax where contract_Main_ID = #a.contractId# and deleted = 0 ) AND
						NOT EXISTS (SELECT BSA_Foodservice_Customers_ID
										FROM Contract_Distributors CDWeight
										where contract_Main_ID = #a.contractId# and deleted = 0 and CDWeight.Program_Weight = cd.Program_Weight AND CDWeight.BSA_Foodservice_Customers_ID != CD.BSA_Foodservice_Customers_ID)
						AND CD.Deleted = 0
				ORDER BY Program_weight DESC
                */
			</cfquery>

			<cfif qGetWarehouse.recordcount GT 0>
				<cfset WmId = qGetWarehouse.Warehouse_Master_ID />
			</cfif>

		<cfreturn WmId />
	</cffunction>

	<cffunction name="getDefaultCustomer" hint="" access="public" output="false" returntype="String">
			<cfargument name="contractId" type="numeric" required="false" default="0" />
			<cfscript>
				// stuff
				var WmId = '';
				var a = arguments;
			</cfscript>
			<!--- Get distributor with max program weight.  Can't be another with same weight or no default --->
			<cfquery name="qGetWarehouse" datasource="#application.datasource#">
				SELECT TOP 1 CD.BSA_Foodservice_Customers_ID
				FROM contract_distributors CD
				WHERE Contract_Main_ID = #a.contractId# and deleted = 0
				ORDER BY Program_weight DESC
			</cfquery>
			<!--- <cfdump var = '#qGetWarehouse#' output='c:\dump.log'> --->

			<cfif qGetWarehouse.recordcount GT 0>
				<cfset WmId = qGetWarehouse.BSA_Foodservice_Customers_ID />
			</cfif>

		<cfreturn WmId />
	</cffunction>

<!--- MASS APPLY RATES --->
	<cffunction name="updateRFPCompRates" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="aData" type="any" required="true" />
		<cfargument name="compId" type="string" required="true" default="0" />
		<cfargument name="rate" type="numeric" required="true" default="0" />
			<cfscript>
				// stuff
				var arrData = deserializeJson(aData);
				var a = arguments;
				var st = {};
				var rId = 0;
				var s = '';
				for (i=1; i <= arrayLen(arrData);i=i+1) {
				    st = arrData[i];
				    rId = st['program_rebates_component_id_byname_#compId#'];
				    st['rate_#rId#'] = a.rate;
				    rid = 'rate_' & rid;
				    s = serializeJson(st);
				    saveRFPProductOverRide(a.contractId,s,rId);
				}

				//writedump(var=dId,output='c:\dump.log');
			</cfscript>

			<cfreturn 'MASSAPPLY'/>
	</cffunction>

	<cffunction name="deleteRFPProducts" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="aData" type="any" required="true" />
			<cfscript>
				// stuff
				var arrData = deserializeJson(aData);
				var a = arguments;
				var lBSAid = '';
				var lCPid = '';
				var lPRDid = '';
				var lCPFixedid = '';
				for (i=1; i <= arrayLen(arrData);i=i+1) {
				    st = arrData[i];
				    	lBSAid = listappend(lBSAid,st.bsa_foodservice_items_master_id);
				    	lCPid = listappend(lCPid,st.contract_products_id);
				    	lCPFixedid = listappend(lCPFixedid,st.contract_products_id_fixed);
				}
			</cfscript>
			<cfquery name="qDeletSelectedRFPProds" datasource="#application.datasource#" result='qDeletSelectedRFPProds'>

				DELETE PFPPD
				FROM  Contract_Products CP
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_ID = CP.Contract_Products_ID
				WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
					CP.Product_Type_ID = 1 AND
					CP.Contract_Products_ID in (<cfqueryparam value="#lCPFixedid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

                DELETE cpmo
                  FROM Contract_Products CP
                        INNER JOIN Contract_Product_Margin_Override cpmo ON
                            cpmo.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
                            AND Field_Name = 'Variable_contribution_margin_cs'
                 WHERE CP.Contract_Main_Id = #a.contractId#
                        AND CP.Contract_Products_ID in (<cfqueryparam value="#lCPFixedid#" cfsqltype="CF_SQL_VARCHAR" list="true"/>)
				DELETE FROM Contract_Products where Contract_Main_Id = #a.contractId# AND
					Contract_Products_Id IN(<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
			</cfquery>

			<cfreturn 'DELETE_RFP PRODUCTS'/>
	</cffunction>

	<cffunction name="deleteOneRFPComponent" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="compId" type="string" required="true" default="0" />
			<cfscript>
				// stuff
				var a = arguments;
			</cfscript>

			<cfquery name="qDeleteOneRFPComponentProds" datasource="#application.datasource#" result='qDelOneRFPCompProd'>
				DELETE PFPPD
				FROM  Contract_Products CP
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CP.Contract_Main_Id
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_ID = CP.Contract_Products_ID
					AND PFPPD.Program_fixed_Component_Id = PFC.Program_fixed_Component_Id
				WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
					CP.Product_Type_ID = 1 AND
					PFC.Program_fixed_Component_Name_Id = #a.compID#


				DELETE FROM PFC
				FROM Program_Fixed_Component PFC
				WHERE PFC.Program_ID = #a.contractId# AND
					PFC.Program_fixed_Component_Name_Id = #a.compID#
			</cfquery>

			<!---  <cfdump var="#qDelOneRFPCompProd#" output="c:\dump.log">
			<cfdump var="#qDelOneRFPComp#" output="c:\dump.log">  --->
			<cfreturn 'deleteRFPComponent'/>
	</cffunction>

	<cffunction name="saveRFPProductOverRide" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="any" required="true" />
		<cfargument name="field" type="string" required="true" default="0" />
		<cfargument name="rev" type="numeric" required="true" default="0" />
			<cfscript>
				// stuff
				var st = deserializeJson(stData);
				var a = arguments;
				var rId = listLast(field,'_');
				var rate = st['#field#'];
				var dId = st['program_fixed_price_product_data_id_#rId#'];
				var currentPrice = st['current_price'];
			</cfscript>
			<cfquery name="qSaveRfpProdOverRide" datasource="#application.datasource#">
				UPDATE Program_Fixed_Price_Product_Data
				SET Fixed_Price_Value = CAST(CAST(#rate# as decimal(14,2)) as VARCHAR (25))
				,Unit_Of_Measure_ID = 1
				<!---<cfif currentPrice eq 0>
					,Market_Price_Rate_Orig = #rate#
				</cfif> et_Price_Rate_Orig = #rate#
				</cfif> --->
				WHERE program_fixed_price_product_data_id = #dId# AND
					Contract_Products_Id = '#st.Contract_Products_Id#'
			</cfquery>

			<cfquery name="qSaveCurrentPrice" datasource="#application.datasource#">
				UPDATE P2 set Market_Price_Rate_Orig = p.Market_Price_Rate_Orig
				FROM Program_Fixed_Price_Product_Data P2
				INNER JOIN Program_Fixed_Price_Product_Data P ON
						P.program_fixed_price_product_data_id != #dId# AND
						P.Program_Id = '#a.contractId#' AND
						P.Contract_Products_Id = P2.Contract_Products_Id AND
						isNull(p.Market_Price_Rate_Orig,0) != 0
				WHERE 	P2.program_fixed_price_product_data_id = #dId# AND
						P2.Contract_Products_Id = '#st.Contract_Products_Id#'
			</cfquery>
				<!--- <cfif a.rev eq 0>
					,Market_Price_Rate_Orig = #rate#
				</cfif> --->
			<!--- Update other fixed comps to 0 for this item --->
			<cfquery name="qSaveRfpProdOverRide" datasource="#application.datasource#">
				UPDATE Program_Fixed_Price_Product_Data
				SET Fixed_Price_Value = 0
				---,Market_Price_Rate_Orig = 0
				--,Unit_Of_Measure_ID = 1
				WHERE program_fixed_price_product_data_id != #dId# AND
						Program_Id = '#a.contractId#' AND
						Contract_Products_Id = '#st.Contract_Products_Id#'
			</cfquery>

			<!--- <cfdump var='#qEndUser#' output='c:\dump.log'> --->
		<cfreturn this.getRfpProducts(contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="getFixedComps" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="hasData" type="numeric" required="false" default="0" />
			<cfscript>
				// stuff
				var a = arguments;
				//var hasData = a.hasData; // checkRFPRebateComp(a.contractId);
			</cfscript>
			<cfquery name="qGetFixedComps" datasource="#application.datasource#">
				SELECT 	'' AS chkbox,
						F.Program_Fixed_Component_Name_Id as CompId,
						F.Program_Fixed_Component_Name as name,
						CASE WHEN PFC.Program_Fixed_Component_Id IS NOT NULL THEN 1
						ELSE 0
						END AS Selected,

						CASE WHEN  F.OFF_Invoice_On = 1 THEN
							ISNULL(nullif(PFC.Claim_Mechanics,0),PTOI.Payment_Type_ID)
						ELSE ISNULL(nullif(PFC.Claim_Mechanics,0),PT.Payment_Type_ID)
						END AS pay_id,

						CASE WHEN  F.OFF_Invoice_On = 1 THEN
							PTOI.Payment_type_Name
						ELSE PT.Payment_type_Name
						END as pay_name,

						ISNULL(PFC.Program_Fixed_Component_Id,0) as prg_comp_id
				FROM 	Contract_Main CM
				INNER JOIN	Program_Control_Panel_Options PCPO ON
					CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
				INNER JOIN Program_Template_Component ptc ON
					ptc.Template_ID = pcpo.ProgramControl_Panel_Options_ID
				INNER JOIN Payment_Template_Mapping PTM on PTM.Template_ID =  PCPO.ProgramControl_Panel_Options_ID
				INNER JOIN Program_Fixed_Component_Name F ON
					F.Program_Fixed_Component_Name_Id = PTC.Component_Id
				LEFT JOIN Program_Fixed_Component PFC ON
					PFC.Program_Id = CM.Contract_Main_Id AND
					PFC.Program_Fixed_Component_Name_Id = F.Program_Fixed_Component_Name_Id AND
					PFC.Deleted = 0
				LEFT JOIN Program_Fixed_Component_Profile PFCP ON
					PFCP.Program_Fixed_Component_Name_ID = F.Program_Fixed_Component_Name_Id AND
					PFCP.Profiles_ID = #request.AccessStructure.Profiles_ID# AND
					PFCP.Deleted = 0
				LEFT JOIN Payment_Type PT ON PT.Payment_Type_ID = PTM.Payment_Type_ID AND PT.Off_Invoice = 0
				LEFT JOIN Payment_Type PTOI ON PTOI.Payment_Type_ID =  PTM.Payment_Type_ID AND PTOI.Off_Invoice = 1
				WHERE CM.Contract_Main_Id = '#a.contractId#' AND
				PTC.Deleted = 0 AND
				F.Deleted = 0 AND
				PTC.Discount_Type_Id = 1 AND
				(
					(   PT.Payment_Type_ID IS NOT NULL AND F.OFF_Invoice_On = 0) OR
				    ( PTOI.Payment_Type_ID is not null AND F.OFF_Invoice_On = 1)
				) AND
				ISNULL(PFCP.Allow_User_To_View,1) = 1
				ORDER BY F.Program_Fixed_Component_Name
			</cfquery>

		<cfreturn application.util.query.toAgGridJSON(qGetFixedComps, 'compid,name,selected,pay_id,pay_name,prg_comp_id')  />
	</cffunction>

	<cffunction name="saveRFPFixedComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="Component_Name_ID" type="numeric" required="false" default="0" />
		<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />

		<!--- <cfquery name="qDelFixedComps" datasource="#application.datasource#">
			Update Program_Fixed_Component
			Set deleted = 1
			WHERE Program_Id = #arguments.contractId#
		</cfquery> --->
			<cfquery name="qInsFixedComps" datasource="#application.datasource#" result="q">
				INSERT INTO Program_Fixed_Component
						(Program_ID,Program_Fixed_Component_Name_Id,Fixed_Component_Paid_To, Claim_Mechanics, GL_account_Id)
				SELECT #arguments.contractId#,
					PFCN.Program_Fixed_Component_Name_Id,
					ISNULL(PTC.Default_Paid_To_CF_Pages,1) AS Fixed_Component_Paid_To,
					#arguments.Claim_Mechanics# AS Claim_Mechanics,
					GCM.GL_Account_Id
				FROM Program_Fixed_Component_Name PFCN
				INNER JOIN Contract_Main CM ON
					CM.Contract_Main_ID = #arguments.contractId#
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
				LEFT JOIN GL_Component_Mapping GCM
					ON GCM.Discount_Type_ID = 1
					AND GCM.Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				LEFT JOIN Program_Template_Component PTC ON
					Template_Id = PCPO.ProgramControl_Panel_Options_ID AND
					PTC.Discount_Type_Id = 1 AND
					PTC.Component_Id = PFCN.Program_Fixed_Component_Name_ID AND
					PTC.Deleted = 0
				WHERE Program_Fixed_Component_Name_id = #arguments.Component_Name_ID# AND
						PFCN.Deleted = 0 AND
						 NOT EXISTS(
								SELECT Program_ID FROM Program_Fixed_Component PFC2
								WHERE PFC2.Program_ID = #arguments.contractId# AND
										PFC2.Deleted = 0 AND
										PFC2.Program_Fixed_Component_Name_id = #arguments.Component_Name_ID#
							)

				UPDATE Contract_Main
				SET ClaimMechanics = '#arguments.Claim_Mechanics#'
				WHERE Contract_Main_ID = #arguments.contractId#
			</cfquery>
			<cfquery name="qInsRFPFixedCompData" datasource="#application.datasource#">
					INSERT INTO Program_Fixed_Price_Product_Data (
							Program_ID,
							Contract_Products_ID,
							Fixed_Price_Value,
							Unit_Of_Measure_ID,
							Program_Fixed_Component_ID
						)
						SELECT
							CM.Contract_Main_Id,
							CP.Contract_Products_Id,
							0,--CP.Base_Sales_Cs,
							1 as Unit_Of_Measure_ID,
							PFC.Program_Fixed_Component_ID
						FROM Contract_Main CM
						INNER JOIN Program_Fixed_Component PFC ON
							PFC.Program_ID = CM.Contract_Main_Id AND
							PFC.Deleted = 0
						INNER JOIN Contract_Products CP ON
							CP.Contract_Main_Id = CM.Contract_Main_Id
						WHERE CM.Contract_Main_Id = #arguments.contractId#  AND
								PFC.Program_Fixed_Component_Name_id = #arguments.Component_Name_ID# AND
								CP.Deleted = 0 AND
								CP.Product_Type_ID = 1
			</cfquery>

		<cfreturn 'SAVED'  />
	</cffunction>

	<cffunction name="checkRFPRebateComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />

			<cfquery name="qGetRFPrebate" datasource="#application.datasource#">
				SELECT Max(ISNULL(PFC.Program_Fixed_Component_ID,0)) AS iNumber
				FROM 	Contract_Main CM
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = PRC.Program_Id AND
					PFC.Deleted = 0
			---	INNER JOIN Program_Rebates_Product_Data PRPD ON
			---		PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
				WHERE CM.Contract_Main_Id = #arguments.contractId# AND
						PRC.Deleted = 0
			</cfquery>

		<cfreturn application.util.query.toAgGridJSON(qGetRFPrebate, 'inumber') />
	</cffunction>

	<cffunction name="checkRFPRebateCompHeader" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />

			<cfquery name="qGetRFPrebate" datasource="#application.datasource#">
				SELECT Count(PRC.Program_Rebates_Component_ID) AS iNumber FROM 	Contract_Main CM
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id
				WHERE CM.Contract_Main_Id = #arguments.contractId# AND
						PRC.Deleted = 0
			</cfquery>

		<cfreturn qGetRFPrebate.iNumber />
	</cffunction>

	<cffunction name="createRfpComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="LoyaltyCompId" type="numeric" required="false" default="0" />
		<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
			var data = {};
			data.compid = a.LoyaltyCompId;
			data.selected = 1;
			jsonData = serializeJson(data);
			if(checkRFPRebateCompHeader(a.contractId) == 0 && a.LoyaltyCompId == 0){
				return('DONE No Rebate Comp Selected');
			}

			saveRFPFixedComp(a.contractId,a.Claim_Mechanics);

			//writedump(var=form,output='c:\dump.log');
		</cfscript>

		<cfreturn 'DONE createRfpComponents'  />
	</cffunction>

	<cffunction name="deleteRfpComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>
			<cfquery name="qDeleteRFPrebate" datasource="#application.datasource#">
				DELETE FROM Contract_Products WHERE Contract_Main_Id = #a.contractId#
				-- DELETE FROM Program_Rebates_Product_Data WHERE program_ID = #a.contractId#
				-- DELETE FROM Program_Rebates_Component_Data WHERE Program_Rebates_Component_ID IN (SELECT Program_Rebates_Component_Id from Program_Rebates_Component where program_Id = #a.contractId# )
				DELETE FROM Program_Fixed_Price_Product_Data WHERE  Program_Fixed_Component_ID IN (SELECT Program_Fixed_Component_ID FROM Program_Fixed_Component PFC WHERE PFC.Program_ID =#a.contractId#)
				---UPDATE Program_Rebates_Component Set Deleted = 1 WHERE program_Id = #a.contractId# AND deleted = 0
				UPDATE Program_Fixed_Component SET Deleted = 1 WHERE Program_ID = #a.contractId# And Deleted = 0
			</cfquery>

		<cfreturn 'DeleteRFPComponents Done' />
	</cffunction>

	<cffunction name="getRfpProducts" hint="getRfpProducts" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="true" default="0" />
		<cfargument name="ContractProdId" type="numeric" required="false" default="0" />
		<cfargument name="ProdId" type="string" required="false" default="" />
		<cfscript>
			var jsonData = '';
			var a = arguments;
			jsonData = serializeJson(getRfpProductsObject(a.contractId,a.ContractProdId,a.ProdId));
			//writedump(var=form,output='c:\dump.log');
		</cfscript>

		<cfreturn jsonData/>
	</cffunction>

	<cffunction name="getRfpProductsObject" hint="" access="Public" output="false" returntype="Array">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="ContractProdId" type="numeric" required="false" default="0" />
		<cfargument name="ProdId" type="string" required="false" default="" />
		<cfargument name="tier" type="numeric" required="false" default="4" />
		<cfargument name="overRidePricelistId" type="string" required="false" default="" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>

		<cfquery name="qGetRfpFixedFComps" datasource="#application.datasource#">
				SELECT PFC.Program_Fixed_Component_ID,
					   PFCN.Program_Fixed_Component_Name_ID,
					   PFCN.Program_Fixed_Component_Name,
					   convert(varchar, ISNULL(CM.Effective_Start_Date,Contract_Start_Date), 1) AS Contract_Start_Date,
					   convert(varchar, ISNULL(CM.Effective_End_Date,Contract_End_Date), 1) AS Contract_End_Date,
					   CM.Contract_Reference_Number
				FROM Contract_Main CM
				INNER JOIN Program_Fixed_Component PFC ON PFC.Program_ID = CM.Contract_Main_Id
				INNER JOIN Program_Fixed_Component_Name PFCN
					ON PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
				WHERE CM.Contract_Main_Id = #a.contractId#  AND
						PFC.Program_ID = #a.contractId# AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0
		</cfquery>
		<cfscript>
			var data = {};
			var data2 = {};
			var aResult = [];
			var qFixedComps = qGetRfpFixedFComps;
			var qProdData = '';
			var qProdFixData = '';
			var id = 0;
			var i = 1;
			var p = 1;
			var redi = 0;
			//-------------------------------------   GET FIXED   ------------------------------
			for (compFixRow in qFixedComps) {
			    qProdFixData = getRfpFixedProductData(compFixRow.Program_Fixed_Component_ID,a.contractId,a.ProdId);
			    //writedump(var=qProdFixData,output='c:\dump.log');
			    //writedump(var=compFixRow,output='c:\dump.log');
			    p=1;
			    for (dataFixRow in qProdFixData) {
				 	data = {};
				 	id = compFixRow.Program_Fixed_Component_ID;
				 	nameId = compFixRow.Program_Fixed_Component_Name_ID;
				 	if(! Isnumeric(dataFixRow.fixed_price_value)){
				 		dataFixRow.fixed_price_value = 0;
					}
					data['program_fixed_component_id_#id#'] = compFixRow.program_fixed_component_id;
					data['program_fixed_component_name_id_#id#'] = compFixRow.program_fixed_component_name_id;
					data['program_fixed_component_name_#id#'] = compFixRow.program_fixed_component_name;
				   	data['program_fixed_price_product_data_id_#id#']= dataFixRow.program_fixed_price_product_data_id;
				   	data['program_fixed_component_id_byname_#nameId#']= dataFixRow.program_fixed_component_id;
				   	data['fixed_price_value_#id#'] = dataFixRow.fixed_price_value;
					data['unit_of_measure_id_#id#'] = dataFixRow.unit_of_measure_id;
					data['is_formula_#id#'] = dataFixRow.Formula_Pricing;
					data['is_formula'] = dataFixRow.Formula_Pricing;

					if(dataFixRow.variance_perc != 0){
						data['variance_perc'] = dataFixRow.variance_perc;
					}
					if(dataFixRow.current_price > 0){
						data['current_price'] = dataFixRow.current_price;
					}

					if( dataFixRow.fixed_price_value != 0 ){
						data['redi'] = dataFixRow.redi;
					}

					if(i==1){
						data['contract_products_id_fixed']= dataFixRow.contract_products_id;
						data['contract_products_id']= dataFixRow.contract_products_id;
					   	data['price_list_id'] = dataFixRow.price_list_id;
						data['item'] = dataFixRow.item;
						data['description'] = dataFixRow.description;
                        data['bsa_foodservice_items_master_id'] = dataFixRow.bsa_foodservice_items_master_id;
                        data['net_weight'] = dataFixRow.net_weight;
                        data['gross_weight'] = dataFixRow.gross_weight;
						// data['start_date'] = dataFixRow.start_date;
						// data['end_date'] = dataFixRow.end_date;
						data['base_sales_cs'] = dataFixRow.base_sales_cs;
						data['list_price'] = dataFixRow.list_price;
						data['program_fixed_price_product_data_id'] = dataFixRow.program_fixed_price_product_data_id;
					/* 	data['contract_start_date'] = compFixRow.Contract_Start_Date;
						data['contract_end_date'] = compFixRow.Contract_End_Date; */
						data['contract_reference_number'] = compFixRow.Contract_Reference_Number;
						data['volume'] = dataFixRow.volume;
						data['current_price'] = dataFixRow.current_price;
						data['variance_perc'] = dataFixRow.variance_perc;
						data['case_cube'] = dataFixRow.case_cube;
						data['annual_case_cube'] = dataFixRow.annual_case_cube;
						data['edit_stock_bracket'] = dataFixRow.Edit_Stock;
						data['item_bracket'] = dataFixRow.item_bracket;
						data['either_or'] = dataFixRow.either_or;
						data['commissions'] = dataFixRow.commissions;
						data['run_vol_cs'] = dataFixRow.run_vol_cs;
						data['run_vol_piece'] = dataFixRow.run_vol_piece;
						data['case_count'] = dataFixRow.case_count;
						data['custom_print_colors'] = dataFixRow.custom_print_colors;
						data['custom_print_ink'] = dataFixRow.custom_print_ink;
						data['isTBD'] = dataFixRow.isTBD;
						//data['redi'] = dataFixRow.redi;
						data['est_annual_piece'] = dataFixRow.est_annual_piece;
						data['facility_id'] = ["id"='#dataFixRow.facility_Id#',"name"='#dataFixRow.facility_desc#'];
						data['facility_desc'] = dataFixRow.facility_desc;
						data['est_annual_piece'] = dataFixRow.est_annual_piece;
						data['formula_comp_id'] = dataFixRow.formula_comp_id;
			 			aResult.append(data);
					}
					else{
						data2 = {};
						data2 = aResult[P];
						data2.Append(data);
						aResult[P] = data2;
					}
					p++;
				}
				i++;
			}
			//jsonData = serializeJson(aResult);
			//writedump(var=qProdFixData,output='c:\dump.log');
		</cfscript>

		<cfreturn aResult/>
	</cffunction>

	<cffunction name="getRfpFixedProductData" hint="getRfpFixedProductData" access="public" output="false" returntype="query">
		<cfargument name="ComponentId" type="numeric" required="false" default="0" />
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="ProdId" type="string" required="false" default="" />
		<cfargument name="ExcludeProductsWithNoPrice" type="numeric" required="false" default="0" />

		<cfscript>
			var isCustRedi = 0;
		</cfscript>

		<cfquery name="qGetRediCust" datasource="#application.datasource#">
			SELECT TOP 1 DT.Distributor_Type
			FROM contract_distributors CD
			INNER JOIN BSA_Foodservice_Customers C ON
				C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
			INNER JOIN Distributor_Type DT ON DT.Distributor_Type_ID = C.Distributor_Type_ID
			WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contractId#" /> AND
			 		CD.Deleted = 0 AND
					DT.Distributor_Type != 'Y'
		</cfquery>

		<cfscript>
			if(qGetRediCust.recordcount == 0){
				isCustRedi = 1;
			}
		</cfscript>

		<cfquery name="qGetRfpFixedProductData" datasource="#application.datasource#">
				SELECT PFC.Program_Fixed_Component_ID,
					  PFPPD.Program_Fixed_Price_Product_Data_ID,
					  PFPPD.Fixed_Price_Value,
					  PFPPD.Unit_Of_Measure_Id,
					  PFC.Program_Fixed_Component_Name_ID,
					  PFCN.Program_Fixed_Component_Name,
					  PFCN.Formula_Pricing,
					  CP.Contract_Products_Id,
					  I.Item,
					  I.Description,
					  I.BSA_Foodservice_Items_Master_Id,
					  isnull(I.alt_description, I.description) AS alt_description,
                      i.Net_Weight,
                      i.gross_weight,
					  ISNULL(convert(varchar, D.Start_Date, 1),'') AS Start_Date,
					  IsNull(convert(varchar, D.end_Date, 1),'') AS end_Date,
					 /* --- CAST(CP.Base_Sales_CS as decimal(12,2)) */
					  0.0 AS Base_Sales_CS,
					  CASE
						  WHEN isnumeric(CP.Base_Sales_CS) = 1 THEN cast(CP.Base_Sales_CS as decimal(14,2))
						  WHEN isnumeric(D.Price) = 1 THEN cast(D.Price as decimal(14,2))
						  ELSE 0.0
					  END as list_price,
					  H.Price_list_Id,
					  ROUND( (ISNULL(V.Volume_CS, 0) / 7) * 365,0) AS volume,
					  CASE
							WHEN isnumeric(PFPPD.Fixed_Price_Value) = 0 THEN 0
							WHEN isnumeric(PFPPD.Market_Price_Rate_Orig) = 0  THEN 0
							WHEN PFPPD.Market_Price_Rate_Orig = 0 THEN 0
							WHEN cast(PFPPD.Fixed_Price_Value  as decimal(14,2)) = 0.00 THEN 0
							ELSE cast(   ( cast(PFPPD.Fixed_Price_Value as decimal(12,4)) -  cast(PFPPD.Market_Price_Rate_Orig  as decimal(12,4)) )   /( cast(PFPPD.Market_Price_Rate_Orig as decimal(12,4))  ) *100 as Decimal(12,2))
						END
					as variance_perc,
					isnull(v.Volume_CS,0) as Volume_CS,
					isnull(v.Volume_LB,0) as Volume_LB,
					isnull(PFPPD.Market_Price_Rate_Orig,0) as current_price,
					ISNULL(ISNULL(nullif(cast(CP.case_cube as decimal(14,2)),0.0),i.Case_Count),0) as case_cube,
					CAST(ROUND( (ISNULL(V.Volume_CS, 0) / 7) * 365,0) * ISNULL(ISNULL(nullif(cast(CP.case_cube as decimal(14,2)),0.0),i.Case_Count),0) AS int)	AS annual_case_cube,
					CASE WHEN I.SIGNATURE_SKU_INDICATOR = 'C' OR  I.SIGNATURE_SKU_INDICATOR = '1'  /*  ONLY ASSIGN Item_Bracket_ID if it is Stock item  */
						THEN 1
						ELSE 0
					END AS Edit_Stock,
					CP.Item_Bracket_ID as item_bracket,
					CP.Product_Process_Flag as either_or,
					CP.Commissions as commissions,
					CAST(		ISNULL(NULLIF(CP.Run_Volume_CS,0),ISNULL(I.Prime_LOB,0))		AS decimal(12,4)) as run_vol_cs,
					CAST(		ISNULL(NULLIF(CP.Run_Volume_CS,0),ISNULL(I.Prime_LOB,0))		AS decimal(12,4)) * ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,2)),0.0),i.PACK_QTY),0.0) as  run_vol_piece,
					ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,2)),0.0),i.PACK_QTY),0.0) AS case_count,
					Isnull(Colors,0)	 AS custom_print_colors,
					Isnull(Graphics,'0') AS custom_print_ink,
					CASE WHEN TBD.BSA_Foodservice_Items_Master_ID IS NOT NULL THEN 1 ELSE 0 END AS isTBD,
					CP.Warehouse_Master_Id as facility_Id,
					'(' + Cast(W.Warehouse_Code as varchar(25)) + ') ' + W.Warehouse_Name as facility_desc,
					CASE WHEN ISNULL(PT.OFF_Invoice,0) = 0 THEN '0'
						WHEN #isCustRedi# = 1 AND (PVD.Prod_Var_D = 'REDI Eligible' OR PVD.Prod_Var_D = 'Y') THEN '1'
						ELSE '0'
						END
						AS Redi,
					ROUND( (ISNULL(V.Volume_CS, 0) / 7) * 365,0) * ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,2)),0.0),i.PACK_QTY),0.0) AS est_annual_piece,
					ISNULL(R.Program_Fixed_Component_Id,0) AS formula_comp_id
				FROM Program_Fixed_Component PFC
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PFPPD.Contract_Products_ID
				INNER JOIN BSA_Foodservice_Items_Master I ON I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
				LEFT JOIN Price_List_Detail D ON
					D.Price_List_Detail_Id = CP.Price_List_Id AND
					D.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
				LEFT JOIN Price_List_Header H ON
					H.Price_List_Header_ID = D.Price_List_Header_ID
				LEFT JOIN Program_Product_Volume V ON
					I.BSA_Foodservice_Items_Master_ID = V.BSA_Foodservice_Items_Master_ID AND
					V.Program_Id = PFC.Program_ID
				LEFT JOIN TBD_Item TBD ON
					TBD.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_ID
				LEFT JOIN Print_Program_Custom_Options PPCO ON
					PPCO.Contract_Main_Id = PFC.Program_ID AND
					PPCO.Contract_Products_Id = CP.Contract_Products_Id AND
					PPCO.Deleted = 0
				LEFT JOIN Warehouse_Master W  ON
					W.Warehouse_Master_Id = CP.Warehouse_Master_Id
				LEFT JOIN Prod_Var_D PVD ON
					PVD.Prod_Var_D_ID = I.Prod_Var_D_ID
				LEFT JOIN Payment_Type PT ON PT.Payment_Type_Id = PFC.Claim_Mechanics
				LEFT  JOIN Program_Formula_Pricing_Rules R ON
					R.Contract_Products_Id = CP.Contract_Products_ID AND
					R.Deleted = 0 AND
					R.Program_Fixed_Component_Id = PFC.Program_Fixed_Component_ID AND
					R.Program_Fixed_Component_Name_Id =  PFC.Program_Fixed_Component_Name_ID
				WHERE PFC.Program_ID = #arguments.contractId#  AND
					<cfif arguments.ComponentId NEQ 0>
						PFC.Program_Fixed_Component_Id =  #arguments.ComponentId# AND
					</cfif>
					PFPPD.Program_ID = #arguments.contractId# AND
					CP.Deleted = 0 AND
					PFC.Deleted = 0 AND
					PFPPD.Deleted = 0
					<cfif arguments.ProdID NEQ ''>
						AND I.Item = '#arguments.ProdId#'
					</cfif>
					<cfif arguments.ExcludeProductsWithNoPrice>
						AND CAST( PFPPD.Fixed_Price_Value AS FLOAT ) != 0
					</cfif>
				order by I.Item,CP.BSA_Foodservice_Items_Master_Id DESC
		</cfquery>
		<cfreturn qGetRfpFixedProductData />
	</cffunction>

	<cffunction name="updClaimMechanic" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />

		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cmId = st.pay_type.pay_id;
			var compId = st.prg_comp_id;
		</cfscript>
			<cfdump var="#st#" output="c:/dump.log" />
			<cfquery name="qSaveInfo" datasource="#application.datasource#">
				Update Program_Fixed_Component set Claim_Mechanics = #cmId#
				WHERE Program_Id = #a.contractId# AND
						Program_Fixed_Component_id = #compId#
			</cfquery>

		<cfreturn arguments />

	</cffunction>

	<cffunction name="saveItemBracket" hint="saveItemBracket" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var bracketId = st.item_bracket;
			var CustId = this.getDefaultCustomer(a.contractId);
			var s = '';
	            switch(bracketId) {
					  case 1:s = 'TL';break;
					  case 2:s = 'LTL';break;
				}
		</cfscript>

		<cfquery name="qSaveItemBracketn" datasource="#application.datasource#">
			Update Contract_Products set Item_Bracket_ID = '#bracketId#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" />
		</cfquery>
		<CFIF len(trim(CustId)) GT 0 and bracketId NEQ 3>
			<cfquery name="qUpdatePriceList" datasource="#application.datasource#" result = 'q'>
				Update Contract_Products set
					Base_Sales_CS = PLD.Price,
					Price_List_ID = PLD.Price_List_Detail_ID
				FROM
				(
					SELECT top 1 D.Price, D.Price_List_Detail_ID
					FROM Contract_Products CP
					INNER JOIN BSA_Foodservice_Items_Master I ON
					 	I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
					INNER JOIN Contract_Main CM ON
					 		CM.Contract_Main_Id = CP.Contract_Main_ID
					INNER JOIN BSA_Foodservice_Customers C ON
						C.Bsa_FoodService_Customers_Id = '#CustId#'
					INNER JOIN Price_List_Region PLR ON
						C.Price_List_Id = PLR.Region
						 AND PLR.Size = '#s#'
					LEFT JOIN TBD_Item TBD ON
						TBD.BSA_Foodservice_Items_Master_ID = CP.Bsa_Foodservice_Items_Master_Id AND
						TBD.Deleted = 0
					LEFT JOIN Price_List_Detail D ON
						D.Price_List_Header_Id = PLR.Price_List_Header_Id AND
							(D.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
								OR
								(
									D.Product_Id = TBD.Base_BSA_Foodservice_Items_Master_ID AND
									(I.SIGNATURE_SKU_INDICATOR = 'C' OR  I.SIGNATURE_SKU_INDICATOR = '1')
								)
							)
					WHERE	cp.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" /> and
							CP.Contract_Products_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
							CM.Contract_End_Date >= D.Start_Date AND
							CM.Contract_Start_Date <= D.End_Date
					ORDER BY D.End_Date ASC
				) AS PLD
				WHERE	Contract_Products.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" /> and
						Contract_Products.Contract_Products_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" />
			</cfquery>
			<!--- <cfdump var = '#q#' output='c:\dump.log'> --->
		</CFIF>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveCurrentPrice" hint="saveCurrentPrice" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var currentPrice = st.current_price;
		</cfscript>

		<cfquery name="qSaveCurrentPrice" datasource="#application.datasource#">
			UPDATE PD SET Market_Price_Rate_Orig = '#currentPrice#'
			FROM	dbo.Program_Fixed_Price_Product_Data PD
			WHERE	PD.Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					PD.Deleted = 0
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="SaveFormulaComponent" hint="SaveFormulaComponent" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="Fixed_Component_Id" type="numeric" required="false" default="0" />
		<cfargument name="Fixed_Component_Name_Id" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>

		<cfquery name="qSaveFormulaComp" datasource="#application.datasource#">
			UPDATE PD SET Market_Price_Rate_Orig = '#currentPrice#'
			FROM	dbo.Program_Fixed_Price_Product_Data PD
			WHERE	PD.Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					PD.Deleted = 0
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>



	<cffunction name="saveRunVolumeCS" hint="saveRunVolumePieces" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var bracketId = st.item_bracket;
			var pieces = st.run_vol_cs;
		</cfscript>
		<cfif isnumeric(pieces)>
			<cfquery name="qSaveRunVolCS" datasource="#application.datasource#">
				Update CP SET Run_Volume_CS =
				CASE WHEN (ISNULL(Prime_Lob,0) > 0 AND #pieces# >  ISNULL(Prime_Lob,0)) OR ISNULL(Prime_Lob,0) = 0
						THEN #pieces#
						ELSE ISNULL(Prime_Lob,0)
					END
				FROM Contract_Products CP
				LEFT JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
				WHERE	CP.Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
						CP.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
			</cfquery>
		</cfif>

		<!--- <cfif bracketId NEQ 3>
			<cfquery name="deleteCustomPrintOptions" datasource="#application.datasource#">
				UPDATE Print_Program_Custom_Options
				SET Deleted = 1
				WHERE Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" /> and
					  Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" />
			</cfquery>
		</cfif> --->

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveWeight" hint="saveWeight" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="netWeight" type="any" required="true" default="0" />
		<cfargument name="grossWeight" type="any" required="true" default="0" />
		<cfargument name="contractProductsId" type="numeric" required="true" />

		<cfscript>
			// stuff
			var a = arguments;
			var bResetNet = 0;
			var bResetGross = 0;
			if(a.netWeight == 0 OR NOT Isnumeric(a.netWeight)){
				bResetNet = 1;
			}
			if(a.grossWeight == 0 OR NOT Isnumeric(a.grossWeight)){
				bResetGross = 1;
			}
		</cfscript>

		<cfquery name="qSaveItemWeight" datasource="#application.datasource#">
			UPDATE CP
			SET <CFIF bResetNet EQ 0 AND Isnumeric(a.netWeight)>
					Net_Weight		 = '#a.netWeight#',
				<CFELSE>
					Net_Weight		 = ISNULL(I.Net_Weight,0),
				</CFIF>
				<CFIF bResetGross EQ 0 AND Isnumeric(a.grossWeight)>
					Gross_Weight	 = '#a.grossWeight#'
				<CFELSE>
					Gross_Weight	 = ISNULL(I.Gross_Weight,0)
				</CFIF>
			FROM Contract_Products CP
			<CFIF bResetNet EQ 1 OR bResetGross EQ 1>
			LEFT JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_id = CP.BSA_Foodservice_Items_Master_id
			</CFIF>
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractProductsId#" />  AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<CFIF bResetNet EQ 1>
			<cfquery name="qgetNet" datasource="#application.datasource#">
				Select Net_Weight
				FROM Contract_Products CP
				WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractProductsId#" />  AND
						Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
			</cfquery>
			<CFRETURN qgetNet.Net_Weight>
		</CFIF>

		<CFIF bResetGross EQ 1>
			<cfquery name="qgetNet" datasource="#application.datasource#">
				Select Gross_weight
				FROM Contract_Products CP
				WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractProductsId#" />  AND
						Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
			</cfquery>
			<CFRETURN qgetNet.Gross_weight>
		</CFIF>

		<cfreturn '0'/>
	</cffunction>

	<cffunction name="saveEitherOr" hint="saveEitherOr" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var eitherOr = st.either_or;
		</cfscript>

		<cfquery name="qSaveEitherOr" datasource="#application.datasource#">
			Update Contract_Products set Product_Process_Flag = '#eitherOr#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" />  AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveFacility" hint="saveFacility" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var facility_id = st.facility_id.id;
		</cfscript>

		<cfquery name="qSaveFacility" datasource="#application.datasource#">
			Update Contract_Products set Warehouse_Master_Id = '#facility_id#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveCommissions" hint="saveCommissions" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var commissions = st.commissions;
		</cfscript>

		<cfquery name="qSaveCommissions" datasource="#application.datasource#">
			Update Contract_Products set Commissions = '#commissions#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveListPrice" hint="saveListPrice" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var baseSalesCS = st.list_price;
			if(!isNumeric(baseSalesCS)){
				return this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item); 
			}
		</cfscript>

		<cfquery name="qSaveFacility" datasource="#application.datasource#">
			Update Contract_Products set Base_Sales_CS = '#baseSalesCS#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveCaseCube" hint="saveFacility" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var caseCube = st.case_cube;
			if(!isNumeric(caseCube)){
				return this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item); 
			}
		</cfscript>

		<cfquery name="qSaveFacility" datasource="#application.datasource#">
			Update Contract_Products set Case_Cube = '#caseCube#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveCaseCount" hint="saveFacility" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var caseCount = st.case_count;
			if(!isNumeric(caseCount)){
				return this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item);
			}
		</cfscript>

		<cfquery name="qSaveFacility" datasource="#application.datasource#">
			Update Contract_Products set Case_Count = '#caseCount#'
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveCustomPrint" hint="saveCustomPrint" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var cpId = st.contract_products_id;
			var colors = st.custom_print_colors;
			var ink = st.custom_print_ink;

			if(!isnumeric(colors) or Colors < 0){
				colors = 0;
			}
			else if(colors > 8){
				colors = 8;
			}

			if(!isnumeric(ink) or ink < 0){
				ink = 0;
			}
			else if(ink > 100){
				ink = 100;
			}
		</cfscript>

		<cfquery name="qCheck" datasource="#application.datasource#">
			Select * from Print_Program_Custom_Options
			WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
					Contract_main_Id = <cfqueryparam value="#a.contractId#" cfsqltype="cf_sql_integer" /> AND
					Deleted = 0
		</cfquery>
		<cfif qCheck.recordcount GT 0>
			<cfquery name="updCustomPrintOptions" datasource="#application.datasource#">
				UPDATE Print_Program_Custom_Options
				SET
					Graphics = <cfqueryparam value="#ink#" cfsqltype="CF_SQL_NVARCHAR" />,
					Colors = <cfqueryparam value="#colors#" cfsqltype="cf_sql_integer" />
				WHERE	Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cpId#" /> AND
						Contract_main_Id = <cfqueryparam value="#a.contractId#" cfsqltype="cf_sql_integer" />
			</cfquery>
		<cfelse>
			<cfquery name="qInsertPrintProgramCustomOptions" datasource="#application.datasource#">
				INSERT INTO Print_Program_Custom_Options
				(
					Contract_Main_Id,
					Contract_Products_ID,
					Graphics,
					Colors
				)
				VALUES
				(
					<cfqueryparam value="#a.contractId#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#cpId#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#ink#" cfsqltype="CF_SQL_NVARCHAR" />,
					<cfqueryparam value="#colors#" cfsqltype="cf_sql_integer" />
				)
			</cfquery>
		</cfif>
		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="massApplyFreight" hint="mass apply" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="aData" type="string" required="true" />
		<cfargument name="field" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			var arr = deserializeJson(a.aData);
			var stData = '';
			var res = '';
			for (i=1;i LTE ArrayLen(arr);i=i+1) {
				stData = serializeJson(arr[i]);
				res = savePFFR(a.contractId,stData,a.field,0);
			}
			return this.getFreightData(a.contractId,0);
		</cfscript>

	</cffunction>

	<cffunction name="savePFFR" hint="savePFFR" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfargument name="field" type="string" required="true" />
		<cfargument name="recalc" type="boolean" required="false" default = "1" />
		<cfscript>
			// stuff
			var a = arguments;
			var st = deserializeJson(a.stData);
			var data = st[field];
			var overField = 'OverRide_' & a.field;
			var frId = st.program_fixed_freight_id;
			var fobPrice = st.fob_price;
			var delPrice = st.delivered_Price;
			var isBlended = 0;
			if(st.fixed_component_type == 8){
				isBlended = 1;
			}
		</cfscript>

		<cfquery name="qSaveItemBracketFreight" datasource="#application.datasource#">
			Update Program_Fixed_Freight_Rates
				SET #a.field# = #data#
					<cfif a.field NEQ 'input_adjustment_amount' AND a.field NEQ 'is_delivered'>
						,#overField# = '#data#'
					</cfif>
					<cfif a.field EQ 'is_delivered'>
						,Final_Price_Change_Date = getDate()
						,Final_Price_Change_User_Id = <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">
						,Interfaced = 0
						<cfif data eq 1>
							,final_price = CAST(#delPrice# AS DECIMAL(10,2))
						<cfelseif data eq 0>
							,final_price = CAST(#fobPrice# AS DECIMAL(10,2))
						</cfif>
					</cfif>
			WHERE	program_fixed_freight_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#frId#" /> AND
					Program_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" /> AND
					Deleted = 0
		</cfquery>

		<cfif a.field EQ 'is_delivered'>
			<cfreturn this.getFreightData(a.contractId,frId,0) />
		<cfelseif  isBlended EQ 0>  <!--- rreturn one row  and recalc--->
			<cfreturn this.getFreightData(a.contractId,frId,1) />
		<cfelseif  a.recalc eq 0>
			<cfreturn 'rowSaved'/>	<!--- from mass apply, so no recalc.  Mass apply does it at the end --->
		</cfif>
		<cfreturn this.getFreightData(a.contractId,0) /> <!--- frId = 0 so it is blended and all rows returned (recalc is defaulted to 0) --->
	</cffunction>

	<cffunction name="resetFreightData" hint="resetFreightData" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var a = arguments;
			//var st = deserializeJson(a.stData);
		</cfscript>

		<cfquery name="qSaveItemBracketFreight" datasource="#application.datasource#">
			Update Program_Fixed_Freight_Rates
				SET OverRide_Freight_Upcharge_Amount = NULL,
					OverRide_Freight_Upcharge_Percent = NULL,
					OverRide_Warehouse_Master_ID = NULL,
					OverRide_Item_Bracket_ID = NULL,
					OverRide_OBF_Rate = NULL
			WHERE	program_fixed_freight_id in(#a.stData#) AND
					Program_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" /> AND
					Deleted = 0
		</cfquery>

		<cfreturn this.getFreightData(a.contractId,0) /> <!--- frId   TODO:  Only Freight Matrix needs full refresh--->
	</cffunction>

	<cffunction name="getFreightData" hint="getFreightData" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="freightId" type="numeric" required="false" default="0" />
		<cfargument name="reCalc" type="numeric" required="false" default="1" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>
		<cfif a.reCalc EQ 1>
			<cfquery name="SetRFPFreight" datasource="#application.datasource#">
					EXEC Populate_Program_Fixed_Freight_Rates_RFP '#a.contractId#'
			</cfquery>
		</cfif>

		<cfscript>
			GetRFPFreight = this.getFreightDataQuery(a.contractId,a.freightId);
		</cfscript>


		<cfreturn application.util.query.toAgGridJSON(GetRFPFreight) />
		<!--- <cfreturn serializeJSON(GetRFPFreight) /> --->
	</cffunction>

	<cffunction name="getFreightDataQuery" hint="getFreightData" access="remote" output="false">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="freightId" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>

		<cfquery name="GetRFPFreight" datasource="#application.datasource#">
			SELECT  PFFR.program_fixed_freight_id,
					PFFR.product_id,
					PFFR.customer_id,
					PFFR.program_id,
					PFFR.component_name_id,
					PFFR.delivered_price,
					PFFR.freight_rate,
					PFFR.fob_price,
					PFFR.freight_uom,
					PFFR.deleted,
					PFFR.paid_to,
					PFFR.program_fixed_component_id,
					PFFR.input_adjustment_amount,
					PFFR.obf_rate,
					PFFR.default_obf_rate,
					PFFR.OverRide_obf_rate,
					PFFR.freight_upcharge_amount,
					PFFR.default_freight_upcharge_amount,
					PFFR.OverRide_freight_upcharge_amount,
					PFFR.warehouse_master_id,
					PFFR.default_warehouse_master_id,
					PFFR.OverRide_warehouse_master_id,
					PFFR.item_bracket_id,
					PFFR.default_item_bracket_id,
					PFFR.OverRide_item_bracket_id,
					PFFR.is_delivered,
					PFFR.fixed_component_type,
					PFFR.final_price,
					PFFR.tbd_product_id,
					PFFR.OverRide_OBF_Rate,
					PFFR.OverRide_Freight_Upcharge_Amount,
					PFFR.OverRide_Freight_Upcharge_Percent,
					PFFR.OverRide_Warehouse_Master_ID,
					PFFR.OverRide_Item_Bracket_ID,
					I.Item,
					I.Description,
					C.Name,
					C.Ship_To,
					WM.Warehouse_Name,
					WM.Warehouse_Code,
					'(' + Cast(WM.Warehouse_Code as varchar(25)) + ') ' + WM.Warehouse_Name as facility_desc,
					interfaced,
					freight_rate_per_volume,
					ISNULL(ISNULL(nullif(cast(CP.case_cube as decimal(14,2)),0.0),i.Case_Count),0) as case_cube,
					freight_upcharge_percent,
					total_freight_cs,
					ISNULL(Won,0) as Won,
					CD.Program_Weight as weight
			FROM Program_Fixed_Freight_Rates PFFR
			INNER JOIN BSA_Foodservice_Customers C ON
				C.BSA_Foodservice_Customers_ID = PFFR.Customer_Id
			INNER JOIN Contract_Distributors CD ON
				CD.BSA_Foodservice_Customers_ID =  PFFR.Customer_Id AND
				CD.Contract_Main_ID = PFFR.Program_Id AND
				CD.Deleted = 0
			INNER JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = PFFR.Product_Id
			INNER JOIN Contract_Products CP ON
				CP.Contract_Products_Id = PFFR.Contract_Products_Id
			INNER JOIN Warehouse_Master WM ON
				WM.Warehouse_Master_ID = PFFR.Warehouse_Master_Id
			LEFT JOIN Program_product_bid_info BID ON
				BID.Product_ID = I.BSA_Foodservice_Items_Master_ID AND
				BID.Deleted = 0 AND
				BID.Program_ID = PFFR.Program_Id
			WHERE 	PFFR.Program_Id =  '#a.contractId#'
			AND 	PFFR.Deleted = 0
			<cfif a.freightId NEQ 0>
				AND program_fixed_freight_id = #a.freightId#
			</cfif>
			Order by C.Name, I.Item
		</cfquery>
		<!--- <cfreturn 'ItemBracketSaved' /> --->
		<cfreturn GetRFPFreight />
	</cffunction>

	<cffunction name="saveVolume" hint="saveRfpVolume" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="string" required="true" />
		<cfscript>
			// stuff
			var st = deserializeJson(stData);
			var a = arguments;
			var bsaId = st.bsa_foodservice_items_master_id;
			if(!isNumeric(st.volume)){
				return this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item);
			}
		</cfscript>

		<cfquery name="qGetProgramSpan" datasource="#application.datasource#">
			SELECT	DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1 AS Program_Span,
					Contract_Quantity_UOM_IDX
			FROM 	Contract_Main
			WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#a.contractId#" />
		</cfquery>

		<!--- <cfset nProgramSpan = qGetProgramSpan.Program_Span /> --->
		<cfset nProgramSpan = 365 />
		<cfset Contract_Quantity_UOM_IDX = qGetProgramSpan.Contract_Quantity_UOM_IDX />

		<cfquery name="qCheckVolume" datasource="#application.datasource#">
			SELECT	Program_Product_Volume_ID,
					ISNULL(I.Is_Item_Group,0) AS Is_Item_Group,
					I.Net_Weight
			FROM	BSA_Foodservice_Items_Master I
			LEFT JOIN  Program_Product_Volume V ON
			 	I.BSA_Foodservice_Items_Master_ID = V.BSA_Foodservice_Items_Master_ID
			 	AND		V.Program_ID = #a.contractId#
			 	AND V.deleted = 0
			WHERE	I.BSA_Foodservice_Items_Master_ID = '#bsaId#'
		</cfquery>

		<cfif Contract_Quantity_UOM_IDX EQ 1>
			<cfset nWeeklyCs = (st.volume * 7.00) / nProgramSpan />
		<cfelse>
			<cfset nWeeklyCs = (st.volume / qCheckVolume.Net_Weight * 7.00) / nProgramSpan />
		</cfif>

		<!---<cfset nWeeklyCs = (stVolume["#i#"]["volume"] * 7.00) / nProgramSpan />--->
		<cfset nWeeklyCs = TRIM(nWeeklyCs) />
		<cfif NOT isNumeric(nWeeklyCs)>
			<cfset nWeeklyCs = (1 * 7.00) / nProgramSpan />
		</cfif>

		<cfif qCheckVolume.Program_Product_Volume_ID NEQ ''>
			<cfquery name="qUpdateVolume" datasource="#application.datasource#">
				UPDATE	Program_Product_Volume
				SET		Volume_CS = <cfqueryparam value="#trim(nWeeklyCs)#" cfsqltype="CF_SQL_FLOAT" />,
						Volume_Cap_UOM = #Contract_Quantity_UOM_IDX#
				WHERE	BSA_Foodservice_Items_Master_ID = '#bsaId#'
				AND		Program_ID = #a.contractId#
				AND		Deleted = 0
			</cfquery>
		<cfelse>
			<cfquery name="qInsertVol" datasource="#application.datasource#">
				INSERT INTO	Program_Product_Volume
					(BSA_Foodservice_Items_Master_ID, Program_ID, Volume_CS, Is_Group, Volume_Cap_UOM)
				VALUES
					('#bsaId#', #a.contractId#,  <cfqueryparam value="#nWeeklyCs#" cfsqltype="CF_SQL_DECIMAL" SCALE="6" />,#qCheckVolume.Is_Item_Group# ,#Contract_Quantity_UOM_IDX#)
			</cfquery>
		</cfif>
		<!--- <cfreturn 'volSaved'/> --->
		<cfreturn this.getRfpProducts(a.contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="saveSelectedRfpProducts" hint="save" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="arrData" type="any" required="false" default="0" />

		<cfscript>
			try {
				var a = arguments;
				var arr = deserializeJSON(arguments.arrData);
				var form = structNew();
				var defWarehouseId = this.getDefaultWarehouse(a.contractId);
				for (i=1;i LTE ArrayLen(arr);i=i+1) {
					form['#arr[i].name#'] = arr[i].value;
				}
				var arrProds = ListToArray(Form.Product_List);
				var existingProds = ListToArray(Form.ExistingProductList);
				var existingProdsTmp = ListToArray(Form.ExistingProductList);

				// get list of existing items we need to delete -> not in Product_List means see ya.
				for (n=1;n LTE ArrayLen(arrProds);n=n+1) {
					existingProds.delete(arrProds[n]);
				}
				//Only insert New Products so clean up the "new" list
				for (n=1;n LTE ArrayLen(existingProdsTmp);n=n+1) {
					arrProds.delete(existingProdsTmp[n]);
				}

				insProds = listRemoveDuplicates( arrayToList( arrProds ) );
				delProds = ArrayToList(existingProds);
			}
			catch (any e) {
			    throw(message=e.message);
			}
		</cfscript>
		<cftry>
			<cfif len(trim(insProds)) GT 0>

				<cfquery name="qInsSelectedFixedContractProd" datasource="#application.datasource#">
					INSERT INTO Contract_Products(
							Contract_Main_ID,
							BSA_Foodservice_Items_Master_ID,
							Date_Created,
							Deleted,
							Product_Type_ID,
							Product_Process_Flag,
							Pricing_Level_ID,
							Is_Group,
							Product_Group_Level_ID,
							Dynamic_Static_Groups,
							Discounted_Item,
							Captured_From_Group,
							EZButton_On_Default,
							products_not_captured_flag,
							Include_In_Margin,
							Include_In_Volume,
							Item_Bracket_ID,
							Warehouse_Master_Id,
							Net_Weight,
							Gross_Weight
						)
					SELECT cm.Contract_Main_ID AS Contract_Main_ID,
								I.BSA_Foodservice_Items_Master_Id AS BSA_Foodservice_Items_Master_ID,
							GETDATE() AS Created_Date,
							0 AS Deleted,
							1 AS Product_Type_ID,
							0 AS Product_Process_Flag,
							1 AS Pricing_Level_ID,
							0 AS Is_Group,
							0 AS Product_Group_Level_ID,
							0 AS Dynamic_Static_Groups,
							1 AS Discounted_Item,
							0 AS Captured_From_Group,
							0 AS EZButton_On_Default,
							0 AS products_not_captured_flag,
							1 AS Include_In_Margin,
							1 AS Include_In_Volume,
							CASE WHEN I.SIGNATURE_SKU_INDICATOR = 'C' OR  I.SIGNATURE_SKU_INDICATOR = '1'  /* ---- ONLY ASSIGN Item_Bracket_ID if it is Stock item */
								THEN CM.Data_integration_Deals_ID
								ELSE 0 /* --- 3 is a 'Custom Items - Make & Ship' */
							END AS Item_Bracket_ID,
							#defWarehouseId# AS Warehouse_Master_Id,
							I.Net_Weight,
							I.Gross_Weight
					FROM Contract_Main C
					INNER JOIN Contract_Main_Aux_Data CM ON
						CM.Contract_Main_ID = C.Contract_Main_ID
					INNER JOIN BSA_Foodservice_Items_Master I ON
						I.BSA_Foodservice_Items_Master_Id in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
						WHERE 	C.Contract_Main_ID = #a.contractId# AND
								NOT EXISTS(SELECT BSA_Foodservice_Items_Master_ID FROM Contract_products CP
											WHERE CP.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_Id  AND
													CP.Contract_Main_Id = #a.contractId# AND
													CP.Deleted = 0 AND
													CP.Product_Type_ID = 1)
						ORDER BY 1, 4, 2
					</cfquery>

                <cfquery datasource="#application.datasource#">
                    IF Object_id( 'tempdb..##tmp_prior_product' ) IS NOT NULL
                        DROP TABLE ##tmp_prior_product
                </cfquery>

                <cfquery datasource="#application.datasource#">
                    SELECT    CP.BSA_Foodservice_Items_Master_ID
                            , PFC.Program_Fixed_Component_Name_ID
                            , PFPPD.Market_Price_Rate_Orig
                            , PFPPD.Unit_Of_Measure_ID
                            , PFPPD.Fixed_Price_Value
                      INTO  ##tmp_prior_product
                      FROM  Contract_Main CM
                                INNER JOIN Program_Fixed_Component PFC
                                ON         PFC.Program_ID = CM.Revision_Of_Contract_Main_ID
                                        AND PFC.Deleted = 0
                                INNER JOIN Contract_Products CP
                                ON         CP.Contract_Main_Id = CM.Revision_Of_Contract_Main_ID
                                        AND CP.BSA_Foodservice_Items_Master_ID IN ( #listQualify( insProds, "'" )# )
                                INNER JOIN Program_Fixed_Price_Product_Data PFPPD
                                ON         PFPPD.Contract_Products_ID = CP.Contract_Products_ID
                                        AND PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID
                                        AND PFPPD.Deleted = 0
                     WHERE  CM.Contract_Main_Id = #a.contractId#
                            AND CP.Deleted = 0
                            AND CP.Product_Type_ID = 1
                </cfquery>

				<cfquery name="qInsRFPFixedCompData" datasource="#application.datasource#">
                    INSERT INTO Program_Fixed_Price_Product_Data
                                (     Program_ID
                                    , Contract_Products_ID
                                    , Fixed_Price_Value
                                    , Unit_Of_Measure_ID
                                    , Program_Fixed_Component_ID
                                    , Market_Price_Rate_Orig
                                )
                        SELECT DISTINCT
                                  CM.Contract_Main_Id
                                , CP.Contract_Products_Id
                                , 0
                                , ISNULL(pv.Unit_Of_Measure_ID, 1) AS Unit_Of_Measure_ID
                                , PFC.Program_Fixed_Component_ID
                                , ISNULL(pv.Fixed_Price_Value, 0.00)
                        FROM  Contract_Main CM
                                INNER JOIN Program_Fixed_Component PFC
                                    ON PFC.Program_ID = CM.Contract_Main_Id AND PFC.Deleted = 0
                                INNER JOIN Contract_Products CP
                                    ON CP.Contract_Main_Id = CM.Contract_Main_Id
                                        AND CP.BSA_Foodservice_Items_Master_ID IN ( #listQualify( insProds, "'" )# )
                                LEFT JOIN  ##tmp_prior_product pv
                                    ON pv.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
                                        AND pv.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
                        WHERE   CM.Contract_Main_Id = #a.contractId#
                                AND CP.Deleted = 0
                                AND CP.Product_Type_ID = 1
				</cfquery>
			</cfif>

			<cfif len(trim(delProds)) GT 0>
				<cfquery name="qDeleteRFPprods" datasource="#application.datasource#">

					DELETE PFPPD
					FROM  Contract_Products CP
					INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
						PFPPD.Contract_Products_ID = CP.Contract_Products_ID
					WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
						CP.Product_Type_ID = 1 AND
						CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

					DELETE FROM Contract_Products WHERE Contract_Main_Id = #a.contractId# AND BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

				</cfquery>
			</cfif>
			<cfscript>
				// stuff
				this.updItemStockItemBracket(a.contractId,this.getStockItemBracket(a.contractId),insProds);
			</cfscript>

			<cfcatch>
				<cfdump var="#cfcatch#" output="c:\dump.log">
				<cfrethrow>
			</cfcatch>
		</cftry>

		<cfreturn 'done' />

	</cffunction>

	<cffunction name="QueryToArray" access="public" returntype="array" output="false" hint="This turns a query into an array of structures.">
	    <!--- Define arguments. --->
	    <cfargument name="Data" type="query" required="yes" />
	    <cfscript>
	        var LOCAL = StructNew();
	        LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
	        LOCAL.QueryArray = ArrayNew( 1 );
	        for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
	            LOCAL.Row = StructNew();
	            for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
	                LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
	                LOCAL.Row[ LOCAL.ColumnName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
	            }
	            ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
	        }
	        return( LOCAL.QueryArray );
	    </cfscript>
	</cffunction>


</cfcomponent>
