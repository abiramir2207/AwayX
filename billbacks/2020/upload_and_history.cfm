<!---
  * ==================================================================================================== 
  *    @File: \billbacks\2020\upload_and_history.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2020
  * 
  * @Remarks: Billbacks - Upload & History sub-tab (under Upload tab)
  *			  See FlexDev\Forge\src\com\Billback\Upload\views\BBUploadHistoryForm.mxml
  * ==================================================================================================== 
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<!---  SAH
	<cfset local.arrowDown = "/images/arrow-d-blue-12.png" />
	<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />
	  --->
    <title>Upload and History</title>
</head>
<body>
	<cfsavecontent variable="styles">
        <cf_include files="shared_styles.css, upload.css">
		</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( styles )#">
	
		<!--- ~~~~~~~~~~ top section ~~~~~~~~~~~ --->
		<!--- SAH
		<button id="searchSectionBtn" class="sectionHeader">
			<img src="#local.arrowDown#" alt="expand/collapse" style="padding:1px 3px 0 0">
			Billback Upload Results: &nbsp;<span id="record_count"></span>
		</button>
  		--->
		  	<!--- begin of Dropzone upload --->
		<cf_include files=#arrayToList( [ "/common_files/dropzone.cfm", "/styles/ba_upload.css", "/common_files/dhx_message.cfm" ] )#>
		<style>

			#upl18 { font-size: 14px; margin:10px; }
			.hideDisplay{
				display: none;
			}

			fieldset {
  				border-radius: 5px; background-color: white; padding: 5px;
			}
			
		
		</style>
		<div id="upl18">
			<!------------- Dropzone area ------------->
			<div id="myDropId" class="dropzone dz-clickable hideDisplay">
				<div class="dz-message">
					<img class='ba-dz-message' src='/Images/cloud_343540.svg'>
					&nbsp; Drop Excel file here or
					<span style="color:blue">click to upload</span>
				</div>
			</div>
			<!------------- File list Results area ------------->
			<div class="upl-table" id="previews" style="max-width:600px;">
				<!--- upload result gets put here via shared template --->
			</div>

		</div> <!-- #upl18 -->

		<!------------- Dropzone setup ------------->
		<script>
			// <!--- callbacks --->
			doneUploading2 = function(){
				window.close();
			}

			postProcessing = function(good_responses){
				$('#myDropId').toggle('slow', function() {
					$('#myDropId').hide();
					$('#previews').hide();
				});
			}

			setupDropzone(
  				"ajax/import.cfm", //upload url
  				doneUploading2, //callback after acknowledging completion
  				999,    // max files
  				150,   // max size MiB
  				"application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // only accept Excel file types sa xls, xlsx
  				postProcessing    // optional callback
  			);
		</script>
		<!--- end of Dropzone upload --->
<cfscript>
		// Default dates should be for today
		param name="form.from_date"				default="#dateformat(now(),'m/d/yyyy')#";
		param name="form.to_date"				default="#dateformat(now(),'m/d/yyyy')#";

		// Comment out the following line to TEST LOCAL
		cfwebsocket(name="cfDataWs", onMessage="handleMessage", subscribeto="cfData", secure="false");
</cfscript>


<cfoutput>
		
		<form style="width:100%">
		<div id="searchArea">
			
			<div style="display:flex; align-items:start;">
				<fieldset id="refreshData">
					<button class="button" id="BOTRefresh" name="BOTRefresh" title="refresh the list of corrections">refresh data</button>
					<span id="sRefreshTime" style="color:red"></span>
				</fieldset>

				<fieldset id="dateSet">
				<label>Show Dates</label>
				<input type="text" class="date" name="dateRangeStartValueKeyword" value="#form.from_date#" />
				<label>to</label>
				<input type="text" class="date" name="dateRangeEndValueKeyword" value="#form.to_date#" />

			</fieldset>

			<!--- Message area to show upload results --->
            <textarea id="lMessage" rows="5" cols="120" ></textarea>

			</div>

			<div>
			<fieldset id="uploadClearLog">
				<button class="button" id="BOTUpload" name="BOTUpload" title="Upload an Excel spreadsheet of billbacks">Upload File</button>
				<button class="button" title="clear results">Clear Log</button>
			</fieldset>
		
			<fieldset id="search">
				<label>CTM ID ##</label>
				<input type="text" class="medium" id="ctmidN">
				<label style="margin-left: 5px;">Invoice ##</label>
				<input type="text" class="medium" id="invoiceN">
				<label style="margin-left: 5px;">Payee ##</label>
				<input type="text" class="medium" id="payeeN">
				<button class="button recommended" id="BtSearch">Search</button> 
				<button class="button"  id="BtReset">Reset</button>
			</fieldset>
			</div>
		</div>
		</form>

	</cfoutput>
	<!--- ~~~~~~~~~~ grid section ~~~~~~~~~~~ --->
	<section id="upload_grid" class="ag-theme-balham">
	</section>
	
	<!--- Billback detail section at the bottom of the screen --->
	<section class="horiz-aligner">
		<button class="button" title="Click to get a list of Billbacks generated by this upload file" onclick="getCreatedBillbacks();">
			View Billbacks for ID: <span id="bbuploadID"></span>
		</button>
		<!--- Area to load bb list into --->
		<div id="uploadBBList" ></div>&nbsp
		<a href="##" id="upload_file"></a>
	</section>

	<cfset jQueryUI.widgets = "datepicker">
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
									"/common_files/jQueryUI.cfm",
									"/common_files/ag-grid.cfm",
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
		 function handleMessage(message)  {
		    // Output message object to console
		    //console.log(message);
		    if(message.type == 'data'){
			    var s = '[' + message.data.BODY.user + ' @' + message.data.BODY.serial + '] ' + message.data.BODY.message + '\n';
			    s = s + $('#lMessage').val();
				//var sFileName = message.data.BODY.sFileName;
			    $('#lMessage').val(s);
			}
		  }

		function upload() {
			//$('#myDropId').show();
			//alert($('#myDropId').attr('display'));
			$('#myDropId').toggle('slow', function() { 
            });
			return false;
		}

		/*
		// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
		document.addEventListener("DOMContentLoaded", function () {
			buildGrid();
		});
		*/

		const COL = {
						upload_id					:0
						,user_id					:1
                        ,total_header_count			:2
						,total_header_count_failed	:3
                        ,total_header_count_loaded	:4
                        ,total_detail_count			:5
                        ,total_detail_count_failed	:6
                        ,total_detail_count_loaded	:7
                        ,upload_date				:8           
                        ,upload_status				:9
                        ,deleted					:10
                        ,header_file_name			:11
                        ,detail_file_name			:12
                        ,deleted_by					:13
                        ,deleted_date				:14
                        ,upload_type				:15
                        ,VendorSearchField			:16
						,Name_First					:17
						,Name_Last					:18
                        ,BBTitleSearchField			:19
                        ,BBCodeSearchField			:20
                                                       
		};

		var my_grid = {
		
			defaultColDef:	{
						floatingFilterComponentParams: { suppressFilterButton: true }
						,suppressMenu:                  true
						,suppressMovable:               false
						,unSortIcon:                    false
						,sortable:                      true
						,resizable:                     true
						,suppressToolPanel:				true	// Default to no show/hide col, override per column
						,filter:                        'agTextColumnFilter'
			}

			// Define the Grid Columns
			,columnDefs:[
				{headerName: "ID", width:70, valueGetter:function(p){ return p.data[COL.upload_id] }},
				{headerName: "User", width:120, valueGetter:function(p){ return p.data[COL.Name_First] + ' ' +  p.data[COL.Name_Last]}},
				{headerName: "Header",  children: [
					{headerName: "Count",   type:'numericColumn', width:50, valueGetter:function(p){ return p.data[COL.total_header_count] }},
					{headerName: "Failed", type:'numericColumn', width:50, valueGetter:function(p){ return p.data[COL.total_header_count_failed] }},
					{headerName: "Loaded",  type:'numericColumn', width:50, valueGetter:function(p){ return p.data[COL.total_header_count_loaded] }}
					]
				},	
				{headerName: "Detail",  children: [
					{headerName: "Count",  type:'numericColumn', width:50, valueGetter:function(p){ return p.data[COL.total_detail_count] }},
					{headerName: "Failed", type:'numericColumn', width:50, valueGetter:function(p){ return p.data[COL.total_detail_count_failed] }},
					{headerName: "Loaded",  type:'numericColumn', width:50, valueGetter:function(p){ return p.data[COL.total_detail_count_loaded] }}
					]
				},		
				{headerName: "Status", width:240, valueGetter:function(p){ return p.data[COL.upload_status] }},
				{headerName: "Upload Date",  width:130, valueGetter:function(p){ return p.data[COL.upload_date] }},

				{headerName: "File Name", width:240, valueGetter:function(p){ return p.data[COL.header_file_name] }},
				{headerName: "Type", width:100, valueGetter:function(p){ return p.data[COL.upload_type] }},

				{headerName: "BBcode", field: "BBcode", width:100, hide: true,  filter: 'agTextColumnFilter', valueGetter:function(p){ return p.data[COL.BBCodeSearchField] }},
				{headerName: "BBnumber", field: "BBnumber", width:100, hide: true,  filter: 'agTextColumnFilter', valueGetter:function(p){ return p.data[COL.BBTitleSearchField] }},
				{headerName: "Vendor", field: "Vendor", width:100, hide: true, filter: 'agTextColumnFilter', valueGetter:function(p){ return p.data[COL.VendorSearchField] }}
			]

			,blackSmith: { fullHeight: true, height_offset: -102 }
			,floatingFilter: true
			,rowModelType: "clientSide"
			,rowSelection: "single"
			,suppressContextMenu: true
			,enableBrowserTooltips: true
			,statusBar: footerbar("filtered_and_total")
			, onSelectionChanged: onSelectionChanged
			,suppressRowClickSelection: false
		};
	
		function onSelectionChanged() {
			let selectedRows = my_grid.api.getSelectedRows();
			let urlStr = "/getDocument.cfm?filepath=/Data_Files/Settings/Billback_Upload_Files/" + selectedRows[0][11];
			document.querySelector('#bbuploadID').innerHTML = selectedRows[0][0];
			document.querySelector('#upload_file').innerText = selectedRows[0][11];
			document.querySelector('#uploadBBList').innerHTML = '';
			$("#upload_file").attr("onClick", "NewWindow('" + urlStr + "');");
			
		}

		ag_grid_default(my_grid);		// set up default features
		init_ag_grid(my_grid, "#upload_grid", false );   // false=setup as client side

		get_grid_content();

		function get_grid_content() {

			my_grid.api.setRowData( [] );
			my_grid.api.showLoadingOverlay();
			const form = $( "form" );
				$.ajax({
						url: "ajax/upload_history.cfm"
						,data: form.serialize()
						,type: "POST"
						,error: function(xhr, status, error) { error_handler(xhr, status, error) }
						,success: function( result ) {
														if (typeof result === 'string') {
															result = JSON.parse(result);
															my_grid.api.setRowData( result.ROWS );
															var d = new Date();
				              								$("#sRefreshTime").html('&nbsp;&nbsp;&nbsp;Data as of &nbsp;' + moment(d).format('L') + ' ' + moment(d).format('LTS'));
														}
													}
						}
					);
		}
	
		// return the list of billbacks per id (to list in the detail box at the bottom of the screen)
		function getCreatedBillbacks() {

			let selectedRow = my_grid.api.getSelectedRows();
			
			$.ajax({ url: "/mvc/Models/Billback/BillbackUploadManager.cfc"
									,type: "post"
									,data: { 	method: "getBBsForUploadIDJSON",
												UploadID: selectedRow[0][0]
											}
									,async: true
									,error: function(xhr, status, error) { error_handler(arguments); }
									,success: function( result ) {
																	if (typeof result === 'string') {
																		result = JSON.parse(result);
																	}
																	//console.log(result);

																	document.querySelector('#uploadBBList').innerHTML = '';
																	if(result.length === 0){
																		document.querySelector('#uploadBBList').innerHTML =  '<p>No Billbacks</p>';
																	}
																	else{
																		var box = document.querySelector("#uploadBBList")
																		result.forEach(function (item) {
																			// console.log("bbcode: "+item.bbcode+ "and idint:"+item.billbackidint);
																			box.innerHTML += '<p><a href="javascript:parent.parent.create_tab('+item.billbackidint+',\''+item.bbcode+'\' )">' +
																				item.bbcode + '</a></p>';																		
																	});
																	}
																	 
									}
							});

		}

		<!--- ~~~~~ refresh button handler ~~~~~~ --->
        $("button[name=BOTUpload]").click( function(e){
			e.preventDefault();
     		upload();
    		return false;
        });
  		<!--- ~~~~~ refresh button handler ~~~~~~ --->
        $("button[name=BOTRefresh]").click( function(e){
			e.preventDefault();
     		get_grid_content();
    		return false;
        });

        <!--- ~~~~~ search button handler ~~~~~~ --->
        $('#BtSearch').click( function(e){
			e.preventDefault();
     		filter();
    		return false;
        });

        <!--- ~~~~~ reet button handler ~~~~~~ --->
        $('#BtReset').click( function(e){
			e.preventDefault();
     		clearFilters();
    		return false;
        });

        function filter() {
		  var filters = {
		    BBcode: {type: 'contains', filter: $('#ctmidN').val() },
		    BBnumber: { type: 'contains', filter: $('#invoiceN').val() },
		    Vendor: { type: 'contains', filter: $('#payeeN').val() },
		  };

		  my_grid.api.setFilterModel(filters);
		}

		function clearFilters() {
		  my_grid.api.setFilterModel(null);
		  $('#ctmidN').val('');
		  $('#invoiceN').val('');
		  $('#payeeN').val('');
		}

		// handler for clicking collapsible section header
		<!--- SAH
		var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
		var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';
		$( ".sectionHeader" ).on( "click", function() {
			var imgUrl = $(this).children(0).attr('src');
			if ( imgUrl == arrowDown ) {
				$(this).children(0).attr("src", arrowRight);
			}else {
				$(this).children(0).attr("src", arrowDown);
			}
			$(this).next().toggle();        // show/hide following div

			// When open/close section, resize the grid (to take advantage of more room available)
			// adjust_grid_height();
		});
		--->

		$(".date").datepicker({
            dateFormat: "m/d/yy",
            changeMonth: true,
            changeYear: true,
            onSelect: function( selected ) {
                // change date limit based on selected value
                if ( jQuery(this).attr("name") === "dateRangeStartValueKeyword" )
                    jQuery("input[name=dateRangeEndValueKeyword]").datepicker("option", "minDate", selected);
                else
                    jQuery("input[name=dateRangeStartValueKeyword]").datepicker("option", "maxDate", selected);
            }
        });

	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>