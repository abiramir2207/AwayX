<cfcomponent hint="program_dates_manager">
	
	<cfset this.periodStartDate = "" />
	<cfset this.periodEndDate = "" />
	
	<!--- periodStartDate setter --->
	<cffunction name="setPeriodStartDate" output="false">
		<cfargument name="periodStartDate" type="string" required="true" />
		<cfset this.periodStartDate = arguments.periodStartDate />
	</cffunction>
	<!--- periodStartDate getter --->
	<cffunction name="getPeriodStartDate" returntype="string" output="false">
		<cfreturn this.periodStartDate />
	</cffunction>
	
	<!--- periodEndDate setter --->
	<cffunction name="setPeriodEndDate" output="false">
		<cfargument name="periodEndDate" type="string" required="true" />
		<cfset this.periodEndDate = arguments.periodEndDate />
	</cffunction>
	<!--- periodEndDate getter --->
	<cffunction name="getPeriodEndDate" returntype="string" output="false">
		<cfreturn this.periodEndDate />
	</cffunction>
	
</cfcomponent>