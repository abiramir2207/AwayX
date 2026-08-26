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
            overflow-y: scroll;
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

    <cfset query_blacksmith_users = false>
    <cfif form.query contains "_Blacksmith_Users">
        <cfset query_blacksmith_users = true>
        <cfsavecontent variable="form.query">
            SELECT  User_Code
                ,Name_First + ' ' + Name_Last                     AS Full_Name
                ,CASE WHEN Deleted = 1 THEN 'Deleted' ELSE '' END AS Is_Deleted
                ,CASE
                    WHEN User_Password = '5F4DCC3B5AA765D61D8327DEB882CF99' THEN
                        '!!!!!!!!'
                    WHEN User_Password = 'B5712B7C6FFA239F15AC870FB33E9EBA' THEN
                        'nada'
                    ELSE
                        User_Password
                    END                                              AS _Password
                ,User_Email
                ,Profiles_ID
                ,User_Rights_ID
                ,Authority_Sequence_ID
                ,User_Number
                ,Is_Eligible_RSP
                ,Sales_Person_ID
                ,Blacksmith_User
                ,Is_On_Behalf_Of
                ,RFA_Notification_Email
                ,Remote_Approval_Option
                ,Analytics_SSO_User_Name
            FROM  _Users
            WHERE  1 = 1
                    AND (   0 = 1
                            OR  User_Code LIKE '%support%'
                            OR  User_Code LIKE 'asrinivasarao%'
                            OR  User_Code LIKE 'bflame%'
                            OR  User_Code LIKE 'bgillis%'
                            OR  User_Code LIKE 'cnguyen%'
                            OR  User_Code LIKE 'dkunnath%'
                            OR  User_Code LIKE 'drachala%'
                            OR  User_Code LIKE 'dwachowski%'
                            OR  User_Code LIKE 'jwagner%'
                            OR  User_Code LIKE 'jwei%'
                            OR  User_Code LIKE 'kal%'
                            OR  User_Code LIKE 'kcole%'
                            OR  User_Code LIKE 'kcullom%'
                            OR  User_Code LIKE 'kmoore%'
                            OR  User_Code LIKE 'mhoover%'
                            OR  User_Code LIKE 'msaunders%'
                            OR  User_Code LIKE 'rgrimsley%'
                            OR  User_Code LIKE 'sharris%'
                            OR  User_Code LIKE 'splomin%'
                            OR  User_Code LIKE 'tford%'
                            OR  User_Code LIKE 'tpavlatos%'
                            OR  User_Code LIKE 'vcooper%'
                            )
            ORDER BY User_Code
        </cfsavecontent>
    </cfif>

    <cfparam name="form.query" default="">

    <cfif query_blacksmith_users>
        <textarea name="query" id="query"></textarea>
    <cfelse>
    <div style="height:21vh;">
        <form method="post" id="querydatabase">
                <cfoutput><textarea name="query" id="query">#form.query#</textarea></cfoutput>
        </form>
        <div style="margin:5px">
            <button class="button recommended f5">F5 execute</button>
            <button class="button f7">F7 switch view</button>
            <button class="button f9">F9 format</button>
            <button class="button reset danger">reset</button>
        </div>
    </div>
    </cfif>

    <cfscript>
        db_host = "unknown";
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
            <cfset max_rows = val(application.util.query.get_setting("queryDatabase_maxrows", 0))>
            <cfset max_rows = max_rows eq 0 ? 5000 : max_rows>
            <cfset max_rows = 100>

            <cfquery name="qData" datasource="#application.datasource#">
                <cfif query_blacksmith_users>
                    #PreserveSingleQuotes(FORM.query)#
                <cfelse>
                    SELECT TOP #max_rows# *
                      FROM (#PreserveSingleQuotes(FORM.query)#) Loremipsumdolor
                </cfif>
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
            <cfset aMetaData = getMetaData( qData )>

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

                    // add data types
                    for (i=1; i lte aMetaData.len(); i++) {
                        if ( trim( aMetaData[ i ].Name ) == trim( headerName ) ) {
                            headerName = headerName & " = " & aMetaData[ i ].TypeName;
                            break;
                        }
                    }
                    arrayAppend(columns, '{headerName:"#headerName#"'
                                            & (counter eq 1 ? ',pinned:"left"' : '')
                                            & ',floatingFilter:true'
                                            & ',filter: "agTextColumnFilter", filterParams: { buttons: false }, floatingFilterComponentParams: { suppressFilterButton: true }'
                                            & ',valueGetter:function(p){return p.data[' & (counter - 1) & ']}}') ;
                </cfscript>
            </cfloop>

            <cfset request.ag_grid_version = "24">
            <cfset request.ag_grid_theme   = "ag-theme-balham">

            <cfoutput>
                <div id="aggrid" style="height:78vh;width:99%;margin:0 auto;padding:0;" class="#request.ag_grid_theme#"></div>

                <cfinclude template="/common_files/ag-grid.cfm">

                <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/24/styles/ag-grid.css?v=1144410">
                <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/24/styles/#request.ag_grid_theme#.css">
            </cfoutput>

            <style>
                .ag-side-button-label {
                    transform: rotate(180deg);
                }
                /* restore sidebar buttons panel */
                div.ag-side-buttons {
                    display: block;
                }
            </style>

            <script>
                function onFilterTextBoxChanged() {
                    gridoptions.api.setQuickFilter(document.getElementById('filter-text-box').value);
                }

                let rows = <cfoutput>#serializeJSON(qData, "row")#</cfoutput>;
                // console.table(rows);
                let gridoptions = {
                                    columnDefs:         [<cfoutput>#arrayToList(columns)#</cfoutput>]
                                                    , enableRangeSelection: true
                                                    // , floatingFilter: true
                                                    , pagination:         false
                                                    , paginationPageSize: 10000
                                                    , onFirstDataRendered: resize_all_columns
                                                    , rowModelType:       "clientSide"
                                                    , rowSelection:         "multiple"
                                                    , sideBar: sidebar()
                                                    , suppressRowClickSelection: false
                                                    , suppressContextMenu: false
                                                    // , rowData:            <cfoutput>#application.util.query.toDtJSON(qData, arrayToList(aColumns))#</cfoutput>
                                                    ,rowData: rows.DATA
                                                };

                gridoptions.sideBar.position = 'left';

                ag_grid_default(gridoptions);     // set up default features

                gridoptions.defaultColDef.suppressMenu = true;

                init_ag_grid( gridoptions, "#aggrid", false );


                // auto size all columns
                function resize_all_columns() {
                    let allColumnIds = [];
                    gridoptions.columnApi.getAllColumns().forEach(function(column) {
                        allColumnIds.push(column.colId);
                    });
                    gridoptions.columnApi.autoSizeColumns(allColumnIds);
                }

                // adjust columns to fit when window is resized
                $(window).resize(function(){
                    resize_all_columns();
                });

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

        function switch_view() {
            show_loader();
            const q = $("textarea").val().replace(/\n/g, " ");
            window.location = "queryDatabase2.cfm?query=" + q;
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
</body>
</html>