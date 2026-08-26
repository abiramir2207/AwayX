<CFSET PAGE_TITLE=	"User Management">
<CFSET GROUP=		"Administration">



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
<DIV ALIGN="center">
	<CF_button
	button_caption	=	"Create User"
	button_action	=	"user_general_info.cfm"
	button_type	=	"link"
	button_width	=	"200"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"13"
	font_weight		=	"bold"
>
<BR>
	<CF_button
	button_caption	=	"Search Users"
	button_action	=	"user_search.cfm"
	button_type	=	"link"
	button_width	=	""
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"13"
	font_weight		=	"bold"
>
</DIV>	
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
