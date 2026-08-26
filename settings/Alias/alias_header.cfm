<!------alias_header.cfm----->

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

<CFPARAM NAME="ALIAS_PAGE_NAME" DEFAULT=1>
<CFSET ALIAS_PAGE_TITLES = "">
<CFSET ALIAS_PAGE_ACTIONS = "">

<CFSET ALIAS_PAGE_TITLES = ListAppend(ALIAS_PAGE_TITLES, "Search", ",")>
<CFSET ALIAS_PAGE_ACTIONS = ListAppend(ALIAS_PAGE_ACTIONS, "Search", ",")>

<CFSET ALIAS_PAGE_TITLES = ListAppend(ALIAS_PAGE_TITLES, "Add/Edit", ",")>
<CFSET ALIAS_PAGE_ACTIONS = ListAppend(ALIAS_PAGE_ACTIONS, "Add_Edit", ",")>

<CFSET ALIAS_PAGE_TITLES = ListAppend(ALIAS_PAGE_TITLES, "Create File", ",")>
<CFSET ALIAS_PAGE_ACTIONS = ListAppend(ALIAS_PAGE_ACTIONS, "CreateFile", ",")>

<CFSET ALIAS_PAGE_TITLES = ListAppend(ALIAS_PAGE_TITLES, "Upload File", ",")>
<CFSET ALIAS_PAGE_ACTIONS = ListAppend(ALIAS_PAGE_ACTIONS, "UploadFile", ",")>

<CFSET ALIAS_PAGE_TITLES = ListAppend(ALIAS_PAGE_TITLES, "Ranking", ",")>
<CFSET ALIAS_PAGE_ACTIONS = ListAppend(ALIAS_PAGE_ACTIONS, "Ranking", ",")>

<CFSET ALIAS_PAGE_TITLES = ListAppend(ALIAS_PAGE_TITLES, "Upload History", ",")>
<CFSET ALIAS_PAGE_ACTIONS = ListAppend(ALIAS_PAGE_ACTIONS, "UploadHistory", ",")>


<!---highlight tabs according to action (Default "display" value is "search" --->
<cfif form.display eq "Add_Edit">
	<cfset ALIAS_PAGE_NAME = 2 />
<cfelseif form.display eq "CreateFile">
	<cfset ALIAS_PAGE_NAME = 3 />
<cfelseif form.display eq "UploadFile">
	<cfset ALIAS_PAGE_NAME = 4 />
<cfelseif form.display eq "Ranking">
	<cfset ALIAS_PAGE_NAME = 5 />
<cfelseif form.display eq "UploadHistory">
	<cfset ALIAS_PAGE_NAME = 6 />
</cfif>
<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET C_Counter = 1>
		<CFLOOP LIST="#ALIAS_PAGE_TITLES#" INDEX="ThisMenuItem">

			<CFIF C_Counter EQ ALIAS_PAGE_NAME>
				<CFSET CLASS_NAME= "headerselected">
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="110" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="" onClick="JavaScript: return submitDataFormDisplay('#ListGetAt(ALIAS_PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A>
			</B>
			</TD>
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
