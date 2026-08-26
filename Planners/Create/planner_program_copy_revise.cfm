<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_program_copy_revise.cfm
Date:  		11/21/2016
Author:		Tim Ford
Purpose:  	Single Page Planner Program Copy/Revise
----------------------------------------------------------------------------------------------------------------------->

<cfsetting showdebugoutput="yes" />
<cfparam name="url.templateId" 				default="0" />
<cfparam name="form.templateId" 			default="#url.templateId#" />
<cfparam name="form.ProgramType_ID" 		default="#form.templateId#" />
<cfparam name="form.Perf_Start_Date" 		default="" />
<cfparam name="form.Perf_End_Date" 			default="" />
<cfparam name="form.Delivery_Start_Date" 	default="" />
<cfparam name="form.Delivery_End_Date"		default="" />
<cfparam name="form.Marketing_Event"		default="" />
<cfparam name="form.Notes"					default="" />

<cfparam name="form.lFixedCompIds"			default="" />
<cfparam name="form.lRebateCompIds" 		default="" />
<cfparam name="form.lLumpSumCompIds" 		default="" />
<cfparam name="form.strFixedData"			default="" />
<cfparam name="form.strRebateData" 			default="" />
<cfparam name="form.strLumpSumData" 		default="" />
<cfparam name="form.bSave" 					default="0" />
<cfparam name="form.Contract_Title" 		default="" />
<cfparam name="form.Product_Group_Level_ID"	default="" />
<cfparam name="form.Pricing_Level_ID" 		default="" />
<cfparam name="form.Product_Group_ID" 		default="" />
<cfparam name="url.Product_List" 			default="" />
<cfparam name="form.Product_List" 			default="#url.Product_List#" />
<cfparam name="url.programId" 				default="0" />
<cfparam name="form.programId" 				default="#url.programId#" />
<cfparam name="url.plannerId" 				default="" />
<cfparam name="form.plannerId" 				default="#url.plannerId#" />
<cfparam name="url.customerId" 				default="" />
<cfparam name="form.customerId" 			default="#url.customerId#" />
<cfparam name="url.Product_List_Type" 		default="9" />
<cfparam name="form.Product_List_Type" 		default="#url.Product_List_Type#" />
<cfparam name="url.bInit" 					default="0" />
<cfparam name="form.bFromCompPopUp"			default="0" />
<cfparam name="form.bSaveVolume" 			default="0" />
<cfparam name="form.bHasGroup" 				default="0" />
<cfparam name="form.bIsGroupItems" 			default="0" />
<cfparam name="form.bFormIsValid" 			default="1" />
<cfparam name="form.bFromGroupPopUp" 		default="0" />
<cfparam name="form.GroupLevel_1" 			default="#form.Product_List_Type#" />
<cfparam name="form.approved" 				default="0" />
<cfparam name="url.bCopy" 					default="0" />
<cfparam name="form.bCopy" 					default="#url.bCopy#" />
<cfparam name="url.bRevise" 				default="0" />
<cfparam name="form.bRevise" 				default="#url.bRevise#" />
<cfparam name="form.plTemplatedefaultUOM" 	default="1" />

<!--- Make sure discount component is lists don't have duplicates --->
<cfset form.lFixedCompIds = request.app_general_functions.listRemoveDupes(form.lFixedCompIds, ",") />
<cfset form.lRebateCompIds = request.app_general_functions.listRemoveDupes(form.lRebateCompIds, ",") />
<cfset form.lLumpSumCompIds = request.app_general_functions.listRemoveDupes(form.lLumpSumCompIds, ",") />


<!---form.programIdCopyRevise--->
<cfset form.programIdCopyRevise = listFirst(form.programId) />
<cfset form.programId = 0 />

<cfscript>
	oProgram                = CreateObject("component", "components.programs.program");
	oProduct                = CreateObject("component", "components.products.ProductManager");
	oDistributor            = CreateObject("component", "components.programs.distributors.Distributor");
	oPlannerSettings        = CreateObject("component", "mvc.Models.Planner.PlannerSettingsManager");
	oProgramComponents      = CreateObject("component", "components.programcomponents.programcomponents");
	oTemplateComponents     = CreateObject("component", "components.programs.template.TemplateManager");
	oUom                    = CreateObject("component", "components.programs.rebates.uom");
	oPlannerManager 		= CreateObject("component","mvc.Models.Planner.PlannerManager");
	oPlannerProgram 		= CreateObject("component", "mvc.Models.Planner.PlannerProgramManager");
</cfscript>


<!--- save program data --->
<cfif form.bSave eq 1>

	<cfset bNewProgram = form.programId />
	<cfset form.lFixedCompIds = request.app_general_functions.listRemoveDupes(form.lFixedCompIds, ",") />
	<cfset form.lRebateCompIds = request.app_general_functions.listRemoveDupes(form.lRebateCompIds, ",") />
	<cfset form.lLumpSumCompIds = request.app_general_functions.listRemoveDupes(form.lLumpSumCompIds, ",") />

	<cfset form.programId	= oPlannerProgram.saveProgramPlannerData(form) />
	<cfset form.bSave 		= 0 />

	<cfset qGetPlannerVolumeData	= oPlannerProgram.getProgramPlannerVolumeData(form.programId) />

	<cfloop index="idx" list="#form.Product_List#">

		<cfquery name="qGetVol" dbtype="query">
			SELECT	*
			FROM	qGetPlannerVolumeData
			WHERE	BSA_Foodservice_Items_Master_ID = '#idx#'
		</cfquery>

		<cfif qGetVol.Volume_CS eq "">
			<cfset volVal = 0 />
		<cfelse>
			<cfset volVal = qGetVol.Volume_CS />
		</cfif>
		<cfset form["vol." & idx] = volVal />

	</cfloop>

</cfif>


<cfscript>
    qGetData 				= oPlannerProgram.getProgramPlannerData(form.programIdCopyRevise);

    if(form.programIdCopyRevise neq 0 and form.plannerId eq ""){
        form.plannerId = qGetData.Planner_ID;
    }

    if(form.programIdCopyRevise neq 0 and form.templateId eq 0){
        form.templateId = qGetData.ProgramType_ID;
    }

    qGetPlannerData 		= oPlannerManager.getPlanner( plannerID=form.plannerId);

    if(form.plannerId neq 0 and form.customerId eq ""){
        form.customerId = qGetPlannerData.BSA_FoodService_Customers_ID;
    }

    qGetProgramUserSettings = oProgram.getProgramUserSettings();
	qGetProducts            = oPlannerProgram.getproducts(Form.Product_List, form.Product_List_Type);
	qGetPlannerPerfTypes    = oPlannerSettings.getPerfTypeInfo();
	qGetDistributor         = oDistributor.getDistributor(form.customerId);
	qGetTemplates           = oTemplateComponents.getAllDiscountTypes(form.templateId);
	qGetPlannerProfileData 	= oPlannerManager.getPlannerProfile( plannerID=form.plannerId );
	oGetTemplateData        = oTemplateComponents.get(form.templateId);
	qGetUnitPriceData 		= oPlannerProgram.getUnitPrice(form.programIdCopyRevise);

	form.plTemplatedefaultUOM	= qGetPlannerData.UOM_Default;



	if(form.programIdCopyRevise neq 0){
		qGetProgramData			= oProgram.getProgramInfo(form.programIdCopyRevise);
		form.approved			= qGetProgramData.Approved;
	}

	gGetProdGroupAttr		= oPlannerSettings.getProductGroupTypeData();
</cfscript>

<cf_layout_planner_program jQueryUI="1.11.4" page_title="Planner Create">

<cf_include files="/Script/javascript/gridviewScroll.min.js">

<cfquery name="gGetExpMargin" dbtype="query">
	SELECT DISTINCT Planner_Expected_Margin
	FROM qGetPlannerProfileData
</cfquery>


<cfset qGetData = oPlannerProgram.getProgramPlannerData(form.programIdCopyRevise) />

<cfif form.bCopy eq 1>
	<CFINCLUDE TEMPLATE="/Common_Files/contracts/contract_number_generator.cfm">
	<cfset form.Contract_Number = generator_contract_number />
<cfelse>
	<cfset qGetData = oPlannerProgram.getProgramPlannerData(form.programIdCopyRevise) />
	<cfset form.Contract_Number = qGetData.Contract_Number />
</cfif>


<!--- Check if the template allows fixed --->
<cfquery name="qHasFixedComp" dbtype="query">
	SELECT * FROM qGetTemplates WHERE Discount_Type_ID = 1
</cfquery>
<!--- Check if the template allows rebate --->
<cfquery name="qHasRebateComp" dbtype="query">
	SELECT * FROM qGetTemplates WHERE Discount_Type_ID = 2
</cfquery>
<!--- Check if the template allows lump sum --->
<cfquery name="qHasLumpComp" dbtype="query">
	SELECT * FROM qGetTemplates WHERE Discount_Type_ID = 3
</cfquery>

<cfif form.bSaveVolume>
	<cfscript>
		oPlannerProgram.saveProgramPlannerVolumeData(form);
		form.bSaveVolume = 0;
	</cfscript>
</cfif>

<cfif form.bFromGroupPopUp eq 1>
	<cfset form.Product_List_Type = form.GroupLevel_1 />
	<cfset form.bFromGroupPopUp = 0 />
</cfif>
<!---
Component List variables data structure. Delimited list separated by an _
compNameId	rate	uom	Component_Paid_To	PaymentCycle	lump_sum_apply_to
--->
<cfif form.bFromCompPopUp>
	<!--- Fixed --->
	<cfif len(trim(form.strFixedData))>

		<cfset form.lFixedCompIds = listAppend(form.lFixedCompIds, ListGetAt(form.strFixedData, 1, "_")) />

		<cfloop index="idx" list="#form.Product_List#">

			<cfset "form.fixed_comp_#ListGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strFixedData, 1, "_") />
			<cfset "form.fixed_rate_#ListGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strFixedData, 2, "_") />
			<cfset "form.fixed_uom_#ListGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 					= ListGetAt(form.strFixedData, 3, "_") />
			<cfset "form.fixed_component_paid_to_#ListGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 	= ListGetAt(form.strFixedData, 4, "_") />
			<cfset "form.fixed_paymentcycle_#ListGetAt(form.strFixedData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 		= ListGetAt(form.strFixedData, 5, "_") />

		</cfloop>

		<cfset form.strFixedData 	= "" />
		<cfset form.bFromCompPopUp 	=  0/>

	<!--- Rebate --->
	<cfelseif len(trim(form.strRebateData))>

		<cfset form.lRebateCompIds = listAppend(form.lRebateCompIds, ListGetAt(form.strRebateData, 1, "_")) />

		<cfloop index="idx" list="#form.Product_List#">

			<cfset "form.rebate_comp_#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strRebateData, 1, "_") />
			<cfset "form.rebate_rate_#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strRebateData, 2, "_") />
			<cfset "form.rebate_uom_#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strRebateData, 3, "_") />
			<cfset "form.rebate_component_paid_to_#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#"	= ListGetAt(form.strRebateData, 4, "_") />
			<cfset "form.rebate_paymentcycle_#ListGetAt(form.strRebateData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 		= ListGetAt(form.strRebateData, 5, "_") />

		</cfloop>

		<cfset form.strRebateData 	= "" />
		<cfset form.bFromCompPopUp 	=  0/>

	<!--- Lump Sum --->
	<cfelseif len(trim(form.strLumpSumData))>

		<cfset form.lLumpSumCompIds = listAppend(form.lLumpSumCompIds, ListGetAt(form.strLumpSumData, 1, "_")) />
		<cfset lsApplyTo = ListGetAt(form.strLumpSumData, 6, "_") />

		<cfif lsApplyTo eq "1">
			<cfset lsRateVal = ListGetAt(form.strLumpSumData, 2, "_") />
		<cfelse>
			<cfset lsRateVal = ListGetAt(form.strLumpSumData, 2, "_") / listLen(form.Product_List) />
		</cfif>

		<cfloop index="idx" list="#form.Product_List#">

			<cfset "form.lump_sum_comp_#ListGetAt(form.strLumpSumData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strLumpSumData, 1, "_") />
			<cfset "form.lump_sum_rate_#ListGetAt(form.strLumpSumData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= lsRateVal />
			<cfset "form.lump_sum_uom_#ListGetAt(form.strLumpSumData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 				= ListGetAt(form.strLumpSumData, 3, "_") />
			<cfset "form.lump_sum_component_paid_to_#ListGetAt(form.strLumpSumData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#"	= ListGetAt(form.strLumpSumData, 4, "_") />
			<cfset "form.lump_sum_paymentcycle_#ListGetAt(form.strLumpSumData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 		= ListGetAt(form.strLumpSumData, 5, "_") />
			<cfset "form.lump_sum_apply_to_#ListGetAt(form.strLumpSumData, 1, "_")#_#Replace(idx, "-", "_", "ALL")#" 			= ListGetAt(form.strLumpSumData, 6, "_") />

		</cfloop>

		<cfset form.strLumpSumData 	= "" />
		<cfset form.bFromCompPopUp 	=  0/>

	</cfif>

</cfif>

<!--- Run this code when planner program created gets called from calendar or volume plan --->
<cfif url.bInit eq 1>

	<cfscript>
		qGetProdData = oPlannerProgram.getProgramPlannerProductData(form.programIdCopyRevise);
		qGetFixedData = oPlannerProgram.getProgramPlannerFixedData(form.programIdCopyRevise);
		qGetRebateData = oPlannerProgram.getProgramPlannerRebateData(form.programIdCopyRevise);
		qGetLumpSumData = oPlannerProgram.getProgramPlannerLumpSumData(form.programIdCopyRevise);
		gGetProductGroupType = oPlannerProgram.getProgramProductGroupType(form.programIdCopyRevise);
		qGetPlannerVolumeData	= oPlannerProgram.getProgramPlannerVolumeData(form.programIdCopyRevise);

		form.plannerId 				= qGetData.Planner_Id;
		form.Contract_Title 		= qGetData.Contract_Title;
		form.Perf_Start_Date 		= dateformat(qGetData.Contract_Start_Date, "m/d/yyyy");
		form.Perf_End_Date 			= dateformat(qGetData.Contract_End_Date, "m/d/yyyy");
		form.Notes 					= qGetData.Notes;
		form.Planner_Perf_Types_ID	= qGetData.Planner_Perf_Type_ID;

		//set product group level fields only if whe get a record set
		if(gGetProductGroupType.RecordCount){
			form.Product_List_Type		= gGetProductGroupType.Product_Group_Level_ID;
			form.GroupLevel_1			= gGetProductGroupType.Product_Group_Level_ID;
		}

		form.Delivery_Start_Date	= dateformat(qGetData.Delivery_Start_Date, "m/d/yyyy");
		form.Delivery_End_Date		= dateformat(qGetData.Delivery_End_Date, "m/d/yyyy");

	</cfscript>

	<!--- loop over the data and map form fields --->

	<!--- fixed mappings start--->
	<cfquery name="qGetFixedCompId" dbtype="query">
		SELECT 	DISTINCT compNameId, uom
		FROM	qGetFixedData
	</cfquery>

	<cfloop query="qGetFixedCompId">

		<cfset form.lFixedCompIds = listAppend(form.lFixedCompIds, "#qGetFixedCompId.compNameId#") />

		<cfloop query="qGetFixedData">

			<cfset qGet = oPlannerProgram.getProgramPlannerFixedData(form.programIdCopyRevise, trim(qGetFixedCompId.compNameId), qGetFixedData.BSA_FOODSERVICE_Items_Master_ID) />
			<cfset "form.fixed_comp_#qGetFixedData.compNameId#_#Replace(qGetFixedData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" =  qGet.compNameId />
			<cfset "form.fixed_uom_#qGetFixedData.compNameId#_#Replace(qGetFixedData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = uom />
			<cfset "form.fixed_component_paid_to_#qGetFixedData.compNameId#_#Replace(qGetFixedData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Component_Paid_To />
			<cfset "form.fixed_paymentcycle_#qGetFixedData.compNameId#_#Replace(qGetFixedData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.PaymentCycle />
			<cfset "form.fixed_rate_#qGetFixedData.compNameId#_#Replace(qGetFixedData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Rate />

		</cfloop>
	</cfloop>
	<!--- fixed mappings end--->

	<!--- rebate mappings start--->
	<cfquery name="qGetRebateCompId" dbtype="query">
		SELECT 	DISTINCT compNameId, uom
		FROM	qGetRebateData
	</cfquery>
	<cfloop query="qGetRebateCompId">

		<cfset form.lRebateCompIds = listAppend(form.lRebateCompIds, "#qGetRebateCompId.compNameId#") />

		<cfloop query="qGetRebateData">

			<cfset qGet = oPlannerProgram.getProgramPlannerRebateData(form.programIdCopyRevise, trim(qGetRebateCompId.compNameId), qGetRebateData.BSA_Foodservice_Items_Master_ID) />
			<cfset "form.rebate_comp_#qGetRebateData.compNameId#_#Replace(qGetRebateData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" =  qGet.compNameId />
			<cfset "form.rebate_uom_#qGetRebateData.compNameId#_#Replace(qGetRebateData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = uom />
			<cfset "form.rebate_component_paid_to_#qGetRebateData.compNameId#_#Replace(qGetRebateData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Component_Paid_To />
			<cfset "form.rebate_paymentcycle_#qGetRebateData.compNameId#_#Replace(qGetRebateData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.PaymentCycle />
			<cfset "form.rebate_rate_#qGetRebateData.compNameId#_#Replace(qGetRebateData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Rate />

		</cfloop>
	</cfloop>
	<!--- rebate mappings end--->

	<!--- lump sum mappings start--->
	<cfquery name="qGetLumpSumCompId" dbtype="query">
		SELECT 	DISTINCT compNameId, uom
		FROM	qGetLumpSumData
	</cfquery>
	<cfloop query="qGetLumpSumCompId">

		<cfset form.lLumpSumCompIds = listAppend(form.lLumpSumCompIds, "#qGetLumpSumCompId.compNameId#") />
		<cfloop query="qGetLumpSumData">

			<cfset qGet = oPlannerProgram.getProgramPlannerLumpSumData(form.programIdCopyRevise, trim(qGetLumpSumData.compNameId), qGetLumpSumData.BSA_Foodservice_Items_Master_ID) />
			<cfset "form.lump_sum_comp_#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" =  qGet.compNameId />
			<cfset "form.lump_sum_uom_#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = uom />
			<cfset "form.lump_sum_component_paid_to_#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Component_Paid_To />
			<cfset "form.lump_sum_paymentcycle_#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.PaymentCycle />
			<cfset "form.lump_sum_rate_#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Rate />
			<cfset "form.lump_sum_apply_to_#qGetLumpSumData.compNameId#_#Replace(qGetLumpSumData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGet.Product_Option />

		</cfloop>

	</cfloop>
	<!--- lump sum mappings start--->

	<cfset Form.Product_List	= ValueList(qGetProdData.BSA_Foodservice_Items_Master_ID) />
	<cfset qGetProducts			= oPlannerProgram.getproducts(Form.Product_List, form.Product_List_Type) />

	<cfloop index="idx" list="#form.Product_List#">

		<cfquery name="qGetVol" dbtype="query">
			SELECT	*
			FROM	qGetPlannerVolumeData
			WHERE	BSA_Foodservice_Items_Master_ID = '#idx#'
		</cfquery>

		<cfif qGetVol.Volume_CS eq "">
			<cfset volVal = 0 />
		<cfelse>
			<cfset volVal = qGetVol.Volume_CS />
		</cfif>
		<cfset form["vol." & idx] = volVal />

	</cfloop>

	<!--- Make sure discount component is lists don't have duplicates --->
	<cfset form.lFixedCompIds = request.app_general_functions.listRemoveDupes(form.lFixedCompIds, ",") />
	<cfset form.lRebateCompIds = request.app_general_functions.listRemoveDupes(form.lRebateCompIds, ",") />
	<cfset form.lLumpSumCompIds = request.app_general_functions.listRemoveDupes(form.lLumpSumCompIds, ",") />

</cfif>

<!--- If we don't have a title then default it to nickname/marketing event/performance type --->
<cfif trim(form.Contract_Title) eq "">
	<cfset form.Contract_Title = qGetPlannerProfileData.Planner_NickName />
</cfif>

<cfquery name="qCheckGroup" datasource="#application.datasource#">
	SELECT	*
	FROM	Contract_Products
	WHERE	Contract_Main_ID = '#form.programIdCopyRevise#'
	AND		Deleted = 0
	AND		Is_Group = 1
</cfquery>

<cfif qCheckGroup.RecordCount>
	<cfset form.bHasGroup = 1 />
</cfif>

<cfset qCheckIsGroupItems	= oPlannerProgram.checkIfGroupItems(Form.Product_List) />
<cfset form.bIsGroupItems	= qCheckIsGroupItems />

<cfset bIsEDLP = 0 />
<cfif isDefined("qGetData.Planner_Perf_Type_ID") and IsNumeric(qGetData.Planner_Perf_Type_ID)>
    <cfset bIsEDLP = oPlannerProgram.isEDLP(qGetData.Planner_Perf_Type_ID) />
</cfif>

<!--- <link rel="stylesheet" type="text/css" href="/common_files/datatable.css"> --->
<!--- <cfinclude template="\common_files\DataTables2.cfm"> --->

<script>

	function showProductSearchWindow() {

		var bShowProd = true;
		var bIsGroupItems = document.MyForm.bIsGroupItems.value;
		var prodList = document.MyForm.Product_List.value;

		if(prodList != '' && bIsGroupItems != 0){
			bShowProd = false;
		}

		if (bShowProd == false){
			alert("Cannot add products with groups");
		}
		else{
			popupInCenter("/Common_Files/contracts/product_Select_V1.cfm?Formname=MyForm&SourceCaller=MyForm", "programPlannerProductWindow", 1300, 800);
			document.MyForm.bSaveVolume.value = 1;
		}
	}

	function showGroupSearchWindow()
	{
		var bShowGroup = true;
		var bIsGroupItems = document.MyForm.bIsGroupItems.value;
		var prodList = document.MyForm.Product_List.value;

		if(prodList != '' && bIsGroupItems == 0){
			bShowGroup = false;
		}

		if (bShowGroup == false){
			alert("Cannot add groups with products");
		}
		else{
			NewWindow("/Common_Files/contracts/Groups/index.cfm?formName=MyForm&programId=<cfoutput>#form.programIdCopyRevise#</cfoutput>", "groupproductwindow", 800, 700, "yes", "yes");
			document.MyForm.bSaveVolume.value = 1;
			document.MyForm.bFromGroupPopUp.value = 1;
		}
	}

	function showComponentSelect(discountType) {
		var dt = discountType;
		var cl;

		if (discountType == 1){
			cl =  document.MyForm.lFixedCompIds.value;
		}
		else if (discountType == 2){
			cl = document.MyForm.lRebateCompIds.value;
		}
		else if (discountType == 3){
			cl = document.MyForm.lLumpSumCompIds.value;
		}

		NewWindow("/planners/create/component_select.cfm?templateId=<cfoutput>#form.templateId#&programId=#form.programIdCopyRevise#</cfoutput>&discountType=" + dt + "&compList=" + cl, "plannercomponentselect", 800, 150, "yes", "yes", true);
	}

	function removeComponent(id, strVal, discountType) {

		var objInp;

		if (discountType == 1){
			objInp = document.MyForm.lFixedCompIds;
		}
		else if (discountType == 2){
			objInp = document.MyForm.lRebateCompIds;
		}
		else if(discountType == 3){
			objInp = document.MyForm.lLumpSumCompIds;
		}

		var str = objInp.value;
		var str2 = "";
		var aRray = str.split(",");
		var i, arrLen;

		objInp.value = "";
		arrLen = aRray.length;

		for(i=0;i<arrLen;i++)
		{
			if(aRray[i] != strVal && aRray[i] != "")
			{
				str2 = str2 + aRray[i] + ",";
			}
		}

		objInp.value = str2;
		$("tr").remove("#" + id);

		return;
	}

	function removeProduct(id, itemGUID) {

		var str = document.MyForm.Product_List.value;

		var str2 = "";
		var aRray = str.split(",");
		var i, arrLen;

		$( "#customContainer" ).show();

		document.MyForm.Product_List.value = "";
		document.MyForm.ExistingProductList.value = "";

		arrLen = aRray.length;

		for(i=0;i<arrLen;i++)
		{
			if(aRray[i] != itemGUID && aRray[i] != "")
			{
				str2 = str2 + aRray[i] + ",";
			}
		}

		document.MyForm.Product_List.value = str2;
		document.MyForm.ExistingProductList.value = str2;

		$("td").remove("#" + id);
		document.MyForm.submit();
	}


</script>

<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="#Now()#">
<cfset Cache_Control_Header_Already_Added = 1>


<style>
	#top100 { border-bottom: 1px solid #CCC; padding-bottom: 10px; width: 100%; height: 140px; margin-top: 10px; }
	#top100 > div { float:left; line-height: 26px; }
	#top100 label { text-align: right; width: 33%; display: inline-block; position: relative; padding-right: 10px; font-weight: bold; letter-spacing: 0.3px; }
	#top100 input, #top100 select { width: 60%; }
	#top100 textarea { width: 80%; }
	#top100 a { letter-spacing: 0.5px; width:90%; display: block; padding: 0 5px 5px 25px; }
	#top100 .date { width: 20%; }
	#top102, #top104, #top106, #top108 { width: 25%; }
	#mid100 { border-bottom2: 1px solid #CCC; padding-bottom: 5px; width: 100%; height2: 500px; }
	#bot100 { width: 100%; display: none; }
	#mid100 div { float:left; border-bottom: 1px dotted #CCC; padding-bottom2: 5px; }
	#bot100 div { float:left; }


	table.pgrid { table-layout: fixed; width:100%; border-collapse:collapse; }
	table.pgrid td, table.pgrid th { padding:3px; vertical-align:middle; width:150px; min-width:150px; }
	table.pgrid th { font-weight:bold; background-color2:#ffce84; text-align:right; vertical-align:top !important;}
	table.pgrid th.frozen2 { background-color2: white; text-align: left; height2: 30px; vertical-align:middle; width:150px; }

	table.pgrid td.header2 { font-weight:bold; letter-spacing:0.25px; background-color2:#ffce84; text-align:right; vertical-align:top !important; }
	table.pgrid td.numeric { text-align: right !important; }
	table.pgrid td.numeric div { float:right !important; }
	td.numeric input { width: 40%; text-align:right; }

	.GridviewScrollHeader TH, .GridviewScrollHeader TD {
	    padding: 5px;
	    font-weight: bold;
	    white-space: nowrap;
	    border-right: 0px solid #CCC;
	    border-bottom: 0px solid #CCC;
	    background-color: #4F81BD;
	    color: white;
	    vertical-align: middle;
	    height: 36px !important;
	}
	.GridviewScrollHeader div {
		margin:3px 0 0 3px;
	}

	.GridviewScrollItem TD {
	    padding: 5px;
	    white-space: nowrap;
	    border-right: 1px dotted #CCC;
	    border-bottom: 1px dotted #CCC;
	    background-color: #FFFFFF;
	    height: 30px !important;
	}
	.GridviewScrollPager {
    	border-top: 1px solid #AAAAAA;
    	background-color: #FFFFFF;
	}
	.GridviewScrollPager TD {
	    padding-top: 3px;
	    font-size: 14px;
	    padding-left: 5px;
	    padding-right: 5px;
	}
	.GridviewScrollPager A {
    	color: #666666;
	}
	.GridviewScrollPager SPAN {
	    font-size: 16px;
	    font-weight: bold;
	}

	#pgridFreeze div { font-weight: bold !important; }
	i.volume { cursor: pointer; color:blue; }
	i.cut { font-size: 1.5em; color: #00ff00; cursor: pointer;}
	a.discount { letter-spacing: 0.25px; font-weight: bold; cursor: pointer; }
	.redDisplay {  color: #ff0000;}
	.greenDisplay {  color: #008000;}

</style>

<cfoutput>
<FORM ACTION="planner_program_create.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<div id="top100">
		<div id="top102">
			    <label>#Application.PlannerPrgLabel# ##</label>
				 <input type="text" disabled value="#form.Contract_Number#"> <input name="Contract_Number" type="hidden" value="#form.Contract_Number#" />
			    <label>Perf Type</label>
				 <select name="Planner_Perf_Types_ID" tabindex="2">
										<cfloop query="qGetPlannerPerfTypes">
											<cfquery name="gGetPerfData" dbtype="query">
												SELECT	Duration * 7 as Duration,
														Planner_Delivery_Days_Start,
														Planner_Delivery_Days_End
												FROM	qGetPlannerProfileData
												WHERE	Planner_Perf_Types_ID = #Planner_Perf_Types_ID#
											</cfquery>
											<option	value="#Planner_Perf_Types_ID#"
													Duration="#gGetPerfData.Duration#"
													deliveryDaysStart="#gGetPerfData.Planner_Delivery_Days_Start#"
													deliveryDaysEnd="#gGetPerfData.Planner_Delivery_Days_End#"
													<cfif isDefined("qGetData.Planner_Perf_Type_ID") && qGetData.Planner_Perf_Type_ID eq qGetPlannerPerfTypes.Planner_Perf_Types_ID > selected </cfif>
											> #Description#
											</option>
										</cfloop>
									 </select>
			    <label>Perf Start</label>
				<cfif trim(FORM.Perf_Start_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				 <input type="text" class="date" name="Perf_Start_Date" value="#FORM.Perf_Start_Date#" tabindex="4"> <br>
			    <label>Delivery Start</label>
				<cfif trim(FORM.Delivery_Start_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				 <input type="text" class="date" name="Delivery_Start_Date" value="#FORM.Delivery_Start_Date#" tabindex="6"> <br>
			    <label>Budget</label>
				 <input type="text" disabled>
		</div>
		<div id="top104">
			    <label>Title</label>
				 <input name="Contract_Title" type="text" value="#form.Contract_Title#" tabindex="1" />
			    <label>Marketing Event</label>
				 <input name="Marketing_Event" type="text" value="#form.Marketing_Event#" tabindex="3" />
			    <label>Perf End</label>
				<cfif trim(FORM.Perf_End_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				 <input type="text" class="date" name="Perf_End_Date" value="#FORM.Perf_End_Date#" tabindex="5" /> <br>
			    <label>Delivery End</label>
				<cfif trim(FORM.Delivery_End_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				 <input type="text" class="date" name="Delivery_End_Date" value="#FORM.Delivery_End_Date#" tabindex="7"> <br>
		</div>
		<div id="top106">
			    <label style="text-align:left;display:inline;vertical-align:top;">Notes</label>
				<textarea rows=7 name="notes">#form.notes#</textarea>
		</div>
		<div id="top108">
			<a onclick="return validate_form();" href="##">#application.util.string.LinkFormat("save")#</a>
			<a onClick="return showProductSearchWindow();" href="##">#application.util.string.LinkFormat("add products")#</a>
			<cfif oGetTemplateData.Allow_Product_Group_Search eq 1>
				<a onClick="return showGroupSearchWindow();" href="##">#application.util.string.LinkFormat("add groups")#</a>
			</cfif>
		</div>
	</div>

	<div id="mid100" class="productBody">
		<table class="pgrid" id="pgrid" cellspacing="0">
			<!--- <thead> --->
				<tr class="GridviewScrollHeader">
					<th>Products/Groups</th>
					<cfloop query="qGetProducts">
						<th title="#qGetProducts.description#">#(qGetProducts.item eq "" ? "" : qGetProducts.item & "<br>")##application.util.string.fullLeft(qGetProducts.description,20)#
						<a onClick="javascript: return removeProduct('item_#item#', '#BSA_Foodservice_Items_Master_ID#');" style="cursor:pointer;"><i class="fa fa-trash-o cut"></i></a> </th>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>
			<!--- </thead>
			<tbody> --->
				<!------------->
				<!--- PRICE --->
				<!------------->
				<tr class="GridviewScrollItem">
					<td>Price</td>
					<cfloop query="qGetProducts">
						<cfset nPrice = oPlannerProgram.getnPrice( qGetProducts.item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM)>
						<td class="numeric">#DollarFormat(nPrice.val)# #nPrice.uom#</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!---------------->
				<!--- EDLP/TPR --->
				<!---------------->
            <cfif not bIsEDLP>
				<tr class="GridviewScrollItem">
					<td>EDLP/TPR</td>
					<cfloop query="qGetProducts">
						<cfset nPrice = oPlannerProgram.getnEDLPPrice(qGetProducts.BSA_Foodservice_Items_Master_ID, form.plannerId, form.Contract_Number) />
						<td class="numeric">#DollarFormat(nPrice.Everyday_Low_Price)#</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>
            </cfif>

				<!------------------->
				<!--- FIXED PRICE --->
				<!------------------->
				<cfif qHasFixedComp.RecordCount>
					<tr class="GridviewScrollItem">
						<td><a onClick="javascript: return showComponentSelect(1);" title="click to add fixed price" class="discount"><i class="fa fa-plus-square"></i> Fixed Price </a></td>
						<cfloop query="qGetProducts">
							<td>&nbsp;</td>
						</cfloop> <!---  query="qGetProducts" --->
					</tr>
					<cfloop index="fixIndx" list="#form.lFixedCompIds#">
						<cfset thisFixedId = ListGetAt(fixIndx, 1, "_") />
						<tr id="fx_#thisFixedId#" class="GridviewScrollItem">
							<td>
								<a onClick="javascript: return removeComponent('fx_#thisFixedId#', '#fixIndx#', 1);" style="cursor:pointer;"><img src="/Images/scissor.gif" width="14" height="9" border="0"></a>
								<cfset qGetCompData = oProgramComponents.GetComponentDetails(thisFixedId, 1) />
								#qGetCompData.Component_Name#
							</td>
							<cfloop query="qGetProducts">
								<td class="numeric">
									<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
									<cfparam name="form.fixed_rate_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.fixed_comp_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.fixed_uom_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.fixed_component_paid_to_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.fixed_paymentcycle_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfset thisFixedRate = "#evaluate("form.fixed_rate_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisFixedComp = "#evaluate("form.fixed_comp_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisFixedUom = "#evaluate("form.fixed_uom_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisFixedPaidTo = "#evaluate("form.fixed_component_paid_to_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisFixedPaymentCycle = "#evaluate("form.fixed_paymentcycle_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#")#" />

									<cfset thisFixedRate = ListFirst(thisFixedRate) />
									<cfset thisFixedUom = ListFirst(thisFixedUom) />

									<cfif thisFixedUom neq form.plTemplatedefaultUOM>
										<cfif form.plTemplatedefaultUOM eq 1>
											<cfset thisFixedSumRate = thisFixedRate * qGetProducts.Net_Weight />
										<cfelse>
											<cfset thisFixedSumRate = thisFixedRate / qGetProducts.Net_Weight />
										</cfif>
									<cfelse>
										<cfset thisFixedSumRate = thisFixedRate />
									</cfif>

									<cfset "local.discountSum_#thisStripGUID#" = thisFixedSumRate />

									<!---compNameId	rate	uom	Component_Paid_To	PaymentCycle--->
									<input name="fixed_comp_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" value="#thisFixedComp#" type="hidden" />
									<input name="fixed_uom_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" value="#thisFixedUom#" type="hidden" />
									<input name="fixed_component_paid_to_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" value="#thisFixedPaidTo#" type="hidden" />
									<input name="fixed_paymentcycle_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#" value="#thisFixedPaymentCycle#" type="hidden" />
									$
									<input
										name="fixed_rate_#ListGetAt(fixIndx, 1, "_")#_#thisStripGUID#"
										type="text"
										value="#NumberFormat(thisFixedRate, "_.__")#"
										class="rightColumn discountRate"
										guid="#thisStripGUID#"
										nPrice_#thisStripGUID#="#oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM).val#"
										<cfif not form.bFormIsValid>
											disabled
										</cfif>
									>
									&nbsp;#oUom.getUomAbbr(thisFixedUom)#
								</td>
							</cfloop> <!---  query="qGetProducts" --->
						</tr>
					</cfloop>
				</cfif> <!--- qHasFixedComp.RecordCount> --->

				<!-------------->
				<!--- REBATE --->
				<!-------------->
				<cfif qHasRebateComp.RecordCount>
					<tr class="GridviewScrollItem">
						<td><a onClick="javascript: return showComponentSelect(2);" title="click to add rebate" class="discount"><i class="fa fa-plus-square"></i> Rebate </a></td>
						<cfloop query="qGetProducts">
							<td>&nbsp;</td>
						</cfloop> <!---  query="qGetProducts" --->
					</tr>
					<cfloop index="rebIndx" list="#form.lRebateCompIds#">
						<cfset thisRebId = ListGetAt(rebIndx, 1, "_") />
						<tr id="r_#thisRebId#" class="GridviewScrollItem">
							<td>
								<a onClick="javascript: return removeComponent('r_#thisRebId#', '#rebIndx#', 2);" style="cursor:pointer;"><img src="/Images/scissor.gif" width="14" height="9" border="0"></a>
								<cfset qGetCompData = oProgramComponents.GetComponentDetails(thisRebId, 2) />
								#qGetCompData.Component_Name#
							</td>
							<cfloop query="qGetProducts">
								<td class="numeric">
									<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
									<cfparam name="form.rebate_rate_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" default="0" />
									<cfparam name="form.rebate_comp_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.rebate_uom_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" default="1" />
									<cfparam name="form.rebate_component_paid_to_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.rebate_paymentcycle_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfset thisRebRate = "#evaluate("form.rebate_rate_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisRebComp = "#evaluate("form.rebate_comp_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisRebUom = "#evaluate("form.rebate_uom_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisRebPaidTo = "#evaluate("form.rebate_component_paid_to_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisRebPaymentCycle = "#evaluate("form.rebate_paymentcycle_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#")#" />

									<cfset thisRebRate = ListFirst(thisRebRate) />
									<cfset thisRebUom = ListFirst(thisRebUom) />
									<cfparam name="local.discountSum_#thisStripGUID#" default="0" />

									<cfif thisRebUom neq form.plTemplatedefaultUOM>
										<cfif form.plTemplatedefaultUOM eq 1>
											<cfset thisRebateSumRate = thisRebRate * qGetProducts.Net_Weight />
										<cfelse>
											<cfset thisRebateSumRate = thisRebRate / qGetProducts.Net_Weight />
										</cfif>
									<cfelse>
										<cfset thisRebateSumRate = thisRebRate />
									</cfif>

									<cfset "local.discountSum_#thisStripGUID#" = local[ "discountSum_" & thisStripGUID] + thisRebateSumRate />

									<!---compNameId	rate	uom	Component_Paid_To	PaymentCycle--->
									<input name="rebate_comp_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" value="#thisRebComp#" type="hidden" />
									<input name="rebate_uom_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" value="#thisRebUom#" type="hidden" />
									<input name="rebate_component_paid_to_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" value="#thisRebPaidTo#" type="hidden" />
									<input name="rebate_paymentcycle_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#" value="#thisRebPaymentCycle#" type="hidden" />
									$
									<input
										name="rebate_rate_#ListGetAt(rebIndx, 1, "_")#_#thisStripGUID#"
										type="text"
										value="#NumberFormat(thisRebRate, "_.__")#"
										class="rightColumn discountRate"
										guid="#thisStripGUID#"
										nPrice_#thisStripGUID#="#oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM).val#"
										<cfif not form.bFormIsValid>
											disabled
										</cfif>
									>
									&nbsp;#oUom.getUomAbbr(thisRebUom)#
								</td>
							</cfloop> <!---  query="qGetProducts" --->
						</tr>
					</cfloop>
				</cfif>

				<!---------------->
				<!--- LUMP SUM --->
				<!---------------->
				<cfif qHasLumpComp.RecordCount>
					<tr class="GridviewScrollItem">
						<td><a onClick="javascript: return showComponentSelect(3);" class="discount" title="click to add lump sum"><i class="fa fa-plus-square"></i> Lump Sum</a></td>
						<cfloop query="qGetProducts">
							<td>&nbsp;</td>
						</cfloop> <!---  query="qGetProducts" --->
					</tr>
					<cfloop index="lsIndx" list="#form.lLumpSumCompIds#">
						<cfset thisLsId = ListGetAt(lsIndx, 1, "_") />
						<tr id="ls_#thisLsId#" class="GridviewScrollItem">
							<td>
								<a onClick="javascript: return removeComponent('ls_#thisLsId#', '#lsIndx#', 3);"><img src="/images/scissor.gif" width="14" height="9" border="0"></a>
								<cfset qGetCompData = oProgramComponents.GetComponentDetails(thisLsId, 3) />
								#qGetCompData.Component_Name#
							</td>
							<cfloop query="qGetProducts">
								<td class="numeric">
									<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
									<cfparam name="form.lump_sum_rate_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" default="0" />
									<cfparam name="form.lump_sum_comp_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.lump_sum_uom_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.lump_sum_component_paid_to_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.lump_sum_paymentcycle_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfparam name="form.lump_sum_apply_to_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" default="" />
									<cfset thisLsRate = "#evaluate("form.lump_sum_rate_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisLsComp = "#evaluate("form.lump_sum_comp_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisLsUom = "#evaluate("form.lump_sum_uom_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisLsPaidTo = "#evaluate("form.lump_sum_component_paid_to_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisLsPaymentCycle = "#evaluate("form.lump_sum_paymentcycle_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#")#" />
									<cfset thisLsApplyLumpSumTo = "#evaluate("form.lump_sum_apply_to_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#")#" />

									<cfset thisLsRate = ListFirst(thisLsRate) />
									<cfset thisLsUom = ListFirst(thisLsUom) />

									<cfparam name="local.discountLSSum_#thisStripGUID#" default="0" />

									<cfset thisLsSumRate = thisLsRate />

									<cfset "local.discountLSSum_#thisStripGUID#" = local[ "discountLSSum_" & thisStripGUID] + thisLsSumRate />

									<!---compNameId	rate	uom	Component_Paid_To	PaymentCycle--->
									<input name="lump_sum_comp_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" value="#thisLsComp#" type="hidden" />
									<input name="lump_sum_uom_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" value="#thisLsUom#" type="hidden" />
									<input name="lump_sum_component_paid_to_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" value="#thisLsPaidTo#" type="hidden" />
									<input name="lump_sum_paymentcycle_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" value="#thisLsPaymentCycle#" type="hidden" />
									<input name="lump_sum_apply_to_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#" value="#thisLsApplyLumpSumTo#" type="hidden" />
									$
									<input
										name="lump_sum_rate_#ListGetAt(lsIndx, 1, "_")#_#thisStripGUID#"
										type="text"
										value="#NumberFormat(thisLsRate, "_.__")#"
										class="rightColumn discountRate"
										guid="#thisStripGUID#"
										nPrice_#thisStripGUID#="#oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM).val#"
										<cfif not form.bFormIsValid>
											disabled
										</cfif>
									>
									&nbsp;&nbsp;&nbsp;
								</td>
							</cfloop> <!---  query="qGetProducts" --->
						</tr>
					</cfloop>
				</cfif>

				<!------------->
				<!--- VOLUME --->
				<!------------->
				<tr class="GridviewScrollItem">
					<td>Volume</td>
					<cfloop query="qGetProducts">
                        <cfif structKeyExists(form, "vol." & qGetProducts.BSA_Foodservice_Items_Master_ID)>
                            <cfset input_value = replace(form[ 'vol.' & qGetProducts.BSA_Foodservice_Items_Master_ID ],",", "") />
                        <cfelse>
                            <cfset input_value = oPlannerProgram.getProductVolumeFromVolumePlan(form.programIdCopyRevise, qGetProducts.BSA_Foodservice_Items_Master_ID).forecast_cs />
                        </cfif>
						<td class="numeric">
							<input	type="text"
									class="lfc"
									name="vol.#qGetProducts.BSA_Foodservice_Items_Master_ID#"
									value="#NumberFormat(input_value)#"
									<cfif not form.bFormIsValid>
										disabled
									</cfif>
							>
							<input type="hidden" name="volChange#qGetProducts.BSA_Foodservice_Items_Master_ID#" value="0">
							<i class="fa fa-bars volume" title="click to view #Application.PlannerPrgLabel# volume"></i>
						</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!----------->
				<!--- UOM --->
				<!----------->
				<tr class="GridviewScrollItem">
					<td>UOM</td>
					<cfloop query="qGetProducts">
						<td style="text-align:right;">Unit</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!-------------------->
				<!--- PROMOTED NUC --->
				<!-------------------->
				<tr class="GridviewScrollItem">
					<td>Promoted NUC Target</td>
					<cfloop query="qGetProducts">
						<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
						<cfquery name="qGetNUCTarget" datasource="#application.datasource#">
							SELECT	NUCT.Promoted_NUC
							FROM	#gGetProdGroupAttr.Product_Group_Attribute_Table# TCD
									LEFT join BSA_Foodservice_Items_Master im on im.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field#
									LEFT JOIN NUC_Targets NUCT ON TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = NUCT.Product_Group_ID AND NUCT.Deleted = 0
							WHERE	<cfif form.bIsGroupItems eq 1>TCD.#gGetProdGroupAttr.Product_Group_Attribute_Master_ID_Field# = <cfqueryparam value='#qGetProducts.BSA_Foodservice_Items_Master_ID#'> <cfelse>im.BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#qGetProducts.BSA_Foodservice_Items_Master_ID#'></cfif>
						</cfquery>
						<cfparam name="form.nucval__#thisStripGUID#" default="0" />
						<cfset "form.nucval__#thisStripGUID#" = qGetNUCTarget.Promoted_NUC />
						<cfif form[ "nucval__" & thisStripGUID] eq "">
							<cfset "form.nucval__#thisStripGUID#" = 0 />
						</cfif>
						<input type="hidden" name="nucval__#thisStripGUID#" value="#form[ "nucval__" & thisStripGUID]#" />
						<td class="numeric">#DollarFormat(form["nucval__" & thisStripGUID])#</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!-------------------------->
				<!--- RETAILER UNIT COST --->
				<!-------------------------->
				<tr class="GridviewScrollItem">
					<td>Retailer Unit Cost</td>
					<cfloop query="qGetProducts">
						<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
						<cfset nPrice = oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM)>
						<!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
						<cfset nUnits = oPlannerProgram.getUnits(qGetProducts.BSA_Foodservice_Items_Master_ID)>

						<cfset nEDLPPrice = oPlannerProgram.getnEDLPPrice(qGetProducts.BSA_Foodservice_Items_Master_ID, form.plannerId, form.Contract_Number).Everyday_Low_Price />
						<cfif nEDLPPrice eq "">
							<cfset nEDLPPrice = 0 />
						</cfif>

						<cfparam name="local.discountSum_#thisStripGUID#" default="0" />
						<cfparam name="form.nucval__#thisStripGUID#" default="0" />
						<cfif local[ "discountSum_" & thisStripGUID] eq "">
							<cfset "local.discountSum_#thisStripGUID#" = 0 />
						</cfif>
						<cfset calc =  (nPrice.val - local[ "discountSum_" & thisStripGUID] - nEDLPPrice) />
						<cfif calc eq 0 or calc eq "" or nUnits eq 0>
							<cfset n = 0 />
						<cfelse>
							<cfset n = calc	/ nUnits />
						</cfif>
						<cfset diffCalc = n - form["nucval__" & thisStripGUID] />
						<input type="hidden" name="discountSum_#thisStripGUID#" value="#local[ "discountSum_" & thisStripGUID]#" />
						<input type="hidden" name="rucval__#thisStripGUID#" value="#n#" />
						<input type="hidden" name="edlp__#thisStripGUID#" value="#nEDLPPrice#" />
						<td class="numeric" id="ruc__#thisStripGUID#">
							#DollarFormat(n)#&nbsp;&nbsp;&nbsp;
							<div id="ruc__calc#thisStripGUID#">#DollarFormat(diffCalc)#</div>
							<cfif n lt 0>
								<script>
									$("##ruc__#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##ruc__#thisStripGUID#").addClass("greenDisplay");
								</script>
							</cfif>
							<cfif diffCalc lt 0>
								<script>
									$("##ruc__calc#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##ruc__calc#thisStripGUID#").addClass("greenDisplay");
								</script>
							</cfif>
						</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!------------------------------->
				<!--- RETAILER UNIT COST W/LS --->
				<!------------------------------->
				<tr class="GridviewScrollItem">
					<td>Retailer Unit Cost W/LS</td>
					<cfloop query="qGetProducts">
						<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
						<cfset nPrice = oPlannerProgram.getnPrice( qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM)>

						<!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
						<cfset nUnits = oPlannerProgram.getUnits(qGetProducts.BSA_Foodservice_Items_Master_ID)>

						<cfset nEDLPPrice = oPlannerProgram.getnEDLPPrice(qGetProducts.BSA_Foodservice_Items_Master_ID, form.plannerId, form.Contract_Number).Everyday_Low_Price />
						<cfif nEDLPPrice eq "">
							<cfset nEDLPPrice = 0 />
						</cfif>

						<cfset nVolume = structKeyExists(form, "vol." & qGetProducts.BSA_Foodservice_Items_Master_ID) ? replace(form[ 'vol.' & qGetProducts.BSA_Foodservice_Items_Master_ID ],",", "") : 1>

						<cfif nVolume eq 0>
							<cfset nVolume = 1 />
						</cfif>
						<cfparam name="local.discountLSSum_#thisStripGUID#" default="0" />
						<cfset nAllSum = local[ "discountSum_" & thisStripGUID] + (local[ "discountLSSum_" & thisStripGUID] / nVolume) />
						<cfset calc2 = (nPrice.val - nAllSum) - nEDLPPrice />
						<cfif calc2 eq 0 or calc2 eq "" or nUnits eq 0>
							<cfset n = 0 />
						<cfelse>
							<cfset n = calc2 / nUnits />
						</cfif>
						<cfset diffCalc = n - form["nucval__" & thisStripGUID] />
						<input type="hidden" name="discountLSSum_#thisStripGUID#" value="#local[ "discountLSSum_" & thisStripGUID]#" />
						<td class="numeric" id="rucls__#thisStripGUID#">
							#DollarFormat(n)#&nbsp;&nbsp;&nbsp;
							<div id="ruc__calcls#thisStripGUID#">#DollarFormat(diffCalc)#</div>
							<cfif n lt 0>
								<script>
									$("##rucls__#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##rucls__#thisStripGUID#").addClass("greenDisplay");
								</script>
							</cfif>
							<cfif diffCalc lt 0>
								<script>
									$("##ruc__calcls#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##ruc__calcls#thisStripGUID#").addClass("greenDisplay");
								</script>
							</cfif>
						</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>
				<!--------------------------->
				<!--- EVERYDAY UNIT PRICE --->
				<!--------------------------->
				<tr class="GridviewScrollItem">
					<td>Everyday Unit Price</td>
					<cfloop query="qGetProducts">
						<td class="numeric">
							<cfparam name="form.everydayprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" default="0" />
							<cfquery name="qGetEveryDayPrice" dbtype="query">
								SELECT 	*
								FROM	qGetUnitPriceData
								WHERE	Group_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
							</cfquery>
							<cfif qGetEveryDayPrice.RecordCount>
								<cfset "form.everydayprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGetEveryDayPrice.Everyday_Unit_Price />
							</cfif>
							$
							<input
								type="text"
								name="everydayprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#"
								value="#form[ "everydayprice__" &  Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") ]#"
								id="evdp"
								<cfif not form.bFormIsValid>
									disabled
								</cfif>
							>
						</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!------------------------>
				<!--- MERCH UNIT PRICE --->
				<!------------------------>
				<tr class="GridviewScrollItem">
					<td>Merch Unit Price</td>
					<cfloop query="qGetProducts">
						<td class="numeric">
							<cfparam name="form.merchprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" default="0" />
							<cfquery name="qGetMerchPrice" dbtype="query">
								SELECT 	*
								FROM	qGetUnitPriceData
								WHERE	Group_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
							</cfquery>
							<cfif qGetMerchPrice.RecordCount>
								<cfset "form.merchprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" = qGetMerchPrice.Merchant_Price />
							</cfif>
							$
							<input
								type="text"
								name="merchprice__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#"
								value="#form[ "merchprice__" &  Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") ]#"
								class="merchp"
								<cfif not form.bFormIsValid>
									disabled
								</cfif>
							/>
						</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!----------------------->
				<!--- RETAILER MARGIN --->
				<!----------------------->
				<tr class="GridviewScrollItem">
					<td>Retailer Margin / Profit</td>
					<cfloop query="qGetProducts">
						<td class="numeric" id="rm__#Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#">
							<cfquery name="qGetMerchPrice2" dbtype="query">
								SELECT 	*
								FROM	qGetUnitPriceData
								WHERE	Group_ID = '#qGetProducts.BSA_Foodservice_Items_Master_ID#'
							</cfquery>
							<cfset thisStripGUID = Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") />
							<cfset nPrice = oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID, form.programIdCopyRevise, form.plTemplatedefaultUOM)>
							<cfset nMerchantPrice = 0 />
							<cfif qGetMerchPrice2.RecordCount>
								<cfset nMerchantPrice = qGetMerchPrice2.Merchant_Price />
							</cfif>
							<cfparam name="local.discountSum_#thisStripGUID#" default="0" />
							<cfparam name="form.merchprice__#thisStripGUID#" default="0" />
							<!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
							<cfset nUnits = oPlannerProgram.getUnits(qGetProducts.BSA_Foodservice_Items_Master_ID)>

							<cfset ruc = (nPrice.val - local[ "discountSum_" & thisStripGUID]) />
							<cfif ruc eq 0 or ruc eq "" or nUnits eq 0>
								<cfset n = 0 />
								<cfset rm = 0 />
							<cfelse>
								<cfset n = ruc / nUnits />
								<cfset rm = ((nMerchantPrice - n ) / n) * 100 />
							</cfif>
							<cfset rmp = (nMerchantPrice - n )  />
							<input type="hidden" name="retailMargin_#thisStripGUID#" value="#rm#" />
							<input type="hidden" name="Planner_Expected_Margin" value="#gGetExpMargin.Planner_Expected_Margin#" />
							#NumberFormat(rm, "(_.__)")#%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DollarFormat(rmp)#
							<cfif rm lt 0>
								<script>
									$("##rm__#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##rm__#thisStripGUID#").addClass("greenDisplay");
								</script>
							</cfif>
						</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>
			<!--- </tbody> --->
		</table>
	</div>

	<div id="bot100">
		<div id="bot102"></div>
	</div>

	<INPUT TYPE="hidden"	NAME="Product_List" 			VALUE="#Form.Product_List#">
	<INPUT TYPE="hidden"	NAME="ExistingProductList" 		VALUE="#Form.Product_List#">
	<INPUT TYPE="hidden" 	NAME="templateId" 				VALUE="#Form.templateId#">
	<INPUT TYPE="hidden" 	NAME="lFixedCompIds" 			VALUE="#Form.lFixedCompIds#">
	<INPUT TYPE="hidden" 	NAME="lRebateCompIds" 			VALUE="#Form.lRebateCompIds#" />
	<INPUT TYPE="hidden" 	NAME="lLumpSumCompIds"			VALUE="#Form.lLumpSumCompIds#">

	<INPUT TYPE="hidden" 	NAME="strFixedData" 			VALUE="#form.strFixedData#">
	<INPUT TYPE="hidden" 	NAME="strRebateData" 			VALUE="#form.strRebateData#">
	<INPUT TYPE="hidden" 	NAME="strLumpSumData"			VALUE="#form.strLumpSumData#">

	<INPUT TYPE="hidden" 	NAME="bSave"					VALUE="#form.bSave#">

	<INPUT TYPE="hidden" 	NAME="programId"				VALUE="0">
	<input type="hidden"	name="plannerId"				value="#form.plannerId#" />
	<input type="hidden"	name="customerId"				value="#form.customerId#" />
	<input type="hidden"	name="Product_List_Type"		value="#form.Product_List_Type#" />
	<input type="hidden"	name="bFromCompPopUp"			value="#form.bFromCompPopUp#" />
	<input type="hidden"	name="bSaveVolume"				value="0" />

	<INPUT TYPE="hidden" 	NAME="bHasGroup"				VALUE="#form.bHasGroup#">
	<INPUT TYPE="hidden" 	NAME="bIsGroupItems"			VALUE="#form.bIsGroupItems#">

	<!--- Group hidden form variables --->
	<INPUT TYPE="hidden" 	NAME="Level_1"					VALUE="#form.Product_List#">
	<INPUT TYPE="hidden" 	NAME="GroupLevel_1"				VALUE="#form.Product_List_Type#">
	<INPUT TYPE="hidden" 	NAME="bFromGroupPopUp"			VALUE="0">

	<INPUT TYPE="hidden" 	NAME="bFormIsValid"					VALUE="#form.bFormIsValid#">
	<INPUT TYPE="hidden" 	NAME="Business_Segment_ID"			VALUE="6">
	<INPUT TYPE="hidden" 	NAME="Contract_Quantity_UOM_IDX"	VALUE="1">
	<INPUT TYPE="hidden" 	NAME="Planner_Start_Date"			VALUE="#DateFormat(qGetPlannerData.Planner_Start_Date, "mm/dd/yyyy")#">
	<INPUT TYPE="hidden" 	NAME="Planner_End_Date"				VALUE="#DateFormat(qGetPlannerData.Planner_End_Date, "mm/dd/yyyy")#">
	<INPUT TYPE="hidden" 	NAME="bVolumeChange"				VALUE="0">
	<INPUT TYPE="hidden" 	NAME="bCopy"						VALUE="#form.bCopy#">
	<INPUT TYPE="hidden" 	NAME="bRevise"						VALUE="#form.bRevise#">
	<INPUT TYPE="hidden" 	NAME="programIdCopyRevise"			VALUE="#form.programIdCopyRevise#">


</form>

<!--- this form with dynamic populated hidden inputs is sent to program volume plan popup --->
<form name="volume_plan_popup" action="/planners/create/program_volume_plan.cfm" method="post" onsubmit="popup_form(this, 'volume_plan_popup', 1300, 400)">
	<input type="hidden" name="programid" value="#form.programIdCopyRevise#">
	<input type="hidden" name="product_list" id="product_list">
	<input type="hidden" name="Product_List_Type" value="#form.Product_List_Type#" />
	<input type="hidden" name="delivery_start_date" id="delivery_start_date">
	<input type="hidden" name="delivery_end_date" id="delivery_end_date">
	<input type="hidden" name="action"    value="show">
	<input type="hidden" name="delivery_weeks_only"  value="1">
</form>

</cfoutput>

<cf_include files="/Script/javascript/gridviewScroll.min.js, /script/javascript/jquery.cfjs.min.js,  /script/javascript/numeral.min.js, /script/javascript/date_functions.js, /script/javascript/jquery.noty.packaged.min.js">

<script>

	<cfif trim(Form.Product_List) eq "">
		check();
	</cfif>

    jQuery("input.date").datepicker({
		dateFormat: "m/d/yy",
		changeMonth: true,
		changeYear: true,
        minDate: "<cfoutput>#DateFormat(qGetPlannerData.Planner_Start_Date, "mm/dd/yyyy")#</cfoutput>",
        maxDate: "<cfoutput>#DateFormat(qGetPlannerData.Planner_End_Date, "mm/dd/yyyy")#</cfoutput>",
		onSelect: function( selected ) {
			var elem = jQuery(this).attr("name");
			if ( elem === "Perf_Start_Date" ){
				jQuery("input[name=Perf_End_Date]").datepicker("option", "minDate", selected);
				$(this).trigger("change");
			}
			// else if ( elem === "Perf_End_Date" )
				// jQuery("input[name=Perf_End_Date]").datepicker("option", "maxDate", selected);
			else if ( elem === "Delivery_Start_Date" )
				jQuery("input[name=Delivery_End_Date]").datepicker("option", "minDate", selected);
			// else if ( elem === "Delivery_End_Date" )
				// jQuery("input[name=Delivery_End_Date]").datepicker("option", "maxDate", selected);
		}
	});

    // Delivery Start Date can be before planner start date
    jQuery("input[name=Delivery_Start_Date]").datepicker( "option", "minDate", null)

     <cfoutput>
        var plannerStartDate = new Date("#DateFormat(qGetPlannerData.Planner_Start_Date, "mm/dd/yyyy")#");
        var plannerEndDate = new Date("#DateFormat(qGetPlannerData.Planner_End_Date, "mm/dd/yyyy")#");
    </cfoutput>
	jQuery("input[name=Perf_Start_Date]").change(function(){
        var objPt = jQuery("select[name=Planner_Perf_Types_ID]");
		var objPED = jQuery("input[name=Perf_End_Date]");
		var objDSD = jQuery("input[name=Delivery_Start_Date]");
		var objDED = jQuery("input[name=Delivery_End_Date]");
		var dur = $('option:selected', objPt).attr('Duration');
		var dsd = $('option:selected', objPt).attr('deliveryDaysStart');
		var ded = $('option:selected', objPt).attr('deliveryDaysEnd');
		var d = $(this).val();

		if(d == ''){
            validate_date_fields_init(0, 0);
			return;
		}
		var d = new Date(d);
		var dPerEd = d;
		var dDelSd = d;
		var dDelEd = d;
		dur = parseInt(dur) -1;
        if(dur < 0) dur = 0;
		dsd = parseInt(dsd);
		ded = parseInt(ded);

		dPerEd = dateAdd('d', d, dur);
		dDelSd = dateAdd('d', d, -dsd);
		dDelEd = dateAdd('d', dPerEd, - ded);

        //  If text fields are already populated we will not overwrite, so use the text box values for validating
        if(objPED.val() != ""){
			dPerEd = objPED.val();
		}
        if(objDSD.val() != ""){
			dDelSd = objDSD.val();
		}
        if(objDED.val() != ""){
			dDelEd = objDED.val();
		}

		dPerEd = $.DateFormat(dPerEd, 'm/dd/yyyy');
		dDelSd = $.DateFormat(dDelSd, 'm/dd/yyyy');
		dDelEd = $.DateFormat(dDelEd, 'm/dd/yyyy');

        /////////////////////////////// Validate date values
        if(validate_date_fields(d, dPerEd, dDelSd, dDelEd, 1, 0).length){
            return;
        }

        if(objPED.val() == "" && $.IsDate(dPerEd)){
			objPED.val(dPerEd);
		}
		if(objDSD.val() == "" && $.IsDate(dDelSd)){
			objDSD.val(dDelSd);
		}

		if(objDED.val() == "" && $.IsDate(dDelEd)){
			objDED.val(dDelEd);
		}
		check();
	});

    jQuery("input[name=Perf_End_Date]").change(function(){
        validate_date_fields_init(1, 0);
	});

    jQuery("input[name=Delivery_Start_Date]").change(function(){
        validate_date_fields_init(1, 0);
	});

    jQuery("input[name=Delivery_End_Date]").change(function(){
        validate_date_fields_init(1, 0);
	});

  var  gridWidth = Math.min(<cfoutput>#(qGetProducts.recordCount + 1)#</cfoutput> * 160, $(window).width() - 10)
      ,gridHeight = $(window).height() - 400;

	jQuery('table.pgrid').gridviewScroll({
			width: gridWidth,
			height: 590,
		  	freezesize: 1,
            barsize: 18,
            railcolor: "#F0F0F0",
            barcolor: "#CDCDCD",
            barhovercolor: "#606060",
            bgcolor: "#F0F0F0",
            arrowsize: 30,
            varrowtopimg: "/Images/arrowvt.png",
            varrowbottomimg: "/Images/arrowvb.png",
            harrowleftimg: "/Images/arrowhl.png",
            harrowrightimg: "/Images/arrowhr.png",
            railsize: 16
        });

	///////////////////////////////
	// program volume plan popup //
	///////////////////////////////
	jQuery("i.volume").click(function(){
		var errors = []
			,cnt = 0
		    ,required = [ "Delivery_Start_Date", "Delivery_End_Date" ]
		    ,messages = [ "Please enter a delivery start date.", "Please enter a delivery end date." ];

		// check on required fields
		for (cnt = 0; cnt <= required.length; cnt++) {
			var $obj = $("input[name=" + required[cnt] + "]");
			if ( $obj.val() == "" ) {
				errors.push( messages[cnt] );
				$obj.addClass( "attention" );
			}
			else {
				$obj.removeClass( "attention" );
			}
		};

		if ( $("input[name=programId]").val() == 0 ) {
			errors.push( "Please save the data first." );
		}

		if (errors.length) {
			alert( errors.join("\n") );
			return false;
		}

		// gather products list
		var products = [];
		$("input.lfc").each(function(){
			var product_id = $.ListGetAt($(this).attr("name"), 2, '.');
			products.push( product_id );
		});
		// populate hidden inputs to send to popup
		$("input#product_list").val( products.join(",") );
		$("input#delivery_start_date").val( $("input[name=Delivery_Start_Date]").val() );
		$("input#delivery_end_date").val( $("input[name=Delivery_End_Date]").val() );

		$("form[name=volume_plan_popup]").submit();
	});


    function validate_date_fields_init(bDisplayNoty, bValidateBlank) {
        return validate_date_fields(
            $("input[name=Perf_Start_Date]").val(),
            $("input[name=Perf_End_Date]").val(),
            $("input[name=Delivery_Start_Date]").val(),
            $("input[name=Delivery_End_Date]").val(),
            bDisplayNoty,
            bValidateBlank);
    }

    function validate_date_fields(perfStartDate, perfEndDate, delStartDate, delEndDate, bDisplayNoty, bValidateBlank) {
        var errors = [],
            bNotyNeeded = 0,
            dPerfStartDate = Date.parse(perfStartDate),
            dPerfEndDate = Date.parse(perfEndDate),
            dDelStartDate = Date.parse(delStartDate),
            dDelEndDate = Date.parse(delEndDate);
        <cfoutput>
        var plannerStartDate = new Date("#DateFormat(qGetPlannerData.Planner_Start_Date, "mm/dd/yyyy")#");
        var plannerEndDate = new Date("#DateFormat(qGetPlannerData.Planner_End_Date, "mm/dd/yyyy")#");
        var notyText = "<cfoutput>#Application.PlannerLabel#</cfoutput> dates (#DateFormat(qGetPlannerData.Planner_Start_Date, "mm/dd/yyyy")# - #DateFormat(qGetPlannerData.Planner_End_Date, "mm/dd/yyyy")#)";
        </cfoutput>

        ////////////////////////////////// Perf Start Date
        if(perfStartDate == "" && bValidateBlank){
            $("input[name=Perf_Start_Date]").addClass( "attention" );
            errors.push('Please enter a Perf Start date.');
        }
        else if(dPerfStartDate < plannerStartDate || dPerfStartDate > plannerEndDate){
            $("input[name=Perf_Start_Date]").addClass( "attention" );
            errors.push('Perf Start date must be within <cfoutput>#Application.PlannerLabel#</cfoutput> dates.');
            notyText = notyText + " <br> Perf Start (" + $.DateFormat(perfStartDate, 'm/dd/yyyy') + ") not within plan dates";
            bNotyNeeded = 1;
        }
        else {
             $("input[name=Perf_Start_Date]").removeClass( "attention" );
        }

        ////////////////////////////////// Perf End Date
        if(perfEndDate == "" && bValidateBlank){
            $("input[name=Perf_End_Date]").addClass( "attention" );
            errors.push('Please enter a Perf End date.');
        }
        else if(dPerfEndDate < plannerStartDate || dPerfEndDate > plannerEndDate){
            $("input[name=Perf_End_Date]").addClass( "attention" );
            errors.push('Perf End date must be within <cfoutput>#Application.PlannerLabel#</cfoutput> dates.');
            notyText = notyText + " <br> Perf End (" + $.DateFormat(perfEndDate, 'm/dd/yyyy') + ") not within plan dates";
            bNotyNeeded = 1;
        }
        else if(dPerfEndDate < dPerfStartDate){
            $("input[name=Perf_End_Date]").addClass( "attention" );
            errors.push('Perf end date must be after start date.');
            notyText = notyText + " <br> Perf end date must be after start date";
            bNotyNeeded = 1;
        }
        else {
             $("input[name=Perf_End_Date]").removeClass( "attention" );
        }

        ////////////////////////////////// Delivery Start Date
        if(delStartDate == "" && bValidateBlank){
            $("input[name=Delivery_Start_Date]").addClass( "attention" );
            errors.push('Please enter a Delivery Start date.');
        }
        else if(dDelStartDate > plannerEndDate){
            $("input[name=Delivery_Start_Date]").addClass( "attention" );
            errors.push('Delivery Start date must be before <cfoutput>#Application.PlannerLabel#</cfoutput> end date.');
            notyText = notyText + " <br> Delivery Start (" + $.DateFormat(delStartDate, 'm/dd/yyyy') + ") not within plan end date";
            bNotyNeeded = 1;
        }
        else {
             $("input[name=Delivery_Start_Date]").removeClass( "attention" );
        }

        ////////////////////////////////// Delivery End Date
        if(delEndDate == "" && bValidateBlank){
            $("input[name=Delivery_End_Date]").addClass( "attention" );
            errors.push('Please enter a Delivery End date.');
        }
        else if(dDelEndDate < plannerStartDate || dDelEndDate > plannerEndDate){
            $("input[name=Delivery_End_Date]").addClass( "attention" );
            errors.push('Delivery End date must be within <cfoutput>#Application.PlannerLabel#</cfoutput> dates.');
            notyText = notyText + " <br> Delivery End (" + $.DateFormat(delEndDate, 'm/dd/yyyy') + ") not within plan dates";
            bNotyNeeded = 1;
        }
         else if(dDelEndDate < dDelStartDate){
            $("input[name=Delivery_End_Date]").addClass( "attention" );
            errors.push('Delivery end date must be after start date.');
            notyText = notyText + " <br> Delivery end date must be after start date.";
            bNotyNeeded = 1;
        }
        else {
             $("input[name=Delivery_End_Date]").removeClass( "attention" );
        }


        if(bDisplayNoty && bNotyNeeded){
        noty({
            text: notyText,
            layout: "topCenter",
            type: 'success',
            closeWith: ['click', 'button'],
            killer: true });
        }
        else {
            $.noty.closeAll();
        }
        return errors;
    }

    function duplicateProgramExists(){

        ///////////////////// Find if there are other programs in this planner same per type, with overlapping dates and same products
        <cfif form.Product_List neq "">
        var dupProgramList = [],
            iPgmLen = 0,
            colMap = [],
            sMessage = "",
            maxDisplay = 5;

        $.ajax({ url: "/mvc/Models/Planner/PlannerProgramManager.cfc"
                ,type: "post"
                ,timeout:60000
                ,data: { method: "checkDuplicateProgram"
                        ,plannerId:'<cfoutput>#form.plannerId#</cfoutput>'
                        ,contractNumber:'<cfoutput>#form.Contract_Number#</cfoutput>'
                        ,perfTypeId: jQuery("select[name=Planner_Perf_Types_ID]").val()
                        ,startDate: $("input[name=Perf_Start_Date]").val()
                        ,endDate: $("input[name=Perf_End_Date]").val()
                        ,productList: '<cfoutput>#form.Product_List#</cfoutput>'
                        }

                ,dataType: "json"
                ,async: false
                ,success: function(r) {
                    dupProgramList = r;
                }
                ,error: function(XMLHttpRequest, textStatus, errorThrown) {
                    alert("Status: " + textStatus); alert("Error: " + errorThrown);
                }

        });

        iPgmLen = dupProgramList.DATA.length;

        if(iPgmLen){
            /////// Display program list

            //first - find my columns
            for(var i = 0; i < dupProgramList.COLUMNS.length; i++) {
                colMap[dupProgramList.COLUMNS[i]] = i;
            }

            if(iPgmLen == 1)
            sMessage = "There is one duplicate <cfoutput>#Application.PlannerPrgLabel#</cfoutput>";
            else
            sMessage = "There are " + iPgmLen + " duplicate programs";

            sMessage += "\n (same product, same performance type, overlapping time period)\n";
            for(var i = 0; i < iPgmLen && i < maxDisplay; i++) {
                sMessage    += "\n"
                            + dupProgramList.DATA[i][colMap["CONTRACT_NUMBER"]] + ": "
                            + dupProgramList.DATA[i][colMap["CONTRACT_TITLE"]] + " ("
                            + dupProgramList.DATA[i][colMap["CONTRACT_START_DATE"]] + "-"
                            + dupProgramList.DATA[i][colMap["CONTRACT_END_DATE"]] + ")";

                if(i == (maxDisplay-1) && dupProgramList.DATA.length > maxDisplay){
                    sMessage    += "\n(more)....";
                }
            }

            alert(sMessage);

            return 1;

        }
        </cfif>
        return 0;

    }

	function validate_form() {

		try{
			var errors = []
				,cnt = 0
				,required = [ "Contract_Title"]
				,messages = [ "Please enter a title."]
				,perStartDate = $("input[name=Perf_Start_Date]").val()
				,perEndDate = $("input[name=Perf_End_Date]").val()
				,delStartDate = $("input[name=Delivery_Start_Date]").val()
				,delEndDate = $("input[name=Delivery_End_Date]").val()
				,prgId = $("input[name=programId]").val()
				,planPerfStartDate = $("input[name=Planner_Start_Date]").val()
				,planPerfEndDate = $("input[name=Planner_End_Date]").val();

			/////////////////////////////// Validate date values
			errors = validate_date_fields_init(0, 1);

			for (cnt = 0; cnt <= required.length; cnt++) {
				var $obj = $("input[name=" + required[cnt] + "]");
				if ( $obj.val() == "" ) {
					errors.push( messages[cnt] );
					$obj.addClass( "attention" );
				}
				else {
					$obj.removeClass( "attention" );
				}
			};


			$("input.lfc").each(function(){
				var thisVal = $(this).val();

				if(prgId != 0 && (thisVal == 0 || thisVal == "")){
					errors.push('Please enter volume');
					return false;
				}
			});

			$("input.merchp").each(function(){
				var thisVal = $(this).val();

				if(prgId != 0 && (thisVal == 0 || thisVal == "")){
					errors.push('Please enter merch unit price');
					return false;
				}
			});

			if (errors.length) {
				alert( errors.join("\n") );
				return false;
			}
			else {

				if(duplicateProgramExists())
					return false;

			}

			$("input[name=bFormIsValid]").val(1);
			MyForm.bSave.value = 1;
			window.opener.close();
			MyForm.submit();

			}
		catch(err){
			alert(err.message);
		}
	};


	$( "input.merchp" ).change(function() {
		var guid = $.ListGetAt($(this).attr("name"), 2, '__');
		var mup = $(this).val();
		//var mup = $("input[name=merchprice__" + guid + "]").val();
		//fixed_rate_
		//rebate_rate_
		var setVal = parseFloat(mup);
		var	setVal2 = 0;
		var	setVal3 = 0;
		var	setVal4 = 0;

		//var som = $( "input[name$=" + guid + "]" );
		var setVal2 = parseFloat($("input[name=rucval__" + guid + "]").val());

		setVal3 = ((setVal - setVal2) / setVal2) ;
		setVal3 = numeral(setVal3).format('0,0.00');

		setVal4 = setVal - setVal2;
		setVal4 = numeral(setVal4).format('($0,0.00)');

		$("#rm__" + guid).html(setVal3 + '%' + '&nbsp;&nbsp;&nbsp;' + setVal4);

		if(setVal3 < 0){
			$("#rm__" + guid).removeClass("greenDisplay");
			$("#rm__" + guid).addClass("redDisplay");
		}
		else{
			$("#rm__" + guid).removeClass("redDisplay");
			$("#rm__" + guid).addClass( "greenDisplay" );
		}
	});

	$("input.discountRate").change(function() {
		var guid = $(this).attr("guid");
		var rebRate = $(this).val();
		var price = $(this).attr("nPrice_" + guid);
		var setVal = parseFloat(price);
		var	setVal2 = 0;
		var	setVal3 = 0;
		var	setVal4 = 0;
		var	setVal5 = 0;
		var	setVal6 = 0;
		var	setVal7 = 0;
		var	setVal8 = 0;
		var	setVal9 = 0;
		var	hiddenSetVal2 = 0;
		var	hiddenSetVal3 = 0;
		var	hiddenSetVal7 = 0;
		var nAllSum = 0;
		var calc = 0;
		var somReb = $( "input[name^='rebate_rate_']" );
		var mup = $("input[name=merchprice__" + guid + "]").val();
		var somLump = $( "input[name^='lump_sum_rate_']" );
		var nuc = $("input[name=nucval__" + guid + "]").val();
		var nUnit = $("input[name=bUnits_" + guid + "]").val();
		var nEDLP = $("input[name=edlp__" + guid + "]").val();
		var guid2 = guid.replace(/_/g, "-");
		var nVol = $("input[name='vol." + guid2 + "']").val();

		somReb.each(function (){
			var s = $(this).attr("name");
			var n = s.search(guid);
			if (n > -1){
				setVal2 = setVal2 + parseFloat($(this).val());
			}
		});

		somLump.each(function (){
			var s = $(this).attr("name");
			var n = s.search(guid);
			if (n > -1){
				setVal6 = setVal6 + parseFloat($(this).val());
			}
		});


		nAllSum = parseFloat(setVal2) + (parseFloat(setVal6) / parseFloat(nVol));
		calc = parseFloat(setVal) - parseFloat(nAllSum) - parseFloat(nEDLP);
		calc = parseFloat(calc) / parseFloat(nUnit);
		setVal7 = parseFloat(calc);
		setVal2 = parseFloat(setVal2) + parseFloat(nEDLP);

		setVal3 = (setVal - setVal2) / nUnit;

		setVal4 = ((mup - setVal3) / setVal3);
		setVal5 = mup - setVal3;
		setVal8 = setVal3 - nuc;
		setVal9 = setVal7 - nuc;

		hiddenSetVal3 = setVal3;
		hiddenSetVal7 = setVal7;

		setVal3 = numeral(setVal3).format('($0,0.00)');
		setVal4 = numeral(setVal4).format('0,0.00');
		setVal5 = numeral(setVal5).format('($0,0.00)');
		setVal7 = numeral(setVal7).format('($0,0.00)');
		setVal8 = numeral(setVal8).format('($0,0.00)');
		setVal9 = numeral(setVal9).format('($0,0.00)');
		$("#ruc__" + guid).html(setVal3 + '&nbsp;&nbsp;&nbsp;' + setVal8);
		$("#rucls__" + guid).html(setVal7 + '&nbsp;&nbsp;&nbsp;' + setVal9);
		$("#rm__" + guid).html(setVal4 + '%'  + '&nbsp;&nbsp;&nbsp;' + setVal5);
		$("input[name=rucval__" + guid + "]").val(hiddenSetVal3);
		$("input[name=discountSum_" + guid + "]").val(setVal2);

		if(hiddenSetVal3 < 0){
			$("#ruc__" + guid).removeClass("greenDisplay");
			$("#ruc__" + guid).addClass("redDisplay");
		}
		else{
			$("#ruc__" + guid).removeClass("redDisplay");
			$("#ruc__" + guid).addClass( "greenDisplay" );
		}

		if(hiddenSetVal7 < 0){
			$("#rucls__" + guid).removeClass("greenDisplay");
			$("#rucls__" + guid).addClass("redDisplay");
		}
		else{
			$("#rucls__" + guid).removeClass("redDisplay");
			$("#rucls__" + guid).addClass( "greenDisplay" );
		}



		if(setVal4 < 0){
			$("#rm__" + guid).removeClass("greenDisplay");
			$("#rm__" + guid).addClass("redDisplay");
		}
		else{
			$("#rm__" + guid).removeClass("redDisplay");
			$("#rm__" + guid).addClass( "greenDisplay" );
		}

	});

	$("#top100 input").focusout(function() {
   		check();
 	});

	function check(){

		var errors = []
			,cnt = 0
		    ,required = [ "Contract_Title", "Perf_Start_Date", "Perf_End_Date", "Delivery_Start_Date", "Delivery_End_Date" ]
			,objIsValid =  $("input[name=bFormIsValid]")
			,prgId = $("input[name=programId]").val()
			,bIsRevision = $("input[name=bRevise]").val();

		for (cnt = 0; cnt <= required.length; cnt++) {

			var $obj = $("input[name=" + required[cnt] + "]");
			if ( $obj.val() == "" ) {
				errors.push(cnt);
			}
		}

		if(errors.length == 0 && (bIsRevision = 1 || prgId != 0)){
			objIsValid.val(1);
			$("#mid100 input").prop("disabled", false);
			$("#mid100").show(500);
		}
		else{
			$("#mid100 input").prop("disabled", true);
			//$("#mid100").hide(500);
		}
	}

	$("input.lfc").change(function(){

		var product_id = $.ListGetAt($(this).attr("name"), 2, '.');
		var obj = $("input[name=volChange" + product_id + "]");
		obj.val(1);
		$("input[name=bVolumeChange]").val(1);

	});


	<cfif url.bLock eq 0>
		$("input[type=text], select, textarea, a, i.volume").attr("disabled", true).addClass("disabled");
		$("a").removeAttr("onclick");
	</cfif>

	<cfif form.approved eq 1 and form.bRevise eq 0>
		$("#top100 a, #top100 input[type=text], #top100 select, #top100 textarea, #top100 i.volume").removeAttr("onclick").addClass("disabled");
		$("#mid100 a, #mid100 input[type=text], #mid100 select, #mid100 textarea, #mid100 i.volume").removeAttr("onclick").addClass("disabled");
	</cfif>


</script>

</cf_layout_planner_program>