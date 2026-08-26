<CFSET PAGE_TITLE=	"User Information">
<CFSET GROUP=		"Administration">

<CFPARAM NAME="URL.User_ID" DEFAULT="">


<CFQUERY NAME="GetUserLevels" datasource="#application.datasource#">SELECT *
	FROM _Users_Access_Rights
</CFQUERY>

<CFQUERY NAME="GetAllCompanies" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Main
	WHERE Deleted = 0
	ORDER BY Company_Name ASC
</CFQUERY>

<CFQUERY NAME="GetUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM _Users
	WHERE 
			User_ID = '#URL.User_ID#'
			AND
			Deleted = 0
</CFQUERY>

<CFPARAM NAME="URL.RTS" DEFAULT="0">
<CFPARAM NAME="Form.ActionPage" DEFAULT="InsertActions.cfm">
<CFPARAM NAME="ButtonCaption" DEFAULT="create user">

<CFPARAM NAME="Form.User_Name_First" DEFAULT="#GetUserInfo.Name_First#">
<CFPARAM NAME="Form.User_Name_Last" DEFAULT="#GetUserInfo.Name_Last#">
<CFPARAM NAME="Form.User_Title" DEFAULT="#GetUserInfo.Title#">
<CFPARAM NAME="Form.User_Work_Address_1" DEFAULT="#GetUserInfo.Work_Address_1#">
<CFPARAM NAME="Form.User_Work_Address_2" DEFAULT="#GetUserInfo.Work_Address_2#">
<CFPARAM NAME="Form.User_Work_City" DEFAULT="#GetUserInfo.Work_City#">
<CFPARAM NAME="Form.User_Work_State" DEFAULT="#GetUserInfo.Work_State#">
<CFPARAM NAME="Form.User_Work_Zip" DEFAULT="#GetUserInfo.Work_Zip#">
<CFPARAM NAME="Form.User_Work_Phone_1" DEFAULT="#mid(GetUserInfo.Work_Phone,2,3)#">
<CFPARAM NAME="Form.User_Work_Phone_2" DEFAULT="#mid(GetUserInfo.Work_Phone,6,3)#">
<CFPARAM NAME="Form.User_Work_Phone_3" DEFAULT="#mid(GetUserInfo.Work_Phone,9,4)#">
<CFPARAM NAME="Form.emailaddress" DEFAULT="#GetUserInfo.user_email#">
<CFPARAM NAME="Form.User_Rights_ID" DEFAULT="#GetUserInfo.User_Rights_ID#">

<CFIF GetUserInfo.Recordcount NEQ 0>
	<CFSET Form.ActionPage = "UpdateActions.cfm">
	<CFSET ButtonCaption = "save changes">
</CFIF>


<CFQUERY NAME="GetStates" datasource="#application.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<SCRIPT SRC="../PhoneNumberValidationCode.js"></SCRIPT>
<SCRIPT>
	function DeleteUser(User_ID) {
		if(confirm("Press OK To Delete This User")) {
			document.all.DeleteUserForm.submit();
		}
	}
	
	function submittheform(){
		if(_CF_checkUserGeneralInfo(document.all.UserGeneralInfo)) document.all.UserGeneralInfo.submit();
	}

</SCRIPT>
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>

	<DIV CLASS="page_instructions" ALIGN="left">Please Enter the Appropiate User Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">

	
	
	<CFFORM ACTION="#Form.ActionPage#" METHOD="POST" NAME="UserGeneralInfo">
	<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="UserGeneralInfo">		
	<INPUT TYPE="hidden" NAME="User_ID" ID="User_ID" VALUE="<CFOUTPUT>#URL.User_ID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="RTS" VALUE="<CFOUTPUT>#URL.RTS#</CFOUTPUT>">
	
	<DIV ALIGN="center">	

<FIELDSET STYLE="padding:8px; width: 1%; border: 1px solid Blue;">
     <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">General User Information</LEGEND>
		<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="0" CELLPADDING="3" BORDERCOLORDARK="#000000" ALIGN="left">
			<TR>
				<TD ALIGN="right" VALIGN="middle" NOWRAP>Access Right</TD>
				<td>
					<SELECT NAME="User_Rights_ID">
						<CFOUTPUT QUERY="GetUserLevels">
							<OPTION VALUE="#GetUserLevels.User_Rights_ID#"<cfif GetUserLevels.User_Rights_ID EQ Form.User_Rights_ID> SELECTED</cfif>>#GetUserLevels.User_Rights_Description#</OPTION>
						</CFOUTPUT>
						
					
					</SELECT>
				</td>
			
			</TR>
			<TR>
				<TD ALIGN="right" VALIGN="middle">Name</TD>
				<TD>
					<TABLE>
						<TR>
							<TD>
								<FONT COLOR="Silver">First Name</FONT><BR>
								<CFINPUT TYPE="Text" NAME="User_Name_First" VALUE="#Form.User_Name_First#" MESSAGE="Please Enter The Users First Name" REQUIRED="Yes">
							</TD>
							<TD ALIGN="left">
								<FONT COLOR="Silver">Last Name</FONT><BR>
								<CFINPUT TYPE="Text" NAME="User_Name_Last" VALUE="#Form.User_Name_Last#" MESSAGE="Please Enter THe Users Last Name" REQUIRED="Yes">
							</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">Company</TD>
				<TD>
					<SELECT NAME="Company_Main_ID" ID="Company_Main_ID">
						<CFOUTPUT QUERY="GetAllCompanies">
							<OPTION VALUE="#GetAllCompanies.Company_Main_ID#"<CFIF GetUserInfo.RecordCount>#IIF(GetAllCompanies.Company_Main_ID EQ GetUserInfo.Company_Main_ID, DE(" SELECTED"), DE(""))#<CFELSE>#IIF(GetAllCompanies.Company_Main_ID EQ request.AccessStructure.Company_Main_ID, DE(" SELECTED"), DE(""))#</CFIF>>#GetAllCompanies.Company_Name#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">Title</TD>
				<TD>
					<CFINPUT TYPE="Text" NAME="User_Title" VALUE="#Form.User_Title#" MESSAGE="Please Enter A Title" REQUIRED="Yes" SIZE="40">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">Address 1</TD>
				<TD>
					<CFINPUT TYPE="Text" NAME="User_Work_Address_1" VALUE="#Form.User_Work_Address_1#" MESSAGE="Please Enter An Address" REQUIRED="Yes" SIZE="40">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">Address 2</TD>
				<TD>
					<CFINPUT TYPE="Text" NAME="User_Work_Address_2" VALUE="#Form.User_Work_Address_2#" REQUIRED="No" SIZE="40">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">City</TD>
				<TD>
					<CFINPUT TYPE="Text" NAME="User_Work_City" VALUE="#Form.User_Work_City#" MESSAGE="Please Enter A City" REQUIRED="Yes" SIZE="40">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">State</TD>
				<TD>
					<CFSELECT NAME="User_Work_State" QUERY="GetStates" VALUE="State_ID" DISPLAY="State_Name" SELECTED="#Form.User_Work_State#" REQUIRED="Yes"></CFSELECT><FONT SIZE="-1" COLOR="Red">*</FONT>
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">ZIP</TD>
				<TD>
					<INPUT TYPE="Text" NAME="User_Work_Zip" VALUE="<CFOUTPUT>#Form.User_Work_Zip#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE', 5)" SIZE="4" MAXLENGTH="5">
				</TD>
			</TR>

			<TR>
				<TD ALIGN="right">Phone</TD>
				<TD>
					<INPUT TYPE="text" NAME="User_Work_Phone_1" ID="User_Work_Phone_1" VALUE="<CFOUTPUT>#Form.User_Work_Phone_1#</CFOUTPUT>" SIZE="2" MAXLENGTH="3" onKeyUp="javascript:nextBox(this, 'User_Work_Phone_2', 3)">-
					<INPUT TYPE="text" NAME="User_Work_Phone_2" ID="User_Work_Phone_2" VALUE="<CFOUTPUT>#Form.User_Work_Phone_2#</CFOUTPUT>" SIZE="2" MAXLENGTH="3" VALUE="" ONKEYUP="javascript:nextBox(this, 'User_Work_Phone_3', 3)">-
					<INPUT TYPE="text" NAME="User_Work_Phone_3" ID="User_Work_Phone_3" VALUE="<CFOUTPUT>#Form.User_Work_Phone_3#</CFOUTPUT>" SIZE="3" MAXLENGTH="4" VALUE="" ONKEYUP="javascript:nextBox(this, 'NONE', 4)">
				</TD>
			</TR>
			<TR>
				<TD ALIGN="right">E-Mail</TD>
				<TD><INPUT TYPE="text" NAME="emailaddress" SIZE="40" VALUE="<CFOUTPUT>#FORM.emailaddress#</CFOUTPUT>"></TD>
			</TR>
		</TABLE>
	</FIELDSET>
	</DIV>
	<TABLE ALIGN="center"><TR><TD>
	<CF_button
		button_caption	=	"#ButtonCaption#"
		button_action	=	"javascript:submittheform()"
		button_type		=	"link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	"Click here to Add the new User"
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold"
	>
	</TD>
	<CFIF GetUserInfo.RecordCount NEQ 0>
	<TD>
	
	<CF_button
		button_name		=	""
		button_caption	=	"delete user"
		button_action	=	"javascript:DeleteUser('#URL.User_ID#')"
		button_type		=	"button"
		button_width	=	""
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold"
	>
	</CFIF>
	</TR>
	</TABLE>
	

	</CFFORM>
	<FORM ACTION="UpdateActions.cfm" METHOD="post" NAME="DeleteUserForm" ID="DeleteUserForm">
		<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="DeleteUserForm">		
		<INPUT TYPE="hidden" NAME="User_ID" ID="User_ID" VALUE="<CFOUTPUT>#URL.User_ID#</CFOUTPUT>">
	</FORM>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>


