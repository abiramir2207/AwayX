<!--- LOOP UP TO 20 TIMES UNTIL THE FISCAL YEAR IS CURRENT --->
<cfloop index="i" from="1" to="20">
<!--- VARIABLE TO CUT THE LOOP IF FISCAL YEAR IS CURRENT --->
<cfset anotherTry = 0>

<CFQUERY NAME="getCompanies" datasource="#application.datasource#" maxrows="3">
	SELECT DISTINCT Company_Main_ID
	FROM Fiscal_Year
</CFQUERY>

<cfif getCompanies.recordcount GT 0>

<cfloop query="getCompanies">

<cfset CompanyMainID = getCompanies.Company_Main_ID>

<!--- CHECK TO SEE IF NAME EXISTS ON FISCAL YEAR, IF NOT THEN CREATE IT --->
<CFQUERY NAME="createNameOnNullCheck" datasource="#application.datasource#">
	SELECT TOP 1 MAX(End_Date) AS End_date, Fiscal_Year
	FROM Fiscal_Year
	WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
		AND Deleted = 0
	GROUP BY Fiscal_Year
</CFQUERY>

<cfif createNameOnNullCheck.recordcount EQ 0>
	<CFQUERY NAME="createNameOnNullCheck" datasource="#application.datasource#">
		SELECT TOP 1 MAX(End_Date) AS End_date, Fiscal_Year
		FROM Fiscal_Year
		WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
		GROUP BY Fiscal_Year
		ORDER BY Fiscal_Year DESC
	</CFQUERY>
</cfif>

<cfif createNameOnNullCheck.fiscal_year EQ "">
	<cfset periodStDt = dateFormat(createNameOnNullCheck.End_date) - 365>
	<cfset FYTitle = "FY_" & dateFormat(createNameOnNullCheck.End_Date,'yyyy')>
	<CFQUERY NAME="createNameOnNullAction" datasource="#application.datasource#">
		UPDATE Fiscal_year
		SET Fiscal_Year = '#FYTitle#'
			,Deleted = 0
		WHERE Company_main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
			AND Start_Date > <cfqueryparam cfsqltype="cf_sql_date" value="#periodStDt#">
	</CFQUERY>
</cfif>

<!---

	<!--- CHECK DB SERVER VERSION TO DECIDE WHICH PROCESS IS MORE EFFICIENT FOR GATHERING ROW NUMBERS WITH SQL --->
	<cfquery name="DBVersion" datasource="#application.datasource#">
	SELECT  SERVERPROPERTY('productversion') as version
	</cfquery>

	<cfif listGetAt(DBVersion.version,1,".") LT 9>

 --->

	<!--- WORKS IN ALL VERSIONS OF SQL SERVER --->
		<CFQUERY NAME="getFiscalCalendar" datasource="#application.datasource#">
			SELECT a.*,
					(SELECT COUNT(*) FROM Fiscal_Year b
						WHERE b.start_date <= a.start_date
						AND a.deleted = 0
						AND b.deleted = 0
						AND a.Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
							) as row,
					(SELECT MAX(End_Date)
						FROM Fiscal_Year
						WHERE Deleted = 0
							AND Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
							) AS maxEndDate,
					(SELECT Min(Start_Date)
						FROM Fiscal_Year
						WHERE Deleted = 0
						AND Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
							) AS minStartDate
			FROM Fiscal_Year a
			WHERE a.Deleted = 0
				AND a.Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
			ORDER BY a.Start_Date
		</CFQUERY>

		<cfif getFiscalCalendar.recordcount EQ 0>

			<!--- IF ALL RECORDS ARE DELETED CREATE A START DATE FROM THE MAXIMUM DELETED DATE --->
			<!--- GRAB ALL PERIODS AFTER GENERATED START DATE --->
			<CFQUERY NAME="maxEndDate" datasource="#application.datasource#">
				SELECT MAX(End_Date) AS maxEndDate
				FROM Fiscal_Year
				WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
			</CFQUERY>

			<cfset startdate = dateFormat(maxEndDate.maxEndDate) - 366>

			<CFQUERY NAME="getFiscalCalendar" datasource="#application.datasource#">
				SELECT a.*,
						(SELECT COUNT(*) FROM Fiscal_Year b
							WHERE b.start_date <= a.start_date
							AND a.Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
							AND b.start_date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">
								) as row,
						(SELECT MAX(End_Date)
							FROM Fiscal_Year
								WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
								AND start_date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">
								) AS maxEndDate,
						(SELECT Min(Start_Date)
							FROM Fiscal_Year
							WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
								AND start_date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">
								) AS minStartDate
				FROM Fiscal_Year a
				WHERE a.Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
					AND a.start_date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">
				ORDER BY a.End_Date
			</CFQUERY>
		</cfif>

<!---
	<cfelse>
	<!--- ONLY WORKS IN SQL SERVER 2005 - (( BETTER OPTIMIZATION FOR SQL SERVER 2005 )) --->
		<CFQUERY NAME="getFiscalCalendar" datasource="#application.datasource#">
			SELECT *,
					'row' = ROW_NUMBER() OVER (ORDER BY End_Date),
					(SELECT MAX(End_Date)
						FROM Fiscal_Year
						WHERE Deleted = 0
							AND Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">) AS maxEndDate,
					(SELECT Min(Start_Date)
						FROM Fiscal_Year
						WHERE Deleted = 0
							AND Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">) AS minStartDate

			FROM Fiscal_Year
			WHERE Deleted = 0
				AND Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getCompanies.Company_Main_ID#">
			ORDER BY Start_Date
		</CFQUERY>

		<cfif getFiscalCalendar.recordcount EQ 0>
			<!--- IF ALL RECORDS ARE DELETED CREATE A START DATE FROM THE MAXIMUM DELETED DATE --->
			<!--- GRAB ALL PERIODS AFTER GENERATED START DATE --->
			<CFQUERY NAME="maxEndDate" datasource="#application.datasource#">
				SELECT MAX(End_Date) AS maxEndDate
				FROM Fiscal_Year
				WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
			</CFQUERY>
			<cfset startdate = dateFormat(maxEndDate.maxEndDate) - 366>
			<CFQUERY NAME="getFiscalCalendar" datasource="#application.datasource#">
				SELECT *,
						'row' = ROW_NUMBER() OVER (ORDER BY End_Date),
						(SELECT MAX(End_Date)
							FROM Fiscal_Year
							WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
								AND Start_Date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">) AS maxEndDate,
						(SELECT Min(Start_Date)
							FROM Fiscal_Year
							WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
								AND Start_Date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">) AS minStartDate

				FROM Fiscal_Year
				WHERE Company_Main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
					AND Start_Date > <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#">
				ORDER BY End_Date
			</CFQUERY>
		</cfif>
	</cfif>

	 --->

	<!--- ONLY CREATE NEW FISCAL YEAR IF WITHIN 30 DAYS OF FISCAL YEAR END OR AFTER --->
	<cfset daysToFYEnd = dateformat(getFiscalCalendar.maxEndDate,'mm/dd/yyyy') - dateformat(now(),'mm/dd/yyyy')>
	<CFIF daysToFYEnd LTE 30>

		<CFQUERY NAME="deletePriorCalendar" datasource="#application.datasource#">
			UPDATE Fiscal_year
			SET Deleted = 1
			WHERE Company_main_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">
		</CFQUERY>

		<cfset periods = getFiscalCalendar.recordcount>
		<cfset Fiscal_Year = listGetAt(getFiscalCalendar.Fiscal_Year,2,"_") + 1>
		<cfset Fiscal_Year_Title = "FY_" & Fiscal_Year>
		<cfif isLeapYear(Fiscal_Year - 1)>
			<cfset nextPeriodStartDate = createodbcdate(getFiscalCalendar.minStartDate) + 366>
		<cfelse>
			<cfset nextPeriodStartDate = createodbcdate(getFiscalCalendar.minStartDate) + 365>
		</cfif>

		<!--- CREATE START AND END NUMBERS FOR THE LOOP --->
		<cfset startRow = listGetAt(ValueList(getFiscalCalendar.row),1)>
		<cfset endRow = startRow + periods - 1>

		<CFLOOP INDEX="LoopCnt" FROM="#startRow#" TO="#endRow#">
			<CFQUERY NAME="periodInfo" dbtype="query">
				SELECT Start_Date, End_Date, Period_Length, Fiscal_Year, Last_Updated_By_User_ID
				FROM getFiscalCalendar
				WHERE row = <cfqueryparam cfsqltype="cf_sql_integer" value="#LoopCnt#">
			</CFQUERY>

			<cfset Period_Length = periodInfo.Period_Length>
			<cfset Period_Starting_Date = createodbcdate(nextPeriodStartDate)>
			<cfset Period_Ending_Date = createodbcdate(Period_Starting_Date + Period_Length - 1)>

			<CFQUERY NAME="saveFiscalPeriod" datasource="#application.datasource#">
				INSERT INTO Fiscal_year
				(
					Start_Date,
					End_Date,
					Fiscal_Year,
					Company_Main_ID,
					Period_Length,
					Last_Updated,
					Last_Updated_By_User_ID
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdatetime(evaluate('Period_Starting_Date'))#">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdatetime(evaluate('Period_Ending_Date'))#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Fiscal_Year_Title#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#CompanyMainID#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('Period_Length')#">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdatetime(now())#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#periodInfo.Last_Updated_By_User_ID#">
				)
			</CFQUERY>

			<cfset nextPeriodStartDate = createodbcdate(Period_Ending_Date) + 1>

			<!--- VARIABLE TO KEEP LOOPING IF FISCAL YEAR IS NOT CURRENT --->
			<cfset anotherTry = 1>

		</CFLOOP>
	</CFIF>
	<!--- KEEP GENERATING FISCAL YEARS UNTIL SYSTEM IS CURRENT --->
</cfloop>

</cfif>
<cfif anotherTry EQ 0><cfbreak></cfif>
</cfloop>
