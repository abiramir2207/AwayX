<!---
       Name:          UploadHistoryGridManager.cfm
       Copyright:     Copyright (c) 2019 Blacksmith Applications, Inc.
       Created Date:  15-Nov-2019
       Created By:    Anand Rao
       Label:		  
       Description:  This Page loads Upload History Grid data
--->

<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />
<cfset stSearchFilters = structNew()>

<cfinclude template="upload_history_columns.cfm">

<script>
set_grid_full_height("#UploadHistory_Grid");

var isGridInitialized = 0;
var searchFilters = {};

function validationComplete(){
	let bReturnValue = 1;
	if( $( "#Uploaded_User" ).val().length == 0 && $( "#File_Name" ).val().length == 0 && $( "#Upload_Type" ).val().length == 0 
		&& $( "#Uploaded_Date" ).val().length == 0 && $( "#BB_Reference" ).val().length == 0 && $( "#BB_Code" ).val().length == 0 
		&& $( "#Vendor_ID" ).val().length == 0 
		&& $( "#Upload_ID" ).val().length == 0
		&& $( "#BB_Upload_Status" ).val().length == 0 
		&& $( "#Reference_Number_list" ).val().length == 0 && $( "#payable_list" ).val().length == 0
		)		
	{
		alert('Pick/Enter a criteria to search');
		bReturnValue = 0;
	}
return bReturnValue;
}

function getSearchFilters(){
	searchFilters = 
		{
		Uploaded_User: $( "#Uploaded_User" ).val(), 
		File_Name: $( "#File_Name" ).val(),
		Upload_Type: $( "#Upload_Type" ).val(), 
		Uploaded_Date: $( "#Uploaded_Date" ).val(), 
		BB_Reference: $( "#BB_Reference" ).val(), 
		BB_Code: $( "#BB_Code" ).val(), 
		Vendor_ID: $( "#Vendor_ID" ).val(), 
		Upload_ID: $( "#Upload_ID" ).val(), 
		BB_Upload_Status: $( "#BB_Upload_Status" ).val(), 
		match_type: $( "#match_type" ).val(),
		Reference_Number_list: $( "#Reference_Number_list" ).val(),
		payable_list: $( "#payable_list" ).val(),
		lnkClick: $( "#lnkClick" ).val(),
		UploadMonthYear: $( "#UploadMonthYear" ).val()	
		};
}

var uploadHistgoryColumnDefs = [
<cfoutput>
	{headerName: "ID", field: "UPLOAD_ID", width:50},
	{headerName: "Type", field: "UPLOAD_TYPE", width:80},
	{headerName: "Uploaded By", field: "USER_CODE", width:90, tooltipField: 'USER_CODE'  },
	{
	 headerName: "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Header Count",
        children: [
	{headerName: "Total", field: "TOTAL_HEADER_COUNT", width:60,   valueFormatter: numberFormatter, cellClass: "grid-cell-centered" },
	{headerName: "Failed", field: "TOTAL_HEADER_COUNT_FAILED", width:60,  valueFormatter: numberFormatter, cellClass: "grid-cell-centered"},/* type:'numericColumn' */
	{headerName: "Success", field: "TOTAL_HEADER_COUNT_LOADED", width:60, valueFormatter: numberFormatter, cellClass: "grid-cell-centered"},
	],  cellClass: "grid-cell-centered"},
	{
	 headerName: "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detail Count",
        children: [
	
	{headerName: "Total", field: "TOTAL_DETAIL_COUNT", width:60,   valueFormatter: numberFormatter, cellClass: "grid-cell-centered"},
	{headerName: "Failed", field: "TOTAL_DETAIL_COUNT_FAILED", width:60,   valueFormatter: numberFormatter, cellClass: "grid-cell-centered"},
	{headerName: "Success", field: "TOTAL_DETAIL_COUNT_LOADED", width:60,   valueFormatter: numberFormatter, cellClass: "grid-cell-centered"},
	],  cellClass: "grid-cell-centered"
},

	{headerName: "Files", field: "HEADER_FILE_NAME", width:280,  cellClass: "cell-wrap-text", autoHeight: true, tooltipField: 'HEADER_FILE_NAME' },
	{headerName: "Date", field: "UPLOAD_DATE", width:80},
	{headerName: "Status", field: "UPLOAD_STATUS", width:200, 
				  cellRenderer: function(params) { 
				  					let status_link = '';	
									let new_status='';
									if (params.data.UPLOAD_STATUS == 'Header Validation Failed; Detail Validation Failed')
									{
										new_status = 'Validation Failed';
									}
									else
									{
										new_status = params.data.UPLOAD_STATUS;
									}
									status_link = '<a href="##" title="' + params.data.UPLOAD_STATUS  + ': click to view upload errors" onclick="viewdetails(' + params.data.UPLOAD_ID + ');return false;">' + new_status + '</a>';
														// action_link = '<span style="color:##808080">[' + action_link + ']</span>'; 
														return status_link;
									 }
	},
	
	{headerName: "Action", field: "UPLOAD_STATUS", width:50,
				  cellRenderer: function(params) { 
								let Action_link_new = '--';
								if ((params.data.UPLOAD_STATUS == 'Creation Complete') || (params.data.UPLOAD_STATUS == 'Creation Complete - Partial'))
								{
									Action_link_new = '<a href="##" title="click to view associated billbacks" onclick="viewbillbacks(' + params.data.UPLOAD_ID + ',' + params.data.TOTAL_HEADER_COUNT + ',' + params.data.UPLOAD_TYPE_ID + ');return false;">(View)</a>';
								}
								return Action_link_new;
					}
	}
	 
<cfif vars.audit_rpt_on>
	,{headerName: "Audit Report", field: "REPORT_HEADER_FILENAME", width:140,
				  cellRenderer: function(params) { 
								let ReportLink = '--';
								let hdrFileName = '';
								let dtlFileName = '';
								if ((params.data.REPORT_HEADER_FILENAME != '') && (params.data.REPORT_DETAIL_FILENAME != ''))
								{
									hdrFileName = "'" + params.data.REPORT_HEADER_FILENAME + "'";
									dtlFileName = "'" + params.data.REPORT_DETAIL_FILENAME + "'";
									ReportLink = '<a href="##" title="click to view header" onclick="viewHeader(' + hdrFileName + ')">(View Header)</a><a href="##" title="click to view detail" onclick="viewDetail(' + dtlFileName + ')">(View Detail)</a>';
								}
								return ReportLink;
					}
	}
	
	
	</cfif>
</cfoutput>
];

var UploadHistoryGridOptions = {
blackSmith: {fullHeight:true, pleaseWaitSpinner:false, height_offset:12 },
	columnDefs: uploadHistgoryColumnDefs
	,cacheBlockSize: 20000
	,debug: false
    ,rowModelType: "serverSide"
    ,enableRangeSelection: false
    ,suppressRowClickSelection:true
    ,suppressCellSelection: true
	,onRowDoubleClicked: function (params) {
		let claimNum = params.data.CLAIM_NUM;
		let uploadID = params.data.UPLOAD_ID;
		let HdrID = params.data.BILLBACK_UPLOAD_III_PH_ID;
		let ID = uploadID+ '_' + HdrID;
		let urlString = 'BBNum='+params.data.CLAIM_NUM+'&BBDate='+params.data.CLAIM_DATE+'&VendorName='+params.data.VENDOR_NAME+'&VendorNum='+params.data.VENDOR_ID+'&SoldToName='+params.data.DISTRIBUTOR_NAME+'&SoldToNum='+params.data.DISTRIBUTOR_ID+'&TotalAmt='+params.data.E_TOTAL_CLAIMED_AMT+'&Volume='+params.data.TOT_VOLUME
		
		/* Create and open detail tab */
		// createDetailTab(ID,encodeURI(urlString),'ID:' + uploadID + ' / ' + '(' + encodeURI(claimNum) + ')');
    }
}

ag_grid_default (UploadHistoryGridOptions); // set up default features

function loadUploadHistoryData(){

	if(validationComplete() == 0){
		alert('Please enter a search criteria!');
	}
	else{
		getSearchFilters();
		/* For first search. Here the grid is created. */
		if(isGridInitialized == 0){
			AjaxDatasource.prototype.getRows = function(params) {
				$.ajax({ type: "post"
						,url: "ajax/upload_history_data.cfm"
						,dataType: "json"
						,data:{
								searchFilters: JSON.stringify(searchFilters)
								,startRow: params.request.startRow
								,endRow: params.request.endRow
								,sortColumn: params.request.sortModel.length ? params.request.sortModel[0].colId : ""
								,sortOrder: params.request.sortModel.length ? params.request.sortModel[0].sort : ""
							 }
						,success : function (response) {
							var arr_columns = [];
							/* We need the list of columns in javascript, but the columns are defined in CF (program_columns_arr).
							To get the list of columns in javascrpt, we need to loop through the data in CF and create an array 
							in javascript. THis way we can get the same column list in javascript. No need to hardcdde the 
							array in javascript.
							*/
							<cfoutput>
							<cfloop from="1" to="#ArrayLen(uploadHistory_columns_arr)#" index="i">
								arr_columns.push('#uploadHistory_columns_arr[i]#');
							</cfloop>
							</cfoutput>

							<!--- "response" does not have column names defined, but it has the array indexes defined.
							"convertToArrayOfObjects" function will assign column names, so that AG grid can load the 
							data in appropriate columns. --->
							var data_to_load = convertToArrayOfObjects(response,arr_columns);

							if(response.length == 0){
								$("span.ag-loading-icon").hide();
								$("span.ag-loading-text").text("No records found.");
								/* update screen display with record count */
								$("#upload_history_count").text(0);
							}
							else{
								params.successCallback(data_to_load, data_to_load[0].ROWS_CNT);
								/* update screen display with record count */
								$("#upload_history_count").text(data_to_load[0].ROWS_CNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
							}
						}
						,error: function(xhr, status, err) {
						alert(err);
							//alert('error occured');
						}
				});
			};

			init_ag_grid (UploadHistoryGridOptions, "#UploadHistory_Grid", true);
			isGridInitialized = 1;
		}
		else{
			/* No need to create the grid. Just do a search. */
			UploadHistoryGridOptions.api.onFilterChanged();
		}
	}
}

	function viewdetails(id)
	{
		// window.location.href = 'index.cfm?show_tab=6&tab_title=Upload Detail&upload_id=' + id;
		window.open('upload_detail2.cfm?show_tab=6&tab_title=Upload Detail&upload_id=' + id ,null,"height=600,width=1000,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
	} 
 
	function numberFormatter(params) 
 	{
		return new Intl.NumberFormat().format(params.value);
	}

</script>