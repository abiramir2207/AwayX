<!---
* ==================================================================================================== 
*    @File: \deployment\redistribution\corrections.cfm
*  @Author: Chris Nguyen
*    @Date: 2019 May - 85971
* 
* @Remarks: Corrections tab on redistribution page
*
*
* 
*  
* ==================================================================================================== 
--->
<cfscript>
    // retrieve a hidden setting for page size
    redistribution_page_size = application.util.query.get_setting("redistribution_page_size", false);

    // if setting is not defined use 500 rows per page
    if (val(redistribution_page_size) eq 0) {
        redistribution_page_size = 500;
    }
</cfscript>

<style>
    label.corr {
        display: inline-block;
        font-weight: bold;
        margin-right: .5rem;
        text-align: right;
        width: 45%;
        opacity: .6;
    }
    i.corr, textarea.corr {
        padding-left: 2px;
        font-style: normal;
        background-color: #EDEEF2;
    }
    i.close {
        color: green;
        font-style: normal;
        float: right;
        padding-left: 5px;
        padding-right: 5px;
    }
    #correction_grid div.ag-cell {
        cursor: pointer;
    }
    .center {
        text-align: center;
    }
    a.refresh {
        margin-right: 15px;
    }
</style>

<div class="corrections">
    <!------------------------------->
    <!--- Edit/Delete Correction  --->
    <!------------------------------->
    <div id="edit_corr" class="mb-2 rounded-lg">
        <cfoutput>
        <p class="pt-1 pl-5 ml-4 tracking-wide">Selected Correction &nbsp; <span class="tracking-wide font-extrabold" id="selected_corr"></span></p>
        <div class="flex p-2">
            <div class="w-1/3 leading-loose">
                <input type="hidden" name="header_primary_key">
                <label class="corr">#config.appSettings.Original_Buyer_Label# Name</label> <i class="corr w-48" name="orig_buyer_name"></i> <br>
                <label class="corr">#config.appSettings.Original_Buyer_Label# #application.returned_customer_setting.Shard_Ship_To_Label#</label> <i class="corr w-48" name="orig_buyer_ship_to"></i> <br>
                <label class="corr">#config.appSettings.Original_Buyer_Label# Inv. ##</label> <i class="corr" name="orig_buyer_inv"></i> <br>
                <div class="mt-3 ml-4">
                    <button class="button recommended edit_corr" disabled>edit</button>
                    <button class="button delete_corr" disabled>delete</button>
                </div>
            </div>
            <div class="w-1/3 leading-loose">
                <label class="corr">#config.appSettings.Final_Buyer_Label# Name</label> <i class="corr w-48" name="ult_buyer_name"></i> <br>
                <label class="corr">#config.appSettings.Final_Buyer_Label# Buyer #application.returned_customer_setting.Shard_Ship_To_Label#</label> <i class="corr w-48" name="ult_buyer_ship_to"></i> <br>
                <label class="corr">PO ##</label> <i class="corr" name="po_number"></i> <br>
            </div>
            <div class="w-1/3 leading-loose">
                <label class="corr">#config.appSettings.Original_Buyer_Label# Inv. Date</label> <i class="corr" name="orig_buyer_inv_date"></i> <br>
                <label class="corr">Total Cases</label>           <i class="corr" name="total_cases"></i> <br>
                <label class="corr">Total Dollars</label>         <i class="corr" name="total_dollars"></i> <br>
                <label class="corr align-top">Message</label>     <textarea name="message" readonly class="corr w-48"></textarea>
            </div>
        </div>
        </cfoutput>       
    </div>

    <!---------------------------->
    <!--- Corrections Actions  --->
    <!---------------------------->
    <div id="corr_action" class="mb-0 flex pt-0 pb-2 justify-between">
        <div class="mr-3">
            <button class="button delete_selected">delete selected</button>
            <label class="ml-4"><input type="checkbox" name="only_reprocess"> show only reprocess</label>
            <button class="button reprocess" disabled>reprocess</button>
            <button class="button clear_filters">clear filters</button>
            <button class="button export">export</button>                
            <button class="button" id="close_all_edit" disabled>close all edit</button>
        </div>
        <div>
            <cfoutput>
                <a href="##" class="refresh">#application.util.string.linkFormat("refresh")#</a>
                <a href="##" class="alias_management">#application.util.string.linkFormat("alias management")#</a>
            </cfoutput>
        </div>
    </div>

    <!------------------------->
    <!--- Corrections Grid  --->
    <!------------------------->
    <div id="correction_grid" class="ag-theme-balham">
    </div>
</div>  <!--- class="corrections" --->


<script>
    <!--- these are the JS positions of columns in the returned JSON data --->
    const corr_index = {
                          upload_id           : 0
                        , source_num          : 1
                        , source_type         : 2
                        , orig_buyer_inv      : 3
                        , orig_buyer_inv_date : 4
                        , orig_buyer_name     : 5
                        , orig_buyer_ship_to  : 6
                        , ult_buyer_name      : 7
                        , ult_buyer_ship_to   : 8
                        , po_number           : 9
                        , total_cases         : 10
                        , total_dollars       : 11
                        , message             : 12
                        , header_primary_key  : 13
                        };
    // set_grid_full_height("correction_grid");

    let correction_grid = {
        columnDefs: [
                     { headerName:'Upload ID ', valueGetter:function(p){return p.data[ corr_index.upload_id ]}, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true, sort:'desc' }
                    ,{ headerName:'Source #', valueGetter:function(p){return p.data[ corr_index.source_num ]} }
                    ,{ headerName:'Source', valueGetter:function(p){return p.data[ corr_index.source_type ]} }
                    ,{ headerName:'Invoice #', valueGetter:function(p){return p.data[ corr_index.orig_buyer_inv ]}, sort:'desc', cellClass:'stringType' }
                    ,{ headerName:'Inv. Date', valueGetter:function(p){return p.data[ corr_index.orig_buyer_inv_date ]}, filter:false, valueFormatter:function(p){return dateFormat(p.data[ corr_index.orig_buyer_inv_date ],'MM/DD/YYYY')}} 
                    ,{ headerName:'Orig. Buyer Name', valueGetter:function(p){return p.data[ corr_index.orig_buyer_name ]} }
                    ,{ headerName:'Orig. Buyer <cfoutput>#application.returned_customer_setting.Shard_Ship_To_Label#</cfoutput>', valueGetter:function(p){return p.data[ corr_index.orig_buyer_ship_to ]} }
                    ,{ headerName:'Ult. Buyer Name', valueGetter:function(p){return p.data[ corr_index.ult_buyer_name ]} }
                    ,{ headerName:'Ult. Buyer <cfoutput>#application.returned_customer_setting.Shard_Ship_To_Label#</cfoutput>', valueGetter:function(p){return p.data[ corr_index.ult_buyer_ship_to ]}, cellClass:'stringType' }
                    ,{ headerName:'PO #', valueGetter:function(p){return p.data[ corr_index.po_number ]}, cellClass:'stringType' }
                    ,{ headerName:'Total', valueGetter:function(p){return p.data[ corr_index.total_cases ]}, type:'numericColumn', filter:false }
                    ,{ headerName:'Total $', valueGetter:function(p){return p.data[ corr_index.total_dollars ]}, valueFormatter:function(p){return currencyFormat(p.data[ corr_index.total_dollars ])}, type:'numericColumn', filter:false }
                    ,{ headerName:'Message', valueGetter:function(p){return p.data[ corr_index.message ]}, width:350 }
                    // ,{ headerName:'Header Primary Key', valueGetter:function(p){return p.data[ corr_index.header_primary_key ]}, hide:true }
                ]
        ,defaultColDef:              {
                                           editable:                      false
                                          ,filterParams:                  { apply: false }
                                          ,floatingFilterComponentParams: { suppressFilterButton: true }
                                          ,suppressMenu:                  true
                                          ,suppressMovable:               false
                                          ,unSortIcon:                    false
                                          ,sortable:                      true
                                          ,resizable:                     true
                                          ,filter:                        'agTextColumnFilter'
                                    }
        ,enableRangeSelection:      false
        ,floatingFilter:            true
        ,getRowNodeId:              function(data) { return data[ corr_index.header_primary_key ] }
        ,onFirstDataRendered:       function(params) { params.api.sizeColumnsToFit() }
        ,onRowClicked:              onRowClicked
        ,onCellDoubleClicked:       function(event) { edit_correction( event.node.data[ corr_index.header_primary_key ] ) }
        ,pagination:                false
        ,paginationPageSize:        <cfoutput>#redistribution_page_size#</cfoutput>
        ,rowModelType:              "clientSide"
        ,rowSelection:              "multiple"
        ,suppressContextMenu:       true
        ,suppressRowClickSelection: true
        ,onRowSelected:             onRowClicked
        ,statusBar:                 footerbar("filtered_and_total")
    };

    function onRowClicked(event) {
        $("button.edit_corr").removeAttr("disabled");
        $("button.delete_corr").removeAttr("disabled");
        $("#selected_corr").text( event.node.data[ corr_index.source_num ]
                                    + " "
                                    + event.node.data[ corr_index.source_type ] 
                                    + " :: "
                                    + "[ ecid " + event.node.data[ corr_index.header_primary_key ] + " ]" );
        $("i[name=orig_buyer_name]").text(event.node.data[ corr_index.orig_buyer_name ]);
        $("i[name=orig_buyer_ship_to]").text(event.node.data[ corr_index.orig_buyer_ship_to ]);
        $("i[name=orig_buyer_inv]").text(event.node.data[ corr_index.orig_buyer_inv ]);

        $("i[name=ult_buyer_name]").text(event.node.data[ corr_index.ult_buyer_name ]);
        $("i[name=ult_buyer_ship_to]").text(event.node.data[ corr_index.ult_buyer_ship_to ]);
        $("i[name=po_number]").text(event.node.data[ corr_index.po_number ]);

        $("i[name=orig_buyer_inv_date]").text(dateFormat(event.node.data[ corr_index.orig_buyer_inv_date ]));
        $("i[name=total_cases]").text(event.node.data[ corr_index.total_cases ]);
        $("i[name=total_dollars]").text(currencyFormat(event.node.data[ corr_index.total_dollars ]));
        $("textarea[name=message]").val(event.node.data[ corr_index.message ]);
        $("input[name=header_primary_key]").val(event.node.data[ corr_index.header_primary_key ]);
    }

    ag_grid_default( correction_grid );
    
    init_ag_grid( correction_grid, "#correction_grid", false );  

    function refresh_corrections() {
        $.ajax({
                 url: "ajax/corrections.cfm"
                ,data: { returnFormat: "json", only_reprocess: ($("input[name=only_reprocess]:checked").length ? 1 : 0) }
                ,success: function( result ) {
                                                if (typeof result === 'string') { 
                                                    result = JSON.parse(result); 
                                                }
                                                correction_grid.api.setRowData( result.ROWS );
                                            }
                ,type: "POST"
                ,error: function(xhr, status, error) { error_handler(arguments) }
            });
    }
    refresh_corrections();

    // keep track of browser tabs
    const redistribution_page = { tabs: [] };
    function opentab( name ) {
        // browser tab is already opened
        if (redistribution_page.tabs[ name ] && !redistribution_page.tabs[ name ].closed) {
            redistribution_page.tabs[ name ].focus();
        }
        else {
            // browser tab not yet opened
            switch (name.toLowerCase().trim()) {
                case 'alias_management':
                    redistribution_page.tabs[ name ] = window.open("/settings/Alias_Management/AliasMain.cfm", "_blank");                    
                    break;            
                default:
                    break;
            }
        }
    }

    $("button#close_all_edit").click(function(){
        $("li.navi").each(function(){
            let li_name = $(this).attr("name");
            if  ( (li_name !== 'corrections') && (li_name !== 'history') ) {
                close_edit_tab(li_name);
            }
        });
    });

    ///////////////////////////////
    //  [ edit button ] event   //
    //////////////////////////////
    $("#page-container").on("click", "button.edit_corr", function(e){
        edit_correction( $("input[name=header_primary_key]").val() );
    });

    /////////////////////////////////////////////////////
    // Create, activate edit tab for selected correction
    /////////////////////////////////////////////////////
    function edit_correction( header_primary_key ) {
        if (header_primary_key == '') {
            return;
        }
        let tabs = $("ul#pagetabs");
        if (tabs.find("li." + header_primary_key).length) {
            var is_tab_opened = true;
        }
        // if edit tab does not exist create a new edit tab
        else {
            var is_tab_opened = false;
        }
        // too many opened tabs? corrections, history + 7 edit tabs = 9 tabs
        if (tabs.find("li").length >= 9 && is_tab_opened === false) {
            dhx_alert( "Maximum number of edits has been reached.<br>Please close some existing edits first." );
            return;
        }
        // is edit tab already opened?
        // if edit tab does not exist create a new edit tab
        if (is_tab_opened === false) {
            tabs.append( $("<li></li>", {
                                               "name":  header_primary_key
                                             , "class": "navi " + header_primary_key
                                             , "text":  "Edit " + header_primary_key
                                        })
                            // append letter x to allow closing tab
                            .append( $("<i></i>", { 
                                                       "title":     "close tab"
                                                     , "class":     "close"
                                                     , "header_id": header_primary_key
                                                     , "text":      "X"
                                                } ) ) );
            // add a div container for newly created edit tab
            $("div#page-container").append( $('<div></div>', { "class": header_primary_key }) );
        }
        // activate page tab
        activate_tab( header_primary_key );
        // retrieve page tab content
        if (is_tab_opened == false) {
            load_edit_tab(header_primary_key);
        }
    }

    ////////////////////////////////
    //  [ delete button ] event   //
    ////////////////////////////////
    $("#page-container").on("click", "button.delete_corr", function(e){
        let header_primary_key = $("input[name=header_primary_key]").val();
        if (header_primary_key !== '') {
            noty( { text: "Please confirm you wish to delete the selected correction."
                    ,type:'confirm'
                    ,layout:'center'
                    ,killer:true
                    ,modal:true
                    ,buttons: [  { text:'Delete', addClass:'btn-primary', onClick:function($noty) {  $noty.close();
                                                                                                     delete_corrections( header_primary_key );
                                                                                                    } }
                                ,{ text:'Cancel', onClick:function($noty) { $noty.close(); } } ]
            });            
        }
    });

    /////////////////////////////////////////
    //  [ delete selected button ] event   //
    /////////////////////////////////////////
    $("#page-container").on("click", "button.delete_selected", function(e){
       let selected = correction_grid.api.getSelectedNodes();
       if (selected.length) {
            noty( { text: "Please confirm you wish to delete the selected "
                                + (selected.length == 1 ? "" : numeral(selected.length).format("0,0"))
                                + " correction" 
                                + (selected.length == 1 ? '.' : 's.')
                    ,type:'confirm'
                    ,layout:'center'
                    ,killer:true
                    ,modal:true
                    ,buttons: [ { text:'Delete', addClass:'btn-primary', onClick:function($noty) {     $noty.close();
                                                                                                        let ids = [];
                                                                                                        for (let i = 0; i < selected.length; i++) {
                                                                                                            ids.push(selected[i].data[ corr_index.header_primary_key ]);
                                                                                                        }
                                                                                                        delete_corrections( ids.join(",") );
                                                                                                    } }
                                ,{ text:'Cancel', onClick:function($noty) { $noty.close(); } } ]
            });
       }
    });

    ////////////////////////////////
    // Delete selected corrections
    ////////////////////////////////
    function delete_corrections( ids ) {
        correction_grid.api.showLoadingOverlay();
        $.ajax({
             url: "ajax/corrections.cfm"
            ,data: { returnFormat: "json", action: "delete", ids_list: ids  }
            ,success: function( result ) {
                                            if (typeof result === 'string') { 
                                                result = JSON.parse(result); 
                                            }
                                            // the correction displayed in the header was selected to delete
                                            if (ids.indexOf( $("input[name=header_primary_key]").val() ) !== -1) {
                                                // clear the top selected correction
                                                reset_header();
                                            }
                                            correction_grid.api.setRowData( result.ROWS );
                                        }
            ,type: "POST"
            ,error: function(xhr, status, error) { error_handler(arguments) }
        });
    }

    ////////////////////////////////////////////////
    // Clear out information displayed in the header
    ////////////////////////////////////////////////
    function reset_header() {
        $("#selected_corr").text('');
        $("i[name=orig_buyer_name]").text('');
        $("i[name=orig_buyer_ship_to]").text('');
        $("i[name=orig_buyer_inv]").text('');

        $("i[name=ult_buyer_name]").text('');
        $("i[name=ult_buyer_ship_to]").text('');
        $("i[name=po_number]").text('');

        $("i[name=orig_buyer_inv_date]").text('');
        $("i[name=total_cases]").text('');
        $("i[name=total_dollars]").text('');
        $("textarea[name=message]").val('');
        $("input[name=header_primary_key]").val('');        

        $("button.edit_corr").attr("disabled", "disabled");
        $("button.delete_corr").attr("disabled", "disabled");
    }

    $("input[name=only_reprocess]").click(function(){
        if ($(this).is(":checked")) {
            $("button.reprocess").removeAttr("disabled");
        }
        else {
            $("button.reprocess").attr("disabled", "disabled");
        }
        reset_header();
        correction_grid.api.showLoadingOverlay();
        refresh_corrections();
    });

    $("button.clear_filters").click(function(){
        correction_grid.api.setFilterModel(null);
    });

    $("button.export").click(function(){
        let d           = new Date();
        let date_string = d.getFullYear() + '' + (d.getMonth()+1) + '' + d.getDate() + "_" + d.getHours() + '' + d.getMinutes();
        correction_grid.api.exportDataAsExcel( { fileName: "redistribution_export", sheetName: "OpenRediCorrections" + date_string } );
    });

    $("a.refresh").click(function(){
        // window.location = window.location;
        reset_header();
        correction_grid.api.showLoadingOverlay();
        refresh_corrections();
    });
</script>
