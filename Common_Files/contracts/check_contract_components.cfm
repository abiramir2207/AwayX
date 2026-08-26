<!--- Dev Note:Milan (13264 and 13421)
			If there are no products in the program for a discount type, delete all the components from the component table.
			This is to make sure that there are never any orphan components in the program. 
--->

<!--- Only do the update for discounts that actually have products on that type of discount. We do this by checking the discount types
			of the parent program. We do this only for copies and revisions. --->

<cfset Program_ID = Renewed_Program_ID>

<!--- Get the products from the parent program (whether a parent of a copied program or a revised program)--->
<cfquery name="GetDiscountList" datasource="#application.datasource#">
	SELECT DISTINCT Product_Type_ID
	FROM Contract_Products
	WHERE Contract_Main_ID = (SELECT Renewal_of_Contract_Main_ID
	FROM Contract_Main
	WHERE Contract_Main_ID =  '#Program_ID#'
	AND Renewal_of_Contract_Main_ID IS NOT NULL
	AND Renewal_of_Contract_Main_ID != ''
	UNION
	SELECT Revision_of_Contract_Main_ID
	FROM Contract_Main
	WHERE Contract_Main_ID =  '#Program_ID#'
	AND Revision_of_Contract_Main_ID IS NOT NULL
	AND Revision_of_Contract_Main_ID != '')
</cfquery>

<cfset DiscountList = valuelist(GetDiscountList.Product_Type_ID)>

<!--- Fixed --->
	<cfif ListFind(DiscountList, 1) IS NOT 0>
	<cfquery name="FixedComponentsToUpdate" datasource="#application.datasource#">
	UPDATE Program_Fixed_Component
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_Fixed_Price_Product_Data_ID
	FROM Program_Fixed_Price_Product_Data
	WHERE Program_ID = '#Program_ID#'
	AND deleted = 0
	)
	</cfquery>
	</cfif>

<!--- Rebate --->
<cfif ListFind(DiscountList, 2) IS NOT 0>
	<cfquery name="RebateComponentsToUpdate" datasource="#application.datasource#">
	UPDATE Program_Rebates_Component
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_Rebates_Product_Data_ID
	FROM Program_Rebates_Product_Data
	WHERE Program_ID = '#Program_ID#'
	AND deleted = 0
	)
	</cfquery>

	<cfquery name="RebateComponentsDataToUpdate" datasource="#application.datasource#">
	UPDATE Program_Rebates_Component_Data
	SET Deleted = 1
	WHERE Program_Rebates_Component_ID IN
	( 
	SELECT Program_Rebates_Component_ID
	FROM Program_Rebates_Component
	WHERE Program_ID = '#Program_ID#'
	AND deleted = 1
	)
	</cfquery>
</cfif>

<!--- LumpSum --->
<cfif ListFind(DiscountList, 3) IS NOT 0>
 <!--- If the items are required in Lumpsum --->
 <cfif getTemplateSettings.Discount_Lump_Sums_Item_Mandated eq 1>
	<cfquery name="LumpSumComponentsToUpdate" datasource="#application.datasource#">
	UPDATE Program_Lump_Sums
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_Lump_Sum_Product_Data_ID
	FROM Program_Lump_Sum_Product_Data
	INNER JOIN Contract_Products
	ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
	WHERE Contract_Products.Contract_Main_ID = '#Program_ID#'
	AND Contract_Products.deleted = 0
	AND Program_Lump_Sum_Product_Data.deleted = 0
	)
	</cfquery>
 </cfif>
</cfif>

<!--- Growth --->
<cfif ListFind(DiscountList, 4) IS NOT 0>
	<cfquery name="GrowthComponentsToUpdate" datasource="#application.datasource#">
	UPDATE Program_Growth_Components
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_Growth_Component_Product_Data_ID
	FROM Program_Growth_Component_Product_Data
	INNER JOIN Contract_Products
	ON Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
	WHERE Contract_Products.Contract_Main_ID = '#Program_ID#'
	AND Contract_Products.deleted = 0
	AND Program_Growth_Component_Product_Data.deleted = 0
	)
	</cfquery>
		
	<cfquery name="GrowthComponentTiersToUpdate" datasource="#application.datasource#">
	UPDATE Program_Growth_Component_Tiers
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_Growth_Component_Product_Data_ID
	FROM Program_Growth_Component_Product_Data
	INNER JOIN Contract_Products
	ON Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
	WHERE Contract_Products.Contract_Main_ID = '#Program_ID#'
	AND Contract_Products.deleted = 0
	AND Program_Growth_Component_Product_Data.deleted = 0
	)
	</cfquery>

	<cfquery name="GrowthComponentProductTiersToUpdate" datasource="#application.datasource#">
	UPDATE Program_Growth_Component_Product_Tier_Data
	SET Deleted = 1
	WHERE Program_Growth_Component_Tier_ID IN
	( 
	SELECT Program_Growth_Component_Tier_ID
	FROM Program_Growth_Component_Tiers
	WHERE Program_ID = '#Program_ID#'
	AND deleted = 1
	)
	</cfquery>
</cfif>

<!--- Off Invoice --->	
<cfif ListFind(DiscountList, 8) IS NOT 0>
	<cfquery name="OffInvoiceComponentsToUpdate" datasource="#application.datasource#">
	UPDATE Program_OffInvoice_Component
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_OffInvoice_Product_Data_ID
	FROM Program_OffInvoice_Product_Data
	WHERE Program_ID = '#Program_ID#'
	AND deleted = 0
	)
	</cfquery>
</cfif>

<!--- Bid Request --->
<cfif ListFind(DiscountList, 10) IS NOT 0>
	<cfquery name="BidrequestComponentsToUpdate" datasource="#application.datasource#">
	UPDATE Program_Bidrequest_Component
	SET Deleted = 1
	WHERE Program_ID = '#Program_ID#'
	AND NOT Exists
	( 
	SELECT TOP 1 Program_Bid_Request_Product_ID
	FROM Program_Bid_Request_Product
	WHERE Program_ID = '#Program_ID#'
	AND deleted = 0
	)
	</cfquery>
</cfif>