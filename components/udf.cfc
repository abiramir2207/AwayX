<!---
  * ====================================================================================================
  *    @File: /components/udf.cfc
  *  @Author: Chris Nguyen
  *    @Date: November 2020
  *
  * @Remarks: Reusable user defined functions available on all pages
  *
  * ====================================================================================================
--->

<cfcomponent output="false" hint="I define user defined functions.">

    <cffunction name="compress" output="false" hint="compress a string, replace multiple white spaces, carriage returns, line feeds, tabs with a single blank space">
        <cfargument name="str" required="true" type="string">

        <cfreturn reReplace(arguments.str, "\s{2,}|#chr(13)#|#chr(9)#|\n|\r", " ", "all")>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <!--- 2015 jan 23 - chrisn: introduced new _SETTINGS table with multiple rows feature --->
    <cffunction name="get_Setting" output="false" hint="Return interal setting value.">
		<cfargument name="setting_input_name" required="true" type="string" hint="this is the setting input name in the database and also in the form">
		<cfargument name="missing_not_allowed" required="false" default="true" hint="if true generate error when setting is missing">

        <cfreturn application.util.query.get_Setting( arguments.setting_input_name, arguments.missing_not_allowed )>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
    /*** Returns multiple setting values based on an optional list of setting names ****/
    public function get_Settings( setting_names, missing_not_allowed ) output="false" {
        arguments.setting_names       = arguments.setting_names ?: '';
        arguments.missing_not_allowed = arguments.missing_not_allowed ?: true;

        local.result = {};

        /* return settings based on a given list */
        if (arguments.setting_names gt '') {
            for (local.setting_name in arguments.setting_names) {
                local.result[ trim(lcase(local.setting_name)) ] = get_Setting( local.setting_name, arguments.missing_not_allowed );
            }
            return local.result;
        }

        /* return all settings */
        local.qSettings = queryExecute( "SELECT * FROM _Settings", [], { datasource = application.datasource } );

        for (local.setting in local.qSettings) {
            local.result[ local.setting.input_Name ] = local.setting.value;
        }

        local.qSettings = queryExecute( "SELECT * FROM _Application_Settings", [], { datasource = application.datasource } );
        for (local.column in local.qSettings.columnList) {
            local.result[ local.column ] = local.qSettings[local.column][1];
        }

        return local.result;
    }
    </cfscript>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="get_profile" output="false" hint="Get all profile Information For Supplied Profile ID">
		<cfargument name="profileId" type="numeric" required="yes">

		<cfquery name="local.qGetProfile" datasource="#application.datasource#">
            SELECT dbo.Profiles_Settings.*,
                Isnull(dbo.BB_Profiles_Settings.BB_Create, 0)                                  AS BB_Create,
                Isnull(dbo.BB_Profiles_Settings.BB_Delete, 0)                                  AS BB_Delete,
                Isnull(dbo.BB_Profiles_Settings.BB_View_Deviation, 0)                          AS BB_View_Deviation,
                Isnull(dbo.BB_Profiles_Settings.BB_Approve, 0)                                 AS BB_Approve,
                Isnull(dbo.BB_Profiles_Settings.BB_DevGrid_Expected, 0)                        AS BB_DevGrid_Expected,
                Isnull(dbo.BB_Profiles_Settings.BB_DevGrid_ELT, 0)                             AS BB_DevGrid_ELT,
                Isnull(dbo.BB_Profiles_Settings.BB_DevGrid_Claimed, 0)                         AS BB_DevGrid_Claimed,
                Isnull(dbo.BB_Profiles_Settings.BB_DevGrid_Selected, 0)                        AS BB_DevGrid_Selected,
                Isnull(dbo.BB_Profiles_Settings.BB_Approve_Amount, 0)                          AS BB_Approve_Amount,
                Isnull(dbo.BB_Profiles_Settings.BB_Approve_Critical, 0)                        AS BB_Approve_Critical,
                dbo.BB_Profiles_Settings.BB_User_ID,
                dbo.BB_Profiles_Settings.BB_Updated_Date,
                dbo.BB_Profiles_Settings.Created_Date,
                dbo.Profiles.Profiles_Desc,
                dbo.Profiles.Profiles_Short_Desc,
                Isnull(dbo.BB_Profiles_Settings.BB_RFA_Agreed, 0)                              AS BB_RFA_Agreed,
                Isnull(dbo.BB_Profiles_Settings.BB_Allow_Vendor_Master_Search, 0)              AS BB_Allow_Vendor_Master_Search,
                Isnull(dbo.BB_Profiles_Settings.BB_Add_Program, 0)                             AS BB_Add_Program,
                Isnull(BB_Profiles_Settings.BB_Add_Payee_Any_Position, 0)                      AS BB_Add_Payee_Any_Position,
                Isnull(BB_Profiles_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount, 0) AS Max_BB_Oper_Location_Level_Dup_Approval_Amount,
                Isnull(BB_Profiles_Settings.View_Deviated_Items_Only_OnLoad, 0)                AS View_Deviated_Items_Only_OnLoad,
                Isnull(BB_Profiles_Settings.View_Count_Column_In_Deviation_Grid, 0)            AS View_Count_Column_In_Deviation_Grid
            FROM   dbo.Profiles_Settings
                INNER JOIN dbo.Profiles
                        ON dbo.Profiles_Settings.Profiles_ID = dbo.Profiles.Profiles_ID
                LEFT OUTER JOIN dbo.BB_Profiles_Settings
                                ON dbo.Profiles_Settings.Profiles_ID = dbo.BB_Profiles_Settings.Profiles_ID
            WHERE  ( dbo.Profiles_Settings.Deleted = 0 )
                AND ( dbo.BB_Profiles_Settings.Deleted = 0 )
                AND Profiles_Settings.Profiles_ID = #arguments.profileId#
		</cfquery>

		<cfreturn local.qGetProfile>
	</cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="get_Settings2" output="false" hint="I return internal settings based on a filter (with % support)">
        <cfargument name="filters" type="string" required="yes">

        <cfset local.result = {}>

        <!--- look for settings in classic table with only one row --->
        <cfquery name="local.qSetting" datasource="#application.datasource#">
            SELECT *
              FROM
                    (
                        SELECT n.value('local-name(.)', 'SYSNAME') AS Input_Name,
                            n.value('.', 'nvarchar(4000)') AS Value
                        FROM _Application_Settings c
                            CROSS APPLY
                        (SELECT c.* FOR XML PATH('r'), TYPE) ca(x)
                            CROSS APPLY ca.x.nodes('/r/*') n(n)
                    ) q
                    WHERE 1 = 0
                            <cfloop list="#arguments.filters#" item="local.filter">
                                OR Input_Name LIKE '#local.filter#'
                            </cfloop>
        </cfquery>

        <cfscript>
            for (local.row in local.qSetting) {
                local.result[local.row.input_name] = local.row.value;
            }
        </cfscript>

        <!--- look for settings in current setting table with many rows --->
        <cfquery name="local.qSetting" datasource="#application.datasource#">
            SELECT *
              FROM _Settings
              WHERE 1 = 0
                    <cfloop list="#arguments.filters#" item="local.filter">
                        OR Input_Name LIKE '#local.filter#'
                    </cfloop>
        </cfquery>

        <cfscript>
            for (local.row in local.qSetting) {
                local.result[local.row.input_name] = local.row.value;
            }

            return local.result;
        </cfscript>

	</cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
    public function get_export_formats() output="false" {
        var format = {};

        format.center      = { alignment: "center" };
        format.currency    = { dataformat: "$##,####0.00;($##,####0.00)" };
        format.currencyFour    = { dataformat: "$##,####0.0000;($##,####0.0000)" };
        format.font_family = "Arial";
        format.font_size   = 9;
        format.percentage  = { dataformat: "0.00%;(0.00%)" };
        format.percentageFour  = { dataformat: "0.0000%;(0.0000%)" };
        format.right       = { alignment: "right" };

        format.title = { alignment:  "center"
                         , bold:     true
                         , font:     format.font_family
                         , fontsize: 16       };

        format.table_header = { alignment:          "center"
                                ,bold:              true
                                ,bottomborder:      "thin"
                                ,color:             "white"
                                ,fgcolor:           "grey_80_percent"
                                ,font:              format.font_family
                                ,fontsize:          format.font_size
                                ,leftborder:        "thin"
                                ,rightborder:       "thin"
                                ,textwrap:          true
                                ,topborder:         "thin"
                                ,verticalalignment: "vertical_center"   };

        // alternate row colors for odd rows and even rows
        format.table_body = [ {  bottomborder:      "thin"
                                ,fgcolor:           "grey_25_percent"
                                ,font:              format.font_family
                                ,fontsize:          format.font_size
                                ,leftborder:        "thin"
                                ,rightborder:       "thin"
                                ,topborder:         "thin"     },

                              { bottomborder:      "thin"
                                ,font:              format.font_family
                                ,fontsize:          format.font_size
                                ,leftborder:        "thin"
                                ,rightborder:       "thin"
                                ,topborder:         "thin"    }
                            ];
        return format;
    }
    </cfscript>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
        public function queryToArray( q ) output="false" {
            return q.reduce( function(result, row) { result.append(row); return result; }, [] );
        }

        boolean function isQueryEmpty( required query ) {
            return query.recordCount ? false : true;
        }
    </cfscript>


    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="get_UOM" output="false">
        <cfargument name="id" required="true">

        <!--- insert query into "request" scope to make it reusable --->
        <cfif !structKeyExists(request, "qUOM")>
            <cfquery name="request.qUOM" datasource="#application.datasource#">
                select *
                  from Units_Of_Measure
            </cfquery>
        </cfif>

        <cfquery name="local.qoq" dbtype="query">
            SELECT *
              FROM [request].qUOM
             WHERE Unit_of_measure_id = #id#
        </cfquery>

        <cfreturn local.qoq>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
        public function validate_CDN() output="false" hint="Validate CDN service, track its status & refresh retest minutes setting" {
            // skip validation when CDN does not exist
            if ( isDefined("application.Forge_CDN") eq false or trim(application.Forge_CDN) eq '' )
                return;

            cfhttp(method="GET", url="#application.forge_cdn#/script/javascript/numeral.min.js", result="local.result");

            param name="local.result.responseHeader.status_Code" default="";
            // is there a 200 good response status code?
            local.cdn_available = local.result.responseHeader.status_Code eq "200"
                                    or local.result.responseHeader.status_Code eq "304"
                                        ? true
                                        : false;

            // update application variables only when CDN status is different
            if ( (isDefined("application.cdn_available") eq false) or (application.cdn_available neq local.cdn_available) ) {
                //
                // try to lock for 21 seconds (single thread) application scope to assign cdn application variables
                //
                lock timeout="21" scope="application" type="exclusive" throwontimeout="false" {
                    //
                    // check one more time prior to updating application variables
                    // it is possible other user has already updated it while waiting for a lock
                    //
                    if ( (isDefined("application.cdn_available") eq false) or (application.cdn_available neq local.cdn_available) ) {
                        application.cdn_tested_date    = now();
                        application.cdn_available      = local.cdn_available;
                        //
                        // refresh number of minutes to retest CDN, enable us to control dynamically CDN
                        // validations (i.e. set it to zero or negative to stop the test in CF_INCLUDE)
                        //
                        application.cdn_retest_minutes = val(get_Setting("cdn_retest_minutes", 0));
                    }
                }
            }
        }
    </cfscript>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="ArrayOfStructSort" output="no">
        <cfargument name="base" type="array" required="yes" />
        <cfargument name="sortType" type="string" required="no" default="text" />
        <cfargument name="sortOrder" type="string" required="no" default="ASC" />
        <cfargument name="pathToSubElement" type="string" required="no" default="" />

        <cfscript>
            var tmpStruct = {};
            var returnVal = [];
            var i         = 0;
            var keys      = "";
        </cfscript>

        <cfloop from="1" to="#ArrayLen(base)#" index="i">
          <cfset tmpStruct[i] = base[i]>
        </cfloop>

        <cfset keys = StructSort(tmpStruct, sortType, sortOrder, pathToSubElement)>

        <cfloop from="1" to="#ArrayLen(keys)#" index="i">
          <cfset returnVal[i] = tmpStruct[keys[i]]>
        </cfloop>

        <cfreturn returnVal>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
        // Blacksmith Applications, Inc. styles and JS for "cfdump" tag
        function dump2022_head() {
            savecontent variable="local.css" {
                writeOutput( "<style>
                    table.cfdump_wddx,
                    table.cfdump_xml,
                    table.cfdump_struct,
                    table.cfdump_varundefined,
                    table.cfdump_array,
                    table.cfdump_query,
                    table.cfdump_cfc,
                    table.cfdump_object,
                    table.cfdump_binary,
                    table.cfdump_udf,
                    table.cfdump_udfbody,
                    table.cfdump_udfarguments {
                        font-family: verdana, arial, helvetica, sans-serif;
                        font-size: 12px;
                        border-radius: 7px;
                        border: 1px solid ##bdc3c7;
                    }

                    table.cfdump_wddx th,
                    table.cfdump_xml th,
                    table.cfdump_struct th,
                    table.cfdump_varundefined th,
                    table.cfdump_array th,
                    table.cfdump_query th,
                    table.cfdump_cfc th,
                    table.cfdump_object th,
                    table.cfdump_binary th,
                    table.cfdump_udf th,
                    table.cfdump_udfbody th,
                    table.cfdump_udfarguments th {
                        text-align: left;
                        color: white;
                        padding: 5px;
                    }

                    table.cfdump_wddx td,
                    table.cfdump_xml td,
                    table.cfdump_struct td,
                    table.cfdump_varundefined td,
                    table.cfdump_array td,
                    table.cfdump_query td,
                    table.cfdump_cfc td,
                    table.cfdump_object td,
                    table.cfdump_binary td,
                    table.cfdump_udf td,
                    table.cfdump_udfbody td,
                    table.cfdump_udfarguments td {
                        padding: 5px;
                        background-color: ##ffffff;
                        vertical-align: top;
                    }

                    table.cfdump_wddx {
                        background-color: ##000000;
                    }
                    table.cfdump_wddx th.wddx {
                        background-color: ##444444;
                    }

                    table.cfdump_xml {
                        background-color: ##888888;
                    }
                    table.cfdump_xml th.xml {
                        background-color: ##aaaaaa;
                    }
                    table.cfdump_xml td.xml {
                        background-color: ##dddddd;
                    }

                    table.cfdump_struct {
                        background-color: ##0000cc;
                        border-radius: 7px;
                    }
                    table.cfdump_struct th.struct {
                        background-color: ##4444cc;
                        background-color: ##666666;
                    }
                    table.cfdump_struct td.struct {
                        background-color: ##ccddff;
                    }

                    table.cfdump_varundefined {
                        background-color: ##cc3300;
                    }
                    table.cfdump_varundefined th.varundefined {
                        background-color: ##cc3300;
                    }
                    table.cfdump_varundefined td.varundefined {
                        background-color: ##ccddff;
                    }

                    table.cfdump_array {
                        background-color: ##006600;
                    }
                    table.cfdump_array th.array {
                        background-color: ##009900;
                    }
                    table.cfdump_array td.array {
                        background-color: ##ccffcc;
                    }

                    table.cfdump_query {
                        background-color: ##884488;
                    }
                    table.cfdump_query th.query {
                        background-color: ##aa66aa;
                    }
                    table.cfdump_query td.query {
                        background-color: ##ffddff;
                    }

                    table.cfdump_cfc {
                        background-color: ##ff0000;
                    }
                    table.cfdump_cfc th.cfc {
                        background-color: ##ff4444;
                    }
                    table.cfdump_cfc td.cfc {
                        background-color: ##ffcccc;
                    }

                    table.cfdump_object {
                        background-color: ##ff0000;
                    }
                    table.cfdump_object th.object {
                        background-color: ##ff4444;
                    }

                    table.cfdump_binary {
                        background-color: ##eebb00;
                    }
                    table.cfdump_binary th.binary {
                        background-color: ##ffcc44;
                    }
                    table.cfdump_binary td {
                        font-size: x-small;
                    }
                    table.cfdump_udf {
                        background-color: ##aa4400;
                    }
                    table.cfdump_udf th.udf {
                        background-color: ##cc6600;
                    }
                    table.cfdump_udfarguments {
                        background-color: ##dddddd;
                    }
                    table.cfdump_udfarguments th {
                        background-color: ##eeeeee;
                        color: ##000000;
                    }
                    pre {
                        padding: 2px 0 1px 0;
                        font-size: 13px;
                        font-family: Consolas,Menlo,Monaco,'Andale Mono','Ubuntu Mono',monospace;
                    }
    </style>" ); }

            // click handler for pre tag, does not work in email due to email protection which removes all JS
            savecontent variable="local.js" {
                writeOutput('<script language="javascript">
					function preSelect( el ) {
						var range = document.createRange();
						range.selectNodeContents( el );
						var sel = window.getSelection();
						sel.removeAllRanges();
						sel.addRange(range);
					}
                </script>');
            }

            return local.css & chr(10) & local.js & chr(10);
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        // format sql statements into an easy to read format
        function sql_format( required cf_dump ) {
            local.new_splits = [];
            // parse SQL entries to wrap SQL statements inside a pair of pre tags
            if ( arguments.cf_dump.find( "BODY</td>") ) {
                local.find_SQL = "BODY</td>";
            }
            else {
                local.find_SQL = "SQL</td>";
            }

            local.splits = arguments.cf_dump.split( local.find_SQL );

            for ( local.split in local.splits ) {
                // wrap SQL statements inside pre tag to preserve the easy to read format
                if ( left(trim( local.split ), 4) is "<td>") {
                    local.split = replaceNoCase( local.split, "</td>", "</pre></td>" );
                    local.split = replaceNoCase( local.split, "<td>", local.find_SQL & "<td><pre>" );
                    local.split = replaceNoCase( local.split, chr(9), "    ", "all" );

                    // attempt to remove the leading blank spaces in the pre content
                    local.pre = local.split.split( "<pre>" );
                    if ( arrayLen( local.pre ) gt 1 ) {
                        local.split = local.pre[ 1 ] & "<pre>" & trim( local.pre[ 2 ] );
                    }
                }

                local.split = replace( local.split, "<pre>", "<pre onClick='preSelect( this )'>", "all" );

                local.new_splits.append( local.split );
            }

            local.sql_result = arrayToList( new_splits, chr(10) );
            // replace multiple empty lines
            local.sql_result = reReplace( local.sql_result, "[\r\n]\s*([\r\n]|\Z)", chr(10), "ALL" );

            return local.sql_result;
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        // display debugging objects on the page
        function dump2022() {
            // get Blacksmith Applications, Inc. styles for cfdump
            local.dumps = [ dump2022_head() ];

            for ( var i = 1; i <= arrayLen( arguments ); i++ ) {
                savecontent variable="local.dump" {
                    local.label = structCount( arguments ) gt 1 ? "object ###i#" : '';
                    writeDump( var=arguments[ i ], top=100, showUDFs=false, label="#local.label#" );
                }
                // parse cfdump into two parts
                // 1st part has style
                local.split = local.dump.split( "</style>" );

                // save 2nd part with JS + dumped content
                local.dumps.append( sql_format( arrayLen( local.split ) gt 1
                                                    ? local.split[ 2 ]
                                                    : local.dump )
                                    );
            }

            return arrayToList( local.dumps, ' ');
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        // email debugging objects
        function dumpToEmail() {
            // get Blacksmith Applications, Inc. styles for cfdump
            local.dumps = [ dump2022_head() ];

            for ( var i = 1; i <= arrayLen( arguments ); i++ ) {
                savecontent variable="local.dump" {
                    local.label = structCount( arguments ) gt 1 ? "object ###i#" : '';
                    writeDump( var=arguments[ i ], top=100, showUDFs=false, label="#local.label#" );
                }
                // parse cfdump into two parts
                // 1st part has style
                local.split = local.dump.split( "</style>" );

                // save 2nd part with JS + dumped content
                local.dumps.append( sql_format( arrayLen( local.split ) gt 1
                                                    ? local.split[ 2 ]
                                                    : local.dump )
                                    );
            }

            param name="request.senderEmail_address" default="forge@blacksmithapplications.com";

            if ( structKeyExists(request, "dumpToEmail_address") and isDefined( "request.AccessStructure.User_Code" ) ) {
                cfmail( from = "#request.senderEmail_address#",
                        to = "#request.dumpToEmail_address#",
                        subject = "#request.AccessStructure.User_Code# - #replaceNoCase( cgi.http_host, '.awayx.com', '')# #cgi.script_name# - Debugging Log #now()#", type="text/html" ) {
                    writeOutput( arrayToList( local.dumps, ' ') );
                }
            }
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        // returns a "Dump To Page" button to display multiple debugging objects
        function dumpToPage() {
            // get Blacksmith Applications, Inc. styles for cfdump
            local.dumps = [ dump2022_head() ];

            for ( var i = 1; i <= arrayLen( arguments ); i++ ) {
                savecontent variable="local.dump" {
                    local.label = structCount( arguments ) gt 1 ? "object ###i#" : '';
                    writeDump( var=arguments[ i ], top=100, showUDFs=false, label="#local.label#" );
                }
                // parse cfdump into two parts
                // 1st part has style
                local.split = local.dump.split( "</style>" );

                // save 2nd part with JS + dumped content
                local.dumps.append( sql_format( arrayLen( local.split ) gt 1
                                                    ? local.split[ 2 ]
                                                    : local.dump )
                                    );
            }

            local.out_file = application.util.io.tempFileStructure( "cfdump" );
            fileWrite ( local.out_file.full_path, arrayToList( local.dumps, ' ') );
            return '<div style="position:fixed;bottom:0;right:0;z-index:9999;height:27px;margin:10px;"><a target="dump to page" style="text-decoration:none;border:1px solid ##CCC;padding:5px 10px;font-weight:bold;border-radius:8px;background-color:##6e45e2;color:white" href="#local.out_file.relative_path#">dump to page</a></div>';
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        // format a button with an icon, requires "/styles/font-awesome.min.css"
        function buttonFormat( required string buttonText ) {
            local.icon = '';
            if ( arguments.buttonText contains "add " )
                local.icon = "plus";
            else if ( arguments.buttonText contains "cancel" )
                local.icon = "ban";
            else if ( arguments.buttonText contains "close" )
                local.icon = "times";
            else if ( arguments.buttonText contains "delete" )
                local.icon = "trash";
            else if ( arguments.buttonText contains "edit" )
                local.icon = "pencil";
            else if ( arguments.buttonText contains "import" )
                local.icon = "download";
            else if ( arguments.buttonText contains "recalc" )
                local.icon = "refresh";
            else if ( arguments.buttonText contains "reset" )
                local.icon = "refresh";
            else if ( arguments.buttonText contains "save" )
                local.icon = "hdd-o";
            else if ( arguments.buttonText contains "search" )
                local.icon = "search";
            else if ( arguments.buttonText contains "spinner" )
                local.icon = "spinner";
            else if ( arguments.buttonText contains "update" )
                local.icon = "pencil";

            local.font_awesome.loaded = 0;
            local.font_awesome.file   = "/styles/font-awesome.min.css";

            // determine if font awesome css is loaded
            if ( structKeyExists( request, "included_files" ) ) {
                local.font_awesome.loaded = arrayFindNoCase( request.included_files, local.font_awesome.file );
            }

            // inject font awesome css onto the page if needed
            if ( local.font_awesome.loaded eq 0 ) {
                savecontent variable="local.font_awesome.html" {
                    cf_include( files=local.font_awesome.file );
                }
                cfhtmlhead( text=local.font_awesome.html );
            }

            return ( local.icon eq ''
                            ? ''
                            : '<i class="fa fa-' & local.icon & ' btn-icon"></i>&nbsp; ' )
                    & ( arguments.buttonText contains "spinner"
                            ? ''            // includes only spinning symbol & excludes the spinner button text
                            : arguments.buttonText );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function show_loader( string message ) output="false" {
            local.css.loaded = 0;
            local.css.file   = "/styles/css-loader.css";

            // determine if css-loader.css is loaded
            if ( structKeyExists( request, "included_files" ) ) {
                local.css.loaded = arrayFindNoCase( request.included_files, local.css.file );
            }

            // inject css-loader.css onto the page if needed
            if ( local.css.loaded eq 0 ) {
                savecontent variable="local.css.html" {
                    cf_include( files=local.css.file );
                }
                cfhtmlhead( text=local.css.html );
            }

            savecontent variable="local.div" {
                writeOutput( '<div class="loader loader-default is-active" half data-text="#arguments.message#"></div>' );
            }

            return local.div;
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function cf_loader( required string message ) output="false" {
            local.css.loaded = 0;
            local.css.file   = "/styles/css-loader.css";

            // determine if css-loader.css is loaded
            if ( structKeyExists( request, "included_files" ) ) {
                local.css.loaded = arrayFindNoCase( request.included_files, local.css.file );
            }

            // inject css-loader.css onto the page if needed
            if ( local.css.loaded eq 0 ) {
                savecontent variable="local.css.html" {
                    cf_include( files=local.css.file );
                }
                cfhtmlhead( text=local.css.html );
            }

            savecontent variable="local.content" {
                writeOutput( '<div class="loader loader-default is-active" half data-text="#arguments.message#"></div>' );
            }

            return local.content;
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function hide_cf_loader() output="false" {
            savecontent variable="local.content" {
                writeOutput( 'let div_loader = document.querySelectorAll( "div.loader" ); if ( div_loader ) { div_loader[0].remove(); }' );
            }
            return local.content;
        }


        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function is_developer() output="false" hint="Determine if user is a Blacksmith web developer" {
            return     cgi.remote_addr eq "127.0.0.1"              // developer local development
                    or ( structKeyExists( request, "is_developer" ) and request.is_developer eq dateFormat( now(), "dm" ) );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function getUserData( required search_column, required search_id, template_name, user_id ) output="false" {
            // optional template name parameter not provided - default to current CFM
            if ( not structKeyExists( arguments, "template_name" ) ) {
                arguments.template_name = listLast( cgi.script_name, "/" );
            }

            // optional user id parameter not provided - default to current logged in user
            if ( not structKeyExists( arguments, "user_id" ) ) {
                arguments.user_id = '';
                if ( isDefined( "request.accessStructure.user_id" ) ) {
                    arguments.user_id = request.accessStructure.user_id;
                }
            }

			local.query = queryExecute(     "SELECT Data
                                               FROM _User_Data TGT
                                              WHERE TGT.User_ID                  = '#arguments.user_id#'
                                                        AND   TGT.template_name  = '#arguments.template_name#'
                                                        AND   TGT.search_column1 = '#arguments.search_column#'
                                                        AND   TGT.search_id1     = '#arguments.search_id#'
                                            "
                                            , {}, { datasource=application.datasource, result="local.r" }
                                        );
            return local.query.data;
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function saveUserData( required search_column, required search_id, required json, template_name, user_id ) output="false" access="remote" {
            // optional template name parameter not provided - default to current frontend referred CFM
            if ( not structKeyExists( arguments, "template_name" ) ) {
                arguments.template_name = listLast( cgi.http_referer, "/" );
            }

            // optional user id parameter not provided - default to current logged in user
            if ( not structKeyExists( arguments, "user_id" ) ) {
                arguments.user_id = '';
                if ( isDefined( "request.accessStructure.user_id" ) ) {
                    arguments.user_id = request.accessStructure.user_id;
                }
                // bail out when user ID is unknown
                if ( arguments.user_id is '' ) {
                    return;
                }
            }

			local.query = queryExecute(     "MERGE INTO _User_Data AS TGT
                                                USING ( VALUES(       '#arguments.user_id#'
                                                                    , '#arguments.template_name#'
                                                                    , '#arguments.search_column#'
                                                                    , '#arguments.search_id#'
                                                                )
                                                        ) AS SRC (    User_ID
                                                                    , Template_Name
                                                                    , Search_Column1
                                                                    , Search_ID1
                                                                )
                                                        ON    TGT.User_ID        = SRC.User_ID
                                                        AND   TGT.template_name  = SRC.Template_Name
                                                        AND   TGT.search_column1 = SRC.Search_Column1
                                                        AND   TGT.search_id1     = SRC.Search_ID1

                                                WHEN MATCHED THEN
                                                        UPDATE SET TGT.Data = '#arguments.json#'

                                                WHEN NOT MATCHED THEN
                                                        INSERT ( User_ID
                                                                , Template_Name
                                                                , Search_Column1
                                                                , Search_ID1
                                                                , Data
                                                                )
                                                        VALUES (  '#arguments.user_id#'
                                                                , '#arguments.template_name#'
                                                                , '#arguments.search_column#'
                                                                , '#arguments.search_id#'
                                                                , '#arguments.json#'
                                                                );
                                            "
                                            , {}, { datasource=application.datasource, result="local.r" }
                                        );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        // return true when planner is caterogized as either MSA or Indirect
        // populate 1. request.is_planner_indirect_category boolean variable
        //          2. request.planner_indirect_categories based on setting
		function is_planner_indirect_category( planner_ID, planner_category ) output="false" {
			if ( structKeyExists( request, "is_planner_indirect_category" ) eq false ) {
                // gather indirect categories setting
                if ( structKeyExists( request, "planner_indirect_categories" ) eq false ) {
                    request.planner_indirect_categories = application.util.query.get_Setting( "Planner_Indirect_Categories", 0 );
                }

                local.planner_category = "unknown";

                // determine planner category
                if ( structKeyExists( arguments, "planner_category") ) {
                    local.planner_category = arguments.planner_category;
                }
                else if ( structKeyExists( request, "planner_category" ) ) {
                    local.planner_category = request.planner_category;
                }
                else if ( structKeyExists( arguments, "planner_id") ) {
                    local.query = queryExecute( "SELECT P.Planner_ID,
                                                        P.Planner_Number,
                                                        P.Planner_Title,
                                                        P.Parent_Planner_ID,
                                                        PT.Category
                                                    FROM Planners P
                                                    INNER JOIN Planner_Template PT
                                                        ON PT.Planner_Template_ID = P.Planner_Template_ID
                                                    WHERE Planner_ID = #arguments.planner_Id#
                                                    AND P.Deleted  = 0
                                                ", {}, { datasource: application.datasource } );
                    request.planner_category = local.query.Category;
                    local.planner_category   = local.query.Category;
                }

                request.is_planner_indirect_category = request.planner_indirect_categories.listFindNocase( local.planner_category )
                                                            ? true
                                                            : false;
            }

            return request.is_planner_indirect_category;
		}

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function stringToBinary( String stringValue ) {
            var binaryValue = charsetDecode( stringValue, "utf-8" );
            return( binaryValue );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function binaryToString( Any binaryValue ) {
            var stringValue = charsetEncode( binaryValue, "utf-8" );
            return( stringValue );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function getAccessCodes() output="false" hint="Returns 52 security access codes based on 52 playing cards and today's date" {
            local.suits = [ "Hearts", "Clubs", "Spades", "Diamonds" ];
            local.faces = [ 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", "J", "Q", "K" ];

            local.cards = [];
            // build a deck of all playing cards ( 52 cards )
            for ( local.suit in local.suits ) {
                for ( local.face in local.faces ) {
                    // prefix a code with today's date and append the playing card to it. Sample:
                    //      20222306_2_of_Hearts
                    //      20222306_3_of_Hearts
                    //      20222306_4_of_Hearts
                    //      20222306_5_of_Hearts
                    local.cards.append( dateformat( now(), 'yyyyddmm' ) & "_" & local.face & "_of_" & local.suit );
                }
            }

            return local.cards;
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function accessCode() output="false" hint="Returns a dynamic unique access code based on today's date" {
            local.codes = getAccessCodes();

            // code is based on today's date, expire at the end of the day
            return local.codes[ day( now() ) + 1 ];
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function IsAccessValid( required string code ) output="false" {
            local.access_codes = getAccessCodes();
            local.today_code = local.access_codes[ day( now() ) + 1 ];

            // case sensitive comparison for non-hashed code
            if ( compare( local.today_code, arguments.code ) eq 0 ) {
                return true;
            }
            // comparison for hashed code
            else if ( compare( right( hash( local.today_code, "SHA-512" ), 32 ), arguments.code ) eq 0 ) {
                return true;
            }
            else {
                return false;
            }
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function protectURL( required string target_url ) hint="Protect URL by appending a unique access code (scheduled to expire at EOD)" {
            return trim( target_url ) eq ''
                      ? ''
                      // append access code to the URL
                      : trim( target_url )
                            & ( target_url contains '?' ? '&' : '?' )
                            & "ac="
                            & right( hash( accessCode(), "SHA-512" ), 32 );
        }

        function RoundToDecimalPlaces(required string val, required integer decLen)
            {
            local.mult_div_value = 1;
            for(local.i = 1;i LTE arguments.decLen;local.i=local.i+1)
            {
                /* If decLen = 3, mult_div_value=10*10*10 */
                local.mult_div_value = local.mult_div_value * 10;
            }
            local.val1 = arguments.val * local.mult_div_value;
            local.val1 = Round(local.val1);
            local.val1 = local.val1/local.mult_div_value;
            return local.val1;
        }


        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function TitleCase( required string str, string delimeter = '_' ) hint="Return title case for a given string" {
            local.results = [];
            // parse the string into multiple elements in lowered case
            local.elements = arguments.str.lcase().listToArray( '_-, ' & arguments.delimeter );
            local.all_caps = [
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
                            ];

            for ( local.element in local.elements ) {
                if ( local.all_caps.findNoCase( local.element ) ) {
                    local.results.append( ucase( local.element ) );
                }
                else {
                    // upper case the first letter => column "A_R" in templates threw an error
                    if( len( local.element ) > 1 ){
                        local.results.append( left( local.element, 1 ).ucase() & right( local.element, len( local.element ) - 1 ) );
                    }
                    else{
                        local.results.append( local.element.ucase() );
                    }
                }
            }

            // convert the result back into a string
            return local.results.toList( arguments.delimeter );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function compareTopRows( required query q1, required query q2, string ignored_columns = '' ) hint="Compare the top row in two queries and return a list of column names with different values" {
            // validate queries parameters
            if ( arguments.q1.recordCount eq 0 ) {
                throw( message="First query is empty." );
            }
            if ( arguments.q2.recordCount eq 0 ) {
                throw( message="Second query is empty." );
            }
            if ( arguments.q1.columnList neq arguments.q2.columnList ) {
                throw( message="Queries have mismatched columns." );
            }

            // convert rows into structures
            local.row1 = queryGetRow( arguments.q1, 1 );
            local.row2 = queryGetRow( arguments.q2, 1 );
            // store columns with different values in this array
            local.diff = [];

            // compare all columns in 2 rows
            for ( local.key in local.row1 ) {
                if ( arguments.ignored_columns.listFindNoCase( local.key ) ) {
                    continue;
                }
                // keep track of columns with different values
                if ( local.row2[ local.key ] neq local.row1[ local.key ] ) {
                    local.diff.append( TitleCase( local.key ) );
                }
            }

            // convert array result into a list and return
            return local.diff.toList();
        }
        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //
        function writeSettingsAudit(required query qOrig, required query qUpdated, required string tableName, integer recordId = 0 ,string recordDescription = '', string ignored_columns = '') {
            // compare with original settings and get back the list of columns with different values
            local.different_columns = this.compareTopRows( arguments.qOrig, arguments.qUpdated, arguments.ignored_columns );

            local.sql = [];
            if ( isDefined( "request.accessStructure.name_first" ) and isDefined( "request.accessStructure.name_last" ) ) {
                // set up SQL session context for updated_by column
                local.sql.append( "EXEC sp_set_session_context 'Updated_By', '#request.accessStructure.name_first# #request.accessStructure.name_last#'" );     
            }
            local.user_id = "";
            if ( isDefined( "request.AccessStructure.User_Id" ) ) {
                local.user_id = request.AccessStructure.User_Id;
            }

            // gather insert statements to _Auditing tracking table for changed settings
            for ( local.column in local.different_columns ) {
                    local.sql.append( "INSERT INTO _Auditing (
                                            Table_Name
                                            ,Column_Name
                                            ,New_Value
                                            ,Old_Value
                                            ,Updated_Type
                                            ,Record_Id
                                            ,Record_Description
                                            ,Updated_User_Id
                                        )
                                        SELECT    '#arguments.tableName#'
                                                , '#local.column#'
                                                , '#arguments.qUpdated[ local.column ][ 1 ]#'
                                                , '#arguments.qOrig[ local.column ][ 1 ]#'
                                                , 'Update'
                                                , #arguments.recordId#
                                                , '#arguments.recordDescription#'
                                                , '#local.user_id#'
                                        " );
            }
            local.sql.append( "EXEC sp_set_session_context 'Updated_By', NULL" );

            // commit the tracking changes
            queryExecute( local.sql.toList( ' ' ), { }, { datasource: application.datasource } );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function cf_memory() output="false" hint="Returns various CF memory information in MBs" {
            local.runtime = createObject( "java", "java.lang.Runtime").getRuntime();

            local.max     = local.runtime.maxMemory();
            local.total   = local.runtime.totalMemory();
            local.free    = local.runtime.freeMemory();
            local.used    = local.total - local.free;

            local.mb      = 1024 * 1024;

            return {     Max_Memory:   round( local.max / local.mb )            // Maximum memory defined in CF Admin
                        ,Total_Memory: local.total / local.mb
                        ,Total_Free_Memory: ( local.max - ( local.total - local.free ) ) / local.mb
                        ,Free_Memory:  local.free / local.mb
                        ,Used_Memory:  ( local.total - local.free ) / local.mb
                        ,Used_Percentage: round( ( local.used / local.max ) * 100 )
                    };
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function arrayToQuery( required data ) output="false" hint="Convert an array of structures into a query" {
            return data.reduce( function( accumulator, element ) {
                                                                    element.each( function( key ) {
                                                                        if ( !accumulator.keyExists( key ) ) {
                                                                            accumulator.addColumn( key, [] );
                                                                        }
                                                                    } );
                                                                    accumulator.addRow( element );
                                                                    return accumulator;
                                                                }, queryNew( "" ) );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function columnList( required query q ) output="false" hint="Returns a column list in the order defined by the given query" {
            var result = [];
            var metaData = q.getMetaData();

        	for ( var i = 1; i <= metadata.getColumnCount(); i++ ) {
		        result.append( metadata.getColumnName( i ) );
            }

            return result.toList();
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function uomToInt( required string uom ) output="false" hint="Returns an integer UOM based on the given UOM string" {
            // place query in memory for faster processing
            if ( !structKeyExists( request, "qUOM" ) ) {
                // remove white spaces in UOM columns
                request.qUOM = queryExecute( " SELECT Unit_Of_Measure_ID,
                                                      TRIM( Abbreviation ) AS Abbreviation,
                                                      TRIM( Abbreviation_Singular ) AS Abbreviation_Singular
                                                 FROM Units_Of_Measure", {}, { datasource: application.datasource } );
            }

            // sanitize the given UOM string, and convert it to uppercase due to query of query search is case-sensitive
            arguments.uom = arguments.uom.trim().uCase();

            var query = queryExecute( " SELECT Unit_Of_Measure_ID
                                          FROM request.qUOM
                                         WHERE UPPER( Abbreviation ) = '#arguments.uom#' OR UPPER( Abbreviation_Singular ) = '#arguments.uom#' "
                                        , {}, { dbtype: "query" } );

            return ( query.recordCount ? query.Unit_Of_Measure_ID : 0 );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function queriesToExcel( required scope, string filter = '' ) output="false" hint="Export queries to an Excel file" {
            var udf = var _given = var _meta = var _excel = var _temp = {};
            var _hdr_format = { 	bold="true",
                                    fgcolor="black",
                                    color="white",
                                    textwrap="true",
                                    verticalalignment="vertical_center",
                                    alignment="center" };
            udf = new components.udf();

            _given.queries = [];
            _given.filters = arguments.filter.trim().listToArray();

            // collecting queries in the given scope (e.g. variables, local, form, url, request, application, etc..)
            scope.each( function ( key, value ) {
                if ( _given.filters.len() ) {
                    _temp.found = false;

                    // filter queries based on the given query names list
                    _given.filters.each( function( element, index ) {
                        if ( key contains element ) {
                            _temp.found = true;
                            break;
                        }
                    } )

                    if ( not _temp.found ) {
                        continue;
                    }
                }

                // gather meta data for the given query
                if ( isQuery( scope[ key ] ) ) {
                    try {
                        _meta = scope[ key ].getMetadata().getExtendedMetaData();
                        _temp.parameters = structKeyExists( _meta, "SQLParameters" )
                                                ? _meta.SQLParameters.toList()
                                                : '';
                        _given.queries.append( { 	query_name: key,
                                                    record_count: _meta.recordCount,
                                                    sql: _meta.sql,
                                                    content:scope[key],
                                                    parameters:_temp.parameters  } );
                    }
                    catch ( any e ) {
                    }
                }
            } )

            if ( _given.queries.len() == 0) {
                _excel = spreadSheetNew( "No Data", "yes" );
                spreadSheetAddRow( _excel, "" );
            }
            else {
                _given.queries.each( function ( element, index ) {
                    if ( index == 1 ) {
                        _temp.first_sheet = element.query_name.lCase();
                        _excel = spreadSheetNew( _temp.first_sheet, "yes" );
                    }
                    else {
                        spreadSheetCreateSheet( _excel, element.query_name.lCase() );
                    }

                    spreadSheetSetActiveSheet( _excel, element.query_name );
                    spreadSheetAddRow( _excel, udf.columnList( element.content ) );
                    spreadSheetFormatRow( _excel, _hdr_format, 1 );
                    spreadSheetAddRows( _excel, element.content );

                    _temp.sql_sheet = "sql-" & element.query_name.lCase();

                    spreadSheetCreateSheet( _excel, _temp.sql_sheet );
                    spreadSheetSetActiveSheet( _excel, _temp.sql_sheet );
                    _meta = queryNew( "SQL,Parameters", "VarChar,VarChar", [ element.sql, element.parameters ] );

                    // spreadSheetAddRows( _excel, [ element.sql, "[ parameters ]", element.parameters ] );
                    spreadSheetAddRow( _excel, udf.columnList( _meta ) );
                    spreadSheetFormatRow( _excel, _hdr_format, 1 );
                    spreadSheetAddRows( _excel, _meta );
                    SpreadsheetFormatCell( _excel, { textwrap="true" }, 2, 1 );
                } );

                spreadSheetSetActiveSheet( _excel, _temp.first_sheet );
            }

            // generate a debugging Excel file under common_documents/temp_files/debug/ folder
            spreadSheetWrite( _excel, application.util.io.TempFileName( "Queries To Excel ", "debug" ) & ".xlsx", true );
        }

        // --------------------------------------------------------------------------------------------------------------------------------------------------------- //

        function queryToExcel( required query qGiven, string label ) output="false" hint="Export a query to an Excel file" {
            var _temp = var _excel = var _meta = var udf = {};
            var _hdr_format = { 	bold="true",
                                    fgcolor="black",
                                    color="white",
                                    textwrap="true",
                                    verticalalignment="vertical_center",
                                    alignment="center" };

            if ( structKeyExists( arguments, "label") ) {
                _temp.excel_file = arguments.label.trim();
            }
            else {
                arguments.label = "Query Data";
            }

            udf = new components.udf();
            _excel = spreadSheetNew( arguments.label, "yes" );
            // ----------------------------------------------------
            // place SQL data content on the 1st sheet
            // ----------------------------------------------------
            spreadSheetAddRow( _excel, udf.columnList( arguments.qGiven ) );
            spreadSheetFormatRow( _excel, _hdr_format, 1 );
            spreadSheetAddRows( _excel, arguments.qGiven );

            // ----------------------------------------------------
            // place SQL statements and parameters on the 2nd sheet
            // ----------------------------------------------------
            try {
                _meta = arguments.qGiven.getMetadata().getExtendedMetaData();
                param name="_meta.SQLParameters" default=[];
                _meta = queryNew( "SQL,Parameters", "VarChar,VarChar", [ _meta.sql, _meta.SQLParameters.toList() ] );

                spreadSheetCreateSheet( _excel, "sql" );
                spreadSheetSetActiveSheet( _excel, "sql" );

                spreadSheetAddRow( _excel, udf.columnList( _meta ) );
                spreadSheetFormatRow( _excel, _hdr_format, 1 );
                spreadSheetAddRows( _excel, _meta );
                spreadsheetFormatCell( _excel, { textwrap="true" }, 2, 1 );
            }
            catch ( any e ) {
            }

            spreadSheetSetActiveSheet( _excel, arguments.label );

            // generate a debugging Excel file under common_documents/temp_files/debug/ folder
            spreadSheetWrite( _excel, application.util.io.TempFileName( _temp.excel_file, "debug" ) & ".xlsx", true );
        }
    </cfscript>

</cfcomponent>
