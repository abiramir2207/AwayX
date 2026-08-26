<!---
  * ==================================================================================================== 
  *    @File: /components/log.cfc
  *  @Author: Chris Nguyen
  *    @Date: November 2020
  * 
  * @Remarks: Reusable user defined functions available on all pages
  *
  * ==================================================================================================== 
--->

<cfcomponent output="false" hint="I define user defined functions for logging.">

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="tempFileStructure" access="public" output="false" hint="Returns a structure with full path, relative path for a temporary file">
        <cfargument name="prefix" type="string" required="false" default="">
        <cfargument name="subFolder" type="string" required="false" default="any">
        <cfargument name="file_extension" type="string" required="false" default="html">
    
        <cfscript>
            local              = {};
            local.relativePath = '/common_documents/temp_files/' & arguments.subFolder & "/";
            local.tempFolder   = expandPath( local.relativePath );

            if ( not directoryExists( local.tempFolder ) ) {
                directoryCreate( local.tempFolder );
            }
    
            if ( len(arguments.prefix) ) {
                arguments.prefix = arguments.prefix & '_';
            }
    
            local.tempFileName = replace( lcase( arguments.prefix
                                                    & timeformat(now(),"hh-nntt")
                                                    & '_' & dateformat(now(),"mmm-d") 
                                                    & '_' & getTickCount()
                                                    & "." & arguments.file_extension ), '-', '_', "all" );
    
            return { 	  full_path: local.tempFolder & local.tempFileName
                        , relative_path: local.relativePath & local.tempFileName
                        , file_name: local.tempFileName 							};
        </cfscript>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="dumpObject" output="true" hint="Return cfdump information without duplicate cfdump styles and cfdump script code">
        <cfargument name="object" required="true">
    
        <cfset local.dump_max_rows = structkeyExists(request, "dump_max_rows")
                                        ? request.dump_max_rows
                                        : 50>
        <cfsavecontent variable="local.dump_content">
            <cfdump var="#arguments.object#" top=#local.dump_max_rows# showUDFs=false>
        </cfsavecontent>
        
        <cfscript>
            /* keep track of number of cfdump objects */
            param name="request.dumpObject" default="0";
            request.dumpObject++;
    
            /* find the starting position of cfdump table content */
            local.start = max(1, findNoCase('<table class="cfdump', local.dump_content));
            /* add bsa custom styles */
            local.ngt_style = udf.compress( 
                                "<style>
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
                                        border-radius: 7px;
                                        border:1px solid ##bdc3c7;
                                        background-color: white;
                                        font-size: 14px;
                                    }
    
                                    table.cfdump_struct th.struct {
                                        background-color: ##666666;
                                    }
    
                                    th, td {
                                        border-radius: 5px;
                                        padding-left: 9px !important;
                                        padding-right: 9px !important; 
                                        text-transform: capitalize;
                                    }
    
                                    td.sql {
                                        white-space: pre;
                                        user-select: all;
                                    }
                                 </style>      
                                ");
            /* only keep cfdump styles and cfdump script code for the 1st dump object */
            return ( request.dumpObject eq 1
                        ? replaceNocase( left(local.dump_content, local.start - 1), "font-family: verdana, arial, helvetica, sans-serif;", "font-size:0.8rem;", "all" ) & local.ngt_style
                        : '' )
    
                    /* minimize the cfdump string */
                    & udf.compress( mid(local.dump_content, local.start, len(local.dump_content) - local.start + 1) );
        </cfscript>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="dumpToPage" access="public" output="false" hint="Dumps objects to a .html page and return a link">
        <cfargument name="objects" required="true">
        <cfargument name="config"  required="true">

        <cfif !isArray(arguments.objects)
        or !isStruct(arguments.objects[1])>
        or !structKeyExists(arguments.objects[1], "content")>
        <cfreturn>
        </cfif>
        
        <cfoutput>
        <cfsavecontent variable="local.page_content">
            <!--- gather page section with all extra white spaces for compression later --->
            <cfsavecontent variable="local.page_section">
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <!--- parse CF template name, grap 1st letter of subfolder names (i.e. /common_files/contract/mytemplate.cfm becomes c/c/mytemplate_cfm --->
                <cfset script_name = listToArray(lcase(cgi.script_name), '/')>
                <cfloop index="counter" item="folder" array="#script_name#">
                    <cfset script_name[counter] = uCase(left(folder, 1))>
                </cfloop>
                <!--- place CF template name in page title --->
                <cfif arrayLen(script_name)>
                    <cfset script_name[counter] = uCase(left(folder, 1)) & right(folder, len(folder) - 1)>
                    <cfoutput><title>#arrayToList( script_name, '/' )#</title></cfoutput>
                <cfelse>
                    <title>Dev Tools</title>
                </cfif>
        
                <link rel="stylesheet" href="https://cdn.awayx.com/dev/styles/orbitcss/1.1/orbit.min.css">
                <style>
                    nav.top { 
                        position: sticky;
                        top: 0;
                    }
                    div.panel {
                        margin-top: 50px;
                        padding-bottom: 40px;
                    }
                    h6.poorsql {
                        cursor: pointer;
                    }
                </style>
            </head>
            <body>
                <nav class="top is-static has-bg-night">
                    <div class="top__links">
                      <ul>
                        <cfloop array="#arguments.objects#" item="local.object" index="local.counter">
                            <li><a class="has-text-white" href="##section_#local.counter#">#local.object.label#</a></li>
                        </cfloop>
                      </ul>
                    </div>
                    <div class="top__buttons is-end has-text-white">
                        <h6 class="poorsql">#timeFormat(now(), "short")# - #dateFormat(now(), "mmm d, yyyy")#</h6>
                    </div>
                </nav>                
            </cfsavecontent>#udf.compress(local.page_section)#

                <cfset structDelete(variables, "devtools")>

                <cfloop array="#arguments.objects#" item="local.object" index="local.counter">
                    <a id="section_#local.counter#"></a>
                    <div class="panel #lcase(local.object.label)#">
                        <h3>#local.object.label#</h3>
                        #dumpObject( local.object.content )#
                    </div>
                </cfloop>

            <!--- gather page section with all extra white spaces for compression later --->
            <cfsavecontent variable="local.page_section">
                <script src="https://cdn.awayx.com/dev/script/javascript/sql-formatter/2.3.3/sql-formatter.min.js"></script>
                <script src="https://cdn.awayx.com/dev/script/javascript/ajax_js/jquery-1.7.2-min.js?v=0153530" ></script>
        
                <script>
                    /* locate all SQL tds, format the next sibling td */
                    $("div.queries td").each(function(){
                        if ($(this).text() == "SQL") {
                            let sql = $(this).next();
                            if (sql) {
                                sql.text( sqlFormatter.format(sql.text().replace(/\s\s+/g, ' '), {language: "sql", indent: "    "}) ).addClass("sql");
                            }
                        }
                    });
                    $(".poorsql").click(function(){
                        window.open("http://poorsql.com/", "poor-sql-formatter");
                    });
                </script>
            </body>
            </html>
            </cfsavecontent>#udf.compress(local.page_section)#
        </cfsavecontent>
        </cfoutput>        
        
        <cfset local.out_file = tempFileStructure("dev_tools")>
        
        <cflog file="dev_tools" text="[ #cgi.script_name# ] - [  http://#cgi.http_host#/#local.out_file.relative_path#  ]" application=no>
        
        <cffile action="write" file="#local.out_file.full_path#" output="#local.page_content#">
        
        <!--- do not show dev tools button outside Blacksmith network (for debugging production issues) --->
        <cfreturn cgi.remote_addr contains "10.2.4." 
                ? '<a target="#arguments.config.button#" style="text-decoration:none;border:1px solid ##CCC;padding:5px 10px;font-weight:bold;border-radius:8px;background-color:##6e45e2;color:white" href="#local.out_file.relative_path#">#arguments.config.button#</a>'
                : ''>            
    </cffunction>
    

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="show_dev_tools" access="public" output="false" hint="Dumps objects to a .html page and return a link">
        <cfargument name="config" required="false">

        <cfparam name="config.button" default="DEV TOOLS">

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~ gather all query variables into an array ~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset devtools._keys = []>
        <!--- add local variables to our debugging information --->
        <cfif isDefined("local") and isStruct(local)>
            <cfset structAppend(variables, local)>
        </cfif>
        <cfloop collection="#variables#" item="devtools._key">
            <cfif isQuery(variables[devtools._key])>
                <cfset arrayAppend(devtools._keys, lcase(devtools._key))>
            </cfif>
        </cfloop>
        <!---  sort the queries array by names ~ --->
        <cfset arraySort(devtools._keys, "text")>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~ gather all queries meta data into an array ~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

        <!---  result is stored in this devtools._queries array  --->
        <cfset devtools._queries = []>
        <cfloop from="1" to="#arrayLen(devtools._keys)#" index="counter">
            <cfset devtools._key = devtools._keys[counter]>
            <cftry>
                <cfset devtools._qMeta = variables[devtools._key].getMetadata().getExtendedMetaData()>
                <!--- <cfparam name="devtools._qMeta.SQLParameters" default=""> --->
                <cfset arrayAppend(devtools._queries, {query_name: devtools._key, record_count: devtools._qMeta.recordCount, sql: devtools._qMeta.sql, content:#variables[devtools._key]#, execution_time: devtools._qMeta.executionTime })>
                <cfif isDefined("devtools._qMeta.SQLParameters")>
                    <cfset devtools._queries[arrayLen(devtools._queries)].parameters = devtools._qMeta.SQLParameters>
                </cfif>
                <!--- <cfset variables[devtools._key] = "see information in queries section"> --->
            <cfcatch type="any">
            </cfcatch>
            </cftry>
        </cfloop>

        <!--- render debug information only within Blacksmith internal network  --->
        <cfif cgi.remote_addr contains "10.2.4.">
            <cfset request.dumpObject = 0>
            <cfreturn dumpToPage(    [   { label:"Queries", content:devtools._queries } 
                                        ,{ label:"URL", content:URL }
                                        ,{ label:"Form", content:FORM }
                                        ,{ label:"Request", content:REQUEST }
                                        ,{ label:"Variables", content:VARIABLES }
                                    ]
                                    ,config )>
        </cfif>

        <cfreturn ''>
    </cffunction>

</cfcomponent>
