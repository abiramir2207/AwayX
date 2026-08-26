<!---
  * ====================================================================================================
  *    @File: /developer/queryDatabase.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019-03-07 13:17:54
  *
  * @Remarks: Development tool executes a db query and display the query result
  *
  * ====================================================================================================
--->
<!DOCTYPE html>
<html>
<head>
    <title>Query Database | Developer Tools</title>

	<cfsavecontent variable="head_content">
	<link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/tailwind/0.7/tailwind.min.css?v=080654236">
    <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/css-loader.css">
    <style>
        /* body { overflow: hidden; } */
        * { box-sizing: border-box; }
		p { font-size:13px; }
		#query { display:block; font-family:"Lucida Console", "Arial"; font-size:11px; width:99%; min-height:15vh; margin:5px; padding: 5px; }
        div.ag-input-text-wrapper {
            margin-top: 5px;
        }
        button.button {
            background-color: #edeef2;
            border-radius: 50px;
            border: 1px solid #d8d9dd;
            box-sizing: border-box;
            box-shadow: 0px 2px 4px -1px rgba(86, 87, 96, 0.3);
            color: #343540;
            font-size: 11px;
            font-weight: 500;
            height: 20px;
            margin: 0 5px;
            padding: 0px 8px 0 8px;
            white-space: nowrap;
        }
        button.button:hover {
            color: #406be4;
            background-color: #fff;
        }
        button.button:focus {
            outline: 0;
        }
        button.button:disabled,
        button.button[disabled] {
            background-color: #edeef2;
            border: 1px solid #edeef2;
            color: #c4c5c7;
        }
        button.alt {
            background-color: #ffffff;
            border: 1px solid #d8d9dd;
            color: #343540;
        }
        button.recommended {
            background-color: #406be4;
            border: 1px solid #406be4;
            color: #ffffff;
        }
        button.recommended:enabled:hover,
        button.recommended[enabled]:hover {
            background-color: #406be4;
            color: #ffffff;
            opacity: .9;
        }
        button.minor {
            background-color: transparent !important;
            border: none;
            box-shadow: none;
            color: #406be4;
        }
		button.minor:hover {
			text-decoration: underline;
		}
		button.minor:active {
			color: #1e4dd3;
		}
		button.minor:disabled,
		button.minor[disabled] {
			border: none;
			color: #c4c5c7;
		}
        button.danger {
            background-color: #bf1c36;
            border: 1px solid #bf1c36;
            color: #ffffff;
        }

		button.danger:hover {
			background-color: #bf1c36;
			color: #ffffff;
			opacity: .9;
		}

		button.warning {
            border: 1px solid #bf1c36;
            color: #bf1c36;
		}

        button.warning:hover {
            color: #406be4;
        }

		button.outline.danger {
            background-color: #ffffff;
            border: 1px solid #bf1c36;
            color: #bf1c36;
        }

		button.outline.danger:hover {
        	background-color: #bf1c36;
            color: #ffffff;
            opacity: .9;
		}

	    button.success {
	        background-color: #099c09;
	        border: 1px solid #099c09;
	        color: #fff;
	    }
        button.success:hover {
            background-color: #088908;
            color: #fff;
        }
        button.outline.success {
            background-color: #ffffff;
            border: 1px solid #099c09;
            color: #099c09;
        }
		button.outline.success:hover {
		   background-color: #088908;
		   color: #fff;
    	}
        textarea {
            padding: 10px;
            border-radius: 5px;
            border: 1px solid #CCC;
            background-color: #fff;
        }
        #query:focus, textarea:focus {
            outline: none;
            box-shadow: 0 0 2px 1px #719ECE;
            /* border-color: #719ECE; */
            box-shadow: 0 0 0 3px rgba(21, 156, 228, 0.4);
            font-size: 13px;
        }
	</style>
    </cfsavecontent>

	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#head_content#">
</head>
<body>
    <!--- query parameter may be passed in the URL --->
    <cfif structKeyExists(url, "query") and !structKeyExists(form, "query")>
        <cfset form.query = url.query>
    </cfif>

    <cfparam name="form.query" default="">
    <!--- <div style="margin:1vh 5px;height:5vh;" class="flex items-center bg-blue-lightest text-blue-dark text-sm font-bold border-t border-b border-blue px-4 py-3" role="alert">
        <svg class="fill-current w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.432 0c1.34 0 2.01.912 2.01 1.957 0 1.305-1.164 2.512-2.679 2.512-1.269 0-2.009-.75-1.974-1.99C9.789 1.436 10.67 0 12.432 0zM8.309 20c-1.058 0-1.833-.652-1.093-3.524l1.214-5.092c.211-.814.246-1.141 0-1.141-.317 0-1.689.562-2.502 1.117l-.528-.88c2.572-2.186 5.531-3.467 6.801-3.467 1.057 0 1.233 1.273.705 3.23l-1.391 5.352c-.246.945-.141 1.271.106 1.271.317 0 1.357-.392 2.379-1.207l.6.814C12.098 19.02 9.365 20 8.309 20z"/></svg>
        <p class="opacity-100">Enter your SQL statements and click F5 to view the result.</p>
    </div> --->

    <!--- <div style="margin:1vh auto;width:99%;height:5vh;" class="flex items-center bg-blue text-white text-sm font-bold px-4 py-3" role="alert">
        <svg class="fill-current w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.432 0c1.34 0 2.01.912 2.01 1.957 0 1.305-1.164 2.512-2.679 2.512-1.269 0-2.009-.75-1.974-1.99C9.789 1.436 10.67 0 12.432 0zM8.309 20c-1.058 0-1.833-.652-1.093-3.524l1.214-5.092c.211-.814.246-1.141 0-1.141-.317 0-1.689.562-2.502 1.117l-.528-.88c2.572-2.186 5.531-3.467 6.801-3.467 1.057 0 1.233 1.273.705 3.23l-1.391 5.352c-.246.945-.141 1.271.106 1.271.317 0 1.357-.392 2.379-1.207l.6.814C12.098 19.02 9.365 20 8.309 20z"/></svg>
        <p class="opacity-75">Enter your SQL statements into this box below and click f5 to view the result.</p>
    </div> --->

    <div>
        <form method="post" id="querydatabase">
            <cfoutput><textarea name="query" id="query">#form.query#</textarea></cfoutput>
        </form>
    </div>
    <div style="margin:5px">
        <button class="button recommended f5">F5 execute</button>
        <button class="button f7">F7 switch view</button>
        <button class="button f9">F9 format</button>
        <button class="button reset danger">reset</button>
        <!--- <button class="button resize" style="float:right;">-</button> --->
    </div>


    <cfscript>
        adminObj = createObject("component", "cfide.adminapi.administrator");
        cf_admin = application.util.query.cf_admin();
        adminObj.login( cf_admin.password, cf_admin.username );
        datasource        = createObject("component", "cfide.adminapi.datasource");
        server.datasource = datasource.getDatasources( application.datasource );
        db_host = len(server.datasource.host)
                                ? server.datasource.host
                                : replaceNocase(server.datasource.url, 'jdbc:macromedia:sqlserver:', '');
        avoid_keywords    = application.util.io.isProduction()          // detect production by url
                                    or db_host contains "prod"          // dbprod*
                                    or db_host contains "occ00db"       // Simplot
                                    or db_host contains "cagdb"         // Conagra
                                ? [
                                            "ADD"
                                        , "ALTER"
                                        , "BACKUP"
                                        , "CHECK"
                                        , "COLUMN"
                                        , "COMMIT"
                                        , "DROP"
                                        , "CREATE"
                                        , "DELETE"
                                        , "EXEC"
                                        , "EXECUTE"
                                        , "GRANT"
                                        , "INSERT"
                                        , "ROLLBACK"
                                        , "TRAN"
                                        , "TRANSACTION"
                                        , "TRUNCATE"
                                        , "UPDATE"
                                    ]
                                : [];           // development or stage do not restrict anything
        query_failure = false;
    </cfscript>

    <!--- do not allow operations that change db schema/content in production --->
    <cfif form.query neq ''>
        <cfloop from="1" to="#arrayLen(avoid_keywords)#" index="keyword_counter">
            <cfif FindNoCase(avoid_keywords[keyword_counter] & ' ', form.query)
                or FindNoCase(avoid_keywords[keyword_counter] & chr(13) & chr(10), form.query)>
                <p>Sorry! Your database query is not permitted.</p>
                <cfset query_failure = true>
            </cfif>
        </cfloop>
    </cfif>

    <cfif !query_failure and form.query neq ''>
        <cftry>
            <!--- <cfset max_rows = val(application.util.query.get_setting("queryDatabase_maxrows", 0))> --->
            <!--- <cfset max_rows = max_rows eq 0 ? 5000 : max_rows> --->
            <cfset max_rows = 500>
            <cfset max_rows = 100>
            <!--- <cfquery name="qData" datasource="#application.datasource#" maxrows="#max_rows#" result="qResult"> --->
            <cfquery name="qData" datasource="#application.datasource#">
                SELECT TOP #max_rows# *
                  FROM (#PreserveSingleQuotes(FORM.query)#) Loremipsumdolor
            </cfquery>
            <cfcatch>
                <cfset query_failure = true>
                <cfoutput>
                <p style="color:red"><b>#cfcatch.message#</b> - #replaceNoCase(cfcatch.Detail, "[Macromedia][SQLServer JDBC Driver][SQLServer]", '', "all")#</p>
                </cfoutput>
            </cfcatch>
        </cftry>
    </cfif>

    <cfmodule template="/customTags/include.cfm" files="/developer/default.js">
    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>

    <cfif !query_failure and form.query neq ''>
        <cfscript>
            // request.ag_grid_version = 20;
            columns                 = [];
        </cfscript>


        <cfif !isDefined("qData")>
            <p class="result" style="width:99%;margin:0 auto;">Done.</p>
        <cfelse>
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
            <cfset aColumns = qData.getColumnList()>
<!---
            <cfloop from="1" to="#arrayLen(aColumns)#" index="counter">
                <cfscript>
                    column = aColumns[counter];
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
                    headerName = arrayToList(elements, "_");
                    arrayAppend(columns, '{headerName:"#headerName#"'
                                            & (counter eq 1 ? ',pinned:"left"' : '')
                                            & ',filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }'
                                            & ',valueGetter:function(p){return p.data[' & (counter - 1) & ']}}') ;
                </cfscript>
            </cfloop>

        --->
            <cfloop from="1" to="#(qData.recordCount + 1)#" index="counter">
                <cfif counter eq 1>
                    <cfset arrayAppend(columns, '{headerName:"Column"'
                                                & ',pinned:"left", floatingFilter:true'
                                                & ',filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }'
                                                & ',valueGetter:function(p){return p.data[' & (counter - 1) & ']}}'
                                                )>
                <cfelse>
                    <cfset headerName = "Row " & (counter - 1)>
                    <cfset arrayAppend(columns, '{headerName:"#headerName#"'
                                                & ',filter:false, sortable:false'
                                                & ',valueGetter:function(p){return p.data[' & (counter - 1) & ']}}'
                    )>
                </cfif>
            </cfloop>

            <div id="aggrid" style="height:74vh;width:99%;margin:0 auto;padding:0;" class="ag-theme-balham"></div>

            <cfset request.ag_grid_version = "24">
            <cfset request.ag_grid_theme   = "ag-theme-balham">

            <cfoutput>
                <cfinclude template="/common_files/ag-grid.cfm">

                <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/24/styles/ag-grid.css">
                <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/24/styles/#request.ag_grid_theme#.css">
            </cfoutput>

            <cfset local.rows = []>

            <cfset metaData  = qData.getMetaData()>
            <cfset aMetaData = getMetaData( qData )>


            <cfset local.columns = []>
            <cfloop from="1" to="#metadata.getColumnCount()#" index="index">
                <cfset arrayAppend(local.columns, metadata.getColumnName(index))>
            </cfloop>

            <cfloop from="1" to="#arrayLen(local.columns)#" index="local.column_counter">
                <cfset local.column_name = local.columns[ local.column_counter ]>
                <cfscript>
                    elements = listToArray(local.column_name, '_');
                    for (i=1; i lte arrayLen(elements); i++) {
                        if (arrayFindNoCase(all_caps, elements[i]))
                            elements[i] = ucase(elements[i]);
                        else
                            // capitalize the first letter and lowercase the rest
                            elements[i] = ucase(left(elements[i],1)) & lcase(Mid(elements[i], 2, len(elements[i])-1));
                    }

                    // combine all elements back
                    local.column_name = arrayToList(elements, "_");

                    // add data types
                    for (i=1; i lte aMetaData.len(); i++) {
                        if ( trim( aMetaData[ i ].Name ) == trim( local.column_name ) ) {
                            local.column_name = local.column_name & " = " & aMetaData[ i ].TypeName;
                            break;
                        }
                    }
                </cfscript>
                <cfset local.row = [ local.column_name ]>

                <!--- gather all row values for a specific column --->
                <cfloop from="1" to="#qData.recordCount#" index="local.record_counter">
                    <cfset arrayAppend( local.row, qData[ local.columns[ local.column_counter ] ][ local.record_counter ])>
                </cfloop>

                <cfset arrayAppend( local.rows, local.row )>
            </cfloop>

            <script>
                // set_grid_full_height("aggrid", -130);
                function onFilterTextBoxChanged() {
                    gridoptions.api.setQuickFilter(document.getElementById('filter-text-box').value);
                }

                let gridoptions = {
                                    columnDefs:         [<cfoutput>#arrayToList(columns)#</cfoutput>]
                                    , enableRangeSelection: false
                                    , floatingFilter: true
                                    , pagination:         false
                                    , paginationPageSize: 10000
                                    , onFirstDataRendered: resize_all_columns
                                    , rowModelType:       "clientSide"
                                    , rowSelection:         "multiple"
                                    , suppressRowClickSelection: true
                                    , suppressContextMenu: false
                                    , rowData:            <cfoutput>#serializeJSON( local.rows )#</cfoutput>
                                };

                ag_grid_default(gridoptions);     // set up default features

                gridoptions.defaultColDef.suppressMenu = true;

                init_ag_grid( gridoptions, "#aggrid", false );

                // $( "div[col-id=0]" ).dblclick( function() {
                //     var text = $(this).text().split( " = " )[ 0 ];
                //     copyToClipboard( text );
                // });

                function copyToClipboard( text ) {
                    let $temp = $( "<input>" );
                    $( "body" ).append( $temp );
                    $temp.val( text ).select();
                    document.execCommand( "copy" );
                    $temp.remove();
                }

                $( "#aggrid" ).dblclick( function( e ) {
                    let clipboard = $( e.target ).text().split( " = " )[ 0 ];
                    console.log( { clipboard } );
                    copyToClipboard( clipboard );
                });

                // auto size all columns
                function resize_all_columns() {
                    // let allColumnIds = [];
                    // gridoptions.columnApi.getAllColumns().forEach(function(column) {
                    //     allColumnIds.push(column.colId);
                    // });
                    // gridoptions.columnApi.autoSizeColumns(allColumnIds);
                }

                // adjust columns to fit when window is resized
                $(window).resize(function(){
                    // set_grid_full_height("aggrid");
                    // gridoptions.api.sizeColumnsToFit();
                    // resize_all_columns();
                });

                gridoptions.api.closeToolPanel();

                function clearfilters() {
                    gridoptions.api.setFilterModel(null);
                    gridoptions.api.onFilterChanged();
                    $("#filter-text-box").val('');
                    onFilterTextBoxChanged();
                };

                function onBtExport() {
                    gridoptions.api.exportDataAsExcel();
                };
            </script>
        </cfif>
    </cfif>

    <script src="https://unpkg.com/sql-formatter@latest/dist/sql-formatter.min.js"></script>
    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/autosize/autosize.min.js"></script>

    <script>
        format();

        $("#execute_sql, button.f5").click(function() {
            execute_sql();
        });

		function execute_sql() {
			let q = document.getElementById("query");
			if (q.value !== '') {
                // $("#execute_sql").text("executing, please wait...");
                // $("#aggrid, .result, #actions, #filter-text-box").fadeOut(1000);
                show_loader();
                $("form#querydatabase").submit();
			}
		}

		function resetQuery() {
			document.getElementById("query").value = '';
        }

        document.onkeydown = function() {
            switch (event.keyCode) {
                case 116 : //F5 button
                    event.returnValue = false;
                    event.keyCode = 0;
                    execute_sql();
                    return false;
                case 118 : //F7 button
                    switch_view();
                    return false;
                case 120 : //F9 button
                    format();
                    return false;
                case 82 : //R button
                    if (event.ctrlKey) {
                        return true;
                    }
            }
        }

        $("button.export").click(function(){
            let file_title  = "Developer Tools Export";
            gridoptions.api.exportDataAsExcel( { fileName: file_title, sheetName: file_title } );
            return false;
        });

        function switch_view() {
            show_loader();
            const q = $("textarea").val().replace(/\n/g, " ");
            window.location = "queryDatabase.cfm?query=" + q;
        }

        $("button.f7").click(function(){
            switch_view();
        });

        $("button.f9").click(function(){
            format();
        });

        $("button.reset").click(function(){
            $("textarea").val('').css("height", "15vh").focus();
        });

        $("button.resize").click(function(){
        });

        $("textarea").focus();
        autosize( document.querySelectorAll("textarea") );

        function format() {
            let sql = $("textarea");
            if (sql.val()) {
                /* replace double spaces with single space */
                sql.val( sqlFormatter.format(sql.val().replace(/\s\s+/g, ' '), {language: "sql", indent: "    "}) ).focus();
                autosize.update(sql);
            }
        }
    </script>

    <cfset request.focusHiLightOff = 1>

    <script>
        $("textarea").focus();
    </script>

</body>
</html>