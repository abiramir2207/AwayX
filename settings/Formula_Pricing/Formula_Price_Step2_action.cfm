<!------Formula_Price_Step2_action.cfm----->
<CFSET Rule_ID = FORM.Program_Formula_Pricing_Rule_ID>

<CFOUTPUT>


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

	<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Comms#" STEP="1">
		<CFSET thisExchange				= evaluate("FORM.EXCHANGE_#i#")>
		<CFSET thisSymbol				= evaluate("FORM.COMMODITY_#i#")>
		<CFSET thisPointInTIme			= evaluate("FORM.POINT_IN_TIME_#i#")>
		<CFSET thisPointInTImeUOM		= evaluate("FORM.Period_UOM_#i#")>	
		<CFSET thisSampleSize			= evaluate("FORM.SAMPLE_SIZE_#i#")>
		<CFSET thisSampleSizeUOM		= evaluate("FORM.Period_UOM_#i#")>
		<CFSET thisWeight				= evaluate("FORM.Comm_weight_#i#")>
	
		<CFQUERY NAME="saveNewCommData" datasource="#application.datasource#">	
			INSERT INTO Program_Formula_Pricing_Rule_Comm_Data
			(
				Program_Formula_Pricing_Rule_ID,
				Comm_Count,
				Exchange,
				Symbol,
				Point_In_Time,
				Point_In_Time_UOM,
				Sample_Size,
				Sample_Size_UOM,
				Weight,
				Active
			)
			VALUES
			(
				'#Rule_ID#',
				#i#,
				'#thisExchange#',
				'#thisSymbol#',
				'#thisPointInTime#',
				'#thisPointInTImeUOM#',
				'#thisSampleSize#',
				'#thisSampleSizeUOM#',
				'#thisWeight#',
				1
			)
		</CFQUERY>
		<CFSET This_Program_Formula_Pricing_Rule_Comm_Data_ID = saveNewCommData.Program_Formula_Pricing_Rule_Comm_Data_ID>
		
		<!------------ independent ----------->
		<CFLOOP INDEX="j" FROM="1" TO="4" STEP="1">
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
							#i#,
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
		<CFLOOP INDEX="j" FROM="1" TO="4" STEP="1">
			<CFIF Isdefined("FORM.comm_independent_amount_uom#j#_#i#")>
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
							#i#,
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
	<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
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
						Calc_Type
					)
					VALUES
					(
						'#Rule_ID#',
						'#i#',
						'#thisDescription#',
						'#thisAmount#',
						'#thisUOM#',
						1,
						1
					)
				</CFQUERY>
			<CFELSE>
					<CFBREAK>
			</CFIF>
		</CFIF>
	</CFLOOP>
	<!------------ compounded ----------->
	<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
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
						Calc_Type
					)
					VALUES
					(
						'#Rule_ID#',
						'#i#',
						'#thisDescription#',
						'#thisAmount#',
						'#thisUOM#',
						1,
						2
					)
				</CFQUERY>
			<CFELSE>
					<CFBREAK>
			</CFIF>
		</CFIF>
	</CFLOOP>
	<CFTRANSACTION ACTION="COMMIT">
</CFTRANSACTION>

</CFOUTPUT>

<CFLOCATION URL="index.cfm" ADDTOKEN="No">