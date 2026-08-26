<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/inc_PFG_OT1.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  01-Jun-17
Created By   :  Anand Rao
Description  :  Include template for PFG OT1
---------------------------------------------------------------------------------->

<cfoutput>
<cfset isCompletelyParsed = 1 />

<cfset aryTotalRecLength = ArrayLen(structFileContent) />
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
 
		<cfif (NOT(ArrayIsEmpty(structFileContent)))>
			<cfquery name="qCreateTablePFGOT6" datasource="#application.datasource#">
			IF object_id('tempdb..##tblPFGOT6FileData') IS NOT NULL
					BEGIN	 
		                 DROP TABLE ##tblPFGOT6FileData
					END
				
				CREATE TABLE ##tblPFGOT6FileData
				(
					
					[Distributor_Location_Key_0] 		[varchar](max),
					[Document_ID] 						[varchar](max),			
					[File_Name]							[varchar](max),
					[ID]								[varchar](max),			
					[Invoice_Date]  					[varchar](max),
					[Item_Allowance]					[varchar](max),
					[Item_Alwqty]						[varchar](max),  
					[Item_Amount]						[varchar](max),
					[Item_Description]					[varchar](max),
					[Item_Invoice]						[varchar](max),
					[Item_Item_no]						[varchar](max),
					[Item_program_info]					[varchar](max),
					[Item_Row]							[varchar](max),
					[Item_Vend_item_no]					[varchar](max),
					[Media_Link]  						[varchar](max),
					[Page_Count]	  					[varchar](max),
					[Processed_At]  					[varchar](max),
					[Remote_ID]  						[varchar](max),
					[Totals_Amount]						[varchar](max),
					[Totals_Invoice_items]					[varchar](max),
					[Uploaded_at]						[varchar](max),
					[vb_ctl_match]						[varchar](max),
					[Vendor_Match]						[varchar](max),			
					[Year_Match]						[varchar](max),						
								
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
		
		<cfset catchValue = 0 />
		<cftry>
			<cfif (StructKeyExists(structFileContent[1], "item") AND (NOT isArray(structFileContent[1].item)))>
			 	<cfset structLineItems =  structFileContent[i].item />
				<cfset structFileContent[1].line_itemsNew = Arraynew(1) />
				<cfset structFileContent[1].line_itemsNew[1] = structLineItems />
				<cfset aryItemLength = ArrayLen(structFileContent[1].line_itemsNew) />
			<cfelse>	
				<cfset structLineItems =  structFileContent[1].item />
				<cfset structFileContent[1].line_itemsNew = Arraynew(1) />
				<cfset structFileContent[1].line_itemsNew = structLineItems />
				<cfset aryItemLength = ArrayLen(structFileContent[1].line_itemsNew) />
			</cfif>
			<cfcatch>
				<cfset Allowance = ""/>
				<cfset Alwqty = ""/>
				<cfset Amount = ""/>
				<cfset Description = ""/>
				<cfset Invoice = ""/>
				<cfset ItemNo = ""/>
				<cfset ProgramInfo = "" />
				<cfset Row = "" />
				<cfset VendItemNo = "" />
				<cfset aryItemLength = 1 />
				<cfset catchValue = 1 />
				<!--- in inside catch <cfdump var="#cfcatch.detail#" /><cfdump var="#cfcatch.message#" /> --->
			</cfcatch>				
		</cftry>

		<!--- <cfset aryItemLength = ArrayLen(structFileContent[1].item) /> --->
		<cfloop index = "i" from = "1" to = "#aryItemLength#">
			<cftry>
				<cfif (StructKeyExists(structFileContent[1],"distributor_location") AND (structFileContent[1].distributor_location.key_0 NEQ "undefined"))>
				 	<cfset DistributorLocation = structFileContent[1].distributor_location.key_0 />
				<cfelse>
					<cfset DistributorLocation = ""/>
				</cfif>
				<cfcatch>
					<cfset DistributorLocation = ""/>
				</cfcatch>
			</cftry>
				<cftry>
				<cfif (StructKeyExists(structFileContent[1],"invoice_date") AND (structFileContent[1].invoice_date.key_0 NEQ "undefined"))>
				 	<cfset InvoiceDate = structFileContent[1].invoice_date.key_0 />
				<cfelse>
					<cfset InvoiceDate = ""/>
				</cfif>
				<cfcatch>
					<cfset InvoiceDate = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"allowance") AND (structFileContent[1].line_itemsNew[i].allowance NEQ "undefined"))>
				 	<cfset Allowance = structFileContent[1].line_itemsNew[i].allowance />
				<cfelse>
					<cfset Allowance = ""/>
				</cfif>
				<cfcatch>
					<cfset Allowance = ""/>
				</cfcatch>
			</cftry>				
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"alwqty") AND (structFileContent[1].line_itemsNew[i].alwqty NEQ "undefined"))>
				 	<cfset Alwqty = structFileContent[1].line_itemsNew[i].alwqty />
				<cfelse>
					<cfset Alwqty = ""/>
				</cfif>
				<cfcatch>
					<cfset Alwqty = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"amount") AND (structFileContent[1].line_itemsNew[i].amount NEQ "undefined"))>
				 	<cfset Amount = structFileContent[1].line_itemsNew[i].amount />
				<cfelse>
					<cfset Amount = ""/>
				</cfif>
				<cfcatch>
					<cfset Amount = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"description") AND (structFileContent[1].line_itemsNew[i].description NEQ "undefined"))>
				 	<cfset Description = structFileContent[1].line_itemsNew[i].description />
				<cfelse>
					<cfset Description = ""/>
				</cfif>
				<cfcatch>
					<cfset Description = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"invoice") AND (structFileContent[1].line_itemsNew[i].invoice NEQ "undefined"))>
				 	<cfset Invoice = structFileContent[1].line_itemsNew[i].invoice />
				<cfelse>
					<cfset Invoice = ""/>
				</cfif>
				<cfcatch>
					<cfset Invoice = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"item_no") AND (structFileContent[1].line_itemsNew[i].item_no NEQ "undefined"))>
				 	<cfset ItemNo = structFileContent[1].line_itemsNew[i].item_no />
				<cfelse>
					<cfset ItemNo = ""/>
				</cfif>
				<cfcatch>
					<cfset ItemNo = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"program_info") AND (structFileContent[1].line_itemsNew[i].program_info NEQ "undefined"))>
				 	<cfset ProgramInfo = structFileContent[1].line_itemsNew[i].program_info />
				<cfelse>
					<cfset ProgramInfo = ""/>
				</cfif>
				<cfcatch>
					<cfset ProgramInfo = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"row") AND (structFileContent[1].line_itemsNew[i].row NEQ "undefined"))>
				 	<cfset Row = structFileContent[1].line_itemsNew[i].row />
				<cfelse>
					<cfset Row = ""/>
				</cfif>
				<cfcatch>
					<cfset Row = ""/>
				</cfcatch>
			</cftry>
			<cftry>
				<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"vend_item_no") AND (structFileContent[1].line_itemsNew[i].vend_item_no NEQ "undefined"))>
				 	<cfset VendItemNo = structFileContent[1].line_itemsNew[i].vend_item_no />
				<cfelse>
					<cfset VendItemNo = ""/>
				</cfif>
				<cfcatch>
					<cfset VendItemNo = ""/>
				</cfcatch>
			</cftry>	
	 	
			<cfquery name="qInsertTable" datasource="#application.datasource#">
					INSERT INTO ##tblPFGOT6FileData (
						Distributor_Location_Key_0,
						Document_ID,			
						File_Name,
						ID,			
						Invoice_Date,
						Item_Allowance,
						Item_Alwqty,  
						Item_Amount,
						Item_Description,
						Item_Invoice,
						Item_Item_no,
						Item_program_info,
						Item_Row,
						Item_Vend_item_no,
						Media_Link,
						Page_Count,
						Processed_At,
						Remote_ID,
						Totals_Amount,
						Totals_Invoice_items,
						Uploaded_at,
						vb_ctl_match,
						Vendor_Match,
						Year_Match,
						
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
							'#DistributorLocation#',
							'#structFileContent[1].document_id#',
							'#structFileContent[1].file_name#',
							'#structFileContent[1].id#',
							'#InvoiceDate#',
										
							'#Allowance#',
							'#Alwqty#',
							'#Amount#',
							'#Description#',
							'#Invoice#',
							'#ItemNo#',
							'#ProgramInfo#',						
							'#Row#',
							'#VendItemNo#',																														
							'#structFileContent[1].media_link#',
							'#structFileContent[1].page_count#',
							'#structFileContent[1].processed_at#',
							'#structFileContent[1].remote_id#',
							'#structFileContent[1].totals.amount#',
							'#structFileContent[1].totals.invoice_items#',
							'#structFileContent[1].uploaded_at#',
							'#structFileContent[1].vb_ctl.match#',
							'#structFileContent[1].vendor.match#',
							'#structFileContent[1].year.match#',
							
		 
							'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
							'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
							'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
							'#qGetOCRUploadExtracted.Source_Code#', /* 'PFG', OCR_Source, */
							'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
							'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
							'trackmax1', /* DB_OCR_Source_Code */
							'#qGetOCRUploadExtracted.OCR_Code#'
	      				)	 
				</cfquery>
				
			</cfloop>
	 		<cfset useLakebaseForqUpdateFileName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqUpdateFileName>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#qGetOCRUploadExtracted.OCR_Upload_ID#"
			},
			{
				"db_input_filename" = "#qGetOCRUploadExtracted.File_Name#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateFileName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateFileName>
<cfquery name="qUpdateFileName" datasource="#application.datasource#">
				UPDATE OCR_Upload_Log SET DB_Input_FileName = '#qGetOCRUploadExtracted.File_Name#' WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
			</cfquery>
</cfif>	
		
		<cfquery name="qSelPFGOT6FileDataCheck" datasource="#application.datasource#">
			SELECT * FROM ##tblPFGOT6FileData
		</cfquery>
		
		<cfif (qSelPFGOT6FileDataCheck.RecordCount NEQ 0)>
	 
			   <cfquery name="qInsertPermTable" datasource="#application.datasource#">	
			 	INSERT INTO OCR_Trackmax1_Excel_Format
				(
					Distributor_Location, -- Map it to Distributor_Location
					Invoice_Date, -- Map it to Invoice_Date
					--Item_Allowance, -- Map it to Item_Allowance
					Item_Quantity,
					Item_Amount, -- Map it to Item_Amount
					Item_Description,
					--Item_Invoice,
					Item_DID, 
					--Program_Information, 
					Item_Row_Number, -- Map it to Item_Row_ID
					--Item_Vendor,
					Page_Count,
	
					--Total_Amount, 
					--Total_Invoice_Items, /*-- Map it to Total_Avg_Each*/
					Item_Customer_Name, -- Map it to MFG_Info              
					
					/* OCR SETTING FIELDS */
					OCR_Upload_ID,
					OCR_Input_FileName_Raw, -- Populate pdf filename
					DB_OCR_Source_Code_FileName, -- Populate pdf filename
					OCR_Source, -- 'PFG',
					BB_Claim_Source_XREF_ID,
					OCR_Template_Settings_ID,
					DB_OCR_Source_Code,
					OCR_Code  
					)
				SELECT 	
					Distributor_Location_Key_0, -- Map it to Distributor_Location
					Invoice_Date, -- Map it to Invoice_Date
					--Item_Allowance     , -- Map it to Item_Allowance
					Item_Alwqty , -- Map it to Item_Quantity 
					Item_Amount , -- Map it to Item_Amount 
					Item_Description, -- Map it to Item_Description 
					--Item_Invoice, -- Map it to Item_Invoice
					Item_Item_no, -- Map it to Item
				--	Item_program_info, -- Map it to Program_Info
					Item_Row, -- Map it to Item_Row_ID
					--Item_Vend_item_no, -- Map it to Item_Vendor
					Page_Count, -- Map it to Page_Count
					--Totals_Amount, -- Map it to Total_Amount
					--Totals_Invoice_items, -- Map it to Total_Invoice_Items
					Vendor_Match, -- Map it to MFG_Info                                  
					OCR_Upload_ID,
					OCR_Input_FileName_Raw,
					DB_OCR_Source_Code_FileName,
					OCR_Source,
					BB_Claim_Source_XREF_ID,
					OCR_Template_Settings_ID,
					DB_OCR_Source_Code,
					OCR_Code
				FROM
					##tblPFGOT6FileData 
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
		</cfif> <!--- END: <cfif (qSelPFGOT6FileDataCheck.RecordCount NEQ 0)> --->
	
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
				"debug_dev_status" = "The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.",
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
					Debug_Dev_Status = 'The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.',
					Updated_Date = getDate(),
					Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type.'
				WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
		</cfquery>
</cfif> 
	</cfif> <!--- END: 	<cfif (StructKeyExists(structFileContent[1], "distributor_location")  AND --->
<cfelse>
	<cfquery name="updateOCRUploadLogUpdateTries" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log 
				SET 
					Debug_Dev_Status = 'Docparser is still processing the file and returning half the results.',
					ProcessTries = ProcessTries + 1,
					Updated_Date = getDate()
			WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
	</cfquery>	
 </cfif> <!--- <cfif (isCompletelyParsed EQ 1)>	 ---> 				
			
</cfoutput>