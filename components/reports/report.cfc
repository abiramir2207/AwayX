<cfcomponent displayname="Report" hint="this is the base(abstract) class">
	<!--- declare properties --->
	<cfset variables.isExcelGenerated = "false" />
	<!--- init --->
	<cffunction name="init" access="public" returntype="Report" output="false">
		<cfthrow type="Error.abstractClass" message="You can't instantiate this class since it's abstract one" />
	</cffunction>

	<!--- methods --->
	<cffunction name="isExcelGenerated" access="public" returntype="boolean" output="true">
		<cfreturn variables.isExcelGenerated />
	</cffunction>
</cfcomponent>