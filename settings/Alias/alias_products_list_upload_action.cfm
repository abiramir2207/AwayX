<cfparam name="Form.DelUploads" default="">
<cfparam name="URL.ResetUpload" default="0">

<!---Identify unique file name --->
<cfset UniqueGeneralName = replace(request.AccessStructure.User_ID, "-", "_", "all") & dateformat(now(), 'mm_dd_mm_ss')>
<cfset UniqueFileName = "Alias_Products" & UniqueGeneralName & ".csv">

<!---Set file location --->
<cfset filepath = application.Doc_Path & "\data_files\uploaded\Alias\Products\"  & UniqueFileName>

<!--- Upload the file to the web server --->
<CFFILE ACTION = "upload"
		FILEFIELD = "File_Path"
		DESTINATION = "#filepath#"
		NAMECONFLICT =	"MakeUnique">

<!--- Sets the path for uploading the form field to a file --->
<cfset FiletoUpload = '\\' & Application.WebServerName & '\' & Replace(filepath, ':', '$')>

<cfif NOT FileExists(FiletoUpload)>
	<cfset FileToUpload = filepath>
</cfif>

<!--- Make an initial entry into the upload history table and get the Upload ID --->
<cfquery name="setUploadInfo" datasource="#application.datasource#"> 
 INSERT INTO Alias_Management_Products_History(Creator_ID,Created_Date,Upload_FileName,Upload_Action_Status)
 VALUES('#request.Accessstructure.User_ID#',getdate(),'#FiletoUpload#',1)

 SELECT Alias_Management_Product_History_ID = @@IDENTITY
</cfquery>

<!--- Get the db path where the uploaded file will be copied from the web server  --->
<cfquery name="get_DTS_Reference_Path" datasource="#application.datasource#">
SELECT TOP 1 DTS_Reference_Path
FROM DataInt_Settings
ORDER BY Setting_Date DESC
</cfquery>

<!--- Get the filename of the file uploaded to the web server --->
<cfset useLakebaseForget_Upload_File_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alias_management_products_history")>
<cfif useLakebaseForget_Upload_File_Name>
	<cftry>
		<cfset get_Upload_File_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alias_management_products_history", {
				"alias_management_product_history_id" = "eq.#setUploadInfo.Alias_Management_Product_History_ID#",
				"select" = "upload_filename"
			}), "upload_filename"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Upload_File_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Upload_File_Name>
<cfquery name="get_Upload_File_Name" datasource="#application.datasource#">
SELECT Upload_FileName
FROM Alias_Management_Products_History 
WHERE Alias_Management_Product_History_ID = '#setUploadInfo.Alias_Management_Product_History_ID#'
</cfquery>
</cfif>

<!--- We always choose the name '\AliasProducts.csv' for the file. --->
<cfset Complete_File_Path = get_DTS_Reference_Path.DTS_Reference_Path & '\AliasProducts.csv'>

<!--- Copy the file from the web server to the db server --->
<cffile action="copy" source="#get_Upload_File_Name.Upload_FileName#" destination="#Complete_File_Path#">

<cftry>
<!--- Finally, call the routine to upload "Aliases" --->
<cfstoredproc procedure="Upload_Alias_Products" datasource="#application.datasource#">
	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@UploadID" value = "#setUploadInfo.Alias_Management_Product_History_ID#" null="no" />
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Complete_File_Path" value = "#Complete_File_Path#" null="no" />
</cfstoredproc>

	<cfcatch>
	<cfset ErrMessage = "#CFCATCH.Message# : #CFCATCH.detail#">
	<cfquery name="get_Upload_File_Name" datasource="#application.datasource#">
	INSERT INTO Alias_Management_Products_History_Detail(Alias_Management_Product_History_ID,Row_Num,Distributor_Group_Level_ID,
	Product_ID,Distributor_ID,Distributor_Product_Number,Error_Message)
	VALUES(<cfqueryparam value="#setUploadInfo.Alias_Management_Product_History_ID#" cfsqltype="CF_SQL_INTEGER">,0,0,0,0,0,'#ErrMessage#')

	UPDATE Alias_Management_Products_History
	SET Upload_Action_Status = 2
	WHERE Alias_Management_Product_History_ID = <cfqueryparam value="#setUploadInfo.Alias_Management_Product_History_ID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
		<cfrethrow />
	</cfcatch>
</cftry>
