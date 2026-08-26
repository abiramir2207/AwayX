<cfquery name="getCN" datasource="#application.datasource#">
	SELECT Contract_Number
	FROM Contract_main
	WHERE Contract_Main_ID  = '#url.Contract_Main_ID#'
</cfquery>

<cfquery name="qDataPriorVersions" datasource="#application.datasource#">
<!--- Using STUFF, we can remove commas, when not needed. e.g. when there is only one record.
Note: Comma is needed for comma-delimited list of Acknowledgement ID's.
--->
SELECT CM1.revision_version, CM1.last_extract_date,CM1.external_client_ack_date,
			  STUFF((SELECT ', ' + CAST(FEM2.Deal_ID as varchar(20))
			  FROM Forge_ERP_Mapping FEM2
			  WHERE FEM2.Program_ID =  CM1.Contract_Main_ID
			  AND FEM2.Deleted = 0
			  AND FEM2.Deal_ID IS NOT NULL
			  FOR XML PATH('') ), 1, 2, '') As deal_id
FROM Contract_main CM1
WHERE CM1.Contract_Number = '#getCN.Contract_Number#'
AND CM1.Approved = 1
ORDER BY CM1.revision_version DESC
</cfquery>

<cfinclude template="/common_files/jQuery.cfm">
<!--- Include ag-grids --->
<cfset request.ag_grid_theme = "ba-ag-theme-balham">
<cfinclude template="/common_Files/ag-Grid.cfm">

<style>
	.v-header {
		display: inline-block; 
		width: 90%;
		margin:0 0 5px 25px;
	}
	.right {
		float: right;
	}
	.left {
		float: left;
	}
	.ag-theme-balham .ag-cell {
		text-align: center;
	}
	.ag-theme-balham .ag-header-group-text, 
	.ag-header-cell-text {
		margin: 0px auto 0px auto;		/* Center the header text */
	}
</style>

<div class="v-header">
	<span class="Title5 left">Prior version Interface info <cfoutput>(#getCN.Contract_Number#)</cfoutput> </span>
	<span class="right">
		<button class="button" onclick="exportGrid();">Export to Excel</button>
	</span>
</div>
<!--- <div id="InterfaceInfoGrid" style="margin-left:25px; height:300px; width:565px" class="ag-theme-balham"></div> --->
<div id="InterfaceInfoGrid" style="margin-left:25px; height:300px; width:90%" class="ag-theme-balham"></div>

<!--- Setup Client-side Grids --->
<script>
// Setup the grid
<cfif qDataPriorVersions.recordcount gt 0>
	var InterfaceInfoColumnDefs = [
		{headerName: "Version", field: "revision_version", width:100},
		{headerName: "Sent Date", field: "last_extract_date", width:180},
		{headerName: "Acknowledgement Date", field: "external_client_ack_date", width:180},
		{headerName: "Ack ID's", field: "deal_id", headerTooltip:"If this field is consistently blank for all programs, it is due to the client's configuration.   The client's ERP is not sending an Ack ID back to FORGE." }
	];
	// Init CRA grid
	var InterfaceInfoGridOptions = {
		columnDefs: InterfaceInfoColumnDefs
		,rowData: <cfoutput>#application.util.query.toAgGridJSON(qDataPriorVersions, 'revision_version, last_extract_date, external_client_ack_date, deal_id')#</cfoutput>
		,rowModelType: "clientSide"
		,cacheBlockSize: 2000
		,debug: false
		,enableBrowserTooltips: true
		,onFirstDataRendered: function(params) {
			params.api.sizeColumnsToFit();
		}
	};

	// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
	document.addEventListener("DOMContentLoaded", function () {
		ag_grid_default(InterfaceInfoGridOptions);		// set up default features
		init_ag_grid( InterfaceInfoGridOptions, "#InterfaceInfoGrid", false );
	});

</cfif>

function exportGrid() {
	console.log("prep export");
	excelColKeys = [];
	InterfaceInfoColumnDefs.forEach(function(item){
		excelColKeys.push(item.field);
	});

	var params = {
	        allColumns: false,
	        columnKeys: excelColKeys
	       // onlySelected: getBooleanValue('#onlySelected'),
	        ,fileName: 'prior_version_interface_info.xlsx'
	        //sheetName: ''
	    };

        params.processCellCallback = function(params) {
           switch (params.column.colDef.type) {
			  case 'numericColumn':
			    if(params.value == 0){
			    	return '';
			    }
			    else {
			    	return numberFormatter(params);
			    }
			    break;
			  default:
				return params.value;
			}
        };

	    InterfaceInfoGridOptions.api.exportDataAsExcel(params);
}
</script>