<CFSET pagetitle = "SYSTEM ADMINISTRATION: UNLOCK USERS">
<cfset UsersIP = CGI.Remote_Addr>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><Cfoutput>#PageTitle#</CFOUTPUT></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">


<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfif isDefined("url.User_ID")>

	<CFSET alphastring = "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
	<cfset tempPassword ="">
		<CFLOOP INDEX="LoopCount" FROM="1" TO="10" STEP="1">
			<CFSET tempPassword=tempPassword&mid(alphastring, randrange(1, len(alphastring)), 1)>
		</CFLOOP>

	<cfquery name="UnlockUser" datasource="#application.datasource#">
		UPDATE _users
		SET 
		Is_Locked = 0, 
		LoginTries = 0, 
		Is_First_Time = 1, 
		User_Password = '#hash(tempPassword)#'	
		WHERE User_ID = '#url.User_ID#'
		AND Deleted = 0
	</cfquery>
	 
  <!--- 
	Dev Notes: 23086/Anand Rao/21-May-10
	User Traffic Changes
  --->
  <cfquery name="qGetUserCode" datasource="#application.datasource#">
    SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#URL.User_ID#" cfsqltype="CF_SQL_VARCHAR">
  </cfquery>

  <cfquery name="AddUserTransUnlock" datasource="#application.datasource#">
    INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
    VALUES
    (
      'UNLOCK-USER',
      <cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
      <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
      <cfqueryparam value="#REQUEST.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
    )
  </cfquery>

 	<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
	
	<cfquery name="ConfirmLogin" datasource="#application.datasource#">
		SELECT User_Code, User_Password, User_Email
		FROM _users
		WHERE User_ID	=	'#url.User_ID#'
		AND Deleted = 0
	</cfquery>
	
	<cfoutput>
	<CF_EMAILWRAPPER  
		TO="#ConfirmLogin.User_Email#"
		FROM="#Contact_Admin_Email_Address#"
		SUBJECT="#application.CompanyName# Changed Password"
		type="html" 
		messagetype="1" 
		generatedby="2" 
		apparea="9"
		logMessage="0">
		
	<TABLE WIDTH="100%">
	<TR VALIGN="top">
	<TD>
	Your account has been unlocked and your password changed. Your current login information is:<BR><BR>

	User Name: <FONT COLOR="Red" NOWRAP><B>#ConfirmLogin.User_Code#</B></FONT><BR>
	<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getSeparateIdPasswordEmail() >
	<BR>Password for this account will be sent in a separate email.
	<cfelse>
	Password: <FONT COLOR="Red" NOWRAP><B>#tempPassword#</B></FONT><BR>
	</cfif>
	</TD>
	</TR>
	</TABLE>
	</cf_EmailWrapper>
	</cfoutput>

	<!--- Dev Note: 52846; Kal: Separate email for userId and password --->
	<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getSeparateIdPasswordEmail() >
	<cfoutput>
	<CF_EMAILWRAPPER  
		TO="#ConfirmLogin.User_Email#"
		FROM="#Contact_Admin_Email_Address#"
		SUBJECT="#application.CompanyName# Changed Password"
		type="html" 
		messagetype="1" 
		generatedby="2" 
		apparea="9"
		logMessage="0">
		
	<TABLE WIDTH="100%">
	<TR VALIGN="top">
	<TD>
	Your account has been unlocked and your password changed. Your current login information is:<BR><BR>

	Password: <FONT COLOR="Red" NOWRAP><B>#tempPassword#</B></FONT><BR>
	<BR> Username for this account will be sent in a separate email.	
	</TD>
	</TR>
	</TABLE>
	</cf_EmailWrapper>
	</cfoutput>
	</cfif>
	<!--- End Note: 52846; Kal: Separate email for userId and password --->

<!---cfif isDefined("blnSubmit")--->
</cfif>


<cfquery name="LockedUsers" datasource="#application.datasource#">
SELECT * 
FROM _users
WHERE 
		Is_Locked = 1
		AND Deleted = 0
</cfquery>

<BLOCKQUOTE>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<p></p>

<table border="0" width="80%">
<tr><td colspan="2" align="left"><strong>There are <cfoutput>#LockedUsers.Recordcount#</cfoutput> locked users</strong> </td></tr>
<cfoutput query="LockedUsers">
<tr>
<td valign="top">#User_Code# (#Name_First# #Name_Last#)</td>
<td>
<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/settings/unlock_user.cfm?User_ID=#User_ID#">unlock this user</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
</td>
</tr>
</cfoutput>
</table>

</BODY>
</HTML>