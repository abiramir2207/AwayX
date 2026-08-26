<CFSET PAGE_TITLE="Create New Contract - 5 of 6">
<CFSET GROUP="Contracts">

<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="URL.RO" DEFAULT="0">

<CFIF len(trim(URL.CID)) GT 0 AND URL.RO EQ 1>
	<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
	<cfset useLakebaseForGetProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForGetProducts>
	<cftry>
		<cfset GetProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProducts>
<cfquery name="GetProducts" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Products
		WHERE Contract_Main_ID = #cryp.value#
	</cfquery>
</cfif>
	
	<CFSET FORM.FinalUPCList = valuelist(GetProducts.Product_UPC)>

	<CFSET FORM.Contract_Main_ID = cryp.value>
</CFIF>


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
		
	<CFSET ListOfExistingProductsInDB = valuelist(CheckForProductsInDB.Product_UPC)>
	<!--- <CFOUTPUT>#ListOfExistingProductsInDB#</CFOUTPUT> --->
	<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
		<!--- The current UPC from DB Does NOT Exists in the new list so delete it--->
		<!--- <CFOUTPUT>#listfindnocase(FORM.FinalUPCList, ListItem)#</CFOUTPUT> --->
			<cfset useLakebaseForcleartheproducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForcleartheproducts>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#",
				"product_upc" = "eq.#ListItem#"
			},
			{
				"deleted" = "1",
				"editor_id" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcleartheproducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcleartheproducts>
<cfquery name="cleartheproducts" datasource="#application.datasource#">
				UPDATE Contract_Products
				SET deleted = 1,
				Editor_ID = '#request.AccessStructure.User_ID#'
				WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#' AND
				Product_UPC = '#ListItem#'
			</cfquery>
</cfif>

			<cfquery name="cleartheproducts" datasource="#application.datasource#">
				DELETE
				FROM Contract_Products
				WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#' AND
				Product_UPC = '#ListItem#'
			</cfquery>
	</CFLOOP>

<BR>
	<CFLOOP INDEX="ListItem" LIST="#FORM.FinalUPCList#" DELIMITERS=",">
		<!--- The current UPC Does NOT Exists in DB so add it--->
		<!--- <CFOUTPUT>#listfindnocase(FORM.FinalUPCList, ListItem)#</CFOUTPUT> --->
		<CFIF listfindnocase(ListOfExistingProductsInDB, ListItem) EQ 0>
			<cfset useLakebaseForSaveProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForSaveProduct>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_products", {
			"contract_main_id" = "#FORM.Contract_Main_ID#",
			"product_upc" = "#trim(ListItem)#",
			"creator_id" = "#request.AccessStructure.User_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSaveProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveProduct>
<CFQUERY NAME="SaveProduct" datasource="#application.datasource#">
				INSERT INTO Contract_Products
				(Contract_Main_ID, Product_UPC, Creator_ID)
				VALUES
				('#FORM.Contract_Main_ID#', '#trim(ListItem)#','#request.AccessStructure.User_ID#')
			</CFQUERY>
</cfif>					
		</CFIF>
	</CFLOOP>
	
	<BR>

	
	<CF_CRYP type="en" string="#FORM.Contract_Main_ID#" key="#request.key#">
	<CFIF CheckForProductsInDB.recordcount EQ 0>
		<!--- REDIRECTOR --->
		<cfset useLakebaseForgetContractProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractProgramID>
	<cftry>
		<cfset getContractProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractProgramID>
<cfquery name="getContractProgramID" datasource="#application.datasource#">
			SELECT ProgramType_ID
			FROM Contract_Main
			WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
		</cfquery>
</cfif>
		<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>
		<CFSET redirector_FromPage_ID = 5>
		<cfinclude template="internal_redirector_based_on_settings.cfm">
		<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.value#">
		<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
		<CFLOCATION url= "#redirectURL#" />		
	<CFELSE>
		<cflocation url="Contract_Edit_Menu.cfm?CID=#cryp.value#">
	</CFIF>
	

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


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFIF len(FORM.Contract_Main_ID) GT 0><CFSET temp = FORM.Contract_Main_ID></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "pr"> 


<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>


	<!--- 
	<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
	--->
<CFSET helpfilenumber=6>
<cfinclude template="minimal_contract_info.cfm">

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


	<CFQUERY NAME="GetCurrentProducts" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Items_Master
		WHERE UPC IN(#ListQualify(FORM.FinalUPCList, "'", ",", "ALL")#<CFIF len(FORM.FinalUPCList) EQ 0>'0'</CFIF>)
	</CFQUERY>

<STYLE TYPE='text/css'>
<!--
/*Define elements with children with the class='outlineParentItem', and all elements without children with class='outlineItem'*/
li.oItem { color: #000000; cursor: text; list-style-image:url(/images/fill.gif);} ;
li.oParent { color: #0000FF; cursor: pointer; list-style-image:url(/images/fill.gif); font-size: 12pt; font-weight: bold} ;
ul ul { display: none; } ;
// -->
</STYLE>

<SCRIPT LANGUAGE='Javascript'>
<!--
	// Returns the closest parent tag with tagName containing
	// the src tag. If no such tag is found - null is returned.
	function checkParent( src, tagName ) {
		while ( src != null ) {
			if (src.tagName == tagName) 
				return src;
			src = src.parentElement;
		}
		return null;
	}

	
	// Returns the first tag with tagName contained by
	// the src tag. If no such tag is found - null is returned.
	function checkContent( src, tagName ) {
		var pos = src.sourceIndex ;
		while ( src.contains( document.all[++pos] ) )
			if ( document.all[pos].tagName == tagName )
				return document.all[pos] ;
		return null ;
	}

      
	// Handle onClick event in the outline box
	function outlineAction() {     
		var src = event.srcElement ;
		var item = checkParent( src, "LI" ) ;

		if ( parent != null ) {
			var content = checkContent( item, "UL" ) ;

			if ( content != null )
				if ( content.style.display == "" )
					content.style.display = "block" ;
				else
					content.style.display = "" ;
		}
		event.cancelBubble = true;
	}
    
// -->
</SCRIPT>

	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected products</LEGEND>
		<CFIF GetCurrentProducts.recordcount GT 0>
			<DIV onClick="JavaScript: outlineAction();">
				<UL>
			
				
					<LI class='oParent'>click here to view the products
					<UL>
						<LI class='oItem'>
							<TABLE border="0" cellspacing="0" cellpadding="2"  WIDTH="80%" CLASS="Maintable">
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
								<Cf_cryp string="#GetCurrentProducts.upc#" type="en" key="#request.key#">
								<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: help;" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#cryp.value#';doNotRelocate=1;" ONMOUSEOUT="menuID=0;" STYLE="cursor: help;">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP >#GetCurrentProducts.UPC#&nbsp;&nbsp;&nbsp;</TD></cfif></cfif>
									<TD NOWRAP >#GetCurrentProducts.ITEM#&nbsp;&nbsp;&nbsp;</TD>
									<TD NOWRAP >#GetCurrentProducts.Description#&nbsp;&nbsp;&nbsp;</TD>
									<!--- <TD NOWRAP>#GetCurrentProducts.Q_Brand_Desc#</TD> --->
									<TD NOWRAP >#GetCurrentProducts.Type_Code_Desc#&nbsp;&nbsp;&nbsp;</TD>
									<!--- <TD NOWRAP>#GetCurrentProducts.Type_Group_Desc#</TD> --->
									<TD NOWRAP >#GetCurrentProducts.Brand#</TD>
				
				 				</TR>
							<CFFLUSH>
							</CFOUTPUT>
							</TABLE>
						</LI>
					</UL>
				</LI>
			</DIV>
			<DIV></DIV>			
			
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
				<Cf_cryp string="#TheQuery.upc#" type="en" key="#request.key#">
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;" onmouseover="menuID=6" onmouseout="menuID=0">
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
<script>
	//load the name of the select boxes to hide
	findselectboxes()	
</script>

<INPUT TYPE="hidden" NAME="FinalUPCList" VALUE="<CFOUTPUT>#Form.FinalUPCList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingproducts" VALUE="0">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">


<input type="hidden" name="Document_ID" value="select_products">

<cfquery name="CheckForProductsInDB" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Products
	WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
</cfquery>
<CFIF CheckForProductsInDB.recordcount EQ 0>
	<input type="hidden" name="Query_Type" value="INSERT">
	<CFSET button_caption = "finished selecting products">
<CFELSE>
	<input type="hidden" name="Query_Type" value="UPDATE">
	<CFSET button_caption = "save changes">	
</CFIF>

</FORM>

</BLOCKQUOTE></BLOCKQUOTE>

<script SRC="/common_files/scripts/formInputLocationEmphasizer.js">
	<!--- <cfinclude template="/common_files/scripts/formInputLocationEmphasizer.js"> --->
</script>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
