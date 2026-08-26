<cfcomponent hint="Application Number Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.settings.ApplicationNumberManager">
	
		<cfreturn this />
		
	</cffunction>
	

	<cffunction name="getFormatedBANumber" output="false" returntype="string">
		<cfargument name="number" required="true" type="string" />
		<cfargument name="prefix" required="false" type="string" default="" />
		
		<cfset returnValue = arguments.number />
		<cfset sPrefix = "" />
		<cfset usePrefix = 0 />
		<cfif Len(Trim(arguments.prefix)) GT 0>
			<cfset usePrefix = 1 />
		</cfif>
		<cfif usePrefix EQ 1>
		
		<!---BJF D10943, some environments append a letter to the beginning of the program string, so don't add dash --->		
			<cfif len(trim(arguments.prefix)) LT 4>
				<cfset sPrefix = Left(arguments.prefix, 3) />
				<cfset sPrefix = sPrefix & "-" />
			<cfelse>
				<cfset sPrefix = trim(arguments.prefix)>
			</cfif>
		</cfif>
	
		<cfset returnValue = sPrefix & returnValue />
		<cfreturn returnValue />
		
	</cffunction>
	
</cfcomponent>