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
		
		<!---42860 - Tim Ford - 05/12/2014: Adding code to handle for event errors from scheduled tasks--->
		<cfif StructKeyExists(URL, 'resetUtil') or not StructKeyExists(application, 'util')>
		  <cflock timeout="20" scope="Application" type="exclusive" throwontimeout="true">
			<cfset application.util = CreateObject("component", "components.UtilManager").init()>
		  </cflock>
		</cfif>
		
		<cfscript>
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