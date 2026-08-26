<cfcomponent extends="components.AjaxCFC.Ajax">
<!--- ///////// 
   
       This is used by the GL Search in Reason Codes and Auto Match. Because the jquery
	   autocomplete plugin requires an actual file we have to set the access to remote
	   and the output to true so it can retrieve the data.

      ///////// --->
<cffunction name="gl_search" access="remote" ouput="true" displayname="gl_search" hint="returns">
  <cfargument name="q" type="string" required="false" default="" />
	<cfargument name="fromClassification" type="boolean" required="false" default="0" />
	<cfargument name="search" type="any" required="false" default="" />
	
	
  <cfset var get_Gl_Accounts = "" />
	<cfset var result=ArrayNew(1)>
		
<cfquery name="get_Gl_Accounts" datasource="#application.datasource#">
	SELECT gl_account,gl_account_desc
	FROM GL_Account
	WHERE Deleted = 0
	AND Is_Active = 1
 
		<cfif arguments.q eq "All">
		AND (GL_Account LIKE '%%' OR GL_Account_Desc LIKE '%%')
		<cfelse>
		AND (GL_Account LIKE '%#arguments.q#%' OR GL_Account_Desc LIKE '%#arguments.q#%')
		</cfif>

	ORDER BY GL_Account
</cfquery>

<cfif arguments.fromClassification>
	<cfloop query="get_Gl_Accounts">
		
		<cfset returnStruct = StructNew() />
		<cfset returnStruct["value"] =  gl_account/>
		<cfset returnStruct["id"] = gl_account />
		<cfset ArrayAppend(result,returnStruct) />
	</cfloop>
	<cfreturn SerializeJSON(result)/>
<cfelse>
	<cfsetting showdebugoutput="false"><cfcontent reset="true"><cfloop query="get_Gl_Accounts"><cfoutput>#gl_account##Chr(10)#</cfoutput></cfloop>
</cfif>	
	
</cffunction>
	
<cffunction name="getGLAccountById" access="public" ouput="false" returntype="query">
	 <cfargument name="dd_id" type="string" required="true" />
	 <cfset var qGetGlAccountCode = "" />
	 
	 <cfquery name="qGetGlAccountCode" datasource="#application.datasource#">
      Select GL_Account_Code
	  From DD_Reason_Code
	  where DD_Reason_Code_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.dd_id#" />
     </cfquery>
	 
	 <cfreturn qGetGlAccountCode />
	</cffunction>
</cfcomponent>