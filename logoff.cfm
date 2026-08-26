<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Logoff user: expire the cookie and redirect user to the logon screen						   --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----  Reset Session_Tracker ------->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="Cookie.User_Id" DEFAULT="">
<CFPARAM NAME="URL.ID"  DEFAULT="">
<!--- optional user screen dimension passed in from JS on parent page --->
<CFPARAM NAME="URL.LCD" DEFAULT="">

<cfset URL.ID = Cookie.User_Id />
<CFIF IsDefined("URL.ID")>
	<CFQUERY NAME="Reset_Login_Status" datasource="#application.datasource#">
		UPDATE	Session_Tracker
		SET 	Session_ID = NULL
		WHERE	Session_User_ID		=	<cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----  End Reset Session_Tracker ------->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock programs, billbacks and projects
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFIF IsDefined("URL.ID")>
	<CFIF Len(Trim(URL.ID)) GT 0>
		<CFQUERY NAME="Unlock_All" DATASOURCE="#application.datasource#">
			EXEC Unlock_Invalid_Users <cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	</CFIF>
</CFIF>

<!--- unlock all what if p&l --->
<cfscript>
	variables.whatIfCFC = createObject("component", "components.programs.whatif");
	variables.whatIfCFC.unlockAll( URL.ID );

	// remove all global temp tables the current user created
	application.util.query.clearUserGlobalTempTable( 'all' );
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock Locks in User Profiles
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFIF isdefined("URL.ID")>
	<CFSET getProfileLockStatus = CreateObject("component", "components.settings.profiles.profile").getProfileLockStatus()>
	<CFIF getProfileLockStatus.Locked_By_User_ID EQ URL.ID>
		<CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(#URL.ID#,0)>
	</CFIF>
</CFIF>

<!--- 
	115103: Retail Planner Template - updates / Anand Rao / 31-May-2022 
		Unlock all Planner templates locked by this user.
--->
<cfset objPlannerTemplateManager = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager") />
<cfset temp = objPlannerTemplateManager.lockUnlockPlannerTemplate(URL.ID,0,0) />

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock Locks in BB Auto PAy Report
pass a 0 to LockReport() to unlock
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFIF isdefined("URL.ID")>
	<cfset oBBReportUpdate	= CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
	<cfset Locked = oBBReportUpdate.lockReport(URL.ID,0) />
</CFIF>


<!--- Reset the Login_Status bit in the database --->
<CFQUERY NAME="Set_Login_Status" datasource="#application.datasource#">
	UPDATE	_Users
	SET 	Login_Status = 0
	WHERE	User_ID	=	<cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<!--- Dev Notes: 23086/Anand Rao/24-May-10	User Traffic Changes--->
<cfset UsersIP = CGI.Remote_Addr>
<cfquery name="qGetUserCode" datasource="#application.datasource#">
	SELECT 	User_Code, LDAP_User_Name
	FROM 	_Users
	WHERE 	User_ID = <cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfquery name="AddUserTransLoginReset" datasource="#application.datasource#">
	INSERT INTO Audit_User_Transactions
            (
                       Trans_Type
                      ,Trans_User_Code
                      ,Trans_ip_Address
                      ,Trans_By_User_Id
                      ,Browser
					  ,Screen_Resolution
            )
            VALUES
            (
                        'LOGOFF'
                      , <cfqueryparam Value = "#qGetUserCode.User_Code#" cfsqlType = "CF_SQL_VARCHAR">
                      , <cfqueryparam Value = "#UsersIP#" cfsqlType = "CF_SQL_VARCHAR">
                      , <cfqueryparam Value = "#URL.ID#" cfsqlType = "CF_SQL_VARCHAR">
                      , <cfqueryparam Value = "#HTTP_USER_AGENT#" cfsqlType = "CF_SQL_VARCHAR">
					  , '#url.lcd#'
            )
</cfquery>

<cfscript>
	variables.lock_cfc = createObject("component", "components.general.lock");
	variables.lock_cfc.unlockByUser(user_id = url.id);
</cfscript>

<!--- release all redistribution locks from current user --->
<cfquery datasource="#application.datasource#">
    UPDATE REDI_EC_Header
        SET Locked = 0
            ,User_Id_Locked = NULL
            ,Locked_Date = getDate()
    WHERE User_Id_Locked = '#url.id#'
</cfquery>

<cfset automationUploadManager = CreateObject("component", "components.billback.AutomationUploadManager") />
<cfset temp = automationUploadManager.unlockAutomationUploadPage() />

<CFPARAM NAME="cookie.User_Info" DEFAULT="">
<CFCOOKIE NAME="User_Info" VALUE="" EXPIRES="NOW">

<CFQUERY NAME="GetSingleSignOnInfo" datasource="#application.datasource#">
	SELECT SingleSign_On FROM _application_settings
</CFQUERY>

<cfif GetSingleSignOnInfo.SingleSign_On EQ 1>
	<cfheader name="pragma" value="no-store">
	<cfheader name="expires" value="-1">
</cfif>

<TABLE border="0" cellspacing="3" cellpadding="3">
	<TR>
		<TD ROWSPAN="100%" WIDTH="100">&nbsp;</TD>
		<a href="/index.htm"><img border="0" src="/images/logon_telus/TELUS_Trade_Promotion_Management_Logo.svg" height="14" border="0"></a>
		<TD class="mainpageDots">

			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<CFLOOP INDEX="dots" FROM="1" TO="30">
				<CFOUTPUT>&nbsp;&nbsp; .</CFOUTPUT>
			</CFLOOP>
		</TD>
	</TR>
	<TR>
		<TD class="mainpageDots">
			<P align="center"><BR>
			.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>
		</TD>
		<TD valign="top">
			<BR><BR>
			<div class="Title9">
				Logout completed successfully
				<BR><BR>
				<cfoutput>
				<a href="#application.LoginPage#">
					#application.util.string.actionLinkFormat(action="login page")#
				</cfoutput>
				</a>
			</div>
		</TD>
	</TR>
</TABLE>

<!--- <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/index.htm';</SCRIPT> --->
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
    localStorage.clear();    // remove all entries in browser local storage 85971

	<CFOUTPUT>
	<cfif GetSingleSignOnInfo.SingleSign_On EQ 1>
		var loginPage = "index2.cfm?closewindow=yes";
	<cfelseif ((GetSingleSignOnInfo.SingleSign_On EQ 2) AND len(qGetUserCode.LDAP_User_Name))>
		var loginPage = "";
	<cfelse>
		var loginPage = "#application.LoginPage#";
	</cfif>
	</CFOUTPUT>
		if(window.opener)
		{
			try
			{
				if(	window.opener.name == "bsApplicationMainWindow" ||
					window.opener.name == "header_new" ||
					window.opener.name == "mywindowname" ||
					window.opener.name == "footer_new"
					)
				{
				window.opener.top.location.href = loginPage;
				}
			}
			catch(e)
			{
			}
			window.close();
		}
		else if(window.top != window)
		{
			window.top.location.href = loginPage;
		}
		else if(loginPage)
		{
			window.location.href = loginPage;
		}

</SCRIPT>


