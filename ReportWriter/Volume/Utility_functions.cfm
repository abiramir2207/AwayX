	<!--- (Start) Function for getting the Fiscal start Date --->
<cffunction name="getFiscalStartPeriod" returntype="struct" output="false">
	<cfargument name="Search_Start_Date" required="yes" type="date">
	<cfargument name="distributorId" required="no" type="string" default="">
	
 <cfset var Fiscal_Dates = structNew( )>
	<cfif arguments.distributorId eq "">
	
	<!--- Get the Starting Fiscal Date and the Ending Fiscal Date for the year --->
		<cfquery name="selFiscalPeriod" datasource="#application.datasource#">
			SELECT Min(Start_Date) As StartDate, Max(End_Date) As EndDate
			FROM Fiscal_Year
			WHERE Deleted = 0
		</cfquery>
		
	<cfelse>
		
	<!--- Get the Starting Fiscal Date and the Ending Fiscal Date for the year --->
		<cfquery name="selFiscalPeriod" datasource="#application.datasource#">
			SELECT Min(Start_Date) As StartDate, Max(End_Date) As EndDate
			FROM Distributor_Fiscal_Year
			WHERE Deleted = 0
			AND 	Distributor_ID = '#arguments.distributorId#'
		</cfquery>
		
	</cfif>
		
		
	<!--- If the Search start date is after the Starting Fiscal Date --->
			<cfif DateDiff('d',selFiscalPeriod.StartDate,Search_Start_Date) GTE 0>
					<cfset DateDifference = DateDiff('d',selFiscalPeriod.StartDate, selFiscalPeriod.Enddate)>
					<cfset Start_Date = selFiscalPeriod.StartDate>
					<cfset End_Date = selFiscalPeriod.EndDate>
	
	<!--- calculate the new Fiscal_Start_Date --->
					<cfloop condition="DateDiff('d',end_Date,Search_Start_Date) GT 0">
						<cfset Start_Date = DateAdd('d',1,End_Date)>
						<cfset End_Date = DateAdd('d',DateDifference +1,Start_Date)>		
					</cfloop>
							
					<cfset Fiscal_Dates.Fiscal_Start_Date = DateFormat(Start_Date,"MM/DD/YYYY")>
					<cfset Fiscal_Dates.Fiscal_End_Date = DateFormat(End_Date,"MM/DD/YYYY")>
				
			<cfelse>
	<!--- If the Search start date is before the Starting Fiscal Date --->
					<cfset DateDifference = DateDiff('d',selFiscalPeriod.StartDate, selFiscalPeriod.Enddate)>
					<cfset Start_Date = selFiscalPeriod.StartDate>
					<cfset End_Date = selFiscalPeriod.EndDate>
					
	<!--- calculate the new Fiscal_Start_Date --->
					<cfloop condition="DateDiff('d',Start_Date,Search_Start_Date) LT 0">
						<cfset End_Date = DateAdd('d',-1,Start_Date)>
						<cfset Start_Date = DateAdd('d',-(DateDifference+1),End_Date)>	
					</cfloop>
								
					<cfset Fiscal_Dates.Fiscal_Start_Date = DateFormat(Start_Date,"MM/DD/YYYY")>
					<cfset Fiscal_Dates.Fiscal_End_Date = DateFormat(End_Date,"MM/DD/YYYY")>			
					
			</cfif>
		<cfreturn Fiscal_Dates>
	</cffunction>
	<!--- (End) Function for getting the Fiscal start Date --->

	<!--- (Start) Function for putting the minus sign after the number --->
	<cffunction name="setNumber" returntype="string" output="false">
		<cfargument name="AnyNumber" required="yes" type="string">
				<cfif Left(AnyNumber,1) eq "-">
					<cfset AnyNumber = RemoveChars(AnyNumber,1,1)>
					<cfset AnyNumber = AnyNumber & "-">
				</cfif>
			<cfreturn AnyNumber>
	</cffunction>
	<!--- (End) Function for putting the minus sign after the number --->

