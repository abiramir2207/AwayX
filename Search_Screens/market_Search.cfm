<!------ market_Search.cfm ----->
<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Search - Market</TITLE>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFSET thisPage = CGI.SCRIPT_NAME>
<CFPARAM NAME="FORM.state" 	DEFAULT="0">
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.Service_Market_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="URL.importType" 	DEFAULT="multiple">
<CFPARAM NAME="FORM.importType" 	DEFAULT="#URL.importType#">
<CF_Popup_Search
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.Service_Market_ID#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			importType="#FORM.importType#">

<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=12>			


<CFPARAM NAME="FORM.Zone_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Region_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.Market_Name" 	DEFAULT="">
<cfparam name="form.StateCode" 	default="">
<cfparam name="form.County" 	default="">
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<STYLE>
	.LONGINPUT
	{
		width: 360px;
	}
	.SHORTINPUT
	{
		width: 180px;
	}
	SELECT
	{
		width: 180px;
	}
</STYLE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of states from the States table.
Don't use the list from the Zipcodes table since the list also includes military installation --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_States = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("zipcodes")>
<cfif useLakebaseForGet_States>
	<cftry>
		<cfset Get_States = application.oLakebase.toQuery(
			application.oLakebase.selectRows("zipcodes", {
				"order" = "state.asc",
				"select" = "statecode,state"
			}), "statecode,state"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_States = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_States>
<CFQUERY NAME="Get_States" DATASOURCE="#application.datasource#" cachedWithin = "#CreateTimeSpan(30, 0, 0, 0)#">
	Select		DISTINCT StateCode, State
	From		zipCodes
	Order by 	State
</CFQUERY>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<FORM ACTION="#thisPage#" METHOD="post" name="frmMarkets">
	
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">market search</LEGEND>
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" BGCOLOR="WhiteSmoke">
		<TR VALIGN="TOP">
		<TD>
			<B><CFOUTPUT>#application.returned_customer_setting.zone_label_plural#</CFOUTPUT></B><BR>
			<CFQUERY NAME="GetZones" datasource="#application.datasource#">
			SELECT *
			FROM Service_Zones
			WHERE len(Zone_Name) > 0 AND Deleted = 0
			ORDER BY Zone_Name
			</CFQUERY>
			<SELECT NAME="Zone_ID">
				<OPTION VALUE="">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION>
				<CFLOOP QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFLOOP>
			</SELECT>	
		</TD>
		<TD>
			<B><CFOUTPUT>#application.returned_customer_setting.region_label_singular#</CFOUTPUT></B><BR>
			<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
			SELECT *
			FROM Service_Regions
			WHERE len(Region_Name) > 0 AND Deleted = 0
			ORDER BY Region_Name
			</CFQUERY>
			<SELECT NAME="Region_ID">
				<OPTION VALUE="">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION>
				<CFLOOP QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFLOOP>
			</SELECT>	
		</TD>
		<TD>
			<B>State</B><BR>
			<SELECT NAME="StateCode">
				<OPTION VALUE="">Select the state...</OPTION>
				<CFLOOP QUERY="Get_States">
				<OPTION VALUE="#statecode#" <CFIF form.StateCode EQ statecode> SELECTED</CFIF>>#state#</OPTION>
				</CFLOOP>
			</SELECT>
		</TD>
			<TD COLSPAN="2">
			<B>County</B><BR>
			<INPUT TYPE="TEXT" CLASS="SHORTINPUT" NAME="County" VALUE="#Form.County#">
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2">
			<B>Market Name</B><BR>
			<INPUT TYPE="TEXT" CLASS="LONGINPUT" NAME="Market_Name" VALUE="#Form.Market_Name#">
			</TD>
			<TD VALIGN="bottom"><FONT COLOR="##ff0000">&nbsp;&nbsp;&nbsp;<B>[</B></FONT><A HREF="javascript: reset_Form_Fields(document.frmMarkets);"><B>reset</B></A><FONT COLOR="ff0000"><B>]</B></FONT> </TD>
			<TD COLSPAN="2" VALIGN="bottom">
			&nbsp;&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="document.frmMarkets.startrow.value=1;document.frmMarkets.frompage.value=1;document.frmMarkets.submit();return false;">search market</a><FONT COLOR="FF0000">]</FONT></B>
			</TD>
		</TR>
	</TABLE>
</FIELDSET>

	<!------ popup search code ----->
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="state" TYPE="hidden" value="1">
	<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#FORM.importType#">
	
	<CFIF FORM.state EQ 1>
		<CFQUERY NAME="GetMarkets" datasource="#application.datasource#">
			SELECT 	DISTINCT Service_Markets.Service_Market_ID, Service_Markets.Market_Name, Service_Regions.Region_Name, Service_Zones.Zone_Name
			FROM 	Service_Markets
					INNER JOIN Service_Regions
					ON
					Service_Regions.Deleted = 0
					AND
					Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
					<CFIF FORM.Region_ID NEQ "">
					AND Service_Regions.Service_Region_ID = '#FORM.Region_ID#'
					</CFIF>					
					INNER JOIN Service_Zones
					ON
					Service_Zones.Deleted = 0
					AND
					Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
					<CFIF FORM.Zone_ID NEQ "">
					AND
					Service_Zones.Service_Zone_ID = '#FORM.Zone_ID#'					
					</CFIF>
					<CFIF form.StateCode NEQ "" OR form.County NEQ "">
					INNER JOIN Market_ZipCode
					ON
					Market_ZipCode.Service_Market_ID = Service_Markets.Service_Market_ID
					AND
					Market_ZipCode.Deleted = 0
					INNER JOIN ZipCodes
					ON
					Market_ZipCode.ZipCode = ZipCodes.ZIPCode
					AND
					Market_ZipCode.Deleted = 0
						<CFIF form.StateCode NEQ "">
							and
							ZipCodes.StateCode	=	'#form.StateCode#'
						</CFIF>						
						<CFIF form.county NEQ "">
							and	
							ZipCodes.county		like	'%#form.county#%'
						</CFIF>	
					</CFIF>				
			WHERE 	
					len(Service_Markets.Market_Name) > 0 
					AND Service_Markets.Deleted = 0
					<CFIF FORM.Market_Name NEQ "">
					AND Service_Markets.Market_Name LIKE '%#FORM.Market_Name#%'
					</CFIF>
			ORDER BY Service_Markets.Market_Name
		</CFQUERY>
		<CFIF GetMarkets.RecordCount GT 0>
		<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF GetMarkets.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#GetMarkets.recordcount#</CFOUTPUT> <CFIF GetMarkets.recordcount EQ 1>market<CFELSE>markets</CFIF> That <CFIF GetMarkets.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="90%" CLASS="MainTable">
		<TR BGCOLOR="##ffce84">
			<TD>
			<CFIF FORM.importType NEQ "single">
			<INPUT TYPE="checkbox" VALUE="" onClick="javaScript: CHSelectAll('Service_Market_ID', this.checked);">			
			<CFELSE>&nbsp;</CFIF>
			</TD>
			<TD ID="Header"><B>Market</B></TD>
			<TD ID="Header"><B>Region</B></TD>
			<TD ID="Header"><B>Zone</B></TD>
		</TR>
		
		
		<CFSET AlreadySelectedItems = "">
		<CFLOOP QUERY="GetMarkets" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
		<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
			<TD>
			<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" NAME="Service_Market_ID" VALUE="#Service_Market_ID#"
			<CFIF listfind(FORM.FinalItemList, Service_Market_ID) NEQ 0>CHECKED
				<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, Service_Market_ID, ",")>
			</CFIF>
			></TD>
			<TD>#Market_Name#</TD>
			<TD>#Region_Name#</TD>
			<TD>#Zone_Name#	</TD>
		</TR>
		</CFLOOP>
		</TABLE>
	</FIELDSET>
	<DIV STYLE="font-size: 12px; color: Red;">
		<CF_Next_Previous_For_Forms
		formname="frmMarkets"
		query="GetMarkets"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: finishedSearching(document.frmMarkets)"> import selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<CFELSE>
		<BR><BR><SPAN CLASS="Title2">No record found</SPAN>
	</CFIF>
	</CFIF>
	<script language="JavaScript">
		function finishedSearching(searchForm)
		{
			searchForm.FinisedSearching.value = 1;
			searchForm.submit();			
		}
		function reset_Form_Fields(searchForm)
		{
			searchForm.reset();
		}
	</script>
	
</FORM>
			
</BODY>
</HTML>
</CFOUTPUT>