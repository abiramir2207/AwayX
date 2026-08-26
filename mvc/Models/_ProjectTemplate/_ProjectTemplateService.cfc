

<cfcomponent name="_ProjectTemplateService" displayname="_ProjectTemplateService" hint="remote service">
	<cfset appSettings = application.appSettingsGet />
	<cffunction name="getMyData" returntype="Array" access="remote">
		<cfargument name="ProgramId" default="0">
		<cfset var qData = "" />
		<cfset var arrRet = ArrayNew(1)>
		<CFQUERY NAME="qData" datasource="#application.datasource#">
					 SELECT TOP 50 	
					 	Contract_Number AS baData,
				 			CASE WHEN cast(CM.Contract_main_Id as int) % 2 = 1 THEN
				 			 	1 
				 			ELSE
				 			 	0
				 			END
			 			AS isSelected	
						FROM	Contract_Main CM
						WHERE CM.Contract_Main_ID > '#arguments.programId#' AND
								deleted = 0
		</CFQUERY>
		<cfloop query="qData">
			<cfscript>
				stData = structNew();
				stData["__type__"] = "mvc.Models._ProjectTemplate.GridData";
				stData["baData"] = qdata.baData;
				stData["isSelected"] = qdata.isSelected;
				ArrayAppend(arrRet, duplicate(stData));
			</cfscript>
		</cfloop>
		<cfreturn arrRet />
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
		<cfset stSettings.appFlex.var1 = "myColumn Label" />
		<cfset stSettings.appFlex.var2 = "This could be any setting in Db" />
		<cfset stSettings.appFlex.SomeLabel = "_ProjectTemplate Label" /> <!--- Some Label --->
		<cfset stsettings.UIAttributes = obj.getUIAttributes()> 
		<cfreturn stSettings>
	</cffunction>
</cfcomponent>
