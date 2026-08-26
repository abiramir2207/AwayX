<cfoutput>


<cfset useLakebaseForBigBillbackSummaryInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("big_billback_summary")>
<cfif useLakebaseForBigBillbackSummaryInfo>
	<cftry>
		<cfset BigBillbackSummaryInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("big_billback_summary", {
				"billback_id" = "eq.#Billback_ID#",
				"big_billback_summary_id" = "eq.#Big_Billback_Summary_ID#",
				"uploaded" = "eq.0",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBigBillbackSummaryInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBigBillbackSummaryInfo>
<cfquery name="BigBillbackSummaryInfo" datasource="#application.datasource#">
SELECT Big_Billback_Summary.*
	FROM Big_Billback_Summary
WHERE Billback_ID = '#Billback_ID#'
AND Big_Billback_Summary.Big_Billback_Summary_ID = '#Big_Billback_Summary_ID#'
AND Uploaded = 0
</cfquery>
</cfif>

<cfset useLakebaseForBigBillbackDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("big_billback")>
<cfif useLakebaseForBigBillbackDetails>
	<cftry>
		<cfset BigBillbackDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("big_billback", {
				"billback_id" = "eq.#Billback_ID#",
				"big_billback_summary_id" = "eq.#Big_Billback_Summary_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBigBillbackDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBigBillbackDetails>
<cfquery name="BigBillbackDetails" datasource="#application.datasource#">
SELECT *
FROM Big_Billback
WHERE  Billback_ID = '#Billback_ID#'
AND Big_Billback_Summary_ID = '#Big_Billback_Summary_ID#'
AND Deleted = 0
</cfquery>
</cfif>



<!--- Insert into billback program --->

<!--- First make sure the program isn't already on the billback --->
<cfset useLakebaseForIsBillbackProgramAlreadyThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForIsBillbackProgramAlreadyThere>
	<cftry>
		<cfset IsBillbackProgramAlreadyThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#Billback_ID#",
				"program_id" = "eq.#BigBillbackSummaryInfo.Program_ID#",
				"deleted" = "eq.0",
				"select" = "billback_program_id"
			}), "billback_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsBillbackProgramAlreadyThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsBillbackProgramAlreadyThere>
<cfquery name="IsBillbackProgramAlreadyThere" datasource="#application.datasource#">
SELECT Billback_Program_ID
FROM Billback_Program
WHERE Billback_ID = '#Billback_ID#'
AND Program_ID = '#BigBillbackSummaryInfo.Program_ID#'
AND Deleted = 0
</cfquery>
</cfif>

<cfset BillbackProgramID = IsBillbackProgramAlreadyThere.Billback_Program_ID>

<cfif IsBillbackProgramAlreadyThere.Recordcount LT 1>
	<cfquery name="InsertBillbackProgram" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Billback_Program
	(
		Billback_ID,
		Program_ID
	)
	VALUES
	(
		'#Billback_ID#',
		'#BigBillbackSummaryInfo.Program_ID#'
	)
	SELECT Billback_Program_ID = @@IDENTITY
	SET NOCOUNT OFF
	</cfquery>
	<cfset BillbackProgramID = InsertBillbackProgram.Billback_Program_ID>
	
</cfif>

<cfif BigBillbackSummaryInfo.Discount_Type_ID IS 2>
	<!--- Rebate --->
	
		<cfloop list="#BigBillbackSummaryInfo.ComponentNameIDs#" index="ComponentNameIDs">
		<!--- First check to see if Rebate comp is already there --->
		<cfset useLakebaseForIsRebateCompAlreadyThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_rebate_component")>
<cfif useLakebaseForIsRebateCompAlreadyThere>
	<cftry>
		<cfset IsRebateCompAlreadyThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program_rebate_component", {
				"billback_id" = "eq.#Billback_ID#",
				"billback_program_id" = "eq.#BigBillbackSummaryInfo.Program_ID#",
				"program_rebates_component_name_id" = "eq.#ComponentNameIDs#",
				"deleted" = "eq.0",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsRebateCompAlreadyThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsRebateCompAlreadyThere>
<cfquery name="IsRebateCompAlreadyThere" datasource="#application.datasource#">
		SELECT Program_Rebates_Component_Name_ID
		FROM Billback_Program_Rebate_Component
		WHERE Billback_ID = '#Billback_ID#'
		AND Billback_Program_ID = '#BigBillbackSummaryInfo.Program_ID#'
		AND Program_Rebates_Component_Name_ID = #ComponentNameIDs#
		AND Deleted = 0
		</cfquery>
</cfif>
	
		<cfif IsRebateCompAlreadyThere.Recordcount LT 1>
		<!--- Get component name --->
		<cfquery name="RebateComponentName" datasource="#application.datasource#">
		SELECT Program_Rebates_Component_Name.Program_Rebates_Component_Name,
			Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
		FROM Program_Rebates_Component_Name
			INNER JOIN Program_Rebates_Component
			ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = 
			Program_Rebates_Component.Program_Rebates_Component_Name_ID
			AND Program_Rebates_Component.Program_Rebates_Component_Name_ID = '#ComponentNameIDs#'
		</cfquery>

		<cfset useLakebaseForGetComponentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForGetComponentID>
	<cftry>
		<cfset GetComponentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component", {
				"program_id" = "eq.#BigBillbackSummaryInfo.Program_ID#",
				"program_rebates_component_name_id" = "eq.#ComponentNameIDs#",
				"limit" = "1",
				"select" = "program_rebates_component_id"
			}), "program_rebates_component_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetComponentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetComponentID>
<cfquery name="GetComponentID" datasource="#application.datasource#">
		SELECT TOP 1 Program_Rebates_Component_ID
		FROM Program_Rebates_Component
		WHERE Program_Rebates_Component.Program_ID = '#BigBillbackSummaryInfo.Program_ID#'
		AND Program_Rebates_Component_Name_ID = '#RebateComponentName.Program_Rebates_Component_Name_ID#'
		AND Program_Rebates_Component.Program_Rebates_Component_Name_ID = '#ComponentNameIDs#'
		</cfquery>
</cfif>


		<cfset useLakebaseForInsertBBProgramRebateComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_rebate_component")>
<cfif useLakebaseForInsertBBProgramRebateComps>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_program_rebate_component", {
			"billback_id" = "#Billback_ID#",
			"billback_program_id" = "#BigBillbackSummaryInfo.Program_ID#",
			"program_rebates_component_name" = "-- contract_main_id
			'#RebateComponentName.Program_Rebates_Component_Name#'",
			"program_rebates_component_name_id" = "#RebateComponentName.Program_Rebates_Component_Name_ID#",
			"program_rebates_component_id" = "#GetComponentID.Program_Rebates_Component_ID#",
			"checked" = "true"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertBBProgramRebateComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertBBProgramRebateComps>
<cfquery name="InsertBBProgramRebateComps" datasource="#application.datasource#">
		INSERT INTO Billback_Program_Rebate_Component
		(
			Billback_ID,
			Billback_Program_ID,
			Program_Rebates_Component_Name,
			Program_Rebates_Component_Name_ID,
			Program_Rebates_Component_ID,
			Checked
		)
		VALUES
		(
			'#Billback_ID#',
			'#BigBillbackSummaryInfo.Program_ID#', -- contract_main_id
			'#RebateComponentName.Program_Rebates_Component_Name#',
			'#RebateComponentName.Program_Rebates_Component_Name_ID#',
			'#GetComponentID.Program_Rebates_Component_ID#',
			'true'
		)
		</cfquery>
</cfif>
		<!---Already there or need to insert --->
		</cfif>
		</cfloop>
	<!--- Is rebate --->	
	</cfif>
	
<!---Query of products on the program --->
<cfset useLakebaseForProductsOnProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForProductsOnProgram>
	<cftry>
		<cfset ProductsOnProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#BigBillbackSummaryInfo.Program_ID#",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_items_master_id"
			}), "bsa_foodservice_items_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForProductsOnProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForProductsOnProgram>
<cfquery name="ProductsOnProgram" datasource="#application.datasource#">
SELECT DISTINCT BSA_Foodservice_Items_Master_ID
FROM Contract_Products
WHERE Contract_Main_ID = '#BigBillbackSummaryInfo.Program_ID#'
AND Deleted = 0
</cfquery>
</cfif>

<cfparam name="ProductOnProgram" default="2">

<!--- Populate approved discount table --->
<cfset BBID = Billback_ID>
<cfset DiscountList = BigBillbackSummaryInfo.Discount_Type_ID>

<cfset Billback_Contract_Main_ID = BigBillbackSummaryInfo.Program_ID>

<cfinclude template="/billbacks/capture/inc_eligible_products.cfm">

<cfloop query="BigBillbackDetails">
	
	<!--- First, make sure the product isn't already there --->
	<Cfquery name="IsProductAlreadyThere" datasource="#application.datasource#">
	SELECT Billback_Product_ID, BB_Product_Quantity, BB_Product_UOM 
	FROM Billback_Product
	WHERE Billback_ID = '#Billback_ID#'
	AND Billback_Program_ID = '#BillbackProgramID#'
	AND Product_ID = '#BigBillbackDetails.Product_ID#'
	AND Distributor_id = '#BigBillbackDetails.Distributor_ID#'
	<cfif BigBillbackDetails.UOM EQ "CS">
		AND BB_Product_UOM = 1
	<cfelseif BigBillbackDetails.UOM EQ "LB">	
		AND BB_Product_UOM = 2
	</cfif>
	AND Deleted = 0
	</CFQUERY>
	
	<cfset Volume = replace(BigBillbackDetails.Volume, ",", "")>
	<cfset Volume = replace(Volume, "$", "")>
	<cfset BBUOM = BigBillbackDetails.UOM />
	<cfif (BBUOM EQ "CS")>
		<cfset intBBUOM = 1/>
	<cfelse>
		<cfset intBBUOM = 2 />
	</cfif>
	
	<cfif (IsProductAlreadyThere.Recordcount LT 1)>
		<!---Is the product on the program --->
		<cfset useLakebaseForIsProductOnProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("productsonprogram")>
<cfif useLakebaseForIsProductOnProgram>
	<cftry>
		<cfset IsProductOnProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("productsonprogram", {
				"bsa_foodservice_items_master_id" = "eq.#BigBillbackDetails.Product_ID#",
				"select" = "bsa_foodservice_items_master_id"
			}), "bsa_foodservice_items_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsProductOnProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsProductOnProgram>
<cfquery name="IsProductOnProgram" dbtype="query">
		SELECT BSA_Foodservice_Items_Master_ID
		FROM ProductsOnProgram
		WHERE ProductsOnProgram.BSA_Foodservice_Items_Master_ID = '#BigBillbackDetails.Product_ID#'
		</cfquery>
</cfif>
		
		<cfif IsProductOnProgram.Recordcount GT 0>
			<cfset ProductOnProgram = 1>
		<cfelse>
			<cfset ProductOnProgram = 2>
		</cfif>
		
		<cfquery name="InsertBillbackProduct" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO Billback_Product
		(
			Billback_ID,
			Product_ID,
			Billback_Program_ID,
			BB_Product_Quantity, 
			BB_Product_UOM,
			Product_Type_ID, <!--- 1= product on program, 2 = product not on program --->
			Distributor_id 
		)
		VALUES
		(
			'#Billback_ID#',
			'#BigBillbackDetails.Product_ID#',
			'#BillbackProgramID#',
			#Volume#,
			#intBBUOM#,
			'#ProductOnProgram#',
			'#BigBillbackDetails.Distributor_ID#'
		)
		SELECT Billback_Product_ID = @@IDENTITY
		SET NOCOUNT OFF
		</cfquery>
		
		<cfset BillbackProductID = InsertBillbackProduct.Billback_Product_ID>
	
	<cfelse>
	
		<cfset BillbackProductID = IsProductAlreadyThere.Billback_Product_ID>
		
		<!--- Need to update volume --->
		<cfset NewProductQuantity = IsProductAlreadyThere.BB_Product_Quantity + Volume>
		
		<cfset useLakebaseForUpdateVolumeforProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForUpdateVolumeforProduct>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product",
			{
				"billback_product_id" = "eq.#BillbackProductID#"
			},
			{
				"bb_product_quantity" = "#NewProductQuantity#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateVolumeforProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateVolumeforProduct>
<cfquery name="UpdateVolumeforProduct" datasource="#application.datasource#">
		UPDATE Billback_Product
		SET BB_Product_Quantity = '#NewProductQuantity#'
		WHERE Billback_Product_ID = '#BillbackProductID#'
		</cfquery>
</cfif>
	
	</cfif>
	
	<!--- Is the detail already there? --->
	<cfset useLakebaseForIsProductDetailAlreadyThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForIsProductDetailAlreadyThere>
	<cftry>
		<cfset IsProductDetailAlreadyThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_product_detail", {
				"billback_product_id" = "eq.#BillbackProductID#",
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "billback_product_detail_id,bb_rate"
			}), "billback_product_detail_id,bb_rate"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsProductDetailAlreadyThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsProductDetailAlreadyThere>
<cfquery name="IsProductDetailAlreadyThere" datasource="#application.datasource#">
	SELECT Billback_Product_Detail_ID, BB_Rate
	FROM Billback_Product_Detail
	WHERE Billback_Product_ID = '#BillbackProductID#'
	AND Billback_ID = '#Billback_ID#'
	AND Deleted = 0
	</cfquery>
</cfif>

	<cfset BigBBProdAmount = replace(BigBillbackDetails.Amount, ",", "")>
	<cfset BigBBProdAmount = replace(BigBBProdAmount, "$", "")>
	
	<cfif IsProductDetailAlreadyThere.Recordcount LT 1>
	
	<!--- Dev Note(61908) - Replace "brackets" with minus sign. Value with brackets throws an error while insert.--->
	<cfif BigBBProdAmount LT 0>
		<cfset BigBBProdAmount = replace(BigBBProdAmount, "(", "-")>	
		<cfset BigBBProdAmount = replace(BigBBProdAmount, ")", "")>
	</cfif>

	<cfquery name="InsertBillbackProductDetail" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Billback_Product_Detail
	(
		Billback_Product_ID,
		Billback_ID,
		BB_Product_Type_ID,
		BB_Rate,
		Distributor_ID_Earned
	)
	VALUES
	(
		'#BillbackProductID#',
		'#Billback_ID#',
		'#BigBillbackSummaryInfo.Discount_Type_ID#',
		'#BigBBProdAmount#',
		'#BigBillbackDetails.Distributor_ID#'
	)
	SELECT Billback_Product_Detail_ID = @@IDENTITY
	SET NOCOUNT OFF
	</cfquery>
	<cfset BillbackProductDetailID = InsertBillbackProductDetail.Billback_Product_Detail_ID>
	<cfelse>
	<!--- There is already a record for the product detail and it needs to be updated--->
	<cfset BillbackProductDetailID = IsProductDetailAlreadyThere.Billback_Product_Detail_ID>
	<cfset NewProductAmount = IsProductDetailAlreadyThere.BB_Rate + BigBBProdAmount>
	
	
	<cfset useLakebaseForUpdateProductAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForUpdateProductAmount>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product_detail",
			{
				"billback_product_detail_id" = "eq.#BillbackProductDetailID#"
			},
			{
				"bb_rate" = "#NewProductAmount#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateProductAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateProductAmount>
<cfquery name="UpdateProductAmount" datasource="#application.datasource#">
	UPDATE Billback_Product_Detail
	SET BB_Rate = '#NewProductAmount#'
	WHERE Billback_Product_Detail_ID = '#BillbackProductDetailID#'
	</cfquery>
</cfif>
	
	</cfif>
	
	<!--- Eligible products --->
	<cfset DiscountList = "">
	<cfset useLakebaseForDiscountsForProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alleligibleproducts")>
<cfif useLakebaseForDiscountsForProduct>
	<cftry>
		<cfset DiscountsForProduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alleligibleproducts", {
				"product_id" = "eq.#BigBillbackDetails.Product_ID#",
				"select" = "discounttypeid"
			}), "discounttypeid"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDiscountsForProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDiscountsForProduct>
<cfquery name="DiscountsForProduct" dbtype="query">
		SELECT DISTINCT DiscountTypeID
		FROM AllEligibleProducts
		WHERE Product_ID = '#BigBillbackDetails.Product_ID#'
	</cfquery>
</cfif>
	
	<cfif DiscountsForProduct.Recordcount GT 0>
		<cfset DiscountList = valuelist(DiscountsForProduct.DiscountTypeID)>
	</cfif>
	
	<cfset useLakebaseForInsertIntoTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_product_discount")>
<cfif useLakebaseForInsertIntoTable>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_product_discount", {
			"discount_list" = "#DiscountList#",
			"product_id" = "#BigBillbackDetails.Product_ID#",
			"billback_id" = "#Billback_ID#",
			"program_id" = "#BigBillbackSummaryInfo.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoTable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoTable>
<cfquery name="InsertIntoTable" datasource="#application.datasource#">
	INSERT INTO BB_Product_Discount
	(
		Discount_List,
		Product_ID,
		Billback_ID,
		Program_ID
	)
	VALUES
	(
		'#DiscountList#',
		'#BigBillbackDetails.Product_ID#',
		'#Billback_ID#',
		#BigBillbackSummaryInfo.Program_ID#
	)
	</cfquery>
</cfif>

	
	<!--- Insert into  Billback_Distributor_List--->
	<!--- Make sure the distributor isn't already there --->
	
	<cfset useLakebaseForIsDistributorAlreadyThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor_list")>
<cfif useLakebaseForIsDistributorAlreadyThere>
	<cftry>
		<cfset IsDistributorAlreadyThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor_list", {
				"billback_id" = "eq.#Billback_ID#",
				"distributor_id" = "eq.#BigBillbackDetails.Distributor_ID#",
				"select" = "billback_distributor_list_id"
			}), "billback_distributor_list_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsDistributorAlreadyThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsDistributorAlreadyThere>
<cfquery name="IsDistributorAlreadyThere" datasource="#application.datasource#">
	SELECT Billback_Distributor_List_ID
	FROM Billback_Distributor_List WHERE
	Billback_ID = '#Billback_ID#'
	AND Distributor_ID = '#BigBillbackDetails.Distributor_ID#'
	</cfquery>
</cfif>
	
	<cfif IsDistributorAlreadyThere.Recordcount EQ 0>
	<cfset useLakebaseForInsertToBillbackDistributorList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor_list")>
<cfif useLakebaseForInsertToBillbackDistributorList>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_distributor_list", {
			"billback_id" = "#Billback_ID#",
			"distributor_id" = "#BigBillbackDetails.Distributor_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertToBillbackDistributorList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertToBillbackDistributorList>
<cfquery name="InsertToBillbackDistributorList" datasource="#application.datasource#">
	INSERT INTO Billback_Distributor_List
	(
		Billback_ID,
		Distributor_ID
	)
	VALUES
	(
		'#Billback_ID#',
		'#BigBillbackDetails.Distributor_ID#'
	)
	</cfquery>
</cfif>
	</cfif>
	
</cfloop>

<!--- 
D30713 : Deviation throws error on 0 volume products from big billback
Clean up data for 0 volume --->
<cfquery name="UpdateZeroVolumeProducts" datasource="#application.datasource#">
	
	IF OBJECT_ID('tempdb..##tmp_bp_invalid_volume') IS NOT NULL
	DROP TABLE ##tmp_bp_invalid_volume
		
	SELECT	billback_product.billback_product_id,
			billback_product.bb_product_quantity,
			sum(billback_product_detail.bb_rate) as total_dollar
	INTO	##tmp_bp_invalid_volume
	FROM	billback_product
	INNER JOIN billback_product_detail
	ON		billback_product_detail.billback_product_id = billback_product.billback_product_id
	AND		billback_product_detail.deleted = 0
	WHERE	billback_product.billback_id = '#Billback_ID#'
	AND		billback_product.deleted = 0
	AND		cast(billback_product.bb_product_quantity as float) = 0
	GROUP BY billback_product.billback_product_id,
			billback_product.bb_product_quantity
	
	<!--- -- *** If dollar is non-zero AND volume is 0, SET volume = 1 --->
	UPDATE	billback_product
	SET		bb_product_quantity = 1
	FROM	##tmp_bp_invalid_volume
	INNER JOIN billback_product
	ON		billback_product.billback_product_id = ##tmp_bp_invalid_volume.billback_product_id
	WHERE	total_dollar != 0
	
	
	<!--- -- *** If dollar is 0 AND volume is 0, get rid of the record - start --->
	UPDATE	bb_item_invoice_level
	SET		deleted = 1
	WHERE	billback_product_id in
			(
			select	billback_product_id
			FROM	##tmp_bp_invalid_volume
			WHERE	total_dollar = 0
			)
			
	UPDATE	billback_product_detail
	SET		deleted = 1
	WHERE	billback_product_id in
			(
			select	billback_product_id
			FROM	##tmp_bp_invalid_volume
			WHERE	total_dollar = 0
			)
			
	UPDATE	billback_product
	SET		deleted = 1
	WHERE	billback_product_id in
			(
			select	billback_product_id
			FROM	##tmp_bp_invalid_volume
			WHERE	total_dollar = 0
			)
	<!--- -- *** If dollar is 0 AND volume is 0, get rid of the record - end --->

</cfquery>


<CFSET LoadBillbackID = Billback_ID>	
<cfinclude template="/billbacks/capture/load_billback_to_struct.cfm">

<cfset useLakebaseForMarkSummaryAsDone = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("big_billback_summary")>
<cfif useLakebaseForMarkSummaryAsDone>
	<cftry>
		<cfset application.oLakebase.updateRows("big_billback_summary",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"uploaded" = "1",
				"number_of_records" = "#BigBillbackDetails.Recordcount#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForMarkSummaryAsDone = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForMarkSummaryAsDone>
<cfquery name="MarkSummaryAsDone" datasource="#application.datasource#">
UPDATE Big_Billback_Summary
SET Uploaded = 1,
Number_of_Records = #BigBillbackDetails.Recordcount#
WHERE Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>

<cfset useLakebaseForDeleteDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("big_billback")>
<cfif useLakebaseForDeleteDetails>
	<cftry>
		<cfset application.oLakebase.deleteRows("big_billback", {
			"billback_id" = "eq.#Billback_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteDetails>
<cfquery name="DeleteDetails" datasource="#application.datasource#">
DELETE FROM Big_Billback
WHERE Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>

<cfquery name="qResetDeviationRanInfo" datasource="#application.datasource#">
	UPDATE 	Billback
	SET 	Deviation_Ran_Date = NULL,
			Deviation_Ran_By = NULL 
	WHERE 	Billback_ID = '#Billback_ID#'
</cfquery>

<script language="javascript">
	document.all.KnownProgramForm.Data_Action_ID.value = 5;
</script>

<cflocation url="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#">
</cfoutput>
<script>

 try { window.parent.dyniframesize(); } catch (err) { };

</script>
