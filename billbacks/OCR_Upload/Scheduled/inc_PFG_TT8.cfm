<!-----------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/inc_PFG_TT8.cfm
Copyright    :  (c) 2018 Blacksmith Applications, Inc.
Created Date :  09-May-2018
Created By   :  Anand Rao
Description  :  Include template for PFG TT8
------------------------------------------------------------------------------->
in inc_PFG_TT8.cfm
<cfoutput>
<cfset isCompletelyParsed = 1 />
<cfset aryTotalRecLength = ArrayLen(structFileContent) />
<cfset pageCount	= 0 />
	<cfquery name="qCreateTable" datasource="#application.datasource#">
						IF object_id('tempdb..##tblPFGFileData') IS NOT NULL
						BEGIN
			    	    	DROP TABLE ##tblPFGFileData
						END	
						CREATE TABLE ##tblPFGFileData
						(
							[customer_reference_number]  [varchar](max), 
							[distributor_location]  [varchar](max), 
							[document_id]  [varchar](max), 
							[end_date]  [varchar](max), 
							[id]  [varchar](max), 
							[invoice_date]  [varchar](max), 
							[item_amount]  [varchar](max), 
							[item_description]  [varchar](max), 
							[item_distributor_id]  [varchar](max), 
							[item_manufacture_id]  [varchar](max), 
							[item_qty]  [varchar](max), 
							[item_rate]  [varchar](max), 
							[item_upc]  [varchar](max), 
							[item_weight]  [varchar](max), 
							
							[media_link]  [varchar](max),   
							[processed_at]  [varchar](max),
							[program_number]  [varchar](max),
							[remote_id]  [varchar](max), 
							[start_date]  [varchar](max), 
							[uploaded_at]  [varchar](max),
							
							[OCR_Upload_ID]  [varchar](max), 
							[OCR_Input_FileName_Raw]  [varchar](max), 
							[DB_OCR_Source_Code_FileName]  [varchar](max), 
							[OCR_Source]  [varchar](max), 
							[BB_Claim_Source_XREF_ID]  [varchar](max), 
							[OCR_Template_Settings_ID]  [varchar](max), 
							[DB_OCR_Source_Code]  [varchar](max),
						 	[OCR_Code]  [varchar](max)
						)
		</cfquery>
		
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
			<cfset Distributor_ID = ""/>
			<cfset Manufacture_ID = ""/>
			<cfset Qty = ""/>
			<cfset Rate = ""/>
			<cfset UPC = ""/>
			<cfset Weight = ""/>
			<cfset aryItemLength = 1 />
			<cfset catchValue = 1 />
			in inside catch <cfdump var="#cfcatch.detail#" /><cfdump var="#cfcatch.message#" />
		</cfcatch>				
	</cftry>		
		
	<!--- HANDLE WHEN THE WRONG FILE IS UPLOAD TO THE DOCPARSER AND DOCPARSER SEND DATA AS "UNDEFINED" --->
		<!--- <cfset aryItemLength = ArrayLen(structFileContent[i].item) /> --->
		<!--- <cfloop index = "j" from = "1" to = "#aryItemLength#"> --->
<!--- 		<cfset arySubtotalLength = ArrayLen(structFileContent[1].subtotal) />		 --->
		 
		<cfif (NOT(ArrayIsEmpty(structFileContent)))>
			<cfset insNullSubtotal = 1/>
		<!--- 	 <cfdump var='#structFileContent#' output='c:\dumpot8.log'>  --->
				<cfloop index = "j" from = "1" to = "#aryItemLength#">
				
	 				<cftry>
						<cfif (StructKeyExists(structFileContent[i],"customer_reference_number") AND (structFileContent[i].customer_reference_number.match NEQ "undefined"))>
						 	<cfset Customer_Reference_Number = structFileContent[i].customer_reference_number.match />
						<cfelse>
							<cfset Customer_Reference_Number = ""/>
						</cfif>
						<cfcatch>
							<cfset Customer_Reference_Number = ""/>
						</cfcatch>
					</cftry> 				
				
					<cftry>
						<cfif (StructKeyExists(structFileContent[i],"distributor_location") AND (structFileContent[i].distributor_location.key_0 NEQ "undefined"))>
						 	<cfset Distributor_Location = structFileContent[i].distributor_location.key_0 />
						<cfelse>
							<cfset Distributor_Location = ""/>
						</cfif>
						<cfcatch>
							<cfset Distributor_Location = ""/>
						</cfcatch>
					</cftry> 				

	 				<cftry>
						<cfif (StructKeyExists(structFileContent[i],"end_date") AND (structFileContent[i].end_date.formatted NEQ "undefined"))>
						 	<cfset End_Date = structFileContent[i].end_date.formatted />
						<cfelse>
							<cfset End_Date = ""/>
						</cfif>
						<cfcatch>
							<cfset End_Date = ""/>
						</cfcatch>
					</cftry> 
										
	 				<cftry>
						<cfif (StructKeyExists(structFileContent[i],"invoice_date") AND (structFileContent[i].invoice_date.formatted NEQ "undefined"))>
						 	<cfset Invoice_Date = structFileContent[i].invoice_date.formatted />
						<cfelse>
							<cfset Invoice_Date = ""/>
						</cfif>
						<cfcatch>
							<cfset Invoice_Date = ""/>
						</cfcatch>
					</cftry> 

	 				<cftry>
						<cfif (StructKeyExists(structFileContent[i],"start_date") AND (structFileContent[i].start_date.formatted NEQ "undefined"))>
						 	<cfset Start_Date = structFileContent[i].start_date.formatted />
						<cfelse>
							<cfset Start_Date = ""/>
						</cfif>
						<cfcatch>
							<cfset Start_Date = ""/>
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
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"distributor_id") AND (structFileContent[i].line_itemsNew[j].distributor_id NEQ "undefined"))>
						 	<cfset Distributor_ID = structFileContent[i].line_itemsNew[j].distributor_id />
						<cfelse>
							<cfset Distributor_ID = ""/>
						</cfif>
						<cfcatch>
							<cfset Distributor_ID = ""/>
						</cfcatch>
					</cftry>
					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"manufacture_id") AND (structFileContent[i].line_itemsNew[j].manufacture_id NEQ "undefined"))>
						 	<cfset Manufacture_ID = structFileContent[i].line_itemsNew[j].manufacture_id />
						<cfelse>
							<cfset Manufacture_ID = ""/>
						</cfif>
						<cfcatch>
							<cfset Manufacture_ID = ""/>
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
					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"rate") AND (structFileContent[i].line_itemsNew[j].rate NEQ "undefined"))>
						 	<cfset Rate = structFileContent[i].line_itemsNew[j].rate />
						<cfelse>
							<cfset Rate = ""/>
						</cfif>
						<cfcatch>
							<cfset Rate = ""/>
						</cfcatch>
					</cftry>	
					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"upc") AND (structFileContent[i].line_itemsNew[j].upc NEQ "undefined"))>
						 	<cfset UPC = structFileContent[i].line_itemsNew[j].upc />
						<cfelse>
							<cfset UPC = ""/>
						</cfif>
						<cfcatch>
							<cfset UPC = ""/>
						</cfcatch>
					</cftry>	
					<cftry>
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"weight") AND (structFileContent[i].line_itemsNew[j].weight NEQ "undefined"))>
						 	<cfset Weight = structFileContent[i].line_itemsNew[j].weight />
						<cfelse>
							<cfset Weight = ""/>
						</cfif>
						<cfcatch>
							<cfset Weight = ""/>
						</cfcatch>
					</cftry>										
					<cftry>
						<cfif (StructKeyExists(structFileContent[i],"program_number") AND (structFileContent[i].program_number.key_0 NEQ "undefined"))>
						 	<cfset Program_Number = structFileContent[i].program_number.key_0 />
						<cfelse>
							<cfset Program_Number = ""/>
						</cfif>
						<cfcatch>
							<cfset Program_Number = ""/>
						</cfcatch>
					</cftry> 	
				
					<cfquery name="qInsertTable" datasource="#application.datasource#">	
						INSERT INTO ##tblPFGFileData (
								customer_reference_number,
								distributor_location,
								document_id,
								end_date,
								id,
								invoice_date,
								item_amount,
								item_description,
								item_distributor_id,
								item_manufacture_id,
								item_qty,
								item_rate,
								item_upc,
								item_weight,
								
								media_link,  
								processed_at,
								program_number,
								remote_id,
								start_date,
 								uploaded_at,
								
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
							'#Customer_Reference_Number#',
							'#Distributor_Location#',
							'#structFileContent[i].document_id#',
							'#End_Date#',
							'#structFileContent[i].id#',			
							'#Invoice_Date#',
							'#Amount#',
							'#Description#',
							'#Distributor_ID#',
							'#Manufacture_ID#',
							'#Qty#',
							'#Rate#',
							'#UPC#',
							'#Weight#',
							
							'#structFileContent[i].media_link#',
							'#structFileContent[i].processed_at#',
							'#Program_Number#',
							'#structFileContent[i].remote_id#',
							'#Start_Date#',
							'#structFileContent[1].uploaded_at#',
							
							'#qGetOCRUploadExtracted.OCR_Upload_ID#', /* -- uploadID */
							'#qGetOCRUploadExtracted.File_Name#',
							'#qGetOCRUploadExtracted.File_Name#',
							'#qGetOCRUploadExtracted.Source_Code#',	/* 'PFG', */
							'#qGetOCRUploadExtracted.BB_Claim_Source_XREF_ID#', 	/* -- BB_Claim_Source_XREF_ID, */
							'#qGetOCRUploadExtracted.OCR_Template_Settings_ID#',	/* -- OCR_Template_Settings_ID */
							'Trackmax1',
							'#qGetOCRUploadExtracted.OCR_Code#' /* 'PFG_OT8_TESTING'  */ 					
						)
					</cfquery>
		
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
		
					
 				</cfloop>
			 </cfif>  <!---  <cfif (NOT(ArrayIsEmpty(structFileContent)) AND StructKeyExists(structFileContent[i], "address")  AND  --->
		<cfset pageCount = pageCount + structFileContent[i].page_count />
	</cfloop>	
<!---  	CHECKING FOR THE Search_String to make sure it is PFG ---->
				<cfquery name="qSelPFGFileDataCheck" datasource="#application.datasource#">
					SELECT * FROM ##tblPFGFileData
				</cfquery>  
			
  <cfdump var="#qSelPFGFileDataCheck#" />  
				<cfif qSelPFGFileDataCheck.RecordCount GTE 1>
					<cfquery name="qInsertPermTable" datasource="#application.datasource#">	
				 		INSERT INTO OCR_Trackmax1_Excel_Format
						(
							 
							customer_reference_number,
							distributor_location,
							document_id,
							end_date,
							invoice_date,
							item_did,
							Item_amount,
							Item_description,
							Item_Distributor_ID,
							Item_Manufacturer_ID,
							Item_Quantity,
							Item_Rate,
							Item_UPC,
							Item_Total_Weight,
		  
							processed_at,  
							Program_Information, 
							start_date,
							
							Trade_IND, 
							uploaded_at,
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
							customer_reference_number,
							distributor_location,
							document_id,
							end_date,
							invoice_date,
							item_distributor_ID,
							item_amount,
							item_description,
							item_distributor_ID,
							item_manufacture_ID,
							item_qty,
							item_rate,
							item_upc,
							item_weight,
							
							processed_at,
							program_number,
							start_date,
							
							'T',
 							uploaded_at,
							OCR_Upload_ID,
							OCR_Input_FileName_Raw,
							DB_OCR_Source_Code_FileName,
							OCR_Source,
							BB_Claim_Source_XREF_ID,
							OCR_Template_Settings_ID,
							DB_OCR_Source_Code,
							OCR_Code
						FROM
							##tblPFGFileData 
					</cfquery> 
					
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
					<cffile action="move" source="#postPDFFile#" destination="#archiveLocation#">
				<cfelse>
					<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
							UPDATE OCR_Upload_Log 
								SET 
									OCR_Step = '2.CF_Error',
									OCR_Upload_Status = 'The Search string is not found in the distributor_location column from the Docparser',
									Debug_Dev_Status = 'The Search string is not found in the distributor_location column from the Docparser',
									Updated_Date = getDate(),
									Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type.'
							WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
						</cfquery>	
				</cfif>	<!--- END: <cfif qSelPFGFileDataCheck.RecordCount GTE 1> --->
	
			<cfelse>
				<cfset useLakebaseForupdateOCRUploadLogStatus5 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForupdateOCRUploadLogStatus5>
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
			<cfset useLakebaseForupdateOCRUploadLogStatus5 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLogStatus5>
<cfquery name="updateOCRUploadLogStatus5" datasource="#application.datasource#">
					UPDATE OCR_Upload_Log 
					SET 
						Debug_Dev_Status = 'Docparser is still processing the file and returning half the results.',
						ProcessTries = ProcessTries + 1,
						Updated_Date = getDate()
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
				</cfquery>
</cfif> 
			</cfif>  	<!---  <cfif (isCompletelyParsed EQ 1)> --->					
</cfoutput>