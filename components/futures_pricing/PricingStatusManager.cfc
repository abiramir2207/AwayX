<cfcomponent hint="Futures Pricing Pricing Status Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.PricingStatusManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		<cfargument name="active" type="string" required="false" default="" />
	
		<cfquery name="qGetPricingStatus" datasource="#application.datasource#">
			SELECT	FP_Pricing_Status_ID, FP_Pricing_Status_Desc
			FROM	FP_Pricing_Status
			WHERE
					Deleted = 0					
		</cfquery>
		
		<cfreturn qGetPricingStatus />
	
	</cffunction>
	
	<cffunction name="getStatusDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />
	
		<cfquery name="qGetPricingStatus" datasource="#application.datasource#">
			SELECT	FP_Pricing_Status_Desc
			FROM	FP_Pricing_Status					
			WHERE
					Deleted = 0
					AND FP_Pricing_Status_ID = #arguments.id#					
		</cfquery>
		
		<cfreturn qGetPricingStatus.FP_Pricing_Status_Desc />
	
	</cffunction>

</cfcomponent>
