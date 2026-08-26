
<CFSET PAGE_TITLE=	"Help Files">
<CFSET GROUP=		"Help_Files">

<CFSET mainwindowsrc = "/help_files/1.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<TABLE WIDTH="100%" CELLPADDING="1" CELLSPACING="1" BORDER="0">
<TR>
	<TD VALIGN="bottom">
		&nbsp;&nbsp;
		<IMG SRC="/images/logo_1.gif" BORDER="0" ALT=""></TD>
	<TD ALIGN="right">
		<B>
		<FONT SIZE="2">
		<FONT  COLOR="Red">[</FONT>
			<A HREF="##" onclick="window.close();" TITLE="Close this window...">
				close this window
			</A>
		<FONT  COLOR="Red">]</FONT>
		</FONT>
		</B> 
		&nbsp;&nbsp;&nbsp;	
	</TD>
</TR>
</TABLE>



<TABLE CELLSPACING="5" CELLPADDING="0" ALIGN="center" valign="center">
	<TR NOWRAP>
		<TD>
			<!---Left Hand table of contents--->
			<IFRAME SRC="help_toc.cfm" NAME="toc" ID="toc" WIDTH="218" HEIGHT="620" MARGINWIDTH="0" MARGINHEIGHT="0"></IFRAME>
		</TD>
		<TD>
			<!---Right hand contents--->
			<IFRAME SRC="<CFOUTPUT>#mainwindowsrc#</CFOUTPUT>"	NAME="mainwindow" ID="mainwindow" WIDTH="770" HEIGHT="620" MARGINWIDTH="10" MARGINHEIGHT="10" FRAMEBORDER="1"></IFRAME><br>
		</TD>
	</TR>
</table>

<CENTER><B><i>To view a printable version of the help files, right click on the link you would like to print and select "Open In New Window".</i></B></CENTER>



</BODY>
</HTML>
