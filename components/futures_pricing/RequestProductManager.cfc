<cfcomponent>

	<cffunction name="init" output="false" returntype="components.futures_pricing.RequestProductManager">
	
		<cfreturn this />
		
	</cffunction>
	
   	<cffunction name="getProductList" output="false" returntype="query">
		
		<cfargument name="lProductIds" type="string" required="true" default="">
		
		<cfquery name="qGetProducts" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Items_Master_ID,	
					Item,
					UPC,
					Description
			FROM 	BSA_Foodservice_Items_Master
			WHERE	BSA_Foodservice_Items_Master_ID in (#replace(listqualify(arguments.lProductIds, "'"), '"', "'")#)
			ORDER BY Item  ASC
		</cfquery>
		
		<cfreturn qGetProducts />	

   	</cffunction>
	
	<cffunction name="getProduct" output="false" returntype="query">
		
		<cfargument name="productId" type="string" required="true" default="">
		
		<!---get product detail info from database--->
		<cfset useLakebaseForqGetProductInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForqGetProductInfo>
	<cftry>
		<cfset qGetProductInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#arguments.productId#",
				"deleted" = "eq.0",
				"select" = "item,upc,description"
			}), "item,upc,description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductInfo>
<cfquery name="qGetProductInfo" datasource="#application.datasource#">
			SELECT 	Item,
					UPC,
					Description
			FROM 	BSA_Foodservice_Items_Master
			WHERE	BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
			AND		Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn qGetProductInfo />	

   	</cffunction>
	
	<cffunction name="getRequestProducts" output="false" returntype="query">
		
		<cfargument name="requestId" type="numeric" required="true">
		
		<cfquery name="qGetProducts" datasource="#application.datasource#">
			SELECT 	FP_Product.FP_Product_ID, FP_Mat_Req_Product.FP_Preservation_ID,
					FP_Mat_Req_Product.Processing_Plant_Name,
					FP_Mat_Req_Product.Period_Offset,
					FP_Product.Final_Price,
					Delivery_Type.Delivery_Type_Desc,
					FP_Product.Volume,
					FP_Product.UOM,
					CASE
					WHEN FP_Product.Product_ID IS NULL THEN
						FP_New_Product.Product_Desc
					ELSE
						BSA_Foodservice_Items_Master.Description
					END AS Description,
					CASE
					WHEN FP_Product.Product_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.Item
					END AS Item,
					CASE
					WHEN FP_Product.Product_ID IS NULL THEN
						''
					ELSE
						BSA_Foodservice_Items_Master.UPC
					END AS UPC
			FROM 	FP_Product
					LEFT JOIN FP_Mat_Req_Product
					ON
					FP_Mat_Req_Product.FP_Product_ID = FP_Product.FP_Product_ID
					LEFT JOIN BSA_Foodservice_Items_Master
					ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = FP_Product.Product_ID
					AND
					BSA_Foodservice_Items_Master.Deleted = 0
					LEFT JOIN FP_New_Product
					ON
					FP_New_Product.FP_New_Product_ID = FP_Product.FP_New_Product_ID
					AND
					FP_New_Product.Deleted = 0
					LEFT JOIN Delivery_Type
					ON
					FP_Product.Delivery_Type_ID = Delivery_Type.Delivery_Type_ID
					AND
					Delivery_Type.Deleted = 0
			WHERE	
					FP_Product.Deleted = 0
					AND
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
		</cfquery>
		
		<cfreturn qGetProducts />	

   	</cffunction>
	
</cfcomponent>