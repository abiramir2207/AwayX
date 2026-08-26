<cfprocessingdirective pageencoding="utf-8">
<!---
  * ====================================================================================================
  *    @File: \developer\v2\programs.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 Feb
  *
  * @Remarks: Display programs
  *
  * ====================================================================================================
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cf_include files="default.css">

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

    <cfparam name="url.rows"     default="5000">
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


    <cfquery name="qPlanner" datasource="#application.datasource#">
        SELECT *
          FROM sys.Objects
         WHERE Object_ID = Object_id(N'dbo.Planners')
                AND Type IN ( N'U' )
    </cfquery>

    <cfquery name="qPrograms" datasource="#application.datasource#">
        SELECT TOP #url.rows#
            cst.Status_Abbreviation                AS Status
            , cm.Contract_Number                   AS Program
            , cm.Contract_Title                    AS Title
            , CONVERT(VARCHAR, cm.Contract_Created_Date, 112) AS Created
            , pcpo.created_type                    AS Template
            , (
                SELECT COUNT (1)
                  FROM Program_Fixed_Component pfc
                 WHERE pfc.Program_ID = cm.Contract_Main_ID
                        AND pfc.deleted = 0
            )                                      AS Fixed
            , (
                SELECT COUNT (1)
                  FROM Program_Rebates_Component prc
                 WHERE prc.Program_ID = cm.Contract_Main_ID
                        AND prc.deleted = 0
            )                                      AS Rebate
            , (
                SELECT COUNT (1)
                  FROM Program_Growth_Components pgc
                 WHERE pgc.Program_ID = cm.Contract_Main_ID
                        AND pgc.deleted = 0
            )                                      AS Growth
            , (
                SELECT COUNT (1)
                  FROM Program_Lump_Sums pls
                 WHERE pls.Program_ID = cm.Contract_Main_ID
                        AND pls.deleted = 0
            )                                      AS Lump_sum
            <cfif qPlanner.recordCount>
                , p.planner_number                 AS Planner
            </cfif>
            , cm.contract_main_id                  AS Program_ID
        FROM CONTRACT_MAIN                          cm
            LEFT JOIN Contract_Status_Types         cst
                ON cst.Contract_Status_Type_ID = cm.Contract_Status_Type_IDX
            LEFT JOIN Program_Control_Panel_Options pcpo
                ON pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
            <cfif qPlanner.recordCount>
                LEFT JOIN Planners p ON p.Planner_ID = cm.Planner_ID
            </cfif>
        WHERE cm.deleted = 0
                <cfif listLen(url.status)>
                    AND ( cst.Status_Abbreviation in (<cfqueryparam value="#url.status#" list="true">) )
                </cfif>
                <cfif listLen(url.discount)>
                    AND ( 1 = 0

                        <cfif url.discount contains "fixed">
                            OR (
                                    SELECT COUNT (1)
                                      FROM Program_Fixed_Component pfc
                                     WHERE pfc.Program_ID = cm.Contract_Main_ID
                                            AND pfc.deleted = 0
                                ) > 0
                        </cfif>

                        <cfif url.discount contains "rebate">
                            OR (
                                SELECT COUNT (1)
                                  FROM Program_Rebates_Component prc
                                 WHERE prc.Program_ID = cm.Contract_Main_ID
                                        AND prc.deleted = 0
                                ) > 0
                        </cfif>

                        <cfif url.discount contains "growth">
                            OR (
                                SELECT COUNT (1)
                                  FROM Program_Growth_Components pgc
                                 WHERE pgc.Program_ID = cm.Contract_Main_ID
                                        AND pgc.deleted = 0
                                ) > 0
                        </cfif>

                        <cfif url.discount contains "lumpsum">
                            OR (
                                SELECT COUNT (1)
                                  FROM Program_Lump_Sums pls
                                 WHERE pls.Program_ID = cm.Contract_Main_ID
                                        AND pls.deleted = 0
                                ) > 0
                        </cfif>
                    )
                </cfif>

                    /* full created date is given (i.e. 20211231 for Dec 31, 2021)*/
                    <cfif filter_day>
                        <cfset created_date_begin = filter_created>
                        <cfset created_date_end   = dateAdd('d', 1, created_date_begin)>

                        AND cm.Contract_Created_Date BETWEEN '#dateFormat(created_date_begin, 'yyyy/m/d')#' AND '#dateFormat(created_date_end, 'yyyy/m/d')#'

                    /* filter year and month are given (i.e. 202112 for Dec, 2021)*/
                    <cfelseif filter_month>
                        <cfset created_date_begin = createDate(filter_year, filter_month, 1)>
                        <cfset created_date_end   = dateAdd('m', 1, created_date_begin)>

                        AND cm.Contract_Created_Date BETWEEN '#dateFormat(created_date_begin, 'yyyy/m/d')#' AND '#dateFormat(created_date_end, 'yyyy/m/d')#'

                    /* filter year is given (i.e. 2021 for 2021)*/
                    <cfelseif filter_year gte 2000 and filter_year lte 2100>
                        <cfset created_date_begin = createDate(filter_year, 1, 1)>
                        <cfset created_date_end   = createDate(filter_year, 12, 31)>

                        AND cm.Contract_Created_Date BETWEEN '#dateFormat(created_date_begin, 'yyyy/m/d')#' AND '#dateFormat(created_date_end, 'yyyy/m/d')#'
                    </cfif>

        ORDER BY cm.Contract_Main_ID DESC
    </cfquery>


    <script>
        "use strict";

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

        let programs = <cfoutput>#serializeJSON(qPrograms)#</cfoutput>;

        let gridOptions = {
            defaultColDef: {     editable:        false
                                ,suppressMenu:    true
                                ,suppressMovable: false
                                ,unSortIcon:      false
                                ,sortable:        true
                                ,resizable:       true
                                ,filter:          'agSetColumnFilter'
                            }
            ,columnDefs: [
                            { headerName:'Status', valueGetter:function(p){ return p.data[0] }, width:100 }
                            ,{ headerName:'Program', valueGetter:function(p){ return p.data[1] }, filter:"agTextColumnFilter", width:100 }
                            ,{ headerName:'Title', valueGetter:function(p){ return p.data[2] }, filter:"agTextColumnFilter" }
                            ,{ headerName:'Created Date', valueGetter:function(p){ return p.data[3] }, filter:"agTextColumnFilter", valueFormatter:function(p) { return dateFormat( p.value ) }, width:100 }
                            ,{ headerName:'Template', valueGetter:function(p){ return p.data[4] } }
                            ,{ headerName:'#Fixed Price', valueGetter:function(p){ return p.data[5] }, width:100, valueFormatter:function(p) { return discountFormat(p.value) }, cellClass:"right" }
                            ,{ headerName:'#Rebate', valueGetter:function(p){ return p.data[6] }, width:100 , valueFormatter:function(p) { return discountFormat(p.value) }, cellClass:"right" }
                            ,{ headerName:'#Growth', valueGetter:function(p){ return p.data[7] }, width:100 , valueFormatter:function(p) { return discountFormat(p.value) }, cellClass:"right" }
                            ,{ headerName:'#Lump Sum', valueGetter:function(p){ return p.data[8] }, width:100, valueFormatter:function(p) { return discountFormat(p.value) }, cellClass:"right" }
                            ,{ headerName:'Program ID', valueGetter:function(p){ return p.data[10] }, width:100 }
                            <cfif qPlanner.recordCount>
                                ,{ headerName:'<CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT>', valueGetter:function(p){ return p.data[9] }, width:100, filter:"agTextColumnFilter" }
                            </cfif>
                        ]
            ,rowData: programs.DATA
            ,rowModelType: "clientSide"
            ,floatingFilter: true
            ,suppressContextMenu: false             // allow copy operation
        };

        ag_grid_default( gridOptions );
        init_ag_grid( gridOptions, "#ag-grid" );

        gridOptions.api.sizeColumnsToFit();
    </script>
</body>
</html>
