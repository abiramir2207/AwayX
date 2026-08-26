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
		<TD><IMG border="0" src="/images/logo_medium.gif" width="65" height="66" BORDER="0"></TD>
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
		<TD valign="top"><BR>
			
			
			
			
			<TABLE BORDER="0" WIDTH="500">
			<TR>
			<TD>
				
				<CF_browser browserVerbose="true" versionVerbose="true">
				
				<FONT SIZE="2">
				This application requires the use of Microsoft Internet Explorer 5.5 or later.
				You are currently using <CFOUTPUT>#browser#, release #version#</CFOUTPUT>.
				<BR><BR>
				
				Without the appropriate browser, you'll not be able to use the <CFOUTPUT>#application.CompanyName#</CFOUTPUT>.
				<BR><BR>
				
				
				After downloading and properly installing the browser, your system will be automatically configured
				for use with <CFOUTPUT>#application.CompanyName#</CFOUTPUT>.
				<BR><BR>
				
				We have provided a link that will allow you to download the current Microsoft 
				Internet Explorer browser. Review the <B><A HREF="http://www.microsoft.com/windows/ie/evaluation/sysreqs/default.asp">System Requirements</A></B> 
				if you're not sure of your system's configuration.
				<BR><BR><BR>
				
				Thank you
			
			
			
				<BR><BR><BR>
				<B><A HREF="http://www.microsoft.com/windows/ie/default.asp">
				<IMG SRC="/images/getie.jpg" BORDER="0" TITLE="Get the latest MSIE"><BR>
				Download Microsoft Internet Explorer
				</A></B>
				
				
				</FONT>
			
	
			
			</TD>
			</TR>
			</TABLE>

			
			
			
		</TD>
	</TR>
</TABLE>


</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CENTER><FONT COLOR="Gray"><CFINCLUDE TEMPLATE="includes/copyright.cfm"></FONT></CENTER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


