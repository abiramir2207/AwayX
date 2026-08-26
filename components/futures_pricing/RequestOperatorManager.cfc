<cfcomponent>

   	<cffunction name="getOperatorList" output="false" returntype="query">
		
		<cfargument name="lOperatorIds" type="string" required="true" default="">
		
		<cfquery name="qGetOperator" datasource="#application.datasource#">
			SELECT 	BSA_Operator_ID,	
					Operator_Name
			FROM 	BSA_Operator
			WHERE	
					Deleted = 0
					AND
					<cfif arguments.lOperatorIds NEQ "">
					BSA_Operator_ID in (#arguments.lOperatorIds#)
					<cfelse>
					1=2
					</cfif>
			ORDER BY Operator_Name  ASC
		</cfquery>
		
		<cfreturn qGetOperator />	

   	</cffunction>
	
</cfcomponent>