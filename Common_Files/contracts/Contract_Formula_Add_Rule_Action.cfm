<!------Contract_Formula_Add_Rule_Action.cfm----->

<CFPARAM NAME="FORM.New_Formula_Pricing_Rule_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.CID" 	DEFAULT="">
<cf_cryp type="de" key="#request.key#" string="#FORM.CID#">
<CFIF FORM.CID NEQ ""> 
	<CFSET Program_ID = cryp.value>
<CFELSE>
	<CFOUTPUT>
	Invalid Program ID
	</CFOUTPUT>
	<CFABORT>
</CFIF>

<CFIF FORM.New_Formula_Pricing_Rule_ID NEQ "">
	<CFSET Insert_Rule = true>
	<CFIF IsDefined("FORM.Rule_ID")>
		<CFIF FORM.Rule_ID NEQ "">
			<CFSET Insert_Rule = false>
		</CFIF>
	</CFIF>
	<CFIF NOT Insert_Rule>
		<!---- update ---->
		<cfset useLakebaseForUpdate_Rule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_mapped")>
<cfif useLakebaseForUpdate_Rule>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rule_mapped",
			{
				"program_formula_pricing_rule_mapped_id" = "eq.#FORM.Rule_ID#"
			},
			{
				"formula_pricing_rule_id" = "#FORM.New_Formula_Pricing_Rule_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Rule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Rule>
<CFQUERY NAME="Update_Rule" DATASOURCE="#application.datasource#">
			UPDATE	Program_Formula_Pricing_Rule_Mapped
			SET		Formula_Pricing_Rule_ID = '#FORM.New_Formula_Pricing_Rule_ID#'
			WHERE
					Program_Formula_Pricing_Rule_Mapped_ID = '#FORM.Rule_ID#'
		</CFQUERY>
</cfif>
		
		<CFSET generateReleaseProgramID = Program_ID>
		<CFSET generateRelease_GeneratePrices = 1>
		<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">

		<CF_Cryp type="en" key="#request.key#" string="#FORM.Rule_ID#">
		<CFLOCATION URL="Formula_Pricing_Index_Rule_Summary.cfm?CID=#FORM.CID#&RID=#cryp.value#">
	<CFELSE>
		<!---- insert ---->
		<cfset useLakebaseForGet_Rule_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_mapped")>
<cfif useLakebaseForGet_Rule_ID>
	<cftry>
		<cfset Get_Rule_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_rule_mapped", {
				"program_id" = "eq.#Program_ID#",
				"deleted" = "eq.0",
				"formula_pricing_rule_id" = "eq.#FORM.New_Formula_Pricing_Rule_ID#",
				"select" = "program_formula_pricing_rule_mapped_id"
			}), "program_formula_pricing_rule_mapped_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Rule_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Rule_ID>
<CFQUERY NAME="Get_Rule_ID" DATASOURCE="#application.datasource#">
			SELECT	Program_Formula_Pricing_Rule_Mapped_ID
			FROM	Program_Formula_Pricing_Rule_Mapped
			WHERE
					Program_Formula_Pricing_Rule_Mapped.Program_ID = #Program_ID#
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					AND
					Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = '#FORM.New_Formula_Pricing_Rule_ID#'
		</CFQUERY>
</cfif>
		<CFIF Get_Rule_ID.RecordCount GT 0>
			<CFSET FORM.Program_Formula_Pricing_Rule_ID = Get_Rule_ID.Program_Formula_Pricing_Rule_Mapped_ID>
		<CFELSE>
			<CFQUERY NAME="Save_Rule" DATASOURCE="#application.datasource#">
				INSERT INTO
				Program_Formula_Pricing_Rule_Mapped(Program_ID, Formula_Pricing_Rule_ID)
				VALUES (#Program_ID#, '#FORM.New_Formula_Pricing_Rule_ID#')
			</CFQUERY>
			<CFSET FORM.Program_Formula_Pricing_Rule_ID = Save_Rule.Program_Formula_Pricing_Rule_Mapped_ID>
		</CFIF>
	</CFIF>
</CFIF>
