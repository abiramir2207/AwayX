<CFQUERY NAME="getProgramTypes" datasource="#application.datasource#">
SELECT Created_Type, ProgramControl_Panel_Options_ID
FROM Program_Control_Panel_Options
WHERE Company_main_ID = '#request.AccessStructure.Company_main_ID#' and Deleted = 0 AND Active = 1
</CFQUERY>

<STYLE TYPE="text/css">
	.red
	{
		font-size:11px;
		width: 200px;
	}
</STYLE>

<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=10>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->
<title>Search Programs</title>
<FORM NAME="SearchForm">
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="10">

	<TABLE border="0" cellspacing="10" CELLPADDING="0">
		<TR>
			<TD><B><SPAN CLASS="title2">Program Type</SPAN></B><BR>
				<SELECT NAME="Program_Type">
					<OPTION VALUE="0">Any Type</OPTION>
					<cfoutput QUERY="getProgramTypes">
						<OPTION VALUE="#getProgramTypes.ProgramControl_Panel_Options_ID#">#getProgramTypes.Created_Type#</OPTION>
					</cfoutput>
				</SELECT>
			</TD>
			<TD><B><SPAN CLASS="title2">Program Title:</SPAN></B><BR>
				<INPUT type="text" name="contract_title" size="32" CLASS="red"></TD>
		</TR>
		<TR>
			<TD><B><SPAN CLASS="title2">Program Number:</SPAN></B><BR>
				<INPUT type="text" name="contract_number" size="32" CLASS="red"></TD>
			<TD><B><SPAN CLASS="title2">Broker(s):</SPAN></B><BR>
				<INPUT type="text" name="Broker" size="34" CLASS="red"></TD>
		</TR>
		<TR>
			<TD><B><SPAN CLASS="title2">Region:</SPAN></B><BR>
				<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
				SELECT *
				FROM Service_Regions
				WHERE len(Region_Name) > 0
				ORDER BY Region_Name
				</CFQUERY>
				<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
				<SELECT NAME="Region_ID" style="width: 190px;">
					<OPTION VALUE="0">**ALL** Regions</OPTION>
					<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#">#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
				</SELECT>	
			</TD>
			<TD><B><SPAN CLASS="title2">Zone:</SPAN></B><BR>
				<CFQUERY NAME="GetZones" datasource="#application.datasource#">
				SELECT *
				FROM Service_Zones
				WHERE len(Zone_Name) > 0
				ORDER BY Zone_Name
				</CFQUERY>
				<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
				<SELECT NAME="Zone_ID" style="width: 190px;">
					<OPTION VALUE="0">**ALL** Zones</OPTION>
					<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#">#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
				</SELECT>	
			</TD>
		</TR>
		<TR>
			<TD><B><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>(s):</SPAN></B><BR>
				<INPUT type="text" name="Distributor" size="34" CLASS="red"></TD>
			<TD><B><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Family:</SPAN></B><BR>
				<cfquery name="GetFamilyNames" datasource="#application.datasource#">
					SELECT *
					FROM Distributor_Family
					ORDER BY Family_Name
				</cfquery>
				<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
				<SELECT NAME="Family_Name" style="width: 200px;">
					<OPTION VALUE="0">**ALL** Family Names</OPTION>
					<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#">#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
				</SELECT>	
			</TD>
		</TR>
		<TR>
			<TD><B><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>(s):</SPAN></B><BR>
				<INPUT type="text" name="Operator" size="32" CLASS="red"></TD>
		
		</TR>
		<TR>
			<TD>
				<B><SPAN CLASS="title2">Program Status:</SPAN></B><BR>
				<FONT SIZE="2">
				<INPUT TYPE="radio" NAME="contract_status" VALUE="5">Active Programs<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="1" CHECKED>Work in Progress<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="2">Ready For Approval<BR>
				
				</FONT>
			</TD>
			<TD>
				<FONT SIZE="2"><BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="4">Preactive Programs<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="7">Archived/Expired<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="6">Expiring<BR>
				</FONT>
			</TD>
		</TR>

				</TABLE>
			</TD>
		</TR>
	</TABLE>
	<!--- <INPUT TYPE="button" VALUE="Search..." STYLE="width:100px;" ONCLICK="opener.transportFormElementsFromPopupToParentPage()"> --->
		<CF_button
			button_name		=	""
			button_caption	=	"search"
			button_action	=	"javascript: opener.transportFormElementsFromPopupToParentPage();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	"Click here to search the contracts database"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">	
<!--- <input TYPE="Hidden" NAME="template" VALUE="0"> --->
</FORM>
<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>	