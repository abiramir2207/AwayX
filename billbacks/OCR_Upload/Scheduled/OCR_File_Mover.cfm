<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/OCR_File_Mover.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Moves the file after the the txt files are created 
----------------------------------------------------------------------------------> 
<!----
to pick up the TXt file and then do the keyword matchup (from above step) and them move the pdf file to the corresponding location
--->

<!--- This query will check to see if the scheduled task is running or not --->
<cfset useLakebaseForqryIsSTProcessing = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cia_scheduled_task_log")>
<cfif useLakebaseForqryIsSTProcessing>
	<cftry>
		<cfset qryIsSTProcessing = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cia_scheduled_task_log", {
				"isprocessing" = "eq.1",
				"select" = "cia_scheduled_task_log_id,start_datetime,end_datetime,errored,isprocessing"
			}), "cia_scheduled_task_log_id,start_datetime,end_datetime,errored,isprocessing"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryIsSTProcessing = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryIsSTProcessing>
<cfquery name="qryIsSTProcessing" datasource="#application.datasource#">
	SELECT 	CIA_Scheduled_Task_Log_id,
		  	Start_DateTime,
			End_DateTime,
			Errored,
			isProcessing
	FROM	
		CIA_Scheduled_Task_Log
	WHERE 
		isProcessing = 1
</cfquery>
</cfif>

<cftry>
	<cfif (qryIsSTProcessing.Recordcount EQ 0)>


	<cfset useLakebaseForqryINSSTLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cia_scheduled_task_log")>
<cfif useLakebaseForqryINSSTLog>
	<cftry>
		<cfset application.oLakebase.insertRow("cia_scheduled_task_log", {
			"start_datetime" = "#now()#",
			"errored" = "0",
			"isprocessing" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqryINSSTLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryINSSTLog>
<cfquery name="qryINSSTLog" datasource="#application.datasource#">
		INSERT INTO CIA_Scheduled_Task_Log
			(	
				Start_DateTime,
				Errored,
				isProcessing
			)
		VALUES
		(
			Getdate(),
			0,
			1
		)
		
		SELECT SCOPE_IDENTITY()	AS CIA_Scheduled_Task_Log_ID
	</cfquery>
</cfif>
	<cfset CIAScheduledTaskLogID = qryINSSTLog.CIA_Scheduled_Task_Log_ID />
	
	<cfscript>
		OCRSettingsManager  = CreateObject("component","components.Billback.OCRUploadSettingsManager");
	</cfscript>	
	
	<cfquery name="qryGetDBServerType" datasource="#application.datasource#">
		DECLARE @IPString VARCHAR(15), 
		@Stage_IP_Range VARCHAR(50),
		@Prod_IP_Range VARCHAR(50),
		@AzureStage_IP_Range VARCHAR(50),
		@AzureProd_IP_Range VARCHAR(50),
		@Other_IP_Range VARCHAR(50),
		@Server_Type VARCHAR(50)
		
		-- SET @IPString = '10.40.3.9'  
		SELECT @IPString = CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR(15)) 
		
		SET @AzureStage_IP_Range = '10.40'  
		SET @AzureProd_IP_Range = '10.30'
		SET @Stage_IP_Range = '10.2'  
		SET @Prod_IP_Range = '10.1'
		
		 SET @Server_Type = 'STAGE'
		
		IF ( (@IPString LIKE '%' + @AzureStage_IP_Range + '%') OR (@IPString LIKE '%' + @Stage_IP_Range + '%'))
		    SET @Server_Type = 'STAGE'
		ELSE IF ( (@IPString LIKE '%' + @AzureProd_IP_Range + '%') OR (@IPString LIKE '%' + @Prod_IP_Range + '%') )
		    SET @Server_Type = 'PROD' 
		ELSE  
		    SET @Server_Type = 'STAGE'
		
		SELECT @Server_Type as Server_Type
	</cfquery>
	
	<cfset toEmail = "anand.srinivasarao@blacksmithapplications.com" /> 
	<cfif (qryGetDBServerType.RecordCount NEQ 0)>
		<cfif (qryGetDBServerType.Server_Type EQ "STAGE")>
			<cfset toEmail = "anand.srinivasarao@blacksmithapplications.com;nupur.patel@blacksmithapplications.com;mercedes.johnson@blacksmithapplications.com" />
		<cfelseif (qryGetDBServerType.Server_Type EQ "PROD")>
			<cfset toEmail = "ciasupport@blacksmithapplications.com" />
		</cfif>
		<!--- <cfset toEmail = "anand.srinivasarao@blacksmithapplications.com" /> --->
		<!--- <cfset toEmail = "anand.srinivasarao@blacksmithapplications.com;nupur.patel@blacksmithapplications.com;mercedes.johnson@blacksmithapplications.com" />  --->
	</cfif>
	<!--- If Developer machine then set to Developer's Email ID--->
	<cfif CGI.HTTP_HOST EQ "anand.base.awayx.com">
		<cfset toEmail = "anand.srinivasarao@blacksmithapplications.com" /> 
	</cfif>

	<cfset fromEmail = "CIAAdmin@blacksmithapplications.com" />
	<cfset uploadInfoSiteURL = application.HTTPVar & CGI.SERVER_NAME & "/billbacks/OCR_Upload/scheduled/UploadID_Info.cfm?UploadID=" />
	<cfset varTimeoutSinceUpdate = "10" />
	<cfset varTimeoutSinceCreate = "20" />
	<cfset varUmbrellaTimeout 	= "30" />
	<cfset varUmbrellaRTTimeout = "60" />
		<cfquery name="qDBName" datasource="#application.datasource#">
			  SELECT DB_NAME() AS DBName
		</cfquery>

		<html>
		<head>
			<title>OCR File Mover</title>
		</head>

		<body>
		<!---- PHASE 1 for records in OCR_Step = 2 OR '2.CF_Error' /* Adding 2.CF_Error to make sure */ --->
		<br>
		<br>
		<h2>PHASE 1: </h2>
		<cftry>
			<cfquery name="qGetOCRUploadRecords" datasource="#application.datasource#">
				SELECT 	OUL.OCR_Upload_ID,
						OUL.File_Name,
						OUL.Source_Template,
						OUL.Created_User_ID,
						OUL.OCR_Upload_Date,
						OUL.OCR_Upload_Status,
						OUL.Debug_Dev_Status,
						OUL.Deleted,
						OUL.Deleted_By,
						OUL.Deleted_Date,
						OUL.upload_type,
						OUL.BB_Claim_Source_Xref_ID,
						OUL.OCR_Template_Settings_ID,
						OUL.ProcessTries,
						OUL.Pages_Extracted,
						OUL.OCR_Sub_Step,
						OTS.OCR_Reader_Name,
						OTS.DB_OCR_Source_Code,
						OTS.OCR_Code,
						OTS.Source_Code,
						OTS.Is_Double_Processing_On,
						OTS.Special_Processing_Flag
				FROM 
						OCR_Upload_Log OUL
						INNER JOIN OCR_Template_Settings OTS
						ON OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID 
						AND OTS.Deleted = 0
					
				WHERE 
						OUL.Deleted = 0	AND	
						(OUL.OCR_Step = '1') /* OR OCR_Step = '2.CF_Error' */
				ORDER BY
						OUL.OCR_Upload_Date DESC  		
			</cfquery>

			<!--- <cfquery name="qGetOCRUploadSettings" datasource="#application.datasource#">
				SELECT * 
					FROM OCR_Template_Settings 
				WHERE
					Deleted = 0
				ORDER BY Search_Order
			</cfquery> --->

		<!--- 
			A) RUN THE LOGIC TO PICK THE TEMPLATE BY DOING A STRING MATCHING
			B) MOVE THE FOLDER TO THE CORRESPONDING LOCATION AFTER PICKING THE TEMPLATE
			C) UPDATE THE OCR_UPLOAD_LOG FOR THE FIELDS: 
				[OCR_Template_Settings_ID], -- The one that matched from the OCR_Template_Settings
				[Source_Template], 			-- The Template that was picked(desc)
				[OCR_Step], 				-- Update to 3 [will be updated to 2 once the row is fetched and we start doing the check]
				[OCR_Upload_Status]			-- @start will be "Text reader is analysing file Type"  
											   2nd update: "Processing file for #Source_Template#"
											   @end update to "Extracting text for #Source_Template#"
		 --->
		  
		<!--- <cfdump var="#qGetOCRUploadRecords#" />
		<cfdump var="#qGetOCRUploadSettings#" /> --->
			
			<!--- <cfset srcFile  = "\\webstage8\CIA_OCR_Claims\File_Landing\Processed\test1.pdf" />
			<cfset destFile = "\\webstage8\CIA_OCR_Claims\GFS_US\Preprocessed_PDF\" /> 
			 --->
			<!--- START: STRING MATCHING LOGIC TO PICK THE TEMPLATE --->
		 
			<cfloop query = "qGetOCRUploadRecords">
				<cfset qGetOCRUploadSettings = OCRSettingsManager.getOCRSettings(OCRTemplateSettingsID = qGetOCRUploadRecords.OCR_Template_Settings_ID,BBClaimSourceXrefID = qGetOCRUploadRecords.BB_Claim_Source_Xref_ID) />
				<cfset OCRTemplateSettingsID_Matched = 0 />
				<cfloop query = "qGetOCRUploadSettings">
		 			
		<!--- 			<cfquery name="updateOCRUploadLog" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
								SET 
									OCR_Step			= 2,	
									OCR_Upload_Status 	= 'Analyzing the file for Picking Template'
							WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
						</cfquery> --->
					
					<!--- <cfset txtFile = qGetOCRUploadSettings.OCR_File_Landing_Path & "\Raw_Text\" & Replace(qGetOCRUploadRecords.File_Name,".pdf",".txt") />  --->
					<cfif ((qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY") OR (qGetOCRUploadSettings.Is_Double_Processing_On EQ 1 AND qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER" ) OR
							   (qGetOCRUploadSettings.Special_Processing_Flag EQ "1" AND qGetOCRUploadRecords.OCR_Sub_Step EQ '2')
							   )>
								<cfif (qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER")>
									<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\" & qGetOCRUploadRecords.File_Name />
								<cfelseif (qGetOCRUploadSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER")>
									<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\ABBYY\" & qGetOCRUploadRecords.File_Name />
								<cfelse>	
									<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\" & ReplaceNoCase(qGetOCRUploadRecords.File_Name,".pdf",".txt") />
								</cfif>
						 
						<cfif FileExists(txtFile)>
							<!--- <cffile  
				    			action 		= "read"  
				    			file 		= "#txtFile#"
				    			variable 	= "strFileContent" 
				    		> --->
							<cfset moveToNextSetting = 0 /> 
							<cfset match = 0 />
							<!--- Loop oper each search word and make sure they are in the file content, if not move to the next setting --->
							<!--- <cfloop index = "strWord" list = "#qGetOCRUploadSettings.Search_String#" delimiters = "|"> 
				   				<cfset match = FindNoCase(Trim(strWord),strFileContent)>
								<cfif match EQ 0>
									<cfset moveToNextSetting = 1 />
									<cfbreak/>
								</cfif>
							</cfloop>	 --->
						
							<!---moveToNextSetting =<cfdump var="#moveToNextSetting#" /><br>	 
								moveToNextSetting = 0 ==> all the search  string matched  --->
							<cfif (moveToNextSetting EQ 0)>
								<!--- UPDATE THE OCR_Upload_Log to have this setting --->
								<cfset srcFile = qGetOCRUploadSettings.OCR_File_PostProcess_Path & "\" & qGetOCRUploadRecords.File_Name />
								<cfif (qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER")>
									<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\" & qGetOCRUploadRecords.File_Name />
								<cfelseif (qGetOCRUploadSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER")>	
									<cfset srcFile = qGetOCRUploadSettings.OCR_File_PostProcess_Path & "\ABBYY\" & qGetOCRUploadRecords.File_Name />
									<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\ABBYY\" & qGetOCRUploadRecords.File_Name />						
								<cfelse>
									<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\" & ReplaceNoCase(qGetOCRUploadRecords.File_Name,".pdf",".txt") /> 
								</cfif>
								
								<cfif (FileExists(srcFile) AND FileExists(txtFile))>
										<!--- <cffile action="move" source="#srcTxtFile#" destination="#FileDest#"> --->
					  					<cfif (qGetOCRUploadSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER")>
											<cfset srcMainFile = qGetOCRUploadSettings.OCR_File_PreProcess_Path & "\" & qGetOCRUploadRecords.File_Name />
											<cfif FileExists(srcMainFile)>
												<cfset archiveLocation = qGetOCRUploadExtracted.OCR_File_PostProcess_Path & "\archive" />
												moving 1:
												<cffile action="move" source="#srcMainFile#" destination="#archiveLocation#">
												<!--- <cffile action = "rename" source = "#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#fileName#" destination = "#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#newfileName#" > --->
											</cfif>	
					 						<cffile action="copy" source="#txtFile#" destination="#qGetOCRUploadSettings.OCR_File_PreProcess_Path#">
										</cfif>
					 
										<cfquery name="updateOCRUploadLog" datasource="#application.datasource#">
											UPDATE OCR_Upload_Log 
												SET 
													OCR_Step				= '2',
													Updated_Date 			= getDate(),
													<cfif (qGetOCRUploadSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER")>
														OCR_Sub_Step = '3',
														OCR_Sub_Step_Description = 'Pass 3: setting to 3 to be picked by docparser 2nd time', 
													</cfif>
													/* OCR_Template_Settings_ID = #qGetOCRUploadSettings.OCR_Template_Settings_ID#, */
													OCR_Upload_Status = 'Template matched and file converted to Text. Template Used:#qGetOCRUploadSettings.OCR_Template_Name#'
											WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
										</cfquery>
										<cfset OCRTemplateSettingsID_Matched = qGetOCRUploadSettings.OCR_Template_Settings_ID />
										<!--- <cfset OCRTemplateSettingsID_Matched = 1 /> --->
									<cfbreak />
								<cfelse>
										<cfset useLakebaseForupdateOCRUploadLogStatusError1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForupdateOCRUploadLogStatusError1>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#qGetOCRUploadRecords.OCR_Upload_ID#"
			},
			{
				"ocr_step" = "1",
				"debug_dev_status" = "File is missing #srcFile#",
				"updated_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateOCRUploadLogStatusError1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLogStatusError1>
<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
											UPDATE OCR_Upload_Log 
												SET 
													OCR_Step				= '1',	
													Debug_Dev_Status = 'File is missing #srcFile#',
													Updated_Date = getDate()
											WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
										</cfquery>
</cfif>	
								</cfif>	 <!--- <cfif FileExists(srcTxtFile)> --->
							</cfif> <!--- <cfif (moveToNextSetting EQ 0)> --->
						</cfif>	<!--- <cfif FileExists(txtFile)> --->
					<cfelseif (qGetOCRUploadSettings.OCR_Reader_Name EQ "EXCELCSV")>
						<!--- ASSUMING THERE WILL BE ONLY ONE TEMPALTE THAT WILL EXACTLY MATCH THE PFG AND EXCEL FORMAT FOR NOW --->
						<cfquery name="updateOCRUploadLog" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
							SET 
								OCR_Step				= '2',
								Updated_Date 			= getDate(),
								/* OCR_Template_Settings_ID = #qGetOCRUploadSettings.OCR_Template_Settings_ID#, */
								OCR_Upload_Status = 'Setting the ocr_step to 2 to go to next step.'
							WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
						</cfquery>
						<cfset OCRTemplateSettingsID_Matched  = 1 />
					<cfelseif ((qGetOCRUploadSettings.OCR_Reader_Name EQ "DOCPARSER") OR 
								(qGetOCRUploadSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER" AND qGetOCRUploadRecords.OCR_Sub_Step EQ '0') OR
								(qGetOCRUploadSettings.OCR_Reader_Name EQ "EXCELCFPARSE") OR 
								(qGetOCRUploadSettings.Is_Double_Processing_On EQ 1 AND qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER") 
							   )>
						<!--- ASSUMING THERE WILL BE ONLY ONE TEMPALTE THAT WILL EXACTLY MATCH THE PFG AND EXCEL FORMAT FOR NOW --->
						<cfquery name="updateOCRUploadLog" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
							SET 
								OCR_Step				= '2',
								Updated_Date 			= getDate(),
								<cfif qGetOCRUploadSettings.Special_Processing_Flag AND qGetOCRUploadRecords.OCR_Sub_Step EQ '0'>
									OCR_Sub_Step = '1',
									OCR_Sub_Step_Description = 'Pass 1: setting to 1 to be picked by docparser 1st time', 
								</cfif>
							/*	OCR_Template_Settings_ID = #qGetOCRUploadSettings.OCR_Template_Settings_ID#, */
								OCR_Upload_Status = 'Setting the ocr_step to 2 to go to next step.'
							WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
						</cfquery>
						<cfset OCRTemplateSettingsID_Matched  = 1 />	
					</cfif>	<!--- END: qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER" ---->
				</cfloop> 	<!--- <cfloop query = "qGetOCRUploadSettings"> --->
				<!--- if OCRTemplateSettingsID_Matched is equal to 1 then it means that the other files can be deleted from the duplicate locations --->
				<!--- <cfif OCRTemplateSettingsID_Matched EQ 0>
					<cfloop query = "qGetOCRUploadSettings">
						<cfif (OCRTemplateSettingsID_Matched NEQ qGetOCRUploadSettings.OCR_Template_Settings_ID AND qGetOCRUploadSettings.OCR_Reader_Name EQ "ABBYY")>  
							<!--- Remove all the duplicate pdf and txt files that were copied ---> 
							<cfset srcFile = qGetOCRUploadSettings.OCR_File_PostProcess_Path & "\" & qGetOCRUploadRecords.File_Name />
							<cfset txtFile = qGetOCRUploadSettings.OCR_File_PostProcess_Txt_Path & "\" & Replace(qGetOCRUploadRecords.File_Name,".pdf",".txt") /> 
							<cfif FileExists(srcFile)>
								<cffile action="delete" file="#srcFile#" />
							</cfif>
							<cfif FileExists(txtFile)>
								<cffile action="delete" file="#txtFile#" />
							</cfif>
						</cfif>
					</cfloop>
				<cfelse>	
					<!--- None of the setting template matched the selected source  --->
					<cfif ((qGetOCRUploadRecords.ProcessTries GT 5) AND (qGetOCRUploadRecords.OCR_Reader_Name NEQ "DOCPARSER" AND qGetOCRUploadRecords.OCR_Reader_Name NEQ "EXCELCSV"))>
						<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
								SET 
									OCR_Step = '2.CF_Error',
									OCR_Upload_Status = 'Template pick - Failed',
									Debug_Dev_Status = 'No matching templates were found to match Upd- CF',
									ProcessTries = ProcessTries + 1
							WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
						</cfquery>	
					<cfelseif (qGetOCRUploadRecords.OCR_Reader_Name NEQ "DOCPARSER" OR qGetOCRUploadRecords.OCR_Reader_Name NEQ "EXCELCSV")>
						<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
								SET 
									OCR_Step = '1',	
									OCR_Upload_Status = 'Trying to pick Template...',
									Debug_Dev_Status = 'No matching templates found yet, trying to match... - In CF',
									ProcessTries = ProcessTries + 1							
							WHERE OCR_Upload_ID = '#qGetOCRUploadRecords.OCR_Upload_ID#'
						</cfquery>	
					</cfif>
					
				</cfif> ---> <!--- <cfif OCRTemplateSettingsID_Matched NEQ 0> --->
			</cfloop> <!--- <cfloop query = "qGetOCRUploadRecords"> --->
		<!--- END: STRING MATCHING LOGIC TO PICK THE TEMPLATE --->	
		<cfcatch>
			cfcatch.message1:<cfdump var="#cfcatch.Message#"/><br>
			cfcatch.Detail11:<cfdump var="#cfcatch.Detail#"/><br> 
			<cfscript>
			 	WriteLog(type="Error", file="OCR_Error", text="[#cfcatch.type#] #cfcatch.message#"); 
			</cfscript>
		</cfcatch>
		</cftry>

		<!---------------------------------------------------------------------------------------------------->
		<!-------------------------------- PHASE 2 for records in OCR_Step = 2 ------------------------------->
		<!---------------------------------------------------------------------------------------------------->
		<br>
		<br>
		<h2>PHASE 2: </h2>
		<!--- <cftry>  --->

			<!--- 
					Go through the second pass for the records that have been already processed 
					by the Hot folder and ready for SQL Processing.
			--->
			
			<cfquery name="qGetOCRUploadExtracted" datasource="#application.datasource#">
				SELECT 	OUL.OCR_Upload_ID,
						OUL.File_Name,
						OUL.Source_Template,
						OUL.Created_User_ID,
						OUL.OCR_Upload_Date,
						OUL.OCR_Upload_Status,
						OUL.Debug_Dev_Status,
						OUL.OCR_Step,
						OUL.upload_type,
						OUL.Document_ID,
						OUL.Document_ID_2,
						OUL.ProcessTries,
						OUL.Pages_Extracted,
						OUL.OCR_Sub_Step,
						OUL.OCR_Sub_Step_Description,
						OTS.OCR_Template_Settings_ID,	
						OTS.OCR_Code,
						OTS.OCR_Template_Name, 
						OTS.OCR_File_Landing_Path,
						OTS.OCR_File_Landing_Path_Processed,
						OTS.OCR_File_PreProcess_Path,
						OTS.OCR_File_PostProcess_Path,
						OTS.OCR_File_PostProcess_Txt_Path,
						OTS.DB_File_Preprocess_Path,
						OTS.BB_Claim_Source_XREF_ID,
						OTS.DB_OCR_Source_Code,
						OTS.Search_String,
						OTS.IS_OCR_Required,
						OTS.OCR_Reader_Name,
						OTS.Parser_ID,
						OTS.Source_Code,
						OTS.Account_ID,
						OTS.Is_Double_Processing_On,	
						OTS.Special_Processing_Flag,
						OTS.OCR_Template_Description,
						U1.Name_First,
						U1.Name_Last,
						U1.User_Code
				FROM 
						OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				INNER JOIN _Users U1 ON U1.User_ID = OUL.Created_User_ID
				WHERE 
						OUL.Deleted = 0	AND	
						OUL.OCR_Step = '2' AND
						OTS.Deleted = 0
				ORDER BY
						OUL.OCR_Upload_Date DESC 		
			</cfquery>

			<cfloop query = "qGetOCRUploadExtracted">
				<!----*****************************************   ABBYY   *****************************************---->		
				<cfif (qGetOCRUploadExtracted.IS_OCR_Required EQ 1 AND qGetOCRUploadExtracted.OCR_Reader_Name EQ "ABBYY")>
					<cfset srcPDFFile = qGetOCRUploadExtracted.OCR_File_PostProcess_Path & "\" & qGetOCRUploadExtracted.File_Name />
					<cfset srcTxtFile =	qGetOCRUploadExtracted.OCR_File_PostProcess_Txt_Path & "\" & ReplaceNoCase(qGetOCRUploadExtracted.File_Name,".pdf",".txt") /> 
					<cfset archiveLocation = qGetOCRUploadExtracted.OCR_File_PostProcess_Path & "\archive" />
					<!--- Check if both the pdf and the text files exist in the postprocess path before copying them to the DB path --->
					<cfset DBDest = qGetOCRUploadExtracted.DB_File_Preprocess_Path />

					<cfif FileExists(srcPDFFile) AND FileExists(srcTxtFile)>
			 			<cffile action="copy" source="#srcPDFFile#" destination="#DBDest#">
						<cffile action="copy" source="#srcTxtFile#" destination="#DBDest#">
						<!--- 
							When the OCR_Step is set to 4 it means that the steps to convert 
							into text file is complete and the SQL Process should kick-in.
						 --->
						<cfset useLakebaseForupdateOCRUploadLogStatus4 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForupdateOCRUploadLogStatus4>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#qGetOCRUploadExtracted.OCR_Upload_ID#"
			},
			{
				"ocr_step" = "4",
				"ocr_upload_status" = "Transferred file to DB processing",
				"debug_dev_status" = "Transferred file to DB processing. DBLocation ""#DBDest#""",
				"updated_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateOCRUploadLogStatus4 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLogStatus4>
<cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
								UPDATE OCR_Upload_Log 
									SET 
										OCR_Step = '4',
										OCR_Upload_Status = 'Transferred file to DB processing',
										Debug_Dev_Status = 'Transferred file to DB processing. DBLocation "#DBDest#"',
										Updated_Date = getDate()
								WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>
</cfif>
						<!--- After copying the file Move it to archive location --->
						
						<cffile action="move" source="#srcPDFFile#" destination="#archiveLocation#">
						<cffile action="move" source="#srcTxtFile#" destination="#archiveLocation#">
							
					<cfelse>
						<cfquery name="updateOCRUploadLogStatusError2" datasource="#application.datasource#">
							UPDATE 
								OCR_Upload_Log 
							SET 
								Debug_Dev_Status = 'File is missing "#srcPDFFile#" and "#srcTxtFile#" trying to move the file to "#DBDest#". Probably it is still not being picked up by the Hotfolder'
							WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>	
					</cfif>
				<!----*****************************************   DOCPARSER   *****************************************---->	
				<cfelseif ((qGetOCRUploadExtracted.IS_OCR_Required EQ 1 AND qGetOCRUploadExtracted.OCR_Reader_Name EQ "DOCPARSER") OR 
							(qGetOCRUploadExtracted.Is_Double_Processing_On EQ 1 AND qGetOCRUploadExtracted.OCR_Reader_Name EQ "ABBYY&DOCPARSER") OR
							(qGetOCRUploadExtracted.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER" AND  (qGetOCRUploadExtracted.OCR_Sub_Step EQ '1' OR qGetOCRUploadExtracted.OCR_Sub_Step EQ '3' OR qGetOCRUploadExtracted.OCR_Sub_Step EQ '4' ))
							)>
				in DocParser
					<cfinclude template="incDocParser.cfm" /> 
				<!----*****************************************   EXCEL   *****************************************---->				
				<cfelseif (qGetOCRUploadExtracted.OCR_Reader_Name EQ "EXCELCSV")>		
				IN excel
					<cfset srcPDFFile 		= qGetOCRUploadExtracted.OCR_File_PreProcess_Path & "\" & qGetOCRUploadExtracted.File_Name />
					<cfset DBDest		 	= qGetOCRUploadExtracted.DB_File_Preprocess_Path />
					<cfset archiveLocation 	= qGetOCRUploadExtracted.OCR_File_PostProcess_Path & "\archive" />
					<cfif FileExists(srcPDFFile) AND DirectoryExists(DBDest)>
			 			<cffile action="copy" source="#srcPDFFile#" destination="#DBDest#">
						<cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
								UPDATE OCR_Upload_Log 
									SET 
										OCR_Step = '4',
										OCR_Upload_Status = 'Transferred file to DB processing',
										Debug_Dev_Status = 'Transferred file to DB processing. DBLocation "#DBDest#"',
										DB_Input_FileName = '#qGetOCRUploadExtracted.File_Name#',
										Updated_Date = getDate()
								WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>
						<cffile action="move" source="#srcPDFFile#" destination="#archiveLocation#">
					</cfif>	
				<cfelseif qGetOCRUploadExtracted.OCR_Reader_Name EQ "EXCELCFPARSE" >
					IN EXCELCFPARSE <cfoutput>#qGetOCRUploadExtracted.File_Name# :: #now()#</cfoutput><br>
					<cfquery name="q"  dbtype="query" >
						SELECT * FROM qGetOCRUploadExtracted
						WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
					</cfquery>
					<cfscript>
						OCRExcelParser  = CreateObject("component","components.Billback.OCRExcelParser");
						srcFile =  '#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#qGetOCRUploadExtracted.File_Name#';  //'VAR0511295_CDC_LoL.xlsx'; // 'VAR538064_CDC_Kraft.xlsx';//'525563.XLS';  525563_POI
						a = OCRExcelParser.parse(srcFile,q);
						OCRUploadDAO  = CreateObject("component","components.Billback.OCRUploadDAO");
						if(arraylen(a) == 0){
							//this means it was converted and we will get it on the next pass
							writeoutput('<br> CONVERTED: #qGetOCRUploadExtracted.File_Name# <br>');
							break; // WE NEED TO BREAK In case there is a second file that needs libreoffice conversion.  2 instances will cause an issue
						}
						else if(arraylen(a) > 1 || IsSimpleValue(a[1]) == false){
							OCRUploadDAO.updUploadLogStatus('4','Transferred data to DB processing','#arraylen(a)# rows sent','#qGetOCRUploadExtracted.OCR_Upload_ID#','#qGetOCRUploadExtracted.File_Name#');
						}
						else{
							OCRUploadDAO.updUploadLogStatus('2.CF_ParseError','We Have Problems','error: #a[1]#','#qGetOCRUploadExtracted.OCR_Upload_ID#');
						}
						
					</cfscript>
				<cfelseif qGetOCRUploadExtracted.OCR_Reader_Name EQ "">		
					<cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
						UPDATE OCR_Upload_Log 
						SET 
							OCR_Step = '4',
							OCR_Upload_Status = 'Transferred file to DB processing',
							Debug_Dev_Status = 'Transferred file to DB processing.',
							Updated_Date = getDate()
						WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
					</cfquery>
				</cfif>	<!--- 	<cfif qGetOCRUploadExtracted.OCR_Reader_Name EQ "ABBYY">		 --->	
			</cfloop>
		SUCCESS!!
		<!--- <cfcatch> 
		  cfcatch.message2:<cfdump var="#cfcatch.Message#"/><br>
			cfcatch.Detail2:<cfdump var="#cfcatch.Detail#"/><br> 
			<cfscript>
			 	WriteLog(type="Error", file="OCR_Error2.log", text="[#cfcatch.type#] #cfcatch.message#"); 
			</cfscript>
		</cfcatch>
		</cftry> --->

		<!---------------------------------------------------------------------------------------------------->
		<!---- PHASE 3: ARCHIVE THE FILES THAT HAVE BEEN DELETED OR OCR_Step NOT IN ('1','2','2.CF_Error') --->
		<!---------------------------------------------------------------------------------------------------->
		<br>
		<br>
		<h2>PHASE 3: </h2>
		<cfquery name="qGetOCRUploadArchive" datasource="#application.datasource#">
				SELECT 	OUL.OCR_Upload_ID,
						OUL.File_Name,
						OUL.Source_Template,
						OUL.Created_User_ID,
						OUL.OCR_Upload_Date,
						OUL.OCR_Upload_Status,
						OUL.Debug_Dev_Status,
						OUL.OCR_Step,
						OUL.upload_type,
						OTS.OCR_Template_Settings_ID,	
						OTS.OCR_Template_Name, 
						OTS.OCR_File_Landing_Path,
						OTS.OCR_File_Landing_Path_Processed,
						OTS.OCR_File_PreProcess_Path,
						OTS.OCR_File_PostProcess_Path,
						OTS.OCR_File_PostProcess_Txt_Path,
						OTS.DB_File_Preprocess_Path, 
						OTS.OCR_Reader_Name	
				FROM OCR_Upload_Log OUL
				LEFT JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID	 = OUL.OCR_Template_Settings_ID
				WHERE OUL.OCR_Step NOT IN ('1','2','3') /* '2.CF_Error', */
					AND ( DATEDIFF(minute, OUL.Updated_Date, GETDATE()) > 30)
					AND ( DATEDIFF(Day, OUL.Updated_Date, GETDATE()) < 2)
					AND NOT EXISTS (SELECT OCR_Upload_ID FROM OCR_Upload_Log L2 WHERE L2.OCR_Upload_ID != OUL.OCR_Upload_ID AND L2.DB_Input_FileName = OUL.DB_Input_FileName AND L2.OCR_Step IN  ('1','2','3') )
				ORDER BY OUL.OCR_Upload_ID DESC  	
			</cfquery>
		<cfoutput>
			<cfloop query = "qGetOCRUploadArchive">
				<cfset srcPrePDFFile	= qGetOCRUploadArchive.OCR_File_PreProcess_Path & "\" & qGetOCRUploadArchive.File_Name />
				<cfset srcPostPDFFile 	= qGetOCRUploadArchive.OCR_File_PostProcess_Path & "\" & qGetOCRUploadArchive.File_Name />		
				
				<cfif (qGetOCRUploadArchive.OCR_Reader_Name EQ "ABBYY&DOCPARSER")>
					<cfset srcPostPDFFile 	= qGetOCRUploadArchive.OCR_File_PostProcess_Path & "\" & qGetOCRUploadArchive.File_Name />
					<cfset srcTxtFile 		=	qGetOCRUploadArchive.OCR_File_PostProcess_Txt_Path & "\" & qGetOCRUploadArchive.File_Name /> 
				<cfelse>	
					<cfset srcPostPDFFile 	= qGetOCRUploadArchive.OCR_File_PostProcess_Path & "\" & qGetOCRUploadArchive.File_Name />
					<cfset srcTxtFile 		=	qGetOCRUploadArchive.OCR_File_PostProcess_Txt_Path & "\" & ReplaceNoCase(qGetOCRUploadArchive.File_Name,".pdf",".txt") /> 
				</cfif>
				
				<cfset archiveLocation = qGetOCRUploadArchive.OCR_File_PostProcess_Path & "\archive" />
				<cfif FileExists(srcPrePDFFile)>
					<cffile action="move" source="#srcPrePDFFile#" destination="#archiveLocation#" nameconflict="OVERWRITE">
					File "#srcPrePDFFile#" was moved to #archiveLocation#<br>
				</cfif>
				<cfif FileExists(srcPostPDFFile)>
					<cffile action="move" source="#srcPostPDFFile#" destination="#archiveLocation#" nameconflict="OVERWRITE">
					File "#srcPostPDFFile#" was moved to #archiveLocation#<br>
				</cfif>
				<cfif FileExists(srcTxtFile)>
					<cffile action="move" source="#srcTxtFile#" destination="#archiveLocation#" nameconflict="OVERWRITE">
					File "#srcTxtFile#" was moved to #archiveLocation#<br>
				</cfif>
			</cfloop>
		</cfoutput>		


		<!---------------------------------------------------------------------------------------------------->
		<!---- PHASE 4: UPDATE THE OCR_Step TO 12  --->
		<!---------------------------------------------------------------------------------------------------->
		<br>
		<br>
		<h2>PHASE 4: </h2>
			
			<cfquery name="qGetOCRUploadArchive" datasource="#application.datasource#">
				/* SELECT OUL.ocr_step,* FROM OCR_Upload_Log OUL
				INNER JOIN BB_upload_log BUL ON BUL.upload_id = OUL.BB_Upload_ID
				WHERE BUL.upload_status = 'CREATION COMPLETE'
				*/
				
				UPDATE  OUL SET OUL.OCR_Step = '12',
				OUL.OCR_Upload_Status = 'Creation Complete',
				OUL.Debug_Dev_Status = 'Creation Complete'
				FROM dbo.OCR_Upload_Log OUL
				INNER JOIN BB_upload_log BUL ON BUL.upload_id = OUL.BB_Upload_ID
				WHERE BUL.upload_status = 'Creation Complete'
			</cfquery> 
		SUCCESS!!


		<!---------------------------------------------------------------------------------------------------->
		<!---- PHASE 5: ABBYY Timeout/Errors  --->
		<!---------------------------------------------------------------------------------------------------->	
		<h2>PHASE 5: </h2>
		ABBYY Timeout/Errors
		<!--- 			
				OCR_Step	=  '1',	
				OCR_Sub_Step = '2',
		 ---> 
		 <cfquery name="qGetOCRUploadABBYYStuck" datasource="#application.datasource#">
				SELECT 	OUL.OCR_Upload_ID,
						OUL.File_Name,
						OUL.Source_Template,
						OUL.Created_User_ID,
						OUL.OCR_Upload_Date,
						OUL.OCR_Upload_Status,
						OUL.Debug_Dev_Status,
						OUL.OCR_Step,
						OUL.upload_type,
						OUL.Document_ID,
						OUL.Document_ID_2,
						OUL.ProcessTries,
						OUL.Pages_Extracted,
						OUL.OCR_Sub_Step,
						OUL.OCR_Sub_Step_Description,
						OTS.OCR_Template_Settings_ID,	
						OTS.OCR_Code,
						OTS.OCR_Template_Name, 
						OTS.OCR_File_Landing_Path,
						OTS.OCR_File_Landing_Path_Processed,
						OTS.OCR_File_PreProcess_Path,
						OTS.OCR_File_PostProcess_Path,
						OTS.OCR_File_PostProcess_Txt_Path,
						OTS.DB_File_Preprocess_Path,
						OTS.BB_Claim_Source_XREF_ID,
						OTS.DB_OCR_Source_Code,
						OTS.Search_String,
						OTS.IS_OCR_Required,
						OTS.OCR_Reader_Name,
						OTS.Parser_ID,
						OTS.Source_Code,
						OTS.Account_ID,
						OTS.Is_Double_Processing_On,	
						OTS.Special_Processing_Flag,
						DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins_Since_Start,
						DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins_Since_Last_Update,
						OTS.OCR_Template_Description,
						U1.Name_First,
						U1.Name_Last,
						U1.User_Code
				FROM 
						OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				INNER JOIN _Users U1 ON U1.User_ID = OUL.Created_User_ID
				WHERE 
						OUL.Deleted = 0	AND	
						OUL.OCR_Step	=  '1' AND 
						OUL.OCR_Sub_Step = '2' AND 
						OTS.Deleted = 0
						AND ( DATEDIFF(minute, OUL.Updated_Date, GETDATE()) > #varTimeoutSinceUpdate#)
						/* OR DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) > #varTimeoutSinceCreate# */

				ORDER BY
						OUL.OCR_Upload_Date DESC 
				</cfquery>
		No. of rows affected: <cfdump var="#qGetOCRUploadABBYYStuck.RecordCount#" />
				<cfloop query = "qGetOCRUploadABBYYStuck">
					<cfquery name="updateOCRUploadLogStatus_x2" datasource="#application.datasource#">
						UPDATE OCR_Upload_Log 
						SET 
							OCR_Step = '2.CF_Error',
							OCR_Upload_Status = '1. Check if the ABBYYAdmin is logged in.   2. check for hotfolder job is running.  3.Check if the ABBYY page limit has exceeded.',
							Debug_Dev_Status = 'ABBYY timeout as the time exceeded #varTimeoutSinceUpdate# mins waiting in the source status. Pending for #qGetOCRUploadABBYYStuck.Pending_Mins_Since_Start# mins since uploading.Pending for #qGetOCRUploadABBYYStuck.Pending_Mins_Since_Last_Update# mins since last update.OCR_File_Mover.cfm - 637',
							Updated_Date = getDate(),
							Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
						WHERE 
							OCR_Upload_ID = '#qGetOCRUploadABBYYStuck.OCR_Upload_ID#'
					</cfquery>
					<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error -  '#qGetOCRUploadABBYYStuck.Source_Code#' -  #qGetOCRUploadABBYYStuck.OCR_Template_Description# on '#qDBName.DBName#' Failed for Upload ID:#qGetOCRUploadABBYYStuck.OCR_Upload_ID# at SOURCE">
						Please see what needs to be fixed:<br><br>
						<a href="#uploadInfoSiteURL##qGetOCRUploadABBYYStuck.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadABBYYStuck.OCR_Upload_ID#</a><br><br>
					</cfmail>
				</cfloop>		
				
		<!---------------------------------------------------------------------------------------------------->
		<!---- PHASE 6: TIMEOUT FOR INVOICE AND ALIAS --->
		<!---- 
				3	INVOICE: ()
				4	INVOICE: ()
				4.1	INVOICE: ()
				5	INVOICE: ()
				5.1	AMOUNT: ()
				8	ALIAS: ()
				 
		---->
		<!---------------------------------------------------------------------------------------------------->	
		<h2>PHASE 6: </h2>
		TIMEOUT FOR INVOICE AND ALIAS


		<cfquery name="qGetOCRUploadtTimeoutInvAli" datasource="#application.datasource#">
				SELECT 	OUL.OCR_Upload_ID,
						OUL.File_Name,
						OUL.Source_Template,
						OUL.Created_User_ID,
						OUL.OCR_Upload_Date,
						OUL.OCR_Upload_Status,
						OUL.Debug_Dev_Status,
						OUL.OCR_Step,
						OUL.upload_type,
						OUL.Document_ID,
						OUL.Document_ID_2,
						OUL.ProcessTries,
						OUL.Pages_Extracted,
						OUL.OCR_Sub_Step,
						OUL.OCR_Sub_Step_Description,
						OTS.OCR_Template_Settings_ID,	
						OTS.OCR_Code,
						OTS.OCR_Template_Name, 
						OTS.OCR_File_Landing_Path,
						OTS.OCR_File_Landing_Path_Processed,
						OTS.OCR_File_PreProcess_Path,
						OTS.OCR_File_PostProcess_Path,
						OTS.OCR_File_PostProcess_Txt_Path,
						OTS.DB_File_Preprocess_Path,
						OTS.BB_Claim_Source_XREF_ID,
						OTS.DB_OCR_Source_Code,
						OTS.Search_String,
						OTS.IS_OCR_Required,
						OTS.OCR_Reader_Name,
						OTS.Parser_ID,
						OTS.Source_Code,
						OTS.Account_ID,
						OTS.Is_Double_Processing_On,	
						OTS.Special_Processing_Flag,
						DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins_Since_Start,
						DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins_Since_Last_Update,
						OTS.OCR_Template_Description,
						U1.Name_First,
						U1.Name_Last,
						U1.User_Code
				FROM 
						OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				INNER JOIN _Users U1 ON U1.User_ID = OUL.Created_User_ID
				WHERE 
						OUL.Deleted = 0	AND	
						OUL.OCR_Step IN  ('3','4','4.1','5','8') AND
						OTS.Deleted = 0 AND
						(DATEDIFF(minute, OUL.Updated_Date, GETDATE()) > #varTimeoutSinceUpdate#)
				ORDER BY
						OUL.OCR_Upload_Date DESC 
				</cfquery>
		<!--- <cfdump var="#qGetOCRUploadtTimeoutInvAliCre#" /> --->

				<cfloop query = "qGetOCRUploadtTimeoutInvAli">
							<cfquery name="updateOCRUploadLogStatus_x3" datasource="#application.datasource#">
								UPDATE 
									OCR_Upload_Log 
								SET 
									<cfif (qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "3" OR qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "4" OR qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "4.1" OR qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "5")>
										OCR_Step = '6',
										OCR_Upload_Status = 'Please check the DB stored procedures that sets the status to 3/4/4.1/5 for solving this issue. Please contact a DB dev for this issue.',
										Debug_Dev_Status = 'Timeout in Invoice as the time exceeded the waiting time in the Invoice status. Pending for #qGetOCRUploadtTimeoutInvAli.Pending_Mins_Since_Start# mins since uploading.Pending for #qGetOCRUploadtTimeoutInvAli.Pending_Mins_Since_Last_Update# mins since last update. OCR_File_Mover.cfm - 732',
										Updated_Date = getDate(),
										Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
									<cfelseif (qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "8")>
										OCR_Step = '9.Time_Out',
										OCR_Upload_Status = 'Please check the DB stored procedures that sets the status to 8 for solving this issue. Please contact a DB dev for this issue.',
										Debug_Dev_Status = 'Timeout in Alias, as the time exceeded the waiting time in the Alias status. Pending for #qGetOCRUploadtTimeoutInvAli.Pending_Mins_Since_Start# mins since uploading.Pending for #qGetOCRUploadtTimeoutInvAli.Pending_Mins_Since_Last_Update# mins since last update. OCR_File_Mover.cfm - 738',
										Updated_Date = getDate(),
										Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
									</cfif>
								WHERE 
									OCR_Upload_ID = '#qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID#'
							</cfquery>
							
							<cfif (qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "3" OR qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "4" OR qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "4.1" OR qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "5")>					
								<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadtTimeoutInvAli.Source_Code#' -  #qGetOCRUploadtTimeoutInvAli.OCR_Template_Description# on '#qDBName.DBName#' Failed for Upload ID:#qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID# at INVOICE">
								Please see what needs to be fixed:<br><br>
								<a href="#uploadInfoSiteURL##qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID#</a><br><br>
								</cfmail>
							<cfelseif (qGetOCRUploadtTimeoutInvAli.OCR_Step EQ "8")>
								<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadtTimeoutInvAli.Source_Code#' -  #qGetOCRUploadtTimeoutInvAli.OCR_Template_Description# on '#qDBName.DBName#' Failed for Upload ID:#qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID# at ALIAS">
								Please see what needs to be fixed:<br><br>
								<a href="#uploadInfoSiteURL##qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadtTimeoutInvAli.OCR_Upload_ID#</a><br><br>
								</cfmail>
							
							</cfif>
				</cfloop>	
		<!---------------------------------------------------------------------------------------------------->
		<!---- PHASE 7: TIMEOUT FOR CREATED  --->
		<!---- 
				11	CREATED: ()
		---->
		<!---------------------------------------------------------------------------------------------------->	
		<h2>PHASE 7: </h2>
		TIMEOUT CREATED

		<cfquery name="qGetJobInfo" datasource="#application.datasource#">
			DECLARE @dbName NVARCHAR(50),
			@SP_Scheduler_name UNIQUEIDENTIFIER,
			@SP_Name NVARCHAR(250)
			
			SET @dbName = DB_NAME() /* (SELECT TOP 1 TABLE_CATALOG  FROM INFORMATION_SCHEMA.TABLES) */
			-- SELECT @SP_Scheduler_name = job_id FROM msdb..SYSjobs WHERE name = 'BA_'+ @dbName +'_Billback_Upload_Scheduler'
			SELECT @SP_Name = 'BA_'+ @dbName +'_Billback_Upload_Scheduler'
			-- SELECT @SP_Scheduler_name  AS Scheduler_name
			-- SELECT @SP_Name AS sp_Name
			 
			SELECT
			     'Job ID' = j.job_id
			    ,'Job Name' = j.name
			    ,'Job Enabled' = CASE j.enabled
			            WHEN 1 THEN 'Yes'
			            ELSE 'No'
			        END
			    ,'Frequency' = CASE s.freq_type 
			        WHEN 1 THEN 'One time only'
			        WHEN 4 THEN 'Daily'
			        WHEN 8 THEN 'Weekly'
			        WHEN 16 THEN 'Monthly'
			        WHEN 32 THEN 'Monthly, relative to freq_interval'
			        WHEN 64 THEN 'Runs when the SQL Server Agent service starts'
			        WHEN 128 THEN 'Runs when the computer is idle'
			    END
			    ,'Interval' = CASE s.freq_subday_type
			        WHEN 1 THEN 'At specified time'
			       --  when 2 then CAST(freq_subday_interval AS VARCHAR(3)) + ' Seconds'
			        -- when 4 then CAST(freq_subday_interval AS VARCHAR(3)) + ' Minutes'
			       --  when 8 then CAST(freq_subday_interval AS VARCHAR(3)) + ' Hours'
				    -- when 8 then CAST((freq_subday_interval * 60) AS VARCHAR(3)) + ' Mins/' + CAST(freq_subday_interval AS VARCHAR(3)) + ' Hours'
					
					WHEN 2 THEN CAST((freq_subday_interval/60) AS VARCHAR(3))
					WHEN 4 THEN CAST(freq_subday_interval AS VARCHAR(3))
					WHEN 8 THEN CAST((freq_subday_interval * 60) AS VARCHAR(3))
			    END
			    ,'Start_Date' = SUBSTRING(CONVERT(VARCHAR(15),active_start_date),1,4) 
			        + '/' + SUBSTRING(CONVERT(VARCHAR(15),active_start_date),5,2) + '/'
			        + SUBSTRING(CONVERT(VARCHAR(15),active_start_date),7,2)
			        + ' ' + 
			        CASE len(active_start_time)
			            WHEN 1 THEN CAST('00:00:0' + right(active_start_time,2) AS CHAR(8))
			            WHEN 2 THEN CAST('00:00:' + right(active_start_time,2) AS CHAR(8))
			            WHEN 3 THEN CAST('00:0'
			                    + left(right(active_start_time,3),1)  
			                    +':' + right(active_start_time,2) AS CHAR (8))
			            WHEN 4 THEN CAST('00:'
			                    + left(right(active_start_time,4),2)  
			                    +':' + right(active_start_time,2) AS CHAR (8))
			            WHEN 5 THEN CAST('0'
			                    + left(right(active_start_time,5),1) 
			                    +':' + Left(right(active_start_time,4),2)  
			                    +':' + right(active_start_time,2) AS CHAR (8))
			            WHEN 6 THEN CAST(Left(right(active_start_time,6),2) 
			                    +':' + Left(right(active_start_time,4),2)  
			                    +':' + right(active_start_time,2) AS CHAR (8))
			        END
			    ,'Schedule Enabled' = CASE s.enabled
			            WHEN 1 THEN 'Yes'
			            ELSE 'No'
			        END
			    ,'Schedule Desc' = s.name
			FROM msdb.dbo.sysjobs j
			INNER JOIN msdb.dbo.sysjobschedules js
			ON j.job_id = js.job_id
			INNER JOIN msdb.dbo.sysschedules s
			ON s.schedule_id = js.schedule_id
			WHERE j.name =  @SP_Name
			ORDER BY j.name
		</cfquery>

		<cfif (qGetJobInfo.RecordCount GT 0)>
			<cfif isNumeric(qGetJobInfo.Interval)>
				<cfset jobInterval = qGetJobInfo.Interval />
			<cfelse>
				<cfset jobInterval = 1440 />
			</cfif>
		<cfelse>
			<cfset jobInterval = 1440 />
		</cfif>

		<cfset TotalInterval = jobInterval + 10 />


		<cfquery name="qGetOCRUploadtTimeoutCreated" datasource="#application.datasource#">
				SELECT 	OUL.OCR_Upload_ID,
						OUL.File_Name,
						OUL.Source_Template,
						OUL.Created_User_ID,
						OUL.OCR_Upload_Date,
						OUL.OCR_Upload_Status,
						OUL.Debug_Dev_Status,
						OUL.OCR_Step,
						OUL.upload_type,
						OUL.Document_ID,
						OUL.Document_ID_2,
						OUL.ProcessTries,
						OUL.Pages_Extracted,
						OUL.OCR_Sub_Step,
						OUL.OCR_Sub_Step_Description,
						OTS.OCR_Template_Settings_ID,	
						OTS.OCR_Code,
						OTS.OCR_Template_Name, 
						OTS.OCR_File_Landing_Path,
						OTS.OCR_File_Landing_Path_Processed,
						OTS.OCR_File_PreProcess_Path,
						OTS.OCR_File_PostProcess_Path,
						OTS.OCR_File_PostProcess_Txt_Path,
						OTS.DB_File_Preprocess_Path,
						OTS.BB_Claim_Source_XREF_ID,
						OTS.DB_OCR_Source_Code,
						OTS.Search_String,
						OTS.IS_OCR_Required,
						OTS.OCR_Reader_Name,
						OTS.Parser_ID,
						OTS.Source_Code,
						OTS.Account_ID,
						OTS.Is_Double_Processing_On,	
						OTS.Special_Processing_Flag,
						DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins_Since_Start,
						DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins_Since_Last_Update,
						OTS.OCR_Template_Description,
						U1.Name_First,
						U1.Name_Last,
						U1.User_Code
				FROM 
						OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				INNER JOIN _Users U1 ON U1.User_ID = OUL.Created_User_ID
				WHERE 
						OUL.Deleted = 0	AND	
						OUL.OCR_Step IN  ('11') AND
						OTS.Deleted = 0
						AND ( DATEDIFF(minute, OUL.Updated_Date, GETDATE()) > #TotalInterval#)
				ORDER BY
						OUL.OCR_Upload_Date DESC 
				</cfquery>
		<!--- <cfdump var="#qGetOCRUploadtTimeoutInvAliCre#" /> --->

				<cfloop query = "qGetOCRUploadtTimeoutCreated">
							<cfquery name="updateOCRUploadLogStatus_x3" datasource="#application.datasource#">
								UPDATE 
									OCR_Upload_Log 
								SET 
									OCR_Step = '13',
									OCR_Upload_Status = 'Please check the DB stored procedures that sets the status to 11 for solving this issue. Make sure the SP: BA_<DBNAME>_Billback_Upload_Scheduler. Please contact a DB dev for this issue.',
									Debug_Dev_Status = 'Timeout in BB creation, as the time exceeded the waiting time in the Created status. Pending for #qGetOCRUploadtTimeoutCreated.Pending_Mins_Since_Start# mins since uploading.Pending for #qGetOCRUploadtTimeoutCreated.Pending_Mins_Since_Last_Update# mins since last update. OCR_File_Mover.cfm - 741',
									Updated_Date = getDate(),
									Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
								WHERE 
									OCR_Upload_ID = '#qGetOCRUploadtTimeoutCreated.OCR_Upload_ID#'
							</cfquery>
							<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadtTimeoutCreated.Source_Code#' -  #qGetOCRUploadtTimeoutCreated.OCR_Template_Description# on '#qDBName.DBName#' Failed for Upload ID:#qGetOCRUploadtTimeoutCreated.OCR_Upload_ID# at CREATED">
								Please see what needs to be fixed:<br><br>
								<a href="#uploadInfoSiteURL##qGetOCRUploadtTimeoutCreated.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadtTimeoutCreated.OCR_Upload_ID#</a><br><br>
							</cfmail>
				</cfloop>	
				
				
		 <!---------------------------------------------------------------------------------------------------->
		<!---- PHASE 8: UMBRELLA TIMEOUT  --->
		<!---------------------------------------------------------------------------------------------------->

		<h2>PHASE 8: </h2>
		Umbrella Timeout<br>

		<cfquery name="qGetOCRUploadUmbrellaExtracted" datasource="#application.datasource#">
			SELECT 	OUL.OCR_Upload_ID,
					OUL.File_Name,
					OUL.Source_Template,
					OUL.Created_User_ID,
					OUL.OCR_Upload_Date,
					OUL.OCR_Upload_Status,
					OUL.Debug_Dev_Status,
					OUL.OCR_Step,
					OUL.upload_type,
					OUL.Document_ID,
					OUL.Document_ID_2,
					OUL.ProcessTries,
					OUL.Pages_Extracted,
					OUL.OCR_Sub_Step,
					OUL.OCR_Sub_Step_Description,
					OUL.OCR_Upload_Test_Log_ID,
					OTS.OCR_Template_Settings_ID,	
					OTS.OCR_Code,
					OTS.OCR_Template_Name, 
					OTS.OCR_File_Landing_Path,
					OTS.OCR_File_Landing_Path_Processed,
					OTS.OCR_File_PreProcess_Path,
					OTS.OCR_File_PostProcess_Path,
					OTS.OCR_File_PostProcess_Txt_Path,
					OTS.DB_File_Preprocess_Path,
					OTS.BB_Claim_Source_XREF_ID,
					OTS.DB_OCR_Source_Code,
					OTS.Search_String,
					OTS.IS_OCR_Required,
					OTS.OCR_Reader_Name,
					OTS.Parser_ID,
					OTS.Source_Code,
					OTS.Account_ID,
					OTS.Is_Double_Processing_On,	
					OTS.Special_Processing_Flag,
					DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins,
					OTS.OCR_Template_Description,
					U1.Name_First,
					U1.Name_Last,
					U1.User_Code
				FROM 
					OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				INNER JOIN _Users U1 ON U1.User_ID = OUL.Created_User_ID			
				WHERE 
						OUL.Deleted = 0	AND	
						OUL.OCR_Step IN ('1','2') AND
						OTS.Deleted = 0
						AND DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) > #varUmbrellaTimeout#
						AND (OUL.OCR_Upload_Test_Log_ID IS NULL OR OUL.OCR_Upload_Test_Log_ID = 0 )
				ORDER BY
						OUL.OCR_Upload_Date DESC  		
			</cfquery>
			No. of rows affected: <cfdump var="#qGetOCRUploadUmbrellaExtracted.RecordCount#" />
			<cfoutput>
			<cfloop query = "qGetOCRUploadUmbrellaExtracted">
			 	<cfquery name="updateOCRUploadLogStatus_x1" datasource="#application.datasource#">
					UPDATE 
						OCR_Upload_Log 
					SET 
						OCR_Step = '2.CF_Error',
						OCR_Upload_Status = 'Root cause: unknown, this is a failsafe error capture. Please check the Login, Jobs and finally the Permissions for the user.',
						Debug_Dev_Status = 'Umbrella timeout as the time exceeded #varUmbrellaTimeout#  mins waiting on the source status. Pending for #qGetOCRUploadUmbrellaExtracted.Pending_Mins# mins. OCR_File_Mover.cfm - 840',
						Updated_Date = getDate(),
						Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
					WHERE OCR_Upload_ID = '#qGetOCRUploadUmbrellaExtracted.OCR_Upload_ID#'
				</cfquery>
					<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadUmbrellaExtracted.Source_Code#' -  #qGetOCRUploadUmbrellaExtracted.OCR_Template_Description# on '#qDBName.DBName#' Failed for Upload ID:#qGetOCRUploadUmbrellaExtracted.OCR_Upload_ID# at SOURCE">
						Please see what needs to be fixed:<br><br>
						<a href="#uploadInfoSiteURL##qGetOCRUploadUmbrellaExtracted.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadUmbrellaExtracted.OCR_Upload_ID#</a><br><br>
					</cfmail>
			</cfloop>
			</cfoutput>
			
			
			<!--- UMbrella Time out for Regression Testing Records the time out is set at 60 minutes --->
			
			<cfquery name="qGetOCRUploadUmbrellaExtractedRT" datasource="#application.datasource#">
			SELECT 	OUL.OCR_Upload_ID,
					OUL.File_Name,
					OUL.Source_Template,
					OUL.Created_User_ID,
					OUL.OCR_Upload_Date,
					OUL.OCR_Upload_Status,
					OUL.Debug_Dev_Status,
					OUL.OCR_Step,
					OUL.upload_type,
					OUL.Document_ID,
					OUL.Document_ID_2,
					OUL.ProcessTries,
					OUL.Pages_Extracted,
					OUL.OCR_Sub_Step,
					OUL.OCR_Sub_Step_Description,
					OUL.OCR_Upload_Test_Log_ID,
					OTS.OCR_Template_Settings_ID,	
					OTS.OCR_Code,
					OTS.OCR_Template_Name, 
					OTS.OCR_File_Landing_Path,
					OTS.OCR_File_Landing_Path_Processed,
					OTS.OCR_File_PreProcess_Path,
					OTS.OCR_File_PostProcess_Path,
					OTS.OCR_File_PostProcess_Txt_Path,
					OTS.DB_File_Preprocess_Path,
					OTS.BB_Claim_Source_XREF_ID,
					OTS.DB_OCR_Source_Code,
					OTS.Search_String,
					OTS.IS_OCR_Required,
					OTS.OCR_Reader_Name,
					OTS.Parser_ID,
					OTS.Source_Code,
					OTS.Account_ID,
					OTS.Is_Double_Processing_On,	
					OTS.Special_Processing_Flag,
					DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) AS Pending_Mins,
					OTS.OCR_Template_Description,
					U1.Name_First,
					U1.Name_Last,
					U1.User_Code
				FROM 
					OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS ON 
							OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				INNER JOIN _Users U1 ON U1.User_ID = OUL.Created_User_ID			
				WHERE 
						OUL.Deleted = 0	AND	
						OUL.OCR_Step IN ('1','2') AND
						OTS.Deleted = 0
						AND DATEDIFF(minute, OUL.OCR_Upload_Date, GETDATE()) > #varUmbrellaRTTimeout#
						AND (OUL.OCR_Upload_Test_Log_ID >= 1 )
				ORDER BY
						OUL.OCR_Upload_Date DESC  		
			</cfquery>
			No. of rows affected: <cfdump var="#qGetOCRUploadUmbrellaExtractedRT.RecordCount#" />
			<cfoutput>
			<cfloop query = "qGetOCRUploadUmbrellaExtractedRT">
			 	<cfquery name="updateOCRUploadLogStatus_x1" datasource="#application.datasource#">
					UPDATE 
						OCR_Upload_Log 
					SET 
						OCR_Step = '2.CF_Error',
						OCR_Upload_Status = 'Root cause: unknown, this is a failsafe error capture. Please check the Login, Jobs and finally the Permissions for the user.',
						Debug_Dev_Status = 'Umbrella timeout as the time exceeded #varUmbrellaTimeout#  mins waiting on the source status. Pending for #qGetOCRUploadUmbrellaExtractedRT.Pending_Mins# mins. OCR_File_Mover.cfm - 840',
						Updated_Date = getDate(),
						Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
					WHERE OCR_Upload_ID = '#qGetOCRUploadUmbrellaExtractedRT.OCR_Upload_ID#'
				</cfquery>
					<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadUmbrellaExtractedRT.Source_Code#' -  #qGetOCRUploadUmbrellaExtractedRT.OCR_Template_Description# on '#qDBName.DBName#' Failed for Upload ID:#qGetOCRUploadUmbrellaExtractedRT.OCR_Upload_ID# at SOURCE">
						Please see what needs to be fixed:<br><br>
						<a href="#uploadInfoSiteURL##qGetOCRUploadUmbrellaExtractedRT.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadUmbrellaExtractedRT.OCR_Upload_ID#</a><br><br>
					</cfmail>
			</cfloop>
			</cfoutput>
			
			<!---------------------------------------------------------------------------------------------------->
			<!---- REGRESSION TESETING UPDATE --->
			<!---------------------------------------------------------------------------------------------------->
			<cfinclude template = "OCR_Testing_Update.cfm" />
			<br>
			
			<!---------------------------------------------------------------------------------------------------->
			<!---- ABBYY Limit Checking --->
			<!---------------------------------------------------------------------------------------------------->
			<h2>PHASE 9: </h2>
			ABBYY Limit Checker<br>
			<cfinclude template = "AbbyyLimitCheck.cfm" />
			 
			<cfquery name="qryUpdSTLogEnd" datasource="#application.datasource#">
				UPDATE 
					CIA_Scheduled_Task_Log
				SET 
					End_DateTime = Getdate(),
					Errored = 0,
					isProcessing = 0
				WHERE CIA_Scheduled_Task_Log_ID = #CIAScheduledTaskLogID#
			</cfquery>

	</cfif> <!--- <cfif (qryIsSTProcessing.Recordcount EQ 0)> --->
	<cfcatch>
		<cfset useLakebaseForqryUpdSTLogEndError = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cia_scheduled_task_log")>
<cfif useLakebaseForqryUpdSTLogEndError>
	<cftry>
		<cfset application.oLakebase.updateRows("cia_scheduled_task_log",
			{
				"cia_scheduled_task_log_id" = "eq.#CIAScheduledTaskLogID#"
			},
			{
				"end_datetime" = "#now()#",
				"errored" = "1",
				"isprocessing" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryUpdSTLogEndError = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryUpdSTLogEndError>
<cfquery name="qryUpdSTLogEndError" datasource="#application.datasource#">
					UPDATE 
						CIA_Scheduled_Task_Log
					SET 
						End_DateTime = Getdate(),
						Errored = 1,
						isProcessing = 0
					WHERE CIA_Scheduled_Task_Log_ID = #CIAScheduledTaskLogID#
		</cfquery>
</cfif>
	</cfcatch>
</cftry>
</body>
</html>


