
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=19>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<STYLE>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
input,select, TEXTAREA
	{
		width:	240px;
		font-size: 12px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 12px;
	}
input.nostyle
	{
		width:	150px;
		width:	12px;
	}

</STYLE>

<BR><BR>



<DIV CLASS="title2">Search the Product's Database</DIV>
<HR COLOR="Orange">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type groups																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGetTypeGroupDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetTypeGroupDesc>
	<cftry>
		<cfset GetTypeGroupDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"deleted" = "eq.0",
				"select" = "type_group_desc"
			}), "type_group_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTypeGroupDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTypeGroupDesc>
<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Type_Group_Desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get QBrands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGetQBrands = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetQBrands>
	<cftry>
		<cfset GetQBrands = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"deleted" = "eq.0",
				"select" = "q_brand_desc"
			}), "q_brand_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetQBrands = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetQBrands>
<CFQUERY NAME="GetQBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Q_brand_desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type codes																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGetTypeCodeDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetTypeCodeDesc>
	<cftry>
		<cfset GetTypeCodeDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"deleted" = "eq.0",
				"select" = "type_code_desc"
			}), "type_code_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTypeCodeDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTypeCodeDesc>
<CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Type_Code_Desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get brands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGetBrands = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetBrands>
	<cftry>
		<cfset GetBrands = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"deleted" = "eq.0",
				"select" = "brand"
			}), "brand"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrands = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrands>
<CFQUERY NAME="GetBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Brand
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>
</cfif>




<FORM NAME="SearchForm">


		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<TD COLSPAN="100%" COLSPAN="2">
					<B>Search String:</B><BR>
					<INPUT TYPE="Text" NAME="searchstring" STYLE="width: 485px;">
					<BR>
				</TD>
			</TR>
			<TR>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL I</B><BR>
					<SELECT NAME="Type_Group_Desc">
						<OPTION VALUE="All">**ALL** Type Group Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeGroupDesc"><OPTION VALUE="#Type_Group_Desc#">#Type_Group_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL II</B><BR>
					<SELECT NAME="Q_Brand_Desc">
						<OPTION VALUE="All">**ALL** Q Brand Descriptions</OPTION>
						<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#Q_Brand_Desc#">#Q_Brand_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
			<TR>
			</TR>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL III</B><BR>
					<SELECT NAME="Type_Code_Desc">
						<OPTION VALUE="All">**ALL** Type Code Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#Type_Code_Desc#">#Type_Code_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL IV</B><BR>
					<SELECT NAME="Brand">
						<OPTION VALUE="All">**ALL** Brands</OPTION>
						<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#Brand#">#Brand#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="2">
					<BR>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="100%">
						<TR>
							<TD NOWRAP VALIGN="top" ALIGN="left">
								<B>Records per page</B><BR>
								<SELECT NAME="maxrows" STYLE="width:160px;">
									<OPTION VALUE="10">10</OPTION>
									<OPTION VALUE="25" SELECTED>25</OPTION>
									<OPTION VALUE="50">50</OPTION>
									<OPTION VALUE="100">100</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left" NOWRAP>
								<B>Sort records by</B><BR>
								<SELECT NAME="sortby" STYLE="width:160px;">
									<OPTION VALUE="Description">Product Description</OPTION>
									<OPTION VALUE="Type_Group_Desc">Type Group</OPTION>
									<OPTION VALUE="Q_Brand_Desc">Q Brand</OPTION>
									<OPTION VALUE="Type_Code_Desc">Type Code</OPTION>
									<OPTION VALUE="Brand">Brand</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left">
								<B>Order Selection</B><BR>
								<SELECT NAME="sortorder" STYLE="width:160px;">
									<OPTION VALUE="asc">Ascending</OPTION>
									<OPTION VALUE="desc">Descending</OPTION>
								</SELECT>	
							</TD>
						</TR>
					</TABLE>
					<BR>
					&nbsp;&nbsp;
					<CF_button
						button_name		=	""
						button_caption	=	"search"
						button_action	=	"javascript: opener.transportFormElementsFromPopupToParentPage();"
						button_type		=	"link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
					<!--- <INPUT TYPE="button" VALUE="Search..." STYLE="width:100px;" ONCLICK="opener.transportFormElementsFromPopupToParentPage()">				</TD> --->
			</TR>
			
			
		</TABLE>
</FORM>z
<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>
