<!---
	Dev Notes: 22308/Anand Rao/04-Feb-10
	CAG - multi discount type template
--->
<cfset Contract_Main_ID = cryp.value>
<cfset sDiscountType = "REBATE" />
<cfinclude template="inc_Discount_Type_Checker.cfm" />
<cfoutput>
<form action="#fullURL#" method="post" name="dataForm" id="dataForm" style="display:inline">

<input type="hidden" name="compAlertCount" value="0" />
  <cfoutput>
    <input type="hidden" name="bAllowAddComp" value="#bAllowAddComp#" />
	<!---
		Dev Notes: 21553/Anand Rao/04-Mar-10
		HZ - min/max rates for EZ button
	--->
    <cfif (GetSettings.EZButton_On EQ 1 AND URL.EZTemplate EQ 0 AND (GetSettings.Discount_Rebate_Max_Rate_On EQ 1))>
      <input type="hidden" name="bDoCheckMaxVal" value="1" />
    <cfelse>
        <input type="hidden" name="bDoCheckMaxVal" value="0" />
    </cfif>
  </cfoutput>


<cfset tabWidth = "800">
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfset tabWidth = "750">
</cfif>

<cfif appSettings.getProgram_Allow_Negative_Rebate_Rates() eq 1>
	<cfset TextAllowedInTextBox ="0123456789.-">
<cfelse>
	<cfset TextAllowedInTextBox ="0123456789.">
</cfif>

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
<cfif appSettings.getClaims_at_Comp_Level() AND GetPaymentTypesforTemplate.Recordcount GT 0>
	<cfset colsAtComponentSection = colsAtComponentSection + 1 />
</cfif>

<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfset colsAtComponentSection = colsAtComponentSection +1 />
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
<cfif CSLGetContractInfo.Generic_Type IS "USDA NOI">
	<cfset isUSDA = 1>
</cfif>
<cfscript>
	qGetActiveComps = comp.getActive(
			profileId=request.AccessStructure.Profiles_ID,
			isUSDA=isUSDA,
			Price_Protection_on=getSettings.Price_Protection_on,
			arAllowList=arAllowList,
			ExcludeSecondComponent = 1,
			ProgramID = GetContractInfo.Contract_Main_ID
			);
			/*
			D31949:Price Protection Component not Appearing.
			THIS TWO ATTRIBUTES ARE COMMENT OUT TO PREVENT FILTERING REBATE COMPONENTS BASED ON EZ RATE.
			,
			EzButton_Disable = EzButton_Disable,
			GetEZButtonComp = EZ_Rebate_Comp_Ids);*/
</cfscript>

<cfif Display_Basis_Treatment_Code>
	<cfset useLakebaseForqComponentNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetactivecomps")>
<cfif useLakebaseForqComponentNames>
	<cftry>
		<cfset qComponentNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetactivecomps", {
				"select" = "program_rebates_component_name_id component_name_id,allowance_code_id component_allowance_code_id"
			}), "program_rebates_component_name_id component_name_id,allowance_code_id component_allowance_code_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqComponentNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqComponentNames>
<cfquery name="qComponentNames" dbtype="query">
		SELECT	Program_Rebates_Component_Name_ID Component_Name_ID, Allowance_Code_ID Component_Allowance_Code_ID
		FROM	qGetActiveComps
	</cfquery>
</cfif>
	<cfinclude template="Contract_Basis_Tratment_Code.cfm" />
</cfif>

<cfset multiassignmentCols = 2 />
<cfif Display_Basis_Treatment_Code EQ 1>
	<cfset multiassignmentCols = 4 />
</cfif>
<!--- "display:table" will make sure that the width of the fieldset becomes the width of the table inside it. --->
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(desRebateData.programId) />
<cfif url.EZTemplate>
	<input type="hidden" name="compNameId" value= "#qGetActiveComps.Program_Rebates_Component_Name_ID#">
</cfif>
<cfoutput>
<FIELDSET class="clBox" STYLE="padding:10px; width: 1075px; border: 1px solid Blue; <cfif form.bFromMargin>display:none;<cfelse>display:table;</cfif>">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#Application.RebateLabel#</LEGEND>
<table WIDTH="1075" border="0" cellpadding="1" cellspacing="0">
<tr>
	<td colspan="#colsAtComponentSection#" class="bAddProdGroups">
	<!--- Start: Add groups/products --->
	<B>Step 1:&nbsp;</B>
<!---		Criteria under which [create product/rate list] link is available
		1.	Template is not configured as ez button absolute rate.
                    Discount_Rebate_Max_Rate_On default value is 0 (absolute rate) so I also looking if template is EZbutton too.
		2.	If template is configured as ez button max rate, user profile should be able to enter beyond max rate.
		      If template setting "Allow users to enter rates greater than max " is ON or Profile lets user to allow above maxrate
 --->

<!--- D30485: Issues with selecting products by pricing levels START  MOVIED THIS QUERY FROM LINE 747 --->
<cfif ArrayLen(desRebateData.aProd)>
  <cfset variables.productCount = 0 />
    <cfloop index="i" from="1" to="#ArrayLen(desRebateData.aProd)#">
      <cfif not ListFindNoCase(form.Product_List, desRebateData.aProd[i].masterItemId)>
        <cfset form.Product_List = ListAppend(form.Product_List, desRebateData.aProd[i].masterItemId) />
      </cfif>
      <cfif Len(trim(desRebateData.aProd[i].pricingLevel)) and trim(desRebateData.aProd[i].pricingLevel) neq 0>
        <cfset "form.GroupLevel_#desRebateData.aProd[i].pricingLevel#" =  desRebateData.aProd[i].productGroupLevel />
      </cfif>  <!--- get first prod --->
      <cfset Form.groupLevelProducts = desRebateData.aProd[i].productGroupLevel>
    </cfloop>
</cfif>
<!--- D30485: Issues with selecting products by pricing levels END  --->

<cfset dislayCreateProductRateList = 1>

<cfif GetTemplateInfo.EZButton_On >
	<cfif GetTemplateInfo.Discount_Rebate_Max_Rate_On AND (GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates OR Get_Profile_Settings.EzButton_Approve_Beyond_MaxRate)>
		<cfset dislayCreateProductRateList = 1>
	<cfelse>
		<cfset dislayCreateProductRateList = 0>
	</cfif>
</cfif>

<cfif dislayCreateProductRateList>
	<cfquery name="RebateCompCount" datasource="#application.datasource#">
		SELECT *
		FROM dbo.Program_Rebates_Component
		WHERE Program_ID = #desRebateData.programID#
		AND Deleted = 0
	</cfquery>
			<!---disable create product / rate list if revision settings don't allow ---> 
			<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
				#application.util.string.actionLinkFormat("create product / rate list")#
			<cfelse>
				<a onClick="javascript: return showCreateProdcutListWindow();" style="cursor:pointer">#application.util.string.actionLinkFormat("create product / rate list")#</a>
			</cfif>

</cfif>

	<!----Modification: Group Deals--->
	<!---show add products or add group/levels depending on what was set in control panel options--->
	<!--- D49065 :: Added "url.EZTemplate"  to below condition to display "add groups" in EZ button window irrespective of detials tab setting--->
<cfif Form.Discount_Rebates_Group_Level eq 1 OR url.EZTemplate eq 1>
	<cfset addGroupLabel = "add groups" />
	<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel() AND appSettings.get_Setting('Product_Group_Sequencing') neq '1'>
		<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
	</cfif>
	 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
		   #application.util.string.actionLinkFormat("#addGroupLabel#")#
	 <cfelse>
		   <a onClick="javascript: return showGroupSearchWindow();" style="cursor:pointer">#application.util.string.actionLinkFormat("#addGroupLabel#")#</a>
	 </cfif>
</cfif>


<cfif Form.Discount_Rebates_Item_Level eq 1 OR url.EZTemplate eq 1>

	<!---77408 Product Group sequencing START--->
<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>

		<cfif restrictLowerLevelBasedonLevel1 eq 0>
			<cfset addProductAtLevel = 0 /> <!------ Default, determine by itself ----->
			<cfset addProductLabel = "add products" />
		</cfif>

	<cfloop from="2" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		<cfif restrictLowerLevelBasedonLevel1 and ListFindNoCase(availableLowerLevels, levels)>
			<cfset addProductLabel = "add #LCase(arPricingLevel[levels])# products" />
			<cfset addProductAtLevel = levels /><cfbreak>
		</cfif>
	</cfloop>

	<cfif addProductAtLevel EQ 0>
			<cfset variables.enabled = 1 />
			<!--- IF ALL LEVELS ARE GROUPS WE WANT enable 0 --->
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				<cfif not(len(trim(form.GroupLevel_1)) and form.GroupLevel_1 neq 9)>
						<cfset variables.enabled = 0 />
				</cfif>
			</cfloop>
	</cfif>

		<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
			#application.util.string.actionLinkFormat("#addProductLabel#")#
		<cfelse>
			<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
				<a onClick="javascript: return showProductSearchWindow(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			<cfelse>
				<a onClick="javascript: return showProductSearchWindow_old(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			</cfif>
		</cfif>


<cfelse>

	<!------ add products ----->
	<cfif restrictLowerLevelBasedonLevel1 eq 0>
		<cfset addProductAtLevel = 0 /> <!------ Default, determine by itself ----->
		<cfset addProductLabel = "add products" />
		<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
			#application.util.string.actionLinkFormat("#addProductLabel#")#
		<cfelse>
			<cfset variables.enabled = 1 />
			<cfif len(trim(form.GroupLevel_1)) and form.GroupLevel_1 neq 9 and len(trim(form.GroupLevel_2)) and form.GroupLevel_2 neq 9 and len(trim(form.GroupLevel_3)) and form.GroupLevel_3 neq 9>
				<cfset variables.enabled = 0 />
			</cfif>
			<cfif variables.enabled eq 0><!--- Disabled link --->
				#application.util.string.actionLinkFormat("#addProductLabel#")#
			<cfelseif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
				<a onClick="javascript: return showProductSearchWindow(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			<cfelse>
				<a onClick="javascript: return showProductSearchWindow_old(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			</cfif>
		</cfif>
	</cfif>
	<!------ Level 2 ----->
	<cfif restrictLowerLevelBasedonLevel1 and ListFindNoCase(availableLowerLevels, "2")>
		<cfset addProductLabel = "add #LCase(arPricingLevel[2])# products" />
		<cfset addProductAtLevel = 2 /> <!------ At level 2 ----->
		<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
			#application.util.string.actionLinkFormat("#addProductLabel#")#
		<cfelse>
			<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
				<a onClick="javascript: return showProductSearchWindow(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			<cfelse>
				<a onClick="javascript: return showProductSearchWindow_old(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			</cfif>
		</cfif>
	</cfif>
	<!------ Level 3 ----->
	<cfif restrictLowerLevelBasedonLevel1 and ListFindNoCase(availableLowerLevels, "3")>
		<cfset addProductLabel = "add #LCase(arPricingLevel[3])# products" />
		<cfset addProductAtLevel = 3 /> <!------ At level 3 ----->
		<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
			#application.util.string.actionLinkFormat("#addProductLabel#")#
		<cfelse>
			<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
				<a onClick="javascript: return showProductSearchWindow(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			<cfelse>
				<a onClick="javascript: return showProductSearchWindow_old(#addProductAtLevel#);" style="cursor:pointer">#application.util.string.actionLinkFormat("#addProductLabel#")#</a>
			</cfif>
		</cfif>
	</cfif>

</cfif>	<!---77408 Product Group sequencing END--->

</cfif>


<cfif ProductGroupManager.allowSelectAllProducts(2, desRebateData.programId)>
  <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	#application.util.string.actionLinkFormat("add all products")#
  <cfelse>
	<a onClick="javascript: addGroupsLevelProducts(1, '#businessSegmentID#'); return false;" style="cursor:pointer">#application.util.string.actionLinkFormat("add all products")#</a>
  </cfif>
</cfif>


<!--- This value gets set in the file Claim_Mech_Info but needs to be on this page to prevent javascript errors in case they save before selecting a component. --->
	<input type="hidden" name="Auto_Pay_Status" value="">
	<input type="hidden" name="Vendor_Selection" value="true">
	</td>
</tr>
<!--- End: Add groups/products --->
<!---TSF - Label 11426: Move Treatment Code and Basis Code onto new row--->
<cfif Display_Basis_Treatment_Code>
<tr valign="top">
	<td COLSPAN="#colsAtComponentSection#">
	<table border="0" cellpadding="2" cellspacing="0">
		<tr BGCOLOR="eeeeee">
			<td>	Treatment Code</td>
			<td>	Basis Code</td>
		</tr>
		<tr>
		<td>
			<select name="Treatment_Code" style="width:140px" onchange="loadBasisCodes(this.value);">
				<option value="0">Select Treatment Code...</option>
			<cfloop query="qGetTreatmentCodes">
				<option value="#Treatment_Code_Master_ID#">#Treatment_Code_Desc#</option>
			</cfloop>
			</select>
		</td>
		<td>
			<select name="Basis_Code" style="width:140px">
				<option value="0">Select Basis Code...</option>
			</select>
		</td>
		</tr>
	</table>
	</td>
</tr>
</cfif>
<tr>
	<td colspan="#colsAtComponentSection#" >&nbsp;</td>
</tr>
<cfif not bAutoAddComponent AND url.EZTemplate EQ 0><!--- D31949:Price Protection Component not Appearing --->
<tr>
	<td COLSPAN="#colsAtComponentSection#" STYLE="border-bottom:solid 1px blue;padding-bottom:5px;"><b>Step 2: &nbsp;&nbsp;&nbsp;Add Component Information</b></td>
	<!---- COMPONENT DETAILS SECTION START--->
	<td  id"componentBind" style="width:275px;"colspan="#multiassignmentCols#" rowspan="100%" valign="top">
	<cfif (bAutoAddComponent ) OR (url.EZTemplate)><!--- D31949:Price Protection Component not Appearing --->
		<input type="hidden" name="PaymentCycle" value="#GetSettings.PayCycleDefaultOption#">
	<cfelse><!--- D50074 :: Viewing and Editing prior program versions  --->
		<cfdiv bind="url:component_information.cfm?Component_Name_ID={compNameId}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=2&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&ClaimMechanics=#CSLGetContractInfo.ClaimMechanics#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&EligibleRecordCount=#GetPaymentTypesforTemplate.Recordcount#&Generic_type=#CSLGetContractInfo.Generic_Type#&programId=#FORM.Contract_Main_ID#&Business_Segment_ID=#businessSegmentID#" ID="compInfo"/>
	</cfif>
	</td>
	<!---- COMPONENT DETAILS SECTION END--->
</tr>
<tr BGCOLOR="eeeeee">
	<td valign="Middle" style="width:275px;" align="left">Component Name</td>
	<td valign="Middle" align="left">Default Rate</td>
	<td valign="Middle" align="left">UOM</td>
	<td valign="Middle" align="left">Paid To</td>
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<td valign="Middle" align="left">Payment Cycle</td>
</cfif>
</tr>
<tr BGCOLOR="FFFFFF">
	<td valign="top">
		<!------ external id style="width:220px"EZBUTTON_ON EQ 1 AND EButton_Enter_Beyond_Max_Rates EQ 0 <cfif EzButton_Disable EQ 1>disabled</cfif> ----->
		<select name="compNameId"
			onchange="disableRateBox(this);<cfif Display_Basis_Treatment_Code>loadDefaultBasisTreatmentCodeForComponentName(this.value);</cfif>enableDisableIncludeComponentLink(false);"
			>
			<option value="0">Select #Application.RebateLabel# Component...</option>
			<cfloop query="qGetActiveComps">
				<option value="#Program_Rebates_Component_Name_ID#" is_usda_comp="#qGetActiveComps.IS_USDA_NOI_COMP#" rebate_type="#qGetActiveComps.rebate_type#" <cfif qGetActiveComps.recordcount EQ 1>selected</cfif>>#Program_Rebates_Component_Name#<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(External_ID) GT 0> (#External_ID#)</cfif></cfif><cfif len(trim(Allowance_Code_Number))> - (#Allowance_Code_Number#)</cfif></option>
			</cfloop>
		</select>
		<cfloop query="qGetActiveComps">
			<input type="hidden" name="Rebate_GL_Account_ID_#Program_Rebates_Component_Name_ID#" value="#GL_Account_ID#">
		</cfloop>
	</td>
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
	<td valign="top">
		<input name="rate" type="text" size="10" ONKEYUP="clenseText(this,'#TextAllowedInTextBox#')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" style="font-size:10" value="0.00"
		<cfif EzButton_Disable EQ 1 AND GetSettings.Discount_Rebate_Max_Rate_On EQ 0>
			DISABLED
		<cfelseif  EzButton_Disable EQ 1 AND GetSettings.Discount_Rebate_Max_Rate_On EQ 1>
		<cfelse>
		</cfif>
		 />
	</td>
	<!--- Dev Note: Drachala; D27506 : EZ Button, max rate - allow user to enter default rate and mass apply rate END--->
	<td valign="top">
		<cfset disabled = 0>
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
			disabled				=   "#disabled#"
		>
	</td>

<input type="hidden" name="currentTxtPercentage" value="#FORM.currentTxtPercentage#">
	<td valign="top" nowrap="nowrap">
		<!--- "Paid to" radio buttons --->
		<cfdiv bind="url:component_paid_to.cfm?Component_Name_ID={compNameId}&Complen=#ArrayLen(desRebateData.aComp)#&ModifyDeletedPrograms=#ModifyDeletedPrograms#0&ContractMainID=#FORM.Contract_Main_ID#&Discount_Type_ID=2&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#" bindOnLoad="true" ID="paidToInfo" />
	</td>
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<td valign="top">
	<cfparam name="FORM.PaymentCycle" 	default="">
	<cf_payment_cycle_selection
		Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
		Program_ID = "#FORM.Contract_Main_ID#"
		discount_Type_ID = "2"
		Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
		>
	</td>
<cfelse>
	<input type="hidden" name="PaymentCycle" value="">
</cfif>
</tr>
<tr BGCOLOR="eeeeee">
<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1')>
	<td>% of List Price</td>
	<td>From Price List</td>
</cfif>
<cfif Display_Basis_Treatment_Code EQ 0>
<cfelse>
	<td valign="Middle">Rate</td>
	<td valign="Middle">Buy</td>
	<td valign="Middle">Get Free</td>
	<td title="Effective Margin %">Effective Margin %</td>
</cfif>
</tr>
<tr>
<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1')>
<!--- Do not add the minus sign below as when we enter -20% or any other negative number, a negative value shows up, which is fine for Fixed price (when % of list price is used) but not rebate. --->
	<td valign="top"><input name="txtPercentage" type="text" value="" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,1)"></td>
	<td valign="top"><input name="txtPriceListID " type="text" value="#GetSettings.Price_list_ID#" size="10" disabled></td>
<cfelse>
	<input type="hidden" name="txtPercentage" value="0">
</cfif>
<cfif Display_Basis_Treatment_Code EQ 1>
	<td valign="top">
		<input name="apply_rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" <cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>/>
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_rate">
		 </cfif>
	</td>
	<td valign="top">
	<!------ Buy ----->
		<input name="apply_basis_code_quantity" type="text" size="5" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" <cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>/>
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_basis_code_quantity">
		 </cfif>
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
			disabled				=	"#disabled#">
		<cfif Disabled eq 1>
			<input type="hidden" name="apply_basis_code_quantity_uom" value="0">
		</cfif>
	</td>
	<td valign="top">
	<!------ Get Free ----->
		<input name="apply_basis_code_free_goods" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)" <cfif Revision_Products_Rates_Changes eq 0>STYLE="background-color: cccccc" DISABLED</cfif>/>
		<!--- If the program is a revision and revision settings has retrictions for this program and product rate changes cannot be made --->
		 <cfif Revision_Products_Rates_Changes eq 0>
		 <input type="hidden" name="apply_basis_code_free_goods">
		 </cfif>&nbsp;
	</td>
	<td valign="top"><!------ Effective Margin % ----->
		<input name="apply_effective_margin_Percent" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,2)"/>&nbsp;
	</td>
</cfif>
</tr>

<tr>
	<cfset ColspanLen = colsAtComponentSection - 1>
	<td colspan="#ColspanLen#" valign="top">
	<cfif appSettings.getDisableAddingComponentsOnRevision() AND bIsContractARevision>
		<B>Step 3:&nbsp;</B>
		<span style="cursor:pointer;" title='adding new components are not allowed on revisions'>#application.util.string.actionLinkFormat("include this #Application.RebateLabel# component")#</span>
		<!--- Tim Ford - Label 27828: Add materials to active Foodservice off invoices
		Added this empty JS function in the if statement to prevent the rebates page from blowing up when the program is a revision and
		the Don't allow new components to be added on revision: application setting is on
		--->
		<script language="javascript">
			function enableDisableIncludeComponentLink(bEnable)	{
				var someEmptyStrin = "";
			}
		</script>
	<cfelse>
		<B>Step 3:&nbsp;</B>
		<span id="spIncludeComponentLinkEnabled">
			<a onclick="javascript:submitForm('comp','0','','#url.EZTemplate#','#EzButton_Disable#','#GetSettings.EZButton_Enter_Beyond_Max_Rates#','#GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates#');" STYLE="cursor: pointer;" >
			#application.util.string.actionLinkFormat("include this #Application.RebateLabel# component")#
			</a>
		</span>
		<span id="spIncludeComponentLinkDisabled" style="display:none;color:gray;cursor:pointer;">
			#application.util.string.actionLinkFormat("include this #Application.RebateLabel# component")#
		</span>
		<!---
		D20867: CAG DEV 14770 - FORMSCOPE.VENDOR_MASTER_ID undefined in ARGUMENTS
		enableDisableIncludeComponentLink (false) will disable the link "include this rebate component"
		We will disable the link "include this rebate component" when rebate component drop down selection is changed.
		The link will get re-enabled at the end of the page claim_mech_info.cfm
		--->
		<input type="hidden" name="bEnableDisableIncludeComponentLink" value="1" />
		<script language="javascript">
			function enableDisableIncludeComponentLink(bEnable)	{
						var spEnabled = document.getElementById('spIncludeComponentLinkEnabled');
						var spDisabled = document.getElementById('spIncludeComponentLinkDisabled');

				if(bEnable){
					spEnabled.style.display = "";
					spDisabled.style.display = "none";
				}
				else	{
					spEnabled.style.display = "none";
					spDisabled.style.display = "";
				}
			}
		</script>
	</cfif>
	</td>
</tr>
</cfif>
</table>
</FIELDSET>
</cfoutput>

<Cfset RequireGL = 0>
	<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
		<cfset RequireGL = 1>
	</cfif>

<input type="hidden" name="RequireGL" value="#RequireGL#">
		<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF START --->
		<cfset ParentRebateComponents = 0>
		<cfif len(GetContractInfo.Revision_of_Contract_Main_ID)>
		<cfset useLakebaseForgetParentRebateComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForgetParentRebateComponents>
	<cftry>
		<cfset getParentRebateComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component", {
				"program_id" = "eq.#CSLGetContractInfo.Revision_of_Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetParentRebateComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetParentRebateComponents>
<CFQUERY NAME="getParentRebateComponents" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component
			where program_id = #CSLGetContractInfo.Revision_of_Contract_Main_ID#
			AND deleted = 0
		</CFQUERY>
</cfif>
		<cfset ParentRebateComponents = valuelist(getParentRebateComponents.Program_Rebates_Component_Name_ID)>
		</cfif>
		<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF END --->

<cfinclude template="_rebates_components.cfm" />


<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">
<cfparam name="getSettings.Min_Rebate_Case" default="0">
<cfparam name="getSettings.Max_Rebate_Case" default="0">
<cfparam name="getSettings.Min_Rebate_Pound" default="0">
<cfparam name="getSettings.Max_Rebate_Pound" default="0">
<cfparam name="ThereisMinorMax" default="0">

<input type="hidden" name="Price_Protection_on" value="#form.Price_Protection_on#">
<INPUT type="hidden" name="Product_Level_1" value="#Form.Product_Level_1#">
<input type="hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />
<input type="hidden" name="action" value="prod" id="action"/>
<input type="hidden" name="applyVol" value="" />
<input type="hidden" name="sessionFile" value="#sessionFile#" />
<input type="hidden" name="comps" value="" />
<input type="hidden" name="compLen" value="#ArrayLen(desRebateData.aComp)#" />
<input type="hidden" name="prodLen" value="#ArrayLen(desRebateData.aProd)#" />
<input type="hidden" name="compUUID" value="#compUUID#" />
<input type="hidden" name="init" value="#init#" />
<INPUT type="hidden" name="Sort_By" value="#URL.Sort_By#">
<INPUT type="hidden" name="Program_ID" value="#URL.CID#">
<INPUT type="hidden" name="Product_List" value="#Form.Product_List#">
<INPUT type="hidden" name="ExistingProductList" value="#Product_List#">
<INPUT type="hidden" name="DTPS_On" value="1">
<INPUT type="hidden" name="DTPS_Program_ID" value="#FORM.Contract_Main_ID#">
<INPUT type="hidden" name="sortBy" value="#sortBy#">
<INPUT type="hidden" name="sortOrder" value="#sortOrder#">
<INPUT type="hidden" name="Sub_Product_List" id="Sub_Product_List" size="250" value="#Form.Sub_Product_List#">
<INPUT type="hidden" name="pageNum" value="#form.pageNum#" id="pageNum">
<INPUT type="hidden" name="curPageNum" value="#form.pageNum#" id="curPageNum">
<INPUT type="hidden" name="locate" value="#form.locate#" id="locate">
<!---Modification: Group Deals--->
<input type="hidden" name="Discount_Rebates_Item_Level" value="#Form.Discount_Rebates_Item_Level#" />
<input type="hidden" name="Discount_Rebates_Group_Level" value="#Form.Discount_Rebates_Group_Level#" />

<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
  <input type="hidden" name="Level_#levels#" value="#form["Level_#levels#"]#" />
  <!---clean up the group levels--->
  <cfif trim(form["Level_#levels#"]) eq "">
  	<cfset 'form.GroupLevel_#levels#' = "" />
  </cfif>
  <input type="hidden" name="GroupLevel_#levels#" value="#Form["GroupLevel_#levels#"]#" />
</cfloop>
<!---77408 Product Group sequencing END--->

<input type="hidden" name="bFromMargin" value="#Form.bFromMargin#" />
<input type="hidden" name="ProductsGroupLevels" value="#form.ProductsGroupLevels#">
<!---Dev Notes: 21553/Anand Rao/04-Mar-10 HZ - min/max rates for EZ button--->
<cfif (GetSettings.EZButton_On EQ 1 AND URL.EZTemplate EQ 0 AND (GetSettings.Discount_Rebate_Max_Rate_On EQ 1))>
  <input type="hidden" name="tmpltCompLen" value="#ArrayLen(templateRebateData.aComp)#" />
  <input type="hidden" name="tmpltProdLen" value="#ArrayLen(templateRebateData.aProd)#" />
</cfif>
<input type="hidden" name="Allow_Multi_Levels" value="#form.Allow_Multi_Levels#" />
<INPUT type="hidden" name="navigate" value="#FORM.navigate#">
<INPUT type="hidden" name="stopnavigate" value="0">
<INPUT type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#">
<cfif restrictLowerLevelBasedonLevel1>
	<input type="hidden" name="AllowProductGroupList" value="#Form.Level_1#" />
	<input type="hidden" name="AllowProductGroupLevelId" value="#Form.GroupLevel_1#" />
	<input type="hidden" name="IsRestrictLowerLevelBasedonLevel1On" value="#restrictLowerLevelBasedonLevel1#" />
</cfif>
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
<input type="hidden" name="donotallowaddproductsDE" value="#form.donotallowaddproductsDE#">
<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
<input type="hidden" name="numberOfLevels" value="#request.AccessStructure.numberOfProductGroupLevels#"><!---77408 Product Group sequencing --->
</form>
</cfoutput>
