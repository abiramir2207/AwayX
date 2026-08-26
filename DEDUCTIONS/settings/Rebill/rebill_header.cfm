<!------_rebate_component_header.cfm----->

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

<CFPARAM NAME="COMPONENT_PAGE_NAME" 	DEFAULT=1>
<CFSET COMPONENT_PAGE_TITLES = "">
<CFSET COMPONENT_PAGE_ACTIONS = "">

<CFSET COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Active", ",")>
<CFSET COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "active", ",")>


<CFSET COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Inactive", ",")>
<CFSET COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "inActive", ",")>

<CFSET COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Add New", ",")>
<CFSET COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "add", ",")>

<!---highlight tabs according to action--->
<cfif form.display eq "inActive">
	<cfset COMPONENT_PAGE_NAME = 2 />
<cfelseif form.display eq "add">
	<cfset COMPONENT_PAGE_NAME = 3 />
<cfelseif form.display eq "edit">
	<cfset COMPONENT_PAGE_NAME = 4 />
</cfif>
<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET C_Counter = 1>
		<CFLOOP LIST="#COMPONENT_PAGE_TITLES#" INDEX="ThisMenuItem">

			<CFIF C_Counter EQ COMPONENT_PAGE_NAME>
				<CFSET CLASS_NAME= "headerselected">
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="120" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="" onClick="JavaScript: return submitDataForm('#ListGetAt(COMPONENT_PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A>
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