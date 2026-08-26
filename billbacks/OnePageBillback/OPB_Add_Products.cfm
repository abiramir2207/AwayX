<cfparam name="form.type" default="0">
<cfparam name="form.contract_main_id" default="" >
<cfparam name="form.customer_id" default="" >
<cfparam name="form.component_name_id" default="" >

<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/script/javascript/chosen/chosen.jquery.min.js, /styles/chosen/chosen.css">
<cfset request.ag_grid_theme = "ba-ag-theme-balham">
<cfinclude template="/common_files/ag-grid.cfm">

<cfset request.noty_version = "3">
<cfinclude template="/common_files/noty.cfm">
<link rel="stylesheet" type="text/css" href="/styles/OnePageBillback.css">
<cf_include files="/common_files/tailwind-css.cfm">
		
<cfset qGetDropdowns = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").getDropdowns(1)>

<cfset useLakebaseForqPrgdropdown = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetdropdowns")>
<cfif useLakebaseForqPrgdropdown>
	<cftry>
		<cfset qPrgdropdown = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetdropdowns", {
				"order" = "contract_main_id.asc",
				"select" = "contract_main_id,program_number"
			}), "contract_main_id,program_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPrgdropdown = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPrgdropdown>
<cfquery name="qPrgdropdown" dbtype="query">
	SELECT DISTINCT contract_main_id, Program_Number
	FROM qGetDropdowns
	ORDER BY contract_main_id
</cfquery>
</cfif>

<form id="OPBAddProduct" name="OPBAddProduct" method="post" action="OPB_Add_Products.cfm"> 

<div class="m-0" style="width:auto;margin:5px;">
			<div class="card-header">
				Item Search				
			</div> 
			<div class="card-main flex">
				
				<div class="mr-2">
					<div class="text-left">Program</div>
			       <select name="Contract_Main_ID" id="programID" class="card-input-wide mb-1" style="height:20px;" onchange="clearDropdowns(),updateDropdowns('customerID')">
			          <option value=""> Select an option </option>
			          <cfoutput query="qPrgdropdown">
			          	<option value="#contract_main_id#" <cfif form.contract_main_id EQ contract_main_id>SELECTED</cfif>>#program_number#</option>
			          </cfoutput>
			      </select>
				</div>
				
				<div class="mr-2">
					<div class="text-left">Customer</div>
				   <select name="customer_ID" id="customerID" class="card-input-wide mb-1" style="height:20px;" onchange="updateDropdowns('componentID')">
				  	<option value=""> Select an option </option>
			          <cfoutput query="qGetDropdowns">
			          	<option value="#BSA_Foodservice_Customers_ID#" <cfif form.customer_ID EQ BSA_Foodservice_Customers_ID>SELECTED</cfif>>#customer_name#</option>
			          </cfoutput>
				   </select>
				</div>
				
				<div class="mr-2">
					<div class="text-left">Component</div>
				   <select name="component_name_id" id="componentID" class="card-input-wide mb-1" style="height:20px;">
				  	<option value=""> Select an option </option>
			          <cfoutput query="qGetDropdowns">
			          	<option value="#component_name_id#" <cfif form.component_name_id EQ component_name_id>SELECTED</cfif>>#Component_Name#</option>
			          </cfoutput>
				   </select>
				</div>
				
				<div class="mr-2" style="width:250px;">
				 <input type="hidden" name="type" value = "0" />
				 <div class="text-left" style="height:15px;">&nbsp;</div>	
					<a href="#" onclick="javascript:submitForm(1);">
						<cfoutput>
							#application.util.string.actionLinkFormat2('search products')#
						</cfoutput>
					</a>
					<cfif  form.type EQ 1>
					<a href="#" onclick="javascript:submitForm(2);">
						<cfoutput>
							#application.util.string.actionLinkFormat2('add items')#
						</cfoutput>
					</a>
					</cfif>
				</div>								
			</div>
		</div>     
		<input type="hidden" name="items" id="items" value=""> 

</form>

<cfif form.type EQ 1>

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init()>
	<cfset productGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	<cfset programInfo = programManager.getProgramInfo(FORM.Contract_Main_ID)>	
	<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
	<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() />
	<cfset bBusinessSettingONinTemplate = 0 />

 	<cfparam name="form.Item_Number" default="" >
	<cfparam name="form.Description_String" default="" >
	<cfparam name="form.includeCustomersInProgram" default="0">
	<cfparam name="form.Line_Of_Business_ID" default="" >
	<cfparam name="UserClassCodes" default="">
	<cfparam name="EZButton_ProductList" default="">
	<cfparam name="EzButton_Products" default="0">
	<cfparam name="form.Distributor_List" default=""> 
	<cfparam name="form.Product_Status" default="A"> 
	
	<cfif isdefined("form.LoadProductsFromThesePrograms")>
		<cfif listlen(form.LoadProductsFromThesePrograms) GT 0>
			<cfparam name="form.Contract_Main_ID" default="" >
			<cfparam name="form.Type_Group_Desc_ID" default="" >
			<cfparam name="form.Type_Code_Desc_ID" default="" >
			<cfparam name="form.Q_Brand_ID" default="" >
			<cfparam name="form.Line_Of_Biz" default="" >
			<cfparam name="form.Brand_ID" default="" >
			<cfparam name="form.Line_Of_Biz" default="" >
			<cfparam name="form.Product_Status" default="" >
			<cfparam name="form.Description_String" default="" >
			<cfparam name="form.item_number" default="" >
			<cfparam name="form.upc_number" default="" >
			<cfparam name="form.Rebate_Type_Search_ID" default="" >
			<cfparam name="form.Only_Show_Products_From_These_Groups" default="" >
			<cfparam name="form.passed_form" default= "">
	
			<cfparam name="categoryList" default="" >
			<cfparam name="SHOW_INVOICE_FILTER" default="" >			
			<cfset getLOBCharacter = QueryNew("Line_Of_Business")>
		</cfif>
	</cfif>

	<cfset qTemplateBusinessSegments = queryNew("") />
	<cfif (isBusinessSegEnabledForProduct EQ 1 AND appSettings.Filter_Business_Segments EQ 1)>
		<cfset bBusinessSettingONinTemplate = 1 />
		<cfset useLakebaseForqGetTemplateID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetTemplateID>
	<cftry>
		<cfset qGetTemplateID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#form.Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetTemplateID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetTemplateID>
<cfquery name="qGetTemplateID" datasource="#application.datasource#">
			SELECT ProgramType_ID 
			FROM Contract_Main 
			WHERE Contract_Main_ID = #form.Contract_Main_ID# 
		</cfquery>
</cfif>
		<cfif qGetTemplateID.RecordCount GTE 1 >
			<cfset qTemplateBusinessSegments  = businessSegManager.getBusinessSegmentTemplateSettings(qGetTemplateID.ProgramType_ID) />
		</cfif>
	</cfif>
	
	<cfset restrictOnProductGroup = 0>
	<cfset restrictOnProfileProductGroup = 0>

	<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT Program_Control_Panel_Options.Discount_Rebates_Group_Level
								,Program_Control_Panel_Options.IsDominant
								,Program_Control_Panel_Options.First_Parent_ID
								,exclude_sig_products
								,modifying_program
								,EZButton_On
								,EZ_Contract_Id
								,Distributor_Product_Integrity_Rule_ID
								,Discount_Rebate_Max_Rate_On
								,EzButton_Default_Show_Item_Rates
								,Filter_EZButton_Products
		FROM 	Contract_Main
		INNER JOIN	Program_Control_Panel_Options
		ON 		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		WHERE 	Contract_Main_ID = #FORM.Contract_Main_ID#
	</cfquery>

	<cfif GetSettings.modifying_program EQ 1>
		<cfset restrictOnProfileProductGroup = 1>
		<cfset qRestrictOnModifyingProductGroupList = approvalGroupManager.GetProfileAllowApprovalGroups(request.AccessStructure.Profiles_ID)>
		<cfset restrictOnModifyingProductGroupList = ValueList(qRestrictOnModifyingProductGroupList.Group_ID)>
	</cfif>

	<cfif programInfo.Restrict_On_Approval_Group OR GetSettings.modifying_program EQ 1>
		<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(productGroupLevelId=appSettings.getTemplateRestrictGroupLevel()) />
	</cfif>

	<cfif programInfo.Restrict_On_Approval_Group>
		<cfset restrictOnProductGroup = 1>
		<cfset qRestrictOnProductGroupList = approvalGroupManager.getTemplateAllowApprovalGroups(programInfo.ProgramType_ID)>
		<cfset restrictOnProductGroupList = ValueList(qRestrictOnProductGroupList.Group_ID)>
		<cfif appSettings.getTemplateRestrictGroupLevel() eq 10>
			<cfset restrictOnClassCodeUUIDList = restrictOnProductGroupList>
			<cfset restrictOnProductGroupList = businessSegManager.getClassCodeIDList(restrictOnProductGroupList) />
		</cfif>
	</cfif>

	<cfset stStruct = Form>
	<cfset stStruct.appSettings = appSettings>

	<cfset stStruct.EzTemplate = GetSettings.EZButton_On />
	<cfif (isDefined("qTemplateBusinessSegments") AND qTemplateBusinessSegments.RecordCount GTE 1)>
		<cfset stStruct.Business_Segment_ID_List = ValueList(qTemplateBusinessSegments.Business_Segment_ID) />
	</cfif>

	<cfif appSettings.getUseProductHierarchy()>

		<cfset restrictOnProductHierarchy = 0>
		<cfif restrictOnProductGroup AND  approvalGroupType.groupLevelType EQ 2>
			<cfset restrictOnProductHierarchy = 1>
		</cfif>
		<cfset sExcludeLevelList = appSettings.getSearchProductHierarchyExcludeList() />
		
		<cfif restrictOnProductHierarchy>
			<cfset qGetProductHierarchy = productGroupDataManager.getHierarchyLevel(excludeLevelList=sExcludeLevelList,addParentName=0,getLevelNames=1,restrictOnProductHierarchy=restrictOnProductHierarchy,restrictOnProductHierarchyLevel=approvalGroupType.prodHierLevel,restrictOnProductHierarchyList=restrictOnProductGroupList) />
		<cfelse>
			<cfset qGetProductHierarchy = productGroupDataManager.getHierarchyLevel(excludeLevelList=sExcludeLevelList,addParentName=0,getLevelNames=1) />
		</cfif>
						
		<cfset useLakebaseForqGetDistinctLevels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetproducthierarchy")>
<cfif useLakebaseForqGetDistinctLevels>
	<cftry>
		<cfset qGetDistinctLevels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetproducthierarchy", {
				"select" = "hierarchy_level"
			}), "hierarchy_level"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistinctLevels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistinctLevels>
<cfquery name="qGetDistinctLevels" dbtype="query">
			SELECT	DISTINCT Hierarchy_Level
			FROM	qGetProductHierarchy
		</cfquery>
</cfif>
						
		<cfset stStruct.productHierarchyLevelList = ValueList(qGetDistinctLevels.Hierarchy_Level, ",") />
		
		<cfset maxProductHierarchyLevel = productGroupDataManager.getDistinctHierarchyLevel(getMaxLevel=1)>			
		<cfset stStruct.maxProductHierarchyLevel = maxProductHierarchyLevel>
	</cfif>
	
	<cfif restrictOnProductGroup>
		<cfset stStruct.restrictOnProductGroup = restrictOnProductGroup>
		<cfset stStruct.restrictOnProductGroupList = restrictOnProductGroupList>
		<cfset stStruct.approvalGroupType = approvalGroupType>
	</cfif>
	
	<cfif restrictOnProfileProductGroup>
		<cfset stStruct.restrictOnProfileProductGroup = restrictOnProfileProductGroup>
		<cfset stStruct.restrictOnModifyingProductGroupList = restrictOnModifyingProductGroupList>
		<cfset stStruct.approvalGroupType = approvalGroupType>
	</cfif>

	<cfif isDefined("programInfo") and programInfo.recordcount GT 0>
		<cfset form.Line_Of_Business_ID = programInfo.Line_Of_Business_ID>
	</cfif>
		
	<cfset stStruct.Line_Of_Business_ID 	= Form.Line_Of_Business_ID>
	<cfset stStruct.List_Of_Rebate_Product_ID = "">
	
	<cfif IsDefined("Form.Rebate_Type_Search_ID") AND Form.Rebate_Type_Search_ID NEQ 0>
		<cfset useLakebaseForgetRateTypeProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForgetRateTypeProducts>
	<cftry>
		<cfset getRateTypeProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"deleted" = "eq.0",
				"product_type_id" = "eq.#form.Rebate_Type_Search_ID#",
				"contract_main_id" = "eq.#form.Contract_Main_ID#",
				"select" = "bsa_foodservice_items_master_id,product_type_id,contract_main_id"
			}), "bsa_foodservice_items_master_id,product_type_id,contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRateTypeProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRateTypeProducts>
<cfquery name="getRateTypeProducts" datasource="#Application.Datasource#">
			SELECT     BSA_Foodservice_Items_Master_ID, Product_Type_ID, Contract_Main_ID
			FROM      Contract_Products
			WHERE     Deleted = 0 
			AND Product_Type_ID = '#form.Rebate_Type_Search_ID#'
			AND Contract_Main_ID = '#form.Contract_Main_ID#'
		</cfquery>
</cfif>
		<cfset stStruct.List_Of_Rebate_Product_ID = ListQualify(ValueList(getRateTypeProducts.BSA_Foodservice_Items_Master_ID), "'")>
	</cfif>

	<cfset userClassCodeInThisProductSearch = appSettings.getClassCodesOn() />	
	<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(programInfo.Responsible_User_ID, 0) />
	<cfif userClassCodeInThisProductSearch>
		<cfset UserClassCodes = ValueList(qgetUserClassCodes.class_code_id)>
	</cfif>
	<cfset stStruct.UserClassCodes = UserClassCodes>

	<cfquery name="getCategories" datasource="#application.datasource#">
		SELECT Category_ID
		FROM Category
		WHERE Category IN (#ListQualify(application.returned_customer_setting.Category_List, "'", ",")#) 
		AND Deleted = 0
	</cfquery>
	
	<cfset categoryList = listqualify(valuelist(getCategories.Category_ID), "'", ",")>
	
	<cfset stStruct.categoryList = categoryList />
	
	<cfset stStruct.exclude_sig_products = GetSettings.exclude_sig_products />
	<cfset stStruct.SHOW_INVOICE_FILTER = 1>
	
	<cfset arrayProductGroupSelection		= ArrayNew(1) />
	<cfif appSettings.getOperatingGroupOn()>
		<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
		<cfset productGroupSelectLevel				= operatingGroupManager.getProductGroupSelectLevel() />
		<cfset productGroupSelectLevelValue	= operatingGroupManager.getProgramOperatingGroupID(level=productGroupSelectLevel, programId=FORM.Contract_Main_ID) />
		<cfset qGetProductGroupSelection 		= operatingGroupManager.getProductGroupSelection(productGroupSelectLevelValue) />
		<cfset arrayOperatingGroupProductGroupSelection		= operatingGroupManager.convertProductGroupSelectionToArray(qGetProductGroupSelection, 1) />
		<cfset arrayProductGroupSelection = arrayOperatingGroupProductGroupSelection />
	</cfif>		
	<cfset stStruct.operatingGroupProductGroupFilter = arrayProductGroupSelection>

<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
<cfset qGetProductGroupAttributesGroupTemplateAll = ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1,FirstParentID= GetSettings.First_Parent_ID) />
  	
<cfif (isDefined("form.DTPS_Program_ID") AND form.DTPS_Program_ID NEQ 0 AND GetSettings.First_Parent_ID NEQ 0) >
	<cfset qGetProductGroupAttributesGroupTemplate = qGetProductGroupAttributesGroupTemplateAll />
<cfelse>
	<cfset useLakebaseForqGetProductGroupAttributesGroupTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetproductgroupattributesgrouptemplateall")>
<cfif useLakebaseForqGetProductGroupAttributesGroupTemplate>
	<cftry>
		<cfset qGetProductGroupAttributesGroupTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetproductgroupattributesgrouptemplateall", {
				"pg_flag" = "eq.0",
				"order" = "list_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductGroupAttributesGroupTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductGroupAttributesGroupTemplate>
<cfquery name="qGetProductGroupAttributesGroupTemplate" dbtype="query">
		SELECT *
		FROM qGetProductGroupAttributesGroupTemplateAll
		WHERE PG_Flag = 0
		ORDER BY List_Order
	</cfquery>
</cfif>
</cfif>	
	
	<cfset stStruct.qGetProductGroupAttributesGroupTemplate = qGetProductGroupAttributesGroupTemplate>
	<cfset stStruct.FirstParentID = GetSettings.First_Parent_ID>

	<cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />
	<cfif GetSettings.EZButton_On EQ 1 and url.EZTemplate EQ 0 and (GetSettings.Filter_EZButton_Products EQ 1) AND form.rebateTypeSelected neq 1>
		<cfset EzButton_Products = 1>
	<cfelse>
		<cfset EzButton_Products = 0>
	</cfif>

	<cfif EzButton_Products EQ 1>
		
	    <cfif (GetSettings.isDominant EQ 1)>
	      <cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />
	    <cfelse>
	      <cfset useLakebaseForqryGetLatestTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqryGetLatestTemplate>
	<cftry>
		<cfset qryGetLatestTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"first_parent_id" = "eq.#GetSettings.First_Parent_ID#",
				"isdominant" = "eq.1",
				"deleted" = "eq.0",
				"order" = "programcontrol_panel_options_id.desc",
				"limit" = "1",
				"select" = "ez_contract_id"
			}), "ez_contract_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetLatestTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetLatestTemplate>
<cfquery name="qryGetLatestTemplate" datasource="#application.datasource#">
	      SELECT TOP 1 EZ_Contract_ID
				FROM Program_Control_Panel_Options
				WHERE First_Parent_ID = #GetSettings.First_Parent_ID#
				and IsDominant =1
				and deleted = 0
				ORDER BY ProgramControl_Panel_Options_ID desc
	      </cfquery>
</cfif>
	      <cfset Latest_EZ_Contract_ID = qryGetLatestTemplate.EZ_Contract_ID />
	  	</cfif>
	  	
	  	<cfset EZButtonProgramProductList = ProgramProducts.getEZButtonProductList(Latest_EZ_Contract_ID,url.Discountype,url.component_id,url.isparent,0)/>
		<cfset EZButton_ProductList = valuelist(EZButtonProgramProductList.BSA_Foodservice_Items_Master_ID)>

	</cfif>
	
	<cfset stStruct.EZButtonProductList = EZButton_ProductList />
	<cfset stStruct.Filter_EZButton_Products = GetSettings.Filter_EZButton_Products/>
	<cfset stStruct.EZButton_On = EzButton_Products />
	<cfset stStruct.plannerID = 0 /><!--- plannerID --->
	<cfset searchProducts = productManager.search(search = stStruct, useCache = 1)>

<!---- QUERY OF QUERY TO PREVENT DISPLAYING ITEMS WHICH ALREADY ON PROGRAM---->
<cfset useLakebaseForcurrentProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForcurrentProducts>
	<cftry>
		<cfset currentProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0",
				"is_group" = "eq.0",
				"select" = "bsa_foodservice_items_master_id"
			}), "bsa_foodservice_items_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcurrentProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcurrentProducts>
<cfquery name="currentProducts" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Items_Master_ID 
	FROM Contract_Products
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
	AND Deleted = 0
	AND Is_Group = 0
</cfquery>
</cfif>

<cfset ExisitingItems = ValueList(currentProducts.BSA_Foodservice_Items_Master_ID)>

<cfif len(ExisitingItems)>
	<cfquery name="searchProducts" dbtype="query">
		SELECT * 
		FROM searchProducts
		WHERE BSA_Foodservice_Items_Master_ID NOT IN (<cfqueryparam value="#ExisitingItems#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
	</cfquery>
</cfif>

<div class="flex justify-start" style="width:100%;margin-left:5px;margin-bottom:5px;">
	<input type="text" id="filter-text-box" placeholder="Filter..." oninput="onFilterTextBoxChanged()" size="35" style="border-width:1px"/>
</div>

<div id="item_Results_Grid" class="ag-theme-balham" style="height:580px;"></div>	

<script>
	var item_Results_RowData = <cfoutput>#application.util.query.toAgGridJSON(searchProducts, 'item, upc, description,BSA_Foodservice_Items_Master_ID')#</cfoutput>
	var item_Results_ColumnDefs = [ {headerName: "Item", field: "item", width:150}
													     ,{headerName: "Description", field: "description", width:150}
													     ,{headerName: "BSA ID", field: "BSA_Foodservice_Items_Master_ID", hide: true}
													    ];
	// Init Item Results grid
	var item_Results_GridOptions = {
		columnDefs: item_Results_ColumnDefs
		,rowData: item_Results_RowData
		,rowModelType: "clientSide"
		,cacheBlockSize: 2000
		,debug: false
		,rowSelection: "multiple"
		,rowDeselection: true
		,onRowSelected: onRowSelected
		,pagination: "true"
		,defaultColDef: {
	         width: 100
	        ,headerCheckboxSelection: isFirstColumn
	        ,checkboxSelection: isFirstColumn
	        ,resizable: true
    }
	};
	ag_grid_default(item_Results_GridOptions);		// set up default features
	init_ag_grid( item_Results_GridOptions, "#item_Results_Grid", false );  // init item_Results client-side grid
	item_Results_GridOptions.api.sizeColumnsToFit();

function onRowSelected(event) {	
	item_Results_GridOptions.api.forEachNode( function (node) {
		var itemGUID = node.data.bsa_foodservice_items_master_id;
		var item = $('#items').val();

		if (node.isSelected()) {
			if(! item.includes(itemGUID)){
				item = item.concat(',').concat(itemGUID);
			}
		}else{
			item = item.replace(itemGUID, "");
		}    
		$('#items').val(item)
	});
}

function isFirstColumn(params) {
	var displayedColumns = params.columnApi.getAllDisplayedColumns();
	var thisIsFirstColumn = displayedColumns[0] === params.column;
	return thisIsFirstColumn;
}
	
function onFilterTextBoxChanged() {
	item_Results_GridOptions.api.setQuickFilter(document.getElementById('filter-text-box').value);
}
</script>

<cfelseif form.type EQ 2>

	<cfset addItems = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").insertNewItems(stForm = FORM)>

<script>
	window.opener.addItems();
	self.close();
</script>

 </cfif>
 
 <script>
	$('#customerID, #componentID').prop("disabled", true);

function clearDropdowns(){
	$('#customerID, #componentID').empty();
	$('#customerID, #componentID').append('<option > Select an option </option>');
}

function updateDropdowns(type){ 
	$.ajax( {
		type: "POST",
		url: "/mvc/Models/OnePageBillback/OPBManager.cfc?method=getDropdowns&ReturnFormat=json",
		data: ({	
						 type: type
						,contract_main_id : $("#programID").val()	
				   }),
		dataType: 'json',
		success: function(response){
			$('#'+type).empty();
			$('#'+type).append('<option > Select an option </option>');
			for (var i = 0; i < response.DATA.length; i++){
				$('#'+type).append('<option title="' + response.DATA[i][1] + '"  value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
			}
			$('#'+type).prop("disabled", false);
		},
		error: function(xhr, textStatus, errorThrown){ alert('request failed');}
	});
}

function submitForm(submitter){
	var prgID = $( "#programID" ).val();
	var thisForm = document.getElementById('OPBAddProduct');
	var errors = [];

	if (prgID === ''){
		errors.push("Please select a program.");
	}
	if(submitter == 2 && $('#items').val() ==''){
		errors.push("Please select an item.");
	}
	if (errors.length) {
		new Noty({ layout:"center", type:"error", text: noty_message(errors.join("<br>")) }).show();
	}else{	  
		$('select').removeAttr('disabled');
		thisForm.type.value = submitter;
		thisForm.submit(); 
	}
}		 
</script>