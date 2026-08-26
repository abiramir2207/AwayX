<!---
***********************************************************************
Modified By: Milan Mushran
Modification: Send Email to users, If allowed by their company's admin
Filename: password_form_update.cfm
Modified Date: 9/8/2004
Purpose: Update Password
***********************************************************************
--->
					<CFPARAM NAME="PasswordHistory" DEFAULT="10">
					<CFPARAM NAME="PasswordHistoryList" DEFAULT="0">
					<CFPARAM NAME="PasswordHistoryListLen" DEFAULT="0">
					<CFIF IsDefined("URL.PasswordHistory")> <cfset PasswordHistory = #URL.PasswordHistory# /></CFIF>
					<cfset UsersIP = CGI.Remote_Addr>
					<cfquery name="ConfirmLogin" datasource="#application.datasource#">
					SELECT User_Email, User_Code, User_PasswordHistory, isnull(LDAP_User_Name, User_Code) as User_Name
					FROM _users
					WHERE User_ID	=	'#request.AccessStructure.User_ID#'
					AND Deleted = 0
					</cfquery>
					
					<!--- Dev Note: KAL; 7916 --->
					<cfset PasswordHistoryList		=	ValueList(ConfirmLogin.User_PasswordHistory) />
					<cfset PasswordHistoryListLen	=	ListLen(PasswordHistoryList) />
					<cfif PasswordHistoryListLen LT PasswordHistory >
						<cfset PasswordHistoryList	=	ListAppend(PasswordHistoryList, hash(NewPassword)) />
					<cfelse>
						<cfset temp = (PasswordHistoryListLen - PasswordHistory)+1 />
						<cfloop index="ListCount" from="1" to="#temp#" > <cfset PasswordHistoryList	= ListRest(PasswordHistoryList) /> </cfloop>
						<cfset PasswordHistoryList	=	ListAppend(PasswordHistoryList, hash(NewPassword)) />
					</cfif>
					
					<!--- End Note: KAL; 7916 --->
					
					<cfquery name="UpdateUser" datasource="#application.datasource#">
					Update _users
					Set User_Password = '#hash(NewPassword)#', 
					User_PasswordHistory = '#PasswordHistoryList#', 
					Is_First_Time = 0, 
					Is_Locked = 0,
					LoginTries = 0,
					Password_Update_date=getdate()
					WHERE User_ID = '#request.AccessStructure.User_ID#'
					</cfquery>
          <!---  Dev Notes: 23086/Anand Rao/21-May-10 User Traffic Changes --->
          <cfquery name="qGetUserCode" datasource="#application.datasource#">
          	SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
          </cfquery>
          <cfquery name="AddUserTransPasswordReset" datasource="#application.datasource#">
            INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
            VALUES
            (
              'PASSWORD-CHANGE',
              <cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
              <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
              <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
            )
          </cfquery>            
					
					<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">									
					
				<cfset genSettings = CreateObject("component","components.settings.ApplicationSettingsManager").init() />
				
				<!--- Check whether emailing updated password is allowed by the admin. If so, send an email to the user
						who updated his/her password  --->
				<cfset EmailNewPassword = genSettings.get().getNewPassword()>
				
				<!--- Send the Email --->
				<cfif EmailNewPassword eq 0>			
					<cfoutput>
					<CF_EMAILWRAPPER  
						TO="#ConfirmLogin.User_Email#"
						FROM="#Contact_Admin_Email_Address#"
						SUBJECT="#application.CompanyName# Changed Password"
						TYPE="HTML" 
						messagetype="1" 
						generatedby="2" 
						apparea="9"
						logMessage="0">
						
					<TABLE WIDTH="100%">
					<TR VALIGN="top">
					<TD>
					Your password has been changed. Your current login information is:<BR>
					User Name: <FONT COLOR="Red"><B>#ConfirmLogin.User_Name#</B></FONT><BR>					
					<!--- Dev Note: 52846; Kal: Separate email for userId and password --->
					<cfif genSettings.get().getSeparateIdPasswordEmail() > 
						Updated password for this account will be sent in separate email.<BR>
					<cfelse>
						Password: <FONT COLOR="Red"><B>#NewPassword#</B></FONT><BR>
					</cfif>
					</TD>
					</TR>
					</TABLE>
					</CF_EMAILWRAPPER>
					</cfoutput>
					<!--- Dev Note: 52846; Kal: Separate email for userId and password --->
					<cfif genSettings.get().getSeparateIdPasswordEmail() >
						<cfoutput>
							<CF_EMAILWRAPPER  
								TO="#ConfirmLogin.User_Email#"
								FROM="#Contact_Admin_Email_Address#"
								SUBJECT="#application.CompanyName# Changed Password"
								TYPE="HTML" 
								messagetype="1" 
								generatedby="2" 
								apparea="9"
								logMessage="0">
								
							<TABLE WIDTH="100%">
							<TR VALIGN="top">
							<TD>
							Your password has been changed. Your current login information is:<BR>
							Username for this account will be sent in a separate email.<BR>
							Password: <FONT COLOR="Red"><B>#NewPassword#</B></FONT><BR> <!--- email password in separate email --->
							</TD>
							</TR>
							</TABLE>
							</CF_EMAILWRAPPER>
						</cfoutput>					
					</cfif>
				</cfif>
					
				<cfif url.FromHome IS 0>
					<cflocation url="/logoff.cfm?ID=#request.AccessStructure.User_ID#">
				<cfelse>
				 	<script>
					<cfoutput>
					function redirectHome()
					{ 	window.opener.location.href="/logoff.cfm?ID=#request.AccessStructure.User_ID#"
						window.close()
					}
					redirectHome()
					</cfoutput>
					</script> 
				</cfif>