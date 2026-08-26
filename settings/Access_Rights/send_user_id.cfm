<!--- Dev Note: 52846; Kal: Separate email for userId and password --->
<!--- Send User ID in email --->
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
			<TD WIDTH="10%" NOWRAP>Login :</TD>
			<TD ALIGN="left" NOWRAP><FONT COLOR="Red"><B>#Get_User_Data.user_code#</B></FONT></TD>
		</TR>
		<TR VALIGN="top">
			<TD COLSPAN="2">
				Updated password for this account will be sent in separate email.
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