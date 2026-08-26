<!---
	Copyright (c)2010 Blacksmith Applications, Inc.
	Filename:		AwayX\enterLDAP.cfm
	Created:		5/27/2010
	Developer:		Kal
	Description:	User validation for LDAP authentication
	Usage:			enter.cfm
	Tip:			This file is similar in functionality to enter.cfm but needs to authenticate against LDAP.
	--->
<cfset variables.qGetLDAPSettings = application.oLDAPSettingsManager.getLDAPSettings() />
<cfset application.oController.getObject(path="components.user.profile",name="profile",bReload= 0) />

<cfscript>
	/* variables */
	variables.serverName = variables.qGetLDAPSettings.LDAP_Server;
	exists = findNoCase(variables.qGetLDAPSettings.LDAP_Org_Name, variables.qGetLDAPSettings.LDAP_Server);
	if(!exists){
		variables.serverName = listappend(variables.serverName,variables.qGetLDAPSettings.LDAP_Org_Name,".");
	}

		/* root */
	variables.root="";
	variables.root = "CN=" & listFirst(variables.qGetLDAPSettings.LDAP_Org_Unit_Name,".");
	for(i=1; i LTE listLen(variables.serverName,"."); i=i+1){
		variables.root = variables.root & ",DC=" & listGetAt(variables.serverName,i,".");
	}

	/* port */
	variables.port = variables.qGetLDAPSettings.LDAP_Port;
	if(variables.qGetLDAPSettings.LDAP_SSL_Enabled){
		variables.port = variables.qGetLDAPSettings.LDAP_SSL_Port;
	}

	/* attributes */
	variables.attributes = "dn,cn,sn,name,givenname,mail,userPrincipalName,sAMAccountName,objectGUID";

	/* filter */
	variables.filter = "(&(objectCategory=person)(objectClass=user)(SAMAccountName=#Form.User_Code#))";

	/* LDAP username */
	if(variables.qGetLDAPSettings.LDAP_Server_Win2003){
		variables.username = Form.User_Code & "@" & variables.serverName;
	}
	else{
		variables.username = listfirst(variables.serverName,".") & "\" & Form.User_Code;
	}

	/* LDAP password */
	variables.password = Form.User_Password;

</cfscript>

<cftry>
	<cfldap action="QUERY"
		name="qLDAPLogin"
		attributes="#variables.attributes#"
		start="#variables.root#"
		filter="#variables.filter#"
		server="#variables.serverName#"
		port="#variables.port#"
		returnAsBinary = "objectGUID"
		username="#variables.username#"
		password="#variables.password#">
	<!--- Catch any [LDAP unavailable/Login failure] errors and act --->

	<cfcatch type="any">
		<cfset inval_string = "Authentication failed">
		<cfif FindNoCase(inval_string, cfcatch.message)>
			<cfset error="<div class=""Title9"">Authentication Failed! Invalid Username/Password.</div>" />
		<cfelse>
			<cfset error="<div class=""Title9"">#variables.qGetLDAPSettings.LDAP_Issue_Message#</div>" />
		</cfif>

	    <!--- Dev Notes: 23887/Anand Rao/29-Jun-10. Update LDAP for User traffic info/query was moved into recordIP.cfm--->
	    <cfset varAuditAction = "UNKNOWN-USER" />
	    <cfset varUser_Code   = FORM.User_Code />
	    <cfset varUser_ID     = "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxx" />
	    <cfset insLoginIP     = 1 />
	    <cfset LoginIPstatus  = 0 />
	 	<cfinclude template="recordIP.cfm">
		<cfinclude template="#loginFailureIncludePage#">
	</cfcatch>
</cftry>


<cfif isDefined("qLDAPLoginInfo")>

	<cfif (qLDAPLoginInfo.recordCount) and  isDefined("qLDAPLoginInfo.sAMAccountName") and len(qLDAPLoginInfo.sAMAccountName)>
		<!---
		Query user table for the name and-or email and LDAP_ID.
		If user exists but NO LDAP_ID then update user table with LDAP_ID.
		If the user and LDAP_ID exists continue with login.
		If no user account and-or no position display BSA_Issue error msg.
		If multiple accounts then display a drop down of profile-position to select
		 --->
		<!--- Convert the returned User GUID from  --->
		<cfset variables.LDAP_User_ID = BinaryEncode(qLDAPLoginInfo.objectGUID,"hex") />

		<cfquery name="LoginInfo" datasource="#application.datasource#">
			SELECT 	U.User_ID, U.User_Code, U.User_Email, isnull(U.Profiles_ID,1) as Profiles_ID, isnull(U.LDAP_User_ID, '') as LDAP_User_ID, isnull(U.LDAP_User_Name,'') as LDAP_User_Name
			FROM 	_Users U
			WHERE	Deleted = 0
			AND		isnull(U.LDAP_User_ID,<cfqueryparam value="#variables.LDAP_User_ID#" cfsqltype="cf_sql_varchar">) = <cfqueryparam value="#variables.LDAP_User_ID#" cfsqltype="cf_sql_varchar">
			AND		isnull(U.LDAP_User_Name,'') = <cfqueryparam value="#qLDAPLoginInfo.sAMAccountName#" cfsqltype="cf_sql_varchar">
			<cfif isDefined("form.id") and Len(form.id)>
			AND		U.User_ID 		= <cfqueryparam value="#form.id#" cfsqltype="cf_sql_varchar">
			</cfif>
			Order by User_Code
		</cfquery>

		<!--- Update User Records with LDAP ID's --->
		<cfif LoginInfo.recordCount>
			<cfquery name="qUpdateUserInfo" datasource="#application.datasource#">
				UPDATE 	_USERS
				SET 	LDAP_USER_ID 			=	<cfqueryparam value="#variables.LDAP_User_ID#" cfsqltype="cf_sql_varchar">
				WHERE 	User_ID  				IN	(<cfqueryparam value="#ValueList(LoginInfo.User_ID)#" cfsqltype="cf_sql_varchar" list="true">)
				AND		LDAP_User_Name 			=	<cfqueryparam value="#qLDAPLoginInfo.sAMAccountName#" cfsqltype="cf_sql_varchar">
				AND		isnull(LDAP_User_ID,'')	=  ''
			</cfquery>
		</cfif>

	<cfelse> <!--- HZ LDAP returns blank and doesnt return any records --->

		<cfquery name="LoginInfo" datasource="#application.datasource#">
			SELECT 	U.User_ID, U.User_Code, U.User_Email, isnull(U.Profiles_ID,1) as Profiles_ID, isnull(U.LDAP_User_ID, '') as LDAP_User_ID, isnull(U.LDAP_User_Name,'') as LDAP_User_Name
			FROM 	_Users U
			WHERE	U.Deleted = 0
			AND		U.LDAP_User_Name =  <cfqueryparam value="#Form.User_Code#" cfsqltype="cf_sql_varchar">
			<cfif isDefined("form.id") and Len(form.id)>
			AND		U.User_ID 		= <cfqueryparam value="#form.id#" cfsqltype="cf_sql_varchar">
			</cfif>
			Order by User_Code
		</cfquery>
	</cfif> <!--- End: (qLDAPLoginInfo.recordCount) and  isDefined("qLDAPLoginInfo.sAMAccountName") and len(qLDAPLoginInfo.sAMAccountName) --->


	<cfif LoginInfo.recordCount GT 1> <!--- if multiple records show drop down for user code - profile--->
		<cfinclude template="enterMultiPositions.cfm" />
	<cfelseif LoginInfo.recordCount EQ 1> 	<!--- if one record --->
		<cfset form.id = LoginInfo.User_ID />
		<cfinclude template="process_login.cfm">
	<cfelse>		<!--- If no records show BSA error msg --->
		<cfset error="<div class=""Title8"">#variables.qGetLDAPSettings.LDAP_BSA_Issue_Message#</div>" />
		<!--- Dev Notes: 23887/Anand Rao/29-Jun-10. Update LDAP for User traffic info/query was moved into recordIP.cfm --->
		<cfset varAuditAction = "UNKNOWN-USER" />
		<cfset varUser_Code   = FORM.User_Code />
		<cfset varUser_ID     =  "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxx" />
		<cfset insLoginIP = 1 />
		<cfset LoginIPstatus = 0 />
		<cfinclude template="recordIP.cfm">
		<cfinclude template="#loginFailureIncludePage#">
	</cfif>	<!--- End: LoginInfo.recordCount GT 1 --->

</cfif> <!--- End : isDefined("qLDAPLoginInfo") --->
