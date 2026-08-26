
 <!---Deletes any pre-existing information for the period from the table--->
<cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Invoice_Detail
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#' 
</cfquery> 

<!---Gets all distinct records--->
<cfquery name="DistinctInvoiceDistItem" datasource="#application.datasource#">
SELECT DISTINCT RP_Mapping_Table.FP_Start_Date, RP_Mapping_Table.FP_End_Date, RP_Mapping_Table.Legacy_Ship_To, RP_Mapping_Table.Shared_Ship_To, Invoice_Detail.Invoice_Date, Invoice_Detail.Order_Number + '-' + Invoice_Detail.Invoice_Version AS Invoice_Number, RP_Mapping_Table.Invoice_Detail_ID,  RP_Mapping_Table.Distributor_ID, RP_Mapping_Table.Item_Number, RP_Mapping_Table.Total_Eligible_Trade AS Gross_Sales
FROM RP_Mapping_Table
	INNER JOIN Invoice_Header
	ON Invoice_Header.Invoice_Header_ID = RP_Mapping_Table.Invoice_Header_ID
	<!--- AND (Invoice_Header.Deleted = 0 OR Invoice_Header.Invoice_Credit_Flag = 'C') --->
	INNER JOIN Invoice_Detail
	ON Invoice_Detail.Invoice_Detail_ID = RP_Mapping_Table.Invoice_Detail_ID
	<!--- AND (Invoice_Detail.Deleted = 0 OR Invoice_Header.Invoice_Credit_Flag = 'C') --->
WHERE RP_Mapping_Table.FP_Start_Date = '#Fiscal_Period_Start_Date#'
AND RP_Mapping_Table.FP_End_Date = '#Fiscal_Period_End_Date#'
AND Record_Type = 1
</cfquery>

	<!--- <cfdump var="#DistinctInvoiceDistItem#"> --->

	<Cfset InvoiceTotal = 0>
	<cfloop query="DistinctInvoiceDistItem">
	
	<!---Get Distributor Totals--->
	<cfquery name="DistributorPayment" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Item_Earned, isnull(SUM(isnull(Rebate_Sum, 0)), 0) AS Trade_Rate
	FROM RP_Mapping_Table
	WHERE Invoice_Detail_ID = '#DistinctInvoiceDistItem.Invoice_Detail_ID#'
	AND Record_Type = 1
	</cfquery>
	
	<!---Get Distributor Totals--->
	<cfquery name="GrossSalesAmount" datasource="#application.datasource#">
	SELECT isnull(Total_Eligible_Trade, 0) AS Gross_Sales
	FROM RP_Mapping_Table
	WHERE Invoice_Detail_ID = '#DistinctInvoiceDistItem.Invoice_Detail_ID#'
	AND Record_Type = 1
	AND RP_Mapping_Table_ID = (SELECT TOP 1 RMT.RP_Mapping_Table_ID FROM RP_Mapping_Table RMT
						WHERE Record_Type = 1 and RMT.Invoice_Detail_ID = RP_Mapping_Table.Invoice_Detail_ID
						)	
	</cfquery>
	
	<cfset GrossSales = GrossSalesAmount.Gross_Sales>
	
	<!---Get Buying Group Totals--->
	<cfquery name="BuyingGroupPayment" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Item_Earned, isnull(SUM(isnull(Rebate_Sum, 0)), 0) AS Trade_Rate
	FROM RP_Mapping_Table
	WHERE Invoice_Detail_ID = '#DistinctInvoiceDistItem.Invoice_Detail_ID#'
	AND Record_Type = 2
	</cfquery>

	<cfset Total_Item_Earned = DistributorPayment.Item_Earned + BuyingGroupPayment.Item_Earned>
	<cfset Total_Trade_Rate = DistributorPayment.Trade_Rate + BuyingGroupPayment.Trade_Rate>
	
		<!---Insert it all into the database--->
		<cfquery name="InsertValues" datasource="#application.datasource#">
		INSERT INTO RP_Invoice_Detail
		(
		Distributor_ID,
		Item_Number,
		Fiscal_Period_Start_Date,
		Fiscal_Period_End_Date,
		Legacy_Ship_To,
		Shared_Ship_To,
		Invoice_Number,
		Invoice_Date,
		Gross_Sales,
		BG_Trade_Rate,
		BG_Item_Earned,
		D_Trade_Rate,
		D_Item_Earned,
		Total_Item_Earned,
		Total_Trade_Rate
		)
		VALUES
		(
		'#Distributor_ID#',
		'#Item_Number#',
		'#FP_Start_Date#',
		'#FP_End_Date#',
		'#Legacy_Ship_To#',
		'#Shared_Ship_To#',
		'#Invoice_Number#',
		'#Invoice_Date#',
		'#GrossSales#',
		'#BuyingGroupPayment.Trade_Rate#',
		'#BuyingGroupPayment.Item_Earned#',
		'#DistributorPayment.Trade_Rate#',
		'#DistributorPayment.Item_Earned#',
		'#Total_Item_Earned#',
		'#Total_Trade_Rate#'
		)
		</cfquery>
	
	</cfloop>

<!--- <cfset useLakebaseForSelectAll = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_invoice_detail")>
<cfif useLakebaseForSelectAll>
	<cftry>
		<cfset SelectAll = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_invoice_detail", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelectAll = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelectAll>
<cfquery name="SelectAll" datasource="#application.datasource#">
SELECT * FROM RP_Invoice_Detail
</cfquery>
</cfif>	
<cfdump var="#SelectAll#">
<hr>
 --->