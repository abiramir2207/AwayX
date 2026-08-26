<!------Formula_Price_Header.cfm----->

<CFSET TR_BORDER_WIDTH = 2>
<CFSET TD_FORE_COLOR = "FFE083">
<CFOUTPUT>
<STYLE TYPE="text/css">
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	
	
	
	TD.headernotselected
  {
   background-color 	: dddddd;
   border-bottom		: solid #TR_BORDER_WIDTH#px black;
   cursor				: pointer;	
  }
  TD.headerselected
  {
   border-left			: solid #TR_BORDER_WIDTH#px black;
   border-top			: solid #TR_BORDER_WIDTH#px black;
   border-right			: solid #TR_BORDER_WIDTH#px black;
   background-color 	: #TD_FORE_COLOR#;
   cursor				: pointer;	
   TEXT-TRANSFORM		: uppercase;
  }

  TD.headerspacer
  {
   border-bottom		: solid #TR_BORDER_WIDTH#px black;
  }


</STYLE>
</CFOUTPUT>

<CFPARAM NAME="PAGE_NAME" 	DEFAULT=1>
<CFSET PAGE_TITLES = "">
<CFSET PAGE_URLS = "">

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Postal Codes", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?mode=1", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Position", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?mode=2", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Category", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?mode=3", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Priority", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?mode=4", ",")>

<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET F_Counter = 1>
		<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
			<CFIF F_Counter EQ PAGE_NAME>
				<CFSET CLASS_NAME= "headerselected">
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<A CLASS="tablink_back" HREF="#ListGetAt(PAGE_URLS, F_Counter, ",")#">
			<TD WIDTH="120" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="#ListGetAt(PAGE_URLS, F_Counter, ",")#">#ThisMenuItem#</A></B></TD></A></B>
			</TD>
			</A>
			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</CFOUTPUT>
			<!---- End ------>
			<CFSET F_Counter = F_Counter + 1>
		</CFLOOP>
		
		<TD CLASS="headerspacer" WIDTH=100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
</TABLE>