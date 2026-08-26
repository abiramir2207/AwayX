<cfcomponent displayname="Application" hint="extend app.cfc" output="false" extends="AppProxy"> <!--- extends="AppProxy"  --->
<!--- 	<cffunction name="onError" returntype="void" output="true">
		<cfargument 				name="exception" required="yes">
		 <cfargument type="string" 	name="eventName" required="yes">
		 <cfargument type="string" 	name="error" required="no" default="xx">
		 <cfset variables.remoteException = StructNew() />
		<cfset variables.remoteException = arguments.exception>
         <cfinclude template="/site_wide_error_handler.cfm">
		<cfthrow type="Any" detail="#arguments.eventName#" message="#arguments.exception#" />

	</cffunction> --->

	<cffunction name = "onRequestStart" returntype="boolean" output="true">
		<cfargument name="targetPage" required="true" type="string">
        <cfset structInsert(request,"requestStartTime",getTickCount(),true)>
		<!--- legacy [begin] --->
		<!--- <cfinclude template="/Application_Common.cfm"> --->
        <!--- legacy [end] --->
		<!--- <cfset application.oApplicationAppSettingsManager = CreateObject("component", "components.settings.ApplicationAppSettingsManager").init() /> --->
		<!---initialize general functions to be used throuhout the application--->



		<cfscript>
			if (structKeyExists(URL, 'resetUtil')) {
				lock timeout="30" scope="Application" type="exclusive" throwontimeout="false" {
					structDelete(application, 'util');
					structDelete(application, "forge_cdn");
				}
			}

			if (not structKeyExists(application, 'util')) {
				lock timeout="30" scope="Application" type="exclusive" throwontimeout="true" {
					if (not structKeyExists(application, 'util')) {
						application.util = CreateObject("component", "components.UtilManager").init();
					}
				}
			}

			// 2018 april - wr 76496 - chrisN
			if (not structKeyExists(application, 'forge_cdn')) {
				lock timeout="30" scope="Application" type="exclusive" throwontimeout="true" {
					if (not StructKeyExists(application, 'forge_cdn')) {
						application.forge_cdn = trim(application.util.query.get_setting("forge_cdn", 0));
						// get rid of trailing slash
						if (right(application.forge_cdn,1) eq "/") {
							application.forge_cdn = left(application.forge_cdn, len(application.forge_cdn) - 1);
						}						
					}
				}
			};

			request.app_general_functions = CreateObject("component","components.general.General_Functions");
		</cfscript>

		<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

		<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
		<cfset key = request.app_general_functions.GenerateKey() />
		<cfset request.key = key />

        <!--- Let's keep track of who is officially IN our house... [begin] --->
		<cfif isdefined("session.stMvcUserInfo")>
	       <!---  <cfscript>
				if (len(trim(session.stMvcUserInfo.User_ID)) AND NOT listFindNoCase(application.stMvcAppInfo.lsLoggedInUserIDs,session.stMvcUserInfo.User_ID,','))
				{
					application.stMvcAppInfo.lsLoggedInUserIDs = listAppend(application.stMvcAppInfo.lsLoggedInUserIDs,session.stMvcUserInfo.User_ID,',');
				}
	        </cfscript> --->
	    <cfelse>
	    	<cfscript>
			session.stMvcUserInfo 					= structNew();
            // MVC V11 User Vars [begin]
			structInsert(session.stMvcUserInfo,'numberOfPagesVisited',0,true);
			structInsert(session.stMvcUserInfo,'sessionMillisecondsElapsedTime',0,true);
			structInsert(session.stMvcUserInfo,'sessionMillisecondsElapsedTimeString','',true);
			structInsert(session.stMvcUserInfo,'sessionSecondsElapsedTimeString','',true);
			structInsert(session.stMvcUserInfo,'sessionLoggedInTimeStamp',createODBCDateTime(now()),true);
			structInsert(session.stMvcUserInfo,'sessionStartTime',getTickCount(),true);
			structInsert(session.stMvcUserInfo,'User_ID','',true);
			// MVC V11 User Vars [end]
		</cfscript>
		</cfif>
        <!--- Let's keep track of who is officially IN our house... [end] --->

	  	<!--- REQUIRE path defined at this point in 'targetPage' ... --->
		<cfif findNoCase(this.webrootMapping,arguments.targetPage,1)>
			<cfif isDefined("url.reinit")>
				<cfif isDefined("url.entity")>
					<cfset structDelete(application,'o' & url.entity,false)>
                <cfelseif isDefined("url.key")>
					<cfset structDelete(application,url.key,false)>
				<cfelseif isDefined("url.scope")>
                	<!--- not graceful... --->
					<cfset structClear(url.scope)>
				</cfif>
			</cfif>
			<!--- Request Start AOK --->
            <cfreturn true>
		<cfelse>
        	<cflog file="#application.applicationName#" type="information"  application="yes" log="application" text="#application.applicationName# Application MVC Error - Request Start Failed">
        	<!--- Houston, we have an onRequestStart() PROBLEM --->
			<cfreturn false>
		</cfif>
	</cffunction>
</cfcomponent>