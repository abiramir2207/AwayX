<cfcomponent hint="Futures Pricing Request Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.RequestManager">
	
		<cfset this.settings = CreateObject("component", "components.futures_pricing.SettingsManager").get() />
		<cfreturn this />
		
	</cffunction>
	
	<!---//////////////////////////////////////////// GET FUNCTION ///////////////////////////////////////////////////////--->
	<cffunction name="get" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="pagePhase" required="false" default="" />
		<cfargument name="companyId" required="false" default="" />
		<cfargument name="userId" required="false" default="" />
		
		<cfset this.request = CreateObject("component", "components.futures_pricing.Request").init() />
		
		<!---set compnayId--->
		<cfset this.request.setCompanyId(arguments.companyId)>
		<!---set userId--->
		<cfset this.request.setUserId(arguments.userId)>
		
		<cfif arguments.id>
		
			<cfquery name="qGetRequest" datasource="#application.datasource#">
				SELECT	FP_Request_Master.FP_Request_Master_ID,
						FP_Request_Master.FP_Status_ID,
						FP_Request_Master.FP_Pricing_Status_ID,
						FP_Request_Master.FP_Request_Title,
						FP_Request_Master.FP_Request_Start_Date,
						FP_Request_Master.FP_Request_End_Date,
						FP_Request_Master.FP_Cust_Deadline_Date,
						FP_Request_Master.FP_Cust_Request,
						FP_Request_Master.Created_By,
						FP_Request_Master.Created_Date,
						FP_Request_Master.Period_Type,
						FP_Pricing_Status.FP_Pricing_Status_Desc,
						FP_Raw_Material_Quote.Good_Until_Date,
						FP_Request_Master.isExpired
				FROM	FP_Request_Master						
						LEFT JOIN FP_Pricing_Status
						ON
						FP_Pricing_Status.FP_Pricing_Status_ID = FP_Request_Master.FP_Pricing_Status_ID
						AND
						FP_Pricing_Status.Deleted = 0
						LEFT JOIN FP_Raw_Material_Quote
					ON
					FP_Raw_Material_Quote.Deleted = 0
					AND
					FP_Raw_Material_Quote.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					AND
					FP_Raw_Material_Quote.isSelected = 1
					AND
					FP_Raw_Material_Quote.Good_Until_Date <= 
					(
						SELECT 	MIN(Q.Good_Until_Date)
						FROM	FP_Raw_Material_Quote Q
						WHERE
								Q.Deleted = 0
								AND
								Q.isSelected = 1
								AND
								Q.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					)
					AND
					FP_Request_Master.FP_Pricing_Status_ID = 1
				WHERE
						FP_Request_Master.Deleted = 0
						AND FP_Request_Master.FP_Request_Master_ID = #arguments.id#
			</cfquery>
			
			<cfloop query="qGetRequest">
				
				<cfset this.request.setId(FP_Request_Master_ID)>
				<cfset this.request.setStatusId(FP_Status_ID)>
				<cfset this.request.setPricingStatusId(FP_Pricing_Status_ID)>								
				<cfset this.request.setPricingStatusDesc(FP_Pricing_Status_Desc)>
				<cfset this.request.setTitle(FP_Request_Title) />
				<cfset this.request.setStartDate(FP_Request_Start_Date) />
				<cfset this.request.setEndDate(FP_Request_End_Date) />
				<cfset this.request.setDeadLineDate(FP_Cust_Deadline_Date) />
				<cfset this.request.setGoodUntilDate(Good_Until_Date) />				
				<cfset this.request.setRequest(FP_Cust_Request) />
				<cfset this.request.setCreatedBy(Created_By) />
				<cfset this.request.setCreatedDate(Created_Date) />				
				<cfset this.request.setPeriodType(Period_Type) />
				<cfset this.request.setIsExpired(isExpired) />
				
			</cfloop>
			
			<cfquery name="qGetStatusAgeDate" datasource="#application.datasource#">
				SELECT	TOP 1 Created_Date
				FROM	FP_Request_Status_Log
				WHERE
						FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
						AND
						FP_Status_ID = <cfqueryparam value="#this.request.getStatusId()#" cfsqltype="CF_SQL_INTEGER">						
				ORDER BY Created_Date DESC
			</cfquery>
			
			<cfloop query="qGetStatusAgeDate">
				<cfset this.request.setStatusAgeDate(Created_Date) />
			</cfloop>
			
			<cfif NOT this.request.getIsExpired()>
				<!---get product data--->
				<cfquery name="qGetProdData" datasource="#application.datasource#">
					SELECT	FP_Product.FP_Product_ID,
							FP_Product.Product_ID,
							FP_Product.FP_New_Product_ID,
							FP_Product.Volume,
							FP_Product.UOM,
							FP_Product.Delivery_Type_ID,
							FP_Product.Final_Price,
							FP_Mat_Req_Product.Processing_Plant_Name,
							FP_Mat_Req_Product.Period_Offset,
							FP_Mat_Req_Product.FP_Preservation_ID
					FROM 	FP_Product
							LEFT JOIN FP_Mat_Req_Product
							ON
							FP_Mat_Req_Product.FP_Product_ID = FP_Product.FP_Product_ID
					WHERE	FP_Product.Deleted = 0
					AND 	FP_Product.FP_Request_Master_ID = #arguments.id#
				</cfquery>
				
				<!------ get the periods now, so that it can be reused later ----->
				<!------ <cfif qGetProdData.recordCount GT 0>
				
					<cfif arguments.pagePhase eq 1>
						<cfif isDate(this.request.getStartDate()) and  isDate(this.request.getEndDate())>
							<cfset prodVolDist = CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(this.request.getPeriodType(), this.request.getStartDate(), this.request.getEndDate(), this.request.getCompanyId())>
						</cfif>
					</cfif>
				
				</cfif> ----->
				
				<!---loop over product data and get distributed volume--->
				<cfloop query="qGetProdData">
					
					<!---create RequestProduct object--->
					<cfset requestProdObj = CreateObject("component", "components.futures_pricing.RequestProduct") />
				
					<!---set values in RequestProduct object--->
					<cfset requestProdObj.setRequestProdId(FP_Product_ID) />
					<cfset requestProdObj.setProdId(Product_ID) />
					<cfset requestProdObj.setNewProdId(FP_New_Product_ID) />
					<cfset requestProdObj.setVolume(Volume) />
					<cfset requestProdObj.setUom(UOM) />
					<cfset requestProdObj.setDeliveryTypeId(Delivery_Type_ID) />
					<cfset requestProdObj.setFinalPrice(Final_Price) />					
					<cfset requestProdObj.setProcessingPlantName(Processing_Plant_Name) />
					<cfset requestProdObj.setProcessingPeriodOffset(Period_Offset) />
					<cfset requestProdObj.setPreservationId(FP_Preservation_ID) />
					<cfset requestProdObj.setProcessingStartDate(this.request.getStartDate(), Period_Offset) />
					<cfset requestProdObj.setProcessingEndDate(this.request.getEndDate(), Period_Offset) />
					
					<!---get volume distribution if pagePhase is 1--->
					<cfif arguments.pagePhase eq 1>
					
						<cfset this.setVolumeDistFromDb(requestProdObj) />
						
						<cfif isDate(this.request.getStartDate()) and  isDate(this.request.getEndDate())>
							<cfset requestProdObj.setVolumeDistArray(CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(this.request.getPeriodType(), this.request.getStartDate(), this.request.getEndDate(), this.request.getCompanyId()))>
							<!------ the period is same for the whole request, so we don't have to create it over and over again ----->
							<!------ <cfset requestProdObj.setVolumeDistArray(Duplicate(prodVolDist))> ----->
						</cfif>
						
						<cfset requestProdObj.setVolumeDistArray(CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").translateVolumeDistribution(requestProdObj.getSourceVolumeDist(), requestProdObj.getVolumeDist()))>
						
					</cfif>
					
					<!---add the RequestProduct object to the Request object--->
					<cfset this.request.setRequestProduct(requestProdObj) />
				
				</cfloop>
					
					
				<!---set the request product id lists--->
				<cfset this.request.setLFPProductIds(ValueList(qGetProdData.FP_Product_ID)) />
				<cfset this.request.setLProductIds(ValueList(qGetProdData.Product_ID)) />
				<cfset this.request.setLNewProductIds(ValueList(qGetProdData.FP_New_Product_ID)) />	
				
				<!---set the request product query--->
				<cfset this.request.setQProductData(qGetProdData) />
				
				<!---get distributor list if pagePhase eq 1--->
				<cfif arguments.pagePhase eq 1 OR arguments.pagePhase EQ 0>
				
					<cfset useLakebaseForqGetDistList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_distributor")>
<cfif useLakebaseForqGetDistList>
	<cftry>
		<cfset qGetDistList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_distributor", {
				"deleted" = "eq.0",
				"fp_request_master_id" = "eq.#arguments.id#",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistList>
<cfquery name="qGetDistList" datasource="#application.datasource#">
						SELECT	Distributor_ID 
						FROM 	FP_Distributor
						WHERE	Deleted = 0
						AND 	FP_Request_Master_ID = #arguments.id#
					</cfquery>
</cfif>
					
					<!---set the list of distributor id's--->
					<cfset this.request.setLDistributorIds(ValueList(qGetDistList.Distributor_ID)) />
					
					<!---get operator list--->
					<cfset useLakebaseForqGetOpList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_operator")>
<cfif useLakebaseForqGetOpList>
	<cftry>
		<cfset qGetOpList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_operator", {
				"deleted" = "eq.0",
				"fp_request_master_id" = "eq.#arguments.id#",
				"select" = "operator_id"
			}), "operator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOpList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOpList>
<cfquery name="qGetOpList" datasource="#application.datasource#">
						SELECT	Operator_ID 
						FROM 	FP_Operator
						WHERE	Deleted = 0
						AND 	FP_Request_Master_ID = #arguments.id#
					</cfquery>
</cfif>
					
					<!---set the list of operator id's--->
					<cfset this.request.setLOperatorIds(ValueList(qGetOpList.Operator_ID)) />
				
				</cfif>
				
			</cfif>
			
		</cfif>
		
		<cfreturn this.request	/>
	
	</cffunction>
	
	<!---////////////////////////////////////////// SETFROMFORM FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="setFromForm" output="false" returntype="components.futures_pricing.Request">

		<cfargument name="stFormData" required="false" default="" />
		<cfargument name="userId" required="false" default="" />
		
		<!---initialize Request object--->
		<cfset this.request = this.get(id=0, companyId=arguments.stFormData.companyId, userId=arguments.userId) />
		<cfset this.request.setId(arguments.stFormData.id) />
		<cfset this.request.setStatusId(arguments.stFormData.statusId) />
		<cfset this.request.setTitle(arguments.stFormData.title) />
		<cfset this.request.setStartDate(arguments.stFormData.start_date) />
		<cfset this.request.setEndDate(arguments.stFormData.end_date) />
		<cfset this.request.setDeadLineDate(arguments.stFormData.Customer_Deadline) />
		<cfset this.request.setRequest(arguments.stFormData.Customer_Request) />
		<cfset this.request.setCreatedBy(arguments.stFormData.createdBy) />
		<cfset this.request.setUpdatedBy(arguments.stFormData.updatedBy) />
		<cfset this.request.setLProductIds(arguments.stFormData.Product_List) />
		<cfset this.request.setLNewProductIds(arguments.stFormData.New_Product_List) />
		<cfset this.request.setLDistributorIds(arguments.stFormData.Distributor_List) />
		<cfset this.request.setLOperatorIds(arguments.stFormData.Operator_List) />
		<cfset this.request.setForward(arguments.stFormData.forward) />
		
		<cfparam name="arguments.stFormData.periodType" default="#this.request.getPeriodType()#">
		
		<cfset this.request.setPeriodType(arguments.stFormData.periodType) />
		
		<cfset this.setProductVolume(arguments.stFormData, this.request.getLProductIds(), 1) />
		<cfset this.setProductVolume(arguments.stFormData, this.request.getLNewProductIds(), 2) />
		
		<cfreturn this.request />
		
	</cffunction>
	
	<cffunction name="setProductVolume" output="false">
		
		<cfargument name="stFormData" required="false" default="" />
		<cfargument name="prodList" required="false" default="" />
		<cfargument name="prodType" required="false" default="" hint="1 = Products from the item master table, 2 = new poducts" />
		
		<!------ <cfif ListLen(arguments.prodList, ",") GT 0>
			<cfset volDistPeriods = CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(this.request.getPeriodType(), this.request.getStartDate(), this.request.getEndDate(), this.request.getCompanyId())>
		</cfif> ----->
		
		<!---build a query object of product data and set it in the request object--->
		<!--- <cfloop index="prodIndx" list="#this.request.getLProductIds()#"> --->
		<cfloop index="prodIndx" list="#arguments.prodList#">
			
			<!---create RequestProduct object--->
			<cfset requestProdObj = CreateObject("component", "components.futures_pricing.RequestProduct") />
		
			<!---set the product id with no hyphens--->
			<cfset prodIdNoHyphen = request.app_general_functions.replaceHyphen(prodIndx) />
			<cfparam name="arguments.stFormData.Volume_#prodIdNoHyphen#" default="" />
			<cfparam name="arguments.stFormData.UOM_#prodIdNoHyphen#" default="" />
			<cfparam name="arguments.stFormData.deliveryTypeId_#prodIdNoHyphen#" default=0 />
			
			<!---set values in request product object--->
			<cfif arguments.prodType eq 1>
				<cfset requestProdObj.setProdId(prodIndx) />
			<cfelse>
				<cfset requestProdObj.setNewProdId(prodIndx) />
			</cfif>
	
			<cfset requestProdObj.setVolume(Evaluate("arguments.stFormData.VOLUME_#prodIdNoHyphen#")) />
			<cfset requestProdObj.setUom(Evaluate("arguments.stFormData.UOM_#prodIdNoHyphen#")) />
			<cfset requestProdObj.setDeliveryTypeId(Evaluate("arguments.stFormData.deliveryTypeId_#prodIdNoHyphen#")) />
			
			<cfset volDistLen = arguments.stFormData.volDistIndx />
			
			<!---loop for distributed volume--->
			<cfloop index="volDistIndx" from="1" to="#volDistLen#">
				
				<cfparam name="arguments.stFormData.periodStartDate_#prodIdNoHyphen#_#volDistIndx#" default="" />
				<cfparam name="arguments.stFormData.periodEndDate_#prodIdNoHyphen#_#volDistIndx#" default="" />
				<cfparam name="arguments.stFormData.periodVolume_#prodIdNoHyphen#_#volDistIndx#" default="" />
				<cfparam name="arguments.stFormData.lto_#prodIdNoHyphen#_#volDistIndx#" default=0 />

				
				<!---create DistributedVolume object--->
				<cfset distVolObj = CreateObject("component", "components.futures_pricing.DistributedVolume") />

				<!---populate DistributedVolume object with data--->
				<cfset distVolObj.setStartDate(Evaluate("arguments.stFormData.periodStartDate_#prodIdNoHyphen#_#volDistIndx#")) />
				<cfset distVolObj.setEndDate(Evaluate("arguments.stFormData.periodEndDate_#prodIdNoHyphen#_#volDistIndx#")) />
				<cfset distVolObj.setVolume(Evaluate("arguments.stFormData.periodVolume_#prodIdNoHyphen#_#volDistIndx#")) />
				<cfset distVolObj.setLimitedTimeOffer(Evaluate("arguments.stFormData.lto_#prodIdNoHyphen#_#volDistIndx#")) />
				<cfset distVolObj.setOrder(volDistIndx) />
				<cfset distVolObj.setProductID(prodIndx) />
				
				<!---set the DistributedVolume object in the RequestProduct object--->
				<cfset requestProdObj.setSourceVolumeDist(distVolObj) />

			</cfloop>
			
			<cfif isDate(this.request.getStartDate()) and isDate(this.request.getEndDate())>
			
				<cfset requestProdObj.setVolumeDistArray(CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(this.request.getPeriodType(), this.request.getStartDate(), this.request.getEndDate(), this.request.getCompanyId()))>
				<!------ the period is same for the whole request, so we don't have to create it over and over again ----->
				<!------ <cfset requestProdObj.setVolumeDistArray(Duplicate(volDistPeriods)) /> ----->
				
			</cfif>

			<cfset requestProdObj.setVolumeDistArray(CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").translateVolumeDistribution(requestProdObj.getSourceVolumeDist(), requestProdObj.getVolumeDist()))>
			
			<!---set the RequestProduct object in the Request object--->
			<cfset this.request.setRequestProduct(requestProdObj) />
		
		</cfloop>
		

	</cffunction>
	
	<cffunction name="setVolumeDistFromDb" output="false">
	
		<cfargument name="requestProdObj" required="true" type="components.futures_pricing.RequestProduct" />
		<cfargument name="offsetDays" required="false" type="numeric" default="0" />
		
		<cfset requestProdObj = arguments.requestProdObj />
		<cfset offsetDays = arguments.offsetDays * -1 />
		
		<cfset qGetVolDist = setVolumeDistributionInfo(requestProdObj.getRequestProdId()) />
		
		<!---TODO: Remove once we move into objects--->
		<cfset stVolDist = StructNew() />
		<cfset stVolDist.aVolDistPeriod = ArrayNew(1) />
		
		<!---set product id before going into the loop--->
		<cfset prodId = qGetProdData.Product_ID />
		
		<cfloop query="qGetVolDist">
			
			<!---TODO: Remove once we move into objects--->
			<cfset stVolDistPeriod = StructNew() />
			<cfset stVolDistPeriod.startDate = Start_Date />
			<cfset stVolDistPeriod.endDate = End_Date />
			<cfset stVolDistPeriod.volume = Volume />
			<cfset stVolDistPeriod.order = Interval_Order />
			<cfset stVolDistPeriod.productId = prodId />
			
			<!---TODO: Remove once we move into objects--->
			<cfset ArrayAppend(stVolDist.aVolDistPeriod, stVolDistPeriod) />
			
			<!---create DistributedVolume object--->
			<cfset distVolObj = CreateObject("component", "components.futures_pricing.DistributedVolume") />
			
			<!---populate the DistributedVolume object with data--->
			<cfset distVolObj.setStartDate(DateAdd("d", offsetDays, Start_Date)) />
			<cfset distVolObj.setEndDate(DateAdd("d", offsetDays, End_Date)) />
			<cfset distVolObj.setVolume(Volume) />
			<cfset distVolObj.setOrder(Interval_Order) />
			<cfset distVolObj.setProductID(prodId) />
			<cfset distVolObj.setLimitedTimeOffer(Limited_Time_Offer) />
			
			<!---add the DistributedVolume object to the RequestProduct object--->
			<cfset requestProdObj.setSourceVolumeDist(distVolObj) />
			
		</cfloop>
	
	</cffunction>
	

	
	<!---////////////////////////////////////////// SAVEWIP FUNCTION /////////////////////////////////////////////////////--->
	<cffunction name="saveWIP" output="false">
	
		<cfargument name="stData" required="false" default="" type="components.futures_pricing.Request"/>
		
		<cftransaction>
		
			<!---/////////////////////////////// UPDATE ///////////////////////////////////--->
			<cfif arguments.stData.getId()>
			
				<!---UPDATE MASTER--->
				<cfquery name="qRequestInsert" datasource="#application.datasource#">
		
					UPDATE 	FP_Request_Master
					SET		FP_Request_Title = <cfqueryparam value="#arguments.stData.getTitle()#" cfsqltype="CF_SQL_VARCHAR">, 
							FP_Request_Start_Date =  <cfqueryparam value="#arguments.stData.getStartDate()#" cfsqltype="CF_SQL_DATE">, 
							FP_Request_End_Date = <cfqueryparam value="#arguments.stData.getEndDate()#" cfsqltype="CF_SQL_DATE">, 
							FP_Cust_Deadline_Date = <cfqueryparam value="#arguments.stData.getDeadLineDate()#" cfsqltype="CF_SQL_DATE">, 
							FP_Cust_Request = <cfqueryparam value="#arguments.stData.getRequest()#" cfsqltype="CF_SQL_LONGVARCHAR">,
							Updated_By = <cfqueryparam value="#arguments.stData.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							Period_Type = <cfqueryparam value="#arguments.stData.getPeriodType()#" cfsqltype="CF_SQL_INTEGER" />,
							Updated_Date = getDate()
					WHERE 	FP_Request_Master_ID = #arguments.stData.getId()#
											
				</cfquery>
					
			<!---/////////////////////////////// INSERT ///////////////////////////////////--->
			<cfelse>
				
				<!---insert into master--->
				<cfquery name="qRequestInsert" datasource="#application.datasource#">
		
					SET NOCOUNT ON
					
					INSERT INTO FP_Request_Master
						(
							FP_Request_Title, 
							FP_Request_Start_Date, 
							FP_Request_End_Date, 
							FP_Cust_Deadline_Date, 
							FP_Cust_Request, 
							Created_By, 
							Period_Type
						)
					VALUES
						(
							<cfqueryparam value="#arguments.stData.getTitle()#" cfsqltype="CF_SQL_VARCHAR">, 
							<cfqueryparam value="#arguments.stData.getStartDate()#" cfsqltype="CF_SQL_DATE">, 
							<cfqueryparam value="#arguments.stData.getEndDate()#" cfsqltype="CF_SQL_DATE">, 
							<cfqueryparam value="#arguments.stData.getDeadLineDate()#" cfsqltype="CF_SQL_DATE">, 
							<cfqueryparam value="#arguments.stData.getRequest()#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#arguments.stData.getCreatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#arguments.stData.getPeriodType()#" cfsqltype="CF_SQL_INTEGER" />
						)
						
					SELECT FP_Request_Master_ID = @@IDENTITY
					SET NOCOUNT OFF
											
				</cfquery>
				
				<cfset arguments.stData.setId(qRequestInsert.FP_Request_Master_ID) />
				
				<cfset this.addToStatusChangeLog(1, arguments.stData.getCreatedBy()) />
								
			</cfif>
	
			<!---set volume distribution deleted to 1  before inserting--->
			<cfquery datasource="#application.datasource#">
				UPDATE	FP_Volume_Distribution
				SET		Deleted = 1
				WHERE	FP_Product_ID 
							IN 
							(
								SELECT 	FP_Product_ID
								FROM	FP_Product
								WHERE	Deleted = 0
								AND 	FP_Request_Master_ID = #arguments.stData.getId()#
							)
			</cfquery>
				
			<!---set products deleted to 1  before inserting--->
			<cfquery datasource="#application.datasource#">
				UPDATE	FP_Product
				SET		Deleted = 1
				WHERE	FP_Request_Master_ID = #arguments.stData.getId()#
			</cfquery>
			
			<!---set product counter --->
			<cfset prodCount = 1 />
				
			<!---/////////////// INSERT PRODUCTS //////////////////--->
			<!--- <cfloop index="indx" list="#arguments.stData.getLProductIds()#"> --->
			<cfloop index="prodIndx" from="1" to="#ArrayLen(arguments.stData.requestProduct)#">
				
				
				<!---set prodId and newProdId to be null in queryparam tag--->
				<cfset nullProdId = "yes" />
				<cfset nullNewProdId = "yes" />
				
				<!---set whether prodId and newProdId should not be null in queryparam tag--->
				<cfif Len(arguments.stData.requestProduct[prodIndx].getProdId())>
					<cfset nullProdId = "no" />
				</cfif>
				<cfif Len(arguments.stData.requestProduct[prodIndx].getNewProdId())>
					<cfset nullNewProdId = "no" />
				</cfif>
				
				<!---insert into fp_product--->
				<cfquery name="qInsertProduct" datasource="#application.datasource#">
				
					SET NOCOUNT ON
					
					INSERT INTO FP_Product
						(FP_Request_Master_ID, Product_ID, FP_New_Product_ID, Volume, UOM, Delivery_Type_ID)
					VALUES
						(
							<cfqueryparam value="#arguments.stData.getId()#" cfsqltype="CF_SQL_NUMERIC">, 
							<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].getProdId()#" cfsqltype="CF_SQL_VARCHAR" null="#nullProdId#">,
							<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].getNewProdId()#" cfsqltype="CF_SQL_NUMERIC" null="#nullNewProdId#">, 
							<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].getVolume()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].getUom()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].getDeliveryTypeId()#" cfsqltype="CF_SQL_NUMERIC">
						)
						
					SELECT FP_Product_ID = @@IDENTITY
					SET NOCOUNT OFF

				</cfquery>
	
				<cfset arguments.stData.requestProduct[prodIndx].setRequestProdId(qInsertProduct.FP_Product_ID) />
				
				<!---insert for each volume distribution--->
				<cfloop index="n" from="1" to="#ArrayLen(arguments.stData.requestProduct[prodCount].volumeDist)#">

					<cfquery name="qInsertVolDist" datasource="#application.datasource#">
						INSERT INTO FP_Volume_Distribution
							(FP_Product_ID, Start_Date, End_Date, Volume, Interval_Order, Limited_Time_Offer)
						VALUES
							(
								<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].getRequestProdId()#" cfsqltype="CF_SQL_NUMERIC">,
								<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].volumeDist[n].getStartDate()#" cfsqltype="CF_SQL_DATE">, 
								<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].volumeDist[n].getEndDate()#" cfsqltype="CF_SQL_DATE">,
								<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].volumeDist[n].getVolume()#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].volumeDist[n].getOrder()#" cfsqltype="CF_SQL_NUMERIC">,
								<cfqueryparam value="#arguments.stData.requestProduct[prodIndx].volumeDist[n].getLimitedTimeOffer()#" cfsqltype="CF_SQL_BIT">
							)
					</cfquery>
			
				</cfloop>
			
			</cfloop>
		
			<!---set distributors deleted to 0  before inserting--->
			<cfquery datasource="#application.datasource#">
				UPDATE	FP_Distributor
				SET		Deleted = 1
				WHERE	FP_Request_Master_ID = #arguments.stData.getId()#
			</cfquery>
			
			<!--- ////////////// INSERT DISTRIBUTORS //////////////--->
			<cfloop index="distIndx" list="#arguments.stData.getLDistributorIds()#">
	
				<!---insert into fp_distributor--->
				<cfquery datasource="#application.datasource#">
					INSERT INTO FP_Distributor
						(FP_Request_Master_ID, Distributor_ID)
					VALUES
						(#arguments.stData.getId()#, '#distIndx#')
				</cfquery>
			
			</cfloop>
			
			<!---set operators deleted to 0  before inserting--->
			<cfquery datasource="#application.datasource#">
				UPDATE	FP_Operator
				SET		Deleted = 1
				WHERE	FP_Request_Master_ID = #arguments.stData.getId()#
			</cfquery>
			
			<!--- ////////////// INSERT OPERATORS //////////////--->
			<cfloop index="opIndx" list="#arguments.stData.getLOperatorIds()#">
	
				<!---insert into FP_Operator--->
				<cfquery datasource="#application.datasource#">
					INSERT INTO FP_Operator
						(FP_Request_Master_ID, Operator_ID)
					VALUES
						(#arguments.stData.getId()#, #opIndx#)
				</cfquery>
			
			</cfloop>
	
		</cftransaction>
	
		<!------ <cfif arguments.stData.getForward()>
			<cfset this.saveForward(arguments.stData.getId(), IncrementValue(arguments.stData.getStatusId())) />
		</cfif> ----->

	</cffunction>
	
	<cffunction name="saveForward" output="false">
	
		<cfargument name="reqId" type="numeric" required="true" />
		<cfargument name="statusId" type="numeric" required="true" />
		<cfargument name="accessStructure" type="struct" required="true" />
		
		<cfif arguments.statusId EQ 5>
			
			<cfset this.updateProductPrice(arguments.reqId)>
			
		</cfif>	
		
		 <cfset this.changeStatus(statusId, accessStructure) />
		
	</cffunction>
	
	<cffunction name="search" output="false" returntype="query">
	
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		
		<cfset this.search = arguments.search />
		
		<!------ find out the sort order ----->
		<cfparam name="this.search.sortBy" 	default="title">
		<cfparam name="this.search.sortOrder" 	default="ASC">
		<cfset this.search.sortBy = LCase(this.search.sortBy)>
		<cfset this.search.sortOrder = LCase(this.search.sortOrder)>
		
		<cfset sql_Sort_By="FP_Request_Title">
		<cfswitch expression="#this.search.sortBy#">
			<cfcase value="title">
				<cfset sql_Sort_By="FP_Request_Title">
			</cfcase>
			<cfcase value="sd">
				<cfset sql_Sort_By="FP_Request_Start_Date">
			</cfcase>
			<cfcase value="ed">
				<cfset sql_Sort_By="FP_Request_End_Date">
			</cfcase>
			<cfcase value="cust_deadline">
				<cfset sql_Sort_By="FP_Cust_Deadline_Date">
			</cfcase>
			<cfcase value="status">
				<cfset sql_Sort_By="FP_Request_Master.FP_Status_ID">
			</cfcase>
			<cfcase value="good_until_date">
				<cfset sql_Sort_By="FP_Raw_Material_Quote.Good_Until_Date">
			</cfcase>
			<cfcase value="created_by">
				<cfset sql_Sort_By="_Users.Name_First">
			</cfcase>			
		</cfswitch>
		
		<cfif this.search.sortOrder EQ "desc">
			<cfset sql_Sort_By="#sql_Sort_By# DESC">
		<cfelse>
			<cfset sql_Sort_By="#sql_Sort_By# ASC">
		</cfif>
		<cfif Super.variableExist("this.search.restrictAccessUserId", "")>			
			<cfset lPositionsBelow = this.getLPositionsBelowMe(this.search.restrictAccessUserId) />
		</cfif>
		
		<cfquery name="qGetRequests" datasource="#application.datasource#">
			SELECT	DISTINCT FP_Request_Master.FP_Request_Master_ID, FP_Request_Master.FP_Request_Title,
					FP_Request_Master.FP_Request_Start_Date, FP_Request_Master.FP_Request_End_Date,
					FP_Request_Master.FP_Cust_Deadline_Date,
					FP_Request_Master.FP_Status_ID, FP_Status.FP_Status_Desc,
					FP_Request_Master.isExpired,
					FP_Raw_Material_Quote.Good_Until_Date,
					_Users.Name_First + ' ' + _Users.Name_Last AS Created_By_User_Name
					<cfif Super.variableExist("this.search.getReminderCount", "")>
					,
					(
						SELECT	Count(FP_Reminder.FP_Reminder_ID)
						FROM	FP_Reminder
						WHERE
								FP_Reminder.Deleted = 0
								AND	
								DATEDiff(d, FP_Reminder.Reminder_Date, GetDate()) = 0
								AND		
								FP_Reminder.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					) AS ReminderCount
					</cfif>
			FROM	FP_Request_Master
					INNER JOIN FP_Status
					ON
					FP_Status.FP_Status_ID = FP_Request_Master.FP_Status_ID
					AND
					FP_Status.Deleted = 0
					INNER JOIN _Users
					ON
					_Users.User_ID = FP_Request_Master.Created_By
					AND
					_Users.Deleted = 0
					LEFT JOIN FP_Raw_Material_Quote
					ON
					FP_Raw_Material_Quote.Deleted = 0
					AND
					FP_Raw_Material_Quote.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					AND
					FP_Raw_Material_Quote.isSelected = 1
					AND
					FP_Raw_Material_Quote.Good_Until_Date <= 
					(
						SELECT 	MIN(Q.Good_Until_Date)
						FROM	FP_Raw_Material_Quote Q
						WHERE
								Q.Deleted = 0
								AND
								Q.isSelected = 1
								AND
								Q.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					)
					AND
					FP_Request_Master.FP_Pricing_Status_ID = 1
			WHERE
					FP_Request_Master.Deleted = 0
					<cfif Super.variableExist("this.search.isExpired", "")>
					AND FP_Request_Master.isExpired = #this.search.isExpired#
					</cfif>
					<cfif Super.variableExist("this.search.title", "")>
					AND FP_Request_Master.FP_Request_Title LIKE '%#this.search.title#%'
					</cfif>
					<cfif Super.variableExist("this.search.custDeadline", "")>
						<cfif isDate(this.search.custDeadline)>
						AND DATEDIFF(d, #CreateODBCDate(this.search.custDeadline)#,  FP_Request_Master.FP_Cust_Deadline_Date) = 0
						</cfif>
					</cfif>					
					<cfif Super.variableExist("this.search.status", "")>
					AND FP_Request_Master.FP_Status_ID = #this.search.status#
					</cfif>
					<cfif Super.variableExist("this.search.restrictAccessUserId", "")>
						<cfif this.HQ>
							<!------ HQ can access all ----->
						<cfelse>
						AND
						(
						EXISTS(
							SELECT	_Users.User_ID
							FROM	FP_Request_User								
									INNER JOIN _Users
									ON
									_Users.User_ID = FP_Request_User.User_ID
									AND
									_Users.Deleted = 0
									INNER JOIN User_Position_Holders
									ON
									_Users.User_ID = User_Position_Holders.User_ID
									AND
									User_Position_Holders.Deleted = 0
									<cfif Len(lPositionsBelow) GT 0>
									AND
									User_Position_Holders.User_Positions_ID IN (#lPositionsBelow#)
									<cfelse>
									AND
									1=2
									</cfif>								
									AND
									(
										<cfif GP_Supplied_Position>
										User_Position_Holders.User_Positions_ID <> #GP_Supplied_Position#
										OR
										</cfif>
										User_Position_Holders.User_ID = '#this.search.restrictAccessUserId#'
									)								
							WHERE
									FP_Request_User.Deleted = 0
									AND
									FP_Request_User.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
						)					
						OR
						FP_Request_Master.Created_By = '#this.search.restrictAccessUserId#'
						)
						</cfif>
					</cfif>
			ORDER BY #sql_Sort_By#			
		</cfquery>
		
		<cfreturn qGetRequests />
		
	</cffunction>
	
	<cffunction name="requestStatusCount" output="false" returntype="query">
	
		<cfargument name="userId" type="string" required="false" default="" />
	
		<cfif arguments.userId NEQ "">
			<cfset lPositionsBelow = this.getLPositionsBelowMe(arguments.userId) />
		</cfif>
		
		<cfquery name="qGetStatusCount" datasource="#application.datasource#">
			SELECT	FP_Status.FP_Status_ID, FP_Status.FP_Status_Desc, Count(FP_Request_Master.FP_Request_Master_ID) AS Request_Count
			FROM	FP_Status
					LEFT JOIN FP_Request_Master
					ON
					FP_Status.FP_Status_ID = FP_Request_Master.FP_Status_ID
					AND
					FP_Request_Master.Deleted = 0
					AND 
					FP_Request_Master.isExpired = 0
					<cfif arguments.userId NEQ "">
						<cfif this.HQ>
							<!------ HQ can access all ----->
						<cfelse>
						AND
						(
						EXISTS(
							SELECT	_Users.User_ID
							FROM	FP_Request_User								
									INNER JOIN _Users
									ON
									_Users.User_ID = FP_Request_User.User_ID
									AND
									_Users.Deleted = 0
									INNER JOIN User_Position_Holders
									ON
									_Users.User_ID = User_Position_Holders.User_ID
									AND
									User_Position_Holders.Deleted = 0
									<cfif Len(lPositionsBelow) GT 0>
									AND
									User_Position_Holders.User_Positions_ID IN (#lPositionsBelow#)
									<cfelse>
									AND
									1=2
									</cfif>
									AND
									(
										<cfif GP_Supplied_Position>
										User_Position_Holders.User_Positions_ID <> #GP_Supplied_Position#
										OR
										</cfif>
										User_Position_Holders.User_ID = '#arguments.userId#'
									)
							WHERE
									FP_Request_User.Deleted = 0
									AND
									FP_Request_User.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
							)					
							OR
							FP_Request_Master.Created_By = '#arguments.userId#'						
						)
						</cfif>
					</cfif>
			WHERE
					FP_Status.Deleted = 0					
			GROUP BY FP_Status.FP_Status_ID, FP_Status.FP_Status_Desc
			ORDER BY FP_Status.FP_Status_ID
		</cfquery>
		
		<cfreturn qGetStatusCount />
		
	</cffunction>
	
	<cffunction name="emailRequests" output="false" returntype="query">
	
		<cfargument name="NotifyCustDeadlineLeadTime" type="numeric" required="true" />
		<cfargument name="NotifyOfferGoodUntilLeadTime" type="numeric" required="true" />		
		
		<cfquery name="qGetEmailRequests" datasource="#application.datasource#">
			SELECT	DISTINCT FP_Request_Master.FP_Request_Master_ID, FP_Request_Master.FP_Status_ID, FP_Request_Master.FP_Request_Title, FP_Request_Master.FP_Request_Start_Date, FP_Request_Master.FP_Request_End_Date, FP_Request_Master.FP_Cust_Deadline_Date,
					DATEDIFF(d, GetDate(), FP_Request_Master.FP_Cust_Deadline_Date) AS CustDeadlineDaysLeft, CustDeadlineMailSent,
					DATEDIFF(d, GetDate(), FP_Raw_Material_Quote.Good_Until_Date) AS GoodUntilDaysLeft, OfferGoodUntilMailSent, FP_Raw_Material_Quote.Good_Until_Date
			FROM	FP_Request_Master
					LEFT JOIN FP_Raw_Material_Quote
					ON
					FP_Raw_Material_Quote.Deleted = 0
					AND
					FP_Raw_Material_Quote.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					AND
					FP_Raw_Material_Quote.isSelected = 1
					AND
					FP_Raw_Material_Quote.Good_Until_Date <= 
					(
						SELECT 	MIN(Q.Good_Until_Date)
						FROM	FP_Raw_Material_Quote Q
						WHERE
								Q.Deleted = 0
								AND
								Q.isSelected = 1
								AND
								Q.FP_Request_Master_ID = FP_Request_Master.FP_Request_Master_ID
					)
					AND
					FP_Request_Master.FP_Pricing_Status_ID = 1<!------ open ----->
			WHERE
					FP_Request_Master.Deleted = 0
					AND
					FP_Request_Master.isExpired = 0
					AND					
					(	
						<!------ FP_Cust_Deadline_Date is arriving or is over ----->		 
						(
							DATEDIFF(d, GetDate(), FP_Request_Master.FP_Cust_Deadline_Date) <= #arguments.NotifyCustDeadlineLeadTime#
							/*AND 
							CustDeadlineMailSent = 0*/
						)
						OR
						<!------ Good_Until_Date is arriving or is over ----->					 
						(
							DATEDIFF(d, GetDate(), FP_Raw_Material_Quote.Good_Until_Date) <= #arguments.NotifyOfferGoodUntilLeadTime#						
							/*
							AND 
							OfferGoodUntilMailSent = 0
							*/
						)
					)
					<!------ first offer good until date is arriving ----->
					<!------ should fill in the code for this section, once phase 3 code is complete ----->
		</cfquery>
		
		<cfreturn qGetEmailRequests />
		
	</cffunction>
	
	<cffunction name="setMailSent" output="false">
	
		<cfargument name="requestId" type="numeric" required="true" />
		<cfargument name="setCustDeadline" type="numeric" required="true" />
		<cfargument name="setGoodUntilDate" type="numeric" required="true" />
		
		<cfquery name="qGetEmailRequests" datasource="#application.datasource#">
			UPDATE	FP_Request_Master
			SET		CustDeadlineMailSent = <cfif arguments.setCustDeadline>1<cfelse>CustDeadlineMailSent</cfif>,
					OfferGoodUntilMailSent = <cfif arguments.setGoodUntilDate>1<cfelse>OfferGoodUntilMailSent</cfif>
			WHERE
					FP_Request_Master.Deleted = 0
					AND FP_Request_Master_ID = #arguments.requestId#
		</cfquery>
		
	</cffunction>
	
	<cffunction name="setExpired" output="false">
	
		<cfargument name="requestId" type="numeric" required="true" />
		<cfargument name="expiryBit" type="numeric" required="true" />		
		
		<cfquery name="qGetEmailRequests" datasource="#application.datasource#">
			UPDATE	FP_Request_Master
			SET		isExpired =  <cfqueryparam value="#arguments.expiryBit#" cfsqltype="CF_SQL_INTEGER">
			WHERE
					FP_Request_Master.Deleted = 0
					AND
					FP_Request_Master.isExpired = 0
					AND FP_Request_Master_ID = <cfqueryparam value="#arguments.requestId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="changeStatusEmail" output="false">
	
		<cfargument name="oldStatusDesc" type="string" required="true" />
		<cfargument name="userEmail" type="string" required="true" />
		<cfargument name="userName" type="string" required="true" />
		
		<cfset emailUserIds = this.getRequestUserEmails(this.request.getId(), this.request.getStatusId()) />
		
		<cfif Len(emailUserIds) GT 0>
			<cfmail 
					from="#arguments.userEmail#"
					to="#emailUserIds#"
					subject="Futures Pricing Request '#this.request.getTitle()#'"
					type="HTML">
			Futures Pricing Request '<B>#this.request.getTitle()#</B>' - status has been changed to <B>#this.request.getStatusDesc()#</B> from '#arguments.oldStatusDesc#'
			 by <B>#arguments.userName#</B>
			</cfmail>
		</cfif>
		
	</cffunction>
	
	<cffunction name="changeStatus" output="false">
	
		<cfargument name="newStatusId" type="numeric" required="true" />
		<cfargument name="accessStructure" type="struct" required="true" />
		<cfargument name="expiredBit" type="string" required="false" default="" />
		
		
		<cfset statusId = this.request.getStatusId() />
		<cftransaction>
		
			<cftry>
			
				<cfif arguments.newStatusId LT statusId>
				
					<cfloop index="thisPhase" from="#statusId#" to="#Evaluate(arguments.newStatusId + 1)#" step="-1">
					
						<cfset this.deletePhase(thisPhase) />
						<cfset this.deleteGroupUser(thisPhase) />
					
					</cfloop>
					
				</cfif>				
				
				<cfset oldStatusDesc = this.request.getStatusDesc() />
				
				<!------ change status ----->
				<cfquery name="qChnageStatus" datasource="#application.datasource#">
				
					UPDATE	FP_Request_Master
					SET		FP_Status_ID = <cfqueryparam value="#arguments.newStatusId#" cfsqltype="CF_SQL_INTEGER">
							<cfif arguments.expiredBit NEQ "" AND isNumeric(arguments.expiredBit)>
								, isExpired = <cfqueryparam value="#arguments.expiredBit#" cfsqltype="CF_SQL_INTEGER">
							</cfif>
					WHERE
							FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<cfif arguments.newStatusId NEQ statusId>
				
					<cfset this.request.setStatusId(arguments.newStatusId) />
					
					<!------ Log status change (time and user) ----->
					<cfset this.addToStatusChangeLog(arguments.newStatusId, arguments.accessStructure.User_ID) />
					
					<!------ send mail ----->
					<cfset this.changeStatusEmail(oldStatusDesc, request.AccessStructure.User_Email, "#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#") />
					
				</cfif>
				
				<cftransaction action="COMMIT">
				
				<cfcatch>
				
					<cftransaction action="ROLLBACK">
					<cfrethrow/>
				
				</cfcatch>
		
			</cftry>		
		
		</cftransaction>
		
		
	</cffunction>
	
	<cffunction name="getRequestUserEmails" output="false" returntype="string">
	
		<cfargument name="reqId" type="numeric" required="true" />
		<cfargument name="statusId" type="numeric" required="true" />
		
		<cfquery name="qGetEmailUsers" datasource="#application.datasource#">
			SELECT	DISTINCT _Users.User_Email
			FROM	FP_Request_Master
					INNER JOIN _Users
					ON
					FP_Request_Master.Created_By = _Users.User_ID
					AND
					_Users.Deleted = 0
			WHERE
					FP_Request_Master.FP_Request_Master_ID = <cfqueryparam value="#arguments.reqId#" cfsqltype="CF_SQL_INTEGER">
					AND
					FP_Request_Master.Deleted = 0
			UNION
			SELECT	DISTINCT _Users.User_Email
			FROM	FP_Request_User					
					INNER JOIN _Users
					ON
					_Users.Deleted = 0
					AND
					FP_Request_User.User_ID = _Users.User_ID
			WHERE
					FP_Request_Master_ID = <cfqueryparam value="#arguments.reqId#" cfsqltype="CF_SQL_INTEGER">
					AND
					FP_Request_User.Deleted = 0
					AND
					FP_Request_User.FP_User_Group_ID <= <cfqueryparam value="#arguments.statusId#" cfsqltype="CF_SQL_INTEGER">
			ORDER BY _Users.User_Email			
		</cfquery>
		
		<cfset emailUserIds = ValueList(qGetEmailUsers.User_Email, ";") />
		
		<cfreturn emailUserIds />
		
	</cffunction>
	
	<cffunction name="addToStatusChangeLog" output="false">
	
		<cfargument name="newStatusId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfquery name="qLogStatusChange" datasource="#application.datasource#">

			INSERT INTO FP_Request_Status_Log
				(
					FP_Request_Master_ID,
					FP_Status_ID,
					User_ID
				)
			VALUES
				(
					<cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.newStatusId#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				)
			
		</cfquery>
		
	</cffunction>
	
	<cffunction name="deleteGroupUser" output="false">
	
		<cfargument name="groupId" type="numeric" required="false" default="0" />
		
		<cfquery name="qDeleteUsers" datasource="#application.datasource#">
			UPDATE	FP_Request_User
			SET		FP_Request_User.Deleted = 1
			WHERE
					FP_Request_User.FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
					AND
					FP_Request_User.Deleted = 0
					AND
					FP_Request_User.FP_User_Group_ID = #arguments.groupId#						
		</cfquery>
		
	</cffunction>
	
	<cffunction name="saveGroupUser" output="false">
	
		<cfargument name="fpUserIds" type="string" required="true" />
		<cfargument name="groupId" type="numeric" required="false" default="0" />
		
		<cfif arguments.groupId>
			<cfset currentGroupId = arguments.groupId />
		<cfelse>
			<cfset currentGroupId = this.request.getStatusId() + 1 />			
		</cfif>		
		
		<cfif this.request.getId()>
		
			<!------ delete all the existing users for this request ----->
			<cfset this.deleteGroupUser(currentGroupId) />
		
			<!------ insert group users for this request ----->
			<cfloop list="#arguments.fpUserIds#" delimiters="," index="thisUserId">				
			
				<cfquery name="qInsertUser" datasource="#application.datasource#">
					INSERT INTO FP_Request_User
						(
							FP_Request_Master_ID, 
							FP_User_Group_ID, 
							User_ID
						)
					VALUES
						(
							<cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">, 
							<cfqueryparam value="#currentGroupId#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#thisUserId#" cfsqltype="CF_SQL_VARCHAR">
						)
				</cfquery>
			
			</cfloop>
			
		</cfif>
		
	</cffunction>
	
	<cffunction name="deletePhase" output="false">
	
		<cfargument name="phaseId" type="numeric" required="true" />
		
		<cfswitch expression="#arguments.phaseId#">
		
			<cfcase value="2">
				<cfset this.deleteProductRawMaterials() />
			</cfcase>
			
			<cfcase value="3">
				<cfset this.deleteProcurement() />
			</cfcase>
			
			<cfcase value="4">
				<cfset this.deletePricing() />
			</cfcase>
			
			<cfcase value="5">
				<cfset this.deletePriceInSales() />
			</cfcase>
		
		</cfswitch>		
		
	</cffunction>
	
	
	<cffunction name="deleteProductRawMaterials" output="false">
		
		<!--- set deleted to 1 for recommended supplier --->
		<cfquery name="qDeleteRecommendedSupplier" datasource="#application.datasource#">
			UPDATE 	FP_Procurement_Raw_Material
			SET		Deleted = 1
			WHERE	FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
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
							AND FP_Product_ID IN
							(
								SELECT	FP_Product.FP_Product_ID
								FROM	FP_Product
								WHERE
										FP_Product.Deleted = 0
										AND
										FP_Product.FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
							)
					)
		</cfquery>
		
		<!------ delete all raw material info ----->
		<cfquery name="qDeleteMatReq" datasource="#application.datasource#">
			UPDATE	FP_Request_Raw_Material
			SET		Deleted = 1
			WHERE
					FP_Product_ID IN
					(
						SELECT	FP_Product.FP_Product_ID
						FROM	FP_Product
						WHERE
								FP_Product.Deleted = 0
								AND
								FP_Product.FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
					)
		</cfquery>
		
		<!--- delete mat req product --->
		<cfquery name="qDeleteMatReqProduct" datasource="#application.datasource#">
			DELETE
			FROM 	FP_Mat_Req_Product
			WHERE	FP_Product_ID IN
					(
						SELECT	FP_Product.FP_Product_ID
						FROM	FP_Product
						WHERE
								FP_Product.Deleted = 0
								AND
								FP_Product.FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
					)
		</cfquery>
	
	</cffunction>
	
	<cffunction name="deleteProcurement" output="false">
		
		<!---set deleted to 1--->
		<cfquery name="qDelete" datasource="#application.datasource#">
			UPDATE 	FP_Raw_Material_Quote
			SET		Deleted = 1
			WHERE	FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	
	</cffunction>
	
	<cffunction name="deletePricing" output="false">
		
		<!------ delete all over heads for thie request ----->
		<cfquery name="qDeleteOverheads" datasource="#application.datasource#">
			UPDATE	FP_Price_Overhead
			SET		Deleted = 1
			WHERE
					FP_Price_Overhead.FP_Product_ID IN
					(
						SELECT	FP_Product.FP_Product_ID
						FROM	FP_Product
						WHERE
								FP_Product.Deleted = 0
								AND
								FP_Product.FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
					)
					AND
					FP_Price_Overhead.Deleted = 0
		</cfquery>
	
	</cffunction>
	
	<cffunction name="deletePriceInSales" output="false">
		
		<!------ update db ----->
		<cfquery name="qUpdatePricingStatus" datasource="#application.datasource#">
			UPDATE 	FP_Request_Master
			SET		FP_Pricing_Status_ID = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
			WHERE
					Deleted = 0
					AND
					FP_Request_Master_ID = <cfqueryparam value="#this.request.getId()#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	
	</cffunction>
	
	
	<cffunction name="getGroupsUsers" output="false">
		<cfargument name="groupId" type="numeric" required="true"/>
	
		<cfquery name="qGetGroupUsers" datasource="#application.datasource#">			
			SELECT	FP_Request_User.User_ID, FP_Request_User.FP_User_Group_ID
			FROM	FP_Request_User										
			WHERE
					FP_Request_User.Deleted = 0
					AND
					FP_Request_User.FP_Request_Master_ID = #this.request.getId()#
					AND
					FP_Request_User.FP_User_Group_ID = #arguments.groupId#
			ORDER BY FP_Request_User.FP_User_Group_ID		
		</cfquery>
		
		<cfreturn qGetGroupUsers />
		
	</cffunction>
	
	<cffunction name="getGroupsUserAccess" output="false">
	
		<!------ <CFSET positionId = CreateObject("component", "components.user.UserManager").getPositionId(this.request.getUserId()) />
		<cfset lPositionsAbove = CreateObject("component", "components.geography.position").getPositionsAbove(positionId) /> ----->
		<cfset lPositionsBelow = this.getLPositionsBelowMe(this.request.getUserId()) />
		<cfif this.HQ>
			<!------ HQ can access all ----->
			<cfset qGetStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
			<cfloop query="qGetStatus">
				<cfset this.request.setGroupUserAccess(1, FP_Status_ID) />
			</cfloop>
			
		<cfelse>
		
			<cfquery name="qGetGroupUsers" datasource="#application.datasource#">
				
				SELECT	_Users.User_ID, FP_Request_User.FP_User_Group_ID
				FROM	FP_Request_User
						INNER JOIN _Users
						ON
						_Users.User_ID = FP_Request_User.User_ID
						AND
						_Users.Deleted = 0
						INNER JOIN User_Position_Holders
						ON
						_Users.User_ID = User_Position_Holders.User_ID
						AND
						User_Position_Holders.Deleted = 0					
						<cfif Len(lPositionsBelow) GT 0>
						AND
						User_Position_Holders.User_Positions_ID IN (#lPositionsBelow#)
						<cfelse>
						AND
						1=2
						</cfif>					
						AND
						(
							<cfif GP_Supplied_Position>
							User_Position_Holders.User_Positions_ID <> #GP_Supplied_Position#
							OR
							</cfif>
							User_Position_Holders.User_ID = '#this.request.getUserId()#'
						)
				WHERE
						FP_Request_User.Deleted = 0
						AND
						FP_Request_User.FP_Request_Master_ID = #this.request.getId()#
				ORDER BY FP_Request_User.FP_User_Group_ID		
			</cfquery>
		
			<cfloop query="qGetGroupUsers">
			
				<cfset this.request.setGroupUserAccess(1, FP_User_Group_ID) />
				
			</cfloop>
		
			<cfif this.request.getCreatedBy() EQ this.request.getUserId()>
				<cfset this.request.setGroupUserAccess(1, 1) />
			</cfif>
			
		</cfif>
	
	</cffunction>
	
	<cffunction name="getLPositionsBelowMe" output="false">
	
		<cfargument name="userId" type="string" required="true" />
		
		<CFSET GP_Supplied_Position = CreateObject("component", "components.user.UserManager").getPositionId(arguments.userId)>
		<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
		<cfset lPositionsBelow = GP_Position_List_From_My_Position_Down />
		<cfparam name="Position_Type" 	default="">
		<cfset this.HQ = 0 />
		<cfif Position_Type EQ "GOD">
			<cfset this.HQ = 1 />
		</cfif>
		
		<cfreturn lPositionsBelow />
		
	</cffunction>
	
	<cffunction name="setVolumeDistributionInfo" output="false" returntype="query">
	
		<cfargument name="prodId" required="false" type="numeric" default="0" />
		<cfargument name="requestId" required="false" type="numeric" default="0" />
		
		<cfquery name="qGetVolDist" datasource="#application.datasource#">
			SELECT	FP_Volume_Distribution.Start_Date,
					FP_Volume_Distribution.End_Date,
					FP_Volume_Distribution.Volume,
					FP_Volume_Distribution.Interval_Order,
					FP_Volume_Distribution.Limited_Time_Offer,
					FP_Volume_Distribution.FP_Product_ID
			FROM 	FP_Volume_Distribution
					<cfif arguments.requestId>
					INNER JOIN FP_Product
					ON
					FP_Product.Deleted = 0
					AND
					FP_Product.FP_Request_Master_ID = #arguments.requestId#
					</cfif>
			WHERE	FP_Volume_Distribution.Deleted = 0
					<cfif arguments.prodId>
					AND 	FP_Volume_Distribution.FP_Product_ID = #arguments.prodId#
					</cfif>
			ORDER BY FP_Volume_Distribution.FP_Product_ID, FP_Volume_Distribution.Interval_Order
		</cfquery>
		
		<cfreturn qGetVolDist />
		
	</cffunction>
	
</cfcomponent>