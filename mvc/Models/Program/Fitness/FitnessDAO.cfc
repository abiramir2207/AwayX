<cfcomponent displayname="FitnessDAO" extends="mvc.Models.SettingsService">
	
	<cffunction name="getFitnessHeaderData" output="false" access="public" returntype="Query" >
		<cfargument name="h" type="any" required="false" default="#CreateObject("component","mvc.Models.Program.Fitness.vos.FitnessSearchDef")#" >

		<cfscript>
			//set local variables
			var a = arguments;
		</cfscript>
		<cfquery name="qGetFitnessSearchData" datasource="#application.datasource#">
			Select 'Hello'
	    </cfquery>
	    <cfreturn qGetFitnessSearchData />

	</cffunction>
	
	<cffunction name="getFitnessDetailData" output="false" access="public" returntype="Query" >
		<cfargument name="Fiscal_Year_ID" type="any" required="true">
		<cfargument name="Payment_Cycle_ID" type="any" required="true">
		<cfargument name="Period" type="any" required="true">
		<cfargument name="cust" type="any" required="true">
		<cfargument name="Contract_main_Id" type="any" required="true">
		<cfargument name="Component_Id" type="any" required="true">
		<cfargument name="Discount_Type_Id" type="any" required="true">
		<cfargument name="Fiscal_Year" type="any" required="true">
		<cfscript>
			//set local variables
			var a = arguments;
			var qDates = '';
			
			//Get dates
			switch(a.Payment_Cycle_ID) {
			    case "1":  case "2":  case "6":  case "7":  case "8":	//Annual
			    	// WriteLog(file="mws.log", text="ANNUAL");
			         qDates= This.getDatesAnnual(a.Contract_Main_ID,a.Fiscal_Year);
			         break;
			    case "4": case "11":	//Quarterly
			    	//WriteLog(file="mws.log", text="Quarterly");
			         qDates= This.getDatesQuarterly(a.Contract_Main_ID,a.Fiscal_Year_ID);
			         break;
			    case "3": case "10":	//Monthly
			    	//WriteLog(file="mws.log", text="Monthly");
			         qDates= This.getDatesMonthly(a.Contract_Main_ID,a.Fiscal_Year_ID);
			         break;
			    default: 	//Monthly as default
			    	//WriteLog(file="mws.log", text="default(monthly)");
			         qDates= This.getDatesMonthly(a.Contract_Main_ID,a.Fiscal_Year_ID);
			}
			
			//WriteLog(file="mws.log", text="cm #a.Contract_Main_ID# ::fy #a.Fiscal_Year# ::paycycle #a.Payment_Cycle_ID# ::st #qdates.start_date#  ::end #qdates.end_date#  ::yagst  #qdates.Yag_start_date#  ::yagend #qdates.Yag_end_date#");
		</cfscript>
		<!--- <cfdump var="#qDates#" output="D:\dump.log"/>--->
		<cfquery name="qGetFitnessDetailDataDropTmp" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpInvDetail') IS NOT NULL
  			DROP TABLE ##tmpInvDetail
		</cfquery>
		<cfquery name="qGetFitnessDetailData" datasource="#application.datasource#">
			SELECT ID.*,
					CASE WHEN (IH.Invoice_Date >= CM.Contract_Start_Date AND IH.Invoice_Date <= CM.Contract_End_Date) Then 1 Else 0 END AS eligible
			INTO ##tmpInvDetail
			FROM  Invoice_Header IH 	
			INNER JOIN Invoice_Detail ID ON
					ID.Invoice_Header_ID = IH.Invoice_Header_ID
			INNER JOIN Contract_Main CM ON
				CM.Contract_Main_ID = #Contract_main_Id#
			WHERE IH.Invoice_Date >= '#qdates.start_date#' AND
					IH.Invoice_Date <= '#qdates.end_date#' AND
					IH.BSA_Foodservice_Customers_ID = '#arguments.cust#' 
			
			SELECT	I.item AS item,
					description AS description,
					Q.Q_Brand AS qBrand,
					A.Prod_Var_A_Desc AS prodVarA,
					TC.Type_Code_Desc AS typeCodeDesc,
					CASE  WHEN B.Brand = 'Y'  THEN 'Prv lbl'
					 	WHEN B.Brand = 'D'  THEN 'Normal'
					  	WHEN B.Brand = 'O'  THEN 'Operator'
					  	WHEN B.Brand = 'S'  THEN 'Sig'
					    ELSE 'Normal' END AS sigLabel,
					CASE WHEN 	(
									<!---(PFPPD.Contract_Products_ID IS NOT NULL OR
									PRPD.Contract_Products_ID IS NOT NULL OR
									PGCPD.Contract_Products_ID IS NOT NULL )--->
									CP.Contract_Main_ID IS NOT NULL
									AND 
									ID.eligible = 1
								) THEN 'Y' ELSE 'N' END
						AS eligibility
					,Isnull(yag.yagRevenue,0) as yago
					,SUM(ID.Gross_Sales_Dollars) as revenue
					,SUM(CAST(ID.Cases_Invoiced AS DECIMAL(18,4))) as cases
					,SUM(CAST(ID.Pounds_Invoiced AS DECIMAL(18,4))) as lbs
					,0 as yagoNon
					,0 as revenueNon
					,0 as casesNon
					,0 as lbsNon
			FROM  ##tmpInvDetail ID
			INNER JOIN Invoice_Header IH ON
					ID.Invoice_Header_ID = IH.Invoice_Header_ID
			LEFT JOIN( 
						SELECT
							SUM(IDYag.Gross_Sales_Dollars) AS yagRevenue,
							IDYag.BSA_Foodservice_Items_Master_ID,
							IHYag.BSA_Foodservice_Customers_ID
						FROM	Invoice_Header IHYag
						LEFT JOIN Invoice_Detail IDYag ON
							IDYag.Invoice_Header_ID = IHYag.Invoice_Header_ID AND
							IDYag.BSA_Foodservice_Items_Master_ID IN (SELECT BSA_Foodservice_Items_Master_ID FROM ##tmpInvDetail)
						WHERE
							IHYag.Invoice_Date >= '#qdates.Yag_start_date#' AND
							IHYag.Invoice_Date <= '#qdates.Yag_end_date#' AND
							IHYag.BSA_Foodservice_Customers_ID = '#arguments.cust#'
						GROUP BY IDYag.BSA_Foodservice_Items_Master_ID,IHYag.BSA_Foodservice_Customers_ID
					)
					 YAG ON YAG.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID AND
						YAG.BSA_Foodservice_Customers_ID = IH.BSA_Foodservice_Customers_ID
			INNER JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Contract_Products CP ON
				CP.Contract_Main_ID = #Contract_main_Id# AND
				CP.Is_Group = 0 AND
				CP.Deleted = 0 AND
				CP.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID
			<!---LEFT JOIN Program_Rebates_Product_Data PRPD ON
				PRPD.Program_ID = CP.Contract_Main_ID AND
				PRPD.Contract_Products_ID = CP.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id#
			LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
				PFPPD.Program_ID = CP.Contract_Main_ID AND
				PFPPD.Contract_Products_ID = CP.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id#
			LEFT JOIN Program_Growth_Component_Product_Data PGCPD ON
				CP.Contract_Products_ID = PGCPD.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id# AND
				PGCPD.Deleted = 0--->
			LEFT JOIN Q_Brand_Desc Q ON
				Q.Q_Brand_ID = I.Q_Brand_ID
			LEFT JOIN Prod_Var_A A ON
				A.Prod_Var_A_ID = I.Prod_Var_A_ID
			LEFT JOIN Type_Code_Desc TC ON
				TC.Type_Code_Desc_ID = I.Type_Code_Desc_ID
			LEFT JOIN Brand B ON
				B.Brand_ID = I.Brand_ID
			WHERE 
					IH.BSA_Foodservice_Customers_ID = '#arguments.cust#' AND 
					(
						<!---(PFPPD.Contract_Products_ID IS NOT NULL OR
						PRPD.Contract_Products_ID IS NOT NULL OR
						PGCPD.Contract_Products_ID IS NOT NULL )--->
						CP.Contract_Main_ID IS NOT NULL
						AND 
						ID.eligible = 1
					)
			GROUP BY I.item,I.description,q.Q_Brand,a.Prod_Var_A_Desc,TC.Type_Code_Desc,B.Brand,CP.BSA_Foodservice_Items_Master_ID,ID.eligible,CP.Contract_Main_ID 
			---PFPPD.Contract_Products_ID,PRPD.Contract_Products_ID,PGCPD.Contract_Products_ID
			,yag.yagRevenue
			
			UNION
			
			SELECT	I.item AS item,
					description AS description,
					Q.Q_Brand AS qBrand,
					A.Prod_Var_A_Desc AS prodVarA,
					TC.Type_Code_Desc AS typeCodeDesc,
					CASE  WHEN B.Brand = 'Y'  THEN 'Prv lbl'
					 	WHEN B.Brand = 'D'  THEN 'Normal'
					  	WHEN B.Brand = 'O'  THEN 'Operator'
					  	WHEN B.Brand = 'S'  THEN 'Sig'
					    ELSE 'Normal' END AS sigLabel,
					CASE WHEN	(
									<!---(PFPPD.Contract_Products_ID IS NULL AND
									PRPD.Contract_Products_ID IS NULL AND
									PGCPD.Contract_Products_ID IS NULL )--->
									CP.Contract_Main_ID IS NULL
									OR 
									ID.eligible = 0
								) THEN 'N' ELSE 'Y' END
						AS eligibility
					,0 as yago
					,0 as revenue
					,0 as cases
					,0 as lbs
					,Isnull(yag.yagRevenue,0)as yagoNon
					,SUM(ID.Gross_Sales_Dollars)as revenueNon
					,SUM(CAST(ID.Cases_Invoiced AS DECIMAL(18,4))) as casesNon,
					SUM(CAST(ID.Pounds_Invoiced AS DECIMAL(18,4))) as lbsNon
			FROM  ##tmpInvDetail ID
			INNER JOIN Invoice_Header IH ON
					ID.Invoice_Header_ID = IH.Invoice_Header_ID
			LEFT JOIN( 
						SELECT
							SUM(IDYag.Gross_Sales_Dollars) AS yagRevenue,
							IDYag.BSA_Foodservice_Items_Master_ID,
							IHYag.BSA_Foodservice_Customers_ID
						FROM	Invoice_Header IHYag
						LEFT JOIN Invoice_Detail IDYag ON
							IDYag.Invoice_Header_ID = IHYag.Invoice_Header_ID AND
							IDYag.BSA_Foodservice_Items_Master_ID IN (SELECT BSA_Foodservice_Items_Master_ID FROM ##tmpInvDetail)
						WHERE
							IHYag.Invoice_Date >= '#qdates.Yag_start_date#' AND
							IHYag.Invoice_Date <= '#qdates.Yag_end_date#' AND
							IHYag.BSA_Foodservice_Customers_ID = '#arguments.cust#'
						GROUP BY IDYag.BSA_Foodservice_Items_Master_ID,IHYag.BSA_Foodservice_Customers_ID
					)
					 YAG ON YAG.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID AND
						YAG.BSA_Foodservice_Customers_ID = IH.BSA_Foodservice_Customers_ID
			INNER JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Contract_Products CP ON
				CP.Contract_Main_ID = #Contract_main_Id# AND
				CP.Is_Group = 0 AND
				CP.Deleted = 0 AND
				CP.BSA_Foodservice_Items_Master_ID = ID.BSA_Foodservice_Items_Master_ID
		<!---	LEFT JOIN Program_Rebates_Product_Data PRPD ON
				PRPD.Program_ID = CP.Contract_Main_ID AND
				PRPD.Contract_Products_ID = CP.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id#
			LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
				PFPPD.Program_ID = CP.Contract_Main_ID AND
				PFPPD.Contract_Products_ID = CP.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id#
			LEFT JOIN Program_Growth_Component_Product_Data PGCPD ON
				CP.Contract_Products_ID = PGCPD.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id# AND
				PGCPD.Deleted = 0--->
			LEFT JOIN Q_Brand_Desc Q ON
				Q.Q_Brand_ID = I.Q_Brand_ID
			LEFT JOIN Prod_Var_A A ON
				A.Prod_Var_A_ID = I.Prod_Var_A_ID
			LEFT JOIN Type_Code_Desc TC ON
				TC.Type_Code_Desc_ID = I.Type_Code_Desc_ID
			LEFT JOIN Brand B ON
				B.Brand_ID = I.Brand_ID
			WHERE 
					IH.BSA_Foodservice_Customers_ID = '#arguments.cust#' AND
					(
						<!---(PFPPD.Contract_Products_ID IS NULL AND
						PRPD.Contract_Products_ID IS NULL AND 
						PGCPD.Contract_Products_ID IS NULL )
						--->
						CP.Contract_Main_ID IS NULL
						OR 
						ID.eligible = 0
					)
			GROUP BY I.item,I.description,q.Q_Brand,a.Prod_Var_A_Desc,TC.Type_Code_Desc,B.Brand,CP.BSA_Foodservice_Items_Master_ID,CP.Contract_Main_ID,ID.eligible
			---,PFPPD.Contract_Products_ID,PRPD.Contract_Products_ID,ID.eligible,PGCPD.Contract_Products_ID
			,yag.yagRevenue
			
			UNION

			SELECT
					I.item AS item,
					description AS description,
					Q.Q_Brand AS qBrand,
					A.Prod_Var_A_Desc AS prodVarA,
					TC.Type_Code_Desc AS typeCodeDesc,
					CASE  WHEN B.Brand = 'Y'  THEN 'Prv lbl'
					 	WHEN B.Brand = 'D'  THEN 'Normal'
					  	WHEN B.Brand = 'O'  THEN 'Operator'
					  	WHEN B.Brand = 'S'  THEN 'Sig'
					    ELSE 'Normal' END AS sigLabel,
					 'Y' AS eligibility
					,0 as yago
					,0 as revenue
					,0 as cases
					,0 as lbs
					,0 as yagoNon
					,0 as revenueNon
					,0 as casesNon,
					0 as lbsNon
			FROM  Contract_Products CP
			LEFT JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
		<!---	LEFT JOIN Program_Rebates_Product_Data PRPD ON
				PRPD.Program_ID = CP.Contract_Main_ID AND
				PRPD.Contract_Products_ID = CP.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id#
			LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
				PFPPD.Program_ID = CP.Contract_Main_ID AND
				PFPPD.Contract_Products_ID = CP.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id#
			LEFT JOIN Program_Growth_Component_Product_Data PGCPD ON
				CP.Contract_Products_ID = PGCPD.Contract_Products_ID AND
				CP.Product_Type_ID = #Discount_Type_Id# AND
				PGCPD.Deleted = 0--->
			LEFT JOIN Q_Brand_Desc Q ON
				Q.Q_Brand_ID = I.Q_Brand_ID
			LEFT JOIN Prod_Var_A A ON
				A.Prod_Var_A_ID = I.Prod_Var_A_ID
			LEFT JOIN Type_Code_Desc TC ON
				TC.Type_Code_Desc_ID = I.Type_Code_Desc_ID
			LEFT JOIN Brand B ON
				B.Brand_ID = I.Brand_ID
			WHERE  	CP.Contract_Main_ID = #Contract_main_Id# AND
				CP.Is_Group = 0 AND
				CP.Deleted = 0 AND
				CP.Contract_Main_ID IS NOT NULL
				<!---(PFPPD.Contract_Products_ID IS NOT NULL OR
				PRPD.Contract_Products_ID IS NOT NULL OR
				PGCPD.Contract_Products_ID IS NOT NULL )--->
			GROUP BY I.item,I.description,q.Q_Brand,a.Prod_Var_A_Desc,TC.Type_Code_Desc,B.Brand,CP.BSA_Foodservice_Items_Master_ID,CP.Contract_Main_ID
			---PFPPD.Contract_Products_ID,PRPD.Contract_Products_ID,PGCPD.Contract_Products_ID
			ORDER BY eligibility DESC, cases DESC, casesNon DESC
	    </cfquery>
	 <!---   <cfdump var="#qGetFitnessDetailData#" output="D:\dump.log"/>--->
	    <cfreturn qGetFitnessDetailData />

	</cffunction>
	
		<cffunction name="getBusSegData" output="false" access="public" returntype="query">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			 WriteLog(file="mws.log", text="[ ] [getBusSegData ] #now()#"); 
		</cfscript>
		<cfset useLakebaseForqGetDropDownData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForqGetDropDownData>
	<cftry>
		<cfset qGetDropDownData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"deleted" = "eq.0",
				"business_unit_id" = "neq.NONE",
				"select" = "business_segment_id as sid,business_unit_desc as label"
			}), "business_segment_id as sid,business_unit_desc as label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDropDownData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDropDownData>
<cfquery name="qGetDropDownData" datasource="#application.datasource#">
			SELECT Business_Segment_Id as sId,
				Business_Unit_Desc as label
			 FROM Business_Segment
			 WHERE Deleted = 0 AND 
				Business_Unit_ID != 'NONE'
		</cfquery>
</cfif>
	
		<cfreturn qGetDropDownData />
	</cffunction>

	<cffunction name="getArea1Data" output="false" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			 WriteLog(file="mws.log", text="[#arguments.id#] [Area1 ] #now()#"); 
		</cfscript>
		<cfquery name="qGetDropDownData" datasource="#application.datasource#">
			SELECT Zone_Name + ' ' + Zone_Number as label,
	   			   Service_Zone_ID as sId
			FROM dbo.Service_Zones z
			WHERE Z.Deleted = 0 AND
					Zone_Number IS NOT NULL AND
					z.Business_Segment_ID = '#arguments.id#'
			ORDER BY Zone_Name ASC
		</cfquery>
	
		<cfreturn qGetDropDownData />
	</cffunction>
	
	<cffunction name="getRegion2Data" output="false" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			
		</cfscript>
		<cfquery name="qGetDropDownData" datasource="#application.datasource#">
			SELECT Region_Name + ' ' + Region_Number as label,
				Service_Region_ID as sId
			FROM Service_Regions R
			WHERE R.Deleted = 0 AND
				R.Service_Zone_ID = '#arguments.id#'
			ORDER BY label ASC
		</cfquery>
		<cfscript>
			WriteLog(file="mws.log", text="[getRegion2Data :: #qGetDropDownData.RecordCount#] [#arguments.id#] #now()#");
		</cfscript>
	
		<cfreturn qGetDropDownData />
	</cffunction>
	
	<cffunction name="getCustomer3Data" output="false" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			WriteLog(file="mws.log", text="[getCustomer3Data :: [#arguments.id#] #now()#");
		</cfscript>
		<!---Select distributorMultiPosition from _application_Settings--->
		<cfquery name="qGetDropDownData" datasource="#application.datasource#">
				SELECT DISTINCT
						Name + ' ' + Ship_To as label,
						BSA_Foodservice_Customers_Id as sId
				FROM Service_Markets SM
				INNER JOIN BSA_Foodservice_Brokers B ON
					B.Service_Market_ID = SM.Service_Market_ID
				INNER JOIN BSA_Foodservice_Customers C ON
					C.BSA_Foodservice_Brokers_ID = B.BSA_Foodservice_Brokers_ID
				WHERE SM.Service_Region_ID = '#arguments.id#' AND
						SM.Deleted = 0
				ORDER BY label ASC
		</cfquery>
		<cfscript>
			WriteLog(file="mws.log", text="[getCustomer3Data :: #qGetDropDownData.RecordCount#] [#arguments.id#] #now()#");
		</cfscript>
		<cfreturn qGetDropDownData />
	</cffunction>
	
	<cffunction name="getYear4Data" output="false" access="public" returntype="query">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			
		</cfscript>
		<cfquery name="qGetDropDownData" datasource="#application.datasource#">
			SELECT DISTINCT Fiscal_Year as sId, 
					YEAR(FY.Start_Date)  as label
			FROM Fiscal_Year FY
			WHERE YEAR(FY.Start_Date) <= YEAR(GETDATE()) + 1 AND
			RIGHT(Fiscal_Year,4) = YEAR(FY.Start_Date) AND
			RIGHT(Fiscal_Year,4)  > 2014
			ORDER BY label DESC
		</cfquery>
	
		<cfreturn qGetDropDownData />
	</cffunction>
	
	<cffunction name="getProgram5Data" output="false" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfargument name="id2" type="any" required="true"><!--- Fiscal_Year --->
		<cfscript>
			//set local variables
			var nSourceType				= 0;
			var qGetDropDownData		= "";
			
		</cfscript>
		<cfquery name="qGetDropDownData" datasource="#application.datasource#">
			SELECT DISTINCT
					'#Right(id2,4)#' + ' ' + CM.Contract_Title + ' ' + ISNULL(PRCN.Program_Rebates_Component_Name,ISNULL(PFCN.Program_Fixed_Component_Name,PGCN.Program_Growth_Components_Name)) + ' :: ' + CM.Contract_Number as label,
					 CAST(CM.Contract_Main_ID as Varchar(12)) + '_' + CAST(ISNULL(cast(PRC.Program_Rebates_Component_ID as varchar(37)),ISNULL(cast(PFC.Program_Fixed_Component_ID as varchar(37)),PGC.Program_Growth_Component_ID)) as VarChar(37)) + '_' + 
					 CASE WHEN PRC.Program_Rebates_Component_ID IS NOT NULL THEN '2' WHEN PFC.Program_Fixed_Component_ID IS NOT NULL THEN '1' WHEN PGC.Program_Growth_Component_ID IS NOT NULL THEN '4' END as sId 
			FROM Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO ON
				PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			INNER JOIN Discount_Identifier DI ON
				DI.Discount_Identifier_ID = PCPO.Discount_Identifier_ID
			INNER JOIN Contract_Distributors CD ON
			 CD.Contract_Main_ID = CM.Contract_Main_ID
			INNER JOIN Fiscal_Year FY ON
				FY.Fiscal_Year = '#id2#'
			LEFT JOIN Program_Rebates_Component PRC ON
				PRC.Program_ID = CM.Contract_Main_ID AND
				PRC.Deleted = 0
			LEFT JOIN Program_Rebates_Component_Name PRCN ON
				PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
			LEFT JOIN Program_Fixed_Component PFC ON
				PFC.Program_ID = CM.Contract_Main_ID AND
				PFC.Deleted = 0
			LEFT JOIN Program_Fixed_Component_Name PFCN ON
				PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			LEFT JOIN Program_Growth_Components PGC ON
				PGC.Program_ID = CM.Contract_Main_ID AND
				PGC.Deleted = 0
			LEFT JOIN Program_Growth_Components_Name PGCN ON
				PGCN.Program_Growth_Components_Name_Id = PGC.Program_Growth_Components_Name_Id
			WHERE
				CM.Deleted = 0 AND
				CM.Approved = 1 AND
				CD.Deleted = 0 AND
				CD.BSA_Foodservice_Customers_ID = '#id#' AND
				(Contract_Start_Date <= FY.End_Date AND Contract_End_Date >= FY.Start_Date) AND
				(PFC.Program_ID IS NOT NULL OR  PRC.Program_ID IS NOT NULL OR PGC.Program_ID IS NOT NULL) AND
				PCPO.Generic_Type = 'Distributor Trade/Shelter' AND
				DI.Discount_Identifier_Number != '900'
				--- AND RIGHT('#id2#',4) = YEAR(FY.Start_Date)
			ORDER BY label
		</cfquery>
	
		<cfreturn qGetDropDownData />
	</cffunction>
	
	<cffunction name="getPeriod6Data" output="false" access="public" returntype="query">
		<cfargument name="a1" type="numeric" required="true">
		<cfargument name="a2" type="any" required="true">
		<cfargument name="a3" type="numeric" required="true">
		<cfargument name="fy" type="any" required="true">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			
		</cfscript>
   <!---  a1 = a[1]; // Contract_main_Id
		  a2 = a[2]; // Component_Id
		  a3 = a[3]; // Discount_Type_Id   --->
		<cfquery name="qGetReportData" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpFitnessData') IS NOT NULL
  				DROP TABLE ##tmpFitnessData
		</cfquery>
		<cfquery name="qGetDropDownData" datasource="#application.datasource#">
			SELECT
					PC.Payment_Cycle + ' period' + cast(period as varchar(2)) as label,
					FY.Fiscal_Year_ID + '_' + CAST(PC.Payment_Cycle_ID AS VarChar(2)) + '_' + CAST(period AS VarChar(2)) as sId ,
					CASE WHEN CM.Contract_Start_Date < FY.Start_Date THEN FY.Start_Date
						ELSE CM.Contract_Start_Date
						END AS Start_Date,
					CASE WHEN CM.Contract_End_Date > FY.End_Date THEN FY.End_Date
						ELSE CM.Contract_End_Date
						END AS End_Date,
					FY.Fiscal_Year, PC.Payment_Cycle_Id,FY.Period,FY.Fiscal_Year_ID
			INTO ##tmpFitnessData
			FROM Contract_Main CM
			INNER JOIN Fiscal_Year FY ON
				FY.Fiscal_Year = '#fy#'
			LEFT JOIN Program_Rebates_Component PRC ON
				PRC.Program_ID = CM.Contract_Main_ID AND
				PRC.Deleted = 0
			LEFT JOIN Program_Fixed_Component PFC ON
				PFC.Program_ID = CM.Contract_Main_ID AND
				PFC.Deleted = 0
			LEFT JOIN Program_Growth_Components PGC ON
				PGC.Program_ID = CM.Contract_Main_ID AND
				PGC.Deleted = 0
			LEFT JOIN Program_Payment_Cycle PPC ON
				PPC.Program_ID = CM.Contract_Main_ID AND
				(
					(PPC.Component_ID = CAST(PRC.Program_Rebates_Component_ID AS VARCHAR(37)) AND PPC.Discount_Type_ID = 2)
					OR
					(PPC.Component_ID = CAST(PFC.Program_Fixed_Component_ID AS VARCHAR(37)) AND PPC.Discount_Type_ID = 1)
					OR
					(PPC.Component_ID = cast(PGC.Program_Growth_Component_ID as varchar(37)) AND PPC.Discount_Type_ID = 4)
			   ) AND
			   PPC.Deleted = 0
			LEFT JOIN Payment_Cycle PC ON
			PC.Payment_Cycle_ID = PPC.Payment_Cycle_ID  
			WHERE
				CM.Deleted = 0 AND
				CM.Contract_Main_ID = #a1# AND
				(Contract_Start_Date <= FY.End_Date AND Contract_End_Date >= FY.Start_Date) 
				AND ( ('#a2#' = CAST(PRC.Program_Rebates_Component_ID AS VARCHAR(37)) AND #a3# = 2)
						OR
					   ('#a2#' = CAST(PFC.Program_Fixed_Component_Id AS VARCHAR(37)) AND #a3# = 1)
					   OR
					   ('#a2#' = cast(PGC.Program_Growth_Component_ID as varchar(37)) AND #a3# = 4)
					)
			ORDER BY Start_Date ASC
			
			----------------------
			
			SELECT  CASE 
						WHEN Payment_Cycle_Id in (1,2,6,7,8) THEN '#Right(fy,4)#' + ' YR'
						WHEN Payment_Cycle_Id in (4,11) THEN 
								CASE WHEN Period = 1 THEN '#Right(fy,4)#' + ' QTR 1'
									 WHEN Period = 4 THEN '#Right(fy,4)#' + ' QTR 2'
									 WHEN Period = 7 THEN '#Right(fy,4)#' + ' QTR 3'
									 WHEN Period = 10 THEN '#Right(fy,4)#' + ' QTR 4'
								END
						WHEN Payment_Cycle_Id in (3,10) THEN  '#Right(fy,4)#' + ' MTH ' + CAST(Period AS VarChar(2)) 
					END
					AS label,
				   sId
			FROM ##tmpFitnessData
			WHERE	(Payment_Cycle_Id in (1,2,6,7,8) --Annual
						AND 
						(Start_date =	(SELECT MAX(Start_date) 
											FROM ##tmpFitnessData
										)
						)
					)
						OR
					(Payment_Cycle_Id IN (4,11) --Quarterly
						AND 
						(Start_date IN	(SELECT Start_date 
											FROM ##tmpFitnessData
											WHERE Period IN(1,4,7,10)
										)
						)
					) 
						OR
					(Payment_Cycle_Id in (3,10)) --Monthly
		</cfquery>
	
		<cfreturn qGetDropDownData />
	</cffunction>
	
	<cffunction name="getDatesMonthly" output="false" access="public" returntype="query">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="Fiscal_Year_ID" type="any" required="true">
		<cfscript>
			//set local variables
			var qGetDates		= "";
			var FYID = this.getPreviousYearId(Contract_Main_ID,Fiscal_Year_Id);
		</cfscript>
		<cfquery name="qGetDates" datasource="#application.datasource#">
			SELECT FY.Start_Date AS Start_Date,
					FY.End_Date AS End_Date,
					FYYag.Start_Date as Yag_Start_Date,
					FYYag.End_Date as Yag_End_Date
			FROM Contract_Main CM
			INNER JOIN Fiscal_Year FY ON 
				FY.Fiscal_Year_ID = '#FYID#'
			INNER JOIN Fiscal_Year FYYag ON 
				FYYag.Period = FY.Period AND
				CAST(Replace(FYYag.Fiscal_Year,'FY_','') AS INT) = CAST(Replace(FY.Fiscal_Year,'FY_','') AS INT) - 1
			WHERE CM.Contract_Main_ID = '#arguments.Contract_Main_ID#'
		</cfquery>
	
		<cfreturn qGetDates />
	</cffunction>
	
	<cffunction name="getDatesQuarterly" output="false" access="public" returntype="query">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="Fiscal_Year_ID" type="any" required="true">
		<cfscript>
			//set local variables
			var qGetDates		= "";
			var FYID = this.getPreviousYearId(Contract_Main_ID,Fiscal_Year_Id);
		</cfscript>
		<cfquery name="qGetDates" datasource="#application.datasource#">
			SELECT FY.Start_Date AS Start_Date,
					FY_End.End_Date AS End_Date,
					FYYag.Start_Date as Yag_Start_Date,
					FYYag_End.End_Date as Yag_End_Date
			FROM Contract_Main CM
			INNER JOIN Fiscal_Year FY ON 
				FY.Fiscal_Year_ID = '#FYID#'
			INNER JOIN Fiscal_Year FY_End ON
				FY_End.Fiscal_Year = FY.Fiscal_Year AND
				FY_End.Period = FY.Period + 2
			INNER JOIN Fiscal_Year FYYag ON 
				FYYag.Period = FY.Period AND
				CAST(Replace(FYYag.Fiscal_Year,'FY_','') AS INT) = CAST(Replace(FY.Fiscal_Year,'FY_','') AS INT) -1
			INNER JOIN Fiscal_Year FYYag_End ON 
				FYYag_End.Fiscal_Year = FYYag.Fiscal_Year AND
				FYYag_End.Period = FYYag.Period + 2
			WHERE CM.Contract_Main_ID = #arguments.Contract_Main_ID#
		</cfquery>
		<cfreturn qGetDates />
	</cffunction>
	
	<cffunction name="getDatesAnnual" output="false" access="public" returntype="query">
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="Fiscal_Year" type="String" required="true">
		<cfscript>
			//set local variables
			var qGetDates		= "";
			var FY = this.getPreviousYear(Contract_Main_ID,Fiscal_Year);
		</cfscript>
		<cfquery name="qGetDates" datasource="#application.datasource#">
			SELECT FY.Start_Date AS Start_Date,
					FY_End.End_Date AS End_Date,
					FYYag.Start_Date as Yag_Start_Date,
					FYYag_End.End_Date as Yag_End_Date
			FROM Contract_Main CM
			INNER JOIN Fiscal_Year FY ON 
				FY.Fiscal_Year = '#FY#' AND
				FY.Period = 1
			INNER JOIN Fiscal_Year FY_End ON
				FY_End.Fiscal_Year = FY.Fiscal_Year AND
				FY_End.Period = 12
			INNER JOIN Fiscal_Year FYYag ON 
				FYYag.Period = FY.Period AND
				CAST(Replace(FYYag.Fiscal_Year,'FY_','') AS INT) = CAST(Replace(FY.Fiscal_Year,'FY_','') AS INT) -1
			INNER JOIN Fiscal_Year FYYag_End ON 
				FYYag_End.Fiscal_Year = FYYag.Fiscal_Year AND
				FYYag_End.Period = 12
			WHERE CM.Contract_Main_ID = #arguments.Contract_Main_ID#
		</cfquery>
	
		<cfreturn qGetDates />
	</cffunction>
	
	<cffunction name="getPreviousYearFlag" output="false" access="public" returntype="boolean" >
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfscript>
			//set local variables
			var qGetPreviousYear		= "";
			
		</cfscript>
		<cfquery name="qGetPreviousYearFlag" datasource="#application.datasource#">
			SELECT PCPO.Previous_Fiscal_Year_Volume
			FROM 	Contract_Main CM
			INNER JOIN	Program_Control_Panel_Options PCPO ON
				CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
			WHERE CM.Contract_Main_Id = #arguments.Contract_Main_ID#
		</cfquery>
	
		<cfreturn qGetPreviousYearFlag.Previous_Fiscal_Year_Volume />
	</cffunction>
	
	<cffunction name="getPreviousYear" output="false" access="public" returntype="String" >
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="Fiscal_Year" type="String" required="true">
		<cfscript>
			//set local variables
			var qGetDropDownData		= "";
			var FY = arguments.Fiscal_Year;
		</cfscript>
		<cfif this.getPreviousYearFlag(arguments.Contract_Main_ID)>
			<cfscript>
				//get previous FY
				i = replace(FY,'FY_','');
				i = i - 1;
				FY = 'FY_' & i;
			</cfscript>
		</cfif>
		<cfreturn FY />
	</cffunction>
	
	<cffunction name="getPreviousYearId" output="false" access="public" returntype="String" >
		<cfargument name="Contract_Main_ID" type="numeric" required="true">
		<cfargument name="Fiscal_Year_Id" type="String" required="true">
		<cfscript>
			//set local variables
			var qGetPreviousYearId			= "";
			var FYID = arguments.Fiscal_Year_Id;
		</cfscript>
		<cfif this.getPreviousYearFlag(arguments.Contract_Main_ID)>
			<cfquery name="qGetPreviousYearId" datasource="#application.datasource#">
				SELECT FYYag.Fiscal_Year_Id
				FROM Fiscal_Year FY
				INNER JOIN Fiscal_Year FYYag ON 
					FYYag.Period = FY.Period AND
					CAST(Replace(FYYag.Fiscal_Year,'FY_','') AS INT) = CAST(Replace(FY.Fiscal_Year,'FY_','') AS INT) -1
				WHERE FY.Fiscal_Year_ID = '#FYID#'
			</cfquery>
			<cfset FYID = qGetPreviousYearId.Fiscal_Year_Id />
		</cfif>
		<cfreturn FYID />
	</cffunction>
	
	
	
</cfcomponent>