<!---
***********************************************************************
Modified By: Milan Mushran
Modification: Added Password Expiry functionality
Filename: process_login.cfm
Modified Date: 9/8/2004
Purpose: Used for Login purposes
***********************************************************************
--->
<CFPARAM NAME="cookie.User_Info" DEFAULT="">

<!--- Has the Password expired --->
<CFPARAM NAME="IsPasswordExpired" DEFAULT="no">

<!--- Is the Password within 10 days of expiry --->
<CFPARAM NAME="PasswordExpiryWarning" DEFAULT="no">

<CFPARAM NAME="Form.timeZoneOffset" DEFAULT="300">
<CFPARAM NAME="Form.useDayLightSavingsTime" DEFAULT="true">
<CFPARAM NAME="Form.External_Customer_Profile_Access" DEFAULT="0">
<CFPARAM NAME="Form.External_Customer_Profile_Access_CustNum" DEFAULT="">
<CFPARAM NAME="Form.External_Customer_Profile_Access_CustType" DEFAULT="">

<!--- TEMP DIAGNOSTIC -- remove after login investigation. --->
<cftry>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<cfcatch type="any">
		<cfset tcInfo = "">
		<cfloop array="#cfcatch.TagContext#" index="tcFrame">
			<cfset tcInfo = tcInfo & tcFrame.template & ":" & tcFrame.line & " | ">
		</cfloop>
		<cflog file="login_debug" text="CAUGHT in getApplicationAppSettings: #cfcatch.message# / #cfcatch.detail# -- TagContext: #tcInfo#">
		<cfrethrow>
	</cfcatch>
</cftry>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get user data --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetUserData" datasource="#application.datasource#" DBTYPE="ODBC">
Select
		_Users.User_ID,
		_Users.User_Code,
		_Users.Name_First,
		_Users.Name_Last,
		_Users.Profiles_ID,
		_Users.Company_Main_ID,
		_Users.Access_Level,
		_Users.User_Email,
		_Users.User_Rights_ID,
		_Users.Is_USDA_User,
		_Users.LDAP_User_Name,
		_Users.Password_Update_Date,
		_Users.User_Language,
		Company_Main.Company_Name,
		Company_Main.Company_Main_ID,
		Company_Main.Company_Type_ID,
		Company_Main.National_Affiliation_Code,
		Company_Main.Company_logo
		,_Users.User_Rights_ID
		,_Users.Blacksmith_User
	From	_Users
	<cfif Form.External_Customer_Profile_Access EQ "1">
	LEFT JOIN Company_Main
	<cfelse>
	INNER JOIN Company_Main
	</cfif>
	ON		_Users.Company_Main_ID			=	Company_Main.Company_Main_ID
	Where	<cfif Form.External_Customer_Profile_Access EQ "1">
			User_ID = <cfqueryparam value="00000000-0000-0000-0000000000000002" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<cfif (isdefined("logonID") OR appSettings.getLDAP_SSO_Enabled() OR appSettings.getSingleSignOnOverrideUserId() )>
					User_ID	 =	<cfqueryparam value="#Form.ID#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					User_Code =	<cfqueryparam value="#Form.User_Code#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif NOT (isdefined("logonID") OR appSettings.getLDAP_SSO_Enabled())>
					and
					User_Password =	<cfqueryparam value="#hash(Form.User_Password)#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			and
			_Users.deleted					=	0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the user is not found in the database go back to the login screen							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF GetUserData.RecordCount EQ 0>
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/index.htm';</SCRIPT>
	<CFABORT>
</CFIF>

<CFSWITCH EXPRESSION="#GetUserData.Company_Type_ID#">
	<CFCASE VALUE="1"><CFSET User_Directory = "/Manufacturers"></CFCASE>
	<CFCASE VALUE="2"><CFSET User_Directory = "/Distributors"></CFCASE>
	<CFCASE VALUE="3"><CFSET User_Directory = "/Operators"></CFCASE>
	<CFDEFAULTCASE ><CFSET User_Directory = ""></CFDEFAULTCASE>
</CFSWITCH>

<CFSET SSO_User = 0 />
<CFIF len(GetUserData.LDAP_User_Name)>
	<CFSET SSO_User = 1 />
</CFIF>

<!--- TEMP DIAGNOSTIC -- remove after login investigation. --->
<cftry>
<cfinclude template="/setRequestVariables.cfm">

<!--- Create a structure here to hold the variables. --->
<cfscript>
  setRequestAccessStructure( { user_id = GetUserData.User_ID
                                ,External_Customer_Profile_Access = form.External_Customer_Profile_Access
                                ,External_Customer_Profile_Access_CustNum = form.External_Customer_Profile_Access_CustNum
                                ,External_Customer_Profile_Access_CustType = form.External_Customer_Profile_Access_CustType
                                ,timeZoneOffset = form.timeZoneOffset
                                ,useDayLightSavingsTime = form.useDayLightSavingsTime
                                } );

	if(Form.External_Customer_Profile_Access == "1"){
		/* Handle for 2 different sessions (regular login in one browser and customer profile in another prowser)
		- session.AccessStructure will hold regular login info
		- session.AccessStructureExternal will hold the customer profile login info
		*/
		session.AccessStructureExternal = request.AccessStructure;
	}
	else { // 33473 - save info in session variable so we can re-populate request info in application_common.cfm
		session.User_id         = request.AccessStructure.User_ID;
		session.AccessStructure = request.AccessStructure;
	}
</cfscript>
<cfcatch type="any">
	<cfset tcInfo = "">
	<cfloop array="#cfcatch.TagContext#" index="tcFrame">
		<cfset tcInfo = tcInfo & tcFrame.template & ":" & tcFrame.line & " | ">
	</cfloop>
	<cflog file="login_debug" text="CAUGHT in setRequestVariables/setRequestAccessStructure: #cfcatch.message# / #cfcatch.detail# -- TagContext: #tcInfo#">
	<cfrethrow>
</cfcatch>
</cftry>

<CFIF Form.External_Customer_Profile_Access NEQ "1">
	<!--- Serialize packet --->
	<CFWDDX ACTION="CFML2WDDX" INPUT="#request.AccessStructure#" OUTPUT="myPacket">
	<!--- Create cookie with contents of the WDDX packet --->
	<CFCOOKIE NAME="User_Info" VALUE="#myPacket#">
	<CFCOOKIE NAME="User_Id" VALUE="#GetUserData.User_ID#">
</CFIF>

<!--- MVC v11 [begin] --->
<cfscript>
	structAppend(session.stMVCUserInfo,request.AccessStructure,true);
</cfscript>
<!--- MVC v11 [end] --->

<CFSET thisSessionID=Session.SessionID>

<CFQUERY NAME="Get_Session_Status" datasource="#application.datasource#">
	Select		Session_ID, DateDiff(s, Session_Date_Time_Stamp, GetDate()) AS session_delta
	From		Session_Tracker
	Where		Session_User_ID	= <cfqueryparam value="#GetUserData.User_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>


<CFIF Get_Session_Status.recordCount GT 0>
	<CFQUERY NAME="Get_Session_Window" datasource="#application.datasource#">
		Select	Session_Expiration_Length
		From	General_Settings
	</CFQUERY>
	<CFIF Get_Session_Window.recordcount EQ 0>
		<CFSET session_time=0.0104166666667><!--- 0.0104166666667 represents 15 minutes --->
	<CFELSE>
		<CFSET session_time=Get_Session_Window.Session_Expiration_Length>
	</CFIF>

	<CFSET session_delta=Get_Session_Status.session_delta>
	<CFSET session_delta=session_delta/(24*60*60)>

	<CFIF Get_Session_Status.Session_ID NEQ "" AND NOT request.AccessStructure.SSO_User AND request.AccessStructure.External_Customer_Profile_Access NEQ "1">
		<CFIF Get_Session_Status.Session_ID NEQ thisSessionID AND session_delta LTE session_time>
			<!--- If there is another valid session active ----->
			<CFLOCATION URL="/session_expired.cfm" addtoken="false">
			<CFABORT>
		</CFIF>
	</CFIF>
<CFELSE>
	<CFQUERY NAME="Insert_Session_Status" datasource="#application.datasource#">
		INSERT	INTO
		Session_Tracker(Session_User_ID,Session_ID)
		VALUES(	<cfqueryparam value="#GetUserData.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#thisSessionID#" cfsqltype="CF_SQL_VARCHAR">)
	</CFQUERY>
</CFIF>


<CFQUERY NAME="Update_Session_Status" datasource="#application.datasource#">
	UPDATE	Session_Tracker
	SET		Session_ID 				=	<cfqueryparam value="#thisSessionID#" cfsqltype="CF_SQL_VARCHAR">,
			Session_Date_Time_Stamp	=	GetDate()
	WHERE	Session_User_ID 		= <cfqueryparam value="#GetUserData.User_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>


<!--- TEMP DIAGNOSTIC -- remove after login investigation. --->
<cftry>
<!--- Set the Login_Status bit in the database --->
<CFQUERY NAME="Set_Login_Status" datasource="#application.datasource#">
	UPDATE	_Users
	SET 	Login_Status = 1
			<cfif (isdefined("logonID") OR appSettings.getLDAP_SSO_Enabled()) >
			,Is_First_Time = 0 <!--- Dev Note: KAL; 6/15/2010; D21554: Single sign on to application using LDAP  --->
			</cfif>
	WHERE	User_ID	=	<cfqueryparam value="#GetUserData.User_ID#" cfsqltype="cf_sql_varchar">
</CFQUERY>

<!--- Dev Notes: 23086/Anand Rao/24-May-10; User Traffic Changes --->
<cfset UsersIP = CGI.Remote_Addr>
<cfquery name="qGetUserCode" datasource="#application.datasource#">
	SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#GetUserData.User_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<!---
  Dev Notes: 23887/Anand Rao/29-Jun-10
	Update LDAP for User traffic info/query was moved into recordIP.cfm
--->
<cfset varAuditAction = "LOGON" />
<cfset varUser_Code   = qGetUserCode.User_Code />
<cfset varUser_ID     =  GetUserData.User_ID />
<cfset insLoginIP     = 1 />
<cfset LoginIPstatus  = 1 />
<cfinclude template="recordIP.cfm">

<!--- Dev Note: KAL; 8187 --->
<cfset LoginPgEntryBitSet =  CreateObject("component", "components.survey.surveymanager").LoginPgEntrySet("#request.AccessStructure.User_ID#") />
<!--- End Note: KAL; 8187 --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock programs, billbacks and projects
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFIF Len(Trim(request.AccessStructure.User_ID)) GT 0>
	<CFQUERY NAME="Unlock_All" DATASOURCE="#application.datasource#">
		EXEC Unlock_Invalid_Users <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">, 0
	</CFQUERY>
</CFIF>

<!---
	Dev Note: KAL; 6/15/2010; D21554: Single sign on to application using LDAP
	Remove the password expiry and first time login check if LDAP is on.
	Password expiry is maintained by the LDAP server.
--->
<cfif NOT (isdefined("logonID") OR appSettings.getLDAP_SSO_Enabled())>
	<!--- Check whether emailing updated password is allowed by the admin. If so, send an email to the user who updated his/her password --->
	<cfset PasswordChangeDays = appSettings.getPasswordChangeDays() />
	<!--- It should be at least more than the password warning days ---->
	<cfif PasswordChangeDays GTE 30>
		<!--- Password Update date --->
		<cfset PasswordUpdateDate = GetUserData.Password_Update_Date />
		<!--- Has the expiry date been set --->
		<cfif IsDate(PasswordUpdateDate)>
			<!--- Days left for Password Expiry --->
			<cfset DaysDifference = DateDiff("d", "#PasswordUpdateDate#", now()) />
			<!--- User gets a warning to change password, 10 days before and upto the password change date --->
			<cfset cPasswordWarningDays = 10 />
			<!--- The counter to keep track of the days remaining to change password --->
			<cfset PasswordDayCounter = PasswordChangedays - cPasswordWarningDays />
			<!--- Days left for user to change password --->
			<cfset cPasswordDaysRemaining = PasswordChangedays - DaysDifference />
			<!--- If the password is within 10 days of expiry and has not expired --->
			<cfif DaysDifference GTE PasswordDayCounter AND DaysDifference LT PasswordChangedays>
				<cfset PasswordExpiryWarning = "yes" />
			<cfelse>
				<!--- If the password has expired --->
				<cfif DaysDifference GTE PasswordChangedays>
					<cfset IsPasswordExpired = "yes" />
				</cfif>
			</cfif>
		</cfif>
	</cfif>
</cfif>


<!--- clear the session VAR of data --->
<cfscript>
    if (isdefined("SESSION.Programs")) {
        temp = StructDelete(SESSION, "Programs");
    }

    setRequestVariables();
    //
    // do not switch to secured site in developer's development environment
    //
    HTTPVariable = (request.is_developer and findNoCase(".awayx.com", cgi.http_host) eq 0
                                         and findNoCase( "c:\", expandPath( cgi.SCRIPT_NAME ) ) eq 1)
                        ? "http:"
                        : (appSettings.getSSL_On_All_Pages() IS 1)
                            ? "https:"
                            : "http:";
</cfscript>
<cfcatch type="any">
	<cfset tcInfo = "">
	<cfloop array="#cfcatch.TagContext#" index="tcFrame">
		<cfset tcInfo = tcInfo & tcFrame.template & ":" & tcFrame.line & " | ">
	</cfloop>
	<cflog file="login_debug" text="CAUGHT in post-login settings block: #cfcatch.message# / #cfcatch.detail# -- TagContext: #tcInfo#">
	<cfrethrow>
</cfcatch>
</cftry>

<cfoutput>
	<!---
		Dev Note: KAL; 6/15/2010; D21554: Single sign on to application using LDAP
		Remove the password expiry and first time login check if LDAP is on.
		Password expiry is maintained by the LDAP server.
	--->
	<cfif NOT (isdefined("logonID") OR appSettings.getLDAP_SSO_Enabled() OR request.AccessStructure.External_Customer_Profile_Access EQ "1")>
		<cfif Is_First_Time IS 1>
			<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/settings/password_form.cfm?Message=NewUser&FromHome=0';</SCRIPT>
			<cfabort>
		<!---  Password has expired ---->
		<cfelseif IsPasswordExpired IS "yes">
			<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/settings/password_form.cfm?Message=ExpiredPassword&FromHome=0';</SCRIPT>
			<cfabort>
		<!---  User password expiry is within 10 days of expiry ---->
		<cfelseif PasswordExpiryWarning IS "yes">
			<script language="javascript">
			var confirmation;
			confirmation =confirm("Your password will expire in <cfoutput>#cPasswordDaysRemaining#</cfoutput> day(s). Would you like to change it now ? (OK = Yes   Cancel = No)");
				if (confirmation)
				{
					window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/settings/password_form.cfm?Message=PasswordExpiryWarning&Days=<cfoutput>#cPasswordDaysRemaining#</cfoutput>&FromHome=0';
				}
			</script>
		</cfif>
	</cfif>

	<CFINCLUDE TEMPLATE="/Common_Files/inc_login_process_redirect.cfm">

	<CFIF request.AccessStructure.External_Customer_Profile_Access EQ "1">
		<!--- Do nothing. This file is included in another file, that file will take care of the redirect --->
	<CFELSEIF GetUserData.Is_USDA_User EQ 1>
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/Manufacturers/home_new.cfm?pageToOpen=/settings/usdanoi/noi_usage_agreement.cfm';</SCRIPT>
	<CFELSE>
        <script>
            localStorage.clear();    // remove all entries in browser local storage 85971
        </script>
		<CFSWITCH EXPRESSION="#GetUserData.Company_Type_ID#">
			<!--- Manufacturer Homepage --->
			<CFCASE VALUE="1"><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/Manufacturers/home_new.cfm';</SCRIPT></CFCASE>
			<!--- Distributor Homepage --->
			<CFCASE VALUE="2"><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/Distributors/home.cfm';</SCRIPT></CFCASE>
			<!--- Operator Homepage --->
			<CFCASE VALUE="3"><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/index.htm';</SCRIPT></CFCASE>
			<!--- No Access --->
			<CFDEFAULTCASE><SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '#HTTPVariable#//<CFOUTPUT>#CGI.HTTP_HOST#</CFOUTPUT>/index.htm';</SCRIPT></CFDEFAULTCASE>
		</CFSWITCH>
	</CFIF>

</cfoutput>