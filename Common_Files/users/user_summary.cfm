<CFSET PAGE_TITLE="User Summary">

<CFQUERY NAME="GetUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT _Users.*, _states.state_name AS StateName
	FROM _Users, _states
	WHERE 
		_Users.Home_State = _states.state_ID
		AND	
		User_ID = '#URL.User_ID#'
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV CLASS="page_instructions" ALIGN="left">Summary Of User Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">
	<BR>
	<CFOUTPUT>
	<DIV ALIGN="center">
	<FIELDSET CLASS="fieldset">
	<LEGEND ALIGN="left" CLASS="legend">Information Summary</LEGEND>
		<TABLE ALIGN="left">
			<TR>
				<TD ALIGN="right" CLASS="labelname">Name</TD>
				<TD ROWSPAN="100%" BGCOLOR="000099"></TD>
				<TD CLASS="summary_page_cell">#GetUserInfo.Name_First# #GetUserInfo.Name_Last#</TD>
			</TR>
			<TR>
				<TD ALIGN="right" VALIGN="top" CLASS="labelname">Address</TD>
				<TD CLASS="summary_page_cell">
					#GetUserInfo.Home_Address_1#<BR>
					<CFIF len(GetUserInfo.Home_Address_2)>#GetUserInfo.Home_Address_2#<BR></CFIF>
					#GetUserInfo.Home_City#, #GetUserInfo.StateName# #GetUserInfo.Home_ZIP#
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right" CLASS="labelname">Phone</TD>
				<TD CLASS="summary_page_cell">#GetUserInfo.Home_Phone#</TD>
			</TR>
			<TR>
				<TD ALIGN="right" CLASS="labelname" NOWRAP>Access Level</TD>
				<TD CLASS="summary_page_cell">#GetUserInfo.Access_Level#</TD>
			</TR>
		</TABLE>
	</fieldset>
	</DIV>
	</CFOUTPUT>
	<BR>
	<DIV ALIGN="center">
	<TABLE>
		<TR>
			<TD>
				<CF_button
					button_caption	=	"Edit User Information"
					button_action	= "user_general_info.cfm?User_ID=#URL.User_ID#&RTS=1"
					button_type		=	"link"
					button_width	=	"155"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"13"
					font_weight		=	"bold"
				>			
			</TD>
			<TD>
				<CF_button
					button_caption	=	"Edit Access Level"
					button_action	= "user_security_info.cfm?User_ID=#URL.User_ID#&RTS=1"
					button_type		=	"link"
					button_width	=	"155"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"13"
					font_weight		=	"bold"
				>			
			</TD>
			<TD>
				<CF_button
					button_caption	=	"return to search"
					button_action	= "user_search.cfm"
					button_type		=	"link"
					button_width	=	"155"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"13"
					font_weight		=	"bold"
				>			
			</TD>

		</TR>
	</TABLE>
</DIV>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
