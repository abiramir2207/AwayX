<cfprocessingdirective pageencoding="utf-8">
<!---
  * ====================================================================================================
  *    @File: \developer\v2\tables.cfm
  *  @Author: Chris Nguyen
  *    @Date: April 2020
  *
  * @Remarks: Display database tables
  *
  * ====================================================================================================
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DB Tables in <cfoutput>#cgi.SERVER_NAME#</cfoutput></title>
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
        <button id="btn">☰</button>
        <span class="vertical toggle">Toggle &nbsp; List</span>
        <!--- &nbsp; &nbsp; &nbsp; &nbsp; <span class="vertical users">Blacksmith &nbsp; Users</span> --->
    </section>

    <section id="sidebar">
        <cfset list_tables()>
    </section>

    <iframe name="report" class="report" frameborder="0"></iframe>

    <script>
        var rowNode = gridOptions.api.getDisplayedRowAtIndex(0);
        // $("iframe.report").attr("src", "view_db_schema.cfm?table_name=" + rowNode.data[0]);
        $("iframe.report").attr("src", "queryDatabase2.cfm?query=select * from " + rowNode.data[0]);
    </script>
</body>
</html>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!---  display tables on left side bar ~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="list_tables">
    <cfquery name="qTables" datasource="#application.datasource#">
        SELECT '_Blacksmith_Users' AS Table_Name
        UNION
        SELECT Table_Name FROM INFORMATION_SCHEMA.TABLES
         WHERE TABLE_TYPE = 'BASE TABLE'
                AND NOT Table_Name LIKE '@%'
                AND NOT Table_Name LIKE '_##%'
         ORDER BY Table_Name
    </cfquery>

    <cfset all_caps = [
        "bb"
        ,"bsa"
        ,"cp"
        ,"cs"
        ,"dd"
        ,"forge"
        ,"id"
        ,"idx"
        ,"lb"
        ,"lbs"
        ,"ldap"
        ,"rfa"
        ,"os"
        ,"sp"
        ,"upc"
        ,"usda"
        ,"wip"
        ]>

    <!--- format table names --->
    <cfloop from="1" to="#qTables.recordCount#" index="counter">
        <cfscript>
            column = qTables.table_name[counter];
            // parse elements in the name separated by underscore character into an array
            elements = listToArray(column, '_');
            for (i=1; i lte arrayLen(elements); i++) {
                if (arrayFindNoCase(all_caps, elements[i]))
                    elements[i] = ucase(elements[i]);
                else
                    // capitalize the first letter and lowercase the rest
                    elements[i] = ucase(left(elements[i],1)) & lcase(Mid(elements[i], 2, len(elements[i])-1));
            }
            // combine all elements back
            qTables.table_name[counter] = arrayToList(elements, "_");
            if (left(column, 1) eq "_")
                qTables.table_name[counter] = '_' & qTables.table_name[counter];
        </cfscript>
    </cfloop>

    <!--- <cfdump var="#qTables#" abort="true"> --->

    <cfset request.ag_grid_theme = "ag-theme-balham">

    <section id="ag-grid" class="ag-theme-balham">
    </section>

    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
    <cfinclude template="ag-grid.cfm">

    <script>
        let tables = <cfoutput>#serializeJSON(qTables)#</cfoutput>;

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
                            { headerName:'Name'
                                , filter: 'agTextColumnFilter'
                                , field: 'Name'
                                // , filter: 'agSetColumnFilter'
                                ,valueGetter:function(p){ return p.data[0] }
                            }
            ]
            ,rowData: tables.DATA
            ,rowModelType: "clientSide"
            ,floatingFilter: true
            ,onCellClicked: function(event) {
                $("iframe.report").attr("src", "about:blank");
                let sql = '';
                if ( event.node.data[0].toLowerCase() === '_blacksmith_users' ) {
                   sql = event.node.data[0];
                    $("iframe.report").attr("src", "queryDatabase.cfm?query=" + sql);
                }
                else {
                    sql = "select * from " + event.node.data[0];
                    $("iframe.report").attr("src", "queryDatabase2.cfm?query=" + sql);
                }
             }
        };

        ag_grid_default( gridOptions );
        init_ag_grid( gridOptions, "#ag-grid" );
        gridOptions.api.sizeColumnsToFit();

        $("#btn, span.toggle").click(function(){
            $("#sidebar").toggle();
        });

        function copyToClipboard( text ) {
            var $temp = $( "<input>" );
            $( "body" ).append( $temp );
            $temp.val( text ).select();
            document.execCommand( "copy" );
            $temp.remove();
        }

		$( "#ag-grid" ).dblclick( function( e ) {
			let clipboard = $( e.target ).text();
			console.log( { clipboard } );
			copyToClipboard( clipboard );
		});

        const storage_name = "tables.cfm";
        window.addEventListener('beforeunload', function (e) {
            localStorage.setItem( storage_name, $( "input.ag-floating-filter-input" ).val() );
        });

        gridOptions.api.setFilterModel( { Name: { filterType: 'text', type: 'startsWith', filter:localStorage.getItem( storage_name ) } } );
    </script>
</cffunction>