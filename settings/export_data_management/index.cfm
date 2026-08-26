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

<CFPARAM NAME="ACTION" 	DEFAULT="AddCost">

<CFSET EXPORT_PAGE_TITLES = "">
<CFSET EXPORT_PAGE_ACTIONS = "">

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Cost", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddCost", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Country", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddCountry", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Stickering", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddStickering", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "TOS", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddTermsOfSale", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Pallet", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddPalletType", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Port", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddPort", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Origin", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddOrigin", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Relocation", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddRelocation", ",")>

<CFSET EXPORT_PAGE_TITLES = ListAppend(EXPORT_PAGE_TITLES, "Freight", ",")>
<CFSET EXPORT_PAGE_ACTIONS = ListAppend(EXPORT_PAGE_ACTIONS, "AddFreight", ",")>


<BR>
<TABLE border="0" cellspacing="0" cellpadding="1" WIDTH="100%">
	<TR>
	 	<TD CLASS="headerspacer"></TD>
		<CFSET C_Counter = 1>
		<CFLOOP LIST="#EXPORT_PAGE_TITLES#" INDEX="ThisMenuItem">

			<CFIF Action EQ ListGetAt(EXPORT_PAGE_ACTIONS,C_Counter)>
				<CFSET CLASS_NAME= "headerselected">
			<CFELSE>
				<CFSET CLASS_NAME= "headernotselected">
			</CFIF>
			<!---- Start ------>
			<CFOUTPUT>
			<TD WIDTH="85" CLASS="#CLASS_NAME#" ALIGN="center" NOWRAP>
			<B>
			<A CLASS="tablink_back" HREF="index.cfm?Action=#ListGetAt(EXPORT_PAGE_ACTIONS,C_Counter)#">#ThisMenuItem#</A>
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

<CFSWITCH expression="#ACTION#">
	<CFCASE value="AddCost">
		<cfinclude template ="Export_Lookup_Costs.cfm">
	</CFCASE>
	<CFCASE value="AddCountry">
		<cfinclude template ="Export_Lookup_Destination_Country.cfm">
	</CFCASE>	
	<CFCASE value="AddStickering">
		<cfinclude template ="Export_Lookup_Stickering_Cost.cfm">
	</CFCASE>
	<CFCASE value="AddTermsOfSale">
		<cfinclude template ="Export_Lookup_Terms_of_Sale.cfm">
	</CFCASE>	
	<CFCASE value="AddPalletType">
		<cfinclude template ="Export_Lookup_Pallet_Type.cfm">
	</CFCASE>	
	<CFCASE value="AddPort">
		<cfinclude template ="Export_Lookup_Destination_Ports.cfm">
	</CFCASE>
	<CFCASE value="AddOrigin">
		<cfinclude template ="Export_Lookup_Origin.cfm">
	</CFCASE>
	<CFCASE value="AddRelocation">
		<cfinclude template ="Export_Lookup_Origin_Relocation.cfm">
	</CFCASE>
	<CFCASE value="AddFreight">
		<cfinclude template ="Export_Lookup_Freight.cfm">
	</CFCASE>
</CFSWITCH>