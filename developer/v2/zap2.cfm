<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfscript>
        // remove files that are older than twelve hours from now
        TEMP_FILES_OLDER_THAN_IN_HOURS = -12;

        delete_temp_files( "\temp_files\", TEMP_FILES_OLDER_THAN_IN_HOURS);
        delete_temp_files( "\common_documents\temp_files\", TEMP_FILES_OLDER_THAN_IN_HOURS);

        delete_temp_files( "\common_documents\Data_Files\Created\error_files\", -4320);
    </cfscript>



    <cffunction name="delete_temp_files" output="true">
        <cfargument name="folder_relative_path" required="true" type="string">
        <cfargument name="files_last_modified_hours" required="true" type="numeric">

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  only "temp_files" folders are qualified  --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfif listFindNoCase(arguments.folder_relative_path, "temp_files",  "/,\")
           or listFindNoCase(arguments.folder_relative_path, "error_files", "/,\")>
            
           <!--- gather all files in all subfolders and exclude folders --->
            <cfif 0>
                <cfset local.full_path = expandPath( arguments.folder_relative_path )>
            <cfelse>
                <!--- point to the root folder of the site you want to remove the temporary files --->
                <cfset local.full_path = "F:\Inetpub\wwwroot\smithfield.awayx.com\" & arguments.folder_relative_path>
            </cfif>


            <cfdirectory action="list" name="local.qTempFiles" directory="#local.full_path#" type="file" recurse="true">
            <cfif 0>
                <cfloop query="local.qTempFiles" startrow="1" endrow="100">
                    <cfoutput>#Directory#\#Name#<br></cfoutput>
                </cfloop>
            </cfif>
        
            <!--- last modification hours validation - must be a negative value --->
            <cfif arguments.files_last_modified_hours gt 0>
                <cfset arguments.files_last_modified_hours = -1 * arguments.files_last_modified_hours>
            </cfif>

            <!--- determine last modification datetime maximum value: going back number of hours from now --->
            <cfset local.last_modified_cutoff = dateAdd('h', arguments.files_last_modified_hours, now())>

            <!--- gather all files qualified for deletion --->
            <cfquery name="local.qFilesToDelete" dbtype="query">
                SELECT *
                  FROM [local].qTempFiles
                  WHERE DateLastModified < #local.last_modified_cutoff#
            </cfquery>
        
            <cfif 0>
                <cfdump var="#local.qFilesToDelete#">
            </cfif>

            <cfif 1>
                <!--- carry out the actual file deletion --->
                <cfoutput query="local.qFilesToDelete">
                    <cffile action="delete" file="#local.qFilesToDelete.Directory#\#local.qFilesToDelete.Name#">
                </cfoutput>                
            </cfif>
    </cfif>
    </cffunction>

</body>
</html>