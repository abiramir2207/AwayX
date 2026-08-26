<cfcomponent hint="Duplicate Program Template" extends="components.Base">

	<cfset variables.pageID 	= 0 />
	<cfset variables.pageName	= "" />
	<cfset variables.hasTemplate = -1 />	

	<cffunction name="init" output="false" returntype="DuplicateTemplate">
		<cfargument name="pageID" 		type="numeric" required="true" />
		<cfargument name="pageName" 	type="string" required="true" />
		<cfargument name="hasTemplate" 	type="numeric" required="true" />
		<cfset setPageID(arguments.pageID) />
		<cfset setPageName(arguments.pageName) />
		<cfset setHasTemplate(arguments.hasTemplate) /> 
		<cfreturn this />
	</cffunction>
	
	<!--- pageid setter--->
	<cffunction name="setPageId" access="public" output="false">
		<cfargument name="pageid" type="numeric" required="true" />
		<cfset variables.pageID = arguments.pageid />
	</cffunction>
	<!--- pageid getter--->
	<cffunction name="getPageId" access="public" returntype="numeric" output="false">
		<cfreturn variables.pageID />
	</cffunction>
	
	<!--- pageName setter--->
	<cffunction name="setPageName" access="public" output="false">
		<cfargument name="pagename" type="string" required="true" />
		<cfset variables.pageName = arguments.pagename />
	</cffunction>
	<!--- pageName getter--->
	<cffunction name="getPageName" access="public" returntype="string" output="false">
		<cfreturn variables.pageName />
	</cffunction>
	
	<!--- hasTemplate setter--->
	<cffunction name="setHasTemplate" access="public" output="false">
		<cfargument name="hastemplate" type="numeric" required="true" />
		<cfset variables.hasTemplate = arguments.hastemplate />
	</cffunction>
	<!--- hasTemplate getter--->
	<cffunction name="getHasTemplate" access="public" returntype="numeric"  output="false">
		<cfreturn variables.hasTemplate />
	</cffunction>	
</cfcomponent>
