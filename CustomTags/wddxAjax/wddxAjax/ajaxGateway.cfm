<cfsilent><cfprocessingdirective pageencoding="ISO-8859-1">
<cfset debugMode = true>
<cfsetting showdebugoutput="no">
<cfparam name="FORM.method" default="">
<cfparam name="FORM.param" default="">
<cfparam name="FORM.callback" default="">
<cfparam name="FORM.debug" default="false">
<cfparam name="FORM.version" default="1">
<cfparam name="FORM.characterEncoding" default="ISO-8859-1">
<cfparam name="FORM.className" default="wddxAjax">

<!--- Save debug info --->
<cfif FORM.debug>
	<cffile action="append" file="#ExpandPath("log.txt")#" output="Method call: #FORM.method##Chr(13)##Chr(10)#ClassName: #FORM.ClassName##Chr(13)##Chr(10)#Params: #FORM.param##Chr(13)##Chr(10)#">
</cfif>

<!--- Init --->
<cfset errorMsg = "">

<!--- To avoid passing component name over plain JavaScript, an associative array is used to detect which remote component to use based on
the class name of the ajax class. So if you want to use two or more remote components for ajax calls, simply use twice the component wddxAjax with different
class name and different ajax component --->
<cfif StructKeyExists(Application.ajaxComponentSet,FORM.className)>
	<cfset ajaxComponent =  StructFind(Application.ajaxComponentSet,FORM.className)>
<cfelse>
	<cfset errorMsg = "Component not found for this ajax ClassName">	
</cfif>

<!--- Decode params for method --->
<cftry>
	<cfwddx action="wddx2cfml" input="#FORM.param#" output="objParam">
	<cfcatch>
		<cfset errorMsg = "Unable do deserialize WDDX params packet">
	</cfcatch>
</cftry>

<!--- If exists a login method, then check login --->
<cfif StructKeyExists(Application,"ajaxLoginMethodSet") and StructKeyExists(Application.ajaxLoginMethodSet,FORM.className)>
	<cfset loginMethod = StructFind(Application.ajaxLoginMethodSet,FORM.className)>
	<cfif loginMethod neq "">
		<!--- Call login method with name of remote method to be called, should return true or false--->
		<cfscript>
			params = StructNew();
			for (i = 1; i lte ArrayLen(objParam); i = i + 1) StructInsert(params,i,objParam[i]);
		</cfscript>
		<cfinvoke component="#ajaxComponent#" method="#loginMethod#" returnvariable="allowed">
			<cfinvokeargument name="methodName" value="#FORM.method#">
		</cfinvoke>
		<cfif not allowed><cfset errorMsg = "Not allowed"></cfif>
	</cfif>
</cfif>

<!--- Parameters are ok and no errors --->
<cfif IsDefined("objParam") and errorMsg eq "">
	<cftry>
	<!--- Call method inside predefined component --->
		<cfif FORM.version eq 1><!--- Old version, only for compatibility --->
			<cfscript>
				objComp = CreateObject("component",ajaxComponent);
				res = Evaluate("objComp.#FORM.method#(objParam)");
			</cfscript>
		<cfelseif FORM.version eq 2>
			<cfscript>
				params = StructNew();
				for (i = 1; i lte ArrayLen(objParam); i = i + 1) StructInsert(params,i,objParam[i]);
			</cfscript>
			<cfinvoke component="#ajaxComponent#" method="#FORM.method#" returnvariable="res" argumentcollection="#params#" />			
		</cfif>
		<cfcatch>
			<!--- If error, build debug information --->
			<cfset errorMsg = cfcatch.Message & Chr(13) & cfcatch.detail>
			<cfif ArrayLen(cfcatch.tagcontext) gt 0>
				<cfset errorMsg = errorMsg & "<br>Check at:<br>">
				<cfloop from="1" to="#ArrayLen(cfcatch.tagcontext)#" index="idx">
					<cfset errorMsg = errorMsg  & "* Line #cfcatch.tagcontext[idx].line#: #GetFileFromPath(cfcatch.tagcontext[idx].template)#<br>">
				</cfloop>
			</cfif> 
		</cfcatch>
	</cftry>
</cfif>

<!--- Build response object, with result of method, callback function and error message --->
<cfscript>
	objResult = StructNew();
	StructInsert(objResult,"callback",FORM.callback);
	if (IsDefined("res")) StructInsert(objResult,"result",res); else StructInsert(objResult,"result","");
	StructInsert(objResult,"errorMessage",errorMsg);
</cfscript>	

<!--- Encode result with WDDX --->
<cfwddx action="cfml2wddx" input="#objResult#" output="fuori">

<!--- Save debug info for response --->
<cfif FORM.debug>
	<cffile action="append" file="#ExpandPath("log.txt")#" output="Response: #fuori##Chr(13)##Chr(10)#">
</cfif>

<!--- Imposta l'encoding dei caratteri da utilizzare per leggere la pagina CFML --->	
</cfsilent><cfcontent type="text/plain; charset=#FORM.characterEncoding#" reset="yes"><cfoutput>#fuori#</cfoutput>
