<!---BidRequestProduct.cfc--->
<cfcomponent>

	<cfset this.id = 0 />
	<cfset this.programId = 0 />
	<cfset this.contractProductId = 0 />
	<cfset this.itemMasterId = "" />
	<cfset this.item = "" />
	<cfset this.upc = "" />
	<cfset this.desc = "" />
	<cfset this.defaultPrice = 0 />
	<cfset this.defaultLBPrice = 0 />
	<cfset this.defaultCSPrice = 0 />
	<cfset this.specId = 0 />
	<cfset this.previousWonBy = "" />
	<cfset this.previousWonPrice = 0.0000 />
	<cfset this.previousWonUom = 0 />
	<cfset this.allowance = 0.0000 />
	<cfset this.uom = 1 />
	<cfset this.productInventoryUOM = "" />
	<cfset this.net = 0.0000 />
	<cfset this.won = 1 />
	<cfset this.wonByID = "" />
	<cfset this.categoryID = "" />
	<cfset this.packageID = "" />
	<cfset this.wonBy = "" />
	<cfset this.wonPrice = 0.0000 />
	<cfset this.wonUom = 0 />
	<cfset this.qBrand = "" />
	<cfset this.typeCode = "" />
	<cfset this.typeCodeId = "" />
	<cfset this.PackSizeUOM = 0 />
	<cfset this.PackSize = 0 />
	<cfset this.WonDeliveryType = "" />
  <cfset this.categoryDesc = "" />
  <cfset this.packageDesc = "" />
  
	<cffunction name="init" output="false" returntype="components.programs.bid_request.BidRequestProduct">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" required="true" default="" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- programId setter --->
	<cffunction name="setProgramId" access="public" output="false">
		<cfargument name="programId" required="true" default="" />
		<cfset this.programId = arguments.programId />
	</cffunction>
	<!--- programId getter --->
	<cffunction name="getProgramId" access="public" output="false">
		<cfreturn this.programId />
	</cffunction>
	
	<!--- contractProductId setter --->
	<cffunction name="setContractProductId" access="public" output="false">
		<cfargument name="contractProductId" required="true" default="" />
		<cfset this.contractProductId = arguments.contractProductId />
	</cffunction>
	<!--- contractProductId getter --->
	<cffunction name="getContractProductId" access="public" output="false">
		<cfreturn this.contractProductId />
	</cffunction>
	
	<!--- itemMasterId setter --->
	<cffunction name="setItemMasterId" access="public" output="false">
		<cfargument name="itemMasterId" required="true" default="" />
		<cfset this.itemMasterId = arguments.itemMasterId />
	</cffunction>
	<!--- itemMasterId getter --->
	<cffunction name="getItemMasterId" access="public" output="false">
		<cfreturn this.itemMasterId />
	</cffunction>
	
	<!--- typeCodeId setter --->
	<cffunction name="setTypeCodeId" access="public" output="false">
		<cfargument name="typeCodeId" required="true" default="" />
		<cfset this.typeCodeId = arguments.typeCodeId />
	</cffunction>
	<!--- typeCodeId getter --->
	<cffunction name="getTypeCodeId" access="public" output="false">
		<cfreturn this.typeCodeId />
	</cffunction>
	
	<!--- Pack_Size setter --->
	<cffunction name="setPackSize" access="public" output="false">
		<cfargument name="PackSize" required="true" default="" />
		<cfset this.PackSize = arguments.PackSize />
	</cffunction>
	<!--- Pack_Size getter --->
	<cffunction name="getPackSize" access="public" output="false">
		<cfreturn this.PackSize />
	</cffunction>
	
	<!--- PackSizeUOM setter --->
	<cffunction name="setPackSizeUOM" access="public" output="false">
		<cfargument name="PackSizeUOM" required="true" default="" />
		<cfset this.PackSizeUOM = arguments.PackSizeUOM />
	</cffunction>
	<!--- PackSizeUOM getter --->
	<cffunction name="getPackSizeUOM" access="public" output="false">
		<cfreturn this.PackSizeUOM />
	</cffunction>
	
	<!--- item setter --->
	<cffunction name="setItem" access="public" output="false">
		<cfargument name="item" required="true" default="" />
		<cfset this.item = arguments.item />
	</cffunction>
	<!--- item getter --->
	<cffunction name="getItem" access="public" output="false">
		<cfreturn this.item />
	</cffunction>
	
	<!--- upc setter --->
	<cffunction name="setUpc" access="public" output="false">
		<cfargument name="upc" required="true" default="" />
		<cfset this.upc = arguments.upc />
	</cffunction>
	<!--- upc getter --->
	<cffunction name="getUpc" access="public" output="false">
		<cfreturn this.upc />
	</cffunction>
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" required="true" default="" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc getter --->
	<cffunction name="getDesc" access="public" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- productInventoryUOM setter --->
	<cffunction name="setProductInventoryUOM" access="public" output="false">
		<cfargument name="productInventoryUOM" required="true" default="" />
		<cfset this.productInventoryUOM = arguments.productInventoryUOM />
	</cffunction>
	<!--- productInventoryUOM getter --->
	<cffunction name="getProductInventoryUOM" access="public" output="false">
		<cfreturn this.productInventoryUOM />
	</cffunction>
	
	<!--- defaultPrice setter --->
	<cffunction name="setDefaultPrice" access="public" output="false">
		<cfargument name="defaultPrice" required="true" default="" />
		<cfset this.defaultPrice = arguments.defaultPrice />
	</cffunction>
	<!--- defaultPrice getter --->
	<cffunction name="getDefaultPrice" access="public" output="false">
	
		<!---default price depends on the uom--->
		<!---////CS////--->
		<cfif this.getUom() eq 1>
			<cfset this.defaultPrice = this.getDefaultCSPrice() />
		<!---///LB///--->
		<cfelse>
			<cfset this.defaultPrice = this.getDefaultLBPrice() />
		</cfif>
		
		<!---if the default price is empty then set it to 0--->
		<cfif trim(this.defaultPrice) eq "">
			<cfset this.defaultPrice = 0 />
		</cfif>
		
		<cfreturn this.defaultPrice />
		
	</cffunction>
	
	<!--- defaultLBPrice setter --->
	<cffunction name="setDefaultLBPrice" access="public" output="false">
		<cfargument name="defaultLBPrice" required="true" default="" />
		<cfset this.defaultLBPrice = arguments.defaultLBPrice />
	</cffunction>
	<!--- defaultLBPrice getter --->
	<cffunction name="getDefaultLBPrice" access="public" output="false">
		<cfreturn this.defaultLBPrice />
	</cffunction>
	
	<!--- defaultCSPrice setter --->
	<cffunction name="setDefaultCSPrice" access="public" output="false">
		<cfargument name="defaultCSPrice" required="true" default="" />
		<cfset this.defaultCSPrice = arguments.defaultCSPrice />
	</cffunction>
	<!--- defaultCSPrice getter --->
	<cffunction name="getDefaultCSPrice" access="public" output="false">
		<cfreturn this.defaultCSPrice />
	</cffunction>
	
	<!--- specId setter --->
	<cffunction name="setSpecId" access="public" output="false">
		<cfargument name="specId" required="true" default="" />
		<cfset this.specId = arguments.specId />
	</cffunction>
	<!--- specId getter --->
	<cffunction name="getSpecId" access="public" output="false">
		<cfreturn this.specId />
	</cffunction>
	
	<!--- previousWonBy setter --->
	<cffunction name="setLineID" access="public" output="false">
		<cfargument name="LineID" required="true" default="" />
		<cfset this.LineID = arguments.LineID />
	</cffunction>
	<!--- previousWonBy getter --->
	<cffunction name="getLineID" access="public" output="false">
		<cfreturn this.LineID />
	</cffunction>
	
	<!--- previousWonBy setter --->
	<cffunction name="setPreviousWonBy" access="public" output="false">
		<cfargument name="previousWonBy" required="true" default="" />
		<cfset this.previousWonBy = arguments.previousWonBy />
	</cffunction>
	<!--- previousWonBy getter --->
	<cffunction name="getPreviousWonBy" access="public" output="false">
		<cfreturn this.previousWonBy />
	</cffunction>
	
	<!--- previousWonPrice setter --->
	<cffunction name="setPreviousWonPrice" access="public" output="false">
		<cfargument name="previousWonPrice" required="true" default="" />
		<!---we need a value for previousWonPrice so set it to 0.00 if it's empty--->
		<cfif trim(arguments.previousWonPrice) eq "">
			<cfset arguments.previousWonPrice = 0.0000 />
		</cfif>
		<cfset this.previousWonPrice = arguments.previousWonPrice />
	</cffunction>
	<!--- previousWonPrice getter --->
	<cffunction name="getPreviousWonPrice" access="public" output="false">
		<cfreturn this.previousWonPrice />
	</cffunction>
	
	<!--- previousWonUom setter --->
	<cffunction name="setPreviousWonUom" access="public" output="false">
		<cfargument name="previousWonUom" required="true" default="" />
		<!---we need a value for previousWonUom so set it to 0 if it's empty--->
		<cfif trim(arguments.previousWonUom) eq "">
			<cfset arguments.previousWonUom = 0 />
		</cfif>
		<cfset this.previousWonUom = arguments.previousWonUom />
	</cffunction>
	<!--- previousWonUom getter --->
	<cffunction name="getPreviousWonUom" access="public" output="false">
		<cfreturn this.previousWonUom />
	</cffunction>
	
	<!--- allowance setter --->
	<cffunction name="setAllowance" access="public" output="false">
		<cfargument name="allowance" required="true" default="0.00" />
		<!---we need a value for allowance so set it to 0.00 if it's empty--->
		<cfif trim(arguments.allowance) eq "">
			<cfset arguments.allowance = 0.00 />
		</cfif>
		<cfset this.allowance = arguments.allowance />
	</cffunction>
	<!--- allowance getter --->
	<cffunction name="getAllowance" access="public" output="false">
		<!---if net is 0 then return 0 for allowance--->
		<cfif this.getNet() lte 0>
			<cfset this.allowance = 0.0000 />
		<cfelse>
			<cfset this.allowance = this.getDefaultPrice() - this.getNet() />
		</cfif>
		<cfreturn this.allowance />
	</cffunction>
	
	<!--- uom setter --->
	<cffunction name="setUom" access="public" output="false">
		<cfargument name="uom" required="true" default="" />
		<cfset this.uom = arguments.uom />
	</cffunction>
	<!--- uom getter --->
	<cffunction name="getUom" access="public" output="false">
		<cfreturn this.uom />
	</cffunction>
	
	<!--- net setter --->
	<cffunction name="setNet" access="public" output="false">
		<cfargument name="net" required="true" default="" />
		<!---we need a value for net price so set it to default price if it's empty--->
		<cfif trim(arguments.net) eq "" OR trim(arguments.net) eq 0>
			<cfset arguments.net = this.getDefaultPrice()>
			<!--- <cfset arguments.net = 0.00 /> --->
		</cfif>
		<cfset this.net = arguments.net />
	</cffunction>
	<!--- net getter --->
	<cffunction name="getNet" access="public" output="false">
		<cfreturn this.net />
	</cffunction>
	
	<!--- won setter --->
	<cffunction name="setWon" access="public" output="false">
		<cfargument name="won" required="true" default="" />
		<cfset this.won = arguments.won />
	</cffunction>
	<!--- won getter --->
	<cffunction name="getWon" access="public" output="false">
		<cfreturn this.won />
	</cffunction>
	
	<!--- wonBy setter --->
	<cffunction name="setWonBy" access="public" output="false">
		<cfargument name="wonBy" required="true" default="" />
		<cfset this.wonBy = arguments.wonBy />
	</cffunction>
	<!--- wonBy getter --->
	<cffunction name="getWonBy" access="public" output="false">
		<cfreturn this.wonBy />
	</cffunction>

<!--- 
	Dev Notes: 23635/Anand Rao/07-Jun-10
	Competitive Data, Forge changes
--->
  
<!--- wonByID setter --->
	<cffunction name="setWonByID" access="public" output="false">
		<cfargument name="wonByID" required="true" default="" />
		<cfset this.wonByID = arguments.wonByID />
	</cffunction>
	<!--- wonByID getter --->
	<cffunction name="getWonByID" access="public" output="false">
		<cfreturn this.wonByID />
	</cffunction>

<!--- categoryID setter --->
	<cffunction name="setCategoryID" access="public" output="false">
		<cfargument name="categoryID" required="true" default="" />
		<cfset this.categoryID = arguments.categoryID />
	</cffunction>
	<!--- categoryID getter --->
	<cffunction name="getCategoryID" access="public" output="false">
		<cfreturn this.categoryID />
	</cffunction>

  	
 	<cffunction name="setCategoryDesc" access="public" output="false">
		<cfargument name="categoryDesc" required="true" default="" />
		<cfset this.categoryDesc = arguments.categoryDesc />
	</cffunction>
	<!--- packageDesc getter --->
	<cffunction name="getCategoryDesc" access="public" output="false">
		<cfreturn this.categoryDesc />
	</cffunction>
  
  
<!--- packageID setter --->
	<cffunction name="setPackageID" access="public" output="false">
		<cfargument name="packageID" required="true" default="" />
		<cfset this.packageID = arguments.packageID />
	</cffunction>
	<!--- packageID getter --->
	<cffunction name="getPackageID" access="public" output="false">
		<cfreturn this.packageID />
	</cffunction>
  
 	<cffunction name="setPackageDesc" access="public" output="false">
		<cfargument name="packageDesc" required="true" default="" />
		<cfset this.packageDesc = arguments.packageDesc />
	</cffunction>
	<!--- packageDesc getter --->
	<cffunction name="getPackageDesc" access="public" output="false">
		<cfreturn this.packageDesc />
	</cffunction>  
  
  
	<!--- wonPrice setter --->
	<cffunction name="setWonPrice" access="public" output="false">
		<cfargument name="wonPrice" required="true" default="" />
		<!---we need a value for wonPrice so set it to 0.00 if it's empty--->
		<cfif trim(arguments.wonPrice) eq "">
			<cfset arguments.wonPrice = 0.00 />
		</cfif>
		<cfset this.wonPrice = arguments.wonPrice />
	</cffunction>
	<!--- wonPrice getter --->
	<cffunction name="getWonPrice" access="public" output="false">
		<cfreturn this.wonPrice />
	</cffunction>
	
	<!--- wonUom setter --->
	<cffunction name="setWonUom" access="public" output="false">
		<cfargument name="wonUom" required="true" default="" />
		<!---we need a value for wonUom so set it to 0 if it's empty--->
		<cfif trim(arguments.wonUom) eq "">
			<cfset arguments.wonUom = 0 />
		</cfif>
		<cfset this.wonUom = arguments.wonUom />
	</cffunction>
	<!--- wonUom getter --->
	<cffunction name="getWonUom" access="public" output="false">
		<cfreturn this.wonUom />
	</cffunction>

	<!--- wonDeliveryType setter --->
	<cffunction name="setWonDeliveryType" access="public" output="false">
		<cfargument name="wonDeliveryType" required="true" default="" />
		<cfset this.wonDeliveryType = arguments.wonDeliveryType />
	</cffunction>
	<!--- wonDeliveryType getter --->
	<cffunction name="getWonDeliveryType" access="public" output="false">
		<cfreturn this.wonDeliveryType />
	</cffunction>
	
	<cffunction name="getQBrand" output="false" returntype="string">
		
		<!---query to get q brand--->
		<cfquery name="qGetQBrand" datasource="#application.datasource#">
			SELECT 	Distinct(Q_Brand)
			FROM 	ITEM_Q_BRAND
			WHERE 	BSA_Foodservice_Items_Master_ID = '#this.getItemMasterId()#'
		</cfquery>

		<cfset this.qBrand = qGetQBrand.Q_Brand />
		<cfreturn this.qBrand />
		
   	</cffunction>
	
	<cffunction name="getTypeCode" output="false" returntype="string">
		
		
		<cfset this.typeCode = "" />
		
		<cfif this.getTypeCodeId() NEQ "">
		
			<!---query to get Type Code --->
			<cfquery name="qGetTypeCode" datasource="#application.datasource#">
				SELECT 	Distinct(Type_Code_Desc)
				FROM 	Type_Code_Desc
				WHERE 	Type_Code_Desc_ID = '#this.getTypeCodeId()#'
			</cfquery>
	
			<cfset this.typeCode = qGetTypeCode.Type_Code_Desc />
		
		</cfif>
		
		<cfreturn this.typeCode />
		
   	</cffunction>
	
</cfcomponent>