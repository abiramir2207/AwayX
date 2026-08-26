<!---BidRequestStatus.cfc--->
<cfcomponent>

	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="void" output="false">	
	</cffunction>
	
	<cffunction name="getBidRequestStatus" output="false">

		<cfargument name="id" required="false" default="0" />
		<cfargument name="filterSplit" required="false" default="1" />

		<!---get status--->
		<cfquery name="qGetBidRequestStatus" datasource="#application.datasource#">

			SELECT 	Bid_Request_Status_ID,	
					Status_Desc
			FROM	Bid_Request_Status
			WHERE	Deleted = 0
			<cfif arguments.id gt 0>
			AND		Bid_Request_Status_ID = #arguments.id#
			</cfif>
			<cfif arguments.filterSplit eq 0>
			AND		Status_Desc != 'Split'
			</cfif>
		
		</cfquery>		
		
		<cfreturn qGetBidRequestStatus />
		
	</cffunction>
	
</cfcomponent>