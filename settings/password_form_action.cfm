<CFPARAM NAME="PasswordHistoryList" DEFAULT="0">
<CFPARAM NAME="PassHistoryHit" DEFAULT="0">
<!--- Dev Note: Clay 8821: Handle Empty New Password   --->
<cfif NOT isdefined("form.NewPassword")>
	<BR><BR><BR><BR>
		<TABLE ALIGN="CENTER">
		  <TR>
	  		<TD style="font-weight:bold;color:RGB(255,0,0)">
			A new password has not been defined. Please re-enter your new password. 
			If you have reached this page in error, you will be redirected to the prior page.</TD>
		  </TR>
		</TABLE>
		<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 6000);</SCRIPT> 
	<CFABORT>	
</cfif>

	<cfif Form.NewPassword IS Form.NewPassword2>

		<cfset useLakebaseForConfirmLogin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForConfirmLogin>
	<cftry>
		<cfset ConfirmLogin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0",
				"select" = "user_code,user_password,user_email,user_passwordhistory"
			}), "user_code,user_password,user_email,user_passwordhistory"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForConfirmLogin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForConfirmLogin>
<cfquery name="ConfirmLogin" datasource="#application.datasource#">
		SELECT User_Code, User_Password, User_Email, User_PasswordHistory
		FROM _users
		WHERE User_ID	=	'#request.AccessStructure.User_ID#'
		AND Deleted = 0
		</cfquery>
</cfif>
			
		<cfset CurrentPassword = ConfirmLogin.User_Password>

		<cfif hash(Form.OldPassword) EQ CurrentPassword>		
	
			<cfif ConfirmLogin.recordcount IS 1 >
				<!--- Dev Note: KAL; 7916: Getting Password History --->
				<cfset PasswordHistoryList = ValueList(ConfirmLogin.User_PasswordHistory)>
				<cfset PassHistoryHit = ListContains(PasswordHistoryList, hash(Form.NewPassword))>
				
				<cfif CurrentPassword IS hash(Form.NewPassword)> 
					<cfset error="You cannot set your new password to your old password's value.">
					<cfoutput><cflocation url="password_form.cfm?error=#error#&FromHOme=#Form.FromHome#"></cfoutput> 
					<cfabort>
				<cfelseif PassHistoryHit GT 0 >	<!---Failure -- Password found in History--->
					<cfset error="You cannot use a password from your previous #Form.PasswordHistory# passwords!">
					<cfoutput><cflocation url="password_form.cfm?error=#error#&FromHOme=#Form.FromHome#"></cfoutput> 
					<cfabort>
				<cfelse>	<!---Success -- updates the database--->
					<cfoutput><cflocation url="password_form_update.cfm?NewPassword=#UrlEncodedFormat(Form.NewPassword)#&FromHome=#Form.FromHome#&PasswordHistory=#UrlEncodedFormat(Form.PasswordHistory)#"></cfoutput>
				</cfif> 
			
			<cfelse>
				<cfset error="More or less than one account exists with your user name.">
				<cfoutput><cflocation url="password_form.cfm?error=#error#&FromHome=#Form.FromHome#"></cfoutput> 
			</cfif>
	
		<cfelse>
			<cfset error="The old password you entered does not match your existing password">
			<cfoutput> <cflocation url="password_form.cfm?error=#error#&FromHome=#Form.FromHome#"> </cfoutput>
		</cfif>
	
	<cfelse>
		<cfset error="Your new password selections did not match">
		<cfoutput> <cflocation url="password_form.cfm?error=#error#&FromHome=#Form.FromHome#"> </cfoutput>
	
	</cfif>

<cfoutput>#error#</cfoutput>

