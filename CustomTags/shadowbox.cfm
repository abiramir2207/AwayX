<CFPARAM NAME="Attributes.Align" TYPE="string" DEFAULT="">


<CFOUTPUT>
	<CFSWITCH EXPRESSION="#ThisTag.ExecutionMode#">
		<CFCASE VALUE="start">
			<TABLE border="0" cellpadding="0" cellspacing="0" ALIGN="#Attributes.Align#">
			  <TR>
			    <TD><IMG src="/_qa/images/shadow_01.gif" width="13" height="13"></TD>
			    <TD background="/_qa/images/shadow_02.gif"></TD>
			    <TD><IMG src="/_qa/images/shadow_03.gif" width="13" height="13"></TD>
			  </TR>
			  <TR>
			    <TD background="/_qa/images/shadow_04.gif"></TD>
			    <TD BGCOLOR="White" NOWRAP>
		</CFCASE>
		
		<CFCASE VALUE="end">
				</TD>
			    <TD background="/_qa/images/shadow_06.gif"></TD>
			  </TR>
			  <TR>
			    <TD><IMG src="/_qa/images/shadow_07.gif" width="13" height="13"></TD>
			    <TD background="/_qa/images/shadow_08.gif"></TD>
			    <TD><IMG src="/_qa/images/shadow_09.gif" width="13" height="13"></TD>
			  </TR>
			</TABLE>
		</CFCASE>
	</CFSWITCH>
</CFOUTPUT>