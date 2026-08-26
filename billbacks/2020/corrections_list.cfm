<!---
  * ==================================================================================================== 
  *    @File: \billbacks\2020\corrections_list.cfm
  *  @Author: Sharon Harris
  *    @Date: August 2020
  * 
  * @Remarks: Billbacks - List of Corrections
  *			  See FlexDev\Forge\src\com\Billback\Upload\views\BBCorrectionsGrid.mxml
  * ==================================================================================================== 
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Corrections List</title>
</head>
<body>
	<cfsavecontent variable="corr_styles">
		<cf_include files="shared_styles.css, upload.css">
		<cfinclude template="/common_files/dhx_message.cfm">
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( corr_styles )#">

	<!--- ~~~~~~~~~~ any actions above the grid ~~~~~~~~~~~ --->
	<div id="actionArea">
		<button class="button" id="corr_del_id" title=="Delete the selected records" onclick="deleteCorrections();">Delete</button>
		<!--- <label>
			<input type="checkbox"></input>
			show filters
		</label>
			--->
		<button class="button" title="Clear filters" onclick="CorrGridOptions.api.setFilterModel(null);">Clear Filters</button>

		<button class="button" title="Refresh Data" onclick="getErrorCorrectionSummary();">Refresh Data</button>

		<span id="sRefreshTime" style="color:red"></span>
	</div>


	<!--- ~~~~~~~~~~ grid section ~~~~~~~~~~~ --->
	<section id="corrections_grid" class="ag-theme-balham">
	</section>

	<cfscript>
		request.ag_grid_version = 23;
	</cfscript>


	<!--- <cfset jQueryUI.widgets = "datepicker"> --->
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
									"/common_files/jQueryUI.cfm",
									"/common_files/ag-grid.cfm",
									"/styles/css-loader.css",
									"/script/javascript/moment.min.js"
									] )#>

	<style>
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
	</style>
	<script>
		
		// Delete the selected corrections
		function deleteCorrections() {
			let popup = dhtmlx.modalbox( {
				text: "Do you want to delete the selected records?",
				title: "Confirm Delete",
				buttons: ["Yes", "No"],
				callback: function(res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						deleteCorrectionRecords();
					}
				}
			});
			return false;
		}

		// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
		document.addEventListener("DOMContentLoaded", function () {
			buildCorrGrid();
			getErrorCorrectionSummary();
		});
		// Define the Grid Columns
		var columnDefs_CorrectionsGrid = [
			{headerName: "", field: 'deleted',checkboxSelection:true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, width:24, filter:false, resizable:false, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true},
			{headerName: "ID", field: 'uploadID', type:'numericColumn', width:70},
			{headerName: "Hdr ID", field: 'bbHdrCounter', width:70},
			{headerName: "Upload User", width:120 ,valueGetter: params => {return params.data.uploadUser.fullName} },		
			{headerName: "Status", field: 'uploadStatus', width:240},
			{headerName: "Upload Date",  field: 'uploadDateTime', width:130},
			{headerName: "Inv", field: 'BBReference', width:200},
			{headerName: "Inv Title", field: 'billbackTitle', width:200, sortable:true},
			{headerName: "Payee",  field: 'vendorName', width:200},
			{headerName: "Amount",  field: 'BBAmount',type:'numericColumn', width:100},
			{headerName: "Start Date",  field: 'startDate', width:100},
			{headerName: "End Date",  field: 'endDate', width:100},
			{headerName: "Type",  field: 'uploadType', width:80, filter: 'agSetColumnFilter'},
			{headerName: "Locked By", width:120, hide:false, valueGetter:  params => {return params.data.lockedUser.fullName} }
		];

		var CorrGridOptions = {};	// Global so can access API later
		var rowData_Corrections = [];

		function buildCorrGrid() {
			CorrGridOptions = {
				blackSmith: { fullHeight: true, height_offset: -90 },
				columnDefs: columnDefs_CorrectionsGrid
				,rowData: rowData_Corrections
				,rowModelType: "clientSide"
				,rowSelection: "multiple"
				,suppressContextMenu: true
				,enableBrowserTooltips: true

				// To open the details tab when a row is double clicked:
				// ,onCellDoubleClicked: function(event) { if(event.column.colId == 12){return} else parent.parent.create_tab( event.node.data[ COL.BILLBACK_ID_INT ], event.node.data[COL.CTM_ID] ) }
				,onCellDoubleClicked: function(event) { //console.log(event); 
														parent.create_tab( event.node.data) }
				,defaultColDef:	{
						floatingFilterComponentParams: { suppressFilterButton: false }
						,suppressMenu:                  true
						,suppressMovable:               false
						,unSortIcon:                    false
						,sortable:                      true
						,resizable:                     true
						,suppressColumnsToolPanel: false
						,filter: 'agTextColumnFilter'
						,floatingFilter: true
				}
				,statusBar: footerbar("filtered_and_total")
			};

			ag_grid_default(CorrGridOptions);		// set up default features
			init_ag_grid(CorrGridOptions, "#corrections_grid", false );   // false=setup as client side
		}

		function getErrorCorrectionSummary(){
			show_loader('Loading Data...');
			$.ajax({
							async: true
							,data: { 	method: "getErrorCorrectionSummaryJSON" }
							//,dataType: "json"
							,success: function (data) {
				              rowData_Corrections = JSON.parse(data);
				              //console.log(rowData_RFP_Products);
				              CorrGridOptions.api.setRowData(rowData_Corrections);
				              $("div.loader").hide();
				              var d = new Date();
				              $("#sRefreshTime").html('&nbsp;&nbsp;&nbsp;Data as of &nbsp;' + moment(d).format('L') + ' ' + moment(d).format('LTS'));
				            }
				            ,error: function (data) {
				                alert('An error occurred.  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
				});
		}

		function deleteCorrectionRecords(){
			var selectedData = CorrGridOptions.api.getSelectedRows();
			var a = [];
		    selectedData.forEach(e => a.push(e.bbHeaderID));  // Create List
		    show_loader('Deleting Selected Rows...');
			$.ajax({
							async: true
							,data: { 	method: "deleteCorrectionRecords",
										BBHeaderIDList: a.join() }	//list of BB HeaderId's
							//,dataType: "json"
							,success: function (data) {
				              onRemoveSelected();
				              $("div.loader").hide();
				            }
				            ,error: function (data) {
				                alert('An error occurred.  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
				});
		}

		function onRemoveSelected() {
		  var selectedData = CorrGridOptions.api.getSelectedRows();
		  //console.log(selectedData);
  		  var res = CorrGridOptions.api.applyTransaction({remove: selectedData});
		  //console.log(res);
		}

	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>