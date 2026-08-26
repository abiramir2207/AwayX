<CF_CRYP type="de" string="#CID#" key="#request.key#">

<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(cryp.value)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>

<!--- Dev Note: Clay 11219 - DropDown Names Undefined   --->
<SCRIPT type="text/javascript">
if(dropdown_names == undefined)
{
	var dropdown_names = new Array();
}
</SCRIPT>

<cfset DiscountType = 2>
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
	<!--- Get parent program products --->
			<cfset getProgramProducts = ProgramProducts.getproducts('',DiscountType,ParentProgramInfo.Revision_of_Contract_main_id)>
	</cfif>


	<cfset ProductItemList = queryNew("")>

	<cfif getProgramProducts.recordcount neq 0>
		<cfset ProductItemList = ValueList(getProgramProducts.MasterItemID)>
	<cfelse>
		<cfset ProductItemList = "NULL">
	</cfif>

<cfelse>
<!--- to avoid an error --->
	<cfset ProductItemList = queryNew("")>
	<cfset ProductItemList = "NULL">
</cfif>
<cfoutput>
<style>
	select,input
	{
		font-size:10;
	}
</style>
<CFSET checkbox_width=20>
<CFSET upc_width=68>
<CFSET level_width=40>
<CFSET group_width=80>
<CFSET desc_width=90>
<CFSET component_width=90>

<cfif ArrayLen(desRebateData.aProd) gt 10>
	<cfset divHght = "height:270px;" />
	<cfset divTableWidth = "850" />
<cfelse>
	<cfset divHght = "" />
	<cfset divTableWidth = "850" />
</cfif>
<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfset getCompetitiveProductsInfo = bidRequestProdMan.getpreviousinfo(CSL_Contract_Main_ID)>
</CFIF>

<cfset rowspan = 1 />
<cfif Display_Basis_Treatment_Code EQ 1>
	<cfset rowspan = 2 />
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<table border="0" cellpadding="1" cellspacing="0" bgcolor="ffce84" CLASS="Maintable" width="800">
	<tr>
		<TD ID="header" WIDTH="15" rowspan="#rowspan#" style="display:none;">
			<NOBR>
		<!--- If the program is a revision and revision settings has retrictions for this program and products cannot be removed --->
			<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2)>
				<img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onclick="deleteAll('prodChkBx_');" style="cursor: pointer;">
			<cfelse>
				&nbsp;
			</cfif>
			</NOBR>
		</TD>
		<td width="#checkbox_width#" rowspan="#rowspan#"><input style="display:none;" name="prodCheck" type="checkbox" onClick="checkAllProd()" checked>
		<INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products" checked>
		</td>
		<TD width="#upc_width#" rowspan="#rowspan#">
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>			<b><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></b>&nbsp;<cfif form.sortBy eq "upc"><cfif form.sortOrder eq "desc"><img src="/Images/up_1.gif" border="0"><cfelse><img src="/Images/down_1.gif" border="0"></cfif></cfif><br></cfif></cfif>
			<b><cfoutput>#application.returned_customer_setting.item_label#</cfoutput> ##</b>&nbsp;<cfif form.sortBy eq "item"><cfif form.sortOrder eq "desc"><img src="/Images/up_1.gif" border="0"><cfelse><img src="/Images/down_1.gif" border="0"></cfif></cfif>
		</TD>
		<!---Modification: Group Deals--->
		<cfif Form.Discount_Rebates_Group_Level eq 1 and appSettings.getAllowMultiLevelGroups()>
			<TD width="#group_width#" rowspan="#rowspan#">
				LEVEL/<br>
				GROUP
			</TD>
			
		</cfif>
		
		<TD width="#desc_width#" rowspan="#rowspan#">
			<b>DESCRIPTION</b>&nbsp;<cfif form.sortBy eq "description"><cfif form.sortOrder eq "desc"><img src="/Images/up_1.gif" border="0"><cfelse><img src="/Images/down_1.gif" border="0"></cfif></cfif>
		</TD>
		
		<cfset componentTDLen = 0 />
		<cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
		
			<!---param the comp var--->
			<cfparam name="form.uomsToCheck_#index#" default="" />
			
			<!---get the name of the component with the id that's in the data struct--->
			<cfscript>
				qCompName = comp.getComp(desRebateData.aComp[index].compNameId);
				qGetActiveComps = comp.getActive();
				qGetCompRuleUoms = compBusRule.getCompRuleUoms(desRebateData.aComp[index].compNameId);
			</cfscript>

			<cfset componentNamePopupWidth = 200 />
			<!------ <cfif Display_Basis_Treatment_Code EQ 1>
				<cfset componentNamePopupWidth = componentNamePopupWidth + 200 />
			</cfif> ----->
			<cfset componentColSpan = 1 />
			<cfif Display_Basis_Treatment_Code EQ 1>
				<cfif BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) EQ "Y">
					<cfset componentColSpan = componentColSpan + 2 />
					<cfset componentTDLen = componentTDLen + 2 />
				</cfif>
			</cfif>
			
			<cfset componentTDLen = componentTDLen + 1 />
			<td width="#Evaluate(component_width * componentColSpan)#" nowrap colspan="#componentColSpan#" style="border-left:solid ##93BEE2 1px; font-size : 10px;">
				<!--- <A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#index#', '#replace(qCompName.Program_Rebates_Component_Name, "'", "\'")#')"><img src="/Images/scissor.gif"  alt="delete this component" border="0"></A> --->
				<input name="comp" type="checkbox" value="#index#">
				#Left(qCompName.Program_Rebates_Component_Name, 10)#<cfif Len(qCompName.Program_Rebates_Component_Name) gt 10>...</cfif>
				
				
				<cfset additionalInfo = "" />
				<!---if the component type is 1 then we pay to distributor, otherwise it's operator---->
				<cfsavecontent variable="additionalInfo">#additionalInfo#				
				Paid To:
			<cfif desRebateData.aComp[index].componentPaidTo eq 1>
					&nbsp;#application.returned_customer_setting.distributor_label_singular#
				<cfelseif desRebateData.aComp[index].componentPaidTo eq 2>
					&nbsp;#application.returned_customer_setting.operator_label_singular#
				<cfelseif desRebateData.aComp[index].componentPaidTo eq 3>
					&nbsp;#application.returned_customer_setting.broker_label_singular#
				<cfelseif desRebateData.aComp[index].componentPaidTo eq 4>
					&nbsp;#application.returned_customer_setting.distributor_label_singular# & #application.returned_customer_setting.operator_label_singular#
				</cfif>
				</cfsavecontent>
				<!--- if claim mech at component level is on, display ---->
				<cfif appSettings.getClaims_at_Comp_Level()>
				<cfsavecontent variable="additionalInfo">#additionalInfo#
				<br>Claim Mechanism: #paymenttypeManager.getDesc(desRebateData.aComp[index].Claim_Mechanics)#
				</cfsavecontent>
				</cfif>
				<!--- display basis code treatment code information ---->
				<cfif Display_Basis_Treatment_Code EQ 1>
				<cfsavecontent variable="additionalInfo">#additionalInfo#
				<!------ <br>Treatment Code: #TreatmentCodeManager.getTreatmentCodeDesc(desRebateData.aComp[index].TreatmentCode)#
				<br>Basis Code: #BasisCodeManager.getBasicCodeDesc(desRebateData.aComp[index].BasisCode)# ----->
				</cfsavecontent>
				</cfif>
				<!------ Display additional info ----->
				<!--- <cfif Len(additionalInfo)>
				<CF_SmallHelp
					height = "50"
					width = "200"
					displayShifyX = "-90"
					displayShifyY = "-50"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					>
				<center>#additionalInfo#</center>
				</CF_SmallHelp>
				</cfif> --->
				
			</td>
			
			<!---hidden form vars holding component data--->
			<input type="hidden" name="compNameId_#index#" value="#desRebateData.aComp[index].compNameId#" />
			<input type="hidden" name="compHasRules_#index#" value="#qCompName.Has_Rules#" />
			<input type="hidden" name="compRulesReq_#index#" value="#qCompName.Rule_Required#" />
			<input type="hidden" name="rebate_type_#index#" value="#qCompName.rebate_type#" />
			<input type="hidden" name="lCompRuleUoms_#index#" value="#ValueList(qGetCompRuleUoms.Unit_Of_Measure_ID)#" />
			<input type="hidden" name="compPaidTo_#index#" value="#desRebateData.aComp[index].componentPaidTo#" />
			<cfset "form.uomsToCheck_#index#" = "" />
			
		</cfloop>
		<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
				<td rowspan="#rowspan#">Similar<br />Product</td>
		</cfif>	
		<!---set placeholder cells--->
		<cfset tmp = 6 - componentTDLen />
		<cfloop index="index" from="1" to="#tmp#">
			<td width="#component_width#" rowspan="#rowspan#">&nbsp;</td>
		</cfloop>
		<!------ <cfif ArrayLen(desRebateData.aProd) gt 9><td>&nbsp;</td></cfif> ----->
	</tr>
	<cfif Display_Basis_Treatment_Code EQ 1>
	<tr>
		<cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
		
			<!---get the name of the component with the id that's in the data struct--->
			<cfscript>
				qCompName = comp.getComp(desRebateData.aComp[index].compNameId);
				qGetActiveComps = comp.getActive();
				qGetCompRuleUoms = compBusRule.getCompRuleUoms(desRebateData.aComp[index].compNameId);
			</cfscript>

			<td width="#component_width#" nowrap id="header" style="border-left:solid ##93BEE2 1px;" align="center"><strong>rate</strong></td>
			<cfif Display_Basis_Treatment_Code EQ 1>
				<cfif BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) EQ "Y">
				<td width="#component_width#" nowrap id="header" align="center"><strong>buy</strong></td>
				<td width="#component_width#" nowrap id="header" align="center"><strong>get free</strong></td>
				</cfif>
			</cfif>
			
		</cfloop>
	</tr>
	</cfif>
</table>

<cfif ArrayLen(desRebateData.aProd) gt 10>

	<cfset divHght = "height:300px;" />
	<cfset divTableWidth = "850" />

<cfelse>

	<cfset divHght = "" />
	<cfset divTableWidth = "850" />

</cfif>

<cfparam name="currentheader" default="">
<cfparam name="currentheader_id" default="0">
	
  <DIV STYLE="position:relative;overflow:auto;#divHght#"> 
	<!--- <DIV STYLE="position:relative;overflow:auto;#divHght#;width=900">  --->
	<table border="0" cellpadding="1" cellspacing="0" CLASS="Maintable" width="800">
	  <!---if we have product data then loop through--->
	  <cfif ArrayLen(desRebateData.aProd)>
	  
		<cfloop index="i" from="1" to="#ArrayLen(desRebateData.aProd)#">
		 <!--- New Type Code Header --->
		<cfparam name="bgcolor_row" default="1">	
		 <cfif desRebateData.aProd[i].displaygroupname NEQ currentheader>
		 	<cfset bgcolor_row = 1>
		 	<cfset currentheader = desRebateData.aProd[i].displaygroupname />
			<cfset currentheader_id = #REREPLACE(trim(desRebateData.aProd[i].displaygroupname),' ','_','ALL')# />
			<tr><td colspan="100%" style="background-color:##ddddee;color:##000000;font-weight:900;font-size:11px;"><input type="checkbox" id="tcHeader_#currentheader_id#" name="type_code_header" value="#currentheader_id#" onClick="checkMatchingProd('#JSStringFormat(currentheader_id)#',this);" checked>&nbsp;#application.returned_customer_setting.TYPE_CODE_LABEL_PLURAL#: #UCASE(desRebateData.aProd[i].displaygroupname)#&nbsp;</td></tr>
		<cfelse>
		    <cfset bgcolor_row = bgcolor_row + 1 />
		</cfif>
			
		<cfset stripProdId = request.app_general_functions.replaceHyphen(desRebateData.aProd[i].masterItemId) />
		  <cfparam name="request.menuId" default="6" />
		  <cfset request.theMOId = desRebateData.aProd[i].masterItemId />
		  <cfparam name="tmpBgColor" default="ccffcc" />
		  <!---build product list from prod array--->
		  <cfif not ListFindNoCase(form.Product_List, desRebateData.aProd[i].masterItemId)>
			<cfset form.Product_List = ListAppend(form.Product_List, desRebateData.aProd[i].masterItemId) />
		  </cfif>
		  <!---Modification: Group Deals--->
		  <cfif Form.Discount_Rebates_Group_Level eq 1>
			<!---set groups in the proper levels--->
			<cfif Len(trim(desRebateData.aProd[i].pricingLevel)) and trim(desRebateData.aProd[i].pricingLevel) neq 0>
			  <!---check for duplicate in level lists--->
			  <cfif not ListFindNoCase(Evaluate("form.Level_#desRebateData.aProd[i].pricingLevel#"), desRebateData.aProd[i].masterItemId)>
				<cfset "form.Level_#desRebateData.aProd[i].pricingLevel#" =  ListAppend(Evaluate("form.Level_#desRebateData.aProd[i].pricingLevel#"), desRebateData.aProd[i].masterItemId) />
			  </cfif>
			  <cfset "form.GroupLevel_#desRebateData.aProd[i].pricingLevel#" =  desRebateData.aProd[i].productGroupLevel />
			</cfif>
			<!---Modification: Group Deals--->
			<cfset Form.groupLevelProducts = desRebateData.aProd[i].productGroupLevel>
			<!---set the hidden variables--->
			<input type="hidden" name="Product_Group_ID_#stripProdId#" value="#desRebateData.aProd[i].productGroupID#" />
			<input type="hidden" name="Product_Group_Level_ID_#stripProdId#" value="#desRebateData.aProd[i].productGroupLevel#" />
			<input type="hidden" name="Pricing_Level_ID_#stripProdId#" value="#desRebateData.aProd[i].pricingLevel#" />
			<input type="hidden" name="Is_Group_#stripProdId#" value="#desRebateData.aProd[i].isGroup#" />
			<input type="hidden" name="Product_Group_Level_Type_ID_#stripProdId#" value="#desRebateData.aProd[i].productGroupLevelTypeId#" />
			<!---set bgcolor--->
			<cfif desRebateData.aProd[i].pricingLevel eq 3>
			  <cfset tmpBgColor = "E2CBE4" />
			  <cfelseif desRebateData.aProd[i].pricingLevel eq 2>
			  <cfset tmpBgColor = "DFE6FF" />
			  <cfelse>
			  <cfset tmpBgColor = "CCFFCC" />
			</cfif>
			<!--- 		<tr id="compRow_#i#" bgcolor="#IIF( i mod 2 eq 0, DE("DFE6FF"), DE("ccffcc"))#" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#desRebateData.aProd[i].masterItemId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">  --->
			<!---onmouseover menuId--->
			
			<cfif desRebateData.aProd[i].isGroup eq 1>
			  <cfset request.menuId = 11 />
			  <cfset request.theMOId = "#desRebateData.aProd[i].productGroupID#&Group_Level_ID=#desRebateData.aProd[i].productGroupLevel#&Program_ID=#desRebateData.programId#" />
			 <cfelse>
			  <cfset request.menuId = 6 />
			  <cfset request.theMOId = desRebateData.aProd[i].masterItemId />
			</cfif>
			<cfelse>
<!--- 			<cfif Evaluate(i mod 2) eq 0>
			  <cfset tmpBgColor = "FFFFFF" />
			  <cfelse>
			  <cfset tmpBgColor = "ccffcc" />
			</cfif> --->
			<cfif bgcolor_row mod 2>
				<cfset tmpBgColor="white" />
			<cfelse>
				<cfset tmpBgColor="ccffcc" />
			</cfif>	
		  </cfif>
		 
		  <tr id="compRow_#i#" bgcolor="#tmpBgColor#" ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"> 
			<TD width="15">
			<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2  AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0)>
				<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" title="click here to delete this product" border="0" onclick="deleteThisRebate('#stripProdId#', '#desRebateData.aProd[i].masterItemId#', '#tmpBgColor#', '#desRebateData.aProd[i].pricingLevel#','#Evaluate("form.GroupLevel_#desRebateData.aProd[i].pricingLevel#")#')" style="cursor: pointer;display:none;">
			<cfelse>
				&nbsp;
			</cfif>
			</TD>
			<td width="#checkbox_width#"><input name="prodChkBx_#stripProdId#" id="#currentheader_id#" type="checkbox" value="#desRebateData.aProd[i].masterItemId#" checked> 

			</td>
			<TD width="#upc_width#"><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1> #trim(desRebateData.aProd[i].upc)#<br> </cfif></cfif>
			  <!---hack to limit item length--->
			  <cfif Len(desRebateData.aProd[i].item) gt 10>
				<label title="#desRebateData.aProd[i].item#">#Left(trim(desRebateData.aProd[i].item), 
				10)#...</label>
				<cfelse>
				#desRebateData.aProd[i].item# </cfif> </TD>
				
			<input name="volume_#i#" type="hidden" value="#desRebateData.aProd[i].volume#" />
			<!---strip our the double quotes--->
			<cfset thisDesc = REReplaceNoCase(desRebateData.aProd[i].description, '"', ' ', 'ALL') />
			<!---Modification: Group Deals--->
			<cfif Form.Discount_Rebates_Group_Level eq 1>
			  <!---Modification: Group Deals--->
			  <!---get the group level desc--->
			  <cfset thisGroupLevelDesc = CreateObject("component", "components.products.Group.DataManager").getProductGroupsData(desRebateData.aProd[i].productGroupLevel).Group_Level_Desc />
			  <cfif trim(thisGroupLevelDesc) eq "">
				<cfset thisGroupLevelDesc = "Product" />
			  </cfif>
			  <!--- <cfif BSAGroups> --->
			  <cfif Form.Discount_Rebates_Group_Level eq 1 and appSettings.getAllowMultiLevelGroups()>
				<TD width="#group_width#" valign="top"> #desRebateData.aProd[i].pricingLevelDesc#/<br> 
				  #thisGroupLevelDesc# </TD>
			  </cfif>
			</cfif>
			<TD width="#desc_width#" title="#thisDesc#" valign="top"> #desRebateData.aProd[i].description# 
			<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
				<cfquery name="getcompetitiveinfo" dbtype="query">
					select * from getCompetitiveProductsInfo
					where product_id = '#desRebateData.aProd[i].masterItemId#'
				</cfquery>
				<CFMODULE template="/CustomTags/SmallHelp.cfm"
				width = "180"
				height = "50"
				imgPath="/Images/Asterix.gif"
				imgWidth="10"
				imgHeight="10"
				>
				<table>
				<tr><td align="left">Previous Won By:</td><td>#getcompetitiveinfo.Previous_Won_By#</td></tr>
				<tr><td align="left">Previous Won Price:</td>
				<td>#numberformat(getcompetitiveinfo.Previous_Won_Price,"_,___,____.____")#/
				<cfif getcompetitiveinfo.Previous_Won_UOM EQ 1>CS<cfelse>LB</cfif></td></tr>
				<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
				<tr><td align="left">Delivery Type:</td><td><cfif getcompetitiveinfo.Previous_Won_Delivery_Type EQ 1>FOB<cfelseif getcompetitiveinfo.Previous_Won_Delivery_Type EQ 2>DEL<cfelse>&nbsp;</cfif></td></tr></cfif>
				</table>
				</CFMODULE>
			</cfif>
			  <cfif restrictLowerLevelBasedonLevel1>
				<input type="hidden" name="productGroupForThisProduct_#request.app_general_functions.replaceHyphen(desRebateData.aProd[i].masterItemId)#" value="#desRebateData.aProd[i].productGroupForThisProduct#">
			  </cfif> </TD>
			<cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
			  <!---guard against empty strings--->
			  <cfif desRebateData.aCompVal[i][index].rate eq "">
				<cfset desRebateData.aCompVal[i][index].rate = 0.0000 />
			  </cfif>
			  <cfset frmUOM = desRebateData.aCompVal[i][index].UOMID />
			  <cfset compVarReplace = "#request.app_general_functions.replaceHyphen(desRebateData.aProd[i].masterItemId)#_#request.app_general_functions.replaceHyphen(desRebateData.aComp[index].compUUID)#" />
			  <!--- <cfset compVarReplace = "#Replace(desRebateData.aProd[i].masterItemId,"-","_","ALL")#_#Replace(desRebateData.aComp[index].compUUID,"-","_","ALL")#"/> --->
			  <!---set for rebate rules--->
			  <cfset tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent")>
			  <cfset "form.uomsToCheck_#index#" = ListAppend(Evaluate("form.uomsToCheck_#index#"), compVarReplace) />
			  <td width="#component_width#" nowrap style="border-left:solid ##93BEE2 1px; font-size : 10px;">
			  <input name="reb_rule_#compVarReplace#" type="hidden" value="#desRebateData.aCompVal[i][index].ruleId#" /> 
				<!--- If the program is a revision and revision settings has retrictions for this program and product rate cannot be changed --->
				<cfif Revision_Products_Rates_Changes eq 1 and EZButton_Disable EQ 0>
					<input id="#i#_#index#" name="comp_rate_#compVarReplace#" type="text"  size="1" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
						 <cfif  tmpUSDAComp.isUSDANOIComp(desRebateData.aComp[index].compnameID) EQ 1 OR desRebateData.aComp[index].rebate_type EQ 2> Readonly</cfif>
						 <CFIF (desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1>value=""<CFELSE>value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, "(_.____)")#"</CFIF>
						 <CFIF appSettings.getProgram_Allow_Null_Rate() EQ 1>onChange="this.value = formatToDeciamalPlacesAllowNull(this.value,4,1);resetnavigate();"<CFELSE>onChange="this.value = formatToDeciamalPlaces(this.value,4);resetnavigate();"</CFIF>
						 /> 
				<cfelse>
					<input  id="#i#_#index#" name="comp_rate_#compVarReplace#" type="text" size="1" ONKEYUP="clenseText(this,'0123456789.')" 
						 <cfif  tmpUSDAComp.isUSDANOIComp(desRebateData.aComp[index].compnameID) EQ 1> Readonly</cfif>
						 <CFIF (desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1>value=""<CFELSE>value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, "(_.____)")#"</CFIF>
						 <CFIF appSettings.getProgram_Allow_Null_Rate() EQ 1>onChange="this.value = formatToDeciamalPlacesAllowNull(this.value,4,1);resetnavigate();"<CFELSE>onChange="this.value = formatToDeciamalPlaces(this.value,4);resetnavigate();"</CFIF> 
						 <cfif (listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0) OR EZButton_Disable EQ 1>style="font-size:10; background-color: cccccc" DISABLED</cfif>
						/>
					<!--- If the product rate textbox is disabled --->
					<cfif listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0>
					<input  id="#i#_#index#" name="comp_rate_#compVarReplace#" type="hidden" style="font-size:10" 
						 <CFIF (desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1>value=""<CFELSE>value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, "(_.____)")#"</CFIF> 						
						/> 
					</cfif>
				</cfif>
				<!---Modification: Group Deals--->
				<!---if it's a group type then automatically set the uom to %--->
				<cfif desRebateData.aProd[i].isGroup eq 1 and Left(trim(application.returned_customer_setting.customer_keyword), 1) eq "C" and Right(trim(application.returned_customer_setting.customer_keyword), 1) eq "a">
				  % 
				  <input name="uom_#compVarReplace#" type="hidden" value="3" id="c_uom_#i#_#index#"/>
				  <cfelse>
				  	<cfset Disabled = 0>
					<!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made --->
				  <cfif (Revision_Products_UOM_Changes eq 0 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0) OR EZButton_Disable EQ 1>
					<cfset Disabled = 1>
				  </cfif>
				  <cf_uom_dropdown
								program_id				=	"#desRebateData.programID#"
								dropdown_id				=	"c_uom_#i#_#index#"
								company_main_id			=	""
								default_option_on		=	"0"
								default_option_text		=	""
								default_option_value	=	""
								dropdown_name			=	"uom_#compVarReplace#"
								option_text_abbreviated	=	"1"
								plural_uom_display		=	""
								product_type_id			=	"2"
								program_template_id		=	""
								selected_uom_id			=	"#frmUOM#"
								text_before_tag_close	=	"onchange=""resetnavigate();"""
								uom_id_exclusion_list	=	""
								uom_id_inclusion_list	=	""
								productUom				=	"#desRebateData.aProd[i].productInventoryUOM#"
								Disabled				= 	"#Disabled#"
							>
								<cfif Disabled eq 1>
									<input type="hidden" name="uom_#compVarReplace#" value="#frmUOM#">
								</cfif>
							</cfif>
				</td>
				<cfif Display_Basis_Treatment_Code EQ 1>
				<cfif BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) EQ "Y">
					<td width="#component_width#" nowrap>
					
					<input name="comp_basis_code_quantity_#compVarReplace#" type="text"  size="1" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
						 value="#LSNumberFormat(desRebateData.aCompVal[i][index].basisCodeQuantity, "(_.____)")#"
						  <cfif Revision_Products_Rates_Changes eq 0>disabled</cfif>
						/>
					<cfif Revision_Products_Rates_Changes eq 0>
					<input type="Hidden" name="comp_basis_code_quantity_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeQuantity#" />
					</cfif>
						 <cf_uom_dropdown
								program_id				=	"#desRebateData.programID#"
								company_main_id			=	""
								default_option_on		=	"0"
								default_option_text		=	""
								default_option_value	=	""
								dropdown_name			=	"comp_basis_code_quantity_uom_#compVarReplace#"
								option_text_abbreviated	=	"1"
								plural_uom_display		=	""
								product_type_id			=	"2"
								program_template_id		=	""
								selected_uom_id			=	"#desRebateData.aCompVal[i][index].basisCodeQuantityUom#"
								text_before_tag_close	=	"onchange=""resetnavigate();"""
								uom_id_exclusion_list	=	"3"
								uom_id_inclusion_list	=	""
								productUom				=	"#desRebateData.aProd[i].productInventoryUOM#"
								Disabled				= 	"#Disabled#"
							>
						<cfif Disabled>
						<input type="Hidden" name="comp_basis_code_quantity_uom_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeQuantityUom#" />
						</cfif>
					</td>
					<td width="#component_width#" nowrap>
					<input name="comp_basis_code_free_goods_#compVarReplace#" type="text"  size="1" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
						 value="#LSNumberFormat(desRebateData.aCompVal[i][index].basisCodeFreeGoods, "(_.____)")#"
						 <cfif Revision_Products_Rates_Changes eq 0>disabled</cfif>
						/>
					<cfif Revision_Products_Rates_Changes eq 0>
					<input type="Hidden" name="comp_basis_code_free_goods_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeFreeGoods#" />
					</cfif>
						<cf_uom_dropdown
								program_id				=	"#desRebateData.programID#"
								company_main_id			=	""
								default_option_on		=	"0"
								default_option_text		=	""
								default_option_value	=	""
								dropdown_name			=	"comp_basis_code_free_goods_uom_#compVarReplace#"
								option_text_abbreviated	=	"1"
								plural_uom_display		=	""
								product_type_id			=	"2"
								program_template_id		=	""
								selected_uom_id			=	"#desRebateData.aCompVal[i][index].basisCodeFreeGoodsUom#"
								text_before_tag_close	=	"onchange=""resetnavigate();"""
								uom_id_exclusion_list	=	"3"
								uom_id_inclusion_list	=	""
								productUom				=	"#desRebateData.aProd[i].productInventoryUOM#"
								Disabled				= 	"#Disabled#"
							>
						<cfif Disabled>
						<input type="Hidden" name="comp_basis_code_free_goods_uom_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeFreeGoodsUom#" />
						</cfif>
					</td>
				</cfif>
				</cfif>
			</cfloop>
			
			<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
			<td><input name="Like_Product" type="checkbox" value="#desRebateData.aProd[i].masterItemId#" <cfif ListFind(SimilarExistingProductList,desRebateData.aProd[i].masterItemId) neq 0 >CHECKED</cfif>></td>
			</cfif>

			<!---set placeholder cells--->
			<cfset tmp = 6 - componentTDLen />
			<cfloop index="index" from="1" to="#tmp#">
			  <td width="#component_width#">&nbsp; 
				<!--- <img src="/images/fill.gif" width="10">  --->
			  </td>
			</cfloop>
		  </tr>
		</cfloop>
		<INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">
		<!---hidden var to let rebate.cfc update method know when to pull component values from the form scope--->
		<input type="hidden" name="bGetFromForm" value="true" />
		<cfelse>
		<!---handle for group deals--->
		<cfif form.Discount_Rebates_Group_Level eq 1>
		  <cfset noProdWidth = Evaluate(checkbox_width + upc_width + group_width + desc_width) />
		  <!---clear all level and group level fields--->
		  <cfset form.Level_1 = "" />
		  <cfset form.Level_2 = "" />
		  <cfset form.Level_3 = "" />
		  <cfset Form.GroupLevel_1 = "" />
		  <cfset Form.GroupLevel_2 = "" />
		  <cfset Form.GroupLevel_3 = "" />
		  <cfelse>
		  <cfset noProdWidth = Evaluate(checkbox_width + upc_width + desc_width) />
		</cfif>
		<tr bgcolor="##ccffcc"> 
		  <td width="#noProdWidth#"> No product (s) selected<img src="/Images/fill.gif" height="1" width="#noProdWidth#"> 
		  </td>
		  <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
			<td width="#component_width#" nowrap> <input name="comp_rate_#index#" type="text" value="#desRebateData.aCompVal[index].rate#" size="3" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4);resetnavigate(); <cfif desRebateData.aComp[index].rebate_type EQ 2>disabled</cfif>"  /> 
			 		<cfset Disabled = 0>
					<!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made --->
				  <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0>
					<cfset Disabled = 1>
				  </cfif>
			  <cf_uom_dropdown
						program_id				=	"#desRebateData.programID#"
						company_main_id			=	""
						default_option_on		=	"0"
						default_option_text		=	""
						default_option_value	=	""
						dropdown_name			=	"uom_#index#"
						option_text_abbreviated	=	"1"
						plural_uom_display		=	""
						product_type_id			=	"2"
						program_template_id		=	""
						selected_uom_id			=	"#desRebateData.aCompVal[index].UOMID#"
						text_before_tag_close	=	"onchange=""resetnavigate();"""
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	""
						Disabled				= 	"#Disabled#"
					> 
						<cfif Disabled eq 1>
							<input type="hidden" name="uom_#index#" value="#desRebateData.aCompVal[index].UOMID#">
						</cfif>
					</td>
		  </cfloop>
		  <cfset tmp = 6 - ArrayLen(desRebateData.aComp) />
		  <cfloop index="index" from="1" to="#tmp#">
			<td width="#component_width#">&nbsp; 
			  <!---  <img src="/images/fill.gif" width="10">  --->
			</td>
		  </cfloop>
		</tr>
	  </cfif>
	</table>
  </div>
  
<!---loop through the comp array and set hidden variables for component rule validation--->
<cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
	
	<!---param the comp var--->
	<cfparam name="form.uomsToCheck_#index#" default="" />
	<input type="hidden" name="uomsToCheck_#index#" value="#Evaluate("form.uomsToCheck_#index#")#" />
</cfloop>


</cfoutput>
<cfif GetContractInfo.modifying_program EQ 0 and marginedit_saved>
	<cfset overrideClosure = 1>
	<cfset form.programid = '#URL.CID#' />
	<cfinclude template="reset_program_agreed.cfm" />
</cfif>