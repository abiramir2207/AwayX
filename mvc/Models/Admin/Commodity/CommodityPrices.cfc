<cfcomponent hint="Manage commodity price data">

	<cffunction name="getExchangeDetails" output="false" returntype="Query" >
		
		<CFQUERY NAME="qGetExchangeDetails" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT Exchange_Detail_Abrev,
					Exchange_Detail_Name,
					CET.Commodity_Exchange_Type_Description,
					CC.Category_Name,
					CC.Category_ID,
					Web_Service_URL,
					CED.Exchange_Detail_ID,
					CED.Update_Commodities,
					CED.Request_Header_List
			FROM [dbo].[Commodities_Exchange_Detail] CED
			INNER JOIN Commodities_Category CC ON
				CC.Category_ID = CED.Category_ID
			INNER JOIN  [dbo].[Commodity_Exchange_Type] CET ON
				CED.Commodity_Exchange_Type_ID = CET.Commodity_Exchange_Type_ID
			WHERE Active = 1
		</CFQUERY>
		
		<cfreturn qGetExchangeDetails>
	</cffunction>
	
	<cffunction name="getCommodityPrices" output="false" returntype="Query" >
		
		<CFQUERY NAME="qGetCommodityPrices" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT	
				Symbol,
				Comm_Last,
				Comm_High,
				Comm_Low,
				Comm_Datetime,
				Sub_Category_Name,
				Category_Name,
				Exchange_Detail_Name,
				CED.Exchange_Detail_Abrev
			FROM	Commodities_Symbol CS
			INNER JOIN Commodities C ON
				C.Commodities_Symbol_ID = cs.Commodities_Symbol_ID
		--	INNER JOIN Commodities_Report_Log L On l.Report_Date = C.Comm_Datetime
			LEFT JOIN Commodities_Sub_Category CSC ON
				C.Sub_Category_ID = CSC.Sub_Category_ID
			INNER JOIN Commodities_Category CC ON
				CC.Category_ID = C.Category_ID
			INNER JOIN Commodities_Exchange_Detail CED ON
				CED.Exchange_Detail_ID = CS.Exchange_Detail_ID
			ORDER BY C.Comm_Datetime
		</CFQUERY>
		
		<cfreturn qGetCommodityPrices>
	</cffunction>
	
	<cffunction name="saveSubCategory" output="false" returntype="Numeric" >
		<cfargument name="name" type="String" required="true" >
		<cfargument name="Category_ID" type="numeric" required="true" >
		
		<CFQUERY NAME="qCheckSubCat" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT CSC.Sub_Category_Id
			FROM Commodities_Sub_Category CSC
			WHERE CSC.Sub_Category_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" > AND
					CSC.Category_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Category_ID#" >
		</CFQUERY>
		<cfset subCatId = qCheckSubCat.Sub_Category_Id />
		<cfif qCheckSubCat.RecordCount EQ 0>
			<CFQUERY NAME="qInsertSubCategory" DATASOURCE="#APPLICATION.DATASOURCE#">
				INSERT Commodities_Sub_Category 
					(
						Sub_Category_Name,
						Category_Id
					)
				Values
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Category_ID#" >
					)
				SELECT SCOPE_IDENTITY()  AS 'Sub_Category_Id';
			</CFQUERY>
			<cfset subCatId = qInsertSubCategory.Sub_Category_Id />
		</cfif>
		
		<cfreturn subCatId />
	</cffunction>

	<cffunction name="getSubCategory" output="false" returntype="Numeric" >
		<cfargument name="name" type="String" required="true" >
		<cfargument name="Category_ID" type="numeric" required="true" >
		
		<CFQUERY NAME="qCheckSubCat" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT CSC.Sub_Category_Id
			FROM Commodities_Sub_Category CSC
			WHERE CSC.Sub_Category_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" > AND
					CSC.Category_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Category_ID#" >
		</CFQUERY>
		<cfset subCatId = qCheckSubCat.Sub_Category_Id />
		<cfscript>
			if(isnumeric(subCatId) == 0){
				subCatId = 0;
			}
		</cfscript>

		<cfreturn subCatId />
	</cffunction>
	
	<cffunction name="saveSymbol" output="false" returntype="Numeric" >
		<cfargument name="symbol" type="String" required="true" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="true" >
		
		<cfset local.Symbol = replace(arguments.symbol,',','',"all") />
		
		<CFQUERY NAME="qCheckSymbol" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT CS.Commodities_Symbol_ID
			FROM Commodities_Symbol CS
			WHERE CS.Symbol = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.Symbol#" > 
					AND CS.Exchange_Detail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Exchange_Detail_ID#" >
		</CFQUERY>
		<cfset symbolId = qCheckSymbol.Commodities_Symbol_ID />
		<cfif qCheckSymbol.RecordCount EQ 0>
			<CFQUERY NAME="qInsertSymbol" DATASOURCE="#APPLICATION.DATASOURCE#">
				INSERT Commodities_Symbol 
					(
						Symbol,
						Symbol_Description,
						Exchange_Detail_ID
					)
				Values
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.Symbol#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.Symbol#" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Exchange_Detail_ID#" >
					)
				SELECT SCOPE_IDENTITY()  AS 'Commodities_Symbol_ID';
			</CFQUERY>
			<cfset symbolId = qInsertSymbol.Commodities_Symbol_ID />
		</cfif>
		
		<cfreturn symbolId />
	</cffunction>

	<cffunction name="checkSymbol" output="false" returntype="Numeric" >
		<cfargument name="symbol" type="String" required="true" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="true" >
		
		<cfset local.Symbol = replace(arguments.symbol,',','',"all") />
		
		<CFQUERY NAME="qCheckSymbol" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT CS.Commodities_Symbol_ID
			FROM Commodities_Symbol CS
			WHERE CS.Symbol = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.Symbol#" > 
					AND CS.Exchange_Detail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Exchange_Detail_ID#" >
		</CFQUERY>
		<cfset symbolId = qCheckSymbol.Commodities_Symbol_ID />
		
		<cfreturn symbolId />
	</cffunction>
	
	<cffunction name="saveCommodity" output="false" returntype="Numeric" >
		<cfargument name="Commodities_Symbol_ID" type="numeric" required="true" >
		<cfargument name="Category_ID" type="numeric" required="true" >
		<cfargument name="Sub_Category_ID" type="numeric" required="true" >
		<cfargument name="Comm_High" type="numeric" required="true" >
		<cfargument name="Comm_Low" type="numeric" required="true" >
		<cfargument name="Comm_Last" type="numeric" required="true" >
		<cfargument name="Comm_Open" type="numeric" required="true" > <!--- rolling average --->
		<cfargument name="Comm_Datetime" type="date" required="true" >
		<cfargument name="Commodities_Report_Log_ID" type="numeric" required="true" >
		
		<CFQUERY NAME="qCheckCommodity" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT C.Commodities_ID
			FROM Commodities C
			WHERE C.Commodities_Symbol_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Symbol_ID#" >AND
					Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Category_ID#" >AND
					Sub_Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Sub_Category_ID#" > AND
					Comm_Datetime = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.Comm_Datetime#" > 
					
		</CFQUERY>
		<cfset CommoditiesID = qCheckCommodity.Commodities_ID />
		<cfif qCheckCommodity.RecordCount EQ 0>
			<CFQUERY NAME="qInsertCommodity" DATASOURCE="#APPLICATION.DATASOURCE#">
				INSERT Commodities 
					(
						Comm_High,
						Comm_Low,
						Comm_Last,
						Comm_Open,
						Category_ID,
						Sub_Category_ID,
						Commodities_Symbol_ID,
						Comm_Datetime,
						Commodities_Report_Log_ID
					)
				Values
					(
						<cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_High#" >,
						<cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_Low#" >,
						<cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_Last#" >,
						<cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_Open#"  >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Category_ID#" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Sub_Category_ID#" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Symbol_ID#" >,
						<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.Comm_Datetime#" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Report_Log_ID#" >
					)
				SELECT SCOPE_IDENTITY()  AS 'Commodities_ID';
			</CFQUERY>
			<cfset CommoditiesID = qInsertCommodity.Commodities_ID />
		<cfelse>
			<CFQUERY NAME="qInsertCommodity" DATASOURCE="#APPLICATION.DATASOURCE#">
				UPDATE Commodities SET
						Comm_High = <cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_High#" >,
						Comm_Low = <cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_Low#" >,
						Comm_Last = <cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_Last#" >,
						Comm_Open = <cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#arguments.Comm_Open#" >,
						Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Category_ID#" >,
						Sub_Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Sub_Category_ID#" >,
						Commodities_Symbol_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Symbol_ID#" >,
						Comm_Datetime = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.Comm_Datetime#" >,
						Comm_Update_Date = getdate(),
						Commodities_Report_Log_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Report_Log_ID#" >
				WHERE Commodities_ID = #CommoditiesID#
			</CFQUERY>
		</cfif>
		
		<cfreturn CommoditiesID />
	</cffunction>
	
	<cffunction name="getLastCommodityPrice" output="false" returntype="Struct" >
		<cfargument name="Commodities_Symbol_ID" type="numeric" required="true" >
		<cfargument name="Comm_Datetime" type="date" required="true" >
		<cfset var str = structnew() />
		<CFQUERY NAME="qgetLastCommodityPrice" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT top 1 Comm_High,
					Comm_Low,
					Comm_Last,
					Comm_Open
			FROM Commodities C
			WHERE C.Commodities_Symbol_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Symbol_ID#" >AND
					Comm_Datetime <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.Comm_Datetime#" >
			ORDER BY Comm_Datetime desc	
		</CFQUERY>
		<cfset str.price_range_high = qgetLastCommodityPrice.Comm_High />
		<cfset str.price_range_low = qgetLastCommodityPrice.Comm_Low />
		<cfset str.weighted_average = qgetLastCommodityPrice.Comm_Last />
		<cfset str.rolling_avg = qgetLastCommodityPrice.Comm_Open />
		<cfreturn str />
	</cffunction>
	
	<cffunction name="setCommoditiesReportLog" output="false" returntype="Numeric" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="true" >
		<cfargument name="Report_Date" type="date" required="true" >
		
		<cfset CommoditiesReportLogID = this.checkCommoditiesReportLog(arguments.Exchange_Detail_ID,arguments.Report_Date) />
		<cfif CommoditiesReportLogID EQ 0>
			<CFQUERY NAME="qInsertCommoditiesReportLog" DATASOURCE="#APPLICATION.DATASOURCE#">
				INSERT Commodities_Report_Log 
					(
						Exchange_Detail_ID,
						Report_Date
					)
				Values
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Exchange_Detail_ID#" >,
						<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.Report_Date#" >
					)
				SELECT SCOPE_IDENTITY()  AS 'Commodities_Report_Log_ID';
			</CFQUERY>
			<cfset CommoditiesReportLogID = qInsertCommoditiesReportLog.Commodities_Report_Log_ID />
			<cfset Processed = 0>
		</cfif>
		<cfreturn CommoditiesReportLogID />
	</cffunction>

	<cffunction name="setCommoditiesReportLogUpload" output="false" returntype="Numeric" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="true" >
		<cfargument name="Report_Date" type="date" required="true" >
		
			<CFQUERY NAME="qInsertCommoditiesReportLog" DATASOURCE="#APPLICATION.DATASOURCE#">
				INSERT Commodities_Report_Log 
					(
						Exchange_Detail_ID,
						Report_Date
					)
				Values
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Exchange_Detail_ID#" >,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.Report_Date#" >
					)
				SELECT SCOPE_IDENTITY()  AS 'Commodities_Report_Log_ID';
			</CFQUERY>
			<cfset CommoditiesReportLogID = qInsertCommoditiesReportLog.Commodities_Report_Log_ID />
			<cfset Processed = 0>
		<cfreturn CommoditiesReportLogID />
	</cffunction>
	
	<cffunction name="checkCommoditiesReportLog" output="false" returntype="Numeric" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="true" >
		<cfargument name="Report_Date" type="date" required="true" >

		<CFQUERY NAME="qCheckCommoditiesReportLog" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT CRL.Commodities_Report_Log_ID,Record_Count AS Records_In_Report
			FROM Commodities_Report_Log CRL
			WHERE CRL.Exchange_Detail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Exchange_Detail_ID#" >AND
				   CRL.Report_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.Report_Date#" >
		</CFQUERY>
		<cfset CommoditiesReportLogID = qCheckCommoditiesReportLog.Commodities_Report_Log_ID />
		<cfif qCheckCommoditiesReportLog.RecordCount EQ 0>
			<cfset CommoditiesReportLogID = 0>
		<cfelse><!--- Check if we have data in the report --->
			<cfif qCheckCommoditiesReportLog.Records_In_Report EQ 0><!--- delete log reord so we can run it again --->
				<CFQUERY NAME="qCheckCommoditiesReportLog" DATASOURCE="#APPLICATION.DATASOURCE#">
					DELETE FROM Commodities_Report_Log WHERE Commodities_Report_Log_ID = #qCheckCommoditiesReportLog.Commodities_Report_Log_ID#
				</CFQUERY>
				<cfset CommoditiesReportLogID = 0>
			</cfif>
		</cfif>
		
		<cfreturn CommoditiesReportLogID />
	</cffunction>
	
	<cffunction name="updCommoditiesReportLog" output="false" returntype="void" >
		<cfargument name="Commodities_Report_Log_ID" type="numeric" required="true" >
		<cfargument name="Report_Date" type="date" required="true" >
		<cfargument name="Record_Count" type="numeric" required="true" >


			<CFQUERY NAME="qUpdateCommoditiesReportLog" DATASOURCE="#APPLICATION.DATASOURCE#">
				UPDATE Commodities_Report_Log 
				SET Record_Count = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Record_Count#" >,
					Updated_Date = GetDate()
				WHERE Commodities_Report_Log_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Commodities_Report_Log_ID#" >
			</CFQUERY>

	</cffunction>


	<cffunction name="UpdateDataInt" output="false" >
		<cfargument name="DataIntId" type="numeric" required="true" >
		<cfargument name="Record_Count" type="numeric" default="0" required="no" >
		<cfargument name="Upd_Count" type="numeric" default="0" required="no" >
		<cfargument name="Ins_Count" type="numeric" default="0" required="no" >
		<cfargument name="History_Table_Name" type="string" default="" required="no" >

		<CFQUERY NAME="qUpdateDataInt" DATASOURCE="#APPLICATION.DATASOURCE#">
				UPDATE  Data_integration_Upload 
						SET	Process_Yes_No = 'YES',
							Count_Inserted = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Ins_Count#" >,
							Count_Updated = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Upd_Count#" >,
							Count_Deleted = 0,
							Count_Rejected = 0,
							Total_Count = 0,
							Amount_Checksum = 0,
							Quantity_Checksum = 0,
							<cfif arguments.History_Table_Name neq "">
							Archive_Tablename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.History_Table_Name#" >,
							</cfif>
							Total_Count_Received = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Record_Count#" >
				WHERE  Data_integration_Upload_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.DataIntId#" >
		</CFQUERY>
		<!--- CLEAR PREVIOUS INCOMPLETE FLAGS FROM EARLIER TODAY --->
		<CFQUERY NAME="qUpdateDataInt" DATASOURCE="#APPLICATION.DATASOURCE#">
				UPDATE D2 SET Deleted = 1
				FROM Data_integration_Upload D
				INNER JOIN Data_integration_Upload D2 ON
					D2.Run_Date = D.Run_Date AND
					D2.Intra_Id = D.Intra_ID AND 
					D2.Data_integration_Upload_ID != D.Data_integration_Upload_ID AND
					D2.Process_Yes_No = 'NO'
				WHERE D.Intra_Id = '2499' AND 
					D.Deleted = 0 AND
					D.Data_integration_Upload_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.DataIntId#"> AND
					D.Process_Yes_No = 'Yes'
		</CFQUERY>
	</cffunction>

	<cffunction name="InsertDataIntReports" output="false" returntype="numeric" >
		<cfargument name="Intra_Id" type="numeric" default="2490" required="no" >
		<cfargument name="X_Name" type="String" default="" required="no" > <!--- Shows up in DIV Description --->
		<cfargument name="Unique_File_Name" type="string" default="" required="no" > <!--- URL --->
		<cfargument name="commDate" type="date" default="#now()#" required="no" >

		<CFQUERY NAME="qInsertDataIntReports" DATASOURCE="#APPLICATION.DATASOURCE#">
				Insert INTO Data_integration_Upload (
							Run_Time,
							Run_Date,
							Intra_ID,
							Process_Yes_No,
							Count_Inserted,
							Count_Updated,
							Count_Deleted,
							Count_Rejected,
							Total_Count,
							X_Name,
							I_Name,
							Amount_Checksum,
							Quantity_Checksum,
							Flat_File_Name,
							Unique_File_Name,

							Total_Count_Received,
							Category,
							IsInbox
						)
				SELECT 
							'',   ----'#timeFormat(arguments.commDate,'short')#',		---Run_Time,
							'#dateFormat(arguments.commDate,'medium')#' ,		---Run_Date,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Intra_Id#" >,		---Intra_ID,
							'NO',		---Process_Yes_No,
							0,		---Count_Inserted,
							0,		---Count_Updated,
							0,		---Count_Deleted,
							0,		---Count_Rejected,
							0,		---Total_Count,
							'GET USDA PRICE #X_Name#',		---X_Name,
							'GET USDA PRICE #X_Name#',		---I_Name,
							0,		---Amount_Checksum,
							0,		---Quantity_Checksum,
							'Get USDA Report #X_Name#',		---Flat_File_Name,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Unique_File_Name#" >,---Unique_File_Name  URL,

							0,		---Total_Count_Received,
							'PRICING CONDITION',		---Category
							1		---IsInbox

					SELECT SCOPE_IDENTITY() AS DatintId
		</CFQUERY>

		<CFRETURN qInsertDataIntReports.DatintId />
	</cffunction>

	<cffunction name="InsertDataInt" output="false" returntype="numeric" >

		<CFQUERY NAME="qCheckDataInt" DATASOURCE="#APPLICATION.DATASOURCE#">
				SELECT Data_integration_Upload_id
				FROM Data_integration_Upload 
				WHERE Process_Yes_No = 'YES' AND Intra_Id = '2499'  and Deleted = 0
				and Cast(run_date as date) = cast(getdate() as date)
		</CFQUERY>
		<cfset s = 'NO'>
		<cfif qCheckDataInt.recordcount GT 0>
			<cfset s = 'YES'>
		</cfif>
		
		<CFQUERY NAME="qInsertDataInt" DATASOURCE="#APPLICATION.DATASOURCE#">
				Insert INTO Data_integration_Upload (
							Run_Time,
							Run_Date,
							Intra_ID,
							Process_Yes_No,
							Count_Inserted,
							Count_Updated,
							Count_Deleted,
							Count_Rejected,
							Total_Count,
							X_Name,
							I_Name,
							Amount_Checksum,
							Quantity_Checksum,
							Flat_File_Name,
							Unique_File_Name,

							Total_Count_Received,
							Category,
							IsInbox
						)
				SELECT 
							FORMAT ( GetDATE(), 'hh:mm:ss tt', 'en-US' )  ,		---Run_Time,
							FORMAT ( GetDATE(), 'd', 'en-US' ) ,		---Run_Date,
							'2499',		---Intra_ID,
							'#s#',		---Process_Yes_No,
							0,		---Count_Inserted,
							0,		---Count_Updated,
							0,		---Count_Deleted,
							0,		---Count_Rejected,
							0,		---Total_Count,
							'GET USDA PRICE',		---X_Name,
							'GET USDA PRICE',		---I_Name,
							0,		---Amount_Checksum,
							0,		---Quantity_Checksum,
							'Get USDA Commodity Prices Job',		---Flat_File_Name,
							'',---Unique_File_Name PUT URL HERE,

							0,		---Total_Count_Received,
							'PRICING CONDITION',		---Category
							1		---IsInbox

					SELECT SCOPE_IDENTITY() AS DatintId
		</CFQUERY>

		<CFRETURN qInsertDataInt.DatintId />
	</cffunction>

	<cffunction name="cleanDeletedData" output="false" >
		
		<CFQUERY NAME="qDeleteProgram_Formula_Pricing_Rule_Overage" DATASOURCE="#APPLICATION.DATASOURCE#">
			DELETE  PFPRO
			FROM Program_Formula_Pricing_Rule_Overage PFPRO
			LEFT JOIN Program_Formula_Pricing_Rules PFPR ON
				PFPR.Program_Formula_Pricing_Rule_ID = PFPRO.Program_Formula_Pricing_Rule_ID
			WHERE PFPRO.Deleted = 1 AND
				(DATEDIFF(DD,PFPR.Calc_Date,GetDAte()) > 120 OR 
					PFPR.Program_Formula_Pricing_Rule_ID IS NULL)
		</CFQUERY>
		
		<CFQUERY NAME="qDeleteProgram_Formula_Pricing_Rule_Comm_Data" DATASOURCE="#APPLICATION.DATASOURCE#">
			DELETE PFPRCD 
			FROM Program_Formula_Pricing_Rule_Comm_Data PFPRCD
			LEFT JOIN Program_Formula_Pricing_Rules PFPR ON
				PFPR.Program_Formula_Pricing_Rule_ID = PFPRCD.Program_Formula_Pricing_Rule_ID
			WHERE PFPRCD.Deleted = 1 AND
				(DATEDIFF(DD,PFPR.Calc_Date,GetDAte()) > 120 OR 
					PFPR.Program_Formula_Pricing_Rule_ID IS NULL)
		</CFQUERY>
		
		<CFQUERY NAME="qDeleteFormula_Pricing_Commodity_Overage" DATASOURCE="#APPLICATION.DATASOURCE#">
			DELETE FPCO 
			FROM Formula_Pricing_Commodity_Overage FPCO
			LEFT JOIN Program_Formula_Pricing_Rules PFPR ON
				PFPR.Program_Formula_Pricing_Rule_ID = FPCO.Program_Formula_Pricing_Rule_ID
			WHERE FPCO.Deleted = 1 AND
				(DATEDIFF(DD,PFPR.Calc_Date,GetDAte()) > 120 OR 
					PFPR.Program_Formula_Pricing_Rule_ID IS NULL)
		</CFQUERY>
	
	</cffunction>
	
	<cffunction name="parse_JK_PY001" output="false" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			if(trim(arrData[1]) == 'JK_PY001'){ //basic chcek for data
				dtReportDate = this.createDateFromString(replace(arrData[8],'AS OF ',''));
				if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					subCat = 'F.O.B. DOCK OR EQUIVALENT, ICED-PACKED';
					subCatId = this.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						if(LEFT(arrData[i],4) == 'ITEM' && bParse == 0){bParse = 1;}
						if(findNoCase(arrData[i],'weekly') != 0 && bWeekly == 0){bWeekly = 1;}
						if(LEFT(arrData[i],4) == '****' && bParse == 1){
							bParse = 0;
							break;
						}
						if(bParse == 1 && LEFT(arrData[i],4) != 'ITEM'){
							//writedump(var="#arrData[i]#", output="c:\dump.log");
							sSymbol = trim(Left(arrData[i],20));
							if(bWeekly == 1){
								decWtdAvg 	= trim(mid(arrData[i],56,9));
								hiLo 		= trim(mid(arrData[i],28,16));
							}
							else{
								decWtdAvg 	= trim(mid(arrData[i],59,9));
								hiLo 		= trim(mid(arrData[i],30,16));
							}
							decWtdAvg 	= replace(decWtdAvg,',','');
							hiLo 		= replace(hiLo,',','');

							price_range_high = listFirst(hiLo,'-');
							price_range_low = listLast(hiLo,'-');

							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									strLastPrice = structNew();
									strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									price_range_high = strLastPrice.price_range_high;
									price_range_low = strLastPrice.price_range_Low;
									decWtdAvg = strLastPrice.weighted_average;
								}
								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}
							}//if Isnumeric
						}//if Row > 11
					}//For Loop ArrayData
				}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','JK_PY001',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_NW_PY029" output="true" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			if(left(trim(arrData[1]),8) == 'NW_PY029'){ //basic check for data
			//writedump(var="#arrData#", output="c:\dump.log");
			//abort;
				for (i=5;i LTE 15;i=i+1) {
					if( LEFT(arrData[i],6) == 'AS OF '){
						dtReportDate = this.createDateFromString2(replace(arrData[i],'AS OF ',''));
						break;
					}
				}
				//dtReportDate = this.createDateFromString2(replace(arrData[8],'AS OF ',''));
				if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					subCat = 'DOMESTIC TRADING ';
					subCatId = this.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						if(LEFT(arrData[i],8) == 'DOMESTIC' && bParse ==0){bParse = 1;}
						if(findNoCase('weekly',arrData[i]) != 0 && bWeekly ==0){bWeekly = 1;}
						if(LEFT(arrData[i],2) == '1/' && bParse == 1){
							bParse = 0;
							break;
						}
						if(bParse == 1 && trim(LEFT(arrData[i],14)) != 'EXPORT TRADING' && trim(LEFT(arrData[i],16)) != 'DOMESTIC TRADING'){  /// was 25?
							sSymbol = trim(Left(arrData[i],34));
							if(bWeekly == 1){
								decWtdAvg = trim(mid(arrData[i],52,8));  //51,8  friday
								hiLo = trim(mid(arrData[i],35,16));
							}
							else{
								decWtdAvg = trim(mid(arrData[i],57,10));  //51,8  friday
								hiLo = trim(mid(arrData[i],35,16));
							}
							decWtdAvg = replace(decWtdAvg,',','');
							hiLo = replace(hiLo,',','');
								
							price_range_high = listFirst(hiLo,'-');
							price_range_low = listLast(hiLo,'-');

							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									strLastPrice = structNew();
									strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									price_range_high = strLastPrice.price_range_high;
									price_range_low = strLastPrice.price_range_Low;
									decWtdAvg = strLastPrice.weighted_average;
								}

								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}
							}//if Isnumeric
						}//if Row > 11
					}//For Loop ArrayData
				}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','NW_PY029',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_NW_LS440" output="true" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			iParse = 999;
			bWeekly = 0;
			subCat = '';
			subCatId = 0;
			sUpperSymbol = '';
			if(trim(arrData[1]) == 'NW_LS440'){ //basic chcek for data
			//writedump(var="#arrData#", output="c:\dump.log");
				dtReportDate = this.createDateFromString(mid(arrData[2],24,13));
				//writeoutput('<br>::#this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate)#::');
				if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						if(right(arrData[i],5) == '-----' && left(arrData[i],5) != '-----'){
							subCat = Trim(Replace(arrData[i],'-','','all'));
							subCatId = this.saveSubCategory(subCat,Category_ID);
							iParse = i + 2;
						}
						if(left(arrData[i],5) == '-----'){
							iParse = i + 7;
						}
						if(left(arrData[i],5) == 'ABCDE'){
							iParse = 9999;
							break;
						}
						if(i >= iparse){
							sSymbol = Left(arrData[i],34);
							tmpSymbol = ListFirst(sSymbol);
							if(Compare(tmpSymbol,ucase(tmpSymbol)) == 0){
								sUpperSymbol = trim(tmpSymbol);
								sFullSymbol = trim(sSymbol);
							}
							if(Left(sSymbol,1) == ' '){
								if(ListLen(sSymbol,',') == 1){
									if(trim(ListLast(sFullSymbol)) == 'domestic' && trim(sSymbol) == 'export'){
										sSymbol = sUpperSymbol & ' ' & trim(sSymbol);
									}
									else{
										sSymbol = sFullSymbol & ' ' & trim(sSymbol);
									}
									
								}
								else{
									sSymbol = sUpperSymbol & ' ' & trim(sSymbol);
								}
							}
							else{
								sSymbol = trim(sSymbol);
							}
							sSymbol = reReplace(sSymbol, "[ ]{2,}", " ", "all");// trim spaces in middle of string
							decWtdAvg = trim(mid(arrData[i],61,8));  //51,8  friday
							hiLo = trim(mid(arrData[i],42,16));

							decWtdAvg = replace(decWtdAvg,',','');
							hiLo = replace(hiLo,',','');
								
							price_range_high = listFirst(hiLo,'-');
							price_range_low = listLast(hiLo,'-');

							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								//writedump(var="#sSymbol#::#decWtdAvg#::#hiLo#::#price_range_high#::#price_range_low#", output="c:\dump.log");
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									strLastPrice = structNew();
									strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									price_range_high = strLastPrice.price_range_high;
									price_range_low = strLastPrice.price_range_Low;
									decWtdAvg = strLastPrice.weighted_average;
								}

								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}//if Isnumeric
							}// if Symbol
						}//if Parse
					}//For Loop ArrayData
				}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','NW_LS440',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_NW_LS442" output="true" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			iParse = 999;
			bWeekly = 0;
			subCat = '';
			subCatId = 0;
			sUpperSymbol = '';
			if(left(trim(arrData[1]),8) == 'NW_LS442'){ //basic chcek for data
				dtReportDate = this.createDateFromString(mid(arrData[2],24,13));
				//writeoutput('<br>::#this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate)#::');
				if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						if(i == 5){
							subCat = 'TALLOW, GREASE, AND LARD';
							subCatId = this.saveSubCategory(subCat,Category_ID);
							iParse = i + 1;
						}
						if(left(arrData[i],5) == '-----'){
							iParse = 9999;
							break;
						}
						if(i >= iparse){
							sSymbol = Left(arrData[i],30);
							tmpSymbol = ListFirst(sSymbol);
							if(Compare(tmpSymbol,ucase(tmpSymbol)) == 0){
								sUpperSymbol = trim(tmpSymbol);
								sFullSymbol = trim(sSymbol);
							}
							if(Left(sSymbol,1) == ' '){
								sSymbol = sFullSymbol & ' ' & trim(sSymbol);
							}
							else{
								sSymbol = trim(sSymbol);
							}
							sSymbol = reReplace(sSymbol, "[ ]{2,}", " ", "all");// trim spaces in middle of string
							decWtdAvg = trim(mid(arrData[i],66,9));  //51,8  friday
							hiLo = trim(mid(arrData[i],46,17));

							decWtdAvg = replace(decWtdAvg,',','');
							hiLo = replace(hiLo,',','');
								
							price_range_high = listFirst(hiLo,'-');
							price_range_low = listLast(hiLo,'-');
							//writedump(var="#arrData[i]#", output="c:\dump.log");
							//writedump(var="#sSymbol#::#decWtdAvg#::#hiLo#::#price_range_high#::#price_range_low#", output="c:\dump.log");
							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									strLastPrice = structNew();
									strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									price_range_high = strLastPrice.price_range_high;
									price_range_low = strLastPrice.price_range_Low;
									decWtdAvg = strLastPrice.weighted_average;
								}

								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}//if Isnumeric
							}// if Symbol
						}//if Parse
					}//For Loop ArrayData
				}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','NW_LS442',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_WA_DA300" output="false" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			sCom = '';
			//writedump(var="#arrData#", output="c:\dump.log"); 
			if(trim(left(arrData[1],21)) == 'Announcement of Class'){ //basic chcek for data
				aDate = listToArray(trim(arrdata[1]),' ');
				writedump(var="#adate#", output="c:\dump.log"); 
				sYear = adate[arraylen(aDate)];
				sMonth = adate[arraylen(aDate)-1];
				sDate = sMonth & ' 1, ' & sYear;
				dtReportDate = this.createDateFromString(sDate);
				writedump(var="#dtReportDate#", output="c:\dump.log"); 
				//firstOfReportMonth = createDate(year(dtReportDate), month(dtReportDate), 1);
				//dtReportDate = dateAdd("d", -1, firstOfReportMonth);//last day of previous month
				if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					subCat = 'Milk';
					subCatId = this.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						if(sCom == 'Dry Whey'){
							break;
						}
						if(FindNoCase(':',trim(arrData[i])) != 0 && sCom != 'Product Price Averages'){
							sCom = trim(ListFirst(arrData[i],':'));
						}
						//sCom = trim(ListFirst(arrData[i],':'));
						//writedump(var="#sCom#", output="c:\dump.log"); 
						if(sCom == 'Class III Price' || sCom == 'Class III Skim Milk Price' || sCom == 'Product Price Averages'){
							//writedump(var="#arrData[i]#", output="c:\dump.log");     Nonfat Dry Milk
							//writedump(var="#arrData[i]#", output="c:\dump.log"); 
							sSymbol = sCom;
							if(sCom == 'Product Price Averages'){
								sSymbol = trim(Left(arrData[i],22));
								if(sSymbol != 'Butter' && sSymbol != 'Nonfat Dry Milk'){
									continue;
								}
							}
							
							decWtdAvg 	= trim(mid(arrData[i],40,11));
							hiLo 		= decWtdAvg;

							decWtdAvg 	= replace(decWtdAvg,',','');
							hiLo 		= replace(hiLo,',','');

							price_range_high = 0;
							price_range_low = 0;
							//writedump(var="#sSymbol# :: #decWtdAvg#", output="c:\dump.log"); 
							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									continue;
									// strLastPrice = structNew();
									// strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									// price_range_high = strLastPrice.price_range_high;
									// price_range_low = strLastPrice.price_range_Low;
									// decWtdAvg = strLastPrice.weighted_average;
								}
								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}
							}//if Isnumeric
						}//if Row > 11
					}//For Loop ArrayData
				}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','WA_DA300',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_MD_DA997" output="false" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			sCom = '';
			arrComData = [];
			///writedump(var="#arrData#", output="c:\dump.log"); 
			if(trim(arrData[1]) == 'MD_DA997'){ //basic chcek for data
				dtReportDate = this.createDateFromString(replace(ListLast(arrData[3],'-'),'Released on ',''));
				if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					subCat = 'Products';
					subCatId = this.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						if(sCom == 'Dry Whey'){
							break;
						}
						if(FindNoCase(':',trim(arrData[i])) != 0){
							sCom = trim(ListFirst(arrData[i],':'));
						}
						//sCom = trim(ListFirst(arrData[i],':'));
						//writedump(var="#sCom#", output="c:\dump.log"); 
						if(sCom == '40 POUND BLOCKS' || sCom == 'BARRELS' || sCom == 'GRADE AA'){
							if(sCom == '40 POUND BLOCKS' || sCom == 'BARRELS'){
								sCom = 'CHEESE ' & sCom;
							}
							else if(sCom == 'GRADE AA'){
								sCom = 'BUTTER ' & sCom;
							}
							arrComData = listToArray(arrData[i],':');
							//writedump(var="#arrData[i]#", output="c:\dump.log");     Nonfat Dry Milk
							//writedump(var="#arrData[i]#", output="c:\dump.log"); 
							sSymbol = sCom;
							
							decWtdAvg 	= trim(arrComData[2]);
							decWtdAvg 	= replace(decWtdAvg,',','');
							decWtdAvg 	= replace(decWtdAvg,'$','');

							price_range_high = 0;
							price_range_low = 0;
							//writedump(var="#sSymbol# :: #decWtdAvg#", output="c:\dump.log"); 
							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									continue;
									// strLastPrice = structNew();
									// strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									// price_range_high = strLastPrice.price_range_high;
									// price_range_low = strLastPrice.price_range_Low;
									// decWtdAvg = strLastPrice.weighted_average;
								}
								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}
							}//if Isnumeric
						}//if Row > 11
					}//For Loop ArrayData
				}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','MD_DA997',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_MD_DA599" output="false" >
		<cfargument name="arrData" type="array" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			sCom = '';
			arrComData = [];
			//writedump(var="#arrData#", output="c:\dump.log"); 
			if(trim(arrData[1]) == 'MD_DA599'){ //basic chcek for data
				dtReportDate = this.createDateFromString(replace(ListLast(arrData[3],'-'),'Released on ',''));
				//if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we can't process past dates
					Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
					subCat = 'Products';
					subCatId = this.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID
					for (i=1;i LTE ArrayLen(arrData);i=i+1) {
						x=0;
						sCom = trim(arrData[i]);
						if(sCom == 'BUTTERMILK POWDER'){
							sCom = 'BUTTERMILK POWDER WEST';
							x = i + 2;
							if(arrData[x] contains 'MOSTLY' == FALSE){
								x = i + 3;
							}
						}
						else if(sCom == 'WHEY POWDER'){
							sCom = 'WHEY POWDER CENTRAL';
							x = i + 1;
						}
						else if(sCom == 'LACTOSE'){
							sCom = 'LACTOSE CENTRAL AND WEST ';
							x = i + 1;
						}
						else if(sCom == 'WHEY PROTEIN CONCENTRATE 34%'){
							sCom = 'WHEY PROTEIN CONCENTRATE 34% CENTRAL AND WEST';
							x = i + 1;
						}
						else{
							continue;
						}
						//sCom = trim(ListFirst(arrData[i],':'));
						//writedump(var="#sCom#", output="c:\dump.log"); 
						if(sCom != '' && arrData[x] contains 'MOSTLY'){
							//writedump(var="#arrData[x]#", output="c:\dump.log"); 
							aComData = listLast(arrData[x],'MOSTLY');
							arrComData = listToArray(aComData,'-');
							//writedump(var="#aComData#", output="c:\dump.log"); 
							//writedump(var="#arrComData#", output="c:\dump.log"); 
							p1 = trim(arrComData[1]);
							p2 = trim(arrComData[2]);

							p1 	= replace(p1,',','');
							p1 	= replace(p1,'$','');
							p2 	= replace(p2,',','');
							p2 	= replace(p2,'$','');

							sSymbol = sCom;
							
							decWtdAvg 	= (p1 + P2)/2;

							price_range_high = 0;
							price_range_low = 0;
							//writedump(var="#sSymbol# :: #decWtdAvg#", output="c:\dump.log"); 
							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									continue;
									// strLastPrice = structNew();
									// strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									// price_range_high = strLastPrice.price_range_high;
									// price_range_low = strLastPrice.price_range_Low;
									// decWtdAvg = strLastPrice.weighted_average;
								}
								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		0,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}
							}//if Isnumeric
						}//if Row > 11
					}//For Loop ArrayData
				//}// IF it hasn't run
			}
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','MD_DA997',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_2991" output="true" >
		<cfargument name="sData" type="string" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfargument name="dDate" type="date" required="yes">
			
		<cfscript>
			var dtReportDate = now();
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			sCom = '';
			
			///writedump(var="#arguments.sData#", output="c:\dump.log"); 
			stCommodity = deserializeJson(arguments.sData);
			if(stCommodity.stats['returnedRows:']){ // if there is data returned
				if(ArrayLen(stCommodity.results)){ // if there is data returned
					for (i=1; i <= ArrayLen(stCommodity.results);i=i+1){ 
						thisCommodity = stCommodity.results[i];
						if(thisCommodity.keyExists("class_3_Price") && thisCommodity.keyExists("week_ending_date")){
							/*For April 2021, we received week_ending_date = 5/1/2021.
							 We will subtract 7 days to handle for this scenario*/
							dtReportDate = dateAdd("d", -7, thisCommodity.week_ending_date); 
							dtReportDate = createDate(year(dtReportDate), month(dtReportDate), 1); // Find first day of the month
							/********************
							Array will include data for lot of months.
							We only need the first array element of results to get the latest month data. We will take 2 months just in case we missed one.
							We will also get data from prior month, if a prior month was passed in to the function
							********************/
							if(i <= 2 || (year(dtReportDate) == year(arguments.dDate) && month(dtReportDate) == month(arguments.dDate))){
								if(this.checkCommoditiesReportLog(Exchange_Detail_ID,dtReportDate) == 0){ // these Reports are text so we cannot process past dates
									Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
									subCat = 'Milk';
									subCatId = this.saveSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID

									sSymbol = 'Class III Price';
									symbolId = this.saveSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID

									price_range_high = 0;
									price_range_low = 0;
									decWtdAvg 	= trim(thisCommodity.class_3_Price);
									decWtdAvg 	= replace(decWtdAvg,',','');
									decWtdAvg 	= replace(decWtdAvg,'$','');

									if(isNumeric(decWtdAvg) && decWtdAvg != 0){
										commoditiesId = this.saveCommodity(symbolId,
																			Category_ID,
																			subCatId,
																			price_range_high,
																			price_range_low,
																			decWtdAvg,
																			0,
																			dtReportDate,
																			Commodities_Report_Log_ID);
										counter ++;
									} // if(isNumeric
								}// if(this.checkCommoditiesReportLog
							} // if(i <= 2 || (year(dtReportDate) == year(arguments.dDate) && month(dtReportDate) == month(arguments.dDate)))
						} // if(thisCommodity.keyExists("class_3_Price"))
					} // for loop
				} // if(ArrayLen(stCommodity.results))
			} // if(stCommodity.stats.returnedRows)
			
			If(counter > 0){
				ReportDataIntID = this.InsertDataIntReports('2490','2991',sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
			
			return counter;
		</cfscript>
	</cffunction>
            
    <cffunction name="parse_urner_barry" output="true" >
		<cfargument name="sData" type="string" required="yes" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Exchange_Detail_Name" type="string" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes">
		<cfargument name="sUrl" type="string" required="yes">
		<cfargument name="dDate" type="date" required="yes">
        
        <CFQUERY NAME="qDropTempTable" DATASOURCE="#APPLICATION.DATASOURCE#">
            DROP TABLE IF EXISTS ##Tmp_Commodity_Data
        </CFQUERY>
        <CFQUERY NAME="qCreateTempTable" DATASOURCE="#APPLICATION.DATASOURCE#">
			CREATE TABLE ##Tmp_Commodity_Data (
                Comm_Datetime DATE,
                Category varchar(10),
                Sub_Category_Name varchar(200),
                Symbol varchar(10),
                Symbol_Description varchar(200),
                quoteDate varchar(100),
                Comm_High varchar(100),
                Comm_Low varchar(100),
                Comm_Last varchar(100),
                Comm_Open varchar(100)
            )
		</CFQUERY>
		<cfscript>
			var dtReportDate = arguments.dDate;
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			sCom = '';
			
			///writedump(var="#arguments.sData#", output="c:\dump.log"); 
			stCommodity = deserializeJson(arguments.sData);
            if(ArrayLen(stCommodity.items)){ // if there is data returned
            
                Commodities_Report_Log_ID = this.setCommoditiesReportLog(Exchange_Detail_ID,dtReportDate);
            
                /*************************************************************************
                Loop per Commodity
                **************************************************************************/
                //for (i=1; i <= ArrayLen(stCommodity.items);i=i+1){ 
                for (i=1; i <= ArrayLen(stCommodity.items);i=i+1){ 
                    thisCommodity = stCommodity.items[i];
                    cat = thisCommodity.cat;
                    subCat = thisCommodity.subCategory;
                    sSymbol = thisCommodity.comcode;
                    sSymbolDesc = thisCommodity.comcode & ':' & thisCommodity.description;
                        
                    if(sSymbol != '' && Category_ID > 0 && Exchange_Detail_ID > 0){
            
                        for (j=1; j <= ArrayLen(thisCommodity.marketData);j=j+1){
                                                                          
                            thisMarketData = thisCommodity.marketData[j];
                                                                          
                            if(thisMarketData.keyExists("high") || thisMarketData.keyExists("low") || thisMarketData.keyExists("sAvg") || thisMarketData.keyExists("wtdAvg")) {
                                            
                                price_range_high = "";
                                price_range_low = "";
                                sAvg = "";
                                wtdAvg = "";
                                                                          
                                if(thisMarketData.keyExists("high")) {
                                    price_range_high 	  = trim(thisMarketData.high);
                                }
                                if(thisMarketData.keyExists("low")) {
                                    price_range_low 	  = trim(thisMarketData.low);
                                }
                                if(thisMarketData.keyExists("sAvg")) {
                                    sAvg 	  = trim(thisMarketData.sAvg);
                                }
                                if(thisMarketData.keyExists("wtdAvg")) {
                                    wtdAvg 	  = trim(thisMarketData.wtdAvg);
                                }
                                                                          
                                qInsert = queryExecute( "INSERT INTO ##Tmp_Commodity_Data(Comm_Datetime, Category, Sub_Category_Name, Symbol, Symbol_Description, Comm_High, Comm_Low, Comm_Last, Comm_Open, quoteDate) values('#dtReportDate#', '#cat#', '#subCat#', '#sSymbol#', '#sSymbolDesc#', '#price_range_high#', '#price_range_low#', '#sAvg#', '#wtdAvg#', '#thisMarketData.quoteDate#')", {} ,{ datasource: application.datasource } );

                                
                            } // if keyExists
                        } // for loop j
                    } // if(sSymbol != '' && subCatId > 0  && Category_ID > 0 && Exchange_Detail_ID > 0)                           

                } // for loop i
            
                // call SP here
                if(Exchange_Detail_ID > 0 && Category_ID > 0 && Commodities_Report_Log_ID > 0){
                    qSPCall = queryExecute( "EXEC Commodity_Load #Exchange_Detail_ID#, #Category_ID#, #Commodities_Report_Log_ID#, '##Tmp_Commodity_Data'", {} ,{ datasource: application.datasource } );
                    counter = qSPCall.Update_Count;
                }

            } // if(ArrayLen(stCommodity.items))
			
                
			// Update DIV
				ReportDataIntID = this.InsertDataIntReports('2490',arguments.Exchange_Detail_Name,sUrl,dtReportDate); 
				this.UpdateDataInt(ReportDataIntID,counter,0,0,"History_CF_UrnerBarry_Data");
                
                //Get Run date and run time from DIV table to poplate history table
                qDIV = queryExecute( " SELECT RUN_DATE + ' ' + RUN_TIME as Process_Date FROM Data_integration_Upload WHERE Data_integration_Upload_ID = #ReportDataIntID# ", {} ,{ datasource: application.datasource } );
            
                //Delete old entries from history table
                qInsert = queryExecute( "DELETE FROM History_CF_UrnerBarry_Data WHERE Created_Date < DATEADD(DAY, -120, GETDATE())", {} ,{ datasource: application.datasource } );
            
                //Insert into history table
                qInsert = queryExecute( "INSERT INTO History_CF_UrnerBarry_Data(Commodity_Date, cat, subCategory, comcode, comdesc, com_high, com_low, sAvg, wtdAvg, quoteDate, Process_Date, Data_integration_Upload_ID) SELECT Comm_Datetime, Category, Sub_Category_Name, Symbol, Symbol_Description, Comm_High, Comm_Low, Comm_Last, Comm_Open, quoteDate, '#qDIV.Process_Date#', '#ReportDataIntID#' FROM ##Tmp_Commodity_Data", {} ,{ datasource: application.datasource } );
            
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			
			
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="parse_upload" output="false" >
		<cfargument name="arrData" type="array" required="yes" >
		<!--- <cfargument name="Exchange_Detail_ID" type="numeric" required="yes">
		<cfargument name="Category_ID" type="numeric" required="yes"> --->
		<cfscript>
		try{
			var dtReportDate = now();
			var Exchange_Detail_ID = 0;
			var Category_ID = 0;
			counter = 0;
			bParse = 0;
			bWeekly = 0;
			sCom = '';
			arrComData = [];
			//writedump(var="#arrData#", output="c:\dump.log"); 
				Commodities_Report_Log_ID = this.setCommoditiesReportLogUpload(Exchange_Detail_ID,now()); 
					for (i=2;i LTE ArrayLen(arrData);i=i+1) {
						//added code to remove commas from elements
						quoteChar = """";
						quoteMatch = reFind('(\#quoteChar#.*?\#quoteChar#)|([0-9\.\/\[[A-Za-z]*\])', arrData[i], 1, true, 'all' );
						for (n=1;n LTE arrayLen(quoteMatch);n=(n+1))
						{
							if(quoteMatch[n].len[1]){
								arrData[i] = replace(arrData[i], quoteMatch[n].match[1], replace(quoteMatch[n].match[1], ',','', 'all'));
							}
						}
						//writedump(var="#arrData[i]#", output="c:\dump.log"); 
						arrComData = listToArray(arrData[i],',');
						if(arrayLen(arrComData) == 0){
							break;
						}
						sCom = trim(arrComData[1]);
						Exchange_Detail_ID = checkExchange(trim(arrComData[10]));
						Category_ID = checkCat(trim(arrComData[8]),Exchange_Detail_ID);
						subCat = trim(arrComData[9]);
						subCatId = this.getSubCategory(subCat,Category_ID);//If it already exists, it returns the ID  else Insert and then Return ID

						if(sCom == 'Palm Oil'){
							subCat = 'Oil';
							subCatId = this.saveSubCategory(subCat,Category_ID);
						}
						sDate = trim(arrComData[7]);
						dtReportDate = CreateDateTime(ListLast(sDate,'/'),ListFirst(sDate,'/'),ListGetAt(sDate,2,'/'),DatePart('h', now()),DatePart('n', now()),DatePart('s', now()));
			
						//sCom = trim(ListFirst(arrData[i],':'));
						if(sCom != '' && subCatId > 0  && Category_ID > 0 && Exchange_Detail_ID > 0){
							//arrComData = listToArray(arrData[i],':');
							//writedump(var="#arrData[i]#", output="c:\dump.log");
							sSymbol = sCom;
							
							decWtdAvg 	= trim(arrComData[3]);
							decWtdAvg 	= replace(decWtdAvg,',','');
							decWtdAvg 	= replace(decWtdAvg,'$','');

							// price_range_high = 0;
							// price_range_low = 0;

							price_range_high 	= trim(arrComData[4]);
							price_range_high 	= replace(price_range_high,',','');
							price_range_high 	= replace(price_range_high,'$','');

							price_range_low 	= trim(arrComData[5]);
							price_range_low 	= replace(price_range_low,',','');
							price_range_low 	= replace(price_range_low,'$','');

							commOpen 	= trim(arrComData[6]);
							commOpen 	= replace(commOpen,',','');
							commOpen 	= replace(commOpen,'$','');

							//writedump(var="#sSymbol# :: #decWtdAvg#", output="c:\dump.log"); 
							if(trim(sSymbol) != ''){   // isNumeric(decWtdAvg)
								// insert comm and price
								symbolId = this.checkSymbol(sSymbol,Exchange_Detail_ID);//If it already exists, it returns the ID  else Insert and then Return ID
								if(!isNumeric(decWtdAvg)){
									continue;
									// strLastPrice = structNew();
									// strLastPrice = this.getLastCommodityPrice(symbolId,dtReportDate);
									// price_range_high = strLastPrice.price_range_high;
									// price_range_low = strLastPrice.price_range_Low;
									// decWtdAvg = strLastPrice.weighted_average;
								}
								if(!isNumeric(price_range_high)){
									price_range_high = decWtdAvg;
								}
								if(!isNumeric(price_range_low)){
									price_range_low = decWtdAvg;
								}
								if(isNumeric(decWtdAvg) && decWtdAvg != 0){
									commoditiesId = this.saveCommodity(symbolId,
																		Category_ID,
																		subCatId,
																		price_range_high,
																		price_range_low,
																		decWtdAvg,
																		commOpen,
																		dtReportDate,
																		Commodities_Report_Log_ID);
									counter ++;
								}
							}//if Isnumeric
						}//if Row > 11
					}//For Loop ArrayData
			If(counter > 0){
				//ReportDataIntID = this.InsertDataIntReports('2490','MD_DA997',sUrl,dtReportDate); 
				//this.UpdateDataInt(ReportDataIntID,counter);
				this.updCommoditiesReportLog(Commodities_Report_Log_ID,dtReportDate,counter);
			}
		}
		catch (any e) {
			//writedump(var=e,output='c:\dump.log');
			rethrow; 
		}
			return counter;
		</cfscript>
	</cffunction>

	<cffunction name="uploadCommodityData" output="false" returntype="string" access="remote">
		<cfargument name="data" type="any" required="true" >
		<cfscript>
			var jsonData = '';
			var a = arguments;
			var b64 = ListLast(a.data);
			var s = ToString( ToBinary( b64 ) );
			var arrData = listToArray(s,"#chr(13)##chr(10)#",false);
			//writedump(var=arrData,output='c:\dump.log');
			var sRetMessage = this.parse_upload(arrData) & ' rows processed';
			//writedump(var=s,output='c:\dump.log');
			return sRetMessage;
		</cfscript>

	</cffunction>

	<cffunction name="checkCat" output="false" returntype="Numeric" >
		<cfargument name="cat" type="String" required="true" >
		<cfargument name="Exchange_Detail_ID" type="numeric" required="true" >
		
		<CFQUERY NAME="qCheckCat" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT 
					CC.Category_ID
			FROM [dbo].[Commodities_Exchange_Detail] CED
			INNER JOIN Commodities_Category CC ON
				CC.Category_ID = CED.Category_ID
			INNER JOIN  [dbo].[Commodity_Exchange_Type] CET ON
				CED.Commodity_Exchange_Type_ID = CET.Commodity_Exchange_Type_ID
			WHERE CED.Exchange_Detail_ID = '#arguments.Exchange_Detail_ID#'
				AND CC.Category_Name = '#trim(arguments.cat)#'
		</CFQUERY>
		<cfset Category_ID = qCheckCat.Category_ID />
		<cfscript>
			if(isnumeric(Category_ID) == 0){
				Category_ID = 0;
			}
		</cfscript>
		
		<cfreturn Category_ID />
	</cffunction>

	<cffunction name="checkExchange" output="false" returntype="Numeric" >
		<cfargument name="exchDet" type="String" required="true" >
		
		
		<CFQUERY NAME="qGetExchangeDetails" DATASOURCE="#APPLICATION.DATASOURCE#">
			SELECT 
					CED.Exchange_Detail_ID
			FROM [dbo].[Commodities_Exchange_Detail] CED
			WHERE Exchange_Detail_Abrev = '#trim(arguments.exchDet)#'
		</CFQUERY>
		<cfset Exchange_Detail_ID = qGetExchangeDetails.Exchange_Detail_ID />
		<cfscript>
			if(isnumeric(Exchange_Detail_ID) == 0){
				Exchange_Detail_ID = 0;
			}
		</cfscript>
		
		<cfreturn Exchange_Detail_ID />
	</cffunction>

	<cffunction name="createDateFromString" output="false" returntype="date" >
		<cfargument name="sDate" type="string" required="yes" >
		<cfscript>
			//sDate = 'JANUARY 31, 2019';
			aDate = listToArray(trim(sDate)," ",true);
			iMonth = 0;
			iDay = trim(replace(aDate[2],',',''));
			iYear = trim(aDate[3]);
			WriteDump(aDate);

			for (i=1;i LTE 12;i=i+1){
				if(LEFT(MonthAsString(i),3) == Left(aDate[1],3)){
					iMonth = i;
					break;
				}
			}
			cfDate=CreateDateTime(iYear,iMonth,iDay,0,0,0);
			//dtDate=CreateODBCDate(cfDate);
    		return cfDate;
		</cfscript>
	</cffunction>

	<cffunction name="createDateFromString2" output="false" returntype="date" >
		<cfargument name="sDate" type="string" required="yes" >
		<cfscript>
			//sDate = 'JANUARY 31, 2019';
			aDate = listToArray(sDate," ",true);
			iMonth = 0;
			iDay = trim(replace(aDate[1],',',''));
			iYear = trim(aDate[3]);
			WriteDump(aDate);

			for (i=1;i LTE 12;i=i+1){
				if(LEFT(MonthAsString(i),3) == Left(aDate[2],3)){
					iMonth = i;
					break;
				}
			}
			cfDate=CreateDateTime(iYear,iMonth,iDay,0,0,0);
			//dtDate=CreateODBCDate(cfDate);
    		return cfDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="calcMovingAverage" output="false" >
		
	
	</cffunction>

</cfcomponent>