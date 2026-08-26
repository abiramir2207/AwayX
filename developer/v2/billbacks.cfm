<cfprocessingdirective pageencoding="utf-8">
<!---
  * ====================================================================================================
  *    @File: \developer\v2\billbacks.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 Feb
  *
  * @Remarks: Display billbacks
  *
  * ====================================================================================================
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfmodule template="/customTags/include.cfm" files="default.css">

    <style>
        .right {
            text-align: right;
        }
    </style>

    <cfset request.ag_grid_theme = "ag-theme-balham">

    <section id="ag-grid" class="ag-theme-balham"></section>

    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
    <cfinclude template="ag-grid.cfm">

    <!--- url parameter validations --->
    <cfif structKeyExists(url, "rows") and !isNumeric(url.rows)>
        <cfset structDelete(url, "rows")>
    </cfif>

    <cfparam name="url.rows"     default="4000">
    <cfparam name="url.status"   default="">
    <cfparam name="url.discount" default="">

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~ filter by created date, formatted as yyyymmdd where mm and dd are optional ~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfparam name="url.created"  default="">

    <cfscript>
        filter_year  = 0;
        filter_month = 0;
        filter_day   = 0;


        if (url.created neq '' and isNumeric(url.created) ) {
            if ( len(url.created) gte 4 ) {
                // get the first 4 digits year
                filter_year  = left(url.created, 4);

                // get the next 2 digits month (i.e 01 for Jan)
                if ( len(url.created) gte 6 ) {
                    filter_month = mid(url.created, 5, 2);

                    if ( (filter_month lte 0) or (filter_month gt 12) ) {
                        filter_month = 0;
                    }
                    else {
                        // get the next 2 digits day (i.e 01 for first day of the month)
                        if ( len(url.created) gte 8 ) {
                            filter_day = mid(url.created, 7, 2);

                            if ((filter_day gt 0) and (filter_day lte 31)) {
                                try {
                                    // build the filtering created date - if it is invalid set filter_day to zero
                                    filter_created = createDate(filter_year, filter_month, filter_day);
                                }
                                catch (any e) {
                                    filter_day = 0;
                                }
                            }
                            else {
                                filter_day = 0;
                            }
                        }
                    }
                }
            }
        }
    </cfscript>

    <cfquery name="qBillbacks" datasource="#application.datasource#">
        SELECT TOP #url.rows#
                     /* 0 */ bbs.BB_Status_Abbreviation
                     /* 1 */, bb_code
                     /* 2 */, bb.BB_Title
                     /* 3 */, BB_Reference
                     /* 4 */, CONVERT(VARCHAR, bb.Created_Date, 112) AS Created
                     /* 5 */, bb.Billback_ID_Int
             FROM Billback                   bb
                LEFT JOIN Billback_Status   BBS
                    ON BBS.Billback_Status_ID = BB.Billback_Status_ID
            WHERE bb.deleted = 0

                    /* full created date is given (i.e. 20211231 for Dec 31, 2021)*/
                    <cfif filter_day>
                        <cfset created_date_begin = filter_created>
                        <cfset created_date_end   = dateAdd('d', 1, created_date_begin)>

                        AND bb.Created_Date BETWEEN '#dateFormat(created_date_begin, 'yyyy/m/d')#' AND '#dateFormat(created_date_end, 'yyyy/m/d')#'

                    /* filter year and month are given (i.e. 202112 for Dec, 2021)*/
                    <cfelseif filter_month>
                        <cfset created_date_begin = createDate(filter_year, filter_month, 1)>
                        <cfset created_date_end   = dateAdd('m', 1, created_date_begin)>

                        AND bb.Created_Date BETWEEN '#dateFormat(created_date_begin, 'yyyy/m/d')#' AND '#dateFormat(created_date_end, 'yyyy/m/d')#'

                    /* filter year is given (i.e. 2021 for 2021)*/
                    <cfelseif filter_year gte 2000 and filter_year lte 2100>
                        <cfset created_date_begin = createDate(filter_year, 1, 1)>
                        <cfset created_date_end   = createDate(filter_year, 12, 31)>

                        AND bb.Created_Date BETWEEN '#dateFormat(created_date_begin, 'yyyy/m/d')#' AND '#dateFormat(created_date_end, 'yyyy/m/d')#'
                    </cfif>

            ORDER BY bb.created_date DESC
    </cfquery>

    <cfquery name="qPrograms" datasource="#application.datasource#">
        SELECT
                CM.Contract_Number
                , CM.Contract_Main_ID
                , CM.Contract_Title
                , (
                    SELECT COUNT (1)
                    FROM Program_Fixed_Component pfc
                    WHERE pfc.Program_ID = cm.Contract_Main_ID
                            AND pfc.deleted = 0
                )                                       AS Fixed
                , (
                    SELECT COUNT (1)
                    FROM Program_Rebates_Component prc
                    WHERE prc.Program_ID = cm.Contract_Main_ID
                            AND prc.deleted = 0
                )                                       AS Rebate
                , (
                    SELECT COUNT (1)
                    FROM Program_Growth_Components pgc
                    WHERE pgc.Program_ID = cm.Contract_Main_ID
                            AND pgc.deleted = 0
                )                                       AS Growth
                , (
                    SELECT COUNT (1)
                    FROM Program_Lump_Sums pls
                    WHERE pls.Program_ID = cm.Contract_Main_ID
                            AND pls.deleted = 0
                )                                       AS Lump_sum
                , Billback_ID_Int
        FROM Billback                   bb
            JOIN Billback_Program bbp
                ON bbp.Billback_ID = bb.Billback_ID
                AND bbp.Deleted = 0
            JOIN Contract_Main    CM
                ON CM.Contract_Main_ID = BBP.Program_ID
        WHERE bb.deleted = 0
                AND Billback_ID_Int IN (#valueList(qBillbacks.Billback_ID_Int)#)
            ORDER BY bb.created_date DESC
    </cfquery>

    <script>
        "use strict";

        let programs = 0;

        function dateFormat( str ) {
            let year  = str.substring(0, 4);
            let month = str.substring(4, 6);
            let day   = str.substring(6, 8);

            return month + '/' + day + '/' + year;
        }

        function discountFormat( count ) {
            // display empty when count is zero
            return count ? count : '';
        }

        let billbacks = <cfoutput>#serializeJSON(qBillbacks)#</cfoutput>;

        // locate related programs for a single BB
        // convert programs into JSON format
        // insert programs for a single BB into JSON input for Ag-grid
        <cfsetting enablecfoutputonly="true">
        <cfloop query="qBillbacks">
            <cfquery name="qPRG" dbtype="query">
                SELECT *
                  FROM qPrograms
                  WHERE Billback_ID_Int = <cfoutput>#qBillbacks.Billback_ID_Int#</cfoutput>
            </cfquery>
            <cfoutput>programs = #serializeJSON(qPRG)#; billbacks.DATA[#(qBillBacks.currentRow - 1)#][6] = programs.DATA;</cfoutput>
        </cfloop>
        <cfsetting enablecfoutputonly="false">

        function discountFormat( count ) {
            // display empty when count is zero
            return count ? count : '';
        }


        let gridOptions = {
            defaultColDef: {     editable:        false
                                ,suppressMenu:    true
                                ,suppressMovable: false
                                ,unSortIcon:      false
                                ,sortable:        true
                                ,resizable:       true
                                ,flex: 1
                                ,filter:          false
                            }
            ,columnDefs: [
                            { headerName:'Status', valueGetter:function(p){ return p.data[0] }, width:100, cellRenderer: 'agGroupCellRenderer', filter:          'agSetColumnFilter' }
                            ,{ headerName:'BB Code', valueGetter:function(p){ return p.data[1] }, filter:"agTextColumnFilter", width:100 }
                            ,{ headerName:'Title', valueGetter:function(p){ return p.data[2] }, filter:"agTextColumnFilter" }
                            ,{ headerName:'Created Date', valueGetter:function(p){ return p.data[4] }, filter:"agTextColumnFilter", valueFormatter:function(p) { return dateFormat( p.value ) }, width:100 }
                            ,{ headerName:'Reference', valueGetter:function(p){ return p.data[3] }, filter:"agTextColumnFilter" }
                            ,{ headerName:'BB ID', valueGetter:function(p){ return p.data[5] }, width:100, filter:"agTextColumnFilter" }
                        ]
            ,rowData: billbacks.DATA
            ,rowModelType: "clientSide"
            ,floatingFilter: true
            ,suppressContextMenu: false             // allow copy operation

            ,masterDetail: true
            ,detailCellRendererParams: {
                                        detailGridOptions: {
                                                                columnDefs: [
                                                                    { headerName:'Program', valueGetter:function(p){ return p.data[0] } }
                                                                    ,{ headerName:'ID', valueGetter:function(p){ return p.data[1] } }
                                                                    ,{ headerName:'Title', valueGetter:function(p){ return p.data[2] } }
                                                                    ,{ headerName:'#Fixed', valueGetter:function(p){ return p.data[3] }, valueFormatter:function(p) { return discountFormat(p.value) } }
                                                                    ,{ headerName:'#Rebate', valueGetter:function(p){ return p.data[4] }, valueFormatter:function(p) { return discountFormat(p.value) } }
                                                                    ,{ headerName:'#Growth', valueGetter:function(p){ return p.data[5] }, valueFormatter:function(p) { return discountFormat(p.value) } }
                                                                    ,{ headerName:'#Lump Sum', valueGetter:function(p){ return p.data[6] }, valueFormatter:function(p) { return discountFormat(p.value) } }
                                                                ],
                                                                defaultColDef: {
                                                                    flex: 1
                                                                }
                                                            },
                                                            getDetailRowData: function (params) { params.successCallback( params.data[6] ); }
                                                        }
        };

        ag_grid_default( gridOptions );
        init_ag_grid( gridOptions, "#ag-grid" );

        gridOptions.api.sizeColumnsToFit();
    </script>
</body>
</html>
