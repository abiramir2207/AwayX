<cfcomponent>

	<cfset this.requestProdId			= 0 />
	<cfset this.prodId					= "" />
	<cfset this.newProdId				= "" />
	<cfset this.volume					= "" />
	<cfset this.uom						= 2 />
	<cfset this.desc					= "" />
	<cfset this.item					= "" />
	<cfset this.upc						= "" />
	<cfset this.deliveryTypeId			= 0 />
	<cfset this.deliveryTypeDesc		= "" />
	<cfset this.newProdName				= "" />
	<cfset this.netWeight				= 0 />
	<cfset this.finalPrice				= "" />
	<cfset this.volumeDist				= ArrayNew(1) />
	<cfset this.sourceVolumeDist		= ArrayNew(1) />
	<cfset this.processingPlantName		= "" />
	<cfset this.processingPeriodOffset	= "" />
	<cfset this.processingStartDate		= "" />	
	<cfset this.processingEndDate		= "" />	
	<cfset this.requestRawMaterial		= ArrayNew(1) />
	
	<!--- requestProdId setter --->
	<cffunction name="setRequestProdId" access="public" output="false">
		<cfargument name="requestProdId" required="true" />
		<cfset this.requestProdId = arguments.requestProdId />
	</cffunction>
	<!--- requestProdId getter --->
	<cffunction name="getRequestProdId" access="public" output="false">
		<cfreturn this.requestProdId />
	</cffunction>
	
	<!--- prodId setter --->
	<cffunction name="setProdId" access="public" output="false">
	
		<cfargument name="prodId" required="true" />
		<cfset this.prodId = arguments.prodId />
		
		<!---only get product info if we have a prodId--->
		<cfif Len(trim(arguments.prodId))>
		
			<!---get product detail info from database--->
			<cfquery name="qGetProductInfo" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 8, 0, 0)#">
				SELECT 	Item,
						UPC,
						Description,
						Net_Weight
				FROM 	BSA_Foodservice_Items_Master
				WHERE	BSA_Foodservice_Items_Master_ID = '#arguments.prodId#'
				AND		Deleted = 0
			</cfquery>
			
			<cfoutput query="qGetProductInfo">
				<cfset this.setDesc(Description) />
				<cfset this.setItem(Item) />
				<cfset this.setUpc(UPC) />
				<cfset this.setNetWeight(Net_Weight) />
			</cfoutput>
		
		</cfif>
		
	</cffunction>
	<!--- prodId getter --->
	<cffunction name="getProdId" access="public" output="false">
		<cfreturn this.prodId />
	</cffunction>
	
	<!--- newProdId setter --->
	<cffunction name="setNewProdId" access="public" output="false">
	
		<cfargument name="newProdId" required="false" default=0 />
		<cfset this.newProdId = arguments.newProdId />
		
		<!---if we have a number then get new product info--->
		<cfif IsNumeric(this.newProdId)>
		
			<!---get new product detail info from database--->
			<cfquery name="qNewProducts" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 8, 0, 0)#">
				SELECT 	Product_Desc
				FROM 	FP_New_Product
				WHERE	Deleted = 0
				AND		FP_New_Product_ID = #arguments.newProdId#
			</cfquery>
			
			<cfoutput query="qNewProducts">
				<cfset this.setDesc(Product_Desc) />
				<cfset this.setItem("(new product)") />
				<cfset this.setUpc("") />
				<cfset this.setNetWeight(0) />
			</cfoutput>
		
		</cfif>
	</cffunction>
	<!--- newProdId getter --->
	<cffunction name="getNewProdId" access="public" output="false">
		<cfreturn this.newProdId />
	</cffunction>
	
	<!--- volume setter --->
	<cffunction name="setVolume" access="public" output="false">
		<cfargument name="volume" required="true" />
		<cfset this.volume = arguments.volume />
	</cffunction>
	<!--- volume getter --->
	<cffunction name="getVolume" access="public" output="false">
		<cfreturn this.volume />
	</cffunction>
	<!--- lbVolume getter --->
	<cffunction name="getLbVolume" access="public" output="false">
		<cfset lbVolume = this.volume />
		<cfif this.uom EQ 1>
			<cfif isNumeric(this.volume) AND this.volume NEQ "" AND isNumeric(this.netWeight) AND this.netWeight NEQ "">
				<cfset lbVolume = this.volume * this.netWeight />
			</cfif>
		</cfif>
		<cfreturn lbVolume />
	</cffunction>
	
	<!--- uom setter --->
	<cffunction name="setUom" access="public" output="false">
		<cfargument name="uom" required="true" default="2" />
		<cfset this.uom = arguments.uom />
	</cffunction>
	<!--- uom getter --->
	<cffunction name="getUom" access="public" output="false">
		<cfreturn this.uom />
	</cffunction>
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" required="true" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc getter --->
	<cffunction name="getDesc" access="public" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- item setter --->
	<cffunction name="setItem" access="public" output="false">
		<cfargument name="item" required="true" />
		<cfset this.item = arguments.item />
	</cffunction>
	<!--- item getter --->
	<cffunction name="getItem" access="public" output="false">
		<cfreturn this.item />
	</cffunction>
	
	<!--- upc setter --->
	<cffunction name="setUpc" access="public" output="false">
		<cfargument name="upc" required="true" />
		<cfset this.upc = arguments.upc />
	</cffunction>
	<!--- upc getter --->
	<cffunction name="getUpc" access="public" output="false">
		<cfreturn this.upc />
	</cffunction>
	
	<!--- deliveryTypeId setter --->
	<cffunction name="setDeliveryTypeId" access="public" output="false">
		<cfargument name="deliveryTypeId" required="true" />
		<cfset this.deliveryTypeId = arguments.deliveryTypeId />
		
		<!---grab delivery type desc from database--->
		<cfif isNumeric(arguments.deliveryTypeId)>
			<cfquery name="qGetDelTypeDesc" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 8, 0, 0)#">
				SELECT 	Delivery_Type_Desc
				FROM 	Delivery_Type
				WHERE	Delivery_Type_ID = #arguments.deliveryTypeId#
				AND	Deleted = 0
			</cfquery>
			
			<cfset this.setDeliveryTypeDesc(qGetDelTypeDesc.Delivery_Type_Desc) />
		</cfif>
		
	</cffunction>
	<!--- deliveryTypeId getter --->
	<cffunction name="getDeliveryTypeId" access="public" output="false">
		<cfreturn this.deliveryTypeId />
	</cffunction>
	
	<!--- deliveryTypeDesc setter --->
	<cffunction name="setDeliveryTypeDesc" access="public" output="false">
		<cfargument name="deliveryTypeDesc" required="true" />
		<cfset this.deliveryTypeDesc = arguments.deliveryTypeDesc />
	</cffunction>
	<!--- deliveryTypeDesc getter --->
	<cffunction name="getDeliveryTypeDesc" access="public" output="false">
		<cfreturn this.deliveryTypeDesc />
	</cffunction>
	
	<!--- newProdName setter --->
	<cffunction name="setNewProdName" access="public" output="false">
		<cfargument name="newProdName" required="true" />
		<cfset this.newProdName = arguments.newProdName />
	</cffunction>
	<!--- newProdName getter --->
	<cffunction name="getNewProdName" access="public" output="false">
		<cfreturn this.newProdName />
	</cffunction>
	
	<!--- netWeight setter --->
	<cffunction name="setNetWeight" access="public" output="false">
		<cfargument name="netWeight" required="true" />
		<cfset this.netWeight = arguments.netWeight />
	</cffunction>
	<!--- netWeight getter --->
	<cffunction name="getNetWeight" access="public" output="false">
		<cfreturn this.netWeight />
	</cffunction>
	
	<!--- finalPrice setter --->
	<cffunction name="setFinalPrice" access="public" output="false">
		<cfargument name="finalPrice" required="true" />
		<cfset this.finalPrice = arguments.finalPrice />
	</cffunction>
	<!--- finalPrice getter --->
	<cffunction name="getFinalPrice" access="public" output="false">
		<cfargument name="decimalLen" type="numeric" required="false" default="3" />
		<cfreturn request.app_general_functions.roundDecimalPlaces(this.finalPrice, arguments.decimalLen) />
	</cffunction>
	
	<!--- sourceVolumeDist setter --->
	<cffunction name="setSourceVolumeDist" access="public" output="false">
		<cfargument name="sourceVolumeDist" required="true" default="" type="components.futures_pricing.DistributedVolume" />
		<cfset ArrayAppend(this.sourceVolumeDist, arguments.sourceVolumeDist) />
	</cffunction>
	<!--- sourceVolumeDist getter --->
	<cffunction name="getSourceVolumeDist" access="public" output="false">
		<cfreturn this.sourceVolumeDist />
	</cffunction>
	
	<!--- volumeDist setter --->
	<cffunction name="setVolumeDist" access="public" output="false">
		<cfargument name="volumeDist" required="true" default="" type="components.futures_pricing.DistributedVolume" />
		<cfset ArrayAppend(this.volumeDist, arguments.volumeDist) />
	</cffunction>
	
	<!--- volumeDist array setter --->
	<cffunction name="setVolumeDistArray" access="public" output="false">
		<cfargument name="volumeDistArray" required="true" default="" type="array" />
		<cfset this.volumeDist = arguments.volumeDistArray />
	</cffunction>
	
	<!--- volumeDist getter --->
	<cffunction name="getVolumeDist" access="public" output="false">
		<cfreturn this.volumeDist />
	</cffunction>
	
	<!--- processingPlantName setter --->
	<cffunction name="setProcessingPlantName" access="public" output="false">
		<cfargument name="processingPlantName" required="true" />
		<cfset this.processingPlantName = arguments.processingPlantName />
	</cffunction>
	<!--- processingPlantName getter --->
	<cffunction name="getProcessingPlantName" access="public" output="false">
		<cfreturn this.processingPlantName />
	</cffunction>
	
	<!--- processingPeriodOffset setter --->
	<cffunction name="setProcessingPeriodOffset" access="public" output="false">
		<cfargument name="processingPeriodOffset" required="true" />
		<cfset this.processingPeriodOffset = arguments.processingPeriodOffset />
		<cfif this.processingPeriodOffset eq "" OR NOT isNumeric(this.processingPeriodOffset)>
			<cfset this.processingPeriodOffset = 0 />
		</cfif>
	</cffunction>
	<!--- processingPeriodOffset getter --->
	<cffunction name="getProcessingPeriodOffset" access="public" output="false">
		<cfreturn this.processingPeriodOffset />
	</cffunction>
	
	<!--- processingStartDate setter --->
	<cffunction name="setProcessingStartDate" access="public" output="false">
		<cfargument name="processingStartDate" required="true" />
		<cfargument name="offset" required="true" />
		<cfset this.processingStartDate = getProcessingDate(arguments.processingStartDate, arguments.offset) />
	</cffunction>
	<!--- processingStartDate getter --->
	<cffunction name="getProcessingStartDate" access="public" output="false">
		<cfreturn this.processingStartDate />
	</cffunction>
	
	<!--- processingEndDate setter --->
	<cffunction name="setProcessingEndDate" access="public" output="false">
		<cfargument name="processingEndDate" required="true" />
		<cfargument name="offset" required="true" />
		<cfset this.processingEndDate = getProcessingDate(arguments.processingEndDate, arguments.offset) />
	</cffunction>
	<!--- processingEndDate getter --->
	<cffunction name="getProcessingEndDate" access="public" output="false">
		<cfreturn this.processingEndDate />
	</cffunction>
	
	<!--- processingDate setter --->
	<cffunction name="getProcessingDate" access="private" output="false">
		<cfargument name="processingDate" required="true" />
		<cfargument name="offset" required="true" />
		
		<cfset processingOffset = 0>
		<cfif isNumeric(arguments.offset) AND arguments.offset NEQ "">
			<cfset processingOffset = arguments.offset * -1>
		</cfif>
		
		<cfif isDate(arguments.processingDate)>
			<cfreturn DateAdd("d", processingOffset, arguments.processingDate) />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<!--- preservationId setter --->
	<cffunction name="setPreservationId" access="public" output="false">
		<cfargument name="preservationId" required="true" />
		<cfset this.preservationId = arguments.preservationId />
	</cffunction>
	<!--- preservationId getter --->
	<cffunction name="getPreservationId" access="public" output="false">
		<cfreturn this.preservationId />
	</cffunction>
	
	<!--- requestRawMaterial setter --->
	<cffunction name="setRequestRawMaterial" access="public" output="false">
		<cfargument name="requestRawMaterial" required="true" default="" type="components.futures_pricing.RequestRawMaterial" />
		<cfset ArrayAppend(this.requestRawMaterial, arguments.requestRawMaterial) />
	</cffunction>
	<!--- requestRawMaterial getter --->
	<cffunction name="getRequestRawMaterial" access="public" output="false">
		<cfreturn this.requestRawMaterial />
	</cffunction>
	
</cfcomponent>