<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\target_adjustments.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Target Adjustments
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
            <cfset targets_cfc.setTargetAdjustments( form )>
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
        qHeader       = targets_cfc.getTargets(url.id);
        header_height = qHeader.Target_Adj_Updated_Date neq '' ? 70 : 36;
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
        .editable2 {
            padding-right: 5px !important;
        }
        input.cb {
            position: relative;
            top: 1.5px;
        }        
        label {
            margin-left: 10px;
            user-select: none;
        }
    </style>
        
    <cfoutput>       
        <div class="header">
            <cfif qHeader.Target_Adj_Updated_Date neq ''>
                <p class="last_changed">
                    Last updated on <b>#dateFormat(qHeader.Target_Adj_Updated_Date, "medium")#</b> at #timeFormat(qHeader.Target_Adj_Updated_Date, "short")# by <b>#qHeader.Target_Adj_Updated_By#</b>
                    <span class="changes_made" style="display:none;float:right;padding-right:5px;color:red;"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Changes have been made. Remember to save them.</span>
                </p>
            </cfif>

            <div id="actions">
                <button class="button save recommended">Save</button>
                <button class="button export">Export</button>
                <span style="display:inline-block; float:right">
                    <label><input type="radio" name="filter" class="cb filter" checked value="hide_zero"> Hide $0 rows</label>
                    <label><input type="radio" name="filter" class="cb filter" value="show_adjusted"> Show adjusted accounts</label>
                    <label><input type="radio" name="filter" class="cb filter" value="show_unadjusted"> Show unadjusted accounts</label>
                </span>
            </div>            
        </div>

        <form name="target_adjustments" method="post" action="target_adjustments.cfm?id=#url.id#">
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
        }
        div[col-id=SALES_TARGET_FINAL], div[col-id=TRADE_RATE_TARGET_FINAL] {
            border-right: 1px solid #444 !important;
        }
    </style>

    <!--- <cf_include files="hide_zeros.js"> --->

    <script>
        'use strict';
        
        var show_what = 'hide_zero'; 
        
        function isExternalFilterPresent() {
            return true;
        }

        function doesExternalFilterPass(node) {
            // log.debug(show_what)
            switch (show_what) {
                case 'hide_zero': return node.data.SALES_TARGET_ORIGINAL > 0 || node.data.SALES_TARGET_OVERRIDE > 0;
                case 'show_adjusted': return node.data.SALES_TARGET_OVERRIDE > 0 || node.data.TRADE_RATE_TARGET_OVERRIDE > 0;
                case 'show_unadjusted': return node.data.SALES_TARGET_OVERRIDE == null || node.data.TRADE_RATE_TARGET_OVERRIDE == null;
                default: return true;
            }
        }

        function externalFilterChanged() {
            show_what = $("input[name=filter]:checked").val();
            // log.debug({show_what});
            glob.my_grid.api.onFilterChanged();
        }

        $("input.filter").click(function(){
            externalFilterChanged();
        });        

        function numberParser(params) {
            return Number(params.newValue);
        }

        function tab_changed() {
            $("span.changes_made").show();
            $("div.ag-root-wrapper").addClass("grid_changed");
        }

        function changes_made(p){
            if (p && (Math.round(p.oldValue) !== Math.round(p.newValue))) {
                if (glob.tab_name) {
                    parent.refresh_tab_name( glob.tab_name, 1 );
                }
                tab_changed();
            }
        }






        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid", tab_name:"adjustments", totals:{} };
 
        <!--- ~~~~~~ adjust grid height ~~~~~~ --->
        function adjust_grid_height() {
            let grid_element = $(glob.grid_id);
            if (grid_element) {
                let grid_height  = $(window).innerHeight() - grid_element[0].offsetTop - 20;
                // log.log($(window).innerHeight(), grid_element[0].offsetTop );                // $("body").css("border", "2px solid blue")
                // grid_element.css({ "height": grid_height + "px" } );
            }
        }
        // adjust_grid_height();
 
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
                                 { headerName:<cfoutput>"#targets_cfc.getDistGroupLabel(qHeader.Sub_Distributor_Group_Type)#"</cfoutput>, field:"SUB_DISTRIBUTOR_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:200, floatingFilter: true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true }
                                ,{ headerName:<cfoutput>"#targets_cfc.getProductGroupLabel(qHeader.Sub_Product_Group_Type)#"</cfoutput>, field:"SUB_PRODUCT_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:200, floatingFilter: true }

                                ,{ headerName:"Orig Target Rev", field:"SALES_TARGET_ORIGINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_ORIGINAL, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "dollar"], filter:false, width:100, floatingFilter: false, sortable:true
                                }
                                ,{ headerName:"Override Value", field:"SALES_TARGET_OVERRIDE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_OVERRIDE, CURRENCY_FORMAT) }
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass mass_apply" name="SALES_TARGET_OVERRIDE" placeholder="mass apply" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="SALES_TARGET_OVERRIDE" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,editable:function(p) { return p.node.isRowPinned() ? false : true }
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "dollar"] 
                                                                        : ["rightA", "editable", "dollar"] } 
                                    ,width:100, filter:false, floatingFilter: false, sortable:true, valueParser: numberParser }
                                ,{ headerName:"Abs Variance", field:"SALES_TARGET_ABSOLUTE_VARIANCE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_ABSOLUTE_VARIANCE, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "dollar"], width:100, filter:false, floatingFilter: false }
                                ,{ headerName:"Perc Change", field:"SALES_TARGET_PERCENTAGE_CHANGE"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.SALES_TARGET_PERCENTAGE_CHANGE, PERCENTAGE_FORMAT) }
                                    ,cellClass:["rightA", "perc"], width:100, filter:false, floatingFilter: false }
                                ,{ headerName:"Final Target\n Revenue", field:"SALES_TARGET_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_FINAL, CURRENCY_FORMAT) }
                                    ,cellClass:["rightA", "border1", "dollar"], width:100, filter:false, floatingFilter: false }

                                ,{ headerName:"Original Trade\n Rate", field:"TRADE_RATE_TARGET_ORIGINAL"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_ORIGINAL, PERCENTAGE_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:["rightA", "perc"] }
                                ,{ headerName:"Override Trd Rt", field:"TRADE_RATE_TARGET_OVERRIDE"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_OVERRIDE, PERCENTAGE_FORMAT) }
								  	,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass_apply" name="TRADE_RATE_TARGET_OVERRIDE" placeholder="mass apply" tabindex="-1" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="TRADE_RATE_TARGET_OVERRIDE" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,type:'numericColumn', filter:false, width:150, floatingFilter: false
                                    ,editable:function(p) { return p.node.isRowPinned() ? false : true }
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "perc"] 
                                                                        : ["rightA", "editable", "perc"] } 
                                    ,sortable:true, valueParser: numberParser }
                                ,{ headerName:"Final Trade\n Rate", field:"TRADE_RATE_TARGET_FINAL"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_RATE_TARGET_FINAL, PERCENTAGE_FORMAT) }
                                    ,filter:false, floatingFilter: false, cellClass:["rightA", "border1", "perc"], width:130, sortable:true }
                                ,{ headerName:"Original Trade\n Fund", field:"TRADE_FUND_ORIGINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.TRADE_FUND_ORIGINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:["rightA", "dollar"] }
                                ,{ headerName:"Final Trade\n Fund", field:"TRADE_FUND_FINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.TRADE_FUND_FINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:["rightA", "dollar"] }
                                ,{ headerName:"Abs Variance", field:"TRADE_FUND_ABSOLUTE_VARIANCE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.TRADE_FUND_ABSOLUTE_VARIANCE, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false, cellClass:["rightA", "dollar"] }
                                ,{ headerName:"Perc Change", field:"TRADE_FUND_PERCENTAGE_CHANGE"
                                    ,valueFormatter:function(p){ return excelPercentFormat(p.data.TRADE_FUND_PERCENTAGE_CHANGE, PERCENTAGE_FORMAT) }
                                    ,cellClass:["rightA", "perc"], width:100
                                    ,type:'numericColumn'
                                    <cfif request.is_developer and 0>
                                        ,filter: "agNumberColumnFilter"
                                        ,floatingFilterComponent: 'customNumberFloatingFilter'
                                        ,floatingFilterComponentParams: {
                                            suppressFilterButton: true,
                                            color: 'orange'
                                        }                                
                                    </cfif>
                                }
                                ,{ headerName:"Appr Incr Funds", field:"APPROVED_INCREMENTAL_FUNDS"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.APPROVED_INCREMENTAL_FUNDS, CURRENCY_FORMAT) }
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=mass_apply><input class="mass mass_apply" name="APPROVED_INCREMENTAL_FUNDS" placeholder="mass apply" tabindex="-1" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" name="APPROVED_INCREMENTAL_FUNDS" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
                                    ,onCellValueChanged: changes_made
                                    ,type:'numericColumn', filter:false, width:100, floatingFilter: false
                                    ,editable:function(p) { return p.node.isRowPinned() ? false : true }
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "dollar"] 
                                                                        : ["rightA", "editable", "dollar"] } 
                                    ,sortable:true, valueParser: numberParser }
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
                ,getRowStyle:               function(p) { if (p.node.rowPinned) { return { 'font-weight': 'bold' } } }
                ,components: { customNumberFloatingFilter: getNumberFloatingFilterComponent() }
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
            glob.totals.APPROVED_INCREMENTAL_FUNDS     = 0;
            glob.totals.SALES_TARGET_ABSOLUTE_VARIANCE = 0;
            glob.totals.SALES_TARGET_FINAL             = 0;
            glob.totals.SALES_TARGET_ORIGINAL          = 0;
            glob.totals.SALES_TARGET_OVERRIDE          = 0;
            glob.totals.SALES_TARGET_OVERRIDE          = 0;
            glob.totals.TRADE_FUND_ABSOLUTE_VARIANCE   = 0;
            glob.totals.TRADE_FUND_FINAL               = 0;
            glob.totals.TRADE_FUND_ORIGINAL            = 0;
            glob.totals.TRADE_RATE_TARGET_OVERRIDE     = 0;
            glob.totals.TRADE_RATE_TARGET_OVERRIDE     = 0;

            <!--- ~~~~~~~~~~~~~~~~~~~~~~ calculate totals for visible rows ~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                glob.totals.APPROVED_INCREMENTAL_FUNDS     += rowNode.data.APPROVED_INCREMENTAL_FUNDS     !== null ? +rowNode.data.APPROVED_INCREMENTAL_FUNDS     : 0;
                glob.totals.SALES_TARGET_ABSOLUTE_VARIANCE += rowNode.data.SALES_TARGET_ABSOLUTE_VARIANCE !== null ? +rowNode.data.SALES_TARGET_ABSOLUTE_VARIANCE : 0;
                glob.totals.SALES_TARGET_FINAL             += rowNode.data.SALES_TARGET_FINAL             !== null ? +rowNode.data.SALES_TARGET_FINAL             : 0;
                glob.totals.SALES_TARGET_ORIGINAL          += rowNode.data.SALES_TARGET_ORIGINAL          !== null ? +rowNode.data.SALES_TARGET_ORIGINAL          : 0;
                glob.totals.SALES_TARGET_OVERRIDE          += rowNode.data.SALES_TARGET_OVERRIDE          !== null ? +rowNode.data.SALES_TARGET_OVERRIDE          : 0;
                glob.totals.TRADE_FUND_ABSOLUTE_VARIANCE   += rowNode.data.TRADE_FUND_ABSOLUTE_VARIANCE   !== null ? +rowNode.data.TRADE_FUND_ABSOLUTE_VARIANCE   : 0;
                glob.totals.TRADE_FUND_FINAL               += rowNode.data.TRADE_FUND_FINAL               !== null ? +rowNode.data.TRADE_FUND_FINAL               : 0;
                glob.totals.TRADE_FUND_ORIGINAL            += rowNode.data.TRADE_FUND_ORIGINAL            !== null ? +rowNode.data.TRADE_FUND_ORIGINAL            : 0;
                glob.totals.TRADE_RATE_TARGET_OVERRIDE     += rowNode.data.TRADE_RATE_TARGET_OVERRIDE     !== null ? +rowNode.data.TRADE_RATE_TARGET_OVERRIDE     : 0;
                glob.totals.TRADE_RATE_TARGET_OVERRIDE     += rowNode.data.TRADE_RATE_TARGET_OVERRIDE     !== null ? +rowNode.data.TRADE_RATE_TARGET_OVERRIDE     : 0;
            });

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~ disable these two columns ~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            glob.totals.TRADE_RATE_TARGET_OVERRIDE = null;
            glob.totals.TRADE_RATE_TARGET_FINAL = glob.totals.SALES_TARGET_FINAL && glob.totals.SALES_TARGET_FINAL !== 0 && glob.totals.TRADE_FUND_FINAL
                                                ? glob.totals.TRADE_FUND_FINAL / glob.totals.SALES_TARGET_FINAL
                                                : null;
            glob.totals.TRADE_RATE_TARGET_ORIGINAL = glob.totals.SALES_TARGET_ORIGINAL && glob.totals.SALES_TARGET_ORIGINAL !== 0 && glob.totals.TRADE_FUND_ORIGINAL
                                                ? glob.totals.TRADE_FUND_ORIGINAL / glob.totals.SALES_TARGET_ORIGINAL
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
                    show_totals();
                    changes_made();
                }
            });
        }

        ag_grid_default( glob.my_grid );

        // glob.my_grid.excelStyles.push({ id: "rightA", numberFormat: {format: '$#,###,##0'} });

        init_ag_grid( glob.my_grid, glob.grid_id, 0, 1 );

        glob.my_grid.api.setHeaderHeight(35);

        $("div.ag-header-row:nth-child(2) div:nth-child(5)").addClass("border1");
        $("div.ag-header-row:nth-child(2) div:nth-child(8)").addClass("border1");
        
        // $("div.ag-header-row-floating-filter div:nth-child(8)").addClass("border1");  // version 23

        $.ajax({    url: <cfoutput>"ajax/target_adjustments.cfm?id=#url.id#"</cfoutput>
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

        $("form").bind("keypress", function(e) {
            if (e.keyCode == 13) {
                return false;
            }
        });

        // $(window).resize(function(){ adjust_grid_height(); });

        $("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = <cfoutput>"Trade Targets #qHeader.Fiscal_Year# #qHeader.Main_Distributor_Group_Number#"</cfoutput>;
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
            return false;
        });

        $("button.save").click(function(){
            show_loader();
            let form = $("form[name=target_adjustments]");

            let row_keys = '';
            glob.my_grid.api.forEachNode(function(rowNode, index) {
                row_keys = rowNode.data.SUB_DISTRIBUTOR_GROUP_ID + '$' + rowNode.data.SUB_PRODUCT_GROUP_ID;
                if (rowNode.data.SUB_PRODUCT_GROUP_DESC !== 'TOTAL') {
                    <!--- ~~ select only rates with change ~~ --->
                    if (rowNode.data.SALES_TARGET_OVERRIDE !== rowNode.data.X_SALES_TARGET_OVERRIDE) {
                        form.append("<input type=hidden name='SALES_TARGET_OVERRIDE$" 
                                                                + row_keys
                                                                + "' value='" + rowNode.data.SALES_TARGET_OVERRIDE + "'>");
                    }
                    if (rowNode.data.TRADE_RATE_TARGET_OVERRIDE !== rowNode.data.X_TRADE_RATE_TARGET_OVERRIDE) {
                        form.append("<input type=hidden name='TRADE_RATE_TARGET_OVERRIDE$" 
                                                                + row_keys
                                                                + "' value='" + rowNode.data.TRADE_RATE_TARGET_OVERRIDE * 100.00 + "'>");
                    }
                    if (rowNode.data.APPROVED_INCREMENTAL_FUNDS !== rowNode.data.X_APPROVED_INCREMENTAL_FUNDS) {
                        form.append("<input type=hidden name='APPROVED_INCREMENTAL_FUNDS$" 
                                                                + row_keys
                                                                + "' value='" + rowNode.data.APPROVED_INCREMENTAL_FUNDS + "'>");
                    }                    
                }
            });

            $("input[name=action]").val("save");
            parent.refresh_tab_name( glob.tab_name, 0 );
            form.submit();
        });


        function getNumberFloatingFilterComponent() {
            function NumberFloatingFilter() {
            }

            NumberFloatingFilter.prototype.init = function(params) {
                this.eGui = document.createElement('div');
                this.eGui.innerHTML = '&gt; <input style="width:80%" class="perc_change" type="text"/>%';
                this.currentValue = null;
                this.eFilterInput = this.eGui.querySelector('input');
                this.eFilterInput.style.color = params.color;
                var that = this;

                function onInputBoxChanged() {
                    if (that.eFilterInput.value === '') {
                        // Remove the filter
                        params.parentFilterInstance(function(instance) {
                            instance.onFloatingFilterChanged(null, null);
                        });
                        return;
                    }

                    that.currentValue = Number(that.eFilterInput.value);
                    params.parentFilterInstance(function(instance) {
                        instance.onFloatingFilterChanged('greaterThan', that.currentValue);
                    });
                }

                this.eFilterInput.addEventListener('input', onInputBoxChanged);
            };

            NumberFloatingFilter.prototype.onParentModelChanged = function(parentModel) {
                // When the filter is empty we will receive a null message her
                if (!parentModel) {
                    this.eFilterInput.value = '';
                    this.currentValue = null;
                } else {
                    this.eFilterInput.value = parentModel.filter + '';
                    this.currentValue = parentModel.filter;
                }
            };

            NumberFloatingFilter.prototype.getGui = function() {
                return this.eGui;
            };

            return NumberFloatingFilter;
        }
    </script>

    <!--- <cfinclude template="/common_files/focus.cfm"> --->
    <cfset request.focusHiLightOff = true>
</body>
</html>