
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/Freight/Program_Fixed_Freight_Rates_Display.cfm
   Author: Deepa Kunnath
   Date: 12/2020
 
   Usage: Custom display for bFREIGHT_VERSION_ITEM
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
<cfparam name="url.cid"	default="0">
<cf_cryp type="de" string="#trim(url.cid)#" key="#request.key#">
</cfsilent>

<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfsavecontent variable="styles">
        <cf_include files="/styles/tabnav-2020.css">
        <style>
            * { 
                box-sizing: border-box; 
                margin: 0;
                padding: 0;
            }
            html, body {
                height: 100%;
            }
            body {
                display: flex;
            }
            aside {
                width: 141px;
                background-color: #f8fafc;
                height: 100vh;
                padding-left: 7px;
				padding-top: 7px;
            }
            main {
                width: 100%;
				padding-top: 7px;
				padding-right: 7px;
            }
            nav {
                margin-top: 5px;
            }
            iframe {
                border: 0;
                width: 100%;
                height: 100vh;
            }
            .hidden {
                display: none;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    
    <cf_cryp type="de" string="#trim(url.cid)#" key="#request.key#">

    <cfscript>
        variables.ContractMainID = cryp.value ;
        Contract_Main_ID         = cryp.value ;
        CSL_Contract_Main_ID     = Contract_Main_ID;
        CSL_CallingPageCode      = "gi"     ;
        form.contract_main_id    = cryp.value;
		sEditable = true;
    </cfscript>

	<cfquery name="loadFreightDataCC" datasource="#application.datasource#">
		EXEC Populate_Program_Freight_Version_CC '#variables.ContractMainID#'
	</cfquery>

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~ Page Elements ~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <!--- left-hand side bar --->
	
    <aside>
        <cfinclude template="/common_files/contracts/contract_status_legend.cfm">
    </aside>

    <main>
        <!--- program header --->
        <cfset request.style = "2020">  
        <cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">
			
		
		<cfscript>
			verb                    = "CREATE";                // <!--- could be CREATE, EDIT, or VIEW --->
			request.noty_version    = "3";
			jQuery.version          = "1.12.4";
			jQueryUI.widgets        = "tooltip,datepicker";
			jQueryUI.widgets        = "all";
			jQueryUI.version        = "1.11";
			request.ag_grid_theme   = "ba-ag-theme-balham";
			request.ag_grid_version = "21";
			request.ag_expand_header_bars = true;
			
			if(GetContractInfo.Approved) sEditable = false;
		</cfscript>
			
		<cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm">

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
		</style>

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


		<div class="sectionContents"><br>&nbsp;&nbsp;&nbsp;
			Display: 
			<input name="freight_display_type" type="radio" value="freight" checked onclick="javascript: showHideFreightOrDelivered(this)">&nbsp;Freight&nbsp;&nbsp;
			<input name="freight_display_type" type="radio" value="del_price" onclick="javascript: showHideFreightOrDelivered(this)">&nbsp;Delivered Price&nbsp;&nbsp;
			<input name="freight_display_type" type="radio" value="all" onclick="javascript: showHideFreightOrDelivered(this)">&nbsp;All&nbsp;&nbsp;
			
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button class="button export">Export to Excel</button>
		</div>
		<div class="sectionContents">
			<!--- SAMPLE GRID --->
			<div id="Freight_Grid" style="width: 99%; height: 95%;" class="ag-theme-balham ml-2 mt-2"></div>
		</div>
		<br>
	</main>

	<SCRIPT>
		
		// RFP Distributor test data
		var columnDefs_RFP_Freight = [
			{headerName: "Bracket Set", field: "product_attribute_code", cellClass:"stringType",  width:20,filter: 'agTextColumnFilter'},
			{headerName: "Item", field: "item", cellClass:"stringType",  width:40,filter: 'agTextColumnFilter'},
			{headerName: "Item Description", field: "description", cellClass:"stringType",  width:80, headerClass: 'multiline', autoHeight: true,filter: 'agTextColumnFilter'},

			/* FOB column*/
			{headerName: "FOB Price", field: "fob_price_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},																															 
			/* freight columns*/
			{headerName: "Bracket 1 Freight", field: "obf_rate_1_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 2 Freight", field: "obf_rate_2_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 3 Freight", field: "obf_rate_3_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 4 Freight", field: "obf_rate_4_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 5 Freight", field: "obf_rate_5_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 6 Freight", field: "obf_rate_6_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 7 Freight", field: "obf_rate_7_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
																															 
			{headerName: "Bracket 8 Freight", field: "obf_rate_8_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'<cfif sEditable EQ 1>,'editable'</cfif>], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			<cfif sEditable>,editable: true</cfif>},
						
			/* Del columns*/
			{headerName: "Bracket 1 Del Price", field: "del_price_1_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 2 Del Price", field: "del_price_2_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 3 Del Price", field: "del_price_3_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 4 Del Price", field: "del_price_4_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 5 Del Price", field: "del_price_5_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 6 Del Price", field: "del_price_6_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 7 Del Price", field: "del_price_7_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
			
			{headerName: "Bracket 8 Del Price", field: "del_price_8_cs",  width:40, filter: 'agNumberColumnFilter', cellClass: ['twoDecimalPlacesDollar','textRight'], type: 'numericColumn', valueFormatter: currencyFormatterZero ,headerClass: 'multiline',autoHeight: true, filter: 'agNumberColumnFilter',cellEditor:NumericCellEditor
			,hide: true},
																															 
		];


		var Freight_GridOptions = {};

		function Build_RFPFreightGrid() {
			// Init RFP Freight grid
			Freight_GridOptions = {
				columnDefs: columnDefs_RFP_Freight

				,rowModelType: "clientSide"     // TODO change to server-side
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
				,onGridReady: function (p) {
					this.api.sizeColumnsToFit();
				}
				,onRowSelected: function(event) {
					//console.log(event);
					if(event.node.selected == false){
						//console.log(event.data);
						//deleteCustomer(event.data);
					}
				   // alert('onCellValueChanged: ' + event.colDef.field + ' = ' + event.newValue);
				}
				,onColumnResized: autosizeHeaders
				,getRowNodeId: function(data) {
					return data.program_freight_version_cc_id;
				}
				<cfif sEditable EQ 1 >
				,onCellValueChanged: function(event) {
					if(event.oldValue != event.newValue){
						//console.log(event);
						saveData(JSON.stringify(event.data), event.colDef.field);
					}
				}
				</cfif>
			};

			ag_grid_default(Freight_GridOptions);		// set up default features
			Freight_GridOptions.excelStyles.push({ id: "twoDecimalPlacesDollar", numberFormat: {format: '$#,###,##0.00'} });

			/* For some reason grid was not showing otherwise */
			Freight_GridOptions.blackSmith.fullHeight = true;
			Freight_GridOptions.blackSmith.height_offset = -20;

			init_ag_grid( Freight_GridOptions, "#Freight_Grid", false );   // setup as client side TODO change to server-side
			set_grid_line_height( "#Freight_Grid", "26px" );

		}

		function saveData(data, field){ // Save a single rows
			<cfif sEditable EQ 0> return; </cfif>

			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>'#variables.ContractMainID#'</cfoutput>,
										stData: data,
										field: field,
										method: 'saveFreightDataCC'
									}
							//,dataType: "json"
							,success: function (data) {
								var aData = JSON.parse(data);
								var rowData = aData[0];
								var rowNode = Freight_GridOptions.api.getRowNode(rowData.program_freight_version_cc_id);
								rowNode.setData(rowData);
								//RFP_Products_GridOptions.redrawRows({ rowNodes: rowNode });
								var rowNodes = [rowNode]; // params needs an array
								// RFP_Products_GridOptions.api.refreshCells(params);
								Freight_GridOptions.api.redrawRows({ rowNodes: rowNodes });   // 
							}
							,error: function (data) {
								alert('An error occurred. ' + JSON.stringify(data) );
							}
							,type: "post"
							,url: "/components/freight/ProgramFreight.cfc"
				});
		}

		function getFreightData(){
			$.ajax({
							async: true
							,dataType: 'json'
							,data: { 	contractId: <cfoutput>'#variables.ContractMainID#'</cfoutput>,
										method: "getFreightDataCC" }
							,success: function (data) {
								rowData_RFP_Freight = data;
								Freight_GridOptions.api.setRowData(rowData_RFP_Freight);
								//Freight_GridOptions.api.setHeaderHeight(50);
								Freight_GridOptions.api.sizeColumnsToFit();
								Freight_GridOptions.api.doLayout();
							}
							,error: function (data) {
								alert('An error occurred. ' + JSON.stringify(data) );
							}
							,type: "post"
							,url: "/components/freight/ProgramFreight.cfc"
				});
		}

		document.addEventListener("DOMContentLoaded", function () {
			Build_RFPFreightGrid();
			getFreightData();
		});
		
		function showHideFreightOrDelivered(obj){
			
			var arFreightColumns = ["obf_rate_1_cs", "obf_rate_2_cs", "obf_rate_3_cs", "obf_rate_4_cs", "obf_rate_5_cs", "obf_rate_6_cs", "obf_rate_7_cs", "obf_rate_8_cs"];
			var arDelColumns = ["fob_price_cs", "del_price_1_cs", "del_price_2_cs", "del_price_3_cs", "del_price_4_cs", "del_price_5_cs", "del_price_6_cs", "del_price_7_cs", "del_price_8_cs"];
			
			if(obj.value == "all"){
				
				var arAllColumns = arFreightColumns.concat(arDelColumns);
				
				//Show all columns
				Freight_GridOptions.columnApi.setColumnsVisible(arAllColumns, true);
				Freight_GridOptions.columnApi.autoSizeColumns(arAllColumns);
				
			}
			else if(obj.value == "del_price"){
				
				//Hide freight columns
				Freight_GridOptions.columnApi.setColumnsVisible(arFreightColumns, false);
				
				//Show del columns
				Freight_GridOptions.columnApi.setColumnsVisible(arDelColumns, true);
				Freight_GridOptions.columnApi.autoSizeColumns(arDelColumns);
				
				Freight_GridOptions.api.sizeColumnsToFit();
				
			}
			else {
				
				//Hide del columns
				Freight_GridOptions.columnApi.setColumnsVisible(arDelColumns, false);
				
				//Show freight columns
				Freight_GridOptions.columnApi.setColumnsVisible(arFreightColumns, true);
				
				Freight_GridOptions.api.sizeColumnsToFit();
			}
			
			
		}
		
		$("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
			//freight_display_type
			var sFreightDisplayType = $("input[name=freight_display_type]:checked").val();
			var sColDesc = "Delivered Price";
			if(sFreightDisplayType == "freight") sColDesc = "Freight";
			<cfoutput>
			let file_title  = "#GetContractInfo.Contract_Number# - " + sColDesc;
			</cfoutput>
            Freight_GridOptions.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
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




	</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



</body>
</html>