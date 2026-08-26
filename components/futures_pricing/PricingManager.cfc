<cfcomponent hint="Futures Pricing Pricing Manager" extends="components.futures_pricing.MatReqManager">

	<cffunction name="init" output="false" returntype="components.futures_pricing.PricingManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getPricingRequest" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<cfset this.getMatReq(id=arguments.id, pagePhase=4, userId=arguments.userId)>
		
		<cfreturn this.request	/>
	
	</cffunction>
	
	<cffunction name="getProductRawMaterials" output="false" returntype="query">
	
		<cfargument name="requestProductId" type="numeric" required="true" />
		
		<cfquery name="qGetProductRawMaterials" datasource="#application.datasource#">
				SELECT	FP_Request_Raw_Material.FP_Request_Raw_Material_ID,
						FP_Request_Raw_Material.FP_Raw_Material_ID,
						FP_Request_Raw_Material.Blend, FP_Request_Raw_Material.Yield_Loss,
						SUM((FP_Raw_Material_Quote.Quote/ (((100*FP_Raw_Material_Quote.Quote_UOM+2) - 100) - FP_Raw_Material_Quote.Quote_UOM)) * FP_Raw_Material_Quote.Quote_Volume) 
						/ (
							SELECT 	SUM(Quote.Quote_Volume)
							FROM	FP_Raw_Material_Quote Quote
							WHERE
									Quote.FP_Request_Master_ID = FP_Product.FP_Request_Master_ID
									AND
									Quote.FP_Raw_Material_ID = FP_Request_Raw_Material.FP_Raw_Material_ID
									AND
									Quote.isSelected = 1
									AND
									Quote.Deleted = 0
							)
						AS Quote										
				FROM	FP_Request_Raw_Material
						INNER JOIN FP_Product
						ON
						FP_Product.Deleted = 0
						AND
						FP_Product.FP_Product_ID = FP_Request_Raw_Material.FP_Product_ID
						INNER JOIN FP_Raw_Material_Quote
						ON
						FP_Raw_Material_Quote.FP_Request_Master_ID = FP_Product.FP_Request_Master_ID
						AND
						FP_Raw_Material_Quote.FP_Raw_Material_ID = FP_Request_Raw_Material.FP_Raw_Material_ID
						AND
						FP_Raw_Material_Quote.isSelected = 1
						AND
						FP_Raw_Material_Quote.Deleted = 0
				WHERE
						FP_Request_Raw_Material.FP_Product_ID = #requestProduct.getRequestProdId()#
						AND
						FP_Request_Raw_Material.Deleted = 0
				GROUP BY FP_Product.FP_Request_Master_ID, FP_Request_Raw_Material.FP_Request_Raw_Material_ID, FP_Request_Raw_Material.FP_Raw_Material_ID, FP_Request_Raw_Material.Blend, FP_Request_Raw_Material.Yield_Loss
			</cfquery>
		
		<cfreturn qGetProductRawMaterials />
	
	</cffunction>
	
	<!------ <cffunction name="getRequestRawMaterials" output="false" returntype="query">
	
		<cfargument name="requestId" type="numeric" required="true" />
		
		<cfquery name="qGetRequestRawMaterials" datasource="#application.datasource#">
			SELECT	FP_Request_Raw_Material.FP_Request_Raw_Material_ID,
					FP_Request_Raw_Material.FP_Raw_Material_ID, FP_Product.FP_Product_ID,
					FP_Request_Raw_Material.Blend, FP_Request_Raw_Material.Yield_Loss,
					FP_Raw_Material.Raw_Material_Number, FP_Raw_Material.Raw_Material_Desc,
					AVG(FP_Raw_Material_Quote.Quote / (((100*FP_Raw_Material_Quote.Quote_UOM+2) - 100) - FP_Raw_Material_Quote.Quote_UOM)) AS Quote
			FROM	FP_Product
					LEFT JOIN BSA_Foodservice_Items_Master
					ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = FP_Product.Product_ID
					AND
					BSA_Foodservice_Items_Master.Deleted = 0
					INNER JOIN FP_Request_Raw_Material
					ON
					FP_Request_Raw_Material.FP_Product_ID = FP_Product.FP_Product_ID
					AND
					FP_Request_Raw_Material.Deleted = 0
					INNER JOIN FP_Raw_Material
					ON
					FP_Request_Raw_Material.FP_Raw_Material_ID = FP_Raw_Material.FP_Raw_Material_ID
					AND
					FP_Raw_Material.Deleted = 0
					INNER JOIN FP_Raw_Material_Quote
					ON
					FP_Raw_Material_Quote.FP_Request_Master_ID = FP_Product.FP_Request_Master_ID
					AND
					FP_Raw_Material_Quote.FP_Raw_Material_ID = FP_Raw_Material.FP_Raw_Material_ID
					AND
					FP_Raw_Material_Quote.isSelected = 1
					AND
					FP_Raw_Material_Quote.Deleted = 0
			WHERE
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
					AND
					FP_Product.Deleted = 0
			GROUP BY FP_Product.FP_Product_ID, FP_Request_Raw_Material.FP_Request_Raw_Material_ID, FP_Request_Raw_Material.FP_Raw_Material_ID, FP_Request_Raw_Material.Blend, FP_Request_Raw_Material.Yield_Loss, FP_Raw_Material.Raw_Material_Number, FP_Raw_Material.Raw_Material_Desc
		</cfquery>
		
		<cfreturn qGetRequestRawMaterials />
	
	</cffunction> ----->
	
	
	<cffunction name="getProductCost" output="false" returntype="query">
	
		<cfargument name="requestId" type="numeric" required="true" />
		
		<cfquery name="qGetProductCost" datasource="#application.datasource#">
			SELECT	SUM(((FP_Raw_Material_Quote.Quote * FP_Request_Raw_Material.Blend) / 100) * (100 + FP_Request_Raw_Material.Yield_Loss) / 100) AS Product_Cost, 
					FP_Product.FP_Product_ID
			FROM	FP_Product
					INNER JOIN FP_Request_Raw_Material
					ON
					FP_Request_Raw_Material.FP_Product_ID = FP_Product.FP_Product_ID
					AND
					FP_Request_Raw_Material.Deleted = 0
					INNER JOIN FP_Raw_Material
					ON
					FP_Request_Raw_Material.FP_Raw_Material_ID = FP_Raw_Material.FP_Raw_Material_ID
					AND
					FP_Raw_Material.Deleted = 0
					INNER JOIN FP_Raw_Material_Quote
					ON
					FP_Raw_Material_Quote.FP_Request_Master_ID = FP_Product.FP_Request_Master_ID
					AND
					FP_Raw_Material_Quote.FP_Raw_Material_ID = FP_Raw_Material.FP_Raw_Material_ID
					AND
					FP_Raw_Material_Quote.isSelected = 1
					AND
					FP_Raw_Material_Quote.Deleted = 0
			WHERE
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
					AND
					FP_Product.Deleted = 0
			GROUP BY FP_Product.FP_Product_ID
		</cfquery>
		
		<cfreturn qGetProductCost />
	
	</cffunction>
	
	
	<cffunction name="getPricingOverheads" output="false" returntype="query">
	
		<cfargument name="requestId" type="numeric" required="false" default="0" />
		<cfargument name="productId" type="numeric" required="false" default="0" />
	
		<cfquery name="qGetPricingOverheads" datasource="#application.datasource#">
			SELECT	FP_Price_Overhead.FP_Product_ID, 
					FP_Price_Overhead.Overhead_Desc, 
					FP_Price_Overhead.Overhead_Value, 
					FP_Price_Overhead.FP_Overhead_UOM_ID,
					FP_Price_Overhead.Componded_Independent,
					FP_Overhead_UOM.UOM_Desc
			FROM	FP_Price_Overhead
					INNER JOIN FP_Overhead_UOM
					ON
					FP_Overhead_UOM.Deleted = 0
					AND
					FP_Overhead_UOM.FP_Overhead_UOM_ID = FP_Price_Overhead.FP_Overhead_UOM_ID
					<cfif arguments.requestId>
					INNER JOIN FP_Product
					ON
					FP_Product.FP_Product_ID = FP_Price_Overhead.FP_Product_ID
					AND
					FP_Product.Deleted = 0
					AND
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
					</cfif>
			WHERE
					FP_Price_Overhead.Deleted = 0
					<cfif arguments.productId>
					AND FP_Price_Overhead.FP_Product_ID = #arguments.productId#
					</cfif>
		</cfquery>
		
		<cfreturn qGetPricingOverheads />	
	
	</cffunction>
	
	<cffunction name="getPricingOverheadUOM" output="false" returntype="query">
	
		<cfset useLakebaseForqGetPricingOverheadUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_overhead_uom")>
<cfif useLakebaseForqGetPricingOverheadUOM>
	<cftry>
		<cfset qGetPricingOverheadUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_overhead_uom", {
				"deleted" = "eq.0",
				"select" = "fp_overhead_uom_id,uom_desc"
			}), "fp_overhead_uom_id,uom_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPricingOverheadUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPricingOverheadUOM>
<cfquery name="qGetPricingOverheadUOM" datasource="#application.datasource#">
			SELECT	FP_Overhead_UOM_ID, UOM_Desc
			FROM	FP_Overhead_UOM
			WHERE
					Deleted = 0
		</cfquery>
</cfif>
		
		<cfreturn qGetPricingOverheadUOM />
	
	</cffunction>
	
	<cffunction name="savePricingOverheads" output="false">
	
		<cfargument name="dataStruct" type="struct" required="true" />
		
		
		<cfset compoundedIndependent = "1,2">
		
		<cftransaction action="BEGIN">
		
			<cftry>
			
				<cfloop list="#this.request.getLFPProductIds()#" delimiters="," index="currentProductId">
		
					<!------ delete all over heads for thie request ----->
					<cfquery name="qDeleteOverheads" datasource="#application.datasource#">
						UPDATE	FP_Price_Overhead
						SET		Deleted = 1
						WHERE
								FP_Product_ID = #currentProductId#
								AND
								Deleted = 0
					</cfquery>
		
					<cfloop list="#compoundedIndependent#" delimiters="," index="thisCompIndep">

						<cfset compondedIndependentCountField = "compondedIndependentCount_#currentProductId#_#thisCompIndep#">
						<cfset compIndepCount = Evaluate("arguments.dataStruct.#compondedIndependentCountField#")>
						
						<cfset counter = 0>
						<cfset i = 0>
						
						<!------ <cfloop index="i" from="1" to="#compIndepCount#"> ----->
						<cfloop condition="counter LT compIndepCount">
							<cfif i GT 10>
								<cfbreak>
							</cfif>
							<cfset i = i + 1>
							<cfset fieldNameSuffix = "#currentProductId#_#thisCompIndep#_#i#">
						
							<cfif isDefined("arguments.dataStruct.Overhead_Desc_#fieldNameSuffix#")>
							
								<cfset counter = counter + 1>
								<cfset Overhead_Desc = Trim(Evaluate("arguments.dataStruct.Overhead_Desc_#fieldNameSuffix#"))>
								<cfset Overhead_Value = Evaluate("arguments.dataStruct.Overhead_Value_#fieldNameSuffix#")>
								<cfset Overhead_UOM = Evaluate("arguments.dataStruct.Overhead_UOM_#fieldNameSuffix#")>							
							
								<cfif Len(Overhead_Desc) GT 0 AND Overhead_Value NEQ "" AND isNumeric(Overhead_Value)>
									<!------ insert overheads ----->
									<cfquery name="qInsertOverhead" datasource="#application.datasource#">
										INSERT INTO FP_Price_Overhead
												(FP_Product_ID, Overhead_Desc, Overhead_Value, FP_Overhead_UOM_ID, Componded_Independent)
										VALUES
												(#currentProductId#, '#Overhead_Desc#', #Overhead_Value#, #Overhead_UOM#, #thisCompIndep#)
									</cfquery>
								</cfif>
								
							</cfif>
							
						</cfloop>						
						
					</cfloop>

				</cfloop>
				
				<cftransaction action="COMMIT">
				<cfcatch>
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				</cfcatch>
			
			</cftry>
		
		
		</cftransaction>
	
	</cffunction>
	
	
	<cffunction name="savePricingStatus" output="false">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="pricingStatusId" type="numeric" required="true" />
		
		<!------ update db ----->
		<cfquery name="qUpdatePricingStatus" datasource="#application.datasource#">
			UPDATE 	FP_Request_Master
			SET		FP_Pricing_Status_ID = <cfqueryparam value="#arguments.pricingStatusId#" cfsqltype="CF_SQL_INTEGER">
			WHERE
					Deleted = 0
					AND
					FP_Request_Master_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
	</cffunction>
	
	
	<cffunction name="updateProductPrice" output="false">
	
		<cfargument name="reqId" type="numeric" required="false" default="" />
	
		<!------ Final_Price ----->
		
		<!------ <cfset qGetAllProductCost = this.getProductCost(form.id) /> ----->
		<cfset qGetPricingOverheads = this.getPricingOverheads(form.id)>
		
		<!------ <cfloop list="#this.request.getLFPProductIds()#" delimiters="," index="currentProductId"> ----->
		<!------ Loop thru products ----->
		<cfset requestProductArray = this.request.getRequestProduct()>
		<cfset productCount = ArrayLen(requestProductArray)>
		<cfloop index="prodIndex" from="1" to="#productCount#">
			<cfset requestProduct = requestProductArray[prodIndex]>
			
			<cfset currentProductId = requestProduct.getRequestProdId() />
			
			<cfset totalPrice = 0 />
			<cfset totalAmount = 0 />
			<cfset requestRawMaterialsArray = requestProduct.getRequestRawMaterial()>
			<cfset requestRawMaterialsCount = ArrayLen(requestRawMaterialsArray)>
			<!------ Loop thru raw materials ----->				
			<cfloop index="rawMatIndex" from="1" to="#requestRawMaterialsCount#">
				<cfset requestRawMaterial = requestRawMaterialsArray[rawMatIndex]>
				
				<cfset Quote = requestRawMaterial.getQuote()>
				<cfset rawVolumeCentYield = (requestProduct.getLbVolume() * requestRawMaterial.getBlend()) / 100 />
				<cfset rawVolume = requestRawMaterial.getEffectiveVolume() />
				<cfset rawAmount = Quote * rawVolume>
				<cfset totalAmount = totalAmount + rawAmount>				
			</cfloop>
			
			<cfif requestProduct.getLbVolume() NEQ 0>
				<cfset totalPrice = totalAmount/requestProduct.getLbVolume() />
				<!------ change lb price to appropriate price ----->
				<cfif requestProduct.getUOM() EQ 1>
					<cfset totalPrice = totalPrice * requestProduct.getNetWeight() />
				</cfif>
			</cfif>
			
			<cfset compoundedIndependent = "1,2">
			<cfset totalOverhead = 0>
			<cfloop list="#compoundedIndependent#" delimiters="," index="thisCompIndep">
			
				<cfset useLakebaseForqGetProductPricingOverheads = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetpricingoverheads")>
<cfif useLakebaseForqGetProductPricingOverheads>
	<cftry>
		<cfset qGetProductPricingOverheads = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetpricingoverheads", {
				"fp_product_id" = "eq.#currentProductId#",
				"componded_independent" = "eq.#thisCompIndep#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductPricingOverheads = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductPricingOverheads>
<cfquery name="qGetProductPricingOverheads" dbtype="query">
					SELECT	*
					FROM	qGetPricingOverheads
					WHERE
							FP_Product_ID = #currentProductId#
							AND
							Componded_Independent = #thisCompIndep#
				</cfquery>
</cfif>
				
				<cfset totalOverhead = totalOverhead + this.calcOverhead(totalPrice, qGetProductPricingOverheads, thisCompIndep)>
				
			</cfloop>
			
			<cfset totalPrice = totalPrice + totalOverhead>	
			
			<cfset useLakebaseForqUpdatePrice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_product")>
<cfif useLakebaseForqUpdatePrice>
	<cftry>
		<cfset application.oLakebase.updateRows("fp_product",
			{
				"fp_product_id" = "eq.#currentProductId#",
				"deleted" = "eq.0"
			},
			{
				"final_price" = "#totalPrice#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdatePrice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdatePrice>
<cfquery name="qUpdatePrice" datasource="#application.datasource#">
				
				UPDATE	FP_Product
				SET		Final_Price = #totalPrice#
				WHERE
						FP_Product_ID = #currentProductId#
						AND
						Deleted = 0
				
			</cfquery>
</cfif>

		</cfloop>	
		
	</cffunction>
	
	
	<cffunction name="calcOverhead" output="false">
	
		<cfargument name="startValue" type="numeric" required="true" />
		<cfargument name="srcQuery" type="query" required="true" />
		<cfargument name="compoundedIndependent" type="numeric" required="true" />
		
		<cfset totalValue = arguments.startValue>
		<cfset startValue = arguments.startValue>
		
		<cfloop query="qGetProductPricingOverheads">
			
				<cfif FP_Overhead_UOM_ID EQ 2><!------ % ----->
				
					<cfset currentValue = (Overhead_Value * startValue) / 100>
				
				<cfelse>
				
					<cfset currentValue = Overhead_Value>
					
				</cfif>
				
				<cfset totalValue = totalValue + currentValue>
				
				<cfif arguments.compoundedIndependent EQ 1><!------ compounded ----->
				
					<cfset startValue = totalValue>
				
				</cfif>
			
		</cfloop>
		
		<cfset totalValue = totalValue - arguments.startValue>
		
		<cfreturn totalValue />
	
	</cffunction>
	
</cfcomponent>
