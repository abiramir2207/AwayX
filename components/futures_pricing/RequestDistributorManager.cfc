<cfcomponent>

   	<cffunction name="getDistributorList" output="false" returntype="query">
		
		<cfargument name="lDistributorIds" type="string" required="true" default="">
		
		<cfquery name="qGetDistributor" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Customers_ID,	
					Name
			FROM 	BSA_Foodservice_Customers
			WHERE	
					Deleted = 0
					AND
					<cfif arguments.lDistributorIds NEQ "">
					BSA_Foodservice_Customers_ID in (#replace(listqualify(arguments.lDistributorIds, "'"), '"', "'")#)
					<cfelse>
					1=2
					</cfif>
			ORDER BY Name  ASC
		</cfquery>
		
		<cfreturn qGetDistributor />	

   	</cffunction>

</cfcomponent>