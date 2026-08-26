<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\demos.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Demos
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
            <cfset targets_cfc.setDemos( form )>
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
        header_height = qHeader.Demo_Updated_Date neq '' ? 70 : 36;
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

    <cfif cgi.request_method is "post" and form.action is "save">
        <!--- <cfset targets_cfc.setTradeTargets( form )> --->
        <!--- <cfdump var="#form#"> --->
    </cfif>

    <cfoutput>       
        <div class="header">
            <cfif qHeader.Demo_Updated_Date neq ''>
                <p class="last_changed">Last updated on <b>#dateFormat(qHeader.Demo_Updated_Date, "medium")#</b> at #timeFormat(qHeader.Demo_Updated_Date, "short")# by <b>#qHeader.Demo_Updated_By#</b>
                    <span class="changes_made" style="display:none;float:right;padding-right:5px;color:red;"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Changes have been made. Remember to save them.</span>
                </p>
            </cfif>

            <div id="actions">
                <button class="button save recommended">Save</button>
                <button class="button export">Export</button>
                <span style="display:inline-block; float:right">
                    <label><input type="checkbox" class="cb" checked name="hide_zero"> Hide $0 rows</label>
                </span>    
            </div>            
        </div>

        <form name="demos" method="post" action="demos.cfm?id=#url.id#">
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
            border: none;
        }
        .border1 {
            border-right: 1px solid #444 !important;
            /* border-right: 1px solid transparent; */
        }
        div[col-id=APPROVED_INCREMENTAL_FUNDS] {
            border-right: 1px solid #444 !important;
        }
    </style>

    <cf_include files="hide_zeros.js">

    <script>
        'use strict';
        
        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid", tab_name:"demos", totals:{} };
  
        const CURRENCY_FORMAT   = '($0,0)';
        const MASS_APPLY        = true;
        const PERCENTAGE_FORMAT = '(0,0.0)';

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
                                 { headerName:<cfoutput>"#targets_cfc.getDistGroupLabel(qHeader.Sub_Distributor_Group_Type)#"</cfoutput>, field:"SUB_DISTRIBUTOR_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:200, floatingFilter: true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true }
                                ,{ headerName:<cfoutput>"#targets_cfc.getProductGroupLabel(qHeader.Sub_Product_Group_Type)#"</cfoutput>, field:"SUB_PRODUCT_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:200, floatingFilter: true }

                                ,{ headerName:"Final Target\n Revenue", field:"SALES_TARGET_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_FINAL, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "dollar"], filter:false, width:100, floatingFilter: false }


                                ,{ headerName:"Final Trade\n Rate", field:"TRADE_RATE_TARGET_FINAL"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_FINAL, PERCENTAGE_FORMAT) }
                                    ,cellClass:["rightA", "perc"], width:100, filter:false, floatingFilter: false }



                                ,{ headerName:"Final Trade\n Fund", field:"TRADE_FUND_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.TRADE_FUND_FINAL, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "dollar"], filter:false, width:100, floatingFilter: false }
                                ,{ headerName:"Approved Incr\n Funds", field:"APPROVED_INCREMENTAL_FUNDS"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.APPROVED_INCREMENTAL_FUNDS, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "dollar"], filter:false, width:100, floatingFilter: false }
                                ,{ headerName:"Demo Fund", field:"DEMO_FUND"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.DEMO_FUND, CURRENCY_FORMAT) }
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass mass_apply" name="DEMO_FUND" placeholder="mass apply" tabindex="-1" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="DEMO_FUND" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "dollar"] 
                                                                        : ["rightA", "editable", "dollar"] } 
                                    ,editable:function(p) { return p.node.isRowPinned() ? false : true }
                                    ,sortable:true, valueParser: numberParser }
                                ,{ headerName:"Demo Fund Override", field:"DEMO_FUND_OVERRIDE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.DEMO_FUND_OVERRIDE, CURRENCY_FORMAT) }
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass mass_apply" name="DEMO_FUND_OVERRIDE" placeholder="mass apply" tabindex="-1" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="DEMO_FUND_OVERRIDE" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,type:'numericColumn', filter:false, width:120, floatingFilter: false
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "dollar"] 
                                                                        : ["rightA", "editable", "dollar"] } 
                                    ,editable:function(p) { return p.node.isRowPinned() ? false : true }
                                    ,sortable:true, valueParser: numberParser }
                                ,{ headerName:"Demo Fund\n Final", field:"DEMO_FUND_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.DEMO_FUND_FINAL, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "dollar"], filter:false, width:100, floatingFilter: false }
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
                ,isExternalFilterPresent: isExternalFilterPresent
                ,doesExternalFilterPass: doesExternalFilterPass
                ,getRowStyle: function(p) { if (p.node.rowPinned) { return { 'font-weight': 'bold' } } }
                ,onFilterChanged: function(e) { show_totals() }
                ,onCellValueChanged: function(e) { show_totals() }
                ,excelStyles: [
                                { id: "dollar", numberFormat: {format: '$#,###,##0;[Red]($#,###,##0)'} }
                                ,{ id: "perc", numberFormat: {format: '##,##0.0%;[Red](##,##0.0)%'} }
                            ]
            };

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  calculate totals and show them in the footer  --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function show_totals() {
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~ initialize totals to zero ~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.totals.APPROVED_INCREMENTAL_FUNDS = 0;
            glob.totals.DEMO_FUND                  = 0;
            glob.totals.DEMO_FUND_FINAL            = 0;
            glob.totals.DEMO_FUND_OVERRIDE         = 0;
            glob.totals.SALES_TARGET_FINAL         = 0;
            glob.totals.TRADE_FUND_FINAL           = 0;
            glob.totals.X_DEMO_FUND                = 0;
            glob.totals.X_DEMO_FUND_OVERRIDE       = 0;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~ calculate totals for visible rows ~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                glob.totals.APPROVED_INCREMENTAL_FUNDS += rowNode.data.APPROVED_INCREMENTAL_FUNDS !== null ? +rowNode.data.APPROVED_INCREMENTAL_FUNDS :  0;
                glob.totals.DEMO_FUND                  += rowNode.data.DEMO_FUND            !== null ? +rowNode.data.DEMO_FUND            : 0 ;
                glob.totals.DEMO_FUND_FINAL            += rowNode.data.DEMO_FUND_FINAL      !== null ? +rowNode.data.DEMO_FUND_FINAL      : 0 ;
                glob.totals.DEMO_FUND_OVERRIDE         += rowNode.data.DEMO_FUND_OVERRIDE   !== null ? +rowNode.data.DEMO_FUND_OVERRIDE   : 0 ;
                glob.totals.SALES_TARGET_FINAL         += rowNode.data.SALES_TARGET_FINAL   !== null ? +rowNode.data.SALES_TARGET_FINAL   : 0 ;
                glob.totals.TRADE_FUND_FINAL           += rowNode.data.TRADE_FUND_FINAL     !== null ? +rowNode.data.TRADE_FUND_FINAL     : 0 ;
                glob.totals.X_DEMO_FUND                += rowNode.data.X_DEMO_FUND          !== null ? +rowNode.data.X_DEMO_FUND          : 0 ;
                glob.totals.X_DEMO_FUND_OVERRIDE       += rowNode.data.X_DEMO_FUND_OVERRIDE !== null ? +rowNode.data.X_DEMO_FUND_OVERRIDE : 0 ;
            });

            glob.totals.TRADE_RATE_TARGET_FINAL = glob.totals.SALES_TARGET_FINAL && glob.totals.SALES_TARGET_FINAL !== 0 && glob.totals.TRADE_FUND_FINAL
                                                    ? (glob.totals.TRADE_FUND_FINAL / glob.totals.SALES_TARGET_FINAL)
                                                    : null;
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~ insert totals row to the bottom ~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.setPinnedBottomRowData( [glob.totals] );
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
        init_ag_grid( glob.my_grid, glob.grid_id);
        glob.my_grid.api.setHeaderHeight(35);

        $("div.ag-header-row:nth-child(2) div:nth-child(4)").addClass("border1");        

        $.ajax({    url: <cfoutput>"ajax/demos.cfm?id=#url.id#"</cfoutput>
                    ,data: { returnFormat:"json" }
                    ,error: function(xhr, status, error) { error_handler(arguments) }
                    ,success: function( result ) {
                                                    if (typeof result === 'string') {
                                                        result = JSON.parse(result);
                                                        glob.my_grid.api.setRowData( result[0] );

                                                        // insert total row to the bottom
                                                        glob.totals = result[1][0];
                                                        show_totals();
                                                    }
                                                }
        });

        $("form").bind("keypress", function(e) {
            if (e.keyCode == 13) {
                return false;
            }
        });

        // $(window).resize(function(){ adjust_grid_height(); });

        $("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = <cfoutput>"Demos #qHeader.Fiscal_Year# #qHeader.Main_Distributor_Group_Number#"</cfoutput>;
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
            return false;
        });

        $("button.save").click(function(){
            show_loader();
            let form = $("form[name=demos]");

            let row_keys = '';
            glob.my_grid.api.forEachNode(function(rowNode, index) {
                row_keys = rowNode.data.SUB_DISTRIBUTOR_GROUP_ID + '$' + rowNode.data.SUB_PRODUCT_GROUP_ID;
                <!--- ~~ select only rates with changed value ~~ --->
                if ( 
                        (rowNode.data.DEMO_FUND !== rowNode.data.X_DEMO_FUND)
                        || (rowNode.data.DEMO_FUND_OVERRIDE !== rowNode.data.X_DEMO_FUND_OVERRIDE) 
                    ) {
                    log.debug(rowNode)
                    form.append("<input type=hidden name='DEMO_FUND$" 
                                                            + row_keys
                                                            + "' value='" + rowNode.data.DEMO_FUND + "'>"
                                +
                                "<input type=hidden name='DEMO_FUND_OVERRIDE$" 
                                                            + row_keys
                                                            + "' value='" + rowNode.data.DEMO_FUND_OVERRIDE + "'>");
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