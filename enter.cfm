<!---
Document Name:	enter.cfm
Directory:		/
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	February 5, 2002
Revised:		May 5, 2004, Brenda Flynn, to add check to ensure users logging in have positions
This is a major revision of a previous version of the login.  We now count unsuccessful logins and record the IP addresses of users who have either locked their accounts or used a bogus username.
--->

<!--- CFC Calls: initiate all the CFC's a the top to avoid duplication --->
<cfset appSettings = application.appSettingsGet>
<cfset userManager = createobject("component", "components.user.userManager") />
<cfset application.oController.getObject(path="components.user.profile",name="profile",bReload= 0) />
<cfset application.oController.getObject(path="components.settings.LDAPSettingsManager",name="LDAPSettingsManager",bReload= 1) />



<!----- Fix for the error if someone bookmarks this page ----->
<CFSET Referer_Filename = LCase(ListLast(CGI.HTTP_Referer, "/"))>
<cfparam name="form.id" default="" />  <!--- D21554: Kal; variable to hold passed in user id --->
<cfparam name="varAuditAction" default=""/>

<cfif not isdefined("LogonId")>
	<!--- TEMP DIAGNOSTIC -- remove after login investigation. Logs lengths/
	      booleans only, never actual credential content. --->
	<cflog file="login_debug" text="disableAutoLogIn=#appSettings.getDisableAutoLogIn()# frmKeyDefined=#isdefined('form.frmKey')# User_Code_len=#len(Form.User_Code)# User_Password_len=#len(Form.User_Password)# form.u_len=#len(Form.u)# form.p_len=#len(Form.p)#">

	<!--- dynamic form field names are used to kill auto populate functionality. If we allow auto populate, then form.frmKey will be 0	--->
	<cfif appSettings.getDisableAutoLogIn() and isdefined("form.frmKey")>
		<cfset Form.User_Code = evaluate("Form.u")>
		<cfset Form.User_Password = evaluate("Form.p")>
	</cfif>

	<cflog file="login_debug" text="AFTER override: User_Code_len=#len(Form.User_Code)# User_Password_len=#len(Form.User_Password)#">

	<CFIF NOT isDefined("Form.User_Code") OR NOT isDefined("Form.User_Password")>
		<CFLOCATION ADDTOKEN="No" URL="#application.LoginPage#">
	</CFIF>
</cfif>


<cfset loginFailureIncludePage = "index2.cfm" />
<cfif isdefined("Logonid") and (GetSingleSignOnInfo.SingleSign_On EQ 1) >
	<!--- PACTIV --->
	<cfset loginFailureIncludePage = "http://pactivpartners.pactiv.com" />
</cfif>


	<CFSET Contact_Admin_Email_Address = "">
	<CFQUERY NAME="get_Contact_Admin_Email_Address" datasource="#application.datasource#">
		SELECT 	User_Email, Name_First, Name_Last, Work_Phone_1, Work_Phone_2, Work_Phone_3, Work_Phone_Ext, Company_Main.Company_Name
		FROM 	_Users
				INNER JOIN
	            Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
		WHERE Contact_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
	<CFIF get_Contact_Admin_Email_Address.recordCount GT 0>
		<CFSET Contact_Admin_Email_Address = get_Contact_Admin_Email_Address.User_Email>
	<CFELSE>
		<CFQUERY NAME="get_Contact_Admin_Email_Address" datasource="#application.datasource#">
			SELECT 	User_Email, Name_First, Name_Last, Work_Phone_1, Work_Phone_2, Work_Phone_3, Work_Phone_Ext, Company_Main.Company_Name
			FROm 	_Users
					INNER JOIN
	            	Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
			WHERE Is_System_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
		<CFIF get_Contact_Admin_Email_Address.recordCount GT 0>
			<CFSET Contact_Admin_Email_Address = get_Contact_Admin_Email_Address.User_Email>
		</CFIF>
	</CFIF>

<CFSET SendMailTo = Contact_Admin_Email_Address>
<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm"> 

<cfheader name="Cache-Control" value="no-store">
<cfheader name="pragma" value="no-cache">
<cfset error="">


<!--- 	Dev Note: KAL; D21554: 06/02/2010
		When LDAP is enabled include the LDAP authentication page, else continue with the regular login processing. --->
<cfif appSettings.getLDAP_SSO_Enabled()>
	<!--- 	Dev Note: KAL; D21554: 06/02/2010 : LDAP authentication
			When LDAP is enabled and user has multiple accounts user will select one account and resubmit the page.
			If resubmitted then continue with login process.
	--->
	<cfif isdefined("form.UserMultiPositionSelected") and form.UserMultiPositionSelected eq 1>
		<cfinclude template="process_login.cfm">
	<cfelse>
		<!--- include the LDAP Authentication file. --->
		<cfinclude template="enterLDAP.cfm">
	</cfif>
<cfelse>
	<!--- Continue with the regular approval process. --->
	<cfquery name="GetMaximumAttempts" datasource="#application.datasource#">
		SELECT 	Login_Attempts
		FROM 	General_Settings
	</cfquery>

	<cfset MaximumAttempts = GetMaximumAttempts.Login_Attempts>

	<cfset useLakebaseForIsValidUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")
			AND NOT (appSettings.getsinglesign_on() eq 2 and isdefined("LogonId"))>

	<cfif useLakebaseForIsValidUserName>
		<!--- Lakebase path: non-SSO username lookup only; SSO/ADFS lookup stays on SQL Server for now. --->
		<cftry>
			<cfset IsValidUserName = application.oLakebase.toQuery(
				application.oLakebase.selectRows("_users", {
					"select"    = "logintries,user_id,name_first,name_last,ldap_user_name,ldap_user_id",
					"user_code" = "eq.#Form.User_Code#",
					"deleted"   = "eq.false"
				}),
				"logintries,user_id,name_first,name_last,ldap_user_name,ldap_user_id"
			)>
			<!--- TEMP DIAGNOSTIC -- remove after login investigation. --->
			<cflog file="login_debug" text="IsValidUserName path=lakebase recordcount=#IsValidUserName.recordcount#">
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cflog file="login_debug" text="IsValidUserName lakebase FAILED (#cfcatch.type#: #cfcatch.message#) -- falling back to SQL Server">
				<cfset useLakebaseForIsValidUserName = false>
			</cfcatch>
		</cftry>
	</cfif>

	<cfif NOT useLakebaseForIsValidUserName>
		<cfquery name="IsValidUserName" datasource="#application.datasource#">
			SELECT	LoginTries, User_ID, Name_First, Name_Last,
					isnull(LDAP_User_Name,'') as LDAP_User_Name,
					isnull(LDAP_User_ID, '') as LDAP_User_ID
			FROM	_users
			<cfif appSettings.getsinglesign_on() eq 2 and isdefined("LogonId")> <!--- SSO ADFS --->
			WHERE 	isnull(LDAP_User_Name,'') = <cfqueryparam value="#LogonId#" cfsqltype="cf_sql_varchar">
			AND 	isnull(LDAP_User_ID,<cfqueryparam value="#LogonEmail#" cfsqltype="cf_sql_varchar">) = <cfqueryparam value="#LogonEmail#" cfsqltype="cf_sql_varchar">
			<cfelse>
			WHERE 	User_Code = <cfqueryparam value="#Form.User_Code#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			AND 	Deleted = 0
		</cfquery>
	</cfif>

	<!--- TEMP DIAGNOSTIC -- remove after login investigation. --->
	<cflog file="login_debug" text="IsValidUserName.recordcount=#IsValidUserName.recordcount# LoginTries=#(IsValidUserName.recordcount ? IsValidUserName.LoginTries : 'n/a')#">

	<cfif (appSettings.getsinglesign_on() eq 2 OR appSettings.getSingleSignOnOverrideUserId()) and len(IsValidUserName.LDAP_User_Name) and NOT isdefined("Logonid") >
		<cfset error="<div align=""Center""><font color=""red"">SSO login is enabled for this user. Please authenticate via SSO login.</font></div>">
		<cfset varAuditAction = "SSO User" />
		<cfset varUser_Code   = FORM.User_Code />
		<cfset varUser_ID     = IsValidUserName.User_ID />
		<cfset insLoginIP     = 1 />
		<cfset LoginIPstatus  = 0 />
		<cfinclude template="recordIP.cfm">
		<cfinclude template="#loginFailureIncludePage#">
		<cfabort> <!--- Dont proceed further --->
	</cfif>

	<cfif not isdefined("LogonId")>
		<cfset useLakebaseForLoginInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")
				AND NOT appSettings.getSingleSignOnOverrideUserId()>

		<cfif useLakebaseForLoginInfo>
			<!--- Lakebase path: plain User_Code credential check only; SSO-override-by-LDAP-name lookup stays on SQL Server for now. --->
			<cftry>
				<cfset LoginInfo = application.oLakebase.toQuery(
					application.oLakebase.selectRows("_users", {
						"user_code"     = "eq.#Form.User_Code#",
						"user_password" = "eq.#hash(Form.User_Password)#",
						"is_locked"     = "eq.false",
						"deleted"       = "eq.false"
					}),
					"user_id,is_first_time"
				)>
				<!--- TEMP DIAGNOSTIC -- remove after login investigation. --->
				<cflog file="login_debug" text="LoginInfo path=lakebase recordcount=#LoginInfo.recordcount#">
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cflog file="login_debug" text="LoginInfo lakebase FAILED (#cfcatch.type#: #cfcatch.message#) -- falling back to SQL Server">
					<cfset useLakebaseForLoginInfo = false>
				</cfcatch>
			</cftry>
		</cfif>

		<cfif NOT useLakebaseForLoginInfo>
			<cfquery name="LoginInfo" datasource="#application.datasource#">
				SELECT 	*
				FROM	_users
				<cfif appSettings.getSingleSignOnOverrideUserId() >	<!--- SSO overide UserID --->
				WHERE 	isnull(LDAP_User_Name, User_Code) = <cfqueryparam value="#Form.User_Code#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
				WHERE 	User_Code = <cfqueryparam value="#Form.User_Code#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				AND 	User_Password = <cfqueryparam value="#hash(Form.User_Password)#" cfsqltype="CF_SQL_VARCHAR">
				AND 	Is_Locked = 0
				AND 	Deleted = 0
			</cfquery>
		</cfif>

		<!--- TEMP DIAGNOSTIC -- remove after login investigation. Logs the
		      computed hash so it can be compared against the stored
		      User_Password value directly in SQL Server -- never logs the
		      plaintext password itself. --->
		<cflog file="login_debug" text="LoginInfo.recordcount=#LoginInfo.recordcount# computedHash=#hash(Form.User_Password)#">
	<cfelse>

		<cfquery name="LoginInfo" datasource="#application.datasource#">
			SELECT 	*
			FROM 	_users
			<cfif appSettings.getsinglesign_on() eq 2>
			WHERE 	isnull(LDAP_User_Name,'') = <cfqueryparam value="#LogonId#" cfsqltype="cf_sql_varchar">
			AND 	isnull(LDAP_User_ID,<cfqueryparam value="#LogonEmail#" cfsqltype="cf_sql_varchar">) = <cfqueryparam value="#LogonEmail#" cfsqltype="cf_sql_varchar">
			<cfelse>
			WHERE 	User_Code = <cfqueryparam value="#Form.User_Code#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<cfif isDefined("form.id") and Len(form.id)>
			AND		User_ID = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_varchar">
			</cfif>
			AND 	Is_Locked = 0
			AND 	Deleted = 0
		</cfquery>

		<!--- Update User Records with LDAP ID's --->
		<cfif (appSettings.getsinglesign_on() eq 2) AND LoginInfo.recordCount>
			<cfquery name="qUpdateUserInfo" datasource="#application.datasource#">
				UPDATE 	_USERS
				SET 	LDAP_USER_ID = <cfqueryparam value="#LogonEmail#" cfsqltype="cf_sql_varchar">
				WHERE 	User_ID IN	(<cfqueryparam value="#ValueList(LoginInfo.User_ID)#" cfsqltype="cf_sql_varchar" list="true">)
				AND		LDAP_User_Name = <cfqueryparam value="#LogonId#" cfsqltype="cf_sql_varchar">
				AND		isnull(LDAP_User_ID,'')	=  ''
			</cfquery>
		</cfif>
	</cfif>

	<cfset Is_First_Time = LoginInfo.Is_First_Time>


	<cfif LoginInfo.Recordcount GT 1>
		<!--- SSO/ADFS: when there are multiple positions/profiles then display a dropdown for positions-profiles  --->
		<cfif isdefined("form.UserMultiPositionSelected") and form.UserMultiPositionSelected eq 1>
			<cfinclude template="process_login.cfm">
		<cfelse>
			<cfinclude template="enterMultiPositions.cfm" />
		</cfif>

	<cfelseif LoginInfo.Recordcount EQ 1>
		<cfset form.id = LoginInfo.User_ID />
		<cfquery name="ResetFailures" datasource="#application.datasource#">
			UPDATE 	_users
			SET     LoginTries = 0
			WHERE   User_ID = <cfqueryparam value="#LoginInfo.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND     Deleted = 0
		</cfquery>

		<!--- Remove AutoLogout Reason If Any --->
		<cfquery name="getAutoLogout" datasource="#application.datasource#">
			SELECT 	_Users_Auto_Logout_List_ID
			FROM 	_Users_Auto_Logout_List
			WHERE 	User_ID = <cfqueryparam value="#LoginInfo.User_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif getAutoLogout.Recordcount GT 0>
			<cfquery name="stopAutoLogout" datasource="#application.datasource#">
				DELETE FROM _Users_Auto_Logout_List WHERE User_ID = <cfqueryparam value="#LoginInfo.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				DELETE FROM _Users_Auto_Logout_Reason WHERE _Users_Auto_Logout_List_ID IN (<cfqueryparam value="#valuelist(getAutoLogout._Users_Auto_Logout_List_ID)#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
			</cfquery>
		</cfif>


		<!---Makes sure the user has a position--->
		<CFSET currentUserPositionID = userManager.getPositionId(LoginInfo.User_ID)>

		<cfif len(trim(currentUserPositionID)) LT 1 OR currentUserPositionID IS 0>
			<cfset error="<div align=""Center""><font color=""red"">Your account does not have a user position associated with it. Please contact your system administrator and notify them of the issue.</font></div>">

			<cfoutput>
				<CF_EMAILWRAPPER
					TO = "#sendmailto#"
					FROM = "#Contact_Admin_Email_Address#"
					SUBJECT = "A user is trying to log in without a position"
					TYPE = "html"
					MESSAGETYPE = "1"
					generatedBy="2"
					appArea="4">

						<TABLE WIDTH="100%">
						<TR VALIGN="top">
						<TD ALIGN="right" NOWRAP>
						<B>Date:</B>
						</TD>
						<TD>
						&nbsp;&nbsp;&nbsp;#DateFormat(now(),"mm/dd/yyyy")#
						</TD>
						</TR>
						<TR VALIGN="top">
						<TD ALIGN="right" NOWRAP>
						<B>Time:</B>
						</TD>
						<TD>
						&nbsp;&nbsp;&nbsp;#TimeFormat(now(), "hh:mm:sstt")#
						</TD>
						</TR>
						<TR VALIGN="top">
						<TD ALIGN="right" NOWRAP>
						<B>Company Name:</B>
						</TD>
						<TD>
						&nbsp;&nbsp;&nbsp;#application.returned_customer_setting.Company_Name#
						</TD>
						</TR>
						<TR VALIGN="top">
						<TD ALIGN="right" NOWRAP>
						<B>User Name:</B>
						</TD>
						<TD>
						&nbsp;&nbsp;&nbsp;#IsValidUserName.Name_First# #IsValidUserName.Name_Last#
						</TD>
						</TR>
						<TR VALIGN="top">
						<TD ALIGN="right" NOWRAP>
						<B>Installation:</B>
						</TD>
						<TD>
						&nbsp;&nbsp;&nbsp;#cgi.Server_Name#
						</TD>
						</TR>

						<TR VALIGN="top">
						<TD COLSPAN="2"><br><br>This user does not have a valid position. To assign a position to the user, go to Settings. Under "Users", click on "List Users". Find the record for this user, and click on it. You should then assign a position to the user. The user will not be able to log in until you have assigned them a position.<br><br></TD>
						</TR>
						</TABLE>
				<!--- </CFMAIL> --->
				</CF_EMAILWRAPPER>
			</cfoutput>
			<cfif not isdefined("LogonId")>
				<!--- Dev Notes: 23887/Anand Rao/29-Jun-10 Update LDAP for User traffic info/query was moved into recordIP.cfm --->
				<cfset insLoginIP     = 1 />
				<cfset LoginIPstatus  = 0 />
				<cfinclude template   = "recordIP.cfm">
				<cfinclude template="#loginFailureIncludePage#">
			</cfif>
			<cfabort>
		</cfif>
		<!---End user position checking--->
		<cfinclude template="process_login.cfm">
	<!---Not a valid login--->
	<cfelse> <!--- LoginInfo.Recordcount --->

		<cfif IsValidUserName.Recordcount GT 0>
			<cfset NewLoginTries = IsValidUserName.LoginTries + 1>
			<cfquery name="IncrementFailure" datasource="#application.datasource#">
				UPDATE 	_Users
				SET 	LoginTries = <cfqueryparam value="#NewLoginTries#" cfsqltype="CF_SQL_INTEGER">
						<cfif NewLoginTries GTE MaximumAttempts AND NOT isdefined("Logonid")>
						, Is_Locked = 1
						</cfif>
				WHERE	User_Code = <cfqueryparam value="#Form.User_Code#" cfsqltype="CF_SQL_VARCHAR">
				AND 	Deleted = 0
			</cfquery>

			<!--- Dev Notes: 23086/Anand Rao/21-May-10: User Traffic Changes --->
			<!--- Dev Notes: 23887/Anand Rao/29-Jun-10 Update LDAP for User traffic info/query was moved into recordIP.cfm --->
			<cfset varAuditAction = "UNSUCCESS-LOGON" />
			<cfset varUser_Code   = FORM.User_Code />
			<cfset varUser_ID     =  IsValidUserName.User_ID />
			<cfset insLoginIP     = 1 />
			<cfset LoginIPstatus  = 0 />
			<cfinclude template="recordIP.cfm">

			<cfif NewLoginTries GTE MaximumAttempts AND NOT isdefined("Logonid")>
				<!--- Dev Notes: 23887/Anand Rao/29-Jun-10 Update LDAP for User traffic info/query was moved into recordIP.cfm --->
				<cfset varAuditAction = "LOCKED-OUT" />
				<cfset varUser_Code   = FORM.User_Code />
				<cfset varUser_ID     =  IsValidUserName.User_ID />
				<cfset insLoginIP     = 0 />
				<cfset LoginIPstatus  = 0 />
				<cfinclude template="recordIP.cfm">

				<cfset error="<div align=""Center""><font color=""red"">You have attempted to log into this account unsuccessfully more  times than is allowed.  <br>The account is now locked. <br>Please contact an administrator to unlock your account.</font></div>">
				<!--- Dev Notes: 23887/Anand Rao/29-Jun-10 Update LDAP for User traffic info/query was moved into recordIP.cfm --->
				<cfset insLoginIP    = 1 />
				<cfset LoginIPstatus = 0 />
				<cfinclude template="recordIP.cfm">
				<cfinclude template="#loginFailureIncludePage#">

				<cfoutput>
					<CF_EMAILWRAPPER
						TO = "#sendmailto#"
						FROM = "#Contact_Admin_Email_Address#"
						SUBJECT = "A user has become locked"
						TYPE = "html"
						MESSAGETYPE = "1"
						generatedBy="2"
						appArea="4">

							<TABLE WIDTH="100%">
							<TR VALIGN="top">
							<TD ALIGN="right" NOWRAP>
							<B>Date:</B>
							</TD>
							<TD>
							&nbsp;&nbsp;&nbsp;#DateFormat(now(),"mm/dd/yyyy")#
							</TD>
							</TR>
							<TR VALIGN="top">
							<TD ALIGN="right" NOWRAP>
							<B>Time:</B>
							</TD>
							<TD>
							&nbsp;&nbsp;&nbsp;#TimeFormat(now(), "hh:mm:sstt")#
							</TD>
							</TR>
							<TR VALIGN="top">
							<TD ALIGN="right" NOWRAP>
							<B>Company Name:</B>
							</TD>
							<TD>
							&nbsp;&nbsp;&nbsp;#application.returned_customer_setting.Company_Name#
							</TD>
							</TR>
							<TR VALIGN="top">
							<TD ALIGN="right" NOWRAP>
							<B>User Name:</B>
							</TD>
							<TD>
							&nbsp;&nbsp;&nbsp;#IsValidUserName.Name_First# #IsValidUserName.Name_Last#
							</TD>
							</TR>
							<TR VALIGN="top">
							<TD ALIGN="right" NOWRAP>
							<B>Installation:</B>
							</TD>
							<TD>
							&nbsp;&nbsp;&nbsp;#cgi.Server_Name#
							</TD>
							</TR>

							<TR VALIGN="top">
							<TD COLSPAN="2"><br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To unlock this user, log in to the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>. Go to the settings area, and find the link called "unlock users" in the Users menu. You will see a list of all locked users. Click on the [unlock this user] link next to the user's name. The user will receive an email containing a new password, and their account will be unlocked.<br><br></TD>
							</TR>
							</TABLE>
					<!--- </CFMAIL> --->
					</CF_EMAILWRAPPER>
				</cfoutput>
				<cfabort>
				<!---cfif NewLoginTries GTE MaximumAttempts--->
			</cfif>

		<cfelse> <!--- cfif IsValidUserName.Recordcount GT 0 --->

			<!--- Dev Notes: 23086/Anand Rao/21-May-10; User Traffic Changes --->
			<!--- Dev Notes: 23887/Anand Rao/29-Jun-10 Update LDAP for User traffic info/query was moved into recordIP.cfm --->
			<cfset varAuditAction = "UNKNOWN-USER" />
			<cfif isdefined("Logonid") >
				<cfset varUser_Code   = Logonid />
			<cfelse>
				<cfset varUser_Code   = FORM.User_Code />
			</cfif>
			<cfset varUser_ID     =  "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxx" />
			<cfset insLoginIP     = 1 />
			<cfset LoginIPstatus  = 0 />
			<cfinclude template="recordIP.cfm">

		</cfif> <!--- cfif IsValidUserName.Recordcount GT 0 --->

		<cfif isdefined("LogonId") >
			<cfset error="#application.oLDAPSettingsManager.getLDAPSettings().LDAP_BSA_Issue_Message#" />
		<cfelse>
			<cfset error="The username and password you entered are not a valid combination">
		</cfif>

		<cfif not isdefined("LogonId")>
			<!--- Dev Notes: 23887/Anand Rao/29-Jun-10 Update LDAP for User traffic info/query was moved into recordIP.cfm 			--->
			<cfset varAuditAction = ''/>
			<cfset insLoginIP     = 1 />
			<cfset LoginIPstatus  = 0 />
			<cfinclude template="recordIP.cfm">
			<cfinclude template="#loginFailureIncludePage#">
		<cfelse>
			<cfoutput><div align="Center"><font color="red">#error#</font></div></cfoutput>
			<cfif appSettings.getsinglesign_on() eq 2>
				<div class="Title9">
				<a href="/Shibboleth.sso/Logout">
				<cfoutput>
					#application.util.string.actionLinkFormat(action="login page")#
				</cfoutput>
				</a>
				</div>
			</cfif>
		</cfif>

		<!--- cfif LoginInfo.Recordcount EQ 1 --->
	</cfif>
</cfif>

