<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/inc_OCR_Insert_Copy.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Upload from home page
---------------------------------------------------------------------------------->
<cfif FORM.Amount EQ "">
						<cfset FORM.Amount = 0 />
					<cfelse>
						<cfset FORM.Amount = Replace(Replace(FORM.Amount,',','','ALL'),'$','','ALL') />
					</cfif>
					<cfquery name="qInsOCRUploadLog" datasource="#application.datasource#">
						DECLARE  @upload_id int, 
		           		 @Upload_date datetime,
		          		 @User_id varchar(50),
				         @File_name varchar(255),
						 @File_ext varchar(15)
				
					    SET @upload_date = getdate()
				      	SET @User_id = '#request.AccessStructure.user_id#'
				      	SET @File_name = '#strFileName#'
						SET @File_ext = '#FileExt#'
							<!--- <cfloop from="1" to="#arrayLen(variables.upload)#" index="variables.index"> --->
							  INSERT INTO	
							  		OCR_Upload_Log
									(	 
										File_Name,
										Source_Template,
										Created_User_ID,
										OCR_Upload_Date,
										OCR_Upload_Status,
										upload_type,
										BB_Claim_Source_XRef_ID,
										OCR_Template_Settings_ID,
										OCR_Amount,
										File_Extension,
										File_Size,
										OCR_Step,
										DB_Input_FileName,
										Pages_Extracted,
										OCR_Upload_Test_Log_ID
									)
								VALUES	
									(	 
									    @File_name,
										NULL,
										@User_id,
										@Upload_date,
										'File is accepted in the system.', /* Uploaded.. Waiting for Text Reader */
										'', /* This will be the type */
										'#FORM.selSource#',
										'#FORM.selType#',
										'#FORM.Amount#',
										@File_ext,
										'#FileSize#',
										'1',
										'#strServerFileName#.txt',
										#TotalFilePages#,
										#OCRUploadTestLogID#
										)
			 					SELECT 
				  					OCR_Upload_ID 
				  				FROM 
				  					OCR_Upload_Log 
				 				WHERE Created_User_ID = @user_id AND OCR_Upload_Status = 'File is accepted in the system.' AND OCR_Upload_Date = @Upload_Date AND File_Name = @File_name AND Deleted = 0
				</cfquery>	
				<cfset OCRUploadID = qInsOCRUploadLog.OCR_Upload_ID />
			 
				<cfif (isDefined("URL.Testing") and URL.Testing EQ "1")>
					<cfset useLakebaseForqInsOCRUploadTestLogDetailSummary = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log_detail_summary")>
<cfif useLakebaseForqInsOCRUploadTestLogDetailSummary>
	<cftry>
		<cfset application.oLakebase.insertRow("ocr_upload_test_log_detail_summary", {
			"ocr_upload_test_log_id" = "#OCRUploadTestLogID#",
			"ocr_upload_id" = "#OCRUploadID#",
			"ocr_upload_testset_id" = "#OCRUploadTestSetID#",
			"ocr_step_expected" = "#OCRStepExpected#",
			"total_invoices_expected" = "#TotalInvoicesExpected#",
			"total_line_items_expected" = "#TotalLineItemsExpected#",
			"total_amount_expected" = "#TotalAmountExpected#",
			"total_quantity_expected" = "#TotalQuantityExpected#",
			"display_status" = "IN PROGRESS"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsOCRUploadTestLogDetailSummary = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsOCRUploadTestLogDetailSummary>
<cfquery name="qInsOCRUploadTestLogDetailSummary" datasource="#application.datasource#">
					INSERT INTO	OCR_Upload_Test_Log_Detail_Summary
					(
						OCR_Upload_Test_Log_ID,
						OCR_Upload_ID,
						OCR_Upload_TestSet_ID,
						OCR_Step_Expected,
						Total_Invoices_Expected,
						Total_Line_Items_Expected,
						Total_Amount_Expected,
						Total_Quantity_Expected,
						
						Display_Status
						
					)
					VALUES
					(
						#OCRUploadTestLogID#,
						#OCRUploadID#,
						#OCRUploadTestSetID#,
						'#OCRStepExpected#',
						#TotalInvoicesExpected#,
						#TotalLineItemsExpected#,
						#TotalAmountExpected#,
						#TotalQuantityExpected#,
						
						'IN PROGRESS'
					)
					</cfquery>
</cfif>
				</cfif>	
			
				<cfquery name="qInsOCRUploadLog" datasource="#application.datasource#">
					SELECT OCR_Reader_Name FROM OCR_Template_Settings
					WHERE OCR_Template_Settings_ID = '#FORM.selType#'
				</cfquery>
				
				<cfif ((qInsOCRUploadLog.OCR_Reader_Name EQ "DOCPARSER") OR (qInsOCRUploadLog.OCR_Reader_Name EQ "ABBYY&DOCPARSER") OR (qInsOCRUploadLog.OCR_Reader_Name EQ "EXCELCSV"))>
					<cfset useLakebaseForqUpdOCRUploadAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqUpdOCRUploadAmount>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#OCRUploadID#",
				"deleted" = "eq.0"
			},
			{
				"db_input_filename" = "#strFileName#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdOCRUploadAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdOCRUploadAmount>
<cfquery name="qUpdOCRUploadAmount" datasource="#application.datasource#">
						UPDATE 
							OCR_Upload_Log
						SET 
							DB_Input_FileName = '#strFileName#'
						WHERE OCR_Upload_ID = '#OCRUploadID#'  AND Deleted = 0
					</cfquery>
</cfif>
				</cfif>
				
				
				<!--- Handle for Invoice details insert into OCR_User_Input --->
					<cfif isDefined("FORM.startDate_1") AND FORM.startDate_1 NEQ "">
						<cfset dtStartDate 	 = FORM.startDate_1 />
						<cfset stdatenull = "no" />
					<cfelse>		
						<cfset dtStartDate 	 = "" />
						<cfset stdatenull = "yes" />
					</cfif>	
					<cfif isDefined("FORM.endDate_1") AND FORM.endDate_1 NEQ "">
						<cfset dtEndDate 	 = FORM.endDate_1 />
						<cfset endatenull = "no" />
					<cfelse>		
						<cfset dtEndDate 	 = "" />
						<cfset endatenull = "yes" />
					</cfif>						
					<cfif isDefined("FORM.invoiceDate_1") AND FORM.invoiceDate_1 NEQ "">
						<cfset dtInvoiceDate 	 = FORM.invoiceDate_1 />
						<cfset invdatenull = "no" />
					<cfelse>		
						<cfset dtInvoiceDate 	 = "" />
						<cfset invdatenull = "yes" />						
					</cfif>

					<cfif isDefined("FORM.Invoice_1") AND FORM.Invoice_1 NEQ "">
						<cfset strInvoice 	 = FORM.Invoice_1 />
						<cfset strInvoicenull = "no" />
					<cfelse>		
						<cfset strInvoice 	 = "" />
						<cfset strInvoicenull = "yes" />						
					</cfif>	

					<cfif isDefined("FORM.Amount_1") AND FORM.Amount_1 NEQ "">
						<cfset strAmount 	 = FORM.Amount_1 />
						<cfset strAmountnull = "no" />
					<cfelse>		
						<cfset strAmount 	 = #FORM.Amount# />
						<cfset strAmountnull = "no" />						
					</cfif>	

				<cfset amtTotal = 0 />
				<cfif isDefined("FORM.Invoice_1") and FORM.Invoice_1 NEQ "" OR invdatenull EQ "no"> <!--- AND FORM.curTRCount NEQ 0 --->
					<cfif FORM.curTRCount EQ 0><cfset FORM.curTRCount = 1 /></cfif>
					<cfloop from="1" to="#FORM.curTRCount#" index="ctr">
						<cfif isDefined("FORM.Amount_#ctr#")>
							<cfset strAmount 	 = '#evaluate("FORM.Amount_#ctr#")#' />
						</cfif>
						<cfset strAmount = Replace(Replace(strAmount,',','','ALL'),'$','','ALL') />
						<cfif isDefined("FORM.Invoice_#ctr#")>
							<cfset strInvoice 	 = '#evaluate("FORM.Invoice_#ctr#")#' />
						</cfif>
							<cfif strInvoice NEQ "" OR invdatenull EQ "no" and isnumeric(strAmount)>
							<cfquery name="qInsOCRUserInput" datasource="#application.datasource#">			
							DECLARE
							 @User_id varchar(50),
							 @Upload_date datetime
							 
							 SET @upload_date = getdate()
			      			 SET @User_id = '#request.AccessStructure.user_id#'
							 
							INSERT INTO OCR_User_Input
							(
								OCR_Upload_ID,
								OCR_Template_Settings_ID,
								Invoice_Number,
								Invoice_Amount,
								Invoice_Date,
								Start_Date,
								End_Date,
								Created_Date,
								Created_By	
							)
							VALUES
							(
								#OCRUploadID#,
								#FORM.selType#,
								'#strInvoice#',
								'#strAmount#',
								<cfqueryparam value="#dtInvoiceDate#" cfsqltype="CF_SQL_DATE" null="#invdatenull#">,  
								<cfqueryparam value="#dtStartDate#" cfsqltype="CF_SQL_DATE" null="#stdatenull#">,
								<cfqueryparam value="#dtEndDate#" cfsqltype="CF_SQL_DATE" null="#endatenull#">,
								@Upload_date,
								@User_id
							)
							</cfquery>
							<cfset amtTotal = amtTotal + strAmount />
						</cfif>	
					</cfloop>
					<!--- TO UPLOAD THE AMOUNT  WHEN FILE HAS MULTIPLE INVOICES --->
					<cfquery name="qUpdOCRUploadAmount" datasource="#application.datasource#">
						UPDATE 
							OCR_Upload_Log
						SET 
							OCR_Amount = '#amtTotal#'
						WHERE OCR_Upload_ID = '#OCRUploadID#'  AND Deleted = 0
					</cfquery>
				</cfif> 
 
				
				<!--- <cftry> --->
					<cfset fileSource = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#strFileName#" />
					<cfloop query = "qGetOCRSettings">
						<cfif ((qGetOCRSettings.OCR_File_PreProcess_Path NEQ "" AND DirectoryExists("#qGetOCRSettings.OCR_File_PreProcess_Path#")
								AND qGetOCRSettings.DB_File_Preprocess_Path NEQ "" AND DirectoryExists("#qGetOCRSettings.DB_File_Preprocess_Path#")
								AND qGetOCRSettings.DB_OCR_Root_Path NEQ "" AND DirectoryExists("#qGetOCRSettings.DB_OCR_Root_Path#")
								AND qGetOCRSettings.DB_OCR_Source_Code NEQ ""
								AND qGetOCRSettings.OCR_Reader_Name EQ "ABBYY"
								) 
								OR
								(
									qGetOCRSettings.OCR_File_PreProcess_Path NEQ "" AND DirectoryExists("#qGetOCRSettings.OCR_File_PreProcess_Path#") 
									AND qGetOCRSettings.DB_OCR_Source_Code NEQ ""
									AND qGetOCRSettings.OCR_Reader_Name EQ "ABBYY&DOCPARSER"
									AND qGetOCRSettings.Is_Double_Processing_On EQ 1
								))
						>
							<cffile action="copy" destination="#qGetOCRSettings.OCR_File_PreProcess_Path#" source="#fileSource#">
						<cfelseif (qGetOCRSettings.OCR_File_PreProcess_Path NEQ "" AND DirectoryExists("#qGetOCRSettings.OCR_File_PreProcess_Path#")
									AND (qGetOCRSettings.OCR_Reader_Name EQ "DOCPARSER" OR qGetOCRSettings.OCR_Reader_Name EQ "EXCELCSV"))>
							<cffile action="copy" destination="#qGetOCRSettings.OCR_File_PreProcess_Path#" source="#fileSource#">
						<cfelseif ( 
									qGetOCRSettings.OCR_File_PreProcess_Path NEQ "" AND DirectoryExists("#qGetOCRSettings.OCR_File_PreProcess_Path#") 
									AND qGetOCRSettings.DB_OCR_Source_Code NEQ ""
									AND qGetOCRSettings.OCR_Reader_Name EQ "DOCPARSER_ABBYY_DOCPARSER"
									AND qGetOCRSettings.Special_Processing_Flag EQ "1"
									)>	
							<cffile action="copy" destination="#qGetOCRSettings.OCR_File_PreProcess_Path#" source="#fileSource#">
							<cffile action="copy" destination="#qGetOCRSettings.OCR_File_PreProcess_Path#\ABBYY" source="#fileSource#">
						<cfelseif qGetOCRSettings.OCR_Reader_Name NEQ "EXCELCFPARSE">
							<cfset useLakebaseForqUpdOCRUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqUpdOCRUploadLog>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#OCRUploadID#",
				"deleted" = "eq.0"
			},
			{
				"debug_dev_status" = "ERROR: There seems to be multiple templates and atleast one does not have a valid path!!"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdOCRUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdOCRUploadLog>
<cfquery name="qUpdOCRUploadLog" datasource="#application.datasource#">
								UPDATE 
									OCR_Upload_Log
								SET 
									Debug_Dev_Status = 'ERROR: There seems to be multiple templates and atleast one does not have a valid path!!'
								WHERE OCR_Upload_ID = '#OCRUploadID#'  AND Deleted = 0
							</cfquery>
</cfif>
								
						</cfif>
					</cfloop>
					<!--- <cfquery name="qUpdOCRUploadLog2" datasource="#application.datasource#">
						UPDATE 
							OCR_Upload_Log
						SET 
							OCR_Step = '2',
							OCR_Upload_Status = 'Analyzing the file and contents'
						WHERE OCR_Upload_ID = '#OCRUploadID#' AND Deleted = 0
					</cfquery> --->
						
					<!--- Delete the temporary file from the webserver location --->
				<!---	<cfif qGetOCRSettings.OCR_Reader_Name NEQ "EXCELCFPARSE">
						<cffile action="delete" file="#fileSource#" />
					</cfif> --->
					<!--- <cfcatch>
					 	<cfoutput>
						From Copy function to the preprocess paths
						<b>Type:</b> #cfcatch.Type# <br><br>
						<b>Message:</b> #cfcatch.Message# <br><br>
						<cfif cfcatch.Detail NEQ "">
							<b>Detail:</b> #cfcatch.Detail# <br><br>
						</cfif>
						</cfoutput>
					</cfcatch>
				</cftry> --->