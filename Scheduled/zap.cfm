<!---
  * ==================================================================================================== 
  *    @File: \scheduled\zap.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 April
  * 
  * @Remarks: Clean up temporary files - This utility should be executed manually during off hours. Only 
  *              use this utility when there are hundred of thousands files. Otherwise, we should let 
  *              the updated standard scheduled task do clean up.
  *
  * @Important:  DO NOT RUN this utility on MULTIPLE SITES ON THE SAME SERVER AT THE SAME TIME.
  *
  * ==================================================================================================== 
--->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zap.cfm Utility</title>
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
</head>

<body>
    <header>
        <h1>Zap.cfm Utility</h1>
        <p>This utility cleans up temporary files</p>
    </header>

    <cfset started_time = getTickCount()>

    <cfoutput>
        <main>
            <table>
                <tbody>
                    <tr>
                        <td>Started Running At</td>
                        <td>#timeformat(now(), "medium")#</td>
                    </tr>

                    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                    <!---  start the clean up process here ~ --->
                    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                    <cfscript>
                        // remove files that are older than twelve hours from now
                        FILES_OLDER_THAN_IN_HOURS = -12;
                
                        delete_temp_files( "\temp_files\", FILES_OLDER_THAN_IN_HOURS);
                        delete_temp_files( "\common_documents\temp_files\", FILES_OLDER_THAN_IN_HOURS);
                
                        delete_temp_files( "\common_documents\Data_Files\Created\error_files\", -4320);
                    </cfscript>

                    
                    <tr>
                        <td>Ended At</td>
                        <td>#timeformat(now(), "medium")#</td>
                    </tr>

                    <tr>
                        <td>Time Elapsed</td>
                        <td>#numberFormat((getTickCount() - started_time) / 60000, ",")# minutes</td>
                    </tr>
                </tbody>
            </table>
        </main>
    </cfoutput>
    

    <footer>
        <p>Blacksmith Applications Inc. 2021</p>
    </footer>    
</body>
</html>



<cffunction name="delete_temp_files" output="true">
    <cfargument name="folder_relative_path" required="true" type="string">
    <cfargument name="files_last_modified_hours" required="true" type="numeric">

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  only "temp_files" folders are qualified  --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif listFindNoCase(arguments.folder_relative_path, "temp_files",  "/,\")
       or listFindNoCase(arguments.folder_relative_path, "error_files", "/,\")>
        <!--- gather all files in all subfolders and exclude folders --->
        <cfdirectory action="list" name="local.qTempFiles" directory="#expandPath( arguments.folder_relative_path )#" type="file" recurse="true">
    
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

        <!--- carry out the actual file deletion --->
        <cfoutput query="local.qFilesToDelete">
            <cffile action="delete" file="#local.qFilesToDelete.Directory#\#local.qFilesToDelete.Name#">
        </cfoutput>
    </cfif>
</cffunction>
