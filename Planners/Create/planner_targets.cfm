<!---
  * ====================================================================================================
  *    @File: \planners\create\planner_targets.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  *
  * @Remarks: Planner Targets Tab
  *
  * ====================================================================================================
--->
<cf_layout_planner>

<cfinclude template="topnav_form.cfm">

<cfscript>
	plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" );
	getPlanner     = plannerManager.getPlanner( form.plannerID );
	subProductGroupLabel = createObject("component", "mvc.models.planner.plannerTargets").getSubProductGroupLabel();
</cfscript>

<script>
show_loader();

</script>

<div style="width:99%;padding:0 5px;display:flex;margin-bottom:5px;">
    <div style="width:50%">
        <cfoutput>
            <a href="##" class="export">#application.util.string.linkFormat("export")#</a>
        </cfoutput>
    </div>
    <div style="text-align:right;width:50%;padding-right:5px;">
        <input type="checkbox" name="hideZeros" id="hideZeros" checked style="position:relative;top:2px;" onchange="externalFilterChanged(this.checked)"> <label for="hideZeros">Hide $0 rows</label>
    </div>
</div>
<div id="aggrid" class="ag-theme-balham" style="width:100%;margin:0 0 30px 0;padding:0;"></div>

<style>
    div#slotting_summary * {
        box-sizing: border-box;
        margin: 0;
        /* padding: 0; */
    }
    div#slotting_summary {
        width: 250px;
        margin-left: 10px;
    }
    div#slotting_summary h3 {
        margin: 8px 0;
    }
    div#slotting_position_label {
        text-align: right;
        font-size: 12px;
        background-color: #9BC2E6;
        height: 30px;
        min-height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    div#slotting {
        display: flex;
        width: 100%;
        /* border: 1px solid black; */
        /* font-size: 13px; */
    }
        div#slotting > div {
            flex: 1;
            width: 50%;
        }
        div.slotting_item1 {
            height: 30px;
            min-height: 30px;
            border-bottom: 1px solid;
            border-left: 1px solid;
            padding: 8px 7px;
        }
        div.slotting_item2 {
            height: 30px;
            min-height: 30px;
            border-bottom: 1px solid;
            border-left: 1px solid;
            border-right: 1px solid;
            padding: 8px 7px;
            text-align: right;
        }
</style>

<div id="slotting_summary">
    <h3>Regional Slotting Summary</h3>
    <div id="slotting_position_label"></div>
    <div id="slotting">
        <!--- first column --->
        <div>
            <div class="slotting_item1">Final Slotting Fund</div>
            <div class="slotting_item1">LE Spend Slotting</div>
            <div class="slotting_item1">LE Slotting Balance</div>
        </div>
        <!--- second column --->
        <div>
            <div class="slotting_item2" id="final_slotting_fund"></div>
            <div class="slotting_item2" id="le_spend_slotting"></div>
            <div class="slotting_item2" id="le_slotting_balance"></div>
        </div>
    </div>
</div>

<!--- <div style="text-align:center;margin-top:150px;">
    <h1>Under Construction</h1>
    <p>
       We are working very hard to make this section available.
    </p>
</div> --->
<cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /styles/css-loader.css, /script/javascript/numeral.min.js">

<style>
.ag-theme-balham .ag-row {
    border-color: #424949;
}
.rightA {
    text-align: right;
}
</style>

<script>
    'use strict';

    <!--- ~~~~~~~~~~ glob   = global variables  ~~~~~~~~~~ --->
    let   glob              = { grid_id:"#aggrid", totals:{} };
    const CURRENCY_FORMAT   = '($0,0)';
    const PERCENTAGE_FORMAT = '(0,0.0)';

    <!--- ~~~~~~ adjust grid height ~~~~~~ --->
    function adjust_grid_height( offset ) {
        offset = offset || 170;
        let grid_element = $(glob.grid_id);
        if (grid_element) {
            let grid_height  = $(window).innerHeight() - grid_element[0].offsetTop - offset;
            grid_element.css({ "height": grid_height + "px" } );
        }
    }
    // adjust_grid_height();

    <!--- ~~ define ag-grid configuration ~~ --->
    glob.ppg_grid = {
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
                             { headerName:<cfoutput>"#subProductGroupLabel#"</cfoutput>, field:"SUB_PRODUCT_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:170, floatingFilter: true }
                            ,{ headerName:"Fin Target Rev", field:"TARGET_REVENUE_FINAL", valueFormatter:function(p){ return currencyFormat(p.data.TARGET_REVENUE_FINAL, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"]  }

                            ,{ headerName:"Fin Trade Rate", field:"TARGET_TRADE_RATE", valueFormatter:function(p){ return excelPercentFormat(p.data.TARGET_TRADE_RATE, PERCENTAGE_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "perc"] }
                            ,{ headerName:"Fin Trade Fnd", field:"TARGET_TRADE_FUND_FINAL", valueFormatter:function(p){ return currencyFormat(p.data.TARGET_TRADE_FUND_FINAL, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"Appr Incr Fnd", field:"APPROVED_INCREMENTAL_FUNDS", valueFormatter:function(p){ return currencyFormat(p.data.APPROVED_INCREMENTAL_FUNDS, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"LE Trade Fnd", field:"LE_TRADE_FUND", valueFormatter:function(p){ return currencyFormat(p.data.LE_TRADE_FUND, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"Fin Demo Fnd", field:"DEMO_FUND_FINAL", valueFormatter:function(p){ return currencyFormat(p.data.DEMO_FUND_FINAL, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }

                            ,{ headerName:"LE Revenue", field:"LE_REVENUE", valueFormatter:function(p){ return currencyFormat(p.data.LE_REVENUE, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"LE Trade Spend", field:"LE_TRADE_SPEND", valueFormatter:function(p){ return currencyFormat(p.data.LE_TRADE_SPEND, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"LE Trade Rate", field:"LE_TRADE_RATE", valueFormatter:function(p){ return excelPercentFormat(p.data.LE_TRADE_RATE, PERCENTAGE_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "perc"] }
                            ,{ headerName:"LE Spend Demo", field:"LE_SPEND_DEMO", valueFormatter:function(p){ return currencyFormat(p.data.LE_SPEND_DEMO, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"LE Spend Slot", field:"LE_SPEND_SLOTTING", valueFormatter:function(p){ return currencyFormat(p.data.LE_SPEND_SLOTTING, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"LE Trade Fnd Bal", field:"LE_TRADE_FUND_BALANCE", valueFormatter:function(p){ return currencyFormat(p.data.LE_TRADE_FUND_BALANCE, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"LE Demo Bal", field:"LE_DEMO_BALANCE", valueFormatter:function(p){ return currencyFormat(p.data.LE_DEMO_BALANCE, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                            ,{ headerName:"Gap to Target", field:"GAP_TO_TARGET", valueFormatter:function(p){ return currencyFormat(p.data.GAP_TO_TARGET, CURRENCY_FORMAT) }, type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass: ["rightA", "dollar"] }
                        ]
                ,enableRangeSelection:      false

                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              false
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
                ,floatingFilter:  true
                ,getRowStyle:               function(p) { if (p.node.rowPinned) { return { 'font-weight': 'bold' } } }
                ,onFilterChanged: function(e) { show_totals() }
                ,onCellValueChanged: function(e) { show_totals() }
                ,isExternalFilterPresent: isExternalFilterPresent
                ,doesExternalFilterPass: doesExternalFilterPass
                ,excelStyles: [
                                { id: "dollar", numberFormat: {format: '$#,###,##0;[Red]($#,###,##0)'} }
                                ,{ id: "perc", numberFormat: {format: '##,##0.0%;[Red](##,##0.0)%'} }
                            ]
            };

        var hideZeros = 1;
        function isExternalFilterPresent() {
            if($('#hideZeros').is(':checked')){
                return true;
            }else{
                return false;
            }
        }
        function doesExternalFilterPass(node) {
            if(hideZeros){
                return node.data.TARGET_REVENUE_FINAL != 0 ||  node.data.LE_REVENUE != 0;
            }
        }
        function externalFilterChanged(newValue) {
            hideZeros = 1;
            if(! newValue){
                hideZeros = 0;
            }
            glob.ppg_grid.api.onFilterChanged();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  calculate totals and show them in the footer  --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function show_totals() {
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~ initialize totals to zero ~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.totals.APPROVED_INCREMENTAL_FUNDS = 0;
            glob.totals.DEMO_FUND_FINAL            = 0;
            glob.totals.GAP_TO_TARGET              = 0;
            glob.totals.LE_DEMO_BALANCE            = 0;
            glob.totals.LE_REVENUE                 = 0;
            glob.totals.LE_SLOTTING_BALANCE        = 0;
            glob.totals.LE_SPEND_DEMO              = 0;
            glob.totals.LE_SPEND_SLOTTING          = 0;
            glob.totals.LE_TRADE_FUND              = 0;
            glob.totals.LE_TRADE_FUND_BALANCE      = 0;
            glob.totals.LE_TRADE_RATE              = 0;
            glob.totals.LE_TRADE_SPEND             = 0;
            glob.totals.SLOTTING_FUND_FINAL        = 0;
            glob.totals.TARGET_REVENUE_FINAL       = 0;
            glob.totals.TARGET_TRADE_FUND_FINAL    = 0;
            glob.totals.TARGET_TRADE_RATE          = 0;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~ calculate totals for visible rows ~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.ppg_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                glob.totals.APPROVED_INCREMENTAL_FUNDS += rowNode.data.APPROVED_INCREMENTAL_FUNDS !== null ? +rowNode.data.APPROVED_INCREMENTAL_FUNDS : 0;
                glob.totals.DEMO_FUND_FINAL            += rowNode.data.DEMO_FUND_FINAL            !== null ? +rowNode.data.DEMO_FUND_FINAL            : 0;
                glob.totals.GAP_TO_TARGET              += rowNode.data.GAP_TO_TARGET              !== null ? +rowNode.data.GAP_TO_TARGET              : 0;
                glob.totals.LE_DEMO_BALANCE            += rowNode.data.LE_DEMO_BALANCE            !== null ? +rowNode.data.LE_DEMO_BALANCE            : 0;
                glob.totals.LE_REVENUE                 += rowNode.data.LE_REVENUE                 !== null ? +rowNode.data.LE_REVENUE                 : 0;
                glob.totals.LE_SLOTTING_BALANCE        += rowNode.data.LE_SLOTTING_BALANCE        !== null ? +rowNode.data.LE_SLOTTING_BALANCE        : 0;
                glob.totals.LE_SPEND_DEMO              += rowNode.data.LE_SPEND_DEMO              !== null ? +rowNode.data.LE_SPEND_DEMO              : 0;
                glob.totals.LE_SPEND_SLOTTING          += rowNode.data.LE_SPEND_SLOTTING          !== null ? +rowNode.data.LE_SPEND_SLOTTING          : 0;
                glob.totals.LE_TRADE_FUND              += rowNode.data.LE_TRADE_FUND              !== null ? +rowNode.data.LE_TRADE_FUND              : 0;
                glob.totals.LE_TRADE_FUND_BALANCE      += rowNode.data.LE_TRADE_FUND_BALANCE      !== null ? +rowNode.data.LE_TRADE_FUND_BALANCE      : 0;
                glob.totals.LE_TRADE_SPEND             += rowNode.data.LE_TRADE_SPEND             !== null ? +rowNode.data.LE_TRADE_SPEND             : 0;
                glob.totals.SLOTTING_FUND_FINAL        += rowNode.data.SLOTTING_FUND_FINAL        !== null ? +rowNode.data.SLOTTING_FUND_FINAL        : 0;
                glob.totals.TARGET_REVENUE_FINAL       += rowNode.data.TARGET_REVENUE_FINAL       !== null ? +rowNode.data.TARGET_REVENUE_FINAL       : 0;
                glob.totals.TARGET_TRADE_FUND_FINAL    += rowNode.data.TARGET_TRADE_FUND_FINAL    !== null ? +rowNode.data.TARGET_TRADE_FUND_FINAL    : 0;
            });

            glob.totals.LE_TRADE_RATE     = glob.totals.LE_REVENUE !== 0 ? (glob.totals.LE_TRADE_SPEND / glob.totals.LE_REVENUE) : null;
            glob.totals.TARGET_TRADE_RATE = glob.totals.TARGET_REVENUE_FINAL !== 0 ? (glob.totals.TARGET_TRADE_FUND_FINAL / glob.totals.TARGET_REVENUE_FINAL) : null;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~ insert totals row to the bottom ~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.ppg_grid.api.setPinnedBottomRowData( [ glob.totals ] );
        }

        function number_style(p) {
            return (Number(p.value) < 0) ? {color: 'red'} : null;
        }

        ag_grid_default( glob.ppg_grid );
        init_ag_grid( glob.ppg_grid, glob.grid_id );

        $.ajax({    url: <cfoutput>"ajax/planner_targets.cfm?id=#form.plannerID#"</cfoutput>
                    ,data: { returnFormat:"json" }
                    ,error: function(xhr, status, error) { error_handler(arguments); show_loader ('', -1 ); }
                    ,success: function( result ) {
                                                    show_loader ('', -1 );
                                                    if (typeof result === 'string') {
                                                        result = JSON.parse(result);
                                                        glob.ppg_grid.api.setRowData( result[0] );

                                                        let grid_element = $(glob.grid_id);
                                                        if (grid_element) {
                                                            const grid_header = 50;
                                                            const grid_footer = 50;
                                                            const row_height  = 20;
                                                            let grid_height  = grid_header + grid_footer + (row_height * (Math.min(9, result[0].length) + 1)) - 7;
                                                            grid_element.css({ "height": grid_height + "px" } );
                                                        }

                                                        let slotting = result[1][0];
                                                        $("#slotting_position_label").html( slotting.SLOTTING_POSITION_LABEL );
                                                        $("#final_slotting_fund").html( currencyFormat(slotting.FINAL_SLOTTING_FUND, CURRENCY_FORMAT) );
                                                        $("#le_spend_slotting").html( currencyFormat(slotting.LE_SPEND_SLOTTING, CURRENCY_FORMAT) );
                                                        $("#le_slotting_balance").html( currencyFormat(slotting.LE_SLOTTING_BALANCE, CURRENCY_FORMAT) );

                                                        glob.totals = result[2][0];
                                                        show_totals();
                                                    }
                                                }
        });

        $("a.export").click(function(){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            <cfoutput>
            let file_title  = "Spending Progress For #Application.PlannerLabel# #getPlanner.planner_number#";
            glob.ppg_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: "Spend Progress #getPlanner.planner_number#" } );
            </cfoutput>
            return false;
        });
</script>

</cf_layout_planner>
