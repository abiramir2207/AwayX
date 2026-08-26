<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\io.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all input output operation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="io" output="false" hint="This has user defined functions for input output operations.">

	<cffunction name="Init" access="public" returntype="any" output="false">
		<cfargument name="Library" type="any" required="true" />

		<cfscript>
			// The library variable is a reference to the main UDF library. This is
			// going to be used to reference other parts of the library that are not
			// in this specific component.
			variables.Library = arguments.Library;

			return( this );
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="TempFileName" access="public" returntype="string" output="false" hint="Returns full path of temporary file name (without the extension)">
		<cfargument name="prefix" type="string" required="false" default="" />
		<cfargument name="subFolder" type="string" required="false" default="any" />

		<cfscript>
			var local = {};
			local.tempFolder = expandPath( '/common_documents/temp_files/' ) & arguments.subFolder;
			if ( not directoryExists( local.tempFolder ) ) {
				directoryCreate( local.tempFolder );
			}

			if ( len(arguments.prefix) ) {
				arguments.prefix = arguments.prefix & '_';
			}

			local.tempFileName = arguments.prefix & dateformat(now(),"mmddyy") & '_' & getTickCount() & '_' & request.AccessStructure.User_ID;
			return( local.tempFolder & '/' & local.tempFileName );
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="dumpToEmail" access="public" output="false" hint="Dump objects to email">
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

		<!--- grap email address from caller  --->
		<cfif isDefined("request.dumpToEmail_address")>
			<cfset local.user_email = trim(request.dumpToEmail_address)>

		<!--- grap email address from current logged in user  --->
		<cfelseif isDefined("request.AccessStructure.User_ID")>
			<cfset useLakebaseForlocal_user = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForlocal_user>
	<cftry>
		<cfset local.user = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_user = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_user>
<cfquery name="local.user" datasource="#application.datasource#">
				select user_email from _users where user_id = '#request.AccessStructure.User_ID#'
			</cfquery>
</cfif>

			<cfset local.user_email = trim(local.user.user_email)>

		<!--- no email address available --->
		<cfelse>
			<cfset local.user_email = "">
		</cfif>

		<!--- generate email when email address is available --->
		<cfif local.user_email neq "">
			<cfset local.user_email = replaceNoCase(local.user_email, "blacksmithapplication.com", "blacksmithapplications.com")>
			<cfmail from="#local.user_email#" to="#local.user_email#" subject="#cgi.http_host# - Debugging information #now()#" type="text/html">
				#local.dumpVar#
			</cfmail>
		</cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

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
		<cfreturn '<a target="_blank" style="border:3px solid red;padding:5px 10px;font-weight:bold;border-radius:8px;box-shadow:6px 6px 3px grey;background-color:rgb(255,255,0)" href="#local.out_file.relative_path#">cfdump</a>'>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

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

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="filterFilename" access="public" returntype="string" output="false" hint="I remove any special characters from a filename and replace any spaces with underscores.">
	    <cfargument name="filename" type="string" required="true" />
	    <cfargument name="replacement" type="string" required="false" default="_" />

	    <cfset var filenameRE = "[" & "'" & '"' & "##" & "/\\%&`@~!,:;=<>\+\*\?\[\]\^\$\(\)\{\}\|]" />
	    <cfset var newfilename = reReplace(arguments.filename,filenameRE,"","all") />
	    <cfset newfilename = replace(newfilename, " ", arguments.replacement, "all") />

	    <cfreturn newfilename />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="fileSource" access="public" returntype="string" output="false" hint="Append a URL file version number to a given file source">
		<cfargument name="file_name" type="string" required="true" hint="file name and file extension (with relative path)"/>

		<!--- e.g. input  = "/script/javascript/dhtml.js"
		           output = "/script/javascript/dhtml.js?v=115741484" --->
		<cfreturn '"' & arguments.file_name & '?v=' & application.util.dateTime.fileVersion(arguments.file_name) & '"'>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="isProduction" output="false" hint="Return true for production environment">
		<cfscript>
			if (cgi.http_host contains ".awayx.com")
				return ( cgi.http_host contains ".stage." ? false : true );
			else
				// domains not include "awayx.com" (e.g. developer's custom domains)
				return false;
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="debugLog" output="false" hint="Write debugging information to a log file.">
        <cfparam name="request.debugLog" default="debug">
        <cfset local.text = []>
    
        <cfloop collection="#arguments#" item="local.item">
            <cfset arrayAppend(local.text, replace(serializeJSON(arguments[ local.item ]), '"', '', 'all'))>
        </cfloop>
    
        <cfif arrayLen(local.text)>
            <cflog file="#request.debugLog#" application=no text="#arrayToList(local.text, ' ')#">
        </cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="isSingleSheetExcel" output="false" hint="Inspect an Excel file for unexpected content (e.g. multiple sheets).">
        <cfargument name="excel_expand_path" required="true">

        <cfset local.result = structNew()>
        <cfset local.result.isSingleSheetExcel = true>

        <cftry>
            <cfspreadsheet action="read" src="#arguments.excel_expand_path#" name="local.excelInfo">        

            <!--- unexpect contents in Excel file - found more than one sheets --->
            <cfif isDefined("local.excelInfo.SummaryInfo") and local.excelInfo.SummaryInfo.Sheets gt 1>
                <cfset local.result.isSingleSheetExcel = false>
                <cfset local.result.summaryInfo = structCopy(excelInfo.SummaryInfo)>
            </cfif>

            <cfcatch type="any">
                <!--- failed to read excel file --->
                <cfset local.result.cfcatch = cfcatch>
                <cfset local.result.isSingleSheetExcel = false>
            </cfcatch>
        </cftry>

        <cfreturn local.result>
	</cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="getProgramLeftPanelHtml" output="false" hint="Return program left hand panel .html information.">
        <cfargument name="program_id" required="true">
        <cfargument name="in_edit_mode" required="false" default="true">

        <!--- internal setting #1 = "save_program_left_panel_to_html" default to true in Huhtamaki site to support tbd items page --->
        <!--- optional internal setting #2 = "program_left_panel_html_expiration_minutes" default to 60 minutes
                                                automatically regenerate .html file after specified minutes --->

        <cfscript>
            local.full_path    = "";
            local.html_content = "";

            // <!--- ~~~~~~~~ save program left panel to html only when setting is enabled ~~~~~~~~~ --->
            if ( application.util.query.get_setting("save_program_left_panel_to_html", 0) ) {
                // <!--- ~~~~ edit mode goes into one html file, readonly goes to another html file ~~~~ --->
                local.full_path = Application.Doc_Path
                                     & "\Temp_Files\Program\left_panel_" 
                                     & arguments.program_id 
                                     & (arguments.in_edit_mode ? "_edit" : "_readonly") 
                                     & ".html";
       
                if ( fileExists( local.full_path ) ) {
                    local.last_modified = getFileInfo( local.full_path ).lastModified;    

                    // <!---  locate left panel html refresh minutes setting - default to 60 minutes if it does not exist  --->
                    local.program_left_panel_html_expiration_minutes = val( application.util.query.get_setting("program_left_panel_html_expiration_minutes", 0) );
                    if (local.program_left_panel_html_expiration_minutes eq 0) 
                        local.program_left_panel_html_expiration_minutes = 60;

                    // <!--- ~~~~~~~~~ flag html file is needed to regenerate when it becomes old ~~~~~~~~~~ --->
                    local.html_age = dateDiff( 'n', local.last_modified, now() );
                    if ( local.html_age lte local.program_left_panel_html_expiration_minutes ) {
                        local.html_content = fileRead( local.full_path );
                    }
                }
            }
        </cfscript>

        <cfreturn {   html_full_path: local.full_path
                    , html_content:   local.html_content  }>
	</cffunction>

</cfcomponent>