<cffunction name="tempFileStructure" access="public" output="false" hint="Returns a structure with full path, relative path for a temporary file">
    <cfargument name="prefix" type="string" required="false" default="">
    <cfargument name="subFolder" type="string" required="false" default="any">
    <cfargument name="file_extension" type="string" required="false" default="html">

    <cfscript>
        var local = {};

        param name="request.AccessStructure.User_ID" default="#CreateUUID()#";

        local.relativePath = '/common_documents/temp_files/' & arguments.subFolder & "/";
        local.tempFolder = expandPath( local.relativePath );
        if ( not directoryExists( local.tempFolder ) ) {
            directoryCreate( local.tempFolder );
        }

        if ( len(arguments.prefix) ) {
            arguments.prefix = arguments.prefix & '_';
        }

        local.tempFileName = arguments.prefix
                                & dateformat(now(),"mmddyy")
                                & '_' & getTickCount()
                                & '_' & request.AccessStructure.User_ID
                                & "." & arguments.file_extension;

        return { 	  full_path: local.tempFolder & local.tempFileName
                    , relative_path: local.relativePath & local.tempFileName
                    , file_name: local.tempFileName 							};
    </cfscript>
</cffunction>


<cffunction name="dumpToPage" access="public" output="false" hint="Dump objects to a .html page and return a link">
    <cfargument name="object_1" required="true">
    <cfargument name="object_2" required="false">
    <cfargument name="object_3" required="false">
    <cfargument name="object_4" required="false">
    <cfargument name="object_5" required="false">
    <cfargument name="top_rows" required="false" default="250">

    <cfsavecontent variable="local.dumpVar">
        <cfif structKeyExists(arguments, "object_1")>
            <cfdump top=#arguments.top_rows# showUDFs=false var="#arguments.object_1#">
        </cfif>
        <cfif structKeyExists(arguments, "object_2")>
            <br><cfdump top=#arguments.top_rows# showUDFs=false var="#arguments.object_2#">
        </cfif>
        <cfif structKeyExists(arguments, "object_3")>
            <br><cfdump top=#arguments.top_rows# showUDFs=false var="#arguments.object_3#">
        </cfif>
        <cfif structKeyExists(arguments, "object_4")>
            <br><cfdump top=#arguments.top_rows# showUDFs=false var="#arguments.object_4#">
        </cfif>
        <cfif structKeyExists(arguments, "object_5")>
            <br><cfdump top=#arguments.top_rows# showUDFs=false var="#arguments.object_5#">
        </cfif>
    </cfsavecontent>

    <cfset local.out_file = tempFileStructure("cfdump")>
    <cffile action="write" file="#local.out_file.full_path#" output="#local.dumpVar#">
    <cfreturn '<a target="dump_queries" style="position:fixed;bottom:10;left:10;z-index:9999;border:3px solid red;padding:5px 10px;font-weight:bold;border-radius:8px;box-shadow:6px 6px 3px grey;background-color:rgb(255,255,0)" href="#local.out_file.relative_path#">cfdump</a>'>
</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~ gather all query variables into an array ~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfset _keys = []>
<cfloop collection="#variables#" item="_key">
    <cfif isQuery(variables[_key])>
        <cfset arrayAppend(_keys, lcase(_key))>
    </cfif>
</cfloop>
<!---  sort the queries array by names ~ --->
<cfset arraySort(_keys, "text")>

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~ gather all queries meta data into an array ~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

<!---  result is stored in this _queries array  --->
<cfset _queries = []>
<cfloop from="1" to="#arrayLen(_keys)#" index="counter">
    <cfset _key = _keys[counter]>
    <cftry>
        <cfset _qMeta = variables[_key].getMetadata().getExtendedMetaData()>
        <!--- <cfparam name="_qMeta.SQLParameters" default=""> --->
        <cfset arrayAppend(_queries, {query_name: _key, record_count: _qMeta.recordCount, sql: _qMeta.sql, content:#variables[_key]# })>
        <cfif isDefined("_qMeta.SQLParameters")>
            <cfset _queries[arrayLen(_queries)].parameters = _qMeta.SQLParameters>
        </cfif>
    <cfcatch type="any">
    </cfcatch>
    </cftry>
</cfloop>

<cfoutput>
    #dumpToPage(_queries)#
</cfoutput>
