<cfparam name="url.fromflex" default="0">
<cfparam name="cookie.user_id" default="">
<!--- 84748: Kal: 03/27/2019 :  For some clients we set secure cookies This makes the cookie set by a browser(chrome) not accessible in another browser window (IE), causing a login loop --->
<cfset url.id = cookie.user_id />
<cfif (url.id eq "") and isdefined("session.accessstructure.user_id")>
	<cfset url.id = session.accessstructure.user_id />
</cfif>

<cfquery name="checkForAutoLogout" datasource="#application.datasource#">
	SELECT _Users_Auto_Logout_List_ID
	FROM _Users_Auto_Logout_List
	WHERE User_ID = <cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<CFSET AutoLogOut=false>
<CFSET AutoLogOut_Users_Auto_Logout_List_ID = "">
<cfif checkForAutoLogout.recordcount GT 0>
	<CFSET AutoLogOut=true>
	<CFSET AutoLogOut_Users_Auto_Logout_List_ID = checkForAutoLogout._Users_Auto_Logout_List_ID>
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyName#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>
<BR><BR>


<TABLE border="0" cellspacing="0" cellpadding="0">
	<TR>
		<TD ROWSPAN="100%" WIDTH="100">&nbsp;</TD>
		<TD><IMG border="0" src="/images/logon_telus/TELUS_Trade_Promotion_Management_Logo.svg" height="14" BORDER="0"></TD>
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
			<BR><BR><br>

			<B>Your current login session is no longer valid due to one of the following reasons,<BR>
			<CFIF AutoLogOut EQ false>
				<UL>
					<LI>Your session has timed out due to inactivity</LI>
					<LI>You didn't logout the last time you closed the application</LI>
					<LI>Some other login session has reset your current login session</LI>
				</UL>
				To avoid this, please make sure that you click the "Logoff" button when ready to leave the application.
			<CFELSE>
				<cfquery name="getReason" datasource="#application.datasource#">
					SELECT Reason_Text
					FROM _Users_Auto_Logout_Reason
					WHERE _Users_Auto_Logout_List_ID = <cfqueryparam value="#AutoLogOut_Users_Auto_Logout_List_ID#" cfsqltype="CF_SQL_VARCHAR">
					ORDER BY _Users_Auto_Logout_Reason_ID
				</cfquery>
				<UL>
					<CFIF getReason.RECORDCOUNT EQ 0>
						<LI>The reason for logging you out has not been specified.</LI>
					<CFELSE>
						<cfoutput>
						<CFLOOP query="getReason">
							<LI>#getReason.Reason_Text#</LI>
						</CFLOOP>
						</cfoutput>

					</CFIF>
				</UL>
			</CFIF>
			<BR><BR>
			To reset your present login status, click the "reset login status" button below.</B>
			<BR>
			<BR><BR><BR>
			<BR><BR><BR><BR>
			<cfoutput>
			<A HREF="reset_login_status.cfm"><IMG BORDER="0" TITLE="reset login status" SRC="/Images/reset_button.gif"></A>
			</cfoutput>
		</TD>
	</TR>
</TABLE>


</BLOCKQUOTE></BLOCKQUOTE>

<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("closeChildWindows();")
function closeChildWindows()
{

	<CFOUTPUT>
	var homePage = "#application.MainFrameHomePage#";
	/* Milan (24104) - When the CF session has expired, Any call made from Flex to CF
	   has to pass session expiration value to flex. If the session has expired, then
		 the user is redirected to this page. If I do not add "if(#URL.FromFlex# == 0)"
		 this condition, then the user is redirected from this page to the home page.
		 The flex calls are using "FromFlex=1", whenever mvc\models folder is used.
	*/
 if(#URL.FromFlex# == 0)
 {
	</CFOUTPUT>
	try
	{
		if(window.opener)
		{
			if(	window.opener.name == "bsApplicationMainWindow" ||
				window.opener.name == "header_new" ||
				window.opener.name == "mywindowname" ||
				window.opener.name == "footer_new"
				) {
					window.opener.location.href = homePage;
					window.close();
				}
		}
		else if(window.top != window)
		{
			window.top.location.href = homePage;
		}
	}
	catch(e)
	{
	}
 }
}
</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CENTER><FONT COLOR="Gray"><CFINCLUDE TEMPLATE="includes/copyright.cfm"></FONT></CENTER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

