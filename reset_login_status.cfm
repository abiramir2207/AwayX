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


<TABLE border="0" cellspacing="3" cellpadding="3">
	<TR>
		<TD ROWSPAN="100%" WIDTH="100">&nbsp;</TD>
		<TD>
			<a href="/index.htm"><img border="0" src="/images/logon_telus/TELUS_Trade_Promotion_Management_Logo.svg" height="14" border="0"></a>
		</TD>

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

			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!-----  Reset Session_Tracker ------->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<CFPARAM NAME="URL.ID" DEFAULT="">
			<CFPARAM NAME="Cookie.User_Id" DEFAULT="">
			<CFSET URL.ID = Cookie.User_Id />
			<!--- 84748: Kal: 03/27/2019 :  For some clients we set secure cookies This makes the cookie set by a browser(chrome) not accessible in another browser window (IE), causing a login loop --->
			<cfif (url.id eq "") and isdefined("session.accessstructure.user_id")>
				<cfset url.id = session.accessstructure.user_id />
			</cfif>

			<CFQUERY NAME="Reset_Login_Status" datasource="#application.datasource#">
			UPDATE	Session_Tracker
			SET 	Session_ID = NULL
			WHERE	Session_User_ID		=	<cfqueryparam value="#URL.ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!-----  End Reset Session_Tracker ------->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!-----  Reset autologout queue ------->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<CFPARAM NAME="URL.ID" DEFAULT="">
			<!--- remove user from queue --->
			<CFSET AutoLogout = CreateObject("component","components.AutoLogout.AutoLogout")>
			<cfset temp = AutoLogout.removeUserFromQueue(URL.ID)>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!-----  End Reset autologout queue ------->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



			<BR><BR>
			<B>The user login status has been reset!<BR><BR>Please wait while we take you back</B>

		</TD>
	</TR>
</TABLE>



<script language="JavaScript">
<CFOUTPUT>
	var loginPage = "#application.LoginPage#";
</CFOUTPUT>
function seeya()
{
	window.parent.window.location.href=loginPage;
}
setTimeout('seeya()',2000); 
</script>



</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CENTER><FONT COLOR="Gray"><CFINCLUDE TEMPLATE="includes/copyright.cfm"></FONT></CENTER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
































