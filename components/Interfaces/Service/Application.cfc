<cfcomponent  name="Application" extends="AppProxy" output="false">
	
	<!--- extends="/Application.cfc via /AppProxy.cfc" --->

	<!--- 	I thought we needed this but the extends brings in all application scope/settings data
		We need this in case the first request to the application after a restart is a TPO Webservice call 
			- Super in this case is /AppProxy.cfc which extends /Application.cfc
	--->

	<!--- <cffunction name="onApplicationStart">>
    	<cfscript>
    		super.onApplicationStart();
		</cfscript> 
	   <!--- You do not need to return True if you don't set the cffunction returntype attribute. --->
	 </cffunction>  --->

	<!--- AUTHENTICATE THE REQUEST :: apiKey must be sent in the http header --->
	<cffunction name="onRequestStart" access="public" output="true">
		<cfargument name="targetPage" required="true" type="string">
		<cfscript>
			var httpData = GetHttpRequestData().headers;
	 		var bAuthorized = false;
	 		//var apiKey = application.util.query.get_Setting('TPO_REST_apiKey',0);

	 		//Try Header
	 		if(isdefined('httpData.apiKey')){
	 			if(httpData.apiKey == 'L7iP6wwW8B+Gw9FayRq+koUXn9akRPWb0/OiFXxkld8='){
					bAuthorized = true;
				}
	 		}

	 		// if(isDefined('httpData.apiKey') && len(trim(apiKey)) > 30){
	 		// 	if(httpData.apiKey == apiKey){
				// 	bAuthorized = true;
				// }
	 		// }

	 		/*	If this is not TRUE then the request is aborted in components.Interfaces.Service.CreatePlanner.Create() which is the remote access function that handles REST requests	*/
		 	request.bAuthorized = bAuthorized;
			return true;
			//return request.bAuthorized;
		</cfscript>
	</cffunction>

	<cffunction name="onRequestEnd" returnType="void"> 
		<cfargument type="String" name="targetPage" required=true/>
		<cfscript>
			if(structKeyExists(request,'tpoInterfaceError')){
				if(!isSimpleValue(request.tpoInterfaceError)){
					throw(object=request.tpoInterfaceError);
				}
	        }
		</cfscript>
	</cffunction>
	<!--- Without this, errors thrown by the REST service don't make it to site_wide_error_handler.cfm --->
	<cffunction name="onError" returntype="void" output="true">
        <cfinclude template="/Library/site_wide_error_handler.cfm">
    </cffunction>


	<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">	
		<cfargument name="type" type="any" required="false" default="Information">
		 <cfdump var='#x#' output='c:\dumpWebservice.log'>   
		<!--- <cfscript>
				savecontent variable="local.dump" {
       	 			writeDump(var=x,format='text');
    		}
    		WriteLog(type="#arguments.type#", text="REST SERVICE :: #local.dump# :: REST SERVICE"); 
		</cfscript> --->
	</cffunction>

	<cffunction name="inv" returntype="Any">
		<cfargument type="string" name="cfcname"> 
        <cfargument type="string" name="method"> 
        <cfargument type="Any" name="args"> 
		<!---<cfset var result = 0>--->
		<cfinvoke component = "#arguments.cfcname#" 
	              method = "#arguments.method#" 
	              returnVariable = "result" 
	              argumentCollection = "#arguments.args#">
		<cfif IsDefined("result")>
			<cfreturn result />
		</cfif>
	</cffunction>
</cfcomponent>
