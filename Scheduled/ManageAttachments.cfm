<!---
	Copyright (c)2010 Blacksmith Applications, Inc.
	Filename:		AwayX\Scheduled\ManageAttachments.cfm
	Created:		7/20/2010
	Developer:		kvangapalli
	Description:	Used to create entries for files/attachements transferred via FTP
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->

<!--- For all files in Temp directory rename and move the files to Upload folder and attach --->
<cfdirectory directory="#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc" type="file" name="tempDirectory" />

<cfloop query="tempDirectory">

	<cfset tempFileName = tempDirectory.name />
	<!--- get the filename(deduction number), filenumber, filetype(extension) and filesize. --->
	<cfset ddNumber = listFirst(tempFileName, ".") />
	<cfset fileType = listLast(tempFileName, ".") />
	<cfset fileNumber = Replace(Replace(Replace(tempFileName, ddNumber,""), fileType, ""), ".", "", "ALL") />
	<cfset fileSize = tempDirectory.size />

	<!--- 	Query DB for existing decuction record and then move and add the file as attachment.
	 		Otherwise leave it here and when there is a Deduction then we will move it. --->
	<cfquery name="qFindAttachment" datasource="#application.datasource#">
		SELECT DEDUCTION_ID FROM DEDUCTIONS WHERE DD_DedID LIKE <cfqueryparam value="%#ddNumber#%" cfsqltype="cf_sql_varchar">
	</cfquery>


	<cfif qFindAttachment.recordCount>
		<!--- rename the file to make it unique --->
		<cfset unique_ID = createUUID() />
		<cfset modFileName = "#Replace(unique_ID,"-","_","all")#.#fileType#" />

		<!--- rename the file to unique name --->
		<cffile action="rename"
				source="#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#tempFileName#"
				destination="#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#modFileName#" />
		<!--- move the file from temp directory --->
		<cffile action="move"
			source="#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#modFileName#"
			destination="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#modFileName#" />

		<!--- Insert into database --->
		<cfquery name="SaveAttachment" datasource="#application.datasource#">
			INSERT INTO Document_Details
			(
			 	Doc_Uni_Name, Doc_Title, Doc_Description, Uploaded_Date, Uploaded_By,
				Doc_Type, Doc_Family, Deleted, Doc_File_Name, Doc_Size, LastUpdated_UserId,
				User_Position_ID, Public_View, Is_Welcome_Letter
			)
			Values
			(
			 '#modFileName#', '#ddNumber#_#fileNumber#', '#ddNumber#_#fileNumber#_#fileType#', getdate(), 'System',
			 '#fileType#', '#fileType#', '0', '#tempFileName#', '#fileSize#', 'System',
			 '1', '0', '0'
			)
			SELECT Doc_ID = @@IDENTITY
		</cfquery>

		<cfquery name="attachDocument" datasource="#application.datasource#">
			INSERT INTO CONTRACT_ATTACHMENTS (DOC_ID, DEDUCTION_ID)
			SELECT 	'#SaveAttachment.Doc_ID#', DEDUCTION_ID
			FROM 	DEDUCTIONS
			WHERE 	DD_DedID LIKE <cfqueryparam value="%#ddNumber#%" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cfif>

</cfloop>

<!--- Delete files older than n number of days --->
<cfdirectory directory="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\" type="file" name="uploadDirectory" />

<cfloop query="uploadDirectory">
	<!--- get the filename, age and delete if old enough. --->
	<cfset tempFileName = uploadDirectory.name />
	<cfset fileAge = DateDiff("d", uploadDirectory.dateLastModified, now()) />
	<cfset DocumentPurgeAge = Application.oApplicationAppSettingsManager.getApplicationAppSettings().getDocumentPurgeAge() />

	<cfif len(DocumentPurgeAge) AND DocumentPurgeAge AND fileAge GT DocumentPurgeAge >
		<cfquery name="DeleteDocument" datasource="#application.datasource#">
			UPDATE 	Document_Details
			SET 	Deleted = 1
			WHERE	Doc_Uni_Name = <cfqueryparam value="#listFirst(tempFileName, ".")#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cffile action="delete"
				file="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#tempFileName#" />
	</cfif>
</cfloop>

