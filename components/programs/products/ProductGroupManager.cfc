<cfcomponent hint="Product Group Manager" extends="components.Base">
	<!--- Label 10406: Hide Add all products link --->
	<cfset allProductsOn = 0 /> 
	
	<cffunction name="init" output="false" returntype="components.programs.products.ProductGroupManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="allowSelectAllProducts" output="false" returntype="boolean">
	
		<cfargument name="discountTypeId" type="numeric" required="true">
		<cfargument name="programId" type="numeric" required="true">
		
		<cfset bAllowSelectAllProducts = false>
		
		<cfif allProductsOn AND ListFindNoCase("2,3,4,8", arguments.discountTypeId, ",")>
		
			<!------ Get Allow_Add_All_Products variable ----->
			<cfquery name="qGetAllowAddAllProducts" datasource="#application.datasource#">
				SELECT	Allow_Add_All_Products
				FROM	Contract_Main					
						INNER JOIN Program_Control_Panel_Options
						ON
						Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
				WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
			</cfquery>
			
			<cfif qGetAllowAddAllProducts.Allow_Add_All_Products EQ 1>
				<cfset bAllowSelectAllProducts = true>
			</cfif>
		
		</cfif>
	
		<cfreturn bAllowSelectAllProducts />
		
	</cffunction>
	
	<cffunction name="getProductForGroupProducts" output="false" returntype="string">
	
		<cfargument name="groupLevel" type="numeric" required="true">
		<cfargument name="groupID" type="numeric" required="true">
	
		<cfset productId = "">
		
		<cfif arguments.groupLevel NEQ 0 AND isNumeric(arguments.groupLevel)>
	
			<cfset useLakebaseForqGetAllProductsProductID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_product")>
<cfif useLakebaseForqGetAllProductsProductID>
	<cftry>
		<cfset qGetAllProductsProductID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_product", {
				"deleted" = "eq.0",
				"product_group_level_id" = "eq.#arguments.groupLevel#",
				"product_group_id" = "eq.#arguments.groupID#",
				"limit" = "1",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAllProductsProductID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAllProductsProductID>
<cfquery name="qGetAllProductsProductID" datasource="#application.datasource#">
				SELECT	TOP 1 Product_ID
				FROM	Product_Group_Product
				WHERE
						Deleted = 0
						AND Product_Group_Level_ID = #arguments.groupLevel#
						AND Product_Group_ID = '#arguments.groupID#'
			</cfquery>
</cfif>
			
			<cfloop query="qGetAllProductsProductID">
			
				<cfset productId = Product_ID>
			
			</cfloop>
		
		</cfif>
	
		<cfreturn productId />
		
	</cffunction>
	
	<cffunction name="getGroupFromProduct" output="false" returntype="any">
	
		<cfargument name="productId" type="string" required="true">
		<cfargument name="returnType" type="numeric" required="false" default="1" hint="1=query,2=groupLevel,3=groupId">
		<cfargument name="selectedRebateType" type="numeric" required="false" default="0">
		<cfargument name="contact_main_id" type="string" required="false" default="0">
		
		<cfset groupLevel = 0>
		<cfset groupId = "">
		<cfif arguments.selectedRebateType gt 0>
		<cfset useLakebaseForqGetProductGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqGetProductGroup>
	<cftry>
		<cfset qGetProductGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"deleted" = "eq.0",
				"bsa_foodservice_items_master_id" = "eq.#arguments.productId#",
				"product_type_id" = "eq.#arguments.selectedRebateType#",
				"contract_main_id" = "eq.#arguments.contact_main_id#",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductGroup>
<cfquery name="qGetProductGroup" datasource="#application.datasource#">
			SELECT top 1 *
			FROM	Contract_Products
			WHERE	Deleted = 0
			AND		BSA_Foodservice_items_master_id = '#arguments.productId#'
			and 	product_type_id = #arguments.selectedRebateType#
			and 	contract_main_id = #arguments.contact_main_id#
		</cfquery>
</cfif>
		<cfelse>
		<cfquery name="qGetProductGroup" datasource="#application.datasource#">
			SELECT	Product_Group_Level_ID, Product_Group_ID
			FROM	Product_Group_Product
			WHERE	Deleted = 0
			AND		Product_ID = '#arguments.productId#'
		</cfquery>
		</cfif>
		<cfif arguments.returnType EQ 1>
		
			<cfif NOT qGetProductGroup.recordCount>
			
				<cfset QueryAddRow(qGetProductGroup) />
				<cfset QuerySetCell(qGetProductGroup, "Product_Group_Level_ID", 0) />
				<cfset QuerySetCell(qGetProductGroup, "Product_Group_ID", "") />
			
			</cfif>
		
			<cfreturn qGetProductGroup />
			
		<cfelseif arguments.returnType EQ 2>
		
			<cfif qGetProductGroup.recordCount>
			
				<cfset groupLevel = qGetProductGroup.Product_Group_Level_ID />
			
			</cfif>
			
			<cfreturn groupLevel />
			
		<cfelseif arguments.returnType EQ 3>
		
			<cfif qGetProductGroup.recordCount>
			
				<cfset groupId = qGetProductGroup.Product_Group_ID />
			
			</cfif>
			
			<cfreturn groupId />
			
		</cfif>
		
		<cfreturn 0 />
		
	</cffunction>
	
	<cffunction name="getGroupFromSelectedRebateType" returntype="query" output="false" access="public">
		<cfargument name="productList" type="string" required="true">
		<cfargument name="group_rebate_type_search_id" type="numeric" required="true">
		<cfargument name="programID" type="string" required="true">
		<cfargument name="pricingLevel" type="numeric" required="false">
		<cfquery name="qGetGroupFromSelectedRebateType" datasource="#application.datasource#">
			select distinct *
			from 	contract_products
			where 	deleted = 0
			and 	contract_main_id = #arguments.programID#
			and		product_type_id = #arguments.group_rebate_type_search_id#
			<cfif arguments.pricingLevel neq "">
				and pricing_level_id = #arguments.pricingLevel# 
			</cfif>
			<cfif arguments.productList neq "">
				and product_group_id in (#ListQualify(arguments.productList,"'",",","ALL")#)
			</cfif>	
		</cfquery>
		<cfreturn qGetGroupFromSelectedRebateType />
	</cffunction>
	
	<cffunction name="getMaxPricingLevelForSelectedRebateType" returntype="numeric" output="false" access="public">
		<cfargument name="group_rebate_type_search_id" type="numeric" required="true">
		<cfargument name="programID" type="string" required="true">
		<cfquery name="qGetMaxPricingLevelForSelectedRebateType" datasource="#application.datasource#">
			select max(pricing_level_id) as max_pricing_level_id
			from 	contract_products
			where 	deleted = 0
			and 	contract_main_id = #arguments.programID#
			and		product_type_id = #arguments.group_rebate_type_search_id#
		</cfquery>
		<cfreturn qGetMaxPricingLevelForSelectedRebateType.max_pricing_level_id />
	</cffunction>
	
	<cffunction name="getProductGroupDetails" output="false" returntype="any">
	
		<cfargument name="productGroupLevel" type="numeric" required="true">
		<cfargument name="productGroupID" type="string" required="true">
		
		<cfset prodGroupDetails = StructNew() />
		<cfset prodGroupDetails.item = "" />
		<cfset prodGroupDetails.upc = "" />
		<cfset prodGroupDetails.description = "All Products" />
		<cfset prodGroupDetails.BSA_Foodservice_Items_Master_ID = "" />
		
		<cfif arguments.productGroupLevel EQ 1>
		
			<cfif isNumeric(arguments.productGroupID) AND arguments.productGroupID NEQ 0>
			
				<cfset useLakebaseForprodGroupDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForprodGroupDetails>
	<cftry>
		<cfset prodGroupDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"deleted" = "eq.0",
				"business_segment_id" = "eq.#arguments.productGroupID#",
				"select" = "'' as item,'' as upc,'all ' + business_unit_desc + ' products' as description,'' as bsa_foodservice_items_master_id"
			}), "'' as item,'' as upc,'all ' + business_unit_desc + ' products' as description,'' as bsa_foodservice_items_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForprodGroupDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForprodGroupDetails>
<cfquery name="prodGroupDetails" datasource="#application.datasource#">
				
					SELECT 	'' AS item,
							'' AS upc,
							'All ' + Business_Unit_Desc + ' products' As description,
							'' AS BSA_Foodservice_Items_Master_ID
					FROM	Business_Segment
					WHERE
							Business_Segment.Deleted = 0
							AND
							Business_Segment.Business_Segment_ID = #arguments.productGroupID#
							
				</cfquery>
</cfif>
			
			</cfif>
		
		</cfif>	
		
		<cfreturn prodGroupDetails />
	
	</cffunction>
	
	
	<cffunction name="getProductGroupProductCount" output="false" returntype="numeric">
	
		<cfargument name="productGroupLevel" type="numeric" required="true">
		<cfargument name="productGroupID" type="string" required="true">
		<cfargument name="programID" type="string" required="false" default="">
		
		<cfset productsCount = 0>
	
		<cfif arguments.productGroupLevel EQ 1>
		
			<cfquery name="qGetProductsCount" datasource="#application.datasource#">
				SELECT 	Count(BSA_Foodservice_Items_Master.Item) As groupProductsCount
				FROM	BSA_Foodservice_Items_Master
						INNER JOIN Line_Of_Business
						ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID
						INNER JOIN	Type_Code_Desc 
						ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID 
						INNER JOIN	Brand 
						ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID 
						<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
						INNER JOIN	Product_Q_Brand_Desc 
						ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
						AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
						<CFELSE>
						INNER JOIN	Q_Brand_Desc 
						ON BSA_Foodservice_Items_Master.Q_Brand_ID = Q_Brand_Desc.Q_Brand_ID
						</CFIF>
						INNER JOIN	Type_Group_Desc 
						ON BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
						INNER JOIN Category
						ON Category.Category_ID = BSA_Foodservice_Items_Master.Category_ID
						AND Category.Category IN (#ListQualify(application.returned_customer_setting.Category_List, "'", ",")#)
				WHERE
						BSA_Foodservice_Items_Master.Deleted = 0
						AND
						BSA_Foodservice_Items_Master.Active_Code = 'A'						
						<cfif arguments.productGroupID NEQ "" AND arguments.productGroupID NEQ 0>
						AND BSA_Foodservice_Items_Master.Business_Segment_ID = #arguments.productGroupID#
						</cfif>
			</cfquery>
						
			<cfset productsCount = qGetProductsCount.groupProductsCount />
		
		<cfelse>
		
			<!---initialize the ProductGroup DataManager--->
 			<cfset ProductGroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
			<cfset productsCount = ProductGroupDataManager.getGroupCount(arguments.productGroupID, arguments.productGroupLevel, arguments.programID) />
			
		</cfif>
	
		
		<cfreturn productsCount />
		
	</cffunction>
	
	<cffunction name="isAllProductProgram" output="true" returntype="boolean">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="discountTypeID" type="numeric" required="false" default="0">
		
		<cfset bAllProductProgram = false />
		
		<cfset this.businessSegmentID = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getSegmentIdByProgram(arguments.programId) />
		
		<!--- <cfset this.groupProductId = this.getProductForGroupProducts(1, this.businessSegmentID) /> LEGACY CODE?  TABLE has NO Data...anywhere--->
		<cfset this.groupProductId = "" />
		
		<cfif Len(this.groupProductId) Gt 0>
		
			<cfquery name="qGetAllProduct" datasource="#application.datasource#">
	
				SELECT	BSA_Foodservice_Items_Master_ID
				FROM	Contract_Products
				WHERE
						Contract_Products.Deleted = 0
						AND
						Contract_Products.Contract_Main_ID = #arguments.programId#
						AND
						Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#'
						<cfif arguments.discountTypeID>
						AND Contract_Products.Product_Type_ID = #arguments.discountTypeID#
						</cfif>
			</cfquery>
			
			<cfif qGetAllProduct.recordCount>
	
				<cfset bAllProductProgram = true />
			
			</cfif>
		
		</cfif>
		
		<cfreturn bAllProductProgram />
		
	</cffunction>
	
	
	<cffunction name="growthSelectProductsType" output="false" returntype="numeric" hint="returnvalue:0=search and add all,1=no add all,2=not search and no add all">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="growthComponentId" type="string" required="true" default="">
		
		<cfquery name="qGetOtherComponentProducts" datasource="#application.datasource#">

			SELECT	DISTINCT Contract_Products.Product_Group_Level_ID
			FROM	Program_Growth_Component_Product_Data
					INNER JOIN Program_Growth_Components
					ON
					Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
					AND
					Program_Growth_Components.Deleted = 0
					AND
					Program_Growth_Components.Program_ID = #arguments.programId#
					INNER JOIN Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
			WHERE
					Program_Growth_Component_Product_Data.Deleted = 0
					<cfif Len(arguments.growthComponentId) GT 0>
					AND
					Program_Growth_Component_Product_Data.Program_Growth_Component_ID <> '#arguments.growthComponentId#'
					</cfif>
			ORDER BY Contract_Products.Product_Group_Level_ID
					
		</cfquery>
		
		<cfset returnValue = 0 />
		
		<cfloop query="qGetOtherComponentProducts">
			<cfif Product_Group_Level_ID EQ 0 OR Product_Group_Level_ID EQ 1>
				<cfset returnValue = Product_Group_Level_ID + 1 />
			</cfif>
		</cfloop>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="lumpSelectProductsType" output="false" returntype="numeric" hint="returnvalue:0=search and add all,1=no add all,2=not search and no add all">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="lumpComponentId" type="string" required="true" default="">
		
		<cfquery name="qGetOtherComponentProducts" datasource="#application.datasource#">

			SELECT	DISTINCT Contract_Products.Product_Group_Level_ID
			FROM	Program_Lump_Sum_Product_Data
					INNER JOIN Program_Lump_Sums
					ON
					Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
					AND
					Program_Lump_Sums.Deleted = 0
					AND
					Program_Lump_Sums.Program_ID = #arguments.programId#
					INNER JOIN Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
			WHERE
					Program_Lump_Sum_Product_Data.Deleted = 0
					<cfif Len(arguments.lumpComponentId) GT 0>
					AND
					Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID <> '#arguments.lumpComponentId#'
					</cfif>
			ORDER BY Contract_Products.Product_Group_Level_ID
					
		</cfquery>
		
		<cfset returnValue = 0 />
		
		<cfloop query="qGetOtherComponentProducts">
			<cfif Product_Group_Level_ID EQ 0 OR Product_Group_Level_ID EQ 1>
				<cfset returnValue = Product_Group_Level_ID + 1 />
			</cfif>
		</cfloop>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	
	<cffunction name="getPerProductVolume" output="true" returntype="string">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="qProgram" type="query" required="true">
		<cfargument name="groupLevelId" type="numeric" required="false" default="0">
		
		<cfset returnVolume = "" />

		<cfset contractSpan = DateDiff("d", qProgram.Contract_Start_Date, qProgram.Contract_End_Date) + 1 />		
		<cfif groupLevelId>
			<cfset returnVolume = (qProgram.Contract_Quantity  * 7)/ (contractSpan) />
		<cfelse>
			<cfset businessSegmentID = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getSegmentIdByProgram(arguments.programId) />
			
			<cfif this.isAllProductProgram(arguments.programId)>
			
				<cfset productsCount = this.getProductGroupProductCount(1, businessSegmentID) />				
				<cfset returnVolume = (qProgram.Contract_Quantity  * 7)/ (productsCount * contractSpan) />
			
			</cfif>
		
		</cfif>

		<cfreturn returnVolume />
		
	</cffunction>
	
	<cffunction name="updateOtherAvgProductVolume" output="true">
	
		<cfargument name="programId" type="numeric" required="true">
		
		<cfif this.isAllProductProgram(arguments.programId) AND Len(this.groupProductId) GT 0>
		
			<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(arguments.programId) />
			<cfset productsCount = this.getProductGroupProductCount(1, this.businessSegmentID) />
			<cfset contractSpan = DateDiff("d", qProgram.Contract_Start_Date, qProgram.Contract_End_Date) + 1 />			
			<cfset This_Volume = qProgram.Contract_Quantity />
			<cfif productsCount NEQ 0 AND contractSpan NEQ 0>
				<cfset This_Volume = (qProgram.Contract_Quantity  * 7)/ (productsCount * contractSpan) />
			</cfif>
			<cfset Total_Weekly_Volume = (qProgram.Contract_Quantity  * 7)/ (contractSpan) />
			
			<!---------- Save Fixed Price ------------>
			<CFQUERY NAME="Get_Fixed_Volume" DATASOURCE="#application.datasource#">				
				UPDATE	Program_Fixed_Price_Product_Data
				SET 	Program_Fixed_Price_Product_Data.Volume = 
						CASE 
						WHEN	Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END
				FROM 	Program_Fixed_Price_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #arguments.programId#
				WHERE 	len(Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID) > 0
						AND Program_Fixed_Price_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Rebate Price ------------>
			<CFQUERY NAME="Get_Rebate_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Rebates_Product_Data
				SET 	Program_Rebates_Product_Data.Volume = 
						CASE 
						WHEN	Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END
				FROM 	Program_Rebates_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #arguments.programId#
				WHERE 	len(Program_Rebates_Product_Data.Unit_Of_Measure_ID) > 0
						AND Program_Rebates_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Lumpsum Price ------------>
			<CFQUERY NAME="Get_Lumpsum_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Lump_Sum_Product_Data
				SET 	Program_Lump_Sum_Product_Data.Volume = 
						CASE 
						WHEN	Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END
				FROM 	Program_Lump_Sum_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #arguments.programId#
				WHERE 	Program_Lump_Sum_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Growth Price ------------>
			<CFQUERY NAME="Get_Growth_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Growth_Component_Product_Data
				SET 	Program_Growth_Component_Product_Data.Weekly_Volume = 
						CASE 
						WHEN	Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END
				FROM 	Program_Growth_Component_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #arguments.programId#
						INNER JOIN Program_Growth_Component_Tiers
						ON
						Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
						AND
						Program_Growth_Component_Tiers.Tier_Number = '1'
						AND
						Program_Growth_Component_Tiers.Deleted = 0
						INNER JOIN Program_Growth_Component_Product_Tier_Data
						ON
						Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
						AND
						Program_Growth_Component_Product_Tier_Data.Deleted = 0
						AND
						Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
						
				WHERE 	len(Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID) > 0
						AND Program_Growth_Component_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Formula Price ------------>
			<CFQUERY NAME="Get_Formula_Volume" DATASOURCE="#application.datasource#">
				UPDATE	Program_Formula_Pricing_Rule_Products
				SET 	Program_Formula_Pricing_Rule_Products.Weekly_Volume = 
						CASE 
						WHEN	Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END
				FROM 	Program_Formula_Pricing_Rule_Products
						INNER JOIN Contract_Products
						ON
						Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #arguments.programId#
				WHERE 	len(Program_Formula_Pricing_Rule_Products.Unit_Of_Measure_ID) > 0
						AND Program_Formula_Pricing_Rule_Products.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Off_Invoice ------------>
			<CFQUERY NAME="Get_Off_Invoice_Volume" DATASOURCE="#application.datasource#">				
				UPDATE	Program_OffInvoice_Product_Data
				SET 	Program_OffInvoice_Product_Data.Volume = 
						CASE 
						WHEN	Contract_Products.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END
				FROM 	Program_OffInvoice_Product_Data
						INNER JOIN Contract_Products
						ON
						Program_OffInvoice_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
						AND Contract_Products.Deleted = 0
						AND	Contract_Products.Contract_Main_ID = #arguments.programId#
				WHERE 	len(Program_OffInvoice_Product_Data.UOM) > 0
						AND Program_OffInvoice_Product_Data.Deleted = 0 
			</CFQUERY>
			
			<!---------- Save Global Volume Rule ------------>
			<CFQUERY NAME="Get_Global_Volume" DATASOURCE="#application.datasource#">				
				UPDATE	Program_Product_Volume
				SET 	
						Volume_LB = 
						(CASE 
						WHEN	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END) *
						<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>
						CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float)
						<cfelse>
						1
						</cfif>,
						Volume_CS = 
						(CASE 
						WHEN	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#this.groupProductId#' THEN
						#Total_Weekly_Volume#
						ELSE
						#This_Volume#
						END) / 
						<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>
						1
						<cfelse>
						CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float)
						</cfif>
						
				FROM	Program_Product_Volume
						INNER JOIN BSA_Foodservice_Items_Master
						ON
						BSA_Foodservice_Items_Master.Deleted = 0
						AND
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
				WHERE
						Program_Product_Volume.Program_ID = '#arguments.programId#'
						AND Program_Product_Volume.Deleted = 0
			</CFQUERY>	
		
		</cfif>

	</cffunction>
	
	<cffunction name="getTypeGroups" output="true" returntype="query">
	
		<cfquery name="qGetTypeGroups" datasource="#application.datasource#">
			SELECT	Type_Group_Desc_ID As Product_Group_ID, Type_Group_Legacy As Product_Group_Legacy_ID, Type_Group_Desc As Product_Group_Desc
			FROM	Type_Group_Desc
			WHERE	Deleted = 0
			ORDER BY Type_Group_Desc
		</cfquery>
		
		<cfreturn qGetTypeGroups />
	
	</cffunction>
	
</cfcomponent>