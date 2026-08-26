<cfcomponent hint="Futures Pricing New Product" extends="components.Base">

	<cfset this.id 			= 0 />
	<cfset this.desc 		= "" />
	<cfset this.custRequest = "" />
	<cfset this.surrogate	= ArrayNew(1) />	

	<cffunction name="init" output="false" returntype="components.futures_pricing.NewProduct">
	
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
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" type="string" required="true" />
		<cfset this.desc = trim(arguments.desc) />
	</cffunction>
	<!--- desc name --->
	<cffunction name="getDesc" access="public" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- custRequest setter --->
	<cffunction name="setCustRequest" access="public" output="false">
		<cfargument name="custRequest" required="true" />
		<cfset this.custRequest = trim(arguments.custRequest) />
	</cffunction>
	<!--- custRequest getter --->
	<cffunction name="getCustRequest" access="public" output="false">
		<cfreturn this.custRequest />
	</cffunction>
	
	<!--- surrogate setter --->
	<cffunction name="setSurrogate" access="public" output="false">
		<cfargument name="surrogate" required="true" default="" type="components.futures_pricing.NewProductSurrogate" />
		<cfset ArrayAppend(this.surrogate, arguments.surrogate) />
	</cffunction>
	<!--- surrogate getter --->
	<cffunction name="getSurrogate" access="public" output="false">
		<cfreturn this.surrogate />
	</cffunction>
	
</cfcomponent>