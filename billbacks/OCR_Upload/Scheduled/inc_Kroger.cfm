<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/inc_Kroger.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  06-Sep_2017
Created By   :  Anand Rao
Description  :  Kroger parser handling
----------------------------------------------------------------------------------> 
 
<cfset isCompletelyParsed = 1 />
<!--- for JSON structure --->
<cfoutput>
	<cfquery name="qCreateTableKroger" datasource="#application.datasource#">
	IF object_id('tempdb..##tblKrogerFileData') IS NOT NULL
			BEGIN	 
                 DROP TABLE ##tblKrogerFileData
			END
		
		CREATE TABLE ##tblKrogerFileData
		(
			
			[BB_End_Date_Formatted] 			[varchar](max),
			[BB_Start_Date]						[varchar](max),
			[Billback_Date_Formatted] 			[varchar](max),
			[Customer_Reference_Number] 		[varchar](max),
			[Distributor_ID_Key_0]				[varchar](max),
			[Document_ID] 						[varchar](max),
			[File_Name]							[varchar](max),
			[ID] 								[varchar](max),
			[Item_Amount] 						[varchar](max),
			[Item_Description] 					[varchar](max),
			[Item_Number] 						[varchar](max),
			[Item_Qty] 							[varchar](max),
			[Item_Row] 							[varchar](max),
			[Item_Rate] 						[varchar](max),
			[Item_Distributor_ID]				[varchar](max), 
			
			[Item_UPC] 							[varchar](max),			
			[Media_Link] 						[varchar](max),
			[Media_Link_Data] 					[varchar](max),
			[Media_Link_Original] 				[varchar](max),
			[Page_Count] 						[varchar](max),
			[Processed_at] 						[varchar](max),
			[Program_ID_Key_0] 					[varchar](max),
			[Remote_ID] 						[varchar](max),
			[Uploaded_At] 						[varchar](max),			
				
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
 
	<!--- <cfdump var="#structFileContent#" /> <br>  --->
			
	<cfset aryTotalRecLength = ArrayLen(structFileContent) />
	<cfset pageCount	= 0 />
<cfloop index = "iLoop" from = "1" to = "#aryTotalRecLength#">
	<!--- <cfdump var="#structFileContent[iLoop].processed_at#" /><br> --->
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
	
		<cfif (StructKeyExists(structFileContent[i], "item") AND (NOT isArray(structFileContent[i].item)) AND StructKeyExists(structFileContent[i].item,"amount"))>
		 	<cfset structItems =  structFileContent[i].item />
			<cfset structFileContent[i].itemNew = Arraynew(1) />
			<cfset structFileContent[i].itemNew[1] = structItems />
		<cfelse>	
			<cfset structItems =  structFileContent[i].item />
			<cfset structFileContent[i].itemNew = Arraynew(1) />
			<cfset structFileContent[i].itemNew = structItems />
		</cfif>

 		<cfset aryItemLength = ArrayLen(structFileContent[i].itemNew) />
		<cfloop index = "j" from = "1" to = "#aryItemLength#">
			<!--- <cfif (StructKeyExists(structFileContent[i], "customer_reference_number")  AND
					StructKeyExists(structFileContent[i], "distributor_id")  AND
					StructKeyExists(structFileContent[i], "bb_end_date")  AND
					StructKeyExists(structFileContent[i], "billback_date")  AND
					StructKeyExists(structFileContent[i], "program_id")  AND

	   				StructKeyExists(structFileContent[i], "item") AND
					StructKeyExists(structFileContent[i], "processed_at")  AND structFileContent[i].processed_at NEQ "undefined"
					)> --->
 				<!--- <cftry>
					<cfif (StructKeyExists(structFileContent[i],"bb_end_date") AND (structFileContent[i].bb_end_date.key_0 NEQ "undefined"))>
					 	<cfset BB_Start_Date = dateadd("d","-6",createBrowserDate(structFileContent[i].bb_end_date.key_0))/>
					<cfelse>
						<cfset BB_Start_Date = ""/>
					</cfif>
					<cfcatch>
						<cfset BB_Start_Date = ""/>
					</cfcatch>
				</cftry>  --->
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
					<cfif (StructKeyExists(structFileContent[i],"end_date") AND (structFileContent[i].end_date.key_0 NEQ "undefined"))>
					 	<cfset EndDate = structFileContent[i].end_date.key_0 />
					<cfelse>
						<cfset EndDate = ""/>
					</cfif>
					<cfcatch>
						<cfset EndDate = ""/>
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
					<cfif (StructKeyExists(structFileContent[i],"program_id") AND (structFileContent[i].program_id.key_0 NEQ "undefined"))>
					 	<cfset ProgramInfo = structFileContent[i].program_id.key_0 />
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
					<cfif (StructKeyExists(structFileContent[i].item[j],"distributor_id") AND (structFileContent[i].item[j].distributor_id NEQ "undefined"))>
					 	<cfset DistributorID = structFileContent[i].item[j].distributor_id />
					<cfelse>
						<cfset DistributorID = ""/>
					</cfif>
					<cfcatch>
						<cfset DistributorID = ""/>
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
 				<cftry>
					<cfif (StructKeyExists(structFileContent[i].item[j],"upc") AND (structFileContent[i].item[j].upc NEQ "undefined"))>
					 	<cfset UPC = structFileContent[i].item[j].upc />
					<cfelse>
						<cfset UPC = ""/>
					</cfif>
					<cfcatch>
						<cfset UPC = ""/>
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
 <!--- <cfdump var="#EndDate#" /> --->
	<cfquery name="qInsertTable" datasource="#application.datasource#">
				DECLARE 
				@BBStartDate DATE,
				@BBEndDate DATE,
				@newdate DATE
				
				SET @BBEndDate = '#EndDate#'
				SET @newdate = CONVERT(varchar(10), @BBEndDate, 101)
				SET @BBStartDate = DATEADD(day,-6,@newdate)  
	
				INSERT INTO ##tblKrogerFileData (
					BB_End_Date_Formatted,
					BB_Start_Date,
					Billback_Date_Formatted,
					Customer_Reference_Number,
					Distributor_ID_Key_0,
					Document_ID,
					File_Name,
					ID,
					Item_Amount,
					Item_Description,
					Item_Number,
					Item_Qty,
					Item_Row,
					Item_UPC,
					Item_Rate,
					Item_Distributor_ID,
					Media_Link,
					Media_Link_Data,
					Media_Link_Original,
					Page_Count,
					Processed_at,
					Program_ID_Key_0,
					Remote_ID,
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
						'#EndDate#',
						@BBStartDate,
						'#InvoiceDate#',
						'#CustomerReferenceNumber#',
						'#DistributorID#',
						'#structFileContent[i].document_id#',
						'#structFileContent[i].file_name#',
						'#structFileContent[i].id#',
						'#Amount#',
						'#Description#',
						'#UPC#', /* '#ItemNumber#', */
						'#Qty#',
						'#Row#',
						'#UPC#',
						'#Rate#',
						'#ItemNumber#',
						'#structFileContent[i].Media_Link#',
						'#structFileContent[i].Media_Link_Data#',
						'#structFileContent[i].Media_Link_Original#',												
						'#structFileContent[i].Page_Count#',
						'#structFileContent[i].processed_at#',
						'#ProgramInfo#',
						'#structFileContent[i].remote_id#',
						'#structFileContent[i].uploaded_at#',
																		
						'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
						'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
						'#qGetOCRUploadExtracted.File_Name#', /* OCR_Input_FileName_Raw -- populate orignial uploaded file name from ocr_upload_log */
						'#qGetOCRUploadExtracted.Source_Code#', /* 'Kroger', OCR_Source, */
						'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
						'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
						'#qGetOCRUploadExtracted.DB_OCR_Source_Code#', /* DB_OCR_Source_Code */
						'#qGetOCRUploadExtracted.OCR_Code#'
					)	 
			</cfquery>
			<!--- </cfif> --->
		</cfloop>
		<cfset pageCount = pageCount + structFileContent[i].page_count />
	</cfloop>
 
 pageCount: <cfdump var="#pageCount#" />
<br>
 
 	<cfquery name="qSelSyscoFileDataCheck" datasource="#application.datasource#">
		SELECT * FROM ##tblKrogerFileData
	</cfquery>
	
	<!--- <cfquery name="qSelSyscoFileDataCheck" datasource="#application.datasource#">
		SELECT * FROM ##tblKrogerFileData WHERE 
			Customer_Reference_Number IS NOT NULL 
		AND Distributor_ID_Key_0 IS NOT NULL 
		AND BB_End_Date_Formatted IS NOT NULL  
		AND Item_Amount IS NOT NULL
		AND Item_Description IS NOT NULL
		AND Item_Qty IS NOT NULL
		AND Item_Rate IS NOT NULL
		AND Item_UPC IS NOT NULL
		AND Program_ID_Key_0 IS NOT NULL
	</cfquery> --->
<!---  <cfdump var="#qSelSyscoFileDataCheck#" />
 <cfabort> --->

<cfif (qSelSyscoFileDataCheck.RecordCount NEQ 0)>
		 <cfquery name="qInsertPermTable" datasource="#application.datasource#">	
		 	INSERT INTO OCR_Trackmax1_Excel_Format
			(
				Start_Date,
				End_Date,
				Invoice_Date,
				Customer_Reference_Number,
				Distributor_Location,
				Item_Amount,
				Item_Description,
				Item_Quantity,
				 
				Item_DID,
				Item_Row_number,
				Item_UPC,
				Item_Distributor_ID,
				Page_Count,
				Program_Information,
				Program_Number,
				Payee_Type_IND,
				Item_Rate,
				Trade_IND,
				Trade_Indicator,
				
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
				REPLACE(BB_Start_Date,'-',''),
				BB_End_Date_Formatted,
				Billback_Date_Formatted,
				Customer_Reference_Number,
				Distributor_ID_Key_0,
				Item_Amount,
				Item_Description,
				Item_Qty,
				Item_Number,
				Item_Row,
				Item_UPC,
				Item_Distributor_ID,
				Page_Count,
				Program_ID_Key_0,
				Program_ID_Key_0,
 				'',
				Item_Rate,
				'T',
				'T',
				
				OCR_Upload_ID,
				OCR_Input_FileName_Raw,
				DB_OCR_Source_Code_FileName,
				OCR_Source,
				BB_Claim_Source_XREF_ID,
				OCR_Template_Settings_ID,
				DB_OCR_Source_Code,
				'Kroger'
			FROM
				##tblKrogerFileData 
		</cfquery>
	 
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
</body>
</html>
 