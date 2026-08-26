<!---
* ==================================================================================================== 
*    @File: \deployment\redistribution\history.cfm
*  @Author: Chris Nguyen
*    @Date: 2019 May 
* 
* @Remarks: History tab on redistribution page
*
* ==================================================================================================== 
--->

<div class="history">
    <!--- <div id="open_history" class="mb-2 rounded-lg"><p style="padding:7px 0 0 15px" id="history_count">History of Corrections Results:</p></div> --->

    <div id="history_grid" class="ag-theme-balham">
    </div>    
</div>


<!--- these are the JS positions of columns in the returned JSON data --->
<cfscript>
    hist.ajax                  = {};
    hist.ajax.upload_id        = 0;
    hist.ajax.source_type      = 1;
    hist.ajax.source_type_desc = 2;
    hist.ajax.header_count     = 3;
    hist.ajax.header_failed    = 4;
    hist.ajax.header_loaded    = 5;
    hist.ajax.detail_count     = 6;
    hist.ajax.detail_failed    = 7;
    hist.ajax.detail_loaded    = 8;
    hist.ajax.file_name        = 9;;
    hist.ajax.run_date         = 10;
</cfscript>

<script>
    let history_grid = {
        <cfoutput>
        columnDefs: [
                     { headerName:'Upload ID', valueGetter:function(p){return p.data[ #hist.ajax.upload_id# ]}, sort:'desc' }
                    ,{ headerName:'Partner ID', valueGetter:function(p){return p.data[ #hist.ajax.source_type# ]} }
                    ,{ headerName:'Partner Name', valueGetter:function(p){return p.data[ #hist.ajax.source_type_desc# ]} }

                    ,{ headerName:'Header Count', valueGetter:function(p){return p.data[ #hist.ajax.header_count# ]}, type:'numericColumn', filter:false }
                    ,{ headerName:'Header Failed', valueGetter:function(p){return p.data[ #hist.ajax.header_failed# ]}, type:'numericColumn', filter:false }
                    ,{ headerName:'Header Loaded', valueGetter:function(p){return p.data[ #hist.ajax.header_loaded# ]}, type:'numericColumn', filter:false }

                    ,{ headerName:'Detail Count', valueGetter:function(p){return p.data[ #hist.ajax.detail_count# ]}, type:'numericColumn', filter:false }
                    ,{ headerName:'Detail Failed', valueGetter:function(p){return p.data[ #hist.ajax.detail_failed# ]}, type:'numericColumn', filter:false }
                    ,{ headerName:'Detail Loaded', valueGetter:function(p){return p.data[ #hist.ajax.detail_loaded# ]}, type:'numericColumn', filter:false }

                    ,{ headerName:'File Name', valueGetter:function(p){return p.data[ #hist.ajax.file_name# ]} }
                    ,{ headerName:'Inv. Date', valueGetter:function(p){return p.data[ #hist.ajax.run_date# ]}, valueFormatter:function(p){return dateFormat(p.data[ #hist.ajax.run_date# ],'MM/DD/YYYY')} }
                ]
        </cfoutput>                
        ,defaultColDef:              {
                                            editable:                      false
                                          , filterParams:                  { apply: false }
                                          , floatingFilterComponentParams: { suppressFilterButton: true }
                                          , suppressMenu:                  true
                                          , suppressMovable:               false
                                          , unSortIcon:                    false
                                          , sortable:                      true
                                          , resizable:                     true
                                          , filter:                        'agTextColumnFilter'
                                    }
        , enableRangeSelection:      false
        , floatingFilter:            true
        , onFirstDataRendered:       function(params) { params.api.sizeColumnsToFit() }
        , pagination:                false
        , paginationPageSize:        <cfoutput>#redistribution_page_size#</cfoutput>
        , rowModelType:              "clientSide"
        , suppressContextMenu:       true
        , suppressRowClickSelection: true
        , statusBar:                 footerbar("filtered_and_total")
    };

    ag_grid_default( history_grid );
    init_ag_grid( history_grid, "#history_grid", false );  

    // pulls history data and render on display
    function load_history() {
        set_grid_full_height("history_grid");

        $.ajax({
            url: "ajax/history.cfm"
            ,data: { returnFormat: "json" }
            ,success: function( result ) {
                if (typeof result === 'string') { 
                    result = JSON.parse(result); 
                }
                history_grid.api.setRowData( result.ROWS );
            }
            ,type: "POST"
            ,error: function(xhr, status, error) { error_handler(xhr, status, error) }
        });
    }
</script>