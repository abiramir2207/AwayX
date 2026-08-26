<cfset variables.oSettlement = CreateObject("component","mvc.Models.Billback.BillbackSettlementManager")>

<cfquery name="GetItems" datasource="#application.datasource#">
	SELECT 
	SUM(
			CASE 
			WHEN Billback_Product.BB_Product_UOM = 1 AND BB_Item_Final.Item_E_Volume_CS IS NOT NULL THEN
				CAST(IsNull(BB_Item_Final.Item_E_Volume_CS,0) * IsNull(Expected_Rate_CS,0)  As decimal(18,2))

			WHEN Billback_Product.BB_Product_UOM <> 1 AND BB_Item_Final.Item_E_Volume_LB IS NOT NULL THEN
				CAST(IsNull(BB_Item_Final.Item_E_Volume_LB,0) * IsNull(Expected_Rate_LB,0)  As decimal(18,2))

			WHEN Billback_Product.BB_Product_UOM = 1  AND BB_Item_Final.Item_BB_Volume_CS IS NOT NULL THEN
				CAST(ISNull(BB_Item_Final.Item_BB_Volume_CS, 0) * IsNull(Expected_Rate_CS,0)  As decimal(18,2))

			WHEN Billback_Product.BB_Product_UOM <> 1 AND BB_Item_Final.Item_BB_Volume_LB IS NOT NULL THEN
				CAST(ISNull(BB_Item_Final.Item_BB_Volume_LB, 0) * IsNull(Expected_Rate_LB,0)  As decimal(18,2))
			
			ELSE
				CAST(0 As decimal(18,2))
			END
		)
		As ExpectedTotal
	FROM 	BB_Item_Final
			INNER JOIN Billback_Product
			ON
			Billback_Product.Deleted = 0
			AND
			Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
			INNER JOIN BB_Item_Final_Detail
			ON BB_Item_Final.BB_Item_Final_id = BB_Item_Final_Detail.BB_Item_Final_id
	WHERE 
			BB_Item_Final.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND BB_Item_Final.Deleted = 0 
			AND BB_Item_Final_Detail.Deleted = 0
			AND BB_Item_Final_Detail.BB_Product_Type != 3 
			AND BB_Item_Final_Detail.BB_Product_Type !=4
</cfquery>

<cfset ExpectedTotal = variables.oSettlement.NumericRoundDecimal(val(GetItems.ExpectedTotal), 2) />