<cfif isdefined("request.accessstructure.user_id")>
		<cfquery name="getUserLogout" datasource="#application.datasource#">
			SELECT 	_Users_Auto_Logout_List_ID
			FROM 	_Users_Auto_Logout_List
			WHERE 	user_id = <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR">
			AND 	User_Notified_Of_Reason = <cfqueryparam value="0" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfif getUserLogout.recordcount GT 0>
			<cfset sessionOK=false>
		</cfif>

</cfif>

