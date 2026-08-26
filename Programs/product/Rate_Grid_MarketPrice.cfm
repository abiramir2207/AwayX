<!---
Note: This file is a modified version of "Rate_Main_Grid".cfm. "Rate_Main_Grid".cfm has
the discount type logic (rabate and fixed price), but this file does not.
There are also many features which are a part of "Rate_Main_Grid".cfm, but does not exist here. --->
<script>
var price_header_name = "price";
var bFilterByRate = false;
var bfilterByVarianceMP = false;
var bfilterByMP = false;
var bfilterByGroup = false;
var bfilterByItem = false;
var bfilterByProdStatus = false;
var bfilterBySelectedRecords = false;
var uomList = [];
var fmt_4_decimal_places = '(0,0.0000)'; // 4 decimal places
var fmt_2_decimal_places = '(0,0.00)';	// 2 decimal places
var Rate_GridOptions = {};	// Global so can access API later
var arrObjProducts = [];
var arrObjComponentsDef = [];
var arrObjSelectedComponent = [];
var objProgram = {};

var columnDefs_ratesGrid_MarketPrice = [
	{width:24, checkboxSelection:true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, filter:false, resizable:false, suppressToolPanel:true, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true, suppressNavigable:true},
	{headerName: "Item", suppressToolPanel:false, width:100, autoHeight: true,field: 'baItemDisplay', suppressNavigable:true},
	{headerName: "Description", suppressToolPanel:false, width:125, autoHeight: true ,field: 'Description', suppressNavigable:true},
	/* This column stores the "Price/MP rate" and is hidden. Whenever we add a component, we copy the data from here
	and add a new "Price" column for that component.
	Note:The product data loads on initial load, but we need to add the "Price" column per component. */
	{headerName: "Item UOM", suppressToolPanel:true, field: 'uomMP.uomId', hide:true},
	{headerName: "Market Price CS", suppressToolPanel:true, field: 'marketPriceCS', hide:true},
	{headerName: "Market Price LB", suppressToolPanel:true, field: 'marketPriceLB', hide:true}
]

function Build_Rate_Grid_MarketPrice() {
	Rate_GridOptions = {
		blackSmith: { fullHeight: true, height_offset: -22 },
		columnDefs: columnDefs_ratesGrid_MarketPrice
		,floatingFilter: true
		,rowData: arrObjProducts
		,rowModelType: "clientSide"
		,rowSelection: "multiple"
		,suppressContextMenu: true
		,enableBrowserTooltips: true
		,isExternalFilterPresent: isExternalFilterPresent
		,doesExternalFilterPass: showFilteredRecords
		,getRowNodeId: function(data) { return data.itemGuid }
		,defaultColDef:	{
				editable:                      false
				,floatingFilterComponentParams: { suppressFilterButton: true }
				,singleClickEdit:				true
				,suppressMenu:                  true
				,suppressMovable:               false
				,unSortIcon:                    false
				,sortable:                      true
				,resizable:                     true
				,suppressToolPanel:				true	// Default to no show/hide col, override per column
				,filter:                        'agTextColumnFilter'
		}
		,statusBar: footerbar("filtered_and_total")
    };
	Rate_GridOptions.sideBar = { toolPanels: [
			{
				id: 'columns',
				labelDefault: 'Columns',
				labelKey: 'columns',
				iconKey: 'columns',
				toolPanel: 'agColumnsToolPanel',
				toolPanelParams: {
					suppressColumnExpandAll: true,
					suppressColumnFilter: true,
					suppressColumnSelectAll: true,
					suppressPivotMode: true,
					suppressPivots: true,
					suppressRowGroups: true,
					suppressValues: true,
				}
			}
		]
	};
	ag_grid_default(Rate_GridOptions);		// set up default features
	init_ag_grid( Rate_GridOptions, "#Rate_Grid", false );   // false=setup as client side
}

function loadComponentData(){
	$.ajax({
		url: "/mvc/models/Program/Component/ComponentDefManager.cfc"
		,type: "POST"
		//,async: true
		,dataType: "json"
		,data: { method: "getComponentDefJSON"
				<!--- "url.programID" is actually "marketPriceListId", passed as "url.programID" from the template "filters" tab ("rates" link) --->
				,programId: <cfoutput>'#url.programID#'</cfoutput>
				,bMarketPrice: 1
		 }
		,success: function( response ) {
			arrObjComponentsDef = response;
			loadComponentDropDown();
		}
	});
}

function hide_loader() {
	$(".loader").hide();
}

function loadRateData(){
	show_loader( "LOADING, PLEASE WAIT...");

	$.ajax({
		url: "/mvc/models/Item/ItemSearchService_Groups.cfc"
		,type: "POST"
		,dataType: "json"
		,data: {
			ProgramId: <cfoutput>'#url.programID#'
			,StatusFilterOn: #statusFilterOn#
			,bAll: 1
			,bMP:	1
			,TemplateFiltersID: #url.TemplateFiltersID#
		</cfoutput>
		,method: "getAllItemsJSON"
		}
		,success: function( response ) {
			$.ajax({
				url: "/mvc/models/Program/ProgramManager.cfc"
				,type: "POST"
				//,async: true
				,dataType: "json"
				,data: { ProgramId: <cfoutput>'#url.programID#'
						,bMarketPrice: 1
				</cfoutput>
				,method: "getProgramJSON"
				}
				,success: function( responseProgram ) {

					/* add the product attribute columns */
					 responseProgram.arrPrdAttr.forEach(function(item){
						columnDefs_ratesGrid_MarketPrice.push({headerName: item.groupLevelDesc, field: item.productGroupAttributeNameField, suppressToolPanel:false, width:100, suppressNavigable:true,
							// For these, filter via a list of choices
							floatingFilterComponentParams: { suppressFilterButton: false },
							/* "agSetColumnFilter" automatically adds the unique records on the column to the filter dropdown. */
							filter: 'agSetColumnFilter',
        					filterParams: {cellHeight: 20}
						})
					});

					/* Create the grid */
					Build_Rate_Grid_MarketPrice();
					hide_loader();

					arrObjProducts = response;

					/* Add all the "item master" products to the grid.*/
					Rate_GridOptions.api.setRowData(arrObjProducts);

					objProgram = responseProgram;

					if(objProgram.components.length){
						loadComponentData();

						/* Once all the component's get loaded on the grid, the component dropdown will
						have one of them selected. Make that the first one on the grid.
						Looks like when we access the "Rates grid" (template rates grid) from the template, there is only one component.
						It is only on the "rates grid" inside the program, where we have multiple components. */
						arrObjSelectedComponent = objProgram.components[0].componentDef;
					}

					/* Loop through the program components */
					objProgram.components.forEach(function(item){

							/* Add components on the grid */
							addComponent(item);

							/* Loop through the product/component rates and populate the values for different columns on the grid */
							item.prodRate.forEach(function(item1){

								let rowNode = Rate_GridOptions.api.getRowNode(item1.itemGuid);

								if(rowNode !== undefined)
								{
									rowNode.data['rate_'+item.componentId] = numberFormat(parseFloat(item1.rate),fmt_4_decimal_places);
									rowNode.data['uom_'+item.componentId] = item1.uom.uomId;

									/* Looks like what happens is that whenever a user enters a rate and then clicks on save, that rate entered, becomes the market price
									of the product and so while loading the data, we can use market rate (marketPriceCS or marketPriceLB) as the column to populate
									the "price" column.*/
									let rateMPCS = numberFormat(parseFloat(rowNode.data.marketPriceCS),fmt_4_decimal_places);
									let rateMPLB = numberFormat(parseFloat(rowNode.data.marketPriceLB),fmt_4_decimal_places);

									/* If the UOM is "LB" */
									if(item1.uom.uomId == 2){
										rowNode.data['marketPrice_'+item.componentId] = rateMPLB;
									}
									else{
										rowNode.data['marketPrice_'+item.componentId] = rateMPCS;
									}

									/* Since we are not dealing with any discount type, variance logic is the same as what is would be for fixed price on "Rate_Main_Grid.cfm" */
									/* If the UOM is "LB" */
									if(item1.uom.uomId == 2 && rateMPLB != 0){
										rowNode.data['variancePercMP_'+item.componentId] = numberFormat(parseFloat((((rateMPLB - item1.rate)/rateMPLB) * 100)),fmt_2_decimal_places);
									}
										/* If the UOM is "CS" */
									else if(item1.uom.uomId == 1 && rateMPCS != 0){
										rowNode.data['variancePercMP_'+item.componentId] = numberFormat(parseFloat((((rateMPCS - item1.rate)/rateMPCS) * 100)),fmt_2_decimal_places);
									}
								}
							});
					});

					Rate_GridOptions.api.refreshCells();

					/* Filter on initial load */
					filterOnLoad();
				}
			});
		}
	});
}

function loadComponentDropDown(){
	let compDrpDown = "#cboCompName";
	$(compDrpDown + " option").remove();//clear all the options

	/* Add the component entries to the "component" dropdown. */
	for(var i= 0; i< arrObjComponentsDef.length; i++){
		$(compDrpDown).append('<option value="' + arrObjComponentsDef[i].componentId + '">' + arrObjComponentsDef[i].name + "</option>'");
	}

	/*  Loop though the existing components to find the first component which matches the entire component list.
	Set the selected component (arrObjSelectedComponent) to the first one found.
	Looks like we only have one component in the "template rates grid". It is only in the "Rates grid" inside the program, where
	we have multiple components. */
	let breakloop = 0;

	for(var i= 0; i< arrObjComponentsDef.length; i++){
		for(var j= 0; j< objProgram.components.length; j++){
			if(objProgram.components[j].componentId == arrObjComponentsDef[i].componentId){
				arrObjSelectedComponent = arrObjComponentsDef[i];
				breakloop = 1;
				break;
			};
		}
		/* Break out of the outer loop as well */
		if(breakloop == 1){
			break;
		}
	}

	/* If no component has been added to the template, then set the selected component to be the first one on the dropdown.*/
	if(breakloop == 0){
		for(var i= 0; i< arrObjComponentsDef.length; i++){
				arrObjSelectedComponent = arrObjComponentsDef[i];
				break;
		}
	}

	/* Below code is useful when the page loads for the first time and the component dropdown selected option is the first component on the grid */
	$('#cboCompName').val(arrObjSelectedComponent.componentId);

	loadUOMdropDown();

	/* Fire the change event, so that next steps can be taken. */
	$('#cboCompName').change();
}

$('#cboCompName').change(function(){
	callSelectedComponentDef($('#cboCompName').val());
});

function callSelectedComponentDef(selectedComponentID){
	setSelectedComponentDef(selectedComponentID);
	enableDisableMassApplyOptions();
	hideShowFilterOptions();
	loadMassApplyOptionsDropdown();
}

/* Whatever option was selected from the "Components" dropdown, becomes the "arrObjSelectedComponent" */
function setSelectedComponentDef(componentId){
	for(var i= 0; i< arrObjComponentsDef.length; i++){
		if(componentId == arrObjComponentsDef[i].componentId){
			arrObjSelectedComponent = arrObjComponentsDef[i];
			break;
		}
	}
}

function addComponent(comp){
	let compDrpDown = "#cboCompName";
	let selectedOptionValueName = $(compDrpDown + " option:selected").text();

	if(comp.bMarketPriceTemplate == true){
		price_header_name = 'MP rate';
	}

	columnDefs_ratesGrid_MarketPrice.push({headerName: comp.name
		,suppressToolPanel:true
	,children:
	[	{headerName: "rate", field: 'rate_'+comp.componentId, editable:true, width:70
			,type:'numericColumn'
			,filter:false
			,cellEditor:NumericCellEditor
			,cellEditorParams: {
				min: "0",
				// max: "1000",
				step: "0.0001"	// valid decimal places
			}
			,valueSetter: function(params) {
				if (params.oldValue !== params.newValue) {
					let rateColumn = 'rate_'+ comp.componentId;
					params.data[rateColumn] = numberFormat(parseFloat(params.newValue),fmt_4_decimal_places)
					return true;
				} else {
					return false;
				}
			}
			,onCellValueChanged: function(params) {
				if(params.oldValue != params.newValue){
					let uniqueColumnID = comp.componentId;
					setDiscountValue(params.data,'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);
					updateRate(comp.componentId,params);
					/* While entring a rate. in case the user tabs from rate to UOM, below code (selectedUomIdx and updateUOM) is not needed , but in case the
					user enters a rate and does not tab to the UOM column, then below code is needed to populate the UOM column.
					"selectedUomIdx" populates the UOM column and "updateUOM" updates the program object, as that is what is sent to the server. */
					selectedUomIdx(params,comp);
					updateUOM(comp.componentId,params.data.itemGuid,params.data['uom_'+uniqueColumnID]);
				}
			}
		}
	]
	});

	/* Since we need to use conditonal logic before adding these columns, we could not add below
	columns directly in the "children" array above. */
	columnDefs_ratesGrid_MarketPrice.forEach(function(itemCol){
		if(itemCol.hasOwnProperty("children")){
			/* First child column is "rate". Just verifying that these children are part of the component, since
			we do not want to add the "shipTo" columns for headers which are not a program component. */
			if(itemCol.children[0].headerName == "rate"){
				/*  The digits(s) after the last underscore "_" is the component ID.
				We are looking for index of 1 because the field is in the following format:
				"rate_ComponentID" So, the last index will be 1 in this case. */
				let compid = itemCol.children[0].field.split('_')[1];

				/* Find the correct component. */
				if(compid == comp.componentId){
					itemCol.children.push(
						{headerName: "uom", field: 'uom_'+comp.componentId, editable:true, width:50
							,filter:false
							,cellRenderer: existingUOMCellRenderer
							,cellEditor: 'agRichSelectCellEditor'
							,cellEditorParams: {
								cellRenderer: existingUOMCellRenderer
								,values:	getUOMList(objProgram.components)
							}
							,cellClass:'drop-down-arrow'
							,onCellValueChanged: function(params) {
								/* setMarketPriceBasedOnUOM(params); */
								let uniqueColumnID = comp.componentId;
								/* In case UOM is blank, function "selectedUomIdx" will set the default UOM.
								Note: it is important to set UOM here using function selectedUomIdx.
								When "setDiscountValue" is fired, the correct UOM selected value is passed to the function. */
								selectedUomIdx(params,comp);
								setDiscountValue(params.data,'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);
								/* Sometimes, for some reason, "params.newValue" does not exist
								and that is why the updated value (params.data['uom_'+uniqueColumnID]) is being passed */
								updateUOM(comp.componentId,params,params.data['uom_'+uniqueColumnID]);
							}
						}
					);

					let priceHeaderColumnFound = 0;
					let discountPercentColumnFound = 0;

					for(var i= 0; i< itemCol.children.length; i++){
						if(itemCol.children[i].headerName == price_header_name){
							priceHeaderColumnFound = 1;
							break;
						}
					}

					for(var i= 0; i< itemCol.children.length; i++){
						if(itemCol.children[i].headerName == "disc %"){
							discountPercentColumnFound = 1;
							break;
						}
					}

					/* Add "price/market rate" column */
					if(priceHeaderColumnFound == 0){
						itemCol.children.push({headerName: price_header_name, field: 'marketPrice_'+comp.componentId, editable:false, type:'numericColumn', filter:false, width:50, suppressNavigable:true});
					}
					/* Add "disc %" column */
					if(discountPercentColumnFound == 0){
						itemCol.children.push({headerName: 'disc %', field: 'variancePercMP_'+comp.componentId, editable:false, type:'numericColumn', filter:false, width:50, suppressNavigable:true});
					}

				}//Find the correct component (end)
			}
		}
	});

	Rate_GridOptions.api.setColumnDefs(columnDefs_ratesGrid_MarketPrice);
	/*setMarketPriceForAllProducts(comp);*/
}
<!---
/* This function copies the "MP Rate" column data to the newly added component, based on UOM. */
function setMarketPriceForAllProducts(selectedComponent){
	/* "node.setValue" is slow. Using "rowNode.data" to update data. */
	arrObjProducts.forEach(function(item){
		let rowNode = Rate_GridOptions.api.getRowNode(item.itemGuid);

		if(item.uomMP.uomId == 2){
			rowNode.data['marketPrice_'+selectedComponent.componentId] = item['marketPriceLB'];
		}
		else{
			rowNode.data['marketPrice_'+selectedComponent.componentId] = item['marketPriceCS'];
		}
	});
	Rate_GridOptions.api.refreshCells();
}
--->
<!---
/* When a user changes the UOM, then the market price value based on UOM is set. */
function setMarketPriceBasedOnUOM(params){
	let arrColName = params.colDef.field.split('_');

	/* arrColName[1] is the component id. */
	let id = 'marketPrice_'+ +arrColName[1];

	if(params.newValue == 2){
		params.node.data[id] = params.node.data.marketPriceLB;
		params.node.data['marketPrice'] = params.node.data.marketPriceLB;
	}
	else{
		params.node.data[id] = params.node.data.marketPriceCS;
		params.node.data['marketPrice'] = params.node.data.marketPriceCS;
	}
	Rate_GridOptions.api.refreshCells(params);

	updateMarketPrice(arrColName[1],params.data.itemGuid,params.node.data['marketPrice']);
}
--->

/* "rateMP" in prodRate are used while saving data. It is important to update these values. */
function updateMarketPrice(componentID,itemID,updatedMarketPrice){
	let exitLoop = 0;

	objProgram.components.some(function(item){
		/* Find the component passed to this function in "objProgram.components", based
			on componentID passed to this function. */
		if(item.prodRate !== undefined && item.componentId == componentID){
			item.prodRate.some(function(item1){
				if(itemID == item1.itemGuid){
					item1.rateMP = updatedMarketPrice;
					exitLoop = 1;
					return true; //exit loop*/
				}
			});
		}
		if(exitLoop == 1){
			return true;//exit the outer loop as well
		}
	});
}

function massApplyRatesAndUOM(){
	let tiRate = Number($("#tiRate").val());
	let cboUom = $('select[name=cboUom] option:selected').val();
	let applyRateOption = $('select[name=apply_rdoUomActionGrp] option:selected').val();
	let arrSelectedRecords = Rate_GridOptions.api.getSelectedRows();
	let uniqueColumnID;
	addProdRateObjForNewCompAndItemCombination(arrSelectedRecords);

	/* Loop through the selected records and do the following -
	a) update the "objProgram.components" object with the updated rate and/or UOM.
	b) update the grid  with the updated rate and/or UOM. */
	arrSelectedRecords.forEach(function(item){
		objProgram.components.forEach(function(item1){
			item1.prodRate.forEach(function(item2){
				if(item.itemGuid == item2.itemGuid){
					let rowNode = Rate_GridOptions.api.getRowNode(item.itemGuid);
					if(item1.componentId == arrObjSelectedComponent.componentId){

						uniqueColumnID = item1.componentId;

						if(applyRateOption == '0' || applyRateOption == ''){ /* "abs" selection or no selection */
							/* In cases where the user only wants to apply UOM and not rate, then in that case,
							" applyRateOption == '0' and tiRate != '' " logic will be useful. */
							if(applyRateOption == '0'){/* abs */
								if(tiRate != ''){
									item2.rate = tiRate;
								}
							}
							item1.uom.some(function(itemUOM){
								if(itemUOM.uomId == cboUom){
									item2.uom = itemUOM;
								}
							});
						}
						else if(applyRateOption == '1'){ /* inc */
							item2.rate = Number(item2.rate) + tiRate;
						}
						else if(applyRateOption == '2'){ /* % chg */
							item2.rate = Number(item2.rate) + ((Number(item2.rate) * tiRate) / 100);
						}
						else if(applyRateOption == '3'){ /* % price chg */
							if(selectedDiscountType == rebate_type_id){
								item2.rate = Number(item.marketPrice) - (Number(item.marketPrice) + ((Number(item.marketPrice) * tiRate) / 100));
							}
							else{
								item2.rate =  Number(item.marketPrice) + ((Number(item.marketPrice) * tiRate) / 100);
							}
						}
						else if(applyRateOption == '4'){ /* inc price chg */
							if(selectedDiscountType == rebate_type_id){
								item2.rate = (Number(item.marketPrice) + tiRate) - Number(item.marketPrice);
							}
							else{
								item2.rate =  Number(item.marketPrice) + tiRate;
							}
						}
						else if(applyRateOption == '5'){ /* eq price rate */
							item2.rate = Number(item.marketPrice);
						}

						rowNode.data['rate_'+uniqueColumnID] = numberFormat(parseFloat(item2.rate),fmt_4_decimal_places);;

						/* For mass apply, we can apply UOM only for the "Abs" option ("applyRateOption == '0' ").
						"applyRateOption == '' when the default (no option) option is selected. That can be used
						to just apply UOM, even if rate does not need to be applied. */
						if(applyRateOption == '0' || applyRateOption == ''){
							rowNode.data['uom_'+uniqueColumnID] = item2.uom.uomId;
						}
						/* For options other than "Abs", we will set the default UOM, if the UOM is not already set. */
						else{
							let colUOM = rowNode.data['uom_'+uniqueColumnID];
							if(colUOM == undefined){
								colUOM = selectedUomIdx(rowNode,item1);
							}
							/* When the user selects the "Abs" option, there is code above in this function to update the UOM object in
							"objProgram.components", but in this case we are setting the default UOM. Below code takes care of updating the
							 UOM object in "objProgram.components" */
							item1.uom.some(function(itemUOM){
								if(itemUOM.uomId == rowNode.data['uom_'+uniqueColumnID]){
									item2.uom = itemUOM;
								}
							});
						}
						/* Call this function manually. If we would have used "setRowData", instead of "rowNode.data", then the "onCellValueChanged"
						function would be automatically called and below function does not need to be called manually. We canot use "setRowData",
						as it is very slow, when we are dealing with a lot of records. */
						setDiscountValue(rowNode.data,'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);

						/* NOTE: Do not call the "updateUOM" OR "updateRate" function from here. The "objProgram.components"
						has already been updated in this function and so there is no need. In fact calling the "updateUOM"
						from here will cause issues in the UOM object of "objProgram.components". */
					}
				}
			});
		});
	});
	Rate_GridOptions.api.refreshCells();
}

function addProdRate(objItem){
	objProgram.components.some(function(item){
		/* Create a new "prodRate" object for very component. If the "prodRate" object is the same
		for multiple components (code outside the component loop), then the memory space for
		all those component's "prodRate" object will be the same, which we do not want. */
		let prodRate = new Object();
		let arrProdRateList = [];

		prodRate["itemGuid"] = objItem.itemGuid;
		prodRate["itemNumber"] = objItem.baItem;
		prodRate["description"] = objItem.Description;
		prodRate["netWeight"] = 1;
		prodRate["bActive"] = objItem.bActive;

		/* RATE */
		prodRate["rate"] = 0;
		prodRate["rateMP"] = objItem.marketPrice;
		//for custom price, rateMP is calculated based on MP price.  we need to store original MP
		prodRate["rateMPOrig"] = objItem.rateMPOrig;
		prodRate["rateMPCS"] = objItem.rateMPCS;
		prodRate["rateMPLB"] = objItem.rateMPLB;

		/* VARIANCE */
		prodRate["variancePercMP"] = 0;
		prodRate["MPApprovalVariance"] = 0;

		/* UOM */
		prodRate["uom"] = new Object();
		prodRate["uom"].uomId = 0;
		prodRate["uom"].description = "";
		prodRate["uom"].abbreviation = "";

		/* UOMDP */
		prodRate["uomMP"] = new Object();
		prodRate["uomMP"].uomId = 0;
		prodRate["uomMP"].description = "";
		prodRate["uomMP"].abbreviation = "";

		/* If the "prodRate* array does NOT EXIST or the component, i.e., rate for no product
		has been added for that component. */
		if(item.prodRate == undefined){
			item["prodRate"] = [];
		}
		else{
			/* If the "prodRate* array EXISTS for the component, then create an array of products for which the
			"prodRate* array EXISTS. */
			item.prodRate.forEach(function(item1){
				arrProdRateList.push(item1.itemGuid);
			});
		}

		/* If the item for which this function is called, does not exist in the "prodRate* array for the component,
		then add the placeholder "prodrate" array. */
		if($.inArray(objItem.itemGuid, arrProdRateList) == -1){
			item["prodRate"].push(prodRate);
		}
	});
}

function enableDisableMassApplyOptions(){
	let rateVal = $("#tiRate").val();
	let applyRateOption = $('select[name=apply_rdoUomActionGrp] option:selected').val();

	/* Note:"eq price rate"  does not exist as an option and so we DO NOT have the "applyRateOption" == 5 option */
	if(Number(rateVal) || rateVal == '0' || rateVal == ''){
		/* Rate cannot be applied, if a user has not selected any option - like "abs" etc. */
		if(Number(rateVal) && applyRateOption == ''){
				$("#setRateUomBtn").prop("disabled", true);
		}
		else{
			$("#setRateUomBtn").prop("disabled", false);
		}
	}
	else{
		$("#setRateUomBtn").prop("disabled", true);
	}
}

function loadMassApplyOptionsDropdown(){
	$("#apply_rdoUomActionGrp" + " option").remove();//clear all the options

	let compDrpDown = $("#apply_rdoUomActionGrp");
	let arrMassApply = [];

	arrMassApply.push('Abs');
	arrMassApply.push('Inc');
	arrMassApply.push('% chg');
	arrMassApply.push('% price chg');
	arrMassApply.push('Inc price chg');

	$(compDrpDown).append('<option value="' + '' + '">' + 'Apply...' + "</option>'");
	for(var i= 0; i< arrMassApply.length; i++){
		$(compDrpDown).append('<option value="' + i + '">' + arrMassApply[i] + "</option>'");
	}
}

function hideShowFilterOptions(){
	let bGroup = false;
	let allowInSearch = false;

	objProgram.arrPrdAttr.some(function(item){
		if(item.allowInGroupSearch == true){
			bGroup = true;
			return true; // exit the loop
		}
	});

	if(! bGroup && objProgram.template.bGroupDeal && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
		$("#chFilterGroup").hide();
		$('label[for="chFilterGroup"]').hide();
		$("#chFilterItem").hide(); // Hide the "items" filter also, when groups do not exist. (all are items).
		$('label[for="chFilterItem"]').hide();// Hide the "items" filter also, when groups do not exist. (all are items).
	}
}

function loadUOMdropDown(){
	$("#cboUom" + " option").remove();//clear all the options

	/* Get the data */
	var uom = arrObjSelectedComponent.uom;

	/* Populate "uom" dropdown. */
	for(var i= 0; i< uom.length; i++){
		$("#cboUom").append('<option value="' + uom[i].uomId + '">' + uom[i].abbreviation + "</option>'");
	}
}

function saveData(){
	$.ajax({
			url: "/mvc/Models/Program/Component/ComponentManager.cfc"
			,type: "POST"
			,dataType: "json"
			,data: { method: "saveComponentDataJSON"
					,programId:
					<cfoutput>'#url.programID#'
					,acComponents:JSON.stringify(objProgram.components)
					,bMarketPrice: 1
					</cfoutput>
			 }
			,success: function( response ) {
				window.close();
			}
	});
}

/* Calculate "variance". */
function setDiscountValue(paramsData, variancePercentColumn, marketPriceColumn, rateColumn, uomColumn){
	if(paramsData[marketPriceColumn] != 0 && paramsData[marketPriceColumn] !== undefined){
		paramsData[variancePercentColumn] = numberFormat(parseFloat((((paramsData[marketPriceColumn] - paramsData[rateColumn])/paramsData[marketPriceColumn]) * 100)),fmt_2_decimal_places);
		Rate_GridOptions.api.refreshCells();
	}
}

function isExternalFilterPresent() {
	let filterOptionChecked = false;
		bFilterByRate = false;
		bfilterByVarianceMP = false;
		bfilterByMP = false;
		bfilterByGroup = false;
		bfilterByItem = false;
		bfilterByProdStatus = false;
		bfilterBySelectedRecords = false;

	if($('#chFilterRates').is(":checked") || $('#chFilterSelected').is(":checked")
		|| $('#chFilterVarianceMP').is(":checked") || $('#chFilterMP').is(":checked")
		|| $('#chFilterItem').is(":checked") || $('#chFilterGroup').is(":checked")
		|| $('#cboProductStatus').val() != 'All Status'){
			filterOptionChecked = true;
	}

	if($('#chFilterRates').is(":checked")){
		bFilterByRate = true;
	}
	if($('#chFilterSelected').is(":checked")){
		bfilterBySelectedRecords = true;
	}
	if ($('#chFilterVarianceMP').is(":checked")){
		bfilterByVarianceMP = true;
	}
	if ($('#chFilterMP').is(":checked")){
		bfilterByMP = true;
	}
	if ($('#chFilterItem').is(":checked")){
		bfilterByItem = true;
	}
	if ($('#chFilterGroup').is(":checked")){
		bfilterByGroup = true;
	}
	if($('#cboProductStatus').val() != 'All Status'){
		bfilterByProdStatus = true;
	}

	return filterOptionChecked;
}
function showFilteredRecords(node) {
	/* Note: The reason why a second variable for every filter (wg: bFilterByRate and bFilterRate)
	is created is to filter fast. This way we can just use the boolean value to decide whether records
	need to be filtered or not.Without it, it is quite slow. */

	let bFilterRate = true;
	let bfilterSelectedRecords = true;
	let bFilterVarianceMP = true;
	let bfilterMP = true;
	let bfilterItem = true;
	let bfilterGroup = true;
	let bfilterProdStatus = true;

	if(bFilterByRate){
		objProgram.components.some(function(item){
			if(item.prodRate){
				if(item.prodRate.length){
					item.prodRate.some(function(item1){
						if(item1.rate != 0 && item1.itemGuid == node.data.itemGuid){
							bFilterRate = true;
							return true;// exit the "prodrate" loop
						}
						else{
							bFilterRate = false;
						}
					});
					if(bFilterRate == true){
						return true;// exit the "objProgram.components" loop
					}
				}
				else{
					bFilterRate = false;
				}
			}
			else{
				bFilterRate = false;
			}
		});
	}

	if(bfilterBySelectedRecords){
		if(node.selected == false){
			bfilterSelectedRecords = false;
		}
	}

	if(bfilterByVarianceMP){
		objProgram.components.some(function(item){
			if(item.prodRate){
				if(item.prodRate.length){
					item.prodRate.some(function(item1){
						if((item1.rate != node.data.marketPrice) && item1.itemGuid == node.data.itemGuid){
							bFilterVarianceMP = true;
							return true;// exit the loop
						}
						else{
							bFilterVarianceMP = false;
						}
					});
					if(bFilterVarianceMP == true){
						return true;// exit the loop
					}
				}
				else{
					bFilterRate = false;
				}
			}
			else{
				bFilterRate = false;
			}
		});
	}

	if(bfilterByMP){
		if(node.data.marketPrice == '' || node.data.marketPrice == 0){
			bfilterMP = false;
		}
	}

	if(bfilterByItem){
		if(node.data.isGroup == true){
			bfilterItem = false;
		}
	}

	if(bfilterByGroup){
		if(node.data.isGroup == false){
			bfilterGroup = false;
		}
	}

	if(bfilterByProdStatus){
		if(node.data.Item_Status != $('#cboProductStatus').val()){
			bfilterProdStatus = false;
		}
	}

	return (bFilterRate == true && bfilterSelectedRecords == true && bFilterVarianceMP == true && bfilterMP == true && bfilterItem == true
			&& bfilterGroup == true && bfilterProdStatus == true
			);
}

function externalFilterChanged(){
   Rate_GridOptions.api.onFilterChanged();
}

/* This gets called when adding a new component.
This loops through "arrObjComponentsDef". */
function newUOMCellRenderer() {}
	newUOMCellRenderer.prototype.init = function (params) {

		this.eGui = document.createElement('span');
		if (params.value !== "" || params.value !== null) {
			let uomStr = '';
			/* Loop through "arrObjComponentsDef" and get the "abbreviation"
			for the "uomId". Then show the "abbreviation" on the cell. */
			arrObjComponentsDef.some(function(item){
					item.uom.some(function(item1){
						if(params.value == item1.uomId){
							uomStr = item1.abbreviation;
							return true;// exit the loop
						}
					});
					if(uomStr != ''){
						return true;// exit the loop
					}
			});
			this.eGui.innerHTML = uomStr;
		}
	};
newUOMCellRenderer.prototype.getGui = function () {
	return this.eGui;
};
/* This gets called on the initial load.
This loops through "objProgram.components". */
function existingUOMCellRenderer() {}
	existingUOMCellRenderer.prototype.init = function (params) {

		this.eGui = document.createElement('span');
		if (params.value !== "" || params.value !== null) {
			let uomStr = '';
			/* Loop through "objProgram.components" and get the "abbreviation"
			for the "uomId". Then show the "abbreviation" on the cell. */
			objProgram.components.some(function(item){
					item.uom.some(function(item1){
						if(params.value == item1.uomId){
							uomStr = item1.abbreviation;
							return true;// exit the loop
						}
					});
					if(uomStr != ''){
						return true;// exit the loop
					}
			});
			this.eGui.innerHTML = uomStr;
		}
	};
existingUOMCellRenderer.prototype.getGui = function () {
	return this.eGui;
};
/* Get a list of UOM's */
function getUOMList(compObj){
	let uomList = [];
	compObj.some(function(item){
		item.uom.some(function(item1){
			uomList.push(item1.uomId);
		});
		if(uomList.length > 0){
			return true;// exit the loop
		}
	});
	return uomList;
}
/* Set the UOM - Set the first one in the list,as the default UOM.
Just a random choice. */
function selectedUomIdx(params,comp){
	let defaultUOM = 1;//default is CS
	let uniqueColumnID = comp.componentId;
	if(params.data['uom_'+uniqueColumnID] == undefined){
		arrObjComponentsDef.some(function(item){
			item.uom.some(function(item1){
					defaultUOM = item1.uomId;
					return true;//exit the loop
			});
		});
		params.data['uom_'+uniqueColumnID] = defaultUOM;
		Rate_GridOptions.api.refreshCells(params);
		/* do not call the "updateuom" function from here.
		let it be called from wherever the "selecteduomidx" function is being called (if needed) .
		This is important to avoid issues, in some cases. */
	}
}
function enableDisableUOMOptions(){
	let applyRateOption = $('select[name=apply_rdoUomActionGrp] option:selected').val();

	if(applyRateOption != 0 && applyRateOption != ''){
		$("#cboUom").prop("disabled", true);
	}
	else{
		$("#cboUom").prop("disabled", false);
	}
}
function filterOnLoad(){
	/* Just check if there are any products added */
	if(objProgram.components[0].prodRate.length){
		$('#chFilterRates').prop('checked', true);
	}
	else{
		if(objProgram.template.bGroupDeal && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
			$('#chFilterGroup').prop('checked', true);
		}
		if(objProgram.bMarketPriceTemplate){
			$('#chFilterMP').prop('checked', true);
		}
	}
	externalFilterChanged();
}

/* Update the rate in the "objProgram" object. "objProgram" is sent to the server for saving.*/
function updateRate(componentID,params){
	let exitLoop = 0;
	let arrItem = [];
	arrItem.push(params.data);
	/* In case the "prodRate" object does not already exist for the product, add the "prodRate" object first. */
	addProdRateObjForNewCompAndItemCombination(arrItem);

	if(params.oldValue != params.newValue){
		objProgram.components.some(function(item){
			/* Find the component passed to this function in "objProgram.components" */
			if(item.prodRate !== undefined && item.componentId == componentID){
				item.prodRate.some(function(item1){
					if(params.data.itemGuid == item1.itemGuid){
						item1.rate = params.newValue;
						exitLoop = 1;
						return true; //exit loop
					}
				});
			}
			if(exitLoop == 1){
				return true;//exit the outer loop as well
			}
		});
	}
}

/* Because this function gets called from different places, the parameters passed in differ, but the objective remains the same -
We need to update the component in "objProgram.components" with the new value. */
function updateUOM(componentID,params,updatedValue){
	let exitLoop = 0;
	let itemID;
	let arrItem = [];

	if(params.data){
		itemID = params.data.itemGuid;
		arrItem.push(params.data);
		addProdRateObjForNewCompAndItemCombination(arrItem);
	}
	else{
		itemID = params;//Here "params" is the "itemGuid"
	}

	if(params.newValue){
		updatedValue = params.newValue;
	}

	/*Currently, when the user tabs off the UOM column, the "OnCellValueChanged" event is fired,which sets the default UOM on the UOM column.
	Note: Here the params.oldValue and params.newValue are the same and so we cannot use the if(params.oldValue != params.newValue) logic. */
	objProgram.components.some(function(item){
		/* Find the component passed to this function in "objProgram.components" */
		if(item.prodRate !== undefined && item.componentId == componentID){
			item.prodRate.some(function(item1){
				if(itemID == item1.itemGuid){
					item.uom.some(function(item2){
						if(item2.uomId == updatedValue){
							item1.uom = item2;
							exitLoop = 1;
							return true; //exit loop
						}
					});
				}
				if(exitLoop == 1){
					return true;//exit the outer loop as well
				}
			});
		}
		if(exitLoop == 1){
			return true;//exit the outermost loop as well
		}
	});
}

/* It gets called to check whether the item is already added to the "prodRate" array.
If not, then this function calls the "addProdRate" function to add that product to the "prodRate" array. */
function addProdRateObjForNewCompAndItemCombination(arrItems){
	let arrayProdList = [];

	/* Loop through the products */
	arrItems.forEach(function(item){

		/* Loop through the components in the program */
		objProgram.components.forEach(function(item1){

			/* If the "prodRate" exists, i.e. rate has already been added for at least
			one product for this component. */
			if(item1.prodRate){
				let prodRatesGUID = [];

				/* Get a list of products for this component, which already have a rate. */
				item1.prodRate.forEach(function(item2){
					prodRatesGUID.push(item2.itemGuid);
				})

				/* If the product does not not already have a rate for this component. */
				if($.inArray(item.itemGuid, prodRatesGUID) == -1){
					if($.inArray(item.itemGuid, arrayProdList) == -1){
						/* Create an array of products from the products passed to this function, for which rates does not
						already exist for any component which exist in the program. */
						arrayProdList.push(item.itemGuid);
					}
				}
			}
			/* If rate does not exist for any product for this component. */
			else{
				if($.inArray(item.itemGuid, arrayProdList) == -1){
					/* "arrayProdList" will store list of products for which rate does not exist for any
					component added to the progran (including the action of clicking "add component") */
					arrayProdList.push(item.itemGuid);
				}
			}
		});

	});

	/* Loop through the selected records and call the "addProdRate" function
	for the products in the "arrayProdList" array. */
	arrItems.forEach(function(item){
		if($.inArray(item.itemGuid, arrayProdList) != -1){
			addProdRate(item);
		}
	});
}

function downloadRates(){
	let s = '';
	let cr  = '|||';
	let pattern = /,/g;
	let prodRateList;

	/* Build the string */
	s = 'Item,Description,Rate,UOM,Price' + ',';

	objProgram.arrPrdAttr.forEach(function(item){
		s = s + item.groupLevelDesc.toString().replace(pattern," ") + ',';
	});

	if(objProgram.template.bGroupDeal == true && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
		s = s + 'Key' + cr;
	}
	else{
		s = s + 'Key' + cr; //s = s + cr;
	}

    Rate_GridOptions.api.forEachNodeAfterFilter(function(node, index){
		s = s + '="' + node.data.baItemDisplay + '"' + ',';

		let sDesc = node.data.Description.toString().replace(pattern,"");
		s = s + sDesc + ',';

		let nRateColumn = "rate_" + arrObjSelectedComponent.componentId;
		let nRate = node.data[nRateColumn];

		if(isNaN(nRate)){
			nRate = 0;
		}

		s = s + nRate + ',';

		let nUOMColumn = "uom_" + arrObjSelectedComponent.componentId;
		let nUOM = node.data[nUOMColumn];

		if(isNaN(nUOM)){
			sUOM = '';
		}
		else{
			/* Get the abbreviation for the UOM */
			arrObjComponentsDef.some(function(item){
					item.uom.some(function(item1){
						if(nUOM == item1.uomId){
							sUOM = item1.abbreviation;
							return true;// exit the loop
						}
					});
					if(sUOM != ''){
						return true;// exit the loop
					}
			});
		}

		s = s + sUOM + ',';

		s = s + node.data.marketPrice + ',';

		objProgram.arrPrdAttr.forEach(function(item){
			s = s + node.data[item.productGroupAttributeNameField].toString().replace(pattern," ") + ',';
		});

		s = s + node.data.itemGuid + cr;
    });

	prodRateList = s;

	let sFilename = "Prod_Rates_" + objProgram.number + "_" + arrObjSelectedComponent.name +".csv";

	// Remove chars not allowed in Windows filename \ / : * ? " < > |
	sFilename = sFilename.replace(/[~\\\/:\*\?"<>\|]/g, "");

	// Trim leading and trailing whitespace.
	sFilename = sFilename.trim();

	document.frmProdRate.fileName.value = sFilename;
	document.frmProdRate.prodRateList.value = prodRateList;
	document.frmProdRate.submit();
}
var uploadfileWindow;
function uploadCSV(){
	uploadfileWindow = NewWindow("uploadfile.cfm", "upload","600","300","yes","yes");
}
function processFileData(arrInput){

	/* If we just use "show_loader("PLEASE WAIT...");" at the top of this function, the show_loader code will not work, as expected.
	To see show_loader before heavy duty javasscript code like this function, we need to use "loadChain". This will make sure
	step 1 is called first and then step 2 and so on. Using loadChain, show_loader actually works.*/
		var loadChain = new LoadChain();

		/* STEP 1 */
		loadChain.push(function() { show_loader("PLEASE WAIT..."); });

        /* STEP 2. Deleted - it created SCRIPT18 error in IE, spinner would not stop */

		/* STEP 3. Note - This step actually should be a function by itself, but "loadChain" required that the code be put here directly and
		not call any function, which had below code.
		*/
		loadChain.push(function() {
			let arrayOfarrInput = [];
			let arrayOfarrFinal = [];
			let arrColumnHeaders = [];
			let uniqueColumnID;
			let arrItem = [];
			let item_Guid;
			let UOMAbbreviation;
			let objArrayItem;
			let ObjArrayItemList = [];
			let guidIndex = 0;

			/* Loop through the data aray and create an array for every element of the array. This is important so that
			we can loop through the data easily.
			*/
			arrInput.forEach(function(item){
				arrayOfarrInput.push(item.split(","));
			});

			/* The first element of the "arrayOfarrInput" array, contains the column headers. */
			arrColumnHeaders = arrayOfarrInput[0];
			guidIndex = arrColumnHeaders.indexOf("Key");
			/* Get a list of GUID's, which the user is trying to upload. */
			arrayOfarrInput.forEach(function(data,index){
				/* Skip the first element, as it contains the header. */
				if(index > 0 && data[2] != 0){
					objArrayItem = new Object();
					/* Data from the last column in the CSV file. It is the "key" column and has the GUID.
					The replace function removes the new line character from the GUID column. It has the new line
					character, as it is the last column on the file. */
					objArrayItem.itemGuid = data[guidIndex].replace(/[\n\r]/g, '');
					arrItem.push(objArrayItem);
					/* This array (arrayOfarrFinal) will only have those entries, which have a rate. We do not want to
					loop through all the rows of the file. */
					arrayOfarrFinal.push(data);
				}
			});

			/* arrItem only has the "itemGuid" property, but the "addProdRateObjForNewCompAndItemCombination" function
			(actually the "addProdRate" function, which is called by "addProdRateObjForNewCompAndItemCombination") needs
			all the item attributes and so we loop through the grid and get those pproperties. */
			arrItem.forEach(function(item){
				Rate_GridOptions.api.forEachNode(function(node){
					if(node.data.itemGuid == item.itemGuid){
						ObjArrayItemList.push(node.data);
					}
				})
			})

			/* In case the "prodRate" object does not already exist for any product, add the "prodRate" object first. */
			addProdRateObjForNewCompAndItemCombination(ObjArrayItemList);

			arrayOfarrFinal.some(function(data,index){
				/* Data from the last column in the CSV file. It is the "key" column and has the GUID.
				The replace function removes the new line character from the GUID column. It has the new line
				character, as it is the last column on the file. */
				item_Guid = data[guidIndex].replace(/[\n\r]/g, '');

				objProgram.components.some(function(item){
					item.prodRate.some(function(item1){

						if(item_Guid == item1.itemGuid){
							/* We are using "arrObjSelectedComponent", because the upload is for the selected component on the dropdown. */
							if(item.type == arrObjSelectedComponent.type){
								if(item.componentId == arrObjSelectedComponent.componentId){

									let rowNode = Rate_GridOptions.api.getRowNode(item1["itemGuid"]);

									let objInvalidItemsList = new Object();

									if(rowNode != undefined){
										item1["rate"] = numberFormat(parseFloat(data[2]),fmt_4_decimal_places);

										UOMAbbreviation = data[3];
										/* Get the UOM object based on UOM description */
										arrObjComponentsDef.some(function(itemComp){
											item.uom.some(function(itemUOM){
												if(UOMAbbreviation == itemUOM.abbreviation || UOMAbbreviation == itemUOM.description){
													item1["uom"] = itemUOM;
													return true;// exit the loop
												}
											});
										});

										uniqueColumnID = arrObjSelectedComponent.componentId;
										rowNode.data['rate_'+uniqueColumnID] = item1["rate"];
										rowNode.data['uom_'+uniqueColumnID] = item1["uom"].uomId;

										/* Call this function manually. If we would have used "setRowData", instead of "rowNode.data", then the ",onCellValueChanged"
										function would be automatically called and below function does not need to be called manually. We canot use "setRowData",
										as it is very slow, when we are dealing with a lot of records. */
										setDiscountValue(rowNode.data,'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);

										Rate_GridOptions.api.refreshCells();
									}
								}
							}
							/* exit the inner loop (item.prodrate). */
							return true;
						}
					});
				});
			});
				hide_loader();
		});  // Load chain (STEP 3 ends)

			/* STEP 4 - Close the popup page woich uploads the file. If we do this as a first step, then
			the file data does not get processed (the main lofic of this function), i.e. STEP 3 */
			loadChain.push(function() { uploadfileWindow.close(); });

			/* STEP 5 - 	Rerun Filter to show records with "Rates". If the user added products which did not have a rate earlier, then we can
			view those records as well. */
			loadChain.push(function() { filterOnLoad()});

		/* THis step starts the sequence of steps from STEP 1. */
		loadChain.start();
}
</script>

<form name="frmProdRate" id="frmProdRate" method="post" action="/flex/csv_Report.cfm">
	<input type="hidden" name="fileName" />
	<input type="hidden" name="prodRateList" />
</form>
