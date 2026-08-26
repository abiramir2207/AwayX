<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\trade_targets.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Trade Targets
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
        <cfif form.action is "update">
        <cfelseif form.action is "save">
            <cfset targets_cfc.setTradeTargets( form )>
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
    <cfscript>
        qHeader       = targets_cfc.getTargets(url.id);
        header_height = qHeader.Trade_Target_Updated_Date neq '' ? 70 : 36;
    </cfscript>

    <cf_include files="/styles/ag-grid-ba.css">

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
                padding-top: #(header_height + 5)#px;
            }
        </cfoutput>
        button.default {
            margin-right: 50px;
        }
        input.cb {
            position: relative;
            top: 1.5px;
        }
        label {
            user-select: none;
        }
    </style>
    

    <cfoutput>       
        <div class="header">
            <cfif qHeader.Trade_Target_Updated_Date neq ''>
                <p class="last_changed">Last updated on <b>#dateFormat(qHeader.Trade_Target_Updated_Date, "medium")#</b> at #timeFormat(qHeader.Trade_Target_Updated_Date, "short")# by <b>#qHeader.Trade_Target_Updated_By#</b>
                    <span class="changes_made" style="display:none;float:right;padding-right:5px;color:red;"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Changes have been made. Remember to save them.</span>
                </p>
            </cfif>

            <div id="actions">
                <button class="button save recommended">Save</button>
                <button class="button export">Export</button>
                <button class="button default">Default Trade Rates</button>
                <span style="display:inline-block; float:right">
                    <label><input type="checkbox" class="cb" checked name="hide_zero"> Hide $0 rows</label>
                </span>
            </div>
        </div>

        <form name="trade_targets" method="post" action="trade_targets.cfm?id=#url.id#">
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
        input.rate, input.mass_rate {
            width: 70%;
            position: relative;
            top: -1px;
        }
        .ag-header-cell-label {
           justify-content: center;
        }
        .ag-root-wrapper {
            /* border: 1px solid red; */
        }
    </style>

    <cf_include files="hide_zeros.js">

    <script>
        'use strict';

        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid", tab_name:"trades", totals:{} };
 
        const CURRENCY_FORMAT   = '($0,0)';
        const PERCENTAGE_FORMAT = '(0,0.0)';
        const MASS_APPLY        = true;

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
                                 { headerName:<cfoutput>"#targets_cfc.getProductGroupLabel(qHeader.Sub_Product_Group_Type)#"</cfoutput>, field:"SUB_PRODUCT_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:250, floatingFilter: true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true 
                                    ,pinnedRowCellRendererParams: { style: { "text-align":"center", "font-weight":"bold" } }                                
                                 }
                                ,{ headerName:"Original Target\n Revenue", field:"SALES_TARGET_ORIGINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_ORIGINAL, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "currency"], filter:false, width:100, floatingFilter: false }
                                ,{ headerName:"Override\n Revenue", field:"SALES_TARGET_OVERRIDE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_OVERRIDE, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "currency"], width:100, filter:false, floatingFilter: false }
                                ,{ headerName:"Final Target\n Revenue", field:"SALES_TARGET_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_FINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:["rightA", "currency"] }


                                ,{ headerName:"Original Trade\n Rate", field:"TRADE_RATE_TARGET_ORIGINAL" 
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_ORIGINAL, PERCENTAGE_FORMAT) }
                                    ,filter:false, width:100, floatingFilter: false, cellClass:["percent", "rightA"] }


                                ,{ headerName:"Override Trade Rate", field:"TRADE_RATE_TARGET_OVERRIDE"
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass_apply mass_rate" tabindex="-1" placeholder="mass apply" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_OVERRIDE, PERCENTAGE_FORMAT) }
                                    ,onCellValueChanged: changes_made
                                    ,filter:false, floatingFilter: false, width:130, sortable:true, valueParser: numberParser, editable:function(p) { return p.node.isRowPinned() ? false : true } 
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "percent"] 
                                                                        : ["rightA", "editable", "percent"] } }


                                ,{ headerName:"Final Trade\n Rate", field:"TRADE_RATE_TARGET_FINAL"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_FINAL, PERCENTAGE_FORMAT) }
                                    ,filter:false, width:100, floatingFilter: false, cellClass:["rightA", "percent"] }




                                ,{ headerName:"Final Trade\n Fund", field:"TRADE_FUND_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.TRADE_FUND_FINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:["rightA", "currency"] }
                            ]
                ,enableRangeSelection:      false
                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              "multiple"
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
                ,floatingFilter:  true
                ,onGridReady:               function(p) { mass_apply_event() }
                ,onBodyScroll:              function(p) { mass_apply_event() }
                ,isExternalFilterPresent: isExternalFilterPresent
                ,doesExternalFilterPass: doesExternalFilterPass
                ,getRowStyle:               function(p) { if (p.node.rowPinned) { return { 'font-weight': 'bold' } } }
                ,onFilterChanged: function(e) { show_totals() }
                ,excelStyles: [
                                { id: "currency", numberFormat: {format: '$#,###,##0;[Red]($#,###,##0)'} }
                                ,{ id: "percent", numberFormat: {format: '##,##0.0%;[Red](##,##0.0)%'} }
                            ]
            };

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  calculate totals and show them in the footer  --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function show_totals() {
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~ initialize totals to zero ~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.totals.SALES_TARGET_ABSOLUTE_VARIANCE = 0 ;
            glob.totals.SALES_TARGET_FINAL             = 0 ;
            glob.totals.SALES_TARGET_ORIGINAL          = 0 ;
            glob.totals.SALES_TARGET_OVERRIDE          = 0 ;
            glob.totals.TRADE_FUND_FINAL               = 0 ;
            glob.totals.TRADE_RATE_TARGET_FINAL        = 0 ;
            glob.totals.TRADE_RATE_TARGET_ORIGINAL     = 0 ;
            glob.totals.TRADE_RATE_TARGET_OVERRIDE     = 0 ;
            glob.totals.X_TRADE_RATE_TARGET_OVERRIDE   = 0 ;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~ calculate totals for visible rows ~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                glob.totals.SALES_TARGET_ABSOLUTE_VARIANCE += rowNode.data.SALES_TARGET_ABSOLUTE_VARIANCE !== null ? +rowNode.data.SALES_TARGET_ABSOLUTE_VARIANCE : 0;
                glob.totals.SALES_TARGET_FINAL             += rowNode.data.SALES_TARGET_FINAL             !== null ? +rowNode.data.SALES_TARGET_FINAL             : 0;
                glob.totals.SALES_TARGET_ORIGINAL          += rowNode.data.SALES_TARGET_ORIGINAL          !== null ? +rowNode.data.SALES_TARGET_ORIGINAL          : 0;
                glob.totals.SALES_TARGET_OVERRIDE          += rowNode.data.SALES_TARGET_OVERRIDE          !== null ? +rowNode.data.SALES_TARGET_OVERRIDE          : 0;
                glob.totals.TRADE_FUND_FINAL               += rowNode.data.TRADE_FUND_FINAL               !== null ? +rowNode.data.TRADE_FUND_FINAL               : 0;
                glob.totals.TRADE_RATE_TARGET_FINAL        += rowNode.data.TRADE_RATE_TARGET_FINAL        !== null ? +rowNode.data.TRADE_RATE_TARGET_FINAL        : 0;
                glob.totals.TRADE_RATE_TARGET_ORIGINAL     += rowNode.data.TRADE_RATE_TARGET_ORIGINAL     !== null ? +rowNode.data.TRADE_RATE_TARGET_ORIGINAL     : 0;
                glob.totals.TRADE_RATE_TARGET_OVERRIDE     += rowNode.data.TRADE_RATE_TARGET_OVERRIDE     !== null ? +rowNode.data.TRADE_RATE_TARGET_OVERRIDE     : 0;
                glob.totals.X_TRADE_RATE_TARGET_OVERRIDE   += rowNode.data.X_TRADE_RATE_TARGET_OVERRIDE   !== null ? +rowNode.data.X_TRADE_RATE_TARGET_OVERRIDE   : 0;
            });

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~ disable these two columns ~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.totals.TRADE_RATE_TARGET_ORIGINAL = null;
            glob.totals.TRADE_RATE_TARGET_OVERRIDE = null;

            glob.totals.TRADE_RATE_TARGET_FINAL = glob.totals.SALES_TARGET_FINAL && glob.totals.SALES_TARGET_FINAL !== 0 && glob.totals.TRADE_FUND_FINAL
                                                    ? glob.totals.TRADE_FUND_FINAL / glob.totals.SALES_TARGET_FINAL
                                                    : null;
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~ insert totals row to the bottom ~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.setPinnedBottomRowData([ glob.totals ]);
        }

        function mass_apply_event() {
            $("input.mass_apply").click(function(e){
                e.stopPropagation();
            });
            <!--- ~~~~~~~~ mass apply logic ~~~~~~~~ --->
            $("i.mass_apply").click(function(e){
                e.stopPropagation();
                let mass_rate = $("input.mass_rate").val();
                let changes_count = 0;
                <!---  apply to filtered (visible) rows only  --->
                glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                    <!--- ~~ apply to selected rows only ~~~ --->
                    if (rowNode.selected) {
                        changes_count += 1;
                        rowNode.setDataValue("TRADE_RATE_TARGET_OVERRIDE", mass_rate);
                    }
                });
                if (changes_count) {
                    changes_made();
                    // show_totals();
                }
            });
        }
        
        ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, glob.grid_id );        
        glob.my_grid.api.setHeaderHeight(35);

        $.ajax({    url: <cfoutput>"ajax/trade_targets.cfm?id=#url.id#"</cfoutput>
                    ,data: { returnFormat:"json" }
                    ,error: function(xhr, status, error) { error_handler(arguments) }
                    ,success: function( result ) {
                                                    if (typeof result === 'string') {
                                                        result = JSON.parse(result);
                                                        glob.my_grid.api.setRowData( result[0] );

                                                        glob.totals = result[1][0];
                                                        show_totals();
                                                    }
                                                }
        });

        $("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = <cfoutput>"Trade Targets #qHeader.Fiscal_Year# #qHeader.Main_Distributor_Group_Number#"</cfoutput>;
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
            return false;
        });

        $("button.default").click(function(e){
            <cfoutput>
                popupInCenter("default_trade_targets.cfm?id=#url.id#", "default_trade_targets", 450, 700);
            </cfoutput>
            return false;
        });

        $("form").bind("keypress", function(e) {
            if (e.keyCode == 13) {
                return false;
            }
        });


        $("button.save").click(function(e){
            show_loader();
            let form = $("form[name=trade_targets]");
            
            glob.my_grid.api.forEachNode(function(rowNode, index) {
                <!--- ~~ select only rates with value ~~ --->
                if (rowNode.data.SUB_PRODUCT_GROUP_DESC !== "TOTAL"                    
                        && rowNode.data.TRADE_RATE_TARGET_OVERRIDE !== rowNode.data.X_TRADE_RATE_TARGET_OVERRIDE) {
                    form.append("<input type=hidden name='ITEM-" + rowNode.data.SUB_PRODUCT_GROUP_ID + "' value='" + rowNode.data.TRADE_RATE_TARGET_OVERRIDE * 100.00 + "'>");
                    log.debug(rowNode);
                }
            });
            // return false;

            $("input[name=action]").val("save");
            parent.refresh_tab_name( glob.tab_name, 0 );
            form.submit();
        });
    </script>

    <cfset request.focusHiLightOff = true>
</body>
</html>