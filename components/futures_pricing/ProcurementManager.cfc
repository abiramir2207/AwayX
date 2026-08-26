<cfcomponent hint="Futures Pricing Raw Material Manager" extends="components.futures_pricing.RequestManager">
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.ProcurementManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getRequestProcurement" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<cfset this.get(id=arguments.id, userId=arguments.userId)>
		<cfset this.request.setProcurement(this.getProcurementRawMaterials(arguments.id)) />
		
		<cfreturn this.request	/>
	
	</cffunction>
	
	<cffunction name="getProcurementRawMaterials" output="false" returntype="components.futures_pricing.ProcurementRawMaterial">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="loadQuote" type="numeric" required="false" default="1" hint="1=Load quotes from DB, 2=Load quotes from form, 3=Don't load quotes." />
		
		<!---create an instance of the Procurement object--->
		<cfset procurementRawMaterial = CreateObject("component", "components.futures_pricing.ProcurementRawMaterial") />
		
		<!---get list of raw materials--->
		<cfset qGetRawMat = this.getRequestRawMaterials(arguments.id) />
		<cfset procurementRawMaterial.setLRecommendedSupplierIds(ValueList(qGetRawMat.FP_Supplier_ID)) />
		
		<cfloop query="qGetRawMat">
			
			<!---create an instance of the RawMaterial object and populate with data--->
			<cfset rawMaterial = CreateObject("component", "components.futures_pricing.RawMaterial") />
			<cfset rawMaterial.setId(FP_Raw_Material_ID) />
			<cfset rawMaterial.setNumber(Raw_Material_Number) />
			<cfset rawMaterial.setDesc(Raw_Material_Desc) />
			<cfset rawMaterial.setRecommendedSupplierId(FP_Supplier_ID) />
			<cfset rawMaterial.setVolumeLb(rawMaterialVolumeLb) />
			
			<!---load supplier quotes from DB--->
			<cfif arguments.loadQuote eq 1>
				<cfset this.getQuotesFromDB(rawMaterial, arguments.id) />
			<!---load supplier quotes from form--->
			<cfelseif arguments.loadQuote eq 2>

			<!---don't load supplier quotes--->
			<cfelseif arguments.loadQuote eq 3>
			
			</cfif>
			
			<cfset procurementRawMaterial.setRawMaterial(rawMaterial) />
				
		</cfloop>

		<cfreturn procurementRawMaterial />
		
	</cffunction>
	
	<cffunction name="getQuotesFromDB" output="false">
			
		<cfargument name="rawMaterial" required="true" default="" type="components.futures_pricing.RawMaterial" />
		<cfargument name="id" required="true" default="" type="numeric" />
		
		<!---get list of supplier quotes--->
		<cfset qGetSupplier = this.getRawMatQuotes(arguments.id, arguments.rawMaterial.getId()) />
			
		<cfloop query="qGetSupplier">
			
			<!---create an instance of the SupplierQuote object and populate with data--->
			<cfset suppQuote = CreateObject("component", "components.futures_pricing.SupplierQuote") />
			<cfset suppQuote.setQuoteId(FP_Raw_Material_Quote_ID) />
			<cfset suppQuote.setSupplierId(FP_Supplier_ID) />
			<cfset suppQuote.setSupplierName(Supplier_Name) />
			<cfset suppQuote.setRawMaterialId(FP_Raw_Material_ID) />
			<cfset suppQuote.setQuote(Quote) />
			<cfset suppQuote.setQuoteVolume(Quote_Volume) />
			<cfset suppQuote.setQuoteUOM(Quote_UOM) />
			<cfset suppQuote.setQuoteDate(Quote_Date) />
			<cfset suppQuote.setQuoteGoodUntil(Good_Until_Date) />
			<cfset suppQuote.setIsSelected(isSelected) />
				
			<!---add SupplierQuote object to the RawMaterial object--->
			<cfset arguments.rawMaterial.setSupplierQuotes(suppQuote) />
				
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getRequestRawMaterials" output="false" returntype="query">
	
		<cfargument name="requestId" type="numeric" required="true" />
		
		<cfquery name="qGetRequestRawMaterials" datasource="#application.datasource#">
		
			SELECT		FP_Raw_Material.FP_Raw_Material_ID, 
						FP_Raw_Material.Raw_Material_Number,
						FP_Raw_Material.Raw_Material_Desc,
						FP_Procurement_Raw_Material.FP_Supplier_ID,
						SUM(FP_Product.Volume *
							POWER(ISNull(CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT), 0), FP_Product.uom % 2)
							* (FP_Request_Raw_Material.Blend / 100) * ((FP_Request_Raw_Material.Yield_Loss + 100) / 100)) rawMaterialVolumeLb
			FROM		FP_Product
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
						FP_Raw_Material.FP_Raw_Material_ID = FP_Request_Raw_Material.FP_Raw_Material_ID
						AND
						FP_Raw_Material.Deleted = 0
						LEFT JOIN FP_Procurement_Raw_Material
						ON
						FP_Procurement_Raw_Material.Deleted = 0
						AND
						FP_Procurement_Raw_Material.FP_Raw_Material_ID = FP_Raw_Material.FP_Raw_Material_ID
						AND
						FP_Procurement_Raw_Material.FP_Request_Master_ID = FP_Product.FP_Request_Master_ID
			WHERE		FP_Product.FP_Request_Master_ID = #arguments.requestId#
						AND		
						FP_Product.Deleted = 0	
			GROUP BY 	FP_Raw_Material.FP_Raw_Material_ID, 
						FP_Raw_Material.Raw_Material_Number, 
						FP_Raw_Material.Raw_Material_Desc,
						FP_Procurement_Raw_Material.FP_Supplier_ID
		
		</cfquery>
		
		<!------ <cfquery name="qGetRequestRawMaterials" datasource="#application.datasource#">
			SELECT	FP_Raw_Material.FP_Raw_Material_ID, 
					FP_Raw_Material.Raw_Material_Number, 
					FP_Raw_Material.Raw_Material_Desc,
					FP_Procurement_Raw_Material.FP_Supplier_ID
			FROM	FP_Raw_Material
					LEFT JOIN FP_Procurement_Raw_Material
					ON
					FP_Procurement_Raw_Material.Deleted = 0
					AND
					FP_Procurement_Raw_Material.FP_Raw_Material_ID = FP_Raw_Material.FP_Raw_Material_ID
					AND
					FP_Procurement_Raw_Material.FP_Request_Master_ID = #arguments.requestId#
			WHERE	FP_Raw_Material.Deleted = 0
			AND		FP_Raw_Material.FP_Raw_Material_ID IN 
					(
						SELECT		Distinct(FP_Request_Raw_Material.FP_Raw_Material_ID)
						FROM		FP_Product
									INNER JOIN FP_Request_Raw_Material
									ON
											FP_Request_Raw_Material.FP_Product_ID = FP_Product.FP_Product_ID
									AND		FP_Request_Raw_Material.Deleted = 0
						WHERE		FP_Product.FP_Request_Master_ID = #arguments.requestId#
						AND			FP_Product.Deleted = 0
					)
		</cfquery> ----->
		
		<cfreturn qGetRequestRawMaterials />
	
	</cffunction>
	
	<cffunction name="getRawMatQuotes" output="false" returntype="query">
	
		<cfargument name="requestId" type="numeric" required="true" />
		<cfargument name="rawMaterialId" type="numeric" required="true" />
		
		<cfquery name="qGetQuotes" datasource="#application.datasource#">
			
			SELECT 		FP_Raw_Material_Quote.FP_Raw_Material_Quote_ID,
						FP_Raw_Material_Quote.FP_Supplier_ID,
						FP_Supplier.Supplier_Name,
						FP_Raw_Material_Quote.FP_Raw_Material_ID,
						FP_Raw_Material_Quote.Quote,
						FP_Raw_Material_Quote.Quote_Volume,
						FP_Raw_Material_Quote.Quote_UOM,
						FP_Raw_Material_Quote.Quote_Date,
						FP_Raw_Material_Quote.Good_Until_Date,
						FP_Raw_Material_Quote.isSelected
			FROM 		FP_Raw_Material_Quote
						INNER JOIN FP_Supplier
						ON
						FP_Supplier.FP_Supplier_ID = FP_Raw_Material_Quote.FP_Supplier_ID
						AND
						FP_Supplier.Deleted = 0
			WHERE 		FP_Raw_Material_Quote.FP_Request_Master_ID = #arguments.requestId#
			AND			FP_Raw_Material_Quote.FP_Raw_Material_ID = #arguments.rawMaterialId#
			AND			FP_Raw_Material_Quote.Deleted = 0
		
		</cfquery>
		
		<cfreturn qGetQuotes />
	
	</cffunction>
	
	<!---////////////////////////////////////////// SETFROMFORM FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="setFromForm" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="struct" required="false" default="" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<cfset this.get(id=arguments.id, userId=arguments.userId)>
		<cfset this.request.setForward(arguments.stData.forward) />
		<cfset this.request.setProcurement(this.getProcurementRawMaterials(arguments.id, 2)) />
		
		<cfloop index="rmIndx" from="1" to="#ArrayLen(this.request.getProcurement().rawMaterial)#">
		
			<cfloop index="suppIndx" list="#Evaluate("arguments.stData.lrawMatId_#this.request.getProcurement().rawMaterial[rmIndx].getId()#")#">
				
				<cfparam name="arguments.stData.quote_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#" default="" />
				<cfparam name="arguments.stData.quoteVolume_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#" default="" />
				<cfparam name="arguments.stData.uom_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#" default="" />
				<cfparam name="arguments.stData.quoteDate_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#" default="" />
				<cfparam name="arguments.stData.goodUntil_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#" default="" />
				<cfparam name="arguments.stData.selected_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#" default=0 />
				
				<!---create an instance of SupplierManager to get the supplier name--->
				<cfset suppName = CreateObject("component","components.futures_pricing.SupplierManager").get(suppIndx).getName() />
				
				<!---create an instance of the SupplierQuote object and populate with data--->
				<cfset suppQuote = CreateObject("component", "components.futures_pricing.SupplierQuote") />
				<cfset suppQuote.setSupplierId(suppIndx) />
				<cfset suppQuote.setSupplierName(suppName) />
				<cfset suppQuote.setRawMaterialId(this.request.getProcurement().rawMaterial[rmIndx].getId()) />
				<cfset suppQuote.setQuote(Evaluate("arguments.stData.quote_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#")) />
				<cfset suppQuote.setQuoteVolume(Evaluate("arguments.stData.quoteVolume_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#")) />
				<cfset suppQuote.setQuoteUOM(Evaluate("arguments.stData.uom_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#")) />
				<cfset suppQuote.setQuoteDate(Evaluate("arguments.stData.quoteDate_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#")) />
				<cfset suppQuote.setQuoteGoodUntil(Evaluate("arguments.stData.goodUntil_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#")) />
				<cfset suppQuote.setIsSelected(Evaluate("arguments.stData.selected_#this.request.getProcurement().rawMaterial[rmIndx].getId()#_#suppIndx#")) />
				
				<!---add SupplierQuote object to the RawMaterial object--->
				<cfset this.request.procurement.rawMaterial[rmIndx].setSupplierQuotes(suppQuote) />
				
			</cfloop>
			
		</cfloop>

		<cfreturn this.request	/>
	
	</cffunction>
	
	<cffunction name="save" output="false">
		
		<cfargument name="stProcurementData" type="components.futures_pricing.Request" required="true" default="" />

		<cftransaction>
		
			<!---set deleted to 1--->
			<cfquery name="qInsert" datasource="#application.datasource#">
				UPDATE 	FP_Raw_Material_Quote
				SET		Deleted = 1
				WHERE	FP_Request_Master_ID = #arguments.stProcurementData.getId()#
			</cfquery>
					
			<!---loop for each raw material--->
			<cfloop index="rmIndx" from="1" to="#ArrayLen(arguments.stProcurementData.procurement.rawMaterial)#">
			
				<!---loop for each supplier--->
				<cfloop index="suppIndx" from="1" to="#ArrayLen(arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes)#">

					<!---now insert--->
					<cfquery name="qInsert" datasource="#application.datasource#">
						INSERT INTO FP_Raw_Material_Quote
							(FP_Request_Master_ID, FP_Raw_Material_ID, FP_Supplier_ID, Quote, Quote_Volume, Quote_UOM, Quote_Date, Good_Until_Date, isSelected)
						VALUES
							(
								<cfqueryparam value="#arguments.stProcurementData.getId()#" cfsqltype="CF_SQL_NUMERIC" />, 
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getRawMaterialId()#" cfsqltype="CF_SQL_NUMERIC" />,
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getSupplierId()#" cfsqltype="CF_SQL_NUMERIC" />,
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuote()#" cfsqltype="CF_SQL_VARCHAR" />,
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteVolume()#" cfsqltype="CF_SQL_VARCHAR" />,
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteUOM()#" cfsqltype="CF_SQL_NUMERIC" />, 
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteDate()#" cfsqltype="CF_SQL_DATE" />, 
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getQuoteGoodUntil()#" cfsqltype="CF_SQL_DATE" />, 
								<cfqueryparam value="#arguments.stProcurementData.procurement.rawMaterial[rmIndx].supplierQuotes[suppIndx].getIsSelected()#" cfsqltype="CF_SQL_BIT" />
							)
					</cfquery>
					
				</cfloop>
				
			</cfloop>
		
		</cftransaction>

	</cffunction>
	
</cfcomponent>
