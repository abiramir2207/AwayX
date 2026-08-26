<!------di_weekly_Log_System_Admin.cfm----->
<CFSET Current_User_Is_SysAdmin = false>
<cfset useLakebaseForIs_SysAdmin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForIs_SysAdmin>
	<cftry>
		<cfset Is_SysAdmin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "is_system_administrator"
			}), "is_system_administrator"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIs_SysAdmin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIs_SysAdmin>
<CFQUERY NAME="Is_SysAdmin" DATASOURCE="#application.datasource#">
	SELECT	Is_System_Administrator
	FROM	_Users
	WHERE
			USer_ID = '#request.AccessStructure.User_ID#'
</CFQUERY>
</cfif>

<CFIF Is_SysAdmin.RecordCount GT 0>
	<CFIF Is_SysAdmin.Is_System_Administrator NEQ "">
		<CFIF Is_SysAdmin.Is_System_Administrator>
			<CFSET Current_User_Is_SysAdmin = true>
		</CFIF>
	</CFIF>
</CFIF>