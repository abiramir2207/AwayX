<!------ Application_Vars.cfm ----->

<!------ 
<cfset application.CompanyNameFull="Awayx Solution, Inc.">
<cfset application.CompanyName="Awayx Solution">
<cfset application.CompanyLogo="/images/Header_Footer_New/awayx_logo.gif">
<cfset application.CompanyWebsiteURL="http://www.awayx.com">
<cfset application.CompanyWebsite="www.awayx.com">
<cfset application.CompanyEmailSuffix="awayx.com">
<cfset application.CompanyOtherSuffix="awayx.com">
----->
<cfset application.datasource="Resers"><!---  awayx"  :: sirius_McCain :: awayx_McCain  :: sirius_McCain--->
<cfset application.CompanyNameFull="Blacksmith Applications, Inc.">
<cfset application.CompanyName="Blacksmith Applications">
<cfset application.CompanyLogo="/images/Header_Footer_New/redflame_small.gif">
<cfset application.CompanyWebsiteURL="http://www.blacksmithapps.com">
<cfset application.CompanyWebsite="www.blacksmithapps.com">
<cfset application.CompanyEmailSuffix="bigredflame.com">
<cfset application.CompanyOtherSuffix="blacksmithapps.com">
<cfset application.WebServerName="10.40.1.8"><!--- Give your WebServerName --->
<!--- don't change this, otherwise fax won't work --->
<cfset application.CompanyFaxFromEmail="chainlink@awayx.com">
<!--- don't change this, otherwise fax won't work --->
<cfset APPLICATION.masterDataCacheSpan = CreateTimeSpan(0, 12, 0, 0) />
<cfset APPLICATION.userDataCacheSpan = CreateTimeSpan(0, 12, 0, 0) />


<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth START ADD 1, 4 --->
<CFQUERY NAME = "GetRebateLabel" DATASOURCE = "#Application.Datasource#"><!---  CACHEDWITHIN = "#CreateTimeSpan(1, 0, 0, 0)#" --->
	SELECT 	Discount_Type_ID,
			Discount_Type_Desc

	FROM 	Discount_Type

	WHERE 	Discount_Type_ID IN (<cfqueryparam value="1,2,3,4" cfsqltype="CF_SQL_INTEGER" list="Yes">)
</CFQUERY>

<CFLOOP QUERY="GetRebateLabel">
	<CFIF Discount_Type_ID EQ 1>
		<CFSET Application.FixedPriceLabel 	= Discount_Type_Desc>
	</CFIF>
	<CFIF Discount_Type_ID EQ 2>
		<CFSET Application.RebateLabel 		= Discount_Type_Desc>
	</CFIF>
	<CFIF Discount_Type_ID EQ 3>
		<CFSET Application.LumpsumLabel 	= Discount_Type_Desc>
	</CFIF>
	<CFIF Discount_Type_ID EQ 4>
		<CFSET Application.GrowthLabel 		= Discount_Type_Desc>
	</CFIF>
</CFLOOP>
<!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth END --->

<!------ Temporary switch to turn on and off 'operator variables' links and options ----->
<cfset application.operatorVariableAvailable = 1>

<!--- 24075 set Deduction Module on App settings 
<!------ Temporary switch to turn on and off 'deduction' links and options ----->
<cfset application.deductionLinksAvailable = 1><!------ pls don't turn this on until the deduction is schema is in all environments ----->
--->

<!------ Temporary switch to turn on and off 'futuresPricing' links and options ----->
<cfset application.futuresPricingLinksAvailable = 1>

<!------ Temporary switch to turn on and off 'bid pricing' links and options ----->
<cfset application.bidPricingLinksAvailable = 0>

<!------ Temporary switch to turn on and off 'Auto Billback' links and options ----->
<cfset application.AutoBillbackLinksAvailable = 0>

<!------ Temporary switch to turn on and off 'Pay Multiple Billbacks' links and options ----->
<CFSET application.PaymentRequestWithMultiBBLinksAvailable = 1>

<!------ Temporary switch to turn on and off 'Personalization' links and options ----->
<cfset application.Personalization = 0>

<!------ Temporary switch to turn on and off 'Bid Request' links and options ----->
<cfset application.BidRequest = 1>

<!------ Temporary switch to turn on and off 'Duplicate Program Check' links and options ----->
<cfset application.Check_Duplicate_Program = 1>

<!------ Temporary switch to turn on and off 'Invoice Reports' links and options ----->
<cfset application.InvoiceReportsLinksAvailable = 1>

<cfset application.programlayout = 1>

<!------ Temporary switch to turn on and off 'Program Performance Indicator' links and options ----->
<cfset application.ProgramPerformanceIndicatorLinksAvailable = 1>

<!------ Temporary switch to turn on and off revisionreport ----->
<cfset application.revisionreport="1">


<!---D36632  --->
<cfset useLakebaseForGetUOMLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGetUOMLabel>
	<cftry>
		<cfset GetUOMLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", { "unit_of_measure_id" = "in.(1,2)" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetUOMLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUOMLabel>
	<CFQUERY NAME = "GetUOMLabel" DATASOURCE = "#Application.Datasource#">
	SELECT *
	FROM Units_of_Measure
	WHERE Unit_of_Measure_ID IN (1,2)
	</CFQUERY>
</cfif>

<CFLOOP QUERY="GetUOMLabel">
	<CFIF Unit_of_Measure_ID EQ 1>
							<cfset Application.UOMCaseSingular  = Unit_of_Measure_Desc_Singular>
				     		<cfset Application.UOMCasePlural  = Unit_of_Measure_Desc>
				     		<cfset Application.UOMCaseAbrSingular  = Abbreviation_Singular>
				     		<cfset Application.UOMCaseAbrPlural  = Abbreviation>
	</CFIF>
	<CFIF Unit_of_Measure_ID EQ 2>
				     		<cfset Application.UOMPoundSingular  = Unit_of_Measure_Desc_Singular>
				     		<cfset Application.UOMPoundPlural  = Unit_of_Measure_Desc>
				     		<cfset Application.UOMPoundAbrSingular  = Abbreviation_Singular>
				     		<cfset Application.UOMPoundAbrPlural  = Abbreviation>
	</CFIF>
</CFLOOP>
<!--- D36632  --->
<!--- D43704 :: Create label name for 'Growth Bonus' in labeling tool --->
<cfset useLakebaseForGetGeneralLabels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_labels")>
<cfif useLakebaseForGetGeneralLabels>
	<cftry>
		<cfset GetGeneralLabels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_labels", { "general_labels_desc" = "in.(""GL Account"",""Bonus"")", "select" = "general_labels_label,general_labels_desc" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetGeneralLabels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetGeneralLabels>
	<CFQUERY NAME = "GetGeneralLabels" DATASOURCE = "#Application.Datasource#">
		SELECT General_Labels_Label, General_Labels_desc
		FROM General_Labels
		WHERE General_Labels_desc IN('GL Account', 'Bonus')
	</CFQUERY>
</cfif>
<cfloop Query="GetGeneralLabels">
	<cfif GetGeneralLabels.General_Labels_desc EQ 'GL Account'>
		<cfset Application.GLAccountLabel  = General_Labels_Label>		
	<cfelseif GetGeneralLabels.General_Labels_desc EQ 'Bonus'>
		<cfset Application.BonusLabel  = General_Labels_Label>	
	</cfif>		 
</cfloop>	
<!--- D43704 :: Create label name for 'Growth Bonus' in labeling tool --->
<cfquery name="qPlannerLabels" datasource="#Application.Datasource#">
	SELECT 	Planner_Labels_ID,
			Planner_Labels_Desc,
			Planner_Labels_Singular =
			CASE
				WHEN Planner_Labels_Singular IS NULL OR LEN(LTRIM(RTRIM(Planner_Labels_Singular))) = 0 THEN Planner_Labels_Desc
				ELSE Planner_Labels_Singular
			END
			,Planner_Labels_Plural =
			CASE
				WHEN Planner_Labels_Plural IS NULL OR LEN(LTRIM(RTRIM(Planner_Labels_Plural))) = 0 THEN Planner_Labels_Desc
				ELSE Planner_Labels_Plural
			END
	FROM 	Planner_Labels
	WHERE	0 = 0
	AND		Planner_Labels_Desc IN('Planner', 'Program', 'Component', 'Lump Sum', 'Est Trade')
</cfquery>

<cfloop Query="qPlannerLabels">
	<cfif qPlannerLabels.Planner_Labels_Desc EQ 'Planner'>
		<cfset Application.PlannerLabel  = qPlannerLabels.Planner_Labels_Singular>
		<cfset Application.PlannerLabel_Plural  = qPlannerLabels.Planner_Labels_Plural>
	<cfelseif qPlannerLabels.Planner_Labels_Desc EQ 'Program'>
		<cfset Application.PlannerPrgLabel  = qPlannerLabels.Planner_Labels_Singular>
		<cfset Application.PlannerPrgLabel_Plural  = qPlannerLabels.Planner_Labels_Plural>
	<cfelseif qPlannerLabels.Planner_Labels_Desc EQ 'Component'>
		<cfset Application.PlannerCompLabel  = qPlannerLabels.Planner_Labels_Singular>
		<cfset Application.PlannerCompLabel_Plural  = qPlannerLabels.Planner_Labels_Plural>
	<cfelseif qPlannerLabels.Planner_Labels_Desc EQ 'Est Trade'>
		<cfset Application.PlannerEstTradeLabel  = qPlannerLabels.Planner_Labels_Singular>
		<cfset Application.PlannerEstTradeLabel_Plural  = qPlannerLabels.Planner_Labels_Plural>
	<cfelse>
		<cfset Application.PlannerLSLabel  = qPlannerLabels.Planner_Labels_Singular>
		<cfset Application.PlannerLS_Plural  = qPlannerLabels.Planner_Labels_Plural>
	</cfif>
</cfloop>


<!------
we created the file Application_Settings_Initialise.cfm so that we do not have to modify Application_Vars.cfm file at all.
If Application_Vars.cfm file is modified then we always have problem while building......
----->
<cfinclude template="Application_Settings_Initialise.cfm" />
