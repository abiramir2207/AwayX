<cfcomponent hint="handle remote FLEX errors" output="false">
	
	<cffunction name="logError" returntype="any" access="remote">
		<cfargument name="errorDetail" type="String" default="flex_error_Detail">
		<cfargument name="errorString" type="string" default="flex_error_String" required="false">
		
		<cflog text="FLEX ERROR! #errorString# :: #errorDetail#" log="Application"/>
		<!--- <cfthrow detail="#errorDetail#" message="#errorString#" errorcode="FX_Remote"> --->
		
	</cffunction>
</cfcomponent>