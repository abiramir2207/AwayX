<cfcomponent hint="Market">
	
	<cffunction name="getMarket" output="false" returntype="query">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetMarket" datasource="#application.datasource#">
			SELECT 	Service_Markets.Service_Market_ID, Service_Markets.Market_Name, Service_Regions.Region_Name, Service_Zones.Zone_Name
			FROM 	Service_Markets
					INNER JOIN Service_Regions
					ON
					Service_Regions.Deleted = 0
					AND
					Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
					INNER JOIN Service_Zones
					ON
					Service_Zones.Deleted = 0
					AND
					Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID			
			WHERE 	
					len(Service_Markets.Market_Name) > 0 
					AND Service_Markets.Deleted = 0
					AND
					<cfif arguments.id>
						Service_Markets.Service_Market_ID = #arguments.id#
					</CFIF>
			ORDER BY Service_Markets.Market_Name
		</cfquery>
		
		<cfreturn qGetMarket />
		
	</cffunction>
	
	
	<cffunction name="getBrokers" output="false" returntype="query">
		
		<cfargument name="marketId" type="numeric" required="true" />
		<cfargument name="checkForBusinessSegment" type="boolean" required="false" default="0" />
		<cfargument name="BusinessSegmentId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetBrokers" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID,
					BSA_Foodservice_Brokers.Broker_Shard,
					BSA_Foodservice_Brokers.Broker_Name,
					BSA_Foodservice_Brokers.E_Mail,
					BSA_Foodservice_Brokers.Legacy_Broker_ID
			FROM 	BSA_Foodservice_Brokers						
			WHERE 	BSA_Foodservice_Brokers.deleted = 0 and 
					BSA_Foodservice_Brokers.Service_market_ID = #arguments.marketId#
					<cfif arguments.checkForBusinessSegment>
					AND BSA_Foodservice_Brokers.Business_Segment_ID = #arguments.BusinessSegmentId#
					</cfif>
		</cfquery>
		
		<cfreturn qGetBrokers />
		
	</cffunction>
	
	<cffunction name="getBrokerIds" output="false" returntype="query">
		
		<cfargument name="marketId" type="string" required="true" />
		<cfargument name="checkForBusinessSegment" type="boolean" required="false" default="0" />
		<cfargument name="BusinessSegmentId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetBrokerIds" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID,
					BSA_Foodservice_Brokers.Broker_Shard,
					BSA_Foodservice_Brokers.Broker_Name,
					BSA_Foodservice_Brokers.E_Mail,
					BSA_Foodservice_Brokers.Legacy_Broker_ID
			FROM 	BSA_Foodservice_Brokers						
			WHERE 	BSA_Foodservice_Brokers.deleted = 0 and 
					BSA_Foodservice_Brokers.Service_market_ID In (#arguments.marketId#)
					<cfif arguments.checkForBusinessSegment>
					AND BSA_Foodservice_Brokers.Business_Segment_ID = #arguments.BusinessSegmentId#
					</cfif>
		</cfquery>
		
		<cfreturn qGetBrokerIds />
		
	</cffunction>
</cfcomponent>