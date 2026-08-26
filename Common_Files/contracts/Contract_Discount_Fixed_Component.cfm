<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="URL.bFromMargin" DEFAULT="0" type="boolean">
<CFPARAM NAME="form.bFromMargin" DEFAULT="#URL.bFromMargin#">
<cfparam name="form.Fixed_Component_Paid_To" default="0"> <!--- Dev Note: KAL : D13043: Claim Mechanism on Fixed Price Page  --->
<cfparam name="form.Treatment_Code" default="0">
<cfparam name="form.Basis_Code" default="0">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="bIsIndirectBid" default="0">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="variables.FOB_CS_Price" default="0">
<cfparam name="variables.FOB_LB_Price" default="0">
<cfparam name="form.paidToList" default="" />
<cfparam name="form.GL_Account_ID" default="">
<cfparam name="form.Vendor_Master_ID" default="0">
<cfparam name="form.VendorSelection" default="0">
<cfparam name="form.PaymentCycle" default="">
<cfparam name="form.Program_Fixed_Component_Name_ID_Selection_Validated" default="0">
<cfparam name="form.Payee_Selection" default="">
<cfparam name="form.priceListID" default="">
<cfparam name="form.priceBracketUpdate" default="0">
<cfparam name="form.Claim_Mechanics" default="0">
<!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START--->
<cfparam name="id_i" default = "0">
<!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
<!--- D51533 :: Added below param values as this variables are declared only if certain appsettings are on --->
<cfparam name="variables.FOB_CS_Price" default="0">
<cfparam name="variables.FOB_LB_Price" default="0">
<cfparam name="variables.DEL_CS_Price" default="0">
<cfparam name="variables.DEl_LB_Price" default="0">
<cfparam name="Item_Margin_Targets_default" default="">
<cfparam name="FORM.currentTxtPercentage"  default="">
<cfparam name="form.IsSecondComponent" default="0">
<cfparam name="IPcomp_id" default="0">

<cfset bAutoAddComponent = 0 />
<cfset disableRateUOMText = ''>

<cfif isDefined("form.txtPercentage") AND FORM.txtPercentage NEQ "">
	<cfset FORM.currentTxtPercentage = form.txtPercentage />
</cfif>

<CFSET thisPage=GetFileFromPath(GetCurrentTemplatePath())>
<CFSET fullUrl="">
<cfset displayMinRateWarn = "none" />
<cfset displayMaxRateWarn = "none" />
<cfloop collection=#URL# item="thisURLItem">
	<CFIF thisURLItem NEQ "Sort_By">
		<CFSET fullUrl=ListAppend(fullUrl, "#thisURLItem#=#StructFind(URL, thisURLItem)#","&")>
	</CFIF>
</cfloop>
<CFIF Len(fullUrl) GT 0>
	<CFSET fullUrl="#thisPage#?#fullUrl#&">
<CFELSE>
	<CFSET fullUrl="#thisPage#?">
</CFIF>

<cfparam name="URL.Sort_By" default="Item">
<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />
<cfinclude template="Contract_Discount_Fixed_Component_Functions.cfm" />

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>
</cfif>
	<cfset program_Span = Datediff('d',GetContractInfo.Contract_Start_Date, GetContractInfo.Contract_End_Date) + 1>
  <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id,source,source_required,source_type,source_type_required,date_source_received,date_source_received_required,ezbutton_on,discount_rebate_max_rate_on,ezbutton_enter_beyond_max_rates,ideal_price,ratetypedefault"
			}), "first_parent_id,source,source_required,source_type,source_type_required,date_source_received,date_source_received_required,ezbutton_on,discount_rebate_max_rate_on,ezbutton_enter_beyond_max_rates,ideal_price,ratetypedefault"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT
			First_parent_ID,
			Source,
			Source_Required,
			Source_Type,
			Source_Type_Required,
			Date_Source_Received,
			Date_Source_Received_Required,
			EZbutton_On,
			Discount_Rebate_Max_Rate_On,
			EzButton_Enter_Beyond_Max_Rates,
			Ideal_Price,
			RateTypeDefault
    FROM Program_Control_Panel_Options
    WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
  </cfquery>
</cfif>

  <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
  <cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(cryp.value) />

<cfif GetTemplateInfo.Ideal_Price>
	<cfset useLakebaseForgetFixedComponentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForgetFixedComponentID>
	<cftry>
		<cfset getFixedComponentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component", {
				"program_id" = "eq.#cryp.value#",
				"deleted" = "eq.0",
				"select" = "program_fixed_component_name_id"
			}), "program_fixed_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFixedComponentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFixedComponentID>
<CFQUERY NAME="getFixedComponentID" datasource="#application.datasource#">
		SELECT Program_Fixed_Component_Name_ID
		FROM Program_Fixed_Component
		where program_id =  '#cryp.value#'
		AND deleted = 0
	</CFQUERY>
</cfif>
	<cfif getFixedComponentID.recordCount>
		<cfset IPcomp_id = getFixedComponentID.Program_Fixed_Component_Name_ID>
	</cfif>
</cfif>

		<!--- D50074 :: Viewing and Editing prior program versions START --->
		<cfinclude template="/get_access_profile.cfm">
		<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<!--- D50074 :: Viewing and Editing prior program versions END --->
		<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>
</CFIF>
		<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF START --->
		<cfset ParentFixedComponents = 0>
		<cfif len(GetContractInfo.Revision_of_Contract_Main_ID)>
		<cfset useLakebaseForgetParentFixedComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForgetParentFixedComponents>
	<cftry>
		<cfset getParentFixedComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component", {
				"program_id" = "eq.#GetContractInfo.Revision_of_Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "program_fixed_component_name_id"
			}), "program_fixed_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetParentFixedComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetParentFixedComponents>
<CFQUERY NAME="getParentFixedComponents" datasource="#application.datasource#">
			SELECT Program_Fixed_Component_Name_ID
			FROM Program_Fixed_Component
			where program_id = #GetContractInfo.Revision_of_Contract_Main_ID#
			AND deleted = 0
		</CFQUERY>
</cfif>
		<cfset ParentFixedComponents = valuelist(getParentFixedComponents.Program_Fixed_Component_Name_ID)>
		</cfif>
		<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF END --->
<CFSET PAGE_TITLE= "Product Fixed Component Creation">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY>
<SCRIPT SRC="/script/javascript/string_functions.js?v=08182020"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<cfif url.EZTemplate EQ 1>
<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "fixed_prices">
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfparam name="URL.Sort_By" 	default="Item">
<cfparam name="EZ_Fixed_Comp_Ids" default="">

<!---
	Dev Notes: 22308/Anand Rao/04-Feb-10
	CAG - multi discount type template
--->
<cfset sDiscountType = "FIXED" />
<cfset Contract_Main_ID = cryp.value>
<cfinclude template="inc_Discount_Type_Checker.cfm" />

<!--- reload search list Fx
<cfif isdefined("session.qGetItems")>
	<cfset StructDelete(session,"qGetItems",false) />
</cfif>
	<cfset application.oController.getObject("mvc.models.Item.ItemSearchService") />
	<cfset application.oItemSearchService.getItems(CSL_Contract_Main_ID,1) />
end reload search items--->
<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
<CFSWITCH expression="#URL.sort_by#">
	<CFCASE value="Type Code">
		<CFSET sql_Sort_By="dbo.Type_Code_Desc.Type_Code_Desc">
	</CFCASE>
	<CFCASE value="Brand">
		<CFSET sql_Sort_By="dbo.Brand.Brand_Name">
	</CFCASE>
	<CFCASE value="Item">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
	</CFCASE>
	<CFCASE value="UPC">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.UPC">
	</CFCASE>
	<CFCASE value="Description">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Description">
	</CFCASE>
</CFSWITCH>

<cfset fixedCompObj = CreateObject("component","components.programs.fixed.fixedComponent") />
<cfset compBusRule = createObject("component","components.programs.fixed.FixedComponentBusinessRule")>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<!--- <cfset profBusRule = createObject("component","components.programs.fixed.FixedComponentProfile")> --->

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<cfsavecontent variable="vContractStatusLegend">
	<!--- Width for the below div used to be 180px, but needed to be changed to 130px due to the following issue on IE 11.
	- Put the cursor over the scissor for any product (which deletes the product)
	- The cursor should turn into a hand and the scissor should be clickable.
	The above feature did not work on IE 11 for fixed price products, with the width of the div being 180px.
	--->
		<div id="Layer2" style="position:absolute; width: 130px; height: 400px; z-index: 5; left: 10px; top: 0px;">
  			<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
		</div>
	</cfsavecontent>
	<cfif not form.bFromMargin>
		<cfoutput>#vContractStatusLegend#</cfoutput>
	</cfif>
<cfelse>
	<cfsavecontent variable="vContractStatusLegend">
		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</cfsavecontent>
	<cfif not form.bFromMargin>
		<cfoutput>#vContractStatusLegend#</cfoutput>
	</cfif>
</cfif>

<CF_CRYP type="de" string="#CID#" key="#request.key#">

<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(cryp.value)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>

<cfset DiscountType = 1>
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
		<cfset ProductItemList = ValueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
	<cfelse>
		<cfset ProductItemList = "NULL">
	</cfif>
<cfelse>
<!--- to avoid an error --->
	<cfset ProductItemList = queryNew("")>
	<cfset ProductItemList = "NULL">
</cfif>

<cfif url.EZTemplate EQ 0>
<BLOCKQUOTE><BLOCKQUOTE>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
	<cfset bIsIndirectBid = bidRequestProdMan.checkIndirectBid(form.contract_main_id) />
</cfif>

<!--- If "Use Fixed Price Type" app setting is ON, get the price bracket and whether the price bracket is overriddeb or not from the db. --->
<cfif appSettings.getUseFixedPriceType() EQ 1>
	<cfif form.priceListID eq "">
		<cfset form.priceListID = CSLGetContractInfo.Price_List_ID>
		<cfset priceListBracketForProgram = programManager.getPriceListBracketForProgram(form.contract_main_id)>
		<cfset form.priceBracketUpdate = priceListBracketForProgram.PriceBracket_Update>

	<cfelse>
	<!--- If "Use Fixed Price Type" app setting is ON and the page got refreshed be the user clicking save on the "edit component" popup. In this case, get the
	      price bracket from the pop-up page.
	--->
		<cfset form.priceBracketUpdate = programManager.getPriceListBracketOverridden(form.contract_main_id,form.priceListID)>
	</cfif>
</cfif>

<cfset Display_Basis_Treatment_Code = 0 />
<cfif GetSettings.Include_Treatment_Basis_Code>
	<cfset Display_Basis_Treatment_Code = 1 />
</cfif>

<cfset multiassignmentCols = 2 />
<cfif Display_Basis_Treatment_Code EQ 1>
	<cfset multiassignmentCols = 4 />
</cfif>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
	<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
	<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
		<cfset donotallowaddproductsDE = 1>
	</CFIF>
</cfif>

<!--- Get the competitor list --->
<cfset CompetitorList = programManager.getCompetitorList()>

<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
	<CFQUERY NAME="checkifdistributorsadded" datasource="#application.datasource#">
		select count(*) as distributorsadded
		from contract_distributors
		where contract_main_id = '#FORM.Contract_Main_ID#'
		and deleted = 0
	</CFQUERY>
</cfif>

<CFSET AllowNullInComponent = appSettings.getProgram_Allow_Null_Rate()>
<CFSET HideProductList = 1>
<cfoutput>
	<script language="JavaScript">
		//D45776 :: Show additional fields on fixed price page and max component
			<cfset maxComponentPossible = appSettings.getRebateMaxComponents()>
		<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 OR getsettings.Discount_Fixed_Prices_Freight EQ 1>
			<cfset maxComponentPossible = 20>
		</cfif>
		<cfif appSettings.getRebateMaxComponents() LT maxComponentPossible >
			<cfset maxComponentPossible = #appSettings.getRebateMaxComponents()#>
		</cfif>
		var maxComponentPossible = #maxComponentPossible#;
		//D45776 :: Show additional fields on fixed price page and max component
		<!--- If template setting "Single_Component_Per_Discount_Type" is ON, only one component can be added --->
		<cfif getsettings.Single_Component_Per_Discount_Type EQ 1>
			var maxComponentPossible = 1;
		</cfif>
	</script>
</cfoutput>
<CFSET helpfilenumber=7>
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; <cfif not form.bFromMargin>left: 60px;</cfif> top: 0px;"> </cfif>
<cfif url.EZTemplate EQ 0>
<cfset width = '1080'>
<cfinclude template="minimal_contract_info.cfm">
</cfif>

<!--- D27179:Remove step 2 of fixed and rebate if only one component and one selection
1. If template have Single_Component_Per_Discount_Type = 1
2. Template has a default payment cycle
3. GL Account is OFF
4. Template has components
Get first component that has a claim mechanics which is not auto pay
--->
<cfset iAutoAddComponentNameId = 0 />
<cfset iAutoAddClaimMechOption = 0 />
<cfset iAutoAddDefaultComponentPaidTo = 0 />
<cfif GetSettings.Single_Component_Per_Discount_Type
	and GetSettings.PayCycleDefaultOption neq 0
	and not (appSettings.getGL_Account_On() AND appSettings.getGL_Account_Required_for_Comp())> <!--- Rules 1, 2, 3 --->
	<!--- Get top 1 component --->
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 1, 1) />
	<cfset arComponentAllowList = ArrayNew(1)>
	<cfset arComponentAllowList[1] = ValueList(qComponents.Component_ID) />
	<cfscript>
		qGetActiveComps = fixedCompObj.getProgramFixedComponentNames(arAllowList=arComponentAllowList);
	</cfscript>

	<cfif qGetActiveComps.recordCount gt 0><!--- Rule 4 --->
		<cfset iAutoAddComponentNameId = qGetActiveComps.Program_Fixed_Component_Name_ID />
		<cfset qryAutoAddDefaultComponentPaidTo = templateManager.getDiscountComponentDefaultPaidTo(GetContractInfo.ProgramType_ID,1,iAutoAddComponentNameId) />
		<cfset iAutoAddDefaultComponentPaidTo = qryAutoAddDefaultComponentPaidTo.Default_Paid_To_CF_Pages>

		<!--- 2. Check if the component has a claim mechanics --->
		<cfset CompDetails = CreateObject("component","components.programcomponents.programcomponents").GetComponentDetails(iAutoAddComponentNameId, 1)>
		<cfset qGetPaymentTypesforTemplate = CreateObject("component", "components.programs.payment_type.paymenttype").GetPaymentTypesforTemplate(
			Template_ID = GetSettings.ProgramControl_Panel_Options_ID,
			Discount_Type_ID = 1,
			Component_Name_ID = iAutoAddComponentNameId,
			Allow_Off_Invoice = CompDetails.Off_Invoice_On,
			Allow_Auto_Payment = 0 <!--- Allow_Auto_Payment is passed as 0 purposely, if the only claim mech available is auto pay, we want user to manually select as payee selection may be involved --->
			) >
		<!--- check if default claim mechanics is not auto pay which requires payee selection --->
		<cfif qGetPaymentTypesforTemplate.recordCount>
			<cfset bAutoAddComponent = 1 />
			<cfset iAutoAddClaimMechOption = qGetPaymentTypesforTemplate.Payment_Type_ID />
		</cfif>
	</cfif>

</cfif>

<!--- <cfsilent> --->
	<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
		SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity, contract_main.Contract_Quantity_UOM_IDX
		FROM         dbo.Contract_Main
		INNER JOIN dbo.Units_of_Measure
		ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
		WHERE dbo.Contract_Main.Contract_Main_ID = '#FORM.Contract_Main_ID#'
	</CFQUERY>

<!---<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>--->

<cfset EzButton_Disable = 0>

<cfset uom_id_exclusion_list = "">
<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
	<cfset uom_id_exclusion_list = 1>
</cfif>

<cfif EzButton_Disable EQ 1>
<cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />
<cfset GetEZButtonDefaultComp = EZProgramManager.getFixedEZComponents(getsettings.EZ_Contract_Id)>
<cfif GetEZButtonDefaultComp.recordcount GT 0>
<cfset EZ_Fixed_Comp_Ids = ValueList(GetEZButtonDefaultComp.Program_Fixed_Component_Name_Id)>
</cfif>
</cfif>

<cfif NOT isDefined("form.FixedComponentList")>
	<CFQUERY NAME="getAllFixedComponents" datasource="#application.datasource#">
	SELECT 	ISNULL(firstComp.Program_Fixed_Component_Name, Program_Fixed_Component_Name.Program_Fixed_Component_Name) FirstCompName,
			Program_Fixed_Component_Name.Include_Second_Component,
			Program_Fixed_Component.Program_Fixed_Component_Name_Id, Program_Fixed_Component.Fixed_Component_Paid_to,
			isnull(Program_Fixed_Component.Treatment_Code_Master_ID, 0) as Treatment_Code_Master_ID,
			isnull(Program_Fixed_Component.Basis_Code_Master_ID, 0) as Basis_Code_Master_ID,
			Program_Fixed_Component.Claim_Mechanics,
			Program_Fixed_Component.GL_Account_ID,
			Program_Fixed_Component.Vendor_Master_ID,
			Program_Fixed_Component.Vendor_Selection,
			Program_Fixed_Component.Parent_Program_Fixed_Component_ID
			<cfif appSettings.getPaymentCycleAtDiscountType()>
				,Program_Payment_Cycle.Payment_Cycle_ID AS PaymentCycle
			</cfif>
			,isnull(nullif(Program_Fixed_Component.Payee_Type,''),0) As Payee_Selection
			,Program_Fixed_Component_Name.Include_Second_Component
			,Program_Fixed_Component_Name.Second_Component_Name_ID
	FROM 	Program_Fixed_Component
	INNER JOIN Program_Fixed_Component_Name
	ON Program_Fixed_Component.Program_Fixed_Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
	LEFT JOIN Program_Fixed_Component_Name firstComp ON
	firstComp.Second_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_Id
	<cfif appSettings.getPaymentCycleAtDiscountType()>
	LEFT JOIN Program_Payment_Cycle
		ON Program_Payment_Cycle.Program_ID = Program_Fixed_Component.Program_ID
		AND Program_Payment_Cycle.Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID
		AND Program_Payment_Cycle.Discount_Type_ID = 1
		AND Program_Payment_Cycle.Deleted = 0
	</cfif>
	WHERE Program_Fixed_Component.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Contract_Main_ID#">
	AND Program_Fixed_Component.DELETED = 0
	<!--- Dev Note(79237) When a component has a second component, both components should be next to neach other, with the parent component displaying before the 2nd component.
	Columns "FirstCompName" and "Include_Second_Component" have been included for that purpose.
	--->
	ORDER BY Program_Fixed_Component.Program_Fixed_Component_ID <!--- Do not change "ORDER BY" logic --->
	</CFQUERY>

	<!--- Dev Note - (79237)  Find the 2nd Component (Child of the first component). IF there are multiple components with
	a second component, then there will be more than one second component.
	--->
	<cfset variables.SecondComponentList = "">
	<cfloop query="getAllFixedComponents">
		<cfif Include_Second_Component eq 1>
			<cfset variables.SecondComponentList = ListAppend(variables.SecondComponentList,Second_Component_Name_ID)>
		</cfif>
	</cfloop>
	<CFSET form.FixedComponentList = "" />
	<cfloop query="getAllFixedComponents">
		<cfset variables.IsSecondComponent= 0>
		<!--- Dev Note - (79237) Find out whether this is a 2nd Component (Child of the first component) --->
		<cfif ListFind(variables.SecondComponentList,Program_Fixed_Component_Name_Id) neq 0>
			<cfset variables.IsSecondComponent = 1>
		</cfif>

		<cfif Vendor_Master_ID EQ "">
			<cfset VendorMasterID = 0>
		<cfelse>
			<cfset VendorMasterID = Vendor_Master_ID>
		</cfif>
		<cfset currentComponentInfo = compileComponentInfo(Program_Fixed_Component_Name_Id, Fixed_Component_Paid_to, Treatment_Code_Master_ID, Basis_Code_Master_ID, Claim_Mechanics, GL_Account_ID, VendorMasterID, PaymentCycle, Vendor_Selection, Parent_Program_Fixed_Component_ID, Payee_Selection, variables.IsSecondComponent) />
		<CFSET form.FixedComponentList = ListAppend(form.FixedComponentList, currentComponentInfo, ",") />

	</cfloop>
</cfif>

<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfset useLakebaseForgetAllFixedComponentsAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component_profile")>
<cfif useLakebaseForgetAllFixedComponentsAccess>
	<cftry>
		<cfset getAllFixedComponentsAccess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component_profile", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"allow_user_to_view" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllFixedComponentsAccess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllFixedComponentsAccess>
<cfquery name="getAllFixedComponentsAccess" datasource="#application.datasource#">
			SELECT 	*
			FROM		Program_Fixed_Component_Profile
			WHERE	Deleted = 0
			AND 		Profiles_ID = #request.AccessStructure.Profiles_ID#
			AND 		Allow_User_To_View = 1
	</cfquery>
</cfif>
<!--- D45016 :: Restrict access at component level for all discount types END--->

<!---
Auto add component is ON,
No component selected so far,
Product exists
User is not deleting a component
--->
<cfif bAutoAddComponent
	and not ListLen(form.FixedComponentList)
	and isDefined("form.product_list") and ListLen(form.product_list)
	and	(not isDefined("form.DeletedComponentPosition") or Form.DeletedComponentPosition eq 0)>

	<cfset form.Program_Fixed_Component_Name_ID = iAutoAddComponentNameId />
	<cfset form.Program_Fixed_Component_Name_ID_Selection_Validated = 1 />
	<cfset form.Fixed_Component_Paid_To = iAutoAddDefaultComponentPaidTo />
	<cfset form.Claim_Mechanics = iAutoAddClaimMechOption />
	<cfset form.PaymentCycle = GetSettings.PayCycleDefaultOption />

</cfif>
<!---COMPONENT SAVE LOGIC START --->
<cfif isdefined("form.Program_Fixed_Component_Name_ID") AND form.Program_Fixed_Component_Name_ID NEQ '-1' AND form.Program_Fixed_Component_Name_ID_Selection_Validated EQ "1">
	<cfset currentComponentInfo = compileComponentInfo(form.Program_Fixed_Component_Name_ID, form.Fixed_Component_Paid_To, form.Treatment_Code, form.Basis_Code, form.Claim_Mechanics, form.GL_Account_ID, form.Vendor_Master_ID, form.PaymentCycle, form.VendorSelection, "", form.Payee_Selection, form.IsSecondComponent) />
	<CFSET form.FixedComponentList = ListAppend(form.FixedComponentList, currentComponentInfo)>

	<cfset componentLen = ListLen(form.FixedComponentList) />
	<!--- When the fixed price type is either deviated price (meets competition) or price extension or combination (blended), set the rate and UOM to null.
	      This information comes from the price list table.
	--->
	<cfset iFixedPriceType = Evaluate("Form.Fixed_Fixed_Price_Type_#form.Program_Fixed_Component_Name_ID#") />
	<cfset bIsFormulaComp = Evaluate("Form.FORMULA_PRICING_#form.Program_Fixed_Component_Name_ID#") />
	<cfif iFixedPriceType eq 1 or iFixedPriceType eq 2 or iFixedPriceType eq 3 or bIsFormulaComp eq 1>
		<!----<cfset form.rate = "" />
		<cfset form.uom = "" />---->
		<cfif bIsFormulaComp eq 1 >
			<cfset form.uom = "2" />
			<cfset form.User_Picked_UOM = "6">
			<cfset form.rate = "0" />
		</cfif>
	</cfif>
	<cfif isDefined("form.rate") AND isDefined("form.product_list") AND isDefined("form.uom")>
		<cfloop list="#form.product_list#" index="prodid">
			<cfset "form.fixed_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#_rate" = #form.rate#>
			<cfset "form.fixed_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#_uom" = #form.uom#>
			<cfset fixrule = compBusRule.getComponentRules(form.Program_Fixed_Component_Name_Id, 1).Program_Fixed_Component_Rule_ID />
			<cfset "form.fix_rule_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#" = fixrule />
		</cfloop>
	</cfif>

	<!--- Dev Note(79237) - When a 2nd Component (Child of the first component) exists fpr the component, the we need to add the 2nd(child) component and set the
	"paid to", Rate and UOM  of th 2nd Component, same as the  the first component. --->
	<cfset useLakebaseForgetSecondComponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component_name")>
<cfif useLakebaseForgetSecondComponent>
	<cftry>
		<cfset getSecondComponent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component_name", {
				"program_fixed_component_name_id" = "eq.#form.Program_Fixed_Component_Name_ID#",
				"select" = "include_second_component,second_component_name_id,second_component_payment_type_id,second_component_gl_account_id,second_component_payment_cycle_id"
			}), "include_second_component,second_component_name_id,second_component_payment_type_id,second_component_gl_account_id,second_component_payment_cycle_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSecondComponent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSecondComponent>
<cfquery name="getSecondComponent" datasource="#application.datasource#">
		SELECT	Include_Second_Component,Second_Component_Name_ID,Second_Component_Payment_Type_ID,Second_Component_GL_Account_ID,Second_Component_Payment_Cycle_ID
		FROM	Program_Fixed_Component_Name
		WHERE	Program_Fixed_Component_Name_ID = #form.Program_Fixed_Component_Name_ID#
	</cfquery>
</cfif>

	<cfif getSecondComponent.Include_Second_Component EQ 1 AND getSecondComponent.Second_Component_Name_ID GT 0>
		<cfset form.Program_Fixed_Component_Name_ID = getSecondComponent.Second_Component_Name_ID><!--- From the 2nd component dropdown --->
		<cfset form.Fixed_Component_Paid_To = form.Fixed_Component_Paid_To>  <!--- same as first component --->
		<cfset form.Claim_Mechanics = getSecondComponent.Second_Component_Payment_Type_ID> <!---From the 2nd component dropdown --->
		<cfset form.GL_Account_ID = getSecondComponent.Second_Component_GL_Account_ID> <!--- From the 2nd component dropdown --->
		<cfset form.PaymentCycle =  getSecondComponent.Second_Component_Payment_Cycle_ID> <!--- from the 2nd component dropdown --->
		<cfset form.VendorSelection = 0> <!--- currently, we cannot create a auto pay component as a second component --->
		<cfset form.Payee_Selection = 0> <!--- currently, we cannot create a auto pay component as a second component --->

		<cfset currentComponentInfo = compileComponentInfo(form.Program_Fixed_Component_Name_ID, form.Fixed_Component_Paid_To, form.Treatment_Code, form.Basis_Code, form.Claim_Mechanics, form.GL_Account_ID, form.Vendor_Master_ID, form.PaymentCycle, form.VendorSelection, "", form.Payee_Selection, form.IsSecondComponent) />
		<CFSET form.FixedComponentList = ListAppend(form.FixedComponentList, currentComponentInfo)>
	</cfif>

	<!--- Note: Below code for setting the rate and UOM is being repeated for the 2nd component (Below code already exists above). --->
	<cfset componentLen = ListLen(form.FixedComponentList) />
	<!--- When the fixed price type is either deviated price (meets competition) or price extension or combination (blended), set the rate and UOM to null.
	      This information comes from the price list table.
	--->
	<cfset iFixedPriceType = Evaluate("Form.Fixed_Fixed_Price_Type_#form.Program_Fixed_Component_Name_ID#") />
	<cfset bIsFormulaComp = Evaluate("Form.FORMULA_PRICING_#form.Program_Fixed_Component_Name_ID#") />
	<cfif iFixedPriceType eq 1 or iFixedPriceType eq 2 or iFixedPriceType eq 3 or bIsFormulaComp eq 1>
	<!----	<cfset form.rate = "" />
		<cfset form.uom = "" />--->
		<cfif bIsFormulaComp eq 1 >
			<cfset form.uom = "2" />
			<cfset form.User_Picked_UOM = "6">
			<cfset form.rate = "0" />
		</cfif>
	</cfif>

	<cfif isDefined("form.rate") AND isDefined("form.product_list") AND isDefined("form.uom")>
		<cfloop list="#form.product_list#" index="prodid">
			<cfset "form.fixed_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#_rate" = #form.rate#>
			<cfset "form.fixed_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#_uom" = #form.uom#>
			<cfset fixrule = compBusRule.getComponentRules(form.Program_Fixed_Component_Name_Id, 1).Program_Fixed_Component_Rule_ID />
			<cfset "form.fix_rule_C#form.Program_Fixed_Component_Name_Id#_P#replace(prodid, "-", "_", "ALL")#_#componentLen#" = fixrule />
		</cfloop>
	</cfif>

	<cfinclude template="contract_fixed_component_save.cfm">
</cfif>
<!---COMPONENT SAVE LOGIC END --->
<cfparam name="fixed_comp_ids" default="">
<cfparam name="currentComponentId" default="0">
<cfif isdefined("form.FixedComponentList")>
	<cfloop list="#form.FixedComponentList#" index="i">
		<cfset currentComponentId = getComponentNameId(i) />
		<cfset fixed_comp_ids = ListAppend(fixed_comp_ids, currentComponentId, ",")>
	</cfloop>
</cfif>


<CFQUERY NAME="getFixedComponents" datasource="#application.datasource#">
	select  Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,Program_Fixed_Component_Name.Fixed_Component_Type,Program_Fixed_Component_Name.Program_Fixed_Component_Name,
	Program_Fixed_Component.Program_Fixed_Component_Id, Program_Fixed_Component.Fixed_Component_Paid_to, Program_Fixed_Component.GL_Account_ID, Program_Fixed_Component.Claim_Mechanics, Program_Fixed_Component.Vendor_Master_ID
	,Program_Fixed_Component.Vendor_Selection
	,Program_Fixed_Component_Name.FP_Type <!--- 62455  --->
	<cfif appSettings.getPaymentCycleAtDiscountType()>,Program_Payment_Cycle.Payment_Cycle_ID AS PaymentCycle</cfif>
	FROM Program_Fixed_Component_Name
	LEFT JOIN Program_Fixed_Component
	ON Program_Fixed_Component.Program_Fixed_Component_Name_ID =
	Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
	AND Program_Fixed_Component.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Contract_Main_ID#">
	AND Program_Fixed_Component.Deleted = 0
	<cfif appSettings.getPaymentCycleAtDiscountType()>
	LEFT JOIN Program_Payment_Cycle
	ON Program_Payment_Cycle.Discount_Type_ID = 1
	AND Program_Payment_Cycle.Program_ID = Program_Fixed_Component.Program_ID
	AND Program_Payment_Cycle.Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID
	AND Program_Payment_Cycle.Deleted = 0
	</cfif>
	WHERE
		Program_Fixed_Component_Name.Deleted = 0
		<cfif form.FixedComponentList NEQ "">
		AND Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id IN (#fixed_comp_ids#)
		<cfelse>
		AND 1=2
		</cfif>
	ORDER BY Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,Program_Fixed_Component.Program_Fixed_Component_Id
</CFQUERY>

<CFIF NOT isdefined("form.product_list")>
<CFQUERY NAME="Get_Fixed_Products" DATASOURCE="#application.datasource#">
		SELECT	distinct BSA_Foodservice_Items_Master_ID
		FROM	Contract_Products
				INNER JOIN	dbo.Program_Fixed_Price_Product_Data
				ON
				Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND
				Program_Fixed_Price_Product_Data.Deleted = 0
		WHERE
				Contract_Products.Deleted = 0
				AND
				Contract_Products.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Contract_Main_ID#">
				AND Contract_Products.product_type_id =1
	</CFQUERY>
<CFSET FORM.Product_List = ValueList(Get_Fixed_Products.BSA_Foodservice_Items_Master_ID, ",")>
</CFIF>

<cfoutput>
	<!--- 114617 :: Ideal Price START --->
	<cfif GetTemplateInfo.Ideal_Price AND listlen(form.Product_List)>
	<CFQUERY NAME="IdealPriceQuery" datasource="#application.datasource#">
		DROP TABLE IF EXISTS ##tmp_program_ideal_price
		DROP TABLE IF EXISTS ##tmp_program_ideal_price_product_list

		CREATE TABLE ##tmp_program_ideal_price (
					 BSA_Foodservice_Items_Master_ID uniqueidentifier,
					 Item varchar(100),
					 Ideal_Price_Type tinyint not null, /*1 = No ideal price, 2 = Need volume, 3 = Has volume*/
					 SLOPE_CS decimal(38, 7) null,
					 SLOPE_LB decimal(38, 7) null,
					 YINTERCEPT_CS decimal(38, 7) null,
					 YINTERCEPT_LB decimal(38, 7) null,
					 CS decimal(38, 0) null,
					 LBS decimal(38, 0) null,
					 IDEAL_CS decimal(38, 7) null,
					 IDEAL_LB decimal(38, 7) null
		)

		SELECT value as Product_ID
		INTO ##tmp_program_ideal_price_product_list
		FROM STRING_SPLIT('#form.Product_List#', ',')

		EXEC Program_Ideal_Price #FORM.Contract_Main_ID#, '##tmp_program_ideal_price_product_list'
	</CFQUERY>
	</cfif>
<!--- 114617 :: Ideal Price END --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
SET NOCOUNT ON
			if object_id('tempdb..##tmp_cm') is not null
			drop table ##tmp_cm

			if object_id('tempdb..##contract_distributors') is not null
			drop table ##contract_distributors

			if object_id('tempdb..##tmp_cm_total_weight') is not null
			drop table ##tmp_cm_total_weight

			if object_id('tempdb..##tmp_cp_price_layered') is not null
			drop table ##tmp_cp_price_layered

			if object_id('tempdb..##tmp_program_product_price_layered') is not null
			drop table ##tmp_program_product_price_layered


		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

		DECLARE @Program_Product_Price table
		(
			Contract_Main_ID Int,
			Product_ID uniqueidentifier,
			Net_Weight decimal(20, 4),
			Price_CS_FOB decimal(20, 4),
			Price_LB_FOB decimal(20, 4),
			Price_CS_DEL decimal(20, 4),
			Price_LB_DEL decimal(20, 4),
			Item_Margin_Targets_default varchar(5)<!---D51088 :: Base Sales on Fixed Price page to be based on component type --->
		)

		DECLARE @Program_Products table
		(
			Contract_Main_ID Int,
			Product_ID uniqueidentifier,
			Net_Weight float
		)

		DECLARE
		@Price_List_By_Template BIT,
		@AppSetting_Percentage_Of_List_Price BIT,
		@Tmplt_Percentage_Of_List_Price BIT,
		@Price_List_ID NVARCHAR(50),
		@Base_Sales_based_on_Prg_Start_Date bit,
		@Effective_Date_for_Price datetime,
		@Price_List_Header_ID uniqueidentifier,
		@Contract_Start_Date datetime

		SELECT @Price_List_By_Template = Price_List_By_Template FROM _Application_Settings
		SELECT @AppSetting_Percentage_Of_List_Price = value FROM _Settings WHERE Input_name='Percentage_Of_List_Price'

		SELECT	@Effective_Date_for_Price = ISNULL(cm.Price_Protection_Date, cm.Effective_Date_for_Price),
				@Base_Sales_based_on_Prg_Start_Date =  pcpo.Base_Sales_based_on_Prg_Start_Date,
				@Price_List_Header_ID = pcpo.Margin_Price_List_Header_ID,
				@Contract_Start_Date = cm.Contract_Start_Date,
				@Tmplt_Percentage_Of_List_Price = pcpo.Percentage_Of_List_Price,
				@Price_List_ID	=	pcpo.Price_List_ID

		FROM	Contract_Main cm
				inner join Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.programtype_id
		WHERE	cm.contract_main_id = '#FORM.Contract_Main_ID#'

		IF @Effective_Date_for_Price IS NULL
		SET @Effective_Date_for_Price = @Contract_Start_Date

		INSERT INTO @Program_Products (Contract_Main_ID, Product_ID, Net_Weight)
		SELECT	'#FORM.Contract_Main_ID#',BSA_Foodservice_Items_Master.BSA_Foodservice_Items_master_ID,
		ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight as float), 0)
		FROM	BSA_Foodservice_Items_Master
		<CFIF FORM.Product_List EQ "">
		WHERE 1=2
			<CFELSE>
		WHERE BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)
		</CFIF>

		SELECT 	contract_main_id, BSA_Foodservice_Customers_id, cast(program_weight as decimal(20, 4)) as  program_weight
		INTO 	##contract_distributors
		FROM 	Contract_Distributors
		WHERE 	Contract_Distributors.Contract_Main_ID = '#FORM.Contract_Main_ID#'
		AND	Contract_Distributors.Is_Group = 0
		AND Contract_Distributors.Deleted = 0

		INSERT INTO @Program_Product_Price (Contract_Main_ID, Product_ID,Net_Weight)
		SELECT	DISTINCT Contract_Main_ID, Product_ID,Net_Weight
		FROM	@Program_Products

		--**********************************************************************************
		-- price list based on template - start
		--**********************************************************************************
		IF @Price_List_By_Template = 1
		BEGIN

			UPDATE	@Program_Product_Price
			SET		Price_CS_DEL = ISNULL(CAST(CS_Bracket_1 as float),0),
					Price_CS_FOB = ISNULL(CAST(CS_FOB_Price as float),0)
			FROM	@Program_Product_Price as Program_Products
					INNER JOIN Price_List_Detail ON	Price_List_Detail.Product_ID = Program_Products.Product_ID
					AND	(
							(@Base_Sales_based_on_Prg_Start_Date = 1 AND @Effective_Date_for_Price between Price_List_Detail.Start_Date and Price_List_Detail.End_Date)
							OR
							(@Base_Sales_based_on_Prg_Start_Date = 0 AND Price_List_Detail.Active_Code = 'A')
						)
					INNER JOIN Price_List_Header ON Price_List_Header.Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
					AND (@Price_List_By_Template = 1 AND Price_List_Header.Price_List_Header_ID = @Price_List_Header_ID)
			WHERE	Program_Products.Contract_Main_ID =  '#FORM.Contract_Main_ID#'
			AND		Price_List_Detail.Deleted = 0

			UPDATE	@Program_Product_Price
			SET		Price_LB_DEL = Price_CS_DEL / Net_Weight,
					Price_LB_FOB = Price_CS_FOB / Net_Weight

		END
		--**********************************************************************************
		-- price list based on template - end
		--**********************************************************************************

		ELSE IF (@AppSetting_Percentage_Of_List_Price = 1 AND @Tmplt_Percentage_Of_List_Price = 1)
		--**********************************************************************************
		-- START: D48146	% of List Price ---- 8.0 Release
		--**********************************************************************************
		BEGIN

			UPDATE	@Program_Product_Price
			SET		Price_CS_DEL = ISNULL(CAST(CS_Bracket_1 as float),0),
					Price_CS_FOB = ISNULL(CAST(CS_FOB_Price as float),0)
			FROM	@Program_Product_Price as Program_Products
					INNER JOIN Contract_Main CM ON  CM.Contract_Main_ID = Program_Products.Contract_Main_ID
					LEFT JOIN Price_List_Detail ON	Price_List_Detail.Product_ID = Program_Products.Product_ID
					AND Price_List_Detail.Active_Code = 'A' AND CM.Contract_Start_Date BETWEEN Price_List_Detail.Start_Date AND Price_List_Detail.End_Date
					LEFT JOIN Price_List_Header ON Price_List_Header.Price_List_Header_ID = Price_List_Detail.Price_List_Header_ID
					AND Price_List_Header.Price_List_ID = @Price_List_ID

			WHERE	Program_Products.Contract_Main_ID =  '#FORM.Contract_Main_ID#'

			AND		Price_List_Detail.Deleted = 0

			UPDATE	@Program_Product_Price
			SET		Price_LB_DEL = Price_CS_DEL / Net_Weight,
					Price_LB_FOB = Price_CS_FOB / Net_Weight

		END
		--**********************************************************************************
		-- END: D48146	% of List Price ---- 8.0 Release
		--**********************************************************************************

		ELSE
		BEGIN
			--**********************************************************************************
			-- price from item margin targets - start
			--**********************************************************************************

			UPDATE	@Program_Product_Price
			SET	Price_CS_DEL = ISNULL(cast(ITEM_DEL_BASE_PRICE_CS as float),0)
			,Price_CS_FOB = ISNULL(cast(ITEM_FOB_BASE_PRICE_CS as float),0)
			,Item_Margin_Targets_default = item_default_type<!---D51088 :: Base Sales on Fixed Price page to be based on component type --->
			FROM	@Program_Product_Price as Program_Products
			INNER JOIN Item_Margin_Targets
			ON	Item_Margin_Targets.Product_ID = Program_Products.Product_ID
			WHERE Program_Products.Contract_Main_ID =  '#FORM.Contract_Main_ID#'
			AND Item_Margin_Targets.Deleted = 0

			UPDATE	@Program_Product_Price
			SET	Price_LB_DEL = Price_CS_DEL / Net_Weight
			,Price_LB_FOB = Price_CS_FOB / Net_Weight

			--**********************************************************************************
			-- price from item margin targets - end
			--**********************************************************************************


			--**********************************************************************************
			-- price from gross margin table - start
			--**********************************************************************************

			SELECT		Contract_Products.Contract_Main_Id,
						Contract_Products.Product_Id,
						Cs_Fob_Price, Cs_Del_Price,
						Contract_Distributors.Bsa_Foodservice_Customers_Id,
						Program_Weight
			INTO		##Tmp_Gross_Margin
			FROM		##Contract_Distributors As Contract_Distributors
			INNER JOIN 	@Program_Products Contract_Products
			ON 			Contract_Distributors.Contract_Main_Id = Contract_Products.Contract_Main_Id
			LEFT JOIN 	Gross_Margin
			ON			Gross_Margin.Customer_Id = Contract_Distributors.Bsa_Foodservice_Customers_Id
			AND 		Gross_Margin.Product_Id = Contract_Products.Product_Id
			WHERE 		Cs_Fob_Price <> 0
			AND 		Gross_Margin.Deleted = 0


			SELECT		Contract_Main_Id, Product_Id, Sum(Program_Weight) As Sum_Program_Weight
			INTO 		##Tmp_CM_Total_Weight
			FROM 		##Tmp_Gross_Margin
			WHERE 		CS_Fob_Price <> 0
			GROUP BY 	Contract_Main_Id, Product_Id

			SELECT 		##Tmp_Gross_Margin.Contract_Main_Id,
						##Tmp_Gross_Margin.Product_Id,
						Sum(Cs_Fob_Price * Program_Weight / Sum_Program_Weight) As Price_Cs_Fob,
						Sum(Cs_Del_Price * Program_Weight / Sum_Program_Weight) As Price_Cs_Del
			INTO		##Tmp_Program_Product_Price_Layered
			FROM		##Tmp_Gross_Margin
			INNER JOIN 	##Tmp_CM_Total_Weight
			ON			##Tmp_CM_Total_Weight.Contract_Main_Id = ##Tmp_Gross_Margin.Contract_Main_Id
			AND 		##Tmp_CM_Total_Weight.Product_Id = ##Tmp_Gross_Margin.Product_Id
			WHERE 		##Tmp_Gross_Margin.Contract_Main_Id =  <cfqueryparam value="#FORM.Contract_Main_ID#" cfsqltype="cf_sql_integer">
			GROUP BY 	##Tmp_Gross_Margin.Contract_Main_Id, ##Tmp_Gross_Margin.Product_Id

			UPDATE		@Program_Product_Price
			SET			Price_CS_FOB = tmp_program_product_price.Price_CS_FOB,
						Price_CS_DEL = tmp_program_product_price.Price_CS_DEL
			FROM		@Program_Product_Price as Program_Products
			INNER JOIN 	##tmp_program_product_price_layered as tmp_program_product_price
			ON			tmp_program_product_price.contract_main_id = Program_Products.contract_main_id
			AND			tmp_program_product_price.Product_ID = Program_Products.Product_ID
			WHERE 		tmp_program_product_price.contract_main_id = <cfqueryparam value="#FORM.Contract_Main_ID#" cfsqltype="cf_sql_integer">

			UPDATE		@Program_Product_Price
			SET			Price_LB_DEL = (Price_CS_DEL / Net_Weight),
						Price_LB_FOB = (Price_CS_FOB / Net_Weight)

			--**********************************************************************************
			-- price from gross margin table - end
			--**********************************************************************************
		END

	SELECT  distinct  dbo.Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID,
				<!---63887 :: Need new UOM for Per Hundred Weight (CWT) START --->
				CASE
					WHEN ISNULL(dbo.Program_Fixed_Price_Product_Data.User_Picked_UOM,0) = 6 THEN CAST(ISNULL(dbo.Program_Fixed_Price_Product_Data.Fixed_Price_Value,0.0000) as float) *100
					WHEN ISNULL(dbo.Program_Fixed_Price_Product_Data.User_Picked_UOM,0) = 5 THEN ISNULL(dbo.Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price,0.0000)
					WHEN ISNULL(dbo.Program_Fixed_Price_Product_Data.User_Picked_UOM,0) = 7 THEN ISNULL(dbo.Program_Fixed_Price_Product_Data.User_Picked_Fixed_Price,0.0000)
					ELSE ISNULL(dbo.Program_Fixed_Price_Product_Data.Fixed_Price_Value,0.0000)
				END AS Fixed_Price_Value,

				CASE
					WHEN ISNULL(dbo.Program_Fixed_Price_Product_Data.User_Picked_UOM,0) IN (5,6,7) THEN dbo.Program_Fixed_Price_Product_Data.User_Picked_UOM
					ELSE dbo.Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
				END AS Unit_Of_Measure_ID,
				<!---63887 :: Need new UOM for Per Hundred Weight (CWT) END --->
				dbo.Type_Code_Desc.Type_Code_Desc,
				dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				dbo.BSA_Foodservice_Items_Master.Item,
				dbo.BSA_Foodservice_Items_Master.UPC,
				dbo.BSA_Foodservice_Items_Master.Description,
				dbo.BSA_Foodservice_Items_Master.Inventory_UM,
				cast(BSA_Foodservice_Items_Master.Net_Weight as float) as Net_Weight,
				ISNULL(BSA_Foodservice_Items_Master.Case_Count, 1) as Case_Count,
				CASE
							WHEN ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 0) = 0 THEN 1
							ELSE ISNULL(BSA_Foodservice_Items_Master.Sleeves_Per_Case, 1) end as Sleeve_Count,
				dbo.Contract_Products.Contract_Main_ID,
				contract_products.EZButton_On_Default,
				BSA_Foodservice_Items_Master.Inventory_UM,
				Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id,
				Program_Fixed_Component.GL_Account_ID,
				Program_Fixed_Component.Claim_Mechanics,
				Program_Fixed_Component.Vendor_Master_ID,
				Program_Fixed_Component.Vendor_Selection,
				dbo.Program_Fixed_Price_Product_Data.volume,
				Program_Fixed_Component.Program_Fixed_Component_Id,
				Program_Fixed_Price_Product_Data.Program_Fixed_Component_Name_Rule_ID,
				Program_Fixed_Price_Product_Data.Competitor_Name_ID,
				Program_Fixed_Price_Product_Data.Competitor_Price,
				Program_Fixed_Price_Product_Data.Competitor_Time_Frame
	<cfif  ((GetSettings.Include_Competitive_Data_Tracking EQ 1 and GetSettings.display_basesales_Competitive_Data EQ 1)  OR appsettings.getshowfixedpriceadditionalfields() EQ 1)and appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
				,isnull(Program_Product_Price.Price_CS_FOB, 0) as FOB_CS_Price
				,isnull(Program_Product_Price.Price_LB_FOB, 0) as FOB_LB_Price
				,isnull(Program_Product_Price.Price_CS_DEL, 0) as DEL_CS_Price
				,isnull(Program_Product_Price.Price_LB_DEL, 0) as DEL_LB_Price
				,isnull(program_Product_Price.Item_Margin_Targets_default, 'D') AS Item_Margin_Targets_default <!---D51088 :: Base Sales on Fixed Price page to be based on component type --->
	</cfif>
		<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
				,Program_Competitive_Data.Previous_Won_By
				,Program_Competitive_Data.Previous_Won_Price
				,Program_Competitive_Data.Previous_Won_Uom
				,Program_Competitive_Data.Previous_Won_Delivery_Type
		</cfif>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
			,Program_Payment_Cycle.Payment_Cycle_ID AS PaymentCycle
		</cfif>
		,Contract_Products.Base_Sales_CS <!--- D30357:Today's Price Wrong on Revision History --->
		,Program_Fixed_Price_Product_Data.Max_Volume_Fixed_Price
		-- 114617 :: Ideal Price START
		<cfif GetTemplateInfo.Ideal_Price  AND listlen(form.Product_List)>
		,isnull(IdealPrice.IDEAL_CS, 0) as Ideal_CS
		,isnull(IdealPrice.IDEAL_LB, 0) as Ideal_LB
		,isnull(IdealPrice.Ideal_Price_Type, 0) as Ideal_Price_Type
		,isnull(CS, 1) as VolumeCS
		,isnull(LBS, 1) as VolumeLB
		,IdealPrice.slope_cs
		,IdealPrice.slope_lb
		,IdealPrice.yintercept_cs
		,IdealPrice.yintercept_lb
		</cfif>
		---114617 :: Ideal Price END
	FROM dbo.BSA_Foodservice_Items_Master
	LEFT join Program_Fixed_Component_Name
	ON Program_Fixed_Component_Name.deleted = 0
	<CFIF LIstlen(fixed_comp_ids) GT 0>
	AND Program_Fixed_Component_Name_Id IN (#fixed_comp_ids#)
	<cfelse>
	AND 1 = 2
	</CFIF>
	LEFT JOIN	dbo.Brand
	ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID
	LEFT JOIN	dbo.Type_Code_Desc
	ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
	<!---  --->
	LEFT JOIN Program_Fixed_Component
	ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_Id = Program_Fixed_Component.Program_Fixed_Component_Name_ID
	AND Program_Fixed_Component.program_id = '#FORM.Contract_Main_ID#'
	AND Program_Fixed_Component.deleted = 0
	LEFT JOIN (dbo.Contract_Products
						INNER JOIN dbo.Program_Fixed_Price_Product_Data
						ON dbo.Program_Fixed_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID
						AND (dbo.Program_Fixed_Price_Product_Data.Deleted = 0)
					)
	ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	AND (dbo.Contract_Products.Deleted = 0)
	AND (dbo.Contract_Products.Contract_Main_ID = Program_Fixed_Component.program_id)
	AND (dbo.Contract_Products.Product_Type_ID = 1)
	AND Program_Fixed_Component.Program_Fixed_Component_Id = Program_Fixed_Price_Product_Data.Program_Fixed_Component_Id
	<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
		LEFT JOIN Program_Competitive_Data
		ON Program_Competitive_Data.program_id = contract_products.contract_main_id
		AND contract_products.BSA_Foodservice_Items_Master_id = Program_Competitive_Data.product_id
	</cfif>
	<cfif  ((GetSettings.Include_Competitive_Data_Tracking EQ 1 and GetSettings.display_basesales_Competitive_Data EQ 1)  OR appsettings.getshowfixedpriceadditionalfields() EQ 1)and appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
		LEFT JOIN @Program_Product_Price As Program_Product_Price
		ON Program_Product_Price.product_id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	</cfif>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		LEFT JOIN Program_Payment_Cycle
		ON Program_Payment_Cycle.Discount_Type_ID = 1
		AND Program_Payment_Cycle.Program_ID = Program_Fixed_Component.Program_ID
		AND Program_Payment_Cycle.Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID
		AND Program_Payment_Cycle.Deleted = 0
	</cfif>
<!--- 114617 :: Ideal Price START --->
<cfif GetTemplateInfo.Ideal_Price AND listlen(form.Product_List)>
LEFT JOIN ##tmp_program_ideal_price IdealPrice
ON IdealPrice.BSA_Foodservice_Items_Master_ID  = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
</cfif>
<!--- 114617 :: Ideal Price END --->
	WHERE 	<CFIF FORM.Product_List EQ "">
					1=2
				<CFELSE>
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)
					<!--- Dev Note(79237 and 94627) When a component has a second component, both components should be next to neach other,
					with the parent component displaying before the 2nd component.--->
					ORDER BY #sql_Sort_By#,Program_Fixed_Component.Program_Fixed_Component_Id <!--- Do not change "ORDER BY" logic --->
				</CFIF>
	if object_id('tempdb..##tmp_cm') is not null
	drop table ##tmp_cm

	if object_id('tempdb..##contract_distributors') is not null
	drop table ##contract_distributors

	if object_id('tempdb..##tmp_cm_total_weight') is not null
	drop table ##tmp_cm_total_weight

	if object_id('tempdb..##tmp_cp_price_layered') is not null
	drop table ##tmp_cp_price_layered

	if object_id('tempdb..##tmp_program_product_price_layered') is not null
	drop table ##tmp_program_product_price_layered
</CFQUERY>

<cfif EzButton_Disable EQ 1>
<cfset GetEZButtonDefaultRates = EZProgramManager.getFixedEZSettings(getsettings.EZ_Contract_Id,FORM.Product_List,fixed_comp_ids)>
</cfif>

<CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfset getCompetitiveProductsInfo = bidRequestProdMan.getpreviousinfo(CSL_Contract_Main_ID)>
</CFIF>

</cfoutput>

<cfset checkifprodmatchinfreighttable = "true">
<cfset FREIGHTRATESAPPLIED = 0>
<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
<cfif form.Product_List NEQ "">
<cfset checkifprodmatchinfreighttable  = fixedCompObj.checkifprodmatchinfreighttable(FORM.Contract_Main_ID,form.Product_List)>
<cfloop list="#form.paidToList#" index="pdList">
<cfset FREIGHTRATESAPPLIED = fixedCompObj.FREIGHTRATESAPPLIED(FORM.Contract_Main_ID,0,pdList)>
</cfloop>
</cfif>
</cfif>

<cfscript>
	function buildFixedInputName(compId, pId, iI, sSuffix)
	{
		return "fixed_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix;
	}

	function buildFixeddocumentName(compId, pId, iI, sSuffix)
	{
		return "document.all.fixed_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix & ".value";
	}

	function buildSecondInputName(compId, pId, iI, sSuffix)
	{
		return "document.all.fixed_C" & compId & "_P" & replace(pId, "-", "_", "ALL") & "_" & iI & sSuffix;
	}
</cfscript>
<!--- </cfsilent> --->
<SCRIPT>
	var my_queue = new Queue();
	function deleteComponent(component_id, name) {
		if(confirm("Do you really want to delete " + name + "?")){
			document.all.comDeleteForm.Component_ID.value = component_id;
			document.all.comDeleteForm.submit();
		}

	}

	function showProductSearchWindow_old() {
	<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
		if (<cfoutput>#checkifdistributorsadded.distributorsadded#</cfoutput> > 0)
		{
	</cfif>
		if(document.all.Program_Fixed_Component_Name_ID){
			 document.all.Program_Fixed_Component_Name_ID.value = "-1";
		}

			 openPopup("product_Select_V1.cfm?Formname=FixedComponents&Discountype=1&EZTemplate=<cfoutput>#url.EZTemplate#&FirstParentID=#GetTemplateInfo.First_Parent_ID#&prgID=#GetContractInfo.Contract_Main_ID#</cfoutput>", 1000, 800,"productwindow", "yes", "yes", true)
	<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
		}
		else
		{
		alert ("Add distributors to the program before you add products.");
		}
	</cfif>
		}


	function showProductSearchWindow() {
	<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
		if (<cfoutput>#checkifdistributorsadded.distributorsadded#</cfoutput> > 0)
		{
	</cfif>
			 document.all.Program_Fixed_Component_Name_ID.value = "-1";
			 var sURL = "/Flex/search/ItemSearchFx.cfm?Formname=FixedComponents&DiscountType=1&EZTemplate=<cfoutput>#url.EZTemplate#&programId=#FORM.Contract_Main_ID#</cfoutput>";
			 NewWindowTopLeft(sURL, "productwindow", 1000, 715, "yes", "yes", true)
	<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
		}
		else
		{
		alert ("Add distributors to the program before you add products.");
		}
	</cfif>
		}

		var startDataCol = 3;
		<cfif application.returned_customer_setting.upc_switch EQ 0>
			startDataCol = startDataCol - 1;
		</cfif>

		function deleteThisFixedPrice(FieldNameRe, prodID)
	{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.FixedComponents.Product_List.value;
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = 'true';

		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = 'false';
		}

		document.all.Product_List.value = resultString;
		document.all.ExistingProductList.value = resultString;
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		if(trObj)
		{
			if(bDelete == 'true')
			{
				trObj.height = trObj.offsetHeight;

				trObj.cells[trObj.cells.length-1].innerHTML = empty_String;

				<cfset CompLen = ListLen(form.fixedcomponentlist)>

				for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
				{
				disableDiv(trObj.cells[i+startDataCol], true, false);
				}
        // DO NOT CHANGE THE BACKGROUND COLOR!!! IF YOU WANT TO CHANGE MAKE SURE THE CHECKING IN THE
        // FUNCTION verifyData() IS ALSO CHANGED TO THE COLOR YOU ARE SETTING HERE - Anand Rao, 02/12/09, Label 18107
				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);

				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				//resetnavigate();
				document.all.deleted.value = Number(document.all.deleted.value) + 1;		//D30231:Deleting Items off a Revised Program
			}
			else
			{

				<cfset CompLen = ListLen(form.fixedcomponentlist)>
				<cfif EzButton_Disable EQ 0>
				for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
				{
				disableDiv(trObj.cells[i+startDataCol], false, false);
				}
				</cfif>
				var bgCol = "FFFFFF";
				if(trObj.rowIndex % 2 == 1)
				{
					bgCol = "C6FFC6";
				}
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);

				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;

				propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
				document.all.deleted.value = document.all.deleted.value - 1;		//D30231:Deleting Items off a Revised Program
			}
			/* The reason why "bDelete" is a string and not a boolean is because "setAttribute" can only set a string value and not a boolean. */
			srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
			trObj.setAttribute('bDelete',(bDelete == 'true'?1:0));
		}

	}

	function enableDisableRate()
	{
		document.all.rate.disabled = false;
		document.getElementById("uom").disabled = false;

		var PassedNumber;
		PassedNumber = parseInt(document.all.Program_Fixed_Component_Name_ID.value);

		if(PassedNumber > 0)
		{
			var fixed_price_type = eval("document.all.Fixed_Fixed_Price_Type_" + PassedNumber + ".value");
			var Formula_Pricing = eval("document.all.Formula_Pricing_" + PassedNumber + ".value");
			 /* When the fixed price type is either deviated price (meets competition) or price extension or combination (blended), disable the rate as the rate
			    is derived from the price list.
			 */
			if(fixed_price_type == 1 || fixed_price_type == 2 || fixed_price_type == 3)
			{
				document.all.rate.disabled = true;
				document.all.rate.value='0.000';
			}
			if(Formula_Pricing == 1)
			{
				document.all.rate.disabled = true;
				document.all.rate.value='0.000';
				document.getElementById("uom").disabled = true;
				document.all.uom.value='6';
			}
		}

	}

	function submitForm()
	{
		ErrorCount = 0

		if(document.FixedComponents.Claim_Mech)
		{
		/* This variable is set in Component_Information.cfm. If the component/Claim Mech template setting combo returns nothing,
			 show this message. The value is set to blank in claim_mech_info.cfm
		*/
			if(document.FixedComponents.Claim_Mech.value == '')
			{
			 alert("Please ask your system administrator to review the configuration settings for the component.  This component does not have any claim mechanics to display.");
			 return false;
			}
		}

    if(<cfoutput>#GetTemplateInfo.Ideal_Price#</cfoutput> && document.FixedComponents.compLen.value >=1 )
		{
		  alert("This program can only have one discount type. Please remove a discount type.");
			 return false;
		}

    if(document.FixedComponents.bAllowAddComp.value == 0 )
		{
		  alert("This program can only have one discount type. Please remove a discount type.");
			// return false; // This will be a HARD STOP and we only need an information
		}

		<cfset complen = ListLen(form.FixedComponentList)>
		<cfset prodlen = ListLen(form.Product_List)>
		/* Initial Count */
		var ExistsComponent = 0;
		/*ID passed to javascript */
		var PassedNumber;
				PassedNumber = parseInt(document.all.Program_Fixed_Component_Name_ID.value);
		var complen = 0;
		var complist = document.all.FixedComponentList.value;
				if(complist.length){
					complist = complist.concat(',',PassedNumber);
				}else{
					complist = complist.concat(PassedNumber);
				}
				complen = complist.length;

		var compArray = complist.split(',');

    /* Dont let the user add the same component more than twice */
		<cfloop list="#form.FixedComponentList#" index="FixedComponentID">
			//existing comp id and paid to
			var thisCompId = <cfoutput>"#getComponentNameId(FixedComponentID)#"</cfoutput>;
			var thisPaidTo = <cfoutput>"#getComponentPaidTo(FixedComponentID)#"</cfoutput>;
			//comp id and paid to being selected
			var selCompId = document.all.Program_Fixed_Component_Name_ID.value;
			//figure out which paid to is selected
			var selPaidTo = 0;
			collObjects = document.getElementsByName("Fixed_Component_Paid_To");
			for (var i = 0; i<collObjects.length; i++){
				if(collObjects[i].checked)
					selPaidTo = collObjects[i].value;
			}
			if(selCompId == thisCompId){
			//PassedNumber = parseInt(document.all.Program_Fixed_Component_Name_ID.value);
				ExistsComponent = parseInt(ExistsComponent) + PassedNumber;
				/* Divide the Passed SelectedIndex ID by the previously Selected Number (Chosen twice) */
				<cfif url.EZTemplate EQ 1 or EzButton_Disable EQ 1>
				if(document.all.Program_Fixed_Component_Name_ID.value == ExistsComponent)
				<cfelse>
				if(document.all.Program_Fixed_Component_Name_ID.value == ExistsComponent/2)
				</cfif>
				{
					alert("You cannot add the same component more than twice.");
					return false;
				}
				//if this component/paid to combination alrady exists then show alert and don't submit
				if (thisPaidTo == selPaidTo){
					alert("A component with this Paid To already exists. Please change the Paid To or select another component.");
					return false;
				}
			}
		</cfloop>


		<!--- If it is auto pay, and operator or broker, the vendor id is required.
				If it is auto pay and includes distributor and doesn't have id, then let them know
				about the manual allocation of vendors on the auto billbacks --->
		<!--- only bother with any of this if it's auto pay --->
		if(document.FixedComponents.Auto_Pay_Status.value == 1){
			<!--- They didn't pick a payee --->
			if(document.all.Vendor_Master_ID){
			 if(document.all.Vendor_Master_ID.value == 0){
				 var OperatorOption = 0;
				 var PayeeOption = 0;
					if (document.all.Fixed_Component_Paid_To){
						/* Determine who the payee is */
						for (i=0; i<=document.all.Fixed_Component_Paid_To.length-1; i++){
							if (document.all.Fixed_Component_Paid_To[i].checked == true){
								PayeeOption = i;
							}
						}
							if (PayeeOption == 1 || PayeeOption == 3){
								OperatorOption = 1
							}
					}
				/* A vendor needs to be selected if "Select a single payee" option is selected, otherwise the vendor
					 needs is required ony if the payee is an operator or has an operator (Customer and Operator option).
					 document.all.Vendor_Selection.value will be true for "Select a single payee".
					 (It comes from claim_mech_info.cfm)
				*/
					 if(document.all.Vendor_Selection.value == 'true'){
					 		if(PayeeOption == 0){
								alert("You must select a vendor for the auto payments.")
								return false;
							}else{
								alert("You must select a vendor for auto pay components not payable to distributor")
								return false;
							}
						}else{
							if(PayeeOption == 1 || PayeeOption == 3){
								alert("You must select a vendor for auto pay components not payable to distributor")
								return false;
							}
					 	}
					}
				}
			}

		if (<cfoutput>#compLen#</cfoutput> >= maxComponentPossible)
		{
			ErrorCount++;
			queueMessage("No more than " + maxComponentPossible + " component(s) may be applied.", document.all.error_component);
		}else{
				clearQueue(document.all.error_component);
			if(document.all.Program_Fixed_Component_Name_ID.value == "-1"){
					ErrorCount++;
					queueMessage("You must select at least one component.", document.all.error_component);
				}else {
					clearQueue(document.all.error_component);
				}
		<cfif EzButton_Disable EQ 0>
			var fixed_price_type = eval("document.all.Fixed_Fixed_Price_Type_" + PassedNumber + ".value");
			var Formula_Pricing = eval("document.all.Formula_Pricing_" + PassedNumber + ".value");
			/* When the rate ir blank and fixed price type is NOT deviated price (meets competition) or price extension or combination (blended) */
			if(document.all.rate.value == "" && fixed_price_type != 1 && fixed_price_type != 2 && fixed_price_type != 3  <cfif appSettings.get_Setting('Percentage_Of_List_Price') EQ '1'>&& document.all.txtPercentage.value == "" </cfif> && Formula_Pricing != 1){
				ErrorCount++;
				queueMessage("You must enter a rate for the component.", document.all.error_rate);
			}else{
				clearQueue(document.all.error_rate);
			}

			<cfif appSettings.getPaymentCycleAtDiscountType()>
				if(document.all.PaymentCycle.value == 0){
					ErrorCount++;
					queueMessage("You must select a payment cycle for the component.", document.all.Err_Payment_Cycle);
				}else{
					clearQueue(document.all.Err_Payment_Cycle);
				}
			</cfif>

			<!--- Make sure that the GL Code is there if GL Account is on and GL Required for app setting is on --->
			<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
				if(document.FixedComponents.GL_Account_ID.value == "0" || document.FixedComponents.GL_Account_ID.value == ""){
					ErrorCount++;
					queueMessage("You must select a <cfoutput>#Application.GLAccountLabel#</cfoutput> for this component.", document.all.Err_GL);//D42774
				}else{
					clearQueue(document.all.Err_GL);
				}
			</cfif>
		</cfif>
		}

			if(ErrorCount == 0){
				<cfif EzButton_Disable EQ 1>
				document.all.rate.value = "0.000";
				</cfif>
				document.all.Program_Fixed_Component_Name_ID_Selection_Validated.value = 1;
				processingPopUpDisplay('div.customContainer');//D51575
			//	var actionpage;
			//	actionpage = "contract_fixed_component_save.cfm";
			//	document.FixedComponents.action = actionpage;
				document.FixedComponents.DoNotRedirectToNextPage.value = 1;
				document.FixedComponents.submit();
			}else{
				showMessageWindow();
			}
	}


	var resultString;
	function verifyDelete(component_id, component_name,position,paidTo,secondComponentNameID) {

		/*  Dev Note - (79237) - If the component has a 2nd (child) component */
		if(document.all.Program_Fixed_Component_Name_ID){
		 document.all.Program_Fixed_Component_Name_ID.value = "-1";
		}
		 document.all.component_id_value.value = component_id;
		if(confirm("Are you sure you want to delete " + component_name + "?")) {
            var FINALCOMPLIST = document.all.FixedComponentList.value;
									resultString = ListDeleteAt(FINALCOMPLIST, ",", position);

		if(secondComponentNameID > 0 ){
			 verifySecondComponentDelete(secondComponentNameID);
		 }

			/*
			document.all.FixedComponentList.value = resultString;
			document.all.DeletedComponentPosition.value = position+1;
			*/
			jQuery("input[name=FixedComponentList]").val(resultString);
			jQuery("input[name=DeletedComponentPosition]").val( position+1);

			$.ajax({
							type: "POST",
							url: "/components/programs/Display_Program/viewprogramtemplateManager.cfc?method=FixedCompDelete",
							data:{
								ContractMainID: <cfoutput>#form.Contract_Main_ID#</cfoutput>,
								CompID:component_id
							},
							success:function(){
								document.FixedComponents.submit();
            		NewWindow("save_fixed_freight_rates.cfm?deleteComponent=true&programId=<cfoutput>#form.Contract_Main_ID#</cfoutput>&componentId="+ component_id + "&paidTo="+paidTo, "freightwindow", 800, 600, "yes", "yes", true);
							},
							error: function(){
														alert("Failed to remove component.")
													}
							});
       }
	}
	/* Dev Note - (79237) - Delete the 2nd component */
	function verifySecondComponentDelete(component_id){
		if(component_id != ''){

			var bDelete = 0;
			var deletePosition = -1;

			/*"arrResultString" will have one component per array index. eg: "4_1_41_121_0_0_10_0_1_12_1" will be the content of one index */
			var arrResultString = resultString.split(",");

			for(i=0;i<arrResultString.length;i++){

				 /*"arrResultStringParts" will have one attribute of component per index, e.g. - component_name,component_paid_to etc.
				 Cuurrentl, there are 12 attributes of a component. 1st is component_name and and 12th is "IsSecondComponent".
				 e.g. For ""4_1_41_121_0_0_10_0_1_12_1", 4 will be first index, 1 will be second,41 will be the third index and so on.
				 */
				 var arrResultStringParts = arrResultString[i].split("_");

				for(j=0;j<arrResultStringParts.length;j++){
						/* If the component id and matches and "IsSecondComponent" is true */
						if(arrResultStringParts[0] == component_id && arrResultStringParts[11] == 1)
						{
							bDelete = 1;
							deletePosition = i;
							break;
						}
				}

			}
			/* Delete the Second Component */
			if(bDelete == 1){
				 resultString = ListDeleteAt(resultString, ",", deletePosition);
			}
		 }
	}

	function adjustdiscount(compprodId,defaultCSPrice,defaultLBPrice,ruleUOM,applyPercentTo,costImpact,netWeight,fobCSPrice,fobLBPrice,prodId)
	{
		var fixedpricevalue = eval("document.all." + compprodId + "_rate.value");
		var fixeduomvalue = eval("document.all." + compprodId + "_uom.value");
		var caseCount = eval("document.all.case_count_" + prodId + ".value");
		var SleeveCount = eval("document.all.Sleeve_count_" + prodId + ".value");
		var inventoryUM = eval("document.all.Inventory_UM_" + prodId + ".value");
		var PDiscountPercent = eval(compprodId + "_DP");

		var PDiscount = eval(compprodId + "_D");
		var TDiscountPercent = eval(compprodId + "_TDDiscPer");
		var TDDiscount = eval(compprodId + "_TDDisc");
		var TDFixedPrice = eval(compprodId + "_TDFP");

		var TDCompetitorName = eval("document.all." + compprodId + "_TDCName");
		var TDCompetitorPrice = eval("document.all." + compprodId + "_TDCPrice");
		var TDCompetitorTimeFrame = eval("document.all." + compprodId + "_TDCTimeFrame");
		var enteredCSRate, enteredLBRate, discountVal;


	<!---	*******************************************************************************************************
		If ruleUOM == 3 and applyPercentTo == 2 then there is a business rule for this Fixed Component where the
		cost impact is based on a percentage of the fixed price amount entered. So we have to adjust the
		defaultCSPrice and defaultLBPrice values.
		*******************************************************************************************************--->
		if (ruleUOM == 3 && applyPercentTo == 2)
		{
			if (fixeduomvalue == 1)
			{
				enteredCSRate = fixedpricevalue;
				enteredLBRate = enteredCSRate / netWeight;
			}
			else
			{
				enteredLBRate = fixedpricevalue;
				enteredCSRate = enteredLBRate * netWeight;
			}

			defaultCSPrice = eval(parseFloat(fobCSPrice) + (parseFloat(enteredCSRate) * (costImpact/100.00)));
			defaultLBPrice = eval(parseFloat(fobLBPrice) + (parseFloat(enteredLBRate) * (costImpact/100.00)));
		}

		var trObj = getParentObject(event.srcElement, "tr");

		if(fixeduomvalue == 6){ // CWT
			// convert from CWT to LB
			fixedpricevalue = fixedpricevalue / 100.00;
			fixeduomvalue = 2;
		}
		else if(fixeduomvalue == 5 || fixeduomvalue == 7){ // 76541 Eaches
				if(fixeduomvalue == 5){
					// convert from EA to CS
					fixedpricevalue = fixedpricevalue * caseCount;
				}else{
					// convert from SL to CS
					fixedpricevalue = fixedpricevalue * SleeveCount;
				}
			fixeduomvalue = 1;
			if(inventoryUM == "LB"){
				fixedpricevalue = fixedpricevalue / netWeight;
				fixeduomvalue = 2;
			}
		}

		if (fixeduomvalue == 1)
		{
			discountVal = defaultCSPrice - fixedpricevalue;
			if(discountVal > 0)
			{
				<cfif ! GetTemplateInfo.Ideal_Price>
				TDDiscount.style.backgroundColor = "F2ACA5";
				TDiscountPercent.style.backgroundColor = "F2ACA5";
				TDFixedPrice.style.backgroundColor = "F2ACA5";
				if(TDCompetitorName) TDCompetitorName.style.backgroundColor = "F2ACA5";
				if(TDCompetitorPrice)TDCompetitorPrice.style.backgroundColor = "F2ACA5";
				if(TDCompetitorTimeFrame)TDCompetitorTimeFrame.style.backgroundColor = "F2ACA5";
				</cfif>
				/* If a discount is offered,then the user needs to enter all the competitor Information.
				   - Name, Price
				   The variable "Check_Competitor_Info" is used to detetmine whether the competitor info should
				   be filled or not
				  */
				if(TDCompetitorName && TDCompetitorPrice)
				{
				 document.FixedComponents[compprodId +'_Check_Competitor_Info'].value = 1;
				}
			}
			else
			{
				TDDiscount.style.backgroundColor = "";
				TDiscountPercent.style.backgroundColor = "";
				TDFixedPrice.style.backgroundColor = "";
				if(TDCompetitorName) TDCompetitorName.style.backgroundColor = "";
				if(TDCompetitorPrice) TDCompetitorPrice.style.backgroundColor = "";
				if(TDCompetitorTimeFrame)TDCompetitorTimeFrame.style.backgroundColor = "";
				/* If a discount is not offered,then filling in the competitor Information (Name, Price) is optional.
				   The variable "Check_Competitor_Info" is used to detetmine whether the competitor info should
				   be filled or not
				  */
				if(TDCompetitorName && TDCompetitorPrice)
				{
				 document.FixedComponents[compprodId +'_Check_Competitor_Info'].value = 0;
				}
			}

			discountVal = formatToDeciamalPlaces(discountVal,4);
			if(eval(discountVal < 0))
			{
				discountVal = formatToDeciamalPlaces(0,4);
			}
			//PDiscount.innerText = '$ ' + formatToDeciamalPlaces((defaultCSPrice - fixedpricevalue),4);
			PDiscount.innerText = '$ ' + discountVal;

			if (defaultCSPrice != 0 && eval(discountVal > 0))
			{
				PDiscountPercent.innerText = Math.round(formatToDeciamalPlaces(((defaultCSPrice - fixedpricevalue)/defaultCSPrice) * 100,2)) + "%";
			}
			else
			{
				PDiscountPercent.innerText = formatToDeciamalPlaces(0,2) + "%";
			}
		}
		else if (fixeduomvalue == 2)
		{
			discountVal = defaultLBPrice - fixedpricevalue;
			if(discountVal > 0)
			{
				<cfif ! GetTemplateInfo.Ideal_Price>
				TDDiscount.style.backgroundColor = "F2ACA5";
				TDiscountPercent.style.backgroundColor = "F2ACA5";
				TDFixedPrice.style.backgroundColor = "F2ACA5";
				if(TDCompetitorName) TDCompetitorName.style.backgroundColor = "F2ACA5";
				if(TDCompetitorPrice)TDCompetitorPrice.style.backgroundColor = "F2ACA5";
				if(TDCompetitorTimeFrame)TDCompetitorTimeFrame.style.backgroundColor = "F2ACA5";
				</cfif>
				/* If a discount is offered,then the user needs to enter all the competitor Information.
				   - Name, Price
				   The variable "Check_Competitor_Info" is used to detetmine whether the competitor info should
				   be filled or not
				  */
				if(TDCompetitorName && TDCompetitorPrice)
				{
				 document.FixedComponents[compprodId +'_Check_Competitor_Info'].value = 1;
				}
			}
			else
			{
				TDDiscount.style.backgroundColor = "";
				TDiscountPercent.style.backgroundColor = "";
				TDFixedPrice.style.backgroundColor = "";
				if(TDCompetitorName) TDCompetitorName.style.backgroundColor = "";
				if(TDCompetitorPrice) TDCompetitorPrice.style.backgroundColor = "";
				if(TDCompetitorTimeFrame)TDCompetitorTimeFrame.style.backgroundColor = "";
				/* If a discount is not offered,then filling in the competitor Information (Name, Price, Source) is optional.
				   The variable "Check_Competitor_Info" is used to detetmine whether the competitor info should
				   be filled or not
				  */
				if(TDCompetitorName && TDCompetitorPrice)
				{
				 document.FixedComponents[compprodId +'_Check_Competitor_Info'].value = 0;
				}
			}

			discountVal = formatToDeciamalPlaces(discountVal,4);
			if(eval(discountVal < 0))
			{
				discountVal = formatToDeciamalPlaces(0,4);
			}
			//PDiscount.innerText = '$ ' + formatToDeciamalPlaces((defaultLBPrice - fixedpricevalue),4);
			PDiscount.innerText = '$ ' + discountVal;

			if (defaultLBPrice != 0 && eval(discountVal > 0))
			{
				PDiscountPercent.innerText = formatToDeciamalPlaces(((defaultLBPrice - fixedpricevalue)/defaultLBPrice) * 100,2) + "%";
			}
			else
			{
				PDiscountPercent.innerText = 0;
			}
		}
	}

	function openPopup(url, winW, winH, winN)
	{
		var windowWidth = 640;
		var windowHeight = 480;
		var windowName = 'popupWindow';

		if(winW)
		{
			windowWidth = winW;
		}
		if(winH)
		{
			windowHeight = winH;
		}
		if(winN)
		{
			windowName = winN;
		}
		var w = 640/3;
		var h = 480/3;
		var cw = w/2;
		var ch = h/2;

		if (window.screen)
		{
			w = Math.floor(screen.availWidth/3);
    		h = Math.floor(screen.availHeight/3);
    		cw = Math.floor((screen.availWidth-windowWidth)/2);
    		ch = Math.floor((screen.availHeight-windowHeight)/2);
		}

    	myPopup = window.open(url,windowName,'resizable=yes,scrollbars=yes,,width='+windowWidth+',height='+windowHeight+',top='+ch+',left='+cw);
    	if (!myPopup.opener)
        	myPopup.opener = self;
	}
</SCRIPT>

<CF_MessageWindow>
<cfif NOT isDefined("FORM.FirstTime")>
	<cfoutput query="Thequery" group="BSA_Foodservice_Items_Master_ID">
		<cfset i =1>
		<cfoutput>
			<cfparam name="form.fixed_C#Program_Fixed_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_rate" default="#Fixed_Price_Value#">
			<cfparam name="form.fixed_C#Program_Fixed_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_uom" default="#Unit_Of_Measure_ID#">
			<cfparam name="form.fixed_C#Program_Fixed_Component_Name_Id#_P#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#_#i#_volume" default="#volume#">
			<cfset i = i+1>
		</cfoutput>
	</cfoutput>
</cfif>

<cfif isDefined("FORM.FirstTime")>
<cfparam name="Form.DeletedComponentPosition" default="0">
<cfloop list="#Form.Product_List#" index="productId">
	<cfset anyDeleted = 0>
	<cfloop from="1" to="#ListLen(fixed_comp_ids)#" index="i">

	<cfset sInputRate1 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_rate") >
	<cfset sInputUom1 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_uom") >
	<cfset sInputVolume1 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_volume") >

	<cfset sInputRate2 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i+1, "_rate") >
	<cfset sInputUom2 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i+1, "_uom") >
	<cfset sInputVolume2 = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i+1, "_volume") >

	<cfset sInputCompetitorNameID = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_Competitor_Name_ID") >
	<cfset sInputCompetitorPrice = buildFixedInputName(ListGetAt(fixed_comp_ids,i), productId, i, "_CompetitorPrice") >

	<cfif Form.DeletedComponentPosition EQ i>
		<cfset anyDeleted = 1>
	</cfif>


	<cfif anyDeleted>
		<cfparam name="form.#sInputRate1#" default="">
		<cfparam name="form.#sInputUom1#" default="">
		<cfparam name="form.#sInputVolume1#" default="">
		<cfset "form.#sInputRate1#" = Evaluate("form.#sInputRate2#")>
		<cfset "form.#sInputUom1#" = Evaluate("form.#sInputUom2#")>
		<cfset "form.#sInputVolume1#" = Evaluate("form.#sInputVolume2#")>
	<cfelse>
		<cfparam name="form.#sInputRate1#" default="">
		<cfparam name="form.#sInputUom1#" default="">
		<cfparam name="form.#sInputVolume1#" default="">
	</cfif>

	</cfloop>
</cfloop>
</cfif>

<cfparam name="Min_Fixed_Case" default="">
<cfparam name="Max_Fixed_Case" default="">
<cfparam name="Min_Fixed_Pound" default="">
<cfparam name="Max_Fixed_Pound" default="">
<cfparam name="ThereisMinorMax" default="0">

<!---Sets min and max values if they exist for the profile--->
<cfif len(trim(getSettings.Min_Fixed_Case)) IS NOT 0>
	<cfset Min_Fixed_Case = getSettings.Min_Fixed_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Fixed_Case)) IS NOT 0>
	<cfset Max_Fixed_Case = getSettings.Max_Fixed_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_Fixed_Pound)) IS NOT 0>
	<cfset Min_Fixed_Pound = getSettings.Min_Fixed_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Fixed_Pound)) IS NOT 0>
	<cfset Max_Fixed_Pound = getSettings.Max_Fixed_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>

<cfset session.fix_Product_List = form.Product_List>

<SCRIPT>
	function jsBuildFixedInputName(compId, pId, iI, sSuffix)
	{
		return "fixed_C" + compId + "_P" + pId + "_" + iI + sSuffix;
	}

	function jsBuildFixeddocumentName(compId, pId, iI, sSuffix)
	{
		return "document.all.fixed_C" + compId + "_P" + pId + "_" + iI + sSuffix + ".value";
	}

	function jsBuildSecondInputName(compId, pId, iI, sSuffix)
	{
		return "document.all.fixed_C" + compId + "_P" + pId + "_" + iI + sSuffix;
	}
function setStyle(o)
	{
		var s = "background-color: red";
		alert(o.value + "  ::  ");
		if(o.value == 0.0 || o.value == "")
			{
				s = "background-color: #CC99FF";
			}
		return s;
	}
function verifyDataChange(compid,prod,i,o)
{

	var Errcount = 0;
	var FatalErr = 0;
	var srcObj = event.srcElement;
	var allowNull = "<CFOUTPUT>#AllowNullInComponent#</CFOUTPUT>";
	var thisForm = document.FixedComponents;

		var InputRate1 = eval(jsBuildFixeddocumentName(compid,prod,i,"_rate"));
		var InputRate2 = jsBuildFixedInputName(compid,prod,i,"_rate");
		var InputUOM   = eval(jsBuildFixeddocumentName(compid,prod,i,"_uom"));
		var InputObj = document.getElementById(InputRate2);
		//alert(InputRate1 + " :: <cfoutput>lb: #Min_Fixed_Pound# :: cs: #Min_Fixed_Case#</cfoutput>");
     	//  CHECKING FOR THE DELETED ITEM WILL NOT WORK IF THIS IS UNCOMMENTED
		// propogateProperty(spanObj, "style.backgroundColor", "white", false);

	var caseCount = eval("document.all.case_count_" + prod + ".value");
	var SleeveCount = eval("document.all.Sleeve_count_" + prod + ".value");
	var inventoryUM = eval("document.all.Inventory_UM_" + prod + ".value");
	var netWeight = eval("document.all.net_weight_" + prod + ".value");

		if(InputRate1 == "")
		{
			//propogateProperty(spanObj, "style.backgroundColor", "#CC99FF", false);
			InputObj.style.backgroundColor = "#CC99FF"
			Errcount++;
		}

		if(InputRate1 != "" && InputUOM == 6){ // CWT
			InputUOM = 2;
			InputRate1 = InputRate1 / 100.00;
		}
		else if(InputRate1 != "" && (InputUOM == 5 || InputUOM == 7)){ // 76541 Eaches
			InputUOM = 1;
			if(InputUOM == 5){
				InputRate1 = InputRate1 * caseCount;
			}else{
				InputRate1 = InputRate1 * SleeveCount;
			}
			if(inventoryUM == "LB"){
				InputUOM = 2;
				InputRate1 = InputRate1 / netWeight;
			}
		}

		<cfif ThereisMinorMax IS 1>
		<!---Pounds first--->
		if((InputUOM == 2) && (InputRate1 != "") && (InputObj.disabled == false) && (InputObj.style.backgroundColor != "#dddddd") )
		{	<!--- alert(InputObj.disabled) --->
			<Cfif len(trim(Min_Fixed_Pound)) IS NOT 0 AND ! GetTemplateInfo.Ideal_Price>
			<!---Pounds Min--->
			if(InputRate1 < <cfoutput>#Min_Fixed_Pound#</cfoutput>)
			{
				//propogateProperty(spanObj, "style.backgroundColor", "yellow", false);
				InputObj.style.backgroundColor = "yellow";
				FatalErr++;
				document.all.spMinRateWarn.style.display = "inline";
			}
			</cfif>

			<Cfif len(trim(Max_Fixed_Pound)) IS NOT 0 AND Max_Fixed_Pound IS NOT 0 AND ! GetTemplateInfo.Ideal_Price>
			<!---Pounds Max--->
			if(InputRate1 > <cfoutput>#Max_Fixed_Pound#</cfoutput>)
			{
				//propogateProperty(spanObj, "style.backgroundColor", "red", false);
				InputObj.style.backgroundColor = "red";
				FatalErr++;
				document.all.spMaxRateWarn.style.display = "inline";
			}
			</cfif>

		}

		<!---Cases--->
		if((InputUOM == 1) && (InputRate1 != "") && (InputObj.disabled == false) && (InputObj.style.backgroundColor != "#dddddd"))
		{
			<Cfif len(trim(Min_Fixed_Case)) IS NOT 0 AND ! GetTemplateInfo.Ideal_Price>
			<!---Pounds Min--->
			if(InputRate1 < <cfoutput>#Min_Fixed_Case#</cfoutput>)
			{
				//propogateProperty(spanObj, "style.backgroundColor", "yellow", false);
				InputObj.style.backgroundColor = "yellow"
				FatalErr++
				document.all.spMinRateWarn.style.display = "inline";
			}
			</cfif>
			<Cfif len(trim(Max_Fixed_Case)) IS NOT 0 AND Max_Fixed_Case IS NOT 0 AND ! GetTemplateInfo.Ideal_Price>
			<!---Pounds Max--->
			if(InputRate1 > <cfoutput>#Max_Fixed_Case#</cfoutput>)
			{
				//propogateProperty(spanObj, "style.backgroundColor", "red", false);
				InputObj.style.backgroundColor = "red"
				FatalErr++
				document.all.spMaxRateWarn.style.display = "inline";
			}
			</cfif>
		}
		</cfif>
		if (!FatalErr)
			{
				InputObj.style.backgroundColor = "white"
				//propogateProperty(spanObj, "style.backgroundColor", "white", false);
			}

}
function verifyData(){
	var Errcount = 0;
	var FatalErr = 0;
	var srcObj = event.srcElement;
	var allowNull = "<CFOUTPUT>#AllowNullInComponent#</CFOUTPUT>";
	var thisForm = document.FixedComponents;

	/* Dev Note: Milan Start - (For Competitor Info) */
	var frmFixedComponents = document.forms['FixedComponents'].elements;
	var i=frmFixedComponents.length;
	var name_;
	var elem;
	var value_;
	var CompetitorInfoNotFilled = 0;
	var Competitor_Name_Filled = 1;
	var Competitor_Price_Filled = 1;
	var Competitor_Time_Frame_Filled = 1;
	var Competitor_Info_Complete = 1;
	var deleted_field = document.all.deleted.value; //D30231:Deleting Items off a Revised Program

	thisForm.DoNotRedirectToNextPage.value = 0;
	/* Make sure that all the competitor info is filled when the user offers a discount on the product */
		for (var i=0, il= frmFixedComponents.length; i<il; i++){

			 elem =frmFixedComponents[i]
			 name_ = elem.name;
			 value_ = elem.value;

				if(elem.type=='select-one' && name_.indexOf('Competitor_Name_ID') != -1)
				{
						compProdIDEndPosition = name_.indexOf('_Competitor_Name_ID');
						compProdID = name_.substring(0,compProdIDEndPosition);

						/* Is discount offered */
						CompetitorInfoNotFilled = eval('document.FixedComponents.'+compProdID+'_Check_Competitor_Info'+'.value');

						/* If discount is offered and Competitor name is not filled */
						if(value_ == 0 && CompetitorInfoNotFilled == 1 && deleted_field == 0) //D30231:Deleting Items off a Revised Program
						{
						 Competitor_Name_Filled = 0;
						}
				}

				if(elem.type=='text' && name_.indexOf('Competitor_Price') != -1)
				{
						/* If discount is offered (discount having a value greater than 0 on changing fixed price by the user) and competitor info is not filled */
						if(((value_ == '0.00') || (value_ == '')) && CompetitorInfoNotFilled == 1 && deleted_field == 0) //D30231:Deleting Items off a Revised Program
						{
						 Competitor_Price_Filled = 0;
						}
				}

				if(elem.type=='text' && name_.indexOf('Competitor_Time_Frame') != -1)
				{
						/* If discount is offered (discount having a value greater than 0 on changing fixed price by the user) and competitor time frame is not filled */
						if(value_ == '' && CompetitorInfoNotFilled == 1 && deleted_field == 0) //D30231:Deleting Items off a Revised Program
						{
						 Competitor_Time_Frame_Filled = 0;
						}
				}
		}
<!---D42287 :: Competitive Info not required by User Profile START--->
	<cfif Get_Profile_Settings.Competitive_Info_not_required EQ 0 AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1 AND GetTemplateInfo.Source_Required EQ 1>
		 if(Competitor_Name_Filled == 0 || Competitor_Price_Filled == 0 || Competitor_Time_Frame_Filled == 0)
		 {
		   alert("Please fill in the complete competitor info (Name,Price,Time Frame) for the highlighted rows");
		   Competitor_Info_Complete = 0;
		 }
	</cfif>
<!---D42287 :: Competitive Info not required by User Profile END--->
		/* Dev Note: Milan End - (For Competitor Info) */

<!--- 	<cfloop list="#form.Product_List#" index="prod">
	<cfloop from="1" to="#ListLen(fixed_comp_ids)#" index="compid">
		<cfset InputRate1 = buildFixeddocumentName(ListGetAt(fixed_comp_ids,compid), prod, compid, "_rate") >
		<cfset InputRate2 = buildFixedInputName(ListGetAt(fixed_comp_ids,compid), prod, compid, "_rate") >
		<cfset InputUOM   = buildFixeddocumentName(ListGetAt(fixed_comp_ids,compid), prod, compid, "_uom") >
		<cfoutput>
		var InputObj = eval("#buildSecondInputName(ListGetAt(fixed_comp_ids,compid), prod, compid, "_rate")#")
		</cfoutput>

		var spanObj = document.getElementById("SPAN_" + <cfoutput>'#InputRate2#'</cfoutput>);
     //  CHECKING FOR THE DELETED ITEM WILL NOT WORK IF THIS IS UNCOMMENTED
		// propogateProperty(spanObj, "style.backgroundColor", "white", false);

		if(<cfoutput>#InputRate1#</cfoutput> == "")
		{
			propogateProperty(spanObj, "style.backgroundColor", "#CC99FF", false);
			Errcount++;
		}
		<cfif ThereisMinorMax IS 1>
		<!---Pounds first--->
		if((<cfoutput>#InputUOM#</cfoutput> == 2) && (<cfoutput>#InputRate1#</cfoutput> != "") && (InputObj.disabled == false) && (InputObj.style.backgroundColor != "#dddddd") )
		{	<!--- alert(InputObj.disabled) --->
			<Cfif len(trim(Min_Fixed_Pound)) IS NOT 0>
			<!---Pounds Min--->
			if(<cfoutput>#InputRate1#</cfoutput> < <cfoutput>#Min_Fixed_Pound#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "yellow", false);
				FatalErr++
			}
			</cfif>

			<Cfif len(trim(Max_Fixed_Pound)) IS NOT 0 AND Max_Fixed_Pound IS NOT 0>
			<!---Pounds Max--->
			if(<cfoutput>#InputRate1#</cfoutput> > <cfoutput>#Max_Fixed_Pound#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "red", false);
				FatalErr++
			}
			</cfif>

		}

		<!---Cases--->
		if((<cfoutput>#InputUOM#</cfoutput> == 1) && (<cfoutput>#InputRate1#</cfoutput> != "") && (InputObj.disabled == false) && (InputObj.style.backgroundColor != "#dddddd"))
		{
			<Cfif len(trim(Min_Fixed_Case)) IS NOT 0>
			<!---Pounds Min--->
			if(<cfoutput>#InputRate1#</cfoutput> < <cfoutput>#Min_Fixed_Case#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "yellow", false);
				FatalErr++
			}
			</cfif>

			<Cfif len(trim(Max_Fixed_Case)) IS NOT 0 AND Max_Fixed_Case IS NOT 0>
			<!---Pounds Max--->
			if(<cfoutput>#InputRate1#</cfoutput> > <cfoutput>#Max_Fixed_Case#</cfoutput>)
			{
				propogateProperty(spanObj, "style.backgroundColor", "red", false);
				FatalErr++
			}
			</cfif>

		}

		</cfif>
	</cfloop>
	</cfloop> ---->

	/* If Competitor info exists, it should be filled up */
	if(Competitor_Info_Complete == 1)
	{
	if(Errcount == 0 || allowNull == 1)
	{
		var complistlen = <cfoutput>#ListLen(fixed_comp_ids)#</cfoutput>;
		var prodlenlist;
		if(document.FixedComponents.Product_List.value == "")
		{
			prodlenlist = 0;
		}
		else
		{
			prodlenlist = listLength(document.FixedComponents.Product_List.value,",");
		}

		if((complistlen > 0 && prodlenlist > 0) ||(complistlen == 0 && prodlenlist == 0) || complistlen > 0 && prodlenlist == 0)
		{
			{
			<!---
			paul said we just bring over what is in the settings panel, and it is always required if one is selected, so no pop-up to pick and choose business rules
			<cfif compBusRule.getComponentRules(fixed_comp_ids,1).recordcount gt 0>
			if(bApplyRule())
				{	NewWindow("apply_fixed_rule_popup.cfm?Contract_Main_ID=" + thisForm.Contract_Main_ID.value + "&fixedComponentList=" + thisForm.FixedComponentList.value, "productwindow", 800, 600, "yes", "yes");
					return;
				}
			</cfif>
			---->
				<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
					{
						document.all.deletedateexclusions.value = 1;
				</cfif>
						if (FatalErr > 0)
						{
							if (!confirm("Fields highlighted yellow are below the minimum value. Fields highlighted red are above the maximum. Press ok to continue anyway or cancel to correct this."))
							{
								return;
							}
						}
						var actionpage;
						actionpage = "contract_fixed_component_save.cfm";
						document.FixedComponents.action = actionpage;

						if (allowNull == 1 && Errcount != 0)
						{
							if (confirm("The highlighted fields have a value of zero. Click Cancel to view them. Click OK to accept them."))
							{
							/* disable top and bottom "save" links */
							$(".save").attr('disabled','disabled');
							disableButton("save_table", true, false);
							<cfif checkifprodmatchinfreighttable EQ "false">

							if (confirm("Freight rates are not applied. Are you sure you want to continue?"))
							{	/* disable top and bottom "save" links */
								$(".save").attr('disabled','disabled');
								disableButton("save_table", true, false);
								processingPopUpDisplay('div.customContainer');//D51575
								oTable.search('').draw();  //<!---bring back all rows including hidden ones to save--->
								document.FixedComponents.submit();
							}

							else
							{
								return false;
							</cfif>

							<cfif checkifprodmatchinfreighttable EQ "false">
							}
							</cfif>
							}
						}
						else
						{

							<cfif checkifprodmatchinfreighttable EQ "false">
							if (confirm("Freight rates are not applied. Are you sure you want to continue?"))
							{	/* disable top and bottom "save" links */
								$(".save").attr('disabled','disabled');
								disableButton("save_table", true, false);
								processingPopUpDisplay('div.customContainer');//D51575
								oTable.search('').draw();  //<!---bring back all rows including hidden ones to save--->
								document.FixedComponents.submit();
							}
							else
							{
								return false;
						</cfif>
							// disableButton("save_table", false, false);
							<cfif checkifprodmatchinfreighttable EQ "false">
							}
							</cfif>
						}
						/* disable top and bottom "save" links */
						$(".save").attr('disabled','disabled');
						disableButton("save_table", true, false);
						processingPopUpDisplay('div.customContainer');//D51575
						oTable.search('').draw();  //<!---bring back all rows including hidden ones to save--->
						document.FixedComponents.submit();
						<cfif donotallowaddproductsDE EQ 1>
						}
						else
						{
							return false;
						}
						</cfif>
					}
				}
				else
				{
					if(complistlen == 0)
					{
						alert("Please select at least one component to save");
					}
					else if(prodlenlist == 0)
					{
						alert("Please select at least one product to save");
					}
				}
			}
		}
	}
	function checkAllProd()
	{
		<cfloop list="#Form.Product_List#" index="product_id">
		<cfset prod_id = replace(product_id,"-","_", "ALL")>
		<cfset prod_check = "Prod_"&#prod_id#>
		if(document.all.prodCheck.checked)
		{
		document.all.<cfoutput>#prod_check#</cfoutput>.checked = true;
		}
		else
		{
		document.all.<cfoutput>#prod_check#</cfoutput>.checked = false;
		}
		</cfloop>
	}

	function applyrate()
	{
	var prodchecked = false;
	var compchecked = false;

	<cfset listcount = 0>
	<cfloop list="#fixed_comp_ids#" index="comp_name_id">
		<cfset comp_check = "Comp_"&#comp_name_id#&"_"&#listcount#>
		if(document.all.<cfoutput>#comp_check#</cfoutput>.checked)
		{
			compchecked = true;

		}
	<cfset listcount = listcount + 1>
	</cfloop>

	if((!prodchecked) && (!compchecked))
	{alert("Please select a component and products.")}
	else if(!prodchecked)
	{ alert("Please select products."); }
	else if(!compchecked)
	{ alert("Please select a component."); }
	else
	{
		<cfset compcount = 0>
	}
	}
//function to determine if rules have to be applied
function bApplyRule()
{ //return true; }

	var thisForm = document.FixedComponents;
	var rApplyRule = true; //false; was false...removed uom check (commented out below) as I am unsure of what it does mws
	var hasRules = true;
	var compIndx = thisForm.compLen.value;
	var prodIndx = thisForm.prodLen.value;
	//if rules already exist then give the option to modify
	if(hasRules && rApplyRule)
	{
		if (!confirm("Click OK to modify Business Rules. Click Cancel to continue."))
		{
			rApplyRule = false;
		}
	}

	return rApplyRule;

}//end bApplyRule function
</SCRIPT>

<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
<script>

function freightpopup(type,componentId,listNum,paidTo)
{
<cfset prodlen = ListLen(form.Product_List)>
<cfset complen = ListLen(form.FixedComponentList)>


	if (<cfoutput>#prodlen#</cfoutput> == 0 || <cfoutput>#complen#</cfoutput> == 0)
		{
			alert("You must select products and components before adding freight rates");
			return false;
		}
	else
		{
			if (!componentId == '')
			{
				document.FixedComponents.paidTo.value = paidTo;
				document.FixedComponents.component_id_value.value = componentId + '_' + listNum;
			}

			NewWindow("add_fixed_freight_rates.cfm?Formname=FixedComponents&paidTo="+paidTo, "freightwindow", 800, 600, "yes", "yes", true);
			document.FixedComponents.target = 'freightwindow';
			if(type == 0)
			{
			document.FixedComponents.action = 'add_fixed_freight_rates.cfm?Formname=FixedComponents&paidTo='+paidTo;
			document.all.FixedComponents.submit();
			document.FixedComponents.target = "";
			document.FixedComponents.action = 'contract_fixed_component_save.cfm';
			}
			else
			{
			document.FixedComponents.action = 'add_fixed_freight_rates.cfm?paidTo='+paidTo;
			document.all.FixedComponents.submit();
			document.FixedComponents.target = "";
			document.FixedComponents.action = 'Contract_Discount_Fixed_Component.cfm?CID=<cfoutput>#URL.CID#&EZTemplate=#url.EZTemplate#</cfoutput>'
			}
			}
}

function editfreightrates(prodid,compId,num,paidTo)
{
	if (!compId == '')
	{
			document.FixedComponents.paidTo.value = paidTo;
			document.FixedComponents.component_id_value.value = compId + '_' + num;
	}
	NewWindow("add_fixed_freight_rates.cfm?editproduct=1&product_id="+prodid+"&paidTo="+paidTo, "freightwindow", 800, 600, "yes", "yes", true);
	document.FixedComponents.target = 'freightwindow';
	document.FixedComponents.action = 'add_fixed_freight_rates.cfm?editproduct=1&product_id='+prodid+"&paidTo="+paidTo;
	document.all.FixedComponents.submit();
	document.FixedComponents.target = "";
	document.FixedComponents.action = 'Contract_Discount_Fixed_Component.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>';
}
</script>

</cfif>
<cfset fixedData = fixedCompObj.getFixedData(form.CONTRACT_MAIN_ID,FORM.Product_List,fixed_comp_ids)>
<CFOUTPUT><FORM ACTION="Contract_Discount_Fixed_Component.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#" METHOD="post" NAME="FixedComponents" ID="FixedComponents" style="display:inline"></CFOUTPUT>
<FIELDSET class="clBox" STYLE="padding:10px; width: 700px; border: 1px solid Blue;  <cfif form.bFromMargin>display:none;<cfelse>display:table;</cfif>">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#Application.FixedPriceLabel#</cfoutput><!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth END --->

	<cfif appSettings.getShow_Fixed_Freight()>
		<cfset TemplateInfo = templatemanager.getProgramTemplate(FORM.Contract_Main_ID)>
		(<cfif TemplateInfo.Fixed_Type IS 1>Variable<cfelse>Guaranteed</cfif>)
		<span style="font: normal 12px sans-serif; color: black;"><cfif len(trim(#TemplateInfo.Fixed_Type_Explanation#)) GT 0> - </cfif><cfoutput>#TemplateInfo.Fixed_Type_Explanation#</cfoutput></span>
	</cfif>
	</LEGEND>
 <cfscript>
	GetFixedComponentId = fixedCompObj.getActive(request.AccessStructure.Profiles_ID);
  </cfscript>
<cfsilent>
<cfset arAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />
<!------ Operating Group ----->
<cfset componentsUnderOperatingGroupLevel2 = "" />
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=CSL_Contract_Main_ID) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 1) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
	<cfset bTemplateLevelComponentFilter = 0 />
</cfif>
<!------ Operating Group ----->
<cfif bTemplateLevelComponentFilter>
	<!--- get a list of comps to filter based on template --->
	<cfset qComponents = templateManager.getAllTemplateDiscountComponents(templateId=GetSettings.ProgramControl_Panel_Options_ID, discountTypeList=1, returnSelected=1, fixedprice_freight=GetSettings.Discount_Fixed_Prices_Freight) />
	<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
</cfif>

<cfset arAllowList[ArrayLen(arAllowList) + 1] = ValueList(GetFixedComponentId.Program_Fixed_Component_Name_Id) />

<cfset getFixedComponentNames = fixedCompObj.getProgramFixedComponentNames(
		arAllowList = arAllowList,
		Discount_Fixed_Prices_Freight = getsettings.Discount_Fixed_Prices_Freight,
		EzButton_Disable = EzButton_Disable,
		EZ_Fixed_Comp_Ids = EZ_Fixed_Comp_Ids,
		programId=CSL_Contract_Main_ID
		) />
</cfsilent>

<cfif Display_Basis_Treatment_Code>
	<cfset useLakebaseForqComponentNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getfixedcomponentnames")>
<cfif useLakebaseForqComponentNames>
	<cftry>
		<cfset qComponentNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getfixedcomponentnames", {
				"select" = "program_fixed_component_name_id component_name_id,allowance_code_id component_allowance_code_id"
			}), "program_fixed_component_name_id component_name_id,allowance_code_id component_allowance_code_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqComponentNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqComponentNames>
<cfquery name="qComponentNames" dbtype="query">
		SELECT	Program_Fixed_Component_Name_ID Component_Name_ID, Allowance_Code_ID Component_Allowance_Code_ID
		FROM	GetFixedComponentNames
	</cfquery>
</cfif>
	<cfinclude template="Contract_Basis_Tratment_Code.cfm" />
</cfif>

<cfset colsAtComponentSection = 5 />
<cfif appSettings.getClaims_at_Comp_Level() AND GetPaymentTypesforTemplate.Recordcount GT 0>
	<cfset colsAtComponentSection = colsAtComponentSection + 1 />
</cfif>
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfset colsAtComponentSection = colsAtComponentSection + 1 />
</cfif>

<cfset dislayCreateProductRateList = 1>

<cfif GetTemplateInfo.EZButton_On >
	<cfif GetTemplateInfo.Discount_Rebate_Max_Rate_On AND (GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates OR Get_Profile_Settings.EzButton_Approve_Beyond_MaxRate)>
		<cfset dislayCreateProductRateList = 1>
	<cfelse>
		<cfset dislayCreateProductRateList = 0>
	</cfif>
</cfif>

<table WIDTH="1060" border="0" cellpadding="3" cellspacing="0">
<tr>
<cfoutput>
	<td COLSPAN="#colsAtComponentSection#"><b>Step 1:</b>&nbsp;
	<cfif dislayCreateProductRateList>
		<a onClick="javascript: return showCreateProdcutListWindow();" style="cursor:pointer">#application.util.string.actionLinkFormat("create product / rate list")#</a>
	</cfif>
	 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
		#application.util.string.actionLinkFormat("add products")#
	<cfelse>
		<cfif appSettings.getFlexProductSearch()>
			<a onClick="javascript: return showProductSearchWindow();" style="cursor:pointer;">#application.util.string.actionLinkFormat("add products")#</a>
		<cfelse>
			<a onClick="javascript: return showProductSearchWindow_old();" style="cursor:pointer;">#application.util.string.actionLinkFormat("add products")#</a>
		</cfif>
	</cfif>
	</td>
</cfoutput>
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<td>&nbsp;</td>
</cfif>
	<td colspan="<cfoutput>#multiassignmentCols#</cfoutput>" rowspan="100%">
	<cfif not bAutoAddComponent>
		<cfdiv bind="url:component_information.cfm?Component_Name_ID={Program_Fixed_Component_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=1&ClaimMechanics=#CSLGetContractInfo.ClaimMechanics#&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&EligibleRecordCount=#GetPaymentTypesforTemplate.Recordcount#&programId=#FORM.Contract_Main_ID#" ID="compInfo" />
	</cfif>
	</td>
</tr>
<cfif not bAutoAddComponent>
<tr>
	<td COLSPAN="20">&nbsp;</td>
</tr>
<tr>
<cfoutput>
	<td COLSPAN="#colsAtComponentSection#" STYLE="border-bottom:solid 1px blue;">
		<b>Step 2: &nbsp;&nbsp;&nbsp;Add Component Information</b>
	</td>
</cfoutput>
</tr>
<tr BGCOLOR="eeeeee">
	<td valign="top">Component Name</td>
	<td valign="top">Default Price</td>
	<td valign="top">UOM</td>
	<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1')>
		<td>% of List Price</td>
		<td>From Price List</td>
	</cfif>
	<td valign="top">Paid To</td>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
	<td>Select Payment Cycle</td>
	</cfif>
</tr>
	<!--- This value gets set in the file Claim_Mech_Info but needs to be on this page to prevent javascript errors in case they save before selecting a component. --->
	<input type="hidden" name="Auto_Pay_Status" value="">
	<input type="hidden" name="Vendor_Selection" value="true">
 <cfoutput><input type="hidden" name="bAllowAddComp" value="#bAllowAddComp#" /></cfoutput>
<tr>
	<td valign="top">
		<cfoutput>
			  <!--- style="width:220px" --->
              <select name="Program_Fixed_Component_Name_ID"
			  	<cfif Display_Basis_Treatment_Code>onChange="loadDefaultBasisTreatmentCodeForComponentName(this.value);enableDisableRate()"<cfelse>onChange="enableDisableRate()"</cfif>>
			  	<option value="-1" selected>Select #Application.FixedPriceLabel# Component</option><!--- 29856	labels for Fixed Price, Rebate, Lump Sum, Growth END --->
                <cfloop query="GetFixedComponentNames">
                  <option value="#Program_Fixed_Component_Name_ID#" <cfif GetFixedComponentNames.recordcount EQ 1>selected</cfif>>
				  #Program_Fixed_Component_Name#
					  <cfif application.returned_customer_setting.external_id_on EQ 1>
						<cfif Len(External_ID) GT 0>
						  (#External_ID#)
						</cfif>
					  </cfif>
					  <cfif len(trim(Allowance_Code_Number))> - (#Allowance_Code_Number#)</cfif>
                  </option>
                </cfloop>
              </select>
		<input type="hidden" name="Program_Fixed_Component_Name_ID_Selection_Validated" value="0">
        </cfoutput>
	</td>
	<td valign="top">
		<input name="rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4)"/ <cfif EzButton_Disable EQ 1>disabled<cfelse> value="0.0000"</cfif>>
	</td>
	<td valign="top">
			<cfset disabled = 0>
		<!--- COMMENTED OUT FOR LABEL D45240
			<cfif EzButton_Disable EQ 1>
				<cfset disabled = 1>
			</cfif>
		--->

		<cf_uom_dropdown
			program_id				=	"#FORM.Contract_Main_ID#"
			company_main_id			=	""
			default_option_on		=	"0"
			default_option_text		=	""
			default_option_value	=	""
			dropdown_name			=	"uom"
			dropdown_id             =   "uom"
			option_text_abbreviated	=	"1"
			plural_uom_display		=	""
			product_type_id			=	"1"
			program_template_id		=	""
			selected_uom_id			=	""
			text_before_tag_close	=	""
			uom_id_exclusion_list	=	"#uom_id_exclusion_list#"
			uom_id_inclusion_list	=	""
			setDefaultSelected		= 	1
			disabled				= 	"#disabled#"
		>
	</td>
	<cfoutput>
		<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1')>
			<td valign="top"><input name="txtPercentage" type="text" value="" size="4" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,1)"></td>
			<td valign="top"><input name="txtPriceListID " type="text" value="#GetSettings.Price_list_ID#" size="5" disabled></td>
		</cfif>
		<input type="hidden" name="currentTxtPercentage" value="#FORM.currentTxtPercentage#">
	</cfoutput>

	<td valign="top" nowrap="nowrap">
		<!--- "Paid to" radio buttons --->
		<cfdiv bind="url:component_paid_to.cfm?Component_Name_ID={Program_Fixed_Component_Name_ID}&ModifyDeletedPrograms=#ModifyDeletedPrograms#&Discount_Type_ID=1&ContractMainID=#FORM.Contract_Main_ID#&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#" bindOnLoad="true" ID="paidToInfo" />
			<!--- Note: "GetPaymentPaidToTypes" is populated based on template, component and discount type on "component_paid_to.cfm".
			On this page, the only reason "GetPaymentPaidToTypes" still exists is because it is being used below for "form.paidToList".
			--->
			<cfscript>
				GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(CSLGetContractInfo.ProgramType_ID,1,0);
			</cfscript>

			<cfset form.paidToList = ValueList(GetPaymentPaidToTypes.Payment_Paid_To_ID) />
	</td>
<cfif appSettings.getPaymentCycleAtDiscountType()>
	<td valign="top">
	<cfparam name="FORM.PaymentCycle" 	default="">
		<cf_payment_cycle_selection
		Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
		Program_ID = "#FORM.Contract_Main_ID#"
		discount_Type_ID = "1"
		Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
		>
	</td>
</cfif>
</TR>
<!---TSF - Label 11426: Move Treatment Code and Basis Code onto new row--->
<cfif Display_Basis_Treatment_Code>
<tr valign="top">
	<td COLSPAN="<cfoutput>#colsAtComponentSection#</cfoutput>">
		<table border="0" cellpadding="2" cellspacing="0">
			<tr BGCOLOR="eeeeee">
				<td>Treatment Code</td>
				<td>Basis Code</td>
			</tr>
			<tr>
				<td>
					<select name="Treatment_Code" style="width:140px" onChange="loadBasisCodes(this.value);">
						<option value="0">Select Treatment Code...</option>
						<cfloop query="qGetTreatmentCodes">
						<cfoutput><option value="#Treatment_Code_Master_ID#">#Treatment_Code_Desc#</option></cfoutput>
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
		<cfoutput>
		<td colspan="20" valign="top">
			<b>Step 3:</b>&nbsp;&nbsp;&nbsp;
			<cfif appSettings.getDisableAddingComponentsOnRevision() AND bIsContractARevision>
				#application.util.string.actionLinkFormat2('include this fixed component')#
			<cfelse>
				<a onClick="javascript:submitForm();" STYLE="cursor: pointer;">#application.util.string.actionLinkFormat2('include this fixed component')#</a>
			</cfif>
		</td>
		</cfoutput>
	</tr>
</cfif>
</table>
<cfoutput>
	<cfloop query="GetFixedComponentNames">
		<input type="hidden" name="Fixed_GL_Account_ID_#Program_Fixed_Component_Name_ID#" value="#GL_Account_ID#">
		<input type="hidden" name="Fixed_Fixed_Price_Type_#Program_Fixed_Component_Name_ID#" value="#Fixed_Price_Type#">
		<input type="hidden" name="Formula_Pricing_#Program_Fixed_Component_Name_ID#" value="#Formula_Pricing#">

		<!--- Dev Note(79237) - Handle for 2nd components --->
		<cfif GetFixedComponentNames.Second_Component_Name_ID>
			<input type="hidden" name="Fixed_GL_Account_ID_#GetFixedComponentNames.Second_Component_Name_ID#" value="#GL_Account_ID#">
			<input type="hidden" name="Fixed_Fixed_Price_Type_#GetFixedComponentNames.Second_Component_Name_ID#" value="#Fixed_Price_Type#">
			<input type="hidden" name="Formula_Pricing_#GetFixedComponentNames.Second_Component_Name_ID#" value="#Formula_Pricing#">
		</cfif>
	</cfloop>

</cfoutput>
</FIELDSET>

<!--- D51575 ::"Please Wait" Indicator    8.0 Release START --->
<div class="customContainer" style="display:none;width:800px;"></div>
<!--- D51575 :: "Please Wait" Indicator    8.0 Release END --->

<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release START--->
<br>
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<style>
	.dataTables_wrapper{
		width:1100px;
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
		background-color:#FFF8DC;
		font-size:10px;
		margin-left:-220px;
		margin-top: -20px;
	}
	.header{
		text-align: left;
	}
	.save{
		clear:both;
		padding-bottom:5px;
	}
	.dper {width:55px;}
	.disc {width:75px;}
	/* Dev Note:71380- When a user views the application in French, then the length of the text
	of a few entries on the Left NAV can be long, which causes issues like "not being able to delete products(s)"
	and perhaps other issues as well. Added a margin so that the text does not overlap.
	*/
	.clBox,.save,.top_header,#save_table{margin-left:15px;}
	.datagrid,.dataTables_filter{margin-left:15px !important;}
</style>

<cfif getFixedComponents.Recordcount GT 0>
	<cfoutput>

	<cfset j = 0>
	<!--- Fixed component Header Loop Start--->
	<cfset compNamesList = ''>
	<cfloop list="#form.fixedcomponentlist#" index="i">
		<cfset FixedCompID = getComponentNameId(i) />
		<cfsavecontent variable="Comp_#FixedCompID#"> 
			<cfset comp_id_start = Find("_",i)>
			<cfset comp_id = getComponentNameId(i) />
			<cfset paid_to = getComponentPaidTo(i)>
			<cfset treatment_code = getComponentTreatmentCode(i) />
			<cfset basis_code = getComponentBasisCode(i) />
			<cfset GL_Account_ID = getGL_Account_ID(i) />
			<cfset Claim_Mechanics = getClaimMechanics(i) />
			<cfset Vendor_Master_ID = getVendor_Master_ID(i) />
			<cfset PaymentCycle = getPaymentCycle(i) />
			<cfset VendorSelection = getVendorSelection(i) />
			<cfset Payee_Selection = getPayeeSelection(i) />
			<cfset IsSecondComponent = getIsSecondComponent(i) />

			<CFQUERY NAME="getFixedComponentName" datasource="#application.datasource#">
				SELECT			Program_Fixed_Component_Name.Program_Fixed_Component_Name,
									Program_Fixed_Component_Name_Id,
									ISNULL(Allowance_Code.Allowance_Code_Number, 0) AS Allowance_Code_Number,
									Program_Fixed_Component_Name.fixed_price_type,
									Formula_Pricing,Include_Second_Component,Second_Component_Name_ID
				FROM 			Program_Fixed_Component_Name
				LEFT JOIN 	Allowance_Code
				ON				Allowance_Code.Allowance_Code_ID = Program_Fixed_Component_Name.Allowance_Code_ID
				AND 			Allowance_Code.Deleted = 0
				WHERE 			Program_Fixed_Component_Name_Id = #comp_id#
				AND 			Program_Fixed_Component_Name.DELETED = 0
			</CFQUERY>
			<cfset compNamesList = listAppend(compNamesList, REPLACE(getFixedComponentName.Program_Fixed_Component_Name,',','','ALL'))>
			<cfset "qFixedComponentNameInfo_#getFixedComponentName.Program_Fixed_Component_Name_Id#" = getFixedComponentName />

			<!--- D11147 BJF Component product restrictions 	Set product restriction query here so there are fewer iterations	--->
			<cfif appsettings.getComponent_Product_Restrictions_On()>
				<cfset useLakebaseForQuery_#getFixedComponentName_Program_Fixed_Component_Name_Id# = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_products_restricted")>
<cfif useLakebaseForQuery_#getFixedComponentName_Program_Fixed_Component_Name_Id#>
	<cftry>
		<cfset Query_#getFixedComponentName.Program_Fixed_Component_Name_Id# = application.oLakebase.toQuery(
			application.oLakebase.selectRows("component_products_restricted", {
				"discount_type_id" = "eq.1 --Fixed",
				"component_id" = "eq.#comp_id#",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForQuery_#getFixedComponentName_Program_Fixed_Component_Name_Id# = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForQuery_#getFixedComponentName_Program_Fixed_Component_Name_Id#>
<cfquery name="Query_#getFixedComponentName.Program_Fixed_Component_Name_Id#" datasource="#application.datasource#">
					SELECT 		Product_ID
					FROM 		Component_Products_Restricted
					WHERE 		Discount_Type_ID = 1 --Fixed
					AND 		Component_ID = '#comp_id#'
				</cfquery>
</cfif>
			</cfif>

			<cfset qGetCompRuleUoms = compBusRule.getCompRuleUoms(#comp_id#)>
				<cfif variables.IsSecondComponent eq 0>
					<input name="Comp_#comp_id#_#j#" type="checkbox" value="Comp_#comp_id#_#j#">
					<cfif not form.bFromMargin>
						<cfif getFixedComponentName.Include_Second_Component eq 1 and getFixedComponentName.Second_Component_Name_ID GT 0>
							<!---  Dev Note - (79237) - For components which have a second component(child component), pass the "Second_Component_Name_ID" also to the "verifyDelete" function --->
							<A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#getFixedComponentName.Program_Fixed_Component_Name_Id#', '#replace(getFixedComponentName.Program_Fixed_Component_Name, "'", "\'")#',#j#,'#paid_to#','#getFixedComponentName.Second_Component_Name_ID#')">
						<cfelse>
							<A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#getFixedComponentName.Program_Fixed_Component_Name_Id#', '#replace(getFixedComponentName.Program_Fixed_Component_Name, "'", "\'")#',#j#,'#paid_to#')">
						</cfif>
						<img src="/Images/scissor.gif"  title="delete this component" border="0">
						</A>
					</cfif>
				</cfif>
				<!------ Display additional info ----->
				<cfset additionalInfo = "" />
				<cfset HelpHeight = 16>
				<cfset HelpWidth = 150>
				<cfsavecontent variable="additionalInfo">#additionalInfo##getFixedComponentName.Program_Fixed_Component_Name#
				<br>Paid To: #templateManager.getPaymentPaidToTypeDesc(paidToID=paid_to, paidToDesc="")#</cfsavecontent>
				<cfif appSettings.getUseFixedPriceType() EQ 1>
					<cfsavecontent variable="additionalInfo">
						#additionalInfo#
						<!--- Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  (What  I did: added ListLast to display numbers after "_")--->
						<br>Price Bracket:  #ListLast(Form.priceListID, "_")#
						<!--- End Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  --->
						<sup <cfif form.priceBracketUpdate eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>>*	</sup>
					</cfsavecontent>
				</cfif>
				<cfif Display_Basis_Treatment_Code>
					<cfset HelpHeight = HelpHeight + 16>
					<cfset HelpWidth = 250>
					<cfsavecontent variable="additionalInfo">
						#additionalInfo#
						<br>Treatment Code: #TreatmentCodeManager.getTreatmentCodeDesc(treatment_code)#
						<br>Basis Code: #BasisCodeManager.getBasicCodeDesc(basis_code)#
					</cfsavecontent>
				</cfif>
				<!--- Dev Note:(73491). Added "j = j+1" here. Earlier, it was below, which made "j" to be 0 and caused an issue in edit component popup (CF indexes start from 1) --->
				<cfset j = j+1>
				<cfif not form.bFromMargin>
					<a onClick="JavaScript: openPopup('ezprogram_editcomponent.cfm?download=2&programid=#GetContractInfo.contract_main_id#&copNameIndx=#j#&discounttypeid=1&PaidTo=#paid_to#&GL_Account_ID=#GL_Account_ID#&ProgramType_ID=#CSLGetContractInfo.ProgramType_ID#&Formname=FixedComponents&compid=#getFixedComponentName.Program_Fixed_Component_Name_Id#&Claim_Mechanics=#Claim_Mechanics#&Vendor_Master_ID=#Vendor_Master_ID#&PaymentCycle=#PaymentCycle#&FixedComponentList=#FixedComponentList#&ThisFixedComponent=#i#&Is_A_Revision=#CSLGetContractInfo.Is_a_Revision#&VendorSelection=#VendorSelection#&Payee_Selection=#Payee_Selection#&priceListID=#form.priceListID#&Business_Segment_ID=#businessSegmentID#&IsSecondComponent=#variables.IsSecondComponent#', 440, 700)" title="#getFixedComponentName.Program_Fixed_Component_Name#" STYLE="cursor: pointer;">
						#application.util.string.actionLinkFormat("edit")#
					</a>
				</cfif>
				<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1 and not form.bFromMargin>
					<a onClick="javascript:freightpopup(1,'#getFixedComponentName.Program_Fixed_Component_Name_Id#','#j#','#paid_to#');" STYLE="cursor: pointer;">
						#application.util.string.actionLinkFormat("add/edit freight rates")#
					</a>
				</cfif>
				<br>
				<cfif Len(additionalInfo)>
					<cfif form.bFromMargin>
						<cfset structDelete(variables, "SmallHelpScriptAdded", "True")>
					</cfif>
					<div class="on-hover-content" style="display:none;">
						#additionalInfo#
					</div>
				</cfif>
				<cfif getFixedComponentName.Formula_Pricing eq 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 0>
					<a onClick="JavaScript: openPopup('/Common_Files/contracts/Formula/Formula_Display.cfm?Program_Id=#GetContractInfo.contract_main_id#', 800, 800)" title="Edit Formula #getFixedComponentName.Program_Fixed_Component_Name#" STYLE="cursor: pointer;">
						#application.util.string.actionLinkFormat("edit formula rules")#
					</a>
				</cfif>
			</cfsavecontent>
	</cfloop>

</cfoutput>
</cfif>

<table id="datagrid" class="datagrid">
	<thead>
<cfoutput>
<!--- 114617 :: Ideal Price START --->
<cfif GetTemplateInfo.Ideal_Price>
	<tr>
		<th  style="border: 2px solid ##808080;">&nbsp;</th>
		<th  style="border: 2px solid ##808080;">&nbsp;</th>
		<th  style="border: 2px solid ##808080;">&nbsp;</th>
		<th colspan="4" style="text-align: center;border: 2px solid ##808080;">Ideal Price</th>
	<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
		<th colspan="3" style="text-align: center;border: 2px solid ##808080;">Base Sales</th>
	</cfif>
	<cfif getFixedComponents.Recordcount GT 0>
		<th colspan="6" style="border: 2px solid ##808080;">
			#evaluate('Comp_'&'#getFixedComponents.Program_Fixed_Component_Name_ID#')#
		</th>
	</cfif>
	</tr>
</cfif>
<!--- 114617 :: Ideal Price END --->
		<tr>
			<th class="header" style="width:48px;border: 2px solid ##808080;">
				<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2) and not form.bFromMargin>
					<img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onClick="deleteAll('Prod_');" style="cursor: pointer;">
				</cfif>
				<input name="prodCheck" type="checkbox" onClick="checkAllProd()" checked>
			</th>
			<th class="header" style="border: 2px solid ##808080;">
				<cfif (application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string)
						AND (application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1)>
						#trim(application.returned_customer_setting.upc_label)#<br>
				</cfif>
				<cfif application.appSettingsget.get_Setting('Display_Item_No') eq '1'>#trim(application.returned_customer_setting.item_label)# ##</cfif>
			</th>
			<th class="header" style="border: 2px solid ##808080;">
				Description
			</th>
				<!--- 114617 :: Ideal Price START --->
				<cfif GetTemplateInfo.Ideal_Price>
					<th class="header" style="border: 2px solid ##808080;">Volume</th>
					<th class="header" style="border: 2px solid ##808080;">Ideal Price</th>
					<th class="header" style="border: 2px solid ##808080;">Diff $</th>
					<th class="header" style="border: 2px solid ##808080;">Diff %</th>
				</cfif>
				<!--- 114617 :: Ideal Price END --->
			<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
			<th class="header" style="border: 2px solid ##808080;">
				#appSettings.getBaseSaleLabel()#
			</th>
			</cfif>

		<cfif getFixedComponents.Recordcount GT 0>

				<cfset j = 0>
				<!--- Fixed component Header Loop Start--->
				<cfloop list="#form.fixedcomponentlist#" index="i">
					<cfset j = j + 1>
					<!--- D45016 :: Restrict access at component level for all discount types START--->
					<cfif ! listfind(valuelist(getAllFixedComponentsAccess.Program_Fixed_Component_Name_ID),comp_id)>
						<cfset display =''/>
						<cfelse>
						<cfset display = 'none'/>
					</cfif>
					<!--- D45016 :: Restrict access at component level for all discount types END--->

					<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
						<th class="header disc" style="display:#display#; border: 2px solid ##808080;">Discount</th>
						<th class="header dper" style="display:#display#; border: 2px solid ##808080;">Disc%</th>
					</cfif>
					<th style="border: 2px solid ##808080;">
						<cfif not GetTemplateInfo.Ideal_Price>
							#evaluate('Comp_'&'#fixedData.aComp[j].compNameId#')#	
						</cfif>
						<span class="addinfo" style="cursor:pointer;font-size:11px">
							<cfif len(listGetAt(compNamesList, j)) LTE 25>
								#listGetAt(compNamesList, j)#
							<cfelse>
									#replace(listGetAt(compNamesList, j),' ','<br>', 'first')#
							</cfif>
						</span>

						<cfif ArrayLen(fixedData.aComp) GTE j>
							<input type="hidden" name="compNameId_#j#" value="#fixedData.aComp[j].compNameId#" />
							<input type="hidden" name="compHasRules_#j#" value="#fixedData.aComp[j].HasRules#" />
							<input type="hidden" name="compRulesReq_#j#" value="#fixedData.aComp[j].RulesRequired#" />
							<input type="hidden" name="compPaidTo_#j#" value="#paid_to#" />
							<input type="hidden" name="GL_Account_ID_#j#" value="#GL_Account_ID#" />
							<input type="hidden" name="Claim_Mechanics_#j#" value="#Claim_Mechanics#" />
							<input type="hidden" name="Vendor_Master_ID_#j#" value="#Vendor_Master_ID#" />
							<input type="hidden" name="PaymentCycle_#j#" value="#PaymentCycle#">
							<input type="hidden" name="VendorSelection_#j#" value="#VendorSelection#">
							<input type="hidden" name="Payee_Selection_#j#" value="#Payee_Selection#">
							<input type="hidden" name="IsSecondComponent_#j#" value="#IsSecondComponent#">
						 </cfif>
						<cfset "Form.uomsToCheck_#j#" = "" />
						<input type="hidden" name="lCompRuleUoms_#j#" value="#ValueList(qGetCompRuleUoms.Unit_Of_Measure_ID)#" />
					</th>
					<!--- If the fixed price type is "Deviated price" (Meets Competition) OR Combination (Blended), show the competitor info --->
					<cfif appSettings.getUseFixedPriceType() AND (getFixedComponentName.fixed_price_type eq 1 OR getFixedComponentName.fixed_price_type eq 3) AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1>
							<th class="header" style="display:#display#;border: 2px solid ##808080;">&nbsp;&nbsp;&nbsp;&nbsp; Comp Name</th>
							<th class="header" style="display:#display#;border: 2px solid ##808080;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dist Cost</th>
							<th class="header" style="display:#display#;border: 2px solid ##808080;">Time Frame</th>
					<cfelse>
						<th class="header" style="display:none;border: 2px solid ##808080;">&nbsp;</th>
					</cfif>
					<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
						<cfloop list="#form.paidToList#" index="paidList">
							<cfset freightApplied = fixedCompObj.FREIGHTRATESAPPLIED(FORM.Contract_Main_ID,0,0) />
						</cfloop>
						<cfif freightApplied EQ 1>
							<th class="header" style="display:#display#;border: 2px solid ##808080;"></th>
						</cfif>
					</cfif>
				</cfloop>
			<!--- Fixed component Header Loop END--->
		</cfif>
		<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
			<th class="header" style="border: 2px solid ##808080;">Similar<br />Product</th>
		</cfif>
		</tr>
	</cfoutput>
	</thead>

	<tbody>
		<cfset theList = ""/>
		<cfset rowcount = 0>
		<cfif TheQuery.recordcount GT 0>
			<cfoutput query="TheQuery" group="BSA_Foodservice_Items_Master_ID">
				<cfset rowcount = rowcount + 1>
				<cfsilent>
					<cfif (GetSettings.Include_Competitive_Data_Tracking EQ 1 and GetSettings.display_basesales_Competitive_Data EQ 1) OR (appsettings.getshowfixedpriceadditionalfields() EQ 1)><!--- 1st IF START--->
						<cfif appSettings.getBidRequestUsePriceByDate() EQ 1><!---- appSettings.getBidRequestUsePriceByDate() START --->
							<cfif bIsIndirectBid>
								<cfset priceListId = bidRequestProdMan.getPriceListId("GIL98") />
							<cfelse>
								<cfset priceListId = bidRequestProdMan.getPriceListId() />
							</cfif>
							<cfparam name="priceIdNull" default="no" />
							<cfif trim(priceListId) eq "">
								<cfset priceIdNull = "yes" />
							</cfif>
							<cfset stPrice = bidRequestProdMan.getPrice(BSA_Foodservice_Items_Master_ID, priceListId, priceIdNull, CSLGetContractInfo.contract_start_date, bIsIndirectBid) />
							<cfset variables.FOB_CS_Price = stPrice.CSPrice />
							<cfset variables.FOB_LB_Price = stPrice.LBPrice />
							<cfset variables.DEL_CS_Price = stPrice.CSDELPrice />
							<cfset variables.DEL_LB_Price = stPrice.LBDELPrice />
						<cfelseif appSettings.getUseFixedPriceType() EQ 1>
							<!--- D30357:Today's Price Wrong on Revision History START--->
							<cfif len(TheQuery.BASE_SALES_CS)>
								<cfset variables.FOB_CS_Price = #TheQuery.Base_Sales_CS#>
								<cfset variables.FOB_LB_Price = #TheQuery.Base_Sales_CS#/#TheQuery.NET_WEIGHT#>
								<cfset variables.DEL_CS_Price = #TheQuery.Base_Sales_CS#>
								<cfset variables.DEl_LB_Price = #TheQuery.Base_Sales_CS#/#TheQuery.NET_WEIGHT#>
							<cfelse>
								<cfset getItemCustPrice = bidRequestProdMan.getItemCustPriceForFP(BSA_Foodservice_Items_Master_ID,CSLGetContractInfo.contract_main_id,form.priceListID) />
								<cfset variables.FOB_CS_Price = getItemCustPrice.FOB_CS_Price>
								<cfset variables.FOB_LB_Price = getItemCustPrice.FOB_LB_Price>
								<cfset variables.DEL_CS_Price = getItemCustPrice.DEL_CS_Price>
								<cfset variables.DEl_LB_Price = getItemCustPrice.DEL_LB_Price>
							</cfif>
							<!--- D30357:Today's Price Wrong on Revision History END--->
						<cfelse>
							<cfif appSettings.getUseItemCustPrice() EQ 1>
								<cfset getItemCustPrice = bidRequestProdMan.getItemCustPrice(BSA_Foodservice_Items_Master_ID,CSLGetContractInfo.contract_main_id) />
								<cfset variables.FOB_CS_Price = getItemCustPrice.FOB_CS_Price>
								<cfset variables.FOB_LB_Price = getItemCustPrice.FOB_LB_Price>
								<cfset variables.DEL_CS_Price = getItemCustPrice.DEL_CS_Price>
								<cfset variables.DEl_LB_Price = getItemCustPrice.DEL_LB_Price>
							<cfelse>
								<cfset variables.FOB_CS_Price = TheQuery.FOB_CS_Price>
								<cfset variables.FOB_LB_Price = TheQuery.FOB_LB_Price>
								<cfset variables.DEL_CS_Price = TheQuery.DEL_CS_Price>
								<cfset variables.DEl_LB_Price = TheQuery.DEl_LB_Price>
							</cfif>
						</cfif><!---- appSettings.getBidRequestUsePriceByDate() END --->
						<cfif not isNumeric(variables.FOB_CS_Price)>
							<cfset variables.FOB_CS_Price = 0 />
						</cfif>
						<cfif not isNumeric(variables.FOB_LB_Price)>
							<cfset variables.FOB_LB_Price = 0 />
						</cfif>
					</cfif><!--- 1st IF START--->
					<cfset request.menuId = 6 />
					<cfset request.theMOId = TheQuery.BSA_Foodservice_Items_Master_ID />
					<cfset FieldNameEnd = replace(TheQuery.BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
					<cfset reproduct_id = replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
					<cfset theList = ListAppend(theList, reproduct_id) />
				</cfsilent>
				<tr BGCOLOR="#IIf(rowcount Mod 2, DE('ffffff'), DE('C6FFC6'))#" ORIGINALBGCOLOR="#IIf(rowcount Mod 2, DE('ffffff'), DE('C6FFC6'))#" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0" ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onMouseOut="menuID=0;doNotRelocate=0;" style="cursor: help;">
				<td>
					<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0)
							AND NOT form.bFromMargin>
							<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" title="click here to delete this product" border="0" onClick="deleteThisFixedPrice('#FieldNameEnd#', '#TheQuery.BSA_FOODSERVICE_ITEMS_MASTER_ID#')" style="cursor: pointer;">
					</cfif>
					<input name="Prod_#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" id="Prod_#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" type="checkbox" value="#replace(Thequery.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" tabindex="-1" checked>
				</td>
				<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
					<td>
						<cfif (application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string)
								AND (application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1)>
							#trim(TheQuery.UPC)#<br>
						</cfif>
							#trim(TheQuery.Item)#
						<input type="hidden" name="base_sales_cs_#reproduct_id#" value="#TheQuery.Base_Sales_CS#"/>
					</td>
				<!--- Tim Ford - 03/14/2016: WR 57765 - Adding else statement do display Item if the getshowfixedpriceadditionalfields() application setting is off --->
				<cfelse>
					<td>#trim(TheQuery.Item)#</td>
					<input type="hidden" name="base_sales_cs_#reproduct_id#" value="#TheQuery.Base_Sales_CS#"/>

				</cfif>
				<td>#TheQuery.Description#
					<input type="hidden" name="net_weight_#reproduct_id#" value="#TheQuery.Net_Weight#" id="net_weight_#reproduct_id#"/>
					<input type="hidden" name="case_count_#reproduct_id#" value="#TheQuery.Case_Count#"/>
					<input type="hidden" name="Sleeve_count_#reproduct_id#" value="#TheQuery.Sleeve_Count#"/>
					<input type="hidden" name="Inventory_UM_#reproduct_id#" value="#TheQuery.Inventory_UM#"/>
				</td>
			<!--- 114617 :: Ideal Price START --->
			<cfif GetTemplateInfo.Ideal_Price>
				<td>
					<cfif Ideal_Price_Type EQ 2>
						<cfset readOnlyCS= ''>
						<cfset readOnlylLB = ''>
						<cfif isDefined("form.fixed_C#IPcomp_id#_P#reproduct_id#_1_uom") AND evaluate("form.fixed_C#IPcomp_id#_P#reproduct_id#_1_uom") EQ 1>
							<cfset readOnlyCS = ''>
							<cfset readOnlylLB = 'readonly'>
						<cfelseif isDefined("form.fixed_C#IPcomp_id#_P#reproduct_id#_1_uom") AND evaluate("form.fixed_C#IPcomp_id#_P#reproduct_id#_1_uom") EQ 2>
							<cfset readOnlyCS = 'readonly'>
							<cfset readOnlylLB = ''>
						<cfelse>
							<!--- When Item imported We will take template default UOM to enable Volume text box --->
							<cfif GetTemplateInfo.RateTypeDefault EQ 2>
								<cfset readOnlyCS = 'readonly'>
								<cfset readOnlylLB = ''>
							<cfelse>
								<cfset readOnlyCS = ''>
								<cfset readOnlylLB = 'readonly'>
							</cfif>
						</cfif>
							<input type="text" #readOnlyCS# <Cfif len(readOnlyCS)>tabindex="-1"</cfif> name="fixed_#reproduct_id#_IP_VolumeCS" id="fixed_#reproduct_id#_VolumeCS" value="#numberformat(VolumeCS)#" size="5" onkeyup="clenseText(this,'0123456789,');" onchange="idealVolChange('#reproduct_id#','#rowcount#','#numberformat(slope_cs, "0.0000000")#','#numberformat(yintercept_cs, "0.0000000")#','#numberformat(slope_lb, "0.0000000")#','#numberformat(yintercept_lb, "0.0000000")#', #IPcomp_id#)" style="text-align:right<cfif len(readOnlyCS)>;background-color: ##e5e2e9;</cfif>"> CS<br>
							<input type="text" #readOnlylLB# <Cfif len(readOnlylLB)>tabindex="-1"</cfif> name="fixed_#reproduct_id#_IP_VolumeLB" id="fixed_#reproduct_id#_VolumeLB" value="#numberformat(VolumeLB)#" size="5" onkeyup="clenseText(this,'0123456789,');"onchange="idealVolChange('#reproduct_id#','#rowcount#','#numberformat(slope_cs, "0.0000000")#','#numberformat(yintercept_cs, "0.0000000")#','#numberformat(slope_lb, "0.0000000")#','#numberformat(yintercept_lb, "0.0000000")#', #IPcomp_id#)" style="text-align:right<cfif len(readOnlylLB)>;background-color: ##e5e2e9;</cfif>"> LB
					<cfelseif Ideal_Price_Type EQ 3>
						#VolumeCS#/CS<br>
						#VolumeLB#/LB
					<cfelse>
						N/A
					</cfif>
					<input type="hidden" name="fixed_#reproduct_id#_Ideal_Price_Type" id="fixed_#reproduct_id#_Ideal_Price_Type" value="#Ideal_Price_Type#" size="5" >
				</td>
				<td id="fixed_#reproduct_id#_#rowcount#_IP">
					<cfset IPCSPrice = #trim(numberformat(Ideal_CS, ViewProgramManager.getRateFormatMask(1, 1, 1)))#>
					<cfset IPLBPrice = #trim(numberformat(Ideal_LB, ViewProgramManager.getRateFormatMask(1, 2, 1)))#>
					<div id = "#reproduct_id#_#rowcount#_IdealCSPrice">#IPCSPrice#/CS</div>
					<div id = "#reproduct_id#_#rowcount#_IdealLBPrice">#IPLBPrice#/LB</div>
					<input type="hidden" name="fixed_#reproduct_id#_#rowcount#_IPCS" id="fixed_#reproduct_id#_#rowcount#_IPCS" value="#Ideal_CS#">
					<input type="hidden" name="fixed_#reproduct_id#_#rowcount#_IPLB" id="fixed_#reproduct_id#_#rowcount#_IPLB" value="#Ideal_LB#">
				</td>

				<td>$&nbsp;<input <cfif Ideal_Price_Type EQ 1>disabled</cfif> type="textbox" name="fixed_#reproduct_id#_#rowcount#_IPD" id="fixed_#reproduct_id#_#rowcount#_IPD" value="" size="5" ONKEYUP="clenseText(this,'0123456789.-')" onChange="idealPriceCal('#reproduct_id#', 1, 1, #IPcomp_id#, #rowcount#)"></td>
				<td><input <cfif Ideal_Price_Type EQ 1>disabled</cfif> type="textbox" name="fixed_#reproduct_id#_#rowcount#_IPDP" id="fixed_#reproduct_id#_#rowcount#_IPDP" value="" size="5" ONKEYUP="clenseText(this,'0123456789.-')" onChange="idealPriceCal('#reproduct_id#', 1, 2, #IPcomp_id#, #rowcount#)">&nbsp;%</td>
			</cfif>
			<!--- 114617 :: Ideal Price END --->
				<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
					<td>
						<!---D51088 :: Base Sales on Fixed Price page to be based on component type START --->
						<cfset CS_Price = variables.DEL_CS_Price>
						<cfset LB_Price = variables.DEL_LB_Price>

						<cfif (getFixedComponents.Recordcount EQ 1 AND getFixedComponents.Fixed_Component_Type EQ 2)
								OR (getFixedComponents.Recordcount EQ 0  AND Item_Margin_Targets_default EQ 'F')
								OR (getFixedComponents.Recordcount GT 1  AND Item_Margin_Targets_default EQ 'F')>
							<cfset CS_Price = variables.FOB_CS_Price>
							<cfset LB_Price = variables.FOB_LB_Price>
						</cfif>

						<!--- If "Use Fixed price Type" and "Restrict Rate UOM on Product UOM" app setting is ON and Inventory UOM is NOT "LB" ("CS" or any other), do not show UOM and it is 3 decimal places --->
						<cfif appSettings.getUseFixedPriceType() AND appSettings.getRestrictProductUOM() and Inventory_UM neq "LB">
							$#numberformat(CS_Price,"_,___,____.___")#
						<!--- If "Use Fixed price Type" and "Restrict Rate UOM on Product UOM" app setting is ON and Inventory UOM is "LB", do not show UOM and it is 3 decimal places --->
						<cfelseif appSettings.getUseFixedPriceType() AND appSettings.getRestrictProductUOM() and Inventory_UM eq "LB">
							$#numberformat(LB_Price,"_,___,____.___")#
						<cfelse>
						<!--- If "Restrict Rate UOM on Product UOM" is OFF --->
							$#numberformat(CS_Price,"_,___,____.__")#/CS<br>
							$#numberformat(LB_Price,"_,___,____.____")#/LB
						</cfif>
						<!---D51088 :: Base Sales on Fixed Price page to be based on component type END --->
						<input type="hidden" name="fixed_P#reproduct_id#_Price_CS" value="#variables.FOB_CS_Price#">
						<input type="hidden" name="fixed_P#reproduct_id#_Price_LB" value="#variables.FOB_LB_Price#">
					</td>
				</cfif>
	<!---********************** START Fixed Components Loop *****************************--->
	<cfif getFixedComponents.Recordcount GT 0>

		<cfloop from="1" to="#ListLen(form.fixedComponentList)#" index="i" >
			<cfset currentComponentInfo = ListGetAt(form.fixedComponentList,i) />
			<cfset currentcompid = getComponentNameId(currentComponentInfo)>
			<cfset paidTo = getComponentPaidTo(currentComponentInfo)>
			<cfset GL_Account_ID = getGL_Account_ID(currentComponentInfo)>
			<cfset currentcompid = ListGetAt(fixed_comp_ids,i)>
			<cfset getFixedComponentName = Evaluate("qFixedComponentNameInfo_#currentcompid#") />
			<cfset variables.fixed_price_type = getFixedComponentName.fixed_price_type />
			<cfset variables.IsSecondComponent = getIsSecondComponent(currentComponentInfo) />

			<cfif variables.fixed_price_type eq "">
				<cfset variables.fixed_price_type = 0 />
			</cfif>

			<cfset variables.fixed_price_type_disable = 0 />
			<cfset variables.fixed_price_type_bgcolor = "" />

			<!--- D45016 :: Restrict access at component level for all discount types START--->
			<cfset display = ''>
			<cfif ! listfind(valuelist(getAllFixedComponentsAccess.Program_Fixed_Component_Name_ID),currentcompid)>
				<cfset display ='table-cell'/>
			<cfelse>
				<cfset display = 'none'/>
			</cfif>
			<!--- D45016 :: Restrict access at component level for all discount types END--->

        	<cfif variables.fixed_price_type eq 2>
				<!--- Price Extension --->
				<!--- always use the price. users cannot change price --->
				<!---D51088 :: Base Sales on Fixed Price page to be based on component type START --->
				<cfset CS_Price = variables.DEL_CS_Price>
				<cfset LB_Price = variables.DEL_LB_Price>

				<cfif (getFixedComponents.Recordcount EQ 1 AND getFixedComponents.Fixed_Component_Type EQ 2)
					OR (getFixedComponents.Recordcount EQ 0  AND Item_Margin_Targets_default EQ 'F')
					OR (getFixedComponents.Recordcount GT 1  AND Item_Margin_Targets_default EQ 'F')>
					<cfset CS_Price = variables.FOB_CS_Price>
					<cfset LB_Price = variables.FOB_LB_Price>
				</cfif>
				<!---D51088 :: Base Sales on Fixed Price page to be based on component type END --->
				<cfif appSettings.getRestrictProductUOM() and Inventory_UM eq "LB">
					<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" = LB_Price />
					<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" = 2 />
				<cfelse>
					<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" = CS_Price />
					<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" = 1 />
				</cfif>
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_volume"	default="#TheQuery.volume#">
				<cfset variables.fixed_price_type_disable = 1 />
			<cfelseif variables.fixed_price_type eq 1 or variables.fixed_price_type eq 3>
				<!--- Deviated Price (Meets Competition) OR Combination (Blended) --->
				<!--- use price as default, users can change --->
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" 		default="#TheQuery.Fixed_Price_Value#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_volume"	default="#TheQuery.volume#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" 		default="#TheQuery.Unit_Of_Measure_ID#">

				<cfif Evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ "">
					<cfif appSettings.getRestrictProductUOM() and Inventory_UM eq "LB">
						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" = LB_Price />
						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" = 2 />
					<cfelse>
						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" = CS_Price />
						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" = 1 />
					</cfif>
				</cfif>
			<cfelse>
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" 		default="#TheQuery.Fixed_Price_Value#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_volume"	default="#TheQuery.volume#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_UOM" 		default="#TheQuery.Unit_Of_Measure_ID#">
			</cfif>
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Name_ID" 		default="#TheQuery.Competitor_Name_ID#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Price" 		default="#TheQuery.Competitor_Price#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Time_Frame" 	default="#TheQuery.Competitor_Time_Frame#">
				<cfparam name = "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_Check_Competitor_Info" 	default="">
				<cfset variables.Rule_UOM = 0 />
				<cfset variables.Apply_Percent_To = 0 />
				<cfset variables.Cost_Impact = 0 />

				<cfif NOT isDefined("form.fix_rule_C#currentcompid#_P#reproduct_id#_#i#")>
						<cfset fixrule = fixedCompObj.getFixProdRule(Thequery.BSA_Foodservice_Items_Master_ID,currentcompid,FORM.Contract_Main_ID,paidTo)>
						<cfset "form.fix_rule_C#currentcompid#_P#reproduct_id#_#i#" = fixrule />
				</cfif>
				<cfset currentRuleId = Evaluate("form.fix_rule_C#currentcompid#_P#reproduct_id#_#i#") />
				<cfset currentUOM = evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") />
				<cfset currentRate = Val(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate")) />

				<cfif currentUOM eq 6> <!--- CWT --->
					<cfset currentRate = currentRate / 100.00 />
					<cfset currentUOM = 2 />
				<cfelseif currentUOM eq 5 OR currentUOM eq 7> <!--- 76541 Eaches --->
						<cfif currentUOM eq 5>
							<cfset currentRate = currentRate * TheQuery.Case_Count />
						<cfelse>
							<cfset currentRate = currentRate * TheQuery.Sleeve_Count />
						</cfif>
					<cfset currentUOM = 1 />
					<cfif TheQuery.Inventory_UM EQ "LB">
						<cfset currentRate = currentRate / TheQuery.Net_Weight />
						<cfset currentUOM = 2 />
					</cfif>
				</cfif>
				<!---- discount fields --->
				<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
						<cfsilent>
							<cfset currentFOBCSPrice = CS_Price />
  						<cfset currentFOBLBPrice = LB_Price />
  						<cfif currentUOM eq 1>
    						<!--- cs --->
    						<cfset currentCSRate = currentRate />
    						<cfset currentLBRate = currentCSRate / Net_Weight />
    					<cfelse>
    						<!--- lb --->
    						<cfset currentLBRate = currentRate />
    						<cfset currentCSRate = currentLBRate * Net_Weight />
  						</cfif>
  						<!--- if business rule specified, add it to the base sales or fixed price depending on what's defined in the rule ---->
  						<cfif isNumeric(currentFOBLBPrice) AND currentRuleId neq 0>
    						<cfset addRuleValueCS = 0 />
    						<cfset addRuleValueLB = 0 />
    						<cfset qGetRuleInfo = compBusRule.getRules(ruleId = currentRuleId) />
    						<cfif qGetRuleInfo.recordCount>
	  							<cfset variables.Cost_Impact	= qGetRuleInfo.Cost_Impact />
	  							<cfset variables.Rule_UOM		= qGetRuleInfo.Unit_Of_Measure_ID />
	  							<cfif qGetRuleInfo.Unit_Of_Measure_ID eq 1>
        							<!--- cs --->
									<cfset addRuleValueCS = qGetRuleInfo.Cost_Impact />
									<cfset addRuleValueLB = qGetRuleInfo.Cost_Impact / Net_Weight />
	    						<cfelseif qGetRuleInfo.Unit_Of_Measure_ID eq 2>
        							<!--- lb --->
									<cfset addRuleValueCS = qGetRuleInfo.Cost_Impact * Net_Weight />
									<cfset addRuleValueLB = qGetRuleInfo.Cost_Impact />
	    						<cfelseif qGetRuleInfo.Unit_Of_Measure_ID eq 3>
        							<!--- % --->
									<!---*******************************************************************************
										Tim Ford - Label 17679: Apply_Percent_To dictates percentage of what value.
										We only handle for this variable if Apply_Percent_To equal to Fixed Price (2)
										1 = Base Sales: is handled by adding teh cost impact to currentFOBCSPrice
										2 = Fixed Price: is handled in the javascript based on the variable Apply_Percent_To
										by dynamically getting teh fixed price from the text box
										*********************************************************************************--->
									<cfif qGetRuleInfo.Apply_Percent_To eq 1>
          								<cfset addRuleValueCS = currentFOBCSPrice * (qGetRuleInfo.Cost_Impact/100.00) />
          								<cfset addRuleValueLB = currentFOBLBPrice * (qGetRuleInfo.Cost_Impact/100.00) />
		  							<cfelseif qGetRuleInfo.Apply_Percent_To eq 2>
          								<cfset addRuleValueCS = currentCSRate * (qGetRuleInfo.Cost_Impact/100.00) />
          								<cfset addRuleValueLB = currentLBRate * (qGetRuleInfo.Cost_Impact/100.00) />
          								<cfset variables.Apply_Percent_To = qGetRuleInfo.Apply_Percent_To />
									</cfif>
	  							</cfif>
    						</cfif>
    						<cfset currentFOBCSPrice = currentFOBCSPrice + addRuleValueCS />
    						<cfset currentFOBLBPrice = currentFOBLBPrice + addRuleValueLB />
  						</cfif>
  						<!---- find the discount ---->
	  					<cfif currentUOM EQ 1>
								<cfset discount = currentFOBCSPrice - currentRate>
							<cfelseif currentUOM EQ 2>
								<cfset discount = currentFOBLBPrice - currentRate>
							<cfelse>
								<cfset discount = 0>
	  					</cfif>
  						<!---- find the discount % ---->
  						<cfset discount_percent = 0 />
  						<cfif currentUOM EQ 1>
    						<cfif currentFOBCSPrice NEQ 0>
	  							<cfset discount_percent = (discount/currentFOBCSPrice) * 100 />
    						</cfif>
    					<cfelse>
    						<cfif currentFOBLBPrice NEQ 0>
	  							<cfset discount_percent = (discount/currentFOBLBPrice) * 100 />
    						</cfif>
  						</cfif>
  						<!---Tim Ford - If discount is a negative value then set it to zero --->
  						<cfif discount lt 0>
    						<cfset discount 		= 0 />
    						<cfset discount_percent = 0 />
  						</cfif>
						</cfsilent>
  						<!--- If the fixed price type is "Deviated price" (Meets Competition) OR Combination (Blended) --->

  						<cfif (variables.fixed_price_type eq 1 or variables.fixed_price_type eq 3) and discount gt 0 AND ! GetTemplateInfo.Ideal_Price>
    						<cfset variables.fixed_price_type_bgcolor = "F2ACA5" />
  						</cfif>
										<!--- -When we use the "% of list price" feature (48146 and 73058 and 73241). Do it for newly added components only (i eq ListLen(form.fixedComponentList). --->
										<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1') AND (isDefined("FORM.txtPercentage") AND FORM.txtPercentage NEQ "") AND i eq ListLen(form.fixedComponentList)>
													<!---  Do it only when a user enters a negative number (which means discount) --->
													<cfif FORM.txtPercentage LT 0>
														<cfif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 2><!--- LB --->
															<cfset discount = #Abs(Trim((LB_Price * (FORM.txtPercentage/100))))# />
														<cfelseif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 1><!--- CS --->
															<cfset discount = #Abs(Trim((CS_Price * (FORM.txtPercentage/100))))# />
														</cfif>
															<cfset discount_percent = Abs(FORM.txtPercentage) />
													<cfelse>
															<cfset discount = 0 />
															<cfset discount_percent = 0 />
													</cfif>
										<cfelse>
												<cfif appSettings.getUseFixedPriceType() EQ 1>
													<!--- 3 decimal places --->
													<cfset discount = numberformat(trim(discount),"_,___,____.___") />
												<cfelse>
													<!--- 4 decimal places --->
													<cfset discount = numberformat(trim(discount),"_,___,____.___-") />
												</cfif>
													<cfset discount_percent = numberformat(round(discount_percent),"_,___,____") />
										</cfif>

											<td valign="center" class="disc" id="fixed_C#currentcompid#_P#reproduct_id#_#i#_TDDisc" style="display:#display#;background-color:#variables.fixed_price_type_bgcolor#">
												<span id="fixed_C#currentcompid#_P#reproduct_id#_#i#_D">$#discount#</span>
											</td>

											<td valign="center" class="dper" id="fixed_C#currentcompid#_P#reproduct_id#_#i#_TDDiscPer" style="display:#display#;background-color:#variables.fixed_price_type_bgcolor#">
												<span id="fixed_C#currentcompid#_P#reproduct_id#_#i#_DP">#discount_percent#%</span>
											</td>
										</cfif>
						<td id="fixed_C#currentcompid#_P#reproduct_id#_#i#_TDFP" style="display:#display#;background-color:#variables.fixed_price_type_bgcolor#">
							<span id="SPAN_fixed_C#currentcompid#_P#reproduct_id#_#i#_rate">
						<!--- 76380 decimal places START--->
							<cfset decimalprecision = programManager.decimalPrecisionByUOM(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom"),1)>
							<cfset decimalformatValidation = programManager.decimalPrecisionByUOM(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom"),2)>
						<!--- 76380 decimal places END--->
      				<!--- D11147 BJF Component product restrictions  Check to see if the product is restricted--->
      				<cfset DisabledbyComp = 0>
							<cfif appsettings.getComponent_Product_Restrictions_On()>
								<cfquery name="ProductInForbiddenlist" dbtype="query">
									SELECT Product_ID
									FROM Query_#currentcompid#
									WHERE Product_ID = '#Thequery.BSA_Foodservice_Items_Master_ID#'
								</cfquery>
								<cfif ProductInForbiddenlist.Recordcount GT 0>
									<cfset DisabledbyComp = 1>
								</cfif>
							</cfif>
              				<!---<cfif (Revision_Settings_Allowed eq 0 OR RevisionStatus.Is_A_Revision eq 0 OR RevisionSettings.Products_Rates_Changes neq 0) and ((getsettings.EZButton_On eq 1 and url.EZtemplate EQ 1) OR ((getsettings.EZButton_On eq 0 and url.EZtemplate EQ 0))) AND DisabledbyComp NEQ 1 AND variables.fixed_price_type_disable NEQ 1>--->
							<!--- Dev Note: (49437). Remove the conditions related to Ezbutton (Ezbutton conditions on the above line - commented code). Fixed price does not have Ezbutton anymore. Without this change, if we have ezbutton ON on the template, the code assumes that the product rates cannot be revised
							under certain conditions. So, the below condition fails and code goes to the else condition and adds hidden variables for rate. If Ezbutton was ON, then the rate textbox would have been disabled
							and the hidden variables would be needed.
							--->
							<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 AND appSettings.getProgram_Allow_Null_Rate() EQ 1>
								<cfset val="">
							<CFELSE>
								<cfset val="#NumberFormat(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate"), decimalprecision)#">
							</CFIF>
							<cfif (Revision_Settings_Allowed eq 0 OR RevisionStatus.Is_A_Revision eq 0 OR RevisionSettings.Products_Rates_Changes neq 2) AND DisabledbyComp NEQ 1 AND variables.fixed_price_type_disable NEQ 1>
									<cfif !isDefined("variables.rateTabindex")>
										<cfset variables.rateTabindex = 300>
									<cfelse>
										<cfset variables.rateTabindex += 10>
									</cfif>

								<!--- -When we use the "% of list price" feature (48146 and 73058 and 73241)--->
								<cfif (appSettings.get_Setting('Percentage_Of_List_Price') EQ '1' AND GetSettings.Percentage_Of_List_Price EQ '1')>
									<cfif (isDefined("FORM.txtPercentage") AND FORM.txtPercentage NEQ "")>
										<!--- Do it for the newly added component only (i eq ListLen(form.fixedComponentList)). Without it, the previously added component's rate will change as well, which is not correct. --->
										<cfif i eq ListLen(form.fixedComponentList)>
											<cfif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 2><!--- LB --->
												<cfset val = #Trim(numberformat((LB_Price * (FORM.txtPercentage/100) + LB_Price), decimalprecision))# />
											<cfelseif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 1><!--- CS --->
												<cfset val = #Trim(numberformat((CS_Price * (FORM.txtPercentage/100) + CS_Price), decimalprecision))# />
											</cfif>
										</cfif>
									</cfif>
								</cfif>
								<!--- DISABLE IF IT IS FORMULA Fixed.  formula will calculate the Rate --->
								<cfscript>
									disableRateUOMText = '';
									if(getFixedComponentName.Formula_Pricing == 1 OR variables.IsSecondComponent == 1){
										disableRateUOMText = 'ReadOnly STYLE="background-color: lightgray"';
									}
								</cfscript>
								<input type="text" size="4"
										value="#val#"
										name="fixed_C#currentcompid#_P#reproduct_id#_#i#_rate"
										id="fixed_C#currentcompid#_P#reproduct_id#_#i#_rate"
										ONKEYUP="clenseText(this,'0123456789.');"
										onChange="idealPriceCal('#reproduct_id#', 1, 3, #currentcompid#, #rowcount#);verifyDataChange('#currentcompid#','#reproduct_id#','#i#',this);
										this.value =
										<CFIF appSettings.getProgram_Allow_Null_Rate() EQ 1>
											formatToDeciamalPlacesAllowNull(this.value,#decimalformatValidation#,1);
										<CFELSE>
											formatToDeciamalPlaces(this.value, #decimalformatValidation#);
										</CFIF>
										<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
											adjustdiscount('fixed_C#currentcompid#_P#reproduct_id#_#i#','#currentFOBCSPrice#','#currentFOBLBPrice#','#variables.Rule_UOM#','#variables.Apply_Percent_To#', '#variables.Cost_Impact#', '#Net_Weight#', '#variables.FOB_CS_Price#', '#variables.FOB_LB_Price#','#reproduct_id#');
										</cfif>"
									<!--- BASED ON MIN MAX TEMPLATE SETTINGS SET THE BACKGROUND COLOR --->
									<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 OR evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ "">
										STYLE="background-color: yellow"
                  						<cfset displayMinRateWarn = "inline" />
				  					<CFELSE>
                  						<cfif ThereisMinorMax IS 1>
                    						<!---Pounds first--->
                    						<cfif currentUOM EQ 2>
                      							<Cfif len(trim(Min_Fixed_Pound)) IS NOT 0>
                        							<!---Pounds Min--->
                        							<CFIF currentRate LT Min_Fixed_Pound >
						 								STYLE="background-color: yellow"
                          								<cfset displayMinRateWarn = "inline" />
                        							</CFIF>
                      							</cfif>
                      							<Cfif len(trim(Max_Fixed_Pound)) IS NOT 0 AND Max_Fixed_Pound IS NOT 0>
                        							<!---Pounds Max--->
                        							<CFIF currentRate GT Max_Fixed_Pound >
														STYLE="background-color: red"
                          								<cfset displayMaxRateWarn = "inline" />
                        							</CFIF>
                      							</cfif>
                    						</cfif>
                    						<!---Cases--->
                    						<cfif currentUOM EQ 1>
                      							<Cfif len(trim(Min_Fixed_Case)) IS NOT 0>
                        							<!---CASE Min--->
                        							<CFIF currentRate LT Min_Fixed_Case >
						 								STYLE="background-color: yellow"
                          								<cfset displayMinRateWarn = "inline" />
                        							</CFIF>
                      							</cfif>
                      							<Cfif len(trim(Max_Fixed_Case)) IS NOT 0 AND Max_Fixed_Case IS NOT 0>
                        							<!---CASE Max--->
                        							<CFIF currentRate GT Max_Fixed_Case >
														STYLE="background-color: red"
                          								<cfset displayMaxRateWarn = "inline" />
                        							</CFIF>
                      							</cfif>
                    						</cfif>
                  						</cfif>
									</CFIF>
											 #disableRateUOMText# />
	            			<cfelse>
		        					<!--- Set values if EZ Button --->
		        					<cfif EzButton_Disable EQ 1>
			      						<cfset useLakebaseForgetEZButtonRate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getezbuttondefaultrates")>
<cfif useLakebaseForgetEZButtonRate>
	<cftry>
		<cfset getEZButtonRate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getezbuttondefaultrates", {
				"bsa_foodservice_items_master_id" = "eq.#Thequery.BSA_Foodservice_Items_Master_ID#",
				"program_fixed_component_name_id" = "eq.#currentcompid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetEZButtonRate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetEZButtonRate>
<cfquery name="getEZButtonRate" dbtype="query">
											SELECT *
											FROM 	GetEZButtonDefaultRates
											WHERE 	BSA_Foodservice_Items_Master_ID = '#Thequery.BSA_Foodservice_Items_Master_ID#'
											AND 	Program_Fixed_Component_Name_Id = #currentcompid#
			      						</cfquery>
</cfif>
			      						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" = getEZButtonRate.Fixed_Price_Value>
			      						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom" = getEZButtonRate.Unit_Of_Measure_ID>
		        					</cfif>
		        					<!--- Set values if forbidden by component --->
		        					<cfif DisabledbyComp EQ 1>
			      						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" = "0">
			      						<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom" = getProgramInfo.Contract_Quantity_UOM_IDX>
		        					</cfif>
									<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 AND appSettings.getProgram_Allow_Null_Rate() EQ 1>
										<cfset val2="">
									<CFELSE>
										<cfset val2="#NumberFormat(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate"), decimalprecision)#">
									</CFIF>
										<input type="text" size="3" value="#val2#" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" id="fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" ONKEYUP="clenseText(this,'0123456789.')" onChange="verifyDataChange('#currentcompid#','#reproduct_id#','#i#',this);
											    this.value =
												<CFIF appSettings.getProgram_Allow_Null_Rate() EQ 1>
													formatToDeciamalPlacesAllowNull(this.value,#decimalformatValidation#,1);
												<CFELSE>
													formatToDeciamalPlaces(this.value,#decimalformatValidation#);
												</CFIF>
											<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
												adjustdiscount('fixed_C#currentcompid#_P#reproduct_id#_#i#','#currentFOBCSPrice#','#currentFOBLBPrice#','#variables.Rule_UOM#','#variables.Apply_Percent_To#', '#variables.Cost_Impact#', '#Net_Weight#', '#variables.FOB_CS_Price#', '#variables.FOB_LB_Price#','#reproduct_id#');
											</cfif>"
											<cfif (ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0 AND RevisionSettings.Products_Rates_Changes EQ 2) OR (EzButton_Disable EQ 1) OR DisabledbyComp EQ 1 OR variables.fixed_price_type_disable EQ 1>
												STYLE="background-color: FFFFFF" DISABLED
											<cfelse>
												<!--- BASED ON MIN MAX TEMPLATE SETTINGS SET THE BACKGROUND COLOR --->
								               	<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 OR evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ "">
													STYLE="background-color: yellow"
								                	<cfset displayMinRateWarn = "inline" />
												<cfelse>
								                	<cfif ThereisMinorMax IS 1>
													<!---Pounds first--->
														<cfif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 2>
															<Cfif len(trim(Min_Fixed_Pound)) IS NOT 0>
															<!---Pounds Min--->
																<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") LT Min_Fixed_Pound >
																	STYLE="background-color: yellow"
																	<cfset displayMinRateWarn = "inline" />
																</CFIF>
															</cfif>
															<Cfif len(trim(Max_Fixed_Pound)) IS NOT 0 AND Max_Fixed_Pound IS NOT 0>
															<!---Pounds Max--->
																<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") GT Max_Fixed_Pound >
																	STYLE="background-color: red"
																	<cfset displayMaxRateWarn = "inline" />
																</CFIF>
															</cfif>
														</cfif>
								                      	<!---Cases--->
								                     	<cfif evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom") EQ 1>
								                        	<Cfif len(trim(Min_Fixed_Case)) IS NOT 0>
								                          	<!---CASE Min--->
								                          		<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") LT Min_Fixed_Case >
														 			STYLE="background-color: yellow"
								                            		<cfset displayMinRateWarn = "inline" />
								                          		</CFIF>
								                        	</cfif>
								                        	<Cfif len(trim(Max_Fixed_Case)) IS NOT 0 AND Max_Fixed_Case IS NOT 0>
								                          	<!---CASE Max--->
								                          		<CFIF evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") GT Max_Fixed_Case >
																	STYLE="background-color: red"
								                            		<cfset displayMaxRateWarn = "inline" />
								                          		</CFIF>
								                        	</cfif>
								                      	</cfif>
								                    </cfif>
							                  </CFIF>
											</cfif> />
								<cfif (ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0 AND RevisionSettings.Products_Rates_Changes EQ 2) OR (EzButton_Disable EQ 1) OR DisabledbyComp EQ 1 OR variables.fixed_price_type_disable EQ 1>
					 		    	<input type="hidden" <CFIF (evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate") EQ 0 AND appSettings.getProgram_Allow_Null_Rate() EQ 1) OR (DisabledbyComp EQ 1)>value=""<CFELSE>value="#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_rate")#"</CFIF> name="fixed_C#currentcompid#_P#reproduct_id#_#i#_rate" />
						        </cfif>
						</cfif>
						</span>

								<input type="hidden" value="#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_volume")#" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_volume" />
								<input name="fix_rule_C#currentcompid#_P#reproduct_id#_#i#" type="hidden" value="#currentRuleId#" />
								<cfset "Form.uomsToCheck_#i#" = ListAppend(Evaluate("form.uomsToCheck_#i#"), reproduct_id) />

								<cfif #evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")# EQ "">
		        					<cfset setDefaultSelected = 1>
	            					<cfelse>
		        					<cfset setDefaultSelected = 0>
  								</cfif>
								<cfset Disabled = 0>
								<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF START--->
								<cfif listfind(ParentFixedComponents, currentcompid) AND (Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0) OR (EzButton_Disable EQ 1) OR DisabledbyComp EQ 1 OR variables.fixed_price_type_disable EQ 1>
		        					<cfset Disabled = 1>
								</cfif>
								<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF END--->
								<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
		        					<cfset onchangetext = "idealPriceCal('#reproduct_id#', 1, 4, #currentcompid#, #rowcount#);verifyDataChange('#currentcompid#','#reproduct_id#','#i#',this);adjustdiscount('fixed_C#currentcompid#_P#reproduct_id#_#i#','#currentFOBCSPrice#','#currentFOBLBPrice#','#variables.Rule_UOM#', '#variables.Apply_Percent_To#','#variables.Cost_Impact#', '#Net_Weight#', '#variables.FOB_CS_Price#', '#variables.FOB_LB_Price#','#reproduct_id#');">
	            					<cfelse>
		        					<cfset onchangetext ="idealPriceCal('#reproduct_id#', 1, 4, #currentcompid#, #rowcount#);verifyDataChange('#currentcompid#','#reproduct_id#','#i#',this);">
								</cfif>
								<cfif !isDefined("variables.uomTabindex")>
									<cfset variables.uomTabindex = 600>
									<cfelse>
									<cfset variables.uomTabindex += 10>
								</cfif>
								<cfif len(disableRateUOMText)>
									<cfset Disabled = 1>
								</cfif>
								<cfif Disabled eq 1>
											<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF START--->
											<cfif len(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")) EQ 0 AND getFixedComponentName.Formula_Pricing EQ 0 AND val(GetContractInfo.Revision_of_Contract_Main_ID) neq 0>
												<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom" = fixedCompObj.getParentProgProductUOM(GetContractInfo.Revision_of_Contract_Main_ID, replace(reproduct_id,'_','-','ALL'))>
											<cfelseif len(evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")) EQ 0 AND getFixedComponentName.Formula_Pricing EQ 1>
												<cfset "form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom" = 6> <!--- FORMULA USES CWT FOR User_Picked_UOM and LB (2) for Unit_Of_Measure_ID --->
											</cfif>
											<!---61605 : Event error on fixed price save when revision setting for UOM change is OFF END--->
		        					<input type="hidden" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_uom" value="#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")#">
								</cfif>
								<cf_uom_dropdown
									program_id				=	"#FORM.Contract_Main_ID#"
									company_main_id			=	""
									default_option_on		=	"0"
									default_option_text		=	""
									default_option_value	=	""
									dropdown_name			=	"fixed_C#currentcompid#_P#reproduct_id#_#i#_uom"
									option_text_abbreviated	=	"1"
									plural_uom_display		=	""
									product_type_id			=	"1"
									program_template_id		=	""
									selected_uom_id			=	"#evaluate("form.fixed_C#currentcompid#_P#reproduct_id#_#i#_uom")#"
									text_before_tag_close	=	""
									uom_id_exclusion_list	=	"#uom_id_exclusion_list#"
									uom_id_inclusion_list	=	""
									setDefaultSelected		= 	"#setDefaultSelected#"
									productUom				=	"#TheQuery.Inventory_UM#"
									Disabled				= 	"#Disabled#"
									onchange				=   "#onchangetext#"
								>

<!--- 62455 :: Fixed Price Components - Additional Drop Down for Fixed Price Type START--->
<cfif getFixedComponents.FP_Type EQ 1>
	<input type="text" size="4" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_MaxVolumeFixedPrice" value="#TheQuery.Max_Volume_Fixed_Price#">
</cfif>
<!--- 62455 :: Fixed Price Components - Additional Drop Down for Fixed Price Type  END--->
						</td>
        				<cfif ((getFixedComponentName.fixed_price_type eq 1 or getFixedComponentName.fixed_price_type eq 3) AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1)>
          						<cfset Competitor_Name_ID = evaluate("FIXED_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Name_ID") />
          						<cfif appSettings.getUseFixedPriceType()>
            						<cfset CompetitorPrice = NumberFormat(evaluate("FIXED_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Price"), ".__") />
           						<cfelse>
            						<cfset CompetitorPrice = NumberFormat(evaluate("FIXED_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Price"), ".____") />
          						</cfif>
          						<td id="fixed_C#currentcompid#_P#reproduct_id#_#i#_TDCName" style="display:#display#;background-color:#variables.fixed_price_type_bgcolor#">
	          						<!--- The variable to check whether "discount" is offered or not --->
	          						<input type="hidden" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Check_Competitor_Info" <cfif Discount GT 0>value="1"<cfelse>value="0"</cfif> />
	            						<!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  (Changed/Added: onChange="showCompetitorSource_Other(#id_i#)" id="CompetitorSource#id_i#")--->
										<cfset not_other ="">
										<br>
										<select name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Name_ID" onChange="showCompetitorSource_Other(#id_i#)" id="CompetitorSource#id_i#">
	              							<OPTION VALUE="0" SELECTED>Select a Competitor</OPTION>
		          							<CFLOOP QUERY="CompetitorList">
		            							<cfset sChecked = "" />
		            							<cfif CompetitorList.Program_Bid_Won_By_ID eq form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID']>
			          								<cfset sChecked = " selected " />
			          								<cfset not_other ="yes">
		            							</cfif>
		            							<OPTION VALUE="#CompetitorList.Program_Bid_Won_By_ID#" #sChecked#>
													#trim(CompetitorList.Program_Bid_Won_By_Description)#
												</OPTION>
	              							</cfloop>
		                  							<!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START
           Changed/Added: Added new OPTION Other--->
		   		          							<OPTION VALUE="-1" <cfif (form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID'] EQ #TheQuery.Competitor_Name_ID#) AND (CompetitorList.Program_Bid_Won_By_ID NEQ #TheQuery.Competitor_Name_ID#) AND (len(TheQuery.Competitor_Name_ID) GT 0) AND (#TheQuery.Competitor_Name_ID# NEQ 0) AND (len(not_other) EQ 0)  OR (form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID'] EQ -1)>SELECTED</cfif>>Other</OPTION>
	              							<!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
	            						</SELECT>
	            						<br>
            						<!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  (Changed/Added: added condition to display Other value in text box.)--->
									<cfset other_value = "">
												<cfif (form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID'] EQ #TheQuery.Competitor_Name_ID#) AND (CompetitorList.Program_Bid_Won_By_ID NEQ #TheQuery.Competitor_Name_ID#) AND (len(TheQuery.Competitor_Name_ID) GT 0) AND #TheQuery.Competitor_Name_ID# NEQ 0  AND (len(not_other) EQ 0)  OR (form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID'] EQ -1)>
              							<cfset useLakebaseForPull_other_comp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForPull_other_comp>
	<cftry>
		<cfset Pull_other_comp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"program_bid_won_by_id" = "eq.#TheQuery.Competitor_Name_ID#",
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
												FROM	Program_Bid_Won_By
												WHERE Program_Bid_Won_By_ID = #TheQuery.Competitor_Name_ID#
              							</cfquery>
</cfif>
              							<cfset other_value = #Pull_other_comp.Program_Bid_Won_By_Description#>
									</cfif>
												<input type="text" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_CompetitorSourceOther" id="CompetitorSourceOther#id_i#" value = "#other_value#" <cfif (form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID'] EQ #TheQuery.Competitor_Name_ID#) AND (CompetitorList.Program_Bid_Won_By_ID NEQ #TheQuery.Competitor_Name_ID#) AND (len(TheQuery.Competitor_Name_ID) GT 0) AND #TheQuery.Competitor_Name_ID# NEQ 0  AND (len(not_other) EQ 0)  OR (form["fixed_C"&currentcompid&'_P'&reproduct_id&'_'&i&'_Competitor_Name_ID'] EQ -1)>style="display: block;"</cfif>style="display: none;">
            						<!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
								</td>
								<td align="left" id="fixed_C#currentcompid#_P#reproduct_id#_#i#_TDCPrice" style="display:#display#;background-color:#variables.fixed_price_type_bgcolor#">
									<input type="text" value="#CompetitorPrice#" size="2" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Price" maxlength="20" ONKEYUP="clenseText(this,'0123456789.')" />
								</td>
								<td  align="left"  id="fixed_C#currentcompid#_P#reproduct_id#_#i#_TDCTimeFrame" style="display:#display#;background-color:#variables.fixed_price_type_bgcolor#">
									<input type="text" value="#Competitor_Time_Frame#" size="5" 	name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Time_Frame" maxlength="15" />
								</td>
					<cfelse>
						<td style="display:none;">
							<input type="hidden" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Name_ID" value=""/>
							<input type="hidden" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Price" value=""/>
							<input type="hidden" name="fixed_C#currentcompid#_P#reproduct_id#_#i#_Competitor_Time_Frame" value=""/>
						</td>
					</cfif>

					<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
  						<cfset isFreightApplied = fixedCompObj.FREIGHTRATESAPPLIED(FORM.Contract_Main_ID,0,0) />
  						<cfif isFreightApplied EQ 1>
    						<td style="display:#display#">
    							<a onClick="JavaScript: editfreightrates('#Thequery.BSA_Foodservice_Items_Master_ID#','#currentcompid#','#i#','#paidTo#')" title="Edit/View Freight Rates" STYLE="cursor: pointer;">
    								add/edit
    							</a>
   							 </td>
						</cfif>
					</cfif>
					</cfloop>
			</cfif>
			<!---********************** END Fixed Components Loop *****************************--->
			<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
				<td>
					<input name="Like_Product" type="checkbox" value="#BSA_Foodservice_Items_Master_ID#" <cfif ListFindNoCase(SimilarExistingProductList,BSA_Foodservice_Items_Master_ID) neq 0 >CHECKED</cfif>>
				</td>
			</cfif>
			</tr>
			</cfoutput>
		</cfif>
	</tbody>

</table>

<cfsavecontent variable="saveContent">
	<a onclick="verifyData();" style="cursor:pointer">
		<b><font color="FF0000">[ </font> save <font color="FF0000">]</font></b>
	</a>
	<cfif GetTemplateInfo.Ideal_Price>
		<a onclick="MassApplyIP(<cfoutput>#IPcomp_id#</cfoutput>);" style="cursor:pointer">
			<b><font color="FF0000">[ </font> mass apply ideal price <font color="FF0000">]</font></b>
		</a>
	</cfif>
</cfsavecontent>

<cfset jQuery.version ="1.12.4">
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables2.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
<!--- D51575 :: "Please Wait" Indicator    8.0 Release START --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 :: "Please Wait" Indicator    8.0 Release END --->
<cfoutput>
<script>
oTable = $('.datagrid').DataTable( {
		     "processing": true
		    , "autoWidth": false
		    , "paging": false
		    , "searchDelay": 250
		    , "language": {"sSearch": "<b>Search:</b>"}
		    , "dom": "f<'save'>prti"
		    , "columns": [
		    						{"sWidth": "40px", "searchable": false, "sortable":false}
							,       {"searchable": true, "sortable":true}
							,       {"searchable": true, "sortable":true}
							/// 114617 :: Ideal Price START
						<cfif GetTemplateInfo.Ideal_Price>
							,      {"searchable": false, "sortable":false}
							,      {"searchable": false, "type": "currency", "sortable":true}
							,      {"searchable": false,  "sortable":false}
							,      {"searchable": false, 	"sortable":false}
						</cfif>
						<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
							,      {"searchable": false, "sortable":true}
						</cfif>
						<cfloop list="#form.fixedcomponentlist#" index="i">
							<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>
							,      {"searchable": false, "sortable":true}
							,      {"searchable": false, "sortable":true}
							</cfif>
							,      {"searchable": false, "sortable":false}
						<cfif (appSettings.getUseFixedPriceType() AND (getFixedComponentName.fixed_price_type eq 1 OR getFixedComponentName.fixed_price_type eq 3) AND isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1)>
							,      {"searchable": false, "sortable":true}
							,      {"searchable": false, "sortable":true}
							,      {"searchable": false, "sortable":true}
							<cfelse>
							,      {"searchable": false, "sortable":true}
						</cfif>
						<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1 AND freightApplied EQ 1>
							,      {"searchable": false, "sortable":true}
						</cfif>
						</cfloop>
						<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							,      {"searchable": false, "sortable":true}
						</cfif>
                            ]
       } )

function showmessage(){
  $('.showmessage').show(0).delay(2000).hide(0);
}

$(".editablefield").on('keypress', function(e) {
    if (e.keyCode === 9 || e.keyCode == 13) {
      $(this).next('.editablefield').focus();
    }
});
$('div.save').html('#application.util.string.compress(saveContent)#');
function clensetext(textvalue){
	clenseText(textvalue,"0123456789.")
}
function validateform(){
	disableButton("pageLink","true");
}
$(".addinfo").mouseenter(function(){
	$(this).siblings("div.on-hover-content").fadeToggle( "slow", "linear" );
})
.mouseleave(function(){
	$(this).siblings("div.on-hover-content").fadeToggle( "slow", "linear" );
});
</script>

<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release END--->

<table border="0" cellpadding="2" cellspacing="3">
	<tr>
		<td><CF_button
				button_name		=	"save"
				button_caption	=	"save"
				button_action	=	"verifyData();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		<cfif form.bFromMargin>
			<td><CF_button
				button_name		=	"close"
				button_caption	=	"close"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		</cfif>
		<cfif ThereisMinorMax IS 1>
		<td>
			<table border="0" cellpadding="2" cellspacing="2">
				<Cfif (len(trim(Max_Fixed_Pound)) IS NOT 0 AND Max_Fixed_Pound IS NOT 0) OR (len(trim(Max_Fixed_Case)) IS NOT 0 AND Max_Fixed_Case IS NOT 0)>
					<tr>
						<td nowrap="true"><span id="spMaxRateWarn" style="display:#displayMaxRateWarn#">
							<span style="background-color: red">&nbsp;red&nbsp;</span> = rate above the maximum template setting
							</span>
						</td>
					</tr>
				</cfif>
				<Cfif (len(trim(Min_Fixed_Case)) IS NOT 0) OR (len(trim(Min_Fixed_Pound)) IS NOT 0)>
					<tr>
						<td nowrap="true"><span id="spMinRateWarn" style="display:#displayMinRateWarn#">
							<span style="background-color: yellow">&nbsp;yellow&nbsp;</span> = zero rate or below the minimum template setting
							</span>
						</td>
					</tr>
				</cfif>
			</table>
		</td>
		</cfif>
	</tr>
</table>

	<INPUT TYPE="hidden" NAME="ProductCount" VALUE="#TheQuery.Recordcount#">
	<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#URL.Sort_By#">

	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="#URL.CID#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Form.Product_List#">
	<input TYPE="hidden" NAME="FixedComponentList" VALUE="<cfoutput>#form.FixedComponentList#</cfoutput>">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Form.Product_List#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	<INPUT TYPE="hidden" NAME="deletedateexclusions" VALUE="0">
	<INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">
	<input type="hidden" name="component_id_value" value="" />

	<input type="hidden" name="compLen" value="#ArrayLen(FixedData.aComp)#" />
  <input type="hidden" name="prodLen" value="#ArrayLen(FixedData.aProd)#" id="prodLen"/>
	<input type="Hidden" name="prodList" value="#theList#" id="prodList">
	<input type="hidden" name="EZTemplate" value="#url.EZTemplate#">
	<input type="hidden" name="fixedfreight_on" value="#getsettings.Discount_Fixed_Prices_Freight#">
	<input type="hidden" name="paidToList" value="" />
	<input type="hidden" name="paidTo" value="" />
	<input type="Hidden" name="priceListID" value="#form.priceListID#">
	<input type="Hidden" name="bFromMargin" value="#Form.bFromMargin#" />
	<!--- <input type="Hidden" name="saveCompData" value="#form.saveCompData#"> --->
	<input type="hidden" name="deleted" value="0"><!--- D30231:Deleting Items off a Revised Program --->
	<input type="hidden" name="DoNotRedirectToNextPage" value="1">
	<input type="hidden" name="prgSpan" value="#program_Span#">
</form>
</cfoutput>
</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0></div></cfif>
<!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START--->
<script language="JavaScript">
	function showCompetitorSource_Other(id)
	{
	    var field =  "CompetitorSource";
			var field = field.concat(id);

		var tfield =  "CompetitorSourceOther";
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

	var client_height = document.body.clientHeight;
	client_height = client_height - 455;
	datagrid_height = client_height + 'px';

	/* To set the height of the data body (scrollable data) inside the fixed price datagrid.
	This is to prevent double scroll bars.
	*/
	$('.dataTables_scrollBody').css('height', datagrid_height);

	function showCreateProdcutListWindow(){
		var sURL = "/Planners/Create/component_select.cfm?<cfoutput>discountType=1&EZTemplate=#url.EZTemplate#&templateId=#GetContractInfo.ProgramType_ID#&Program_Upload=1&programId=#FORM.Contract_Main_ID#&FirstParentID=#GetTemplateInfo.First_parent_ID#&ClaimMechanics=#CSLGetContractInfo.ClaimMechanics#</cfoutput>";
		NewWindowTopLeft(sURL, "productRateList", "1000", "600", "no","no","yes", "yes");
	}

	/// 114617 :: Ideal Price START
	function idealPriceCal(prodID, typ, frm, CompID, rowID){
		/*
		prodID
			BSA FoodService Item Master ID
		typ
			0-- When Page loads: 1--Individual Item
		frm
			1--Ideal Price Discount, 2--Ideal Price Percentage, 3--Fixed Rate & Ideal Price Volume
		*/

		if(typ ==1){
			var ProdLen = 1;
			var ListofProd = prodID.split(',');
		}else{
			var ProdLen = $('#prodLen').val();
			var ListofProd = $('#prodList').val().split(',');
		}
		var CompID = CompID;

		for(i=0; i<ProdLen; i++){
			if(typ ==1){
				var j = rowID;
			}else{
				var j = i +1;
			}
			var prodID = ListofProd[i];
			var RatefieldName = 'fixed_C'+CompID+'_P'+prodID+'_1_rate';
			var UOMfieldName = 'fixed_C'+CompID+'_P'+prodID+'_1_uom';
			var UOM = $('select[name='+UOMfieldName+']').val();
			var IPName = 'fixed_'+prodID+'_'+j+'_IP';
			var IPDiff = 'fixed_'+prodID+'_'+j+'_IPD';
			var IPPer = 'fixed_'+prodID+'_'+j+'_IPDP';

			var fixedPrice = parseFloat($('#'+RatefieldName).val());
			var diffAmt = parseFloat($('#'+IPDiff).val());
			var diffPer = parseFloat($('#'+IPPer).val());

			var idealPrice = IPUOM(UOM, prodID, j);

			if(UOM ==1){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_CS#</cfoutput>;
			}else if(UOM ==2){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_LB#</cfoutput>;
			}else if(UOM ==5){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_EA#</cfoutput>;
			}else if(UOM ==6){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_CWT#</cfoutput>;
			}else{
				var decimalprecision = '4';
			}
			idealPrice = parseFloat(idealPrice).toFixed(decimalprecision);

			if( (fixedPrice > idealPrice) &  typ==0) {
				var diffAmount = parseFloat('0').toFixed(decimalprecision);
				var diffPercentage = parseFloat('0').toFixed(decimalprecision);
				$('#'+IPDiff).val(diffAmount);
				$('#'+IPPer).val(diffPercentage);
			}else{
				if(frm ==1){ //IDEAL PRICE DIFFERENCE
								var fixedRate = parseFloat(diffAmt) + parseFloat(idealPrice); 
								var diffAmount = parseFloat(diffAmt);
								$('#'+RatefieldName).val(fixedRate.toFixed(decimalprecision)); //ITEM RATE UPDATE
								if(fixedRate < idealPrice){
									$("#TR_Products").attr("attrbuteName");
								}
								if( isNaN(idealPrice) ){
									var diffPercentage = '0' ;
								}else{
									var diffPercentage = (( diffAmount / idealPrice )*100) ;
								}
					
						$('#'+IPPer).val(diffPercentage.toFixed(decimalprecision));//IDEAL PRICE DIFFERENCE PECENTAGE UPDATE
				}else if(frm ==2){ //IDEAL PRICE PERCENTAGE
					if( isNaN(idealPrice) ){
						var diffAmount = '0';
						var diffPercentage = '0';	
					}else{
						var diffAmount = (parseFloat(diffPer) * 0.01 * idealPrice);
						var diffPercentage = ( diffAmount / idealPrice)*100 ;
					}

						if(diffPer > '100'){
							diffPer = parseFloat('100').toFixed(decimalprecision);
							$('#'+IPPer).val(parseFloat('100').toFixed(decimalprecision));
						}
						if(diffPercentage > 0){
							var NewdiffAmount = parseFloat((parseFloat(diffPer) * parseFloat(diffAmount))/diffPercentage);
						}else{
							var NewdiffAmount = parseFloat('0');
						}
							$('#'+IPDiff).val(NewdiffAmount.toFixed(decimalprecision));//IDEAL PRICE UPDATE
							$('#'+IPPer).val(diffPercentage.toFixed(decimalprecision));//IDEAL PRICE DIFFERENCE PECENTAGE UPDATE
							var fixedRate = parseFloat(NewdiffAmount) + parseFloat(idealPrice);
							$('#'+RatefieldName).val(fixedRate.toFixed(decimalprecision)); //ITEM RATE UPDATE
				}else{ //REBATE RATE * IDEAL PRICE VOLUME
						var diffAmount = (fixedPrice - idealPrice);
						if(idealPrice != 0){
							var diffPercentage = (( diffAmount / idealPrice)*100) ;
						}else{
							var diffPercentage = parseFloat('0');
						} 
						if( isNaN(diffAmount) || (fixedPrice > idealPrice)){
							diffAmount = parseFloat('0');
							diffPercentage = parseFloat('0');
						}
						$('#'+IPDiff).val(diffAmount.toFixed(decimalprecision));
						$('#'+IPPer).val(diffPercentage.toFixed(decimalprecision));
				}
			}
		}
	}

	function IPUOM(UOM, prodID, j){
			//var UOM = $('select[name='+UOMfieldName+']').val();
			var IPCSField = 'fixed_'+prodID+'_'+j+'_IPCS';
			var IPLBField = 'fixed_'+prodID+'_'+j+'_IPLB';
			var CCField = 'case_count_'+prodID;
			var SCField = 'Sleeve_count_'+prodID;
			var NWField = 'net_weight_'+prodID;

		if(UOM == 1){ //1 CS
			var idealPrice = $('#'+IPCSField).val();
			}else if(UOM == 2){ //2 LB
				var idealPrice = $('#'+IPLBField).val();
			}else if(UOM == 5){//5 UN (EACHES)
				//(IdealPrice CS / CaseCount)
				var idealPriceCS = $('#'+IPCSField).val();
				var CaseCount = $('#'+CCField).val();
				var idealPrice =  ( idealPriceCS/CaseCount );
			}else if(UOM == 6){//6 CWT
				//( IdealPrice LB * 100.00 )
				var idealPrice =  (idealPriceLB * 100);
			}else if(UOM == 7){//7 SL
				//(IdealPrice CS / Sleeves_Count)
				var idealPriceCS = $('#'+IPCSField).val();
				var SleeveCount = $('#'+SCField).val();
				var idealPrice =  (idealPriceCS/SleeveCount);
			}
			return idealPrice;
	}
	function idealVolChange(Prodid, rowcnt,slopeCS,yinterceptCS,slopeLB,yinterceptLB,IPcomp_id){
		var Vol_CS_field = 'fixed_'+Prodid+'_VolumeCS';
		var Vol_LBS_field = 'fixed_'+Prodid+'_VolumeLB';
		var IPVol_Field = 'fixed_'+Prodid+'_IPVolume';
		var netWeight = $('#net_weight_'+Prodid).val();

		var Vol_CS = $('#'+Vol_CS_field).val().replace(/,/g, '');
		if (Vol_CS ==''){
			Vol_CS = 1;
		}
		var Vol_LBS = $('#'+Vol_LBS_field).val().replace(/,/g, '');
		if (Vol_LBS ==''){
			Vol_LBS = 1;
		}

		if(! $('#'+Vol_CS_field).prop('readonly')){
			$('#'+IPVol_Field).html(Vol_CS);
			 Vol_LBS = Vol_CS*netWeight;
			$('#'+Vol_LBS_field).val(Vol_LBS.toFixed());
		}else{
			$('#'+IPVol_Field).html(Vol_LBS);
			 Vol_CS = Vol_LBS/netWeight;
			$('#'+Vol_CS_field).val(Vol_CS.toFixed());
		}

		var Ideal_CS  = ((parseFloat(slopeCS) * parseFloat(Vol_CS) )+ parseFloat(yinterceptCS)).toFixed(<cfoutput>#request.settings.Decimal_display_for_CS#</cfoutput>);
		var Ideal_LB = ((parseFloat(slopeLB) * parseFloat(Vol_LBS) )+ parseFloat(yinterceptLB)).toFixed(<cfoutput>#request.settings.Decimal_display_for_LB#</cfoutput>);

		$('#'+Prodid+'_'+rowcnt+'_IdealCSPrice').html('$'+Ideal_CS+'/CS');
		$('#'+Prodid+'_'+rowcnt+'_IdealLBPrice').html('$'+Ideal_LB+'/LB');

		$('#fixed_'+Prodid+'_'+rowcnt+'_IPCS').val(Ideal_CS);
		$('#fixed_'+Prodid+'_'+rowcnt+'_IPLB').val(Ideal_LB);

		Vol_CS = $('#'+Vol_CS_field).val().replace(/,/g, '');
		Vol_LBS = $('#'+Vol_LBS_field).val().replace(/,/g, '');

		$('#'+Vol_CS_field).val(Number(Vol_CS).toLocaleString("en-US"));
		$('#'+Vol_LBS_field).val(Number(Vol_LBS).toLocaleString("en-US"));

			idealPriceCal(Prodid, 1, 4, IPcomp_id, rowcnt)
	}
	function MassApplyIP(CompID){
		var ProdLen = $('#prodLen').val();
		var ListofProd = $('#prodList').val().split(',');
		var CompID = CompID;

		var j = 0
		for(i=0; i<ProdLen; i++){
			var j = j + 1;
			var prodID = ListofProd[i];
			var CBName = "Prod_"+prodID;
			var UOMfieldName = 'fixed_C'+CompID+'_P'+prodID+'_1_uom';
			var UOM = $('select[name='+UOMfieldName+']').val();
			var IPDiff = 'fixed_'+prodID+'_'+j+'_IPD';
			var IPPer = 'fixed_'+prodID+'_'+j+'_IPDP';
			var RatefieldName = 'fixed_C'+CompID+'_P'+prodID+'_1_rate';

			if(UOM ==1){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_CS#</cfoutput>;
			}else if(UOM ==2){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_LB#</cfoutput>;
			}else if(UOM ==5){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_EA#</cfoutput>;
			}else if(UOM ==6){
				var decimalprecision = <cfoutput>#request.settings.Decimal_display_for_CWT#</cfoutput>;
			}else{
				var decimalprecision = '4';
			}

			if($('#'+CBName).is(':checked')){
				var idealPrice = IPUOM(UOM, prodID, j)
				idealPrice = parseFloat(idealPrice).toFixed(decimalprecision);
				$('#'+RatefieldName).val(idealPrice);
				$('#'+IPDiff).val(parseFloat('0').toFixed(decimalprecision));
				$('#'+IPPer).val(parseFloat('0').toFixed(decimalprecision));
			}
		}
	}
<cfif GetTemplateInfo.Ideal_Price>
	$(window).on('load', function() {
		idealPriceCal('',0, 3, <cfoutput>#IPcomp_id#</cfoutput>,0)
	});
</cfif>
</script>
<!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>