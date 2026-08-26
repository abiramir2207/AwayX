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
			<!-----<B>We cannot accept your login request since you're already logged on to the application.
			<BR><BR>
			To avoid this, please make sure that you click the "Loggoff" button when ready to leave the application.
			<BR><BR>
			To reset your present loggin status, click the "reset loggin status" button below.</B>
			<BR>------->
			<B>Your current login session is no longer valid due to one of the following reasons,<BR>
			<UL>
				<LI>You didn't logout the last time you closed the application</LI>
				<LI>Some other login session has reset your current login session</LI>
			</UL>			
			To avoid this, please make sure that you click the "Logoff" button when ready to leave the application.
			<BR><BR>
			To reset your present login status, click the "reset login status" button below.</B>
			<BR>
			<BR><BR><BR>
			<BR><BR><BR><BR>
			
			<cfoutput>
			<A HREF="reset_login_status.cfm?id=#URL.ID#"><IMG BORDER="0" TITLE="reset login status" SRC="/Images/reset_button.gif"></A>
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
	</CFOUTPUT>
	if(window.opener)
	{
		window.opener.location.href = homePage;
		window.close();
	}
}
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CENTER><FONT COLOR="Gray"><CFINCLUDE TEMPLATE="includes/copyright.cfm"></FONT></CENTER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

