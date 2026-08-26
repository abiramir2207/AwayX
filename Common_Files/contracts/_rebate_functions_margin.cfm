
<cfoutput>
<form action="#fullURL#" method="post" name="dataForm" id="dataForm" style="display:inline">
<cfset tabWidth = "800">
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfset tabWidth = "750">
</cfif>

<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">

	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">#Application.RebateLabel# Component Information</LEGEND>

<!------ set revision settings variables ----->
<cfset Revision_Products_Rates_Changes = 1 />
<cfset Revision_Products_UOM_Changes = 1 />
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2>
	<cfset Revision_Products_Rates_Changes = 0 />
</cfif>
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2>
	<cfset Revision_Products_UOM_Changes = 0 />
</cfif>
	
<cfset colsAtComponentSection = 4 />
<cfif appSettings.getClaims_at_Comp_Level()>
	<cfset colsAtComponentSection = colsAtComponentSection + 1 />
</cfif>
<cfset Display_Basis_Treatment_Code = 0 />
<cfif appSettings.getOperatingGroupOn()>
	<cfset Display_Basis_Treatment_Code = 1 />
	<cfset colsAtComponentSection = colsAtComponentSection + 1 />
</cfif>

<cfset arAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />
<!------ Operating Group ----->
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=FORM.Contract_Main_ID) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 2) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />	
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
	<cfset bTemplateLevelComponentFilter = 0 />
</cfif>
<!------ Operating Group ----->
<cfif bTemplateLevelComponentFilter>
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 2, 1) />		
	<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
</cfif>

<cfset isUSDA = 0>
<!---Return only usda components --->
<cfif GetContractInfo.Generic_Type IS "USDA NOI">
	<cfset isUSDA = 1>
</cfif>
<cfscript>
	qGetActiveComps = comp.getActive(
			profileId=request.AccessStructure.Profiles_ID, 
			isUSDA=isUSDA,
			Price_Protection_on=getSettings.Price_Protection_on,
			arAllowList=arAllowList);
</cfscript>

<cfif Display_Basis_Treatment_Code>
	<cfquery name="qComponentNames" dbtype="query">
		SELECT	Program_Rebates_Component_Name_ID Component_Name_ID, Allowance_Code_ID Component_Allowance_Code_ID
		FROM	qGetActiveComps
	</cfquery>
	<cfinclude template="Contract_Basis_Tratment_Code.cfm" />
</cfif>
	
<cfset multiassignmentCols = 2 />
<cfif Display_Basis_Treatment_Code EQ 1>
	<cfset multiassignmentCols = 3 />
</cfif>
<table WIDTH="250" border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td COLSPAN="4" STYLE="border-bottom:solid 1px blue;display:none;"><B>Components</B></td>
		<td BGCOLOR="white" ROWSPAN="3" style="display:none;">&nbsp;&nbsp;</td>
		<td COLSPAN="#multiassignmentCols#" width="150" STYLE="border-bottom:solid 1px blue;">
			<B>Multi Assignment Tool</B>&nbsp;&nbsp;&nbsp;
			<font color="##0000FF" size="3" title="Use this feature to make adjustments to the rate/uom for any item/component combinations listed below." STYLE="cursor:pointer">
				<b>?</b>
			</font>
		</td>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<td BGCOLOR="white" ROWSPAN="4" style="border-right:1px solid blue;">&nbsp;&nbsp;</td>
		<td BGCOLOR="white" ROWSPAN="4">&nbsp;</td>
		<td><B>Select Payment Cycle</B></td>
		</cfif>
	</tr>
	<tr BGCOLOR="eeeeee">
		<td  style="display:none;">Component Name</td>
		<td  style="display:none;">Default Rate</td>
		<td  style="display:none;">UOM</td>
		<td  style="display:none;">Paid To</td>
		<cfif appSettings.getClaims_at_Comp_Level() AND GetPaymentTypesforTemplate.Recordcount GT 0>
		<td style="display:none;">Claim Mechanism</td>
		</cfif>
		<cfif Display_Basis_Treatment_Code>
		<td style="display:none;">Treatment Code/Basis Code</td>
		</cfif>
		<cfif Display_Basis_Treatment_Code EQ 0>
		<td>Rate</td>
		<td>UOM</td>
		<cfelse>
		<td>Rate</td>
		<td>Buy</td>
		<td>Get Free</td>
		</cfif>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<td>
		<cfparam name="FORM.PaymentCycle" 	default="">
		<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "#FORM.Contract_Main_ID#"
			discount_Type_ID = "2"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			>
		</td>
		</cfif>
	</tr>
	<tr BGCOLOR="eeeeee">
		<td style="display:none;"><input name="volume" type="text" value="" size="3" ONKEYUP="clenseText(this,'0123456789')" /></td>
		<td style="display:none;">
		
			<!------ external id ----->
			<select name="compNameId" style="width:120px" 
				onchange="disableRateBox(this);<cfif Display_Basis_Treatment_Code>loadDefaultBasisTreatmentCodeForComponentName(this.value);</cfif>"
				>
				<option>Select #Application.RebateLabel# Component...</option>
				<cfloop query="qGetActiveComps">
					<option value="#Program_Rebates_Component_Name_ID#" is_usda_comp="#qGetActiveComps.IS_USDA_NOI_COMP#" rebate_type="#qGetActiveComps.rebate_type#" <cfif qGetActiveComps.recordcount EQ 1>selected</cfif>>#Allowance_Code_ID# #Program_Rebates_Component_Name#<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif></option>
				</cfloop>
			</select>
		</td>
		<td  style="display:none;"><input name="rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" /></td>
		<td  style="display:none;">
							
			<cf_uom_dropdown
				program_id				=	"#desRebateData.programID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"2"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1		
			>
		
		</td>
		<td  style="display:none;">
			<!---check to see if we can select Paid To: Distributor, Operator or both based on Template Generic Type--->

	<cfscript> 
	GetPaymentPaidToTypes = CreateObject('component', 'components.Programs.template.TemplateManager').GetPaymentPaidToTypes(CSLGetContractInfo.ProgramType_ID);
	</cfscript>
	<cfloop query="GetPaymentPaidToTypes">
	<input name="Component_Paid_To" type="Radio" value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>" <cfif GetSettings.PaidToDefaultOption eq Payment_Paid_To_ID>checked</cfif>><cfoutput>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</cfoutput><br>
	</cfloop>
		</td>
		<cfparam name="FORM.ClaimMechanic" 	default="#CSLGetContractInfo.ClaimMechanics#">
		<cfif appSettings.getClaims_at_Comp_Level() AND GetPaymentTypesforTemplate.Recordcount GT 0>
		<td style="display:none;">
		<cf_claim_mechanic_selection
			Default_Claim_Selection = "#CSLGetContractInfo.ClaimMechanics#"
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Edit_Selection = "#FORM.ClaimMechanic#"
			Is_Revision = "#CSLGetContractInfo.Is_a_Revision#">
		</td>
		<cfelse>
			<input type="hidden" name="Claim_Mechanics" value="#CSLGetContractInfo.ClaimMechanics#">
		</cfif>
		<cfif Display_Basis_Treatment_Code EQ 1>
		<td style="display:none;">
		<select name="Treatment_Code" style="width:140px" onchange="loadBasisCodes(this.value);">
			<option value="0">Select Treatment Code...</option>
			<cfloop query="qGetTreatmentCodes">
			<option value="#Treatment_Code_Master_ID#">#Treatment_Code_Desc#</option>
			</cfloop>
		</select>
		<br>
		<select name="Basis_Code" style="width:140px">
			<option value="0">Select Basis Code...</option>
		</select>
		</td>
		</cfif>
		<cfif Display_Basis_Treatment_Code EQ 0>
		<td>		
		<input name="apply_rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" 
			<cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>
			 />
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_rate">
		 </cfif>
		</td>		
		<td>
		<cfset disabled = 0>
		<!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made --->
		 <cfif Revision_Products_UOM_Changes eq 0>
			<cfset disabled = 1>
		 </cfif>
			<cf_uom_dropdown
				program_id				=	"#desRebateData.programID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"apply_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"2"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1		
				disabled				=	"#disabled#"
			>
			<cfif Disabled eq 1>
				<input type="hidden" name="apply_uom" value="0">
			</cfif>			
		</td>
		<cfelse><!------ Revision_Products_Rates_Changes EQ 1 ----->
		<td>
		<!------ Rate ----->
		<input name="apply_rate" type="text" size="2" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" 
			<cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>
			 />
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_rate">
		 </cfif>
		 <br>
		<cfset disabled = 0>
		<!--- If the program is a revision and revision settings has retrictions for this program and product UOM changes cannot be made --->
		 <cfif Revision_Products_UOM_Changes eq 0>
			<cfset disabled = 1>
		 </cfif>
		 <!------ Rate UOM ----->
			<cf_uom_dropdown
				program_id				=	"#desRebateData.programID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"apply_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"2"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1	
				disabled				=	"#disabled#"
			>
			<cfif Disabled eq 1>
				<input type="hidden" name="apply_uom" value="0">
			</cfif>			
		</td>
		<td>
		<!------ Buy ----->
		<input name="apply_basis_code_quantity" type="text" size="2" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" 
			<cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>
			 />
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_basis_code_quantity">
		 </cfif>
		 <br>
		  <!------ Buy UOM ----->
			<cf_uom_dropdown
				program_id				=	"#desRebateData.programID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"apply_basis_code_quantity_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"2"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	"3"
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1	
				disabled				=	"#disabled#"
			>
			<cfif Disabled eq 1>
				<input type="hidden" name="apply_basis_code_quantity_uom" value="0">
			</cfif>	
		</td>
		<td>
		<!------ Get Free ----->
		<input name="apply_basis_code_free_goods" type="text" size="2" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" 
			<cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>
			 />
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_basis_code_free_goods">
		 </cfif>
		 <br>
		  <!------ Get Free UOM ----->
			<cf_uom_dropdown
				program_id				=	"#desRebateData.programID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"apply_basis_code_free_goods_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"2"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1	
				disabled				=	"#disabled#"
			>
			<cfif Disabled eq 1>
				<input type="hidden" name="apply_basis_code_free_goods_uom" value="0">
			</cfif>	
		</td>
		</cfif>
	</tr>
	<tr BGCOLOR="eeeeee">
		<td style="display:none;" colspan="#colsAtComponentSection#"><B><font color="FF0000">[</font> <a onclick="<cfif EzButton_Disable EQ 0>javascript:submitForm('comp');<cfelse>""</cfif>" STYLE="cursor: pointer;">include this #Application.RebateLabel# component</a> <font color="FF0000">]</font></B></td>
		<td colspan="#multiassignmentCols#"><B><font color="FF0000">[</font>
		<!--- If the program is a revision and revision settings has retrictions for this program and products UOM and rate changes cannot be made --->
		<cfif NOT(Revision_Products_Rates_Changes eq 0 AND Revision_Products_UOM_Changes eq 0)>
			<a onclick="<cfif EzButton_Disable EQ 0>javascript:submitForm('appVolComp');<cfelse>""</cfif>" STYLE="cursor: pointer;">apply rate / uom</a>	
		<cfelse>
			<span style="color:gray">apply rate / uom</span>
		</cfif> <font color="FF0000">]</font></B>
		</td>
		<td BGCOLOR="White">&nbsp;&nbsp;&nbsp;</td>
		<td BGCOLOR="White">&nbsp;&nbsp;&nbsp;</td>
	</tr>
</table>
<br>
</FIELDSET>
<!---Modification: Group Deals--->
<!---this value is used to strip out all the stuff BSA uses for groups in rebates--->
<!--- <cfset BSAGroups = 0 />
<cfif Form.Discount_Rebates_Group_Level eq 1 and application.returned_customer_setting.customer_keyword eq "conagra">
	<cfset BSAGroups = 1 />
</cfif> --->

<!--- <cfif BSAGroups> --->
<cfif Form.Discount_Rebates_Group_Level eq 1 and appSettings.getAllowMultiLevelGroups()>
<br>
	<cfoutput>
	<table WIDTH="300" border="0" cellpadding="0" cellspacing="0">
	
		<tr valign="middle">
		
			<td bgcolor="##ccffcc">
				<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
			</td>
			<td>&nbsp;= #arPricingLevel[1]#&nbsp;&nbsp;&nbsp;</td>
	
			<td bgcolor="##DFE6FF">
				<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
			</td>
			<td>&nbsp;= #arPricingLevel[2]#&nbsp;&nbsp;&nbsp;</td>
	
			<td bgcolor="##E2CBE4">
				<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
			</td>
			<td>&nbsp;= #arPricingLevel[3]#&nbsp;&nbsp;&nbsp;</td>
	
		</tr>
		
	</table>
	</cfoutput>
	
</cfif>

<br>
<span style="width:600px;display:none;">
<B>

<!---Modification: Group Deals--->
<!---show add products or add group/levels depending on what was set in control panel options--->
<cfif Form.Discount_Rebates_Group_Level eq 1>
	<cfset addGroupLabel = "add groups" />
	<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()>
		<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
	</cfif>
	 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	<CF_smallLink 
			title = "#addGroupLabel#"
			url = "##"
			enabled = "0"
		>
	 <cfelse>
		<CF_smallLink 
			title = "#addGroupLabel#"
		url = "##"
		parameters = "onClick=""javascript: return showGroupSearchWindow();"""
	>
	</cfif>
</cfif>

<cfif Form.Discount_Rebates_Item_Level eq 1>
	<cfset addProductAtLevel = 0 /> <!------ Default, determine by itself ----->
	<cfset addProductLabel = "add products" />
	<cfif restrictLowerLevelBasedonLevel1>
		<cfset addProductLabel = "add #LCase(arPricingLevel[2])# products" />
		<cfset addProductAtLevel = 2 /> <!------ At level 2 ----->
	</cfif>
 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	<CF_smallLink 
		title = "#addProductLabel#" 
		url = "##"
		enabled = "0"
	>
<cfelse>
	<CF_smallLink 
		title = "#addProductLabel#" 
		url = "##"
		parameters = "onClick=""javascript: return showProductSearchWindow(#addProductAtLevel#);"""
	>
</cfif>
	<!------ Level 3 ----->
	<cfif restrictLowerLevelBasedonLevel1>
	<cfset addProductLabel = "add #LCase(arPricingLevel[3])# products" />
	<cfset addProductAtLevel = 3 /> <!------ At level 3 ----->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	<CF_smallLink 
		title = "#addProductLabel#" 
		url = "##"
		enabled = "0"
	>
<cfelse>
	<CF_smallLink 
		title = "#addProductLabel#" 
		url = "##"
		parameters = "onClick=""javascript: return showProductSearchWindow(#addProductAtLevel#);"""
	>
</cfif>
	</cfif>
	
</cfif>
<!--- <font color="FF0000">[</font> <a href="javascript:showProductSearchWindow();">add products</a> <font color="FF0000">]</font> --->
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(desRebateData.programId) />

<cfif ProductGroupManager.allowSelectAllProducts(2, desRebateData.programId)>

  <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>	
	<cf_smallLink
		title = "add all products"
		url = "##"
		enabled = "0"
	>
  <cfelse>
	<cf_smallLink
		title = "add all products"
		url = "##"
		parameters = "onClick=""javascript: addGroupsLevelProducts(1, '#businessSegmentID#'); return false;"""
	>
  </cfif>
		
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	
</cfif>

<!--- <font color="FF0000">[</font> <a href="javascript:submitForm('remProd')">remove selected products</a> <font color="FF0000">]</font> --->
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</B>

</span>

<!---Include the component table--->
<cfinclude template="_rebates_components_margin.cfm" />

<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">
<input type="hidden" name="Price_Protection_on" value="#form.Price_Protection_on#">
<INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
<input type="Hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />
<input type="hidden" name="action" value="prod" />
<input type="hidden" name="applyVol" value="" />
<input type="hidden" name="sessionFile" value="#sessionFile#" />
<input type="hidden" name="comps" value="" />
<input type="hidden" name="compLen" value="#ArrayLen(desRebateData.aComp)#" />
<input type="hidden" name="prodLen" value="#ArrayLen(desRebateData.aProd)#" />
<input type="hidden" name="compUUID" value="#compUUID#" />
<input type="hidden" name="init" value="#init#" />
<INPUT TYPE="Hidden" NAME="Sort_By" VALUE="#URL.Sort_By#">
<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#URL.CID#">
<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#Form.Product_List#">
<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Product_List#">
<INPUT TYPE="Hidden" NAME="DTPS_On" VALUE="1">
<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" VALUE="#FORM.Contract_Main_ID#">
<INPUT TYPE="Hidden" NAME="sortBy" VALUE="#sortBy#">
<INPUT TYPE="Hidden" NAME="sortOrder" VALUE="#sortOrder#">
<!---Modification: Group Deals--->
<input type="Hidden" name="Discount_Rebates_Item_Level" value="#Form.Discount_Rebates_Item_Level#" />
<input type="Hidden" name="Discount_Rebates_Group_Level" value="#Form.Discount_Rebates_Group_Level#" />
<input type="Hidden" name="Level_1" value="#Form.Level_1#" />
<input type="Hidden" name="Level_2" value="#Form.Level_2#" />
<input type="Hidden" name="Level_3" value="#Form.Level_3#" />
<!--- Variable controls redirection to "Margin Edit" version of contract rebates --->
<input type="Hidden" name="RedirectPath" value="1" />

<!---clean up the group levels--->
<cfif trim(form.Level_1) eq "">
	<cfset form.GroupLevel_1 = "" />
</cfif>
<cfif trim(form.Level_2) eq "">
	<cfset Form.GroupLevel_2 = "" />
</cfif>
<cfif trim(form.Level_3) eq "">
	<cfset Form.GroupLevel_3 = "" />
</cfif>
<input type="hidden" name="GroupLevel_1" value="#Form.GroupLevel_1#" />
<input type="hidden" name="GroupLevel_2" value="#Form.GroupLevel_2#" />
<input type="hidden" name="GroupLevel_3" value="#Form.GroupLevel_3#" />
<input type="hidden" name="Allow_Multi_Levels" value="#form.Allow_Multi_Levels#" />
<INPUT TYPE="Hidden" NAME="navigate" VALUE="#FORM.navigate#">
<INPUT TYPE="Hidden" NAME="stopnavigate" VALUE="0">
<INPUT TYPE="Hidden" NAME="Dynamic_Static_Groups" VALUE="#form.Dynamic_Static_Groups#">
<cfif restrictLowerLevelBasedonLevel1>
	<input type="hidden" name="AllowProductGroupList" value="#Form.Level_1#" />
	<input type="hidden" name="AllowProductGroupLevelId" value="#Form.GroupLevel_1#" />
	<input type="hidden" name="IsRestrictLowerLevelBasedonLevel1On" value="#restrictLowerLevelBasedonLevel1#" />	
</cfif>


<!---Min/max values--->
	<cfparam name="getSettings.Min_Rebate_Case" default="0">
	<cfparam name="getSettings.Max_Rebate_Case" default="0">
	<cfparam name="getSettings.Min_Rebate_Pound" default="0">
	<cfparam name="getSettings.Max_Rebate_Pound" default="0">
	<cfparam name="ThereisMinorMax" default="0">
	
	<!---Sets min and max values if they exist for the profile--->
	<cfif len(trim(getSettings.Min_Rebate_Case)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Min_Rebate_Case" value="#getSettings.Min_Rebate_Case#">
	<cfif len(trim(getSettings.Max_Rebate_Case)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Max_Rebate_Case" value="#getSettings.Max_Rebate_Case#">
	<cfif len(trim(getSettings.Min_Rebate_Pound)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Min_Rebate_Pound" value="#getSettings.Min_Rebate_Pound#">
	<cfif len(trim(getSettings.Max_Rebate_Pound)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Max_Rebate_Pound" value="#getSettings.Max_Rebate_Pound#">
	<cfif len(trim(getSettings.Min_Rebate_Percent)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Min_Rebate_Percent" value="#getSettings.Min_Rebate_Percent#">
	<cfif len(trim(getSettings.Max_Rebate_Percent)) IS NOT 0>
		<cfset ThereisMinorMax = 1>
	</cfif>
	<input type="hidden" name="Max_Rebate_Percent" value="#getSettings.Max_Rebate_Percent#">
	<input type="hidden" name="ThereisMinorMax" value="#ThereisMinorMax#">
	<!---end min/max values--->
	<input type="hidden" name="donotallowaddproductsDE" value="#form.donotallowaddproductsDE#">
	<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
</form>

</cfoutput>