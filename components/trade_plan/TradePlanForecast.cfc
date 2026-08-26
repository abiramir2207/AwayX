<!---
	Name:
		TradePlanForecast.cfc
	Created By:
		Tim Ford 09/10/2003 
	Description:
		Trade Plan Forecast component
--->

<cfcomponent hint="Component used to get forecast information specific to the trade planner.">

	<cffunction access="public" name="getForecastData" output="false" returntype="query" hint="Gets basic forecast data.">
		
		<cfargument name="forecastId" type="string" required="true">
		
		<cfquery name="qGetForecastData" datasource="#application.datasource#">
			SELECT 	* 
			FROM	Forecast
			WHERE	Forecast_Id = #arguments.forecastId#
		</cfquery>	
	
		<cfreturn qGetForecastData>
		
	</cffunction>
	
	<cffunction access="public" name="getForecastProdData" output="false" returntype="query" hint="Gets product forecast data.">
		
		<cfargument name="forecastId" type="numeric" required="true" default="">
		<cfargument name="tradeSpan" type="numeric" required="true" default="">
		<cfargument name="forecastSpan" type="numeric" required="true" default="">
		
		<cfquery name="qGetForecastProdData" datasource="#application.datasource#">
			SELECT 	Round((Forecast_Volume.Volume_CS * #arguments.tradeSpan#) / #arguments.forecastSpan#,0) as Volume_CS,	
					Forecast_Product.Product_Id
			FROM 	Forecast_Product
					LEFT JOIN Forecast_Volume
					ON
					(
					Forecast_Volume.Forecast_ID = Forecast_Product.Forecast_ID 
					AND Forecast_Volume.Product_ID = Forecast_Product.Product_ID
					AND Forecast_Volume.Deleted = 0
					)
			WHERE 	Forecast_Product.Forecast_id = #arguments.forecastId#
			AND		Forecast_Product.Deleted = 0
		</cfquery>	
	
		<cfreturn qGetForecastProdData>
		
	</cffunction>
	
	<cffunction access="public" name="checkProdForecast" output="false" returntype="struct" hint="Checks the products and QTY of a forecast.">
		
		<cfargument name="product_id" type="string" required="true" default="">
		<cfargument name="qty" type="string" required="true" default="">
		<cfargument name="qForecastProdData" type="query" required="true" default="">
		
		<!---set up the return struct--->
		<cfset returnStruct = StructNew() />
		
		<!---query on the query that was passed to get status data--->
		<cfquery name="qCheckProdInFC" dbtype="query">
			SELECT 	Volume_CS
			FROM	arguments.qForecastProdData
			WHERE	Product_ID = '#arguments.product_id#'	
		</cfquery>	

		<!---if we have a record count then let the struct know and handle qty status--->
		<cfif qCheckProdInFC.RecordCount>
			
			<cfset returnStruct.ProdExists = 1 />
			
			<!---if the volume is null then we got a zero from the forecast--->
			<cfif not CompareNoCase(qCheckProdInFC.Volume_CS, "")>
				<cfset returnStruct.qtyStatus = "isZero" />
			<!---if the forecast volume doesn't match the trade planner qty--->
			<cfelseif CompareNoCase(qCheckProdInFC.Volume_CS, arguments.qty)>
				<cfset returnStruct.qtyStatus = "notMatch" />
			<!---if they do match--->
			<cfelse>
				<cfset returnStruct.qtyStatus = "match" />
			</cfif>
		<!---set for non existent products--->
		<cfelse>
			<cfset returnStruct.ProdExists = 0 />
			<cfset returnStruct.qtyStatus = "doesNotExist" />
		</cfif>
		
		<cfreturn returnStruct>
		
	</cffunction>
	
	<cffunction access="public" name="getForecastDist" output="false" returntype="query" hint="Gets forecast distributors.">
		
		<cfargument name="forecastId" type="string" required="true">
		
		<cfquery name="qGetForecastDist" datasource="#application.datasource#">
			SELECT 	* 
			FROM	Forecast_Distributor
			WHERE	Forecast_Id = '#arguments.forecastId#'
		</cfquery>	
	
		<cfreturn qGetForecastDist>
		
	</cffunction>
	
</cfcomponent>