<cfcomponent displayname="SavingCost" hint="this is the subclass of Report" extends="Report">
	<!--- declare properties --->
	<cfset variables.savingCost = "" />
	<cfset variables.isExcelGenerated = true />

	<!--- init --->
	<cffunction name="init" access="public" returntype="SavingCost" output="false">
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getSavingCost" returntype="SavingCost" access="public" output="false">
		<cfreturn  variables.savingCost/>
	</cffunction>
	<!--- setter --->
	<cffunction name="setCostSaving" returntype="void" access="private" output="false">
		<cfargument name="savingCost" type="SavingCost" required="true" />
		<cfset variables.savingCost = arguments.savingCost />
	</cffunction>
	<!--- methods --->
	<cffunction name="isExcelGenerated" access="public" returntype="boolean" output="true">
		<cfreturn variables.isExcelGenerated />
	</cffunction>
</cfcomponent>