<!------di_weekly_Log_System_Admin.cfm----->
<CFSET Current_User_Is_SysAdmin = false>
<CFQUERY NAME="Is_SysAdmin" DATASOURCE="#application.datasource#">
	SELECT	Is_System_Administrator
	FROM	_Users
	WHERE
			USer_ID = '#request.AccessStructure.User_ID#'
</CFQUERY>

<CFIF Is_SysAdmin.RecordCount GT 0>
	<CFIF Is_SysAdmin.Is_System_Administrator NEQ "">
		<CFIF Is_SysAdmin.Is_System_Administrator>
			<CFSET Current_User_Is_SysAdmin = true>
		</CFIF>
	</CFIF>
</CFIF>