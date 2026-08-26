<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/Inc_GFS_US_TRADE.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  11-Oct-2017
Created By   :  Anand Rao
Description  :  Include template for GFS US TRADE
---------------------------------------------------------------------------------->

<!--- for JSON structure --->
<cfoutput>
<cfset isCompletelyParsed = 1 />
<cfset aryTotalRecLength = ArrayLen(structFileContent) />
<cfset pageCount	= 0 />

<!--- CHECK IF ALL THE PAGES IN THE UPLOADED FILE HAS BEEN PROCESSED OR NOT --->
<cfloop index = "iLoop" from = "1" to = "#aryTotalRecLength#">
	<cfif (StructKeyExists(structFileContent[iLoop], "item") AND StructKeyExists(structFileContent[iLoop],"processed_at") AND (structFileContent[iLoop].processed_at EQ "undefined" OR 
	structFileContent[iLoop].processed_at EQ ""))>
		<cfset isCompletelyParsed = 0 />
		<cfbreak/>
	<cfelseif 	(NOT StructKeyExists(structFileContent[iLoop],"processed_at"))>
		<cfset isCompletelyParsed = 0 />
		<cfbreak/>
	</cfif>
</cfloop>
<!--- <cfdump var="#structFileContent#"/> --->
<cfif (isCompletelyParsed EQ 1)>	
	<cfquery name="qCreateTableGFS" datasource="#application.datasource#">
			IF object_id('tempdb..##tblGFSFileData') IS NOT NULL
					BEGIN	 
		                 DROP TABLE ##tblGFSFileData
					END
				
				CREATE TABLE ##tblGFSFileData
				(
					[Customer_Reference_Number] 		[varchar](max), 
					[Document_ID]  						[varchar](max),
					[End_Date]  						[varchar](max),
					[Split_File_name]					[varchar](max),
					[ID]								[varchar](max),
					[invoice_date]  					[varchar](max),
					[Item_Amount]						[varchar](max),
					[Item_Description]					[varchar](max),
					[Item_Distributor_Location]			[varchar](max),
					[Item_GFS_Item]						[varchar](max),
					[Item_Quantity]						[varchar](max),
					[Item_Manufacturer_ID]				[varchar](max), 
					[Item_Weight]						[varchar](max), 
					[Item_Rate]							[varchar](max), 					
					[Media_link]  						[varchar](max),
					[Page_Count]  						[varchar](max),
					[Processed_At]  					[varchar](max),
					[Program_Info]  					[varchar](max),
					[Remote_ID]  						[varchar](max),
					[Start_Date]						[varchar](max),
					[Uploaded_at]						[varchar](max),
					
					[OCR_Upload_ID]						[varchar](max),
					[OCR_Input_FileName_Raw]			[varchar](max),
					[DB_OCR_Source_Code_FileName]		[varchar](max),
					[OCR_Source]						[varchar](max),
					[BB_Claim_Source_XREF_ID]			[varchar](max),
					[OCR_Template_Settings_ID]			[varchar](max),
					[DB_OCR_Source_Code]				[varchar](max),
					[OCR_Code]							[varchar](max)
					
				)
			</cfquery>
  
 <!---  <cfdump var="#structFileContent#" /> --->
		 	<cfset aryTotalRecLength = ArrayLen(structFileContent) />
		 	<cfloop index = "i" from = "1" to = "#aryTotalRecLength#">
				<cfif (NOT(ArrayIsEmpty(structFileContent)) AND StructKeyExists(structFileContent[i], "item") )>
						<cfif (StructKeyExists(structFileContent[i], "item") AND (NOT isArray(structFileContent[i].item)) AND StructKeyExists(structFileContent[i].item,"amount"))>
							<cfset structLineItems =  structFileContent[i].item />
							<cfset structFileContent[i].item = Arraynew(1) />
							<cfset structFileContent[i].item[1] = structLineItems />
						</cfif>	
						<cfset aryItemLength = ArrayLen(structFileContent[i].item) />
						<cfloop index = "j" from = "1" to = "#aryItemLength#">
			 				
							<cftry> 
								<cfif (StructKeyExists(structFileContent[i],"customer_reference_number") AND (structFileContent[i].customer_reference_number NEQ "undefined"))>
								 	<cfset customerReferenceNumber = structFileContent[i].customer_reference_number />
								<cfelse>
									<cfset customerReferenceNumber = ""/>
								</cfif>
								<cfcatch>
									<cfset customerReferenceNumber = ""/>
								</cfcatch>
							</cftry> 
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"start_date") AND (StructKeyExists(structFileContent[i].start_date,"key_0")))>
								 	<cfset startDate = structFileContent[i].start_date.key_0 />
								<cfelse>
									<cfset startDate = ""/>
								</cfif>
								<cfcatch>
									<cfset startDate = ""/>
								</cfcatch>
							</cftry> 
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"end_date") AND (StructKeyExists(structFileContent[i].end_date,"key_0")))>
								 	<cfset endDate = structFileContent[i].end_date.key_0 />
								<cfelse>
									<cfset endDate = ""/>
								</cfif>
								<cfcatch>
									<cfset endDate = ""/>
								</cfcatch>
							</cftry> 
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"invoice_date") AND (StructKeyExists(structFileContent[i].invoice_date,"key_0")))>
								 	<cfset invoiceDate = structFileContent[i].invoice_date.key_0 />
								<cfelse>
									<cfset invoiceDate = ""/>
								</cfif>
								<cfcatch>
									<cfset invoiceDate = ""/>
								</cfcatch>
							</cftry>
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"program") AND (StructKeyExists(structFileContent[i].program,"key_0")))>
								 	<cfset programKey0 = structFileContent[i].program.key_0 />
								<cfelse>
									<cfset programKey0 = ""/>
								</cfif>
								<cfcatch>
									<cfset programKey0 = ""/>
								</cfcatch>
							</cftry>
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"program_info") AND (StructKeyExists(structFileContent[i].program_Info,"key_0")))>
								 	<cfset programInfoKey0 = structFileContent[i].program_Info.key_0 />
								<cfelse>
									<cfset programInfoKey0 = ""/>
								</cfif>
								<cfcatch>
									<cfset programInfoKey0 = ""/>
								</cfcatch>
							</cftry>
							<cfset programInformation = programKey0 & " " & programInfoKey0 />
							
							<cftry>
								<cfif (StructKeyExists(structFileContent[i], "distributor_location") AND (structFileContent[i].distributor_location.key_0 NEQ "undefined"))>
								 	<cfset DistributorLocation = structFileContent[i].distributor_location.key_0 />
								<cfelse>
									<cfset DistributorLocation = ""/>
								</cfif>
								<cfcatch>
									<cfset DistributorLocation = ""/>
								</cfcatch>
							</cftry>							
							<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"amount") AND (structFileContent[i].item[j].amount NEQ "undefined"))>
								 	<cfset Amount = structFileContent[i].item[j].amount />
								<cfelse>
									<cfset Amount = ""/>
								</cfif>
								<cfcatch>
									<cfset Amount = ""/>
								</cfcatch>
							</cftry>
			 				<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"description") AND (structFileContent[i].item[j].description NEQ "undefined"))>
								 	<cfset Description = structFileContent[i].item[j].description />
								<cfelse>
									<cfset Description = ""/>
								</cfif>
								<cfcatch>
									<cfset Description = ""/>
								</cfcatch>
							</cftry> 
							<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"id") AND (structFileContent[i].item[j].id NEQ "undefined"))>
								 	<cfset ID = structFileContent[i].item[j].id />
								<cfelse>
									<cfset ID = ""/>
								</cfif>
								<cfcatch>
									<cfset ID = ""/>
								</cfcatch>
							</cftry> 							
 						
			 				<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"quantity") AND (structFileContent[i].item[j].quantity NEQ "undefined"))>
								 	<cfset Quantity = structFileContent[i].item[j].quantity />
								<cfelse>
									<cfset Quantity = ""/>
								</cfif>
								<cfcatch>
									<cfset Quantity = ""/>
								</cfcatch>
							</cftry>

							<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"manufacturer_id") AND (structFileContent[i].item[j].manufacturer_id NEQ "undefined"))>
								 	<cfset Manufacturer_ID = structFileContent[i].item[j].manufacturer_id />
								<cfelse>
									<cfset Manufacturer_ID = ""/>
								</cfif>
								<cfcatch>
									<cfset Manufacturer_ID = ""/>
								</cfcatch>
							</cftry>
							
							<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"net_weight") AND (structFileContent[i].item[j].net_weight NEQ "undefined"))>
								 	<cfset Net_Weight = structFileContent[i].item[j].net_weight />
								<cfelse>
									<cfset Net_Weight = ""/>
								</cfif>
								<cfcatch>
									<cfset Net_Weight = ""/>
								</cfcatch>
							</cftry>						
			
							<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"rate") AND (structFileContent[i].item[j].rate NEQ "undefined"))>
								 	<cfset Rate = structFileContent[i].item[j].rate />
								<cfelse>
									<cfset Rate = ""/>
								</cfif>
								<cfcatch>
									<cfset Rate = ""/>
								</cfcatch>
							</cftry>	
				<cfquery name="qInsertTable" datasource="#application.datasource#">
								INSERT INTO ##tblGFSFileData (
									Customer_Reference_Number, 
									Document_ID, 
									End_Date, 
									Split_File_Name,
									ID,
									Invoice_Date, 
									Item_Amount,
									Item_Description,
									Item_Distributor_Location,
									Item_GFS_Item,	
									Item_Quantity,	
									Item_Manufacturer_ID,
									Item_Weight,
									Item_Rate,
									
									Media_Link,
									Page_Count,
									Processed_At, 
									Program_Info, 
									Remote_ID,
									Start_Date,
									Uploaded_At,
												
									OCR_Upload_ID,
									OCR_Input_FileName_Raw,
									DB_OCR_Source_Code_FileName,
									OCR_Source,
									BB_Claim_Source_XREF_ID,
									OCR_Template_Settings_ID,
									DB_OCR_Source_Code,
									OCR_Code
									)
								VALUES
									(
										'#customerReferenceNumber#',
										'#structFileContent[i].document_id#',
										'#endDate#',
										'#structFileContent[i].file_name#',
										'#structFileContent[i].id#',
										'#invoiceDate#',
										'#Amount#',
										'#Description#',
										'#DistributorLocation#',
										'#ID#',
										'#Quantity#',
										'#Manufacturer_ID#',
										'#Net_Weight#',
										'#Rate#',
										
										'#structFileContent[i].media_link#',
										'#structFileContent[i].page_count#',
										'#structFileContent[i].processed_at#',
										'#programInformation#',
										'#structFileContent[i].remote_id#',
										'#startDate#',
										'#structFileContent[i].uploaded_at#',
										
										'#qGetOCRUploadExtracted.OCR_Upload_ID#', 	 /* OCR_Upload_ID */
										'#qGetOCRUploadExtracted.File_Name#',		 /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
										'#qGetOCRUploadExtracted.File_Name#',		/* DB_OCR_Source_Code_FileName, -- populate orignial uploaded file name from ocr_upload_log */
										'#qGetOCRUploadExtracted.Source_Code#', /* 'GFS', OCR_Source, */
										'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* BB_Claim_Source_XREF_ID, */
										'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#', /* OCR_Template_Settings_ID, */
										'Trackmax1', /* DB_OCR_Source_Code */
										'#qGetOCRUploadExtracted.OCR_Code#'
								)	 
						</cfquery>
						
					</cfloop>
				<cfelse>
						<cfset useLakebaseForupdateOCRUploadLogStatus5 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForupdateOCRUploadLogStatus5>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#qGetOCRUploadExtracted.OCR_Upload_ID#"
			},
			{
				"ocr_step" = "2.CF_Error",
				"ocr_upload_status" = "Data mismatch between the file and the Docparser template. ",
				"debug_dev_status" = "In docParser.cfm Checkpoint 1. The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.",
				"updated_date" = "#now()#",
				"error_tool_tip" = "Please try again with a different source type. The invoice file format did not match the format of the selected source type."
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateOCRUploadLogStatus5 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLogStatus5>
<cfquery name="updateOCRUploadLogStatus5" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
							SET 
								OCR_Step = '2.CF_Error',
								OCR_Upload_Status = 'Data mismatch between the file and the Docparser template. ',
								Debug_Dev_Status = 'In docParser.cfm Checkpoint 1. The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.',
								Updated_Date = getDate(),
								Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type.'
							WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>
</cfif> 
						<cfabort> <!--- OTHER ROWS WILL BE PICKED UP DURING THE NEXT RUN --->
				</cfif>	<!--- END: <cfif (StructKeyExists(structFileContent[i], "customer_reference_number")  AND  --->
			</cfloop>
 
			
			<cfquery name="qSelGFSFileDataCheck" datasource="#application.datasource#">
				SELECT * FROM ##tblGFSFileData
			</cfquery>
 			<!--- <cfdump var="#qSelGFSFileData#" /> --->
 
			<cfif (qSelGFSFileDataCheck.RecordCount GTE 1)>
 
			   <cfquery name="qInsertPermTable" datasource="#application.datasource#">	
			 	INSERT INTO OCR_Trackmax1_Excel_Format
				(
					Customer_Reference_Number, 
					Document_ID, 
					End_Date, 
					File_Name,-- Split_File_Name?
					--ID, ?
					Invoice_Date, 
					Item_Amount,
					Item_Description,
					Distributor_Location,
					Item_DID,	
					Item_Quantity,
					Item_Manufacturer_ID,
					Item_Total_Weight,
					Item_Rate,
					
					Page_Count,
					Trade_IND,
					
					Processed_At, 
					Program_Information, 
					----Remote_ID, ?
					Start_Date,
					Uploaded_At,
					
					
					OCR_Upload_ID,
					OCR_Input_FileName_Raw,
					DB_OCR_Source_Code_FileName,
					OCR_Source,
					BB_Claim_Source_XREF_ID,
					OCR_Template_Settings_ID,
					DB_OCR_Source_Code,
					OCR_Code
					)
				SELECT 	
 
					Customer_Reference_Number, 
					Document_ID, 
					End_Date, 
					Split_File_Name,
					---ID, ? no mapping
					Invoice_Date, 
					Item_Amount,
					Item_Description,
					Item_Distributor_Location,
					Item_GFS_Item,	
					Item_Quantity,
					Item_Manufacturer_ID,
					Item_Weight,
					Item_Rate,
					Page_Count,
					'T' AS Trade_IND,
					
					Processed_At, 
					Program_Info,  ---Leave empty Program_Info from tmp not used
					---Remote_ID, ?no mapping
					Start_Date,
					Uploaded_At,
					
					OCR_Upload_ID,
					OCR_Input_FileName_Raw,
					DB_OCR_Source_Code_FileName,
					OCR_Source,
					BB_Claim_Source_XREF_ID,
					OCR_Template_Settings_ID,
					DB_OCR_Source_Code,
					OCR_Code
				FROM
					##tblGFSFileData 
			</cfquery>
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
				"debug_dev_status" = "Transferred file to DB processing.",
				"db_input_filename" = "#qGetOCRUploadExtracted.File_Name#",
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
						Debug_Dev_Status = 'Transferred file to DB processing.',
						DB_Input_FileName = '#qGetOCRUploadExtracted.File_Name#',
						Updated_Date = getDate()
				WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
			</cfquery>
</cfif>	  
			<!--- <cffile action="move" source="#postPDFFile#" destination="#archiveLocation#">   --->
			<cfelse>
					<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
								SET 
									OCR_Step = '2.CF_Error',
									OCR_Upload_Status = 'The Search string is not found in the distributor_location column from the Docparser',
									Debug_Dev_Status = 'The Search string is not found in the distributor_location column from the Docparser.',
									Updated_Date = getDate(),
									Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please try again or contact ciasupport@blacksmithapplications.com'
							WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>	
			</cfif>	<!--- END: <cfif qSelGFSFileDataCheck.RecordCount GTE 1> --->
<cfelse>
	<cfquery name="updateOCRUploadLogUpdateTries" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log 
				SET 
					Debug_Dev_Status = 'Docparser is still processing the file and returning half the results.',
					ProcessTries = ProcessTries + 1,
					Updated_Date = getDate()
			WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
	</cfquery>	
 </cfif> 			
			
</cfoutput>			