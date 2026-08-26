<CF_Cryp type="de" key="#request.key#" string="#FORM.Program_ID#">

<CFSET Rule_ID = FORM.Program_Formula_Pricing_Rule_ID>

<CFIF FORM.UPDATE EQ 1>
	<cfset useLakebaseFordeleteOldNewCommData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_comm_data")>
<cfif useLakebaseFordeleteOldNewCommData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rule_comm_data",
			{
				"program_id" = "eq.#cryp.value#",
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"active" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteOldNewCommData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteOldNewCommData>
<CFQUERY NAME="deleteOldNewCommData" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Comm_Data
		SET Deleted = 1
		WHERE 
			Program_ID = '#cryp.value#' 
			AND
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Active = 1
			AND
			Deleted = 0
	</CFQUERY>
</cfif>
<CFELSE>
	<CFQUERY NAME="deleteOldNewCommData" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Comm_Data
		SET Deleted = 1
		WHERE 
			Program_ID = '#cryp.value#' 
			AND
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Active = 0
			AND
			Deleted = 0
	</CFQUERY>
</CFIF>

<cfset useLakebaseFordeleteOldNewOverageData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_overage")>
<cfif useLakebaseFordeleteOldNewOverageData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rule_overage",
			{
				"program_id" = "eq.#cryp.value#",
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"active" = "eq.0",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteOldNewOverageData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteOldNewOverageData>
<CFQUERY NAME="deleteOldNewOverageData" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Rule_Overage
	SET Deleted = 1
	WHERE 
		Program_ID = '#cryp.value#' 
		AND
		Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND
		Active = 0
		AND
		Deleted = 0
</CFQUERY>
</cfif>

<CFIF FORM.UPDATE EQ 1>
	<cfset useLakebaseForupdateRules = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rules")>
<cfif useLakebaseForupdateRules>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rules",
			{
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"active" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"number_of_comms" = "#FORM.Number_Of_Comms#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateRules = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateRules>
<CFQUERY NAME="updateRules" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rules
		SET 
			Number_Of_Comms = '#FORM.Number_Of_Comms#'
		WHERE 
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Active = 1
			AND
			Deleted = 0
		
	</CFQUERY>
</cfif>
</CFIF>

<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Comms#" STEP="1">
	<CFSET thisExchange				= evaluate("FORM.EXCHANGE_#i#")>
	<CFSET thisSymbol				= evaluate("FORM.COMMODITY_#i#")>
	<CFSET thisPointInTIme			= evaluate("FORM.POINT_IN_TIME_#i#")>
	<!------<CFSET thisPointInTImeUOM		= evaluate("FORM.TIME_UOM_POINT_IN_TIME_#i#")>----->
	<CFSET thisPointInTImeUOM		= evaluate("FORM.Period_UOM_#i#")>	
	<CFSET thisSampleSize			= evaluate("FORM.SAMPLE_SIZE_#i#")>
	<!------<CFSET thisSampleSizeUOM		= evaluate("FORM.TIME_UOM_SAMPLE_SIZE_#i#")>----->
	<CFSET thisSampleSizeUOM		= evaluate("FORM.Period_UOM_#i#")>
	<CFSET thisWeight				= evaluate("FORM.Comm_weight_#i#")>

	<cfset useLakebaseForsaveNewCommData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_comm_data")>
<cfif useLakebaseForsaveNewCommData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_formula_pricing_rule_comm_data", {
			"program_id" = "#cryp.value#",
			"program_formula_pricing_rule_id" = "#Rule_ID#",
			"comm_count" = "#i#",
			"exchange" = "#thisExchange#",
			"symbol" = "#thisSymbol#",
			"point_in_time" = "#thisPointInTime#",
			"point_in_time_uom" = "#thisPointInTImeUOM#",
			"sample_size" = "#thisSampleSize#",
			"sample_size_uom" = "#thisSampleSizeUOM#",
			"weight" = "#thisWeight#",
			"active" = "#FORM.UPDATE#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveNewCommData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveNewCommData>
<CFQUERY NAME="saveNewCommData" datasource="#application.datasource#">
		INSERT INTO Program_Formula_Pricing_Rule_Comm_Data
		(
			Program_ID,
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
			#cryp.value#,
			'#Rule_ID#',
			#i#,
			'#thisExchange#',
			'#thisSymbol#',
			'#thisPointInTime#',
			'#thisPointInTImeUOM#',
			'#thisSampleSize#',
			'#thisSampleSizeUOM#',
			'#thisWeight#',
			#FORM.UPDATE#
		)
	</CFQUERY>
</cfif>
</CFLOOP>


<CFIF FORM.UPDATE EQ 1>
	<!------<cfset useLakebaseFordeleteExisting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_overage")>
<cfif useLakebaseFordeleteExisting>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_formula_pricing_rule_overage", {
			"program_id" = "eq.#cryp.value#",
			"active" = "eq.1",
			"deleted" = "eq.0"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteExisting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteExisting>
<CFQUERY NAME="deleteExisting" datasource="#application.datasource#">
		DELETE FROM Program_Formula_Pricing_Rule_Overage
		WHERE
		Program_ID = '#cryp.value#' 
		AND
		Active = 1
		AND
		Deleted = 0
	</CFQUERY>
</cfif>----->
	<CFQUERY NAME="deleteExisting" datasource="#application.datasource#">
		UPDATE 		Program_Formula_Pricing_Rule_Overage
		SET
					Deleted = 1,
					Active 	= 0
		WHERE
					Program_ID = '#cryp.value#' 
					AND
					Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
					AND
					Active = 1
					AND
					Deleted = 0
	</CFQUERY>
</CFIF>

<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
	<CFIF Isdefined("FORM.independent_amount_uom#i#_1")>
		
		

		<CFSET thisDescription = evaluate("FORM.INDEPENDENT_DESC_CALC#i#_1")>
		<CFSET thisAmount = evaluate("FORM.independent_amount_calc#i#_1")>
		<CFSET thisUOM = evaluate("FORM.independent_amount_uom#i#_1")>
			<CFIF len(trim(thisDescription)) GT 0 AND len(trim(thisAmount)) GT 0>
			<cfset useLakebaseForsaveOverageData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_overage")>
<cfif useLakebaseForsaveOverageData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_formula_pricing_rule_overage", {
			"program_formula_pricing_rule_id" = "#FORM.Program_Formula_Pricing_Rule_ID#",
			"program_id" = "#cryp.value#",
			"overage_index" = "#i#",
			"description" = "#thisDescription#",
			"amount" = "#thisAmount#",
			"uom" = "#thisUOM#",
			"active" = "#FORM.UPDATE#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveOverageData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveOverageData>
<CFQUERY NAME="saveOverageData" datasource="#application.datasource#">
				INSERT INTO Program_Formula_Pricing_Rule_Overage
				(
					Program_Formula_Pricing_Rule_ID,
					Program_ID,
					Overage_Index,
					Description,
					Amount,
					UOM,
					Active
				)
				VALUES
				(
					'#FORM.Program_Formula_Pricing_Rule_ID#',
					'#cryp.value#',
					'#i#',
					'#thisDescription#',
					'#thisAmount#',
					'#thisUOM#',
					#FORM.UPDATE#
				)
			</CFQUERY>
</cfif>
		</CFIF>
	</CFIF>
</CFLOOP>

<CFSET generateReleaseProgramID = cryp.value>
<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">

<CF_CRYP type="en" key="#request.key#" string="#FORM.Program_Formula_Pricing_Rule_ID#">
<CFSET Rule_ID=cryp.value>

<CFIF FORM.UPDATE EQ 1>
	<!------<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.Program_ID#">----->
	<CFLOCATION URL="Formula_Pricing_Index_Rule_Summary.cfm?CID=#FORM.Program_ID#&RID=#Rule_ID#">
<CFELSE>
	<CFLOCATION URL="Contract_Formula_Rule_Step_3.cfm?CID=#FORM.Program_ID#&RID=#Rule_ID#">
</CFIF>