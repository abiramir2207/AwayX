<CFSET PAGE_TITLE="User Logon Information">

<cfset useLakebaseForGetUserInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserInfo>
	<cftry>
		<cfset GetUserInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#URL.User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserInfo>
<CFQUERY NAME="GetUserInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT Name_First, Name_Last
	FROM _Users
	WHERE User_ID = '#URL.User_ID#'
</CFQUERY>
</cfif>

<CFSET alphastring = "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
<cfset tempPassword ="">
<CFLOOP INDEX="LoopCount" FROM="1" TO="10" STEP="1">
	<CFSET tempPassword=tempPassword&mid(alphastring, randrange(1, len(alphastring)), 1)>
</CFLOOP>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		var username = "";
		var password = "<CFOUTPUT>#tempPassword#</CFOUTPUT>"
		
		var Username_Part1 = "";
		var Username_Part2 = "";
		var Username_Part3 = "";
		
		function writeWindowMsg(text) {
			document.all.CheckForDuplicateUsername.contentWindow.document.clear();
			document.all.CheckForDuplicateUsername.contentWindow.document.write("<BR><DIV ALIGN='center'><FONT SIZE='5' COLOR='Red'>" + text + "</FONT></DIV>")
		}
		
		function BuildUsername() {
			username = Username_Part1
			username = username + Username_Part2
			username = username + Username_Part3
			document.all.BuiltUsername.value = username;
		}
		
		function verifyUsername() {
			writeWindowMsg("Checking Databse For Duplicate Username...")
			document.all.CheckForDuplicateUsername.src = 'CheckForDuplicateUsername.cfm?username=' + username + '&FI=<CFOUTPUT>#lcase(left(GetUserInfo.Name_First, 1))#&LN=#lcase(left(GetUserInfo.Name_Last, 7))#</CFOUTPUT>';
		}
		
		function validUsername(validUsername) {
			disableControls();
			writeWindowMsg("Username: " + validUsername + "<BR>Password: " + password)
			document.all.Username.value = validUsername;
			document.all.Password.value = '<CFOUTPUT>#tempPassword#</CFOUTPUT>';
			document.all.verifyButton_table.style.display = "none";
			document.all.saveLoginInfo_table.style.visibility = "visible";
		}

		function disableControls() {
			document.all.Username_Part1[0].disabled = true;
			document.all.Username_Part1[1].disabled = true;
			document.all.Username_Part1[2].disabled = true;
			document.all.Username_Part1[3].disabled = true;

			document.all.Username_Part2[0].disabled = true;
			document.all.Username_Part2[1].disabled = true;

			document.all.Username_Part3[0].disabled = true;
			document.all.Username_Part3[1].disabled = true;
			document.all.Username_Part3[2].disabled = true;
			document.all.Username_Part3[3].disabled = true;
			
			document.all.verifyButton.disabled = true;
			document.all.BuiltUsername.disabled = true;

		}

		function enableControls() {
			document.all.Username_Part1[0].disabled = false;
			document.all.Username_Part1[1].disabled = false;
			document.all.Username_Part1[2].disabled = false;
			document.all.Username_Part1[3].disabled = false;

			document.all.Username_Part2[0].disabled = false;
			document.all.Username_Part2[1].disabled = false;

			document.all.Username_Part3[0].disabled = false;
			document.all.Username_Part3[1].disabled = false;
			document.all.Username_Part3[2].disabled = false;
			document.all.Username_Part3[3].disabled = false;
			
			document.all.verifyButton.disabled = false;
			document.all.BuiltUsername.disabled = false;			
		}
		
		function initPage() {
			document.all.saveLoginInfo_table.style.visibility = "hidden";
			document.all.Username_Part1[0].onclick()
			document.all.Username_Part2[1].onclick()
			document.all.Username_Part3[2].onclick()			
			BuildUsername();
			writeWindowMsg("Waiting To Validate");
			enableControls();
		}
	</SCRIPT>
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="initPage()">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV CLASS="page_instructions" ALIGN="left">Please Build A Username</DIV>
	<HR ALIGN="left" COLOR="EA7500">
	<BR>
	<DIV ALIGN="center">	
	<FIELDSET CLASS="fieldset" STYLE="Width: 500px;">
	<LEGEND ALIGN="left" CLASS="legend">Build Username</LEGEND>
		<BR>
		<TABLE>
			<TR>
				<TABLE BORDER="0" ALIGN="center" CELLPADDING="0" CELLSPACING="0">
					<TH COLSPAN="3" STYLE="font-size: 9pt; color: white; background-color: navy;">Select A Combination From Below to Build a Username</TH>
					<TR>
						<TD BGCOLOR="ccffcc">Part 1<BR><BR></TD>
						<TD>Part 2<BR><BR></TD>
						<TD BGCOLOR="ccffcc">Part 3<BR><BR></TD>
					</TR>
					<CFOUTPUT>
					<TR VALIGN="top">
						<TD BGCOLOR="ccffcc">
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part1" VALUE="#lcase(trim(GetUserInfo.Name_First))#" ONCLICK="javascript:Username_Part1 = this.value; BuildUsername();" CHECKED></TD><TD NOWRAP>#lcase(trim(GetUserInfo.Name_First))#</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part1" VALUE="#lcase(left(GetUserInfo.Name_First, 1))#" ONCLICK="javascript:Username_Part1 = this.value; BuildUsername();"></TD><TD NOWRAP>#lcase(left(GetUserInfo.Name_First, 1))#</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part1" VALUE="#lcase(trim(GetUserInfo.Name_Last))#" ONCLICK="javascript:Username_Part1 = this.value; BuildUsername();"></TD><TD NOWRAP>#lcase(trim(GetUserInfo.Name_Last))#</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part1" VALUE="#lcase(left(GetUserInfo.Name_Last, 1))#" ONCLICK="javascript:Username_Part1 = this.value; BuildUsername();"></TD><TD NOWRAP>#lcase(left(GetUserInfo.Name_Last, 1))#</TD></TR>
							</TABLE>	
						</TD>
						<TD>
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part2" VALUE="" ONCLICK="javascript:Username_Part2 = this.value; BuildUsername();"></TD><TD NOWRAP>none</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part2" VALUE="_" ONCLICK="javascript:Username_Part2 = this.value; BuildUsername();" CHECKED></TD><TD NOWRAP>underscore</TD></TR>
							</TABLE>
						</TD>
						<TD BGCOLOR="ccffcc">
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part3" VALUE="#lcase(trim(GetUserInfo.Name_First))#" ONCLICK="javascript:Username_Part3 = this.value; BuildUsername();"></TD><TD NOWRAP>#lcase(trim(GetUserInfo.Name_First))#</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part3" VALUE="#lcase(left(GetUserInfo.Name_First, 1))#" ONCLICK="javascript:Username_Part3 = this.value; BuildUsername();"></TD><TD NOWRAP>#lcase(left(GetUserInfo.Name_First, 1))#</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part3" VALUE="#lcase(trim(GetUserInfo.Name_Last))#" ONCLICK="javascript:Username_Part3 = this.value; BuildUsername();" CHECKED></TD><TD NOWRAP>#lcase(trim(GetUserInfo.Name_Last))#</TD></TR>
								<TR><TD><INPUT TYPE="Radio" NAME="Username_Part3" VALUE="#lcase(left(GetUserInfo.Name_Last, 1))#" ONCLICK="javascript:Username_Part3 = this.value; BuildUsername();"></TD><TD NOWRAP>#lcase(left(GetUserInfo.Name_Last, 1))#</TD></TR>
							</TABLE>
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="3" ALIGN="center" STYLE="font-size: 9pt;" BGCOLOR="">
							<BR>
							Constructed Username: <INPUT TYPE="text" NAME="BuiltUsername" SIZE="25" READONLY DISABLED>
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="3" ALIGN="center" STYLE="font-size: 9pt;">
							<BR>
							<CF_button
								button_name		=	"verifyButton"
								button_caption	=	"validate username"
								button_action	=	"verifyUsername()"
								button_type		=	"button"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"Click here to Add the new User"
								font_color		=	"White"
								font_size		=	"13"
								font_weight		=	"bold"
							>
						</TD>
					</TR>

					</CFOUTPUT>
				</TABLE>
			</TR>
			<TR>
				<TD>
					<IFRAME NAME="CheckForDuplicateUsername" ID="CheckForDuplicateUsername" WIDTH="50%" HEIGHT="120" MARGINWIDTH="0" MARGINHEIGHT="0" FRAMEBORDER="1" align="center"></IFRAME>
				</TD>
			</TR>
		</TABLE>
		
		</FIELDSET>
		<DIV align="center">
		<FORM ACTION="UpdateActions.cfm" METHOD="post" NAME="LoginAndPassword">
			<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="NewLoginInfo">
			<INPUT TYPE="hidden" NAME="User_ID" ID="User_ID" VALUE="<CFOUTPUT>#URL.User_ID#</CFOUTPUT>">
			<INPUT TYPE="hidden" NAME="Username" VALUE="">
			<INPUT TYPE="hidden" NAME="Password" VALUE="">
				<CF_button
					button_name		=	"saveLoginInfo"
					button_caption	=	"save login info"
					button_action	=	"document.LoginAndPassword.submit()"
					button_type		=	"button"
					button_width	=	""
					button_color	=	"Navy"
					button_tip		=	"Click here to Add the new User"
					font_color		=	"White"
					font_size		=	"13"
					font_weight		=	"bold"
				>
		</FORM>	
		</DIV>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">

</BODY>
</HTML>
