<!------rebill_package_header.cfm----->

<cfset TR_BORDER_WIDTH = 2>
<cfset TD_FORE_COLOR = "FFE083">
<cfoutput>
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

<cfparam name="REBILL_PACKAGE_PAGE_NAME" 	default=1>
<cfset REBILL_PACKAGE_PAGE_TITLES = "">
<cfset REBILL_PACKAGE_PAGE_ACTIONS = "">

<cfset REBILL_PACKAGE_PAGE_TITLES = ListAppend(REBILL_PACKAGE_PAGE_TITLES, "Active", ",")>
<cfset REBILL_PACKAGE_PAGE_ACTIONS = ListAppend(REBILL_PACKAGE_PAGE_ACTIONS, "active", ",")>


<cfset REBILL_PACKAGE_PAGE_TITLES = ListAppend(REBILL_PACKAGE_PAGE_TITLES, "Inactive", ",")>
<cfset REBILL_PACKAGE_PAGE_ACTIONS = ListAppend(REBILL_PACKAGE_PAGE_ACTIONS, "inActive", ",")>

<cfset REBILL_PACKAGE_PAGE_TITLES = ListAppend(REBILL_PACKAGE_PAGE_TITLES, "Add New", ",")>
<cfset REBILL_PACKAGE_PAGE_ACTIONS = ListAppend(REBILL_PACKAGE_PAGE_ACTIONS, "add", ",")>

<cfset REBILL_PACKAGE_PAGE_TITLES = ListAppend(REBILL_PACKAGE_PAGE_TITLES, "Variable Size", ",")>
<cfset REBILL_PACKAGE_PAGE_ACTIONS = ListAppend(REBILL_PACKAGE_PAGE_ACTIONS, "varsize", ",")>
 
<cfset REBILL_PACKAGE_PAGE_TITLES = ListAppend(REBILL_PACKAGE_PAGE_TITLES, "Rebill Settings", ",")>
<cfset REBILL_PACKAGE_PAGE_ACTIONS = ListAppend(REBILL_PACKAGE_PAGE_ACTIONS, "rebillSettings", ",")>

<cfif FORM.display EQ "edit">
<cfset REBILL_PACKAGE_PAGE_TITLES = ListAppend(REBILL_PACKAGE_PAGE_TITLES, "Edit", ",")>
<cfset REBILL_PACKAGE_PAGE_ACTIONS = ListAppend(REBILL_PACKAGE_PAGE_ACTIONS, "edit", ",")>
</cfif>
  
 
<!---highlight tabs according to action--->
<cfif FORM.display EQ "inActive">
	<cfset REBILL_PACKAGE_PAGE_NAME = 2 />
<cfelseif FORM.display EQ "add">
	<cfset REBILL_PACKAGE_PAGE_NAME = 3 />
<cfelseif FORM.display EQ "varsize">
	<cfset REBILL_PACKAGE_PAGE_NAME = 4 />
<cfelseif FORM.display EQ "rebillSettings">
	<cfset REBILL_PACKAGE_PAGE_NAME = 5 />
<cfelseif FORM.display EQ "edit">
	<cfset REBILL_PACKAGE_PAGE_NAME = 6 /> 
  
</cfif>
 
<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
    
		<cfset C_Counter = 1>
		<cfloop LIST="#REBILL_PACKAGE_PAGE_TITLES#" INDEX="ThisMenuItem">
			<cfif C_Counter EQ REBILL_PACKAGE_PAGE_NAME>
				<cfset CLASS_NAME= "headerselected">
			<cfelse>
				<cfset CLASS_NAME= "headernotselected">
			</cfif>
			<!---- Start ------>
			<cfoutput>
			<TD WIDTH="120" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<a class="tablink_back" HREF="" onClick="JavaScript: return submitDataForm('#ListGetAt(REBILL_PACKAGE_PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A>
			</B>
			</td>
			</B>
			</td>
			<td CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</cfoutput>
			<!---- End ------>
			<cfset C_Counter = C_Counter + 1>
		</cfloop>
		
		
		<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		<td CLASS="headerspacer" nowrap>
	&nbsp; 
		</td>
	</TR>
</TABLE>

