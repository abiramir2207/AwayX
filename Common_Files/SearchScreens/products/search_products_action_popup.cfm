<cfset useLakebaseForGetQBrands = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetQBrands>
	<cftry>
		<cfset GetQBrands = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"select" = "q_brand_desc"
			}), "q_brand_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetQBrands = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetQBrands>
<CFQUERY NAME="GetQBrands" datasource="#application.datasource#">
	SELECT DISTINCT Q_brand_desc
	FROM BSA_Foodservice_Items_Master
</CFQUERY>
</cfif>

<cfset useLakebaseForGetTypeCodeDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetTypeCodeDesc>
	<cftry>
		<cfset GetTypeCodeDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"select" = "type_code_desc"
			}), "type_code_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTypeCodeDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTypeCodeDesc>
<CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#">
	SELECT DISTINCT Type_Code_Desc
	FROM BSA_Foodservice_Items_Master
</CFQUERY>
</cfif>

<cfset useLakebaseForGetTypeGroupDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetTypeGroupDesc>
	<cftry>
		<cfset GetTypeGroupDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"select" = "type_group_desc"
			}), "type_group_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTypeGroupDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTypeGroupDesc>
<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#">
	SELECT DISTINCT Type_Group_Desc
	FROM BSA_Foodservice_Items_Master
</CFQUERY>
</cfif>

<cfset useLakebaseForGetBrands = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetBrands>
	<cftry>
		<cfset GetBrands = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"select" = "brand"
			}), "brand"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrands = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrands>
<CFQUERY NAME="GetBrands" datasource="#application.datasource#">
	SELECT DISTINCT Brand
	FROM BSA_Foodservice_Items_Master
</CFQUERY>
</cfif>


<CENTER>
<FIELDSET STYLE="padding:10px; width: 1%; border: 1px solid Orange;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">search products...</LEGEND>

<FORM NAME="SearchForm">
		<TABLE WIDTH="100%" CELLPADDING="10" CELLSPACING="25">
			<TR>
				<TD NOWRAP>
					<B>LEVEL I</B><BR>

					<SELECT NAME="typegroup_desc">
						<OPTION VALUE="0">**ALL** Type Group Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeGroupDesc"><OPTION VALUE="#trim(GetTypeGroupDesc.Type_Group_Desc)#">#trim(GetTypeGroupDesc.Type_Group_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>LEVEL II</B><BR>
					<SELECT NAME="Qbrand_desc">
						<OPTION VALUE="0">**ALL** Q Brand Descriptions</OPTION>
						<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#trim(GetQBrands.Q_brand_desc)#">#trim(GetQBrands.Q_brand_desc)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				</tr><tr>
				<TD NOWRAP>
					<B>LEVEL III</B><BR>
					<CFPARAM NAME="FORM.typecode_desc" DEFAULT="0">
					<SELECT NAME="typecode_desc">
						<OPTION VALUE="0">**ALL** Type Code Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#trim(GetTypeCodeDesc.Type_code_Desc)#">#trim(GetTypeCodeDesc.Type_code_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>LEVEL IV</B><BR>
					<CFPARAM NAME="FORM.brand" DEFAULT="0">
					<SELECT NAME="brand">
						<OPTION VALUE="0">**ALL** Brands</OPTION>
						<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#trim(GetBrands.brand)#">#trim(GetBrands.brand)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="2">
					Search String:
					<INPUT TYPE="Text" NAME="searchstring" SIZE="64">
					<br><br>
					<INPUT TYPE="image" NAME="Button" SRC="/images/search_button.gif"  ONCLICK="opener.transportFormElementsFromPopupToParentPage()">

					
					
				</TD>
			</TR>
		</TABLE>
</FORM>
</FIELDSET>
</CENTER>

<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>