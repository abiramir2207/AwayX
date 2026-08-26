 <!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/inc_PFG_OT1.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  21-Jun-17
Created By   :  Anand Rao
Description  :  Include template for Sysco OT1 & OT9
---------------------------------------------------------------------------------->

<cfset isCompletelyParsed = 1 />

<cfquery name="qCreateTableSyscoOT1OT9" datasource="#application.datasource#">
	IF object_id('tempdb..##tblSYSCOOT1OT9FileData') IS NOT NULL
			BEGIN	 
                 DROP TABLE ##tblSYSCOOT1OT9FileData
			END
		
		CREATE TABLE ##tblSYSCOOT1OT9FileData
		(
			
			[Agreement_Number_Key_0] 		[varchar](max),
			[Customer_Reference_Key_0] 		[varchar](max),
			[Distributor_Key_0] 			[varchar](max),
			[Document_ID] 					[varchar](max),
			[End_Date_Key_0] 				[varchar](max),
			[File_name] 					[varchar](max),
			[ID] 							[varchar](max),
			[Invoice_Date_Key_0] 			[varchar](max),
			[Line_Items_Amount] 			[varchar](max),
			[Line_Items_Description] 		[varchar](max),
			[Line_Items_Item_Code] 			[varchar](max),
			[Line_Items_Qty] 				[varchar](max),
			[Line_Items_Row] 				[varchar](max),
			[Manufacturer_Key_0] 			[varchar](max),
			[Media_Link] 					[varchar](max),
			[Page_Count] 					[varchar](max),
			[Processed_At] 					[varchar](max),
			[Program_Dates_end_Date] 		[varchar](max),
			[Program_Dates_start_Date] 		[varchar](max),
			[Program_Info_Key_1] 			[varchar](max),
			[Program_Info_Key_2] 			[varchar](max),
			[Remote_ID] 					[varchar](max),
			[Start_Date_Key_0] 				[varchar](max),
			[Total_Amount_Key_0] 			[varchar](max),
			[Uploaded_At] 					[varchar](max),		
			
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
	
<cfset aryTotalRecLength = ArrayLen(structFileContent) />
<cfset pageCount	= 0 />
	<!--- CHECK IF ALL THE PAGES IN THE UPLOADED FILE HAS BEEN PROCESSED OR NOT --->
	<cfloop index = "iLoop" from = "1" to = "#aryTotalRecLength#">
		<cfif (StructKeyExists(structFileContent[iLoop], "line_items") AND StructKeyExists(structFileContent[iLoop],"processed_at") AND (structFileContent[iLoop].processed_at EQ "undefined" OR 
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
		<cfif (StructKeyExists(structFileContent[i], "line_items") AND (NOT isArray(structFileContent[i].line_items)))>
		 	<cfset structLineItems =  structFileContent[i].line_items />
			<cfset structFileContent[i].line_itemsNew = Arraynew(1) />
			<cfset structFileContent[i].line_itemsNew[1] = structLineItems />
		<cfelse>	
			<cfset structLineItems =  structFileContent[i].line_items />
			<cfset structFileContent[i].line_itemsNew = Arraynew(1) />
			<cfset structFileContent[i].line_itemsNew = structLineItems />
		</cfif>

 		<cfset aryItemLength = ArrayLen(structFileContent[i].line_itemsNew) />
		<cfloop index = "j" from = "1" to = "#aryItemLength#">
			<cfif (StructKeyExists(structFileContent[i], "line_items") )>
 				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"agreement_number") AND (structFileContent[i].agreement_number.key_0 NEQ "undefined"))>
					 	<cfset Agreement_Number = structFileContent[i].agreement_number.key_0 />
					<cfelse>
						<cfset Agreement_Number = ""/>
					</cfif>
					<cfcatch>
						<cfset Agreement_Number = ""/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"customer_reference") AND (structFileContent[i].customer_reference.key_0 NEQ "undefined"))>
					 	<cfset Customer_Reference = structFileContent[i].customer_reference.key_0 />
					<cfelse>
						<cfset Customer_Reference = ""/>
					</cfif>
					<cfcatch>
						<cfset Customer_Reference = ""/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"distributor") AND (structFileContent[i].distributor.key_0 NEQ "undefined"))>
					 	<cfset DisributorKey0 = structFileContent[i].distributor.key_0 />
					<cfelse>
						<cfset DisributorKey0 = ""/>
					</cfif>
					<cfcatch>
						<cfset DisributorKey0 = ""/>
					</cfcatch>
				</cftry>								
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"total_amount") AND (structFileContent[i].total_amount.key_0 NEQ "undefined"))>
					 	<cfset Total_AmountKey0 = structFileContent[i].total_amount.key_0 />
					<cfelse>
						<cfset Total_AmountKey0 = ""/>
					</cfif>
					<cfcatch>
						<cfset Total_AmountKey0 = ""/>
					</cfcatch>
				</cftry> 
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"program_dates") AND (structFileContent[i].program_dates.end_date NEQ "undefined"))>
					 	<cfset ProgramDatesEndDate = structFileContent[i].program_dates.end_date />
					<cfelse>
						<cfset ProgramDatesEndDate = ""/>
					</cfif>
					<cfcatch>
						<cfset ProgramDatesEndDate = ""/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"program_dates") AND (structFileContent[i].program_dates.start_date NEQ "undefined"))>
					 	<cfset ProgramDatesStartDate = structFileContent[i].program_dates.start_date />
					<cfelse>
						<cfset ProgramDatesStartDate = ""/>
					</cfif>
					<cfcatch>
						<cfset ProgramDatesStartDate = ""/>
					</cfcatch>
				</cftry>				 
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"invoice_date") AND (structFileContent[i].invoice_date.key_0 NEQ "undefined"))>
					 	<cfset InvoiceDate = structFileContent[i].invoice_date.key_0 />
					<cfelse>
						<cfset InvoiceDate = ""/>
					</cfif>
					<cfcatch>
						<cfset InvoiceDate = ""/>
					</cfcatch>
				</cftry> 
				<cftry>
					<cfif (StructKeyExists(structFileContent[i],"manufacturer") AND (structFileContent[i].manufacturer.key_0 NEQ "undefined"))>
					 	<cfset ManufacturerKey0 = structFileContent[i].manufacturer.key_0 />
					<cfelse>
						<cfset ManufacturerKey0 = ""/>
					</cfif>
					<cfcatch>
						<cfset ManufacturerKey0 = ""/>
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
					<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"amount") AND (structFileContent[i].line_itemsNew[j].amount NEQ "undefined"))>
					 	<cfset ItemAmount = structFileContent[i].line_itemsNew[j].amount />
					<cfelse>
						<cfset ItemAmount = ""/>
					</cfif>
					<cfcatch>
						<cfset ItemAmount = ""/>
					</cfcatch>
				</cftry> 						
						
				<cftry>
					<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"description") AND (structFileContent[i].line_itemsNew[j].description NEQ "undefined"))>
					 	<cfset ItemDescription = structFileContent[i].line_itemsNew[j].description />
					<cfelse>
						<cfset ItemDescription = ""/>
					</cfif>
					<cfcatch>
						<cfset ItemDescription = ""/>
					</cfcatch>
				</cftry>
				
				<cftry>
					<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"item_code") AND (structFileContent[i].line_itemsNew[j].item_code NEQ "undefined"))>
					 	<cfset ItemCode = structFileContent[i].line_itemsNew[j].item_code />
					<cfelse>
						<cfset ItemCode = ""/>
					</cfif>
					<cfcatch>
						<cfset ItemCode = ""/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"qty") AND (structFileContent[i].line_itemsNew[j].qty NEQ "undefined"))>
					 	<cfset ItemQty = structFileContent[i].line_itemsNew[j].qty />
					<cfelse>
						<cfset ItemQty = ""/>
					</cfif>
					<cfcatch>
						<cfset ItemQty = ""/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"row") AND (structFileContent[i].line_itemsNew[j].row NEQ "undefined"))>
					 	<cfset ItemRow = structFileContent[i].line_itemsNew[j].row />
					<cfelse>
						<cfset ItemRow = ""/>
					</cfif>
					<cfcatch>
						<cfset ItemRow = ""/>
					</cfcatch>
				</cftry>
				
				
	<cfquery name="qInsertTable" datasource="#application.datasource#">
				INSERT INTO ##tblSYSCOOT1OT9FileData (
					Agreement_Number_Key_0,
					Customer_Reference_Key_0,
					Distributor_Key_0,
					Document_ID,
					End_Date_Key_0,
					File_name,
					ID,
					Invoice_Date_Key_0,
					Line_Items_Amount,
					Line_Items_Description,
					Line_Items_Item_Code,
					Line_Items_Qty,
					Line_Items_Row,
					Manufacturer_Key_0,
					Media_Link,
					Page_Count,
					Processed_At,
					Program_Dates_start_Date,
					Program_Dates_end_Date,
					Program_Info_Key_1,
					Program_Info_Key_2,
					Remote_ID,
					Start_Date_Key_0,
					Total_Amount_Key_0,
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
						'#Agreement_Number#',
						'#Customer_Reference#',
						'#DisributorKey0#',
						'#structFileContent[i].document_id#',
						'#structFileContent[i].end_date.key_0#',
						'#structFileContent[i].file_name#',
						'#structFileContent[i].id#',
						'#InvoiceDate#',
						'#ItemAmount#',
						'#ItemDescription#',
						'#ItemCode#',
						'#ItemQty#',
						'#ItemRow#',
						'#ManufacturerKey0#',
						'#structFileContent[i].media_link#',
						'#structFileContent[i].page_count#',
						'#structFileContent[i].processed_at#',
						'#ProgramDatesStartDate#',
						'#ProgramDatesEndDate#',
						'#ProgramInfo#',
						'', /* structFileContent[i].program_info.key_2 */
						'#structFileContent[i].remote_id#',
						'#structFileContent[i].start_date.key_0#',
						'#Total_AmountKey0#',
						'#structFileContent[i].uploaded_at#',
						
						'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
						'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
						'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
						'#qGetOCRUploadExtracted.Source_Code#', /* 'SYSCO', OCR_Source, */
						'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
						'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
						'SYSCO_US_Operator_PDF', /* DB_OCR_Source_Code */
						'#qGetOCRUploadExtracted.OCR_Code#'
						
					)	 
	 
			</cfquery>
			</cfif>
		</cfloop>
		<cfset pageCount = pageCount + structFileContent[i].page_count />
	</cfloop>

<br>

 pageCount: <cfdump var="#pageCount#" />
<br>
 
<!---  	<cfquery name="qSelSyscoFileData" datasource="#application.datasource#">
		SELECT * FROM ##tblSYSCOOT1OT9FileData
	</cfquery> --->
	
	<cfquery name="qSelSyscoFileDataCheck" datasource="#application.datasource#">
		SELECT * FROM ##tblSYSCOOT1OT9FileData
	</cfquery>
 <!--- <cfdump var="#qSelSyscoFileDataCheck#" /> --->
 
<cfif (qSelSyscoFileDataCheck.RecordCount NEQ 0)>
 
		<cfquery name="qInsertPermTable" datasource="#application.datasource#">	
		 	INSERT INTO OCR_SYSCO_US_Operator_PDF_Excel_Format
			(
				Agreement_Number,
				Invoice_Number,
				Distributor_Location,
				Start_Date,
				End_Date,
				Invoice_Date,
				Line_Items_Amount,
				Line_Items_Description,
				Line_Items_Item_Code,
				Line_Items_Qty,
				Line_Items_Row,
				MFG_Info,
				Page_Count,
				Program_Start_Date,
				Program_End_Date,
				Program_Info_ID,
				Program_Info,
				Total_Amount,
				
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
				Agreement_Number_Key_0,
				Customer_Reference_Key_0,
				Distributor_Key_0,
				Start_Date_Key_0,
				End_Date_Key_0,
				Invoice_Date_Key_0,
				Line_Items_Amount,
				Line_Items_Description,
				Line_Items_Item_Code,
				Line_Items_Qty,
				Line_Items_Row,
				Manufacturer_Key_0,
				Page_Count,
				Program_Dates_start_Date,
				Program_Dates_end_Date,
				Program_Info_Key_2,
				Program_Info_Key_1,
 				Total_Amount_Key_0,
				
				OCR_Upload_ID,
				OCR_Input_FileName_Raw,
				DB_OCR_Source_Code_FileName,
				OCR_Source,
				BB_Claim_Source_XREF_ID,
				OCR_Template_Settings_ID,
				DB_OCR_Source_Code,
				OCR_Code
			FROM
				##tblSYSCOOT1OT9FileData 
		</cfquery>      
		
 
	<cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log 
			SET 
				/* Pages_Extracted = '#pageCount#', */
				OCR_Step = '4',
				OCR_Upload_Status = 'Transferred file to DB processing',
				Debug_Dev_Status = 'Transferred file to DB processing. DBLocation "#DBDest#"',
				Updated_Date = getDate()
		WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
	</cfquery>	  

<cfelse>
	  <cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log 
						SET 
							OCR_Step = '2.CF_Error',
							OCR_Upload_Status = 'Data mismatch between the file and the Docparser template. ',
							Debug_Dev_Status = 'Error from inc_Sysco_OT1_OT9.cfm. The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.',
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
 