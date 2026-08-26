<!---BidRequestSpec.cfc--->
<cfcomponent>

	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="void" output="false">	
	</cffunction>
	
	<cffunction name="getBidRequestSpec" output="true">

		<cfargument name="id" required="false" default="0" />

		<!---get spec--->
		<cfquery name="qGetBidRequestSpec" datasource="#application.datasource#">

			SELECT 	Bid_Request_Spec_ID,	
					Bid_Request_Desc,
					Bid_Request_Key
			FROM	Bid_Request_Spec
			WHERE	Deleted = 0
			<cfif arguments.id gt 0>
			AND		Bid_Request_Spec_ID = #arguments.id#
			</cfif>
		
		</cfquery>		
		
		<cfreturn qGetBidRequestSpec />
		
	</cffunction>
	
</cfcomponent>