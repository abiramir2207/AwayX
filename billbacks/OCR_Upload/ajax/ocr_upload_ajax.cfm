<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\OCR_Upload\ajax\ocr_upload_ajax.cfm
      Date:     28-Feb-2017
      Author:   Anand Rao
      Purpose:  Upload documents

      Parameter: 

----------------------------------------------------------------------------------------------------------------------->
<!---
The below destination needs to be configured and should come from a table. So that it will be easy to update.
 --->
 
<cffile action="uploadall" destination="\\webstage8\CIA_OCR_Claims\File_Landing" nameconflict="makeunique" result="variables.upload"> <cfoutput>#serializeJSON({STATUS=200,MESSAGE='Passed'})#</cfoutput> 

 
<!--- 		<cfset useLakebaseForgetDuplicateUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForgetDuplicateUpload>
	<cftry>
		<cfset getDuplicateUpload = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"header_file_name" = "eq.#cffile.serverFile#",
				"limit" = "1",
				"select" = "[file_name]"
			}), "[file_name]"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDuplicateUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDuplicateUpload>
<cfquery name="getDuplicateUpload" datasource="#application.datasource#">
			SELECT  top 1 [File_Name]
					FROM OCR_Upload_Log
			WHERE 	header_file_name = '#cffile.serverFile#'	
		</cfquery>
</cfif>
		
		
		<cfif getDuplicateUpload.RecordCount GTE 1>
			<!--- <cffile action="delete" file="#cffile.serverDirectory#\#cffile.serverFile#"> --->
			<BR><BR><b><u>Upload Failed due to the below reason:</u></b><BR><BR>
				<TABLE>
				  <TR>
			  		<TD style="font-weight:bold;">
					
					The File with the same name is already in the System!! Please try a different file.
					</TD>
				  </TR>
				</TABLE>
				<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 10000);</SCRIPT> 
			<CFABORT>	
		</cfif>
		
 --->						
			 
<!--- <cffile action="uploadall" destination="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\" nameconflict="makeunique" result="variables.upload"> <cfoutput>#serializeJSON({STATUS=200,MESSAGE='Passed'})#</cfoutput> --->

<!--- <cfdump var="#variables.upload#" format="text" showUDfs="false" output="d:\coldfusion\myDebugLog.txt"> --->

<!--- <cfquery name="variables.qMisc" datasource="#application.datasource#">
  SELECT a.User_Positions_ID
         , ( SELECT Upload_Document_Privacy_Off FROM _application_settings ) AS Upload_Document_Privacy_Off
    FROM User_Position_Holders a
   WHERE a.User_ID = '#request.AccessStructure.user_id#' AND a.User_Position_Type = 'P' AND	a.Deleted = 0
</CFQUERY> --->

<cfquery name="variables.save_data" datasource="#application.datasource#">
	DECLARE @newDocID UNIQUEIDENTIFIER
	<cfloop from="1" to="#arrayLen(variables.upload)#" index="variables.index">
	  INSERT INTO	
	  		OCR_Upload_Log
			(	 
				File_Name,
				Source_Template,
				Created_User_ID,
				OCR_Upload_Date,
				OCR_Upload_Status,
				upload_type,
				File_Extension,
				File_Size,
				OCR_Step
			)
		VALUES	
			(	 
			    '#variables.upload[ variables.index ].serverFile#',
				NULL,
				'#request.AccessStructure.user_id#',
				#now()#,
				'Uploaded.. Waiting for Text Reader',
				'', /* This will be the type */
				'#variables.upload[ variables.index ].serverFileExt#',
				'#variables.upload[ variables.index ].fileSize#',
				1
				)
		<!--- 
		<cfloop list="#url.program_id#" index="variables.program_id">
			INSERT INTO Contract_Attachments
							(	Program_ID,	Doc_ID )
			VALUES	( '#variables.Program_id#',	@newDocID	)
		</cfloop> 
		--->
	</cfloop>
</cfquery>
