<!---Operator.cfc--->
<cfcomponent displayname="Operator Component" hint="Model component for a Program Operator">

	<cfset this.id = "" />
	<cfset this.operatorId = 0 />
	<cfset this.programId = 0 />
	<cfset this.name = "" />
	
	<cffunction name="init" output="false" returntype="components.programs.operators.Operator">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" required="true" default="" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" output="false">
		<cfreturn this.id />
	</cffunction>

	<!--- operatorId setter --->
	<cffunction name="setOperatorId" access="public" output="false">
		<cfargument name="operatorId" required="true" default="" />
		<cfset this.operatorId = arguments.operatorId />
	</cffunction>
	<!--- operatorId getter --->
	<cffunction name="getOperatorId" access="public" output="false">
		<cfreturn this.operatorId />
	</cffunction>
	
	<!--- programId setter --->
	<cffunction name="setProgramId" access="public" output="false">
		<cfargument name="programId" required="true" default="" />
		<cfset this.programId = arguments.programId />
	</cffunction>
	<!--- programId getter --->
	<cffunction name="getProgramId" access="public" output="false">
		<cfreturn this.programId />
	</cffunction>
	
	<!--- name setter --->
	<cffunction name="setName" access="public" output="false">
		<cfargument name="name" required="true" default="" />
		<cfset this.name = arguments.name />
	</cffunction>
	<!--- name getter --->
	<cffunction name="getName" access="public" output="false">
		<cfreturn this.name />
	</cffunction>
	
</cfcomponent>