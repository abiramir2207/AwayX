
<!DOCTYPE html>
<html lang="en">
<cfscript>
    component_cfc     = createObject("component", "mvc.models.planner.IndirectAllocation");

    qUploadDetail     = component_cfc.getUploadDetail( url.docid );
    qUploadHeader     = component_cfc.getUploadByID( url.docid );
    qallocation       = component_cfc.getHeaders( 'WHERE Planner_Indirect_Allocation_Header_ID              = #qUploadHeader.Planner_Indirect_Allocation_Header_ID#' );
    labels            = component_cfc.getLabels( qUploadHeader.Planner_Indirect_Allocation_Header_ID );

    final_destination = application.doc_path & "\Data_Files\Uploaded\settings\planner_indirect_allocation\";
</cfscript>

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <cfoutput>
    <title>Upload Detail FY #qallocation.Fiscal_year#</title>
    </cfoutput>
</head>
<body>
<cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm">    <!--- jquery is needed for focus.cfm --->

<style>
    body {
        overflow: hidden;
    }
    div.document {
        font-size:12px;
        display:flex;
        align-content: space-evenly;
        justify-content: space-around;
    }
    .center {
        text-align: center;
    }
    <!--- REQUIRED: For now, need to update these "ag-" classes, may move to common file --->
    .ag-theme-balham { font-size: 11px; }
    .ag-header { font-size: 11px !important; }
    .ag-theme-balham .ag-cell {
        padding-left: 2px;
        padding-right: 0px;
    }
    .ag-theme-balham .ag-row-selected {
        border-bottom-color: #b5b5b5; /* don't hide lines when selected */
    }
    span[title]:hover::after {
        background-color: yellow;
    }
    span.error {
        color: red;
    }
</style>

<cfoutput>
<h2 class="center">Upload Detailed Status</h2>
<div class="document">
    <span><b>Document Name</b> #qUploadHeader.Doc_Full_Name#</span>
    <span><b>Uploaded On</b> #Dateformat(qUploadHeader.Uploaded_Date, 'medium')# @  #Timeformat(qUploadHeader.Uploaded_Date, 'short')#</span>
    <span><b>Uploaded By</b> #qUploadHeader.Name# <br></span>
</div>

<div id="distributor_Grid" style="margin:10px 1% 10px; height:85vh; width:98%" class="ag-theme-balham"></div>

<div class="center">
    <button style="cursor:pointer" class="button recommended" onclick="downloadFile( '#qUploadHeader.Doc_Full_Name#' )"> Download </button>
    <button style="cursor:pointer" class="button" onclick="window.close()"> Close </button>
</div>
</cfoutput>

<script>
    <cfoutput>
    let GridOptions = {
                	defaultColDef: {     editable:         false
                                        , resizable:       true
                                        , sortable:        false
                                        , suppressMenu:    true
                                        , suppressMovable: false
                                        , unSortIcon:      false
                                        }
                    ,columnDefs: [
                                    {headerName: "#labels.distributors# ##", field: "direct_number" },
                                    {headerName: "#labels.distributors# Name", field: "direct_name" },
                                    {headerName: "#labels.operators# ##", field: "indirect_number" },
                                    {headerName: "#labels.operators# Name", field: "indirect_name" },
                                    {headerName: "#labels.products#", field: "product" },
                                    {headerName: "#labels.products# Name", field: "product_name" },
                                    {headerName: "Allocation %", field: "allocation_percentage", type: 'numericColumn', width:90 },
                                    {headerName: "Error", field: "error_message", width:450,
                                                    cellRenderer: function(params) { return '<span class="error" title="' + params.data.error_message.replaceAll('.','.\n') + '">' + params.data.error_message + '</span>'; } }
                                ]
                    ,rowData: #application.util.query.toAgGridJSON(qUploadDetail, 'Direct_Number, Direct_Name, Indirect_Number, Indirect_Name, Product, Product_Name, Allocation_Percentage, Error_Message')#
                    ,rowModelType: "clientSide"
                    ,debug: false
                    ,floatingFilter: false
                };
    </cfoutput>
    ag_grid_default( GridOptions );		// set up default features
    init_ag_grid( GridOptions, "#distributor_Grid", false );  // init distributor client-side grid
    GridOptions.api.sizeColumnsToFit();

    $(window).resize(function(){ GridOptions.api.sizeColumnsToFit(); });

    <cfoutput>
    function downloadFile( filename ){
        generate_export( "/GetDocument.cfm?FilePath=#URLEncodedFormat(final_destination)#" + filename );
    }
    </cfoutput>

</script>

<cfinclude template="/common_files/focus.cfm">
</body>
</html>
