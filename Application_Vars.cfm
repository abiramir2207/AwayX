<!------ Application_Vars.cfm ----->
<cfscript>
    param name="application.appPath" default=expandpath("/");
    request.app_general_functions = CreateObject("component","components.general.General_Functions");

    // -----------------------------------------------------------------------------------------------------------------------------
    // 2021 July - retrieve datasource from a .config file so it is not in code
    // -----------------------------------------------------------------------------------------------------------------------------
    if(!structKeyExists(application,"datasource") || !structKeyExists(application,"WebServerName")){
    	awayx_config    = application.appPath & "/Awayx.config";
	    awayx           = deserializeJSON( fileRead( awayx_config ) );
	    application.datasource 		= awayx.datasource;
	    application.WebServerName	= awayx.WebServerName;
    }
    /* HARD CODED APP SETTINGS - Mostlt deprecated I am sure */
	if(!structKeyExists(application,"CompanyNameFull")){
				
		application.CompanyNameFull 	="TELUS";
		application.CompanyName 		="TELUS";
		application.CompanyLogo 		="";
		application.CompanyWebsiteURL 	="https://telus.com";
		application.CompanyWebsite 		="www.telus.com";
		application.CompanyEmailSuffix 	="bigredflame.com";
		application.CompanyOtherSuffix 	="blacksmithapplications.com";
		
		// application.CompanyNameFull 	="Blacksmith Applications, Inc.";
		// application.CompanyName 		="Blacksmith Applications";
		// application.CompanyLogo 		="/images/Header_Footer_New/redflame_small.gif";
		// application.CompanyWebsiteURL 	="http://www.blacksmithapps.com";
		// application.CompanyWebsite 		="www.blacksmithapps.com";
		// application.CompanyEmailSuffix 	="bigredflame.com";
		// application.CompanyOtherSuffix 	="blacksmithapps.com";
		application.CompanyFaxFromEmail ="chainlink@awayx.com";
		APPLICATION.masterDataCacheSpan = CreateTimeSpan(0, 12, 0, 0);
		APPLICATION.userDataCacheSpan 	= CreateTimeSpan(0, 12, 0, 0);
		application.operatorVariableAvailable				= 0;
		application.futuresPricingLinksAvailable			= 1;
		application.bidPricingLinksAvailable				= 0;
		application.AutoBillbackLinksAvailable				= 0;
		application.PaymentRequestWithMultiBBLinksAvailable = 1;
		application.Personalization							= 0;
		application.BidRequest 								= 0;
		application.Check_Duplicate_Program 				= 1;
		application.InvoiceReportsLinksAvailable 			= 1;
		application.programlayout 							= 1;
		application.ProgramPerformanceIndicatorLinksAvailable = 0;
		application.revisionreport 							= "1";
	}
	/* MVC STUFF */
	if (structKeyExists(application,"oController"))
	{
		application.oController.getObject("components.settings.ApplicationAppSettingsManager").init();
	}
	else
	{
		if(!structKeyExists(application,"oApplicationAppSettingsManager")){
			application.oApplicationAppSettingsManager = createObject("component", "components.settings.ApplicationAppSettingsManager").init();
		}
	}
</cfscript>

<cfif NOT StructKeyExists(Application, "FixedPriceLabel")>
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
</cfif>

<cfif NOT StructKeyExists(Application, "UOMCaseSingular")>
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
</cfif>

<cfif NOT StructKeyExists(Application, "GLAccountLabel")>
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
</cfif>

<cfif NOT StructKeyExists(Application, "PlannerLabel")>
	<cfscript>
		// predefine planner labels to avoid undefined variable errors on sites without planner features
		Application.PlannerLabel     = Application.PlannerLabel_Plural     = Application.PlannerPrgLabel      = Application.PlannerPrgLabel_Plural      = '';
		Application.PlannerCompLabel = Application.PlannerCompLabel_Plural = Application.PlannerEstTradeLabel = Application.PlannerEstTradeLabel_Plural = '';
		Application.PlannerLSLabel   = Application.PlannerLS_Plural        = '';
	</cfscript>

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
</cfif>

<cfif NOT StructKeyExists(Application, "Session_Expiration_Length")>
	<CFQUERY NAME="Get_Session_Window" datasource="#application.datasource#">
		SELECT	Session_Expiration_Length
		FROM	General_Settings
	</CFQUERY>

	<!--- If there is no data in the session expiration field, put 15 minutes in there --->
	<CFIF Get_Session_Window.recordcount EQ 0>
		<CFQUERY NAME="Get_Session_Window" datasource="#application.datasource#">
			Update	General_Settings
			Set		Session_Expiration_Length		=	<cfqueryparam value="0.0104166666666" cfsqltype="CF_SQL_FLOAT">
		</CFQUERY>
		<CFSET Application.Session_Expiration_Length = 0.0104166666666><!--- 0.0104166666666 represents 15 minutes --->
	<CFELSE>
		<cfset Application.Session_Expiration_Length  = Get_Session_Window.Session_Expiration_Length>
	</CFIF>
</cfif>
<!------
we created the file Application_Settings_Initialise.cfm so that we do not have to modify Application_Vars.cfm file at all.
If Application_Vars.cfm file is modified then we always have problem while building......
----->
<cfinclude template="Application_Settings_Initialise.cfm" />
