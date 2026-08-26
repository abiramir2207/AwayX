
<!--- This replaces tho old BrowseBBDocsGet.cfm with Azure specific mappings --->

<cfscript>
		param name="url.txtFileName" default="";

	    file_name  = urlDecode( url.txtFileName );
	    destPathName = "#application.Doc_path#\data_files\uploaded\documents\uploaded_doc\";

	    if(application.webservername contains "10.30."){
	    	AdjustHomePath = 'F:\pittsburgh\#application.util.query.get_Setting("BB_Doc_Server_Folder", Replace(CreateUUID(),'-',''))#\Claim Documentation';
	    }
	    else{
	    	AdjustHomePath = 'F:\pittsburgh\#application.util.query.get_Setting("BB_Doc_Server_Folder", Replace(CreateUUID(),'-',''))#\Claim Documentation';
	    }
</cfscript>

<cfif application.appSettingsGet.getBillbackFileUploadType() EQ 3>

    <cfset attachments_http_time_out_in_seconds = application.util.query.get_Setting("attachments_http_time_out_in_seconds", 0)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  default to use 90 seconds time-out when optional setting is missing or invalid  --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif val(attachments_http_time_out_in_seconds) eq 0 or !isNumeric(attachments_http_time_out_in_seconds)>
        <cfset attachments_http_time_out_in_seconds = 90>
    </cfif>

	<cfscript>
	    attachment = {name:file_name, directory:''};

	    // use Windows dir command to locate the selected file
	    sArgs = AdjustHomePath & '\';
	    sArgs = '"' & sArgs & file_name & '"';

	    cfexecute (name="#expandPath("find.bat")#", arguments="#sArgs#", timeout="60", variable="find_result", errorVariable="exError");
	    //DO WE NEED A TRY CATCH FOR CFEXECUTE??	writedump(exError);
	    // parse the multiple lines search find_result & convert into an array
	    find_result = listToArray(find_result, chr(10) & chr(13));
	    
	    for (i=2; i <= arrayLen(find_result);i=i+1) {
	        // standardize all the slashes
	        find_result[i] = replace(find_result[i], '/', '\', "all");
	                                         
	        // Get last part of the output
	        result_file_name = listLast(find_result[i], '\');

	        // we are replacing space with * which might result in multiple files. we should check if filename matches
	        if(result_file_name == file_name) {		// || result_file_name == cleaned_file_name
	            attachment.name = result_file_name;                                   
	            // remove file name from full path
	            attachment.directory = listDeleteAt(find_result[i], listLen(find_result[i], '\'), '\');
	        }
	    }
	</cfscript>
	<cfif attachment.directory neq "">
			<cfset url.filePath = '#attachment.directory#\#attachment.name#'/>
			<cfinclude template='/getDocument.cfm'/>
	<cfelse>
	    <p align="center">
		<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			File not found. [<span style="FONT-SIZE: 11pt; FONT-FAMILY: 'Century Gothic'; font-weight:normal; color='red' "><cfoutput>#file_name#</cfoutput></span>]
		</span>
		</p>
	</cfif>  <!--- if attachment.directory --->
</cfif>






