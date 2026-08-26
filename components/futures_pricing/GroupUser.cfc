<cfcomponent hint="Futures Pricing Group User" extends="components.Base">

	<cfset this.id 		= 0 />
	<cfset this.userId 		= "" />
	<cfset this.userGroupId = 0 />
	<cfset this.name 	= "" />	

	<cffunction name="init" output="false" returntype="components.futures_pricing.GroupUser">
	
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
	
	<!--- userId setter --->
	<cffunction name="setUserId" access="public" output="false">
		<cfargument name="userId" type="string" required="true" />
		<cfset this.userId = arguments.userId />
	</cffunction>
	<!--- userId getter --->
	<cffunction name="getUserId" access="public" returntype="string" output="false">
		<cfreturn this.userId />
	</cffunction>
	
	<!--- userGroupId setter --->
	<cffunction name="setUserGroupId" access="public" output="false">
		<cfargument name="userGroupId" type="numeric" required="true" />
		<cfset this.userGroupId = arguments.userGroupId />
	</cffunction>
	<!--- userGroupId getter --->
	<cffunction name="getUserGroupId" access="public" returntype="numeric" output="false">
		<cfreturn this.userGroupId />
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