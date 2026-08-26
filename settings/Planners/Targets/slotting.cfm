<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\slotting.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Slotting
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
    </cfscript>
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ Backend posting logic ~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif cgi.request_method is "post">
        <cfif form.action is "save">
            <cfset targets_cfc.setSlotting( form )>
        </cfif>
    </cfif>
</cfsilent>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cf_include files="/styles/ag-grid-ba.css">

    <cfscript>
        qHeader = targets_cfc.getTargets(url.id);
        header_height = qHeader.Slotting_Updated_Date neq '' ? 75 : 36;
    </cfscript>
    
    <style>
        p {
            margin: 10px;
        }
        div#actions {
            margin: 10px;            
        }
        .rightA {
            text-align: right;
        }
        input.mass {
            width: 80%;
        }
        div.edit {
            padding-left: 7px;
        }
        i.mass_apply {
            cursor: pointer;
        }
        form {
            height: 100%;
        }
        <cfoutput>
            div.header {
                height: #header_height#px;
            }
            div.ag-grid {
                padding-top: #header_height#px;
            }
        </cfoutput>
        label {
            user-select: none;
        }
    </style>

    <cfset save_permission = targets_cfc.getSlottingSaveApproveOptions(url.id)>
    <!--- <cfdump var="#save_permission#" abort="true"> --->

    <cfoutput>       
        <div class="header">
            <cfif qHeader.Slotting_Updated_Date neq ''>
                <p class="last_changed">Last updated on <b>#dateFormat(qHeader.Slotting_Updated_Date, "medium")#</b> at #timeFormat(qHeader.Slotting_Updated_Date, "short")# by <b>#qHeader.Slotting_Updated_By#</b>
                    <span class="changes_made" style="display:none;float:right;padding-right:5px;color:red;"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Changes have been made. Remember to save them.</span>
                </p>
            </cfif>

            <div id="actions">
                <button class="button save recommended">#(save_permission.approve gt 0 ? "Save/Approve" : "Save")#</button>
                <button class="button export">Export</button>
            </div>            
        </div>

        <form name="slotting" method="post" action="slotting.cfm?id=#url.id#">
            <input type="hidden" name="id" value="#url.id#">
            <input type="hidden" name="action">
            <input type="hidden" name="fiscal_year" value="#qHeader.fiscal_year#">
            <input type="hidden" name="Main_Distributor_Group_ID" value='#qHeader.main_distributor_group_id#'>
        
            <div id="aggrid" class="ag-theme-balham ag-grid"></div>   
        </form>
    </cfoutput>

    <!--- <cfset request.ag_grid_version = "23"> --->
    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /script/javascript/numeral.min.js, /styles/css-loader.css, /styles/font-awesome.min.css">

    <style>
        .ag-header-cell-label .ag-header-cell-text {
            white-space: pre;
        }        
        .ag-header-cell-label {
            justify-content: center;
        }
        input.rate, input.mass_rate {
            width: 70%;
            position: relative;
            top: -1px;
        }
        .editable {
            /* border: none; */
        }
        .border1 {
            border-right: 2px solid #444 !important;
        }
    </style>

    <cf_include files="hide_zeros.js">

    <script>
        'use strict';
        
        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid", tab_name:"slotting", totals:{}, not_released:{} };
  
        const CURRENCY_FORMAT = '($0,0)';
        const MASS_APPLY      = true;

        glob.my_grid = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: true
                                    ,unSortIcon:      false
                                    ,sortable:        true
                                    ,resizable:       true
                                    ,cellStyle: function(p) { return ( (p.column.colDef.type !== "numericColumn") || isNaN(p.value) )
                                                                        ? null 
                                                                        : Number(p.value) < 0
                                                                            ? {color: 'red'} 
                                                                            : null }
                               }
                ,columnDefs: [
                                 { headerName:<cfoutput>"#targets_cfc.getPostionTypeLabel(qHeader.Slotting_Position_Type)#"</cfoutput>, field:"POSITION_LABEL", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:200, floatingFilter: true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true
                                    // ,pinnedRowCellRendererParams: { style: { "text-align":"center", "font-weight":"bold" } }
                                 }
                                ,{ headerName:"Slotting Fund", field:"SLOTTING_FUND"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SLOTTING_FUND, CURRENCY_FORMAT) }
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass mass_apply" name="SLOTTING_FUND" placeholder="mass apply" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="SLOTTING_FUND" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,editable:function(p) { 
                                                            return p.node.isRowPinned() && p.node.data.POSITION_LABEL == "TOTAL" ? false : true 
                                                        }
                                    ,cellClass:function(p) { return p.node.isRowPinned() && p.node.data.POSITION_LABEL == "TOTAL" 
                                                                        ? ["rightA"]
                                                                        : ["rightA", "editable"] }
                                    ,width:100, filter:false, floatingFilter: false, sortable:true, valueParser: numberParser }
                                ,{ headerName:"Slot Fund Override", field:"SLOTTING_FUND_OVERRIDE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SLOTTING_FUND_OVERRIDE, CURRENCY_FORMAT) }
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass mass_apply" name="SLOTTING_FUND_OVERRIDE" placeholder="mass apply" tabindex="-1" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="SLOTTING_FUND_OVERRIDE" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,editable:function(p) { 
                                                            return p.node.isRowPinned() && p.node.data.POSITION_LABEL == "TOTAL" ? false : true 
                                                        }
                                    ,cellClass:function(p) { return p.node.isRowPinned() && p.node.data.POSITION_LABEL == "TOTAL" 
                                                                        ? ["rightA"]
                                                                        : ["rightA", "editable"] }
                                    ,type:'numericColumn', filter:false, width:150, floatingFilter: false, sortable:true, valueParser: numberParser }
                                ,{ headerName:"Final Slotting\n Fund", field:"SLOTTING_FUND_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SLOTTING_FUND_FINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:"rightA" }
                                ,{ headerName:"Approved Fin\n Slotting Fund", field:"SLOTTING_FUND_APPROVED_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SLOTTING_FUND_APPROVED_FINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:120, floatingFilter: false, cellClass:"rightA" }
                            ]
                ,enableRangeSelection:      false
                ,floatingFilter:  true
                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              "multiple"
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
                ,onGridReady:               function(p) { mass_apply_event() }
                ,onBodyScroll:              function(p) { mass_apply_event() }
                ,getRowStyle:               function(p) { if (p.node.rowPinned) { return { 'font-weight': 'bold' } } }
                ,onFilterChanged: function(e) { show_totals() }
                ,onCellValueChanged: function(e) { show_totals() }
                ,excelStyles: [
                                { id: "rightA", numberFormat: {format: '$#,###,##0;[Red]($#,###,##0)'} }
                                ,{ id: "perc", numberFormat: {format: '##,##0.0%;[Red](##,##0.0)%'} }
                            ]
            };

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  calculate totals and show them in the footer  --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function show_totals() {
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~ initialize totals to zero ~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.totals.SLOTTING_FUND                = 0;
            glob.totals.SLOTTING_FUND_APPROVED_FINAL = 0;
            glob.totals.SLOTTING_FUND_FINAL          = 0;
            glob.totals.SLOTTING_FUND_OVERRIDE       = 0;
            glob.totals.X_SLOTTING_FUND              = 0;
            glob.totals.X_SLOTTING_FUND_OVERRIDE     = 0;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~ calculate totals for visible rows ~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                glob.totals.SLOTTING_FUND                += rowNode.data.SLOTTING_FUND !== null ? +rowNode.data.SLOTTING_FUND : 0;
                glob.totals.SLOTTING_FUND_APPROVED_FINAL += rowNode.data.SLOTTING_FUND_APPROVED_FINAL !== null ? +rowNode.data.SLOTTING_FUND_APPROVED_FINAL : 0;
                glob.totals.SLOTTING_FUND_FINAL          += rowNode.data.SLOTTING_FUND_FINAL !== null ? +rowNode.data.SLOTTING_FUND_FINAL : 0;
                glob.totals.SLOTTING_FUND_OVERRIDE       += rowNode.data.SLOTTING_FUND_OVERRIDE !== null ? +rowNode.data.SLOTTING_FUND_OVERRIDE : 0;
                glob.totals.X_SLOTTING_FUND              += rowNode.data.X_SLOTTING_FUND !== null ? +rowNode.data.X_SLOTTING_FUND : 0;
                glob.totals.X_SLOTTING_FUND_OVERRIDE     += rowNode.data.X_SLOTTING_FUND_OVERRIDE !== null ? +rowNode.data.X_SLOTTING_FUND_OVERRIDE : 0;
            });

            glob.totals.SLOTTING_FUND                += glob.not_released.SLOTTING_FUND !== null ? +glob.not_released.SLOTTING_FUND : 0;
            glob.totals.SLOTTING_FUND_OVERRIDE       += glob.not_released.SLOTTING_FUND_OVERRIDE !== null ? +glob.not_released.SLOTTING_FUND_OVERRIDE : 0;
            glob.totals.SLOTTING_FUND_FINAL          += glob.not_released.SLOTTING_FUND_FINAL !== null ? +glob.not_released.SLOTTING_FUND_FINAL : 0;
            glob.totals.SLOTTING_FUND_APPROVED_FINAL += glob.not_released.SLOTTING_FUND_APPROVED_FINAL !== null ? +glob.not_released.SLOTTING_FUND_APPROVED_FINAL : 0;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~ insert totals row to the bottom ~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.setPinnedBottomRowData([ glob.not_released, glob.totals ]);
        }

            
        function mass_apply_event() {
            $("input.mass_apply").click(function(e){
                e.stopPropagation();
            });
            <!--- ~~~~~~~~ mass apply logic ~~~~~~~~ --->
            $("i.mass_apply").click(function(e){
                e.stopPropagation();
                let icon_name = $(this).attr("name");
                let mass_rate = $("input[name=" + icon_name + "]").val();
                log.debug(icon_name, mass_rate);
                let changes_count = 0;
                <!---  apply to filtered (visible) rows only  --->
                glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                    <!--- ~~ apply to selected rows only ~~~ --->
                    if (rowNode.selected) {
                        changes_count += 1;
                        rowNode.setDataValue(icon_name, mass_rate);
                    }
                });
                if (changes_count) {
                    changes_made();
                    show_totals();
                }
            });
        }

        ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, glob.grid_id, 0, 1 );
        glob.my_grid.api.setHeaderHeight(35);

        $.ajax({    url: <cfoutput>"ajax/slotting.cfm?id=#url.id#"</cfoutput>
                    ,data: { returnFormat:"json" }
                    ,error: function(xhr, status, error) { error_handler(arguments) }
                    ,success: function( result ) {
                                                    if (typeof result === 'string') {
                                                        result = JSON.parse(result);
                                                        glob.my_grid.api.setRowData( result[0] );

                                                        glob.totals = result[1][0];
                                                        glob.not_released = result[2][0];
                                                        show_totals();
                                                        // insert total row to the bottom
                                                        // glob.my_grid.api.setPinnedBottomRowData([ header, totals ]);
                                                    }
                                                }
        });

        $("form").bind("keypress", function(e) {
            if (e.keyCode == 13) {
                return false;
            }
        });

        $("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = <cfoutput>"Slotting #qHeader.Fiscal_Year# #qHeader.Main_Distributor_Group_Number#"</cfoutput>;
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
            return false;
        });

        $("button.save").click(function(){
            show_loader();
            let form = $("form[name=slotting]");

            let row_keys = '';
            glob.my_grid.api.forEachNode(function(rowNode, index) {
                row_keys = rowNode.data.USER_POSITIONS_ID;
                <!--- ~~ select only rates with value ~~ --->
                if (rowNode.data.SLOTTING_FUND !== rowNode.data.X_SLOTTING_FUND) {
                    form.append("<input type=hidden name='SLOTTING_FUND$" 
                                                            + row_keys
                                                            + "' value='" + rowNode.data.SLOTTING_FUND + "'>");
                }
                if (rowNode.data.SLOTTING_FUND_OVERRIDE !== rowNode.data.X_SLOTTING_FUND_OVERRIDE) {
                    form.append("<input type=hidden name='SLOTTING_FUND_OVERRIDE$" 
                                                            + row_keys
                                                            + "' value='" + rowNode.data.SLOTTING_FUND_OVERRIDE + "'>");
                }
            });

            let not_released = glob.my_grid.api.getPinnedBottomRow(0);
            row_keys = not_released.data.USER_POSITIONS_ID;
            if (not_released.data.SLOTTING_FUND !== not_released.data.X_SLOTTING_FUND) {
                form.append("<input type=hidden name='SLOTTING_FUND$" 
                                                        + row_keys
                                                        + "' value='" + not_released.data.SLOTTING_FUND + "'>");
            }
            if (not_released.data.SLOTTING_FUND_OVERRIDE !== not_released.data.X_SLOTTING_FUND_OVERRIDE) {
                form.append("<input type=hidden name='SLOTTING_FUND_OVERRIDE$" 
                                                        + row_keys
                                                        + "' value='" + not_released.data.SLOTTING_FUND_OVERRIDE + "'>");
            }

            $("input[name=action]").val("save");
            parent.refresh_tab_name( glob.tab_name, 0 );
            form.submit();
        });


    </script>

    <cfset request.focusHiLightOff = true>
</body>
</html>