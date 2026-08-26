<!----
Document Name:	/common_files/contracts/discount_queries.cfm
Directory:		/
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	May 5, 2004
Revised:		This file queries each and every discount type to see if it is associated with the program. It is used in approval where discount types are required, in for the checks and xes that indicate if a section has been completed.
--->

<cfif NOT IsDefined("Discount_Queries_Called") or Discount_Queries_Called eq 0>

<cfset Discount_Queries_Called = 1 />

<cfif len(trim(Contract_Main_ID)) LT 1>
	<cfset Contract_Main_ID = 0>
</cfif>

	<!---Fixed--->
	<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
	<CFQUERY NAME="FixedPricesStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT     Contract_Products.Deleted
	FROM       Contract_Products 
		<!--- DEV NOTE: DAA; D15530
		INNER JOIN Program_Fixed_Price_Product_Data ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
		WHERE     (Program_Fixed_Price_Product_Data.Deleted = 0) 
			AND (Contract_Products.Deleted = 0) 
			AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#)
		 --->
			
	WHERE (Contract_Products.Deleted = 0) 
		AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#) 
		AND Product_Type_ID = 1
	</CFQUERY>
	<cfelse>
		<cfset	FixedPricesStatus = queryNew("Deleted")/>
	</cfif>

	<!---Formula--->
	<CFIF GetSettings.Discount_Formula_Pricing EQ 1>
	<CFQUERY NAME="FormulaStatus" datasource="#application.datasource#" MAXROWS="1">
		SELECT     Program_ID
		FROM       Program_Formula_Pricing_Rule_Mapped
		WHERE     (Deleted = 0) 
			AND (Program_ID = #Contract_Main_ID#)
	</CFQUERY>
	</cfif>
	
	<!---Rebate--->
	<CFIF GetSettings.Discount_Rebates EQ 1>
	<CFQUERY NAME="RebateStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT	Contract_Products.Deleted
	FROM 	Contract_Products 
	<!--- DEV NOTE: DAA; D15530
	INNER JOIN	Program_Rebates_Product_Data ON Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID
	WHERE	(Program_Rebates_Product_Data.Deleted = 0) 
		AND	(Contract_Products.Deleted = 0) 
		AND	(Contract_Products.Contract_Main_ID = #Contract_Main_ID#)
	 --->
			
	WHERE (Contract_Products.Deleted = 0) 
		AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#) 
		AND Product_Type_ID = 2
	</CFQUERY>
	<cfelse>
		<cfset	RebateStatus = queryNew("Deleted") />
	</cfif>
	
	<!---Growth--->
	<CFIF GetSettings.Discount_Growth EQ 1>
	<CFQUERY NAME="GrowthStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT	Contract_Products.Deleted
	FROM	Contract_Products 

	<!--- DEV NOTE: DAA; D15530 	
	INNER JOIN	Program_Growth_Component_Product_Data ON Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
	WHERE	(Program_Growth_Component_Product_Data.Deleted = 0) 
		AND (Contract_Products.Deleted = 0) 
		AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#)
	 --->
			
	WHERE (Contract_Products.Deleted = 0) 
		AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#) 
		AND Product_Type_ID = 4
	</CFQUERY>
	</cfif>
	
	<!---Lump sums--->
	<CFIF GetSettings.Discount_Lump_Sums EQ 1>
	<CFQUERY NAME="LumpStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT	Program_Lump_Sums.Deleted
	FROM	Program_Lump_Sums
	<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
	INNER JOIN Program_Lump_Sum_Product_Data
	ON	Program_Lump_Sum_Product_Data.Deleted = 0
	AND	Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
	</cfif>
	WHERE	Program_Lump_Sums.Deleted = 0
	AND 	Program_Lump_Sums.Program_ID = #Contract_Main_ID#
	</CFQUERY>
	</cfif>
	
	<!---Bid request--->
<CFIF GetSettings.Generic_Type IS "Bid Request" and GetSettings.Discount_BidRequest EQ 1>
<CFQUERY NAME="BidStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT	Contract_Products.Deleted
	FROM 	Contract_Products 
	INNER JOIN Program_Bid_Request_Product ON 
		Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
		WHERE     (Program_Bid_Request_Product.Deleted = 0) 
			AND (Contract_Products.Deleted = 0) 
			AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#)
			AND Contract_Products.product_type_id = 10
</CFQUERY>
</cfif>
	<!---Off Invoice--->
<CFIF GetSettings.Generic_Type IS "Distributor Off-Invoice">
	<cfset useLakebaseForOff_Invoice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_offinvoice_product_data")>
<cfif useLakebaseForOff_Invoice>
	<cftry>
		<cfset Off_Invoice = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_offinvoice_product_data", {
				"program_id" = "eq.#Contract_Main_ID#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOff_Invoice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOff_Invoice>
<cfquery name="Off_Invoice" datasource="#application.datasource#">
	SELECT 	TOP 1 Program_ID
	FROM 	Program_OffInvoice_Product_Data 
	WHERE 	Program_ID = #Contract_Main_ID#
			AND
			Deleted = 0
	</cfquery>
</cfif>
</cfif>

<!--- Claim Mechanics --->
<cfquery name="GetPaymentTypesforTemplate" datasource="#application.datasource#">
SELECT distinct Payment_Type.Payment_Type_Name, Payment_Type.Payment_Type_ID
FROM Payment_Template_Mapping 
	INNER JOIN Payment_Type
	ON Payment_Type.Payment_Type_ID = Payment_Template_Mapping.Payment_Type_ID 
WHERE Payment_Template_Mapping.Deleted = 0
AND Payment_Template_Mapping.Template_ID = '#GetSettings.ProgramControl_Panel_Options_ID#'
ORDER BY Payment_Type.Payment_Type_Name
</cfquery>

<cfif GetSettings.Include_Competitive_Data_Tracking EQ 1>
<CFQUERY NAME="CompetitiveDataStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT	Program_Competitive_Data.product_id
	FROM	Program_Competitive_Data 
	WHERE	(Program_Competitive_Data.program_id = #Contract_Main_ID#)
	</CFQUERY>
</cfif>

</cfif>