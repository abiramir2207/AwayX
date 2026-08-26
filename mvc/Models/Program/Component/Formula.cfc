<cfcomponent hint="Manage Formula Price program components" >

	<cffunction name="getFormulaSchedule" output="false" returntype="Query" >

			<CFQUERY NAME="qGetScheduleOptions" DATASOURCE="#APPLICATION.DATASOURCE#">
				SELECT FP_Schedule_Option_ID,
						Price_Day_Code,
						Price_Day_Description,
						Effective_Day,
						Effective_Day_Description,
						Notes,
						Price_Day_Frequency,
						Price_Day_When,
						Effective_Day_Type,
						Effective_Day_When
				FROM FP_Schedule_Options 
				WHERE active = 1
				ORDER BY price_Day_Frequency desc,Price_Day_When ASC
			</CFQUERY>
			<cfreturn qGetScheduleOptions >
	
	</cffunction>
	
	<cffunction name="getFormulaTypes" output="false" >

			<CFQUERY NAME="qGetFormulaTypes" DATASOURCE="#APPLICATION.DATASOURCE#">
				SELECT FP_Formula_Type_ID,
						FP_Formula_Type,
						Formula_Type_Description,
						Market_Table,
						Notes,
						Calc_Type,
						Calc_Days
				FROM 	FP_Formula_Types 
				WHERE active = 1
				order by Formula_Type_Description DESC
			</CFQUERY>
		<cfreturn qGetFormulaTypes >
	</cffunction>
	
	<cffunction name="getProgramFormula" output="false" returntype="Query" >
		<cfargument name="Program_Id" type="numeric" required="true" >
		<cfargument name="Contract_Products_Id" type="numeric" required="false" default = "0">
		<cfargument name="Rule_Id" type="string" required="false" default = "">

			<CFQUERY NAME="qGetProgramFormula" DATASOURCE="#APPLICATION.DATASOURCE#">
				DECLARE @iRound INT = 0
				SELECT 
					@iRound =
						CASE 
						WHEN PPR.Requirement_Name = 'No Rounding'  THEN -- 
							0
						WHEN PPR.Requirement_Name like '%Nearest%' THEN -- 
							1
						WHEN PPR.Requirement_Name like '%Higher%' THEN --
							2
						ELSE
							0
						END
				FROM 	One_Program_Perf_Mapping OPPM	
				INNER JOIN Program_Perf_Req PPR ON 
						PPR.Program_Perf_Req_ID = OPPM.Program_Perf_Req_ID
				WHERE OPPM.Contract_Main_ID = #arguments.Program_Id# AND
						OPPM.checked = 1

				SELECT 
					CASE
						WHEN  @iRound = 0 THEN --  WR 80994
								CAST(Formula_Price/100 as DECIMAL(18,4)) ---Standard rounding
						WHEN  @iRound = 1 THEN 
								CAST(ROUND(Formula_Price/100,2) as DECIMAL(18,4))  -- Nearest Dollar
						WHEN  @iRound = 2 AND Formula_Price != 0 THEN
								CAST(ROUND(Formula_Price/100,2,2) + .01 as DECIMAL(18,4)) -- Higher Dollar
						ELSE
								CAST(Formula_Price/100 as DECIMAL(18,4))
					END  AS Formula_Price_Rounded,
					Formula_Price,
					Program_Formula_Pricing_Rule_ID,
					Program_Id,
					Rule_Name,
					Number_Of_Comms,
					Active,
					FP_Schedule_Option_ID,
					FP_Formula_Type_ID,
					Calc_Date,
					Price_Date,
					Program_Fixed_Component_Name_Id,
					Program_Fixed_Component_Id,
					im.Item,
					im.Description
				FROM [dbo].[Program_Formula_Pricing_Rules] R
				left join Contract_Products cp on cp.Contract_Products_ID = r.Contract_Products_Id
				left join BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
				WHERE R.Program_Id = #arguments.Program_Id# AND
				        <cfif arguments.Contract_Products_Id NEQ 0>
				        	R.Contract_Products_Id = #arguments.Contract_Products_Id# AND
				        </cfif>
				        <cfif arguments.Rule_Id NEQ ''>
				        	R.Program_Formula_Pricing_Rule_ID = '#arguments.Rule_Id#' AND
				        </cfif>
						Active = 1 AND
						r.Deleted = 0
			</CFQUERY>
		<cfreturn qGetProgramFormula >
	</cffunction>
	
	<cffunction name="getProgramFormulaComponent" output="false" returntype="Query" >
		<cfargument name="Program_Id" type="numeric" required="true" >
		<cfargument name="Program_Formula_Pricing_Rule_ID" type="numeric" required="false" >

			<CFQUERY NAME="qGetProgramFormulaComponent" DATASOURCE="#APPLICATION.DATASOURCE#">
				SELECT PFCN.Formula_Pricing
				FROM	Program_Fixed_Component PFC
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
				WHERE	PFC.Program_ID = #arguments.Program_Id#
					AND	PFC.Deleted = 0
			</CFQUERY>
		<cfreturn qGetProgramFormulaComponent >
	</cffunction>
	
	<cffunction name="getProgramFormulaDetails" output="false" returntype="Query" >
		<cfargument name="Program_Id" type="numeric" required="false" default="0">

			<CFQUERY NAME="qGetProgramFormulaComponent" DATASOURCE="#APPLICATION.DATASOURCE#">
					SELECT  FSO.Effective_Day_When,
							FSO.Price_Day_When,
							Effective_Day_Type,
							CM.Contract_Main_Id,
							CM.Contract_Number,
							CM.Contract_Start_Date,
							CM.Contract_End_Date
					FROM Contract_Main CM
					INNER JOIN Program_Fixed_Component PFC ON
						PFC.Program_ID= CM.Contract_Main_Id
					INNER JOIN Program_Fixed_Component_Name PFCN ON
						PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
					INNER JOIN Program_Formula_Pricing_Rules PFPR ON 
						PFPR.Program_ID = CM.Contract_Main_Id
					INNER JOIN FP_Schedule_Options FSO ON
						FSO.FP_Schedule_Option_ID = PFPR.FP_Schedule_Option_ID
					INNER JOIN FP_Formula_Types FFT ON
						FFT.FP_Formula_Type_ID = PFPR.FP_Formula_Type_ID
					WHERE  CM.Deleted = 0
						AND CM.Contract_Status_Type_IDX  > 1
						AND CM.Contract_Status_Type_IDX  < 8
						AND	PFC.Deleted = 0
						AND PFCN.Formula_Pricing = 1
						AND DATEDIFF(DD,CM.Contract_Start_Date,getDate()) > -7
						AND DATEDIFF(DD,CM.Contract_End_Date,getDate()) < 0
						<cfif arguments.Program_Id NEQ 0>
							AND CM.Contract_Main_Id = #arguments.Program_Id#
						</cfif>
			</CFQUERY>
		<cfreturn qGetProgramFormulaComponent >
	</cffunction>
	
	<cffunction name="getProgram" output="false" returntype="Query" >
		<cfargument name="Program_Id" type="numeric" required="true" >

			<cfset useLakebaseForqGetProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetProgram>
	<cftry>
		<cfset qGetProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.Program_Id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgram>
<CFQUERY NAME="qGetProgram" DATASOURCE="#APPLICATION.DATASOURCE#">
				SELECT	*
				FROM	Contract_Main
				WHERE
						Contract_Main_ID = '#arguments.Program_Id#'
			</CFQUERY>
</cfif>
		<cfreturn qGetProgram >
	</cffunction>
	
	<cffunction name="saveProgramFormula" output="false" returntype="void" >
		<cfargument name="Program_Id" type="numeric" required="true" >
		<cfargument name="Number_Of_Comms" type="numeric" required="false"  >
		<cfargument name="Program_Formula_Pricing_Rule_ID" type="string" required="false" default="" >
		<cfargument name="Contract_Products_Id" type="numeric" required="false" default = "0">
		<cfargument name="Program_Fixed_Component_Id" type="string" required="false" default = "">
		<cfargument name="Program_Fixed_Component_Name_Id" type="string" required="false" default = "">
		<cfscript>
			var id = '';
			if(arguments.Program_Formula_Pricing_Rule_ID != ''){
				id = arguments.Program_Formula_Pricing_Rule_ID;
			}
			else{
				q = getProgramFormula(arguments.Program_Id,arguments.Contract_Products_Id);
				if(q.recordCount > 0){
					id = q.Program_Formula_Pricing_Rule_ID;
				}
			} 
			
			//rName = getProgram(arguments.Program_Id).Contract_Number;
			rname = '';
		</cfscript>
	
		<cfif id EQ '' AND arguments.Program_Id NEQ 0>
			<CFQUERY NAME="Insert_Rule_Basic_Info" DATASOURCE="#application.datasource#">
				INSERT	INTO	
						Program_Formula_Pricing_Rules	
							(
								Program_Id,
								Rule_Name, 
								Number_Of_Comms, 
								Active,
								Contract_Products_Id
							)
				VALUES 		(
								#arguments.Program_Id#,
								'#rName#', 
								#arguments.Number_Of_Comms#, 
								1,
								#arguments.Contract_Products_Id#
							)
			</CFQUERY>
		<CFELSEif id NEQ "" and arguments.Program_Fixed_Component_Id neq "" and arguments.Program_Fixed_Component_Name_Id neq "">
			<CFQUERY NAME="Update_Rule_Basic_Info" DATASOURCE="#application.datasource#">
				UPDATE 	Program_Formula_Pricing_Rules
				SET		Program_Fixed_Component_Id = '#arguments.Program_Fixed_Component_Id#',
						Program_Fixed_Component_Name_Id = '#arguments.Program_Fixed_Component_Name_Id#'
				WHERE	Program_Formula_Pricing_Rule_ID = '#id#'
			</CFQUERY>
		
		</CFIF>
	</cffunction>

	<cffunction name="getFormulaProgramReport" output="false" returntype="string" returnformat="JSON" access="remote">

			<cfscript>
				appSettings = application.appSettingsGet;
			</cfscript>
			<CFQUERY NAME="qGetFormulaProgramReport" DATASOURCE="#application.datasource#">
				SELECT  --ro.*,co.*,cd.*,cm.*
					CM.Contract_number,
					CM.Contract_Title,
					CONVERT(varchar, CM.Contract_Start_Date,23) AS Contract_Start_Date,
					CONVERT(varchar, CM.Contract_End_Date,23) AS Contract_End_Date,
					PCPO.Created_Type,
					PFCN.Program_Fixed_Component_Name,
					U.Name_First + ' ' + U.Name_Last as RSP,
					C.Ship_To,
					C.Name,
					FSO.Price_Day_Description,
					FSO.Effective_Day_Description,
					FSO.Price_Day_Frequency,
					ISNULL(FFT.Formula_Type_Description,FT2.Formula_Type_Description ) Formula_Type_Description,
					ISNULL(FFT.Calc_Type,FT2.Calc_Type) Calc_Type,
					I.Item,
					I.Description,
					PRO.Description as Overage_Desc,
					CASE PRO.Uom WHEN '$' THEN PRO.Uom + ' ' + cast(pro.Amount as Varchar(10))  WHEN '%' THEN  CAST(pro.Amount as Varchar(10)) + ' ' + PRO.Uom  END AS Modification_Overage,
					CASE PRO.Calc_Type WHEN 2 THEN PRO.Compound_Price WHEN 1 THEN PRO.Independent_Price END as Formula_Overage,
					(Select sum(RCD2.Final_Price) FROM Program_Formula_Pricing_Rule_Comm_Data RCD2 WHERE RCD2.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID)  AS Total_Comm_Price,
					pfpr.Formula_Price as Final_Price,
					CED.Exchange_Detail_Abrev + ' :: ' + RCD.Symbol AS Commodity,
					---CAST(CAST(RCD.Weight AS Decimal(10,2)) AS Varchar(10)) + '' + '%'AS Weight,
					I.Net_Weight as weight,
					CO.Description As Comm_Overage_Desc,
					CASE CO.Uom WHEN '$' THEN CO.Uom + ' ' + cast(CO.Amount as Varchar(10)) WHEN '%' THEN  CAST(CO.Amount as Varchar(10)) + ' ' + CO.Uom  END as Comm_Overage,
					CASE CO.Calc_Type WHEN 2 THEN 'Compound' WHEN 1 THEN 'Independent' ELSE 'Unkown' END AS Overage_Calc_Type,
					RCD.Start_Price,
					cast(RCD.Compound_Price + RCD.Independent_Price AS Decimal(12,4))  AS Calculated_Comm_Overage,
					RCD.Final_Price AS Comm_Price,
					PFPPD.Fixed_Price_Value AS Bracket_Price,
					uom.Abbreviation_Singular AS UOM,
					BS.Business_Unit_Desc
				/* ---	,'-----oooooo-----',CO.*,'-------------',RCD.* ,'-----ooooo---',PRO.* */
			FROM Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO ON
				PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			INNER JOIN _Users U ON
				U.User_ID = CM.Responsible_User_ID
			LEFT JOIN Contract_Distributors CD ON
				CD.Contract_Main_ID = CM.Contract_Main_ID AND
				CD.Deleted = 0 AND
				CD.Captured_From_Group = 0
			LEFT JOIN BSA_Foodservice_Customers C ON
				C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
			INNER JOIN Contract_Products CP ON
				CP.Contract_Main_ID = CM.Contract_Main_ID AND
				CP.Deleted = 0 AND
				CP.Product_Type_ID = 1 AND --- Fixed
				CP.Captured_From_Group = 0
			INNER JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			INNER JOIN Program_Fixed_Component PFC ON
				PFC.Program_ID= CM.Contract_Main_Id
			INNER JOIN Program_Fixed_Component_Name PFCN ON
				PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON 
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					CP.Contract_Products_ID = PFPPD.Contract_Products_ID
			INNER JOIN Program_Formula_Pricing_Rules PFPR ON 
				PFPR.Program_ID = CM.Contract_Main_Id and
				pfpr.deleted = 0 
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
				and pfpr.Contract_Products_Id = CP.Contract_Products_ID
				</cfif>
			LEFT JOIN FP_Schedule_Options FSO ON
				FSO.FP_Schedule_Option_ID = PFPR.FP_Schedule_Option_ID
			LEFT JOIN FP_Formula_Types FFT ON
				FFT.FP_Formula_Type_ID = PFPR.FP_Formula_Type_ID
			INNER JOIN Program_Formula_Pricing_Rule_Comm_Data RCD ON 
				RCD.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND
				RCD.Deleted = 0
			LEFT JOIN FP_Formula_Types FT2 ON
				FT2.FP_Formula_Type_ID = RCD.FP_Formula_Type_ID
			INNER JOIN Commodities_Exchange_Detail CED ON
				CED.Exchange_Detail_ID = RCD.Exchange
			INNER JOIN Formula_Pricing_Commodity_Overage CO ON
				CO.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND
				RCD.Program_Formula_Pricing_Rule_Comm_Data_ID = co.Program_Formula_Pricing_Rule_Comm_Data_ID
			LEFT JOIN  Program_Formula_Pricing_Rule_Overage PRO ON 
					PRO.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND 
					PRO.Deleted = 0 
					-- AND PRO.Overage_Index = (SELECT MAX(Overage_Index) From Program_Formula_Pricing_Rule_Overage 
					-- 						WHERE Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND
					-- 						Deleted = 0 ) --- Just get one for the "Final_Price" Column
			LEFT JOIN Units_of_Measure uom on 
					uom.Unit_Of_Measure_ID = PFPPD.Unit_Of_Measure_ID
			LEFT JOIN dbo.Business_Segment BS ON BS.Business_Segment_ID = CM.Business_Segment_ID		
			WHERE  CM.Deleted = 0
				---AND CM.Contract_Status_Type_IDX  > 1
				AND CM.Contract_Status_Type_IDX  < 8
				AND	PFC.Deleted = 0
				AND PFCN.Formula_Pricing = 1
				and CM.Manual_Cancel = 0 
			--		AND DATEDIFF(DD,CM.Contract_Start_Date,getDate()) > -7
 				AND DATEDIFF(DD,CM.Contract_End_Date,getDate()) < 0
			 -- AND COntract_number = 'PRG-1086044'
			order by cm.Contract_Main_ID,I.Item,RCD.Symbol, CO.Overage_Index
			</CFQUERY>
			<cfreturn application.util.query.toAgGridJSON(qGetFormulaProgramReport, 'Contract_number, Contract_Title, Contract_Start_Date, Contract_End_Date, Created_Type, Program_Fixed_Component_Name, RSP, Ship_To, Name, Price_Day_Description, Effective_Day_Description, Price_Day_Frequency, Formula_Type_Description, Calc_Type, Item, Description, Commodity, Weight, Comm_Overage_Desc, Comm_Overage, Overage_Calc_Type, Start_Price, Calculated_Comm_Overage, Comm_Price, Total_Comm_Price, Overage_Desc, Modification_Overage, Formula_Overage, Final_Price, Bracket_Price, UOM, Business_Unit_Desc')>
	
	</cffunction>

	<cffunction name="getFormulaProgramItemLevelReport" output="false" returntype="string" returnformat="JSON" access="remote">

			<cfscript>
				appSettings = application.appSettingsGet;
			</cfscript>
			<CFQUERY NAME="qGetFormulaProgramReport" DATASOURCE="#application.datasource#">
				SELECT  --ro.*,co.*,cd.*,cm.*
					CM.Contract_number,
					CM.Contract_Title,
					CONVERT(varchar, CM.Contract_Start_Date,23) AS Contract_Start_Date,
					CONVERT(varchar, CM.Contract_End_Date,23) AS Contract_End_Date,
					PCPO.Created_Type,
					PFCN.Program_Fixed_Component_Name,
					U.Name_First + ' ' + U.Name_Last as RSP,
					C.Ship_To,
					C.Name,
					FSO.Price_Day_Description,
					FSO.Effective_Day_Description,
					FSO.Price_Day_Frequency,
					ISNULL(FFT.Formula_Type_Description,FT2.Formula_Type_Description ) Formula_Type_Description,
					ISNULL(FFT.Calc_Type,FT2.Calc_Type) Calc_Type,
					I.Item,
					I.Description,
					PRO.Description as Overage_Desc,
					CASE PRO.Uom WHEN '$' THEN PRO.Uom + ' ' + cast(pro.Amount as Varchar(10))  WHEN '%' THEN  CAST(pro.Amount as Varchar(10)) + ' ' + PRO.Uom  END AS Modification_Overage,
					CASE PRO.Calc_Type WHEN 2 THEN PRO.Compound_Price WHEN 1 THEN PRO.Independent_Price END as Formula_Overage,
					(Select sum(RCD2.Final_Price) FROM Program_Formula_Pricing_Rule_Comm_Data RCD2 WHERE RCD2.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID)  AS Total_Comm_Price,
					pfpr.Formula_Price as Final_Price,
					CED.Exchange_Detail_Abrev + ' :: ' + RCD.Symbol AS Commodity,
					---CAST(CAST(RCD.Weight AS Decimal(10,2)) AS Varchar(10)) + '' + '%'AS Weight,
					I.Net_Weight as weight,
					CO.Description As Comm_Overage_Desc,
					CASE CO.Uom WHEN '$' THEN CO.Uom + ' ' + cast(CO.Amount as Varchar(10)) WHEN '%' THEN  CAST(CO.Amount as Varchar(10)) + ' ' + CO.Uom  END as Comm_Overage,
					CASE CO.Calc_Type WHEN 2 THEN 'Compound' WHEN 1 THEN 'Independent' ELSE 'Unkown' END AS Overage_Calc_Type,
					RCD.Start_Price,
					cast(RCD.Compound_Price + RCD.Independent_Price AS Decimal(12,4))  AS Calculated_Comm_Overage,
					RCD.Final_Price AS Comm_Price,
					PFPPD.Fixed_Price_Value AS Bracket_Price,
					uom.Abbreviation_Singular AS UOM
				---	,'-----oooooo-----',CO.*,'-------------',RCD.* ,'-----ooooo---',PRO.*
			FROM Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO ON
				PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			INNER JOIN _Users U ON
				U.User_ID = CM.Responsible_User_ID
			LEFT JOIN Contract_Distributors CD ON
				CD.Contract_Main_ID = CM.Contract_Main_ID AND
				CD.Deleted = 0 AND
				CD.Captured_From_Group = 0
			LEFT JOIN BSA_Foodservice_Customers C ON
				C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
			INNER JOIN Contract_Products CP ON
				CP.Contract_Main_ID = CM.Contract_Main_ID AND
				CP.Deleted = 0 AND
				CP.Product_Type_ID = 1 AND --- Fixed
				CP.Captured_From_Group = 0
			INNER JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			INNER JOIN Program_Fixed_Component PFC ON
				PFC.Program_ID= CM.Contract_Main_Id
			INNER JOIN Program_Fixed_Component_Name PFCN ON
				PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON 
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					CP.Contract_Products_ID = PFPPD.Contract_Products_ID
			INNER JOIN Program_Formula_Pricing_Rules PFPR ON 
				PFPR.Program_ID = CM.Contract_Main_Id and
				pfpr.deleted = 0 
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
				and pfpr.Contract_Products_Id = CP.Contract_Products_ID
				</cfif>
			LEFT JOIN FP_Schedule_Options FSO ON
				FSO.FP_Schedule_Option_ID = PFPR.FP_Schedule_Option_ID
			LEFT JOIN FP_Formula_Types FFT ON
				FFT.FP_Formula_Type_ID = PFPR.FP_Formula_Type_ID
			INNER JOIN Program_Formula_Pricing_Rule_Comm_Data RCD ON 
				RCD.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND
				RCD.Deleted = 0
			LEFT JOIN FP_Formula_Types FT2 ON
				FT2.FP_Formula_Type_ID = RCD.FP_Formula_Type_ID
			INNER JOIN Commodities_Exchange_Detail CED ON
				CED.Exchange_Detail_ID = RCD.Exchange
			INNER JOIN Formula_Pricing_Commodity_Overage CO ON
				CO.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND
				RCD.Program_Formula_Pricing_Rule_Comm_Data_ID = co.Program_Formula_Pricing_Rule_Comm_Data_ID
			LEFT JOIN  Program_Formula_Pricing_Rule_Overage PRO ON 
					PRO.Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND 
					PRO.Deleted = 0 
					-- AND PRO.Overage_Index = (SELECT MAX(Overage_Index) From Program_Formula_Pricing_Rule_Overage 
					-- 						WHERE Program_Formula_Pricing_Rule_ID = pfpr.Program_Formula_Pricing_Rule_ID AND
					-- 						Deleted = 0 ) --- Just get one for the "Final_Price" Column
			LEFT JOIN Units_of_Measure uom on 
					uom.Unit_Of_Measure_ID = PFPPD.Unit_Of_Measure_ID
			WHERE  CM.Deleted = 0
				---AND CM.Contract_Status_Type_IDX  > 1
				AND CM.Contract_Status_Type_IDX  < 8
				AND	PFC.Deleted = 0
				AND PFCN.Formula_Pricing = 1
				and CM.Manual_Cancel = 0 
			--		AND DATEDIFF(DD,CM.Contract_Start_Date,getDate()) > -7
				AND DATEDIFF(DD,CM.Contract_End_Date,getDate()) < 0
			 -- AND COntract_number = 'PRG-1086044'
			order by cm.Contract_Main_ID,I.Item,RCD.Symbol, CO.Overage_Index
			</CFQUERY>
			<cfreturn application.util.query.toAgGridJSON(qGetFormulaProgramReport, 'Contract_number, Contract_Title, Contract_Start_Date, Contract_End_Date, Created_Type, Program_Fixed_Component_Name, RSP, Ship_To, Name, Price_Day_Description, Effective_Day_Description, Price_Day_Frequency, Formula_Type_Description, Calc_Type, Item, Description, Commodity, Weight, Comm_Overage_Desc, Comm_Overage, Overage_Calc_Type, Start_Price, Calculated_Comm_Overage, Comm_Price, Total_Comm_Price, Overage_Desc, Modification_Overage, Formula_Overage, Final_Price, Bracket_Price, UOM')>
	
	</cffunction>
	
	<cffunction name="getFormulaComponentFromProgram" hint="" access="public" output="false">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfscript>
			var a = arguments;
		</cfscript>
		<cfquery name="qGetFormulaComponent" datasource="#application.datasource#">
			select	DISTINCT pfcn.Program_Fixed_Component_Name, pfcn.Program_Fixed_Component_Name_ID, pfc.Program_Fixed_Component_ID
			from	Program_Fixed_Component pfc
					inner join Program_Fixed_Component_Name pfcn on pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
			where	pfc.Program_ID = '#a.contractId#'
			and		pfc.Deleted = 0
		</cfquery>
		
		<cfreturn qGetFormulaComponent />
	</cffunction>

	<cffunction name="getFormulaComponent" hint="" access="public" output="false">
		<cfargument name="formulaID" type="string" required="true" />
		<cfscript>
			var a = arguments;
		</cfscript>
		<cfquery name="qGetFormulaComponent" datasource="#application.datasource#">
			select	DISTINCT pfcn.Program_Fixed_Component_Name, pfcn.Program_Fixed_Component_Name_ID, pfc.Program_Fixed_Component_ID
			from	Program_Formula_Pricing_Rules pfpr
					inner join Program_Fixed_Component pfc on pfc.Program_Fixed_Component_ID = pfpr.Program_Fixed_Component_ID
					inner join Program_Fixed_Component_Name pfcn on pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
			where	pfpr.Program_Formula_Pricing_Rule_ID = '#a.formulaID#'
			and		pfpr.Deleted = 0		
		</cfquery>
		
	<cfreturn qGetFormulaComponent />
</cffunction>

</cfcomponent>