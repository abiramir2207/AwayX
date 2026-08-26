<!-----------------------------------------------------------------------------------------------------------
	Template : 	/Programs/upload/ajax/import.cfm
	Author   : 	Kal
	Date     : 	9/17/2018
	Purpose  : 	Import programs from Excel XLSX file
------------------------------------------------------------------------------------------------------------>
<cfsetting showDebugOutput="No">
<cftry>
	<cfset file_path = application.doc_path & "/data_files/Uploaded/Documents/Uploaded_Doc/">
	<cffile action="upload" destination="#file_path#" nameconflict="makeunique" result="upload"/>

	<!---send success status & uploaded file name back--->
	<cfoutput>#serializeJSON({STATUS=200, MESSAGE=file_path & upload.serverFile})#</cfoutput>
<cfcatch type="any" >
	<cfoutput>#serializeJSON({STATUS=500, MESSAGE=JSStringFormat(arguments.detail_message)})#</cfoutput>
</cfcatch>
</cftry>


<cfsilent>
<cfquery name="qUser" datasource="#application.datasource#">
  SELECT a.User_Positions_ID
         , ( SELECT Upload_Document_Privacy_Off
         	   FROM _application_settings ) AS Upload_Document_Privacy_Off
    FROM User_Position_Holders a
   WHERE a.User_ID = '#request.AccessStructure.user_id#'
     		AND a.User_Position_Type = 'P'
     		AND	a.Deleted = 0
</cfquery>

<cfquery name="qSave" datasource="#application.datasource#">
	DECLARE @newDocID UNIQUEIDENTIFIER
	SET @newDocID = NewID()
	
	INSERT INTO	Document_Details
						(	Doc_ID,
							Doc_Uni_Name,
							Doc_Title,
							Doc_Description,
							Uploaded_Date,
							Uploaded_By,
							Doc_File_Name,
							Doc_Size,
							Doc_Family,
							LastUpdated_UserId,
							User_Position_ID,
							Public_View
						)
		VALUES	(	@newDocID,
			        '#upload.serverFile#',
					'#upload.ClientFileName#',
					'#upload.ClientFileName#',
					#now()#,
					'#request.AccessStructure.user_id#',
					'#upload.clientFileName#',
					'#upload.fileSize#',
					'#upload.serverFileExt#',
					'#request.AccessStructure.user_id#',
					#qUser.User_Positions_ID#,
					#qUser.Upload_Document_Privacy_Off#
				)

</cfquery>

</cfsilent>
