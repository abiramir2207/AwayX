
<CF_Cryp type="de" key="#request.key#" string="#FORM.PROGRAM_ID#">
<CFSET FORM.Program_ID = cryp.value>

<cfset useLakebaseFordeactivateCurrentPeriods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseFordeactivateCurrentPeriods>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_periods",
			{
				"program_id" = "eq.#FORM.Program_ID#",
				"active" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1",
				"active" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeactivateCurrentPeriods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeactivateCurrentPeriods>
<CFQUERY NAME="deactivateCurrentPeriods" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Periods
	SET 
		DELETED = 1,
		ACTIVE = 0
	WHERE 
		Program_ID = #FORM.Program_ID#
		AND Active  = 1
		AND DELETED  = 0
</CFQUERY>
</cfif>

<cfset useLakebaseForactivateNewPeriods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForactivateNewPeriods>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_periods",
			{
				"program_id" = "eq.#FORM.Program_ID#",
				"active" = "eq.0",
				"deleted" = "eq.0"
			},
			{
				"active" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForactivateNewPeriods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForactivateNewPeriods>
<CFQUERY NAME="activateNewPeriods" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Periods
	SET 
		ACTIVE = 1
	WHERE 
		Program_ID = #FORM.Program_ID#
		AND Active  = 0
		AND DELETED  = 0
</CFQUERY>
</cfif>


<!--- <CFSET generateReleaseProgramID = FORM.Program_ID>
<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm"> --->

<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#cryp.string#">