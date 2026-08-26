<cfcomponent displayname="Distributed Volume Factory Component" extends="components.Base">

	
	<cffunction name="getDatePeriods" output="false" returntype="array">
	
		<cfargument name="periodType" type="string" required="false" default="1" />
		<cfargument name="startDate" type="date" required="false" default="" />
		<cfargument name="endDate" type="date" required="false" default="" />
		<cfargument name="companyId" required="false" default="" />
		<cfargument name="distributorId" required="false" default="" />
		
		<cfset startYear = DatePart("yyyy", arguments.startDate) />
		<cfset startMonth = DatePart("m", arguments.startDate) />
		<cfset startDay = DatePart("d", arguments.startDate) />
		<cfset endYear = DatePart("yyyy", arguments.endDate) />
		<cfset endMonth = DatePart("m", arguments.endDate) />
		<cfset endDay = DatePart("d", arguments.endDate) />
			
		<!---create array to hold data struct for each unit--->
		<cfset rUnits = ArrayNew(1) />
			
		<!---calender date--->
		<cfif arguments.periodType eq 1>
			
			<cfset dateCount = CreateDate(startYear, startMonth, "01") />			
			
			<!---now loop over units and set start and end dates--->
			<cfset totalMonths = DateDiff("m", dateCount, arguments.endDate) />
			<cfloop index="unitIndx" from="0" to="#totalMonths#">
				
				<!---create DistributedVolume object--->
				<cfset distVolume = CreateObject("component", "components.futures_pricing.DistributedVolume") />
	
				<!---set first unit based on start date value passed--->
				<cfif unitIndx eq 0>
					<cfset distVolume.setStartDate(arguments.startDate) />
					<cfset distVolume.setEndDate(DateAdd("d", DaysInMonth(arguments.startDate) - startDay, arguments.startDate)) />
				<!---set last unit based on end date value passed--->
				<cfelseif unitIndx eq totalMonths>
					<cfset distVolume.setStartDate(dateCount) />
					<cfset distVolume.setEndDate(arguments.endDate) />
				<!---set units in the middle--->
				<cfelse>
					<cfset distVolume.setStartDate(dateCount) />
					<cfset distVolume.setEndDate(DateAdd("d", DaysInMonth(dateCount) - 1, dateCount)) />
				</cfif>
				
				
				<cfset distVolume.setPeriodStartDate(dateCount) />
				<cfset distVolume.setPeriodEndDate(DateAdd("d", DaysInMonth(dateCount) - 1, dateCount)) />
				
				<cfset distVolume.setOrder(unitIndx + 1) />
				<cfset distVolume.setDesc(DateFormat(distVolume.getStartDate(), "mmm-yy")) />
				
				<!---add a month to date count--->
				<cfset dateCount = DateAdd("m", 1, dateCount) />

				<cfset ArrayAppend(rUnits, distVolume) />
				
			</cfloop>
			
		<!---fiscal date--->
		<cfelse>
		
		<cfif arguments.distributorId eq "">
			<cfset qFiscalYearPeriod = this.getFiscalYearPeriods(arguments.companyId, arguments.startDate, arguments.endDate) />
		<cfelse>
			<cfset qFiscalYearPeriod = this.getFiscalYearPeriods(arguments.companyId, arguments.startDate, arguments.endDate,arguments.distributorId) />
		</cfif>		
			

			<cfloop query="qFiscalYearPeriod">
				
				<!---create DistributedVolume object--->
				<cfset distVolume = CreateObject("component", "components.futures_pricing.DistributedVolume") />
	
				<!---set first unit based on start date value passed--->
				<cfif CurrentRow eq 1>
					<cfset distVolume.setStartDate(arguments.startDate) />
					<cfset distVolume.setEndDate(End_Date) />
				<!---set last unit based on end date value passed--->
				<cfelseif CurrentRow eq RecordCount>
					<cfset distVolume.setStartDate(Start_Date) />
					<cfset distVolume.setEndDate(arguments.endDate) />
				<!---set units in the middle--->
				<cfelse>
					<cfset distVolume.setStartDate(Start_Date) />
					<cfset distVolume.setEndDate(End_Date) />
				</cfif>
				
				<cfset distVolume.setPeriodStartDate(Start_Date) />
				<cfset distVolume.setPeriodEndDate(End_Date) />
				
				<cfset distVolume.setOrder(CurrentRow) />
				<!------ <cfset distVolume.setDesc("Period " & CurrentRow) /> ----->
				<cfset distVolume.setDesc("Period #period_position#") />

				<cfset ArrayAppend(rUnits, distVolume) />
				
			</cfloop>
			
		</cfif>
		
		<cfreturn rUnits />
		
	</cffunction>

	
	<cffunction name="translateVolumeDistribution" returntype="array" output="false">
	
		<cfargument name="sourceVolDist" type="array" required="true" />
		<cfargument name="destVolDist" type="array" required="true" />
		<cfargument name="volumeMultiplier" type="numeric" required="false" default="1" />
		
		<cfset destVolDist = arguments.destVolDist />
		<cfset destVolDistArrayLen = ArrayLen(destVolDist) />
		
		<cfloop index="i" from="1" to="#destVolDistArrayLen#">
		
			<cfset thisVolumeDist = destVolDist[i] />
			<cfset thisVolumeDist.setVolume(getAvgVolume(thisVolumeDist, arguments.sourceVolDist, thisVolumeDist.getPeriodStartDate(), thisVolumeDist.getPeriodEndDate()) * arguments.volumeMultiplier)>
		
		</cfloop>
		
		<cfreturn destVolDist />
		
	</cffunction>
	
	<cffunction name="getAvgVolume" returntype="numeric" output="false">
	
		<cfargument name="destVolDist" type="components.futures_pricing.DistributedVolume" required="true" />
		<cfargument name="sourceVolDist" type="array" required="true" />
		<cfargument name="startDate" type="string" required="true" />
		<cfargument name="endDate" type="string" required="true" />
		
		<cfset destStartDate = destVolDist.getStartDate() />
		<cfset destEndDate = destVolDist.getEndDate() />
		
		<cfset returnVolume = 0>
		
		<cfset srcArrayLen = ArrayLen(arguments.sourceVolDist)>
		<cfset destDateSpan = DateDiff("d", arguments.startDate, arguments.endDate) + 1>

		<!------ <cfloop index="i" from="1" to="#srcArrayLen#"> ----->
		<cfloop index="i" from="#srcArrayLen#" to="1" step="-1">
		
			<cfset currSrcDist = arguments.sourceVolDist[i]>
			
			<cfset dateSpanMatch = checkDateSpanMatch(destStartDate, destEndDate, currSrcDist.getStartDate(), currSrcDist.getEndDate()) OR checkDateSpanMatch(arguments.startDate, arguments.endDate, currSrcDist.getStartDate(), currSrcDist.getEndDate())>
			<cfif dateSpanMatch>
			
				<cfset arguments.destVolDist.setLimitedTimeOffer(currSrcDist.getLimitedTimeOffer()) />
				
			</cfif>
			
			<!------ check whether this period has proper dates and volume ----->
			<cfif isDate(currSrcDist.getStartDate()) AND isDate(currSrcDist.getEndDate()) AND isNumeric(currSrcDist.getVolume()) AND currSrcDist.getVolume() NEQ "">
			
				<cfset currSrcSpan = DateDiff("d", currSrcDist.getStartDate(), currSrcDist.getEndDate()) + 1>
				
				<!------ check there is any overlap ----->				
				<cfif checkDateOverLap(arguments.startDate, arguments.endDate, currSrcDist.getStartDate(), currSrcDist.getEndDate())>
				
					<cfset currOverlap = destDateSpan>
					<!------ take out start date mismatch ----->
					<cfset sdMismatch = DateDiff("d", arguments.startDate, currSrcDist.getStartDate())>
					<cfif sdMismatch LT 0>
						<cfset sdMismatch = 0>
					</cfif>
					
					
					<!------ take out end date mismatch ----->
					<cfset edMismatch = DateDiff("d", currSrcDist.getEndDate(), arguments.endDate)>
					<cfif edMismatch LT 0>
						<cfset edMismatch = 0>
					</cfif>
					
					<cfset currOverlap = currOverlap - sdMismatch - edMismatch>
					
				<cfelse>
				
					<cfset currOverlap = 0>
					
				</cfif>
				
				<cfset returnVolume = returnVolume + ((currSrcDist.getVolume() / currSrcSpan) * currOverlap)>
				
				<cfset currSrcDist.setDaysUsedUp(currOverlap) />
			
				<cfif currSrcDist.getDaysUsedUp() EQ currSrcSpan>
				<!------ <cfif dateSpanMatch> ----->
					
					<cfset ArrayDeleteAt(arguments.sourceVolDist, i) />
					
					<cfif dateSpanMatch>
						<cfbreak />
					</cfif>
				
				</cfif>
			
			<cfelse>
			
				<cfset ArrayDeleteAt(arguments.sourceVolDist, i) />
			
			</cfif><!------ check whether this period has proper dates and volume ----->
			
		</cfloop>
		
		<cfreturn returnVolume />
		
	</cffunction>

	<!---////////////////////////////////////////// GETFISCALYEARPERIODS FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="getFiscalYearPeriods" output="false" returntype="query">
	
		<cfargument name="companyId" required="true" default="" />
		<cfargument name="startDate" required="false" default="" />
		<cfargument name="endDate" required="false" default="" />
		<cfargument name="distributorId" required="false" default="" />
		
		<!---if we don't have a start date and an end date then return an empty query--->
		<cfif Len(arguments.startDate) and Len(arguments.endDate)>
		
		
		
			<!---call getAllFiscalYearPeriods --->
		<cfif distributorId eq "">
			<cfset qAllFiscalDatePeriods = this.getAllFiscalYearPeriods(arguments.companyId) />
		<cfelse>
			<cfset qAllFiscalDatePeriods = this.getAllFiscalYearPeriods(arguments.companyId,arguments.distributorId) />
		</cfif>
			
			<!---set the first period based on fiscal periods set in the settings--->
			<cfloop query="qAllFiscalDatePeriods" startrow="1" endrow="1">
				
				<cfset firstPeriodStart = Start_Date />
				<cfset startDateDiff = DateDiff("d", arguments.startDate, Start_Date) />
				<cfif startDateDiff lt 0>
					<cfset startDateDiff = 0 />
				</cfif>
			
			</cfloop>
			
			<!---set the last period based on fiscal periods set in the settings--->
			<cfloop query="qAllFiscalDatePeriods" startrow="#qAllFiscalDatePeriods.RecordCount#" endrow="#qAllFiscalDatePeriods.RecordCount#">
				
				<cfset lastPeriodEnd = End_Date />
				<cfset endDateDiff = DateDiff("d", End_Date, arguments.endDate) />
				<cfif endDateDiff lt 0>
					<cfset endDateDiff = 0 />
				</cfif>
				
			</cfloop>
			
			<!---set the total span from fiscal periods set in the settings--->
			<cfset totalPeriodSpan = DateDiff("d", firstPeriodStart, lastPeriodEnd)+1 />
			<!---set start date and round it--->
			<cfset startDateDiff = startDateDiff / totalPeriodSpan />
			<cfset startDateDiff = Ceiling(startDateDiff) />
			<!---set end date and round it--->
			<cfset endDateDiff = endDateDiff / totalPeriodSpan />
			<cfset endDateDiff = Ceiling(endDateDiff) />
			
			<!---duplicate fiscal periods query so we don't modify the original qAllFiscalDatePeriods query--->
			<cfset sourceFiscalQuery = Duplicate(qAllFiscalDatePeriods) />
			<!---create the new query--->
			<cfset newFiscalQuery = QueryNew("start_date,end_date,period_length,period_position") />
			
			<cfset currentEndDate = DateAdd("d", ((startDateDiff * totalPeriodSpan) * -1)-1, firstPeriodStart) />
			
			<!--- add periods to the start --->
			<cfloop index="indx" from="1" to="#startDateDiff#">
				
				<cfloop query="sourceFiscalQuery">
				
					<cfset currentStartDate = DateAdd("d", 1, currentEndDate) />
					<cfset currentEndDate = DateAdd("d", period_length-1, currentStartDate) />
					<cfif this.checkDateOverLap(arguments.startDate, arguments.endDate, currentStartDate, currentEndDate)>
						<cfset QueryAddRow(newFiscalQuery) />
						<cfset QuerySetCell(newFiscalQuery, "start_date", currentStartDate) />
						<cfset QuerySetCell(newFiscalQuery, "end_date", currentEndDate) />
						<cfset QuerySetCell(newFiscalQuery, "period_length", period_length) />
						<cfset QuerySetCell(newFiscalQuery, "period_position", currentRow) />						
					</cfif>
				</cfloop>
				
			</cfloop>
			
			<cfif this.checkDateOverLap(arguments.startDate, arguments.endDate, firstPeriodStart, lastPeriodEnd)>
				<!--- add the proper periods --->
				<cfloop query="sourceFiscalQuery">
					
					<cfif this.checkDateOverLap(arguments.startDate, arguments.endDate, start_date, end_date)>
						<cfset QueryAddRow(newFiscalQuery) />
						<cfset QuerySetCell(newFiscalQuery, "start_date", start_date) />
						<cfset QuerySetCell(newFiscalQuery, "end_date", end_date) />
						<cfset QuerySetCell(newFiscalQuery, "period_length", period_length) />
						<cfset QuerySetCell(newFiscalQuery, "period_position", currentRow) />
					</cfif>
					
				</cfloop>
			</cfif>
			
			<!--- add periods to the end --->
			<cfset currentEndDate = lastPeriodEnd />
			
			<cfloop index="indx" from="1" to="#endDateDiff#">
				
				<cfloop query="sourceFiscalQuery">
				
					<cfset currentStartDate = DateAdd("d", 1, currentEndDate) />
					<cfset currentEndDate = DateAdd("d", period_length-1, currentStartDate) />
					<cfif this.checkDateOverLap(arguments.startDate, arguments.endDate, currentStartDate, currentEndDate)>
						<cfset QueryAddRow(newFiscalQuery) />
						<cfset QuerySetCell(newFiscalQuery, "start_date", currentStartDate) />
						<cfset QuerySetCell(newFiscalQuery, "end_date", currentEndDate) />
						<cfset QuerySetCell(newFiscalQuery, "period_length", period_length) />
						<cfset QuerySetCell(newFiscalQuery, "period_position", currentRow) />
					</cfif>
			
				</cfloop>
			
			</cfloop>
		
		<cfelse>
		
			<cfset newFiscalQuery = QueryNew("") />
			
		</cfif>
		
		<cfreturn newFiscalQuery />
		
	</cffunction>
	
	<!---////////////////////////////////////////// GETALLFISCALYEARPERIODS FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="getAllFiscalYearPeriods" output="false" returntype="query">
	
		<cfargument name="companyId" required="true" default="" />
		<cfargument name="distributorId" required="true" default="" />
		
	<cfif distributorId eq "">
		<cfquery name="qGetAllFiscalYearPeriods" datasource="#application.datasource#">
		
			SELECT 	Start_Date,
					End_Date,
					Period_Length
			FROM 	Fiscal_Year
			WHERE 	Deleted = 0 
			AND 	Company_Main_ID = '#arguments.companyId#'			
			ORDER BY Start_Date
			
		</cfquery>
	
	<cfelse>
		
		<cfquery name="qGetAllFiscalYearPeriods" datasource="#application.datasource#">

		SELECT	Start_Date, 
				End_Date,
				Period_Length
		FROM	Distributor_Fiscal_Year
		WHERE	Deleted = 0 
		AND 	Company_Main_ID = '#arguments.companyId#'
		AND 	Distributor_ID = '#arguments.distributorId#'
		ORDER BY Start_Date 
			
		</cfquery>
	</cfif>	
		
		<cfreturn qGetAllFiscalYearPeriods />
		
	</cffunction>
	
	<!---////////////////////////////////////////// checkDateOverLap FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="checkDateOverLap" output="false" returntype="boolean">
	
		<cfargument name="startDate1" required="true" default="" />
		<cfargument name="endDate1" required="true" default="" />
		<cfargument name="startDate2" required="true" default="" />
		<cfargument name="endDate2" required="true" default="" />
		
		<cfset returnVal = false />
		
		<!------ check there is any overlap ----->
		<cfif 
			(
				DateDiff("d", arguments.startDate1, arguments.startDate2) GTE 0
				AND
				DateDiff("d", arguments.startDate2, arguments.endDate1) GTE 0
			)
			OR
			(
				DateDiff("d", arguments.startDate1, arguments.endDate2) GTE 0
				AND
				DateDiff("d", arguments.endDate2, arguments.endDate1) GTE 0
			)
			OR
			(
				DateDiff("d", arguments.startDate2, arguments.startDate1) GTE 0
				AND
				DateDiff("d", arguments.startDate1, arguments.endDate2) GTE 0
			)
			OR
			(
				DateDiff("d", arguments.startDate2, arguments.endDate1) GTE 0
				AND
				DateDiff("d", arguments.endDate1, arguments.endDate2) GTE 0
			)
		>
			<cfset returnVal = true />
			
		</cfif>
		
		<cfreturn returnVal />
		
	</cffunction>
	
	<cffunction name="checkDateSpanMatch" output="false" returntype="boolean">
	
		<cfargument name="startDate1" required="true" default="" />
		<cfargument name="endDate1" required="true" default="" />
		<cfargument name="startDate2" required="true" default="" />
		<cfargument name="endDate2" required="true" default="" />
		
		<cfset returnVal =  false>
		<!------ check the dates are same ----->
		<cfif isDate(arguments.startDate1) AND isDate(arguments.startDate1) AND isDate(arguments.endDate1) AND isDate(arguments.endDate2)>
			<cfset returnVal =  DateDiff("d", arguments.startDate1, arguments.startDate1) EQ 0 AND DateDiff("d", arguments.endDate1, arguments.endDate2) EQ 0>
		</cfif>
		
		<cfreturn returnVal />
		
	</cffunction>
	
	<cffunction name="checkDateInInterval" output="false" returntype="boolean">
	
		<cfargument name="startDate" required="true" default="" />
		<cfargument name="endDate" required="true" default="" />
		
		<cfset returnVal = false />
		
		<!------ check there is any overlap ----->
		<cfif 
			(
				DateDiff("d", arguments.startDate, now()) GTE 0
				AND
				DateDiff("d", now(), arguments.endDate) GTE 0
			)			
		>
			<cfset returnVal = true />
			
		</cfif>
		
		<cfreturn returnVal />
		
	</cffunction>

	
	<cffunction name="getCurrentFiscalYearDates" output="false" returntype="struct">
	
		<cfargument name="storedFYStartDate" type="date" required="true" />
		<cfargument name="storedFYEndDate" type="date" required="true" />
		
		 <cfset var Fiscal_Dates = structNew( )>
		
		<cfset storedFYSpan = DateDiff("d", arguments.storedFYStartDate, arguments.storedFYEndDate) + 1 />
		
		<cfset FYStartDate = arguments.storedFYStartDate />
		<cfset FYEndDate = arguments.storedFYEndDate />
		
		<cfset ReachedCurrentFSYear = 0 />
		
		<cfif checkDateInInterval(FYStartDate, FYEndDate)>
		<cfelse>

			<cfif DateDiff("d", FYStartDate, now()) GTE 0><!------ now() > = current stored fiscal year ----->
			
				<cfloop condition="reachedCurrentFSYear NEQ 1">
				
					<cfset FYStartDate = DateAdd("d", 1, FYEndDate) />
					<cfset FYEndDate = DateAdd("d", storedFYSpan, FYStartDate) />

					<cfif checkDateInInterval(FYStartDate, FYEndDate)>
						<cfset ReachedCurrentFSYear = 1 />
					</cfif>
				</cfloop>
			
			<cfelse><!------ now() < current stored fiscal year ----->
				
				<cfloop condition="reachedCurrentFSYear NEQ 1">
				
					<cfset FYEndDate = DateAdd("d", -1, FYStartDate) />
					<cfset FYStartDate = DateAdd("d", storedFYSpan * -1, FYEndDate) />

					<cfif checkDateInInterval(FYStartDate, FYEndDate)>
						<cfset reachedCurrentFSYear = 1 />
					</cfif>
				</cfloop>
		
			</cfif>
		
		</cfif>
	
		<cfset Fiscal_Dates.Fiscal_Start_Date = DateFormat(FYStartDate,"MM/DD/YYYY")>
		<cfset Fiscal_Dates.Fiscal_End_Date = DateFormat(FYEndDate,"MM/DD/YYYY")>
	
		<cfreturn Fiscal_Dates />
	
	</cffunction>
	
	<cffunction name="getStoredFiscalYearDates" output="false" returntype="query">
	
		<cfquery name="selFiscalPeriod" datasource="#application.datasource#">
			SELECT Min(Start_Date) As StartDate, Max(End_Date) As EndDate
			FROM Fiscal_Year
			WHERE Deleted = 0
		</cfquery>
		
		<cfreturn selFiscalPeriod>
		
	</cffunction>

</cfcomponent>