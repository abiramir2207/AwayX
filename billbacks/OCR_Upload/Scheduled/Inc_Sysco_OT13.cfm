<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/inc_Sysco_OT13.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  24-Jul-17
Created By   :  Anand Rao
Description  :  Include template for SYSCO OT13
----------------------------------------------------------------------------------> 

<cfoutput>
<cfset isCompletelyParsed = 1 />

 	<cfquery name="qCreateTableSyscoOT13" datasource="#application.datasource#">
	IF object_id('tempdb..##tblSYSCOOT13FileData') IS NOT NULL
			BEGIN	 
                 DROP TABLE ##tblSYSCOOT13FileData
			END
		
		CREATE TABLE ##tblSYSCOOT13FileData
		(
			
			[Customer_Reference] 					[varchar](max),
			[Distributor_Key_0] 					[varchar](max),
			[Document_ID] 							[varchar](max),
			[End_Date_Formatted] 					[varchar](max),
			[File_Name] 							[varchar](max),
			[ID] 									[varchar](max),
			[Invoice_Date_Formatted] 				[varchar](max),
			[Item_Amount] 							[varchar](max),
			[Item_Description] 						[varchar](max),
			[Item_Item] 							[varchar](max),
			[Item_Program] 							[varchar](max),
			[Item_Qty] 								[varchar](max),			
			[Media_Link] 							[varchar](max),
			[Media_Link_Original] 					[varchar](max),
			[Page_Count] 							[varchar](max),
			[Processed_at] 							[varchar](max),
			[Remote_ID] 							[varchar](max),
			[Start_Date_Formatted] 					[varchar](max),
			[Uploaded_At] 							[varchar](max),
			
				
			[OCR_Upload_ID]							[varchar](max),
			[OCR_Input_FileName_Raw]				[varchar](max),
			[DB_OCR_Source_Code_FileName]			[varchar](max),
			[OCR_Source]							[varchar](max),
			[BB_Claim_Source_XREF_ID]				[varchar](max),
			[OCR_Template_Settings_ID]				[varchar](max),
			[DB_OCR_Source_Code]					[varchar](max),
			[OCR_Code]								[varchar](max)
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
		
		<cfset catchValue = 0 />
		<cftry>
			<cfif (StructKeyExists(structFileContent[i], "item") AND (NOT isArray(structFileContent[i].item)))>
			 	<cfset structLineItems =  structFileContent[i].item />
				<cfset structFileContent[i].line_itemsNew = Arraynew(1) />
				<cfset structFileContent[i].line_itemsNew[1] = structLineItems />
				<cfset aryItemLength = ArrayLen(structFileContent[i].line_itemsNew) />
			<cfelse>	
				<cfset structLineItems =  structFileContent[i].item />
				<cfset structFileContent[i].line_itemsNew = Arraynew(1) />
				<cfset structFileContent[i].line_itemsNew = structLineItems />
				<cfset aryItemLength = ArrayLen(structFileContent[i].line_itemsNew) />
			</cfif>
			<cfcatch>
				<cfset Amount = ""/>
				<cfset Description = ""/>
				<cfset ItemItem = ""/>
				<cfset Program = ""/>
				<cfset Qty = "" />
				<cfset aryItemLength = 1 />
				<cfset catchValue = 1 />
				<!--- in inside catch <cfdump var="#cfcatch.detail#" /><cfdump var="#cfcatch.message#" /> --->
			</cfcatch>				
		</cftry>
		<!--- <cfif (StructKeyExists(structFileContent[i], "item") AND (NOT isArray(structFileContent[i].item)))>
			<cfset structLineItems =  structFileContent[i].item />
			<cfset structFileContent[i].item = Arraynew(1) />
			<cfset structFileContent[i].item[1] = structLineItems />
		</cfif>	
		<cfset aryItemLength = ArrayLen(structFileContent[i].item) /> --->
			
			<cfloop index = "j" from = "1" to = "#aryItemLength#">
 	 				<cftry>
						<cfif (StructKeyExists(structFileContent[i],"customer_reference") AND (structFileContent[i].customer_reference NEQ "undefined"))>
						 	<cfset Customer_Reference = structFileContent[i].customer_reference />
						<cfelse>
							<cfset Customer_Reference = ""/>
						</cfif>
						<cfcatch>
							<cfset Customer_Reference = ""/>
						</cfcatch>
					</cftry> 
					<cftry>
						<cfif (StructKeyExists(structFileContent[i],"distributor") AND (structFileContent[i].distributor.key_0 NEQ "undefined"))>
						 	<cfset DistributorKey0 = structFileContent[i].distributor.key_0 />
						<cfelse>
							<cfset DistributorKey0 = ""/>
						</cfif>
						<cfcatch>
							<cfset DistributorKey0 = ""/>
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
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"amount") AND (structFileContent[i].line_itemsNew[j].amount NEQ "undefined"))>
						 	<cfset Amount = structFileContent[i].line_itemsNew[j].amount />
						<cfelse>
							<cfset Amount = ""/>
						</cfif>
						<cfcatch>
							<cfset Amount = ""/>
						</cfcatch>
					</cftry> 
	 				<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"description") AND (structFileContent[i].line_itemsNew[j].description NEQ "undefined"))>
						 	<cfset Description = structFileContent[i].line_itemsNew[j].description />
						<cfelse>
							<cfset Description = ""/>
						</cfif>
						<cfcatch>
							<cfset Description = ""/>
						</cfcatch>
					</cftry> 
					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"item") AND (structFileContent[i].line_itemsNew[j].item NEQ "undefined"))>
						 	<cfset ItemItem = structFileContent[i].line_itemsNew[j].item />
						<cfelse>
							<cfset ItemItem = ""/>
						</cfif>
						<cfcatch>
							<cfset ItemItem = ""/>
						</cfcatch>
					</cftry> 
					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"program") AND (structFileContent[i].line_itemsNew[j].program NEQ "undefined"))>
						 	<cfset Program = structFileContent[i].line_itemsNew[j].program />
						<cfelse>
							<cfset Program = ""/>
						</cfif>
						<cfcatch>
							<cfset Program = ""/>
						</cfcatch>
					</cftry> 

					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"qty") AND (structFileContent[i].line_itemsNew[j].qty NEQ "undefined"))>
						 	<cfset Qty = structFileContent[i].line_itemsNew[j].qty />
						<cfelse>
							<cfset Qty = ""/>
						</cfif>
						<cfcatch>
							<cfset Qty = ""/>
						</cfcatch>
					</cftry> 
	 
		<cfquery name="qInsertTable" datasource="#application.datasource#">
					INSERT INTO ##tblSYSCOOT13FileData (
						Customer_Reference,
						Distributor_Key_0,
						Document_ID,
						End_Date_Formatted,
						File_Name,
						ID,
						Invoice_Date_Formatted,
						Item_Amount,
						Item_Description,
						Item_Item,
						Item_Program,
						Item_Qty,
						Media_Link,
						Media_Link_Original,
						Page_Count,
						Processed_at,
						Remote_ID,
						Start_Date_Formatted,
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
							'#Customer_Reference#',
							'#DistributorKey0#',
							'#structFileContent[i].document_id#',
							'#EndDate#',
							'#structFileContent[i].file_name#',
							'#structFileContent[i].id#',
							'#InvoiceDate#',
							'#Amount#',
							'#Description#',
							'#ItemItem#',
							'#Program#',
							'#Qty#',
							'#structFileContent[i].media_link#',
							'#structFileContent[i].media_link_original#',
							'#structFileContent[i].page_count#',
							'#structFileContent[i].processed_at#',
							'#structFileContent[i].remote_id#',
							'#StartDate#',
							'#structFileContent[i].uploaded_at#',
							
							'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
							'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
							'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
							'#qGetOCRUploadExtracted.Source_Code#', /* 'SYSCO', OCR_Source, */
							'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
							'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
							'#qGetOCRUploadExtracted.DB_OCR_Source_Code#', /* DB_OCR_Source_Code */
							'#qGetOCRUploadExtracted.OCR_Code#' 
						)	 
				</cfquery>
			</cfloop>
			<cfset pageCount = pageCount + structFileContent[i].page_count />
		</cfloop>
  
		<cfquery name="qSelSyscoFileDataCheck" datasource="#application.datasource#">
			SELECT * FROM ##tblSYSCOOT13FileData
		</cfquery>
 
	<cfif (qSelSyscoFileDataCheck.RecordCount NEQ 0)>
			   <cfquery name="qInsertPermTable" datasource="#application.datasource#">	
			 	INSERT INTO OCR_Trackmax1_Excel_Format
				(
					Customer_Reference_Number,
					Distributor_Location,
					End_Date,
					Invoice_Date,
					Item_Amount,
					Item_Description,
					Item_DID,
				--	Program_Info_ID,
					Item_Customer_Name, ---operator
					Program_Information,
					Item_Quantity,
					Page_Count,
					Start_Date,
		 
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
					Customer_Reference,
					Distributor_Key_0,
					End_Date_Formatted,
					Invoice_Date_Formatted,
					Item_Amount,
					Item_Description,
					Item_Item,
					--Item_Program,
					Item_Program,
					Item_Program,
					Item_Qty,
					Page_Count,
					Start_Date_Formatted,
				
					OCR_Upload_ID,
					OCR_Input_FileName_Raw,
					DB_OCR_Source_Code_FileName,
					OCR_Source,
					BB_Claim_Source_XREF_ID,
					OCR_Template_Settings_ID,
					DB_OCR_Source_Code,
					OCR_Code
				FROM
					##tblSYSCOOT13FileData 
			</cfquery>  
		 	<cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
				UPDATE OCR_Upload_Log 
					SET 
						/*  Pages_Extracted = '#pageCount#', */
						OCR_Step = '4',
						OCR_Upload_Status = 'Transferred file to DB processing',
						Debug_Dev_Status = 'Transferred file to DB processing.',
						Updated_Date = getDate()
				WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
			</cfquery>	   
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
	<cfset useLakebaseForupdateOCRUploadLogUpdateTries = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForupdateOCRUploadLogUpdateTries>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#qGetOCRUploadExtracted.OCR_Upload_ID#"
			},
			{
				"debug_dev_status" = "Docparser is still processing the file and returning half the results.",
				"processtries" = "ProcessTries + 1",
				"updated_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateOCRUploadLogUpdateTries = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLogUpdateTries>
<cfquery name="updateOCRUploadLogUpdateTries" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log 
				SET 
					Debug_Dev_Status = 'Docparser is still processing the file and returning half the results.',
					ProcessTries = ProcessTries + 1,
					Updated_Date = getDate()
			WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
	</cfquery>
</cfif>	
</cfif> 
  
</cfoutput>	