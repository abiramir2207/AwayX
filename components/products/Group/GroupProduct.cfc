<cfcomponent>

	<cfset this.item = "" />
	<cfset this.upc = "" />
	<cfset this.desc = "" />
	
	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- item setter --->
	<cffunction name="setItem" access="public" output="false">
		<cfargument name="item" required="true" default="" />
		<cfset this.item = arguments.item />
	</cffunction>
	<!--- item getter --->
	<cffunction name="getItem" access="public" output="false">
		<cfreturn this.item />
	</cffunction>
	
	<!--- upc setter --->
	<cffunction name="setUpc" access="public" output="false">
		<cfargument name="upc" required="true" default="" />
		<cfset this.upc = arguments.upc />
	</cffunction>
	<!--- upc getter --->
	<cffunction name="getUpc" access="public" output="false">
		<cfreturn this.upc />
	</cffunction>
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" required="true" default="" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc getter --->
	<cffunction name="getDesc" access="public" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	
</cfcomponent>