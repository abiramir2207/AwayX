

<cfcomponent name="ContractProd" displayname="ContractProd" extends="mvc.Models.Item.ItemSearchService" hint="Search Contract Products">
	<cfset appSettings = application.appSettingsGet />
		<cffunction name="init" output="false" returntype="mvc.Models.ContractProd.ContractProdService">
	
		<cfreturn this />
		
	</cffunction>
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">
		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>
		
		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.Models.SettingsService") />
		<cfset stSettings.user = StructNew()/>
		<cfset stSettings.user = obj.getUserObject(arguments.userId) />

		<!--- APPSETTINGS: return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<!--- <cfset stSettings.appSettings = StructNew()/> --->
		<cfset stSettings.appSettings = obj.getAppSettingsObject() /> 
		<!--- APP FLEX: Custom settings --->
		<cfset stSettings.appFlex = StructNew()/>
		<cfreturn stSettings>
	</cffunction>
</cfcomponent>