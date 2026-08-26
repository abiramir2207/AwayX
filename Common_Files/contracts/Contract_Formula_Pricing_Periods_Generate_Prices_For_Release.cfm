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
	<CFQUERY NAME="resetrulePrices" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Products
		SET Price = 0
		WHERE
			Program_ID						= '#generateReleaseProgramID#'
			AND Active = 1
			AND Deleted = 0
	</CFQUERY>
	
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
