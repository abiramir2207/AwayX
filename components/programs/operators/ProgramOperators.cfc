<!---ProgramOperators.cfc--->
<cfcomponent displayname="Program Operators" hint="Component that holds operator objects for a program">

	<cfset this.operators = ArrayNew(1) />
	<cfset this.lOperatorIds = "" />
	
	<cffunction name="setProgramOperator">
		<cfargument name="operator" type="components.programs.operators.Operator" required="true" />
		
		<cfset ArrayAppend(this.operators, arguments.operator) />
	</cffunction>
	
	<cffunction name="getProgramOperators" returntype="this">
		<cfreturn this.operators />
	</cffunction>
	
	<!--- lOperatorIds setter --->
	<cffunction name="setLOperatorIds" access="public" output="false">
		<cfargument name="lOperatorIds" required="true" default="" />
		<cfset this.lOperatorIds = trim(arguments.lOperatorIds) />
	</cffunction>
	<!--- lOperatorIds getter --->
	<cffunction name="getLOperatorIds" access="public" output="false">
		<cfreturn trim(this.lOperatorIds) />
	</cffunction>
	
</cfcomponent>