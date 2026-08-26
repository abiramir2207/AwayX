<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfscript>
	OCRSettingsManager  = CreateObject("component","components.Billback.OCRUploadSettingsManager");
	qGetValidSources		= OCRSettingsManager.getValidSourcesForUpload();
	bDisplayMappingUpload = 0;
	recToDetail			= 0;
</cfscript>

<cfset recordDeleted = 0/>
	
	<cfset useLakebaseForupdateOCRUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_settings")>
<cfif useLakebaseForupdateOCRUploadLog>
	<cftry>
		<cfset updateOCRUploadLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_upload_settings", {
				"select" = "file_path"
			}), "file_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateOCRUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLog>
<cfquery name="updateOCRUploadLog" datasource="#application.datasource#">
		SELECT File_Path FROM Billback_Upload_Settings
	</cfquery>
</cfif>		
	<cfset goldSetPath = trim(updateOCRUploadLog.File_Path & "OCR_Upload_Test\") />
	<cfset FileUploadPath = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\" />
	<!--- <cfset UploadFileAndPath = trim(goldSetPath & "OCR_Upload_Test\") />  --->

	<cfif (isDefined("FORM.Submitted") AND (FORM.Submitted EQ "2"))>
		<cfif (isDefined("FORM.selDelRec") AND FORM.selDelRec NEQ "")>
			<cfset recToDelete = FORM.selDelRec />
			<cfset useLakebaseForqryGetOCRTemplateSettingsID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqryGetOCRTemplateSettingsID>
	<cftry>
		<cfset application.oLakebase.deleteRows("ocr_upload_log", {
			"ocr_upload_test_log_id" = "eq.#recToDelete#
				DELETE FROM OCR_Upload_Test_Log WHERE OCR_Upload_Test_Log_ID = #recToDelete#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetOCRTemplateSettingsID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetOCRTemplateSettingsID>
<cfquery name="qryGetOCRTemplateSettingsID" datasource="#application.datasource#">
				DELETE FROM OCR_Upload_Log WHERE OCR_Upload_Test_Log_ID = #recToDelete#
				DELETE FROM OCR_Upload_Test_Log WHERE OCR_Upload_Test_Log_ID = #recToDelete#
			</cfquery>
</cfif>	
 			<cfset recordDeleted = 1 />
		</cfif>
	</cfif>

	
 
	<cfset BBUploadManager  = CreateObject("component","mvc.Models.Billback.BillbackUploadManager") />
	<cfscript>
		OCRSettingsManager  = CreateObject("component","components.Billback.OCRUploadSettingsManager");
		qGetValidSources	= OCRSettingsManager.getValidSourcesForUpload();
	</cfscript>
	<cfset TotalFilePages = 0 />
	
	<cfif (isDefined("request.AccessStructure.user_id") AND request.AccessStructure.user_id NEQ "")>
	    <cfset TestingUserID = request.AccessStructure.user_id />
	<cfelse>
		<cfset TestingUserID = URL.UID />
	 	<cfset request.AccessStructure.user_id = TestingUserID />
	</cfif>
	
	<cfoutput>
	<cfif (isDefined("FORM.Submitted") AND (FORM.Submitted EQ "1"))>
	<!--- 
			TODO: 
			1) Check the file that was uploaded and read the contents of the file.
			2) Read each line and insert it into a temp table 
			3) Create a temp table 
			4) Insert into a Permanent table to keep track of the Testing done.
			5) Create a Permanent table
			
			Paths for uploads:
			a) CSV Mapping file gets uploaded in: #Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc
			b) Golden set reside in: Billback_Upload_Settings.File_Path ie:\\dbstage08\Client_Data\DEV_80\BB_Upload\
			and in the folder "OCR_Upload_Test" within that
			c) Rename it to have the Log_ID number at the end -> concat value "_GS<Log_ID>"
			D) 	Copy the file and overwrite, to the path #Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc
			
	--->
	<!--- 
		---  NEW LOGIC ----
		TODO:
			1) Check the golden set path and get all the files list:
			2) check to see if the the records are in the OCR_Upload_Log_TestSet
			3) Insert into table OCR_Upload_Test_Log
			3) Run a nested loop 
			3) if the file in the director match the file in the golden set then copy to a "goldenset/temp" location and rename the files with "_GS<Log_ID>_date format".
			4) Copy the file and to the path #Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc
			5) Then call the insert code in the include file.
			
			
			To Decide:
			a) What happens to the files that are in the Goldenset directory and not in the Testset, should we let the user know, if that file was not processed. (if yes, we need a mechanism to store that record.
			
			
	--->
	
		<!--- Get the list of files from the Goldenset Directory --->
		
		<cfdirectory name="GSUploadDirecotry" action="list" type="file" 
			directory="#goldSetPath#"
			sort="datelastmodified DESC">


		<!--- Create tehe tables if it does not exist already, to avoid any errors from the queries below --->
		<cfinclude template = "OCR_Table_Creation.cfm" />
		
		<!--- Get all the rows from the OCR_Upload_Log_TestSet --->
		<cfquery name="qryGSTestSet" datasource="#application.datasource#">
			 SELECT OULT.*,OTST.OCR_Code FROM OCR_Upload_Log_TestSet OULT
			 INNER JOIN dbo.OCR_Template_Settings_TestSet  OTST
			 ON OTST.OCR_Template_Settings_ID = OULT.OCR_Template_Settings_ID
			 WHERE OULT.Deleted = 0
		</cfquery>	
		<!--- check to see if there are records in the OCR_Upload_Log_TestSet --->
		<cfif (isDefined("qryGSTestSet") AND qryGSTestSet.recordCount GTE 1)>
<!--- 		
		<cfdump var="#qryGSTestSet#" />
		<cfdump var="#GSUploadDirecotry#" /> --->
		
<!--- 	<Cfset i = 1 /> --->
		<!--- Insert a row to record that that the user clicked on the "Go" button --->
		<cfquery name="qInsOCRUploadTestLog" datasource="#application.datasource#">
			DECLARE  @upload_id int, 
          		 @Upload_date datetime,
         		 @User_id varchar(50),
	         @File_name varchar(255),
			 @File_ext varchar(15)
	
		    SET @upload_date = getdate() 
	      	SET @User_id = '#TestingUserID#'
			SET @File_name = 'NONE'
				
			INSERT INTO	
				OCR_Upload_Test_Log
				(	 
					File_Name,
					Created_User_ID,
					Created_Date
				)
				VALUES	
				(	 
				    @File_name,
					@User_id,
					@Upload_date
				)
 				SELECT 
	  				OCR_Upload_Test_Log_ID 
	  			FROM 
	  				OCR_Upload_Test_Log 
	 			WHERE Created_User_ID = @user_id AND Created_Date = @Upload_Date AND File_Name = @File_name
		</cfquery>	
		<cfset OCRUploadTestLogID  = qInsOCRUploadTestLog.OCR_Upload_Test_Log_ID />
					
		<cfset validFileCount = 1 />		
		<cfset todaysDate = now() />
		<!--- 
			Do a nested loop on the test set and the golden set directory and 
			process the files accordigly
		--->
		<!--- <cfset FileUploadPath = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\" /> --->
		<cfset strUnProcessableFiles = "" />
<cfsavecontent variable="ResultsSection">	
	<h3>Results from Upload:</h3>
		<cfset icount = 0 />
		<cfset imaincount = 0 />
		<cfloop query="qryGSTestSet">
			<cfloop query="GSUploadDirecotry">
				<!--- Compare and do the processing of the file only if it exists in the golden set --->
				<cfset imaincount++ >  
				<cfif Trim(qryGSTestSet.File_name) EQ Trim(GSUploadDirecotry.Name)>
					
					<cfset GSFileName = GSUploadDirecotry.name />
					<cfset fileAge = DateDiff("d", GSUploadDirecotry.dateLastModified, now()) />
					<!--- in IF <cfoutput>#i#. #GSUploadDirecotry.Name#</cfoutput><br> --->
					
					<cfset fileNamePart = ListDeleteAt(GSFileName, ListLen(GSFileName, "."), ".")>
					<cfset fileExtPart  = Replace(GSFileName,fileNamePart,'') />
					
					<cfset dtTimeStamp	= "#DateFormat(todaysDate, 'mmddyyyy')#_#TimeFormat(todaysDate, 'HHmmss')#" />
					<cfset RenamedFileName = trim(fileNamePart & "_GS#qInsOCRUploadTestLog.OCR_Upload_Test_Log_ID#_#dtTimeStamp#") & trim(fileExtPart) />
					<cfset RenamedFileAndPath = trim(FileUploadPath  & RenamedFileName) />
					
					<!--- <cfset UploadFileAndPath = trim(goldSetPath & "OCR_Upload_Test\" & UploadFileName) />	 --->
					<cfset GSFileName = GSUploadDirecotry.Name />
					<cfset GSFileAndPath = trim(goldSetPath  & GSUploadDirecotry.Name) />
	 
					<cffile action="copy" source="#GSFileAndPath#" destination="#FileUploadPath#" nameconflict="overwrite">
					<cffile action ="rename" source = "#FileUploadPath#\#GSFileName#" destination = "#RenamedFileAndPath#" />
				 	<cfif fileExtPart EQ ".pdf">
						<cfpdf action = "getInfo" name="uploadedPDF" source="#RenamedFileAndPath#" />
						<cfset TotalFilePages = uploadedPDF.TotalPages />
					</cfif> 
					<cfset validFileCount++ />
					<!--- <cfset UploadFileName 	 = UploadRowsQuery.File_Name /> --->
					<cfset UploadFileAmount  = qryGSTestSet.OCR_Amount />
					<cfset UploadFileOCRCode = qryGSTestSet.OCR_Code />		
					<cfquery name="qryGetOCRTemplateSettingsID" datasource="#application.datasource#">
						SELECT * FROM OCR_Template_Settings WHERE OCR_Code = '#Trim(UploadFileOCRCode)#' AND Deleted = 0
					</cfquery>		<!--- Get the OCRTemplateSettingsID --->
				 	<cfset FORM.selSource 	 = qryGetOCRTemplateSettingsID.BB_Claim_Source_XREF_ID />
					<cfset FORM.selType		 = qryGetOCRTemplateSettingsID.OCR_Template_Settings_ID />
					<cfset FORM.Amount		 = UploadFileAmount />
					<cfset FileSize 		 = GSUploadDirecotry.size />
					<cfset strFileName		 = RenamedFileName />
					<cfset FileExt			 = Replace(fileExtPart,'.','') />
					<cfset strServerFileName = trim(fileNamePart & "_GS#qInsOCRUploadTestLog.OCR_Upload_Test_Log_ID#_#dtTimeStamp#") />
					<cfset qGetOCRSettings = OCRSettingsManager.getOCRSettings(OCRTemplateSettingsID = #FORM.selType#) />
					
					<cfset OCRUploadTestSetID 		= qryGSTestSet.OCR_Upload_ID />
					<cfset OCRStepExpected 			= qryGSTestSet.OCR_Step />
					
					<cfquery name="qryGetOCRTestSet1" datasource="#application.datasource#">
						SELECT 
							COUNT(DISTINCT (customer_Reference_number)) AS Total_Invoices_Expected,
							COUNT(*) AS Total_Line_Items_Expected, 
							SUM(CASE ISNUMERIC(Item_Amount) 
					        	 WHEN 1 THEN ISNULL(CAST(Item_Amount AS Float),'0')
					        	 ELSE 0 
					      		 END) AS Total_Amount_Expected, 
					  		SUM(CASE ISNUMERIC(Item_Quantity) 
					        	 WHEN 1 THEN ISNULL(CAST(Item_Quantity AS Float),'0')
					         	ELSE 0 
					       		END) AS Total_Quantity_Expected 
						FROM OCR_Trackmax1_Excel_Format_TestSet
						WHERE OCR_Upload_ID = #OCRUploadTestSetID#
					</cfquery>
	
					<cfset TotalInvoicesExpected	= qryGetOCRTestSet1.Total_Invoices_Expected />
					<cfset TotalLineItemsExpected	= qryGetOCRTestSet1.Total_Line_Items_Expected  />
					<cfset TotalAmountExpected		= qryGetOCRTestSet1.Total_Amount_Expected  />
					<cfset TotalQuantityExpected	= qryGetOCRTestSet1.Total_Quantity_Expected  />
					
					<cfset FieldDifferences = 0 />
					<cfset URL.Testing = 1 />
					<cfset useLakebaseForqGetOCRUserInput = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_user_input_testset")>
<cfif useLakebaseForqGetOCRUserInput>
	<cftry>
		<cfset qGetOCRUserInput = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_user_input_testset", {
				"ocr_upload_id" = "eq.#OCRUploadTestSetID#",
				"select" = "ocr_user_input_id,ocr_upload_id,ocr_template_settings_id,invoice_number,invoice_amount,invoice_date,start_date,end_date"
			}), "ocr_user_input_id,ocr_upload_id,ocr_template_settings_id,invoice_number,invoice_amount,invoice_date,start_date,end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOCRUserInput = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOCRUserInput>
<cfquery name="qGetOCRUserInput" datasource="#application.datasource#">
						SELECT  
							OCR_User_Input_ID,
							OCR_Upload_ID,
							OCR_Template_Settings_ID,
							Invoice_Number,
							Invoice_Amount,
							Invoice_Date,
							Start_Date,
							End_Date
						FROM
							OCR_User_Input_Testset
						WHERE OCR_Upload_ID = '#OCRUploadTestSetID#'
					</cfquery>
</cfif>
				
				<cfset inputCtr = 0 />
				<cfloop query="qGetOCRUserInput">
					<cfset inputCtr = inputCtr + 1 />
					<cfset "FORM.Invoice_#inputCtr#"		= qGetOCRUserInput.Invoice_Number />
					<cfset "FORM.Amount_#inputCtr#"			= qGetOCRUserInput.Invoice_Amount />
					<cfset "FORM.invoiceDate_#inputCtr#"	= qGetOCRUserInput.Invoice_Date />
					<cfset "FORM.startDate_#inputCtr#"		= qGetOCRUserInput.Start_Date />
					<cfset "FORM.endDate_#inputCtr#"		= qGetOCRUserInput.End_Date />
				</cfloop>
				<cfset FORM.curTRCount = inputCtr />
	 					<cfinclude template="../inc_OCR_Insert_Copy.cfm" />
 				
				<!--- Remove all the form elements that were created to add the user_input data --->
				<cfset inputCtr = 0 />
				<cfloop query="qGetOCRUserInput">
					<cfset inputCtr = inputCtr + 1 />
					<cfset temp = structdelete(FORM, "Invoice_#inputCtr#")>
					<cfset temp = structdelete(FORM, "Amount_#inputCtr#")>
					<cfset temp = structdelete(FORM, "invoiceDate_#inputCtr#")>
					<cfset temp = structdelete(FORM, "startDate_#inputCtr#")>
					<cfset temp = structdelete(FORM, "endDate_#inputCtr#")>
				</cfloop>
				</cfif>
			</cfloop>
<!--- icount: <cfdump var="#icount#" /> imaincount: <cfdump var="#imaincount#" /><br>
			<cfif (icount EQ imaincount)>
			in icount EQ imaincount<br>
				<cfset strUnProcessableFiles = strUnProcessableFiles & GSUploadDirecotry.name & "<br>">
			</cfif>
			<cfset icount = 0 />
			<cfset imaincount = 0 /> --->
		</cfloop>	
		
		<cfquery name="qryGetOCRTemplateSettingsID" datasource="#application.datasource#">
			UPDATE OCR_Upload_Test_Log 
			SET 
				Total_Files_Count	= #validFileCount#,
				In_Progress_Count	= #validFileCount#,
				Completed_Count		= 0,
				Failed_Count		= 0
			WHERE OCR_Upload_Test_Log_ID = #OCRUploadTestLogID#
		</cfquery>	
	
		<!--- <cfif strUnProcessableFiles NEQ "">
			<br>
			The below files does not exist in the Testing set and were not processed for testing:<br>
			#strUnProcessableFiles#
			<br>
		</cfif>		 --->		
		<!--- The below files were available in the Directory:<br><br>
		
		<cfset i=1 />
		<cfloop query="GSUploadDirecotry">
			<cfoutput>#i#. #GSUploadDirecotry.name#<br></cfoutput>
			<cfset i++ />
		</cfloop> --->
		
		
		<cfset useLakebaseForqryGetOCRUploadLogData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqryGetOCRUploadLogData>
	<cftry>
		<cfset qryGetOCRUploadLogData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"ocr_upload_test_log_id" = "eq.#OCRUploadTestLogID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetOCRUploadLogData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetOCRUploadLogData>
<cfquery name="qryGetOCRUploadLogData" datasource="#application.datasource#">
			SELECT * from OCR_Upload_Log WHERE
			OCR_Upload_Test_Log_ID = #OCRUploadTestLogID#
		</cfquery>
</cfif>	 
	 
		
		This upload will load the below #qryGetOCRUploadLogData.RecordCount# files in the DB:<br><br>
		
		<cfset i=1 />
		<cfloop query="qryGetOCRUploadLogData">
			<cfoutput>#i#. #qryGetOCRUploadLogData.File_Name#<br></cfoutput>
			<cfset i++ />			
		</cfloop>
		<cfset FORM.selDtlRec = OCRUploadTestLogID />
	</cfsavecontent>	
  </cfif>
 </cfif>
 
		<cfset useLakebaseForqryOCRUploadTestLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log")>
<cfif useLakebaseForqryOCRUploadTestLog>
	<cftry>
		<cfset qryOCRUploadTestLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_test_log", {
				"order" = "created_date.desc",
				"select" = "ocr_upload_test_log_id,file_name,created_user_id,created_date"
			}), "ocr_upload_test_log_id,file_name,created_user_id,created_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryOCRUploadTestLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryOCRUploadTestLog>
<cfquery name="qryOCRUploadTestLog" datasource="#application.datasource#">
					SELECT 
						OCR_Upload_Test_Log_ID,	
						File_Name,
						Created_User_ID,
						Created_Date 
					FROM 
						OCR_Upload_Test_Log 
					ORDER BY 
						Created_Date DESC
		</cfquery>
</cfif>	

	<!---- CHECK IF THE FORM IS EMPTY, IF SO LOAD TEH LAST TEST BATCH BY DEFAULT  --->		
	<cfif structisEmpty(FORM)>
		<cfset FORM.Submitted = "3" />
		<cfset useLakebaseForqryOCRUploadTestLogTop1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qryocruploadtestlog")>
<cfif useLakebaseForqryOCRUploadTestLogTop1>
	<cftry>
		<cfset qryOCRUploadTestLogTop1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qryocruploadtestlog", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryOCRUploadTestLogTop1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryOCRUploadTestLogTop1>
<cfquery name="qryOCRUploadTestLogTop1" dbType="query" maxrows="1">
			SELECT * from qryOCRUploadTestLog
		</cfquery>
</cfif>
		<cfset FORM.selDtlRec = qryOCRUploadTestLogTop1.OCR_Upload_Test_Log_ID />
	</cfif>
 
 	<cfif (isDefined("FORM.Submitted") AND (FORM.Submitted EQ "3" OR FORM.Submitted EQ "1"))>
 		
		<!--- SET THE OCRUploadTestLogID  AS THE VALUE FOR FORM.selDtlRec --->

		<cfif (isDefined("FORM.selDtlRec") AND FORM.selDtlRec NEQ "")>
		
			<cfset recToDetail = FORM.selDtlRec />
			<!--- <cfquery name="qryGetOCRTemplateSettingsID" datasource="#application.datasource#">
			-- 	DELETE FROM OCR_Upload_Log WHERE OCR_Upload_Test_Log_ID = #recToDelete#
			-- 	DELETE FROM OCR_Upload_Test_Log WHERE OCR_Upload_Test_Log_ID = #recToDelete#
			</cfquery>	 --->
 			<cfset recordDetailed = 1 />
			<cfinclude template = "OCR_Testing_Update.cfm" />			
			<cfquery name="qryDetailSummary" datasource="#application.datasource#">
				 SELECT * FROM dbo.OCR_Upload_Test_Log WHERE OCR_Upload_Test_Log_ID = #recToDetail#
			</cfquery>	
			
			<cfquery name="qryDetailSummary2" datasource="#application.datasource#">
				SELECT  
						*,
						OUL.File_Name AS Uploaded_File_Name
					FROM OCR_Upload_Test_Log_Detail_Summary ODS
					INNER JOIN  OCR_Upload_Test_Log OTL ON OTL.OCR_Upload_Test_Log_ID = ODS.OCR_Upload_Test_Log_ID
			 
					INNER JOIN dbo.OCR_Upload_Log OUL ON OUL.OCR_Upload_ID = ODS.OCR_Upload_ID
					INNER JOIN dbo.OCR_Template_Settings OTS ON OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				WHERE ODS.OCR_Upload_Test_Log_ID = #recToDetail#
			</cfquery>	 
			<!--- <cfdump var="#qryDetailSummary#" />  --->
			
			<cfsavecontent variable="DetailsSection">
			
			<cfoutput>
				<link rel="stylesheet" type="text/css" href="/Common_Files/datatable-ocr.css">
				<br>
				<h3><u><b>Summary of Test Batch #recToDetail#:</b></u></h3><br>
				
				<table  border="1" width="450" cellpadding="0" cellspacing="2" rules="groups" class="datagrid" style="width:400 !important;">
					<tr>
						<td>
							<strong>Total Files in this upload: </strong>
						</td>
						<td>
							#qryDetailSummary.Total_Files_Count#
						</td>
					</tr>
					
						<tr>
							<td>
								In Progress: 
							</td>
							<td>
								#qryDetailSummary.In_Progress_Count# record(s)
							</td>
						</tr>
						<tr>
							<td>
								Completed: 
							</td>
							<td>
								#qryDetailSummary.Completed_Count# record(s)
							</td>
						</tr>
						<cfif (qryDetailSummary.Failed_Count NEQ "" AND qryDetailSummary.Failed_Count NEQ "0")>
							<tr>
								<td>
									Failed Count: 
								</td>
								<td>
									#qryDetailSummary.Failed_Count# record(s)
								</td>
							</tr>
						</cfif>
					
					<tr>
						<td>
							Start Time: 
						</td>
						<td>
							#DateFormat(qryDetailSummary.Created_Date, 'MM/DD/YYYY')# #TimeFormat(qryDetailSummary.Created_Date, 'hh:mm tt')#
						</td>
					</tr>										
					<tr>
						<td>
							End Time: 
						</td>
						<td>
							#DateFormat(qryDetailSummary.End_Time, 'MM/DD/YYYY')# #TimeFormat(qryDetailSummary.End_Time, 'hh:mm tt')#
						</td>
					</tr>										

				</table><br>
				<br>
				
				<!--- 
				
				/images/OCR/Abort24.png
				/images/OCR/checked24.png
				/images/OCR/working24.png				
				
				--->
				  
				
				

				<h3><u><b>Details of Test Batch #recToDetail#:</b></u></h3><br>
				<table class="datagrid" cellspacing="0" cellpadding="0" border="1">
					<thead>
					<tr>
    					<th class="header" colspan="3" style="text-align:center;font-size:14;">Date</th>
						<th class="header" colspan="3" style="text-align:center;font-size:14;">Failure Details</th>
						<th class="header" colspan="2" style="text-align:center;font-size:14;">OCR Step</th>
						<th class="header" colspan="2" style="text-align:center;font-size:14;">Total ## of Invoices</th>
						<th class="header" colspan="2" style="text-align:center;font-size:14;">Total Line Items</th>
						<th class="header" colspan="2" style="text-align:center;font-size:14;">Total Amount</th>
						<th class="header" colspan="2" style="text-align:center;font-size:14;">Total Quantity</th>
						<th class="header" colspan="2" style="text-align:center;font-size:14;">Field Differences</th>
					</tr>
					<tr>
						<th>Status</th>
						<th>Start Time</th>
						<th>End Time</th>
						<th>Invoice Name</th>
						<th>Upload ID<!--- (from ocr_upload_log) ---></th>
						<th>Template Type</th>
						<th>Expected</th>
						<th>Actual</th>
						<th>Expected</th>
						<th>Actual</th>
						<th>Expected</th>
						<th>Actual</th>
						<th>Expected</th>
						<th>Actual</th>
 						<th>Expected</th>
						<th>Actual</th>
						<th></th>
					</tr>
					</thead>
  					<tbody>
					<cfloop query="qryDetailSummary2">
					
						<cfif ((qryDetailSummary2.OCR_Step_Expected EQ qryDetailSummary2.OCR_Step_Actual) 
						)>
							<cfset imgStatus = "<img src='/images/OCR/checked24.png'>" />
						<cfelseif qryDetailSummary2.Display_Status EQ "IN PROGRESS">
							<cfset imgStatus = "<img src='/images/OCR/working24.png'>" />
						<cfelse>
							<cfset imgStatus = "<img src='/images/OCR/abort24.png'>" />
						</cfif>
						<tr>
							<td>
								#imgStatus#
							</td>
							<td>#DateFormat(qryDetailSummary2.Created_Date, 'MM/DD/YYYY')# #TimeFormat(qryDetailSummary2.Created_Date, 'hh:mm tt')#</td>
							<td>#DateFormat(qryDetailSummary2.End_Time, 'MM/DD/YYYY')# #TimeFormat(qryDetailSummary2.End_Time, 'hh:mm tt')#</td>
							<td>#qryDetailSummary2.Uploaded_File_Name#</td>
							<td>#qryDetailSummary2.OCR_Upload_ID#</td>
							<td>#qryDetailSummary2.OCR_Code#</td>
	 						<td>#qryDetailSummary2.OCR_Step_Expected#</td>
							<td <cfif (qryDetailSummary2.OCR_Step_Expected NEQ qryDetailSummary2.OCR_Step_Actual)>bgcolor="FF6600"</cfif>>#qryDetailSummary2.OCR_Step_Actual#</td>						
							<td>#qryDetailSummary2.Total_Invoices_Expected#</td>
							<td <cfif (qryDetailSummary2.Total_Invoices_Expected NEQ qryDetailSummary2.Total_Invoices_Actual)>bgcolor="FF6600"</cfif>>#qryDetailSummary2.Total_Invoices_Actual#</td>
							<td>#qryDetailSummary2.Total_Line_Items_Expected#</td>
							<td <cfif (qryDetailSummary2.Total_Line_Items_Expected NEQ qryDetailSummary2.Total_Line_Items_Actual)>bgcolor="FF6600"</cfif>>#qryDetailSummary2.Total_Line_Items_Actual#</td>
							<td>#qryDetailSummary2.Total_Amount_Expected#</td>
							<td <cfif (qryDetailSummary2.Total_Amount_Expected NEQ qryDetailSummary2.Total_Amount_Actual)>bgcolor="FF6600"</cfif>>#qryDetailSummary2.Total_Amount_Actual#</td>
							<td>#qryDetailSummary2.Total_Quantity_Expected#</td>
							<td <cfif (qryDetailSummary2.Total_Quantity_Expected NEQ qryDetailSummary2.Total_Quantity_Actual)>bgcolor="FF6600"</cfif>>#qryDetailSummary2.Total_Quantity_Actual#</td>
							<td>#qryDetailSummary2.Field_Differences#</td>
						</tr>
					</cfloop>
					</tbody>
				</table> 
 				<!--- <div align="right"> [ <a href="" align="right">Download Detailed Comparison</a> ]</div> --->
			</cfoutput>
			<!--- [Export]  --->
			</cfsavecontent>
		</cfif>
	</cfif>
 
 
</cfoutput>

<html>
<head>
	<title>CIA TESTING</title>
	<script>
		function submitForm(submitter)
		{
			var thisForm = document.all.uploadTestFiles;
			thisForm.Submitted.value = submitter;
			if (submitter == '2')
			{
				if (thisForm.selDelRec.selectedIndex == "")
				{
					alert('Pick a Record to Delete');
					return;
				} 
			}
			if (submitter == '3')
			{
				if (thisForm.selDtlRec.selectedIndex == "")
				{
					alert('Pick a Record to view Details');
					return;
				} 
			}
			if (submitter == '1')
			{
				document.getElementById('uploadActive').style.display = 'none';
				document.getElementById('uploadInactive').style.display = 'block';
			}
			// sleep(1000);
			// alert(submitter);
			thisForm.submit();
		}
	</script>
	<style>
	 	body
		{ 
			font-family: Century Gothic, CenturyGothic, Geneva, AppleGothic, sans-serif; 
			font-size:12px;
			background: #DFFFFF; 
		} /* background:#94ba6d*/
		hr.style12
		{
			height: 6px;
			background: url(/images/ocr/hr-12.png) repeat-x 0 0;
    		border: 0;
		}
		.newLink:link, .newLink:visited 
		{
			    background-color: #406BE4;
			    color: white;
			    padding: 7px 15px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border-radius: 50px;
				font-family: Arial; 
				font-size: 9pt;
		}
		.buttonDisabled
		{
			    background-color: #D3D3D3;
			    color: white;
			    padding: 7px 15px;
			    text-align: center;
			    text-decoration: none;
			    display: inline-block;
				border-radius: 50px;
				border: 0px;
				font-family: Arial; 
				font-size: 10pt;
		}
		.newLink:hover, .newLink:active { 
			    background-color: #1E4DD3;
		}
	</style>
	 
	<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  	<!--- <link rel="stylesheet" href="/resources/demos/style.css"> --->
	<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
	<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
	<script src="https://code.jquery.com/jquery-1.10.2.js"></script> 
  	<cfinclude template="/Common_Files/jQuery.cfm">
	<cfset datatables.version = "1.9.3">	
	<cfset jQueryUI.widgets = "full">
	<cfinclude template="/common_files/jQueryUI.cfm">
	<cfinclude template="/Common_Files/dataTables.cfm">	
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
	<script src="/script/javascript/chosen/chosen.jquery.js" type="text/javascript"></script>	 
</head>

<body>
<cfoutput>

<div style="vertical-align: middle;"><h2><img src="/developer/iconmonstr-bug-11-32.png"> Regression Testing</h2></div>
<br>
	<form id="uploadTestFiles" name="uploadTestFiles" method="post" action="OCR_Testing.cfm?UID=#TestingUserID#" ENCTYPE="multipart/form-data">
		<!--- 		
			<div style="border-radius:15px; background: ##FFE4CA; padding:5px; border:2px solid red;width:90%;font-family: Century Gothic, CenturyGothic, Geneva, AppleGothic, sans-serif;font-size:12px;">
				<cfloop query="qGetValidSources">
				
					<input type="checkbox" name="chkSource" id="chkSource" value="#BB_Claim_Source_XREF_ID#">#Source_Code#<br>
					<cfset qGetType = OCRSettingsManager.getOCRSettingsOnXref(BB_Claim_Source_XREF_ID) />
					<cfloop query="qGetType">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- <input type="checkbox" name="chkType" id="chkType" value="#qGetType.OCR_Template_Settings_ID#">#OCR_Template_Name#<br>
					</cfloop>
					<br>
				</cfloop>
			</div>
		--->	
 
		<cfif bDisplayMappingUpload EQ 1>
			<cfif updateOCRUploadLog.File_Path NEQ "">
				<div>
				Select the Mapping(.csv) file to start the upload:<br>
				<input type="file" size="125" name="file" accept=".csv" style="border:radius:25px"/></div>
				[<a href="##" onclick="javascript:return submitForm('1');"><strong>upload mapping file</strong></a>]<br><br>
				
				<div style="border-radius:15px; background: ##FFE4CA; padding:5px; border:2px solid red;width:90%;font-family: Century Gothic, CenturyGothic, Geneva, AppleGothic, sans-serif;font-size:12px;">
				<!---DFFFFF  --->
				<u><h3>Instructions:</h3></u> 
						1) Go to the location <strong>#updateOCRUploadLog.File_Path#OCR_Upload_Test</strong> and delete all the PDF files from earlier testing.<br>
					2) Copy all the files mapped in the csv file in the location: <strong>#updateOCRUploadLog.File_Path#OCR_Upload_Test</strong><br>
					3) Make sure, the name of file in the uploaded CSV file is the same as the file that is copied to this location or the file will not be picked up for testing.
					<!--- 1) Click "Go" button to initiate regression testing.
					2) Come back to this page within few minutes to review the incremental status.
					3) Refresh the browser to see the most updated results.
					4) In case you want to run limited testing, only keep the limited files in this folder "<strong>#updateOCRUploadLog.File_Path#OCR_Upload_Test</strong>" --->
				</div>
			<cfelse>
				<div>
					NOTE: The Pickup location for the mapped file is not setup in the Billback_Upload_settings. Please contact DEV Support to set up and then try again.
				</div>
			</cfif>
		</cfif>		
		
		<div style="border-radius:15px; background: ##FFE4CA; padding:5px; border:2px solid red;width:90%;font-family: Century Gothic, CenturyGothic, Geneva, AppleGothic, sans-serif;font-size:12px;">
				<!---DFFFFF  --->
				<u><h3>Instructions:</h3></u> 
				<!--- 1) Go to the location <strong>#updateOCRUploadLog.File_Path#OCR_Upload_Test</strong> and confirm that the files that need to be tested are placed here.<br>
				2) Click on the "Go>>" button and check back later to find the status of the upload, as it will take sometime for the upload to complete. --->
				1) Click "Go" button to initiate regression testing.<br>
				2) Come back to this page within few minutes to review the incremental status.<br>
				3) Refresh the browser to see the most updated results.<br>
				4) In case you want to run limited testing, only keep the limited files in this folder "<strong>#updateOCRUploadLog.File_Path#OCR_Upload_Test</strong>"
				<br><br>
				<div align="center" width="100%" id="uploadActive"><a href="##" onclick="javascript:return submitForm('1');" class="newLink">Go >>></a></div>
				<div align="center" width="5" id="uploadInactive" style="display:none;"><button class="buttonDisabled" disabled>Go >>></button></div>
		</div>
		
		<input type="hidden" value="0" id="Submitted" name="Submitted" />
		
		<br>
		<br>
 <!--- /*****************************************************************************************************************************/		--->
 		
		<cfif (isDefined("ResultsSection") and ResultsSection NEQ "")>
		<hr class="style12">	
			#ResultsSection#
		</cfif>	
<!--- /********************************    DISPLAY DETAILS SECTION    ***************************************************************/		--->
		<hr class="style12">		
		<h3>Display Details about Testing</h3>
		<select name="selDtlRec" id="selDelRec" size="1" style="width:250px" data-placeholder="Select a Log Record" style="z-index: 5000 !important;">
				 <option>Pick a row to Display Details</option>
				<cfloop query="qryOCRUploadTestLog">
					<option value="#qryOCRUploadTestLog.OCR_Upload_Test_Log_ID#" <cfif (qryOCRUploadTestLog.OCR_Upload_Test_Log_ID EQ recToDetail)>selected</cfif>>Batch #qryOCRUploadTestLog.OCR_Upload_Test_Log_ID# - #DateFormat(qryOCRUploadTestLog.Created_Date,"mm/dd/yyyy")# #TimeFormat(qryOCRUploadTestLog.Created_Date,"HH:MM:SS")#</option> <!--- - #qryOCRUploadTestLog.File_Name# --->
				</cfloop>
		</select>
		
		[<a href="##" onclick="javascript:return submitForm('3');"><strong>Display Details about the test</strong></a>]<br><br>
		
		<cfif isDefined("DetailsSection") and DetailsSection NEQ "">
		<div style="background-color:##EFEFEF">
			#DetailsSection#
		</div>
		</cfif>	
 


<!--- /*****************************************************************************************************************************/		--->
		<hr class="style12">
		<h3>Delete Testing Batch</h3>
 
		<select name="selDelRec" id="selDelRec" size="1" style="width:300px" data-placeholder="Select a Log Record" style="z-index: 5000 !important;">
				 <option>Pick a row to Delete the Testing Batch</option>
				<cfloop query="qryOCRUploadTestLog">
					<option value="#qryOCRUploadTestLog.OCR_Upload_Test_Log_ID#">#qryOCRUploadTestLog.OCR_Upload_Test_Log_ID# - #qryOCRUploadTestLog.File_Name# - #DateFormat(qryOCRUploadTestLog.Created_Date,"mm/dd/yyyy")# #TimeFormat(qryOCRUploadTestLog.Created_Date,"HH:MM:SS")#</option>
				</cfloop>
		</select>
		
		[<a href="##" onclick="javascript:return submitForm('2');"><strong>Delete Selected Record</strong></a>]<br><br>
		
		<hr class="style12">
	</form>
	

</cfoutput>

 
</body>
</html>
 
<!---- 
1) 
Getting the file size of the file -> try using 
<cfdirectory 
	action="list" 
	directory="#expandpath('images/')#" 
	name="qImages" 
	filter="*.png" />
--->
	<cfif recordDeleted EQ "1">
		<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
		<script>
	 	noty({
	                text: "The Selected batch of upload has been successfully deleted.",
	                layout: "topCenter",
	                type: 'success',
	                timeout:3500  });
		</script>
	</cfif>			