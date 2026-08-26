<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/Inc_GFS_CA_TRADE.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  09-Sep-17
Created By   :  Anand Rao
Description  :  Include template for GFS CA Trade
---------------------------------------------------------------------------------->
<cfoutput>
	<cfset isCompletelyParsed = 1 />

	<cfquery name="qCreateTableGFS" datasource="#application.datasource#">
			IF object_id('tempdb..##tblGFSCATradeFileData') IS NOT NULL
					BEGIN	 
		                 DROP TABLE ##tblGFSCATradeFileData
					END
				
				CREATE TABLE ##tblGFSCATradeFileData
				(
					 
					[Customer_Reference_Number] 	[varchar](max), 
					[Distributor_id]				[varchar](max),
					[Document_ID]  					[varchar](max),
					[End_Date_Formatted]  			[varchar](max),
					[File_name]						[varchar](max),
					[ID]							[varchar](max),
					[Invoice_Date_Formatted]  		[varchar](max),
					[Item_Amount]					[varchar](max),
					[Item_Description]				[varchar](max),
					[Item_Item_Number]				[varchar](max),
					[Item_Qty]						[varchar](max),
 					[Item_Row]						[varchar](max),
					
					[Media_link]  					[varchar](max),
					[Media_link_data]  				[varchar](max),					
					[Media_link_original]  			[varchar](max),					
					[Page_Count]					[varchar](max),
					[Processed_At]  				[varchar](max),
					[Program_Info_Key_0]  			[varchar](max),
					[Remote_ID]  					[varchar](max),
					[Start_Date_Formatted]			[varchar](max),
					[Uploaded_at]					[varchar](max),
					
					[OCR_Upload_ID]					[varchar](max),
					[OCR_Input_FileName_Raw]		[varchar](max),
					[DB_OCR_Source_Code_FileName]	[varchar](max),
					[OCR_Source]					[varchar](max),
					[BB_Claim_Source_XREF_ID]		[varchar](max),
					[OCR_Template_Settings_ID]		[varchar](max),
					[DB_OCR_Source_Code]			[varchar](max),
					[OCR_Code]						[varchar](max)
				)
			</cfquery>
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
	
	<cfif (isCompletelyParsed EQ 1)>	
					
		 	<cfloop index = "i" from = "1" to = "#aryTotalRecLength#">
 				<cfif (NOT(ArrayIsEmpty(structFileContent)))>
						<cfset aryItemLength = ArrayLen(structFileContent[i].item) />
						<cfloop index = "j" from = "1" to = "#aryItemLength#">
			 				<cftry>
								<cfif (StructKeyExists(structFileContent[i], "customer_reference_number") AND (structFileContent[i].customer_reference_number.key_0 NEQ "undefined"))>
								 	<cfset CustomerReferenceNumber = structFileContent[i].customer_reference_number.key_0 />
								<cfelse>
									<cfset CustomerReferenceNumber = ""/>
								</cfif>
								<cfcatch>
									<cfset CustomerReferenceNumber = ""/>
								</cfcatch>
							</cftry>
							<cftry>
								<cfif (StructKeyExists(structFileContent[i], "distributor_id") AND (structFileContent[i].distributor_id.key_0 NEQ "undefined"))>
								 	<cfset distributorID = structFileContent[i].distributor_id.key_0 />
								<cfelse>
									<cfset distributorID = ""/>
								</cfif>
								<cfcatch>
									<cfset distributorID = ""/>
								</cfcatch>
							</cftry>
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"end_date") AND (structFileContent[i].end_date.formatted NEQ "undefined"))>
								 	<cfset EndDate = structFileContent[i].end_date.formatted />
								<cfelse>
									<cfset EndDate = ""/>
								</cfif>
								<cfcatch>
									<cfset EndDate = ""/>
								</cfcatch>
							</cftry> 
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"start_date") AND (structFileContent[i].start_date.formatted NEQ "undefined"))>
								 	<cfset StartDate = structFileContent[i].start_date.formatted />
								<cfelse>
									<cfset StartDate = ""/>
								</cfif>
								<cfcatch>
									<cfset StartDate = ""/>
								</cfcatch>
							</cftry> 
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"invoice_date") AND (structFileContent[i].invoice_date.formatted NEQ "undefined"))>
								 	<cfset InvoiceDate = structFileContent[i].invoice_date.formatted />
								<cfelse>
									<cfset InvoiceDate = ""/>
								</cfif>
								<cfcatch>
									<cfset InvoiceDate = ""/>
								</cfcatch>
							</cftry>	
							<cftry>
								<cfif (StructKeyExists(structFileContent[i],"program_info") AND (structFileContent[i].program_info.key_0 NEQ "undefined"))>
								 	<cfset ProgramInfo = structFileContent[i].program_info.key_0 />
								<cfelse>
									<cfset ProgramInfo = ""/>
								</cfif>
								<cfcatch>
									<cfset ProgramInfo = ""/>
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
								<cfif (StructKeyExists(structFileContent[i].item[j],"number") AND (structFileContent[i].item[j].number NEQ "undefined"))>
								 	<cfset ItemNumber = structFileContent[i].item[j].number />
								<cfelse>
									<cfset ItemNumber = ""/>
								</cfif>
								<cfcatch>
									<cfset ItemNumber = ""/>
								</cfcatch>
							</cftry> 							
 						
			 				<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"qty") AND (structFileContent[i].item[j].qty NEQ "undefined"))>
								 	<cfset Qty = structFileContent[i].item[j].qty />
								<cfelse>
									<cfset Qty = ""/>
								</cfif>
								<cfcatch>
									<cfset Qty = ""/>
								</cfcatch>
							</cftry>
			 				<cftry>
								<cfif (StructKeyExists(structFileContent[i].item[j],"row") AND (structFileContent[i].item[j].row NEQ "undefined"))>
								 	<cfset Row = structFileContent[i].item[j].row />
								<cfelse>
									<cfset Row = ""/>
								</cfif>
								<cfcatch>
									<cfset Row = ""/>
								</cfcatch>
							</cftry>				
				<cfquery name="qInsertTable" datasource="#application.datasource#">
							INSERT INTO ##tblGFSCATradeFileData (
								Customer_Reference_Number, 
								Distributor_ID,
								Document_ID, 
								End_Date_Formatted,
								File_name,
								ID,
								Invoice_Date_Formatted,
								Item_Amount,
								Item_Description,
								Item_Item_Number,
								Item_Qty,
								Item_Row,
								 
								Media_link,
								Media_link_data,
								Media_link_original,
								Page_Count,
								Processed_At,
								Program_Info_Key_0,
								Remote_ID,
								Start_Date_Formatted,
								Uploaded_at,
								
								
								OCR_Upload_ID,
								OCR_Input_FileName_Raw,
								DB_OCR_Source_Code_FileName,
								OCR_Source,
								BB_Claim_Source_XREF_ID,
								OCR_Template_Settings_ID,
								DB_OCR_Source_Code
								,OCR_Code
								)
							VALUES
								(
									'#CustomerReferenceNumber#',
									'#distributorID#',
									'#structFileContent[i].document_id#',
									'#EndDate#',
									'#structFileContent[i].file_name#',
									'#structFileContent[i].id#',
									'#InvoiceDate#',
									'#Amount#',
									'#Description#',
									'#ItemNumber#',
									'#Qty#',
									'#Row#',
									'#structFileContent[i].media_link#',
									'#structFileContent[i].media_link_data#',
									'#structFileContent[i].media_link_original#',																		
									'#structFileContent[i].page_count#',
									'#structFileContent[i].processed_at#',
									'#ProgramInfo#',
									'#structFileContent[i].remote_id#',
									'#StartDate#',
									'#structFileContent[i].uploaded_at#',
									
									'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
									'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
									'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
									'#qGetOCRUploadExtracted.Source_Code#', /* 'GFS', OCR_Source, */
									'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
									'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
									'#qGetOCRUploadExtracted.DB_OCR_Source_Code#', /* DB_OCR_Source_Code - Trackmax1 */
									'#qGetOCRUploadExtracted.OCR_Code#' /* 'GFS_CA_TRADE' */
								)	 
						</cfquery>
						
					</cfloop>
				<cfelse>
				<!--- in error else part <cfoutput>i = #i#, j = #j#</cfoutput><br> --->
						<!--- <cfquery name="updateOCRUploadLogStatus5" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
							SET 
								OCR_Step = '2.CF_Error',
								OCR_Upload_Status = 'Data mismatch between the file and the Docparser template. ',
								Debug_Dev_Status = 'In docParser.cfm Checkpoint 1. The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.'
							WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>  --->
						  <!--- OTHER ROWS WILL BE PICKED UP DURING THE NEXT RUN --->
				</cfif>	<!--- END: <cfif (StructKeyExists(structFileContent[i], "customer_reference_number")  AND  --->
				<cfset pageCount = pageCount + structFileContent[i].page_count />
			</cfloop>
 			
			<cfquery name="qSelGFSFileDataCheck" datasource="#application.datasource#">
				SELECT * FROM ##tblGFSCATradeFileData
			</cfquery>
 

			<cfif (qSelGFSFileDataCheck.RecordCount GTE 1)>
 
			   <cfquery name="qInsertPermTable" datasource="#application.datasource#">	
			 	INSERT INTO OCR_Trackmax1_Excel_Format
				(
					Customer_Reference_Number, 
					Distributor_location,
					End_Date, 
					Invoice_Date, 
					Item_Amount,
					Item_Description,
					Item_DID,
				 
					Item_Quantity,
					Item_Row_Number,
					Page_Count,
					Item_Customer_ID,
					Item_Customer_Name,
					Start_Date,
					Payee_Type_IND,
					Trade_IND,
					Program_Information,
					
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
					Distributor_ID,
					End_Date_Formatted,
					Invoice_Date_Formatted,
					Item_Amount,
					Item_Description,
					Item_Item_Number,

					Item_Qty,
					Item_Row,
					Page_Count,
					Program_Info_Key_0,
					Program_Info_Key_0,
					Start_Date_Formatted,
					'',
					'T',
					Program_Info_Key_0,
								
					OCR_Upload_ID,
					OCR_Input_FileName_Raw,
					DB_OCR_Source_Code_FileName,
					OCR_Source,
					BB_Claim_Source_XREF_ID,
					OCR_Template_Settings_ID,
					DB_OCR_Source_Code,
					OCR_Code
				FROM
					##tblGFSCATradeFileData 
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
					/*  Pages_Extracted = '#pageCount#', */
					OCR_Step = '4',
					OCR_Upload_Status = 'Transferred file to DB processing',
					Debug_Dev_Status = 'Transferred file to DB processing. DBLocation "#DBDest#"',
					Updated_Date = getDate()
			WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
		</cfquery>
</cfif>	 
	
	<cfelse>
		 <cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
			UPDATE OCR_Upload_Log 
							SET 
								OCR_Step = '2.CF_Error',
								OCR_Upload_Status = 'Data mismatch between the file and the Docparser template. ',
								Debug_Dev_Status = 'The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.',
								Updated_Date = getDate(),
								Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type.'
						WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
		</cfquery>
	</cfif>
  
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