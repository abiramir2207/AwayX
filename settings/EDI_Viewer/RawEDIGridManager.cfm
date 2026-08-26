<!---
  * ====================================================================================================
  *  @Author: Milan Mushran
  *  @Date: 29-March-2019
  *  Load EDI Grid Data
  * ====================================================================================================
--->
<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />
<cfset stSearchFilters = structNew()>

<cfinclude template="edi_viewer_columns.cfm">

<script>
set_grid_full_height("#RawEDI_Grid");

var isGridInitialized = 0;
var searchFilters = {};

function validationComplete(){
	let bReturnValue = 1;

	if( $( "#bb_number" ).val().length == 0 && $( "#bb_date" ).val().length == 0 && $( "#Vendor_ID" ).val().length == 0 
		&& $( "#vendor_name" ).val().length == 0 && $( "#agreement_number" ).val().length == 0 && $( "#agreement_name" ).val().length == 0 
		&& $( "#payee_number" ).val().length == 0 && $( "#payee_name" ).val().length == 0 && $( "#upload_id" ).val().length == 0
		&& $( "#volume" ).val().length == 0 && $( "#hdr_id" ).val().length == 0 && $( "#deleted_by" ).val().length == 0
		&& $( "#total_amt" ).val().length == 0 && $( "#deleted_date" ).val().length == 0
		)
	{
		bReturnValue = 0;
	}

return bReturnValue;
}

function getSearchFilters(){
	searchFilters = 
		{
		BBNumberKeyword: $( "#bb_number" ).val(), 
		BBDateKeyboard: $( "#bb_date" ).val(), 
		VendorNumber: $( "#Vendor_ID" ).val(),
		VendorName: $( "#vendor_name" ).val(),
		AgreementNumber: $( "#agreement_number" ).val(),
		AgreementName: $( "#agreement_name" ).val(),
		PayeeNumber: $( "#payee_number" ).val(),
		PayeeName: $( "#payee_name" ).val(),
		UploadID: $( "#upload_id" ).val(),
		Volume: $( "#volume" ).val(),
		HdrID: $( "#hdr_id" ).val(),
		DeletedBy: $( "#deleted_by" ).val(),
		TotalAmt: $( "#total_amt" ).val(),
		DeletedDate: $( "#deleted_date" ).val()
		};
}

var rawEDIColumnDefs = [
<cfoutput>
	{headerName: "ID", field: "UPLOAD_ID", width:65},
	{headerName: "Hdr ID", field: "BILLBACK_UPLOAD_III_PH_ID", width:50},
	{headerName: "#stBBLabels.Billback# ##", field: "CLAIM_NUM", width:170},
	{headerName: "#stBBLabels.Billback# Date", field: "CLAIM_DATE", width:100},
	{headerName: "#stBBLabels.Vendor# ##", field: "VENDOR_ID", width:100},
	{headerName: "#stBBLabels.Vendor# Name", field: "VENDOR_NAME", width:170},
	{headerName: "#application.returned_customer_setting.shard_ship_to_label# ##", field: "DISTRIBUTOR_ID", width:75},
	{headerName: "#application.returned_customer_setting.shard_ship_to_label# Name", field: "DISTRIBUTOR_NAME", width:170},
	{headerName: "Total Amt", field: "E_TOTAL_CLAIMED_AMT", type: "numericColumn", width:75},
	{headerName: "Volume", field: "TOT_VOLUME", type: "numericColumn", width:75},
	{headerName: "Deleted By", field: "DELETED_BY", width:170},
	{headerName: "Deleted Date", field: "DELETED_DATE", width:80}
</cfoutput>
];

var RawEDIgridOptions = {
	columnDefs: rawEDIColumnDefs			
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
		createDetailTab(ID,encodeURI(urlString),'ID:' + uploadID + ' / ' + '(' + encodeURI(claimNum) + ')');
    }
}

ag_grid_default (RawEDIgridOptions); // set up default features

function loadRawEDIData(){
	if(validationComplete() == 0){
		alert('Please enter a search criteria!');
	}
	else{
		getSearchFilters();

		/* For first search. Here the grid is created. */
		if(isGridInitialized == 0){
			AjaxDatasource.prototype.getRows = function(params) {
				$.ajax({ type: "post"
						,url: "/settings/EDI_Viewer/ajax/raw_edi_header_data.cfm"
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
							<cfloop from="1" to="#ArrayLen(edi_columns_arr )#" index="i">
								arr_columns.push('#edi_columns_arr[i]#');
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
								$("#edi_grid_count").text(0);
							}
							else{
								params.successCallback(data_to_load, data_to_load[0].ROWS_CNT);
								/* update screen display with record count */
								$("#edi_grid_count").text(data_to_load[0].ROWS_CNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
							}
						}
						,error: function(xhr, status, err) {
							alert('error occured');
						}
				});
			};

			init_ag_grid (RawEDIgridOptions, "#RawEDI_Grid", true);
			isGridInitialized = 1;
		}
		else{
			/* No need to create the grid. Just do a search. */
			RawEDIgridOptions.api.onFilterChanged();
		}
	}
}
</script>