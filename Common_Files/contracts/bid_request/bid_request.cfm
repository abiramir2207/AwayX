<!---bid_request.cfm--->

<cfoutput>
<CFPARAM NAME="Form.DTPS_Program_ID" DEFAULT="">
<CFPARAM NAME="URL.CID" DEFAULT="#Form.DTPS_Program_ID#">
<cfparam name="form.product_list" default="" />
<cfparam name="form.Program_ID" default="" />
<cfparam name="url.command" default="" />
<cfparam name="form.command" default="#url.command#" />
<cfparam name="form.init" default="0" />
<cfparam name="form.sort_by" default="Item" />
<cfparam name="form.sort_order" default="asc" />
<cfparam name="form.operatorList" default="" />
<cfparam name="form.Like_Product" default="">
<cfparam name="form.Is_Like_Product_Exist" default="0">

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	
	<!---get contract into--->
	<cfset qGetContractInfo = CreateObject("component", "components.programs.Program").getProgramInfo(cryp.value) />

	<!--- Do not show the tabs if the contract is approved --->
	<CFIF qGetContractInfo.Contract_Status_Type_IDX GT 2>
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>	
</CFIF>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////CONTROLLER SECTION///////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---initialize the OperatorManager--->
<cfset OperatorManager = CreateObject("component", "components.programs.operators.OperatorManager") />
<cfset operatorIds = OperatorManager.getProgramOperatorIds(cryp.value) />
<cfset form.operatorList = operatorIds.getLOperatorIds() />

<!---initialize the BidRequestProductManager--->
<cfset bidRequestProductManager = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />

<!---get bid request spec list--->
<cfset bidRequestSpec = CreateObject("component", "components.programs.bid_request.BidRequestSpec") />
<cfset qGetBidSpec = bidRequestSpec.getBidRequestSpec() />

<!---if the form hasn't been initialized then we know it's the first time in so let's get data from DB --->
<cfif not form.init>
	<cfset bidRequest = bidRequestProductManager.getBidRequestProductsFromDb(cryp.value) />
<!---otherwise set data from form--->
<cfelse>
	<cfset bidRequest = bidRequestProductManager.setFromForm(form) />
</cfif>

<!---set the bid request products--->
<cfset bidRequestProducts = bidRequest.getBidRequestProducts() />


<!---set the bid request products list for form.product_list--->
<cfset form.Product_List = bidRequest.getLBidRequestProductIds() />

<cfif form.command eq "save">
	<cfset bidRequestProductManager.saveBidRequestProducts(bidRequest) />

<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>

<!--- (Dev Note: Milan; D7226) Delete previous products only if the same product existed in bid-request discount type --->
		<cfif form.Is_Like_Product_Exist eq 1>
				<cfloop list="#Product_List#" index="Prod">
					<cfset Existing_LikeProduct = ProdManager.getSimilarExistingProduct('#FORM.Program_ID#', '#Prod#')>
						<cfif Existing_LikeProduct.Recordcount neq 0>
							<cfset ProdManager.setDeleteSimilarExistingProduct('#FORM.Program_ID#','#Prod#')>
						</cfif>
				</cfloop>	

<!--- Add Products (These products are generic and not related to any discount type) --->		
				<cfloop list="#form.Like_Product#" index="LikeProd">
							<cfset ProdManager.setSimilarExistingProduct('#FORM.Program_ID#','#LikeProd#')>
				</cfloop>
		</cfif>
<!--- End Note: Milan; D7226 --->

	<CFQUERY NAME="getProgramType" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main 
	WHERE Contract_Main_ID = #bidRequest.getProgramId()#
</CFQUERY>
	<CFSET redirector_Program_ID = getProgramType.ProgramType_ID />
	<CFSET redirector_FromPage_ID = 10>
	<CF_CRYP type="en" string="#cryp.value#" key="#request.key#" return="Enc">
<!--- 	<cflocation url="/Common_Files/contracts/bid_request/bid_request.cfm?CID=#Enc.value#" /> --->
	<cfinclude template="/Common_Files/contracts/internal_redirector_based_on_settings.cfm">
	
	<CFLOCATION url="/Common_Files/contracts/redirect.cfm?destination=#redirector_NextLocation#&CID=#Enc.value#">
</cfif>


<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////END CONTROLLER SECTION///////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<CFSET PAGE_TITLE= "Proposal">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<script src="/billbacks/common/common_js_functions.js"></script>
	<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js"></script>
	<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
	<script language="JavaScript" src="../../../Futures_Pricing/common/common.js"></script>
	<script src="bid_request.js"></script>
	<style>
		.brdrLft td { border-left:1px solid silver }
		.brdrLftTop td { border-left:1px solid silver; border-top:1px solid silver}
		.brdrRgt { border-right:1px solid silver }
		.thickBrdrRgt { border-right:3px solid white}
	</style>	
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "bid request">
<cfset FORM.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
		<CFINCLUDE TEMPLATE="../contract_status_legend.cfm">
	</div>
<cfelse>
	<CFINCLUDE TEMPLATE="../contract_status_legend.cfm">
</cfif>

<CF_CRYP type="de" string="#CID#" key="#request.key#">

<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(cryp.value)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>

<cfset DiscountType = 10>

<!--- If the program is a revision and revision settings has retrictions for this program --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>

<cfif Not IsDefined("ProgramManager")>
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
</cfif>

<cfif NOT IsDefined("ParentprogramInfo")>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(cryp.value)>
</cfif>

<cfif NOT IsDefined("ProgramProducts")>
	<cfset ProgramProducts = CreateObject("component", "components.products.products")/>
</cfif>

<cfif NOT IsDefined("getProgramProducts")>
		<cfset getProgramProducts = ProgramProducts.getproducts('',DiscountType,ParentProgramInfo.Revision_of_Contract_main_id)>
</cfif>

<cfset ProductItemList = queryNew("")>

<cfif getProgramProducts.recordcount neq 0>
	<cfset ProductItemList = ValueList(getProgramProducts.ItemMasterID)>
<cfelse>
	<cfset ProductItemList = "NULL">
</cfif>

<cfelse>
<!--- to avoid an error --->
	<cfset ProductItemList = queryNew("")>
	<cfset ProductItemList = "NULL">
</cfif>

<BLOCKQUOTE><BLOCKQUOTE>


<cfif application.programlayout EQ 1>
	<div id="Layer1" style="position:relative; width:200px; z-index:1; left:80px; top: 10px; height:430px">
</cfif>

<cfinclude template="../minimal_contract_info.cfm">

<FORM ACTION="" METHOD="post" NAME="dataForm" ID="dataForm" STYLE="DISPLAY:INLINE;">
<table WIDTH="800">
	<tr>
		<td align="left">
			<table>
				<tr>
					<td>			
						<CF_button
							button_name		=	""
							button_caption	=	"save"
							button_action	=	"submitForm('save')"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"save"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					</td>
					<td>	
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>	
						<CF_button
							button_name		=	""
							button_caption	=	"select products"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"select products"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							enabled			=	"0"
						>
					<cfelse>	
					<!--- If I remove this function, the one under "futures pricing" folder will be used --->
					<script language="javascript">
						function showProductSearchWindow(formName) 
						{
							NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=" + formName+"&DiscounType=10", "productwindow", 800, 600, "yes", "yes");
							return false;
						}
					</script>
						<CF_button
							button_name		=	""
							button_caption	=	"select products"
							button_action	=	"return showProductSearchWindow('dataForm');"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"select products"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					</cfif>
					</td>
				</tr>
			</table>
		</td>
		<td align="right">
			<!---only show history link if the number of operators are between 1 and 10--->
			<cfif ListLen(form.operatorList) gt 0 and ListLen(form.operatorList) lte 10>
				<FONT SIZE="2">
					<B><FONT COLOR="FF0000">[</FONT><a href="javascript:NewWindow('bid_request_history.cfm?formname=dataForm','name','850','600','Yes', 'No')"> proposal history </a><FONT COLOR="FF0000">]</FONT></B>
				</FONT>
			</cfif>
		</td>
	</tr>
</table>
<br>
<!---table header--->
<TABLE border="0" cellspacing="0" cellpadding="3" CLASS="Maintable" WIDTH="800">
	<TR ID="header" BGCOLOR="##FFCE84" class="brdrLftTop">
		<TD>
		<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2)>
			<img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onclick="deleteAll()" style="cursor: pointer;">
		<cfelse>
			&nbsp;
		</cfif>
		</TD>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left" ID="header"><A HREF="javaScript:sortByThis('UPC');"><b>UPC</b>&nbsp;<cfif form.sort_by eq "upc"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></TD></cfif></cfif>
		<TD align="left" ID="header"><A HREF="javaScript:sortByThis('Item');"><b>Item ##</b>&nbsp;<cfif form.sort_by eq "item"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></TD>
		<TD align="left" ID="header"><A HREF="javaScript:sortByThis('Description');"><b>Description</b>&nbsp;<cfif form.sort_by eq "description"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></TD>
		<TD align="left" ID="header"><b>Spec</b></TD>
		<TD align="left" ID="header"><b>Line Item</b></TD>
		<TD align="left" ID="header"><b>Previous Won By</b></TD>
		<TD align="left" ID="header"><b>Previous Won Price</b></TD>
		<!---show spacer if we have products--->
		<cfif ArrayLen(bidRequestProducts)>
			<td width="2" rowspan="100%" bgcolor="##FFFFFF">&nbsp;</td>
		</cfif>
		<TD align="left" ID="header"><b>Base Price</b></TD>
		<TD align="left" ID="header"><b>Allowance</b></TD>
		<TD align="left" ID="header" class="brdrRgt"><b>Price Offered</b></TD>
	<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
		<TD align="left" ID="header"><b>Similar<br />Product</b></TD>
	</cfif>
	</TR>
	
	<!---loop over products if we have any--->
	<cfif ArrayLen(bidRequestProducts)>
	
		<cfloop index="prodIndx" from="1" to="#ArrayLen(bidRequestProducts)#">
		
			<!---replace hyphens with underscores in prodId--->
			<cfset scrubbedProdId = request.app_general_functions.replaceHyphen(bidRequestProducts[prodIndx].getItemMasterId()) />
			
			<!---set this spec id--->
			<cfset thisSpecId = bidRequestProducts[prodIndx].getSpecId() />
			
			<TR class="brdrLft" <CFIF prodIndx mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> ONMOUSEOVER="menuID=6;URLstring='';an_ID='#bidRequestProducts[prodIndx].getItemMasterId()#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" height="30" ID="SCISSOR_ITEM_#scrubbedProdId#">
				<TD>
				<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND ListFind(ProductItemList,bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0)>
					<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete this product" border="0" onclick="deleteThisRecord('#scrubbedProdId#', '#bidRequestProducts[prodIndx].getItemMasterId()#', document.dataForm.Product_List, document.dataForm.ExistingProductList)" style="cursor: pointer;">
				<cfelse>
					&nbsp;
				</cfif>
				</TD>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#bidRequestProducts[prodIndx].getUpc()#</TD></cfif></cfif>
				<TD NOWRAP>#bidRequestProducts[prodIndx].getItem()#</TD>
				<TD>#bidRequestProducts[prodIndx].getDesc()#</TD>
				<TD><select name="Bid_Request_Spec_ID_#scrubbedProdId#" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>>
						<cfloop query="qGetBidSpec">
							<option value="#Bid_Request_Spec_ID#" <cfif Bid_Request_Spec_ID eq thisSpecId>selected</cfif>>#Bid_Request_Key#</option>
						</cfloop>
					</select>
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>
						<input type="hidden" name="Bid_Request_Spec_ID_#scrubbedProdId#" value="#thisSpecId#">
					</cfif>
				</TD>
				<!---BJF: Add line item --->
				<td><input name="Line_ID_#scrubbedProdId#" type="text" value="#bidRequestProducts[prodIndx].getLineID()#" size="8" maxlength="255"> </td>

				<td>
				<input name="previous_won_by_#scrubbedProdId#" type="text" value="#bidRequestProducts[prodIndx].getPreviousWonBy()#" size="13" maxlength="255" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>/>
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>
						<input type="hidden" name="previous_won_by_#scrubbedProdId#" value="#bidRequestProducts[prodIndx].getPreviousWonBy()#">
					</cfif>
				</td>
				<td nowrap>
					<input name="previous_won_price_#scrubbedProdId#" type="text" value="#bidRequestProducts[prodIndx].getPreviousWonPrice()#" size="3" maxlength="9" onChange="this.value = decimalNumFormat(this.value, 4);" onKeyUp="clenseText(this, '0123456789.');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>/> per
					<cfset disabled = 0>
					 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>
						<cfset disabled = 1>
					 </cfif>
					<cf_uom_dropdown
						program_id				=	"#bidRequest.getProgramId()#"
						company_main_id			=	""
						default_option_on		=	"0"
						default_option_text		=	""
						default_option_value	=	""
						dropdown_name			=	"previous_won_uom_#scrubbedProdId#"
						option_text_abbreviated	=	"1"
						plural_uom_display		=	""
						product_type_id			=	"#bidRequest.getDiscountTypeId()#"
						program_template_id		=	""
						selected_uom_id			=	"#bidRequestProducts[prodIndx].getPreviousWonUom()#"
						text_before_tag_close	=	""
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	""
						disabled				=	"#disabled#"
						>
					<cfif Disabled eq 1>
						<input type="hidden" name="previous_won_uom_#scrubbedProdId#" value="#bidRequestProducts[prodIndx].getPreviousWonUom()#">
					</cfif>
				</td>
				<!--- <td colspan="100%" bgcolor="##FFFFFF" style="border-bottom:none">a</td> --->
				<TD>
					<div id="default_price_#scrubbedProdId#">#NumberFormat(bidRequestProducts[prodIndx].getDefaultPrice() , "$_.__")#</div>
				</TD>
				<TD nowrap>
					<input name="allowance_#scrubbedProdId#" type="text" value="#NumberFormat(bidRequestProducts[prodIndx].getAllowance(), "_.____")#" size="3" maxlength="9" onChange="adjustNet('#scrubbedProdId#')" onKeyUp="clenseText(this, '0123456789.');"  <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>/>
					 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>
						<input type="hidden" name="allowance_#scrubbedProdId#" value="#bidRequestProducts[prodIndx].getAllowance()#">
					 </cfif>
				</TD>

				<TD class="brdrRgt" nowrap>
					<input name="net_#scrubbedProdId#" type="text" value="#NumberFormat(bidRequestProducts[prodIndx].getNet() , "_.____")#" size="3" maxlength="9" onChange="adjustAllowance('#scrubbedProdId#')" onKeyUp="clenseText(this, '0123456789.');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>/>
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, bidRequestProducts[prodIndx].getItemMasterId()) NEQ 0>
							<input type="hidden" name="net_#scrubbedProdId#" value="#bidRequestProducts[prodIndx].getNet()#">
					</cfif>
					per
					<cf_uom_dropdown
						program_id				=	"#bidRequest.getProgramId()#"
						company_main_id			=	""
						default_option_on		=	"0"
						default_option_text		=	""
						default_option_value	=	""
						dropdown_name			=	"uom_#scrubbedProdId#"
						option_text_abbreviated	=	"1"
						plural_uom_display		=	""
						product_type_id			=	"#bidRequest.getDiscountTypeId()#"
						program_template_id		=	""
						selected_uom_id			=	"#bidRequestProducts[prodIndx].getUom()#"
						text_before_tag_close	=	"onChange=uomChange('#scrubbedProdId#');"
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	""
						productUom				=	"#bidRequestProducts[prodIndx].getProductInventoryUOM()#"
						disabled				=	"#disabled#"
						>
					<cfif Disabled eq 1>
							<input type="hidden" name="uom_#scrubbedProdId#" value="#bidRequestProducts[prodIndx].getUom()#">
					</cfif>
					
				</TD>
				<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
				<TD><input name="Like_Product" type="checkbox" value="#bidRequestProducts[prodIndx].GetItemMasterID()#" <cfif ListFind(SimilarExistingProductList,#bidRequestProducts[prodIndx].GetItemMasterID()#) neq 0 >CHECKED</cfif>></TD>
				</cfif>
				<input name="default_lb_price_#scrubbedProdId#" type="hidden" value="#bidRequestProducts[prodIndx].getDefaultLBPrice()#" />
				<input name="default_cs_price_#scrubbedProdId#" type="hidden" value="#bidRequestProducts[prodIndx].getDefaultCSPrice()#" />
				<input name="display_default_lb_price_#scrubbedProdId#" type="hidden" value="#NumberFormat(bidRequestProducts[prodIndx].getDefaultLBPrice(), "$_.__")#" />
				<input name="display_default_cs_price_#scrubbedProdId#" type="hidden" value="#NumberFormat(bidRequestProducts[prodIndx].getDefaultCSPrice(), "$_.__")#" />	
			</TR>
		</cfloop>
	
	<cfelse>
		<tr><td colspan="100%">(No Products Selected)</td></tr>
	</cfif>
</TABLE>

<table width="800">
	<!---loop over spec info and display info--->
	<tr>
		<td colspan="100%" style="border:none">
			<cfloop query="qGetBidSpec">
				#Bid_Request_Key# (#Bid_Request_Desc#)&nbsp;&nbsp;&nbsp;
			</cfloop>
		</td>
	</tr>
</table>
<br>
<CF_button
	button_name		=	"save"
	button_caption	=	"save"
	button_action	=	"submitForm('save', 1, 'save_table')"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"save"
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>
<cfset Form.DTPS_Program_ID = FORM.Contract_Main_ID>
<INPUT TYPE="Hidden" NAME="command" VALUE="#form.command#">
<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#form.Product_List#">
<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#form.Product_List#">
<input type="Hidden" name="Program_ID" value="#cryp.value#" />
<input type="Hidden" name="Contract_Main_ID" value="#cryp.value#" />
<input type="Hidden" name="init" value="1" />
<input type="Hidden" name="sort_by" value="#form.sort_by#" />
<input type="Hidden" name="sort_order" value="#form.sort_order#" />
<input type="Hidden" name="operatorList" value="#form.operatorList#" />
<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" VALUE="#FORM.Contract_Main_ID#">
<INPUT TYPE="Hidden" NAME="DTPS_On" value="1">
<INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">


<!---Min/max values--->
	<cfparam name="getSettings.Min_BidRequest_Case" default="0">
	<cfparam name="getSettings.Max_BidRequest_Case" default="0">
	<cfparam name="getSettings.Min_BidRequest_Pound" default="0">
	<cfparam name="getSettings.Max_BidRequest_Pound" default="0">
	<cfparam name="getSettings.Min_BidRequest_Percent" default="0">
	<cfparam name="getSettings.Max_BidRequest_Percent" default="0">
	<cfparam name="ThereisMinorMax" default="0">
	
	<!---Sets min and max values if they exist for the profile--->
	<cfif len(trim(getSettings.Min_BidRequest_Case)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Min_BidRequest_Case" value="#getSettings.Min_BidRequest_Case#">
	<cfif len(trim(getSettings.Max_BidRequest_Case)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Max_BidRequest_Case" value="#getSettings.Max_BidRequest_Case#">
	<cfif len(trim(getSettings.Min_BidRequest_Pound)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Min_BidRequest_Pound" value="#getSettings.Min_BidRequest_Pound#">
	<cfif len(trim(getSettings.Max_BidRequest_Pound)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Max_BidRequest_Pound" value="#getSettings.Max_BidRequest_Pound#">
	<cfif len(trim(getSettings.Min_BidRequest_Percent)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Min_BidRequest_Percent" value="#getSettings.Min_BidRequest_Percent#">
	<cfif len(trim(getSettings.Max_BidRequest_Percent)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Max_BidRequest_Percent" value="#getSettings.Max_BidRequest_Percent#">
	<input type="hidden" name="ThereisMinorMax" value="#ThereisMinorMax#">
	<!---end min/max values--->
</form>	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
</cfoutput>