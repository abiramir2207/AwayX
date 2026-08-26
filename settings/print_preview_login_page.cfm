	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

<cfset isHttps = false>

<cfif CGI.SERVER_NAME EQ "BSA.blacksmithapps.com" or CGI.SERVER_NAME EQ "BSA.awayx.com">
	<cfset isHttps = true>
</cfif>

<TABLE WIDTH=784 BORDER=0 CELLPADDING=0 CELLSPACING=0 ALIGN="CENTER"  valign="top">
	<TR>
		<TD VALIGN="TOP"><IMG SRC="/images/Logon_Blacksmith/index_01.gif" WIDTH=38 HEIGHT=171 ALT=""></TD>
		<TD VALIGN="TOP"><IMG SRC="/images/Logon_Blacksmith/index_02.gif"  ALT=""><br /><IMG SRC="/images/Logon_Blacksmith/index_05.gif" WIDTH=75 HEIGHT=178 ALT="" valign="top"></TD>
		<TD VALIGN="TOP"><IMG SRC="/images/Logon_Blacksmith/index_03.gif" WIDTH=606 HEIGHT=98 BORDER="0" USEMAP="#mymap">
			<br />
		<TABLE border="0" cellspacing="0" cellpadding="6" align="center">
				<TR>
					<TD ALIGN="right" WIDTH="230"><FONT SIZE="+1" FACE="Arial, Helvetica, sans-serif" COLOR="#990000">User Code</FONT></TD>
					<TD ALIGN="LEFT">
						<INPUT TYPE="Text" NAME="User_Code" SIZE="13" class="input_textbox_input" maxlength="50">
					</TD>
					<TD WIDTH="75">&nbsp;</TD>
				</TR>
				<TR>
					<TD align="right" WIDTH="230"><FONT SIZE="+1" FACE="Arial, Helvetica, sans-serif" COLOR="#990000">Password</FONT></TD>
					<TD ALIGN="LEFT">
						<INPUT TYPE="password" NAME="User_password" SIZE="13" class="input_textbox_input">
					</TD>
					<TD>&nbsp;</TD>
				</TR>
				<TR>
					<TD ALIGN="right"></TD>
					<TD valign="top">&nbsp;&nbsp;<FONT SIZE="3" FACE="Arial, Helvetica, sans-serif" COLOR="#990000">Bookmark Application</font></TD>
					<TD></TD>
				</TR>
				<TR>
				<TR>
					<TD ALIGN="right"></TD>
					<TD>
						<INPUT TYPE="image" NAME="Button" SRC="/Images/Logon_Blacksmith/logon_button.gif">
					</TD>
					<TD>&nbsp;</TD>
				</TR>
				<TR>
					<TD COLSPAN="3" ALIGN="LEFT">
						<CFOUTPUT><span style="font-family:Arial,Helvetica,sans-serif;font-size:smaller">#appSettings.getLoginAndPasswordChangeMsg()#</span></CFOUTPUT>
					</span>
					<p>
					<span style="color:#CCCCCC;font-family:Arial,Helvetica,sans-serif;font-size:smaller">
					<CFINCLUDE TEMPLATE="/includes/copyright.cfm">
					</p>
					</span>
					</TD>
				</TR>
			</TABLE>			
		</TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/Logon_Blacksmith/index_07.gif" WIDTH=38 HEIGHT=104 ALT="">
		</TD>
		<TD ALIGN="CENTER">
			<cfif isHttps>
			<cfoutput><script src=https://seal.verisign.com/getseal?host_name=#CGI.HTTP_HOST#&size=S&use_flash=NO&use_transparent=YES&lang=en></script>
			</cfoutput>
			</cfif>
		</TD>
		<TD ALIGN="CENTER">
			&nbsp;		
		</TD>
	</TR>	
</TABLE>			