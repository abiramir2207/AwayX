<cfprocessingdirective pageencoding="utf-8">
<!---
  * ====================================================================================================
  *    @File: \developer\v2\_auditing.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 June
  *
  * @Remarks: Display rows in the _Auditing table
  *
  * ====================================================================================================
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auditing</title>
</head>
<body>
    <cfmodule template="/customTags/include.cfm" files="default.css">
    <cfset request.ag_grid_theme = "ag-theme-balham">
    <section id="ag-grid" class="ag-theme-balham"></section>

    <script src="https://cdn.awayx.com/base/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
    <cfinclude template="ag-grid.cfm">

    <!--- pull all rows within a recent year for best performance --->
    <cfquery name="qAuditings" datasource="#application.datasource#">
        SELECT  Table_Name
                ,Record_Description
                , Column_Name
                , New_Value
                , Old_Value
                , Updated_By
                , CONVERT( VARCHAR, Updated_On, 112 ) AS Updated_Date
                , FORMAT( Updated_On, 'hh:mm:ss tt' ) as Updated_Time
          FROM _Auditing
         WHERE 1 = 1
               AND Updated_On >= DATEADD( DAY, -366, GETDATE() )
        ORDER BY Audit_ID DESC
    </cfquery>


    <script>
        "use strict";

        let auditings = <cfoutput>#serializeJSON( qAuditings )#</cfoutput>;

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
                            { headerName:'Table', valueGetter:function(p){ return p.data[0] } }
                            ,{ headerName:'Record Desc', valueGetter:function(p){ return p.data[1] } }
                            ,{ headerName:'Column', valueGetter:function(p){ return p.data[2] } }
                            ,{ headerName:'New Value', valueGetter:function(p){ return p.data[3] }, filter:"agTextColumnFilter", sortable: false }
                            ,{ headerName:'Old Value', valueGetter:function(p){ return p.data[4] }, filter:"agTextColumnFilter", sortable: false }
                            ,{ headerName:'Updated By', valueGetter:function(p){ return p.data[5] } }
                            ,{ headerName:'Updated Date', valueGetter:function(p){ return p.data[6] }, valueFormatter:function(p) { return p.value.substring(4, 6)
                                                                                                                                            + '/' + p.value.substring(6, 8)
                                                                                                                                            + '/' + p.value.substring(0, 4); }, sortable: true }
                            ,{ headerName:'Updated Time', valueGetter:function(p){ return p.data[7] }, sortable: false, filter:false }
                        ]
            ,rowData: auditings.DATA
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
