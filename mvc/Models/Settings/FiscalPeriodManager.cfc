<!---
Name: 					FiscalPeriodManager.cfc
Copyright:			(c) 2014 Blacksmith Applications, Inc.
Created Date: 	05/14/2014
Created By:    	Kal
Description:		DB edit/access for Fiscal Perod data.
Parameters:			N/A
Usage:					N/A
--->
<cfcomponent name="FiscalPeriodManager" displayname="FiscalPeriodManager" hint="Manages Fiscal Perod data">

	<!--- get the list of fiscal years --->
	<cffunction name="getFiscalYears" returntype="query" output="false" access="remote">

		<cfset useLakebaseForqGetFiscalYears = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fiscal_year")>
<cfif useLakebaseForqGetFiscalYears>
	<cftry>
		<cfset qGetFiscalYears = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fiscal_year", {
				"deleted" = "eq.0",
				"order" = "fiscal_year.asc",
				"select" = "fiscal_year"
			}), "fiscal_year"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetFiscalYears = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetFiscalYears>
<cfquery name="qGetFiscalYears" datasource="#application.datasource#">
			SELECT DISTINCT Fiscal_Year
			FROM Fiscal_Year
			WHERE Deleted = 0
			ORDER BY Fiscal_Year
		</cfquery>
</cfif>

		<cfreturn qGetFiscalYears />
	</cffunction>

	<!--- get start & end dates for the year --->
	<cffunction name="getFiscalDatesforYear" returntype="query" output="false" access="remote">
		<cfargument name="fiscalYear" type="string" default="" />

		<cfquery name="qGetFiscalDatesforYear" datasource="#application.datasource#">
			SELECT MIN(Start_Date) AS StartDate,
						 MAX(End_Date) AS EndDate,
			 			 Fiscal_Year
			FROM 	Fiscal_Year
			WHERE Deleted = 0
			AND		Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" />
			Group BY Fiscal_Year
		</cfquery>

		<cfreturn qGetFiscalDatesforYear />
	</cffunction>

	<!--- get start & end dates for the fiscal periods in year --->
	<cffunction name="getFiscalPeriodsforYear" returntype="query" output="false" access="remote">
		<cfargument name="fiscalYear" type="string" default="" />

		<cfquery name="qGetFiscalPeriodsforYear" datasource="#application.datasource#">
			SELECT CONVERT(VARCHAR(10), Start_Date, 101) AS StartDate,
						 CONVERT(VARCHAR(10), End_Date, 101) AS EndDate,
						 Period AS FiscalPeriod
			FROM 	Fiscal_Year
			WHERE Deleted = 0
			AND		Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" />
			ORDER BY Start_Date, End_Date
		</cfquery>

		<cfreturn qGetFiscalPeriodsforYear />
	</cffunction>

	<!--- get period Id from given date --->
	<cffunction name="getFiscalPeriodforDate" returntype="numeric" output="false">
		<cfargument name="fiscalDate" type="string" required="true" />

		<cfquery name="qGetFiscalPeriodforDate" datasource="#application.datasource#">
		SELECT TOP 1  Period AS FiscalPeriod
		FROM Fiscal_Year
		WHERE Deleted = 0
			AND 
			(
				DateDiff(d, Start_Date, < cfqueryparam value = "#arguments.fiscalDate#" cfsqltype = "cf_sql_varchar" / >) = 0
				OR
				DateDiff(d, End_Date, < cfqueryparam value = "#arguments.fiscalDate#" cfsqltype = "cf_sql_varchar" / >) = 0
			)
		</cfquery>

		<cfreturn qGetFiscalPeriodforDate.FiscalPeriod />
	</cffunction>	

			
	<!--- get period Id between given date --->
	<cffunction name="getFiscalPeriodforDateRange" returntype="string" output="false">
		<cfargument name="fiscalDate" type="string" required="true" />

		<cfquery name="qGetFiscalPeriodforDateRange" datasource="#application.datasource#">
		SELECT TOP 1 Fiscal_Year
		FROM Fiscal_Year
		WHERE Deleted = 0
		AND  '#arguments.fiscalDate#' BETWEEN Start_Date AND End_Date
		</cfquery>

		<cfreturn qGetFiscalPeriodforDateRange.Fiscal_Year />
	</cffunction>			
			
	<!--- get year from given date --->
	<cffunction name="getFiscalYearforDate" returntype="string" output="false">
		<cfargument name="fiscalDate" type="string" required="true" />

		<cfquery name="qGetFiscalYearforDate" datasource="#application.datasource#">
		SELECT TOP 1  Fiscal_Year
		FROM Fiscal_Year
		WHERE Deleted = 0
			AND 
			(
				DateDiff(d, Start_Date, < cfqueryparam value = "#arguments.fiscalDate#" cfsqltype = "cf_sql_varchar" / >) = 0
				OR
				DateDiff(d, End_Date, < cfqueryparam value = "#arguments.fiscalDate#" cfsqltype = "cf_sql_varchar" / >) = 0
			)
		</cfquery>

		<cfreturn qGetFiscalYearforDate.Fiscal_Year />
	</cffunction>	

	<!--- get date from given period & fiscal year --->
	<cffunction name="getFiscalDateforPeriod" returntype="string" output="false">
		<cfargument name="fiscalPeriod" type="numeric" required="true" />
		<cfargument name="fiscalYear" type="string" required="true" />
		<cfargument name="startEnd" type="string" default="start" hint="which date, start/end date to return"  /> 

		<cfset var returnVar = "" />

		<cfquery name="qGetFiscalDateforPeriod" datasource="#application.datasource#">
			SELECT 	Start_Date, End_Date, Fiscal_Year
			FROM 		Fiscal_Year
			WHERE 	Deleted = 0
				AND 	Fiscal_Year = <cfqueryparam value="#arguments.fiscalYear#" cfsqltype="cf_sql_varchar" />
				AND 	Period = <cfqueryparam value="#arguments.fiscalPeriod#" cfsqltype="cf_sql_integer" />
		</cfquery>

		<!--- decide which value to return --->
		<cfif lCase(arguments.startEnd) eq "end">
			<cfset returnVar = qGetFiscalDateforPeriod.End_Date />
		<cfelse>
			<cfset returnVar = qGetFiscalDateforPeriod.Start_Date />
		</cfif>

		<cfreturn returnVar />
	</cffunction>	

	<!--- get the next fiscal year from given year --->
	<cffunction name="getNextFiscalYear" returntype="string" output="false" access="remote">
		<cfargument name="fiscalYear" type="string" required="true" />

		<cfset  var returnVar = "" />

		<cfquery name="qGetNextFiscalYear" datasource="#application.datasource#">
			SELECT 	DISTINCT TOP 1 Fiscal_Year
			FROM 		Fiscal_Year
			WHERE 	Deleted = 0
			AND 		Fiscal_Year > <cfqueryparam value="#arguments.fiscalYear#" cfsqltype="cf_sql_varchar" />
			ORDER BY Fiscal_Year
		</cfquery>

		<cfif qGetNextFiscalYear.recordCount>
			<cfset returnVar = qGetNextFiscalYear.Fiscal_Year />
		<cfelse>
			<cfset arrayFY = reMatchNoCase("\d+", arguments.fiscalYear) />
			<cfset returnVar = "FY_" & (val(arrayFY[1])+1) />
		</cfif>

		<cfreturn returnVar />
	</cffunction>

</cfcomponent>
