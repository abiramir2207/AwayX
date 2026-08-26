	<!--- Return Budget Max Control Levels --->	
	<cffunction name="getControlLevels" output="false" hint="returns maximum budget level" returntype="numeric">
		<cfargument name="budget_type" required="Yes" type="numeric"> 
		<cfset var controlLevel = "2" />
			<cfreturn controlLevel />			
	</cffunction>
