<cfcomponent displayname="Participation" hint="this is the subclass of Report" extends="Report">
	<!--- declare properties --->
	<cfset variables.participation = "" />
	<cfset variables.isExcelGenerated = true />
	<!--- init --->
	<cffunction name="init" access="public" returntype="Participation" output="false">
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getParticipation" returntype="Participation" access="public" output="false">
		<cfreturn  variables.participation/>
	</cffunction>
	<!--- setter --->
	<cffunction name="setParticipation" returntype="void" access="private" output="false">
		<cfargument name="participation" type="Participation" required="true" />
		<cfset variables.participation = arguments.participation />
	</cffunction>
	<!--- methods --->
	<cffunction name="isExcelGenerated" access="public" returntype="boolean" output="true">
		<cfreturn variables.isExcelGenerated />
	</cffunction>
</cfcomponent>