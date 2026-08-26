<!------ Application_Settings_Initialise.cfm ----->
<!------ This file will be included in Application_Vars.cfm
we created this file so that we do not have to modify Application_Vars.cfm file at all.
If Application_Vars.cfm file is modified then we always have problem while building......
----->

<!------ Application_AppSettingsMan.cfm getting called again so that other application.cfm s in other directories also get it loaded if it does nto exist ----->
<!--- Put Application settings into an app var if they do not exist --->
<cfif NOT StructKeyExists(Application, "appSettingsGet")>>
	<cfinclude template="/Application_AppSettingsMan.cfm">
</cfif>

<cfif NOT StructKeyExists(Application, "db_version")>
	<cfdbinfo
	    type       = "version"
	    datasource = "#application.datasource#"
	    name       = "variables.dbinfo" />

	<cflock scope="application" type="EXCLUSIVE" TIMEOUT="10">	
		<cfset application.db_version = variables.dbinfo.database_version>
	</cflock>
</cfif>

<!---<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="VarDoc" reload=1>--->
<cfif NOT StructKeyExists(Application, "Doc_Path")>
	<cflock scope="application" type="Exclusive" TIMEOUT="10">
		<cfset Application.Doc_Path = application.appSettingsGet.getDocumentPath()>
		<cfset Application.Doc_Mapping = application.appSettingsGet.getDocumentMapping()>
	</cflock>
</cfif>

<cfif NOT StructKeyExists(application, "returned_customer_setting") or ( StructKeyExists(application, "returned_customer_setting") and not Isdefined("application.returned_customer_setting.COMPANY_NAME"))>
	<!---reload customer settings into application scope if it doesn't exist--->
	<cfif fileexists("#request.app_general_functions.Get_Document_Path()#\data_files\created\settings\customer_settings\Memory_Data\Data\application_include.cfm")>
		<cfinclude template="#request.app_general_functions.Get_Document_Mapping()#/data_files/created/settings/customer_settings/Memory_Data/Data/application_include.cfm">
	<cfelse>
		<cfinclude template="/settings/customer_settings/Memory_Data/Render_Files.cfm">
	</cfif>
</cfif>
