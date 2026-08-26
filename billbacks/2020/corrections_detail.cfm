<!---
	* ====================================================================================================
	*    @File: \billbacks\2020\corrections_detail.cfm
	*  @Author: Sharon Harris
	*    @Date: August 2020
	*
	* @Remarks: Billbacks - Corrections Detail
	*			  See FlexDev\Forge\src\com\Billback\Upload\views\BBCorrectionsGrid.mxml
	*				and FlexDev\Forge\src\com\Billback\Upload\views\BBUploadItemsGrid.mxml
	* ====================================================================================================
--->
<cfparam name="URL.data" default=""/>

<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title>Corrections List</title>
</head>
<body>
	<cfsavecontent variable="styles">
		<cfset local.arrowDown = "/images/arrow-d-blue-12.png" />
		<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />

		<cf_include files="shared_styles.css, upload.css, /styles/css-loader.css">
		<cfinclude template="/common_files/dhx_message.cfm">
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( styles )#">

	<cfinclude template="/common_files/jQuery.cfm">
	<cf_include files="/common_files/noty.cfm">

	<!--- <p style="margin: 50px; color: gray; font-size: 26px;">In Progress - coming soon...</p> --->

	<cfoutput>
		<!--- Collapsable header --->
		<button id="topSectionBtn" class="sectionHeader">
			<img src="#local.arrowDown#" alt="expand/collapse" style="padding:1px 3px 0 0"/>
			BB Correction Results: &nbsp; <span id="record_count"></span>
		</button>

		<!------------------------------->
		<!--- TOP collapsible section --->
		<!------------------------------->
		<div>
			<!--- ~~~~~~~~~~  actions at the top of the page ~~~~~~~~~~~ --->
			<div id="menuBar">
				<button id="editToggleBtn" style="width: 100px" title="" class="button" onclick="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</button>
				<button id="corr-save" class="button" title="" onclick="">Save</button>
				<button id="corr-validate" class="button" title="" onclick="">Validate</button>
				<button id="corr-ediDupl" class="button" title="" onclick="showDuplicates();">EDI Duplicate</button>
				<span   id="spacer1"> &nbsp;</span>
				<button id="corr-del" class="button" title="" onclick="">Delete</button>
			</div>

			<!--- ~~~~~~~~~~  Editable Header ~~~~~~~~~~~ --->
			<!--- See FlexDev\Forge\src\com\Billback\Upload\views\BBHeaderForm.mxml --->
			<form name="BB_Corrections">
				<fieldset style="width: 90%">
					<legend><span id="editing_hdr" class="hidden">Edit</span><span id="viewing_hdr">View</span> Header Details</legend>
					<section id="header_elements">
						<cfoutput>
						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~ first column ~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<article>
							<label>Payee Id</label>
							<input type="text" name="vendorId" id="tiVendorId"  class="editable">
							<a id="imgVendorSearch" href="##" onclick="popupVend();return false;">
								<i class="fa fa-search btn-icon"></i>
							</a><br>

							<label>Payee Name</label>
							<input type="text" name="vendorName" id="tiVendorName" class="editable"><br>

							<label>Account</label>
							<input type="text" name="shipTo" id="tiShipTo"  class="editable">
							<a id="imgDistributorSearch" href="##" onclick="popupCust();return false;">
								<i class="fa fa-search btn-icon"></i>
							</a><br>

							<label>Claimed Amount</label>
							<input type="text" name="BBAmount" id="tiBBAmount" readonly><br>

							<label>Claimed Volume</label>
							<input type="text" name="TotalVolume" id="tiBBVolume" readonly><br>
						</article>

						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~~ second column ~~~~~~~~~ --->
						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<article class="smallL">
							<label>Inv Title</label>
							<input type="text" name="billbackTitle" id="tiBillbackTitle"  class="editable"><br>

							<label>Operator Id</label>
							<input type="text" name="operatorLegacyID" id="tiOperator" class="editable">
							<a id="imgOperatorSearch" href="##" onclick="popupOper();return false;">
								<i class="fa fa-search btn-icon"></i>
							</a><br>

							<label>Inv</label>
							<input type="text" name="BBReference" id="tiBBReference" readonly><br>

							<fieldset id="bbUploadHeader" name="bbUploadHeader"><legend>Messages</legend>
								<!--- <input type="textarea" name="tiHeaderError" id="tiHeaderErrors"> --->
								<div id = "headerError" nmae = "headerError"></div>
							</fieldset><br>

						</article>

						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~ third column ~~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<article class="wideL">
							<label>Inv Date</label>
							<input type="text" class="editable date" id="dtBBDate" name="BBDate"><br>

							<label>Start Date</label>
							<input type="text" class="editable date" id="dtStartDate" name="startDate"><br>

							<label>End Date</label>
							<input type="text" class="editable date" id="dtEndDate" name="endDate"><br>
						</article>

						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~ fourth column ~~~~~~~~~~ --->
						<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
						<article class="wideL">
							<label>EDI Remit To Id</label>
							<input type="text" name="agreementNum" id="tiAgreementNum" class="editable"><br>

							<label>EDI Remit To Name</label>
							<input type="text" name="agreementName" id="tiAgreementName" class="editable"><br>
						</article>

						</cfoutput>
					</section>
				</fieldset>

			</form>
		</div>
	</cfoutput>

	<form name='saveOper' id='saveOper' action='javascript:saveOper();'>
			<INPUT TYPE="Hidden" ID="Operator_ID" NAME="Operator_ID" VALUE="">
			<input type="hidden" id="SelectSingleSearchResultOnly" value="1"/>
			<INPUT TYPE="Hidden" ID="Operator_List" NAME="Operator_List" VALUE="">
	</form>

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

	<!--- ~~~~~~~~~~ actions above the grid ~~~~~~~~~~~ --->
	<div id="actionArea">
		<button class="button" title="Clear filters" onclick="glob.my_grid.api.setFilterModel(null);">Clear Filters</button>
		<label>
			<input type="checkbox" name="display_all_rows" onclick="getBillbackUploadDetail();"></input>
			display all rows
		</label>
	</div>

		<!--- ~~~~~~~~~~ grid section ~~~~~~~~~~~ --->
	<section id="corr_edit_grid" class="ag-theme-balham">
	</section>


	<!--- Error Detail section at the bottom of the screen --->
	<section class="horiz-aligner">
		<div>
			<label>
				<input type="radio" name="rdoErrorDisplay" id="rdoErrorDisplay" value="showSelected" checked="checked" onclick="showSelected();">
				Show error for selected row
			</label>
			<br>
			<label>
				<input type="radio" name="rdoErrorDisplay" id="rdoErrorDisplay" value="showAll" onclick="showAll();">
				Show all detail errors
			</label>
		</div>
		<textarea id="taErrorDetail" rows="5" cols="200">
		</textarea>
	</section>

	<cfscript>
		jQueryUI.widgets = "datepicker";
		request.ag_grid_version = 23;
	</cfscript>
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
									"/common_files/jQueryUI.cfm",
									"/styles/font-awesome.min.css",
									"/common_files/ag-grid.cfm"
									] )#>

	<style>
		.ag-header-cell-label .ag-header-cell-text {
			white-space: pre;				/* support \n */
		}
		.ag-header {
			font-size: 11px !important;
			text-align: center;
		}
		.ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
		.ag-theme-balham .ag-header-group-text,
		.ag-header-cell-text {
			margin: 0px auto 0px auto;		/* Center the header text */
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
		.yellowBG {
			background-color: yellow;
		}
	</style>

	<!--- Event Handlers --->
	<cfinclude template="/billbacks/2020/corrections_events.cfm">

	<script>
	<!-------------  Constants ------------->
	const MASS_APPLY = true;
	const config = {
				ui_name: "ag_bb_corr_edit_grid",
				grid_id: "#corr_edit_grid"
			};
	<cfoutput>
		var urlData = #URLDecode(URL.data)#;
	</cfoutput>
	/* 	---------------------------------------------------------------------------------------------------------------------------------*/
	/* 	----------------------------------------	Whole Ball Of Wax		 ------------------------------------------------------------*/

	var bbUploadHeader = urlData;

	/* 	-------------    	This gets populated on initial load via URL.data.
							Immediateley it is refreshed from DB.
							Any edits hit this Obj and it sent to backend on Save and Validate
		---------------------------------------------------------------------------------------------------------------------------------*/
	var objLock = {};
	var bEditable = false;
	<!------------- glob = global variables ------------->
	let glob = { };
	var rowData_corrDetails = [];

	<!------------- wait for the document to be loaded, otherwise ag-Grid will not find the div ------------->
	document.addEventListener("DOMContentLoaded", function () {
		get_corr_data();
		get_grid_content();
		getBillbackUploadDetail();
		// WORKAROUND ag-grid.js BUG WITH INITIAL/RESIZE HEIGHT
		glob.my_grid.blackSmith.height_offset -= 20 // for any resizing, make it smaller to workaround the size bug
	});

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
	var columnDefsCorrEditGrid = [
		{width:24, checkboxSelection:true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, filter:false, resizable:false, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true},
		{width:40, filter:false, editable:false,
			sortable:false,
			headerComponentParams: {
				// This is the (Delete row(s) / Add row) column
				template: customize_column_header(
				'',
				'<div><a id="colDelSel" href="javascript:deleteSelectedRows();">' +
					'<img alt="delete rows" title="delete selected rows" src="/Images/delete2.png" style="padding-bottom:3px; padding-right:10px;">'+
				'</a></div>',
				false)
			},
			cellRenderer: function(params) {
				let delCel =
					'<div style="margin-left:9px; margin-top:3px;">' +
						'<img alt="delete row" title="delete this row" src="/Images/delete2.png">'+
					'</div>';
				return delCel;
			},
			onCellClicked: function(params) {
				deleteRow(params);
			}
		},
		{headerName: "Row ID", field: 'rowID', filter:false, width:50},
		{headerName: "(A) SAP Dist Num", field: 'dupShipTo', width:100,
			cellClass: function(params){ return (correctionGridErrorStyle(params, "dupShipTo", "bg")); },
			tooltipValueGetter: function(params){ return (correctionGridErrorStyle(params, "dupShipTo", "tooltip")); },
			editable:function(params) {
				return bEditable;   //params.node.data.isTBD === 1;
			},
			headerComponentParams: {
				template: customize_column_header(''
				,'<div class="mass_apply"><input class="mass mass_apply" name="dupShipTo" placeholder="mass apply" tabindex="-1" title="Enter to mass apply to selected records" type=text>'
					+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="dupShipTo" title="Click to apply to selected rows"></i></span>'
					+ '</div>'
				,MASS_APPLY) }
				,sortable:true
		},
		{headerName:"(B) Cust\nDist Code", field:'custNumber', width:60},
		{headerName:"(C) Cust\nDist Name", field:'custName', width:80},
		{headerName:"(D) Cust\nPromo Code", field:'custContractNumber', width:80},
		{headerName:"(E) Cust Promo Desc", field:'custContractDescription', width:150},
		{headerName:"(F) GMI Program #", field:'contractNumber', width:100,
			cellClass: function(params){ return (correctionGridErrorStyle(params, "contractNumber", "bg")); },
			tooltipValueGetter: function(params){ return (correctionGridErrorStyle(params, "contractNumber", "tooltip")); },
			editable:function(params) {
				return bEditable;   //params.node.data.isTBD === 1;
			},
			headerComponentParams: {
				template: customize_column_header(''
				,'<div class="mass_apply"><input class="mass mass_apply" name="contractNumber" placeholder="mass apply" tabindex="-1" title="Enter to mass apply to selected records" type=text>'
					+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="contractNumber" title="Click to apply to selected rows"></i></span>'
					+ '</div>'
				,MASS_APPLY) }
				,sortable:true
		},

		{headerName:"(G) SAP Promoted Cust", field:'operatorLegacyId', width:100,
			cellClass: function(params){ return (correctionGridErrorStyle(params, "operatorLegacyId", "bg")); },
			tooltipValueGetter: function(params){ return (correctionGridErrorStyle(params, "operatorLegacyId", "tooltip")); },
			editable:function(params) {
				return bEditable;   //params.node.data.isTBD === 1;
			},
			headerComponentParams: {
				template: customize_column_header(''
				,'<div class="mass_apply"><input class="mass mass_apply" name="operatorLegacyId" placeholder="mass apply" tabindex="-1" title="Enter to mass apply to selected records" type=text>'
					+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="operatorLegacyId" title="Click to apply to selected rows"></i></span>'
					+ '</div>'
				,MASS_APPLY) }
				,sortable:true
		},
		{headerName:"(H) Base Product Code", field:'item', width:100,
			cellClass: function(params){ return (correctionGridErrorStyle(params, "item", "bg")); },
			tooltipValueGetter: function(params){ return (correctionGridErrorStyle(params, "item", "tooltip")); },
			editable:function(params) {
				return bEditable;   //params.node.data.isTBD === 1;
			},
			headerComponentParams: {
				template: customize_column_header(''
				,'<div class="mass_apply"><input class="mass mass_apply" name="item" placeholder="mass apply" tabindex="-1" title="Enter to mass apply to selected records" type=text>'
					+ ' <span class="massEditIcon"><i class="fa fa-pencil mass_apply" name="item" title="Click to apply to selected rows"></i></span>'
					+ '</div>'
				,MASS_APPLY) }
				,sortable:true
		},
		{headerName:"(I) Cust Provided\nProduct Code", field:'custItem', width:80},
		{headerName:"(J) Cust Product Desc", field:'custItemDescription', width:160},
		{headerName:"(K) Quantity", field:'BBProductQuantity',type:'numericColumn', width:70},
		{headerName:"(L) Case\nRate", field:'caseRate',type:'numericColumn', width:70},
		{headerName:"(M) Payment\nAmount", field:'BBRate',type:'numericColumn', width:70},
		{headerName:"(N) Operator\nId", field:'operatorId', width:80},
		{headerName:"(O) Operator\nName", field:'operatorName', width:80},
		{headerName:"(P) Operator\nAddress1", field:'operatorAddress1', width:80},
		{headerName:"(Q) Operator\nCity", field:'operatorCity', width:80},
		{headerName:"(R) Operator\nState", field:'operatorState', width:80},
		{headerName:"(S) Operator\nZip", field:'operatorZip', width:80},
		{headerName:"(T) Discount\nType", field:'DiscountType', width:80}
	];

	<!------------- define ag-grid configuration ------------->
	glob.my_grid = {
		blackSmith: { fullHeight: true, height_offset: -120 }
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
		,columnDefs: columnDefsCorrEditGrid
		,floatingFilter: true
		,rowModelType: "clientSide"
		,rowSelection: "multiple"
		,rowMultiSelectWithClick: true
		,suppressContextMenu: true
		,enableBrowserTooltips: true
		,enterMovesDown: 				true
		,enterMovesDownAfterEdit: 		true
		,onSelectionChanged: onSelectionChanged
		,onGridReady:               function(p) { mass_apply_event() }
		,onBodyScroll:              function(p) { mass_apply_event() }
		,onCellValueChanged: function(event) {
				if(event.oldValue != event.newValue){
					event.data.bEdited = true;
				}
			}
		// ,isExternalFilterPresent: isExternalFilterPresent
		// ,doesExternalFilterPass: showFilteredRecords
		// ,getRowNodeId: function(data) { return data.itemGuid }
		// ,statusBar: footerbar("filtered_and_total")
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
		<!--- ~~~~~~~~ mass apply logic ~~~~~~~~ --->
		$("i.mass_apply").click(function(e){
			e.stopPropagation();

			let icon_name = $(this).attr("name");
			let mass_rate = $("input[name=" + icon_name + "]").val();
			<!---  apply to filtered (visible) rows only  --->
			glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {

				<!--- ~~ apply to selected rows only ~~~ --->
				if (rowNode.selected) {
					rowNode.setDataValue(icon_name, mass_rate);
				}
			});
		});
	}

<!--- MARK --->

	function getBillbackUploadDetail(){
		show_loader('Loading Data...');
		let bDisplayAll = $("input[name=display_all_rows]").prop('checked');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	method: "getBillbackUploadDetailJSON",
									argbbUploadHeader: JSON.stringify(bbUploadHeader),
									argbDisplayAll: bDisplayAll}
						,success: function (obj) {
							bbUploadHeader = obj;
								glob.my_grid.api.setRowData(bbUploadHeader.bbUploadDetail);
								setHeader();
								getLockUnlockBB();
							$("div.loader").hide();
						}
						,error: function (data) {
							alert('An error occurred.  ' + JSON.stringify(data) );
						}
						,type: "post"
						,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
			});
	}

	function setHeader(){
		//console.log(bbUploadHeader);
		var sErrorObj = '';
		var errObj = bbUploadHeader.errObj;
		const keys = Object.keys(errObj)
		for (const key of keys) {
			//console.log(errObj[key]);
			if(errObj[key] != ''){
				sErrorObj = errObj[key] + '\n';
			}
		}

		$("#tiVendorId").val(bbUploadHeader.vendorId);
		$("#tiVendorName").val(bbUploadHeader.vendorName);
		$("#tiShipTo").val(bbUploadHeader.shipTo);
		$("#tiBBAmount").val(bbUploadHeader.BBAmount);
		$("#tiBBVolume").val(bbUploadHeader.TotalVolume);
		$("#tiBillbackTitle").val(bbUploadHeader.billbackTitle);
		$("#tiOperator").val(bbUploadHeader.operatorLegacyID);
		$("#tiBBReference").val(bbUploadHeader.BBReference);
		$("#headerError").text(sErrorObj);
		$("#dtBBDate").val(bbUploadHeader.BBDate);
		$("#dtStartDate").val(bbUploadHeader.startDate);
		$("#dtEndDate").val(bbUploadHeader.endDate);
		$("#tiAgreementNum").val(bbUploadHeader.agreementNum);
		$("#tiAgreementName").val(bbUploadHeader.agreementName);
		if (bbUploadHeader.bbUploadDetail.length && typeof bbUploadHeader.bbUploadDetail[0].errMsg !== 'undefined') {
			$("#taErrorDetail").text(bbUploadHeader.bbUploadDetail[0].errMsg);
		}
		else{
			$("#taErrorDetail").text('');
		}


	}

//   mvc.Models.Billback.BillbackUploadManager.saveUploadHeaderAndDetailsJSON   -> bbUploadHeader
//	mvc.Models.Billback.BillbackUploadManager.lockUnlockBB  -> array

	function finalSave(sAction){
			var sMessage = '';
			if(sAction == 1){
					sMessage ='Saving Data...';
				}
				else{
					sMessage = 'Saving and Validating Data...'
				}
			show_loader(sMessage);
			console.log(bbUploadHeader);
			//return;
			$.ajax({
							async: true
							,dataType: 'json'
							,data: { 	bbUploadHeader : JSON.stringify(bbUploadHeader),
										sAction: sAction,
										method: "saveUploadHeaderAndDetailsJSON" }
							,success: function (obj) {
								//var obj = JSON.parse(data);
								bbUploadHeader = obj;
								//success
								if(bbUploadHeader.bbHeaderID == "" && sAction == 2){
									alert('Validation completed Successfully.  Billback is queued for creation.');
									//now close tab
									parent.closeIFrame(window.name);
										$("div.loader").hide();
								}
									glob.my_grid.api.setRowData(bbUploadHeader.bbUploadDetail);
									setHeader();
									$("div.loader").hide();

							}
							,error: function (data) {
								//console.log('An error occurred.');
								 // console.log(data);
								$("div.loader").hide();
								alert('An error occurred.  ' + data.toString() );
							}
							,type: "post"
							,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
				});
	}

	function lockUnlockBB(isAsync=true){
        if ( $.isNumeric( bbUploadHeader.bbHeaderID ) ) {
            var lockUnlock =  !objLock.bLocked;
            $.ajax({
                    async: isAsync
                    ,dataType: 'json'
                    ,data: { 	bbHeaderId : bbUploadHeader.bbHeaderID,
                                userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>,
                                lockUnlock: lockUnlock,
                                toggleBB: true,
                                unlockExistingLockedByUser: false,
                                bbClose : false,
                                method: "lockUnlockBBJSON" }
                    ,success: function (data) {
                        if(data.objIdLocked != '' && data.objIdLocked != data.objId){
                            alert("Please unlock other billback corrections that you already have locked.");
                        }
                        getLockUnlockBB();

                    }
                    ,error: function (data) {
                        $("div.loader").hide();
                        alert('An error occurred.  ' + data.toString() );
                    }
                    ,type: "post"
                    ,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
                });
        }
	}

	function getLockUnlockBB(){
			if(!Number.isInteger(bbUploadHeader.bbHeaderID)){
				return;
			}

			bEditable = false;

			$( ".button" ).removeClass("recommended");
			$( ".button" ).off( "click" );

			$.ajax({
					async: true
					,dataType: 'json'
					,data: { 	bbHeaderId : bbUploadHeader.bbHeaderID,
								method: "getLockUnlockBBJSON" }
					//,dataType: "json"
					,success: function (data) {
						//console.log(data);
						objLock = data;
						$("#editToggleBtn").addClass("recommended");
						//Not Locked
						if(data.bLocked === false ){
							//console.log('not locked');
							readOnlyMode();
							$("#editToggleBtn").css("width", "100px");
							$("#editToggleBtn").text('read-only');
							$("#editToggleBtn").click(function() {
								lockUnlockBB();
							});

						}
						//Locked by ME
						else if(data.userId === <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>){
							//console.log('locked by me');
							editMode();
						}
						//Locked by Someone Else
						else{
							readOnlyMode();
							$("#editToggleBtn").css("width", "150px");
							$("#editToggleBtn").text('locked by: ' + data.userLocked.fullName);
							$("#editToggleBtn").click(function(e) {
								getLockUnlockBB();
							});
						}
					}
					,error: function (data) {
						//console.log('An error occurred.');
						 // console.log(data);s
						alert('An error occurred.  ' + data.toString() );
					}
					,type: "post"
					,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
				});
			}

	function editMode(){
		bEditable = true;
		// Form Fields------------------------
		$( ".editable" ).prop("readonly", false);
		$( ".mass_apply" ).prop("readonly", false);
		$( ".editable" ).change(function(e) {
			var f = $( this );
			bbUploadHeader[f.attr("name")] = f.val();	//Update the main Obj
		});

		//Lock Buttons------------------------
		$("#editToggleBtn").click(function() {
			lockUnlockBB();
		});
		$("#editToggleBtn").css("width", "100px");
		$("#editToggleBtn").text('edit');

		//All Buttons	----------------------
		$( ".button" ).addClass("recommended");

		//button actions only--------------------------------
		$("#corr-save").click(function() {
			finalSave(1);
		});
		$("#corr-validate").click(function() {
			finalSave(2);
		});
		$("#corr-ediDupl").click(function() {
			showDuplicates();
		});
		$("#corr-del").click(function() {
			deleteCorrection();
		});
		//end Button actions---------------------------------

	}

	function readOnlyMode(){

		// Form Fields
		$( ".editable" ).off('change');
		$( ".editable" ).prop("readonly", true);
		$( ".mass_apply" ).prop("readonly", true);

		$("#corr-ediDupl").addClass("recommended");
		$("#corr-ediDupl").click(function() {
			showDuplicates();
		});
	}

	function showSelected(){
		var selectedData = glob.my_grid.api.getSelectedRows(); // Selected Rows
		var s = '';
		selectedData.forEach(function (e){
			s = s + e.errMsg + '\r\n';
		})
		$("#taErrorDetail").text(s);
	}

	function showAll(){
		var s = '';
		bbUploadHeader.bbUploadDetail.forEach(function (e){
			s = s + e.errMsg + '\r\n';
		})
		$("#taErrorDetail").text(s);
	}
	function onSelectionChanged(){
		var s = $("#rdoErrorDisplay:checked").val();
		if(s == 'showSelected'){
			showSelected();
		}
	}

	$( window ).unload(function(e) {
		if(objLock.bLocked && objLock.userId == <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>){
		e.preventDefault();
		delete e['returnValue'];
		//console.log('XXXXXXXXXXXXXXXXXXXXXXXXX');
		lockUnlockBB(true);
		}
	});

<!--- MARK --->
	function deleteCorrection() {
		let popup = dhtmlx.modalbox( {
			text: "Do you want to delete this entire correction record?",
			title: "Confirm Delete",
			buttons: ["Yes", "No"],
			callback: function(res) {
				// res is 0 if they picked the first button (Yes)
				if (res == 0) deleteData();
			}
		});
		return false;
	}

	function deleteData(){
		show_loader('Deleting Correction Data...');
		$.ajax({
			async: true
			,type: "post"
			,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
			,data: { 	method: "deleteCorrectionRecords",
						BBHeaderIDList: bbUploadHeader.bbHeaderID }	//list of BB HeaderId's
			//,dataType: "json"
			,success: function (data) {
				//close TAB
				parent.closeIFrame(window.name);
				$("div.loader").hide();
			}
			,error: function (data) {
				alert('An error occurred.  ' + JSON.stringify(data) );
			}
		});
	}

 	// row level delete
	function deleteSelectedRows() {
		if (bEditable) {
			let popup = dhtmlx.modalbox( {
				text: "Do you want to delete the selected rows?",
				title: "Confirm Delete",
				buttons: ["Yes", "No"],
				callback: function(res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						let selectedData = glob.my_grid.api.getSelectedRows();

						selectedData.forEach( element => {
							// loop over the seleted and delete
							show_loader('Deleting selected rows...');
							$.ajax({
								async: false
								,type: "post"
								,dataType: "json"
								,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
								,data: { 	method: "deleteBBUploadDetail",
											returnformat: 'json',
											bbUploadDetail: JSON.stringify(element) }
								,success: function (data) {
									$("div.loader").hide();
								}
								,error: function (data) {
									alert('An error occurred.  ' + JSON.stringify(data) );
								}
							});
						});

						// remove from the display on the grid
						let res = glob.my_grid.api.applyTransaction({ remove: selectedData });
					}
				}
			});
		}
		else {
			noty({
				text: "To delete, change to Edit mode",
				layout: "center", type: "information", timeout: 3000, killer: true,
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
		}
		return false;
	}

	function deleteRow(params){
		if (bEditable) {

			let popup = dhtmlx.modalbox( {
				text: "Delete row?",
				title: "Confirm Delete",
				buttons: ["Yes", "No"],
				callback: function(res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						let arrRow = [];
						arrRow.push(params.node.data);
						console.log('params',params);
						console.log('arrRow',arrRow);
						// show_loader('Deleting this row...');
						$.ajax({
							async: false
							,type: "post"
							,dataType: "json"
							,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
							,data: { 	method: "deleteBBUploadDetail",
										returnformat: 'json',
										bbUploadDetail: JSON.stringify(arrRow[0]) }
							,success: function (data) {
								// $("div.loader").hide();
								console.log("data",data);
							}
							,error: function (data) {
								alert('An error occurred.  ' + JSON.stringify(data) );
							}
						});
						// remove from the display on the grid
						let res = glob.my_grid.api.applyTransaction({ remove: arrRow });
					}
				}
			});
		}
		else {
			noty({
				text: "To delete, change to Edit mode",
				layout: "center", type: "information", timeout: 3000, killer: true,
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
		}
		return false;

	}

	// EDI Duplicates button handler
	function showDuplicates(){
		NewWindow("/Billbacks/common/Billback_Dup_Checker.cfm?uploadID=" + bbUploadHeader.uploadID +"&bbHeaderID=" + bbUploadHeader.bbHdrCounter, "ediDupCheck", 800, 900, "yes", "yes");
	}

	function popupCust() {
		if(bEditable){
			NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=saveCust&SelectSingleSearchResultOnly=1&ReloadForm=1&Fieldname=Customer_ID&PageSource=bbCorrections2020", "custSearch", 800, 900, "yes", "yes");
		}
	}

	function saveCust(){
		var vId = $('#shipTo').val();
		// Form Fields
		bbUploadHeader["shipTo"] = vId;
		$("#tiShipTo").val(vId);
	}

	function popupOper() {
		if(bEditable){
			NewWindow("/Billbacks/search_Screens/PM_select_operators.cfm?Formname=saveOper&SelectSingleSearchResultOnly=1&ReloadForm=1&Fieldname=Operator_ID", "operSearch", 900, 900, "yes", "yes");
		}
	}
	function saveOper(){
		var vId = $('#Operator_List').val();
		console.log(vId);
		// Form Fields
		bbUploadHeader["operatorLegacyID"] = vId;
		$("#tiOperator").val(vId);
	}

	function popupVend() {
		//document.BB_Corrections.SelectSingleSearchResultOnly.value = 0;
		if(bEditable){
			window.open('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=saveVend&Reloadform=1&Fieldname=Vendor_ID&PageSource=corrections&SelectSingleSearchResultOnly=1&DescFieldName=VendName','vendorMaster','width=900,height=900,scrollbars=1');
		}
	}
	function saveVend(){
		var vId = $('#Vendor_ID').val();
		// Form Fields
		bbUploadHeader["vendorId"] = vId;
		$("#tiVendorId").val(vId);
	}

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


	$(".date").datepicker({
			dateFormat: "m/d/yy",
			changeMonth: true,
			changeYear: true,
			onSelect: function( selected ) {
				// change date limit based on selected value
				let sel = jQuery(this).attr("name");
				if ( sel === "startDate" )
					jQuery("input[name=endDate]").datepicker("option", "minDate", selected);
				else if ( sel === "endDate" )
					jQuery("input[name=startDate]").datepicker("option", "maxDate", selected);
				 //Update the main Obj
				bbUploadHeader[sel] = selected;
			}
		});

	/* Setting the style for the cells */

	function correctionGridErrorStyle(params, deviationType, retType) { // deviationStyle
		let cellClasses = [];
		let bgClass = "";	// could be no color or highlighted in yellow
		let strToolTip ="";
		 	switch (deviationType) {
				case "contractNumber":
					if ((params.data.errObj.contractNumber.trim()).length != 0) {
				 		bgClass = "yellowBG";
						strToolTip = params.data.errObj.contractNumber.trim();
				 	}
				break;
				case "dupShipTo":
					if ((params.data.errObj.dupShipTo.trim()).length != 0) {
					 	bgClass = "yellowBG";
						strToolTip = params.data.errObj.dupShipTo.trim();
					}
				break;
				case "operatorLegacyId":
					if ((params.data.errObj.operatorLegacyId.trim()).length != 0) {
					 	bgClass = "yellowBG";
						strToolTip = params.data.errObj.operatorLegacyId.trim();
					}
				break;
				case "item":
					if ((params.data.errObj.item.trim()).length != 0) {
					 	bgClass = "yellowBG";
						strToolTip = params.data.errObj.item.trim();
					}
				break;
			}
			cellClasses.push(bgClass);

			if (retType == "bg")
			{
				return cellClasses;
			}
			else if (retType == "tooltip")
			{
				return strToolTip;
			}
			/* if (isLink(params)) {
					cellClasses.push("cursor-pointer");
			} */
	}

	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>