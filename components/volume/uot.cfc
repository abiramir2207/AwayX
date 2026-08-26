<cfcomponent hint="Volume Unit Of Time" extends="components.Base">

	<cfset this.id 		= 0 />
	<cfset this.desc	= "" />
	<cfset this.nounDesc	= "" />
	<cfset this.multiplier 	= 0 />
	
	<cffunction name="init" output="false" returntype="components.volume.uot">
	
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
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc getter --->
	<cffunction name="getDesc" access="public" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- nounDesc setter --->
	<cffunction name="setNounDesc" access="public" output="false">
		<cfargument name="nounDesc" type="string" required="true" />
		<cfset this.nounDesc = arguments.nounDesc />
	</cffunction>
	<!--- nounDesc getter --->
	<cffunction name="getNounDesc" access="public" returntype="string" output="false">
		<cfreturn this.nounDesc />
	</cffunction>
	
	<!--- multiplier setter --->
	<cffunction name="setMultiplier" access="public" output="false">
		<cfargument name="multiplier" type="string" required="true" />
		<cfif IsNumeric(arguments.multiplier)>
			<cfset this.multiplier = arguments.multiplier />
		<cfelse>
			<cfset this.multiplier = 0 />
		</cfif>
	</cffunction>
	<!--- multiplier getter --->
	<cffunction name="getMultiplier" access="public" returntype="numeric" output="false">
		<cfreturn this.multiplier />
	</cffunction>
	
</cfcomponent>