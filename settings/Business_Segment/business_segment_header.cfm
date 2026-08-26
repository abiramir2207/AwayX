<!------business_segment_header.cfm----->

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
<CFSET PAGE_ACTIONS = "">
<cfset actionDisplay = "" />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Enable", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "dEnable", ",")>
<CFSET actionDisplay = ListAppend(actionDisplay, "Enable", ",")>


<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Active #appSettings.getbusiness_segment_label()#", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "dActiveBusinessSegment", ",")>
<cfif form.command eq "cBusinessSegment">
	<CFSET actionDisplay = ListAppend(actionDisplay, "Add", ",")>
<cfelseif form.command eq "eaBusinessSegment">
	<CFSET actionDisplay = ListAppend(actionDisplay, "Edit", ",")>
<cfelse>
	<CFSET actionDisplay = ListAppend(actionDisplay, "Active", ",")>
</cfif>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "InActive #appSettings.getbusiness_segment_label()#", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "dInActiveBusinessSegment", ",")>
<cfif form.command eq "eiBusinessSegment">
	<CFSET actionDisplay = ListAppend(actionDisplay, "Edit", ",")>
<cfelse>
	<CFSET actionDisplay = ListAppend(actionDisplay, "InActive", ",")>
</cfif>


<cfif appSettings.getClassCodesOn()>
<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Class Codes", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "dClassCodes", ",")>
<cfif form.command eq "eClassCodes">
	<CFSET actionDisplay = ListAppend(actionDisplay, "Edit", ",")>
<cfelse>
	<CFSET actionDisplay = ListAppend(actionDisplay, "Class Codes", ",")>
</cfif>
</cfif>

<cfif appSettings.getProgramBudgetOn()>
<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "Budget Percentage", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "eBudgetPercentage", ",")>
<cfif form.command eq "eBudgetPercentage">
	<CFSET actionDisplay = ListAppend(actionDisplay, "Edit Budget Percentage", ",")>
<cfelse>
	<CFSET actionDisplay = ListAppend(actionDisplay, "Budget Percentage", ",")>
</cfif>
</cfif>

<!---highlight tabs according to command--->
<cfif form.command eq "dEnable">
	<cfset PAGE_NAME = 1 />
<cfelseif ListFindNoCase("dActiveBusinessSegment,cBusinessSegment,eaBusinessSegment", form.command)>
	<cfset PAGE_NAME = 2 />
<cfelseif ListFindNoCase("dInActiveBusinessSegment,eiBusinessSegment", form.command)>
	<cfset PAGE_NAME = 3 />
<cfelseif ListFindNoCase("dClassCodes,eClassCodes", form.command)>
	<cfset PAGE_NAME = 4 />
<cfelseif ListFindNoCase("eBudgetPercentage", form.command)>
	<cfset PAGE_NAME = 5 />
</cfif>
<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET C_Counter = 1>
		<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
			<CFIF C_Counter EQ PAGE_NAME>
				<CFSET CLASS_NAME= "headerselected">
				<CFSET actionDisplay= ListGetAt(actionDisplay,C_Counter)>
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="180" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="" onClick="JavaScript: return submitForm('#ListGetAt(PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A>
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