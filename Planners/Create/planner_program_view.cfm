<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_program_view.cfm
Date:  		11/02/2016
Author:		Tim Ford
Purpose:  	Single Page Planner Program View
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



<cfset form.programId = listFirst(form.programId) />

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



<cfscript>
    qGetData 				= oPlannerProgram.getProgramPlannerData(form.programId);	
	
    if(form.programId neq 0 and form.plannerId eq ""){
        form.plannerId = qGetData.Planner_ID;
    }
    
    if(form.programId neq 0 and form.templateId eq 0){
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
	qGetUnitPriceData 		= oPlannerProgram.getUnitPrice(form.programId);
	
	form.plTemplatedefaultUOM	= qGetPlannerData.UOM_Default;
	
    

	if(form.programId neq 0){
		qGetProgramData			= oProgram.getProgramInfo(form.programId);
	}
	
	gGetProdGroupAttr		= oPlannerSettings.getProductGroupTypeData();
	
</cfscript>

<cfquery name="gGetExpMargin" dbtype="query">
	SELECT DISTINCT Planner_Expected_Margin
	FROM qGetPlannerProfileData
</cfquery>

<!--- if we don't have a program id then the program has not been created yet so we need to generate one --->
<cfif form.programId eq 0>
	<CFINCLUDE TEMPLATE="/Common_Files/contracts/contract_number_generator.cfm">
	<cfset form.Contract_Number = generator_contract_number />
<cfelse>
	<cfset qGetData = oPlannerProgram.getProgramPlannerData(form.programId) />
	<cfset form.Contract_Number = qGetData.Contract_Number />
</cfif>

<cf_layout_planner_program jQueryUI="1.11.4" page_title="Planner Program">

<cf_include files="/Script/javascript/gridviewScroll.min.js">
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


<!--- Run this code when planner program created gets called from calendar or volume plan --->
<cfif url.bInit eq 1>

	<cfscript>
		qGetProdData = oPlannerProgram.getProgramPlannerProductData(form.programId);
		qGetFixedData = oPlannerProgram.getProgramPlannerFixedData(form.programId);
		qGetRebateData = oPlannerProgram.getProgramPlannerRebateData(form.programId);
		qGetLumpSumData = oPlannerProgram.getProgramPlannerLumpSumData(form.programId);
		gGetProductGroupType = oPlannerProgram.getProgramProductGroupType(form.programId);
		qGetPlannerVolumeData	= oPlannerProgram.getProgramPlannerVolumeData(form.programId);

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

			<cfset qGet = oPlannerProgram.getProgramPlannerFixedData(form.programId, trim(qGetFixedCompId.compNameId), qGetFixedData.BSA_Foodservice_Items_Master_ID) />
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

			<cfset qGet = oPlannerProgram.getProgramPlannerRebateData(form.programId, trim(qGetRebateCompId.compNameId), qGetRebateData.BSA_Foodservice_Items_Master_ID) />
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

			<cfset qGet = oPlannerProgram.getProgramPlannerLumpSumData(form.programId, trim(qGetLumpSumData.compNameId), qGetLumpSumData.BSA_Foodservice_Items_Master_ID) />
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
	<cfset form.Contract_Number = qGetData.Contract_Number />

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
	WHERE	Contract_Main_ID = '#form.programId#'
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

	<div id="top100">
		<div id="top102">
			    
			<label>Program ##</label>
				 #form.Contract_Number#
			    
			<label>Perf Type</label>
				<cfquery dbtype="query" name="qGetPerfDescription">
					SELECT	Description
					FROM	qGetPlannerPerfTypes
					WHERE	Planner_Perf_Types_ID = #qGetData.Planner_Perf_Type_ID#
				</cfquery>
				#qGetPerfDescription.Description#									
			    
			<label>Perf Start</label>
				<cfif trim(FORM.Perf_Start_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				#FORM.Perf_Start_Date#<br>
			    
			<label>Delivery Start</label>
				<cfif trim(FORM.Delivery_Start_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				 #FORM.Delivery_Start_Date#<br>
			    
			<label>Budget</label>
				 
		</div>
		<div id="top104">
			    
			<label>Title</label>
				 #form.Contract_Title#
			    
			<label>Marketing Event</label>
				 #form.Marketing_Event#
			    
			<label>Perf End</label>
				<cfif trim(FORM.Perf_End_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				 #FORM.Perf_End_Date#<br>
			    
			<label>Delivery End</label>
				<cfif trim(FORM.Delivery_End_Date) eq "">
					<cfset form.bFormIsValid = 0 />
				</cfif>
				#FORM.Delivery_End_Date#<br>
		</div>
		<div id="top106">
			    
			<label style="text-align:left;display:inline;vertical-align:top;">Notes</label>
				#form.notes#
		</div>
		<div id="top108">
			
		</div>
	</div>

	<div id="mid100" class="productBody">
		<table class="pgrid" id="pgrid" cellspacing="0">
			<!--- <thead> --->
				<tr class="GridviewScrollHeader">
					<th>Products/Groups</th>
					<cfloop query="qGetProducts">
						<th title="#qGetProducts.description#">#(qGetProducts.item eq "" ? "" : qGetProducts.item & "<br>")##application.util.string.fullLeft(qGetProducts.description,20)#</th>
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
						<cfset nPrice = oPlannerProgram.getnPrice( qGetProducts.item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID)>
						<td class="numeric">#DollarFormat(nPrice.val)# #nPrice.uom#</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!---------------->
				<!--- EDLP/TPR --->
				<!---------------->
				<tr class="GridviewScrollItem">
					<td>EDLP/TPR</td>
					<cfloop query="qGetProducts">
						<cfset nPrice = oPlannerProgram.getnEDLPPrice(qGetProducts.BSA_Foodservice_Items_Master_ID, form.plannerId, form.Contract_Number) />
						<td class="numeric">#DollarFormat(nPrice.Everyday_Low_Price)#</td>
					</cfloop> <!---  query="qGetProducts" --->
				</tr>

				<!------------------->
				<!--- FIXED PRICE --->
				<!------------------->
				<cfif qHasFixedComp.RecordCount>
					<tr class="GridviewScrollItem">
						<td><i class="fa fa-plus-square"></i> Fixed Price </td>
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

									<cfset "local.discountSum_#thisStripGUID#" = thisFixedRate />
									$
									#NumberFormat(thisFixedRate, "_.__")#
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
						<td><i class="fa fa-plus-square"></i> Rebate</td>
						<cfloop query="qGetProducts">
							<td>&nbsp;</td>
						</cfloop> <!---  query="qGetProducts" --->
					</tr>
					<cfloop index="rebIndx" list="#form.lRebateCompIds#">
						<cfset thisRebId = ListGetAt(rebIndx, 1, "_") />
						<tr id="r_#thisRebId#" class="GridviewScrollItem">
							<td>
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
									<cfset "local.discountSum_#thisStripGUID#" = local[ "discountSum_" & thisStripGUID] + thisRebRate />
									$#NumberFormat(thisRebRate, "_.__")#&nbsp;#oUom.getUomAbbr(thisRebUom)#
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
						<td><i class="fa fa-plus-square"></i> Lump Sum</td>
						<cfloop query="qGetProducts">
							<td>&nbsp;</td>
						</cfloop> <!---  query="qGetProducts" --->
					</tr>
					<cfloop index="lsIndx" list="#form.lLumpSumCompIds#">
						<cfset thisLsId = ListGetAt(lsIndx, 1, "_") />
						<tr id="ls_#thisLsId#" class="GridviewScrollItem">
							<td>
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

									<cfset "local.discountLSSum_#thisStripGUID#" = local[ "discountLSSum_" & thisStripGUID] + thisLsRate />
									$#NumberFormat(thisLsRate, "_.__")#
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
						<cfset input_value = structKeyExists(form, "vol." & qGetProducts.BSA_Foodservice_Items_Master_ID) ? replace(form[ 'vol.' & qGetProducts.BSA_Foodservice_Items_Master_ID ],",", "") : 0>
						<td class="numeric">
							#NumberFormat(input_value)#
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
						<cfset nPrice = oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID)>
						<!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
						<!--- <cfset nUnits = oPlannerProgram.getUnits(qGetProducts.BSA_Foodservice_Items_Master_ID, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID)> --->
						<cfset nUnits = 12 />
						<cfparam name="local.discountSum_#thisStripGUID#" default="0" />
						<cfparam name="form.nucval__#thisStripGUID#" default="0" />
						<cfif local[ "discountSum_" & thisStripGUID] eq "">
							<cfset "local.discountSum_#thisStripGUID#" = 0 />
						</cfif>
						<cfset calc =  (nPrice.val - local[ "discountSum_" & thisStripGUID]) />
						<cfif calc eq 0 or calc eq "">
							<cfset n = 0 />
						<cfelse>
							<cfset n = calc	/ nUnits />
						</cfif>
						<cfset diffCalc = n - form["nucval__" & thisStripGUID] />
						<td class="numeric" id="ruc__#thisStripGUID#">
							#DollarFormat(n)#&nbsp;&nbsp;&nbsp;#DollarFormat(diffCalc)#
							<cfif n lt 0>
								<script>
									$("##ruc__#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##ruc__#thisStripGUID#").addClass("greenDisplay");
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
						<cfset nPrice = oPlannerProgram.getnPrice( qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID )>

						<!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
						<!--- <cfset nUnits = oPlannerProgram.getUnits(qGetProducts.BSA_Foodservice_Items_Master_ID, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID)> --->
						<cfset nUnits = 12 />
						<cfparam name="local.discountLSSum_#thisStripGUID#" default="0" />
						<cfset nAllSum = local[ "discountSum_" & thisStripGUID] + local[ "discountLSSum_" & thisStripGUID] />
						<cfset calc2 = (nPrice.val - nAllSum) />
						<cfif calc2 eq 0 or calc2 eq "">
							<cfset n = 0 />
						<cfelse>
							<cfset n = (nPrice.val - nAllSum)	/ nUnits />
						</cfif>
						<cfset diffCalc = n - form["nucval__" & thisStripGUID] />
						<td class="numeric" id="rucls__#thisStripGUID#">
							#DollarFormat(n)#&nbsp;&nbsp;&nbsp;#DollarFormat(diffCalc)#
							<cfif n lt 0>
								<script>
									$("##rucls__#thisStripGUID#").addClass("redDisplay");
								</script>
							<cfelse>
								<script>
									$("##rucls__#thisStripGUID#").addClass("greenDisplay");
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
							#form[ "everydayprice__" &  Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") ]#
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
							#form[ "merchprice__" &  Replace(qGetProducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL") ]#
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
							<cfset nPrice = oPlannerProgram.getnPrice(qGetProducts.Item, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID)>
							<cfset nMerchantPrice = 0 />
							<cfif qGetMerchPrice2.RecordCount>
								<cfset nMerchantPrice = qGetMerchPrice2.Merchant_Price />
							</cfif>
							<cfparam name="local.discountSum_#thisStripGUID#" default="0" />
							<cfparam name="form.merchprice__#thisStripGUID#" default="0" />
							<!--- TODO: Substitute the number 2 below with the real units per CS from the DB ---->
							<!--- <cfset nUnits = oPlannerProgram.getUnits(qGetProducts.BSA_Foodservice_Items_Master_ID, form.GroupLevel_1, qGetProducts.BSA_Foodservice_Items_Master_ID)> --->
							<cfset nUnits = 12 />
							<cfset ruc = (nPrice.val - local[ "discountSum_" & thisStripGUID]) />
							<cfif ruc eq 0 or ruc eq "">
								<cfset n = 0 />
								<cfset rm = 0 />
							<cfelse>
								<cfset n = ruc / nUnits />
								<cfset rm = (nMerchantPrice - n ) / n/>
							</cfif>
							<cfset rmp = (nMerchantPrice - n )  />
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
</cfoutput>

<cf_include files="/Script/javascript/gridviewScroll.min.js, /script/javascript/jquery.cfjs.min.js,  /script/javascript/numeral.min.js, /script/javascript/date_functions.js">

<script>


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
		

	$(".cd-dropdown-wrapper").remove();
	$("#hdr413").remove();
	$("#hdr419").remove();
		
</script>

</cf_layout_planner_program>




