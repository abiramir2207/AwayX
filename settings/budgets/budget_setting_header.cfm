<!------ budget_setting_header.cfm ----->
<CFSET TR_BORDER_WIDTH = 2>
<CFSET TD_FORE_COLOR = "FFE083">

<CF_tabStyle
		selectedBgColor="##FFE083"
		borderWidth="2"
		>


<CFSET PAGE_TITLES = "">
<CFSET PAGE_ACTIONS = "">
<cfset PAGE_TOKENS = "" />

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "class", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "listBudgetClass", ",")>
<CFSET PAGE_TOKENS = ListAppend(PAGE_TOKENS, "BudgetClass", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "budget", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "listBudget", ",")>
<CFSET PAGE_TOKENS = ListAppend(PAGE_TOKENS, "Budget", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "class budget association", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "listActiveBudgetClassAssociation", ",")>
<CFSET PAGE_TOKENS = ListAppend(PAGE_TOKENS, "BudgetClassAssociation", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "budget labels", ",")>
<CFSET PAGE_ACTIONS = ListAppend(PAGE_ACTIONS, "listBudgetLabel", ",")>
<CFSET PAGE_TOKENS = ListAppend(PAGE_TOKENS, "BudgetLabel", ",")>

<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="90%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET F_Counter = 1>
		<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
			<cfset ThisAction = ListGetAt(PAGE_ACTIONS, F_Counter) />
			<cfset ThisPageToken = ListGetAt(PAGE_TOKENS, F_Counter) />

			<CFSET CLASS_NAME= "headernotselected">
			<CFIF Right(form.command, Len(ThisPageToken)) EQ ThisPageToken>
				<CFSET CLASS_NAME= "headerselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="180" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP onClick="JavaScript: return submitForm('#ThisAction#', 0);">
			<B>#ThisMenuItem#</A></B>
			</TD>
			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</CFOUTPUT>
			<!---- End ------>
			<CFSET F_Counter = F_Counter + 1>
		</CFLOOP>
		
		<TD CLASS="headerspacer" WIDTH=100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
</TABLE>