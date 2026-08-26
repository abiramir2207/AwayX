<!--- 
	1. remove any existing periods for this program
	2. loop through form supplied periods

 --->

<CF_Cryp type="de" key="#request.key#" string="#FORM.PROGRAM_ID#">
<CFSET FORM.Program_ID = cryp.value>


<cfset useLakebaseFordeletedExistingPeriods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseFordeletedExistingPeriods>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_periods",
			{
				"program_id" = "eq.#FORM.Program_ID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1",
				"active" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletedExistingPeriods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletedExistingPeriods>
<CFQUERY NAME="deletedExistingPeriods" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Periods
	SET DELETED = 1, Active = 0
	WHERE 
		Program_ID = #FORM.Program_ID#
		AND Deleted = 0
</CFQUERY>
</cfif>

<CFLOOP INDEX="i" FROM="1" TO="#FORM.NUMBER_OF_PERIODS#" STEP="1">
	<CFIF IsDefined("FORM.PERIOD_LENGTH_#i#")>
		<CFSET thisDuration  	= evaluate("FORM.PERIOD_LENGTH_#i#")>
		<CFSET thisStart  		= evaluate("FORM.PERIOD_STARTING_DATE_#i#")>
		<CFSET thisEnd  		= evaluate("FORM.PERIOD_ENDING_DATE_#i#")>
		<CFSET thisRelease  	= evaluate("FORM.PERIOD_RELEASE_DATE_#i#")>
	
			<CFQUERY NAME="saveNewPeriod" datasource="#application.datasource#">
			INSERT INTO Program_Formula_Pricing_Periods
			(
				Program_ID,
				Duration,
				Start_Date,
				End_Date,
				Release_Date,
				Active
			)
			VALUES
			(
				'#FORM.PROGRAM_ID#',
				'#thisDuration#',
				'#thisStart#',
				'#thisEnd#',
				'#thisRelease#',
				1
			)
		</CFQUERY>
	</CFIF>
</CFLOOP>

<!------
don't have to release at this time, as the program should not be active at this time.
if the program is active, the user should not be editing this program at all
<CFSET generateReleaseProgramID = FORM.Program_ID>
<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">
----->

<CFQUERY NAME="getPricingRules" datasource="#application.datasource#">
	SELECT 	Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID, Formula_Pricing_Rule.*
	FROM 	Program_Formula_Pricing_Rule_Mapped
			INNER JOIN Formula_Pricing_Rule
			ON
			Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
			AND
			Formula_Pricing_Rule.Deleted = 0
	WHERE 
		Program_Formula_Pricing_Rule_Mapped.Program_ID = #FORM.PROGRAM_ID#
		AND
		Program_Formula_Pricing_Rule_Mapped.Deleted = 0
</CFQUERY>

<CFIF getPricingRules.RecordCount GT 0>
	<CFSET generateReleaseProgramID = Program_ID>
	<CFSET generateRelease_GeneratePrices = 1>
	<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">

	<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#cryp.string#">
<CFELSE>
	<CFLOCATION URL="Contract_Formula_Add_Rule.cfm?CID=#cryp.string#">
</CFIF>

<!------<CFLOCATION URL="Contract_Formula_Pricing_Periods_step_3.cfm?CID=#cryp.string#">----->