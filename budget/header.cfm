<!---      
	Name:          	header.cfm
	Copyright:     	Copyright (c) 2006 Blacksmith Applications, Inc.       
	Created Date:  	05/08/2006
	Created By:    	Deepa Kunnath
	Description:   	This page will contain the top menu
	Parameters:    	command - keyword for the current action
	Usage:         	command=addEditBudgetGroup
--->
<!------Formula_Price_Header.cfm----->

<CF_tabStyle
		selectedBgColor="##FFE083"
		borderWidth="2"
		>

<CFPARAM NAME="PAGE_NAME" 	DEFAULT=1>
<CFSET PAGE_TITLES = "">
<CFSET PAGE_URLS = "">
<CFSET PAGE_COMMAND = "">

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "budgets", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=listActiveBudgetGroup", ",")>
<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "listActiveBudgetGroup", ",")>


<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "inactive", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=listInActiveBudgetGroup", ",")>
<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "listInActiveBudgetGroup", ",")>

<cfif form.command EQ "addEditBudgetGroup" AND form.id neq 0>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "edit group", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=addEditBudgetGroup&id=#form.id#", ",")>
<cfelse>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "add new group", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=addEditBudgetGroup", ",")>
</cfif>
<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "addEditBudgetGroup", ",")>

<cfif form.command EQ "createBudget">
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "create budget", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=createBudget&id=#form.id#", ",")>
	<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "createBudget", ",")>
</cfif>
<cfif form.command EQ "editTradeBudget">
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "edit trade budget", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=editTradeBudget&id=#form.id#", ",")>
	<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "editTradeBudget", ",")>
</cfif>
<cfif form.command EQ "editVolumeBudget">
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "edit volume budget", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=editVolumeBudget&id=#form.id#", ",")>
	<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "editVolumeBudget", ",")>
</cfif>

<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET F_Counter = 1>
		<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
			<CFSET ThisURL = ListGetAt(PAGE_URLS, F_Counter, ",")>
			<CFSET ThisCommand = ListGetAt(PAGE_COMMAND, F_Counter, ",")>
			<CFSET CLASS_NAME= "headernotselected">
			<CFIF ThisCommand EQ form.command>
				<CFSET CLASS_NAME= "headerselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<A CLASS="tablink_back" HREF="#ThisURL#">
			<TD WIDTH="120" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>			
			<A CLASS="tablink_back" HREF="#ThisURL#"><NOBR>#ThisMenuItem#</NOBR></A></B></TD></A></B>
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