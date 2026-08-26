<!------ operating_group_header.cfm ----->

<CFSET TR_BORDER_WIDTH = 2>
<CFSET TD_FORE_COLOR = "FFE083">

<CF_tabStyle
		selectedBgColor="##FFE083"
		borderWidth="2"
		>


<CFSET PAGE_TITLES = "">
<CFSET PAGE_ACTIONS = "">
<cfset actionDisplay = "" />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "", ",")>
<CFSET actionDisplay = ListAppend(actionDisplay, "", ",")>

<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET C_Counter = 1>
		<cfloop query="operatingGroupLabels">
			<CFIF Operating_Group_Level_ID EQ form.level>
				<CFSET CLASS_NAME= "headerselected">
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="180" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="" onClick="JavaScript: return submitForm('#Operating_Group_Level_ID#', 'displayList', 0);">#Operating_Group_Level_Desc#</A>
			</B>
			</TD>
			</B>
			</TD>
			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</CFOUTPUT>
			<!---- End ------>
			<CFSET C_Counter = C_Counter + 1>
		</cfloop>
		
		<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
</TABLE>