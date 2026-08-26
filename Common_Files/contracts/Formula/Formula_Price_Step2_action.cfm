
<!------Formula_Price_Step2_action.cfm----->
<CFSET Rule_ID = FORM.Program_Formula_Pricing_Rule_ID>

<CFOUTPUT>

	<cfscript>
		appSettings 	= application.appSettingsGet;
		oFormulaItem    = CreateObject("component", "mvc.Models.Program.FormulaItemLevel");
	</cfscript>


<CFTRANSACTION ACTION="BEGIN">
	<CFIF IsDefined("FORM.Rule_Name")>
		<CFINCLUDE TEMPLATE="Formula_Price_Step1_Save.cfm">
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
	
	<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
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
	<cfelse>
		<CFQUERY NAME="Delete_Old_Comm_Overage" DATASOURCE="#application.datasource#">
			UPDATE Program_Formula_Pricing_Rules
			SET		Number_Of_Comms = #Form.NUMBER_OF_COMMS#
			WHERE	Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		</CFQUERY>

	</cfif>

	<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Comms#" STEP="1">
		<CFSET thisExchange				= evaluate("FORM.EXCHANGE_#i#")>
		<CFSET thisSymbol				= evaluate("FORM.COMMODITY_#i#")>
		<!---<CFSET thisPointInTIme			= evaluate("FORM.POINT_IN_TIME_#i#")>
		<CFSET thisPointInTImeUOM		= evaluate("FORM.Period_UOM_#i#")>	
		<CFSET thisSampleSize			= evaluate("FORM.SAMPLE_SIZE_#i#")>
		<CFSET thisSampleSizeUOM		= evaluate("FORM.Period_UOM_#i#")> --->
		<CFSET thisWeight				= evaluate("FORM.Comm_weight_#i#")>
		<CFSET thisCommoditiesSymbolID	= evaluate("FORM.Commodities_Symbol_ID_#i#")>
		<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
			<CFSET thisFP_Formula_Type_ID	= evaluate("FORM.FP_Formula_Type_ID_#i#")>
		</CFif>
	
		<CFQUERY NAME="saveNewCommData" datasource="#application.datasource#">	
			INSERT INTO Program_Formula_Pricing_Rule_Comm_Data
			(
				Program_Formula_Pricing_Rule_ID,
				Program_Id,
				Comm_Count,
				Exchange,
				Symbol,
			<!---	Point_In_Time,
				Point_In_Time_UOM,
				Sample_Size,
				Sample_Size_UOM, --->
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
				<!---'#thisPointInTime#',
				'#thisPointInTImeUOM#',
				'#thisSampleSize#',
				'#thisSampleSizeUOM#', --->
				'#thisWeight#',
				1,
				#thisCommoditiesSymbolID#
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
					,'#thisFP_Formula_Type_ID#'
				</cfif>
			)
		</CFQUERY>
		<CFSET This_Program_Formula_Pricing_Rule_Comm_Data_ID = saveNewCommData.Program_Formula_Pricing_Rule_Comm_Data_ID>
		<!------------ independent ----------->
		<cfparam name="form.dyn_comm_count_#i#" default="4" />
		<CFLOOP INDEX="j" FROM="1" TO="#evaluate("form.dyn_comm_count_#i#")#" STEP="1">
			<CFIF Isdefined("FORM.comm_independent_amount_uom#j#_#i#")>
				<CFSET thisDescription = Trim(evaluate("FORM.comm_INDEPENDENT_DESC_CALC#j#_#i#"))>
				<CFSET thisAmount = Trim(evaluate("FORM.comm_independent_amount_calc#j#_#i#"))>
				<CFSET thisUOM = Trim(evaluate("FORM.comm_independent_amount_uom#j#_#i#"))>
				<CFIF len(trim(thisDescription)) GT 0 AND len(trim(thisAmount)) GT 0 AND IsNumeric(thisAmount)>
					<CFQUERY NAME="Insert_Formula_Pricing_Commodity_Overage" DATASOURCE="#application.datasource#">
						INSERT INTO	Formula_Pricing_Commodity_Overage
						(
							Program_Formula_Pricing_Rule_ID,
							Program_Formula_Pricing_Rule_Comm_Data_ID,
							Overage_Index,
							Description,
							Amount,
							UOM,
							Calc_Type
						)
						VALUES
						(
							'#Rule_ID#',
							'#This_Program_Formula_Pricing_Rule_Comm_Data_ID#',
							#j#,
							'#thisDescription#', 
							#thisAmount#, 
							'#thisUOM#',
							1
						)
					</CFQUERY>
				<CFELSE>
					<CFBREAK>
				</CFIF>
			</CFIF>
		</CFLOOP>
		
		<!------------ compounded ----------->
		<cfparam name="form.dyn_comm_count_#i#" default="4" />
		<CFLOOP INDEX="j" FROM="1" TO="#evaluate("form.dyn_comm_count_#i#")#" STEP="1">
			<CFIF Isdefined("FORM.comm_COMPOUNDED_amount_uom#j#_#i#")>
				<CFSET thisDescription = Trim(evaluate("FORM.comm_compounded_DESC_CALC#j#_#i#"))>
				<CFSET thisAmount = Trim(evaluate("FORM.comm_compounded_amount_calc#j#_#i#"))>
				<CFSET thisUOM = Trim(evaluate("FORM.comm_compounded_amount_uom#j#_#i#"))>
				<CFIF len(trim(thisDescription)) GT 0 AND len(trim(thisAmount)) GT 0 AND IsNumeric(thisAmount)>
					<CFQUERY NAME="Insert_Formula_Pricing_Commodity_Overage" DATASOURCE="#application.datasource#">
						INSERT INTO	Formula_Pricing_Commodity_Overage
						(
							Program_Formula_Pricing_Rule_ID,
							Program_Formula_Pricing_Rule_Comm_Data_ID,
							Overage_Index,
							Description,
							Amount,
							UOM,
							Calc_Type
						)
						VALUES
						(
							'#Rule_ID#',
							'#This_Program_Formula_Pricing_Rule_Comm_Data_ID#',
							#j#,
							'#thisDescription#', 
							#thisAmount#, 
							'#thisUOM#',
							2
						)
					</CFQUERY>
				<CFELSE>
					<CFBREAK>
				</CFIF>
			</CFIF>
		</CFLOOP>
	</CFLOOP>

	<CFQUERY NAME="Delete_Old_Overage" DATASOURCE="#application.datasource#">
		UPDATE	Program_Formula_Pricing_Rule_Overage
		SET		Deleted = 1
		WHERE
				Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	</CFQUERY>
	<!------------ independent ----------->
	<cfparam name="form.dyn_mod_comm_count_1001" default="4" />
	<CFLOOP INDEX="i" FROM="1" TO="#form.dyn_mod_comm_count_1001#" STEP="1">
		<CFIF Isdefined("FORM.independent_amount_uom#i#_1")>
			<CFSET thisDescription = Trim(evaluate("FORM.INDEPENDENT_DESC_CALC#i#_1"))>
			<CFSET thisAmount = Trim(evaluate("FORM.independent_amount_calc#i#_1"))>
			<CFSET thisUOM = Trim(evaluate("FORM.independent_amount_uom#i#_1"))>
				<CFIF len(trim(thisDescription)) GT 0 AND len(trim(thisAmount)) GT 0>
				<CFQUERY NAME="saveOverageData" datasource="#application.datasource#">
					INSERT INTO Program_Formula_Pricing_Rule_Overage
					(
						Program_Formula_Pricing_Rule_ID,
						Overage_Index,
						Description,
						Amount,
						UOM,
						Active,
						Calc_Type,
						Program_Id
					)
					VALUES
					(
						'#Rule_ID#',
						'#i#',
						'#thisDescription#',
						'#thisAmount#',
						'#thisUOM#',
						1,
						1,
						#Form.Program_Id#
					)
				</CFQUERY>
			<CFELSE>
					<CFBREAK>
			</CFIF>
		</CFIF>
	</CFLOOP>
	<!------------ compounded ----------->
	<CFLOOP INDEX="i" FROM="1" TO="#form.dyn_mod_comm_count_1001#" STEP="1">
		<CFIF Isdefined("FORM.compounded_amount_uom#i#_1")>
			<CFSET thisDescription = Trim(evaluate("FORM.compounded_DESC_CALC#i#_1"))>
			<CFSET thisAmount = Trim(evaluate("FORM.compounded_amount_calc#i#_1"))>
			<CFSET thisUOM = Trim(evaluate("FORM.compounded_amount_uom#i#_1"))>
				<CFIF len(trim(thisDescription)) GT 0 AND len(trim(thisAmount)) GT 0>
				<CFQUERY NAME="saveOverageData" datasource="#application.datasource#">
					INSERT INTO Program_Formula_Pricing_Rule_Overage
					(
						Program_Formula_Pricing_Rule_ID,
						Overage_Index,
						Description,
						Amount,
						UOM,
						Active,
						Calc_Type,
						Program_Id
					)
					VALUES
					(
						'#Rule_ID#',
						'#i#',
						'#thisDescription#',
						'#thisAmount#',
						'#thisUOM#',
						1,
						2,
						#Form.Program_Id#
					)
				</CFQUERY>
			<CFELSE>
					<CFBREAK>
			</CFIF>
		</CFIF>
	</CFLOOP>
		<CFTRANSACTION ACTION="COMMIT">
	</CFTRANSACTION>

	
	<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
		<cfstoredproc procedure="Formula_Price_Calculation" datasource="#application.datasource#"> 
		<cfprocparam 
		    cfsqltype="cf_sql_numeric"  
		    value="#Form.Program_Id#"> 
		<!---<cfprocparam 
			cfsqltype="CF_SQL_DATE"  
			value="#now()#"> --->
		</cfstoredproc>
	<cfelse>
		<!--- call function to handle for retro active pricing --->
		<cfset oFormulaItem.saveFormulaPriceItemCalculation(Form.Program_Id, Rule_ID) />
	</cfif>
</CFOUTPUT>
<CFLOCATION URL="Formula_Display.cfm?Formula_ID=#Rule_ID#&Program_Id=#Form.Program_Id#" ADDTOKEN="No">