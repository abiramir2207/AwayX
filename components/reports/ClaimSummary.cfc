<cfcomponent displayname="ClaimSummary" hint="this is the subclass of Report" extends="Report">
	<!--- declare properties --->
	<cfset variables.claimSummary = "" />
	<cfset variables.isExcelGenerated = "true" />
	<!--- init --->
	<cffunction name="init" access="public" returntype="ClaimSummary" output="false">
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getClaimSummary" returntype="ClaimSummary" access="public" output="false">
		<cfreturn  variables.claimSummary/>
	</cffunction>
	<cffunction name="getIsExcelGenerated" returntype="boolean" access="public" output="false">
		<cfreturn  variables.isExcelGenerated/>
	</cffunction>
	<!--- setter --->
	<cffunction name="setClaimSummary" returntype="void" access="public" output="false">
		<cfargument name="claimSummary" type="ClaimSummary" required="true" />
		<cfset variables.claimSummary = arguments.claimSummary />
	</cffunction>
	<cffunction name="setIsExcelGenerated" returntype="void" access="private" output="false">
		<cfargument name="isExcelGenerated" type="boolean" required="true" />
		<cfset variables.isExcelGenerated = arguments.isExcelGenerated />
	</cffunction>
	<!--- methods --->
	<cffunction name="isExcelGenerated" access="public" returntype="boolean" output="true">
		<cfreturn this.getIsExcelGenerated() />
	</cffunction>
</cfcomponent>