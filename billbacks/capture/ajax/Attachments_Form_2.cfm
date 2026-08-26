<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\capture\ajax\Attachments_Form.cfm
      Date:     2014 August
      Author:   Chris Nguyen
      Purpose:  Upload documents

      Parameter: URL.BBID =

----------------------------------------------------------------------------------------------------------------------->
<cffile action="uploadall" destination="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\" nameconflict="makeunique"> <cfoutput>#serializeJSON({STATUS=200,MESSAGE='Passed'})#</cfoutput>

<!--- <cfdump var="#variables.upload#" format="text" showUDfs="false" output="d:\coldfusion\myDebugLog.txt"> --->

<cfquery name="variables.qMisc" datasource="#application.datasource#">
  SELECT a.User_Positions_ID
         , ( SELECT Upload_Document_Privacy_Off FROM _application_settings ) AS Upload_Document_Privacy_Off
    FROM User_Position_Holders a
   WHERE a.User_ID = '#request.AccessStructure.user_id#' AND a.User_Position_Type = 'P' AND	a.Deleted = 0
</CFQUERY>


<cfquery name="variables.save_data" datasource="#application.datasource#">
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
		        '#cffile.serverFile#',
				'#cffile.clientFileName#',
				'#cffile.clientFileName#',
				#now()#,
				'#request.AccessStructure.user_id#',
				'#cffile.clientFileName#',
				'#cffile.fileSize#',
				'#cffile.serverFileExt#',
							'#request.AccessStructure.user_id#',
							#variables.qMisc.User_Positions_ID#,
							#variables.qMisc.Upload_Document_Privacy_Off#
						)
<cfif url.BBID neq 0>
		<cfloop list="#url.BBID#" index="variables.Billback_ID">
			INSERT INTO Contract_Attachments
							(	Billback_ID,	Doc_ID )
			VALUES	( '#variables.Billback_ID#',	@newDocID	)
		</cfloop>
</cfif>
</cfquery>