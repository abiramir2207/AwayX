<CFSET PAGE_TITLE="Product Blaster! - Select Products">
<CFSET GROUP="Contracts">

<CFPARAM NAME="FORM.Contract_Main_ID" DEFAULT="">


<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedUPCS" DEFAULT="">
<CFPARAM NAME="FORM.FinalUPCList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingproducts" DEFAULT="0">

	<CFSET listofitemstodelete = "">

	<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
		<CFIF listfind(FORM.SelectedUPCS, ListItem, ",") EQ 0>
			<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>

		</CFIF>
	</CFLOOP>
	

	<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedUPCS#" DELIMITERS=",">
		<CFIF listfind(Form.FinalUPCList, ListItem, ",") EQ 0>
			<CFSET Form.FinalUPCList = listappend(FinalUPCList, ListItem, ",")>

		</CFIF>
	</CFLOOP>


	<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
		<CFSET Form.FinalUPCList = listdeleteat(FORM.FinalUPCList, listfind(FORM.FinalUPCList,ListItem, ","), ",")>
	</CFLOOP>



<CFIF FORM.finishedselectingproducts EQ 1>
<FORM ACTION="select_contracts.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<INPUT TYPE="hidden" NAME="UPC_List" VALUE="<CFOUTPUT>#FORM.FINALUPCLIST#</CFOUTPUT>">
</FORM>
<SCRIPT>document.all.MyForm.submit()</SCRIPT>
<CFABORT>
</CFIF>



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



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">



<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BLOCKQUOTE><BLOCKQUOTE>


	<FORM ACTION="select_products.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">product search</LEGEND>
		<TABLE WIDTH="100%">
			<TR>
				<TD NOWRAP>
					<B>LEVEL I</B><BR>
					<CFPARAM NAME="FORM.typegroup_desc" DEFAULT="0">
					<SELECT NAME="typegroup_desc">
						<OPTION VALUE="0">**ALL** Type Group Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeGroupDesc"><OPTION VALUE="#trim(GetTypeGroupDesc.Type_Group_Desc)#"#IIF(trim(FORM.typegroup_desc) EQ trim(GetTypeGroupDesc.Type_Group_Desc), DE(" SELECTED"), DE(""))#>#trim(GetTypeGroupDesc.Type_Group_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>LEVEL II</B><BR>
					<CFPARAM NAME="FORM.Qbrand_desc" DEFAULT="0">
					<SELECT NAME="Qbrand_desc">
						<OPTION VALUE="0">**ALL** Q Brand Descriptions</OPTION>
						<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#trim(GetQBrands.Q_brand_desc)#"#IIF(trim(FORM.Qbrand_desc) EQ trim(GetQBrands.Q_brand_desc), DE(" SELECTED"), DE(""))#>#trim(GetQBrands.Q_brand_desc)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>LEVEL III</B><BR>
					<CFPARAM NAME="FORM.typecode_desc" DEFAULT="0">
					<SELECT NAME="typecode_desc">
						<OPTION VALUE="0">**ALL** Type Code Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#trim(GetTypeCodeDesc.Type_code_Desc)#"#IIF(trim(FORM.typecode_desc) EQ trim(GetTypeCodeDesc.Type_code_Desc), DE(" SELECTED"), DE(""))#>#trim(GetTypeCodeDesc.Type_code_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>LEVEL IV</B><BR>
					<CFPARAM NAME="FORM.brand" DEFAULT="0">
					<SELECT NAME="brand">
						<OPTION VALUE="0">**ALL** Brands</OPTION>
						<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#trim(GetBrands.brand)#"#IIF(trim(FORM.brand) EQ trim(GetBrands.brand), DE(" SELECTED"), DE(""))#>#trim(GetBrands.brand)#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="100%">
					Search String: <INPUT TYPE="Text" NAME="searchstring" SIZE="64"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>>&nbsp;<INPUT TYPE="Submit" VALUE="search">
				</TD>
			</TR>
		</TABLE>
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>

<!--- 	<hr color="orange">
		<cfoutput>
		<p>
			SELECT *
			FROM BSA_Foodservice_Items_Master
			WHERE UPC IN(#ListQualify(FORM.FinalUPCList, "'", ",", "ALL")#<CFIF len(FORM.FinalUPCList) EQ 0>'0'</CFIF>)		
		</p>
		</cfoutput>
	<hr color="orange">
	<cfabort> --->

	<CFQUERY NAME="GetCurrentProducts" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Items_Master
		WHERE UPC IN(#ListQualify(FORM.FinalUPCList, "'", ",", "ALL")#<CFIF len(FORM.FinalUPCList) EQ 0>'0'</CFIF>)
	</CFQUERY>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected products</LEGEND>
		<CFIF GetCurrentProducts.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="2"  WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left">UPC Code</TD></cfif></cfif>
					<TD align="left">Item #</TD>
					<TD align="left">Description</TD>
					<!--- <TD align="left">QBrand</TD> --->
					<TD align="left">Type Code Description</TD>
					<!--- <TD align="left">Type Group Description</TD> --->
					<TD align="left">Brand</TD>
			</TR>
			<CFOUTPUT QUERY="GetCurrentProducts">
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#GetCurrentProducts.UPC#</TD></cfif></cfif>
					<TD NOWRAP>#GetCurrentProducts.ITEM#</TD>
					<TD NOWRAP>#GetCurrentProducts.Description#</TD>
					<!--- <TD NOWRAP>#GetCurrentProducts.Q_Brand_Desc#</TD> --->
					<TD NOWRAP>#GetCurrentProducts.Type_Code_Desc#</TD>
					<!--- <TD NOWRAP>#GetCurrentProducts.Type_Group_Desc#</TD> --->
					<TD NOWRAP>#GetCurrentProducts.Brand#</TD>

 				</TR>
			<CFFLUSH>
			</CFOUTPUT>
			</TABLE>
			<CFELSE>
				NONE
			</CFIF>
			
	</FIELDSET>

<BR>
<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"javascript: document.all.finishedselectingproducts.value = 1; MyForm.submit();"
				button_type		=	"link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>	
		</TD>
	</TR>
</TABLE>
<CFIF isdefined("FORM.DOSEARCH")>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Items_Master
		WHERE
			0 = 0
		<CFIF FORM.Qbrand_desc NEQ 0>
			AND
			Q_Brand_Desc = '#FORM.Qbrand_desc#'
		</CFIF>

		<CFIF FORM.typecode_desc NEQ 0>
			AND
			Type_Code_Desc = '#FORM.typecode_desc#'
		</CFIF>

		<CFIF FORM.typegroup_desc NEQ 0>
			AND
			Type_Group_Desc = '#FORM.typegroup_desc#'
		</CFIF>

		<CFIF FORM.brand NEQ 0>
			AND
			brand = '#FORM.brand#'
		</CFIF>
<!--- 
		<CFIF FORM.Qbrand_desc NEQ 0>
			AND
			Q_Brand_Desc = '#FORM.Q_Brand_Desc#'
		</CFIF>
 --->
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
		
			(
				Item = '#form.searchstring#'
				OR
				Item LIKE '%#form.searchstring#'
				OR
				Item LIKE '#form.searchstring#%'
				OR
				Item LIKE '%#form.searchstring#%'
			)
			OR
			(
				UPC = '#form.searchstring#'
				OR
				UPC LIKE '%#form.searchstring#'
				OR
				UPC LIKE '#form.searchstring#%'
				OR
				UPC LIKE '%#form.searchstring#%'
			)
			<CFIF isnumeric(#form.searchstring#)>
			OR
			(
				Case_Count = '#form.searchstring#'
				OR
				Case_Count LIKE '%#form.searchstring#'
				OR
				Case_Count LIKE '#form.searchstring#%'
				OR
				Case_Count LIKE '%#form.searchstring#%'
			)
			OR
			(
				Pack_Size = '#form.searchstring#'
				OR
				Pack_Size LIKE '%#form.searchstring#'
				OR
				Pack_Size LIKE '#form.searchstring#%'
				OR
				Pack_Size LIKE '%#form.searchstring#%'
			)
			</CFIF>
			OR
			(
				Description = '#form.searchstring#'
				OR
				Description LIKE '%#form.searchstring#'
				OR
				Description LIKE '#form.searchstring#%'
				OR
				Description LIKE '%#form.searchstring#%'
			)
			OR
			(
				Brand = '#form.searchstring#'
				OR
				Brand LIKE '%#form.searchstring#'
				OR
				Brand LIKE '#form.searchstring#%'
				OR
				Brand LIKE '%#form.searchstring#%'
			)
			OR
			(
				Type_Code_Desc = '#form.searchstring#'
				OR
				Type_Code_Desc LIKE '%#form.searchstring#'
				OR
				Type_Code_Desc LIKE '#form.searchstring#%'
				OR
				Type_Code_Desc LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
	</CFQUERY>
<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many products in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</SCRIPT>	

	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Product<CFELSE>Products</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="2" WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products"></TD>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left">UPC Code</TD></cfif></cfif>
					<TD align="left">Item #</TD>
					<TD align="left">Description</TD>
					<!--- <TD align="left">QBrand</TD> --->
					<TD align="left">Type Code Description</TD>
					<!--- <TD align="left">Type Group Description</TD> --->
					<TD align="left">Brand</TD>
			<CFOUTPUT QUERY="TheQuery">
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center"><INPUT type="Checkbox" NAME="SelectedUPCS" VALUE="#trim(TheQuery.UPC)#" <CFIF listfind(FORM.FinalUPCList, trim(TheQuery.UPC)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.UPC), ",")></CFIF>></TD>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#TheQuery.UPC#</TD></cfif></cfif>
					<TD NOWRAP>#TheQuery.ITEM#</TD>
					<TD>#TheQuery.Description#</TD>
					<!--- <TD>#TheQuery.Q_Brand_Desc#</TD> --->
					<TD>#TheQuery.Type_Code_Desc#</TD>
					<!--- <TD NOWRAP>#TheQuery.Type_Group_Desc#</TD> --->
					<TD>#TheQuery.Brand#</TD>
 				</TR>
			<CFFLUSH>
			</CFOUTPUT>
			</TABLE>
		</CFIF>
	</FIELDSET>
	
	
</CFIF>
<INPUT TYPE="hidden" NAME="FinalUPCList" VALUE="<CFOUTPUT>#Form.FinalUPCList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingproducts" VALUE="0">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">


<input type="hidden" name="Document_ID" value="select_products">

<cfset useLakebaseForCheckForProductsInDB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForCheckForProductsInDB>
	<cftry>
		<cfset CheckForProductsInDB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForProductsInDB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForProductsInDB>
<cfquery name="CheckForProductsInDB" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Products
	WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
</cfquery>
</cfif>
<CFIF CheckForProductsInDB.recordcount EQ 0>
	<input type="hidden" name="Query_Type" value="INSERT">
	<CFSET button_caption = "finished selecting products">
<CFELSE>
	<input type="hidden" name="Query_Type" value="UPDATE">
	<CFSET button_caption = "save changes">	
</CFIF>

</FORM>


</BLOCKQUOTE></BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
