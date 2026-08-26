<cfcomponent hint="New Product Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.NewProductManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.NewProduct">
		
		<cfargument name="id" type="string" required="true" />
		
		<cfset this.newProduct = CreateObject("component", "components.futures_pricing.NewProduct").init() />
		
		<cfif arguments.id>
		
			<cfset useLakebaseForqNewProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_new_product")>
<cfif useLakebaseForqNewProducts>
	<cftry>
		<cfset qNewProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_new_product", {
				"deleted" = "eq.0",
				"fp_new_product_id" = "eq.#arguments.id#",
				"select" = "fp_new_product_id,product_desc,customer_request"
			}), "fp_new_product_id,product_desc,customer_request"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqNewProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqNewProducts>
<cfquery name="qNewProducts" datasource="#application.datasource#">
				SELECT 	FP_New_Product_ID,
						Product_Desc,
						Customer_Request
				FROM 	FP_New_Product
				WHERE	Deleted = 0
				AND		FP_New_Product_ID = #arguments.id#
			</cfquery>
</cfif>
			
			<!---loop over new products and populate NewProduct object--->
			<cfloop query="qNewProducts">
			
				<cfset this.newProduct.setId(FP_New_Product_ID)>
				<cfset this.newProduct.setDesc(Product_Desc)>
				<cfset this.newProduct.setCustRequest(Customer_Request)>
				
				<cfquery name="qNewProductSurrogates" datasource="#application.datasource#">
					SELECT 	FP_Surrogate_ID,
							Product_ID,
							FP_New_Product_ID,
							Product_Desc
					FROM 	FP_Surrogate
					WHERE	Deleted = 0
					AND		FP_New_Product_ID = #this.newProduct.getId()#
				</cfquery>
				
				<!---loop over new product surrogates and populate NewProductSurrogate object--->
				<cfloop query="qNewProductSurrogates">
				
					<cfset productSurrogate = CreateObject("component", "components.futures_pricing.NewProductSurrogate") />
					<cfset productSurrogate.setId(FP_Surrogate_ID)>
					<cfset productSurrogate.setProdId(Product_ID)>
					<cfset productSurrogate.setNewProdId(FP_New_Product_ID)>
					<cfset productSurrogate.setDesc(Product_Desc)>
					
					<cfset this.newProduct.setSurrogate(productSurrogate)>
					
				</cfloop>
				
			</cfloop>
			
		</cfif>

		<cfreturn this.newProduct />
	
	</cffunction>
	
	<cffunction name="set" output="false" returntype="components.futures_pricing.NewProduct">
		
		<cfargument name="stData" type="struct" required="true" default="" />
		
		<cfset this.newProduct = CreateObject("component", "components.futures_pricing.NewProduct").init() />
		
		<!---populate NewProduct object--->
		<cfset this.newProduct.setId(arguments.stData.id)>
		<cfset this.newProduct.setDesc(arguments.stData.Product_Desc)>
		<cfset this.newProduct.setCustRequest(arguments.stData.Customer_Request)>
				
		<!---loop over new product surrogates and populate NewProductSurrogate object--->
		<cfloop index="surrIndx" list="#arguments.stData.Product_List#">
			
			<cfset tmpProdId = request.app_general_functions.replaceHyphen(surrIndx) />
			<cfparam name="arguments.stData.Product_Desc_#tmpProdId#" default="" />
			
 			<cfset productSurrogate = CreateObject("component", "components.futures_pricing.NewProductSurrogate") />
			<cfset productSurrogate.setProdId(surrIndx)>
			<cfset productSurrogate.setNewProdId(arguments.stData.id)>
			<cfset productSurrogate.setDesc(Evaluate("arguments.stData.Product_Desc_#tmpProdId#"))>
			
			<cfset this.newProduct.setSurrogate(productSurrogate)>
			
		</cfloop>

		<cfreturn this.newProduct />
	
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cftransaction>
		
			<cfif this.newProduct.getId()>
			
				<!------ update ----->
				<cfquery name="qUpdateNewProduct" datasource="#application.datasource#">
					UPDATE	FP_New_Product
					SET		Product_Desc = <cfqueryparam value="#this.newProduct.getDesc()#" cfsqltype="CF_SQL_VARCHAR">,
							Customer_Request = <cfqueryparam value="#this.newProduct.getCustRequest()#" cfsqltype="CF_SQL_VARCHAR">
					WHERE	Deleted = 0
					AND		FP_New_Product_ID = #this.newProduct.getId()#
				</cfquery>
			
			<cfelse>
			
				<!------ insert ----->
				<cfquery name="qInsertNewProduct" datasource="#application.datasource#">
				
					SET NOCOUNT ON
					
					INSERT INTO FP_New_Product
							(Product_Desc, Customer_Request)
					VALUES
							(
								<cfqueryparam value="#this.newProduct.getDesc()#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#this.newProduct.getCustRequest()#" cfsqltype="CF_SQL_VARCHAR">
							)
					
					SELECT FP_New_Product_ID = @@IDENTITY
					SET NOCOUNT OFF
					
				</cfquery>
				
				<cfset this.newProduct.setId(qInsertNewProduct.FP_New_Product_ID) />
				
			</cfif>
			
			<cfquery name="qUpdateNewProduct" datasource="#application.datasource#">
					UPDATE	FP_Surrogate
					SET		Deleted = 1
					WHERE	FP_New_Product_ID = #this.newProduct.getId()#
					AND		Deleted = 0
			</cfquery>
			
			<!---loop over and insert for each surrogate--->
			<cfloop index="surrIndx" from="1" to="#ArrayLen(this.newProduct.surrogate)#">
			
				<cfquery name="qInsertNewProductSurrogate" datasource="#application.datasource#">
				
					INSERT INTO FP_Surrogate
							(FP_New_Product_ID, Product_ID, Product_Desc)
					VALUES
							(
								<cfqueryparam value="#this.newProduct.getId()#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#this.newProduct.surrogate[surrIndx].getProdId()#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#this.newProduct.surrogate[surrIndx].getDesc()#" cfsqltype="CF_SQL_VARCHAR">
							)
	
				</cfquery>
				
			</cfloop>
		
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		
		<cfset useLakebaseForqGetNewProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_new_product")>
<cfif useLakebaseForqGetNewProducts>
	<cftry>
		<cfset qGetNewProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_new_product", {
				"deleted" = "eq.0",
				"select" = "fp_new_product_id,product_desc,customer_request"
			}), "fp_new_product_id,product_desc,customer_request"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetNewProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetNewProducts>
<cfquery name="qGetNewProducts" datasource="#application.datasource#">
			SELECT 	FP_New_Product_ID,
					Product_Desc,
					Customer_Request
			FROM 	FP_New_Product
			WHERE	Deleted = 0					
		</cfquery>
</cfif>
		
		<cfreturn qGetNewProducts />
	
	</cffunction>
	

</cfcomponent>
