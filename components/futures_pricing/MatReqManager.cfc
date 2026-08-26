<cfcomponent hint="Futures Pricing Raw Material Manager" extends="components.futures_pricing.RequestManager">

	<cffunction name="init" output="false" returntype="components.futures_pricing.MatReqManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getMatReq" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="pagePhase" type="string" required="false" default="" hint="2: will load volume distribution, 3: will load procurement raw material" />
		<cfargument name="companyId" required="false" default="" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<cfset this.get(id=arguments.id, companyId=arguments.companyId, userId=arguments.userId)>
		
	<!--- 	<cfset procurementManager = CreateObject("component", "components.futures_pricing.ProcurementManager").init() /> --->
		
		<!------ load request raw materials for each product ----->
		<cfset requestProductArray = this.request.getRequestProduct()>
		<cfset productCount = ArrayLen(requestProductArray)>
		<cfloop index="prodIndex" from="1" to="#productCount#">
			
			<cfset requestProduct = requestProductArray[prodIndex]>
			
			<cfset qGetRequestRawMaterials = this.getProductRawMaterials(requestProduct.getRequestProdId()) />
			
			<!---loop over raw materials and set the object --->
			<cfloop query="qGetRequestRawMaterials">
			
				<!---create RequestRawMaterial object--->
				<cfset requestRawMaterialObj = CreateObject("component", "components.futures_pricing.RequestRawMaterial") />
			
				<!---set values in RequestProduct object--->
				<cfset requestRawMaterialObj.setRequestRawMaterialId(FP_Request_Raw_Material_ID) />
				<cfset requestRawMaterialObj.setRawMaterialId(FP_Raw_Material_ID) />
				<cfset requestRawMaterialObj.setBlend(Blend) />
				<cfset requestRawMaterialObj.setYieldLoss(Yield_Loss) />
				<cfset requestRawMaterialObj.setEffectiveVolume(requestProduct.getLbVolume()) />
				
				<cfif arguments.pagePhase EQ 4 AND isDefined("Quote")>
					<cfset requestRawMaterialObj.setQuote(Quote) />
				</cfif>
				
			
				<cfif arguments.pagePhase EQ 2>
					<!------ get volume distribution ----->				
					<!------ build the volume distribution from db ----->
					<cfquery name="qGetVolDist" datasource="#application.datasource#">
						SELECT	Start_Date,
								End_Date,
								Volume,
								Interval_Order 
						FROM 	FP_Raw_Volume_Distribution
						WHERE	Deleted = 0
						AND 	FP_Request_Raw_Material_ID = #FP_Request_Raw_Material_ID#
						ORDER BY Interval_Order
					</cfquery>
					
					<cfset volumeMultiplier = 1 />
					<cfif qGetVolDist.recordCount EQ 0>

						<!------ TODO: initial volume ----->
						<cfset volumeMultiplier = this.setProjectedProductVolDist(requestProduct, requestRawMaterialObj) />
						
					<cfelse>
					
						<cfloop query="qGetVolDist">
						
							<!---create DistributedVolume object--->
							<cfset distVolObj = CreateObject("component", "components.futures_pricing.DistributedVolume") />
							
							<!---populate the DistributedVolume object with data--->
							<cfset distVolObj.setStartDate(Start_Date) />
							<cfset distVolObj.setEndDate(End_Date) />
							<cfset distVolObj.setVolume(Volume) />
							<cfset distVolObj.setOrder(Interval_Order) />
							
							<!---add the DistributedVolume object to the requestRawMaterial object--->
							<cfset requestRawMaterialObj.setSourceVolumeDist(distVolObj) />
						
						</cfloop>
						
					</cfif>
					
					<cfset this.setCurrentVolumeDistribution(requestRawMaterialObj, requestProduct.getProcessingStartDate(), requestProduct.getProcessingEndDate(), volumeMultiplier)>
					
				</cfif>
				<!---add the RequestRawMaterial object to the RequestProduct object--->
				<cfset requestProduct.setRequestRawMaterial(requestRawMaterialObj) />
				
			</cfloop><!------ loop on raw material ----->
			
		</cfloop><!------ loop on  products ----->
		
		<cfif arguments.pagePhase EQ 3><!------ load procurementRawMaterial ----->

			<cfset this.request.setProcurement(CreateObject("component", "components.futures_pricing.ProcurementManager").getProcurementRawMaterials(arguments.id)) />
		
		</cfif>
		
		<cfreturn this.request	/>
	
	</cffunction>
	
	
	<cffunction name="setProjectedProductVolDist" output="false">
	
		<cfargument name="requestProduct" type="components.futures_pricing.RequestProduct" required="true" />
		<cfargument name="requestRawMaterial" type="components.futures_pricing.RequestRawMaterial" required="true" />
		
		<cfset volumeMultiplier = arguments.requestRawMaterial.getVolumeMultiplier() />
		<cfif arguments.requestProduct.getUom() EQ 1>
			<cfset volumeMultiplier = volumeMultiplier * arguments.requestProduct.getNetWeight() />
		</cfif>
		<cfset reqProdVolDisArray = arguments.requestProduct.getSourceVolumeDist() />
		<cfif ArrayLen(reqProdVolDisArray) EQ 0>
			<cfset this.setVolumeDistFromDb(arguments.requestProduct, arguments.requestProduct.getProcessingPeriodOffset()) />
		</cfif>
		<cfset arguments.requestRawMaterial.setSourceVolumeDistArray(arguments.requestProduct.getSourceVolumeDist()) />
		
		<cfreturn volumeMultiplier />
		
	</cffunction>
	
	<cffunction name="setCurrentVolumeDistribution" output="false">
		
		<cfargument name="requestRawMaterialObj" required="true" type="components.futures_pricing.RequestRawMaterial" />
		<cfargument name="processingStartDate" required="true" type="string" />
		<cfargument name="processingEndDate" required="true" type="string" />
		<cfargument name="volumeMultiplier" required="false" type="numeric" default="1" />		
		
		<cfset requestRawMaterialObj = arguments.requestRawMaterialObj />
		
		<cfset requestRawMaterialObj.setVolumeDistArray(CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(this.request.getPeriodType(), arguments.processingStartDate, arguments.processingEndDate, this.request.getCompanyId()))>
		
		<cfset requestRawMaterialObj.setVolumeDistArray(CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").translateVolumeDistribution(requestRawMaterialObj.getSourceVolumeDist(), requestRawMaterialObj.getVolumeDist(), arguments.volumeMultiplier))>
		
	</cffunction>
	
	<!---////////////////////////////////////////// SETFROMFORM FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="setFromForm" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="stFormData" required="false" default="" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<!---initialize Request object--->
		<cfset this.get(id=arguments.stFormData.id, companyId=arguments.stFormData.companyId, userId=arguments.userId)>
		<cfset this.request.setPeriodType(arguments.stFormData.periodType) />
		
		<!------ load request raw materials for each product from form variables ----->
		<cfset requestProductArray = this.request.getRequestProduct()>
		<cfset productCount = ArrayLen(requestProductArray)>
		<cfloop index="prodIndex" from="1" to="#productCount#">
			
			<!--- get RequestProduct object --->
			<cfset requestProduct = requestProductArray[prodIndex]>
			<cfset currentReqProductId = requestProduct.getRequestProdId()>
			
			<!------ Get product specific date from form ----->
			<cfparam name="arguments.stFormData.preservation_#currentReqProductId#" 	default="">
			<cfparam name="arguments.stFormData.processingPlant_#currentReqProductId#" 	default="">
			<cfparam name="arguments.stFormData.offset_#currentReqProductId#" 	default="">
			
			<cfset preservationId = Evaluate("arguments.stFormData.preservation_#currentReqProductId#")>
			<cfset processingPlant = Evaluate("arguments.stFormData.processingPlant_#currentReqProductId#")>
			<cfset processingOffset = Evaluate("arguments.stFormData.offset_#currentReqProductId#")>
			
			<cfset requestProduct.setPreservationId(preservationId)>
			<cfset requestProduct.setProcessingPlantName(processingPlant) />
			<cfset requestProduct.setProcessingPeriodOffset(processingOffset) />
			<cfset requestProduct.setProcessingStartDate(this.request.getStartDate(), processingOffset) />
			<cfset requestProduct.setProcessingEndDate(this.request.getEndDate(), processingOffset) />
			
			
			<cfset rawMaterialList = Evaluate("Mat_Id_#currentReqProductId#")>
			
			<!------ this is to find how much blend is free, so that we can distribute it with the raw materils ----->
			<cfset defaultBlend = 0>
			<cfset availBlend = 0>
			<cfset invalidBlend = 0>
			
			<cfloop list="#rawMaterialList#" delimiters="," index="currentRawMaterialId">
			
				<cfif isDefined("arguments.stFormData.Mat_Blend_#currentReqProductId#_#currentRawMaterialId#")>
				
					<cfset thisBlend = Evaluate("arguments.stFormData.Mat_Blend_#currentReqProductId#_#currentRawMaterialId#") />
					<cfif isNumeric(thisBlend)>
						<cfset availBlend = availBlend + thisBlend>
					</cfif>
					
				<cfelse>
				
					<cfset invalidBlend = invalidBlend + 1>
				
				</cfif>
			
			</cfloop>
			
			<cfif availBlend LT 100 AND invalidBlend GT 0>
			
				<cfset defaultBlend = 100 - availBlend />
				<cfset defaultBlend = defaultBlend / invalidBlend />
				<cfset defaultBlend = NumberFormat(defaultBlend, "__.__") />
				
			</cfif>
			
			<cfloop list="#rawMaterialList#" delimiters="," index="currentRawMaterialId">
			
				<cfparam name="arguments.stFormData.Request_Raw_Material_ID_#currentReqProductId#_#currentRawMaterialId#" 	default="0">
				<cfparam name="arguments.stFormData.Mat_Blend_#currentReqProductId#_#currentRawMaterialId#" 	default="#defaultBlend#">
				<cfparam name="arguments.stFormData.Mat_YieldLoss_#currentReqProductId#_#currentRawMaterialId#" 	default="0">
				<cfparam name="arguments.stFormData.periodType" 	default="0">
				
				<cfset requestRawMaterialId = Evaluate("arguments.stFormData.Request_Raw_Material_ID_#currentReqProductId#_#currentRawMaterialId#")>
				<cfset blend = Evaluate("arguments.stFormData.Mat_Blend_#currentReqProductId#_#currentRawMaterialId#")>
				<cfset yieldLoss = Evaluate("arguments.stFormData.Mat_YieldLoss_#currentReqProductId#_#currentRawMaterialId#")>
				<cfset periodType = arguments.stFormData.periodType />
				
				<!---create RequestRawMaterial object--->
				<cfset requestRawMaterialObj = CreateObject("component", "components.futures_pricing.RequestRawMaterial") />
				
				<!---set values in RequestProduct object--->
				<cfset requestRawMaterialObj.setRequestRawMaterialId(requestRawMaterialId) />
				<cfset requestRawMaterialObj.setRawMaterialId(currentRawMaterialId) />
				<cfset requestRawMaterialObj.setBlend(blend) />
				<cfset requestRawMaterialObj.setYieldLoss(yieldLoss) />
				<cfset requestRawMaterialObj.setPeriodType(periodType) />				
				<cfset requestRawMaterialObj.setEffectiveVolume(requestProduct.getLbVolume()) />
				
				
				<!------ get source volume distribution from form ----->
				<cfparam name="arguments.stFormData.periodLength_#currentReqProductId#_#currentRawMaterialId#" 	default="0">
				<cfset volDistPeriodCount = Evaluate("arguments.stFormData.periodLength_#currentReqProductId#_#currentRawMaterialId#")>
				
				<cfset volumeMultiplier = 1 />
				<cfif volDistPeriodCount EQ 0>
				
					<!------ TODO: initial volume ----->
					<cfset volumeMultiplier = this.setProjectedProductVolDist(requestProduct, requestRawMaterialObj) />
				
				<cfelse>
				
					<cfloop index="volIndx" from="1" to="#volDistPeriodCount#">
					
						<cfparam name="arguments.stFormData.periodStartDate_#currentReqProductId#_#currentRawMaterialId#_#volIndx#" 	default="">
						<cfparam name="arguments.stFormData.periodEndDate_#currentReqProductId#_#currentRawMaterialId#_#volIndx#" 	default="">
						<cfparam name="arguments.stFormData.periodVolume_#currentReqProductId#_#currentRawMaterialId#_#volIndx#" 	default="">
						
						<cfset periodStartDate = Evaluate("arguments.stFormData.periodStartDate_#currentReqProductId#_#currentRawMaterialId#_#volIndx#")>
						<cfset periodEndDate = Evaluate("arguments.stFormData.periodEndDate_#currentReqProductId#_#currentRawMaterialId#_#volIndx#")>
						<cfset periodVolume = Evaluate("arguments.stFormData.periodVolume_#currentReqProductId#_#currentRawMaterialId#_#volIndx#")>
					
						<!---create DistributedVolume object--->
						<cfset distVolObj = CreateObject("component", "components.futures_pricing.DistributedVolume") />
						
						<!---populate the DistributedVolume object with data--->
						<cfset distVolObj.setStartDate(periodStartDate) />
						<cfset distVolObj.setEndDate(periodEndDate) />
						<cfset distVolObj.setVolume(periodVolume) />
						<cfset distVolObj.setOrder(volIndx) />
						
						<!---add the DistributedVolume object to the requestRawMaterial object--->
						<cfset requestRawMaterialObj.setSourceVolumeDist(distVolObj) />
						
					</cfloop>
				
				</cfif>
				
				<cfset this.setCurrentVolumeDistribution(requestRawMaterialObj, requestProduct.getProcessingStartDate(), requestProduct.getProcessingEndDate(), volumeMultiplier)>
				
				<!---add the RequestRawMaterial object to the RequestProduct object--->
				<cfset requestProduct.setRequestRawMaterial(requestRawMaterialObj) />
			
			</cfloop>

		</cfloop>

		<!------ <cfset rThisReqObj.setQProductData(rThisReqObj.qProductData) /> ----->
		
		<cfreturn this.request />

	</cffunction>
	
	<!---////////////////////////////////////////// setProcurementRawMaterialFromForm FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="setProcurementRawMaterialFromForm" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="stFormData" required="false" default="" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<!---initialize Request object--->
		<cfset this.get(id=arguments.stFormData.id, companyId=arguments.stFormData.companyId, userId=arguments.userId)>
		<cfset this.request.setProcurement(CreateObject("component", "components.futures_pricing.ProcurementManager").getProcurementRawMaterials(arguments.stFormData.id)) />
		
		<cfparam name="arguments.stFormData.RecommendedSuppliers" 	default="">
		<cfset this.request.getProcurement().setLRecommendedSupplierIds(Evaluate("arguments.stFormData.RecommendedSuppliers")) />
		
		<!------ load request raw materials for each product from form variables ----->
		<cfset rawMaterials = this.request.getProcurement().getRawMaterial() />
		<cfset rawMaterialCount = ArrayLen(rawMaterials) />
		<cfloop index="rawMatIndex" from="1" to="#rawMaterialCount#">
			
			<!--- get rawMaterial object --->
			<cfset rawMaterial = rawMaterials[rawMatIndex] />
			<cfset rawMatId = rawMaterial.getId()>
			<cfparam name="arguments.stFormData.supplier_#rawMatId#" 	default="" />
			<cfset supplierId = Evaluate("arguments.stFormData.supplier_#rawMatId#") />			
			<cfset rawMaterial.setRecommendedSupplierId(supplierId) />
			
		</cfloop>

		<cfreturn this.request />

	</cffunction>
	
	<cffunction name="saveRequestRawMaterialSupplier" output="false">
	
		<cfset id = this.request.getId() />
		
		<cfset rawMaterials = this.request.getProcurement().getRawMaterial() />
		<cfset rawMaterialCount = ArrayLen(rawMaterials) />
		<cfloop index="rawMatIndex" from="1" to="#rawMaterialCount#">
		
			<!--- get rawMaterial object --->
			<cfset rawMaterial = rawMaterials[rawMatIndex] />
			<cfset supplierId = rawMaterial.getRecommendedSupplierId() />
			<cfif isNumeric(supplierId) AND supplierId NEQ "">
				<cfset nullable = "false">
			<cfelse>
				<cfset nullable = "true">
			</cfif>
			
			<!------ see whether there is a record in FP_Procurement_Raw_Material ----->
			<cfquery name="qGetProcurementRawMaterial" datasource="#application.datasource#">
				SELECT	FP_Procurement_Raw_Material_ID
				FROM	FP_Procurement_Raw_Material
				WHERE
						Deleted = 0
						AND
						FP_Request_Master_ID = <cfqueryparam value="#id#" cfsqltype="CF_SQL_INTEGER">
						AND
						FP_Raw_Material_ID = <cfqueryparam value="#rawMaterial.getId()#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfif qGetProcurementRawMaterial.recordCount>
				<!------ update ----->
				
				<cfquery name="qUpdateProcurementRawMat" datasource="#application.datasource#">
					UPDATE	FP_Procurement_Raw_Material
					SET		FP_Supplier_ID = <cfqueryparam value="#supplierId#" cfsqltype="CF_SQL_INTEGER" null="#nullable#">
					WHERE
						Deleted = 0
						AND
						FP_Request_Master_ID = <cfqueryparam value="#id#" cfsqltype="CF_SQL_INTEGER">
						AND
						FP_Raw_Material_ID = <cfqueryparam value="#rawMaterial.getId()#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
			<cfelse>
				<!------ insert ----->
				
				<cfquery name="qInsertProcurementRawMat" datasource="#application.datasource#">
					INSERT INTO FP_Procurement_Raw_Material 
							(FP_Request_Master_ID, 
							FP_Raw_Material_ID, 
							FP_Supplier_ID)
					VALUES
							(<cfqueryparam value="#id#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#rawMaterial.getId()#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#supplierId#" cfsqltype="CF_SQL_INTEGER" null="#nullable#">)
				</cfquery>
				
			</cfif>
		
		</cfloop>
	
	</cffunction>
	
	
	<cffunction name="getRequestRawMaterials" output="false" returntype="query">
	
		<cfargument name="requestId" type="numeric" required="true" />
		
		<cfquery name="qGetRequestRawMaterials" datasource="#application.datasource#">
			SELECT	FP_Request_Raw_Material.FP_Request_Raw_Material_ID,
					FP_Request_Raw_Material.FP_Raw_Material_ID, FP_Product.FP_Product_ID,
					FP_Request_Raw_Material.Blend, FP_Request_Raw_Material.Yield_Loss
			FROM	FP_Product
					INNER JOIN FP_Request_Raw_Material
					ON
					FP_Request_Raw_Material.FP_Product_ID = FP_Product.FP_Product_ID
					AND
					FP_Request_Raw_Material.Deleted = 0
			WHERE
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
					AND
					FP_Product.Deleted = 0
		</cfquery>
		
		<cfreturn qGetRequestRawMaterials />
	
	</cffunction>
	
	<cffunction name="getProductRawMaterials" output="false" returntype="query">
	
		<cfargument name="requestProductId" type="numeric" required="true" />
		
		<cfquery name="qGetProductRawMaterials" datasource="#application.datasource#">
				SELECT	FP_Request_Raw_Material.FP_Request_Raw_Material_ID,
						FP_Request_Raw_Material.FP_Raw_Material_ID,
						FP_Request_Raw_Material.Blend, FP_Request_Raw_Material.Yield_Loss
				FROM	FP_Request_Raw_Material
				WHERE
						FP_Request_Raw_Material.FP_Product_ID = #requestProduct.getRequestProdId()#
						AND
						FP_Request_Raw_Material.Deleted = 0
			</cfquery>
		
		<cfreturn qGetProductRawMaterials />
	
	</cffunction>
	
	<cffunction name="getRequestRawMaterialVolume" output="false" returntype="query">
	
		<cfargument name="requestRawMatId" type="numeric" required="true" />
	
		<cfquery name="qGetRequestRawMaterialVolume" datasource="#application.datasource#">
			SELECT	Start_Date, End_Date, Volume, Interval_Order
			FROM	FP_Raw_Volume_Distribution
			WHERE
					FP_Raw_Volume_Distribution.FP_Request_Raw_Material_ID = #arguments.requestRawMatId#
					AND
					FP_Raw_Volume_Distribution.Deleted = 0
			ORDER BY Interval_Order
		</cfquery>
		
		<cfreturn qGetRequestRawMaterialVolume />
		
	</cffunction>
	
	<cffunction name="save" output="false">
		
		<cftransaction action="BEGIN">
		
			<cftry>
				<!------ <cfloop list="#this.request.getLFPProductIds()#" delimiters="," index="currentProductId"> ----->
				<cfset requestProductArray = this.request.getRequestProduct()>
				<cfset productCount = ArrayLen(requestProductArray)>
				<cfloop index="prodIndex" from="1" to="#productCount#">
				
					<!--- get RequestProduct object --->
					<cfset requestProduct = requestProductArray[prodIndex]>
					<cfset currentProductId = requestProduct.getRequestProdId()>
					
					<cfset productIdEscaped = currentProductId>
					
					<!------ Get Product level values ----->					
					<cfset processingPlant = requestProduct.getProcessingPlantName()>
					<cfset offset = requestProduct.getProcessingPeriodOffset()>
					<cfset preservationId = requestProduct.getPreservationId()>
					
					<!------ save Product level values ----->
					<cfquery name="qGetProductInfo" datasource="#application.datasource#">
						SELECT	FP_Product_ID
						FROM	FP_Mat_Req_Product
						WHERE
								FP_Product_ID = #currentProductId#
					</cfquery>
					
					<cfif qGetProductInfo.recordCount>
						<!------ update Product level values ----->
						<cfquery name="qUpdateProductInfo" datasource="#application.datasource#">
							UPDATE	FP_Mat_Req_Product
							SET		Processing_Plant_Name = <cfqueryparam value="#processingPlant#" cfsqltype="CF_SQL_VARCHAR">,
									Period_Offset = <cfqueryparam value="#offset#" cfsqltype="CF_SQL_NUMERIC">,
									FP_Preservation_ID = <cfqueryparam value="#preservationId#" cfsqltype="CF_SQL_NUMERIC">
							WHERE
									FP_Product_ID = <cfqueryparam value="#currentProductId#" cfsqltype="CF_SQL_NUMERIC">								
						</cfquery>
					<cfelse>
						<!------ insert Product level values ----->
						<cfquery name="qUpdateProductInfo" datasource="#application.datasource#">
							INSERT INTO FP_Mat_Req_Product
								(FP_Product_ID, Processing_Plant_Name, Period_Offset, FP_Preservation_ID)
							VALUES
								(
									<cfqueryparam value="#currentProductId#" cfsqltype="CF_SQL_NUMERIC">, 
									<cfqueryparam value="#processingPlant#" cfsqltype="CF_SQL_VARCHAR">, 
									<cfqueryparam value="#offset#" cfsqltype="CF_SQL_NUMERIC">, 
									<cfqueryparam value="#preservationId#" cfsqltype="CF_SQL_NUMERIC">
								)
						</cfquery>
					</cfif>
					
					
					<!------ delete raq material info ----->
					
					<!------ delete all volume distribution info ----->
					<cfquery name="qDeleteMatReqVolDist" datasource="#application.datasource#">
						UPDATE	FP_Raw_Volume_Distribution
						SET		Deleted = 1
						WHERE
								FP_Request_Raw_Material_ID IN
								(
								SELECT	FP_Request_Raw_Material_ID
								FROM	FP_Request_Raw_Material
								WHERE
										Deleted = 0
										AND FP_Product_ID = #currentProductId#
								)
					</cfquery>
					
					<!------ delete all raw material info ----->
					<cfquery name="qDeleteMatReq" datasource="#application.datasource#">
						UPDATE	FP_Request_Raw_Material
						SET		Deleted = 1
						WHERE
								FP_Product_ID = #currentProductId#
					</cfquery>
					
					<!------ save raq material info ----->
					<cfset requestRawMaterialsArray = requestProduct.getRequestRawMaterial()>
					<cfset requestRawMaterialsCount = ArrayLen(requestRawMaterialsArray)>
					
					<cfloop index="rawMatIndex" from="1" to="#requestRawMaterialsCount#">
					
						<cfset requestRawMaterial = requestRawMaterialsArray[rawMatIndex]>
			
						<cfset rawMaterialId = requestRawMaterial.getRawMaterialId()>
						
						<cfset blend = requestRawMaterial.getBlend()>
						<cfset yieldLoss = requestRawMaterial.getYieldLoss()>
						<cfset volPeriodType = requestRawMaterial.getPeriodType()>
						<!------ save raw material ----->
						
						<cfquery name="qInsertRawMat" datasource="#application.datasource#">
							SET NOCOUNT ON
							
							INSERT INTO FP_Request_Raw_Material
								(FP_Product_ID, FP_Raw_Material_ID, Blend, Yield_Loss)
							VALUES
								(#currentProductId#, #rawMaterialId#, '#blend#', '#yieldLoss#')
							
							SELECT FP_Request_Raw_Material_ID = @@IDENTITY
							SET NOCOUNT OFF
						</cfquery> 
						
						<cfset currentRequestRawMaterialId = qInsertRawMat.FP_Request_Raw_Material_ID>
						
						<cfset volDistArray = requestRawMaterial.getVolumeDist() />
						<cfset volDistArrayLen = ArrayLen(volDistArray)>
						<cfloop index="volDistIndex" from="1" to="#volDistArrayLen#">
							<cfset volDist = volDistArray[volDistIndex]>
							
							<cfset periodStartDate = volDist.getStartDate() />
							<cfset periodEndDate = volDist.getEndDate() />
							<cfset periodVolume = volDist.getVolume() />
									
							<!------ save volume distribution info for each raw material ----->
							<cfquery name="qInsertRawMatVolume" datasource="#application.datasource#">
								INSERT INTO FP_Raw_Volume_Distribution
									(FP_Request_Raw_Material_ID, Interval_Order, Start_Date, End_Date, Volume)
								VALUES
									(#currentRequestRawMaterialId#, #volDistIndex#, #CreateODBCDate(periodStartDate)#, #CreateODBCDate(periodEndDate)#, '#periodVolume#')
							</cfquery>												
<!--- 							<cfquery name="qInsertRawMatVolume" datasource="#application.datasource#">
								INSERT INTO FP_Raw_Volume_Distribution
									(FP_Request_Raw_Material_ID, Interval_Order, Start_Date, End_Date, Volume, Period_Type)
								VALUES
									(#currentRequestRawMaterialId#, #volDistIndex#, #CreateODBCDate(periodStartDate)#, #CreateODBCDate(periodEndDate)#, '#periodVolume#', #volPeriodType#)
							</cfquery> --->
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
	
</cfcomponent>
