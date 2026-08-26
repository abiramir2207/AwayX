 <!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/inc_PFG_OT8.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  21-Jun-17
Created By   :  Anand Rao
Description  :  Include template for Sysco OT1 & OT9
---------------------------------------------------------------------------------->
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
							[trackmax1_address]  [varchar](max), 
							[customer_reference_number]  [varchar](max), 
							[distributor_location]  [varchar](max), 
							[document_id]  [varchar](max), 
							[end_date]  [varchar](max), 
							[grand_total_amount]  [varchar](max),
							[grand_total_charges]  [varchar](max), 
							[grand_total_description]  [varchar](max), 
							[grand_total_quantity]  [varchar](max), 
							[grand_total_weight]  [varchar](max), 
							[header_amount_match]  [varchar](max), 
							[id]  [varchar](max), 
							[invoice_date]  [varchar](max), 
							[item_amount]  [varchar](max), 
							[item_brand]  [varchar](max), 
							[item_customer_id]  [varchar](max), 
							[item_customer_name]  [varchar](max), 
							[item_description]  [varchar](max), 
							[item_did]  [varchar](max), 
							[item_inv_date]  [varchar](max), 
							[item_inv_number]  [varchar](max), 
							[item_pack_size]  [varchar](max), 
							[item_product_id]  [varchar](max), 
							[item_program_amount]  [varchar](max), 
							[item_quantity]  [varchar](max), 
							[item_row_number]  [varchar](max),         
							[item_total_charges]  [varchar](max), 
							[item_total_weight]  [varchar](max), 
							[item_manufacturers_id]  [varchar](max), 
							[item_rate]  [varchar](max), 
							[item_upc]  [varchar](max), 
							
							[location_subtotal_amount]  [varchar](max), 
							[location_subtotal_charges]  [varchar](max), 
							[location_subtotal_description]  [varchar](max), 
							[location_subtotal_quantity]  [varchar](max), 
							[location_subtotal_weight]  [varchar](max), 
							[media_link]  [varchar](max),   
							[processed_at]  [varchar](max),
							[program_information]  [varchar](max),
							[remote_id]  [varchar](max), 
							[start_date]  [varchar](max), 
							[subtotal_amount]  [varchar](max), 
							[subtotal_charges]  [varchar](max), 
							[subtotal_description]  [varchar](max), 
							[subtotal_quantity]  [varchar](max), 
							[subtotal_weight]  [varchar](max), 
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
			<cfset ID = ""/>
			<cfset Qty = ""/>
			<cfset Manufacturer_ID = "" />
			<cfset Rate = "" />
			<cfset UPC = "" />
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
						<cfif (StructKeyExists(structFileContent[i],"distributor_location") AND (StructKeyExists(structFileContent[i]["distributor_location"],"key_0")) AND (structFileContent[i].distributor_location.key_0 NEQ "undefined"))>
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
						<cfif (StructKeyExists(structFileContent[i],"operator_id") AND (structFileContent[i].operator_id.key_0 NEQ "undefined"))>
						 	<cfset Operator_Id = structFileContent[i].operator_id.key_0 />
						<cfelse>
							<cfset Operator_Id = ""/>
						</cfif>
						<cfcatch>
							<cfset Operator_Id = ""/>
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
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"id") AND (structFileContent[i].line_itemsNew[j].id NEQ "undefined"))>
						 	<cfset ID = structFileContent[i].line_itemsNew[j].id />
						<cfelse>
							<cfset ID = ""/>
						</cfif>
						<cfcatch>
							<cfset ID = ""/>
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
						<cfif (StructKeyExists(structFileContent[i].line_itemsNew[j],"manufacturers_id") AND (structFileContent[i].line_itemsNew[j].manufacturers_id NEQ "undefined"))>
						 	<cfset Manufacturer_ID = structFileContent[i].line_itemsNew[j].manufacturers_id />
						<cfelse>
							<cfset Manufacturer_ID = ""/>
						</cfif>
						<cfcatch>
							<cfset Manufacturer_ID = ""/>
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
								item_product_id,
								item_customer_name,
								item_quantity,
								item_manufacturers_id,
								item_rate,
								item_upc,
								
								media_link,  
								processed_at,
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
							'#ID#',
							'#Operator_Id#',
							'#Qty#',
							'#Manufacturer_ID#',
							'#Rate#',
							'#UPC#',
							
							'#structFileContent[i].media_link#',
							'#structFileContent[i].processed_at#',
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
		
					<cfquery name="qUpdateFileName" datasource="#application.datasource#">
						UPDATE OCR_Upload_Log SET DB_Input_FileName = '#qGetOCRUploadExtracted.File_Name#' WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
					</cfquery>
		
					
 				</cfloop>
			 </cfif>  <!---  <cfif (NOT(ArrayIsEmpty(structFileContent)) AND StructKeyExists(structFileContent[i], "address")  AND  --->
		<cfset pageCount = pageCount + structFileContent[i].page_count />
	</cfloop>	
<!---  	CHECKING FOR THE Search_String to make sure it is PFG ---->
				<cfquery name="qSelPFGFileDataCheck" datasource="#application.datasource#">
					SELECT * FROM ##tblPFGFileData WHERE distributor_location IS NOT NULL AND customer_reference_number IS NOT NULL
					AND end_date IS NOT NULL
				</cfquery>  
			
<!--- <cfdump var="#qSelPFGFileDataCheck#" /> --->
				<cfif qSelPFGFileDataCheck.RecordCount GTE 1>
					<cfquery name="qInsertPermTable" datasource="#application.datasource#">	
				 		INSERT INTO OCR_Trackmax1_Excel_Format
						(
							 
							customer_reference_number,
							distributor_location,
							document_id,
							end_date,
							invoice_date,
							
							item_amount,
							item_description,
							item_DID,
							item_customer_name,
							item_quantity,
							Item_Manufacturer_ID,
							Item_Rate,
							Item_UPC,
							
							processed_at,  
							start_date,
							Trade_Ind,
							 
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
							
							item_amount,
							item_description,
							item_product_id,
							item_customer_name,
							item_quantity,
							item_manufacturers_id,
							item_rate,
							item_upc,
							
							processed_at,
							start_date,
							'', --- Trade_Indicator t means Program_Number is required

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
				<cfquery name="updateOCRUploadLogStatus5" datasource="#application.datasource#">
					UPDATE OCR_Upload_Log 
					SET 
						Debug_Dev_Status = 'Docparser is still processing the file and returning half the results.',
						ProcessTries = ProcessTries + 1,
						Updated_Date = getDate()
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
				</cfquery> 
			</cfif>  	<!---  <cfif (isCompletelyParsed EQ 1)> --->					
</cfoutput>