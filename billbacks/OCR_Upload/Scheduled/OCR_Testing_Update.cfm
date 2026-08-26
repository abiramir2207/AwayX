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
	
	<cfquery name="qryNewUploads" datasource="#application.datasource#">
		SELECT * FROM OCR_Upload_Log WHERE OCR_Upload_ID = #qryRecordsToProcess.OCR_Upload_ID#
	</cfquery>
	<cfquery name="qryTestset" datasource="#application.datasource#">
		SELECT * FROM OCR_Upload_Log_TestSet WHERE OCR_Upload_ID = #qryRecordsToProcess.OCR_Upload_TestSet_ID#
	</cfquery>
	
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
				<cfquery name="qryUpdDetailSummaryDisplay1" datasource="#application.datasource#">
						UPDATE OCR_Upload_Test_Log_Detail_Summary 
						SET  Display_Status = 'COMPLETE',
						iDone = 1
						WHERE 
						OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
				</cfquery>
			<cfelseif ((qryNewUploads.OCR_Step EQ '7' OR qryNewUploads.OCR_Step EQ '9') AND  qryTestset.OCR_Step NEQ qryNewUploads.OCR_Step)>
				<cfquery name="qryUpdDetailSummaryDisplay2" datasource="#application.datasource#">
						UPDATE OCR_Upload_Test_Log_Detail_Summary 
						SET  Display_Status = 'IN PROGRESS'
						WHERE 
						OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
				</cfquery>
			<cfelseif ((qryNewUploads.OCR_Step EQ '2.CF_Error' OR qryNewUploads.OCR_Step EQ '2.CF_ParseError' OR qryNewUploads.OCR_Step EQ '2.DB_Error' OR
				qryNewUploads.OCR_Step EQ '4.DB_Error' OR  qryNewUploads.OCR_Step EQ '6' OR qryNewUploads.OCR_Step EQ '6.DB_Error'  OR qryNewUploads.OCR_Step EQ '9.DB_Error' OR
				qryNewUploads.OCR_Step EQ '10') AND  (qryTestset.OCR_Step NEQ qryNewUploads.OCR_Step))>
				<cfquery name="qryUpdDetailSummaryDisplay3" datasource="#application.datasource#">
						UPDATE OCR_Upload_Test_Log_Detail_Summary 
						SET  Display_Status = 'ERROR',
							 iDone = 1
						WHERE 
						OCR_Upload_Test_Log_Detail_Summary_ID = #qryRecordsToProcess.OCR_Upload_Test_Log_Detail_Summary_ID#
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop> <!--- <cfloop query="qryNewUploads"> --->
</cfloop><!--- <cfloop query="qryRecordsToProcess"> --->

	
	<cfquery name="qryTestLog" datasource="#application.datasource#">
		SELECT DISTINCT OCR_Upload_Test_Log_ID FROM OCR_Upload_Test_Log_Detail_Summary
	</cfquery>

	<cfloop query="qryTestLog">	
		<cfset OCRUploadTestLogID = qryTestLog.OCR_Upload_Test_Log_ID />
		<cfquery name="qryRecordsToProcess2" datasource="#application.datasource#">
			SELECT * FROM OCR_Upload_Test_Log_Detail_Summary WHERE OCR_Upload_Test_Log_ID = #OCRUploadTestLogID#
		</cfquery>
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
	 
	 


