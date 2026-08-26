<!------ header.cfm ----->

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
	
	<CFSET PAGE_TITLES = "">
	<CFSET PAGE_URLS = "">
	<CFSET PAGE_NAMES = "">
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "view", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=view", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "view", ",")>
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "analyst", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=analyst", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "analyst", ",")>

	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "assign market", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=market", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "market", ",")>
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "assign #LCase(application.returned_customer_setting.distributor_label_singular)#", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=distributor", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "distributor", ",")>
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "supervisor", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=supervisor", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "supervisor", ",")>

	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "assign supervisor", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=assign-supervisor", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "assign-supervisor", ",")>
		
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "director", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=director", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "director", ",")>

	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "assign director", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=assign-director", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "assign-director", ",")>
	<BR>
	<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
		<TR>
		 	<TD CLASS="headerspacer">&nbsp;</TD>
			<CFSET F_Counter = 1>
			<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
				<CFSET ThisURL = ListGetAt(PAGE_URLS, F_Counter, ",")>
				<CFSET ThisPageName = ListGetAt(PAGE_NAMES, F_Counter, ",")>
				<CFSET CLASS_NAME= "headernotselected">
				<CFIF ThisPageName EQ form.command>
					<CFSET CLASS_NAME= "headerselected">
				</CFIF>
				<!---- Start ------>
				<CFOUTPUT>
				<TD WIDTH="120" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
					<B><A CLASS="tablink_back" HREF="#ThisURL#">#ThisMenuItem#</A></B>
				</TD>
				<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
				</CFOUTPUT>
				<!---- End ------>
				<CFSET F_Counter = F_Counter + 1>
			</CFLOOP>
			
			<TD CLASS="headerspacer" WIDTH=100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		</TR>
	</TABLE>
