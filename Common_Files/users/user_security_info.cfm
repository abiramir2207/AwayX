<CFSET PAGE_TITLE="User Security Info">

<cfset useLakebaseForGetUserAccessLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserAccessLevel>
	<cftry>
		<cfset GetUserAccessLevel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#URL.User_ID#",
				"select" = "access_level"
			}), "access_level"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserAccessLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserAccessLevel>
<CFQUERY NAME="GetUserAccessLevel" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT Access_Level
	FROM _Users
	WHERE User_ID = '#URL.User_ID#'
</CFQUERY>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV CLASS="page_instructions" ALIGN="left">Please Set The Users Access Level</DIV>
	<HR ALIGN="left" COLOR="EA7500">
	<BR>
	<DIV ALIGN="center">	
	<FIELDSET CLASS="fieldset" STYLE="width: 120px;">
	<LEGEND ALIGN="left" CLASS="legend">Access Level</LEGEND>
		<FORM ACTION="UpdateActions.cfm" METHOD="post" NAME="AccessLevel">
			<INPUT TYPE="hidden" NAME="Document_ID" VALUE="AccessLevel">
			<INPUT TYPE="hidden" NAME="User_ID" VALUE="<CFOUTPUT>#URL.User_ID#</CFOUTPUT>">
		
			<SELECT NAME="Access_Level" ID="Access_Level">
				<OPTION VALUE="R"<CFOUTPUT>#IIF(GetUserAccessLevel.Access_Level EQ "R", DE(" SELECTED"), DE(""))#</CFOUTPUT>>Read Only</OPTION>
				<OPTION VALUE="W"<CFOUTPUT>#IIF(GetUserAccessLevel.Access_Level EQ "W", DE(" SELECTED"), DE(""))#</CFOUTPUT>>Read/Write</OPTION>
			</SELECT>
	<br><br>
	</FIELDSET>
	<br><br>
	<CF_button
		button_caption	=	"Apply"
		button_type	=	"submit"
		button_width	=	"120"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold"
	>
		</FORM>

</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>

