<!--- 
	1. get active pricing periods
	2. loop through those periods
		if the row release date is today flag that releas date as active
			and store that date as the current release date
		else flag it as not active 
	3. if a release date is found generate the prices for the products
 --->


 
<CFPARAM NAME="generateReleaseProgramID" DEFAULT="0">
<CFPARAM NAME="generateRelease_GeneratePrices" DEFAULT="0">

<CFIF generateRelease_GeneratePrices EQ 0>
	<cfset useLakebaseForresetrulePrices = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_products")>
<cfif useLakebaseForresetrulePrices>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rule_products",
			{
				"program_id" = "eq.#generateReleaseProgramID#",
				"active" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"price" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForresetrulePrices = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForresetrulePrices>
<CFQUERY NAME="resetrulePrices" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Products
		SET Price = 0
		WHERE
			Program_ID						= '#generateReleaseProgramID#'
			AND Active = 1
			AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<cfset useLakebaseForgenerateReleasePrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForgenerateReleasePrograms>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_periods",
			{
				"program_id" = "eq.#generateReleaseProgramID#",
				"active" = "eq.1",
				"deleted" = "eq.0
			--AND
			--Created_By_System = 0

			EXEC PROGRAM_FORMULA_PRICING"
			},
			{
				"process_by_system" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgenerateReleasePrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgenerateReleasePrograms>
<CFQUERY NAME="generateReleasePrograms" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Periods
		SET Process_By_System = 0
		WHERE 
			Program_ID = '#generateReleaseProgramID#'
			AND
			Active = 1
			AND
			Deleted = 0
			--AND
			--Created_By_System = 0

			EXEC PROGRAM_FORMULA_PRICING
	</CFQUERY>
</cfif>
<CFELSE>

	<CFSET getInfoForProgramID 	= generateReleaseProgramID>
	<CFSET getInfoForPeriod 	= "any">
	<CFINCLUDE TEMPLATE="program_pricing_period_information.cfm">
	
	<CFIF periods.Requested_Period_Info.ValidData EQ 1>
		<CFSET release_Date=periods.Requested_Period_Info.Release_Date>
		<CFSET Program_ID = generateReleaseProgramID>
		<CFINCLUDE TEMPLATE="Formula_Price_Calculate.cfm">
	</CFIF>
		
</CFIF>
