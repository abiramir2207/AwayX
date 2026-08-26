<cfcomponent name="requestScopeAccess">
	
 <cfset variables.user_Id = "" />
 <cfset userid = "" />
 <cfif structKeyExists(session, 'AccessStructure')>
  <cfset setUserId(session.AccessStructure.User_ID) />
 <cfelse>
  <cfset setUserId('0') />
 </cfif>
<cffunction name="init" access="public" output="false" returntype="requestScopeAccess">
 <cfreturn this />
</cffunction>

<cffunction name="getUserId" output="false" access="public" returntype="any">
		<cfreturn variables.user_Id />
</cffunction>

<cffunction name="setUserId" output="false" access="public" returntype="void">
	<cfargument name="val" required="true" />

	<cfset variables.user_Id = arguments.val />

</cffunction>
</cfcomponent>	