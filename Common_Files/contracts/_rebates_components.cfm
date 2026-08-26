<cfparam name="form.Sub_Product_List" default="" />
<cfparam name="displayedProductList" default="">
<CF_CRYP type="de" string="#CID#" key="#request.key#">
<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(cryp.value)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(desRebateData.programId) />
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<cfset showrebateadditionalfields = appSettings.getshowrebateadditionalfields()>
<cfset UseFixedPriceType = appSettings.getUseFixedPriceType()>
<cfset Product_Group_Sequencing = appSettings.get_Setting('Product_Group_Sequencing')>
<cfset AllowMultiLevelGroups = appSettings.getAllowMultiLevelGroups() >
<cfset upc_switch = application.returned_customer_setting.upc_switch>
<cfset Display_Item_No = application.appSettingsget.get_Setting('Display_Item_No')>
<cfset customer_setting_error_string = application.returned_customer_setting.customer_setting_error_string>

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
<!--- use page number to get start and end row --->
<cfset variables.startRow = rebate.getStartRow(form.pageNum) />
<cfset variables.endRow	= rebate.getEndRow(form.pageNum) />

<cfif variables.startRow GT variables.getRebateProdIds.recordCount and form.pageNum neq 1>
	<cfset form.pageNum = 1 />
	<cfset variables.startRow = rebate.getStartRow(form.pageNum) />
	<cfset variables.endRow	= rebate.getEndRow(form.pageNum) />
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 startxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the competitor list --->
<cfset CompetitorList = programManager.getCompetitorList(CSL_Contract_Main_ID)>
<cfset variables.fixed_price_type_bgcolor = "" />
<cfset variables.svfixed_price_type_bgcolor = "F2ACA5" />
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 endxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>
<style>
              select,input{font-size:10;  }
              .tdwrap {word-wrap:break-word;}
</style>
<cfset checkbox_width=20>
<cfset base_sales_width=65>
<cfset disc_perc_width=45>
<cfset saveButton_width=35>
<cfset upc_width=115>
<cfset level_width=40>
<cfset group_width=80>
<cfset desc_width=150>
<cfset component_width=92>
<cfset competitor_width=120>
<cfset distCost_width=55>
<cfset timeFrame_width=75>
<cfset groupNumber_width=125>
<cfset footerTip = "none" />
<cfif ArrayLen(desRebateData.aProd) gt 10>
       <cfset divHght = "height:270px;" />
       <cfset divTableWidth = "850" />
<cfelse>
       <cfset divHght = "" />
       <cfset divTableWidth = "850" />
</cfif>
<cfif GetSettings.Include_Competitive_Data_Tracking EQ 1>
       <cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
       <cfset getCompetitiveProductsInfo = bidRequestProdMan.getpreviousinfo(CSL_Contract_Main_ID)>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxD28445 startxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<cfquery NAME="getFixedComponentInfo" datasource="#application.datasource#">
       SELECT PFCN.Program_Fixed_Component_Name,
       PFCN.Program_Fixed_Component_Name_Id,
       PFCN.fixed_price_type
       FROM   Program_Fixed_Component_Name PFCN
       INNER JOIN Program_Fixed_Component PFC
       ON                   PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
       WHERE PFCN.DELETED = 0
       AND           PFC.Program_ID = #CSL_Contract_Main_ID#
       AND           PFC.Deleted = 0
       AND           PFCN.fixed_price_type IN (1,3)
</cfquery>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxD28445 endxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<cfif EzButton_Disable EQ 1>
       <cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />
       <cfset GetEZButtonDefaultRates = EZProgramManager.getRebateEZSettings(Latest_EZ_Contract_ID,form.Product_List)>
</cfif>
<cfset rowspan = 1 />
<cfif Display_Basis_Treatment_Code EQ 1>
       <cfset rowspan = 2 />
</cfif>
<!--- 62343 8.0 - Blended Rate START --->
<!---Query 1: Query to get volume for blended rate for groups/items in program – can be used in CF--->
	<cfquery name="qGetVolumeForBR" datasource="#application.datasource#">
		<!---Groups--->
		SELECT cp.bsa_FoodService_Items_Master_Id, SUM(Invoice_Volume) as Invoice_Volume, SUM(Invoice_Volume_LB) as Invoice_Volume_LB, SUM(Recapture_Volume) as Recapture_Volume, SUM(Recapture_Volume_LB) as Recapture_Volume_LB
		FROM   Contract_Products cp
		INNER JOIN Program_Rebates_Product_Data pr
		ON            pr.Contract_Products_Id = cp.Contract_Products_Id
		AND           pr.Deleted = 0
		INNER JOIN Program_Rebates_Component_Data prcd
		ON            prcd.Program_Rebates_Product_Data_Id = pr.Program_Rebates_Product_Data_Id
		AND           prcd.Deleted = 0
		INNER JOIN Contract_Products cp2
		ON            cp2.Contract_Main_Id = cp.Contract_Main_Id
		AND           cp2.Deleted = 0
		AND           cp2.Product_Type_Id = 2
		AND           cp2.Product_Group_ID = cp.bsa_FoodService_Items_Master_Id
		AND           cp2.Captured_From_Group = 1
		INNER JOIN Program_Blended_Rate_Info b
		ON            b.Program_ID = cp.Contract_Main_Id
		AND           b.Product_ID = cp2.bsa_FoodService_Items_Master_Id
		WHERE  cp.Contract_Main_Id = #CSL_Contract_Main_ID#
		AND           cp.Deleted = 0
		AND           cp.Product_Type_Id = 2
		AND           cp.Is_Group = 1
		Group BY cp.bsa_FoodService_Items_Master_Id
		union
		<!--- Individual Items --->
		SELECT cp.bsa_FoodService_Items_Master_Id, Invoice_Volume, Invoice_Volume_LB, Recapture_Volume, Recapture_Volume_LB
		FROM   Contract_Products cp
		INNER JOIN Program_Rebates_Product_Data pr
		ON            pr.Contract_Products_Id = cp.Contract_Products_Id
		AND           pr.Deleted = 0
		INNER JOIN Program_Rebates_Component_Data prcd
		ON            prcd.Program_Rebates_Product_Data_Id = pr.Program_Rebates_Product_Data_Id
		AND           prcd.Deleted = 0
		INNER JOIN Program_Blended_Rate_Info b
		ON            b.Program_ID = cp.Contract_Main_Id
		AND           b.Product_ID = cp.bsa_FoodService_Items_Master_Id
		WHERE  cp.Contract_Main_Id = #CSL_Contract_Main_ID#
		AND           cp.Deleted = 0
		AND           cp.Product_Type_Id = 2
		AND           cp.Is_Group = 0
		AND           cp.Captured_From_Group = 0
	</cfquery>
<!--- 62343 8.0 - Blended Rate END --->
<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release START--->
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<style>
.dataTables_wrapper{
	width: 1100px;
}
.on-hover-content{
	overflow:visible;
	display:none;
	z-index: 500000000;
	position:absolute;
	width:200px;
	height:px;
	border:2px Navy solid;
	padding:5px;
	background-color:##FFF8DC;
	font-size:10px;
	margin-left:-220px;
	margin-top: -20px;
}
.header{
	text-align: left;
}
.multiAssign{
	float:right;
}
.maxProducts{
  float: left;
  width:200px;
  padding-left: 15px;
}
.bulletPoints{
  float: left;
}
.save{
	clear:both;
	padding-bottom:5px;
}
/* Dev Note:71380- When a user views the application in French, then the length of the text
of a few entries on the Left NAV can be long, which causes issues like "not being able to delete products(s)"
and perhaps other issues as well. Added a margin so that the text does not overlap.
*/
.clBox,.save,.top_header,##save_table{margin-left:15px;}
.datagrid,.dataTables_filter{margin-left:15px !important;}
</style>

<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<div class="customContainer" style="display:none;"></div>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->
<table class="showmessage"  bgcolor="White" style="border-color:Orange;border-style:solid;margin:5px;display:none;" cellpadding="3" cellspacing="0"  align="center" width="800">
  <tr>
    <td align="center">
        <font size="2">
          <b>Rate(s) has updated succesfully !</b>
        </font>
    </td>
  </tr>
</table>
<br>
	<!--- 62343 8.0 - Blended Rate, CF START  --->
	<cfset PrgHasBlendedRateComp = 0>
	<cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
		<cfif desRebateData.aComp[index].Blended_Rate_On>
			<cfset PrgHasBlendedRateComp = 1>
		<cfbreak>
		</cfif>
	</cfloop>
	<input type="hidden" name="Prg_Has_Blended_Rate_Comp" value="#PrgHasBlendedRateComp#" />
	<!--- 62343 8.0 - Blended Rate, CF END--->

<table id="datagrid" class="datagrid">
       <thead>
        <tr>
       <th class="header" style="width:48px">
              <!--- If the program is a revision and revision settings has retrictions for this program and products cannot be removed --->
              <cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2)>
	      		<img id="scissorAllProd" bDelete="true" sMessage="delete all products" src="/images/scissor.gif" title="delete all products in this page" border="0"
                     onclick="deleteAllProductsOptions();"
                     style="cursor: pointer; <cfif form.bFromMargin>display: none;</cfif>">
              <cfelse>
                     &nbsp;
              </cfif><input name="prodCheck" type="checkbox" onClick="checkAllProd()" checked>
       </th>
       <th class="header" width="125px">
              <cfif (upc_switch NEQ customer_setting_error_string)
                     AND (upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1)>
                     #application.returned_customer_setting.upc_label#<br>
              </cfif>
              <cfif Display_Item_No eq '1'>
              	#application.returned_customer_setting.item_label#
				<cfif GetSettings.Discount_Rebates_Group_Level> /Group </cfif>##
              </cfif>
       </th>

       <!---Modification: Group Deals--->
       <cfif Form.Discount_Rebates_Group_Level eq 1 and AllowMultiLevelGroups and Product_Group_Sequencing eq '0'>
              <th class="header">Level<br>Group</th>
       </cfif>
       <th class="header">Description</th>
       <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxD27183 startxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
       <cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type>
              <th class="header">#appSettings.getBaseSaleLabel()#</th>
       </cfif>

       <cfset componentTDLen = 0 />
	   <cfset ExistingPricingLevelList = "">
       <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
              <!---param the comp var--->
              <cfparam name="form.uomsToCheck_#index#" default="" />
              <!---get the name of the component with the id that's in the data struct--->
              <cfscript>
              qCompName = comp.getComp(desRebateData.aComp[index].compNameId);
              qGetActiveComps = comp.getActive(ProgramID = GetContractInfo.Contract_Main_ID);
              qGetCompRuleUoms = compBusRule.getCompRuleUoms(desRebateData.aComp[index].compNameId);
              </cfscript>
              <!--- D11147 BJF Component product restrictions        Set product restriction query here so there are fewer iterations --->
              <cfif appsettings.getComponent_Product_Restrictions_On()>
                     <cfset CompID = desRebateData.aComp[index].compNameId>
                     <cfset useLakebaseForQuery_#CompID# = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_products_restricted")>
<cfif useLakebaseForQuery_#CompID#>
	<cftry>
		<cfset Query_#CompID# = application.oLakebase.toQuery(
			application.oLakebase.selectRows("component_products_restricted", {
				"discount_type_id" = "eq.2 --Rebate",
				"component_id" = "eq.#CompID#",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForQuery_#CompID# = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForQuery_#CompID#>
<cfquery name="Query_#CompID#" datasource="#application.datasource#">
                            SELECT Product_ID
                            FROM Component_Products_Restricted
                            WHERE Discount_Type_ID = 2 --Rebate
                            AND Component_ID = '#CompID#'
                     </cfquery>
</cfif>
              </cfif>
              <cfset componentNamePopupWidth = 200 />
              <cfset componentColSpan = 1 />
              <cfset componentColWidth = 1 />
              <cfif desRebateData.aComp[index].rebate_type EQ 4>
                     <!----- if this is a scan component ----->
                     <cfset componentColSpan = component_width + 30 />
              </cfif>
              <cfif Display_Basis_Treatment_Code EQ 1>
                     <cfif BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) EQ "Y">
                            <cfset componentColSpan = componentColSpan + 1 />
                            <cfset componentColWidth = componentColWidth + 1 />
                            <cfset componentTDLen = componentTDLen + 1 />
                     </cfif>
                     <cfif desRebateData.aComp[index].EffectiveMarginFlag EQ 1>
                            <!------ Effective Margin % ----->
                            <cfset componentColSpan = componentColSpan + 1 />
                            <cfset componentColWidth = componentColWidth + 0.5 />
                            <cfset componentTDLen = componentTDLen + 1 />
                     </cfif>
              </cfif>
              <cfif len(trim(qCompName.Allowance_Code_ID))>
                     <cfset thisTmpAllowanceCode = qCompName.Allowance_Code_ID />
              <cfelse>
                     <cfset thisTmpAllowanceCode = 0 />
              </cfif>
              <!---TSF - Label 11426: Display Allowance Code in the Component Title--->
              <cfset useLakebaseForqGetAllowanceCodeNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetactivecomps")>
<cfif useLakebaseForqGetAllowanceCodeNumber>
	<cftry>
		<cfset qGetAllowanceCodeNumber = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetactivecomps", {
				"allowance_code_id" = "eq.#thisTmpAllowanceCode#",
				"select" = "allowance_code_number"
			}), "allowance_code_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAllowanceCodeNumber = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAllowanceCodeNumber>
<cfquery name="qGetAllowanceCodeNumber" dbtype="query">
                     SELECT Allowance_Code_Number
                     FROM   qGetActiveComps
                     WHERE  Allowance_Code_ID = #thisTmpAllowanceCode#
              </cfquery>
</cfif>
              <cfset componentTDLen = componentTDLen + 1 />
              <th class="header" nowrap>
                     <cfif URL.EZTemplate EQ 1>
                            <!--- If inside ez template do nto show component name and other details --->
                            <strong>Rate</strong>
                     </cfif>

                     <!--- Dev Note: drachala; D28458: When using rebate page multi assign tool auto check component  START
                     What  I did: Added CSLGetContractInfo.Single_Component_Per_Discount_Type if EQ 1 check the Check Box--->
                     <cfif desRebateData.aComp[index].IsSecondComponent eq 0>
                     <input name="comp" type="checkbox" value="#index#" <cfif CSLGetContractInfo.Single_Component_Per_Discount_Type>Checked</cfif>>
                     </cfif>

                     <cfif URL.EZTemplate NEQ 1>
                            <cfif not form.bFromMargin AND desRebateData.aComp[index].IsSecondComponent eq 0>
                                  <a STYLE="cursor: pointer;" ONCLICK="verifyDeleteComponent('#desRebateData.aComp[index].compID#', '#replace(qCompName.Program_Rebates_Component_Name, "'", "\'")#')">
                                    <img src="/Images/scissor.gif"  title="delete this component" border="0">
                                  </a>
                            </cfif>
                     </cfif>

                     <cfif URL.EZTemplate EQ 0>
                            <!--- End Dev Note: drachala; D28458: CSLGetContractInfo.Single_Component_Per_Discount_Type  --->
                            <cfset additionalInfo = "" />
                            <cfset HelpHeight = 16>
                            <cfset HelpWidth = 150>
                            <!---if the component type is 1 then we pay to distributor, otherwise it's operator---->
                            <cfsavecontent variable="additionalInfo">#additionalInfo#
                            Paid To:
                            #templateManager.getPaymentPaidToTypeDesc(paidToID = desRebateData.aComp[index].componentPaidTo, paidToDesc="")#
                            <!--- Dev Note: drachala; D29214 : Hormel - Brackets and Rebate  START
                            Added/Changed: Added if condition if it true will display Price bracket--->
                            <cfif UseFixedPriceType EQ 1>
                                  <br>Price Bracket: #ListLast(CSLGetContractInfo.Price_List_ID, "_")#
                            </cfif>
                            <!--- End Dev Note: drachala; D29214: Hormel - Brackets and Rebate  --->
                            </cfsavecontent>
                            <!--- if claim mech at component level is on, display ---->
                            <cfif appSettings.getClaims_at_Comp_Level()>
                                  <cfset HelpHeight = HelpHeight + 16>
                                  <cfset HelpWidth = 250>
                                  <cfsavecontent variable="additionalInfo">#additionalInfo#
                                  <br>Claim Mechanism: #paymenttypeManager.getDesc(desRebateData.aComp[index].Claim_Mechanics)#
                                  </cfsavecontent>
                            </cfif>
                            <cfif Display_Basis_Treatment_Code EQ 1>
                                  <cfset HelpHeight = HelpHeight + 16>
                                  <cfset HelpWidth = 250>
                                  <cfsavecontent variable="additionalInfo">#additionalInfo#
                                  <br>Treatment Code: #TreatmentCodeManager.getTreatmentCodeDesc(desRebateData.aComp[index].TreatmentCode)#
                                  <br>Basis Code: #BasisCodeManager.getBasicCodeDesc(desRebateData.aComp[index].BasisCode)#
                                  </cfsavecontent>
                            </cfif>

                            <cfif not form.bFromMargin>
                                  <a onClick="JavaScript: openPopup('ezprogram_editcomponent.cfm?download=1&ModifyDeletedPrograms=#ModifyDeletedPrograms#&copNameIndx=#index#&programid=#GetContractInfo.contract_main_id#&discounttypeid=2&PaidTo=#desRebateData.aComp[index].componentPaidTo#&GL_Account_ID=#desRebateData.aComp[index].GL_Account_ID#&VENDOR_MASTER_ID=#desRebateData.aComp[index].VENDOR_MASTER_ID#&PaymentCycle=#desRebateData.aComp[index].PaymentCycle#&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&Formname=dataForm&compid=#desRebateData.aComp[index].compNameId#&Claim_Mechanics=#desRebateData.aComp[index].Claim_Mechanics#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&VendorSelection=#desRebateData.aComp[index].VendorSelection#&Payee_Selection=#Payee_Selection#&Business_Segment_ID=#businessSegmentID#&IsSecondComponent=#desRebateData.aComp[index].IsSecondComponent#', 440, 700)" title="#qCompName.Program_Rebates_Component_Name#" STYLE="cursor: pointer;">
                                  #application.util.string.actionLinkFormat("edit")#
                                  </a>
                            </cfif>
                            <br>
                           <!------ Display additional info ----->
                            <cfif Len(additionalInfo)>
                                  <cfif form.bFromMargin>
                                         <cfset structDelete(variables, "SmallHelpScriptAdded", "True")>
                                  </cfif>
    															<div class="on-hover-content" style="display:none;"> #additionalInfo# </div>
                            </cfif>
                           <span class="addinfo" style="cursor:pointer">
                            <cfif len(qCompName.Program_Rebates_Component_Name) LTE 15 OR desRebateData.aComp[index].Blended_Rate_On>
                            	#qCompName.Program_Rebates_Component_Name#
                            <cfelse>
                                  #replace(qCompName.Program_Rebates_Component_Name,' ','<br>', 'first')#
                            </cfif>
                           </span>
                           <!--- 62343 8.0 - Blended Rate, CF START  --->
                           	<cfif desRebateData.aComp[index].Blended_Rate_On>
																<br><span><input type="text" name="Base" value="Base"  size="5"  disabled="disabled" style="background-color:##ffce84;color: black;border:none;font-weight: bold;" /></span>
                                        <span><input type="text" name="Disc" value="Disc"  size="5"  disabled="disabled" style="background-color:##ffce84;color: black;border:none;font-weight: bold;" /></span>
                                        <span><input type="text" name="Calc" value="Calc"  size="5"  disabled="disabled" style="background-color:##ffce84;color: black;border:none;font-weight: bold;" /></span>
                                        <span><input type="text" name="Adj" value="Adj"  size="5"  disabled="disabled" style="background-color:##ffce84;color: black;border:none;font-weight: bold;" /></span>
														</cfif>
														<!--- 62343 8.0 - Blended Rate, CF END  --->
                     </cfif>
                     <!---hidden form vars holding component data--->
                     <input type="hidden" name="compNameId_#index#" value="#desRebateData.aComp[index].compNameId#" />
                     <input type="hidden" name="compHasRules_#index#" value="#qCompName.Has_Rules#" />
                     <input type="hidden" name="compRulesReq_#index#" value="#qCompName.Rule_Required#" />
                     <input type="hidden" name="rebate_type_#index#" value="#qCompName.rebate_type#" />
                     <input type="hidden" name="lCompRuleUoms_#index#" value="#ValueList(qGetCompRuleUoms.Unit_Of_Measure_ID)#" />
                     <input type="hidden" name="compPaidTo_#index#" value="#desRebateData.aComp[index].componentPaidTo#" />
                     <input type="hidden" name="GL_Account_ID_#index#" value="#desRebateData.aComp[index].GL_Account_ID#" />
                     <input type="hidden" name="Claim_Mechanics_#index#" value="#desRebateData.aComp[index].Claim_Mechanics#" />
                     <input type="hidden" name="Vendor_Master_ID_#index#" value="#desRebateData.aComp[index].Vendor_Master_ID#" />
                     <input type="hidden" name="VendorSelection_#index#" value="#desRebateData.aComp[index].VendorSelection#" />
                     <input type="hidden" name="PaymentCycle_#index#" value="#desRebateData.aComp[index].PaymentCycle#" />
                     <input type="hidden" name="Payee_Selection_#index#" value="#desRebateData.aComp[index].Payee_Selection#" />
                     <!--- 62343 8.0 - Blended Rate, CF START  --->
                     <input type="hidden" name="Blended_Rate_On_#index#" value="#desRebateData.aComp[index].Blended_Rate_On#" />
                     <input type="hidden" name="Blended_Start_Date_#index#" value="#desRebateData.aComp[index].Blended_Rate_from_date#" />
                     <input type="hidden" name="Blended_End_Date_#index#" value="#desRebateData.aComp[index].Blended_Rate_to_date#" />
                     <input type="hidden" name="Force_Run_Blended_Vol_#index#" value="0" />
                     <!--- 62343 8.0 - Blended Rate, CF END  --->
                     <input type="hidden" name="IsSecondComponent_#index#" value="#desRebateData.aComp[index].IsSecondComponent#" />
                     <cfset "form.uomsToCheck_#index#" = "" />
              </th>
              <!--- D38536  :: Alternate recapture rates per component START--->

              <cfif isDefined("qCompName.Alternate_Recapture_Rate") and qCompName.Alternate_Recapture_Rate EQ 1>

                     <cfset useLakebaseForAlternateRateSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alternate_recapture_rate_setting")>
<cfif useLakebaseForAlternateRateSettings>
	<cftry>
		<cfset AlternateRateSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alternate_recapture_rate_setting", {
				"program_rebates_component_name_id" = "eq.#qCompName.Program_Rebates_Component_Name_ID#",
				"status" = "eq.0",
				"select" = "alternate_recapture_rate_label"
			}), "alternate_recapture_rate_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAlternateRateSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAlternateRateSettings>
<cfquery name="AlternateRateSettings" datasource="#application.datasource#">
                            SELECT Alternate_Recapture_Rate_Label
                            FROM Alternate_Recapture_Rate_Setting
                            WHERE Program_Rebates_Component_Name_ID = #qCompName.Program_Rebates_Component_Name_ID#
                            AND Status = 0
                     </cfquery>
</cfif>
                     <cfset Alternate_Rate_width = #component_width# + 11>
                     <cfloop query="AlternateRateSettings">
                            <th class="header">
                                  <input name="AR_MassApply_#desRebateData.aComp[index].compnameid#_#AlternateRateSettings.currentrow#" type="checkbox" value="1">
                                  <br>#ucase(Alternate_Recapture_Rate_Label)#
                            </th>
                     </cfloop>
              <cfelse>
                     <input name="AR_MassApply_0" type="checkbox" value="1" checked="checked" style="display:none;">
              </cfif>
              <!--- D38536  :: Alternate recapture rates per component END--->
              <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxD27183 startxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
              <cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type>
                     <th class="header" nowrap><b>Net Sales</b>&nbsp;&nbsp;</th>
                     <th class="header" nowrap><b>Disc %</b>&nbsp;&nbsp;</th>
              </cfif>
              <th class="header"  style="display:none;"></th>
              <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxD27183 endxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
       </cfloop>
       <cfif UseFixedPriceType and URL.EZTemplate EQ 0 AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1>
              <th class="header" nowrap >
                     Comp Name
              </th>
              <th class="header" nowrap >
                     Dist Cost
              </th>
              <th class="header" nowrap >
                     Time Frame
              </th>
        <cfelse>
        	<cfif variables.getRebateProdIds.recordcount>
        	<th class="header"  style="display:none;">&nbsp;</th>
        	</cfif>
       </cfif>
       <cfif CSLGetContractInfo.Like_Product_Exist eq 1>
              <th class="header">Similar<br />Product</th>
       </cfif>
       <!--- this is for the SAVE Button at the row level --->
       <cfif ArrayLen(desRebateData.aComp)>
              <th class="header" style="width:48px">&nbsp;</th>
        </cfif>
        </tr>
       <cfif Display_Basis_Treatment_Code EQ 1>
              <tr>
                     <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
                            <!---get the name of the component with the id that's in the data struct--->
                            <cfscript>
                            qCompName = comp.getComp(desRebateData.aComp[index].compNameId);
                            qGetActiveComps = comp.getActive(ProgramID = GetContractInfo.Contract_Main_ID);
                            qGetCompRuleUoms = compBusRule.getCompRuleUoms(desRebateData.aComp[index].compNameId);
                            </cfscript>
                            <cfif BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) NEQ "Y">
                                  <th class="header" nowrap id="header" style="border-left:solid ##93BEE2 1px;" align="center"> rate</th>
                            <cfelse>
                                  <th class="header" nowrap id="header" style="border-left:solid ##93BEE2 1px;" align="center">buy</th>
                                  <th class="header" nowrap id="header" align="center">get free</th>
                            </cfif>
                            <cfif desRebateData.aComp[index].EffectiveMarginFlag EQ 1>
                                  <!------ Effective Margin % ----->
                                  <th class="header" nowrap id="header" align="center" title="Effective Margin %">Eff %</th>
                            </cfif>
                     </cfloop>
              </tr>
       </cfif>

       </thead>
       <tbody>
              <cfset tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent")>
              <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
                     <cfset "USDAComp_#desRebateData.aComp[index].compnameID#" =  tmpUSDAComp.isUSDANOIComp(desRebateData.aComp[index].compnameID)>
              </cfloop>

	  		<!---if we have product data then loop through--->
	  		<cfif ArrayLen(desRebateData.aProd)>
        		<!--- ENDS LINE 680 --->
        			<cfset variables.productCount = 0 />
					<!--- "displayedProductList" is a list of products which are being displayed. Not the hidden ones or the ones which are on another page. --->
					<cfset displayedProductList = "">
				<cfloop query="variables.getRebateProdIds" startrow="#variables.startRow#" endrow="#variables.endRow#">
		  			<cfset i = variables.getRebateProdIds.arIndex />
          				<cfset variables.productCount = variables.productCount + 1 />
		  			<cfset stripProdId = request.app_general_functions.replaceHyphen(desRebateData.aProd[i].masterItemId) />
		  			<cfparam name="request.menuId" default="6" />
		  			<cfset request.theMOId = desRebateData.aProd[i].masterItemId />
		  			<cfparam name="tmpBgColor" default="ccffcc" />
				<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to "ExistingPricingLevelList".
				This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
				Note: we set "variables.productCount" back to 1, so that the color coding can restart for a new group.
				thisGroupLevelDesc i.e., "group_level_desc" is shown on a single row for every pricing level.
				--->
				<cfif Product_Group_Sequencing eq '1'>
					<cfif Form.Discount_Rebates_Group_Level eq 1 and AllowMultiLevelGroups and ListFind(ExistingPricingLevelList,desRebateData.aProd[i].pricingLevel) eq 0>
						<cfset variables.productCount = 1>
						<cfset thisGroupLevelDesc = GroupDataManager.getProductGroupsData(desRebateData.aProd[i].productGroupLevel).Group_Level_Desc />
						<cfif trim(thisGroupLevelDesc) eq "">
							 <cfset thisGroupLevelDesc = "Product" />
						</cfif>
						<!--- (Start) Dev Note (77408): Note: Since for datatables, colspan="100%" did not work, I needed to add different cells. The logic for the different cells comes from the datables towards the end
						of the file.
						--->
						<tr>
						   <td bgcolor="##92B792"></td>
						   <td bgcolor="##92B792">#thisGroupLevelDesc#</td>
							<td bgcolor="##92B792"></td>
							<cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type>
							<td bgcolor="##92B792"></td>
							 </cfif>
							 <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
							<td bgcolor="##92B792"></td>
								<cfquery name="AlternateRateSettings" datasource="#application.datasource#">
									SELECT Alternate_Recapture_Rate_Label
									FROM Alternate_Recapture_Rate_Setting
									WHERE Program_Rebates_Component_Name_ID = #desRebateData.aComp[index].compNameId#
									AND Status = 0
								</cfquery>
							 <cfloop query="AlternateRateSettings">
							<td bgcolor="##92B792"></td>
							</cfloop>
							<cfif showrebateadditionalfields AND GetSettings.Single_Component_Per_Discount_Type>
							<td bgcolor="##92B792"></td>
							<td bgcolor="##92B792"></td>
							</cfif>
							<td bgcolor="##92B792" style="display:none"></td>
							</cfloop>
							 <cfif UseFixedPriceType and URL.EZTemplate EQ 0 AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1>
							 <td bgcolor="##92B792"></td>
							 <td bgcolor="##92B792"></td>
							 <td bgcolor="##92B792"></td>
							<cfelse>
							<cfif variables.getRebateProdIds.recordcount>
							 <td bgcolor="##92B792" style="display:none"></td>
							</cfif>
							</cfif>
							<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
								<td bgcolor="##92B792"></td>
							</cfif>
							 <cfif ArrayLen(desRebateData.aComp)>
								<td bgcolor="##92B792"></td>
							 </cfif>
						</tr>
						<cfif Form.Discount_Rebates_Group_Level eq 1 and Len(trim(desRebateData.aProd[i].pricingLevel)) and trim(desRebateData.aProd[i].pricingLevel) neq 0>
							<cfset ExistingPricingLevelList = ListAppend(ExistingPricingLevelList,desRebateData.aProd[i].pricingLevel)>
						</cfif>
					</cfif>
				</cfif><!--- END Product_Group_Sequencing eq '1' --->
				<!--- (End) Dev Note (77408): Note: Since for datatables, colspan="100%" did not work, I needed to add different cells. The logic for the different cells comes from the datables towards the end
				of the file.
				--->

				<!--- http://tools.awayx.com/punchlist/index_view.cfm?RID=81604 --->
				<cfif desRebateData.aProd[i].isGroup eq 1>
					<cfset request.menuId  = 11>
					<cfset request.theMOId = "#desRebateData.aProd[i].productGroupID#&Group_Level_ID=#desRebateData.aProd[i].productGroupLevel#&programId=#CSLGetContractInfo.Contract_Main_ID#&producttype_id=2">
				<cfelse>
					<cfset request.menuId  = 6>
					<cfset request.theMOId = desRebateData.aProd[i].masterItemId>
				</cfif>

		  	<tr id="compRow_#i#"
		  	<!--- 62343 8.0 - Blended Rate, CF START  --->
		  	<cfif desRebateData.aProd[i].Blended_Adj_Rate GT 0>
		  		bgcolor=##FFFF33 origbgcolor="FFFF33"
		  	<cfelse>
		  		bgcolor="###iif(variables.productCount MOD 2,DE('ffffff'),DE('ccffcc'))#" origbgcolor="#iif(variables.productCount MOD 2,DE('ffffff'),DE('ccffcc'))#"
		  	</cfif>
		  	<!--- 62343 8.0 - Blended Rate, CF END  --->
		  	onmouseover="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;"
		  	onmouseout="menuID=0;doNotRelocate=0;"
		  	style="cursor: help;">
                            <td>
		  			<!---Modification: Group Deals--->
		  			<cfif Form.Discount_Rebates_Group_Level eq 1>
		            			<!---set groups in the proper levels--->
						<cfif Len(trim(desRebateData.aProd[i].pricingLevel)) and trim(desRebateData.aProd[i].pricingLevel) neq 0>
							<!---check for duplicate in level lists--->
							<cfif isdefined("form.Level_#desRebateData.aProd[i].pricingLevel#") AND not ListFindNoCase(Evaluate("form.Level_#desRebateData.aProd[i].pricingLevel#"), desRebateData.aProd[i].masterItemId)>
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
						          <input type="hidden" name="groupNumber_#stripProdId#" value="#desRebateData.aProd[i].groupNumber#" />

						<cfif desRebateData.aProd[i].isGroup eq 1>
							<cfset request.menuId = 11 />
							<cfset request.theMOId = "#desRebateData.aProd[i].productGroupID#&Group_Level_ID=#desRebateData.aProd[i].productGroupLevel#&Program_ID=#desRebateData.programId#" />
						<cfelse>
							<cfset request.menuId = 6 />
							<cfset request.theMOId = desRebateData.aProd[i].masterItemId />
						</cfif>
		  			</cfif>

                                  <cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2  AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0)>
                                         <cfparam name="form.GroupLevel_#desRebateData.aProd[i].pricingLevel#" default="" />
										 <span class="imgDeleteScissor">
	                                         <img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"
	                                         title="click here to delete this product" border="0"
	                                         onclick="deleteThisRebate('#stripProdId#', '#desRebateData.aProd[i].masterItemId#', '#tmpBgColor#', '#desRebateData.aProd[i].pricingLevel#','#Evaluate("form.GroupLevel_#desRebateData.aProd[i].pricingLevel#")#','#desRebateData.aProd[i].CONTRACTPRODID#','#bAutoAddComponent#')"
	                                         style="cursor: pointer;<cfif form.bFromMargin>       display: none;</cfif>">
										 </span>
                                  <cfelse>
                                         &nbsp;
                                  </cfif>
                                  <input name="prodChkBx_#stripProdId#" type="checkbox" value="#desRebateData.aProd[i].masterItemId#" tabindex="-1" checked>
                            </td>
                            <td>
                                  <cfif upc_switch NEQ customer_setting_error_string>
                                         <cfif upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>
                                                #trim(desRebateData.aProd[i].upc)#<br>
                                         </cfif>
                                  </cfif>

								<cfif Display_Item_No eq '1' AND desRebateData.aProd[i].GroupNumber eq "">
									#trim(desRebateData.aProd[i].item)#
								</cfif>
								<cfif GetSettings.Discount_Rebates_Group_Level AND len(desRebateData.aProd[i].groupNumber) gt 0>
									#desRebateData.aProd[i].groupNumber#
								</cfif>

                                  <!--- D30357:Today's Price Wrong on Revision History START--->
                                  <input type="hidden" name="base_sales_cs_#stripProdId#" value="#desRebateData.aProd[i].basesalescs#"/>
                                  <!--- D30357:Today's Price Wrong on Revision History END--->
                            </td>

                            <!---strip our the double quotes--->
                            <cfset thisDesc = REReplaceNoCase(desRebateData.aProd[i].description, '"', ' ', 'ALL') />
                            <!---Modification: Group Deals--->
                            <cfif Form.Discount_Rebates_Group_Level eq 1 and Product_Group_Sequencing eq '0'>
								<!---Modification: Group Deals--->
								<!---get the group level desc--->
								<cfset thisGroupLevelDesc = CreateObject("component", "components.products.Group.DataManager").getProductGroupsData(desRebateData.aProd[i].productGroupLevel).Group_Level_Desc />
								<cfif trim(thisGroupLevelDesc) eq "">
									 <cfset thisGroupLevelDesc = "Product" />
								</cfif>
								<cfif Form.Discount_Rebates_Group_Level eq 1 and AllowMultiLevelGroups>
								   <td width="#group_width#"  nowrap> #replace(desRebateData.aProd[i].pricingLevelDesc,'/','-', 'ALL')#/<br> #thisGroupLevelDesc#</td>
								</cfif>
                            </cfif>
                            <td>
                            	  <input name="volume_#i#" type="hidden" value="#desRebateData.aProd[i].volume#" />
                                  #replace(desRebateData.aProd[i].description,'/','-', 'ALL')#<br>
                                  <cfif GetSettings.Include_Competitive_Data_Tracking EQ 1>
                                         <cfset useLakebaseForgetcompetitiveinfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcompetitiveproductsinfo")>
<cfif useLakebaseForgetcompetitiveinfo>
	<cftry>
		<cfset getcompetitiveinfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcompetitiveproductsinfo", {
				"product_id" = "eq.#desRebateData.aProd[i].masterItemId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetcompetitiveinfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetcompetitiveinfo>
<cfquery name="getcompetitiveinfo" dbtype="query">
                                                SELECT *
                                                FROM getCompetitiveProductsInfo
                                                WHERE product_id = '#desRebateData.aProd[i].masterItemId#'
                                         </cfquery>
</cfif>
                                         <!---
                                         I removed the height from the customtag below. On IE 10, and IE 9 we do not need the height but do need the width.
                                         In fact if the height is added on IE 10, then that exact height is applied and if the data size is more than the height, then
                                          some of the information is hidden.
                                         //height = "50"
                                         --->
	<CFMODULE template="/CustomTags/SmallHelp.cfm"
			width = "300"
			imgPath="/Images/Asterix.gif"
			imgWidth="10"
			imgHeight="10"
			backgroundColor="FFFFFF"
			borderColor="black"
			borderWidth="1"
			>

                                         <table>
                                    <tr>
                                           <td><strong>Previous Won By</strong></td>
                                           <td><strong>Previous Won By Price</strong></td>
                                           <td><strong>Delivery Type</strong></td>
                                    </tr>
                       <cfloop query="getcompetitiveinfo">
                             <cfif #getcompetitiveinfo.won# EQ 1>
                                    <tr>
                                           <td>#getcompetitiveinfo.won_by_client#</td>
                                           <td>#numberformat(getcompetitiveinfo.won_by_client_Price,"_,___,____.____")#/<cfif getcompetitiveinfo.won_by_client_Uom EQ 1>CS    <cfelse>      LB</cfif></td>
                                           <td><cfif getcompetitiveinfo.won_by_client_delivery_type EQ 1>FOB<cfelseif getcompetitiveinfo.won_by_client_delivery_type EQ 2>DEL<cfelse>&nbsp;</cfif></td>
                                    </tr>
                             </cfif>
                             <cfif (#getcompetitiveinfo.won# EQ 1) AND (#len(getcompetitiveinfo.Program_Bid_Won_By_Description)# GT 0)>
                                    <tr>
                                           <td>#getcompetitiveinfo.Program_Bid_Won_By_Description#</td>
                                           <td>#numberformat(getcompetitiveinfo.Won_Price,"_,___,____.____")#/<cfif getcompetitiveinfo.Won_Uom EQ 1>CS<cfelse>LB</cfif></td>
                                           <td><cfif getcompetitiveinfo.Won_Delivery_Type EQ 1>FOB<cfelseif getcompetitiveinfo.Won_Delivery_Type EQ 2>  DEL<cfelse>&nbsp;</cfif></td>
                                    </tr>
                             </cfif>
                             <cfif #getcompetitiveinfo.won# EQ 0>
                                    <tr>
                                           <td>#getcompetitiveinfo.Program_Bid_Won_By_Description#</td>
                                           <td>#numberformat(getcompetitiveinfo.Won_Price,"_,___,____.____")#/<cfif getcompetitiveinfo.Won_Uom EQ 1>CS<cfelse>LB</cfif></td>
                                           <td><cfif getcompetitiveinfo.Won_Delivery_Type EQ 1>FOB<cfelseif getcompetitiveinfo.Won_Delivery_Type EQ 2>  DEL<cfelse>&nbsp;</cfif></td>
                                    </tr>
                             </cfif>
                       </cfloop>
                                         </table>
                                         </CFMODULE>
                                  </cfif>
                                  <cfif restrictLowerLevelBasedonLevel1>
                                         <input type="hidden" name="productGroupForThisProduct_#request.app_general_functions.replaceHyphen(desRebateData.aProd[i].masterItemId)#" value="#desRebateData.aProd[i].productGroupForThisProduct#">
                                  </cfif>
                            </td>



                             <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxD27183 start  Single_Component_Per_Discount_Type xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
                            this only runs if no components are added.  other wise we set these values in the component loop --->
                          <cfset thisRate = 0>
                            <cfif ArrayLen(desRebateData.aComp) EQ 0 && showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type >
                              <td align="right" nowrap>
                                    <cfscript>
                                    discPerc = 0;
                                    netSales = 0;
                                    baseSales = 0;
                                    thisInvUom = desRebateData.aProd[i].productInventoryUOM;
                                    if(desRebateData.aProd[i].BaseSalesCS != 0){
                                    if(thisInvUom == 'CS'){// CS...
                                    baseSales = desRebateData.aProd[i].BaseSalesCS;
                                    }
                                    else if(thisInvUom == 'LB'){// LB...
                                    baseSales = desRebateData.aProd[i].BaseSalesLB;
                                    }
                                    }
                                    </cfscript>
                                   $#baseSales#&nbsp;&nbsp;
                              </td>
                            </cfif>
                            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

                            <cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />
                            <!--- Reset Var to keep track of rates for this prod --->
                            <cfset tmpCompVarReplaceList = ''/>
                            <!---D38536  :: Alternate recapture rates per component START--->
                            <cfset tmpCompVararRateList = ''/>
                            <cfset ARcontractprodid = ''/>
                            <cfset ARcompNameid = ''/>
                            <cfset ARcompID = ''/>
                            <!---D38536  :: Alternate recapture rates per component END--->
                            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  LOOP LOOP      COMPONENTS           LOOP LOOP xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
                            <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
                            	<!---D60905 :: EZ rate UOM issue START--->
                            	<cfset templateProductEZUOM = ''/>
 								<!---D60905 :: EZ rate UOM issue END--->
                                  <cfset thisRate = desRebateData.aCompVal[i][index].rate />
                                  <!---guard against empty strings--->
                                  <cfset variables.tmpSaveImageId = 'save_rate_'&desRebateData.aCompVal[i][index].contractProdID&'_All' />
                                  <cfif EzButton_Disable EQ 1 and listfind(form.Product_List, desRebateData.aProd[i].masterItemId,",")>
                                 <cfset useLakebaseForGetEZSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getezbuttondefaultrates")>
<cfif useLakebaseForGetEZSettings>
	<cftry>
		<cfset GetEZSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getezbuttondefaultrates", {
				"bsa_foodservice_items_master_id" = "eq.#desRebateData.aProd[i].masterItemId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetEZSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetEZSettings>
<cfquery name="GetEZSettings" dbtype="query">
                                        select *
                                        from GetEZButtonDefaultRates
                                        where BSA_Foodservice_Items_Master_ID ='#desRebateData.aProd[i].masterItemId#'
                                 </cfquery>
</cfif>
                                 <!---D60905 :: EZ rate UOM issue--->
                            	<cfset templateProductEZUOM = GetEZSettings.Unit_Of_Measure_Id/>
                                         <cfif GetEZSettings.recordcount GT 0>
                                                <cfset EZ_rebate_rate = GetEZSettings.rebate_rate>
<cfif desRebateData.aCompVal[i][index].UOMID EQ 5>
	<cfset EZ_rebate_rate = GetEZSettings.rebate_rate/desRebateData.aProd[i].EAConversion>
</cfif>
<cfif desRebateData.aCompVal[i][index].UOMID EQ 7>
	<cfset EZ_rebate_rate = GetEZSettings.rebate_rate/desRebateData.aProd[i].Sleeves_Per_Case>
</cfif>
                                                <cfif GetSettings.Discount_Rebate_Max_Rate_On EQ 0 OR (GetSettings.EzButton_Default_Show_Item_Rates EQ 1 AND (desRebateData.aCompVal[i][index].rate eq "" OR desRebateData.aCompVal[i][index].rate eq 0))>
                                                       <cfset desRebateData.aCompVal[i][index].rate = GetEZSettings.rebate_rate>
                                                </cfif>
                                                <!---
                                                D45434 :: When EZ button is on UOM selected on default rate is overridden by UOM from EZ Button
                                                <cfset desRebateData.aCompVal[i][index].UOMID = GetEZSettings.Unit_Of_Measure_Id>
                                                --->
                                         <cfelse>
                                                <cfset EZ_rebate_rate = "">
                                         </cfif>
                                         <cfset desRebateData.aCompVal[i][index].maxrate = EZ_rebate_rate />
                                  </cfif>
                                  <cfif desRebateData.aCompVal[i][index].rate eq "">
                                         <cfset desRebateData.aCompVal[i][index].rate = 0.0000 />
                                  </cfif>
                                  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start  Single_Component_Per_Discount_Type --->
                                  <cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type >
                                         <td align="right" nowrap>
                                         <cfscript>
                                         discPerc = 0;
                                         baseSales = 0;
                                         netSales = 0;
                                         thisInvUom = desRebateData.aProd[i].productInventoryUOM;
                                         thisRate = desRebateData.aCompVal[i][index].rate;
                                         //desRebateData.aCompVal[i][index].UOMID
                                         if(desRebateData.aProd[i].BaseSalesCS != 0){
                                         if(thisInvUom == 'CS'){// CS...
                                         baseSales = desRebateData.aProd[i].BaseSalesCS;
                                         discPerc = thisRate / baseSales * 100;
                                         netSales = baseSales - thisRate;
                                         //(desRebateData.aProd[i].BaseSalesCS - desRebateData.aCompVal[i][index].rate);
                                         }
                                         else if(thisInvUom == 'LB'){// LB...
                                         baseSales = desRebateData.aProd[i].BaseSalesLB;
                                         discPerc = thisRate / baseSales * 100;
                                         netSales = baseSales - thisRate;
                                         //(desRebateData.aProd[i].BaseSalesLB - desRebateData.aCompVal[i][index].rate)/;
                                         }
                                         else {// %...
                                         baseSales = desRebateData.aProd[i].BaseSalesLB;
                                         discPerc = thisRate;
                                         netSales = baseSales - (thisRate * baseSales);
                                         }
                                         }
                                         </cfscript>
                                                $#baseSales#&nbsp;&nbsp;
                                         </td>
                                  </cfif>
                                  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end xxx--->
<cfset frmUOM = desRebateData.aCompVal[i][index].UOMID />
                                  <cfset compVarReplace = "#request.app_general_functions.replaceHyphen(desRebateData.aProd[i].masterItemId)#_#request.app_general_functions.replaceHyphen(desRebateData.aComp[index].compUUID)#" />
                                  <!---set for rebate rules--->
                                  <!---<cfset tmpUSDAComp = createObject("component","components.programs.rebates.RebateComponent")>--->
                                  <cfset "form.uomsToCheck_#index#" = ListAppend(Evaluate("form.uomsToCheck_#index#"), compVarReplace) />
                                  <!---D45263 :: Create table to store max rates by template/profile START--->
                                  <cfif appSettings.getCustomMaxRate()>
                                         <cfquery name="GetCustomMaxRate" datasource="#application.datasource#">
                                                <cfif trim(desRebateData.aProd[i].item) EQ 'GROUP'>
                                                       SELECT EZ.Max_Rate_LB,EZ.Max_Rate_LB * 1 AS Max_Rate_CS,EZ.Max_Rate_Per,EZ.PG_Product_Category_ID
                                                       FROM EZ_Profile_PG_MaxRate EZ
                                                       WHERE EZ.Profiles_ID = #request.AccessStructure.Profiles_ID#
                                                       AND EZ.First_Parent_ID = #GetTemplateInfo.First_parent_ID#
                                                       AND ez.PG_Product_Category_ID = '#desRebateData.aCompVal[i][index].PRODID#'
                                                <cfelse>
                                                       SELECT EZ.Max_Rate_LB,CAST(EZ.Max_Rate_LB AS INT)  *  CAST(CAST(BSA.Net_weight AS float) AS INT) AS Max_Rate_CS,EZ.Max_Rate_Per,EZ.PG_Product_Category_ID
                                                       FROM EZ_Profile_PG_MaxRate EZ
                                                       INNER JOIN PG_Product_Members PPM
                                                       ON PPM.PG_Product_Category_ID = EZ.PG_Product_Category_ID
                                                       INNER JOIN BSA_Foodservice_Items_Master BSA
                                                       ON BSA.BSA_Foodservice_Items_Master_id = PPM.BSA_Foodservice_Items_Master_id
                                                       AND PPM.Deleted = 0
                                                       AND EZ.Profiles_ID = #request.AccessStructure.Profiles_ID#
                                                       AND EZ.First_Parent_ID = #GetTemplateInfo.First_parent_ID#
                                                       AND PPM.BSA_Foodservice_Items_Master_ID = '#desRebateData.aCompVal[i][index].PRODID#'
                                                </cfif>
                                         </cfquery>
                                         <cfset Custom_Max_Rate = 0/>
                                         <cfset Custom_Max_Rate_UOM = 0/>
                                         <cfif frmUOM EQ 1>
                                                <!--- CS --->
                                                <cfif GetCustomMaxRate.Max_Rate_CS EQ '*'>
                                                       <cfset Custom_Max_Rate = 99999999>
                                                <cfelse>
                                                       <cfset Custom_Max_Rate = GetCustomMaxRate.Max_Rate_CS/>
                                                </cfif>
                                                <cfset Custom_Max_Rate_UOM = 1/>
                                         <cfelseif frmUOM EQ 2>
                                                <!--- LB --->
                                                <cfif GetCustomMaxRate.Max_Rate_LB EQ '*'>
                                                       <cfset Custom_Max_Rate = 99999999>
                                                <cfelse>
                                                       <cfset Custom_Max_Rate = GetCustomMaxRate.Max_Rate_LB/>
                                                </cfif>
                                                <cfset Custom_Max_Rate_UOM = 2/>
                                         <cfelse>
                                                <!---% --->
                                                <cfif GetCustomMaxRate.Max_Rate_PER EQ '*'>
                                                       <cfset Custom_Max_Rate = 99999999>
                                                <cfelse>
                                                       <cfset Custom_Max_Rate = GetCustomMaxRate.Max_Rate_PER/>
                                                </cfif>
                                                <cfset Custom_Max_Rate_UOM = 3/>
                                         </cfif>
                                  </cfif>
                                  <!---D45263 :: Create table to store max rates by template/profile END--->

						<!--- 76380 decimal places START--->
							<cfset decimalprecision = programManager.decimalPrecisionByUOM(frmUOM,1)>
							<cfset decimalformatValidation = programManager.decimalPrecisionByUOM(frmUOM,2)>
						<!--- 76380 decimal places END--->

                                  <cfif Display_Basis_Treatment_Code EQ 0 OR BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) NEQ "Y">
                                         <td nowrap>
                                                <nobr>
                                                <!--- If the program is a revision and revision settings has retrictions for this program and product rate cannot be changed --->
                                                 <!--- D11147 BJF Component product restrictions  Check to see if the product is restricted--->
                                                <cfset DisabledbyComp = 0>
                                                <cfif appsettings.getComponent_Product_Restrictions_On()>
                                                       <cfset CompNameID = desRebateData.aComp[index].compnameID>
                                                       <cfset ProdID = desRebateData.aProd[i].masterItemId>
                                                       <cfquery name="ProductInForbiddenlist" dbtype="query">
                                                              SELECT Product_ID
                                                              FROM Query_#CompNameID#
                                                              WHERE Product_ID = '#ProdID#'
                                                       </cfquery>
                                                       <cfif ProductInForbiddenlist.Recordcount GT 0>
                                                              <cfset DisabledbyComp = 1>
                                                       </cfif>
                                                </cfif>
                                                <!--- Dev Notes: 21553/Anand Rao/05-Mar-10 HZ - min/max rates for EZ button   --->
                                                <cfset variables.varTemplateRate = 0 />
                                                <!---D45263 :: Create table to store max rates by template/profile START--->
                                                <input type="hidden" id="#i#_#index#_Tmplt" size = "2" name="comp_rate_#compVarReplace#_Tmplt"
                                                <cfif appSettings.getCustomMaxRate() EQ 0 AND desRebateData.aCompVal[i][index].maxRate eq "">
                                                       value=""
                                                <cfelseif appSettings.getCustomMaxRate() EQ 0 AND desRebateData.aCompVal[i][index].maxRate neq "">
                                                       value="#LSNumberFormat(desRebateData.aCompVal[i][index].maxRate, decimalprecision)#"
                                                <cfelseif appSettings.getCustomMaxRate()>
                                                       value="#Custom_Max_Rate#"
                                                </cfif>
                                                />
                                                <!---D45263 :: Create table to store max rates by template/profile END--->
                                                <!--- D31755:EZ Button View Settings vs. Rebate View Issue START--->
                                                <!--- D32124: EZ Button Defaulting $0 Base Rates to Size Rate --->
                                                <cfif URL.EZTemplate EQ 0>
                                                       <cfset variables.varTemplateRate = LSNumberFormat(desRebateData.aCompVal[i][index].maxRate, "_.____") />
                                                </cfif>
                                            <span id="error_#i#_#index#"></span>
                                            <span id="error_#compVarReplace#"></span>
                                            <cfset itemUom = 'uom_'&#compVarReplace#><!---D45240  --->
                                            <cfif appSettings.getCustomMaxRate()>
                                                   <cfset CustomMaxRate = LSNumberFormat(Custom_Max_Rate, "_.____")>
                                                   <cfset CustomMaxRateUOM = Custom_Max_Rate_UOM>
                                            <cfelse>
                                                   <cfset CustomMaxRate = LSNumberFormat(desRebateData.aCompVal[i][index].maxRate, "_.____")>
                                                   <cfset CustomMaxRateUOM = templateProductEZUOM>
                                            </cfif>
						<cfset itemRateWithMaxRate = 1>
						<cfset txtRate = desRebateData.aCompVal[i][index].rate>
						<cfset itemNetWeight = desRebateData.aProd[i].netweight>
						<cfif CustomMaxRateUOM NEQ frmUOM>
							<!---Convert program rate from LB to CS --->
							<cfif 	CustomMaxRateUOM EQ 1 AND desRebateData.aCompVal[i][index].maxRate LT (txtRate * itemNetWeight)>
								<cfset itemRateWithMaxRate = 0>
							<!---Convert program rate from CS to LB --->
							<cfelseif CustomMaxRateUOM EQ 2 AND desRebateData.aCompVal[i][index].maxRate LT (txtRate / itemNetWeight)>
								<cfset itemRateWithMaxRate = 0>
							</cfif>
						<cfelse>
							<cfif desRebateData.aCompVal[i][index].maxRate LT txtRate>
									<cfset itemRateWithMaxRate = 0>
								<cfelse>
									<cfset itemRateWithMaxRate = 1>
							</cfif>
						</cfif>
						<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1')>
							<cfif (isDefined("FORM.txtPercentage") AND FORM.txtPercentage NEQ "")>
								<cfif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 2><!--- LB --->
									<cfset val = #Trim(numberformat((LB_Price * (FORM.txtPercentage/100) + LB_Price),"_,___,____.__"))# />
								<cfelseif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 1><!--- CS --->
									<cfset val = #Trim(numberformat((CS_Price * (FORM.txtPercentage/100) + CS_Price),"_,___,____.__"))# />
								</cfif>
							</cfif>
						</cfif>
						<cfquery name="BRVolume" dbtype="Query">
							SELECT *, (Invoice_Volume - Recapture_Volume) AS Base_Volume, (Invoice_Volume_LB - Recapture_Volume_LB) AS Base_Volume_LB
							FROM qGetVolumeForBR
							WHERE Bsa_FoodService_Items_Master_Id = '#desRebateData.aCompVal[i][index].PRODID#'
						</cfquery>

						<cfif desRebateData.aComp[index].Blended_Rate_On AND EzButton_Disable EQ 0>

							<!--- BASE RATE --->
                                        <cfif len(CustomMaxRateUOM) EQ 0><cfset CustomMaxRateUOM = 0></cfif>
							<input class="editablefield" name="blended_base_rate_#compVarReplace#" type="text"  size="5"  ONKEYUP="clenseText(this,'#TextAllowedInTextBox#');" style="font-size:10"
							 <cfif DisabledbyComp EQ 1>
                                                          STYLE="background-color: cccccc" DISABLED
                                                   </cfif>
                                                   value="#LSNumberFormat(desRebateData.aProd[i].Blended_Base_Rate, "_.____")#" id="blended_base_rate_#compVarReplace#">
                                                   <!--- DISCOUNT RATE --->
 							<input class="editablefield" name="blended_discount_rate_#compVarReplace#" type="text"  size="5"
 							ONKEYUP="CalRateCal($('##c_uom_#i#_#index#').val(),$('input:text[name=blended_base_rate_#compVarReplace#]').val(), this.value, #BRVolume.Base_Volume#, #BRVolume.Base_Volume_LB#, #BRVolume.Invoice_Volume#, #BRVolume.Invoice_Volume_LB#, #BRVolume.Recapture_Volume#,  #BRVolume.Recapture_Volume_LB#,'#trim(compVarReplace)#');
 										clenseText(this,'#TextAllowedInTextBox#');"
 							style="font-size:10"
							 <cfif DisabledbyComp EQ 1>
                                                          STYLE="background-color: cccccc" DISABLED
                                                   </cfif>
                                                   value="#LSNumberFormat(desRebateData.aProd[i].Blended_Disc_Rate, "_.____")#" id="blended_discount_rate_#compVarReplace#">
                                                   <!--- CALCULATED RATE --->
 							<input readonly class="editablefield" name="blended_calculated_rate_#compVarReplace#" type="text"  size="5"  ONKEYUP="clenseText(this,'#TextAllowedInTextBox#');" style="font-size:10"
							 <cfif DisabledbyComp EQ 1>
                                                          STYLE="background-color: cccccc" DISABLED
                                                   </cfif>
                                                   value="#LSNumberFormat(desRebateData.aProd[i].Blended_Calc_Rate, "_.____")#" id='blended_calculated_rate_#compVarReplace#'>
                                                   <!--- ADJUSTMENT RATE --->
							<input class="editablefield" id="#i#_#index#" name="blended_Adjustment_rate_#compVarReplace#" type="text"  size="5"  ONKEYUP="clenseText(this,'#TextAllowedInTextBox#');" style="font-size:10"

							 <cfif DisabledbyComp EQ 1>
                                                          STYLE="background-color: cccccc" DISABLED
                                                   </cfif>
                                                   value="#desRebateData.aProd[i].Blended_Adj_Rate#">
                                                   <!--- Disabled by comp --->
                                                   <cfif DisabledbyComp EQ 1>
                                                       <input  id="#i#_#index#" name="blended_base_rate_#compVarReplace#" type="hidden" style="font-size:10" value="0"     />
                                                       <input  id="#i#_#index#" name="blended_discount_rate_#compVarReplace#" type="hidden" style="font-size:10" value="0"     />
                                                       <input  id="#i#_#index#" name="blended_calculated_rate_#compVarReplace#" type="hidden" style="font-size:10" value="0"     />
                                                       <input  id="#i#_#index#" name="blended_Adjustment_rate_#compVarReplace#" type="hidden" style="font-size:10" value="0"     />
                                                   </cfif>
                                            <cfelseif Revision_Products_Rates_Changes eq 1 and EzButton_Disable EQ 0 AND DisabledbyComp EQ 0>
                                                   <cfset inputrate = 0>

                                                   <input class="editablefield" id="#i#_#index#"
                                                   name="comp_rate_#compVarReplace#"
                                                   type="text"  size="4"
                                                   ONKEYUP="clenseText(this,'#TextAllowedInTextBox#');<cfif appSettings.getCustomMaxRate() OR (EzButton_Disable EQ 1 AND desRebateData.aCompVal[i][index].maxRate neq "")>chkMaxTmpltRate(this.value,#CustomMaxRate#,'#i#_#index#',#CustomMaxRateUOM#,document.getElementsByName('#itemUom#')[0].value,#desRebateData.aProd[i].netweight#);</cfif>"
                                                   style="font-size:10"
                                                   <cfif  Evaluate("USDAComp_#desRebateData.aComp[index].compnameID#") EQ 1 OR desRebateData.aComp[index].rebate_type EQ 2>
                                                          Readonly STYLE="background-color: eeeeee"
                                                   </cfif>
                                                   <cfif DisabledbyComp EQ 1 OR desRebateData.aComp[index].IsSecondComponent EQ 1>
                                                          STYLE="background-color: cccccc" DISABLED
                                                   </cfif>
                                                   <cfif (desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1>
                                                          value=""
                                                          <!---
                                                          Dev Notes: 21553/Anand Rao/ 08/Mar/10
                                                          Assumed that the user will not be entering a 0 value for the rate and if he does
                                                          so then we will show them only the template Rate(After discussing with Milan on 08/Mar/10) --->
                                                   <cfelseif ((desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND (variables.varTemplateRate NEQ 0))>
                                                          value="#LSNumberFormat(variables.varTemplateRate, decimalprecision)#"
                                                          <cfset inputrate = #LSNumberFormat(variables.varTemplateRate, "(#decimalprecision#)")#>
                                                   <cfelse>
                                                          value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, decimalprecision)#"
                                                          <cfset inputrate = #LSNumberFormat(desRebateData.aCompVal[i][index].rate, decimalprecision)#>
                                                          <cfif appSettings.getProgram_Allow_Negative_Rebate_Rates() eq 1 AND LSNumberFormat(desRebateData.aCompVal[i][index].rate, "#decimalprecision#") LT 0>
                                                                 STYLE="background-color: FFFF00"
                                                          </cfif>
                                                   </cfif>
                                                   <cfif (appSettings.getCustomMaxRate() OR (EzButton_Disable EQ 1 AND desRebateData.aCompVal[i][index].maxRate neq "")) AND inputrate GT CustomMaxRate>
                                                          STYLE="background-color: FF0000"
                                                   </cfif>
                                                   <cfif appSettings.getProgram_Allow_Null_Rate() EQ 1>
                                                          onChange="this.value = formatToDeciamalPlacesAllowNull(this.value,#decimalformatValidation#,1);resetnavigate();applyWarnBorder('#variables.tmpSaveImageId#');validateRate('#compVarReplace#');"
                                                   <cfelse>
                                                          <!--- onChange="this.value = formatToDeciamalPlaces(this.value,#decimalformatValidation#);resetnavigate();applyWarnBorder('#variables.tmpSaveImageId#');validateRate('#compVarReplace#');" --->
                                                          onChange="this.value=decimal_format(this.value,'#compVarReplace#');resetnavigate();applyWarnBorder('#variables.tmpSaveImageId#');validateRate('#compVarReplace#');"
                                                   </cfif>
                                                   />
                                                <!--- setDiscPerc(this.value,#i##index#); --->
                                                <cfelseif DisabledbyComp EQ 1>
                                                       <!--- Disabled by comp --->
                                                       <input  id="#i#_#index#" name="comp_rate_#compVarReplace#" type="text" size="4" ONKEYUP="clenseText(this,'0123456789.')"  value="0" style="font-size:10; background-color: FFFFFF" DISABLED     />
                                                       <input  id="#i#_#index#" name="comp_rate_#compVarReplace#" type="hidden" style="font-size:10" value="0"     />
                                                <cfelse>
                                                       <!--- EZ Button value --->
                                                       <cfset showVal = 1 />
                                                       <cfif (GetSettings.Discount_Rebate_Max_Rate_On EQ 0 OR GetSettings.EzButton_Default_Show_Item_Rates EQ 1)>
                                                              <!--- if it is absolute rate just display the rate no need to look for other settings as it will be uneditable --->
                                                              <cfset showVal = 1 />
                                                       <cfelseif (GetSettings.EzButton_Default_Show_Item_Rates EQ 0 AND GetSettings.Discount_Rebate_Max_Rate_On EQ 1 AND isDefined("FORM.ExistingProductList") AND ListFindNoCase(FORM.ExistingProductList,desRebateData.aProd[i].masterItemId) EQ 0)>
                                                              <cfset showVal = 0 />
                                                       </cfif>
                                                       <input class="editablefield" id="#i#_#index#" name="comp_rate_#compVarReplace#" type="text" size="4" ONKEYUP="clenseText(this,'#TextAllowedInTextBox#')"
                                                       <cfif  Evaluate("USDAComp_#desRebateData.aComp[index].compnameID#") EQ 1 OR desRebateData.aComp[index].rebate_type EQ 2>
                                                              Readonly
                                                       </cfif>
                                                       <cfif (((desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1) OR (showVal EQ 0))>
                                                              value=""
                                                       <CFELSE>
                                                              value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, decimalprecision)#"
                                                              <cfif appSettings.getProgram_Allow_Negative_Rebate_Rates() eq 1 AND LSNumberFormat(desRebateData.aCompVal[i][index].rate, "_.____") LT 0>
                                                                     style="background-color: FFFF00"
                                                              </cfif>
                                                       </cfif>
                                                       <!---D45263 :: Create table to store max rates by template/profile START--->
                                                       <cfif appSettings.getCustomMaxRate() EQ 0 AND(GetSettings.Discount_Rebate_Max_Rate_On EQ 1 AND desRebateData.aCompVal[i][index].maxRate neq  "" AND itemRateWithMaxRate EQ 0 AND desRebateData.aCompVal[i][index].rate GT desRebateData.aCompVal[i][index].maxRate)>
                                                              style="background-color:FF3333;"
                                                              <cfset footerTip = "block" />
                                                       </cfif>
                                                       <cfif appSettings.getCustomMaxRate() AND itemRateWithMaxRate EQ 0>
                                                              style="background-color:FF3333;"
                                                       </cfif>
                                                       <!---D45263 :: Create table to store max rates by template/profile END--->
                                                        onChange="
                                                         <cfif appSettings.getProgram_Allow_Null_Rate() EQ 1>
                                                               this.value = formatToDeciamalPlacesAllowNull(this.value,#decimalformatValidation#,1);resetnavigate();
                                                         <CFELSE>
                                                                this.value = formatToDeciamalPlaces(this.value, #decimalformatValidation#);resetnavigate();
                                                         </cfif>
                                                         <!--- Do not validate if template does not have a max rate --->
                                                         <!---D45263 :: Create table to store max rates by template/profile START--->
                                                         <cfif appSettings.getCustomMaxRate() OR (EzButton_Disable EQ 1 AND desRebateData.aCompVal[i][index].maxRate neq "")>
        chkMaxTmpltRate(this.value,#CustomMaxRate#,'#i#_#index#',#CustomMaxRateUOM#,document.getElementsByName('#itemUom#')[0].value,#desRebateData.aProd[i].netweight#);
                                                         </cfif>
                                                       "
                                                       <!---D45263 :: Create table to store max rates by template/profile END--->
                                                       <cfif (appSettings.getCustomMaxRate() OR (EzButton_Disable EQ 1 AND desRebateData.aCompVal[i][index].maxRate neq "")) AND itemRateWithMaxRate EQ 0 AND desRebateData.aCompVal[i][index].rate GT desRebateData.aCompVal[i][index].maxRate>
                                                              STYLE="background-color: FF0000"
                                                       </cfif>
													 	<!---63628  EZ Button - new template setting to determine if product search filters on EZ Button products --->
                                                       <cfif (Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0)
															 OR  (GetSettings.EZButton_On AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0 AND GetEZSettings.recordcount)>
                                                              style="font-size:10; background-color: FFFFFF" DISABLED
                                                       </cfif>
                                                       />
														<!---63628  EZ Button - new template setting to determine if product search filters on EZ Button products --->
                                                       <cfif (Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0) OR (GetSettings.EZButton_On AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0 AND GetEZSettings.recordcount)>
                                                              <input  id="#i#_#index#" name="comp_rate_#compVarReplace#" type="hidden" style="font-size:10"
                                                              <cfif GetSettings.EZButton_On AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0>
                                                                     value="#LSNumberFormat(EZ_rebate_rate, "(#decimalprecision#)")#"
                                                              <CFELSEIF (desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1>
                                                                     value=""
                                                              <CFELSE>
                                                                     value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, decimalprecision)#"
                                                              </cfif>
                                                              />
                                                       </cfif>
                                                </cfif>
                                                <!---Modification: Group Deals--->
                                                <!---if it's a group type then automatically set the uom to %--->
                                                <cfset Disabled = 0>
                                                <!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made --->
                                                <!---OR (EzButton_Disable EQ 1 AND desRebateData.aCompVal[i][index].maxRate neq "") --->
                                                <!---61605 : Event error on fixed price save when revision setting for UOM change is OFF START--->
                                                <cfif listfind(ParentRebateComponents, desRebateData.aComp[index].compNameId) AND (Revision_Products_UOM_Changes eq 0 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0) OR DisabledbyComp EQ 1>
                                                       <cfset Disabled = 1>
                                                </cfif>

                                                <cfif Disabled eq 0 AND desRebateData.aComp[index].IsSecondComponent EQ 1>
                                                       <cfset Disabled = 1>
                                                </cfif>

                                                <!---61605 : Event error on fixed price save when revision setting for UOM change is OFF END--->
                                                <cfscript>
                                                vars = StructNew();
                                                // 27063 - append '_d' to the select element name when it is disabled
                                                // Otherwise the hidden element & the select element would have a duplicate name!!
                                                if ( Disabled eq 1 ) {
                                                vars.uom_name = "uom_" & compVarReplace & "_d";
                                                }
                                                else {
                                                vars.uom_name = "uom_" & compVarReplace;
                                                }
                                                </cfscript>
                                                <cfset show_EA = 0/>
                                                <cfif  desRebateData.aComp[index].rebate_type EQ 4 and      appSettings.getUOMEAAvailable() EQ 1>
                                                       <!----- if    rebate_type = 4 and app setting for EA is available is 1 then we will provide EA as an available option in UOM selection list ----->
                                                       <cfset show_EA = 1/>
                                                </cfif>
                                                <!--- Dev Note:(44212) - Add tabIndex="-1", so that users can tab from one rate to another rate textbox. This field will not be used while tabbing.--->
                                               <cfset NULL = "null">

                                               <cf_uom_dropdown
                                                    program_id              = "#desRebateData.programID#"
                                                    dropdown_id             = "c_uom_#i#_#index#"
                                                    company_main_id         = ""
                                                    default_option_on       = "0"
                                                    default_option_text     = ""
                                                    default_option_value    = ""
                                                    dropdown_name           = #vars.uom_name#
                                                    option_text_abbreviated = "1"
                                                    plural_uom_display      = ""
                                                    product_type_id         = "2"
                                                    program_template_id     = ""
                                                    selected_uom_id         = "#frmUOM#"
                                                    text_before_tag_close   = "onchange=""resetnavigate();applyWarnBorder('#variables.tmpSaveImageId#');CalRateCal($('##c_uom_#i#_#index#').val(),$('input:text[name=blended_base_rate_#compVarReplace#]').val(), $('input:text[name=blended_discount_rate_#compVarReplace#]').val(), #BRVolume.recordcount ? BRVolume.Base_Volume : NULL#, #BRVolume.recordcount ? BRVolume.Base_Volume_LB : NULL#, #BRVolume.recordcount ? BRVolume.Invoice_Volume : NULL#, #BRVolume.recordcount ? BRVolume.Invoice_Volume_LB : NULL#, #BRVolume.recordcount ? BRVolume.Recapture_Volume : NULL#,  #BRVolume.recordcount ? BRVolume.Recapture_Volume_LB : NULL#,'#trim(compVarReplace)#');chkMaxTmpltRate($('input:text[name=comp_rate_#compVarReplace#]').val(),#LSNumberFormat(desRebateData.aCompVal[i][index].maxRate, "(#decimalprecision#)")#,'comp_rate_#compVarReplace#',#val(CustomMaxRateUOM) ? CustomMaxRateUOM : NULL#,this.value,#desRebateData.aProd[i].netweight#);"""
                                                    uom_id_exclusion_list   = ""
                                                    uom_id_inclusion_list   = ""
                                                    productUom              = "#desRebateData.aProd[i].productInventoryUOM#"
                                                    Disabled                = "#Disabled#"
                                                    isGroup                 = "#desRebateData.aProd[i].isGroup#"
                                                    width                   = "45px"
                                                    show_EA                 = "#show_EA#"
                                                >

<cfif Disabled eq 1>
	<input type="hidden" name="uom_#compVarReplace#" value="#frmUOM#">
</cfif>
                                                <cfif  desRebateData.aComp[index].rebate_type EQ 4>
                                                       <!----- rebate_type = 4, scan
                                                       this is a new volume input box to store scan volume
                                                       ----->
                                                       <input id="#i#_#index#" name="comp_scan_volume_#compVarReplace#" type="text"  size="4" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
                                                       <cfif DisabledbyComp EQ 1> STYLE="background-color: cccccc" DISABLED</cfif>
                                                       value="#LSNumberFormat(desRebateData.aCompVal[i][index].scanVolume, "(_)")#"
                                                       onChange="this.value = formatToDeciamalPlaces(this.value,4);resetnavigate();"
                                                       />
                                                </cfif>
                                                </nobr>
                                         </td>
                                  </cfif>
                                  <cfif Display_Basis_Treatment_Code EQ 1>
                                         <cfif BasisCodeManager.getBasicCodeType(desRebateData.aComp[index].BasisCode) EQ "Y">
                                                <td nowrap>
                                                       <input  id="#i#_#index#" name="comp_rate_#compVarReplace#" type="hidden" style="font-size:10"
                                                       <cfif (desRebateData.aCompVal[i][index].rate EQ 0 OR desRebateData.aCompVal[i][index].rate EQ "") AND appSettings.getProgram_Allow_Null_Rate() EQ 1>value=""<CFELSE>value="#LSNumberFormat(desRebateData.aCompVal[i][index].rate, "_.____")#"</cfif>
                                                       basisCodeType="1"
                                                       />
                                                       <input type="hidden" name="uom_#compVarReplace#" id="c_uom_#i#_#index#" value="#frmUOM#">
                                                       <input type="hidden" name="basisCodeType_#i#_#index#" value="1">
                                                       <input name="comp_basis_code_quantity_#compVarReplace#" type="text"  size="4" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
                                                       value="#LSNumberFormat(desRebateData.aCompVal[i][index].basisCodeQuantity, "_.____")#"
                                                       <cfif Revision_Products_Rates_Changes eq 0>disabled</cfif>
                                                       />
                                                       <cfif Revision_Products_Rates_Changes eq 0>
                                                              <input type="Hidden" name="comp_basis_code_quantity_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeQuantity#" />
                                                       </cfif>
                                                       <cf_uom_dropdown
                                                       program_id                        =       "#desRebateData.programID#"
                                                       company_main_id                   =       ""
                                                       default_option_on           =      "0"
                                                       default_option_text         =      ""
                                                       default_option_value =      ""
                                                       dropdown_name               =       "comp_basis_code_quantity_uom_#compVarReplace#"
                                                       option_text_abbreviated     =      "1"
                                                       plural_uom_display          =      ""
                                                       product_type_id                   =       "2"
                                                       program_template_id         =      ""
                                                       selected_uom_id                   =       "#desRebateData.aCompVal[i][index].basisCodeQuantityUom#"
                                                       text_before_tag_close       =       "onchange=""resetnavigate();"""
                                                       uom_id_exclusion_list       =      "3"
                                                       uom_id_inclusion_list       =      ""
                                                       productUom                        =       "#desRebateData.aProd[i].productInventoryUOM#"
                                                       Disabled                          =        "#Disabled#"
                                                       >
                                                       <cfif Disabled>
                                                              <input type="Hidden" name="comp_basis_code_quantity_uom_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeQuantityUom#" />
                                                       </cfif>
                                                </td>
                                                <td nowrap>
                                                       <input name="comp_basis_code_free_goods_#compVarReplace#" type="text"  size="4" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
                                                       value="#LSNumberFormat(desRebateData.aCompVal[i][index].basisCodeFreeGoods, "(_.____)")#"
                                                       <cfif Revision_Products_Rates_Changes eq 0>disabled</cfif>
                                                       />
                                                       <cfif Revision_Products_Rates_Changes eq 0>
                                                              <input type="Hidden" name="comp_basis_code_free_goods_#compVarReplace#" value="#desRebateData.aCompVal[i][index].basisCodeFreeGoods#" />
                                                       </cfif>
                                                </td>
                                         </cfif>
                                         <cfif desRebateData.aComp[index].EffectiveMarginFlag EQ 1>
                                                <!------ Effective Margin % ----->
                                                <td nowrap align="center">
                                                       <input name="comp_effective_margin_percent_#compVarReplace#" type="text"  size="4" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
                                                       value="#LSNumberFormat(desRebateData.aCompVal[i][index].effectMarginPercent, "(_.__)")#"
                                                       />
                                                </td>
                                         </cfif>
                                  </cfif>

                                  <cfset variables.tmpConProdId = desRebateData.aCompVal[i][index].contractProdID />
                                  <cfif trim(tmpCompVarReplaceList) eq ''>
                                         <cfset tmpCompVarReplaceList = compVarReplace />
                                         <!--- D38536  :: Alternate recapture rates per component --->
                                         <cfset tmpCompVararRateList = desrebatedata.acomp[index].Alternate_Recapture_Rate />
                                         <cfset ARcompNameid = desrebatedata.acomp[index].compnameid/>
                                         <cfset ARcompID = #desrebatedata.acomp[index].compid#>
                                         <!--- D38536  :: Alternate recapture rates per component --->
                                  <CFELSE>
                                         <cfset tmpCompVarReplaceList = tmpCompVarReplaceList & '|' & compVarReplace />
                                         <!--- D38536  :: Alternate recapture rates per component --->
                                         <cfset tmpCompVararRateList = tmpCompVararRateList & '|' & desrebatedata.acomp[index].Alternate_Recapture_Rate />
                                         <cfset ARcompNameid = ARcompNameid & '|' & desrebatedata.acomp[index].compnameid/>
                                         <cfset ARcompID = ARcompID & '|' & desrebatedata.acomp[index].compid>
                                         <!--- D38536  :: Alternate recapture rates per component --->
                                  </cfif>
                                  <!--- D38536  :: Alternate recapture rates per component START--->
                                  <cfif desrebatedata.acomp[index].Alternate_Recapture_Rate>
                                         <cfset ARcontractprodid  = #desrebatedata.acompval[i][index].contractprodid#>
                                         <cfquery name="AR_Index" datasource="#application.datasource#">
                                                SELECT alternate_recapture_rate_index
                                                FROM alternate_recapture_rate_setting
                                                WHERE Program_Rebates_Component_Name_ID =  <cfqueryparam value="#desrebatedata.acomp[index].compnameid#" cfsqltype="cf_sql_integer" />
                                                AND Status = 0
                                         </cfquery>
                                         <cfset indexlist = #valuelist(AR_Index.alternate_recapture_rate_index,",")#>
                                         <cfloop from="1" to="#desRebateData.aComp[index].alternate_recapture_rate#" index="A">
                                                <cfquery name="Pull_Alternate_Rate_Info" datasource="#application.datasource#">
                                                       SELECT *
                                                       FROM Program_Rebate_Alternate_Recapture_Rate
                                                       WHERE Contract_Main_ID = <cfqueryparam value="#desRebateData.aComp[index].programid#" cfsqltype="cf_sql_integer" />
                                                       AND Contract_Products_ID =  <cfqueryparam value="#desrebatedata.acompval[i][index].contractprodid#" cfsqltype="cf_sql_integer" />
                                                       AND Program_Rebates_Component_ID =  <cfqueryparam value="#desrebatedata.acomp[index].compid#" cfsqltype="cf_sql_integer" />
                                                       AND Alternate_Recapture_Rate_Index = #listgetat(indexlist, A)#
                                                </cfquery>
                                                <cfif len(Pull_Alternate_Rate_Info.rate)>
                                                       <cfset rate = #Pull_Alternate_Rate_Info.rate#>
                                                <cfelse>
                                                       <cfset rate = "0.0000">
                                                </cfif>
                                                <cfset Alternate_Rate_width = #component_width# + 10>
                                                <td nowrap align="left">
                                                       <input type="text" name="ARR_#A#_#compVarReplace#" value="#rate#" style="font-size:10" size="5" ONKEYUP="clenseText(this,'#TextAllowedInTextBox#')" onChange="this.value = formatToDeciamalPlaces(this.value,4);resetnavigate();changebg();"
                                                       <cfif (Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 0 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0) OR  (GetSettings.EZButton_On AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0 AND GetEZSettings.recordcount)>
                                                              disabled
                                                       </cfif>
                                                       >
                                                       <cfif (Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 0 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0) OR  (GetSettings.EZButton_On AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0 AND GetEZSettings.recordcount)>
                                                              <input type="hidden" name="ARR_#A#_#compVarReplace#" value="#rate#" />
                                                       </cfif>
						<cfif Pull_Alternate_Rate_Info.recordcount EQ 0>
							<cfset ARR_UOM = #frmUOM#>
						<cfelse>
							<cfif Pull_Alternate_Rate_Info.uom>
								<cfset ARR_UOM = #Pull_Alternate_Rate_Info.uom#>
							<cfelse>
								<cfset ARR_UOM = #frmUOM#>
							</cfif>
						</cfif>
                                                       <cf_uom_dropdown
                                                       program_id                        =       "#desRebateData.programID#"
                                                       dropdown_id                       =       "ARR_uom_#A#_#index#"
                                                       company_main_id                   =       ""
                                                       default_option_on           =      "0"
                                                       default_option_text         =      ""
                                                       default_option_value =      ""
                                                       dropdown_name               =       "ARR_#A#_UOM_#compVarReplace#"
                                                       option_text_abbreviated     =      "1"
                                                       plural_uom_display          =      ""
                                                       product_type_id                   =       "2"
                                                       program_template_id         =      ""
                                                       selected_uom_id                   =       "#ARR_UOM#"
                                                       text_before_tag_close       =       "onchange=""resetnavigate();applyWarnBorder('#variables.tmpSaveImageId#');"""
                                                       uom_id_exclusion_list       =      ""
                                                       uom_id_inclusion_list       =      ""
                                                       productUom                        =       "#desRebateData.aProd[i].productInventoryUOM#"
                                                       Disabled                          =        "#Disabled#"
                                                       isGroup                                  =      "#desRebateData.aProd[i].isGroup#"
                                                       width                             =       "40px"
                                                       show_EA                                  =      "#show_EA#"
                                                       >
                                                       <cfif Disabled eq 1>
                                                              <input type="hidden" name="ARR_#A#_UOM_#compVarReplace#" value="#frmUOM#">
                                                       </cfif>
                                                </td>
                                         </cfloop>
                                  </cfif>
                                  <!--- D38536  :: Alternate recapture rates per component END--->
                                  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start  Single_Component_Per_Discount_Type --->
                                  <cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type >
                                         <cfscript>
                                         /* ..............................
                                         These values are set up above.
                                         Look for D27183
                                         ................................. */
                                         </cfscript>
                                         <td align="right" nowrap>
                                                $#LSNumberFormat(netSales, "(___.___)")#&nbsp;&nbsp;
                                         </td>
                                         <td align="right" nowrap>
                                                #LSNumberFormat(discPerc, "(__)")#%&nbsp;&nbsp;
                                         </td>
                                  </cfif>
                                  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end--->
                                  <td style="display:none">
	                                  <input name="reb_rule_#compVarReplace#" type="hidden" value="#desRebateData.aCompVal[i][index].ruleId#" />
	                                  <input type="hidden" name="ProgRebCompId_#compVarReplace#" value="#desRebateData.aCompVal[i][index].Program_Rebates_Component_Data_ID#" />
	                                  <input type="hidden" name="EAConversion_#compVarReplace#" value="#desRebateData.aProd[i].EAConversion#" />
	                                  <input type="hidden" name="Sleeves_Per_Case_#compVarReplace#" value="#desRebateData.aProd[i].Sleeves_Per_Case#" />
	                                  <input type="hidden" name="net_weight_#compVarReplace#" value="#desRebateData.aProd[i].netWeight#" />
	                                  <input type="hidden" name="productInventoryUOM_#compVarReplace#" value="#desRebateData.aProd[i].productInventoryUOM#" />
                                  </td>
                            </cfloop>
                            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx END  LOOP LOOP      COMPONENTS           LOOP LOOP END  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
                            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 start xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
                            <cfif UseFixedPriceType and URL.EZTemplate EQ 0 AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1>
                                  <!---getFixedComponentInfo.RecordCount && --->
                                  <cfset variables.fixed_price_type_bgcolor = "" />
                                   <cfif thisRate gt 0>
                                         <cfset variables.fixed_price_type_bgcolor = "F2ACA5" />
                                  </cfif>
                                  <cfset Competitor_Name_ID = evaluate("desRebateData.aProd[i].Competitor_Name_ID") />
                                  <td align="left" id="tdCompetitor#stripProdId#_All" style="background-color:#variables.fixed_price_type_bgcolor#">
                                         <!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START
                                         Changed/Added: onChange="showCompetitorSource_Other(#id_i#)" id="CompetitorSource#id_i#"--->
						  <input type="hidden" name="#stripProdId#_Check_Competitor_Info" <cfif thisRate GT 0>value="1"<cfelse>value="0"</cfif> />
                                         <select style="width:#competitor_width#px;" name="Competitor_Name_ID_#stripProdId#"
                                                onChange="showCompetitorSource_Other('#stripProdId#');"
                                                 id="Competitor_Name_ID_#stripProdId#">
                                                <OPTION style="width:#competitor_width#px;" VALUE="0" SELECTED>Select a Competitor</OPTION>
                                                <cfset bChecked = 0 />
                                                <CFLOOP QUERY="CompetitorList">
                                                       <cfset sChecked = "" />
                                                       <cfif CompetitorList.Program_Bid_Won_By_ID eq desRebateData.aProd[i].Competitor_Name_ID>
                                                              <cfset sChecked = "selected" />
                                                              <cfset bChecked = 1 />
                                                       </cfif>
                                                       <OPTION style="width:#competitor_width#px;" VALUE="#CompetitorList.Program_Bid_Won_By_ID#" #sChecked#>
                                                       #trim(CompetitorList.Program_Bid_Won_By_Description)#
                                                       </OPTION>
                                                </cfloop>
                                                <!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START
                                                Changed/Added: Added new OPTION Other--->
                                                <OPTION style="width:#competitor_width#px;" VALUE="-1" <cfif #desRebateData.aProd[i].Competitor_Name_ID# gt 0 && bChecked EQ 0>SELECTED</cfif>>Other</OPTION>
                                                <!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
                                         </SELECT>
                                         <!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START
                                         Changed/Added: added condition to display Other value in text box.--->
                                         <cfset other_value = "">
                                         <cfif (CompetitorList.Program_Bid_Won_By_ID NEQ #desRebateData.aProd[i].Competitor_Name_ID#) AND (len(desRebateData.aProd[i].Competitor_Name_ID) GT 0) AND #desRebateData.aProd[i].Competitor_Name_ID# NEQ 0>
                                                <cfset useLakebaseForPull_other_comp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForPull_other_comp>
	<cftry>
		<cfset Pull_other_comp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"program_bid_won_by_id" = "eq.#desRebateData.aProd[i].Competitor_Name_ID#",
				"select" = "program_bid_won_by_description"
			}), "program_bid_won_by_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPull_other_comp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPull_other_comp>
<cfquery name="Pull_other_comp" datasource="#application.datasource#">
                                                       SELECT Program_Bid_Won_By_Description
                                                       FROM  Program_Bid_Won_By
                                                       WHERE Program_Bid_Won_By_ID = #desRebateData.aProd[i].Competitor_Name_ID#
                                                </cfquery>
</cfif>
                                                <cfset other_value = #Pull_other_comp.Program_Bid_Won_By_Description#>
                                         </cfif>
                                         <input type="text" name="CompetitorSourceOther_#stripProdId#" id="CompetitorSourceOther_#stripProdId#"
                                         value = "#other_value#" <cfif desRebateData.aProd[i].Competitor_Name_ID gt 0 && bChecked EQ 0>style="display: block;"</cfif>style="display: none;">
                                         <!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
                                  </td>
                                  <td align="left" id="#stripProdId#_TDCPrice" style="background-color:#variables.fixed_price_type_bgcolor#">
                                         <input type="text" value="#desRebateData.aProd[i].Competitor_Price#" size="2" name="Competitor_Price_#stripProdId#" id="Competitor_Price_#stripProdId#" style="width:#distCost_width#px;" maxlength="20" ONKEYUP="clenseText(this,'0123456789.')" />
                                  </td>
                                  <td  align="left"  id="#stripProdId#_TDCTimeFrame" style="background-color:#variables.fixed_price_type_bgcolor#">
                                         <input type="text" value="#desRebateData.aProd[i].Competitor_Time_Frame#" size="5" name="Competitor_Time_Frame_#stripProdId#" id="Competitor_Time_Frame_#stripProdId#" maxlength="15" />
                                  </td>
                            <cfelse>
                            	<td style="display:none;">
	                                <input type="hidden" name="Competitor_Name_ID_#stripProdId#" id="Competitor_Name_ID_#stripProdId#" value="0"/>
	                                <input type="hidden" name="Competitor_Price_#stripProdId#" id="Competitor_Price_#stripProdId#" value="0"/>
	                                <input type="hidden" name="Competitor_Time_Frame_#stripProdId#" id="Competitor_Time_Frame_#stripProdId#" value=""/>
	                                <input type="hidden" name="CompetitorSourceOther_#stripProdId#" id="CompetitorSourceOther_#stripProdId#" value=""/>
                                 </td>
                            </cfif>
                            <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 end  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
                            <cfif ArrayLen(desRebateData.aComp) >
                                  <td align="left" nowrap class="bSaveRates">
                                         <!--- Dev Note:(44212) - Add tabIndex="-1", so that users can tab from one rate to another rate textbox. This field will not be used while tabbing.--->
                                    <a href="##"
                                         id="save_rate_#variables.tmpConProdId#_All"
                                         name="save_rate_#variables.tmpConProdId#_All"
                                         title=" click here to save #trim(desRebateData.aProd[i].item)#&##013; rate info "
                                         tabindex="-1"
                                         onclick="saveProdRate_All('#tmpCompVarReplaceList#','#stripProdId#', '#tmpCompVararRateList#','#ARcontractprodid#', '#ARcompNameid#', '#ARcompID#');return false;" >
                                      #application.util.string.actionLinkFormat("save")#
                                    </a>

                                  </td>
                            </cfif>
                            <cfif CSLGetContractInfo.Like_Product_Exist eq 1>
                                  <td><input name="Like_Product" type="checkbox" value="#desRebateData.aProd[i].masterItemId#" <cfif ListFind(SimilarExistingProductList,desRebateData.aProd[i].masterItemId) neq 0 >CHECKED</cfif>></td>
                            </cfif>
                     </tr>
					 <cfset displayedProductList = ListAppend(displayedProductList,desRebateData.aProd[i].masterItemId)>
              </cfloop>


              <INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">
              <!---hidden var to let rebate.cfc update method know when to pull component values from the form scope--->
              <INPUT TYPE="hidden" NAME="aaGetFromForm" VALUE="1">
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

                     <cfif ArrayLen(desRebateData.aProd) gt 0>
                     <tr bgcolor="##ccffcc">
                       <td width="#noProdWidth#">
                              No product (s) selected<img src="/Images/fill.gif" height="1" width="#noProdWidth#">
                       </td>
                            <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
                                  <td width="#component_width#" nowrap> <input name="comp_rate_#index#" type="text" value="#desRebateData.aCompVal[index].rate#" size="3" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4);resetnavigate(); <cfif desRebateData.aComp[index].rebate_type EQ 2>disabled</cfif>"  />
                                         <cfset Disabled = 0>
                                         <!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made --->
                                         <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND listfind(ProductItemList, desRebateData.aProd[i].masterItemId) NEQ 0>
                                                <cfset Disabled = 1>
                                         </cfif>
                                         <cf_uom_dropdown
	                                         program_id                        		=       "#desRebateData.programID#"
	                                         company_main_id                   	=      ""
	                                         default_option_on           		=      "0"
	                                         default_option_text         		=      ""
	                                         default_option_value 			=      ""
	                                         dropdown_name               	=      "uom_#index#"
	                                         option_text_abbreviated     	=      "1"
	                                         plural_uom_display          		=      ""
	                                         product_type_id                   	=      "2"
	                                         program_template_id         	=      ""
	                                         selected_uom_id                   	=       "#desRebateData.aCompVal[index].UOMID#"
	                                         text_before_tag_close       		=       "onchange=""resetnavigate();"""
	                                         uom_id_exclusion_list       		=      ""
	                                         uom_id_inclusion_list       		=      ""
	                                         Disabled                          		=        "#Disabled#"
                                         >
                                         <cfif Disabled eq 1>
                                                <input type="hidden" name="uom_#index#" value="#desRebateData.aCompVal[index].UOMID#">
                                         </cfif>
                                  </td>
                           </cfloop>
                     </tr>
                    </cfif>

       </cfif>
       </tbody>
</table>

<!--- 34678 - When product count is more than 800 we divide products into multiple pages.
Therefore only a portion of the big products array is displayed on the page.
Pass form.startRow and form.endRow to \components\programs\rebates\Rebate.cfc to update database properly --->
<input type="hidden" name="startRow" value="#variables.startRow#">
<input type="hidden" name="endRow"   value="#min(variables.endRow, variables.getRebateProdIds.recordCount)#">
<input type="hidden" name="displayedProductList"   value="#displayedProductList#">


<cfif ArrayLen(desRebateData.aProd)>
	<INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">
	<!---hidden var to let rebate.cfc update method know when to pull component values from the form scope--->
	<INPUT TYPE="hidden" NAME="bGetFromForm" VALUE="1">
</cfif>

<cfsavecontent variable="massApplyRateUom">
	<!--- Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate START
	1) is Ezbutton --NO --Enable
	2) is Ezbutton --YES
	   Max Rate OR Absolute Rate
	     3) is Ezbutton AND Absolute --- YES --- DISABLE (GetSettings.Discount_Rebate_Max_Rate_On  = 1 == MAX, GetSettings.Discount_Rebate_Max_Rate_On  = 0 == Absolute)
	     4) is Ezbutton AND Max Rate
	           Template settings Enter Beyond Max Rate
	           5) is Ezbutton AND Max Rate AND  Template settings Enter Beyond Max Rate --- YES--- ENABLE
	           6) is Ezbutton AND Max Rate AND  Template settings Enter Beyond Max Rate --- NO --- ENABLE AND logic
	              if enter rate higher than max rate, rate for item is defaulted to 0 For adding new component - Default to 0. For mass apply – existing rate
	              if enter rate lower than or equal to max rate, rate for that item is defaulted to ENTERED rate
	--->

<b><font color="FF0000">[ </font></b>
	<cfif NOT(Revision_Products_Rates_Changes eq 0 AND Revision_Products_UOM_Changes eq 0)>
	    <cfset vars = {}>
  		    <cfif ( EzButton_Disable eq 0 ) or (GetSettings.Discount_Rebate_Max_Rate_On and GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates )>
	      <cfset vars.enableMultiAssigns = true>
	    <cfelse>
	      <cfset vars.enableMultiAssigns = false>
	    </cfif><span class="massApplyLink">
		<a <cfif vars.enableMultiAssigns>onclick="javascript:massapplyRateUom();"<cfelse>disabled</cfif> STYLE="cursor: pointer;font-weight:bold;">
			mass apply rate / uom
		</a></span>
	<cfelse>
		<span style="color:gray;font-weight:bold;">mass apply rate / uom</span>
	</cfif>
<b><font color="FF0000">]</font></b>

	<input 	name="apply_rate" type="text" size="10"
			ONKEYUP="clensetext(this)"
			onChange="this.value = formatToDeciamalPlaces(this.value,4)"
		<cfif EzButton_Disable EQ 1 AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0>
			DISABLED
		<cfelseif  EzButton_Disable EQ 1 AND GetSettings.Discount_Rebate_Max_Rate_On EQ 1>
		<cfelseif Revision_Products_Rates_Changes eq 0>
			STYLE="background-color: cccccc" DISABLED
		<cfelse>

		</cfif>/>
		<!--- Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate END--->

	<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
	 <cfif Revision_Products_Rates_Changes eq 0>
	 	<input type="hidden" name="apply_rate">
	 </cfif>
	<cfset disabled = 0>
	<!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made OR EzButton_Disable EQ 1 --->
	 <cfif Revision_Products_UOM_Changes eq 0>
		<cfset disabled = 1>
	 </cfif>
	 <cfset show_EA = 0/>
	 <cfif appSettings.getUOMEAAvailable() EQ 1>
	 	<cfset show_EA = 1/>
	 </cfif>
		<cf_uom_dropdown
			program_id					=	"#desRebateData.programID#"
			company_main_id			=	""
			default_option_on			=	"0"
			default_option_text			=	""
			default_option_value		=	"0"
			dropdown_name			=	"apply_uom"
			option_text_abbreviated	=	"1"
			plural_uom_display			=	""
			product_type_id			=	"2"
			program_template_id		=	""
			selected_uom_id			=	""
			text_before_tag_close		=	""
			uom_id_exclusion_list		=	""
			uom_id_inclusion_list		=	""
			setDefaultSelected			= 	1
			disabled					=	"#disabled#"
			show_EA					=	"#show_EA#"
		>
		<cfif Disabled eq 1>
			<input type="hidden" name="apply_uom" value="1">     <!--- 41094 - assigned default value to the same value in the drop-down --->
      <input type="hidden" name="Revison_UOM_Disable" value="1">
    <cfelse>
      <input type="hidden" name="Revison_UOM_Disable" value="0">
		</cfif>


<!---loop through the comp array and set hidden variables for component rule validation--->
<cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
       <!---param the comp var--->
       <cfparam name="form.uomsToCheck_#index#" default="" />
       <input type="hidden" name="uomsToCheck_#index#" value="#Evaluate("form.uomsToCheck_#index#")#" />
</cfloop>
<!---
Dev Notes: D27225: EZ Button Changes/Anand Rao
Changes were made so that we could display a message when the rate is greater than
the maxrate and highlight the fields that have a greater value.      The function chkMaxTmpltRate will
compare the rates and highlight and display the message.
--->
<table>
       <tr>
              <td nowrap="true">
                     <span id="spMaxRateWarn" style="display:#footerTip#">
                            <span style="background-color: red">
                                  &nbsp;red&nbsp;
                            </span>
                            = rate is above the maximum template setting
                     </span>
              </td>
       </tr>
</table>
</cfsavecontent>

<cfset alert_message = "">
<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
<cfsavecontent variable="MaxProdSearch">
  <input type="text" name="Rebatesearch" id="Rebatesearch" value="#form.Rebatesearch#" maxlength="350" />
  <b style="margin-left:10px"><font color="FF0000">[ </font>
    <a onclick="populateGrid();" tilte="Search for products to EDIT.  Use * to return all.">filter</a>
  <font color="FF0000">]</font></b>
    <cfif ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts()>
      <cfset alert_message = "This page is configured to only display products if there are less than #rebate.getMaxProducts()# products imported.">
    </cfif><br>
</cfsavecontent>
<cfsavecontent variable="bulletPointsInfo">
  <ul style="margin-top: 0px">
    <li>#ArrayLen(desRebateData.aProd)# #lcase(application.returned_customer_setting.item_label)#s/groups in this program</li>
    <li>Rate changes on each page are automatically saved as you move to a new page</li>
    <li>Enter #lcase(application.returned_customer_setting.item_label)# or group number (full or partial) or keywords from the #lcase(application.returned_customer_setting.item_label)# description to view specific #lcase(application.returned_customer_setting.item_label)#s</li>
    <li>You can filter for up to 25 #lcase(application.returned_customer_setting.item_label)#s at once by using a comma to separate the #lcase(application.returned_customer_setting.item_label)# numbers</li>
  </ul>
</cfsavecontent>

<CFELSE><!--- USE LARGE DATA Set Program Display...searchable etc --->
  <input type="hidden" name="Rebatesearch" id="Rebatesearch" value="*"  />
</CFIF>

<cfsavecontent variable="saveContent">
	<div id="rebateSave" class="bSaveRates">
		<a onclick="setPageLocate(1); validateform();" style="cursor:pointer">
			<b><font color="FF0000">[ </font> save <font color="FF0000">]</font></b>
		</a>
	</div>
</cfsavecontent>
<!--- [START] D55224: EZ Rates Enchancement - Disable save button while page is saving --->
<cfinclude template="/Common_Files/dataTables.cfm">
<link rel="stylesheet" href="/Script/css/smoothness/jquery-ui-1.11.4.custom.min.css">
<cf_include files="/styles/css-loader.css">
<cfinclude template="/Common_Files/jQuery.cfm">

<!--- <cfinclude template="/common_files/noty.cfm"> --->

<!--- commented out for D55224 --->
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<!--- <cfinclude template="/Common_Files/noty.cfm"> --->
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<!---<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>--->
<cfset session.nRebateSaveProgress = 0 />
<cfset session.nRebateSaveMax = 1 />
<div id="dialog" title="Saving Data">
	<cfif EZTemplate eq 1>
	<p/>
	<cfprogressbar name="rebateSaveProgress"
				   interval="700"
				   bind="cfc:components.programs.rebates.rebate.getSaveStatus()"
				   autodisplay="false"
				   width="350" >
	</cfif>
</div>

<div id="dProg" title="Validating Rates">
	<cfif EZTemplate eq 1>
    <p/>
	Rate Validation For <i>#ArrayLen(desRebateData.aProd)#</i> Products In Progress
	</cfif>
</div>
<!--- [END] D55224: EZ Rates Enchancement - Disable save button while page is saving --->
<script>
$( "##dProg" ).css('display', 'none');

oTable = $('.datagrid').dataTable( {
      "bServerSide": false
    , "bProcessing": true
    , "bSortClasses": false
    , "bAutoWidth": false
    , "bPaginate": false
    ,"sScrollY":  "500px"
<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
   , "bFilter": false
   , "sDom": "f<'MaxProducts'><'bulletPoints'><'multiAssign'><'save'>prt"
<CFELSE>
   , "oLanguage": {"sSearch": "<b>Search:</b>", "sEmptyTable": "<b>Please import products or provide a filter value</b>"}
    , "sDom": "f<'multiAssign'><'save'>prt"
</CFIF>
    , "aaSorting": []
    , "aoColumns": [
                                      {"sWidth": "40px", "bSearchable": false,      "bSortable":false} //Check Box
                              ,       {"bSearchable": true,       "bSortable":true} // Product ##
                              <cfif Form.Discount_Rebates_Group_Level eq 1 and AllowMultiLevelGroups and Product_Group_Sequencing eq '0'>
                              ,      {"bSearchable": true,       "bSortable":true}//Group Level
                              </cfif>
                              ,      {"bSearchable": false,      "bSortable":true} //Description
                              <cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type>
                              ,      {"bSearchable": false,      "bSortable":false} // Base Sales
                              </cfif>
                              <cfloop index="index" from="1" to="#ArrayLen(desRebateData.aComp)#">
                              ,      {"bSearchable": true,       "bSortable":false} //Comp
                              	<cfset qCompName = comp.getComp(desRebateData.aComp[index].compNameId)>
                                  			<cfquery name="AlternateRateSettings" datasource="#application.datasource#">
																						SELECT Alternate_Recapture_Rate_Label
																						FROM Alternate_Recapture_Rate_Setting
																						WHERE Program_Rebates_Component_Name_ID = #desRebateData.aComp[index].compNameId#
																						AND Status = 0
																				</cfquery>
                                  <cfloop query="AlternateRateSettings">
                                  ,      {"bSearchable": true,       "bSortable":false} // Alternate Rates
                                  </cfloop>
                                <cfif showrebateadditionalfields && GetSettings.Single_Component_Per_Discount_Type>
                                ,      {"bSearchable": true,       "bSortable":false} // Net Sales
                                ,      {"bSearchable": true,       "bSortable":false} // Disc %
                                </cfif>
                                ,      {"bSearchable": false,      "bSortable":false}// EMPTY TH
                              </cfloop>
                              <cfif UseFixedPriceType and URL.EZTemplate EQ 0 AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1>
                              ,      {"bSearchable": true,       "bSortable":false} // Comp Name
                              ,      {"bSearchable": true,       "bSortable":false} // Disc Cost
                              ,      {"bSearchable": true,       "bSortable":false} // Time Frame
                              <cfelse>
                              <cfif variables.getRebateProdIds.recordcount>
                              ,      {"bSearchable": false,      "bSortable":false} // EMPTY TH 2
                              </cfif>
                              </cfif>
                              <cfif CSLGetContractInfo.Like_Product_Exist eq 1>
                              ,      {"bSearchable": true,       "bSortable":false} // Similar Product
                              </cfif>
                              <cfif ArrayLen(desRebateData.aComp)>
                              ,      {"sWidth": "50px", "bSearchable": false,       "bSortable":false} // Save
                              </cfif>
                            ]
      	} ).fnSetFilteringDelay();


function showmessage(){
  $('.showmessage').show(0).delay(2000).hide(0);
}

$(".editablefield").live('keypress', function(e) {
    if (e.keyCode === 9 || e.keyCode == 13) {
      $(this).next('.editablefield').focus();
    }
});

$('div.multiAssign').html(	'#application.util.string.compress(massApplyRateUom)#');
$('div.save').html('#application.util.string.compress(saveContent)#');
<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
$('div.maxProducts').html(  '#application.util.string.compress(MaxProdSearch)#');
$('div.bulletPoints').html(  '#application.util.string.compress(bulletPointsInfo)#');
</CFIF>

function clensetext(textvalue){
	clenseText(textvalue,"0123456789.")
}

function disableActions(){
	disableButton("pageLink","true");
	disableClass(".bSaveRates","true");
	disableClass(".bAddProdGroups","true");
	disableClass(".contractLinks","true");
	disableClass(".massApplyLink","true");
	disableClass(".imgDeleteScissor","true");
	show_loader( "SAVING CHANGES, PLEASE WAIT...", 1000 );
}
function validateform(){
	//disableActions();
	validateForm("#variables.saveBtnAction#", 1, "save_table","#url.EZTemplate#","#EzButton_Disable#","#variables.Profile_EzButtonApproveBeyondMaxRate#","#GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates#")
}
      $(".addinfo").mouseenter(function(){
        $(this).siblings("div.on-hover-content").show();
      })
      .mouseleave(function(){
        $(this).siblings("div.on-hover-content").hide();
      });
function massapplyRateUom(){
       var compCheck = document.querySelectorAll("input[name=comp]");
       var count = 0;
       for (var i = 0; i < compCheck.length; i++) {
		if (compCheck[i] && compCheck[i].checked == true) {
			count++;
		}
       }
       if (count) {
              submitForm("appVolComp");
       }else{
              alert('Please select a component to apply mass changes.')
       }
}

function chkMaxTmpltRate(txtRate,MaxRate,textid,templateEZUOM,itemUOM,itemNetWeight)
{
//var srcObj = event.srcElement;alert(srcObj)
// STYLE="background-color: red"
//D45240
       if(templateEZUOM != itemUOM && itemUOM != 5){
              if(templateEZUOM == 1 ){
                     //Convert program rate from LB to CS
                     txtRate = txtRate * itemNetWeight;
              }
              if(templateEZUOM == 2 ){
                     //Convert program rate from CS to LB
                     txtRate = txtRate / itemNetWeight;
              }
       }
//D45240

       if (txtRate  > MaxRate){
            if ( document.getElementById(textid) ) {
                // ngt
                document.getElementById(textid).style.backgroundColor = "red";
            }
              //D45240 srcObj.style.backgroundColor = "red";
              document.all.spMaxRateWarn.style.display = "inline";
       }
       else   {
              //D45240 srcObj.style.backgroundColor = "";
             // document.getElementById(textid).style.backgroundColor = "";
                     $('##'+textid).css("background-color", "");

       }
}
//D38536  :: Alternate recapture rates per component START
function changebg(obj){
       var srcObj = event.srcElement;
       if (srcObj.value > '0.0000') {
              srcObj.style.backgroundColor = "";
       }
}
//D38536  :: Alternate recapture rates per component END
function editcomponentpaidto(compid,paidto)
{
NewWindow("ezprogram_editcomponent.cfm?ProgramType_ID=<cfoutput>#CSLGetContractInfo.ProgramType_ID#</cfoutput>&discounttypeid=2&programid=<cfoutput>#form.CONTRACT_MAIN_ID#</cfoutput>&Formname=dataForm&Business_Segment_ID=#businessSegmentID#&PaidTo="+paidto+"&compid="+compid, "editcomponentinfo", 300, 200, "yes", "yes", true);
}

function setDiscPerc(rate,ix){
       var id = 'spDiscPerc' + ix.toString();
       var percDiv = document.getElementById(id);
       percDiv.innerHTML = '1234';
}

function showCompetitorSource_Other(id)
{
       var field =  "Competitor_Name_ID_";
       var field = field.concat(id);

       var tfield =  "CompetitorSourceOther_";
       var tfield = tfield.concat(id);

       if(document.getElementById(field).value == '-1')
       {
       document.getElementById(tfield).style.display = "block";
       }
       else
       {
       document.getElementById(tfield).style.display = "none";
       }
}

function validateRate(compProdID){
       /* Dev Note: Milan Start - (For Competitor Info) */
       var frmRebates = document.forms['dataForm'].elements;
       var name_;
       var elem;
       var value_;
       value_ = eval('document.dataForm.comp_rate_' + compProdID+  '.value');

	<cfif UseFixedPriceType and URL.EZTemplate EQ 0 AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1>
              if(value_ != 0){
              document.getElementById('tdCompetitor' + compProdID + '_All').style.backgroundColor = '#variables.svfixed_price_type_bgcolor#';
              document.getElementById(compProdID + '_TDCPrice').style.backgroundColor = '#variables.svfixed_price_type_bgcolor#';
              document.getElementById(compProdID + '_TDCTimeFrame').style.backgroundColor = '#variables.svfixed_price_type_bgcolor#';
              }
              else{
              document.getElementById('tdCompetitor' + compProdID + '_All').style.backgroundColor = '';
              document.getElementById(compProdID + '_TDCPrice').style.backgroundColor = '';
              document.getElementById(compProdID + '_TDCTimeFrame').style.backgroundColor = '';
              }
       </cfif>
       }

	var client_height = document.body.clientHeight;
	client_height = client_height - 455;
	datagrid_height = client_height + 'px';

	/* To set the height of the data body (scrollable data) inside the rebate datagrid.
	This is to prevent double scroll bars.
	*/
	$('.dataTables_scrollBody').css('height', datagrid_height);
	//62343 8.0 - Blended Rate, CF START
	function CalRateCal(UOM,BaseRate, DiscountRate, BaseVolume, BaseVolume_LB, TotalVolume, TotalVolume_LB, RecaptureVolume, RecaptureVolume_LB, compVarReplace){

            /* IF PRODUCT OR GROUP UOM NOT LB OR CS WE ASSIGN TEMPLATE DEFAULT UOM WHEN CALCULATING BLENDED RATE, IF TEMPLATE DOESN'T HAVE A DEFAULT UOM WE ASSIGN UOM CS TO PRODUCT OR GROUP*/
            if(UOM >2){
              if(#GetSettings.RateTypeDefault# == 2){
                UOM = #GetSettings.RateTypeDefault#;
              }else{
                UOM = 1;
              }
            }
		if (TotalVolume) {
              if(UOM == 2){
                  var CalRate = ((BaseRate * BaseVolume_LB) + (DiscountRate * RecaptureVolume_LB)) / TotalVolume_LB;
              }else{
                  var CalRate = ((BaseRate * BaseVolume) + (DiscountRate * RecaptureVolume)) / TotalVolume;
              }
		}else{
			var CalRate = '0.0000';
		}
		$('##blended_calculated_rate_'+compVarReplace).val(CalRate)
	}
	//62343 8.0 - Blended Rate, CF END
    function decimal_format( value, product ) {
        // locate the related uom
        let uom = $("select[name=uom_" +  product  + "]").val();
        let decimal_places = -1;

        <cfoutput>
            switch (uom) {
                case '1':
                    decimal_places = #val( application.util.query.get_Setting("Decimal_display_for_CS", 0) )#;
                    break;
                case '2':
                    decimal_places = #val( application.util.query.get_Setting("Decimal_display_for_LB", 0) )#;
                    break;
                case '3':
                    decimal_places = #val( application.util.query.get_Setting("Decimal_display_for_Percentage", 0) )#;
                    break;
                case '5':
                    decimal_places = #val( application.util.query.get_Setting("Decimal_display_for_EA", 0) )#;
                    break;
                case '6':
                    decimal_places = #val( application.util.query.get_Setting("Decimal_display_for_CWT", 0) )#;
                    break;
            }
        </cfoutput>

        return decimal_places < 0
                    ? value
                    : formatToDeciamalPlaces( value, decimal_places );
    }
</script>
<input type="hidden" name="deleted" value="0"><!--- D30231:Deleting Items off a Revised Program --->
</cfoutput>
<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release END--->

<cfif alert_message neq "">
	<script>	noty( {  text:      "<cfoutput>#alert_message#</cfoutput>"
						,type:      "information"
						,layout:    "bottom"
						,timeout:   7000
						,closeWith: ["click"]
					});
	</script>
</cfif>