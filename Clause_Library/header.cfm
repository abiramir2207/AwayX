<!------Formula_Price_Header.cfm----->

<CF_tabStyle
		selectedBgColor="##FFE083"
		borderWidth="2"
		>

<CFPARAM NAME="PAGE_NAME" 	DEFAULT=1>
<CFSET PAGE_TITLES = "">
<CFSET PAGE_URLS = "">
<CFSET PAGE_COMMAND = "">

<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is ON, show new clauses functionalty, else the old one --->
<cfif appSettings.getSimpleClause() eq 1>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "display", ",")>
<cfelse>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "search category", ",")>
</cfif>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=sClauseCategory", ",")>
<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "sClauseCategory", ",")>

<cfif form.command EQ "ceClauseCategory" AND (isDefined("form.id") OR isDefined("url.id"))>
<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is ON, show new clauses functionalty, else the old one --->
 <cfif appSettings.getSimpleClause() eq 1>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "edit", ",")>
 <cfelse>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "edit category", ",")>
 </cfif>
<cfelse>
<!--- Dev Note: Milan - 19623/25647. If "simple clauses" is ON, show new clauses functionalty, else the old one --->
 <cfif appSettings.getSimpleClause() eq 1>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "create", ",")>
 <cfelse>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "create category", ",")>
 </cfif>
</cfif>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=ceClauseCategory", ",")>
<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "ceClauseCategory", ",")>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "search", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "index.cfm?command=sClause", ",")>
<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "sClause", ",")>

<cfif form.command EQ "ceClause">
	<cfif (isDefined("form.id") OR isDefined("url.id"))>
		<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "edit clause", ",")>
	<cfelse>
		<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "create clause", ",")>
	</cfif>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "##", ",")>
	<CFSET PAGE_COMMAND = ListAppend(PAGE_COMMAND, "ceClause", ",")>
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
			<A CLASS="tablink_back" HREF="#ThisURL#">#ThisMenuItem#</A></B></TD></A></B>
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