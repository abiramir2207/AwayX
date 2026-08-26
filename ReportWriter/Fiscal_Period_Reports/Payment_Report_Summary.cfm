 <!---Deletes any pre-existing information for the period from the table--->
 <cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Payment_Report_Summary
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#' 
</cfquery>

<!---Get data with which to populate Payment Report Summary--->
<cfquery name="dataforPaymentReportSummary" datasource="#application.datasource#">
SELECT DISTINCT RP_Mapping_Table.Legacy_Ship_To, RP_Mapping_Table.Shared_Ship_To, RP_Mapping_Table.Shared_Invoice_Number, RP_Mapping_Table.Invoice_Line_Number, RP_Mapping_Table.QBrand_ID, RP_Mapping_Table.Invoice_Detail_ID, RP_Mapping_Table.Item_Number, RP_Mapping_Table.Buying_Group, RP_Mapping_Table.UPC
FROM RP_Mapping_Table
WHERE RP_Mapping_Table.FP_Start_Date = '#Fiscal_Period_Start_Date#'
AND RP_Mapping_Table.FP_End_Date = '#Fiscal_Period_End_Date#' 
</cfquery>

<cfloop query="dataforPaymentReportSummary">

	<!---Get sum distributor programs--->
	<cfquery name="GetDistributorProgramSum" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Total_Dist_Dollars
	FROM RP_Mapping_Table
	WHERE Invoice_Line_Number = '#dataforPaymentReportSummary.Invoice_Line_Number#'
	AND Invoice_Detail_ID = '#dataforPaymentReportSummary.Invoice_Detail_ID#'
	AND Record_Type = '1'
	</cfquery>
	
	<!---Get Sum Buying Group Programs--->
	<cfquery name="GetBGProgramSum" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Total_BG_Dollars
	FROM RP_Mapping_Table
	WHERE Invoice_Line_Number = '#dataforPaymentReportSummary.Invoice_Line_Number#'
	AND Invoice_Detail_ID = '#dataforPaymentReportSummary.Invoice_Detail_ID#'
	AND Record_Type = '2'
	</cfquery>
	
	<!---Get Corporate Programs--->
	<!---Get Sum Buying Group Programs--->
	<cfquery name="GetCorpProgramSum" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Total_Corp_Dollars
	FROM RP_Mapping_Table
	WHERE Invoice_Line_Number = '#dataforPaymentReportSummary.Invoice_Line_Number#'
	AND Invoice_Detail_ID = '#dataforPaymentReportSummary.Invoice_Detail_ID#'
	AND Record_Type = '3'
	</cfquery>
		
		<cfquery name="InsertValue" datasource="#application.datasource#">
		INSERT INTO RP_Payment_Report_Summary
		(
			Fiscal_Period_Start_Date,
			Fiscal_Period_End_Date,
			Legacy_Ship_To,
			Shared_Ship_To,
			Shared_Invoice_Number,
			Invoice_Line_Number,
			QBrand_ID,
			Total_BG_Dollars,
			Total_Dist_Dollars,
			Total_Corp_Dollars,
			Record_Type,
			Item_Number,
			UPC,
			Buying_Group
		)
		VALUES
		(
			'#Fiscal_Period_Start_Date#',
			'#Fiscal_Period_End_Date#',
			'#Legacy_Ship_To#',
			'#Shared_Ship_To#',
			'#Shared_Invoice_Number#',
			'#Invoice_Line_Number#',
			'#QBrand_ID#',
			#numberformat(GetDistributorProgramSum.Total_Dist_Dollars, '.__')#,
			#numberformat(GetBGProgramSum.Total_BG_Dollars, '.__')#,
			#numberformat(GetCorpProgramSum.Total_Corp_Dollars, '.__')#,
			'Invoice', 
			'#Item_Number#',
			'#UPC#',
			'#Buying_Group#'
		)
		</cfquery>

</cfloop>

<!--- <cfset useLakebaseForGetAllPaymentvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_payment_report_summary")>
<cfif useLakebaseForGetAllPaymentvalues>
	<cftry>
		<cfset GetAllPaymentvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_payment_report_summary", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllPaymentvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllPaymentvalues>
<cfquery name="GetAllPaymentvalues" datasource="#application.datasource#">
SELECT * FROM RP_Payment_Report_Summary
</cfquery>
</cfif>
<cfdump var="#GetAllPaymentvalues#"> --->
	
	<!---Billbacks per distributor/item/type--->
	
	<cfset useLakebaseForGetSumofBillbacks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_billback_table")>
<cfif useLakebaseForGetSumofBillbacks>
	<cftry>
		<cfset GetSumofBillbacks = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_billback_table", {
				"fiscal_period_start_date" = "eq.#Fiscal_Period_Start_Date#",
				"fiscal_period_end_date" = "eq.#Fiscal_Period_End_Date#",
				"select" = "legacy_ship_to,shared_ship_to,qbrand_id,item_number"
			}), "legacy_ship_to,shared_ship_to,qbrand_id,item_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSumofBillbacks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSumofBillbacks>
<cfquery name="GetSumofBillbacks" datasource="#application.datasource#">
	SELECT DISTINCT Legacy_Ship_To, Shared_Ship_To, QBrand_ID, Item_Number
	FROM RP_Billback_Table
	WHERE RP_Billback_Table.Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND RP_Billback_Table.Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
	</cfquery>
</cfif>
	
	<cfloop query="GetSumofBillbacks">
				
		<!---Get distributor Sum--->
		<cfquery name="GetDistributor" datasource="#application.datasource#">
		SELECT isnull(sum(Billed_Back), 0) AS Dist_Billed_Back
		FROM  RP_Billback_Table
		WHERE Shared_Ship_To = '#GetSumofBillbacks.Shared_Ship_To#'
		AND Item_Number = '#GetSumofBillbacks.Item_Number#'
		AND BB_Summary_Type = 1
		</cfquery>
		
		<!---Get Buying Group Sum--->
		<cfquery name="GetBuyingGroup" datasource="#application.datasource#">
		SELECT isnull(sum(Billed_Back), 0) AS BG_Billed_Back
		FROM  RP_Billback_Table
		WHERE Shared_Ship_To = '#GetSumofBillbacks.Shared_Ship_To#'
		AND Item_Number = '#GetSumofBillbacks.Item_Number#'
		AND BB_Summary_Type = 2
		</cfquery>
		
		<!---Insert into Payment Report Summary--->
		<cfquery name="InsertBBs" datasource="#application.datasource#">
			INSERT INTO RP_Payment_Report_Summary
			(
				Fiscal_Period_Start_Date,
				Fiscal_Period_End_Date,
				Legacy_Ship_To,
				Shared_Ship_To,
				Shared_Invoice_Number,
				Invoice_Line_Number,
				Item_Number,
				QBrand_ID,
				Total_BG_Dollars,
				Total_Dist_Dollars,
				Record_Type, 
				UPC,
				Buying_Group
			)
			VALUES
			(
				'#Fiscal_Period_Start_Date#',
				'#Fiscal_Period_End_Date#', 
				'#Legacy_Ship_To#',
				'#Shared_Ship_To#',
				0,
				0,
				'#Item_Number#',
				'#QBrand_ID#',
				#GetDistributor.Dist_Billed_Back#,
				#GetBuyingGroup.BG_Billed_Back#,
				'Billback', 
				#UPC#,
				#Buying_Group#
			)
		</cfquery>
	<!---Billback table--->
	</cfloop>
	
	
	<!---Outputs values for troubleshooting--->
	<cfquery name="WriteReport" datasource="#application.datasource#">
	SELECT 
	RP_Payment_Report_Summary.Fiscal_Period_End_Date,
	RP_Payment_Report_Summary.Fiscal_Period_Start_Date,
	RP_Payment_Report_Summary.Legacy_Ship_To,
	RP_Payment_Report_Summary.Shared_Ship_To,
	RP_Payment_Report_Summary.Shared_Invoice_Number,
	RP_Payment_Report_Summary.Invoice_Line_Number,
	RP_Payment_Report_Summary.QBrand_ID,
	RP_Payment_Report_Summary.Total_BG_Dollars,
	RP_Payment_Report_Summary.Total_Dist_Dollars,
	RP_Payment_Report_Summary.Total_Corp_Dollars,
	RP_Payment_Report_Summary.Record_Type, 
	RP_Payment_Report_Summary.Item_Number,
	RP_Payment_Report_Summary.UPC, 
	RP_Payment_Report_Summary.Buying_Group
	FROM RP_Payment_Report_Summary
	WHERE Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
	AND Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
	</cfquery>

	<!---Create flat files--->
	<cfinclude template="/reportwriter/fiscal_period_reports/report_functions.cfm">
	
	
		<cfset arFields = ArrayNew(2)>
		
		<cfset arFields[1][1] = "Fiscal_Period_End_Date">
		<cfset arFields[1][2] = 21>
		<cfset arFields[2][1] = "Fiscal_Period_Start_Date">
		<cfset arFields[2][2] = 21>
		<cfset arFields[3][1] = "Legacy_Ship_To">
		<cfset arFields[3][2] = 10>
		<cfset arFields[4][1] = "Shared_Ship_To">
		<cfset arFields[4][2] = 10>
		<cfset arFields[5][1] = "Shared_Invoice_Number">
		<cfset arFields[5][2] = 10>
		<cfset arFields[6][1] = "Invoice_Line_Number">
		<cfset arFields[6][2] = 3>
		<cfset arFields[7][1] = "QBrand_ID">
		<cfset arFields[7][2] = 3>
		<cfset arFields[8][1] = "Total_BG_Dollars">
		<cfset arFields[8][2] = 15>
		<cfset arFields[9][1] = "Total_Dist_Dollars">
		<cfset arFields[9][2] = 15>
		<cfset arFields[10][1] = "Total_Corp_Dollars">
		<cfset arFields[10][2] = 15>
		<cfset arFields[11][1] = "Record_Type">
		<cfset arFields[11][2] = 8>
		<cfset arFields[12][1] = "Item_Number">
		<cfset arFields[12][2] = 10>
		<cfset arFields[13][1] = "UPC">
		<cfset arFields[13][2] = 10>
		<cfset arFields[14][1] = "Buying_Group">
		<cfset arFields[14][2] = 50>
		
		<cfset arLen = arrayLen(arFields)>
		
		<cfoutput>
		<cfsavecontent variable="AllDistributorAmounts">
		<cfloop query="WriteReport"><cfloop index="i" from="1" to="#arLen#">
			#padValues(evaluate(arFields[i][1]), arFields[i][2], " ")#
			</cfloop>#chr(13)##chr(10)#
			</cfloop>
		</cfsavecontent>
		</cfoutput>
		
		
		<CFFILE 
			ACTION = "Write" 
			FILE   = "#Application.Doc_path#\data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\#FilePath#\fernandos_payment_report_#Filepath#.txt" 
			OUTPUT = "#AllDistributorAmounts#" 
			ADDNEWLINE = "Yes"
			nameconflict = "overwrite"
		> 
		