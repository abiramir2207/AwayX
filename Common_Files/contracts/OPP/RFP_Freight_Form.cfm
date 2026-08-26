<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/RFP_Freight_Form.cfm
   Author: Mark Saunderss
   Date: 11/2020
 
   Usage: Custom RFP Freight
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <style>
        body {
            overflow: hidden;
        }
    </style>
<cfscript>
        verb                    = "CREATE";                // <!--- could be CREATE, EDIT, or VIEW --->
        request.noty_version    = "3";
        jQuery.version          = "1.12.4";
        jQueryUI.widgets        = "tooltip,datepicker";
        jQueryUI.widgets        = "all";
        jQueryUI.version        = "1.11";
        request.ag_grid_theme   = "ba-ag-theme-balham";
        request.ag_grid_version = "24";//24 has save Filter
        request.ag_expand_header_bars = false;
    </cfscript>

    <cf_include files="/common_files/noty.cfm">
        
    <cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/common_Files/ag-Grid.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css",
                                       "/script/javascript/jQueryUI_1_11/datepicker.js",
                                       "/script/javascript/jQueryUI_1_11/jquery-ui.css",
                                       "/script/javascript/chosen/chosen.jquery.min.js", 
                                       "/styles/chosen/chosen.css"
                                    ] )#>
<style>
	.twoDecimalPlaces{
        text-align: right;
    }
    .twoDecimalPlacesPerc{
        text-align: right;
    }

    .ag-theme-balham {
			font-size: 11px;
	}
	.ag-header {
		font-size: 11px !important;
		text-align: center;
	}
	.ag-theme-balham .multiline .ag-header-cell-label .ag-header-cell-text {
            text-overflow: clip;
            overflow: visible;
            white-space: normal;
            height: auto;
    }
    .ag-theme-balham input[type=checkbox] {
        position: relative;
        top: 2px;
    }
    .centered {
        text-align: center;
    }
    button {
        cursor: pointer;
    }
</style>
<cfparam name="url.cid"	default="0">
<cfparam name="url.x"	default="0">
<cf_cryp type="de" string="#trim(url.cid)#" key="#request.key#">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 <cfscript>
 		variables.ContractMainID = cryp.value;
 		oRFP		= CreateObject("component", "mvc.Models.Program.RfpManager");
 		isMatrix = 0;
 		isFobDel = url.x;
 		if(isFobDel){
 			sEditable = oRFP.getEditFOB_DEL(variables.ContractMainID);	
 		}
 		else{
 			sEditable = oRFP.getEditFreight(variables.ContractMainID);
 		}
 		//sEditable = false;
        Contract_Main_ID         = variables.ContractMainID;
        CSL_Contract_Main_ID     = variables.ContractMainID;
        CSL_CallingPageCode      = "gi"     ;
        form.contract_main_id    = variables.ContractMainID;
        //request.already_had_components = qComponents.recordCount gt 0;
</cfscript>

<cfif isFobDel EQ 0 AND sEditable>
	<cfquery name="SetRFPFreight" datasource="#application.datasource#">
			EXEC Populate_Program_Fixed_Freight_Rates_RFP '#variables.ContractMainID#'
	</cfquery>
</cfif>

<cfquery name="GetRFPFreight" datasource="#application.datasource#">
	SELECT  PFFR.program_fixed_freight_id, 
			PFFR.product_id, 
			PFFR.customer_id, 
			PFFR.program_id, 
			PFFR.component_name_id, 
			PFFR.delivered_price, 
			PFFR.freight_rate, 
			PFFR.fob_price, 
			PFFR.freight_uom, 
			PFFR.deleted, 
			PFFR.paid_to, 
			PFFR.program_fixed_component_id,
			PFFR.input_adjustment_amount, 
			PFFR.obf_rate, 
			PFFR.default_obf_rate,
			PFFR.OverRide_obf_rate, 
			PFFR.freight_upcharge_amount, 
			PFFR.default_freight_upcharge_amount,
			PFFR.OverRide_freight_upcharge_amount, 
			PFFR.warehouse_master_id, 
			PFFR.default_warehouse_master_id,
			PFFR.OverRide_warehouse_master_id, 
			PFFR.item_bracket_id, 
			PFFR.default_item_bracket_id,
			PFFR.OverRide_item_bracket_id, 
			PFFR.is_delivered, 
			PFFR.fixed_component_type, 
			PFFR.final_price, 
			PFFR.tbd_product_id,
			I.Item,
			I.Description,
			C.Name,
			C.Ship_To,
			WM.Warehouse_Name,
			WM.Warehouse_Code,
			'(' + Cast(WM.Warehouse_Code as varchar(25)) + ') ' + WM.Warehouse_Name as facility_desc,
			interfaced,
			freight_rate_per_volume,
			ISNULL(ISNULL(nullif(cast(CP.case_cube as decimal(14,2)),0.0),i.Case_Count),0) as case_cube,
			freight_upcharge_percent,
			total_freight_cs,
			CD.Program_Weight as weight
	FROM Program_Fixed_Freight_Rates PFFR
	INNER JOIN BSA_Foodservice_Customers C ON
		C.BSA_Foodservice_Customers_ID = PFFR.Customer_Id
	INNER JOIN Contract_Distributors CD ON
		CD.BSA_Foodservice_Customers_ID =  PFFR.Customer_Id AND
		CD.Contract_Main_ID = PFFR.Program_Id AND
		CD.Deleted = 0
	INNER JOIN BSA_Foodservice_Items_Master I ON
		I.BSA_Foodservice_Items_Master_ID = PFFR.Product_Id
	INNER JOIN Contract_Products CP ON
		CP.Contract_Products_Id = PFFR.Contract_Products_Id
	INNER JOIN Warehouse_Master WM ON
		WM.Warehouse_Master_ID = PFFR.Warehouse_Master_Id
	WHERE 	Program_Id =  '#variables.ContractMainID#'
	AND 	PFFR.Deleted = 0
	Order by C.Name, I.Item
</cfquery>

 <cfscript>
 		oRFP		= CreateObject("component", "mvc.Models.Program.RfpManager");
        q = GetRFPFreight;
        qGetFacilities	= oRFP.getFacilities(variables.ContractMainID);
        //writedump(q);
</cfscript>
<cfquery name="SetMatrix" dbtype = "query">
		Select 1 from q where fixed_component_type IN (8,9)
</cfquery>
<cfif setMatrix.recordcount GT 0> <cfset isMatrix = 1></cfif>

<cfif isFobDel EQ 1>
 <!--- program header --->
        <cfset request.style = "2020">  
        <cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">
</cfif>
<h5 class="sectionHeader"></h5>
<div class="sectionContents">
	<cfif isFobDel EQ 0 && sEditable>
		<button id="rfpFreightResetButton" type="button" class="button ml-4 review" onclick="resetFreightOverRide();return false;">Reset Overide Values</button>
	</cfif>
<!--- 	<cfif request.accessstructure.BLACKSMITH_USER EQ 1 && isFobDel EQ 0> --->
		<button id="rfpFreightResetButton" type="button" class="button ml-4 review" onclick="onBtHide();return false;">Show/Hide Extra Columns</button>
   <!---  </cfif> --->
    <p style="float:right;color:#393939;font-size:11px;margin-right:20px;background-color:#defade;padding:5px 10px;"> * = user edited record </p>
</div>
<div id="Freight_Grid" style="width: 90%; height:83vh;" class="ag-theme-balham ml-2 mt-2 mb-2"></div>
<cfoutput><button type="button" class="button rfp_save review">Save</button></cfoutput>
<button onclick="onBtExportFreight()" style="margin-left:20px; cursor:pointer" type="button" class="button">Export to Excel</button>
	
<SCRIPT><cfset i = 1>
	var facilityMapping = {
		<cfoutput query="qGetFacilities">
	    		#qGetFacilities.Facility_Id#:'#qGetFacilities.facility_desc#'<cfif i Neq qGetFacilities.recordcount>,</cfif>
	    		<cfset i = i + 1>
	    </cfoutput>
	};
	const MASS_APPLY = true;
	var rowData_RFP_Freight = <cfoutput>#application.util.query.toAgGridJSON(q, 'program_fixed_freight_id, product_id, customer_id, program_id, component_name_id, delivered_price, freight_rate, fob_price, freight_uom, deleted, paid_to, program_fixed_component_id, input_adjustment_amount, obf_rate, default_obf_rate, override_obf_rate, freight_upcharge_amount, default_freight_upcharge_amount, override_freight_upcharge_amount, warehouse_master_id, default_warehouse_master_id, override_warehouse_master_id, item_bracket_id, default_item_bracket_id, override_item_bracket_id, is_delivered, fixed_component_type, final_price, tbd_product_id, item, description, name, ship_to, warehouse_name, warehouse_code,facility_desc,interfaced,freight_rate_per_volume,case_cube,freight_upcharge_percent,total_freight_cs,weight')#</cfoutput>;
	// RFP Distributor test data
	var columnDefs_RFP_Freight = [
		{headerName: "",  width:35
				<cfif sEditable EQ 1>	,checkboxSelection: true,
									headerCheckboxSelection: true,
									headerCheckboxSelectionFilteredOnly: true
				</cfif>},
		{headerName: "Distributor ID", field: "ship_to",  width:100, headerClass: 'multiline',filter: 'agTextColumnFilter', cellClass: 'textFormat'},
	    {headerName: "Distributor Name", field: "name",  width:250, headerClass: 'multiline',filter: 'agTextColumnFilter'},
	    <cfif isFobDel eq 0>
	   	 {headerName: "Weight", field: "weight",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlaces','textRight','debug'], type: 'numericColumn', valueFormatter: percentFormatter ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter', hide:false},
	    </cfif>
	    {headerName: "Item", field: "item",  width:100,filter: 'agTextColumnFilter', cellClass: 'textFormat'},
	    {headerName: "Item Description", field: "description",  width:250, headerClass: 'multiline', autoHeight: true,filter: 'agTextColumnFilter'},

	    <cfif isFobDel eq 0>
	    	{headerName: "Facility", field: "warehouse_master_id",  width:250 // TODO : PROFILE SETTINGS	, filter: 'agTextColumnFilter'
                    // ngt
                    ,cellClass: function(params) {  let css = [];
                                                    <cfif sEditable> css.push ( "editable" ); </cfif>
                                                    if (params.data.override_warehouse_master_id) {
                                                        css.push( "user_edited" );
                                                    }
                                                    return css; 
                                                }
                     ,refData: facilityMapping
					<cfif sEditable><cfset i = 1>   // TODO : PROFILE SETTINGS
			    			,editable: true,
						 	cellEditor : 'agRichSelectCellEditor',
							cellEditorParams : {
							    values:[
							    <cfoutput query="qGetFacilities">
							    		'#qGetFacilities.Facility_Id#'<cfif i Neq qGetFacilities.recordcount>,</cfif>
							    		<cfset i = i + 1>
							    </cfoutput>]
							}
							,headerComponentParams: {
							template: customize_column_header(''
							,'<div class="mass_apply"><select class="mass mass_apply" id="warehouse_master_id" placeholder="Select a Means Code to Mass Apply">'
										+'<option selected disabled value="">select</option>'
										<cfoutput query="qGetFacilities">
											+'<option value="#qGetFacilities.Facility_Id#">#qGetFacilities.facility_desc#</option>'
									    </cfoutput>
										+'</select>'
								+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="warehouse_master_id" title="Click to apply to selected rows"></i></span>'
								+ '</div>'
							,MASS_APPLY) 
						}
					</cfif>
		},
	    {headerName: "Means Code", field: "item_bracket_id",  width:100, headerClass: 'multiline',	//filter: 'agTextColumnFilter',
	    	valueFormatter: function (params) {
						    	let s = '';
					            switch(params.value) {
									  case 1:s = 'TL'; break;
									  case 2:s = 'LTL';break;
									  //case 3:s = 'Custom Items - Make & Ship';break;
                                }
								return s;
						},
				<cfif sEditable>
		    			editable:function(params) {
					            return params.node.data.edit_stock_bracket != 0;   //params.node.data.isTBD === 1;
					        },
					 	cellEditor : 'agRichSelectCellEditor',
						cellEditorParams : {
						    values: [1,2],
						    formatValue: function(value) {
						    	var s = '';
					            switch(value) {
									  case 1:s = 'TL';break;
									  case 2:s = 'LTL';break;
									  //case 3:s = 'Custom Items - Make & Ship';break;
								}
								return s;
					          },
						}
                       ,cellClass: function(params) {   let css = [ "editable" ]; 
                                                        if (params.data.override_item_bracket_id) {
                                                            css.push( "user_edited" );
                                                        }
                                                        return css; 
                                                    }
					   ,headerComponentParams: {
							template: customize_column_header(''
							,'<div class="mass_apply"><select class="mass mass_apply" id="item_bracket_id" placeholder="Select a Means Code to Mass Apply">'
										+'<option selected disabled value="">select</option>'
										+'<option value="1">TL</option>'
										+'<option value="2">LTL</option>'
										+'</select>'
								+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="item_bracket_id" title="Click to apply to selected rows"></i></span>'
								+ '</div>'
							,MASS_APPLY) 
						}
				<cfelse>
						editable: false
				</cfif>

		},
		</cfif>
		<cfif isMatrix eq 1 AND isFobDel eq 0>
		    {headerName: "FOB Price", field: "fob_price",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline', filter: 'agNumberColumnFilter'},
            {headerName: "OBF", field: "obf_rate",  width:75, filter: 'agNumberColumnFilter'
            ,cellClass: function(params) {  let css = [ "twoDecimalPlacesDollar", "textRight" ]; 
                                            <cfif sEditable> css.push ( "editable" ); </cfif>
                                            if (params.data.override_obf_rate) {
                                                css.push( "user_edited" );
                                            }
                                            return css; 
                                        }

            ,type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline', filter: 'agNumberColumnFilter'
						<cfif sEditable>   // TODO : PROFILE SETTINGS
				    			,editable: true
				    	</cfif>},
            {headerName: "Freight Upcharge", field: "freight_upcharge_amount",  width:75, filter: 'agNumberColumnFilter'
            ,cellClass: function(params) {  let css = [ "twoDecimalPlacesDollar", "textRight" ]; 
                                            <cfif sEditable> css.push ( "editable" ); </cfif>
                                            if (params.data.override_freight_upcharge_amount) {
                                                css.push( "user_edited" );
                                            }
                                            return css; 
                                        }
            ,type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline', filter: 'agNumberColumnFilter'
						<cfif sEditable>   // TODO : PROFILE SETTINGS
				    			,editable: true
				    	</cfif>},
		    {headerName: "Input Field", field: "input_adjustment_amount",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable']<cfelse>]</cfif>, type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline', filter: 'agNumberColumnFilter'
						<cfif sEditable>   // TODO : PROFILE SETTINGS
				    			,editable: true
				    	</cfif>
			},
			{headerName: "Total Freight", field: "total_freight_cs",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter'},
		    {headerName: "Delivered Price", field: "delivered_price",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter'},

		    {headerName: "Freight Rate Per Volume", field: "freight_rate_per_volume",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlaces','textRight','debug'], type: 'numericColumn', valueFormatter: numberFormatter ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter', hide:false},
		    {headerName: "Case Cube", field: "case_cube",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlaces','textRight','debug'], type: 'numericColumn', valueFormatter: numberFormatter ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter', hide:false},
		    {headerName: "Freight Upcharge %", field: "freight_upcharge_percent",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlaces','textRight','debug'], type: 'numericColumn', valueFormatter: percentFormatter ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter', hide:false},
		<cfelseif isFobDel eq 1>
			{headerName: "FOB / Delivered", field: "is_delivered",  width:100, headerClass: 'multiline',	//filter: 'agTextColumnFilter',
		    	valueFormatter: function (params) {
							    	var s = '';
						            switch(params.value) {
										  case 1:s = 'Delivered'; break;
										  case 0:s = 'FOB';break;
										  //case 3:s = 'Custom Items - Make & Ship';break;
									}
									return s;
							},
					<cfif sEditable AND isFobDel EQ 1>
			    			editable: true,
			    			cellClass: ['editable'],
						 	cellEditor : 'agRichSelectCellEditor'
							,cellEditorParams : {
							    values: [0,1],
							    formatValue: function(value) {
							    	var s = '';
						            switch(value) {
										  case 1:s = 'Delivered';break;
										  case 0:s = 'FOB';break;
										  //case 3:s = 'Custom Items - Make & Ship';break;
									}
									return s;
						          }
							}
						   ,headerComponentParams: {
								template: customize_column_header(''
								,'<div class="mass_apply"><select class="mass mass_apply" id="is_delivered" placeholder="Select FOB/Del. to Mass Apply">'
											+'<option selected disabled value="">select</option>'
											+'<option value="1">Delivered</option>'
											+'<option value="0">FOB</option>'
											+'</select>'
									+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="is_delivered" title="Click to apply to selected rows"></i></span>'
									+ '</div>'
								,MASS_APPLY) 
							}
					<cfelse>
							editable: false
					</cfif>

			},
			{headerName: "FOB Price", field: "fob_price",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline', filter: 'agNumberColumnFilter'},
			{headerName: "Delivered Price", field: "delivered_price",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter'},
			{headerName: "Final Price", field: "final_price",  width:75, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter'}
	    </cfif>
	];

	function set_mass_apply() {

		$("#item_bracket_id").click(function(e){
			e.stopPropagation();	// stop the sort etc
		});

		$("#warehouse_master_id").click(function(e){
			e.stopPropagation();	// stop the sort etc
		});

		$("div.mass_apply").click(function(e){
			e.stopPropagation();	// stop the sort etc
		});

		<!--- ~~~~~~~~ mass apply logic ~~~~~~~~ --->
		$("i.mass_apply").click(function(e){
			mass_apply_event(e);
			e.stopPropagation();
		});
		//getFreightData();
	}
	
	function mass_apply_event(e) {
		var field = e.srcElement.attributes.name.nodeValue;
		var data = $("#" + field).val();
		var arrData = [];
		if(data == ''){
			return;
		}
			<!---  apply to filtered (visible) rows only  --->
			var count = Freight_GridOptions.api.getSelectedRows().length;
			var i = 1;
			Freight_GridOptions.api.forEachNode(function(rowNode, index) {
				<!--- ~~ apply to selected rows only ~~~ --->
				if(rowNode.selected) {
					if( rowNode.data[field] != $("#" + field).val() ){ //only update fields with different value
						rowNode.data[field] = $("#" + field).val();
						arrData.push(rowNode.data);
					}
					rowNode.selected = false;
					i++;
				}	
			});
			if(arrData.length){
				saveMassApply(JSON.stringify(arrData), field);
			}	
		//getFreightData(); //reload since we need to recalc
	}

	function onBtHide() {
		var a = columnDefs_RFP_Freight;
		columnDefs_RFP_Freight = [];
		Freight_GridOptions.api.setColumnDefs([]);
		a.forEach(function (colDef) {
	    if(colDef.field === 'freight_rate_per_volume' || colDef.field === 'case_cube' || colDef.field === 'freight_upcharge_percent' || colDef.field === 'weight') {
	      	colDef.hide = !colDef.hide ;
	    }
	   columnDefs_RFP_Freight = a;
	  });
	  Freight_GridOptions.api.setColumnDefs(columnDefs_RFP_Freight);
	  Freight_GridOptions.api.doLayout();
	  Freight_GridOptions.api.sizeColumnsToFit();
	  set_mass_apply();
	}
	var Freight_GridOptions = {};
	
	function Build_RFPFreightGrid() {
	    // Init RFP Freight grid
	    Freight_GridOptions = {
	        columnDefs: columnDefs_RFP_Freight
	        ,rowData: rowData_RFP_Freight
	        ,rowModel: 'serverSide'  // TODO change to serverSide
	        ,immutableData: true
	       	// ,serverSideStoreType: 'full'
	        ,cacheBlockSize: 2000
	        ,headerHeight: 50
	        ,floatingFilter: true
	        ,rowHeight: 30
	        ,singleClickEdit: true
	        ,stopEditingWhenGridLosesFocus: true
	        ,rowSelection: 'multiple'
	         ,defaultColDef: {
			        sortable: true,
                    filter: true,
                    resizable: true,
                    autoHeight: true
              }
              ,sideBar: {
				    toolPanels: [{
				        id: 'columns',
				        labelDefault: 'Columns',
				        labelKey: 'columns',
				        iconKey: 'columns',
				        toolPanel: 'agColumnsToolPanel',
				        toolPanelParams: {
				            suppressRowGroups: true,
				            suppressValues: true,
				        }
				    }],
				    defaultToolPanel: 'columns',
				    hiddenByDefault: true,
				}
			// ,domLayout: "autoHeight"
			,multiSortKey: 'ctrl'
	        ,onGridReady: function (p) {
		        this.api.sizeColumnsToFit();
		        set_mass_apply();
		        var defaultSortModel = [
			      { colId: 'ship_to', sort: 'asc', sortIndex: 0 },
			      { colId: 'item', sort: 'asc', sortIndex: 1 },
			    ];
			    //  THIS NEEDS VERSION 24 -> WE NEED CSS UPDATED FOR V24
			    p.columnApi.applyColumnState({ state: defaultSortModel });
	        }
	        ,onRowSelected: function(event) {
	        	if(event.node.selected == false){
	        		//log.debug(event.data);
	        		//deleteCustomer(event.data);
	        	}
		    }
		    ,onColumnResized: autosizeHeaders
		    ,getRowNodeId: function(data) {
			    return data.program_fixed_freight_id;
			}
		    <cfif sEditable EQ 1 >
		    //,onCellEditingStarted : function(event) {	console.log(event);	}
		    ,onCellEditingStopped : function(event) {
		    	var turnEditOff = 0;
		        if(event.oldValue != event.newValue){
		        	turnEditOff = 1;
		        }
		         if(event.oldValue !== event.newValue && event.colDef.field == 'is_delivered'){ /* Different compare != vs. !== for the drop down in is_delivered.  Fails without this*/
		        	turnEditOff = 1;
		        }
		        if(turnEditOff ==1 ){
					Freight_GridOptions.api.stopEditing();	
		        }

		    }  ///  WE STOP EDIT because a change to OBF rate changes the Freight_Upcharge which is the next cell.  We need to recalc that BEFORE User edits the data.
		    ,onCellValueChanged: function(event) {
		    	//console.log(event);
		    	//Freight_GridOptions.api.stopEditing({cancel: false});
		    	var turnEditOn = 0;
		        if(event.oldValue != event.newValue){
		        	saveData(JSON.stringify(event.data), event.colDef.field) /* recalcAll == 0  so revision/override data is not lost  ---  I THINK WE NEED TO LET MANUAL UPDATES RECALC!!*/
		        	turnEditOn = 1;
		        }
		         if(event.oldValue !== event.newValue && event.colDef.field == 'is_delivered'){ /* Different compare != vs. !== for the drop down in is_delivered.  Fails without this*/
		        	saveData(JSON.stringify(event.data), event.colDef.field)
		        	turnEditOn = 1;
		        }
		        if(turnEditOn ==1 ){
		        	var hasFocus = Freight_GridOptions.api.getFocusedCell();
					Freight_GridOptions.api.startEditingCell({
						rowIndex: hasFocus.rowIndex,
						colKey: hasFocus.column.colId
					});	
		        }
		    }
		    </cfif>
		     ,excelStyles: [
		        {
		            id: 'textFormat',
            		dataType: 'string'
		        }
		     	,{
	            id: 'twoDecimalPlacesDollar',
		            numberFormat: {
		                format: '$#,##0.00'
			            }
		        }
	         	,{
	            id: 'twoDecimalPlacesPerc',
		            numberFormat: {
		                format: '#.00%'
			            }
		        }
		        ,{
	            id: 'intPerc',
		            numberFormat: {
		                format: '#,##0'
			            }
		        }
		        ,{
	            id: 'twoDecimalPlaces',
		            numberFormat: {
		                format: '#,##0.00'
			            }
		        }
		        ,{
	            id: 'noDecimalPlaces',
		            numberFormat: {
		                format: '#,##0'
			            }
		        }
	            ,{
		            alignment: {
		            	 horizontal: 'Right'
		            	}
	        	}
	        ]
	    };
	    ag_grid_default(Freight_GridOptions);		// set up default features
	    init_ag_grid( Freight_GridOptions, "#Freight_Grid", false );   // setup as client side TODO change to server-side
	}


	var currrentEditNode = {};
	function saveData(data, field){ // Save a single rows
        <cfif sEditable EQ 0> return; </cfif>


        var stData = JSON.parse(data);
        var isBlended = 0;
        //console.log();
        currrentEditNode = Freight_GridOptions.api.getRowNode(stData.program_fixed_freight_id);
        if(stData.fixed_component_type == 8){
			isBlended = 1;
		}
        //log.debug(JSON.parse(data));''
        saveFilterModel();
        $.ajax({
                        async: true
                        ,data: { 	contractId: <cfoutput>'#variables.ContractMainID#'</cfoutput>,
                                    stData: data,
                                    field: field,
                                    method: 'savePFFR'
                                }
                        ,type: "post"
                        ,url: "/mvc/Models/Program/RfpManager.cfc"
            }).then( (data) => {
					var aData = JSON.parse(data);
					var nodes = [];
                    if(	field !== 'is_delivered' && isBlended == 1){	//ONLY Blended needs full refresh
                          var itemsToUpdate = [];
                          var data = {};
						  Freight_GridOptions.api.forEachNodeAfterFilterAndSort(function (rowNode, index) {
						  	for (var i = 0; i < aData.length; i++) {
							  if (rowNode.data.program_fixed_freight_id === aData[i].program_fixed_freight_id){	
							  	rowNode.setData(aData[i]);
							  	data = rowNode.data;
							  	nodes.push(rowNode);
							  	break;
							  }
							}
						  });
						  //var res = Freight_GridOptions.api.applyTransaction({ update: itemsToUpdate });
						  Freight_GridOptions.api.refreshCells({ rowNodes: nodes });
                    }
                    else{
                        var rowData = aData[0];
                        var rNode = Freight_GridOptions.api.getRowNode(rowData.program_fixed_freight_id);
                        rNode.setData(rowData);
                        nodes = [rNode]; // params needs an array
                        Freight_GridOptions.api.refreshCells({ rowNodes: nodes });
                        // reset "editing" now that data is updated
        				var hasFocus = Freight_GridOptions.api.getFocusedCell();
						Freight_GridOptions.api.startEditingCell({
							rowIndex: hasFocus.rowIndex,
							colKey: hasFocus.column.colId
						});
                    }
                    restoreFilterModel();
	        }).fail(data => {
				// $("div.loader").hide();
				alert('An error occurred.  ' + JSON.stringify(data));
			});
	}

	function saveMassApply(data, field){ // Save a single rows
        <cfif sEditable EQ 0> return; </cfif>
        show_loader('Saving Mass Apply Freight Data...');
        //log.debug(JSON.parse(data));
        $.ajax({
                        async: true
                        ,data: { 	contractId: <cfoutput>'#variables.ContractMainID#'</cfoutput>,
                                    aData: data,
                                    field: field,
                                    method: 'massApplyFreight'
                                }
                        ,type: "post"
                        ,url: "/mvc/Models/Program/RfpManager.cfc"
            }).then( (data) => {
						var aData = JSON.parse(data);
                        // rowData_RFP_Freight = aData;
                        // Freight_GridOptions.api.setRowData(rowData_RFP_Freight);
                        // Freight_GridOptions.api.doLayout();

                        var itemsToUpdate = [];
                         var data = {};
						 var nodes = [];
						  Freight_GridOptions.api.forEachNodeAfterFilterAndSort(function (rowNode, index) {
						  	for (var i = 0; i < aData.length; i++) {
							  if (rowNode.data.program_fixed_freight_id === aData[i].program_fixed_freight_id){	
							  	rowNode.setData(aData[i]);
							  	data = rowNode.data;
							  	nodes.push(rowNode);
							  	break;
							  }
							}
						  });
						  Freight_GridOptions.api.redrawRows({ rowNodes: nodes });

                        $("div.loader").hide();
                    }).fail(data => {
						// $("div.loader").hide();
						alert('An error occurred.  ' + JSON.stringify(data));
						$("div.loader").hide();
					});
	}

	function getFreightData(){
		//alert(data);
		//return false;
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	contractId: <cfoutput>'#variables.ContractMainID#'</cfoutput>,
									method: "getFreightData" }
						//,dataType: "json"
						,success: function (data) {
							rowData_RFP_Freight = data;
							Freight_GridOptions.api.setRowData(rowData_RFP_Freight);
							Freight_GridOptions.api.setHeaderHeight(50);
                          	Freight_GridOptions.api.doLayout();
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}
	
	function resetFreightOverRide(){
		//alert(data);
		//return false;
		var s = '';
		var comma = '';
		Freight_GridOptions.api.forEachNodeAfterFilter(function(rowNode, index) {
				<!--- ~~ apply to selected rows only ~~~ --->
				if(rowNode.selected) {
					s = s + comma + rowNode.data.program_fixed_freight_id;
					comma = ',';
					//rowNode.selected = false;
				}
			});

		if(s.length){
			resetFreightData(s);
		}
	}

	function resetFreightData(data){ // Save a single rows
        <cfif sEditable EQ 0> return; </cfif>
        $.ajax({
                        async: true
                        ,data: { 	contractId: <cfoutput>'#variables.ContractMainID#'</cfoutput>,
                                    stData: data,
                                    method: 'resetFreightData'
                                }
                        //,dataType: "json"
                        ,success: function (data) {
	                        var aData = JSON.parse(data);
		                     var itemsToUpdate = [];
	                         var data = {};
							 var nodes = [];
							  Freight_GridOptions.api.forEachNodeAfterFilterAndSort(function (rowNode, index) {
							  	for (var i = 0; i < aData.length; i++) {
								  if (rowNode.data.program_fixed_freight_id === aData[i].program_fixed_freight_id){
								  	rowNode.setData(aData[i]);
								  	data = rowNode.data;
								  	nodes.push(rowNode);
								  	break;
								  }
								}
							  });
							  Freight_GridOptions.api.redrawRows({ rowNodes: nodes });                       
                        }
                        ,error: function (data) {
                            alert('An error occurred. RFP Freight ' + JSON.stringify(data) );
                        }
                        ,type: "post"
                        ,url: "/mvc/Models/Program/RfpManager.cfc"
            });
	}

	var savedFilterModel = null;

	function clearFilters() {
	  	Freight_GridOptions.api.setFilterModel(null);
	}

	function saveFilterModel() {
		  savedFilterModel = Freight_GridOptions.api.getFilterModel();

		  var keys = Object.keys(savedFilterModel);
		  var savedFilters = keys.length > 0 ? keys.join(', ') : '(none)';
	}

	function restoreFilterModel() {
	  	Freight_GridOptions.api.setFilterModel(savedFilterModel);
	}

	document.addEventListener("DOMContentLoaded", function () {
        Build_RFPFreightGrid();
    });

    const MIN_HEIGHT = 25;

    function autosizeHeaders(event) {
        if (event.finished !== false) {
            event.api.setHeaderHeight(MIN_HEIGHT);
            const headerCells = document.querySelectorAll('#Freight_Grid .ag-header-cell-label');
            let minHeight = MIN_HEIGHT;
            for (var i = 0; i < headerCells.length; i++) {
                minHeight = Math.max(minHeight, headerCells[i].scrollHeight);
            }
            event.api.setHeaderHeight(minHeight);
            let resize_divs = $("div.ag-header-cell-resize");
            // expand border height, for some unknown reasons have to run it twice
            for (var i = 1; i <= 2; i++) {
                resize_divs.each(function() { $(this).pseudo("after", "height", minHeight + 'px !important'); })
            }
        }
    }

    function currencyFormatterZero(params) {
			return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: 2});
	}
	function currencyFormatter(params) {
		if(params.value == 0){
			return '';
		}
		else{
			return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: 2});
		}
	}
	function numberFormatter(params) {
		return Number(params.value).toFixed(2).toLocaleString("en-US");
	}

	function numberFormatterZero(params) {
		if(params.value == 0){
			return '';
		}
		else{
			return Number(params.value).toFixed(2).toLocaleString("en-US");
		}
	}
	function IntFormatterZero(params) {
		if(params.value == 0){
			return '';
		}
		else{
			return params.value.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
		}
	}
	function percentFormatter(params) {
			var s = Number(params.value).toFixed(2).toLocaleString("en-US");
			return s + '%';
	}

	function percentFormatterBracket(params) {
		 if(params.node.data.item_bracket != 3 ){
		 	return '';
		 }
		 else{
			var s = Number(params.value).toFixed(2).toLocaleString("en-US");
			return s + '%';
		 }
	}

	function onBtExportFreight() {
		excelColKeys = [];
		columnDefs_RFP_Freight.forEach(function(item){
			if(item.field != 'price_list_id'){
				excelColKeys.push(item.field);
			}
		});

	    var params = {
	        allColumns: false,
	        columnKeys: excelColKeys
	       // onlySelected: getBooleanValue('#onlySelected'),
	        //fileName: 'export.xlsx',
	        //sheetName: ''
	    };

        params.processCellCallback = function(params) {
           switch (params.column.colDef.field) {
				case 'warehouse_master_id':
					if (typeof params.node.data !== 'undefined'){
						return params.node.data.facility_desc;
					}
					return '';
					break; 
				case 'item_bracket_id':
					var s = '';
		            switch(params.value) {
						  case 1:s = 'TL';break;
						  case 2:s = 'LTL';break;
						  case 3:s = 'Custom Items - Make & Ship';break;}
					return s;
					break; 
				default:
			    	return params.value;
			}
					
		return params.value;
        };

	    Freight_GridOptions.api.exportDataAsExcel(params);
	}

    // jQuery Pseudo
    // URL: http://plugins.jquery.com/pseudo
    // Source: http://github.com/makesites/jquery-pseudo
    //
    // Initiated by [Makis Tracend](http://github.com/tracend)
    // Distributed by [Makesites.org](http://makesites.org)
    // Released under the [MIT license](http://makesites.org/licenses/MIT)

    (function (lib) {

        //"use strict";

        if (typeof define === 'function' && define.amd) {
            // AMD. Register as an anonymous module.
            var deps = ['jquery'];
            define(deps, lib); // give the module a name
        } else if (typeof module === "object" && module && typeof module.exports === "object") {
            // Expose as module.exports in loaders that implement CommonJS module pattern.
            module.exports = lib;
        } else {
            // Browser globals
            var Query = window.jQuery; // not supporting other query engines || window.Zepto || window.vQuery;
            lib(Query);
        }
    }(function ($) {

        // main data container
        var styles = {};


        $.fn.pseudo = function (element, prop, value) {
            // variables
            var el = this[0];
            var id = "pseudo-styles";
            var changed = false;
            var className = "";
            var sheet = document.getElementById(id) || document.createElement('style');
            var head = document.head || document.getElementsByTagName('head')[0];
            sheet.id = id;

            var has_pseudo_class = (this.attr('class') && this.attr('class').indexOf('pseudo-style') > -1);
            if (has_pseudo_class) {
                var classes = this.attr('class');
                // remove classes before
                className = classes.substr(classes.indexOf('pseudo-style'));
                // remove classes after
                className = classes.substr(classes.indexOf(' ') + 1);
                // add / update existing style...
                var selector = className + ":" + element;
                var attributes = {};
                attributes[prop] = value;
                // fallback for the first time...
                if (!styles[selector]) styles[selector] = {};
                // check if the styles have changed
                if (styles[selector] == attributes) {
                    // do nothing...
                } else {
                    styles[selector] = $.extend({}, styles[selector], attributes);
                    changed = true;
                }
            } else {
                // generate a new class name
                var className = "pseudo-style" + UID.getNew();
                el.className += ((el.className == "") ? "" : " ") + className;
                changed = true; // by definition if we're adding a new class we have a change...
            }

            // if the styles hasn't changed, save a cycle
            if (!changed) return this;
            // compile stylesheet
            var output = "";
            for (var target in styles) {
                var css = "";
                for (var key in styles[target]) {
                    css += key + ":" + styles[target][key] + ";";
                }
                output += " ." + target + " {" + css + " }";
            }
            sheet.innerHTML = output;
            // append stylesheet
            head.appendChild(sheet);

            return this;

        };

        // If there is a window object, that at least has a document property
        if (typeof window === "object" && typeof window.document === "object") {
            // save in the global namespace (not needed?)
            window.jQuery = $;
        }


        // Helpers
        var UID = {
            _current: 0,
            getNew: function () {
                this._current++;
                return this._current;
            }
        };


    }));

    <cfif isFobDel>
    	<cfset targetpage = "winSummary_" & variables.ContractMainID>
    	$("button.rfp_save").click( function() {
	        show_loader();
	        var existingWin = window.open('', <cfoutput>'#targetpage#'</cfoutput>);
	            existingWin.reloadFromPopUp();
	            window.close();
	    } )
    <cfelse>
    	$("button.rfp_save").click( function() {
	        show_loader();
	        <cfoutput>parent.location = "/Common_Files/contracts/contract_edit_menu.cfm?CID=#URL.CID#";</cfoutput>
	    } )
    </cfif>
    
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/common_files/focus.cfm">
</body>
</html>
