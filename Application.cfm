<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Turn on Client and Session variables capabilities (to enable CFTOKEN & CFID only)				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <CFSET application.errortracking.status = "1"> --->
<!---Sets datasource name--->
<!---Sets datasource name--->
<CFSILENT>
<cfinclude template="/application_datasource.cfm">

<!--- Put Application settings into an app var if they do not exist --->
<cfif NOT IsDefined("application.appSettingsGet")>
	<cfinclude template="/Application_AppSettingsMan.cfm">
</cfif>

</CFSILENT>
<cfinclude template="/Application_Common.cfm">

<cfif NOT IsDefined("application.masterDataCacheSpan") OR NOT IsDefined("application.userDataCacheSpan")>
<cflock scope = "Application"  timeout = "20" type = "Exclusive">
	<cfset APPLICATION.masterDataCacheSpan = CreateTimeSpan(0, 12, 0, 0) />
	<cfset APPLICATION.userDataCacheSpan = CreateTimeSpan(0, 12, 0, 0) />
</cflock>
</cfif>
