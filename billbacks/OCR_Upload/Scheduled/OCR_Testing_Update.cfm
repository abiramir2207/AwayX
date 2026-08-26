 <!-----------------------------------------------------------------------------

FILE NAME:		OCR_Testing_Update.cfm
DESCRIPTION:	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	03-Apr-2018	

------------------------------------------------------------------------------> 


<!--- Updater --->

<cfquery name="qryRecordsToProcess" datasource="#application.datasource#">
	SELECT * FROM OCR_Upload_Test_Log_Detail_Summary WHERE OCR_Upload_Test_Log_ID IN (
	SELECT Distinct OCR_Upload_Test_Log_ID FROM OCR_Upload_Test_Log_Detail_Summary WHERE iDone = 0 ) 
</cfquery>
 
<cfloop query="qryRecordsToProcess">
	
	<cfset useLakebaseForqryNewUploads = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForqryNewUploads>
	<cftry>
		<cfset qryNewUploads = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log", {
				"ocr_upload_id" = "eq.#qryRecordsToProcess.OCR_Upload_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryNewUploads = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryNewUploads>
<cfquery name="qryNewUploads" datasource="#application.datasource#">
		SELECT * FROM OCR_Upload_Log WHERE OCR_Upload_ID = #qryRecordsToProcess.OCR_Upload_ID#
	</cfquery>
</cfif>
	<cfset useLakebaseForqryTestset = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log_testset")>
<cfif useLakebaseForqryTestset>
	<cftry>
		<cfset qryTestset = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_log_testset", {
				"ocr_upload_id" = "eq.#qryRecordsToProcess.OCR_Upload_TestSet_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryTestset = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryTestset>
<cfquery name="qryTestset" datasource="#application.datasource#">
		SELECT * FROM OCR_Upload_Log_TestSet WHERE OCR_Upload_ID = #qryRecordsToProcess.OCR_Upload_TestSet_ID#
	</cfquery>
</cfif>
	
	<cfloop query="qryNewUploads">
		<!--- <cfloop query="qryTestset"> --->
		
		<cfif (qryNewUploads.OCR_Step EQ '2.CF_Error' OR qryNewUploads.OCR_Step EQ '2.CF_ParseError' OR qryNewUploads.OCR_Step EQ '2.DB_Error' OR
				qryNewUploads.OCR_Step EQ '4.DB_Error' OR  qryNewUploads.OCR_Step EQ '6' OR qryNewUploads.OCR_Step EQ '6.DB_Error' OR
				qryNewUploads.OCR_Step EQ '7' OR qryNewUploads.OCR_Step EQ '9' OR qryNewUploads.OCR_Step EQ '9.DB_Error' OR
				qryNewUploads.OCR_Step EQ '10' OR qryNewUploads.OCR_Step EQ '11' OR qryNewUploads.OCR_Step EQ '12' OR qryNewUploads.OCR_Step EQ '13')>
			
			
<!--- 		<cfquery name="qryDetailSummary2" datasource="#application.datasource#">
				SELECT  
						* 
					FROM OCR_Upload_Test_Log_Detail_Summary ODS
					INNER JOIN  OCR_Upload_Test_Log OTL ON OTL.OCR_Upload_Test_Log_ID = ODS.OCR_Upload_Test_Log_ID
			 
					INNER JOIN dbo.OCR_Upload_Log OUL ON OUL.OCR_Upload_ID = ODS.OCR_Upload_ID
					INNER JOIN dbo.OCR_Template_Settings OTS ON OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID
				WHERE ODS.OCR_Upload_Test_Log_ID = #recToDetail#
			</cfquery>	 --->
			
			<cfquery name="qryGetOCRTestSet2" datasource="#application.datasource#">
				SELECT 
					COUNT(DISTINCT (customer_Reference_number)) AS Total_Invoices_Actual,
					COUNT(*) AS Total_Line_Items_Actual, 
					ISNULL(SUM(CASE ISNUMERIC(Item_Amount) 
			        	 WHEN 1 THEN ISNULL(CAST(Item_Amount AS Float),'0')
			        	 ELSE 0 
			      		 END),0) AS Total_Amount_Actual, 
			  		ISNULL(SUM(CASE ISNUMERIC(Item_Quantity) 
			        	 WHEN 1 THEN ISNULL(CAST(Item_Quantity AS Float),'0')
			         	ELSE 0 
			       		END),0) AS Total_Quantity_Actual
				FROM OCR_Trackmax1_Excel_Format
				WHERE OCR_Upload_ID = #qryNewUploads.OCR_Upload_ID#
			</cfquery>
	
			<cfset TotalInvoicesActual	= qryGetOCRTestSet2.Total_Invoices_Actual />
			<cfset TotalLineItemsActual	= qryGetOCRTestSet2.Total_Line_Items_Actual  />
			<cfset TotalAmountActual	= qryGetOCRTestSet2.Total_Amount_Actual  />
			<cfset TotalQuantityActual	= qryGetOCRTestSet2.Total_Quantity_Actual  />
		
			<cfquery name="qryUpdDetailSummary" datasource="#application.datasource#">
				UPDATE OCR_Upload_Test_Log_Detail_Summary 
				SET OCR_Step_Actual 		= '#qryNewUploads.OCR_Step#',
					Total_Invoices_Actual 	= #TotalInvoicesActual#,
					Total_Line_Items_Actual	= #TotalLineItemsActual#,
					Total_Amount_Actual 	= #TotalAmountActual#,
					Total_Quantity_Actual 	= #TotalQuantityActual#
				WHERE 
				OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
			</cfquery>
		</cfif>
		<!--- </cfloop> <!--- <cfloop query="qryTestset"> ---> --->
		
		<cfloop query="qryTestset"> 
			<cfif ((qryTestset.OCR_Step EQ qryNewUploads.OCR_Step) OR qryNewUploads.OCR_Step EQ '13' OR qryNewUploads.OCR_Step EQ '12' OR qryNewUploads.OCR_Step EQ '7' OR qryNewUploads.OCR_Step EQ '9' )>
				<cfset useLakebaseForqryUpdDetailSummaryDisplay1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log_detail_summary")>
<cfif useLakebaseForqryUpdDetailSummaryDisplay1>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_test_log_detail_summary",
			{
				"ocr_upload_test_log_detail_summary_id" = "eq.#qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#"
			},
			{
				"display_status" = "COMPLETE",
				"idone" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryUpdDetailSummaryDisplay1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryUpdDetailSummaryDisplay1>
<cfquery name="qryUpdDetailSummaryDisplay1" datasource="#application.datasource#">
						UPDATE OCR_Upload_Test_Log_Detail_Summary 
						SET  Display_Status = 'COMPLETE',
						iDone = 1
						WHERE 
						OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
				</cfquery>
</cfif>
			<cfelseif ((qryNewUploads.OCR_Step EQ '7' OR qryNewUploads.OCR_Step EQ '9') AND  qryTestset.OCR_Step NEQ qryNewUploads.OCR_Step)>
				<cfset useLakebaseForqryUpdDetailSummaryDisplay2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log_detail_summary")>
<cfif useLakebaseForqryUpdDetailSummaryDisplay2>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_test_log_detail_summary",
			{
				"ocr_upload_test_log_detail_summary_id" = "eq.#qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#"
			},
			{
				"display_status" = "IN PROGRESS"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryUpdDetailSummaryDisplay2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryUpdDetailSummaryDisplay2>
<cfquery name="qryUpdDetailSummaryDisplay2" datasource="#application.datasource#">
						UPDATE OCR_Upload_Test_Log_Detail_Summary 
						SET  Display_Status = 'IN PROGRESS'
						WHERE 
						OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
				</cfquery>
</cfif>
			<cfelseif ((qryNewUploads.OCR_Step EQ '2.CF_Error' OR qryNewUploads.OCR_Step EQ '2.CF_ParseError' OR qryNewUploads.OCR_Step EQ '2.DB_Error' OR
				qryNewUploads.OCR_Step EQ '4.DB_Error' OR  qryNewUploads.OCR_Step EQ '6' OR qryNewUploads.OCR_Step EQ '6.DB_Error'  OR qryNewUploads.OCR_Step EQ '9.DB_Error' OR
				qryNewUploads.OCR_Step EQ '10') AND  (qryTestset.OCR_Step NEQ qryNewUploads.OCR_Step))>
				<cfset useLakebaseForqryUpdDetailSummaryDisplay3 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log_detail_summary")>
<cfif useLakebaseForqryUpdDetailSummaryDisplay3>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_test_log_detail_summary",
			{
				"ocr_upload_test_log_detail_summary_id" = "eq.#qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#"
			},
			{
				"display_status" = "ERROR",
				"idone" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryUpdDetailSummaryDisplay3 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryUpdDetailSummaryDisplay3>
<cfquery name="qryUpdDetailSummaryDisplay3" datasource="#application.datasource#">
						UPDATE OCR_Upload_Test_Log_Detail_Summary 
						SET  Display_Status = 'ERROR',
							 iDone = 1
						WHERE 
						OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
				</cfquery>
</cfif>
			</cfif>
		</cfloop>
	</cfloop> <!--- <cfloop query="qryNewUploads"> --->
</cfloop><!--- <cfloop query="qryRecordsToProcess"> --->

	
	<cfset useLakebaseForqryTestLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log_detail_summary")>
<cfif useLakebaseForqryTestLog>
	<cftry>
		<cfset qryTestLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_test_log_detail_summary", {
				"select" = "ocr_upload_test_log_id"
			}), "ocr_upload_test_log_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryTestLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryTestLog>
<cfquery name="qryTestLog" datasource="#application.datasource#">
		SELECT DISTINCT OCR_Upload_Test_Log_ID FROM OCR_Upload_Test_Log_Detail_Summary
	</cfquery>
</cfif>

	<cfloop query="qryTestLog">	
		<cfset OCRUploadTestLogID = qryTestLog.OCR_Upload_Test_Log_ID />
		<cfset useLakebaseForqryRecordsToProcess2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_test_log_detail_summary")>
<cfif useLakebaseForqryRecordsToProcess2>
	<cftry>
		<cfset qryRecordsToProcess2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ocr_upload_test_log_detail_summary", {
				"ocr_upload_test_log_id" = "eq.#OCRUploadTestLogID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryRecordsToProcess2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryRecordsToProcess2>
<cfquery name="qryRecordsToProcess2" datasource="#application.datasource#">
			SELECT * FROM OCR_Upload_Test_Log_Detail_Summary WHERE OCR_Upload_Test_Log_ID = #OCRUploadTestLogID#
		</cfquery>
</cfif>
		<cfset countInProgress = 0 />
		<cfset countCompleted = 0 />
		<cfset countFailed = 0 />
		<cfset countTotal = 0 />
		<cfset endDate = "" />
		<cfloop query="qryRecordsToProcess2">
		
			<cfif (qryRecordsToProcess2.Display_Status EQ "IN PROGRESS")>
				<cfset countInProgress++ />
			<cfelseif (qryRecordsToProcess2.Display_Status EQ "COMPLETE")>
				<cfset countCompleted++ />
			<cfelseif (qryRecordsToProcess2.Display_Status EQ "ERROR")>
				<cfset countFailed++ /> 
			</cfif>
			<cfset countTotal++ /> 
		</cfloop>
		<cfif (countInProgress EQ "0")>
			<cfquery name="qryGetMaxDate" datasource="#application.datasource#">
				SELECT MAX(Updated_Date) AS MaxDate FROM dbo.OCR_Upload_Log WHERE OCR_Upload_Test_Log_ID = #OCRUploadTestLogID#
			</cfquery>
			<cfset endDate = qryGetMaxDate.MaxDate />
		</cfif>
		<cfquery name="updTestLog" datasource="#application.datasource#">
			UPDATE OCR_Upload_Test_Log 
			SET 
				<cfif endDate NEQ "">
					End_Time 			= '#endDate#', 
				</cfif>
				Total_Files_Count 	= '#countTotal#',
				In_Progress_Count	= #countInProgress#,
				Completed_Count		= #countCompleted#,
				Failed_Count		= #countFailed#
			WHERE OCR_Upload_Test_Log_ID = #OCRUploadTestLogID#
		</cfquery>
		
	</cfloop>
	 
	 


