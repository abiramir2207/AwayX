<cfprocessingdirective pageencoding="utf-8">
<!---
  * ====================================================================================================
  *    @File: \developer\v2\errors2.cfm
  *  @Author: Chris Nguyen
  *    @Date: April 2020
  *
  * @Remarks: Display modern event errors from database
  *
  * ====================================================================================================
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <cfmodule template="/customTags/include.cfm" files="default.css">
</head>
<body>
    <cfmodule template="/customTags/include.cfm" files="default.css">

    <style>
        body {
            display: flex;
        }
        section#sidebar {
            width: 270px;
            height: 100vh;
            min-height: 100vh;
            /* margin-left: 15px; */
        }
        section#ag-grid {
            /* width: 100%; */
        }
        iframe.report {
            background-color: #F9F9F9;
            height: 100vh;
            flex-grow: 1;
        }
        .hamburger {
            width: 30px;
            height: 100vh;
            min-height: 100vh;
            background-color: white;
            border-right: 1px solid #ccc;
        }
        button#btn {
            font-size: 1rem;
            padding: 3px;
            margin: 5px 1px 1px 3px;
            cursor: pointer;
        }
        span.vertical {
            cursor: pointer;
            font-size: 0.8rem;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
            padding: 10px 7px;
            letter-spacing: 1px;
            writing-mode: vertical-lr;
            user-select: none;
            transform: rotate(180deg);
        }
    </style>

    <section class="hamburger">
        <button id="btn">↻</button>
        <span class="vertical refresh">Refresh &nbsp; Errors</span>
        <button id="toggle">☰</button>
        <span class="vertical toggle">Toggle &nbsp; List</span>
    </section>

    <section id="sidebar">
        <cfset list_errors()>
    </section>

    <iframe name="report" class="report" frameborder="0"></iframe>

    <script>
        var rowNode = gridOptions.api.getDisplayedRowAtIndex(0);
        $("iframe.report").attr("src", "error_detail.cfm?id=" + rowNode.data[0]);
    </script>
</body>
</html>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!---  display errors on left side bar ~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="list_errors">
    <cfquery name="qErrors" datasource="#application.datasource#">
        SELECT TOP 5000
                Cfml_Error_Log_ID
                ,CASE
                    WHEN CAST(Generated_Date AS DATE) = CAST(GETDATE() AS DATE) THEN 'Today'
                    WHEN CAST(Generated_Date AS DATE) = CAST(DATEADD(day, -1, GETDATE()) AS DATE) THEN 'Yesterday'
                    WHEN CAST(Generated_Date AS DATE) > CAST(DATEADD(day, -7, GETDATE()) AS DATE) THEN DATENAME(weekday, Generated_Date)
                    ELSE ''
                END AS WeekDay
                ,FORMAT(Generated_Date, 'MMM dd') AS Generated_Date
                ,FORMAT(Generated_Date, 'hh:mm tt') AS Generated_Time
          FROM Cfml_Error_Log
         WHERE DATALENGTH(File_Structure) > 0
         ORDER BY Cfml_Error_Log_ID DESC
    </cfquery>

    <cfset request.ag_grid_theme = "ag-theme-balham">

    <section id="ag-grid" class="ag-theme-balham">
    </section>

    <cfmodule template="/customTags/include.cfm" files="/developer/default.js">
    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
    <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/css-loader.css">
    <cfinclude template="ag-grid.cfm">

    <script>
        let errors = <cfoutput>#serializeJSON(qErrors)#</cfoutput>;

        let gridOptions = {
            defaultColDef: {     editable:        false
                                ,suppressMenu:    true
                                ,suppressMovable: true
                                ,unSortIcon:      false
                                ,sortable:        false
                                ,resizable:       false
                                ,filter:          true
                            }
            ,columnDefs: [
                            { headerName:'Error', filter: 'agTextColumnFilter', width:130, valueGetter:function(p){ return p.data[0] } }
                            ,{ headerName:'When', filter: false, valueGetter:function(p){ return (p.data[1] === '' ? p.data[2] : p.data[1] ) + ' @ ' + p.data[3] } }
            ]
            ,rowData: errors.DATA
            ,rowModelType: "clientSide"
            ,floatingFilter: true
            ,onCellClicked: function(event) {
                $("iframe.report").attr("src", "about:blank");
                $("iframe.report").attr("src", "error_detail.cfm?id=" + event.node.data[0]);
             }
        };

        ag_grid_default( gridOptions );
        init_ag_grid( gridOptions, "#ag-grid" );
        gridOptions.api.sizeColumnsToFit();

        $("#btn, span.refresh").click(function(){
            show_loader();
            window.location.reload();
        });

        $("#toggle, span.toggle").click(function(){
            $("#sidebar").toggle();
        });
    </script>
</cffunction>