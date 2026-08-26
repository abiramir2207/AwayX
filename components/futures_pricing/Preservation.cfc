<cfcomponent hint="Futures Pricing Preservation" extends="components.Base">

	<cfset this.id 		= 0 />
	<cfset this.desc	= "" />
	<cfset this.active	= 1 />
	<cfset this.createdDate	= "" />
	<cfset this.deleted	= 0 />
	<cfset this.updatedBy 	= "" />
	<cfset this.updatedByUserName 	= "" />	
	<cfset this.updatedOn 	= "" />

	<cffunction name="init" output="false" returntype="components.futures_pricing.Preservation">
	
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
	
	<!--- active setter --->
	<cffunction name="setActive" access="public" output="false">
		<cfargument name="active" type="numeric" required="true" />
		<cfset this.active = arguments.active />
	</cffunction>
	<!--- active getter --->
	<cffunction name="getActive" access="public" returntype="numeric" output="false">
		<cfreturn this.active />
	</cffunction>
	
	<!--- updatedBy setter --->
	<cffunction name="setUpdatedBy" access="public" output="false">
		<cfargument name="updatedBy" type="string" required="true" />
		<cfset this.updatedBy = arguments.updatedBy />
	</cffunction>
	<!--- updatedBy getter --->
	<cffunction name="getUpdatedBy" access="public" returntype="string" output="false">
		<cfreturn this.updatedBy />
	</cffunction>
	
	<!--- updatedByUserName setter --->
	<cffunction name="setUpdatedByUserName" access="public" output="false">
		<cfargument name="updatedByUserName" type="string" required="true" />
		<cfset this.updatedByUserName = arguments.updatedByUserName />
	</cffunction>
	<!--- updatedByUserName getter --->
	<cffunction name="getUpdatedByUserName" access="public" returntype="string" output="false">
		<cfreturn this.updatedByUserName />
	</cffunction>
	
	<!--- updatedOn setter --->
	<cffunction name="setUpdatedOn" access="public" output="false">
		<cfargument name="updatedOn" type="string" required="true" />
		<cfset this.updatedOn = arguments.updatedOn />
	</cffunction>
	<!--- updatedOn getter --->
	<cffunction name="getUpdatedOn" access="public" returntype="string" output="false">
		<cfreturn this.updatedOn />
	</cffunction>
	
</cfcomponent>