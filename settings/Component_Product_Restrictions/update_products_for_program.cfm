<cfset ProductsRestrictedByComponents = "" /> <!--- Dev Note: Kal 11966: Inactive record pop up shows all items being removed --->

<!--- Only do the update for discounts that actually have products on that type of discount --->
<cfset useLakebaseForGetDiscountList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForGetDiscountList>
	<cftry>
		<cfset GetDiscountList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#Program_ID#",
				"deleted" = "eq.0",
				"select" = "product_type_id"
			}), "product_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDiscountList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDiscountList>
<cfquery name="GetDiscountList" datasource="#application.datasource#">
	SELECT DISTINCT Product_Type_ID
	FROM Contract_Products
	WHERE Contract_Main_ID = '#Program_ID#'
	AND Deleted = 0
</cfquery>
</cfif>

<cfset DiscountList = valuelist(GetDiscountList.Product_Type_ID)>

 <!--- Fixed Rates that need updating --->
<cfif ListFind(DiscountList, 1) IS NOT 0>
<cfquery name="FixedRatesToUpdate" datasource="#application.datasource#">
	UPDATE Program_Fixed_Price_Product_Data
	SET Deleted = 1
	WHERE Program_Fixed_Price_Product_Data_ID IN
	( 
		SELECT Distinct Program_Fixed_Price_Product_Data_ID
		FROM Program_Fixed_Price_Product_Data
			INNER JOIN Program_Fixed_Component 
			ON Program_Fixed_Component.Program_Fixed_Component_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
			AND Program_Fixed_Component.Deleted = 0
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Component_Products_Restricted
			ON Component_Products_Restricted.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Component_Products_Restricted.Component_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
			AND Discount_Type_ID = 1
		WHERE Program_Fixed_Price_Product_Data.Program_ID = '#Program_ID#'
		AND Program_Fixed_Price_Product_Data.Deleted = 0
	) 
</cfquery> 
</cfif>

<!--- <cfdump var="#FixedRatesToUpdate#"> --->

<!--- Rebate Rates that need updating --->
<cfif ListFind(DiscountList, 2) IS NOT 0>
<cfquery name="RebateRatesToUpdate" datasource="#application.datasource#">
	UPDATE Program_Rebates_Product_Data
	SET Deleted = 1
	WHERE Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID IN
	(  
		SELECT Distinct Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
		FROM Program_Rebates_Component_Data
			INNER JOIN Program_Rebates_Component 
			ON Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
			AND Program_Rebates_Component.Deleted = 0
		 	INNER JOIN Program_Rebates_Product_Data
			ON Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
			AND Program_Rebates_Product_Data.Deleted = 0
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Component_Products_Restricted
			ON Component_Products_Restricted.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Component_Products_Restricted.Component_ID = Program_Rebates_Component.Program_Rebates_Component_Name_Id
			AND Discount_Type_ID = 2
		WHERE Program_Rebates_Product_Data.Program_ID = '#Program_ID#'
		AND Program_Rebates_Product_Data.Deleted = 0
	) 
</cfquery>
</cfif>

<!--- <cfdump var="#RebateRatesToUpdate#"> --->

<!--- Lump Sum Rates that need updating --->
<cfif ListFind(DiscountList, 3) IS NOT 0>
<cfquery name="LumpSumRatesToUpdate" datasource="#application.datasource#"> 
	UPDATE Program_Lump_Sum_Product_Data
	SET Deleted = 1
	WHERE Program_Lump_Sum_Product_Data_ID IN
	( 
		SELECT Distinct Program_Lump_Sum_Product_Data_ID
		FROM Program_Lump_Sum_Product_Data
			INNER JOIN Program_Lump_Sums 
			ON Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
			AND Program_Lump_Sums.Deleted = 0
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Component_Products_Restricted
			ON Component_Products_Restricted.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Component_Products_Restricted.Component_ID = Program_Lump_Sums.Program_Lump_Sum_Name_Id
			AND Discount_Type_ID = 3
		WHERE Program_Lump_Sums.Program_ID = '#Program_ID#'
		AND Program_Lump_Sum_Product_Data.Deleted = 0
	) 
</cfquery>
</cfif>
<!--- <cfdump var="#LumpSumRatesToUpdate#"> --->

<!--- Growth Rates that need updating --->
<cfif ListFind(DiscountList, 4) IS NOT 0>
<cfquery name="GrowthRatesToUpdate" datasource="#application.datasource#">
	UPDATE Program_Growth_Component_Product_Data
	SET Deleted = 1
	WHERE Program_Growth_Component_Product_Data_ID IN
	( 
		SELECT Distinct Program_Growth_Component_Product_Data_ID
		FROM Program_Growth_Component_Product_Data
			INNER JOIN Program_Growth_Components 
			ON Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
			AND Program_Growth_Component_Product_Data.Deleted = 0
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Component_Products_Restricted
			ON Component_Products_Restricted.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Component_Products_Restricted.Component_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
			AND Discount_Type_ID = 4
		WHERE Program_Growth_Components.Program_ID = '#Program_ID#'
		AND Program_Growth_Component_Product_Data.Deleted = 0
	)  
</cfquery>
</cfif>
<!--- <cfdump var="#GrowthRatesToUpdate#"> --->

 <!--- Off Invoice Rates that need updating --->
 <cfif ListFind(DiscountList, 8) IS NOT 0>
<cfquery name="OffInvoiceRatesToUpdate" datasource="#application.datasource#">
	UPDATE Program_OffInvoice_Product_Data
	SET Deleted = 1
	WHERE Program_OffInvoice_Product_Data_ID IN
	(  
		SELECT Distinct Program_OffInvoice_Product_Data_ID
		FROM Program_OffInvoice_Product_Data
			INNER JOIN Program_OffInvoice_Component 
			ON Program_OffInvoice_Component.Program_OffInvoice_Component_ID = Program_OffInvoice_Product_Data.Program_OffInvoice_Component_ID
			AND Program_OffInvoice_Component.Deleted = 0
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_OffInvoice_Product_Data.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Component_Products_Restricted
			ON Component_Products_Restricted.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Component_Products_Restricted.Component_ID = Program_OffInvoice_Component.Program_OffInvoice_Component_Name_ID
			AND Discount_Type_ID = 8
		WHERE Program_OffInvoice_Component.Program_ID = '#Program_ID#'
		AND Program_OffInvoice_Product_Data.Deleted = 0
	)  
</cfquery>
</cfif>

<!--- <cfdump var="#OffInvoiceRatesToUpdate#"> --->

 <!--- Off Invoice Rates that need updating --->
 <cfif ListFind(DiscountList, 10) IS NOT 0>
<cfquery name="BidRatesToUpdate" datasource="#application.datasource#">
	UPDATE Program_Bid_Request_Product
	SET Deleted = 1
	WHERE Program_Bid_Request_Product_ID IN
	(  
		SELECT Program_Bid_Request_Product_ID
		FROM Program_Bid_Request_Product
			INNER JOIN Program_BidRequest_Component 
			ON Program_BidRequest_Component.Program_BidRequest_Component_ID = Program_Bid_Request_Product.Program_BidRequest_Component_ID
			AND Program_BidRequest_Component.Deleted = 0
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Bid_Request_Product.Contract_Products_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Component_Products_Restricted
			ON Component_Products_Restricted.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Component_Products_Restricted.Component_ID = Program_BidRequest_Component.Program_BidRequest_Component_Name_ID
			AND Discount_Type_ID = 10
		WHERE Program_BidRequest_Component.Program_ID = '#Program_ID#'
		AND Program_Bid_Request_Product.Deleted = 0
	 )  
</cfquery>
 </cfif>
<!--- <cfdump var="#BidRatesToUpdate#">  --->

<!--- Now delete any product that has no valid rate left --->
<cfset useLakebaseForGetProgramContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForGetProgramContractProducts>
	<cftry>
		<cfset GetProgramContractProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#Program_ID#",
				"deleted" = "eq.0",
				"select" = "contract_products_id,bsa_foodservice_items_master_id"
			}), "contract_products_id,bsa_foodservice_items_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProgramContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProgramContractProducts>
<cfquery name="GetProgramContractProducts" datasource="#application.datasource#">
	SELECT DISTINCT Contract_Products_ID, BSA_Foodservice_Items_Master_ID
	FROM Contract_Products
	WHERE Contract_Main_ID = '#Program_ID#'
	AND Deleted = 0
</cfquery>
</cfif>

<!--- Loop through and see if they have any valid discount type --->

<cfloop query="GetProgramContractProducts">

	<cfset ProductHasDiscount = 0>

	<!--- Fixed  --->
	<cfif ListFind(DiscountList, 1) IS NOT 0>
	<cfset useLakebaseForHasFixedValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForHasFixedValue>
	<cftry>
		<cfset HasFixedValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_price_product_data", {
				"contract_products_id" = "eq.#Contract_Products_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHasFixedValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHasFixedValue>
<cfquery name="HasFixedValue" datasource="#application.datasource#">
		Select * FROM Program_Fixed_Price_Product_Data
		WHERE Program_Fixed_Price_Product_Data.Contract_Products_ID = '#Contract_Products_ID#'
		AND Program_Fixed_Price_Product_Data.Deleted = 0
	</cfquery>
</cfif>
	<cfif HasFixedValue.Recordcount GT 0>
		<cfset ProductHasDiscount = 1>
	</cfif>
	</cfif>
	
	<!--- Rebate  --->
	<cfif ListFind(DiscountList, 2) IS NOT 0>
	<cfset useLakebaseForHasRebateValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForHasRebateValue>
	<cftry>
		<cfset HasRebateValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_product_data", {
				"contract_products_id" = "eq.#Contract_Products_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHasRebateValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHasRebateValue>
<cfquery name="HasRebateValue" datasource="#application.datasource#">
		Select * FROM Program_Rebates_Product_Data
		WHERE Program_Rebates_Product_Data.Contract_Products_ID = '#Contract_Products_ID#'
		AND Program_Rebates_Product_Data.Deleted = 0
	</cfquery>
</cfif>
	<cfif HasRebateValue.Recordcount GT 0>
		<cfset ProductHasDiscount = 1>
	</cfif>
	</cfif>
	
	<!--- Lump Sum  --->
	<cfif ListFind(DiscountList, 3) IS NOT 0>
	<cfset useLakebaseForHasLumpSumValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_product_data")>
<cfif useLakebaseForHasLumpSumValue>
	<cftry>
		<cfset HasLumpSumValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_product_data", {
				"contract_products_id" = "eq.#Contract_Products_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHasLumpSumValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHasLumpSumValue>
<cfquery name="HasLumpSumValue" datasource="#application.datasource#">
		Select * FROM Program_Lump_Sum_Product_Data
		WHERE Program_Lump_Sum_Product_Data.Contract_Products_ID = '#Contract_Products_ID#'
		AND Program_Lump_Sum_Product_Data.Deleted = 0
	</cfquery>
</cfif>
	<cfif HasLumpSumValue.Recordcount GT 0>
		<cfset ProductHasDiscount = 1>
	</cfif>
	</cfif>
	
	<!--- Growth  --->
	<cfif ListFind(DiscountList, 4) IS NOT 0>
	<cfset useLakebaseForHasGrowthValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_product_data")>
<cfif useLakebaseForHasGrowthValue>
	<cftry>
		<cfset HasGrowthValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_component_product_data", {
				"contract_products_id" = "eq.#Contract_Products_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHasGrowthValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHasGrowthValue>
<cfquery name="HasGrowthValue" datasource="#application.datasource#">
		Select * FROM Program_Growth_Component_Product_Data
		WHERE Program_Growth_Component_Product_Data.Contract_Products_ID = '#Contract_Products_ID#'
		AND Program_Growth_Component_Product_Data.Deleted = 0
	</cfquery>
</cfif>
	<cfif HasGrowthValue.Recordcount GT 0>
		<cfset ProductHasDiscount = 1>
	</cfif>
	</cfif>
		
	<!--- Off Invoice  --->
	<cfif ListFind(DiscountList, 8) IS NOT 0>
	<cfset useLakebaseForHasOffInvoiceValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_offinvoice_product_data")>
<cfif useLakebaseForHasOffInvoiceValue>
	<cftry>
		<cfset HasOffInvoiceValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_offinvoice_product_data", {
				"contract_products_id" = "eq.#Contract_Products_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHasOffInvoiceValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHasOffInvoiceValue>
<cfquery name="HasOffInvoiceValue" datasource="#application.datasource#">
		Select * FROM Program_OffInvoice_Product_Data
		WHERE Program_OffInvoice_Product_Data.Contract_Products_ID = '#Contract_Products_ID#'
		AND Program_OffInvoice_Product_Data.Deleted = 0
	</cfquery>
</cfif>
	<cfif HasOffInvoiceValue.Recordcount GT 0>
		<cfset ProductHasDiscount = 1>
	</cfif>
	</cfif>
	
	<!---Bid Request  --->
	<cfif ListFind(DiscountList, 10) IS NOT 0>
	<cfset useLakebaseForHasBidRequestValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request_product")>
<cfif useLakebaseForHasBidRequestValue>
	<cftry>
		<cfset HasBidRequestValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_request_product", {
				"contract_products_id" = "eq.#Contract_Products_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForHasBidRequestValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHasBidRequestValue>
<cfquery name="HasBidRequestValue" datasource="#application.datasource#">
		Select * FROM Program_Bid_Request_Product
		WHERE Program_Bid_Request_Product.Contract_Products_ID = '#Contract_Products_ID#'
		AND Program_Bid_Request_Product.Deleted = 0
	</cfquery>
</cfif>
	<cfif HasBidRequestValue.Recordcount GT 0>
		<cfset ProductHasDiscount = 1>
	</cfif>
	</cfif>

	<cfif ProductHasDiscount IS 0>
		<cfset useLakebaseForDeleteProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForDeleteProduct>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"contract_products_id" = "eq.#Contract_Products_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteProduct>
<cfquery name="DeleteProduct" datasource="#application.datasource#">
			UPDATE Contract_Products
			SET Deleted = 1
			WHERE Contract_Products_ID = '#Contract_Products_ID#'
		</cfquery>
</cfif>

		 <!--- Create a list of products restricted by components and pass the list for removing inactive products --->
		<cfset ProductsRestrictedByComponents = ListAppend(ProductsRestrictedByComponents,"#GetProgramContractProducts.BSA_Foodservice_Items_Master_ID#", ",") />
		
	</cfif>
</cfloop>
	
