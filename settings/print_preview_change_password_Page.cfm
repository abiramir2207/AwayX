

<!---End submitted code--->

<CFPARAM NAME="URL.FromHome" DEFAULT="0">
<CFPARAM NAME="PasswordMinLen" DEFAULT="7">
<CFPARAM NAME="PasswordHistory" DEFAULT="10">
<CFPARAM NAME="PasswordUpperChar" DEFAULT="0">
<CFPARAM NAME="PasswordLowerChar" DEFAULT="0">
<CFPARAM NAME="PasswordNumChar" DEFAULT="0">
<CFPARAM NAME="PasswordSpecialChar" DEFAULT="0">

<cfset genSettings = CreateObject("component","components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettings.get() />
<cfset PasswordMinLen = appSettings.getPasswordMinLen()>
<cfset PasswordHistory = appSettings.getPasswordHistory()>
<cfset PasswordUpperChar = appSettings.getPasswordUpperChar()>
<cfset PasswordLowerChar = appSettings.getPasswordLowerChar()>
<cfset PasswordNumChar = appSettings.getPasswordNumChar()>
<cfset PasswordSpecialChar = appSettings.getPasswordSpecialChar()>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Change Password</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET pagetitle = "Personal Settings: Change Password">

<CFPARAM NAME="PageTitle" DEFAULT="">
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="<CFIF URL.FROMHOME>100%<CFELSE>715</CFIF>">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="<CFIF URL.FROMHOME>100%<CFELSE>715</CFIF>" HEIGHT="25"><SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN></TD>
</TR>
</TABLE>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!--- If the customer wants to see the Confidentiality Agreement --->
<cfif appSettings.getConfidentialityAgreementStatus() eq 0 AND (appsettings.getLoginAndPasswordChangeMsg() neq "" OR appsettings.getChangePasswordScreenMsg() neq "")>
<div STYLE="font-size:1Opx; text-align: center; color:red; font-weight:bold;  margin-top:5px;">PLEASE READ THE AGREEMENT CAREFULLY BEFORE UPDATING YOUR PASSWORD</div> 
</cfif>
<cfif appSettings.getConfidentialityAgreementStatus() eq 0 AND appsettings.getLoginAndPasswordChangeMsg() neq "">
<table width="800" style="font-size:smaller"> 
	<tr>
		<td><CFOUTPUT><span style="font-family:Arial,Helvetica,sans-serif;font-size:smaller">#appsettings.getLoginAndPasswordChangeMsg()#</span></CFOUTPUT></td>
	</tr>
</table>
</cfif>

<cfif appsettings.getPasswordRequirementsStatus() eq 0 AND appsettings.getLoginAndPasswordChangeMsg() neq "" AND appsettings.getChangePasswordScreenMsg() neq "">
<p>
</cfif>
<cfif appsettings.getPasswordRequirementsStatus() eq 0  AND appsettings.getChangePasswordScreenMsg() neq "">
<table width="800"> 
	<tr>
		<td><cfoutput><span style="font-family:Arial,Helvetica,sans-serif;font-size:smaller">#appsettings.getChangePasswordScreenMsg()#</span></cfoutput></td>
	</tr>
</table>
</cfif>

<p style="font-weight: bold; color:red;">NOTE: You will need to re-login after you have changed your password
</p>

<FORM ACTION="password_form_action.cfm" METHOD="post"  NAME="ChangePassword" ID="MyForm" onSubmit="return checkData()">
<TABLE>
<TR>
	<TD ALIGN="right">Old Password:</TD>
	<TD><INPUT TYPE="password" NAME="OldPassword"></TD>
</TR>
<TR>
	<TD ALIGN="right">New Password:</TD>
	<TD><INPUT TYPE="password" NAME="NewPassword"></TD>
</TR>
<TR>
	<TD ALIGN="right">Re-enter New Password:</TD>
	<TD><INPUT TYPE="password" NAME="NewPassword2"></TD>
</TR>
<TR>
	<TD></TD>
	<TD></TD>
</TR>
</TABLE>
</FORM>

</BODY>
</HTML>


