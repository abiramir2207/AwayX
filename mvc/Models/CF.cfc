<cfcomponent alias="mvc.Models.CF" hint="Wrapper for CF tags to be used in cfscript">
	<cffunction name="include" hint="cfinclude wrapper">
		<cfargument name="template" type="string" required="true"/>
		<cfinclude template="#arguments.template#" />
	</cffunction>
	
	<cffunction name="abort" hint="abort wrapper">
		<cfabort/>
	</cffunction>
	
	<cffunction name="dump" hint="dump wrapper" returntype="String">
		<cfargument name="var" required="true"/>
		<cfset var retvar = '' />
		<cfsavecontent variable="retVar">
			<cfDump var="#arguments.var#"/>
		</cfsavecontent>
		<cfreturn retVar />
	</cffunction>
	
	
	<cffunction name="serverName" hint="check CGI">
		<cfreturn cgi.HTTP_HOST />
	</cffunction>
	<!---<cffunction name="include" hint="cfinclude wrapper">
	</cffunction>--->
	
</cfcomponent>