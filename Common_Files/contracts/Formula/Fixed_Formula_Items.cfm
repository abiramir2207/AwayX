<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/Formula/Fixed_Formula_Items.cfm
   Author: Mark Saunders
   Date: 3/12/2019

   Usage: Configure Item level Formula details

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->

</cfsilent>

<CF_CRYP type="de" string="#trim(URL.CID)#" key="#request.key#">

<cfscript>
	appSettings = application.appSettingsGet;
	decimalPrecisionCS = appSettings.get_Setting('Formula_Pricing_Round_For_CS');
	decimalPrecisionLB = appSettings.get_Setting('Formula_Pricing_Round_For_LB');

	variables.ContractMainID = cryp.value;
	Contract_Main_ID = cryp.value;
	CSL_Contract_Main_ID = Contract_Main_ID;
	bEdit = 0;
	disableRFA = appSettings.getdisablepagesinrfa();
	byComponent = 0;

	cfparam(name="oppViewOnly", default=0);
	sEditable = 'true';
	if(oppViewOnly == 1){
		sEditable = 'false';
	}


</cfscript>

	<cfquery name="qGetPayTypes" datasource="#application.datasource#">
		SELECT DISTINCT PT.Payment_Type_Name, PT.Payment_Type_ID, PT.Is_Auto_pay,PT.Restrict_From_Billback,
			ISNULL(NULLIF(CM.ClaimMechanics,0),pcpo.ClaimMechDefaultOption) AS ClaimMechanics 
			FROM Contract_Main CM
			INNER JOIN Payment_Template_Mapping PTM ON
				PTM.Template_ID = CM.ProgramType_ID
				and PTM.Deleted = 0
			INNER JOIN Payment_Type PT
				ON PT.Payment_Type_ID = PTM.Payment_Type_ID
			INNER JOIN Program_Control_Panel_Options pcpo on PCPO.ProgramControl_Panel_Options_Id = PTM.Template_Id
			WHERE CM.Contract_Main_ID = #variables.ContractMainID# 
	</CFQUERY>

<cfquery name="GetContractInfo" datasource="#application.datasource#">
            SELECT	*,Contract_Main_Aux_Data.*
            FROM	Contract_Main
            INNER JOIN Contract_Main_Aux_Data
            ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
            WHERE 	Contract_Main.Contract_Main_ID = '#variables.ContractMainID#'
</cfquery>
<cfquery name="qGetScheduleOptions" datasource="#application.datasource#">
		SELECT DISTINCT FSO.FP_Schedule_Option_ID,
								FSO.Price_Day_Code,
								FSO.Price_Day_Description,
								FSO.Effective_Day,
								FSO.Effective_Day_Description,
								FSO.Notes,
								FSO.Price_Day_Frequency,
								FSO.Price_Day_When,
								FSO.Effective_Day_Type,
								FSO.Effective_Day_When,
								ISNULL(CM.Formula_Price_Rebate_Type,0) AS selectedOptionId
						FROM FP_Schedule_Options FSO
						INNER JOIN Contract_Main CM ON CM.Contract_Main_Id = '#variables.ContractMainID#'
						WHERE FSO.active = 1
						ORDER BY price_Day_Frequency desc,Price_Day_When ASC
</cfquery>
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
			Formula_Pricing_Type
    FROM Program_Control_Panel_Options
    WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
  </cfquery>

<cfif GetTemplateInfo.Formula_Pricing_Type eq 2>
	<cfset byComponent = 1 />
</cfif>
<cfscript>
	if(GetContractInfo.Contract_Status_Type_IDX EQ 1 OR (disableRFA EQ 0 AND GetContractInfo.Contract_Status_Type_IDX EQ 2)){
		bEdit = 1;
	}
</cfscript>
<!doctype html>
<html lang="en">
<head>
	<title>Program Editor</title>
	<cfsavecontent variable="head_content">
	<style>
		html, body {
			margin: 0;
            padding: 0;
            width: 99.5%;
            /* height: 95%; */
        }

        legend {
            font-size: 11px;
            font-weight: 600;
        }

        /* Section headers have blue dot, name, then horizontal line */
        .sectionHeader {
            overflow: hidden;
            font-weight: normal;
            margin-bottom: 5px;
        }
        .sectionHeader:before {
            /* blue dot */
            content: "";
            display: block;
            background: #222A97;
            width: 9px;
            height: 9px;
            border-radius: 50%;
            float: left;
            margin: 1px 6px 0 0;
        }
        .sectionHeader:after {
            /* h line */
            display: inline-block;
            position: relative;
            vertical-align: middle;
            margin-left: 6px;
            height: 1px;
            content: "";
            text-shadow: none;
            background-color: #d8d9dd;
            margin-right: -100%;
            width: 100%;
        }
        .sectionContents {
            margin-left: 10px;
        }

        .fieldGroup {
			background-color: #edeef2;
			border: 1px solid #c4c5c7;
			border-radius: 8px;
			margin-top: 3px;
		}
		.formGrayOut{
			background: #ccc;
       	}

	</style>
    </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</HEAD>
<body>
    <cfset verb="CREATE"/>      <!--- could be CREATE, EDIT, or VIEW --->
    <cfset request.noty_version = "3">
	<cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm">
    <cfset request.ag_grid_theme = "ba-ag-theme-balham">
    <cfset request.ag_grid_version = "21">

    <cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/common_Files/ag-Grid.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css",
									   "/script/javascript/jquery.noty.packaged.min.js"
                                        ] )#>
 <style>
        <!--- override the ag-grid styles included above --->
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			/* padding-left: 4px; */
			padding-right: 2px;
        }
        .ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
        .ag-theme-balham .ag-header-cell {
            padding-left: 6px;  /* get checkbox to line up */
        }
  		.ag-theme-balham .ag-row-selected {
    		border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
		    left: 2px; /* center the checkbox */
    	}
    	.number-cell {
	        text-align: right;
	    }
    </style>

<div class="min-h-screen md:flex" style="padding-bottom: 10px;">

    <!--------------------->
    <!---- NAV SECTION ---->
    <!--------------------->
    <div id="navArea" class="flex-none w-full bg-grey-lightest  text-base text-black text-left" style="width:140px;padding-top: 6px;">
      <CFINCLUDE TEMPLATE="/Common_Files/contracts/contract_status_legend.cfm" />
    </div>

    <div class="flex-1 bg-white mx-1 text-sm text-black" style="padding-top: 6px;">
	<!--- program header --->
	<cfset form.contract_main_id    = cryp.value />
	<cfset request.style = "2020">
	<cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">
	<br>
		<!--- Formula Pricing Type is component START --->
		<cfif GetTemplateInfo.Formula_Pricing_Type eq 2>
			<div class="comp"><h5 class="sectionHeader compText">COMPONENTS (Collapse)</h5></div>
				<div class="sectionContents text-xs">
					<!--- COMPONENTS GRID --->
					<div class="table-row review">	
						<button type="button" class="button table-cell review" id="deleteProductComponents" <cfif sEditable>onclick="deleteRFPComponents();return false;" </cfif>style="margin: 5px 0 0 0">Delete All Product Components</button>
					</div>            
					<div id="Components_Grid" style="width: 520px;height: 200px;" class="ag-theme-balham ml-2 mt-2 pb-3"></div>
					<br>
					<div class="ml-2">
						<label class="opacity-75 pr-1">Schedule Options:</label>
						<select name="schedule_options" id="schedule_options" class="border rounded" <cfif bEdit EQ 0>disabled</cfif> >
							<option disabled selected value>-- Select a Formula Schedule --</option>
							<cfoutput query="qGetScheduleOptions">
								<cfset s = ''/>
								<cfif FP_Schedule_Option_ID eq selectedOptionId><cfset s = 'selected'/></cfif>
								<option value="#FP_Schedule_Option_ID#" #s#>#Price_Day_Description# :: #Effective_Day_Description#</option>
							</cfoutput>
						</select>
						<div class="customContainer" style="display:none;"></div>
					</div>
			</div>
		<!--- Formula Pricing Type is component END --->
		<cfelse>
			<section name="section_Brackets" class="mr-1" style="padding-top: 6px;">
				<!--- Brackets GRID --->
				<h5 class="sectionHeader">BRACKETS</h5>
				<section name="section_BasicInfo" class="mr-1" style="padding-top: 6px;">
					<div class="sectionContents text-xs">
						<cfif bEdit EQ 1>
							<button type="button" class="button" id="removeBracketButton" onclick="onRemoveSelected();return false;">Remove Bracket</button>
							<button type="button" class="button" id="insertBracketButton" onclick="addBracketsManual();return false;">Insert Brackets</button>
							<button type="button" class="button" id="resetBracketButton" onclick="resetBracket();return false;">Reset Brackets</button>
						</cfif>
						<!--- BRACKETS GRID --->
						<div id="Brackets_Grid" style="width: 305px; height: 150px;" class="ag-theme-balham ml-2 mt-2 pb-3"></div>
						<br>
						<div class="ml-2">
						<label class="opacity-75 pr-1">Schedule Options:</label>
							<select name="schedule_options" id="schedule_options" class="border rounded" <cfif bEdit EQ 0>disabled</cfif> >
								<option disabled selected value>-- Select a Formula Schedule --</option>
								<cfoutput query="qGetScheduleOptions">
									<cfset s = ''/>
									<cfif FP_Schedule_Option_ID eq selectedOptionId><cfset s = 'selected'/></cfif>
									<option value="#FP_Schedule_Option_ID#" #s#>#Price_Day_Description# :: #Effective_Day_Description#</option>
								</cfoutput>
							</select>
							<div class="customContainer" style="display:none;"></div>
						</div>
					</div>
				</section>
			</section>
		</cfif>
		<FORM ACTION="javascript:saveProducts();" METHOD="post" NAME="ProdForm" ID="ProdForm">
	<CFOUTPUT>
		<input type="hidden" name="Is_Group"  value="1">
		<input type="Hidden" name="ExistingProductList" id="ExistingProductList"  value="">
		<input type="Hidden" name="Product_List"  value=""  id="Product_List">
		<input type="Hidden" name="ExistingProductList_Field_Name"  id="ExistingProductList_Field_Name"  value="ExistingProductList">
		<input type="Hidden" name="Level_1"  value=""  id="Level_1">
		<input type="Hidden" name="GroupLevel_1"  value=""  id="GroupLevel_1">
		<input type="Hidden" name="Level_2"  value=""  id="Level_2">
		<input type="Hidden" name="GroupLevel_2"  value=""  id="GroupLevel_2">
		<input type="Hidden" name="Level_3"  value=""  id="Level_3">
		<input type="Hidden" name="GroupLevel_3"  value=""  id="GroupLevel_3">
	</CFOUTPUT>
</FORM>
<section name="section_Brackets" class="mr-1" style="padding-top: 6px;">
	<h5 class="sectionHeader">PRODUCT BRACKETS</h5>
    <div class="sectionContents pb-4">
	<cfif bEdit EQ 1>
		<button type="button" class="button" onclick="showProductSearch();return false;">select products</button>
		<button id="gpoDeleteProdsButton" type="button" class="button ml-4" onclick="deleteBracketProducts();return false;">delete selected products</button>
		<button id="recalculateFormulaButton" type="button" class="button ml-4" onclick="recalculateFormula();return false;">recalculate formula</button>
	</cfif>
        <br>
		<!--- Products GRID --->
        <div id="Products_Grid" style="width: 1200px; height: 130px;" class="ag-theme-balham ml-2 mt-2"></div>
   </div>
</section>
</div>
</div>
	<SCRIPT>
		function setAutoHeight(gridOptions, gridID) {
			gridOptions.api.setDomLayout('autoHeight');
			// auto height will get the grid to fill the height of the contents,
			// so the grid div should have no height set, the height is dynamic.
			document.querySelector(gridID).style.height = '';
			//console.log('setAutoHeight:  ' + gridID);
		}

		// Use this when you want a specific grid height, or when there is no data, use with height ~ '70px' to center the "No Rows" text
		function setFixedHeight(gridOptions, gridID, height) {
			height = height || '100px';
			gridOptions.api.setDomLayout('normal');
			// when auto height is off, the grid has a fixed height, and then the grid
			// will provide scrollbars if the data does not fit into it.
			document.querySelector(gridID).style.height = height;
		}

		function setGridHeight(gridOptions, gridID, rows) {
			if (rows > 0) {
				setAutoHeight(gridOptions, gridID);
			} else {
				setFixedHeight(gridOptions, gridID, "70px");
			}
		}

		const usdFormat = new Intl.NumberFormat('en-US', {
												style: 'currency',
												currency: 'USD',
												minimumFractionDigits: 4
											});

		function CurrencyCellRenderer(params) {
			// Input is "*" to signify no upper limit. Let that through as is.
			if (params.value =="*")
				return("*");
			// sometimes we get a string with junk in it instead of the integer we are looking for.  Convert it.
			if (isNaN (params.value) ) {
				// Strip out everything except minus sign, digits, period
				params.value = parseFloat(params.value.replace( /[^-\d+\.\d+]/g, ''));
			}
			return usdFormat.format(params.value);
		}

		$("#schedule_options").change(function(){
		    saveSchedule($( this ).val());
		});
		/*************************************************************************
		**************   Formula_Pricing_Type eq 2 START ***********************
		*************************************************************************/
		<cfif GetTemplateInfo.Formula_Pricing_Type eq 2>
			// ComponentS data
			var columnDefs_Components = [
				{headerName: "Component #", field: "chkbox", width:100, checkboxSelection:true, sortable: false},
				{headerName: "Name", field: "name", width:250, editable: false, sortable: false},
				{headerName: "Pay Type", field: "pay_type", width:150,filter: 'agTextColumnFilter',  headerClass:'custom-header' ,headerClass: 'multiline',
					valueFormatter: function (params) {
						if (typeof params.value !== 'undefined'){
							return params.value.pay_name;
						}
						return '';
					}
					<cfif sEditable >
						<cfset i = 1>
							,editable: false
							,cellEditor : 'agRichSelectCellEditor'
							,cellEditorParams : {
								values:[
								<cfoutput query="qGetPayTypes">
										{pay_name:'#qGetPayTypes.Payment_Type_Name#', pay_id: '#qGetPayTypes.Payment_Type_ID#'}<cfif i Neq qGetPayTypes.recordcount>,</cfif>
										<cfset i = i + 1>
								</cfoutput>],
							formatValue: function(value) {
									if (typeof value !== 'undefined'){
										return value.pay_name;
									}
									return '-- --';
								},
								cellRenderer: function(params) {
									if (typeof params.value !== 'undefined'){
										return params.value.pay_name;
									}
									return '-- Select a Pay Type --';
								}
							}
					</cfif>	
				}
			];

			var rowData_Components = [];
			var ComponentCount = 1;

			var editable = 1;
			var Components_GridOptions = {};
			function Build_ComponentsGrid() {
				// Init Components grid
				Components_GridOptions = {
					columnDefs: columnDefs_Components
					<cfif sEditable>
						,rowSelection: 'multiple'
					</cfif>
					,suppressRowClickSelection: true
					,defaultColDef: {editable: true,
									resizable: true}
					,singleClickEdit: true
					,stopEditingWhenGridLosesFocus: true
					,rowData: rowData_Components
					,rowModelType: "clientSide" 
					,cacheBlockSize: 2000
					,domLayout: 'autoHeight'
					,onGridReady: function () {
						// this.api.sizeColumnsToFit();
					}
					
					<cfif sEditable>
					,onRowSelected: function(event) {
						if(event.data.selected != event.node.selected){
							//if($('#rebate_eligibleRFP').val() != 0){
								event.data.selected = event.node.selected;
							//}
							if(event.data.selected){
								saveComponentData(event.data);
							}
							else{
								if(Components_GridOptions.api.getSelectedRows().length > 0 || $('#massApplyList').children('option').length >= 3){
									deleteUnSelectedFPCompFromComp(event.data.compid);
								}
								else{
									deleteRFPComponents();
								}
								
							}
						}
					}
					,onCellValueChanged: function(event) {
						if(event.oldValue != event.newValue){
							var s = event.colDef.field;
				
							switch(s) {
							case 'pay_type':
								updClaimMechanic(JSON.stringify(event.data), event.colDef.field);
								break;
							default:
							}
						}
					}
					</cfif>
				};
				ag_grid_default(Components_GridOptions);		// set up default features
				init_ag_grid( Components_GridOptions, "#Components_Grid", false );   // setup as client side

			}

			function refreshCompData(){
				getComponents();
				getCompIdList();
				getProducts();
			}

			function saveComponentData(svData){
				data = JSON.stringify(svData);
				show_loader('Creating Components...');
				$.ajax({
							async: true
							,dataType: 'json'
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										Component_Name_ID: svData.compid,
										//data: data,
										Claim_Mechanics: svData.pay_type.pay_id,
										method: "saveFPFixedComp" 
									}
							,success: function (data) {
								//rowData_Components = JSON.parse(data);   ///   CONFUSED....NO PARSE NEDED ON SAVE, BUT GET NEEDS IT.  SAME FUNCTION GETS DATA
								rowData_Components = data;
								//saveSelectedRFPProducts(); // ON RFP_Products_Form.cfm
								refreshCompData();
								$("div.loader").hide();
							}
							,error: function (data) {
							$("div.loader").hide();
								alert('An error occurred (saveComponentData).  ' + JSON.stringify(data) );
							}
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function getComponents(){
				$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										method: "getFPFixedComps" }
							//,dataType: "json"
							,success: function (data) {
								rowData_Components = JSON.parse(data);  

								rowData_Components.forEach(function(item){
									item.pay_type = {pay_id: item.pay_id, pay_name: item.pay_name};
								});

								Components_GridOptions.api.setRowData(rowData_Components);
								Components_GridOptions.api.forEachNode( function (node) {
									if (node.data.selected === 1) {
										node.setSelected(true);
									}
								Components_GridOptions.api.doLayout();
								setGridHeight(Components_GridOptions, "#Components_Grid", rowData_Components.length);
								});
								getProducts();
							}
							,error: function (data) {
								alert('An error occurred (getComponents).  ' + JSON.stringify(data) );
							}
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function onRemoveSelected() {
				//show_loader('Removeing Component Data...');
				if(editable === 0){
					alert('Remove not allowed after saving components.');
					return;
				}
				var selectedData = Components_GridOptions.api.getSelectedRows();
				var res = Components_GridOptions.api.updateRowData({remove: selectedData});
				var a = [];
				res.remove.forEach( function(rowNode) {a.push(rowNode.data);});
				deleteComponents(JSON.stringify(a));
			}

			function deleteRFPComponents(){
				show_loader('Deleting Components and Products...');
				$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										method: "deleteFPComponents" }
							//,dataType: "json"
							,success: function (data) {
								refreshCompData();
								$("div.loader").hide();
							}
							,error: function (data) {
								$("div.loader").hide();
								alert('An error occurred (deleteComponents).  ' + JSON.stringify(data) );
							}
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}


			function updClaimMechanic(data, field){
				var d = JSON.parse(data);
				if(d.prg_comp_id == 0){
					return;
				}
				$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										stData: data,
										method: "updClaimMechanic" }
							//,dataType: "json"
							,success: function (data) {
								//refresh
								getComponents();
							}
							,error: function (data) {
								$("div.loader").hide();
								alert('An error occurred (updClaimMechanic).  ' + JSON.stringify(data));
							}
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function deleteUnSelectedFPCompFromComp(compId){
				show_loader('Deleting Selected Rebate Component...');
				$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										compId: compId,
										method: "deleteOneFPComponent" }
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
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
			}
			document.addEventListener("DOMContentLoaded", function () {
				Build_ComponentsGrid();
				getComponents();
				getCompIdList();
				Build_BracketProductsGrid();
				getProducts();
			});

			$(".comp").click(function () {

				$header = $(this);
				//getting the next element
				$content = $header.next();
				//open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
				$content.slideToggle(500, function () {
					//execute this after slideToggle is done
					//change text of header based on visibility of content div
					$(".compText").text(function () {
						//change text based on condition
						return $content.is(":visible") ? "COMPONENTS (Collapse)" : "COMPONENTS (Expand)";
					});
				});
			});
		/*************************************************************************
		****************   Formula_Pricing_Type eq 2 END *************************
		*************************************************************************/

		/*************************************************************************
		****************   Formula_Pricing_Type ELSE START *************************
		*************************************************************************/
		<cfelse>							
			// BRACKETS columns
			var columnDefs_Brackets = [
				{	headerName: "Bracket #",
					field: "description",
					width:150,
					checkboxSelection: function(params){
													// // brack 11 not editable
														return params.node.data.bracketnumber != 11;
													},
					sortable: false,
					editable: false
					},

				{headerName: "Bracket Premium", field: "rate",  type: "numericColumn", width:150, sortable: false, valueFormatter: CurrencyCellRenderer,
						cellStyle: function(params) {
														if (params.data.override === 1) {
															//mark police cells as red  , backgroundColor: 'green'
															return {color: 'red'};
														} else {
															return null;
														}
													},
					<cfif bEdit EQ 1>
						editable: function(params){
													// bracket 11 not editable
													return params.node.data.bracketnumber != 11;
												}
					<cfelse>
						editable: false
					</cfif>
				},
				{headerName: "", field: "override", hide: true, sortable: false},
				{headerName: "", field: "brackid", hide: true, sortable: false}
			];

			var rowData_Brackets = [];
			var bracketCount = 1;

			function createNewRowData() {

				var bracketData = {
					t: "BRACKET " + bracketCount,
					start: "$0 ",
					end: "$0",
					rate: '0',
					id: '0',
					rate_desc: '0%',
					rate_uom_desc: '%',
					rate_uom_id: 3,
					bracketnum: + bracketCount
				};
				bracketCount++;
				return bracketData;
			}

					var columnDefs_Bracket_Products = [];


			var Brackets_GridOptions = {};
			function Build_BracketsGrid() {
				// Init Brackets grid
				Brackets_GridOptions = {
					columnDefs: columnDefs_Brackets
					,rowSelection: 'single'
					,defaultColDef: {editable: true,
									resizable: true}
					,singleClickEdit: true
					,stopEditingWhenGridLosesFocus: true
					,rowData: rowData_Brackets
					,rowModelType: "clientSide"
					,domLayout: 'autoHeight'
					,cacheBlockSize: 2000
					// ,domLayout: "autoHeight"
					,onGridReady: function () {
						setGridHeight(Brackets_GridOptions, "#Brackets_Grid", rowData_Brackets.length);
					}
					,onCellValueChanged: function(event) {
						if(event.oldValue != event.newValue){
							updateBracket(event);
						}

					}
				};
				ag_grid_default(Brackets_GridOptions);		// set up default features
				init_ag_grid( Brackets_GridOptions, "#Brackets_Grid", false );   // setup as client side
				Brackets_GridOptions.api.setRowData(rowData_Brackets);
			}

			function getBrackets(){

				$.ajax({
								async: true
								,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
											method: "insertBrackets" }
								//,dataType: "json"
								,success: function (data) {
									rowData_Brackets = JSON.parse(data);
									bracketCount = rowData_Brackets.length + 1;
									setGridHeight(Brackets_GridOptions, "#Brackets_Grid", rowData_Brackets.length);
									Brackets_GridOptions.api.setRowData(rowData_Brackets);
									getCompIdList();
								}
								,error: function (data) {
									// console.log(data);
									alert('An error occurred (getBrackets).  ' + JSON.stringify(data) );
								}
								,type: "post"
								,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function updateBracket(e){
				if(e.colDef.field == 'rate'){
					sMethod = 'updateBracket';
				}
				else if(e.colDef.field == 'uom'){
					sMethod = 'updateBracketUom';
				}
				$.ajax({
								async: true
								,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
											BracketId: e.data.brackid,
											ruleId:'',
											//Contract_Products_Id:0,
											rate:e.newValue,
											uom:e.newValue,
											method:  sMethod }  //rate or uom update
								//,dataType: "json"
								,success: function (data) {
									rowData_Brackets = JSON.parse(data);
									//console.log(rowData_Brackets);
									bracketCount = rowData_Brackets.length + 1;
									setGridHeight(Brackets_GridOptions, "#Brackets_Grid", rowData_Brackets.length);
									Brackets_GridOptions.api.setRowData(rowData_Brackets);
									getProducts();
								}
								,error: function (data) {
									alert('An error occurred (getBrackets).  ' + JSON.stringify(data) );
								}
								,type: "post"
								,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function resetBracket(){
				var selectedData = JSON.stringify(Brackets_GridOptions.api.getSelectedRows());
				sMethod = 'resetBracket';
				$.ajax({
								async: true
								,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									aData: selectedData,
											method:  sMethod }  //rate or uom update
								,success: function (data) {
									rowData_Brackets = JSON.parse(data);
									bracketCount = rowData_Brackets.length + 1;
									setGridHeight(Brackets_GridOptions, "#Brackets_Grid", rowData_Brackets.length);
									Brackets_GridOptions.api.setRowData(rowData_Brackets);
									getBrackets();
									getProducts();
								}
								,error: function (data) {
									alert('An error occurred (getBrackets).  ' + JSON.stringify(data) );
								}
								,type: "post"
								,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}	



			function createFormulaComps(){
				//Make sure we have rates
				show_loader('Creating Product Brackets...');
				var stop = 0;
				$.ajax({
								async: true
								,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
											//Claim_Mechanics: $('#rebate_eligible').val(),
											method: "createFormulaComponents" }
								//,dataType: "json"
								,success: function (data) {
									getCompIdList();
									$("div.loader").hide();
								}
								,error: function (data) {
									alert('An error occurred (checkFixedCount).  ' + JSON.stringify(data));
								}
								,type: "post"
								,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function onRemoveSelected() {
					var selectedData = Brackets_GridOptions.api.getSelectedRows();
					var res = Brackets_GridOptions.api.updateRowData({remove: selectedData});
					var a = [];
					res.remove.forEach( function(rowNode) {
						a.push(rowNode.data.brackid);
					});
					deleteBracket(a);
				}

			function deleteBracket(a){
				var str = a.join(", ");
				$.ajax({
								async: true
								,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
											BracketId: str,
											method:  'deleteBracket' }  //rate or uom update
								//,dataType: "json"
								,success: function (data) {
									rowData_Brackets = JSON.parse(data);
									//console.log(rowData_Brackets);
									bracketCount = rowData_Brackets.length + 1;
									setGridHeight(Brackets_GridOptions, "#Brackets_Grid", rowData_Brackets.length);

									Brackets_GridOptions.api.setRowData(rowData_Brackets);
									getCompIdList();
								}
								,error: function (data) {
									// console.log(data);
									alert('An error occurred (getBrackets).  ' + JSON.stringify(data) );
								}
								,type: "post"
								,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}

			function addBracketsManual(){
				$.ajax({
								async: true
								,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
											method:  'addBracketsManual' }  //rate or uom update
								//,dataType: "json"
								,success: function (data) {
									rowData_Brackets = JSON.parse(data);
									bracketCount = rowData_Brackets.length + 1;
									setGridHeight(Brackets_GridOptions, "#Brackets_Grid", rowData_Brackets.length);

									Brackets_GridOptions.api.setRowData(rowData_Brackets);
									getCompIdList();
								}
								,error: function (data) {
									alert('An error occurred (getBrackets).  ' + JSON.stringify(data) );
								}
								,type: "post"
								,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
					});
			}


			document.addEventListener("DOMContentLoaded", function () {
				Build_BracketsGrid();
				getBrackets();
				//checkFixedCount();
			});

		</cfif>
		/*************************************************************************
		****************   Formula_Pricing_Type ELSE END *************************
		*************************************************************************/
		function saveSchedule(optionId){

			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										optionId: optionId,
										method: "saveScheduleOption" }
							//,dataType: "json"
							,success: function (data) {
					            d = JSON.parse(data);
					            //console.log(d);
				            }
				            ,error: function (data) {
				                alert('An error occurred (saveSchedule).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
		}
	    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	    // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		function EditCellRenderer() {
		}
		<cfoutput>
		EditCellRenderer.prototype.init = function (params) {
			//console.log(params);
		    this.eGui = document.createElement('span');
			var jsCode = "JavaScript: editFormula(#variables.ContractMainID#, " + params.data.contract_products_id + ")";
		    this.eGui.innerHTML = '<a onClick="'+jsCode+'" title="Edit Formula '+'" STYLE="cursor: pointer;" id="editFormula"><b><font color="red">[ </font>edit formula<font color="red"> ]</font></b></a>';
		};
		</cfoutput>
		EditCellRenderer.prototype.getGui = function () {
		    return this.eGui;
		};

		function setProdColDefs() {
				columnDefs_Bracket_Products = [
				    {headerName: "Item", field: "item",   width:75, filter: 'agTextColumnFilter', sort: 'asc',
				    						checkboxSelection: true,
											headerCheckboxSelection: true,
		        							headerCheckboxSelectionFilteredOnly: true },
				    {headerName: "Description", field: "description",  width:150 ,filter: 'agTextColumnFilter'},
				     {headerName: "UOM", field: "uom", width:50, sortable: false,
				    	editable: <cfif bEdit EQ 1>true<cfelse>false</cfif>,
					 	cellEditor : 'agRichSelectCellEditor',
						cellEditorParams : {
						    values: ['CS', 'LBS']
						}
					},
				    {headerName: "Net Weight", field: "netweight",  width:50 ,filter: 'agTextColumnFilter'},
				      {
					        headerName: "",
					        field: "value",
					        width: 60,
					        cellRendererSelector:function (params) {
					            var editFormullaLink = {
					                component: 'editCellRenderer'
					            };
					            return editFormullaLink;
					        }
					    }
				];
		}

		var rowData_Bracket_Products = [];
		var Products_GridOptions = {};
		var columnDefs_Bracket_Products = [];
		function Build_BracketProductsGrid() {
			$("#Products_Grid").empty();
			// Init Bracket Products grid
			Products_GridOptions = {
				 defaultColDef: {
				        sortable: true,
				        filter: true
				  }
				,floatingFilter: true
				,columnDefs: columnDefs_Bracket_Products
			    ,rowData: rowData_Bracket_Products
			    ,rowModelType: "clientSide"
			    ,cacheBlockSize: 2000
			    ,singleClickEdit: true
		        ,stopEditingWhenGridLosesFocus: true
		        ,rowSelection: 'multiple'
		        ,domLayout: 'autoHeight'
			    ,onGridReady: function () {
			        this.api.sizeColumnsToFit();
			    }
			    ,onCellValueChanged: function(event) {
			        //console.log(event);
			        if(event.oldValue != event.newValue){
			        	saveProductOverride(event.data, event.newValue)
			        }
			    }
			    ,components:{
			        editCellRenderer: EditCellRenderer,
			    }
			};
			ag_grid_default(Products_GridOptions);		// set up default features
			init_ag_grid( Products_GridOptions, "#Products_Grid", false );   // setup as client side
		}

		function getProducts(){

			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										method: "getFormulaProducts" }
							//,dataType: "json"
							,success: function (data) {

				              rowData_Bracket_Products = JSON.parse(data);
							  //setProductsGridHeight(rowData_Bracket_Products.length-1);
							  Products_GridOptions.api.setRowData(rowData_Bracket_Products);
							  Products_GridOptions.api.doLayout();
							  Products_GridOptions.api.refreshHeader();
				              var prodList = '';
				              rowData_Bracket_Products.forEach(function(item){
				              	if(prodList == ''){
				              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
				              	}
				              	else{
				              		prodList = prodList.concat(',');
				              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
				              	}
				              });
				              setGridHeight(Products_GridOptions, "#Products_Grid", rowData_Bracket_Products.length);
							  Products_GridOptions.api.sizeColumnsToFit();
				              $('#ExistingProductList').val(prodList);
				              $('#Level_1').val(prodList);
				            }
				            ,error: function (data) {
				                alert('An error occurred.  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
		}

		function saveProducts(){

			show_loader('Saving Product Data...');
			var frm = $('#ProdForm');
			var fields = frm.serializeArray();
			var data = JSON.stringify(fields);
			 //console.log(data);
			//return;
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										arrData: data,
										method: "saveSelectedProducts" }
							//,dataType: "json"
							,success: function (data) {
				              rowData_Bracket_Products = JSON.parse(data);
				              setProductsGridHeight(rowData_Bracket_Products.length-1);
							  Products_GridOptions.api.setRowData(rowData_Bracket_Products);

				              var prodList = '';
				              rowData_Bracket_Products.forEach(function(item){
				              	if(prodList == ''){
				              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
				              	}
				              	else{
				              		prodList = prodList.concat(',');
				              		prodList = prodList.concat(item.bsa_foodservice_items_master_id);
				              	}
				              });
				              $('#ExistingProductList').val(prodList);
				              $('#Level_1').val(prodList);
				              $("div.loader").hide();
				            }
				            ,error: function (data) {

				                $("div.loader").hide();
				                alert('An error occurred.  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
		}

		function saveProductOverride(data, uom){ // Save a single row
			//console.log(data);
			//data = JSON.parse(data);
			show_loader('Saving Product Data...');
			//data = JSON.stringify(data);
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										contractProdId: data.contract_products_id_fixed,
										uom: uom,
										method: "updateItemUom",
										byComponent: "<cfoutput>#byComponent#</cfoutput>"
									}
							//,dataType: "json"
							,success: function (data) {
				              rowData_Bracket_Products = JSON.parse(data);
							  setProductsGridHeight(rowData_Bracket_Products.length-1);
				              Products_GridOptions.api.setRowData(rowData_Bracket_Products);
				              $("div.loader").hide();
				            }
				            ,error: function (data) {

				                $("div.loader").hide();
				                alert('An error occurred.  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
		}

		function getCompIdList(){
			$.ajax({
							async: true
							,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
										method: "getCompIdList" }
							//,dataType: "json"
							,success: function (data) {
							  aData = JSON.parse(data);
							  //console.log(aData);
				              setProdColDefs();
				              var i = 1;
				              aData.forEach(function(item){
				              	if(i == aData.length && <cfoutput>#bEdit#</cfoutput> ==  1){  //Only Bracket 11 (last bracket in list) is editable and PRG must be Editable
				              		columnDefs_Bracket_Products.push({headerName: item.compname, field: 'rate_'+item.compid,  width:50, valueFormatter: currencyFormatter, cellClass: 'number-cell', editable:true, type: 'numericColumn',
												cellStyle: function(params) {
												        if (params.data.override === 1) {
												            //mark cells as red 
												            return {color: 'red'};
												        } else {
												            return null;
												        }
												    }
				              					});
				              	}
				              	else{
				              		columnDefs_Bracket_Products.push({headerName: item.compname, field: 'rate_'+item.compid,  width:50, valueFormatter: currencyFormatter, cellClass: 'number-cell', editable:false, type: 'numericColumn'});
				              	}

				              	i++;
				              });
				   			 if(aData.length){
				   			 	Build_BracketProductsGrid();
				   			  	getProducts();
				   			 }

				            }
				            ,error: function (data) {
				                alert('An error occurred.  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
				});
		}

		function deleteBracketProducts() {
			show_loader('Deleting Products...');
			var selectedData = JSON.stringify(Products_GridOptions.api.getSelectedRows());
			$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									aData: selectedData,
									method: "deleteBracketProducts" }
						,success: function (data) {
			     			getProducts();
			            	$("div.loader").hide();
			            }
			            ,error: function (data) {
			            	$("div.loader").hide();
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
			});
		}

		//function call to recalculate formula when the recalculate formula button has been selected. This will adjust the formula prices when the schedule option has been changed. 
		function recalculateFormula() {
			show_loader('Recalculating Formula...');
			$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "recalculateFormula" }
						,success: function (data) {
			     			getProducts();
			            	$("div.loader").hide();
			            }
			            ,error: function (data) {
			            	$("div.loader").hide();
			                alert('An error occurred.  ' + JSON.stringify(data) );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
			});
			
		}


		window.reloadGrid = function(){
			getCompIdList();
		}

		function currencyFormatter(params) {
			return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: params.data.uom == 'CS' ? <cfoutput>#decimalPrecisionCS#</cfoutput> : <cfoutput>#decimalPrecisionLB#</cfoutput>});
		}

		function showProductSearch()
		{
			var bSelectedAllProducts = false;
			var groupLevel = 0;

			<cfoutput>
				var sURL = "/Common_Files/contracts/product_Select_V1.cfm?Formname=ProdForm&FirstParentID=#GetTemplateInfo.First_parent_ID#&discountype=1&programId=#variables.ContractMainID#&prgID=#variables.ContractMainID#&LoadExistingProductList=1";
			</cfoutput>
			NewWindowTopLeft(sURL, "productWindow", 1000, 700, "yes", "yes")
			return false;
		}

		function setProductsGridHeight(len) {
			if (len > 0) {
				setAutoHeight(Products_GridOptions, "#Products_Grid");
			} else {
				setFixedHeight(Products_GridOptions, "#Products_Grid", "130px");
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

		
		function editFormula(cmId, cpId)
		{

			var selVal = $("#schedule_options").val();
			//if a schedule option has not been selected then display an alert and don't display formula edit
			if(selVal == ""){
				noty( { text: "Please select a Formula Schedule before editing."
			          ,type:'error'
			          ,layout:'center'
					  ,killer: true
					  ,timeout  : 0
			          ,animation: { open: {height: 'toggle'}, close: {height: 'toggle'}, easing: 'swing', speed: 250 }
					  ,timeout: 2000
			        });
				return;
			}
			else{
				openPopup('/Common_Files/contracts/Formula/Formula_Display.cfm?Program_Id=' + cmId + '&contract_products_id=' + cpId, 800, 800);
			}
		}
		//validate a schedule option was selected before leaving the page
		$(document).on("click", "a.tablink_back", function(e) {
    		var selVal = $("#schedule_options").val();
			
  			if(selVal == '') {
    			noty( { text: "Please select a Formula Schedule."
			          ,type:'error'
			          ,layout:'center'
					  ,killer: true
					  ,timeout  : 0
			          ,animation: { open: {height: 'toggle'}, close: {height: 'toggle'}, easing: 'swing', speed: 250 }
					  ,timeout: 2000
			        });
				e.stopPropagation();
				e.preventDefault();
				$(".loader").hide();
				return false;
  			}
		});

	</SCRIPT>

	
</body>
<html>