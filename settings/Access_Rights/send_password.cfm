<cfset UsersIP = CGI.Remote_Addr>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
	<HEAD>
		<TITLE><CFOUTPUT>#application.CompanyName#</CFOUTPUT></TITLE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
		<!---Gets correct "From" address--->
		<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
		<cfparam name="URL.User_ID" default="">
		<cfparam name="form.User_ID" default="">
		<cfif form.User_ID eq "">
			<cfset form.User_ID = URL.User_ID />	
		</cfif>
		<script>
		<!--
		function autoChange()
			{
				var timeID = setTimeout("location.href= 'logoff.cfm'", 5000)
			}
		//-->
		</script>
	</HEAD>
	<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Header goes here --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<BLOCKQUOTE><BLOCKQUOTE>
		<BR><BR>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Retrieve the login and password that match the provided settings								 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFQUERY NAME="Get_User_Data" DATASOURCE="#application.datasource#">
			Select		NAME_FIRST, NAME_LAST, User_Email, User_Code, isnull(LDAP_User_Name, User_Code) as user_name
			From		_Users
			Where		User_ID		=	<cfqueryparam value="#form.User_ID#" cfsqltype="cf_sql_idstamp">
		</CFQUERY>
		<CFQUERY NAME="Get_Sys_Admin" DATASOURCE="#application.datasource#">
			Select		NAME_FIRST, NAME_LAST
			From		_Users
			Where		User_ID		= <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_idstamp">	
		</CFQUERY>
		<CFIF Get_User_Data.recordCount LTE 0>
			<BR><BR><B>This user does not exist... </B><BR><BR>
			<CFABORT>
		</CFIF>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Generate a new password and encode it															 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- <CFSET password=left(hash(createuuid()),10)> --->
		<!--- Login info --->
		<CFSET alphastring = "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
		<cfset tempPassword ="">
		<CFLOOP INDEX="LoopCount" FROM="1" TO="10" STEP="1">
			<CFSET tempPassword=tempPassword&mid(alphastring, randrange(1, len(alphastring)), 1)>
		</CFLOOP>
		<CFSET password = tempPassword>
		<CFSET hash=hash(password)>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Save new password to database																	 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFQUERY NAME="Save_password" DATASOURCE="#application.datasource#">
			UPDATE _Users
			SET 		User_Password = <cfqueryparam value="#hash#" cfsqltype="cf_sql_varchar">,
			Password_Update_date = getdate(),
			Is_First_Time = 1
			WHERE		User_ID		=	<cfqueryparam value="#form.User_ID#" cfsqltype="cf_sql_idstamp">
		</CFQUERY>
		<!---  Dev Notes: 23086/Anand Rao/21-May-10; User Traffic Changes --->
		<cfquery name="qGetUserCode" datasource="#application.datasource#">
			SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#FORM.User_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfquery name="AddUserTransPasswordReset" datasource="#application.datasource#">
			INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
			VALUES
			(
			'PASSWORD-RESET',
			<cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">, 
			<cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			)
		</cfquery>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Send the password																				 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<cfset genSettings = CreateObject("component","components.settings.ApplicationSettingsManager").init() />
		<!--- Check whether emailing updated password is allowed by the admin. If so, send an email to the user who updated his/her password  --->
		<cfset EmailAdminPassword = genSettings.get().getAdminPassword()>
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
		<!--- Send the Email --->
		<cfif EmailAdminPassword eq 0>
			<cfoutput>
				<CF_EMAILWRAPPER 
					TO="#Get_User_Data.User_Email#"
					FROM="#Contact_Admin_Email_Address#"
					SUBJECT="Information"
					TYPE="HTML" 
					messagetype="1" 
					generatedby="2" 
					apparea="9"
					logMessage="0">
					<TABLE WIDTH="100%"> 
						<TR VALIGN="top">
							<TD COLSPAN="2">
							#Get_Sys_Admin.NAME_FIRST# #Get_Sys_Admin.NAME_LAST# has reset your password.<BR><BR>
							</TD>
						</TR>
						<TR VALIGN="top">
						<cfif appSettings.getSeparateIdPasswordEmail() >
							<TD COLSPAN="2">
								Username for this account will be sent in a separate email.
							</TD>
						<cfelse>
							<TD WIDTH="10%" NOWRAP>Login :</TD>
							<TD ALIGN="left" NOWRAP><FONT COLOR="Red"><B>#Get_User_Data.user_name#</B></FONT></TD>
	  				</cfif>
						</TR>
						<TR VALIGN="top">
							<TD WIDTH="10%" NOWRAP>Password :</TD>
							<TD ALIGN="left" NOWRAP><FONT COLOR="Red"><B>#password#</B></FONT></TD>
						</TR>
						<TR VALIGN="top">
							<TD COLSPAN="2">
								<BR>It is CASE SENSITIVE. Once you have logged in you may change your password.
							</TD>
						</TR>
						<TR VALIGN="top">
							<TD COLSPAN="2">
								<BR><B>URL</B>: <a href="#siteURL#">#siteURL#</a>
							</TD>
						</TR>
					</TABLE>
				</CF_EMAILWRAPPER>
			</cfoutput>
			<!--- Dev Note: 52846; Kal: Separate email for userId and password --->
			<cfif appSettings.getSeparateIdPasswordEmail() >
				<cfinclude template="send_user_id.cfm" />
			</cfif>
		</cfif>
		<CFOUTPUT>
		<BR><BR><B>The password of the following user has been reset
		<cfif EmailAdminPassword eq 0>
			and has been E-Mailed to him/her
		<cfelse>
			<br />
			<span style="color:red">
				Note: The password has not been e-Mailed to him/her as per request
			</span>
		</cfif>
		</B>:<BR><BR>
		<TABLE>
			<TR>
				<TD CLASS="dataLabel" ALIGN="right">Name:</TD>
				<TD ROWSPAN="100%" BGCOLOR="navy"><img SRC="/images/fill.gif" WIDTH="1"></TD>
				<TD>#Get_User_Data.Name_First#&nbsp;#Get_User_Data.Name_Last#</TD>
			</TR>
			<TR>
				<TD CLASS="dataLabel" ALIGN="right">Email:</TD>
				<TD>#Get_User_Data.User_Email#</TD>
			</TR>
		</TABLE>
		</CFOUTPUT>
		<!--- Tim Ford - 07/11/2014: Label 43678 - Emails for password reset and program emails being sent twice. 
					Adding code to redirect this page back to list users to prevent duplicate emails from being sent --->
		<cflocation url="/views/settings/list_users.cfm" />
		</BLOCKQUOTE></BLOCKQUOTE>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Footer goes here --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</BODY>
</HTML>
