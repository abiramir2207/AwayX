<CFOUTPUT><CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#"><CFCASE VALUE="start">
	<TABLE border="0" cellspacing="0" cellpadding="0" ALIGN="center">
		<TR>
			<TD><IMG border="0" src="/Images/shadow_box/shadow1.gif" width="8" height="8"></TD>
			<TD background="/Images/shadow_box/shadow2.gif"><IMG border="0" src="/Images/shadow_box/shadow2.gif" width="9" height="8"></TD>
			<TD><IMG border="0" src="/Images/shadow_box/shadow3.gif" width="8" height="8"></TD>
		</TR>
		<TR>
			<TD background="/Images/shadow_box/shadow4.gif"><IMG border="0" src="/Images/shadow_box/shadow4.gif" width="8" height="9"></TD>
			<TD BGCOLOR="White"></CFCASE><CFCASE VALUE="end"></TD>
			<TD background="/Images/shadow_box/shadow5.gif"><IMG border="0" src="/Images/shadow_box/shadow5.gif" width="8" height="9"></TD>
		</TR>
		<TR>
			<TD><IMG border="0" src="/Images/shadow_box/shadow6.gif" width="8" height="8"></TD>
			<TD background="/Images/shadow_box/shadow7.gif"><IMG border="0" src="/Images/shadow_box/shadow7.gif" width="9" height="8"></TD>
			<TD><IMG border="0" src="/Images/shadow_box/shadow8.gif" width="8" height="8"></TD>
		</TR>
	</TABLE>
</CFCASE></CFSWITCH></CFOUTPUT>
