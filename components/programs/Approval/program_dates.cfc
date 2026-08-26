<cffunction name="getProgramPeriods" output="false" returntype="array">
		<cfargument name="startDate" type="date" required="false" default="" />
		<cfargument name="endDate" type="date" required="false" default="" />
		<cfargument name="companyId" required="false" default="" />
		<cfargument name="paymentcycleid" required="true" default="1" />
		<cfargument name="templateType" required="false" default="" />
		<cfargument name="Discount_Type_ID" required="false" default="0" />
		
	
		<cfset startYear = DatePart("yyyy", arguments.startDate) />
		<cfset startMonth = DatePart("m", arguments.startDate) />
		<cfset startDay = DatePart("d", arguments.startDate) />
		<cfset endYear = DatePart("yyyy", arguments.endDate) />
		<cfset endMonth = DatePart("m", arguments.endDate) />
		<cfset endDay = DatePart("d", arguments.endDate) />
			
		<!---create array to hold data struct for each unit--->
		<cfset rUnits = ArrayNew(1) />
		
	<cfif arguments.paymentcycleid eq 3><!------ Monthly ----->
		<!---calender date--->
			<cfset dateCount = CreateDate(startYear, startMonth, "01") />			
			<!---now loop over units and set start and end dates--->
			<cfset totalMonths = DateDiff("m", dateCount, arguments.endDate) />
			<!--- add one for 11/2010 split month --->
			<cfif startYear eq 2010 AND startMonth LTE 11 AND (endMonth eq 12 OR endYear GT 2010)>
				<cfset totalMonths = totalMonths + 1 />
			</cfif>
			<cfloop index="unitIndx" from="0" to="#totalMonths#">
				<cfset DateManager = CreateObject("component", "components.programs.Approval.program_dates_manager") />
				<cfset DateManager.setPeriodStartDate(dateCount) />
				
				<cfif DatePart("yyyy", dateCount) EQ 2010 AND DatePart("m", dateCount) EQ 11 AND DatePart("d", dateCount) EQ 1>
					<cfset DateManager.setPeriodEndDate(DateAdd("d", 14, dateCount)) />
					<!---add a month to date count--->
					<cfset dateCount = DateAdd("d", 15, dateCount) />
				<cfelseif DatePart("yyyy", dateCount) EQ 2010 AND DatePart("m", dateCount) EQ 11 AND DatePart("d", dateCount) EQ 16>
					<cfset DateManager.setPeriodEndDate(DateAdd("d", 14, dateCount)) />
					<!---add a month to date count--->
					<cfset dateCount = DateAdd("d", 15, dateCount) />	
				<cfelse>
					<cfset DateManager.setPeriodEndDate(DateAdd("d", DaysInMonth(dateCount) - 1, dateCount)) />
					<!---add a month to date count--->
					<cfset dateCount = DateAdd("m", 1, dateCount) />
				</cfif>
				<cfif DateCompare(DateManager.getPeriodEndDate(),arguments.endDate) eq 1>
					<cfset DateManager.setPeriodEndDate(CreateDate(endYear, endMonth, endDay)) />
				</cfif>
				<cfset ArrayAppend(rUnits, DateManager) />
			</cfloop>
			
	<cfelseif arguments.paymentcycleid eq 6><!------ Yearly ----->
			<!---calender date--->
			<cfset dateCount = CreateDate(startYear, startMonth, "01") />			
			<!---now loop over units and set start and end dates--->
			<cfset totalYrs = DateDiff("yyyy", dateCount, dateadd("d",1,arguments.endDate)) />
			
			<!------ If # of year=0, send just the available dates ----->
			<cfif totalYrs EQ 0 AND (UCase(arguments.templateType) EQ "LUMP" OR arguments.Discount_Type_ID EQ 2 OR arguments.Discount_Type_ID EQ 3 OR arguments.Discount_Type_ID EQ 4)>
				<cfset lastMonthEnd = CreateDate(endYear, endMonth, "01") />
				<cfset lastMonthEnd = DateAdd("d", DaysInMonth(lastMonthEnd) - 1, lastMonthEnd) />
				
				<cfset DateManager = CreateObject("component", "components.programs.Approval.program_dates_manager") />				
				<cfset DateManager.setPeriodStartDate(dateCount) />
				<cfset DateManager.setPeriodEndDate(lastMonthEnd) />
				<cfif DateCompare(DateManager.getPeriodEndDate(),arguments.endDate) eq 1>
					<cfset DateManager.setPeriodEndDate(CreateDate(endYear, endMonth, endDay)) />
				</cfif>
				<cfset ArrayAppend(rUnits, DateManager) />
			</cfif>
			<!------ If # of year>0, do normal processing ----->
			<cfloop index="unitIndx" from="1" to="#totalYrs#">
				<cfset DateManager = CreateObject("component", "components.programs.Approval.program_dates_manager") />
				<cfset DateManager.setPeriodStartDate(dateCount) />
				<cfset DateManager.setPeriodEndDate(DateAdd("yyyy", 1, dateCount - 1)) />
				<cfif DateCompare(DateManager.getPeriodEndDate(),arguments.endDate) eq 1>
					<cfset DateManager.setPeriodEndDate(CreateDate(endYear, endMonth, endDay)) />
				</cfif>
				<!---add a yr to date count--->
				<cfset dateCount = DateAdd("yyyy", 1, dateCount) />
				<cfset ArrayAppend(rUnits, DateManager) />
			</cfloop>
			
	<cfelseif arguments.paymentcycleid eq 4><!------ Quarterly ----->
			<!---calender date--->
			<cfset dateCount = CreateDate(startYear, startMonth, "01") />
			<!---now loop over units and set start and end dates--->
			<cfset totalquaters = DateDiff("q", getQuarter(dateCount), arguments.endDate) />
	
			<cfloop index="unitIndx" from="0" to="#totalquaters#">
				<cfset DateManager = CreateObject("component", "components.programs.Approval.program_dates_manager") />
				<cfset DateManager.setPeriodStartDate(dateCount) />
				<cfif unitIndx eq 0>
					<!--- find the date of the nearest quarter start --->
					<cfset DateManager.setPeriodEndDate(DateAdd("q", 1, getQuarter(dateCount))) />
					<!---add a quater to date count--->
					<cfset dateCount = DateAdd("q", 1, getQuarter(dateCount)) />
				<cfelse>
					<cfset DateManager.setPeriodEndDate(DateAdd("q", 1, dateCount)) />
					<!---add a quater to date count--->
					<cfset dateCount = DateAdd("q", 1, dateCount) />
				</cfif>
				<cfset DateManager.setPeriodEndDate(DateAdd("d", -1, DateManager.getPeriodEndDate())) />
				<cflog text="dateComp :: #DateCompare(DateManager.getPeriodEndDate(),arguments.endDate)#" />
				<cfif DateCompare(DateManager.getPeriodEndDate(),arguments.endDate) eq 1>
					<cfset DateManager.setPeriodEndDate(CreateDate(endYear, endMonth, endDay)) />
				</cfif>
				
				<cfset ArrayAppend(rUnits, DateManager) />
			</cfloop>
	</cfif>
		<cfreturn rUnits />
		
	</cffunction>
	<cffunction name="getQuarter" output="false" returntype="date">
		<cfargument name="dt" type="date" required="false" default="#now()#" />
		<cfscript>
		/**
		 * Returns a date object with the first date of the current quarter.
		 */
		    if(dt gte createDateTime(DatePart("yyyy", dt), 01, 01, 00, 00, 00) and dt lte createDateTime(DatePart("yyyy", dt), 03, 31, 23, 59, 59)) return createDate(datePart("yyyy", dt), 01, 01);
		    else if (dt gte createDateTime(DatePart("yyyy", dt), 04, 01, 00, 00, 00) and dt lte createDateTime(DatePart("yyyy", dt), 06, 30, 23, 59, 59)) return createDate(datePart("yyyy", dt), 04, 01);
		    else if (dt gte createDateTime(DatePart("yyyy", dt), 07, 01, 00, 00, 00) and dt lte createDateTime(DatePart("yyyy", dt), 09, 30, 23, 59, 59)) return createDate(datePart("yyyy", dt), 07, 01);
		    else return createDate(datePart("yyyy", dt), 10, 01);
		</cfscript>
	</cffunction>
	
	
	