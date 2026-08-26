<!---
Name: 			BSA.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for invoking the controller component.
Parameters:		N/A
Usage:			N/A
--->
	
<cfsilent>

<!---default params--->
<cfparam name="url.reloadController" default="0" />	

<!---if the controller isn't in memory or needs a reload...--->
<cfif not isDefined("application.controller") or url.reloadController>

	<!---get controller data and put in memory--->
	<cfset variables.methodMappingData = createObject("component", "BSA.controller.Controller").getMethodMappingData() />
	<cfset structInsert(application, "controller", variables.methodMappingData, "true") />
	
</cfif>

<!---grab data from form and url scopes and put them in the request.controller container --->
<cfset request.container = structNew() />
<cfset structAppend(request.container, form, 	"true") />
<cfset structAppend(request.container, url, 	"true") />

</cfsilent>

<!---if BSA was defined in the request.controller container...--->
<cfif isDefined("request.container.BSA")>

	<cfinvoke 
		component="#application.controller[request.container.BSA].component#" 
		method="#application.controller[request.container.BSA].method#"
		request_data_structure="#request.container#"
		returnvariable="request.controllerResponse" />
	
	<!---direct to view page--->
	<cfswitch expression="#application.controller[request.container.BSA].viewPageMethod#">
	
		<!---1 = include--->
		<cfcase value="1">
			<cfinclude template="#application.controller[request.container.BSA].viewPage#" />
		</cfcase>
		
		<!---2 = relocate--->
		<cfcase value="2">
			<cflocation url="#application.controller[request.container.BSA].viewPage#" />
		</cfcase>
		
	</cfswitch>

	
</cfif>

