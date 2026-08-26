 <!---Deletes any pre-existing information for the period from the table--->
<cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Invoice_Summary
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
</cfquery>

<!---Gets all distinct records--->
<cfquery name="DistinctInvoiceDistributors" datasource="#application.datasource#">
SELECT DISTINCT RP_Mapping_Table.FP_Start_Date, RP_Mapping_Table.FP_End_Date, RP_Mapping_Table.Legacy_Ship_To, RP_Mapping_Table.Shared_Ship_To, Invoice_Header.Invoice_Date, Invoice_Header.Order_Number + '-' + Invoice_Header.Invoice_Version AS Invoice_Number, RP_Mapping_Table.Invoice_Header_ID, RP_Mapping_Table.Distributor_ID, Invoice_Header.Purchase_Order
FROM RP_Mapping_Table
	INNER JOIN Invoice_Header
	ON Invoice_Header.Invoice_Header_ID = RP_Mapping_Table.Invoice_Header_ID
	<!--- AND (Invoice_Header.Deleted = 0 OR Invoice_Header.Invoice_Credit_Flag = 'C') --->
	INNER JOIN Invoice_Detail
	ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
	<!--- AND (Invoice_Detail.Deleted = 0 OR Invoice_Header.Invoice_Credit_Flag = 'C') --->
	WHERE RP_Mapping_Table.FP_Start_Date = '#Fiscal_Period_Start_Date#'
AND RP_Mapping_Table.FP_End_Date = '#Fiscal_Period_End_Date#' 
</cfquery>

<!--- <cfdump var="#DistinctInvoiceDistributors#"> --->

	<cfloop query="DistinctInvoiceDistributors">
			
		<!---Sum distributor--->
		<cfquery name="DollarsforDistforInvoice" datasource="#application.datasource#">
		SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Dist_Payment_Amount
		FROM RP_Mapping_Table
		WHERE Invoice_Header_ID = '#DistinctInvoiceDistributors.Invoice_Header_ID#'
		AND Record_Type = 1
		</cfquery>
		<!--- <cfdump var="#DollarsforDistforInvoice#"> --->
			
		<!---Sum distributor--->
		<cfquery name="SalesforDistInvoice" datasource="#application.datasource#">
		SELECT isnull(SUM(isnull(Total_Eligible_Trade, 0)), 0) AS Dist_Sales
		FROM RP_Mapping_Table
		WHERE Invoice_Header_ID = '#DistinctInvoiceDistributors.Invoice_Header_ID#'
		AND Record_Type = 1
		AND RP_Mapping_Table_ID = (SELECT TOP 1 RMT.RP_Mapping_Table_ID FROM RP_Mapping_Table RMT
						WHERE RMT.Invoice_Header_ID = RP_Mapping_Table.Invoice_Header_ID
						AND RMT.Record_Type = RP_Mapping_Table.Record_Type
						AND RMT.Invoice_Detail_ID = RP_Mapping_Table.Invoice_Detail_ID
						)	
						
		</cfquery>
		
		<cfquery name="GetallRecords" datasource="#application.datasource#">
		SELECT * FROM RP_Mapping_Table
		WHERE Invoice_Header_ID = '#DistinctInvoiceDistributors.Invoice_Header_ID#'
		AND Record_Type = 1
		AND Program_ID = (SELECT TOP 1 RP.Program_ID FROM RP_Mapping_Table RP WHERE
						RP.Invoice_Header_ID = RP_Mapping_Table.Invoice_Header_ID
						AND RP.Record_Type = RP_Mapping_Table.Record_Type)
		ORDER BY Invoice_Line_Number	
		</cfquery>
		
		<!---Sum payment amount buying group--->
		<cfquery name="DollarsforBGforInvoice" datasource="#application.datasource#">
		SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS BG_Payment_Amount
		FROM RP_Mapping_Table
		WHERE Invoice_Header_ID = '#DistinctInvoiceDistributors.Invoice_Header_ID#'
		AND Record_Type = 2
		</cfquery>
		
		<!---Sum gross sales buying group--->
		<cfquery name="SalesforBGInvoice" datasource="#application.datasource#">
		SELECT  isnull(SUM(isnull(Total_Eligible_Trade, 0)), 0) AS BG_Sales
		FROM RP_Mapping_Table
		WHERE Invoice_Header_ID = '#DistinctInvoiceDistributors.Invoice_Header_ID#'
		AND Record_Type = 2
		AND Program_ID = (SELECT TOP 1 RP.Program_ID FROM RP_Mapping_Table RP WHERE
						RP.Invoice_Header_ID = RP_Mapping_Table.Invoice_Header_ID
						AND RP.Record_Type = RP_Mapping_Table.Record_Type)		
		AND RP_Mapping_Table_ID = (SELECT TOP 1 RMT.RP_Mapping_Table_ID FROM RP_Mapping_Table RMT
						WHERE RMT.Invoice_Header_ID = RP_Mapping_Table.Invoice_Header_ID
						AND RMT.Record_Type = RP_Mapping_Table.Record_Type
						AND RMT.Invoice_Detail_ID = RP_Mapping_Table.Invoice_Detail_ID
						)	
		</cfquery>
				
		<!---Insert it all into the database--->
		<cfquery name="InsertValues" datasource="#application.datasource#">
		INSERT INTO RP_Invoice_Summary
		(
		Fiscal_Period_Start_Date,
		Fiscal_Period_End_Date,
		Legacy_Ship_To,
		Shared_Ship_To,
		Distributor_ID,
		Invoice_Number,
		Invoice_Date,
		BG_Sales,
		Dist_Sales,
		Total_BG_Dollars,
		Total_Dist_Dollars, 
		Purchase_Order
		)
		VALUES
		(
		'#FP_Start_Date#',
		'#FP_End_Date#',
		'#Legacy_Ship_To#',
		'#Shared_Ship_To#',
		'#Distributor_ID#',
		'#Invoice_Number#',
		'#Invoice_Date#',
		'#SalesforBGInvoice.BG_Sales#',
		'#SalesforDistInvoice.Dist_Sales#',
		#DollarsforBGforInvoice.BG_Payment_Amount#,
		#DollarsforDistforInvoice.Dist_Payment_Amount#,
		'#Purchase_Order#'
		)
		</cfquery>
	
	</cfloop>

<!--- <cfquery name="SelectAll" datasource="#application.datasource#">
SELECT * FROM RP_Invoice_Summary
</cfquery>	
<cfdump var="#SelectAll#">
<hr>  --->
