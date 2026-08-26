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
		<cfquery name="qCreateTablePFGOT1" datasource="#application.datasource#">
			IF object_id('tempdb..##tblPFGOT1FileData') IS NOT NULL
				BEGIN	 
	                 DROP TABLE ##tblPFGOT1FileData
				END
			
			CREATE TABLE ##tblPFGOT1FileData
			(
				
				[Distributor_Location_Key_0] 		[varchar](max),
				[Document_ID] 						[varchar](max),			
				[End_Date_Key_0]					[varchar](max),
				[File_Name]							[varchar](max),
				[ID]								[varchar](max),			
				[Invoice_Date_Key_0]  				[varchar](max),
				
				[Item_Amount]						[varchar](max),
				[Item_Description]					[varchar](max),
				[Item_Number]						[varchar](max),
				[Item_Operator_ID]					[varchar](max),
				[Item_Qty]							[varchar](max),
				[Item_Row]							[varchar](max),
				[Item_Manufacturer_ID]				[varchar](max),
				[Item_UPC]							[varchar](max),				
				 
				[Media_Link]  						[varchar](max),
				[Page_Count]	  					[varchar](max),
				[Processed_At]  					[varchar](max),
				[Remote_ID]  						[varchar](max),
				[Start_Date_Key_0]					[varchar](max),
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
<!---		<cfif (StructKeyExists(structFileContent[1], "item") AND (NOT isArray(structFileContent[1].item)))>
			<cfset structLineItems =  structFileContent[1].item />
			<cfset structFileContent[1].item = Arraynew(1) />
			<cfset structFileContent[1].item[1] = structLineItems />
		</cfif> --->
		<cfset catchValue = 0 />
		<!--- <cfset aryItemLength = ArrayLen(structFileContent[1].item) /> --->
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
			<cfset Amount = ""/>
			<cfset Description = ""/>
			<cfset Number = ""/>
			<cfset Operator_Id = ""/>
			<cfset Qty = ""/>
			<cfset Row = ""/>
			<cfset Manufacturer_ID = ""/>
			<cfset UPC = ""/>
			
			<cfset aryItemLength = 1 />
			<cfset catchValue = 1 />
			in inside catch <cfdump var="#cfcatch.detail#" /><cfdump var="#cfcatch.message#" />
		</cfcatch>				
	</cftry>
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
			<cfif (StructKeyExists(structFileContent[1],"start_date") AND (structFileContent[1].start_date.key_0 NEQ "undefined"))>
			 	<cfset StartDate = structFileContent[1].start_date.key_0 />
			<cfelse>
				<cfset StartDate = ""/>
			</cfif>
			<cfcatch>
				<cfset StartDate = ""/>
			</cfcatch>
		</cftry>
		
		<cftry>
			<cfif (StructKeyExists(structFileContent[1],"end_date") AND (structFileContent[1].end_date.key_0 NEQ "undefined"))>
			 	<cfset EndDate = structFileContent[1].end_date.key_0 />
			<cfelse>
				<cfset EndDate = ""/>
			</cfif>
			<cfcatch>
				<cfset EndDate = ""/>
			</cfcatch>
		</cftry>

		<cfloop index = "i" from = "1" to = "#aryItemLength#">

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
			<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"number") AND (structFileContent[1].line_itemsNew[i].number NEQ "undefined"))>
			 	<cfset Number = structFileContent[1].line_itemsNew[i].number />
			<cfelse>
				<cfset Number = ""/>
			</cfif>
			<cfcatch>
				<cfset Number = ""/>
			</cfcatch>
		</cftry> 

		<cftry>
			<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"operator_id") AND (structFileContent[1].line_itemsNew[i].operator_id NEQ "undefined"))>
			 	<cfset Operator_Id = structFileContent[1].line_itemsNew[i].operator_id />
			<cfelse>
				<cfset Operator_Id = ""/>
			</cfif>
			<cfcatch>
				<cfset Operator_Id = ""/>
			</cfcatch>
		</cftry> 

		<cftry>
			<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"qty") AND (structFileContent[1].line_itemsNew[i].qty NEQ "undefined"))>
			 	<cfset Qty = structFileContent[1].line_itemsNew[i].qty />
			<cfelse>
				<cfset Qty = ""/>
			</cfif>
			<cfcatch>
				<cfset Qty = ""/>
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
			<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"manufacturer_id") AND (structFileContent[1].line_itemsNew[i].manufacturer_id NEQ "undefined"))>
			 	<cfset Manufacturer_ID = structFileContent[1].line_itemsNew[i].manufacturer_id />
			<cfelse>
				<cfset Manufacturer_ID = ""/>
			</cfif>
			<cfcatch>
				<cfset Manufacturer_ID = ""/>
			</cfcatch>
		</cftry> 
		 
			<cftry>
			<cfif (StructKeyExists(structFileContent[1].line_itemsNew[i],"upc") AND (structFileContent[1].line_itemsNew[i].upc NEQ "undefined"))>
			 	<cfset UPC = structFileContent[1].line_itemsNew[i].upc />
			<cfelse>
				<cfset UPC = ""/>
			</cfif>
			<cfcatch>
				<cfset UPC = ""/>
			</cfcatch>
		</cftry>
 			<cfquery name="qInsertTable" datasource="#application.datasource#">
				INSERT INTO ##tblPFGOT1FileData 
				(
					Distributor_Location_Key_0,
					Document_ID,			
					End_Date_Key_0,
					File_Name,
					ID,			
					Invoice_Date_Key_0,
					Item_Amount,
					Item_Description,
					Item_Number,
					Item_Operator_ID,
					Item_Qty,
					Item_Row,
					Item_Manufacturer_ID,
					Item_UPC,
					Media_Link,
					Page_Count,
					Processed_At,
					Remote_ID,
					Start_Date_Key_0,
					Uploaded_at,
										
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
					'#EndDate#',
					'#structFileContent[1].file_name#',
					'#structFileContent[1].id#',
					'#InvoiceDate#',
					'#Amount#',
					'#Description#',
					'#Number#',
					'#Operator_Id#',
					'#Qty#',
					'#Row#',
					'#Manufacturer_ID#',
					'#UPC#',
					'#structFileContent[1].media_link#',
					'#structFileContent[1].page_count#',
					'#structFileContent[1].processed_at#',
					'#structFileContent[1].remote_id#',
					'#StartDate#',
					'#structFileContent[1].uploaded_at#',

					'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
					'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
					'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
					'#qGetOCRUploadExtracted.Source_Code#', /* 'PFG', OCR_Source, */
					'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
					'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
					'Trackmax1', /* DB_OCR_Source_Code */
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
	
		<!---  	<cfquery name="qSelPFGOT1FileData" datasource="#application.datasource#">
			SELECT * FROM ##tblPFGOT1FileData
		</cfquery> --->
	
		<cfquery name="qSelPFGOT1FileDataCheck" datasource="#application.datasource#">
			SELECT * FROM ##tblPFGOT1FileData WHERE Distributor_Location_Key_0 IS NOT NULL AND Start_Date_Key_0 IS NOT NULL AND End_Date_Key_0 
			IS NOT NULL
		</cfquery>			
		<cfif (qSelPFGOT1FileDataCheck.RecordCount NEQ 0)>
 			<cfquery name="qInsertPermTable" datasource="#application.datasource#">	
		 	INSERT INTO OCR_Trackmax1_Excel_Format
			(
				Distributor_Location, -- Map it to Distributor_Location
				End_Date, -- Map it to End_Date
				Invoice_Date, -- Map it to Invoice_Date
				Item_Amount, -- Map it to Item_Amount
				Item_Description, -- Map it to Item_Description
				Item_DID, -- [Item_number] Map it to Item
				item_customer_name, -- [Item_Operator_ID] Map it to item_customer_name. 
				Item_Quantity, --[Item_Qty] Map it to Item_Quantity
				Item_Row_Number, -- [Item_Row] Map it to Item_Row_ID
				Item_Manufacturer_ID,
				Item_UPC,
				Page_Count, /*-- Map it to Page_Count*/
				Start_Date, /*-- Map it to Start_Date*/
				
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
				End_Date_Key_0, -- Map it to End_Date
				Invoice_Date_Key_0, -- Map it to Invoice_Date
				Item_Amount, -- Map it to Item_Amount
				Item_Description, -- Map it to Program_Info. This contains Bid Info. 
				Item_Number, -- Map it to Item
				Item_Operator_ID, -- [Item_Operator_ID] Map it to Program_Info. 
				Item_Qty, -- Map it to Item_Quantity
				Item_Row, -- Map it to Item_Row_ID
				Item_Manufacturer_ID,
				Item_UPC,
				Page_Count, -- Map it to Page_Count
				Start_Date_Key_0, -- Map it to Start_Date
					
				OCR_Upload_ID,
				OCR_Input_FileName_Raw,
				DB_OCR_Source_Code_FileName,
				OCR_Source,
				BB_Claim_Source_XREF_ID,
				OCR_Template_Settings_ID,
				DB_OCR_Source_Code,
				OCR_Code
			FROM
				##tblPFGOT1FileData 
		</cfquery>    
 
		<cfquery name="updateOCRUploadLogStatus4" datasource="#application.datasource#">
			UPDATE OCR_Upload_Log 
				SET 
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
						Debug_Dev_Status = 'The parser failed to return the data. The data location are not correct in the file and did not match the docparser template.',
						Updated_Date = getDate(),
						Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type.'
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
			</cfquery> 
		</cfif> <!--- <cfif (qSelPFGOT1FileDataCheck.RecordCount NEQ 0)> --->
	<cfelse>
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
	</cfif> <!--- <cfif (StructKeyExists(structFileContent[1], "distributor_location")  AND  --->

<cfelse>
	<cfquery name="updateOCRUploadLogUpdateTries" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log 
				SET 
					Debug_Dev_Status = 'Docparser is still processing the file and returning half the results.',
					ProcessTries = ProcessTries + 1,
					Updated_Date = getDate()
			WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
	</cfquery>	
 </cfif>  <!--- <cfif (isCompletelyParsed EQ 1)>	 --->

</cfoutput>					