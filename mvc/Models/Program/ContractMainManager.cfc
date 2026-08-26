<cfcomponent name="ContractMainManager" displayname="ContractMainManager" hint="Service for Fx ContarctMain">
	<cfset appSettings = application.appSettingsGet />
	<cffunction name="init" output="false" returntype="mvc.Models.ContractProd.ContractProdService">
	
		<cfreturn this />
		
	</cffunction>
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">
		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>
		<cflog text="getSettingsObject:: #arguments.userId#"/>
		
		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.Models.SettingsService") />
		<cfset stSettings.user = StructNew()/>
		<cfset stSettings.user = obj.getUserObject(arguments.userId) />

		<!--- APPSETTINGS: return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<cfset stSettings.appSettings = StructNew()/>
		<cfset stSettings.appSettings["__type__"] = "mvc.Models.Settings.vos.AppSettings"/>
		<!--- <cfset stSettings.appSettings = obj.getAppSettingsObject() />  --->
		
		<cfset structinsert(stSettings.appSettings,"Exact_List_Matching_On",appSettings.Exact_List_Matching_On)>
		<!--- APP FLEX: Custom settings --->
		<cfset stSettings.appFlex = StructNew()/>
		<cfset stSettings.appFlex.var1 = "myColumn Label" />
		<cfset stSettings.appFlex.var2 = "Edit a Pending Update" />
		<cfset stSettings.appFlex.brand = obj.getProductGroupLabels().brand />
		<cfset stSettings.appFlex.qBrand = obj.getProductGroupLabels().qBrand />
		<cfset stSettings.appFlex.typeCode = obj.getProductGroupLabels().typeCode /> 
		<cfset stSettings.appFlex.typeGroup = obj.getProductGroupLabels().typeGroup />
		<cfset stsettings.UIAttributes = obj.getUIAttributes()>
		<!---<cfset stsettings = obj.getSettingsObject(arguments.userId) />--->
		<cfreturn stSettings>
	</cffunction>
</cfcomponent>