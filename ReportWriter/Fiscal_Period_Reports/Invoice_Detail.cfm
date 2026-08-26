
 <!---Deletes any pre-existing information for the period from the table--->
<cfset useLakebaseForDeletePrior = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_invoice_detail")>
<cfif useLakebaseForDeletePrior>
	<cftry>
		<cfset application.oLakebase.deleteRows("rp_invoice_detail", {
			"fiscal_period_start_date" = "eq.#Fiscal_Period_Start_Date#",
			"fiscal_period_end_date" = "eq.#Fiscal_Period_End_Date#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDeletePrior = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePrior>
<cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Invoice_Detail
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#' 
</cfquery>
</cfif> 

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
		<cfset useLakebaseForInsertValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_invoice_detail")>
<cfif useLakebaseForInsertValues>
	<cftry>
		<cfset application.oLakebase.insertRow("rp_invoice_detail", {
			"distributor_id" = "#Distributor_ID#",
			"item_number" = "#Item_Number#",
			"fiscal_period_start_date" = "#FP_Start_Date#",
			"fiscal_period_end_date" = "#FP_End_Date#",
			"legacy_ship_to" = "#Legacy_Ship_To#",
			"shared_ship_to" = "#Shared_Ship_To#",
			"invoice_number" = "#Invoice_Number#",
			"invoice_date" = "#Invoice_Date#",
			"gross_sales" = "#GrossSales#",
			"bg_trade_rate" = "#BuyingGroupPayment.Trade_Rate#",
			"bg_item_earned" = "#BuyingGroupPayment.Item_Earned#",
			"d_trade_rate" = "#DistributorPayment.Trade_Rate#",
			"d_item_earned" = "#DistributorPayment.Item_Earned#",
			"total_item_earned" = "#Total_Item_Earned#",
			"total_trade_rate" = "#Total_Trade_Rate#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertValues>
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
</cfif>
	
	</cfloop>

<!--- <cfquery name="SelectAll" datasource="#application.datasource#">
SELECT * FROM RP_Invoice_Detail
</cfquery>	
<cfdump var="#SelectAll#">
<hr>
 --->