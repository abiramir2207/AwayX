<!------header.cfm----->

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
<CFSET PAGE_URLS = "">

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "settings", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=Settings1", ",")>

<cfif request.AccessStructure.User_Rights_ID EQ 9999>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "internal settings", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=Settings2", ",")>

	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "approval settings", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=Settings3", ",")>
</cfif>
<!--- Dev Note: KAL; D21554: Single Sign on - LDAP; when SSO/LDAP is on turn off password settings --->
<cfif NOT Application.oApplicationAppSettingsManager.getApplicationAppSettings().LDAP_SSO_Enabled>
	<!--- Dev Note: KAL; 7916 --->
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "password settings", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=Settings4", ",")>
</cfif>

<!--- Dev Note: KAL; D19440: Approval Via Email: Only if the app setting is on --->
<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().ApprovalViaEmail>
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "approval via email", ",")>
	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=ApprovalViaEmail", ",")>
</cfif>

<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "report settings", ",")>
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=Settings5", ",")>

<!--- Dev Note: Generic Label Tool; CREATED MASS LABEL TOOL TO HANDLE ALL OF THESE LINKS Settings6 - Settings9 --->
<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "labels", ",") />
<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=LabelMaster", ",") />

<!--- Dev Notes: 21554/Anand Rao/30-Apr-10 HZ - Single sign on to application using LDAP --->  
<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().LDAP_SSO_Enabled
 OR	Application.oApplicationAppSettingsManager.getApplicationAppSettings().singlesign_on eq 2>
  	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "LDAP/SSO settings", ",") />
 	<CFSET PAGE_URLS = ListAppend(PAGE_URLS, "app_settings.cfm?command=LDAPSettings", ",") />
</cfif>
<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer">&nbsp;</TD>
		<CFSET F_Counter = 1>
		<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
			<CFSET ThisURL = ListGetAt(PAGE_URLS, F_Counter, ",")>
			<CFSET CLASS_NAME= "headernotselected">
			<CFIF ThisURL EQ "app_settings.cfm?command=#form.command#">
				<CFSET CLASS_NAME= "headerselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<A CLASS="tablink_back" HREF="#ThisURL#">
			<TD NOWRAP WIDTH="110" CLASS="#CLASS_NAME#" ALIGN="center">
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