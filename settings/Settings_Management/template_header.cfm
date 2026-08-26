<CFSET TR_BORDER_WIDTH = 2>
<CFSET TD_FORE_COLOR = "FFE083">
<CFOUTPUT>
<STYLE TYPE="text/css">
A.tablink_back, A:Hover.tablink_back
	{
		color: 		Black;
		font-family:	Arial;
		font-size :		11px; 
		font-weight:	bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 		Black;
		font-family:	Arial;
		font-size :		11px; 
		font-weight:	bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 		Red;
		font-family:	Arial;
		font-size :		11px; 
		font-weight:	bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 		Red;
		font-family:	Arial;
		font-size :		11px; 
		font-weight:	bold;
		text-decoration:	none;
	}
	
	TD.headernotselected
  {
   color: blue;
   background-color 	: dddddd;
   border-bottom	: solid #TR_BORDER_WIDTH#px black;
   cursor		: pointer;	
  }
  TD.headerselected
  {
   border-left		: solid #TR_BORDER_WIDTH#px black;
   border-top		: solid #TR_BORDER_WIDTH#px black;
   border-right		: solid #TR_BORDER_WIDTH#px black;
   color: blue;
   background-color 	: #TD_FORE_COLOR#;
   cursor		: pointer;	
   TEXT-TRANSFORM	: uppercase;
  }
  TD.headerspacer
  {
   border-bottom	: solid #TR_BORDER_WIDTH#px black;
  }
</STYLE>
</CFOUTPUT>

<CFSET COMPONENT_PAGE_TITLES = "">

<CFSET COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "basic info", ",")>
<CFSET COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "details", ",")>

<CFOUTPUT>
<CFSET CLASS_NAME= "headernotselected">
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET C_Counter = 1>
		<CFLOOP LIST="#COMPONENT_PAGE_TITLES#" INDEX="ThisMenuItem">
			<cfif (#C_Counter# eq #tabHeader#) >
				<CFSET CLASS_NAME= "headerselected">
			<cfelse>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="180" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
				<B>
				<!--switch for each action--->
				<cfswitch expression="#C_Counter#">
					<cfcase value="1">
						<A CLASS="tablink_back" HREF="settings_management.cfm?tabHeader=1&Generic_Type=#Form.Generic_Type#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#ThisMenuItem#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</A>
					</cfcase>

					<cfcase value="2">		
						<A CLASS="tablink_back" HREF="settings_management.cfm?tabHeader=2&Generic_Type=#Form.Generic_Type#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#ThisMenuItem#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</A>
					</cfcase>
				</cfswitch>
				</B>
			</TD>
			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</CFOUTPUT>
			<!---- End ------>
			<CFSET C_Counter = C_Counter + 1>
		</CFLOOP>
		
		<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
</TABLE>
</CFOUTPUT>