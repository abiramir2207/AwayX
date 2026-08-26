<cfcomponent alias="mvc.Models.AdvancedBudget.BudgetClassManager">

	<cffunction name="getBudgetClass" returntype="query" access="public" hint="Will return a query with all budgetclass" output="false">
		<cfargument name="budgetClassId" type="numeric" required="false" default="0" />

		<cfset var qGetBudgetClass = "" / >
		<cfquery name="qGetBudgetClass" datasource="#application.datasource#">
			SELECT	Budget_Class_ID,
					Budget_Class_Number,
					Budget_Class_Desc,
					Is_Fiscal,
					Year_Selection,
					Start_Date,
					End_Date,
					Active,
					Last_Updated_Date,
					Last_Updated_By,
					Partial_Year,
					Default_Filter
			FROM	Budget_Class
			WHERE	Deleted = 0
			<cfif arguments.budgetClassId neq "0">
			AND 	Budget_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budgetClassId#" />
			</cfif>
			ORDER BY Budget_Class_Number, Budget_Class_Desc
		</cfquery>

		<cfreturn qGetBudgetClass />

	</cffunction>

	<cffunction name="getSingleBudgetClass" returntype="mvc.Models.AdvancedBudget.vos.BudgetClass" access="public" hint="Will return the BudgetClass object" output="false">
		<cfargument name="budgetClassId" type="numeric" required="true" />

		<cfset var oBudgetClass = createObject('component','mvc.Models.AdvancedBudget.vos.BudgetClass') />

		<cfif arguments.budgetClassId>

			<!--- do the query and get the data --->
			<cfset qGetBudgetClass = getBudgetClass(arguments.budgetClassId) />

			<cfset oBudgetClass.id = qGetBudgetClass.Budget_Class_ID />
			<cfset oBudgetClass.number = qGetBudgetClass.Budget_Class_Number />
			<cfset oBudgetClass.desc = qGetBudgetClass.Budget_Class_Desc />
			<cfset oBudgetClass.isFiscal = qGetBudgetClass.Is_Fiscal />
			<cfset oBudgetClass.year = qGetBudgetClass.Year_Selection />
			<cfset oBudgetClass.active = qGetBudgetClass.Active />
			<cfset oBudgetClass.lastUpdatedDate = qGetBudgetClass.Last_Updated_Date />
			<cfset oBudgetClass.lastUpdatedBy = qGetBudgetClass.Last_Updated_By />
			<cfset oBudgetClass.Partial_Year = qGetBudgetClass.Partial_Year />
			<cfset oBudgetClass.startDate = qGetBudgetClass.start_date />
			<cfset oBudgetClass.endDate = qGetBudgetClass.end_date />
		</cfif>

		<cfreturn oBudgetClass />

	</cffunction>

	<cffunction name="saveBudgetClass" returntype="void" access="public" hint="Will save the Budget Class into the database" output="false">
		<cfargument name="argBudgetClass" type="mvc.Models.AdvancedBudget.vos.BudgetClass" required="true" />

		<cfset var oBudgetClass = arguments.argBudgetClass />
		<cfif oBudgetClass.Partial_Year>
			<!--- users made selection no need to assign --->
		<cfelseif oBudgetClass.isFiscal>
			<cfset qGetFiscalYear = getFiscalYear(oBudgetClass.year) />
			<cfset oBudgetClass.startDate = qGetFiscalYear.Start_Date />
			<cfset oBudgetClass.endDate = qGetFiscalYear.End_Date />
		<cfelse>
			<cfset oBudgetClass.startDate = getCalendarYearStartDate(oBudgetClass.year) />
			<cfset oBudgetClass.endDate = getCalendarYearEndDate(oBudgetClass.year) />

			<!--- D32696: For CY12 only we need it to not consider dates prior to 5.28.12 --->
			<cfif len(trim(application.returned_customer_setting.Program_Start_Date)) GT 0>
				<cfif oBudgetClass.startDate lte application.returned_customer_setting.Program_Start_Date
						and oBudgetClass.endDate gte application.returned_customer_setting.Program_Start_Date>
						<cfset oBudgetClass.startDate = application.returned_customer_setting.Program_Start_Date />
				</cfif>
			</cfif>
		</cfif>

		<cfif oBudgetClass.id eq 0>
			<!--- insert --->
			<cfset var qInsertBudgetClass = "" / >
			<cfquery name="qInsertBudgetClass" datasource="#application.datasource#">
				INSERT INTO Budget_Class (
					Budget_Class_Number,
					Budget_Class_Desc,
					Is_Fiscal,
					Year_Selection,
					Start_Date,
					End_Date,
					Active,
					Last_Updated_Date,
					Last_Updated_By
					,Partial_Year
				)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.number#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.desc#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.isFiscal#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.year#" />,
					<cfqueryparam cfsqltype="cf_sql_date" value="#oBudgetClass.startDate#" />,
					<cfqueryparam cfsqltype="cf_sql_date" value="#oBudgetClass.endDate#" />,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#oBudgetClass.active#" />,
					GetDate(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
					,<cfqueryparam cfsqltype="cf_sql_bit" value="#oBudgetClass.Partial_Year#" />
				)
			</cfquery>

		<cfelse>
			<!--- update --->
			<cfset var qUpdateBudgetClass = "" / >
			<cfquery name="qUpdateBudgetClass" datasource="#application.datasource#">
				UPDATE	Budget_Class
				SET		Budget_Class_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.number#" />,
						Budget_Class_Desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.desc#" />,
						Is_Fiscal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.isFiscal#" />,
						Year_Selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="#oBudgetClass.year#" />,
						Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#oBudgetClass.startDate#" />,
						End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#oBudgetClass.endDate#" />,
						Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#oBudgetClass.active#" />,
						Last_Updated_Date = GetDate(),
						Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#"/>
						,Partial_Year =  <cfqueryparam cfsqltype="cf_sql_bit" value="#oBudgetClass.Partial_Year#" />
				WHERE	Budget_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#oBudgetClass.id#" />
			</cfquery>

		</cfif>

	</cffunction>

	<cffunction name="getFiscalYear" returntype="query" access="public" hint="Will return the list of fiscal years" output="false">
		<cfargument name="fiscalYear" type="string" required="false" default="" />

		<cfset var qGetFiscalYears = "" />

		<!---
		<cfquery name="qGetFiscalYears" datasource="#application.datasource#">
			SELECT 	Fiscal_Year, MIN(Start_Date) as Start_Date, MAX(End_Date) as End_Date
			FROM 	Fiscal_Year
			WHERE Deleted = 0
			<cfif arguments.fiscalYear neq "">
			AND Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" />
			</cfif>
			GROUP BY Fiscal_Year
			ORDER BY Fiscal_Year
		</cfquery>
		--->

		<cfquery name="qGetFiscalYears" datasource="#application.datasource#">
			SELECT 	Fiscal_Year, Start_Date, End_Date
			FROM 	V_Fiscal_Year_List
			<cfif arguments.fiscalYear neq "">
			WHERE Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" />
			</cfif>
			ORDER BY Fiscal_Year
		</cfquery>

		<cfreturn qGetFiscalYears />

	</cffunction>

	<!---
	<cffunction name="getCalendarYear" returntype="array" access="public" hint="Will return the list of calendar years" output="false">


		<cfset var arCalendarYears = ArrayNew(1) />
		<cfset var currentYear = Year(Now()) />
		<cfset var stCalendarYear = StructNew() />

 		<cfloop from="#currentYear-5#" to="#currentYear+5#" index="i">
			<cfset stCalendarYear = StructNew() />
			<cfset stCalendarYear.year = i />
			<cfset stCalendarYear.start_date = this.getCalendarYearStartDate(i) />
			<cfset stCalendarYear.end_date = this.getCalendarYearEndDate(i) />
			<cfset ArrayAppend(arCalendarYears, stCalendarYear) />
		</cfloop>

		<cfreturn arCalendarYears />

	</cffunction>
	--->

	<cffunction name="getCalendarYear" returntype="query" access="public" hint="Will return the list of calendar years" output="false">


		<cfquery name="qGetCalendarYear" datasource="#application.datasource#">
			declare @year_start int,
					@year_end int

			select 	@year_start = year(getdate()) - 5,
					@year_end = year(getdate()) + 5

			SELECT 	year, start_date, end_date
			FROM 	udf_GetCalendarYears (@year_start, @year_end)
			ORDER BY year
		</cfquery>

		<cfreturn qGetCalendarYear />

	</cffunction>

	<cffunction name="getCalendarYearStartDate" returntype="date" access="public" hint="Will return the start date of the provided calendar year" output="false">
		<cfargument name="calendarYear" type="numeric" required="true" />

		<cfreturn CreateDate(arguments.calendarYear, 1, 1) />

	</cffunction>

	<cffunction name="getCalendarYearEndDate" returntype="date" access="public" hint="Will return the end date of the provided calendar year" output="false">
		<cfargument name="calendarYear" type="numeric" required="true" />

		<cfreturn CreateDate(arguments.calendarYear, 12, 31) />

	</cffunction>

	<cffunction name="getFiscalDates" returntype="query" access="public" hint="Will return starting dates & ending dates within a fiscal year" output="false">
		<cfargument name="fiscalYear" type="string" required="true"/>

		<cfquery name="loc.qDates" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpFiscalYear') IS NOT NULL
    		DROP TABLE ##tmpFiscalYear

			SELECT
					periodID=IDENTITY (int, 1, 1),
					start_Date = CONVERT(VARCHAR(10), start_date, 101)
			       , end_Date = CONVERT(VARCHAR(10), end_date, 101)
			INTO ##tmpFiscalYear
			FROM FISCAL_YEAR fy
			WHERE fy.Fiscal_Year = <cfqueryparam value="#arguments.fiscalYear#">
			       AND fy.Deleted = 0
			ORDER BY fy.Start_Date

			SELECT * FROM  ##tmpFiscalYear
			DROP TABLE ##tmpFiscalYear
		</cfquery>

		<cfreturn loc.qDates>

	</cffunction>

	<cffunction name="getCalendarDates" returntype="query" access="public" hint="Will return starting dates & ending dates within a Calendar Year" output="false">
		<cfargument name="calendarYear" type="string" required="true"/>

		<cfquery name="loc.qDates" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmpCalendarYear') IS NOT NULL
    		DROP TABLE ##tmpCalendarYear

			SELECT
					periodID=IDENTITY (int, 1, 1),
					Month,
					start_Date = CONVERT(VARCHAR(10), start_date, 101)
			       , end_Date = CONVERT(VARCHAR(10), end_date, 101)
			INTO ##tmpCalendarYear
			FROM udf_GetCalendarMonths(<cfqueryparam value="#arguments.calendarYear#">)
			ORDER BY start_Date

			SELECT * FROM  ##tmpCalendarYear
			DROP TABLE ##tmpCalendarYear
		</cfquery>

		<cfreturn loc.qDates>

	</cffunction>

	<cffunction name="getDateRange" returntype="query" access="public" hint="Will return Start dates & End dates within program Start and End Dates" output="false">
		<cfargument name="contractStartDate" type="string" required="true"/>
		<cfargument name="contractEndDate" type="string" required="true"/>

		<cfquery name="qryDateRange" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmpDateRange') IS NOT NULL
				DROP TABLE ##tmpDateRange

				CREATE TABLE ##tmpDateRange
				(
				DateRangeID int  IDENTITY(1,1) NOT NULL,
				Start_Date [datetime],
				End_Date [datetime]
				)
				DECLARE
				@sDate datetime = '#arguments.contractStartDate#',
				@eDate datetime = '#arguments.contractEndDate#'

				INSERT INTO ##tmpDateRange
				SELECT @sDate  AS start_Date,End_Date   from Fiscal_Year where @sDate  between start_Date AND End_Date AND Deleted = 0
				UNION
				SELECT Start_Date,End_Date  from Fiscal_Year where start_date >= @sDate AND End_Date <=@eDate AND Deleted = 0
				UNION
				SELECT Start_Date, @eDate AS End_Date  FROM Fiscal_Year WHERE @eDate BETWEEN Start_Date AND  End_Date AND Deleted = 0
				ORDER BY start_Date

				SELECT * FROM ##tmpDateRange ORDER BY Start_Date
				DROP TABLE ##tmpDateRange
			</cfquery>

	<cfreturn qryDateRange>

	</cffunction>

	<cffunction name="getAdjustmentDateRange" returntype="query" access="public" hint="Will return Start dates & End dates within program Start and End Dates based on the Adjustment Date" output="false">
		<cfargument name="contractStartDate" type="string" required="true"/>
		<cfargument name="contractEndDate" type="string" required="true"/>
		<cfargument name="adjustmenDate" type="string" required="true"/>
		<cfset aDate = DateFormat(arguments.adjustmenDate,"yyyy-mm-dd") />

 		<cfquery name="qryDateRange" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmpDateRange') IS NOT NULL
				DROP TABLE ##tmpDateRange

				CREATE TABLE ##tmpDateRange
				(
				DateRangeID int  IDENTITY(1,1) NOT NULL,
				Start_Date [datetime],
				End_Date [datetime]
				)
				DECLARE
				@sDate datetime = '#arguments.contractStartDate#',
				@eDate datetime = '#arguments.contractEndDate#',
				@aDate datetime = '#aDate#'

				INSERT INTO ##tmpDateRange
				SELECT @sDate  AS start_Date,End_Date   from Fiscal_Year where @sDate  between start_Date AND End_Date AND Deleted = 0
				UNION
				SELECT Start_Date,End_Date  from Fiscal_Year where start_date >= @sDate AND End_Date <=@eDate AND Deleted = 0
				UNION
				SELECT Start_Date, @eDate AS End_Date  FROM Fiscal_Year WHERE @eDate BETWEEN Start_Date AND  End_Date AND Deleted = 0
				ORDER BY start_Date

				SELECT Start_Date, End_Date  FROM ##tmpDateRange WHERE @aDate  BETWEEN Start_Date AND  End_Date ORDER BY Start_Date

				DROP TABLE ##tmpDateRange
			</cfquery>

	<cfreturn qryDateRange>

	</cffunction>

	<cffunction name="getFiscalDates2" access="remote" output="false" returnformat="json">
		<cfargument name="fiscal_Year" required="true"/>

    <cfset loc.result = []>
		<cfquery name="loc.qPeriods" datasource="#application.datasource#">
			SELECT start_Date = CONVERT(VARCHAR(10), start_date, 101)
			       , end_Date = CONVERT(VARCHAR(10), end_date, 101)
			  FROM FISCAL_YEAR fy
			 WHERE fy.Fiscal_Year = <cfqueryparam value="#arguments.fiscal_Year#">
			       AND fy.Deleted = 0
			 ORDER BY fy.Start_Date
		</cfquery>

    <cfoutput query="loc.qPeriods">
       <cfscript>
       		loc.object = {};
          loc.object.start_date = loc.qPeriods.start_date;
          loc.object.end_date = loc.qPeriods.end_date;
          arrayAppend(loc.result, loc.object);
       </cfscript>
    </cfoutput>

    <cfreturn loc.result>
	</cffunction>

	<cffunction name="saveBudgetClassDefault" returntype="void" access="public" hint="Will save the Budget Class Defaults into the database" output="true">
		<cfargument name="budgetClassDefaults" type="struct" required="true" />

		<cfset var stData 						= structNew() />
		<cfset var lAllBudgetClassIds			= "" />
		<cfset var qUpdateBudgetClassDefaults	= "" />

		<cfset stData 				= arguments.budgetClassDefaults />
		<cfset lAllBudgetClassIds	= stData.lBudgetClassIDs />

		<cfloop index="idx" list="#lAllBudgetClassIds#">

			<cfparam name="stData.Default_Filter_#idx#" default="0" />

			<cfquery name="qUpdateBudgetClassDefaults" datasource="#application.datasource#">
				UPDATE	Budget_Class
				SET		Default_Filter = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#Evaluate("stData.Default_Filter_#idx#")#" />
				WHERE	Budget_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#idx#" />
			</cfquery>

		</cfloop>

	</cffunction>
<!--- D64200 :: Create new accrual budget forecast process START --->
	<cffunction name="getSpecificBudget" returntype="query" access="remote" hint="Will return a query with budget info for budget id" output="false">
		<cfargument name="budgetId" type="numeric" required="true" default="0" />

		<cfquery name="qBudget" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Budget
			WHERE Budget_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budgetId#" />
			AND Deleted = 0
		</cfquery>

		<cfreturn qBudget />
	</cffunction>

	<cffunction name="getBudgets" returntype="query" access="remote" hint="Will return a query with all budgets" output="false">
		<cfargument name="budgetClassId" type="numeric" required="true" default="0" />

		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.getClassCodesOn()>
			<cfquery name="qBusinessSegmentCount" datasource="#application.datasource#">
				SELECT Class_Code.Business_Segment_ID
			  	FROM User_Class_Code
				INNER JOIN Class_Code ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_ID
				WHERE User_Id = '#request.AccessStructure.User_ID#'
		    		AND User_Class_Code.Deleted = 0
			</cfquery>
		<cfelse>
			<cfquery name="qBusinessSegmentCount" datasource="#application.datasource#">
				SELECT *
			  	FROM dbo.User_Business_Segment
				WHERE User_Id = '#request.AccessStructure.User_ID#'
			       AND Deleted = 0
			</cfquery>
		</cfif>

		<cfquery name="qGetBudgets" datasource="#application.datasource#">
			SELECT  DISTINCT 	b.Budget_ID, b.Budget_Desc
			FROM Budget b
		<cfif businessSegManager.getClassCodesOn()>
			INNER JOIN Class_Code
			ON b.business_segment_id  = Class_Code.Business_Segment_ID
			INNER JOIN User_Class_Code
			ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_Id
			AND User_Class_Code.User_ID = '#request.AccessStructure.User_ID#'
			AND User_Class_Code.Deleted = 0
		<cfelseif businessSegManager.isEnabled() and qBusinessSegmentCount.recordCount>
			INNER JOIN User_Business_Segment ubs
			ON ubs.Business_Segment_Id = b.Business_Segment_Id
			AND ubs.Deleted = 0
			AND ubs.User_Id = '#request.AccessStructure.User_ID#'
		</cfif>

			WHERE b.Deleted = 0
			AND b.Active = 1
			AND b.Budget_Contribution_Factor_Type_ID = 2
			AND b.Is_Perpetual = 1
			AND b.Budget_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budgetClassId#" />

			ORDER BY b.Budget_Desc
		</cfquery>

		<cfreturn qGetBudgets />

	</cffunction>
	<cffunction name="getBudgetDistributors" returntype="JSON" access="remote" hint="Will return a query with all budgets" output="false">
		<cfargument name="budgetId" type="numeric" required="true" default="0" />

		<cfquery name="qGetBudgetDistributors" datasource="#application.datasource#">
			SELECT distributor_group_id AS bsa_foodservice_customers_id, BSA_Foodservice_Customers.Name
			FROM   Budget_Distributor
       		INNER JOIN  BSA_Foodservice_Customers
      	 		ON        BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Budget_Distributor.distributor_group_id
			WHERE  budget_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budgetId#" />
			AND     distributor_group_level_id = 0
			AND     Budget_Distributor.deleted = 0

			UNION

			SELECT BSA_Foodservice_Customers.bsa_foodservice_customers_id, BSA_Foodservice_Customers.Name
			FROM   Budget_Distributor
			INNER JOIN PG_Customer_Members m
			ON      m.PG_Customer_Category_ID = Budget_Distributor.Distributor_Group_ID
			AND    m.Deleted = 0
			INNER JOIN BSA_Foodservice_Customers
			ON        BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = m.BSA_Foodservice_Customers_ID
			WHERE  Budget_Distributor.budget_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budgetId#" />
			AND     Budget_Distributor.distributor_group_level_id != 0
			AND     Budget_Distributor.deleted = 0

			UNION

			SELECT BSA_Foodservice_Customers.bsa_foodservice_customers_id, BSA_Foodservice_Customers.Name
			FROM   Budget b
			INNER JOIN Budget_Distributor_Allocation m
			ON      b.Budget_ID = m.Budget_ID
			AND    b.Budget_Dollar != 0
			INNER JOIN BSA_Foodservice_Customers
			ON      BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = m.BSA_Foodservice_Customers_ID
			WHERE  b.budget_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budgetId#" />
			AND      b.Allocation_Position_Level = 4

			ORDER BY Name
		</cfquery>

		<cfreturn qGetBudgetDistributors />

	</cffunction>
<!--- D64200 :: Create new accrual budget forecast process END--->
</cfcomponent>