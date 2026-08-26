<!---
	* ===========================================================================================
	*    @File: billbacks\2020\edit_billback.cfm
	*    @Author: Kal
	*    @Date: January 2020
	*
	* @Remarks: edit billback - dbl clicking a BB from search opens a new tab next to home tab
	*
	* ===========================================================================================
--->
<cfprocessingdirective pageencoding = "utf-8">
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="x-ua-compatible" content="ie=edge">

	<cfsavecontent variable="head_content">
		<cfset local.arrowDown = "/images/arrow-d-blue-12.png" />
		<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />
		<cfset local.viewIcon = "/images/view.gif" />

		<link rel="stylesheet" type="text/css" href="/styles/font-awesome.min.css">
		<link rel="stylesheet" type="text/css" href="/billbacks/2020/shared_styles.css">
		<link rel="stylesheet" type="text/css" href="/styles/css-loader.css">
		<link rel="stylesheet" type="text/css" href="/billbacks/2020/edit_billback.css">
		<link rel="stylesheet" type="text/css" href="/common_files/select2.css">
		<link rel="stylesheet" type="text/css" href="/script/javascript/dhtmlx/windows/codebase/dhtmlxwindows.css">
		<script src="/script/javascript/dhtmlx/windows/codebase/dhtmlxwindows.js"></script>
		<cfinclude template="/common_files/menu.cfm">
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
		<script type="text/javascript" language="JavaScript">
			var bb = {};
			let objLock = {};
			let bEditable = false;
		</script>
</head>

<body style="margin-top:0;">
	<!------------- variable, flags and formatters ------------->
	<cfset local.fmt_4_decimal = ",_.____" />			<!--- 4 decimal places --->
	<cfset local.fmt_2_decimal = ",_.__" />				<!--- 2 decimal places --->
	<cfset local.fmt_no_decimal = ",__" />				<!--- no decimal places --->
	<cfset local.fmt_date_mmddyyyy = "mm/dd/yyyy" />	<!--- mm/dd/yyyy --->
	<cfset local.fmt_date_mmddyy = "short" />			<!--- mm/dd/yy --->

	<cfset local.view_program_volume_uom = application.util.query.get_setting("view_program_volume_uom", 0) />
	<cfset local.bEditScreenEnabled = 1 />

	<!--- bbIdInt default; if none passed create a new blank billback struck --->
	<cfparam name="url.billback_Id" type="integer" default="0" />
	<!--- <cfset url.billback_Id = 1167465 /> --->

	<cfset local.bbIdInt = url.billback_Id />

	<cfset billbackManager           = CreateObject("component", "mvc.Models.Billback.BillbackManager") />
	<cfset billbackLoadManager       = CreateObject("component", "mvc.Models.Billback.BillbackLoadManager") />
	<cfset billbackEditManager       = CreateObject("component", "mvc.Models.Billback.BillbackEditManager") />
	<cfset billbackEditSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />
	<cfset oProfiles                 = CreateObject("component","components.settings.profiles.profile") />

	<!--- Object needs for BB, these will be converted to JS --->
	<cfset pgmComponent= CreateObject("component", "mvc.Models.Program.Component.vos.Component") />
	<cfset bbComponent= CreateObject("component", "mvc.Models.Billback.vos.BBComponent") />
	<cfset bbPDIR= CreateObject("component", "mvc.Models.Billback.vos.BBPrgDistItemRate") />

	<cfset analysts        = billbackLoadManager.getAnalysts() >
	<cfset closingMethdods = billbackLoadManager.getAllClosingMethods() >
	<cfset uoms            = billbackManager.getUomDp() >
	<cfset profileSettings = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID)>

	<!--- form --->
	<div>
		<!--- Collapse header --->
		<cfoutput>
		<button id="searchSectionBtn" class="sectionHeader">
			<img src="#local.arrowDown#" alt="expand/collapse" style="padding:1px 3px 0 0"/>
			Billback
				Item results: &nbsp; <span id="record_count"> </span> <!--- number of item rows --->
				CTM ID ##: <span id="record_count"> </span> <!--- bb Code --->
				<span id="record_count"> </span> <!--- status --->
				<span id="record_count"> </span> <!--- bb type --->
				Created by: <span id="record_count"> </span> <!--- creator --->
		</button>

		<div id="searchSection">
			<!------------------------------->
			<!--- TOP collapsible section --->
			<!------------------------------->
			<div class="menuArea">
				<div>	<!--- toggle button --->
					<button type="button" id="editToggleBtn" title="" class="button recommended">read-only</button>
					<nav class="nav"style="display:inline-block; margin-top: 2px;">
						<!--- Menu --->
						<cfinclude template="/billbacks/2020/edit_billback_menu.cfm">
					</nav>
				</div>
				<div style="margin-right:20px;">	<!--- right side --->
					Analyst:
					<select name="analyst" id="analyst" style="margin-top:2px; width:200px;" class="editable">
						<option value="none" selected disabled hidden> select an analyst</option>
						<cfloop array="#analysts#" item="analyst">
							<option value="#analyst.idInt#"  #analyst.fullName eq 'Default Analyst'?'selected':''# > #analyst.fullName# </option>
						</cfloop>
					</select>
				</div>
			</div>

			<div id="searchFormArea">
				<!--- FORM GOES HERE --->
				<form style="width:100%">
					<!------------- bb header form ------------->
					<div class="hdr-container">

						<div class="div1">
							<label>Invoice ##:</label>
							<input name="bbNumber" id="bbNumber" type="text" class="editable"/>
						</div>

						<div class="div2">
							<label>Reference ##:</label>
							<input name="referenceNumber" id="referenceNumber" type="text" class="editable"/>
						</div>

						<div class="div3">
							<label>Closing Method:</label>
							<select name="closingMethod" id="closingMethod" class="editable">
								<cfloop array="#closingMethdods#" index="cm">
									<option value="#cm.id#" #cm.bDefault?'selected':''# >#cm.description#</option>
								</cfloop>
							</select>
						</div>

						<div class="div4">
							<label>Invoice Date:</label>
							<input name="bbDate" id="bbDate" type="text" class="date editable"/>
						</div>

						<div class="div5">
							<label>Delivery Start:</label>
							<input name="startDate" id="startDate" type="text" class="date editable"/>
						</div>

						<div class="div6">
							<label>Delivery End:</label>
							<input name="endDate" id="endDate" type="text" class="date editable"/>
						</div>

						<div class="div7">
							<label>Title:</label>
							<input name="title" id="title" type="text" class="editable"/>
						</div>

						<div class="div8">
							<label>Payee ##:</label>	<!--- bsa vendor --->
							<a href="##" onclick="popupVend()" id="idVendorPopup" class="editable">
								<i class="fa fa-search btn-icon" style="margin-left:5px;"></i>
							</a>
							<input name="vendorId" id="vendorId" type="text" class="editable"/>
							<input name="oldVendorId" id="oldVendorId" type="hidden" />
						</div>

						<div class="div9">
							<label>Account ##:</label>	<!--- bsa payee --->
							<input name="oldPayeeId" id="oldPayeeId" type="hidden" />
							<select name="dpdPayee" id="dpdPayee" class="editable">
								<option value="none" selected disabled hidden> </option>
								<!--- payee list for vendor --->
							</select>
						</div>

						<div class="div10">
							<label>Received Date:</label>
							<input name="receivedDate" id="receivedDate"  type="text" class="date editable"/>
						</div>

						<div class="div11">
							<label>Post Date:</label>
							<input name="postDate" id="postDate"  type="text" class="date editable"/>
						</div>

						<div class="div12">
							<label>Summary </label>
							<label>Claimed </label>
							<label>Itemized </label>
							<label>Variation </label>
						</div>

						<div class="div13">
							<label>$</label>
							<input name="claimAmount" id="claimAmount" type="text" class="editable"/>
							<input name="expAmount" id="expAmount" type="text" class="editable"/>
							<input name="variedAmount" id="variedAmount" type="text" class="editable"/>
						</div>

						<div class="div14">
							<cfif local.view_program_volume_uom  eq 1 or local.view_program_volume_uom eq 3 >
								<label>Cs</label>
								<input name="claimCs" id="claimCs" type="text" class="editable"/>
								<input name="expCs" id="expCs" type="text" class="editable"/>
								<input name="variedCs" id="variedCs" type="text" class="editable"/>
							</cfif>
						</div>

						<div class="div14-1">
							<cfif local.view_program_volume_uom  eq 2 or local.view_program_volume_uom eq 3 >
								<label>Lb</label>
								<input name="claimLb" id="claimLb" type="text" class="editable"/>
								<input name="expLb" id="expLb" type="text" class="editable"/>
								<input name="variedLb" id="variedLb" type="text" class="editable"/>
							</cfif>
						</div>

						<!--- bsa vendor --->
						<div class="div15">
							<label> <!--- selectedVendor ---> </label>
						</div>

						<!--- bsa payee --->
						<div class="div16">
							<label> <!--- selectedPayee ---> </label>
						</div>

						<div class="div17">
							<label>Notes:</label>
							<textarea id="notes" class="editable"></textarea>
						</div>

						<!------------------------------------------------->
						<!------------- program & distributor ------------->
						<!------------------------------------------------->
						<div class="div18">
							<!------------- program ------------->
							<div class="div19">
								<label>Program ##:</label>
								<a href="##" onclick="popupProgram();" id="idProgramSearchPopup" class="editable">
									<i class="fa fa-search btn-icon" style="margin-left:5px;"></i>
								</a>
								<!--- programlist for payee --->
								<select name="dpdProgram" id="dpdProgram" class="select2 editable">
								</select>
							</div>

							<div class="div20">
								<label> <!--- selectedProgram ---> </label>
							</div>

							<!------------- distributor ------------->
							<div class="div21">
								<label>Distributor ##:</label>
								<a href="##" onclick="popupCust()" id="idDistributorPopup" class="editable">
									<i class="fa fa-search btn-icon" style="margin-left:5px;"></i>
								</a>
								<!--- distributors from program --->
								<select name="dpdDistributor" id="dpdDistributor" class="select2 editable">
								</select>
							</div>

							<div class="div22">
								<label> <!--- selectedDistributor ---> </label>
							</div>
						</div>
					</div>  <!--- .hdr-container --->


					<!-------------------------------------->
					<!------------- components ------------->
					<!-------------------------------------->
					<div class="details-card">
						<div class="card-header">Add / Remove Components</div>
						<div class="card-main comp-container"> <!--- arrComponent ---> </div>
					</div>
				</form>
			</div> <!--- searchFormArea --->

		</div> <!--- searchSection --->
		</cfoutput>
	</div>


	<!------------- grid ------------->
	<div id="bb_edit_grid" style="height:200px;" class="ag-theme-balham">
		<!--- grid goes here --->
	</div>


	<!--  buttons at the bottom under the grid  -->
	<div class="bottom-row">
		<div>
			<button type="button" id="btnProdFromProg" title="Get all Products from the Program" class="button editable">Products from Program</button>
			<button type="button" id="btnProdRatesFromProg" title="Get Rates from the Program" class="button editable">Program Rates</button>
			<button type="button" id="btnProdSearch" title="Search all Products" class="button editable">Search Products</button>
			<!--- <button type="button" title="Update to latest Program version" class="button">Update Program Vsn</button> --->
		</div>
		<div>
			<button type="button" id="btnSaveBB" title="Save the Billback" class="button editable recommended">Save</button>
			<button type="button" id="btnContinue" class="button editable"></button>
		</div>
	</div>

	<!--- popup forms --->
	<form name='saveCust' id='saveCust' action='javascript:saveCust();'>
		<input type="hidden" id="SelectSingleSearchResultOnly" value="1"/>
		<INPUT TYPE="Hidden" ID="Customer_ID" NAME="Customer_ID" VALUE="">
		<INPUT TYPE="Hidden" ID="shipTo" NAME="shipTo" VALUE="">
		<INPUT TYPE="Hidden" ID="parent_ShipTo" NAME="parent_ShipTo" VALUE="">
	</form>

	<form name='saveVend' id='saveVend' action='javascript:saveVend();'>
		<input type="hidden" name="Vendor_ID" id="Vendor_ID"  value="" >
		<input type="hidden" name="VendName" id="VendName"  value="" >
	</form>

	<form name='saveProduct' id='saveProduct' action='javascript:saveProduct();'>
		<input type="hidden" name="Product_List" id="Product_List"  value="" />
		<input type="hidden" name="ExistingProductList" id="ExistingProductList"  value="" />
	</form>

	<form name='saveProgram' id='saveProgram' action='javascript:saveProgram();'>
		<input type="hidden" name="Program_List" id="Program_List"  value="" />
		<input type="hidden" name="existingProgramList" id="existingProgramList"  value="" />
		<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms"  value="1" />
		<input type="hidden" name="FilterType" id="FilterType"  value="" />
		<input type="hidden" name="FilterDataList" id="FilterDataList"  value="" />
	</form>


	<cfscript>
		request.ag_grid_version = 23;
	</cfscript>
	<cfset jQueryUI.widgets = "datepicker">
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
										"/common_files/jQueryUI.cfm",
										"/common_Files/ag-Grid.cfm",
										"/script/javascript/moment.min.js",
										"/script/javascript/numeral.min.js",
										"/script/javascript/string_functions.min.js",
										"/common_files/noty.cfm",
										"/common_files/dhx_message.cfm",
										"/script/javascript/select2.min.js"
										] )#>

	<style>
		<!--- override the ag-grid styles included above --->
			.ag-header-cell-label .ag-header-cell-text {
				white-space: pre;
			}
			.ag-theme-balham {
				font-size: 11px;
			}
			.ag-header {
				font-size: 11px !important;
				text-align: center;
			}
			.ag-theme-balham .ag-header-cell-label {
				width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
			}
			.ag-theme-balham .ag-row-selected {
				border-top-color: #b5b5b5; /* don't hide lines when selected */
			}
			.ag-theme-balham .ag-selection-checkbox span {
				left: 1px; /* center the checkbox */
			}
			/* Make the resize lines bigger */
			.ag-header-cell-resize {
				content: '';
				position: absolute;
				top: 0;
				right: 0 !important;
				margin: 0 !important;
				width: 4px !important;			/* so make it wider, change the background color to match the hdr, and add a thin border */
				background: #ffce84;
				border-right: 1px solid #9b9b9c;
				z-index: 0;
			}

			.ag-theme-balham .ag-header-group-text,
			.ag-header-cell-text {
				margin: 0px auto 0px auto;		/* Center the header text */
			}
	</style>

	<!--- Event Handlers --->
	<cfinclude template="/billbacks/2020/edit_billback_events.cfm">

	<script>
		const bbReverse = <cfoutput>#profileSettings.BB_Reverse#</cfoutput>;
		const bbDateChangeAllowed = <cfoutput>#profileSettings.Change_BB_Start_End_Date#</cfoutput>;

		'use strict';
		function deleteRow(params) {
			let arrRow = [];
			arrRow.push(params.node.data);
			let pos = bb.bbprgdistitemrate.findIndex( item =>
				item.bbprodrate.itemnumber == arrRow[0].bbprodrate.itemnumber
				&& item.bbprogram.programid == arrRow[0].bbprogram.programid );
			bb.bbprgdistitemrate.splice(pos, 1);
			let res = glob.my_grid.api.applyTransaction({ remove: arrRow });
			update_summary();
		}


		function deleteSelectedRows() {
			let selectedData = glob.my_grid.api.getSelectedRows();
			selectedData.forEach( element => {
					let pos = bb.bbprgdistitemrate.findIndex( item =>
					item.bbprodrate.itemnumber == element.bbprodrate.itemnumber
					&& item.bbprogram.programid == element.bbprogram.programid );
				bb.bbprgdistitemrate.splice(pos, 1);
			});
			let res = glob.my_grid.api.applyTransaction({ remove: selectedData });
			update_summary();
		}

		function createNewRowData() {
			let bbPrgItem = JSON.parse(JSON.stringify(oBBPDIR));
			let discountType = 2; // default discount type = rebate
			let selectedProgramUOM = {...selectedProgram.components[0].uom[0]};

			//if the uom from program is NOT CS or LB then we have to convert the UOM to CS
			if (!(selectedProgramUOM.uomid == 1 || selectedProgramUOM.uomid == 2)){
				selectedProgramUOM.uomid = 1;
				selectedProgramUOM.abbreviation = "CS";
				selectedProgramUOM.description = "Cases";
			}

			let arrSelected = arrComponent.filter(bbComp => {
					return (bbComp.isselected == 1 && selectedProgram.number == bbComp.programnumber && bbComp.componenttypeid != 3)
			});

			let arrAll = arrComponent.filter(bbComp => { return (bbComp.componenttypeid != 3) });

			if(arrSelected.length){
				discountType = arrSelected[0].componenttypeid;
			} else if(arrAll.length){
				discountType = arrAll[0].componenttypeid;
			}

			// bbprogram
			bbPrgItem.bbprogram.programid = selectedProgram.programid;
			bbPrgItem.bbprogram.number = selectedProgram.number;
			bbPrgItem.bbprogram.title = selectedProgram.title;
			bbPrgItem.bbprogram.startdate	= new Date(selectedProgram.startdate);
			bbPrgItem.bbprogram.enddate		= new Date(selectedProgram.enddate);
			bbPrgItem.bbprogram.bislatestversion = selectedProgram.bislatestversion;
			bbPrgItem.bbprogram.effectiveenddate = selectedProgram.effectiveenddate;
			bbPrgItem.bbprogram.effectivestartdate = selectedProgram.effectivestartdate;

			// distributor
			bbPrgItem.bbdistributor = selectedDistributor;

			// item
			bbPrgItem.bbprodrate.amount = 0;
			bbPrgItem.bbprodrate.bnotonprogram = 0;
			bbPrgItem.bbprodrate.description = "";
			bbPrgItem.bbprodrate.discounttype = discountType; //default to rebate
			bbPrgItem.bbprodrate.isselected = 0;
			bbPrgItem.bbprodrate.itemguid = "";
			bbPrgItem.bbprodrate.itemnumber = "0";
			bbPrgItem.bbprodrate.netweight = 0;
			bbPrgItem.bbprodrate.prograte = 0;
			bbPrgItem.bbprodrate.rate = 0;
			bbPrgItem.bbprodrate.uom = selectedProgramUOM; //shallow copy
			bbPrgItem.bbprodrate.volume = 0;

			bbPrgItem.message = "";
			bbPrgItem.bfirsttime = "0";

			return bbPrgItem;
		}

		// + Add a new row to the grid
		function addRow() {
			var newRowArray = [];
			newRow = createNewRowData();
			newRowArray.push(newRow);
			bb.bbprgdistitemrate.push(newRow); // add to bb object
			var res = glob.my_grid.api.applyTransaction({ add: newRowArray });
		}


		<!-------------  Constants ------------->
		const MASS_APPLY = true;
		<!------------- glob = global variables ------------->
		let glob = { };


		<!------------- wait for the document to be loaded, otherwise ag-Grid will not find the div ------------->
		document.addEventListener("DOMContentLoaded", function () {
			console.clear();
			$('#dpdProgram').select2();
			$('#dpdDistributor').select2();
			getAllProducts();
			get_grid_content();
			load_billback(<cfoutput>#local.bbIdInt#</cfoutput>);
			loadBBEditEventListeners();   // call to load all event listeners
		});


		<!------------- ag-grid visible starting column, JSON hidden columns come back in the leading ------------- --->
		const config = { starting_column: 1,
						 ui_name: "ag_bb_edit_grid",
						 grid_id: "#bb_edit_grid"
						};


		<!------------- adjust grid height ------------->
		<!--- this is already done automatically (ag-grid.js) on window resize, but this is needed for manually resizing --->
		function adjust_grid_height() {
			let grid_element = $("div" + config.grid_id);
			if (grid_element) {
				set_grid_full_height( config.grid_id, glob.my_grid.blackSmith.height_offset
													? glob.my_grid.blackSmith.height_offset
													: -8 );
			}
		}


		<!------------- define the grid columns ------------->
		var columnDefsBBEditGrid = [
			{width:24, editable:false, checkboxSelection:true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, filter:false, resizable:false, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true},

			{width:40, filter:false, editable:false,
				headerComponentParams: {
					// This is the (Delete row(s) / Add row) column
					template: customize_column_header(
					'<div><a id="colDelSel" href="javascript:deleteSelectedRows();">' +
						'<img alt="delete rows" title="delete selected rows" src="/Images/delete2.png" style="padding-bottom:3px; padding-top:2px;">'+
					'</a></div>',

					'<div><a id="colAdd" href="javascript:addRow();">' +
						'<img alt="add row" title="insert new row" src="/Images/add2.png" style="padding-top:2px;">'+
					'</a></div>',
					true) },
				cellRenderer: function(params) {
					let delCel =
						'<div style="margin-left:9px; margin-top:3px;">' +
							// '<a id="colDel" href="#">' +
							'<img alt="delete row" title="delete this row" src="/Images/delete2.png">'+
						'</div>';
					return delCel;
				},
				onCellClicked: function(params) { deleteRow(params); }
			},

			{headerName: "Program", field: 'bbprogram.number', editable:false, width:150,
				headerComponentParams: {
					template: customize_column_header(''
					,'<div class="mass_apply"><input class="mass mass_apply" name="bbprogram" placeholder="mass apply" tabindex="-1" title="Enter a Program number to mass apply to selected records" type=text>'
						+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="bbprogram" title="Click to apply to selected rows"></i></span>'
						+ '</div>'
					,MASS_APPLY) }
				,sortable:true
			},

			{headerName: "Assoc. Distributor", field: 'bbdistributor.shipto', editable:false, width:150,
				headerComponentParams: {
					template: customize_column_header(''
					,'<div class="mass_apply"><input class="mass mass_apply" name="bbdistributor" placeholder="mass apply" tabindex="-1" title="Enter an Assoc. Distributor to mass apply to selected records" type=text>'
						+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="bbdistributor" title="Click to apply to selected rows"></i></span>'
						+ '</div>'
					,MASS_APPLY) }
				,sortable:true
			},

			{headerName: "Item", field: 'bbprodrate.itemnumber', width:100
				,editable:function(params) { return bEditable; }
				// Validate first, if not good, retain the old value
				,valueSetter: function(params) {
					// If a new valid Item # is entered, preserve it
					if (params.newValue.length && (params.oldValue !== params.newValue)) {
						if (validateItem(params)) {
							params.data.bbprodrate.itemnumber = params.newValue;
							return true;
						}
					}
					return false;
				}
				,onCellValueChanged: function(params) { if(params.oldValue != params.newValue) { updateItem(params) } }
			},

			{headerName: "Item Description", field: 'bbprodrate.description', editable:false, width:300},
			{headerName: "Volume",  field:'bbprodrate.volume', filter:false, width:80
				,type:'numericColumn'
				,editable:function(params) { return bEditable; }
				//,cellEditor:NumericCellEditor
				,cellEditorParams: { step: "1" }
				// Since it is editable, we can't just use valueFormatter, instead use getter and setter
				// convert # to properly formatted string for display
				,valueGetter: function(params) { return numberFormat(parseFloat(params.data.bbprodrate.volume),fmt_2_decimal); }
				,valueSetter: function(params) {
					// If we have a proper value, convert the string to # for storage
					if (params.newValue.length && (params.oldValue !== params.newValue)) {
						params.data.bbprodrate.volume = parseFloat(params.newValue);
						updateVolume(params);
						return true;
					}
					return false;
				}
			},

			{headerName: "UOM", field: 'bbprodrate.uom.abbreviation', filter:false, width:60
				,editable:function(params) { return bEditable; }
				,cellStyle: {'text-align':'center'}
				,cellEditor: SelectCellEditor
				,cellEditorParams: { values: getUOMAbbreviationList() }
				,onCellValueChanged: function(params) { updateUOM (params) }
			},

			{headerName: "Discount\n Rate",  field: 'bbprodrate.rate', filter:false, width:80
				,type:'numericColumn'
				,editable:function(params) { return bEditable; }
				//,cellEditor:NumericCellEditor
				,cellEditorParams: {step: "0.01" }	// valid decimal places for input stepper
				,valueFormatter: currencyFormatter
				// We want to display the # as a string with with 2 decimal places.
				// Since it is editable, we can't just use valueFormatter, instead use getter and setter
				,valueGetter: function(params) { return numberFormat(parseFloat(params.data.bbprodrate.rate),fmt_2_decimal); }
				,valueSetter: function(params) {
					// If we have a proper value, convert the string to # for storage
					if (params.newValue.length && (params.oldValue !== params.newValue)) {
						params.data.bbprodrate.rate = parseFloat(params.newValue);
						updateRate(params);	// D101200 Update here (synchronous) so that it's complete before user tabs to next cell to edit
						return true;
					}
					return false;
				}
			},

			{headerName: "Discount\n $ Amt",  field: 'bbprodrate.amount', filter:false, width:80
				,type:'numericColumn'
				,editable:function(params) { return bEditable; }
				//,cellEditor:NumericCellEditor
				,cellEditorParams: { step: "0.01" } // valid decimal places for input stepper
				,valueFormatter: currencyFormatter
				// We want to display the # as a string with with 2 decimal places.
				// Since it is editable, we can't just use valueFormatter, instead use getter and setter
				,valueGetter: function(params) { return numberFormat(parseFloat(params.data.bbprodrate.amount),fmt_2_decimal) }
				,valueSetter: function(params) {
					// If we have a proper value, convert the string to # for storage
					if (params.newValue.length && (params.oldValue !== params.newValue)) {
						params.data.bbprodrate.amount = parseFloat(params.newValue);
						updateAmt(params);
						return true;
					}
					return false;
				}
			},

			{headerName: "Message",  field: 'message', filter:false, editable:false, width:150, cellStyle: {color: 'red'}}
		];


		<!------------- define ag-grid configuration ------------->
		glob.my_grid = {
			blackSmith: { fullHeight: true, height_offset: -75 }
			,defaultColDef:	{
					editable:                      bEditable
					,floatingFilterComponentParams: { suppressFilterButton: true }
					,floatingFilter: 				true
					,singleClickEdit:				true
					,suppressMenu:                  true
					,unSortIcon:                    false
					,sortable:                      true
					,resizable:                     true
					,filter:                        'agTextColumnFilter'
			}
			,columnDefs: columnDefsBBEditGrid
			,rowModelType: "clientSide"
			,rowSelection: "multiple"
			,suppressContextMenu: true
			,enableBrowserTooltips: true
			,enterMovesDown: false
			,enterMovesDownAfterEdit: false
			,onGridReady: function(p) { mass_apply_event() }
			// ,onBodyScroll: function(p) { mass_apply_event() }
			// ,isExternalFilterPresent: isExternalFilterPresent
			// ,doesExternalFilterPass: showFilteredRecords
			// ,getRowNodeId: function(data) { return data.itemGuid }
			// ,statusBar: footerbar("filtered_and_total")
			,onCellFocused: function(p) { addCellBlurListener(p); }
		};


		// Add a "blur" handler so when we leave the cell we can check if we need to create a new row.
		addCellBlurListener = (params) => {
			// console.log("Adding listener");
			const target = document.activeElement;
			if (target) {
				target.addEventListener('blur', onCellBlur);
				target.myParams = params;
			}
		};

		removeCellBlurListener = () => {
			// console.log("Removing listener");
			const target = document.activeElement;
			if (target) {
				target.removeEventListener('blur', this.onCellBlur);
			}
		};

		onCellBlur = (evt) => {
			// If editing, if leaving the last row and column, add a new row below it

			// console.log("In onCellBlur");
			// console.log("Editable? "+(bEditable ? "Yes" : "No"));
			// console.log("Last row? Should be: "+(bb.bbprgdistitemrate.length-1)+"  and is: "+evt.currentTarget.myParams.rowIndex);
			// console.log("Column name is: "+evt.currentTarget.myParams.column.colId);

			if (bEditable &&
				evt.currentTarget.myParams.rowIndex == (bb.bbprgdistitemrate.length-1) &&
				// evt.currentTarget.myParams.column.colId == 'message') {
				// When in edit mode, tab goes only to editable columns
				evt.currentTarget.myParams.column.colId == 'bbprodrate.amount') {
					// console.log("DING DING DING!!! "+evt.type);
					addRow();
			}

			removeCellBlurListener();
		};

		<!------------- get grid content ------------->
		function get_grid_content() {
			ag_grid_default( glob.my_grid );
			init_ag_grid( glob.my_grid, config.grid_id, false );
			glob.my_grid.api.setHeaderHeight(35);
		}

		function mass_apply_event() {
			$("input.mass_apply").click(function(e){
				e.stopPropagation();	// stop the sort etc
			});

			let arrErrors 			= [];
			<!--- ~~~~~~~~ mass apply logic ~~~~~~~~ --->
			$("i.mass_apply").click(function(e){
				e.stopPropagation();

				let prgComp 			= new Object();
				let newDist 			= new Object();
				let bCompSelectValid	= false;
				let bPrgSelectValid		= false;
				let bDistSelectValid	= false;
				let bDistUpdated		= false;

				let icon_name 			= $(this).attr("name");
				let mass_apply_val 		= $("input[name=" + icon_name + "]").val();

				//verify if user entered value
				if(mass_apply_val.length == 0){
					pushError('mass apply value is required');
					showErrors();
					return;
				}

				//verify mass apply on program
				if(icon_name == 'bbprogram'){

					arrComponent.forEach(comp => {
						if (comp.programnumber == mass_apply_val && comp.isselected == 1) {
							prgComp = comp;
							bCompSelectValid = true;
						}
					});

					<!---  apply to filtered (visible) rows only  --->
					if(bCompSelectValid == true){
						glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
							<!--- ~~ apply to selected rows only ~~~ --->
							if (rowNode.selected) {
								let bbPrgItem = JSON.parse(JSON.stringify(oBBPDIR));
								bbPrgItem.bbdistributor = rowNode.data.bbdistributor;
								bbPrgItem.bbprodrate = rowNode.data.bbprodrate;
								bbPrgItem.bbprodrate.discounttype = prgComp.componenttypeid;
								// program
								bbPrgItem.bbprogram.programid = prgComp.programid;
								bbPrgItem.bbprogram.number = prgComp.programnumber;
								bbPrgItem.bbprogram.title = prgComp.title;
								bbPrgItem.bbprogram.startdate = new Date(prgComp.startdate);
								bbPrgItem.bbprogram.enddate = new Date(prgComp.enddate);

								//update row data and data in bb.bbprgdistitemrate
								//bb.bbprgdistitemrate has to be updated or mass apply changes won't stick
								rowNode.setData(bbPrgItem);
								bb.bbprgdistitemrate[rowNode.id] = bbPrgItem;
								bPrgSelectValid = true;
							}
						});
					}

					// errors
					if(!bCompSelectValid){
						pushError(`No valid program/component found for ${mass_apply_val}.`);
					}
					if(bCompSelectValid && !bPrgSelectValid){
						pushError(`No program selected to mass apply.`);
					}
				} // bbprogram

				//verify mass apply on distributor
				if(icon_name == 'bbdistributor'){

					arrDistributor.forEach(dist => {
						if (dist.shipto == mass_apply_val) {
							newDist = dist;
							bDistSelectValid = true;
						}
					});
					
					// D115738 : Dist not on selected program. Pick Dist from a program on BB
					if(!bDistSelectValid){
						// get dist from all rows on bb 
						bb.bbprgdistitemrate.some( bbPDIR => {
							if (bbPDIR.bbdistributor.shipTo == mass_apply_val) {
								newDist = bbPDIR.bbdistributor;
								bDistSelectValid = true;							
							}
						});
					}

					<!---  apply to filtered (visible) rows only  --->
					if(bDistSelectValid == true){
						glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
							<!--- ~~ apply to selected rows only ~~~ --->
							if (rowNode.selected) {
								let bbPrgItem = JSON.parse(JSON.stringify(oBBPDIR));
								bbPrgItem.bbdistributor = newDist;
								bbPrgItem.bbprodrate = rowNode.data.bbprodrate;
								bbPrgItem.bbprogram = rowNode.data.bbprogram;

								//update row data and data in bb.bbprgdistitemrate
								//bb.bbprgdistitemrate has to be updated or mass apply changes won't stick
								rowNode.setData(bbPrgItem);
								bb.bbprgdistitemrate[rowNode.id] = bbPrgItem;
								bDistUpdated = true;
							}
						});
					}

					// errors
					if(!bDistSelectValid){
						pushError(`No valid distributor found for ${mass_apply_val}.`);
					}
					if(bDistSelectValid && !bDistUpdated){
						pushError(`No distrubutor selected to mass apply.`);
					}

				} // bbdistributor

				showErrors();
			}); // mass_apply click handler

			function showErrors() {
				// display errors
				if (arrErrors.length) {
					arrErrors.forEach(sErrorMsg => {
						noty({
							text: sErrorMsg,
							layout: "center", type: "information", timeout: 5000, killer: true,
							animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
						});
					});
					arrErrors.length = 0;
				}
			}


			function pushError(sErrorMsg) {
				bValid = false;
				arrErrors.push(sErrorMsg);
			}
		}  // mass_apply_event

		//Lock/unLock Button------------------------
		$("#editToggleBtn").click(function() {
			lockUnlockBB();
		});

		function onWindowClose(){
			if(objLock.blocked && objLock.userid == <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>){
					lockUnlockBB(false);
			}
		}

		function lockUnlockBB(isAsync=true){
			console.log('LOCKUNLOCK-------------------------------------');
			let lockUnlock =  !(objLock.blocked || 0);
			show_loader('Loading Data...');
			$.ajax({
				async: isAsync
				,dataType: 'json'
				,data: { 	billbackIDInt : bb.bbheader.billbackidint,
							userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>,
							lockUnlock: lockUnlock,
							toggleBB: true,
							unlockExistingLockedByUser: false,
							bbClose : false,
							method: "lockUnlockBBJSON" }
				//,dataType: "json"
				,success: function (data) {
					$("div.loader").hide();
					objLock = data;
					if(data.objidlocked != '' && data.objidlocked != data.objid){
						alert("Please unlock this billback that is locked by you: (" + data.objidlockeddesc + ") .");
					}
					getLockUnlockBB();

				}
				,error: function (data) {
					$("div.loader").hide();
					alert('An error occurred.  ' + data.toString() );
				}
				,type: "post"
				,url: "/mvc/Models/Billback/BillbackManager.cfc"
			});
		}


		function getLockUnlockBB(){
			if( !(Number.isInteger(bb.bbheader.billbackidint) && (bb.bbheader.billbackidint > 0) ) ) {
				$("#editToggleBtn").text('edit');
				bEditable = true;
				return;
			}

			bEditable = false;

			$( ".editable" ).prop("disabled", true);

			$( ".button" ).off( "click" );

			$('.editableLink').click(function(e) {
				e.preventDefault();
			});
			$( ".editableLink" ).addClass("inactiveLink");

			$('.customLink').click(function(e) {
				e.preventDefault();
			});
			$( ".customLink" ).addClass("inactiveLink");

			show_loader('Loading Data...');
			$.ajax({
					async: true
					,dataType: 'json'
					,data: { 	billbackIDInt : bb.bbheader.billbackidint,
								unlockExistingLockedByUser:  false,
								method: "getLockUnlockBBJSON" }
					//,dataType: "json"
					,success: function (data) {
						$("div.loader").hide();
						objLock = data;
						$("#editToggleBtn").addClass("recommended");
						//Not Locked
						if(data.blocked === false){
							//console.log('not locked');
							readOnlyMode();
							$("#editToggleBtn").css("width", "100px");
							$("#editToggleBtn").text('read-only');
							$("#editToggleBtn").click(function() {
								lockUnlockBB();
							});

						}
						//Locked by ME
						else if(data.objidlocked === data.objid && data.userlocked.id === <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput> ){
							editMode();
						}
						//Locked by Someone Else
						else{
							readOnlyMode();
							$("#editToggleBtn").css("width", "150px");
							$("#editToggleBtn").text('locked by: ' + data.userlocked.fullname);
							$("#editToggleBtn").click(function(e) {
								getLockUnlockBB();
							});
						}
					}
					,error: function (data) {
						$("div.loader").hide();
						alert('An error occurred.  ' + data.toString() );
					}
					,type: "post"
					,url: "/mvc/Models/Billback/BillbackManager.cfc"
				});
		}

		function editMode(){

			if(bb.bbheader.status.id < 3){
				bEditable = true;
				// Form Fields------------------------
				$(".editable").prop("readonly", false);
				$(".mass_apply" ).prop("readonly", false);
				//All Editable Buttons	----------------------
				$(".editable").prop('disabled', false);
			}

			$(".editableLink").removeClass("inactiveLink");
			$(".editableLink").off('click');

			//enable deviations button to allow deviations to be viewed after billback is paid
			$('#btnContinue').prop("disabled", false);
			//Lock Buttons------------------------
			$("#editToggleBtn").click(function() {
				lockUnlockBB();
			});
			$("#editToggleBtn").css("width", "100px");
			$("#editToggleBtn").text('edit');


			// EXTRA CONDITIONS BESIDES LOCKED **************************************//
			// reverse 	reverseBillbackLink	this.billback.bbHeader.status.id == 5 && oSettings.user.stProfileSettings.BB_REVERSE == 1  && this.billback.bbHeader.bbSettlement.bIsReversible
			if(bb.bbheader.status.id == 5 && bb.bbheader.bbsettlement.bisreversible == 1 && bbReverse == 1){
				$("#reverseBillbackLink").off('click');
				$("#reverseBillbackLink").removeClass("inactiveLink");
			}

			//adjust 		adjustBillbackLink			billback.bbHeader.status.id == 5
			if(bb.bbheader.status.id == 5){
				$("#adjustBillbackLink").off('click');
				$("#adjustBillbackLink").removeClass("inactiveLink");
			}

			//reset 		resetBillbackLink			billback.bbHeader.resetAllowed
			if(bb.bbheader.resetallowed == 1){
				$("#resetBillbackLink").off('click');
				$("#resetBillbackLink").removeClass("inactiveLink");
			}

			//delete		deleteBillbackLink			billback.bbHeader.deleteAllowed
			if(bb.bbheader.deleteallowed == 1){
				$("#deleteBillbackLink").off('click');
				$("#deleteBillbackLink").removeClass("inactiveLink");
			}

			//discrepancy	discrepancyBillbackLink		bbHeader.status.id != 1
			if(bb.bbheader.status.id != 1){
				$("#discrepancyBillbackLink").off('click');
				$("#discrepancyBillbackLink").removeClass("inactiveLink");
			}

			//reinterface	reinterfaceBillbackLink		billback.bbHeader.notAcknowledged
			if(bb.bbheader.notacknowledged == 1){
				$("#reinterfaceBillbackLink").off('click');
				$("#reinterfaceBillbackLink").removeClass("inactiveLink");
			}

			// profile setting allowed approved bb date change
			if(bb.bbheader.status.id >= 3 && bbDateChangeAllowed){
				$("#btnSaveBB").prop("readonly", false).prop("disabled", false);
				$("#startDate").prop("readonly", false).prop("disabled", false);
				$("#endDate").prop("readonly", false).prop("disabled", false);
			}

			//.editable, Settlement, 										billback.bbHeader.status.id < 3
			// reassign		reassignBillbackLink		billback.bbHeader.reassignAllowed

		}

		function readOnlyMode(){
			// Form Field
			$( ".editable" ).off('change');
			$( ".editable" ).prop("readonly", true);
			$( ".mass_apply" ).prop("readonly", true);
			//discrepancy only if bbHeader.status.id != 1
			if(bb.bbheader.status.id != 1){
				$("#discrepancyBillbackLink").off('click');
				$("#discrepancyBillbackLink").removeClass("inactiveLink");
			}
		}

		// TBD - THESE NEED TO BE DONE!!
		function validateItem(params) {
			// return true if the Item # is valid
			return true;
		}

		function updateItem(params) {
			bValidItem = false;
			bValidProgramItem = false;

			//verify prod is valid
			arrAllProducts.some( product => {
				if (params.newValue == product.itemnumber){
					params.data.bbprodrate.description = product.description;
					params.data.bbprodrate.itemguid = product.itemguid;
					params.data.bbprodrate.itemnumber = product.itemnumber;
					params.data.bbprodrate.netweight = product.netweight;
					// params.data.bbprodrate.discountType = 0;
					bValidItem = true;
				}
			});

			//verify prod is on program when its a valid item
			if (bValidItem){
				selectedProgram.components.some( oComp => {
					oComp.prodrate.some(product => {
						if (params.newValue == product.itemnumber){
							params.data.bbprodrate.description = product.description;
							params.data.bbprodrate.itemguid = product.itemguid;
							params.data.bbprodrate.itemnumber = product.itemnumber;
							params.data.bbprodrate.netweight = product.netweight;
							// params.data.bbprodrate.discountType = 0;
							bValidItem = true;
							bValidProgramItem = true;
						}
					})
				});
			}

			params.data.message = '';
			bValidProgramItem ? '': params.data.message = 'Product not on Program';
			bValidItem ? '' : params.data.message = 'Invalid Item';
			update_grid_row(params);
		}

		function updateVolume(params) {
			params.data.bbprodrate.amount = params.data.bbprodrate.volume * params.data.bbprodrate.rate;
			update_grid_row(params);
		}

		function updateUOM(params) {
			let arrUOMs = <cfoutput>#serializeJson(uoms)#</cfoutput>;
			params.data.bbprodrate.uom = arrUOMs.find( uom => { return (uom.abbreviation == params.newValue) });
			update_grid_row(params);
		}

		function updateRate(params) {
			params.data.bbprodrate.amount = params.data.bbprodrate.volume * params.data.bbprodrate.rate;
			update_grid_row(params);
		}

		function updateAmt(params) {
			// When amount changes, if there is non-zero volume, then update the rate too
			if ( ! (isNaN(params.data.bbprodrate.volume) || params.data.bbprodrate.volume == 0)) {
				params.data.bbprodrate.rate = ((params.data.bbprodrate.amount) / (params.data.bbprodrate.volume));
			}
			update_grid_row(params);
		}

		// display updates to the grid
		function update_grid_row(params) {

			let rowNode = glob.my_grid.api.getRowNode(params.node.id);
			// rowNode.setData(params.data);

			let aNode = [];
			aNode.push(rowNode.data);
			let res = glob.my_grid.api.applyTransaction({ update: aNode });

			update_summary();
			return true;
		}

		// update claimed $ and Cs when user updates the grid
		function update_summary() {

			var tempDollars	= 0;
			var tempCases 	= 0;
			var tempPounds 	= 0;
			var tempProdRate = new Array();

			// loop over comps for LS amount
			if(arrComponent.length){
				arrComponent.forEach(bbComp => {
					if ( bbComp.isselected && bbComp.componenttypeid == 3 && !isNaN(bbComp.componentamount) ) {
						tempDollars += numeral(bbComp.componentamount);
					}
				});
			}

			// loop over rows in the grid for cs and $
			if (bb.bbprgdistitemrate.length) {
				bb.bbprgdistitemrate.forEach(bbPDIR => {
					if (bbPDIR.bbprodrate.itemnumber && bbPDIR.bbprodrate.volume) {
						// tempProdRate.push(bbPDIR);
						tempDollars += numeral(bbPDIR.bbprodrate.amount);
						tempCases += numeral(bbPDIR.bbprodrate.volume);
						tempPounds +=  numeral(bbPDIR.bbprodrate.volume) * numeral(bbPDIR.bbprodrate.netweight);
					}
				});
			}

			// $
			expAmount.value    = numeral(tempDollars).format(fmt_$2_decimal);
			variedAmount.value = numeral(numeral().unformat(claimAmount.value) - tempDollars).format(fmt_$2_decimal);

			// Cs
			<cfif local.view_program_volume_uom  eq 1 or local.view_program_volume_uom eq 3 >
				expCs.value    = numeral(tempCases).format(fmt_2_decimal);
				variedCs.value = numeral(numeral().unformat(claimCs.value) - tempCases).format(fmt_2_decimal);
			</cfif>

			// Lb
			<cfif local.view_program_volume_uom  eq 2 or local.view_program_volume_uom eq 3 >
				expLb.value    = numeral(tempPounds).format(fmt_2_decimal);
				variedLb.value = numeral(numeral().unformat(claimLb.value) - tempPounds).format(fmt_2_decimal);
			</cfif>

		}


		// Select drop-down style edit (for UOM)
		function SelectCellEditor() { }

		SelectCellEditor.prototype.init = function (params) {
			this.eSelect = document.createElement('select');
			this.eSelect.classList.add('ag-cell-edit-input');
			//Create and append the options
			for (var i = 0; i < params.values.length; i++) {
				var option = document.createElement("option");
				option.value = params.values[i];
				option.text = params.values[i];
				this.eSelect.appendChild(option);
			}
		};

		SelectCellEditor.prototype.getGui = function () {
			return this.eSelect;
		};

		SelectCellEditor.prototype.afterGuiAttached = function () {
			this.eSelect.focus();
		};

		SelectCellEditor.prototype.getValue = function () {
			return this.eSelect.value;
		};



		// Get the list of UOM abbreviations to display in the drop-down in the editable cell
		function getUOMAbbreviationList() {
			let arrUOMs = <cfoutput>#serializeJson(uoms)#</cfoutput>;
			let arrAbbreviations = arrUOMs.map(function(item) {
				return [item.abbreviation]
			})
			return arrAbbreviations;
		}

		// Ex: $1,234.56
		function currencyFormatter(params) {
			if (params.value == '0' || params.value == ''){
				return '$0.00';
			}
			else {
				return numeral(params.value).format('($0,0.00)');
			}
		}

		function getAllProducts() {
			// if no local data then get from server else use local data for the session
			arrAllProducts = JSON.parse(window.sessionStorage.getItem('allProds'));
			if( arrAllProducts === null ){
				fetch("/mvc/Models/Billback/BillbackEditSearchManager.cfc?method=getProductListJSON&returnformat=json")
				.then(response => response.json())
				.then(data => {
						window.sessionStorage.setItem('allProds', JSON.stringify(data))
						arrAllProducts = data;
					}
				);
			}
		}
		<!------------- deviation ------------->
		// function showDeviations() {
		// 	NewWindow("/billbacks/Deviation/Deviation_Main.cfm?bbid="+`${bb.bbheader.billbackidguid}`+"&caller=BBAgGridScoreCard&source=BBAgGridScoreCard","Billback Deviations", 1300, 640, "yes", "yes", "0", "no");
		// }

		<!------------- deviation ------------->
		function showDeviations() {
			NewWindow("/billbacks/Deviation/Deviation_Main.cfm?bbid="+`${bb.bbheader.billbackidguid}`+"&caller=BBSettlement&source=BBSettlement","Billback Deviations", 1300, 640, "yes", "yes", "0", "no");
		}



		$("div.loader").hide();
		<!------------- handler for clicking collapsible section headers ------------->
		var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
		var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';
		$( ".sectionHeader" ).on( "click", function() {
			var sectionClicker = $(this).attr("id");    // button id
			var imgUrl = $(this).children(0).attr('src');

			if ( imgUrl == arrowDown ) {
				$(this).children(0).attr("src", arrowRight);
			}else {
				$(this).children(0).attr("src", arrowDown);
			}
			$(this).next().toggle();        // show/hide following div

			// When open/close section, resize the grid (to take advantage of more room available)
			adjust_grid_height();
		});


		<!------------- Date picker logic ------------->
		$(".date").datepicker({
			dateFormat: "mm/dd/yy",
			changeMonth: true,
			changeYear: true
		});

		function checkLoader() {
			<cfif local.bbIdInt neq 0>
				show_loader('Loading Data...');
			</cfif>
		}

	</script>

	<cfset request.focusHiLightOff = 1>
	<cfinclude template="/common_files/focus.cfm">

</body>
</html>