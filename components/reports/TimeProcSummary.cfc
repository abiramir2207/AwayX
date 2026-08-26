<cfcomponent displayname="TimeProcSummary" hint="this is the subclass of Report" extends="Report">
	<!--- declare properties --->
	<cfset variables.timeProcSummary = "" />
	<cfset variables.isExcelGenerated = true />

	<!--- init --->
	<cffunction name="init" access="public" returntype="TimeProcSummary" output="false">
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getTimeProcSummary" returntype="TimeProcSummary" access="public" output="false">
		<cfreturn  variables.timeProcSummary/>
	</cffunction>
	<!--- setter --->
	<cffunction name="setTimeProcSummary" returntype="void" access="private" output="false">
		<cfargument name="timeProcSummary" type="TimeProcSummary" required="true" />
		<cfset variables.timeProcSummary = arguments.timeProcSummary />
	</cffunction>
	<!--- methods --->
	<cffunction name="isExcelGenerated" access="public" returntype="boolean" output="true">
		<cfreturn variables.isExcelGenerated />
	</cffunction>
</cfcomponent>