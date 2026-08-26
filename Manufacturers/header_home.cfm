
<!--- Test for the appropriate browser															 --->
<CF_browser browserVerbose="true" versionVerbose="true">
	<CFIF browser NEQ "MS Internet Explorer" OR (browser EQ "MS Internet Explorer" AND version LT 5.0)>
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/getie.cfm';</SCRIPT>
	</CFIF>



<CFPARAM NAME="group" 		DEFAULT="">
<CFPARAM NAME="PAGE_TITLE"	DEFAULT=" ">




<STYLE TYPE="text/css">
#navbarlinks
	{
		font-weight : bold;
		color: #000000;
		font-size: 12px;
	}
A:HOVER.navbarlinks
	{
		color : White;
	}

SPAN.text {
font-size: 12pt;
font-weight: bold;
color: Yellow;
position: absolute;
left: 87px;
top: 13px;
z-index: 2
} 

SPAN.shadow {
font-size: 12pt;
font-weight: bold;
color: black;
position: absolute;
left: 88px;
top: 14px;
z-index: 1
}
</STYLE>






<TABLE HEIGHT="100%" WIDTH="100%" CELLPADDING="0" CELLSPACING="0" BORDER="0"><TR><TD>
<CFOUTPUT>
<TABLE border="0" width="100%" cellspacing="0" cellpadding="0" background="/Images/Header_new/header_background.gif">
	<TR>
		<TD><A HREF="#request.AccessStructure.User_Directory#/home.cfm"><IMG border="0" src="/Images/Header_new/#request.AccessStructure.Company_logo#" width="84" height="78"></A></TD>
		<TD width="100%" VALIGN="bottom">

			<SPAN CLASS="Text">#request.AccessStructure.Company_Name# - <FONT SIZE="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</FONT></SPAN>

			<SPAN CLASS="Shadow">#request.AccessStructure.Company_Name# - <FONT SIZE="3">#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</FONT></SPAN>


			<TABLE border="0" width="100%" cellspacing="0" cellpadding="0">
				<TR>
					<TD width="100%">&nbsp;</TD>
					<TD ALIGN="center"><A HREF="#request.AccessStructure.User_Directory#/home.cfm"><IMG SRC="/images/home_icon_new.gif" BORDER="0" TITLE="Home..." HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/common_files/contracts/index.cfm"><IMG SRC="/images/contracts_icon_new.gif" BORDER="0" TITLE="Contracts..." HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/common_files/payables2/index.cfm"><IMG SRC="/images/payables_icon_new.gif" BORDER="0" TITLE="Payables..." HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/common_files/admin.cfm"><IMG SRC="/images/profiles_icon_new.gif" BORDER="0" TITLE="Profiles..." HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/reports/index.cfm"><IMG SRC="/images/reports_icon_new.gif" BORDER="0" TITLE="Reports..." HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/pda_stuff/index.cfm"><IMG SRC="/images/pda_icon_new.gif" BORDER="0" TITLE="PDA Exports" HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/settings/index.cfm"><IMG SRC="/images/settings_icon_new.gif" BORDER="0" TITLE="Settings..." HSPACE="2"></A></TD>
					<TD ALIGN="center"><A HREF="/logoff.cfm?id=#createuuid()#"><IMG SRC="/images/logoff_icon_new.gif" BORDER="0" TITLE="Logoff..." HSPACE="2"></A></TD>
					<TD><IMG SRC="/images/fill.gif" WIDTH="5" HEIGHT="18"></TD>
				</TR>
			</TABLE>
 


			<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="23">
			<SPAN CLASS="TITLE2"><!--- #PAGE_TITLE# ---></SPAN><BR><BR>
		</TD>
	</TR>
</TABLE>

</CFOUTPUT>

</TD></TR>
<TR><TD HEIGHT="100%" VALIGN="top">

