<cfcomponent>

	<cffunction name="get" output="false" returntype="query">
	
		<cfargument name="custtypeId" type="numeric" required="false" default="0" />
		
		<!---get the business segments--->
		<cfquery name="getCustomerTypes" datasource="#application.datasource#">
			
			SELECT 	*
			FROM 	Customer_Type
			WHERE	Deleted = 0
			AND		Customer_Type_ID = #arguments.custtypeId#
			
		</cfquery>
		
		<cfreturn getCustomerTypes />
	</cffunction>
	
	<cffunction name="getCustomerTypes" output="false" returntype="query">
		<!---get active business segments--->
	<cfquery name="getCustomerTypes" datasource="#application.datasource#">
SELECT 	*
FROM Customer_Type
where deleted = 0
</cfquery>
		<cfreturn getCustomerTypes />
	</cffunction>
	
<cffunction name="save" output="false">
		
		<cfargument name="custtypeId" type="numeric" required="false" default="" />
		<cfargument name="custtypeDesc" type="string" required="false" default="" />
		
			<!---update business segment desc--->
			<cfquery name="qUpdateCustomerType" datasource="#application.datasource#">
				
				UPDATE	Customer_Type
				SET	Customer_Type_Desc = <cfqueryparam value="#trim(arguments.custtypeDesc)#" cfsqltype="CF_SQL_VARCHAR" />
				WHERE	Deleted = 0
				AND		Customer_Type_ID = #arguments.custtypeId#
			</cfquery>
			</cffunction>
</cfcomponent>
