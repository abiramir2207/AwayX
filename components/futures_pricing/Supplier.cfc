<cfcomponent hint="Futures Pricing Supplier" extends="components.Base">

	<cfset this.id 		= 0 />
	<cfset this.name 		= "" />	

	<cffunction name="init" output="false" returntype="components.futures_pricing.Supplier">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" returntype="numeric" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- name setter --->
	<cffunction name="setName" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset this.name = arguments.name />
	</cffunction>
	<!--- desc name --->
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn this.name />
	</cffunction>
	
</cfcomponent>