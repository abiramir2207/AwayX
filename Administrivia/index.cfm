<CFSET PAGE_TITLE="Application Management">
<CFSET group="management">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>



<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_awayx_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
			<DIV CLASS="title2">Application management:</DIV>

			<A HREF="/administrivia/view_email_log.cfm">view email log</A> <FONT COLOR="Red"><B>X</B></FONT><BR>
			<A HREF="/settings/control_panel.cfm?Tab=3">encrypt tool</A> <FONT COLOR="Red"><B>X</B></FONT><BR>

			
		</TD>
	</TR>
</TABLE>










</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
