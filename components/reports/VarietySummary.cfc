<cfcomponent displayname="VarietySummary" hint="this is the subclass of Report" extends="Report">
	<!--- declare properties --->
	<!---<cfset variables.varietySummary = "" />--->
	<cfset variables.isExcelGenerated = true />
	<!--- init --->
	<cffunction name="init" access="public" returntype="VarietySummary" output="false">
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getVarietySummary" returntype="VarietySummary" access="public" output="false">
		<cfreturn  variables.varietySummary/>
	</cffunction> 
	<!--- setter --->
	<cffunction name="setVarietySummary" returntype="void" access="package" output="false">
		<cfargument name="varietySummary" type="VarietySummary" required="true" />
		<cfset variables.varietySummary = arguments.varietySummary />
	</cffunction>
	<!--- methods --->
	<cffunction name="isExcelGenerated" access="public" returntype="boolean" output="true">
		<cfreturn variables.isExcelGenerated />
	</cffunction>
</cfcomponent>