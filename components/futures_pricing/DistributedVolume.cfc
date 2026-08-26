<cfcomponent hint="DistributedVolume">
	
	<cfset this.startDate = "" />
	<cfset this.endDate = "" />
	<cfset this.periodStartDate = "" />
	<cfset this.periodEndDate = "" />
	<cfset this.volume = "" />
	<cfset this.order = "" />
	<cfset this.productId = "" />
	<cfset this.desc = "" />
	<cfset this.limitedTimeOffer = 0 />
	<cfset this.daysUsedUp = 0 />
	
	<!---startDate setter --->
	<cffunction name="setStartDate" output="false">
		<cfargument name="startDate" type="string" required="true" />
		<cfset this.startDate = arguments.startDate />
	</cffunction>
	<!---startDate getter --->
	<cffunction name="getStartDate" returntype="string" output="false">
		<cfreturn this.startDate />
	</cffunction>
	
	<!---endDate setter --->
	<cffunction name="setEndDate" output="false">
		<cfargument name="endDate" type="string" required="true" />
		<cfset this.endDate = arguments.endDate />
	</cffunction>
	<!---endDate getter --->
	<cffunction name="getEndDate" returntype="string" output="false">
		<cfreturn this.endDate />
	</cffunction>
	
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
	
	<!---volume setter --->
	<cffunction name="setVolume" output="false">
		<cfargument name="volume" type="string" required="true" />
		<cfset this.volume = arguments.volume />
	</cffunction>
	<!---volume getter --->
	<cffunction name="getVolume" returntype="string" output="false">
		<cfreturn this.volume />
	</cffunction>
	
	<!---order setter --->
	<cffunction name="setOrder" output="false">
		<cfargument name="order" type="string" required="true" />
		<cfset this.order = arguments.order />
	</cffunction>
	<!---order getter --->
	<cffunction name="getOrder" returntype="string" output="false">
		<cfreturn this.order />
	</cffunction>
	
	<!---productId setter --->
	<cffunction name="setProductID" output="false">
		<cfargument name="productID" type="string" required="true" />
		<cfset this.productId = arguments.productID />
	</cffunction>
	<!---productId getter --->
	<cffunction name="getProductID" returntype="string" output="false">
		<cfreturn this.productId />
	</cffunction>
	
	<!---desc setter --->
	<cffunction name="setDesc" output="false">
		<cfargument name="desc" type="string" required="true" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!---desc getter --->
	<cffunction name="getDesc" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!---limitedTimeOffer setter --->
	<cffunction name="setLimitedTimeOffer" output="false">
		<cfargument name="limitedTimeOffer" type="string" required="true" />
		<cfset this.limitedTimeOffer = arguments.limitedTimeOffer />
	</cffunction>
	<!---limitedTimeOffer getter --->
	<cffunction name="getLimitedTimeOffer" returntype="string" output="false">
		<cfreturn this.limitedTimeOffer />
	</cffunction>
	
	<!--- daysUsedUp setter --->
	<cffunction name="setDaysUsedUp" output="false">
		<cfargument name="daysUsedUp" type="numeric" required="true" />
		<cfset this.daysUsedUp = this.daysUsedUp + arguments.daysUsedUp />
	</cffunction>
	<!--- daysUsedUp getter --->
	<cffunction name="getDaysUsedUp" returntype="numeric" output="false">
		<cfreturn this.daysUsedUp />
	</cffunction>
	
</cfcomponent>