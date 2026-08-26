<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<!---------------------------------------------------------------------------------------------------------------------
      Template: C:\Forge\Base\AwayX\Planners\Create\ajax\upload_documents.cfm
          Date: 2016 December
        Author: Chris Nguyen
       Purpose: Upload documents & save to the database

     Parameter: none

----------------------------------------------------------------------------------------------------------------------->
<cftry>
	<cffile action="uploadall" destination="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\" nameconflict="makeunique" result="upload_result">
	<cfoutput>#serializeJSON({STATUS=200, MESSAGE='Passed'})#</cfoutput>
	<cfcatch type="any" >
		<cfoutput>#serializeJSON({STATUS=500, MESSAGE="Failed"})#</cfoutput>
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

	<cfloop from="1" to="#arrayLen(upload_result)#" index="array_index">
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
			        '#upload_result[ array_index ].serverFile#',
					'#upload_result[ array_index ].ClientFileName#',
					'#upload_result[ array_index ].ClientFileName#',
					#now()#,
					'#request.AccessStructure.user_id#',
					'#upload_result[ array_index ].clientFileName#',
					'#upload_result[ array_index ].fileSize#',
					'#upload_result[ array_index ].serverFileExt#',
					'#request.AccessStructure.user_id#',
					#qUser.User_Positions_ID#,
					#qUser.Upload_Document_Privacy_Off#
				)

		INSERT INTO Contract_Attachments ( Program_ID, Doc_ID )	VALUES ( '#url.programID#',	@newDocID )
	</cfloop>
</cfquery>
</cfsilent>
