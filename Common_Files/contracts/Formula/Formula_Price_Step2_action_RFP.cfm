<!------Formula_Price_Step2_action.cfm----->
<CFSET Rule_ID = FORM.Program_Formula_Pricing_Rule_ID>

<CFOUTPUT>
	<cfscript>
		appSettings = application.appSettingsGet;
	</cfscript> 
<CFTRANSACTION ACTION="BEGIN">
	<CFIF IsDefined("FORM.Rule_Name")>
		<CFINCLUDE TEMPLATE="Formula_Price_Step1_Save_RFP.cfm">
	</CFIF>
	<CFQUERY NAME="Delete_Old_Comm" DATASOURCE="#application.datasource#">
		UPDATE	Program_Formula_Pricing_Rule_Comm_Data
		SET		Deleted = 1
		WHERE
				Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	</CFQUERY>
	
	<CFQUERY NAME="Delete_Old_Comm_Overage" DATASOURCE="#application.datasource#">
		UPDATE	Formula_Pricing_Commodity_Overage
		SET		Deleted = 1
		WHERE
				Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	</CFQUERY>
	
	
	<CFQUERY NAME="Upd_Comm_Overage" DATASOURCE="#application.datasource#">
		UPDATE R
		SET		Number_Of_Comms = #Form.NUMBER_OF_COMMS#
				---- ,Rule_Name	=  'FRM-' + I.Item 
		FROM Program_Formula_Pricing_Rules R
		Inner Join Contract_Main CM ON CM.Contract_Main_Id = R.Program_Id
		INNER JOIN Contract_Products CP ON CP.contract_products_id = R.contract_products_id
		INNER JOIN BSA_Foodservice_Items_Master I ON i.bsa_FoodService_Items_Master_Id = cp.bsa_FoodService_Items_Master_Id
		WHERE	Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	</CFQUERY>

	<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Comms#" STEP="1">
		<CFSET thisExchange				= evaluate("FORM.EXCHANGE_#i#")>
		<CFSET thisSymbol				= evaluate("FORM.COMMODITY_#i#")>
		<CFSET thisWeight				= evaluate("FORM.Comm_weight_#i#")>
		<CFSET thisCommoditiesSymbolID	= evaluate("FORM.Commodities_Symbol_ID_#i#")>
		<CFSET thisFP_Formula_Type_ID	= evaluate("FORM.FP_Formula_Type_ID_#i#")>
	
		<CFQUERY NAME="saveNewCommData" datasource="#application.datasource#">	
			INSERT INTO Program_Formula_Pricing_Rule_Comm_Data
			(
				Program_Formula_Pricing_Rule_ID,
				Program_Id,
				Comm_Count,
				Exchange,
				Symbol,
				Weight,
				Active,
				Commodities_Symbol_ID
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
					,FP_Formula_Type_ID
				</cfif>
			)
			VALUES
			(
				'#Rule_ID#',
				#Form.Program_Id#,
				#i#,
				'#thisExchange#',
				'#thisSymbol#',
				'#thisWeight#',
				1,
				#thisCommoditiesSymbolID#
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
					,'#thisFP_Formula_Type_ID#'
				</cfif>
			)
		</CFQUERY>
		<CFSET This_Program_Formula_Pricing_Rule_Comm_Data_ID = saveNewCommData.Program_Formula_Pricing_Rule_Comm_Data_ID>
	</CFLOOP>
		<CFTRANSACTION ACTION="COMMIT">
	</CFTRANSACTION>
		<cfstoredproc procedure="Formula_Price_RFP_Calculation" datasource="#application.datasource#"> 
		<cfprocparam 
		    cfsqltype="CF_SQL_VARCHAR"  
		    value="#Rule_ID#"> 
		</cfstoredproc>

</CFOUTPUT>
<CFLOCATION URL="Formula_Display_RFP.cfm?Formula_ID=#Rule_ID#&Program_Id=#Form.Program_Id#&Contract_Products_Id=#Form.Contract_Products_Id#" ADDTOKEN="No">