<!---
  * ====================================================================================================
  *  @Author: Milan Mushran
  *  @Date: 9-April-2019
  *  Load EDI Detail Grid Data
  * ====================================================================================================
--->
<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />
<cfinclude template="edi_viewer_columns.cfm">

<script>
var rawEDIDetailColumnDefs = [
	{headerName: "Claim Num", field: "CLAIM_NUM", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Start Date", field: "PERIOD_ST_DATE", width:100, filter:'agDateColumnFilter',filterParams:{filterOptions:['equals','greaterThanOrEqual','lessThanOrEqual'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "End Date", field: "PERIOD_END_DATE", width:100, filter:'agDateColumnFilter',filterParams:{filterOptions:['equals','greaterThanOrEqual','lessThanOrEqual'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Agmt #", field: "AGREEMENT_NUM", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Agmt Name", field: "AGREEMENT_NAME", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Dist Name", field: "VENDOR_LOC_NUM", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Dist Name ID", field: "VENDOR_INV_NUM", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "ShipTo Name", field: "DC_AC_NAME", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "ShipTo Name ID", field: "DC_AC_NUM", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Address", field: "ST_ADDRESS_1", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "City", field: "ST_CITY", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "State", field: "ST_STATE", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Zip", field: "ST_ZIP_CODE", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Qty Sold", field: "CS_QTY", width:75,filter: 'agNumberColumnFilter',type: "numericColumn",filterParams:{filterOptions:['equals','greaterThanOrEqual','lessThanOrEqual'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "UPC", field: "UPC_CODE", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Mfr Item ID", field: "MANUFACTURE_ITEM_ID", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Cust Inv Item", field: "DC_PRODUCT_NUM", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Charge Back Amt", field: "AWARD_AMT", width:75,filter: 'agNumberColumnFilter',type: "numericColumn",filterParams:{filterOptions:['equals','greaterThanOrEqual','lessThanOrEqual'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Item Desc", field: "DC_PRODUCT_DESC", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Deleted By", field: "DELETED_BY", width:75,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}},
	{headerName: "Deleted Date", field: "DELETED_DATE", width:100, filter:'agDateColumnFilter',filterParams:{filterOptions:['equals','greaterThanOrEqual','lessThanOrEqual'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}}
];


var RawEDIDetailgridOptions = {
	columnDefs: rawEDIDetailColumnDefs			
	,cacheBlockSize: 20000
	,floatingFilter: true
	,debug: false
	,rowModelType: "serverSide"
	,onFilterModified:  function (params) {filterResultsOnFilterRemove(RawEDIDetailgridOptions)}
}

ag_grid_default (RawEDIDetailgridOptions); // set up default features

AjaxDatasource.prototype.getRows = function(params) {

		$.ajax({type: "post"
				,url: "/settings/EDI_Viewer/ajax/raw_edi_detail_data.cfm"
				,dataType: "json"
				,data: {
						UploadID: <cfoutput>#uploadID#</cfoutput>
						,BBUploadIIIPHID: <cfoutput>#BBUploadIIIPHID#</cfoutput>
						,filterModel: JSON.stringify(params.request.filterModel)
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
						<cfloop from="1" to="#ArrayLen(edi_details_columns_arr )#" index="i">
							arr_columns.push('#edi_details_columns_arr[i]#');
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
							<cfoutput>
							$("##edi_detail_grid_count_#URL.id#").text(0);
							</cfoutput>
						}
						else{
							params.successCallback(data_to_load, data_to_load[0].ROWS_CNT);
							 <cfoutput>
							/* update screen display with record count */
							$("##edi_detail_grid_count_#URL.id#").text(data_to_load[0].ROWS_CNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
							 </cfoutput>
						}
				}
				,error: function(xhr, status, err) {
					alert('error occured');
				}
	});					
};
<cfoutput>
init_ag_grid (RawEDIDetailgridOptions, "##RawEDIDetail_Grid_#URL.id#", true);
</cfoutput>
</script>