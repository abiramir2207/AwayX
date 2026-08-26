<cfparam name="Form.DelUploads" default="">
<cfparam name="URL.ResetUpload" default="0">


<cfif Form.DelUploads neq "">
	<cfquery name="DelUploadedEntries" datasource="#application.datasource#">
	BEGIN TRANSACTION
	UPDATE Outbound_Freight_Upload
	SET Deleted = 1
	WHERE Outbound_Freight_Upload_ID IN (<cfqueryparam value="#Form.DelUploads#" cfsqltype="CF_SQL_VARCHAR" list="yes">)

	UPDATE Outbound_Freight_Upload_Detail
	SET Deleted = 1
	WHERE Outbound_Freight_Upload_ID IN (<cfqueryparam value="#Form.DelUploads#" cfsqltype="CF_SQL_VARCHAR" list="yes">)

	COMMIT TRANSACTION
	</cfquery>

<cfelseif URL.ResetUpload eq 1>

<!--- Status of 4 means "reset upload manually" --->

		<cfset useLakebaseForset_Error_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("outbound_freight_upload")>
<cfif useLakebaseForset_Error_Status>
	<cftry>
		<cfset application.oLakebase.updateRows("outbound_freight_upload",
			{
				"outbound_freight_upload_id" = "eq.#URL.Outbound_Freight_Upload_ID#"
			},
			{
				"outbound_freight_upload_status" = "4"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForset_Error_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForset_Error_Status>
<cfquery name="set_Error_Status" datasource="#application.datasource#">
		 UPDATE Outbound_Freight_Upload
		 SET Outbound_Freight_Upload_Status = 4
		 WHERE Outbound_Freight_Upload_ID = '#URL.Outbound_Freight_Upload_ID#'
		</cfquery>
</cfif>

		<cfquery name="set_Error_Message" datasource="#application.datasource#">
		 INSERT INTO Outbound_Freight_Upload_Detail(Outbound_Freight_Upload_ID,ErrorMessage)
		 VALUES('#URL.Outbound_Freight_Upload_ID#','Reset Upload Manually')
		</cfquery>

<cfelse>

	<!---Identify unique file name --->
	<cfset UniqueGeneralName = replace(request.AccessStructure.User_ID, "-", "_", "all") & dateformat(now(), 'mm_dd_mm_ss')>
	<cfset UniqueFileName = "Outbound_Freight" & UniqueGeneralName & ".csv">

	<!---Set file location --->
	<cfset filepath = application.Doc_Path & "\data_files\uploaded\freight\upload_outbound_freight\"  & UniqueFileName>

	<CFFILE ACTION = "upload"
			FILEFIELD = "File_Path"
			DESTINATION = "#filepath#"
			NAMECONFLICT =	"MakeUnique">

	<!--- Sets the path for uploading the form field to a file --->
	<cfset FiletoUpload = '\\' & Application.WebServerName & '\' & Replace(filepath, ':', '$')>

	<!---	D36633  Window 2008 sever dont like D$, E$ in file path	 	--->
	<cfif FindNoCase("E$\", FiletoUpload)>
		<cfset FiletoUpload = Replace(FiletoUpload, "E$\", "")>
	<cfelse>
		<cfset FiletoUpload = Replace(FiletoUpload, "D$\", "")>
	</cfif>
	<!---	D36633  Window 2008 sever dont like D$, E$ in file path	 	--->

	<cfif NOT FileExists(FiletoUpload)>
		<cfset FileToUpload = filepath>
	</cfif>


	<cfset filename = Right(filepath, find('\',reverse(filepath))-1)>

	<cfquery name="setUploadErrors" datasource="#application.datasource#">
	INSERT INTO Outbound_Freight_Upload(Outbound_Freight_Upload_By,Outbound_Freight_Upload_Date,Outbound_Freight_Upload_File_Name
	,Outbound_Freight_Upload_Status)
	VALUES('#request.Accessstructure.User_ID#',getdate(),'#FiletoUpload#',1)

	SELECT Outbound_Freight_Upload_ID = @@IDENTITY
	</cfquery>


	<cfset useLakebaseForget_FileShare_Path = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_settings")>
<cfif useLakebaseForget_FileShare_Path>
	<cftry>
		<cfset get_FileShare_Path = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_upload_settings", {
				"select" = "file_path"
			}), "file_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_FileShare_Path = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_FileShare_Path>
<cfquery name="get_FileShare_Path" datasource="#application.datasource#">
		SELECT File_Path FROM Billback_Upload_Settings
	</cfquery>
</cfif>

	<cfset useLakebaseForget_Upload_File_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("outbound_freight_upload")>
<cfif useLakebaseForget_Upload_File_Name>
	<cftry>
		<cfset get_Upload_File_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("outbound_freight_upload", {
				"outbound_freight_upload_id" = "eq.#setUploadErrors.Outbound_Freight_Upload_ID#",
				"select" = "outbound_freight_upload_file_name"
			}), "outbound_freight_upload_file_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Upload_File_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Upload_File_Name>
<cfquery name="get_Upload_File_Name" datasource="#application.datasource#">
	SELECT Outbound_Freight_Upload_File_Name
	FROM Outbound_Freight_Upload
	WHERE Outbound_Freight_Upload_ID = '#setUploadErrors.Outbound_Freight_Upload_ID#'
	</cfquery>
</cfif>

	<!---  We always choose the name 'OutboundFreight.csv' for the file  --->
	<cfset Complete_File_Path = get_FileShare_Path.File_Path & '\OutboundFreight.csv'>

	<!---	D36633  Window 2008 sever dont like D$, E$ in file path	--->
	<cfif FindNoCase("E$\", Complete_File_Path)>
		<cfset Complete_File_Path = Replace(Complete_File_Path, "E$\", "")>
	<cfelse>
		<cfset Complete_File_Path = Replace(Complete_File_Path, "D$\", "")>
	</cfif>
	<!---	D36633  Window 2008 sever dont like D$, E$ in file path	 	--->


	<cffile action="copy" source="#get_Upload_File_Name.Outbound_Freight_Upload_File_Name#" destination="#Complete_File_Path#">

	<cftry>

		<cfstoredproc procedure="Upload_OBF_Rate" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@UploadID" value = "#setUploadErrors.Outbound_Freight_Upload_ID#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Complete_File_Path" value = "#Complete_File_Path#" null="no" />
		</cfstoredproc>

	<!--- Status of 3 means error --->
		<cfcatch>
			<cfset useLakebaseForsetErrorStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("outbound_freight_upload")>
<cfif useLakebaseForsetErrorStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("outbound_freight_upload",
			{
				"outbound_freight_upload_id" = "eq.#setUploadErrors.Outbound_Freight_Upload_ID#"
			},
			{
				"outbound_freight_upload_status" = "3"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsetErrorStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsetErrorStatus>
<cfquery name="setErrorStatus" datasource="#application.datasource#">
			UPDATE Outbound_Freight_Upload
			SET Outbound_Freight_Upload_Status = 3
			WHERE Outbound_Freight_Upload_ID = '#setUploadErrors.Outbound_Freight_Upload_ID#'
			</cfquery>
</cfif>

			<cfset ErrMessage = "#CFCATCH.Message# : #CFCATCH.detail#">

			<cfquery name="setErrorMessage" datasource="#application.datasource#">
			INSERT INTO Outbound_Freight_Upload_Detail(Outbound_Freight_Upload_ID,ErrorMessage)
			VALUES('#setUploadErrors.Outbound_Freight_Upload_ID#','#ErrMessage#')
			</cfquery>

			<cfrethrow />
		</cfcatch>

	</cftry>

</cfif>

<cflocation url="index.cfm?Action=#Action#">
