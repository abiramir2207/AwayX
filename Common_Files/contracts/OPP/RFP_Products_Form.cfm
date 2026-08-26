
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/RFP_Products_Form.cfm
   Author: Mark Saunderss
   Date: 3/25/2020

   Usage: basic Info module for RFP deal (Request For Pricing).  Custom feature.
   		  Called from  /Common_Files/contracts/OPP/RFP_Form.cfm

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->

</cfsilent>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfscript>
	rfpManager 		= CreateObject("component", "mvc.Models.Program.RfpManager");
	qGetFacilities	= rfpManager.getFacilities(Contract_Main_ID);
	qHQPosition = CreateObject("component", "components.geography.position").getHQPosition();
	lGPSuppliedPosition = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1);

	cfparam(name="oppViewOnly", default=0);
	sEditable = 'true';
	if(oppViewOnly == 1 || request.page_mode is review_mode){
		sEditable = 'false';
	}

	bHQUser = 0;
	if(listcontains(lGPSuppliedPosition, qHQPosition.User_Positions_ID)){
		bHQUser = 1;
    }
</cfscript>
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
    /* div.ag-header-cell-resize {
        width: 5px !important;
        height: 100%;
        background-color: #cdb590;
        opacity: 0.7;
    }
    .ag-theme-balham .ag-header-cell::after, .ag-theme-balham .ag-header-group-cell::after {
        height: 100%;
        margin-top: 0;
    }     */
</style>

<FORM ACTION="javascript:saveSelectedRFPProducts();" METHOD="post" NAME="dataForm" ID="dataForm">
	<CFOUTPUT>
		<input type="hidden" name="Is_Group"  value="1">
		<input type="Hidden" name="ExistingProductList" id="ExistingProductList"  value="">
		<input type="Hidden" name="Product_List"  value=""  id="Product_List">
		<input type="Hidden" name="ExistingProductList_Field_Name"  id="ExistingProductList_Field_Name"  value="ExistingProductList">
	</CFOUTPUT>
</FORM>

<cfif oppViewOnly EQ 0>
    <h5 class="sectionHeader">ELIGIBLE PRODUCTS</h5>
</cfif>

<div class="sectionContents text-xs" style="width: 100%;height: 100%;">
    <cfif oppViewOnly EQ 0>
        <div class="ml-2" style="width: 100%;">
            <button id="rfpSelectProdsButton" type="button" class="button ml-4 review" onclick="showRFPProductSearch();return false;">Select Products</button>
            <button id="rfpDeleteProdsButton" type="button" class="button ml-4 review" onclick="deleteRFPProducts();return false;">Delete Selected Products</button>

            <label class="opacity-75 pr-1 review" style="padding-left: 30px;">Stock Item Bracket:</label>
            <select name="stockItemBracket" id="stockItemBracket" class="border rounded review">
                <option selected value="0"> -- select Stock Item Bracket -- </option>
                    <option value="1" >TL</option>
                    <option value="2" >LTL</option>
                    <option value="3" >Custom Items - Make & Ship</option>
            </select>
            <button onclick="onBtExport()" style="margin-left:20px; cursor:pointer" type="button" class="button">Export to Excel</button>
        </div>
    </cfif>

    <!--- PRODUCTS GRID --->
    <div id="RFP_Products_Grid" style="width:99%;height:52vh;" class="ag-theme-balham m-2"></div>

    <cfparam name="request.already_had_components" default="0">
    <!--- do not include freight message when user has no freight view/create permission --->
    <cfset goto_freight = Get_Profile_Settings.RFP_Freight_View_Create eq 0
                            ? ""
                            : "and go to Freight">
    <cfoutput><button type="button" class="button rfp_save hidden review">Save #goto_freight#</button></cfoutput>
</div>



<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~ JavaScript ~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<SCRIPT>

	$("#massApplyList").change(function(){
		var s = $("#massApplyList option:selected").text();
		if(s.includes('%')){

			$("#rateText").text('Rate: %');
		}
		else{
			$("#rateText").text('Rate: $');
		}
	    //savePriceList($( this ).val(),'NON');
	});
	$("#stockItemBracket" ).change(function() {
		updStockItemBracket();
	});
	$("#schedule_options").change(function(){
		    saveSchedule($( this ).val());
		});
	// RFP Products test data
	var columnDefs_RFP_Products = [];
	var excelColKeys = [];

	function setWidthAndHeight(size) {
		    // var eGridDiv = document.querySelector('#RFP_Products_Grid');
		    // eGridDiv.style.setProperty('width', size);
		    // eGridDiv.style.setProperty('height', size);
		    RFP_Products_GridOptions.api.doLayout();
		}
	//FUNCTION TO ADD ICON IN HEADER
	function CheckboxHeaderComponent() {}
		CheckboxHeaderComponent.prototype.init = function (params) {

		this.eGui = document.createElement('div');
		let value = isAllChecked(params.column.colId) == false ? '' : ' checked';
		var domString = '<div class="ag-cell-label-container ag-header-cell-sorted-none" role="presentation">'+
						'<div ref="eLabel" class="ag-header-cell-label" role="presentation" unselectable="on"> '+
							'<span ref="eText" class="ag-header-cell-text cursor-auto" role="columnheader" unselectable="on">'+
								params.displayName +
								'<input type="checkbox" onclick="onCheckboxHeaderClick(\'' +params.column.colId+ '\')" id="' +params.column.colId+ '"' +value+ '>'+
							'</span>'+
						'</div></div>';
		this.eGui.innerHTML = domString;
	}
	CheckboxHeaderComponent.prototype.getGui = function () { return this.eGui; };

	function onCheckboxHeaderClick(sCol) {
		<cfif sEditable NEQ 1>
			return;
		</cfif>
		let checked = $("#"+sCol).prop('checked');
		// if now checked, check all checkboxes below it
		if (checked == true) {
			RFP_Products_GridOptions.api.forEachNode( function(rowNode, index) {
				//if (isEditableCheckbox(rowNode)	) {			// Allow to change if not disabled
					//TODO: Create one Function to save all rows at once
					rowNode.data[sCol] = 1;
					saveData(JSON.stringify(rowNode.data), sCol);
				//}
			});
		}
		else {
			RFP_Products_GridOptions.api.forEachNode( function(rowNode, index) {
				//if (isEditableCheckbox(rowNode)	) {			// Allow to change if not disabled
					rowNode.data[sCol] = 0;
					//TODO: Create one Function to save all rows at once
					saveData(JSON.stringify(rowNode.data), sCol);
				//}
			});
		}
		RFP_Products_GridOptions.api.refreshCells();
	};

	function isAllChecked(col) {
		let ret = true;
		RFP_Products_GridOptions.api.forEachNode( function(rowNode, index) {
			if (rowNode.data[col] == false) {
				ret = false;	// BREAK NOT ALLOWED!! would like to get out at first one found
			}
		});
		$("#"+col).prop('checked', ret);
		return ret;
	}

	function synchHeaderCheckbox(on,col) {
		let state = on ? ' checked' : '';
		let checkbox = document.getElementById(col);
		checkbox.checked = state;
	}

	// <a onClick="JavaScript: NewWindow('/Common_Files/contracts/Formula/Formula_Display_RFP.cfm?Program_Id=#CSLGetContractInfo.Contract_Main_ID#&contract_products_id=#getFixedPriceProducts.Contract_Products_ID#', 'FormulaDisplay',800, 800,1,1)" title="View Formula" STYLE="cursor: pointer;">#getFixedPriceProducts.ITEM#</a>
	function EditCellRenderer() {
		}
		<cfoutput>
		EditCellRenderer.prototype.init = function (params) {
		    this.eGui = document.createElement('span');

		        var jsCode = "JavaScript: openPopup('/Common_Files/contracts/Formula/Formula_Display_RFP.cfm?Program_Id="+#variables.ContractMainID#+"&contract_products_id="+params.data.contract_products_id+"', 800, 800)";
		        this.eGui.innerHTML = '<a onClick="'+jsCode+'" title="Edit Formula '+'" STYLE="cursor: pointer;">'+params.data.item+'</a>';
		};

		EditCellRenderer.prototype.getGui = function () {
		    return this.eGui;
		};
		// gets called whenever the user gets the cell to refresh
		EditCellRenderer.prototype.refresh = function(params) {
		    this.eGui = document.createElement('span');
		    var jsCode = "JavaScript: openPopup('/Common_Files/contracts/Formula/Formula_Display_RFP.cfm?Program_Id="+#variables.ContractMainID#+"&contract_products_id="+params.data.contract_products_id+"', 800, 800)";
		    this.eGui.innerHTML = '<a onClick="'+jsCode+'" title="Edit Formula '+'" STYLE="cursor: pointer;">'+params.data.item+'</a>';
		    return true;
		};
		</cfoutput>
	function setRFPProdColDefs() {
		$("#RFP_Products_Grid").empty();
		columnDefs_RFP_Products = [
			{headerName: "Item", field: "item", width:20, filter: 'agTextColumnFilter', sort: 'asc', cellClass: 'textFormat' ,headerClass: 'multiline'
			<cfif sEditable EQ 1>	,checkboxSelection: true,
									headerCheckboxSelection: true,
									headerCheckboxSelectionFilteredOnly: true,
									cellRendererSelector:function (params) {
							            var editFormullaLink = {
							                component: 'editCellRenderer'
							            };
							          <cfif GetSettings.Discount_Formula_Pricing EQ 1>
							            if(params.node.data.current_price > 0){
							            	return editFormullaLink;
							            }
							            else{
							            	return params.node.data.item;
							       		}
							       	<cfelse>
							       			return params.node.data.item;
							       	</cfif>
							        }
			</cfif>},
		    {headerName: "Description", field: "description",  width:30 ,filter: 'agTextColumnFilter' ,headerClass: 'multiline'},
		    {headerName: "Volume (Est Annual CS)", field: "volume",  width:13, filter: 'agNumberColumnFilter', cellClass: ['noDecimalPlaces','textRight'<cfif sEditable EQ 1>,'editable']<cfelse>]</cfif>, type: 'numericColumn' ,headerClass: 'multiline',valueFormatter:IntFormatterZero
					, editable:<cfoutput>#sEditable#</cfoutput>},
		    {headerName: "Current Price", field: "current_price",  width:13, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable']<cfelse>]</cfif>, type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline'
			    		<cfif sEditable>
				    			,editable: true
				    			,cellEditor: 'numericCellEditor'
						</cfif>
					},

		    {headerName: "List Price", field: "list_price",  width:8, filter: 'agNumberColumnFilter', valueFormatter: currencyFormatterZero, cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable']<cfelse>]</cfif>, type: 'numericColumn' ,headerClass: 'multiline'
						<cfif sEditable>
			    			,editable:function(params) {
						            return params.node.data.isTBD === 1;   //params.node.data.item_bracket === 3;
						        }
						    ,cellClass: function(params) { return (params.node.data.isTBD === 1?['twoDecimalPlacesDollar','editable','textRight']:['twoDecimalPlacesDollar','textRight']); }   //params.node.data.item_bracket === 3;
						<cfelse>
							,editable: false
							,cellClass: 'twoDecimalPlacesDollar textRight'
							,cellEditor: 'numericCellEditor'
						</cfif>},
		    //{headerName: "Price List Id", field: "price_list_id",  width:10, filter: 'agTextColumnFilter' hide: true},
		    {headerName: "Var %", field: "variance_perc",  width:8, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesPerc','textRight'], type: 'numericColumn' ,headerClass: 'multiline', valueFormatter: percentFormatter},
		    {headerName: "Case Cube", field: "case_cube",  width:8, filter: 'agNumberColumnFilter', type: 'numericColumn' ,headerClass: 'multiline'
		    		  <cfif sEditable>
			    			,editable:function(params) {
						            return params.node.data.isTBD === 1;   //params.node.data.item_bracket === 3;
						        }
						    ,cellClass: function(params) { return (params.node.data.isTBD === 1?['twoDecimalPlaces','editable','textRight']:['twoDecimalPlaces','textRight']); }
						<cfelse>
							,editable: false
							,cellClass: 'twoDecimalPlaces textRight'
							,cellEditor: 'numericCellEditor'
						</cfif>},
		    {headerName: "Annual Estimated Case Cube", field: "annual_case_cube",  width:15, filter: 'agNumberColumnFilter', cellClass: ['noDecimalPlaces','textRight'], type: 'numericColumn' ,headerClass: 'multiline',valueFormatter:IntFormatterZero},
		    {headerName: "Stock Item Bracket", field: "item_bracket",  width:28, filter: false ,headerClass: 'multiline',
		    			valueFormatter: function (params) {
						    	var s = '';
					            switch(params.value) {
									  case 1:s = 'TL'; break;
									  case 2:s = 'LTL';break;
									  case 3:s = 'Custom Items - Make & Ship';break;}
								return s;
						},
				<cfif sEditable>
		    			editable:function(params) {
					            return params.node.data.edit_stock_bracket != 0;   //params.node.data.isTBD === 1;
					        },
					 	cellEditor : 'agRichSelectCellEditor',
						cellEditorParams : {
						    values: [1,2,3],
						    formatValue: function(value) {
						    	var s = '';
					            switch(value) {
									  case 1:s = 'TL';break;
									  case 2:s = 'LTL';break;
									  case 3:s = 'Custom Items - Make & Ship';
									  break;
								}
								return s;
					          },
						}
					   ,cellClass: function(params) { return (params.node.data.edit_stock_bracket !=0?['editable']:['']); }
				<cfelse>
						editable: false
				</cfif>
			},
		    {headerName: "Run Volume Per Order (Cases)", field: "run_vol_cs",  width:13, filter: 'agNumberColumnFilter', type: 'numericColumn' ,headerClass: 'multiline'//,valueFormatter:IntFormatterZero
		    			,valueFormatter: function (params) {
			    			if (params.node.data.item_bracket === 3){   ///
					   			return params.value.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
					   		}
						    return '';
			    		}
						<cfif sEditable>
			    			,editable:function(params) {
						            return params.node.data.item_bracket === 3;   //params.node.data.item_bracket === 3
						        }
						    ,cellClass: function(params) { return (params.node.data.item_bracket === 3?['noDecimalPlaces','editable','textRight']:['noDecimalPlaces','textRight']); }   //params.node.data.item_bracket === 3
						<cfelse>
							,editable: false
							,cellClass: 'noDecimalPlaces textRight'
						</cfif>
					    },
		    {headerName: "Run Volume Per Order (Pieces)", field: "run_vol_piece",  width:13, filter: 'agNumberColumnFilter', cellClass: ['noDecimalPlaces','textRight'], type: 'numericColumn' ,headerClass: 'multiline'//,valueFormatter:IntFormatterZero
		    			,valueFormatter: function (params) {
			    			if (params.node.data.item_bracket === 3){  //params.node.data.item_bracket === 3
					   			return params.value.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
					   		}
						    return '';
			    		}
						// <cfif sEditable>
						// 	,editable:function(params) {
						//         return params.node.data.item_bracket == 3;
						//     }
						//  </cfif>
						},
		    // {headerName: "Facility Id", field: "Facility_desc",  width:10, filter: 'agTextColumnFilter', hide: true},
		    {headerName: "Facility Override", field: "facility_id",  width:30, filter: false,  headerClass:'custom-header' ,headerClass: 'multiline',<cfif sEditable AND bHQUser>cellClass: 'editable', </cfif>
		    		valueFormatter: function (params) {
		    			if (typeof params.value !== 'undefined'){
				   			return params.value.name;
				   		}
					    return '';
                    }
                    // ngt
					<cfif sEditable AND bHQUser><cfset i = 1>
			    			,editable: true,
						 	cellEditor : 'agRichSelectCellEditor',
							cellEditorParams : {
							    values:[
							    <cfoutput query="qGetFacilities">
							    		{name:'(#qGetFacilities.Facility_Code#) #qGetFacilities.Warehouse_Name#', id: '#qGetFacilities.Facility_Id#'}<cfif i Neq qGetFacilities.recordcount>,</cfif>
							    		<cfset i = i + 1>
							    </cfoutput>],
							   formatValue: function(value) {
							   		if (typeof value !== 'undefined'){
							   			return value.name;
							   		}
							    	return '-- --';
							    	//return params.valueFormatted.name;
								   	//return params.value.name;
								},
								cellRenderer: function(params) {
                                    if (typeof params.value !== 'undefined'){
							   			return params.value.name;
							   		}
								    return '-- Select a facility --';
								}
							}
					</cfif>	},
		    {headerName: "Cs Cnt", field: "case_count",  width:8, filter: 'agNumberColumnFilter', type: 'numericColumn' ,headerClass: 'multiline',valueFormatter:IntFormatterZero,  editable:<cfoutput>#sEditable#</cfoutput>
					 <cfif sEditable>
			    			,editable:function(params) {
						            return params.node.data.isTBD === 1;   //params.node.data.item_bracket === 3;
						        }
						    ,cellClass: function(params) { return (params.node.data.isTBD === 1?['noDecimalPlaces','editable','textRight']:['noDecimalPlaces','textRight']); }
						<cfelse>
							,editable: false
							,cellClass:['noDecimalPlaces','textRight']
						</cfif>},
		    {headerName: "Est Ann Pcs", field: "est_annual_piece",  width:13, filter: 'agNumberColumnFilter', cellClass: ['noDecimalPlaces','textRight'], type: 'numericColumn' ,headerClass: 'multiline',valueFormatter:IntFormatterZero},
		    {headerName: "Custom Print # of Colors", field: "custom_print_colors",  width:13, filter: 'agNumberColumnFilter', type: 'numericColumn' ,headerClass: 'multiline',valueFormatter: function(params) { const p = { value: params.data.custom_print_colors }; return params.data.isTBD === 1 ? numberFormatterZero(p) : ''
            }
						<cfif sEditable>
			    			,editable:function(params) {
                                    return params.node.data.isTBD === 1;
						        }
						  ,cellClass: function(params) { return (params.node.data.isTBD === 1 ? ['noDecimalPlaces','editable','textRight'] : ['noDecimalPlaces','textRight']); }
						<cfelse>
							,editable: false
							,cellClass: ['noDecimalPlaces','textRight']
						</cfif>
					},
            {headerName: "Custom Print Ink Coverage (%)", field: "custom_print_ink",  width:13, filter: 'agNumberColumnFilter', type: 'numericColumn' ,headerClass: 'multiline', valueFormatter:function(params) { const p = { value: params.data.custom_print_ink }; return params.node.data.isTBD === 1 ? percentFormatter(p) : ''
            }
						<cfif sEditable>
			    			,editable:function(params) {
                                    return params.node.data.isTBD === 1;
						        }
						   ,cellClass: function(params) { return (params.node.data.isTBD === 1 ? ['twoDecimalPlacesPerc','editable','textRight'] : ['twoDecimalPlacesPerc','textRight']); }
						<cfelse>
							,editable: false
							,cellClass: ['twoDecimalPlacesPerc','textRight']
						</cfif>
					},
		    {headerName: "ReDi", field: "redi",  width:10, filter: 'agTextColumnFilter',  headerClass:'custom-header', autoHeight: true,
						valueFormatter: function (params) {
						    	var s = '';
					            switch(params.value) {
									  case 1:s = 'YES'; break;
									  case 0:s = 'NO';break;
									  default:s = '';break;
									}
								return s;
						}
					},
		    {headerName: "Either /Or Item", field: "either_or",  width:10, filter: false ,headerClass: 'multiline', singleClickEdit: true, cellClass: 'centered', headerComponent: CheckboxHeaderComponent, suppressMenu:true, floatingFilter:"true"
		    	<cfif oppViewOnly EQ 0>	,cellRenderer: function(params) {
				        var input = document.createElement('input');
				        input.type="checkbox";
                        input.title = "Check if yes";
                        input.checked=params.value;
                        input.classList.add("checkbox");
                        <cfif request.page_mode is review_mode>
                            input.disabled = true;
                        <cfelse>
                            input.addEventListener('click', function (event) {
                                params.value=!params.value;
                                params.node.data.either_or = params.value ? 1 : 0;
                                log.debug("clicked on 'either_or' & passed", params.node.data.either_or, "to saveData()");
                                saveData(JSON.stringify(params.node.data), "either_or");
                                synchHeaderCheckbox (isAllChecked("either_or"),"either_or");
                            });
                        </cfif>
				        return input;
				    }</cfif>
				},
		    {headerName: "Comm<br>", field: "commissions",  width:12, filter: false ,headerClass: 'multiline', singleClickEdit: true, cellClass: 'centered', headerComponent: CheckboxHeaderComponent, suppressMenu:true, floatingFilter:"true"
                <cfif oppViewOnly EQ 0>	,cellRenderer: function(params) {
				        var input = document.createElement('input');
				        input.type="checkbox";
                        input.checked=params.value;
                        input.title = "Check if yes";
                        input.classList.add("checkbox");
                        <cfif request.page_mode is review_mode>
                            input.disabled = true;
                        <cfelse>
                            input.addEventListener('click', function (event) {
                                params.value=!params.value;
                                params.node.data.commissions = params.value ? 1 : 0;
                                log.debug("clicked on 'commissions' & passed", params.node.data.commissions, "to saveData()");
                                saveData(JSON.stringify(params.node.data), "commissions");
                                synchHeaderCheckbox (isAllChecked ("commissions"),"commissions");
                            });
                        </cfif>
				        return input;
                    }</cfif>

                }

		   // ,{headerName: "comp1", field: "comp1",  width:50, filter: 'agTextColumnFilter'} contract_start_date
        ];
    }

	var rowData_RFP_Products = [];
	var RFP_Products_GridOptions = {};

	function Build_RFPProductsGrid() {

		// Init RFP Products grid
		RFP_Products_GridOptions = {
			 defaultColDef: {
			        sortable: true,
                    filter: true,
                    resizable: true,
                    autoHeight: true
              }
            ,rowHeight: 30
            ,floatingFilter: true
			,columnDefs: columnDefs_RFP_Products
		    ,rowData: rowData_RFP_Products
		    ,rowModelType: "clientSide"     // TODO change to server-side
		    ,cacheBlockSize: 2000
		    ,singleClickEdit: true
	        ,stopEditingWhenGridLosesFocus: true
	        ,rowSelection: 'multiple'
            ,onColumnResized: autosizeHeaders
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
		     ,onGridReady: function () {
		         this.api.sizeColumnsToFit();
		     }
		     ,components:{
                    editCellRenderer: EditCellRenderer,
                    numericCellEditor: NumericCellEditor
			    }
		    <cfif oppViewOnly EQ 0 and request.page_mode neq review_mode>
		    ,onCellValueChanged: function(event) {
		        if(event.oldValue != event.newValue){
		        	var s = event.colDef.field;
                    if(s.indexOf("fixed_price_value_") ==0){s='fixed_price_value_'}
                    if (s === 'facility_id') {
                        if (event.oldValue.id === event.newValue.id)
                            return;
                    }
                    log.debug("saveData() was called for field '" + s + "'");
		        	switch(s) {
					  case 'volume': case 'item_bracket': case 'custom_print_colors': case 'custom_print_ink': case 'facility_id': case 'run_vol_cs' : case 'current_price' : case 'list_price' : case 'case_cube' : case 'case_count' :
					    saveData(JSON.stringify(event.data), event.colDef.field);
					    break;
					  case 'fixed_price_value_':
					    saveRFPProductOverride(JSON.stringify(event.data), event.colDef.field);
					    break;
					  default:
						break;
					}
		        }
		    }
		    </cfif>
		    ,getRowNodeId: function(data) {
			    return data.contract_products_id;
			}
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
		ag_grid_default(RFP_Products_GridOptions);		// set up default features
        /* ngt - disable cells editing and checkboxes selection in review mode */
        <cfif request.page_mode is review_mode>
            disable_editing( RFP_Products_GridOptions );
        </cfif>
        init_ag_grid( RFP_Products_GridOptions, "#RFP_Products_Grid", false );   // setup as client side TODO change to server-side
	}

	function getRFPProducts(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getRFPProducts" }
						//,dataType: "json"
						,success: function (data) {
			              rowData_RFP_Products = JSON.parse(data);
			              var prodList = '';
			              rowData_RFP_Products.forEach(function(item){
			              	if(prodList == ''){
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              	else{
			              		prodList = prodList.concat(',');
			              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
			              	}
			              });
			              $('#ExistingProductList').val(prodList);
			              RFP_Products_GridOptions.api.setRowData(rowData_RFP_Products);
                          RFP_Products_GridOptions.api.doLayout();
                          isAllChecked("either_or");
                          isAllChecked("commissions");
                         // setGridHeight(RFP_Products_GridOptions, "#RFP_Products_Grid", data.length);
                          /* products exist so shows the save button */
                          if (rowData_RFP_Products.length) {
                            $("button.rfp_save").show();
                          }
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function saveSelectedRFPProducts(){
        <cfif request.page_mode is review_mode> return; </cfif>
		show_loader('Saving Product Data...');
		var frm = $('#dataForm');
		var fields = frm.serializeArray();
		var data = JSON.stringify(fields);
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									arrData: data,
									method: "saveSelectedRfpProducts" }
						//,dataType: "json"
						,success: function (data) {
			              getRFPProducts();
			              $("div.loader").hide();
			            }
			            ,error: function (data) {

			                $("div.loader").hide();
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

    function saveRFPProductOverride(data, field){ // Save a single rows'
        <cfif request.page_mode is review_mode> return; </cfif>
        $.ajax({
                        async: true
                        ,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
                                    stData: data,
                                    field: field,
                                    rev:   <cfoutput>#variables.RevisionVersion#</cfoutput>,
                                    method: "saveRFPProductOverRide" }
                        //,dataType: "json"
                        ,success: function (data) {
                            var aData = JSON.parse(data);
                            var rowData = aData[0];
                            var rowNode = RFP_Products_GridOptions.api.getRowNode(rowData.contract_products_id);
                            rowNode.setData(rowData);
                        }
                        ,error: function (data) {
                            alert('An error occurred.  ' + JSON.stringify(data) );
                        }
                        ,type: "post"
                        ,url: "/mvc/Models/Program/RfpManager.cfc"
            });
	}

	function saveData(data, field){ // Save a single rows
        <cfif request.page_mode is review_mode> return; </cfif>
        var sMethod = '';
        switch(field) {
            case 'volume':
                sMethod = 'saveVolume';
                break;
            case 'item_bracket':
                sMethod = 'saveItemBracket';
                break;
            case 'either_or':
                sMethod = 'saveEitherOr';
                break;
            case 'commissions':
                sMethod = 'saveCommissions';
                break;
            case 'custom_print_colors': case 'custom_print_ink':
                sMethod = 'saveCustomPrint';
                break;
            case 'facility_id':
                sMethod = 'saveFacility';
                break;
            case 'run_vol_cs' :
                sMethod = 'saveRunVolumeCS';
                break;
            case 'current_price' :
                sMethod = 'saveCurrentPrice';
                break;
            case 'list_price' :
                sMethod = 'saveListPrice';
                break;
            case 'case_cube' :
                sMethod = 'saveCaseCube';
                break;
            case 'case_count' :
                sMethod = 'saveCaseCount';
                break;
            default:
                return;
        }
        $.ajax({
                        async: true
                        ,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
                                    stData: data,
                                    //field: field,
                                    method: sMethod
                                }
                        //,dataType: "json"
                        ,success: function (data) {
                        var aData = JSON.parse(data);
                        var rowData = aData[0];
                        var rowNode = RFP_Products_GridOptions.api.getRowNode(rowData.contract_products_id);
                        rowNode.setData(rowData);
                        //RFP_Products_GridOptions.redrawRows({ rowNodes: rowNode });
                        var rowNodes = [rowNode]; // params needs an array
                        RFP_Products_GridOptions.api.redrawRows({ rowNodes: rowNodes });   //
                        }
                        ,error: function (data) {
                            alert('An error occurred.  ' + JSON.stringify(data) );
                        }
                        ,type: "post"
                        ,url: "/mvc/Models/Program/RfpManager.cfc"
            });
	}

	function getRFPCompIdList(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getRFPCompIdList" }
						//,dataType: "json"
						,success: function (data) {
			              var comps = JSON.parse(data);
			              setRFPProdColDefs();
                            comps.forEach(function(item){


                                <cfoutput>
                                    columnDefs_RFP_Products.splice(4,0,{headerName: item.compname, field: 'fixed_price_value_'+item.compid,  width:20,
                                    valueFormatter: currencyFormatter, cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable']<cfelse>]</cfif>,
                                    	<cfif sEditable EQ 1>
                                        	editable: #(request.page_mode is review_mode ? false : true)#,
                                        	cellEditor: 'numericCellEditor',
                                    	</cfif>
                                    	type: 'numericColumn', headerClass: 'multiline' } );
                                </cfoutput>
                            });
			   			 if(comps.length){
			   			 	Build_RFPProductsGrid();
			   			  	getRFPProducts();
			   			 }
			   			 else{
			   			 	  $("#RFP_Products_Grid").empty();
			   			 }
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function updStockItemBracket(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									stockItemBracket: $('#stockItemBracket').val(),
									method: "updStockItemBracket" }
						//,dataType: "json"
						,success: function (data) {
							getRFPProducts(); //IN RFP_Products_Form.cfm
			            }
			            ,error: function (data) {
			                $("div.loader").hide();
			                alert('An error occurred (updStockItemBracket).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function getStockItemBracket(){
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getStockItemBracket" }
						//,dataType: "json"
						,success: function (data) {
                            $('#stockItemBracket').val(data)
			            }
			            ,error: function (data) {
			                $("div.loader").hide();
			                alert('An error occurred (updStockItemBracket).  ' + JSON.stringify(data));
			            }
						,type: "post"
						,url: "/mvc/Models/Program/RfpManager.cfc"
			});
	}

	function saveSchedule(optionId){
        <cfif request.page_mode is review_mode> return; </cfif>
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										optionId: optionId,
										method: "saveScheduleOption" }
							//,dataType: "json"
							,success: function (data) {
					            d = JSON.parse(data);
				            }
				            ,error: function (data) {
				                alert('An error occurred (saveSchedule).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
                });
	}

	var savedFilterModel = null;

	function clearFilters() {
	  	RFP_Products_GridOptions.api.setFilterModel(null);
	}

	function saveFilterModel() {
		  savedFilterModel = RFP_Products_GridOptions.api.getFilterModel();

		  var keys = Object.keys(savedFilterModel);
		  var savedFilters = keys.length > 0 ? keys.join(', ') : '(none)';

		  document.querySelector('#savedFilters').innerHTML = savedFilters;
	}

	function restoreFilterModel() {
	  	RFP_Products_GridOptions.api.setFilterModel(savedFilterModel);
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

	function deleteRFPProducts() {
        <cfif request.page_mode is review_mode> return; </cfif>
		show_loader('Deleting Products...');
		var selectedData = JSON.stringify(RFP_Products_GridOptions.api.getSelectedRows());
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								aData: selectedData,
								method: "deleteRFPProducts" }
					,success: function (data) {
		     			getRFPProducts();
		            	$("div.loader").hide();
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/RfpManager.cfc"
		});
	}
	function massApplyRates() {
        <cfif request.page_mode is review_mode> return; </cfif>
		show_loader('Mass Applying Rates...');
		var selectedData = JSON.stringify(RFP_Products_GridOptions.api.getSelectedRows());
		var compId = $("#massApplyList").val();
		var rate = $("#massrate").val();
		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								aData: selectedData,
								compId: compId,
								rate: rate,
								method: "updateRFPCompRates" }
					,success: function (data) {
		     			getRFPProducts();
		            	$("div.loader").hide();
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/RfpManager.cfc"
		});
	}
	function deleteSelectedRFPComponent() {
        <cfif request.page_mode is review_mode> return; </cfif>
		if(Components_GridOptions.api.getSelectedRows().length > 0 || $('#massApplyList').children('option').length >= 2 ){
			show_loader('Deleting Selected Rebate Component...'); //and fall through to delete 1
		}
		else{ // Delete All
			deleteRFPComponents(); ///ON RFP_Components_Form -> Delete All
			return;
		}
		var sMethod = 'deleteOneRFPComponent'; //Delete One
		var compId = $("#massApplyList").val();
		if($('#massApplyList').children('option').length <= 2){
			sMethod = 'deleteRfpComponents'; //Delete All
		}

		$.ajax({
					async: true
					,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
								compId: compId,
								method: sMethod	 }
					,success: function (data) {
		     			// ON RFP_Components_Form.cfm
		     			refreshCompData();
		        		// ON RFP_Components_Form.cfm
		            	$("div.loader").hide();
		            }
		            ,error: function (data) {
		            	$("div.loader").hide();
		                alert('An error occurred.  ' + JSON.stringify(data) );
		            }
					,type: "post"
					,url: "/mvc/Models/Program/RfpManager.cfc"
		});
	}
	document.addEventListener("DOMContentLoaded", function () {
		setRFPProdColDefs();
		getRFPCompIdList();
		getStockItemBracket();
	    //Build_RFPProductsGrid();
	    //getProducts();
	 });

	 const MIN_HEIGHT = 25;

    function autosizeHeaders(event) {
        if (event.finished !== false) {
            event.api.setHeaderHeight(MIN_HEIGHT);
            const headerCells = document.querySelectorAll('#RFP_Products_Grid .ag-header-cell-label');
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

	function showRFPProductSearch(){
		var bSelectedAllProducts = false;
		var groupLevel = 0;
		<cfoutput>
			var sURL = "/Common_Files/contracts/product_Select_V1.cfm?Formname=dataForm&discountype=1&programId=#variables.ContractMainID#&prgID=#variables.ContractMainID#&LoadExistingProductList=1";
		</cfoutput>
		NewWindowTopLeft(sURL, "productWindow", 1000, 700, "yes", "yes")
		return false;
	}

	function getCharCodeFromEvent(event) {
	    event = event || window.event;
	    return (typeof event.which == "undefined") ? event.keyCode : event.which;
	}

	function isCharNumeric(charStr) {
		//console.log(this.value);
		//console.log(!!/^\d*\.?\d{1,1}$/.test(charStr));
	    return !!/^\d*\.?\d{1,1}$/.test(charStr);
	}

	function isKeyPressedNumeric(event) {
	    var charCode = getCharCodeFromEvent(event);
	    var charStr = String.fromCharCode(charCode);
	    return (isCharNumeric(charStr) || charStr == '.');
	}
	function isTextSelected(input) {
	    if (typeof input.selectionStart == "number") {
	        return input.selectionStart == 0 && input.selectionEnd == input.value.length;
	    } else if (typeof document.selection != "undefined") {
	        input.focus();
	        return document.selection.createRange().text == input.value;
	    }
	}
	// function to act as a class
	function NumericCellEditor() {
	}

	// gets called once before the renderer is used
	NumericCellEditor.prototype.init = function (params) {
	    // create the cell
	    this.eInput = document.createElement('input');
	    this.eInput.type = 'number';
	    this.eInput.step =".01";
	   //this.eInput.pattern="/^\d+(?:\.\d{0,2})?/"
	    //this.eInput.classList.add('ag-cell-edit-input');
		//this.eInput.value = params.value;


	    if (isCharNumeric(params.charPress)) {
	        this.eInput.value = params.charPress;
	    } else {
	        if (params.value !== undefined && params.value !== null) {
	            this.eInput.value = params.value;
	        }
	    }
	    //this.eInput.value = 0;

	    var that = this;
	    this.eInput.addEventListener('keypress', function (event) {
	    	//if(this.value == '' || this.value == null)this.value = 0.00
	    	//console.log(String.fromCharCode(getCharCodeFromEvent(event)));
	    	//console.log(event);
	    	//console.log(isKeyPressedNumeric(event));
	    	//console.log(isCharNumeric(this.value));

	        if (!isKeyPressedNumeric(event) ) {  //  || (!isCharNumeric(this.value))	&& String.fromCharCode(getCharCodeFromEvent(event)) != '.'
	        	//this.value =  Number(this.value).toFixed(2).toLocaleString("en-US");
	        	//console.log(this.value);
	            that.eInput.focus();
	            that.eInput.select();
	            if (event.preventDefault) event.preventDefault();
	        } else if (that.isKeyPressedNavigation(event)) {
	        	//console.log(isCharNumeric(Number(this.value.toString + String.fromCharCode(getCharCodeFromEvent(event).toString))));
	        	//console.log(Number(this.value.toString + String.fromCharCode(getCharCodeFromEvent(event).toString)));
	        	if(!isCharNumeric(Number(this.value.toString + String.fromCharCode(getCharCodeFromEvent(event).toString)))){
	    			if (event.preventDefault) event.preventDefault();
	        	}
	        	that.eInput.focus(eInput);
	        	that.eInput.select(eInput);
	            event.stopPropagation();
	        }
	    });

	    var charPressIsNotANumber = params.charPress && ('1234567890.'.indexOf(params.charPress) < 0);
	    this.cancelBeforeStart = charPressIsNotANumber;

	};

	NumericCellEditor.prototype.isKeyPressedNavigation = function (event) {
	    return event.keyCode === 39
	        || event.keyCode === 37;
	};


	// gets called once when grid ready to insert the element
	NumericCellEditor.prototype.getGui = function () {
	    return this.eInput;
	};

	// focus and select can be done after the gui is attached
	NumericCellEditor.prototype.afterGuiAttached = function () {
		this.eInput.focus();
		this.eInput.select();
	};

	// returns the new value after editing
	NumericCellEditor.prototype.isCancelBeforeStart = function () {
	    return this.cancelBeforeStart;
	};

	// returns the new value after editing
	NumericCellEditor.prototype.getValue = function () {
		//var re = new RegExp('^\d*\.?\d{1,2}$');
		//return this.eInput.value;
   		return Number(this.eInput.value.toString().match(/^\d+(?:\.\d{0,2})?/));
	    //return Number(this.eInput.value).toFixed(2).toLocaleString("en-US");
	};

	function onBtExport() {
		excelColKeys = [];
		columnDefs_RFP_Products.forEach(function(item){
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
				case 'either_or': case 'commissions': case 'redi':
					var s = 'NO';
					switch(params.value) {
							  case 1:s = 'YES'; break;
							  case 0:s = 'NO';break;
							}
					return s;
					break;
				case 'facility_id':
					if (typeof params.value !== 'undefined'){
						return params.value.name;
					}
					return '';
					break;
				case 'item_bracket':
					var s = '';
		            switch(params.value) {
						  case 1:s = 'TL';break;
						  case 2:s = 'LTL';break;
						  case 3:s = 'Custom Items - Make & Ship';break;}
					return s;
					break;
				case 'custom_print_colors':
					if (params.value == 0){
						return '';
					}
					return params.value;
					break;
				case 'variance_perc': case 'custom_print_ink':
					if (params.value == 0){
						return '';
					}else{
						return params.value/100;
					}
					return '';
					break;
				default:
			    	return params.value;
			}

		return params.value;
        };

	    RFP_Products_GridOptions.api.exportDataAsExcel(params);
	}

</SCRIPT>

<script>
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

    $("button.rfp_save").click(function(){
        <cfif Get_Profile_Settings.RFP_Freight_View_Create>
            /* activate freight tab only when user has permission */
            parent.get_navli( "freight" ).click();
        <cfelse>
            <cfoutput>parent.location = "/Common_Files/contracts/contract_edit_menu.cfm?CID=#URL.CID#";</cfoutput>
        </cfif>
    });

	// allow to scroll vertically to view products at the bottom
	$("body", window.parent.document).css("overflow", "auto");
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
