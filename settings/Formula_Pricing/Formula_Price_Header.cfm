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
   cursor				: hand;	
  }
  TD.headerselected
  {
   border-left			: solid #TR_BORDER_WIDTH#px black;
   border-top			: solid #TR_BORDER_WIDTH#px black;
   border-right			: solid #TR_BORDER_WIDTH#px black;
   background-color 	: #TD_FORE_COLOR#;
   cursor				: hand;	
   TEXT-TRANSFORM		: uppercase;
  }

  TD.headerspacer
  {
   border-bottom		: solid #TR_BORDER_WIDTH#px black;
  }


</STYLE>
</CFOUTPUT>

<CFPARAM NAME="FORMULA_PAGE_NAME" 	DEFAULT=1>
<CFSET FORMULA_PAGE_TITLES = "">
<CFSET FORMULA_PAGE_URLS = "">

<CFSET FORMULA_PAGE_TITLES = ListAppend(FORMULA_PAGE_TITLES, "Pricing Rules", ",")>
<CFSET FORMULA_PAGE_URLS = ListAppend(FORMULA_PAGE_URLS, "index.cfm", ",")>


<CFSET FORMULA_PAGE_TITLES = ListAppend(FORMULA_PAGE_TITLES, "Inactive Rules", ",")>
<CFSET FORMULA_PAGE_URLS = ListAppend(FORMULA_PAGE_URLS, "index.cfm?active=false", ",")>

<CFSET FORMULA_PAGE_TITLES = ListAppend(FORMULA_PAGE_TITLES, "Add New", ",")>
<CFSET FORMULA_PAGE_URLS = ListAppend(FORMULA_PAGE_URLS, "Formula_Price_Step1.cfm", ",")>

<CFIF FORMULA_PAGE_NAME EQ 4>
	<CFSET FORMULA_PAGE_TITLES = ListAppend(FORMULA_PAGE_TITLES, "Programs", ",")>
	<CFSET FORMULA_PAGE_URLS = ListAppend(FORMULA_PAGE_URLS, "Formula_Price_Programs.cfm?RID=#URL.RID#", ",")>
</CFIF>

<CFIF FORMULA_PAGE_NAME EQ 5>
	<CFSET FORMULA_PAGE_TITLES = ListAppend(FORMULA_PAGE_TITLES, "Edit Rule", ",")>
	<CFSET FORMULA_PAGE_URLS = ListAppend(FORMULA_PAGE_URLS, "Formula_Price_Step1.cfm?RID=#URL.RID#", ",")>
	<CFSET FORMULA_PAGE_NAME = 4>
</CFIF>

<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET F_Counter = 1>
		<CFLOOP LIST="#FORMULA_PAGE_TITLES#" INDEX="ThisMenuItem">
			<CFIF F_Counter EQ FORMULA_PAGE_NAME>
				<CFSET CLASS_NAME= "headerselected">
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="120" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="#ListGetAt(FORMULA_PAGE_URLS, F_Counter, ",")#">#ThisMenuItem#</A></B></TD></A></B>
			</TD>
			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</CFOUTPUT>
			<!---- End ------>
			<CFSET F_Counter = F_Counter + 1>
		</CFLOOP>
		
		<TD CLASS="headerspacer" WIDTH=100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
</TABLE>