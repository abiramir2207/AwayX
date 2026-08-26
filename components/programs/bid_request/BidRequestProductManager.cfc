<!---BidRequestProductManager.cfc--->
<cfcomponent>
	
	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="void" output="false">	
	</cffunction>
	
	<cffunction name="getBidRequestProductsFromDb" output="false" returntype="components.programs.bid_request.BidRequest">
	
		<cfargument name="programId" required="false" default="0" />
		
		<!---initialize BidRequest object to return--->
		<cfset rBidReqObj = CreateObject("component", "components.programs.bid_request.BidRequest") />
		
		<!---set program/contract id--->
		<cfset rBidReqObj.setProgramId(arguments.programId) />
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		
		<!---grab bid request product data from db for this program id. if there is no record then an empty BidRequestProduct object will get returned--->
    <!--- 
	  Dev Notes: 23635/Anand Rao/04-Jun-10
	  Competitive Data, Forge changes
    Added Program_Bid_Won_By_ID, Program_Bid_Category_ID, Program_Bid_Package_ID,
    Program_Bid_Category_Description,Program_Bid_Package_Description
    --->
		<cfquery name="qGetBidRequestProducts" datasource="#application.datasource#">

			SELECT 	pbrp.Program_ID,
					isnull(pbrp.Bid_Request_Spec_ID,1) as Bid_Request_Spec_ID,
					pbrp.Line_ID,
					pbrp.Previous_Won_By,
					pbrp.Previous_Won_Price,
					pbrp.Previous_Won_Uom,
					pbrp.Price,
					pbrp.UOM,
					Program_Product_Bid_Info.Won,
					ISNULL(Program_Bid_Won_By.Program_Bid_Won_By_Description,Program_Product_Bid_Info.Won_By) AS Won_By,
					Program_Product_Bid_Info.Won_Price,
					Program_Product_Bid_Info.Won_Uom,
					Program_Product_Bid_Info.Won_Delivery_Type,
          Program_Product_Bid_Info.Program_Bid_Won_By_ID,
          Program_Product_Bid_Info.Program_Bid_Category_ID,
          Program_Product_Bid_Info.Program_Bid_Package_ID,
          -- Program_Bid_Won_By.Program_Bid_Won_By_Description,
          Program_Bid_Category.Program_Bid_Category_Description,
          Program_Bid_Package.Program_Bid_Package_Description,
					cp.Contract_Products_ID,
					cfim.BSA_Foodservice_Items_Master_ID,
					cfim.Item,
					cfim.UPC,
					cfim.Description,
					cfim.Inventory_UM,
					cfim.Pack_Size,
					cfim.Pack_Size_UOM,
					cfim.Type_Code_Desc_ID,
					cp.EZButton_On_Default
					<cfif appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
					,ITEM_MARGIN_TARGETS.ITEM_FOB_BASE_PRICE as CS_FOB_Price,
					case when ISNULL(cast(cfim.net_weight as float),0) != 0 then
					(ITEM_MARGIN_TARGETS.ITEM_FOB_BASE_PRICE / cast(cfim.net_weight as float)) 
					else 0 end as LB_FOB_Price
					</cfif>
			FROM 	Program_Bid_Request_Product pbrp
					INNER JOIN Contract_Products cp ON
					cp.Contract_Products_ID = pbrp.Contract_Products_ID
					AND cp.contract_main_id = pbrp.Program_ID
					INNER JOIN BSA_Foodservice_Items_Master cfim ON
					cfim.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					<cfif appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
					LEFT JOIN ITEM_MARGIN_TARGETS ON ITEM_MARGIN_TARGETS.product_id = 
					cfim.BSA_Foodservice_Items_Master_ID
					</cfif>
					LEFT JOIN Program_Product_Bid_Info
					ON	Program_Product_Bid_Info.Deleted = 0
					AND	Program_Product_Bid_Info.Program_ID = cp.contract_main_id
					AND	Program_Product_Bid_Info.Product_ID = cp.BSA_Foodservice_Items_Master_ID
         LEFT JOIN Program_Bid_Won_By ON
            Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Product_Bid_Info.Program_Bid_Won_By_ID
         LEFT JOIN  Program_Bid_Category ON
            Program_Bid_Category.Program_Bid_Category_ID = Program_Product_Bid_Info.Program_Bid_Category_ID
         LEFT JOIN  Program_Bid_Package ON
            Program_Bid_Package.Program_Bid_Package_ID = Program_Product_Bid_Info.Program_Bid_Package_ID          
			where cp.Deleted = 0
			AND		pbrp.Deleted = 0
			AND		pbrp.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
				<cfif appSettings.getViewPgmSortBy() EQ 0>
					ORDER BY CFIM.Item, CFIM.UPC, CFIM.Description
				<cfelseif appSettings.getViewPgmSortBy() EQ 1>
		 			ORDER BY CFIM.Description, CFIM.Item, CFIM.UPC
				<cfelse>
					ORDER BY CFIM.Item, CFIM.UPC, CFIM.Description
				</cfif>	
		</cfquery>
		
		<!---determine if this is an indirect bid--->
		<cfset bIsIndirectBid = this.checkIndirectBid(arguments.programId) />
		
		<!---initialize the program object--->
		<cfset oProgram = CreateObject("component", "components.programs.Program") />
		<!---get program start date--->
		<cfset startDate = oProgram.getProgramInfo(arguments.programId).Contract_Start_Date />
		<cfif startDate eq "">
			<cfset startDate = oProgram.getDeletedProgramInfo(arguments.programId).Contract_Start_Date />
		</cfif>
		<cfloop query="qGetBidRequestProducts">
			
			<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
			<!------ get the gillardi price list header id ----->
			<cfif bIsIndirectBid>
				<cfset priceListId = this.getPriceListId("GIL98") />
			<cfelse>
				<cfset priceListId = this.getPriceListId() />
			</cfif>
			
			<cfparam name="priceIdNull" default="no" />
			
			<!---if priceListId is an empty string then set queryparam to null--->
			<cfif trim(priceListId) eq "">
				<cfset priceIdNull = "yes" />
			</cfif>
		
			<!---get CS and LB price--->
			<cfset stPrice = this.getPrice(BSA_Foodservice_Items_Master_ID, priceListId, priceIdNull, startDate, bIsIndirectBid) />
			<cfset csPrice = stPrice.CSPrice />
			<cfset lbPrice = stPrice.LBPrice />
			<cfelse>
			<CFIF appSettings.getUseItemCustPrice() EQ 0>
			<cfset csPrice = CS_FOB_Price>
			<cfset lbPrice = LB_FOB_Price>
			<CFELSE>
			<cfset getItemCustPrice = this.getItemCustPrice(BSA_Foodservice_Items_Master_ID,arguments.programId) />
			<cfset csPrice = getItemCustPrice.FOB_CS_Price>
			<cfset lbPrice = getItemCustPrice.FOB_LB_Price>
			</CFIF>
			</cfif>
	
			<!---create an instance of BidRequestProduct--->
			<cfset rBidReqProdObj = CreateObject("component", "components.programs.bid_request.BidRequestProduct") />
			<cfset rBidReqProdObj.setItemMasterId(BSA_Foodservice_Items_Master_ID) />
			<cfset rBidReqProdObj.setContractProductId(Contract_Products_ID) />
			<cfset rBidReqProdObj.setSpecId(Bid_Request_Spec_ID) />
			<cfset rBidReqProdObj.setItem(Item) />
			<cfset rBidReqProdObj.setUpc(UPC) />
			<cfset rBidReqProdObj.setDesc(Description) />
			<cfset rBidReqProdObj.setProductInventoryUOM(Inventory_UM) />
			<cfset rBidReqProdObj.setDefaultLBPrice(lbPrice) />
			<cfset rBidReqProdObj.setDefaultCSPrice(csPrice) />
			<cfset rBidReqProdObj.setPreviousWonBy(Previous_Won_By) />
			<cfset rBidReqProdObj.setLineID(Line_ID) />
			<cfset rBidReqProdObj.setPreviousWonPrice(Previous_Won_Price) />
			<cfset rBidReqProdObj.setPreviousWonUom(Previous_Won_Uom) />
			<!--- <cfset rBidReqProdObj.setAllowance(Allowance) /> --->
			<cfset rBidReqProdObj.setNet(Price) />
			<cfset rBidReqProdObj.setUom(UOM) />			
			<cfset rBidReqProdObj.setWon(Won) />
			<cfset rBidReqProdObj.setWonBy(Won_By) />
			<cfset rBidReqProdObj.setWonPrice(Won_Price) />
			<cfset rBidReqProdObj.setWonUom(Won_Uom) />
			<cfset rBidReqProdObj.setPackSize(Pack_Size) />
			<cfset rBidReqProdObj.setPackSizeUOM(Pack_Size_UOM) />
			<cfset rBidReqObj.setBidRequestProducts(rBidReqProdObj) />
			<cfset rBidReqProdObj.setTypeCodeId(Type_Code_Desc_ID) />
			<cfset rBidReqProdObj.setWonDeliveryType(Won_Delivery_Type) />
      <cfset rBidReqProdObj.setWonDeliveryType(Won_Delivery_Type) />
			<cfset rBidReqProdObj.setWonByID(Program_Bid_Won_By_ID) />
      <cfset rBidReqProdObj.setCategoryID(Program_Bid_Category_ID) />
      <cfset rBidReqProdObj.setPackageID(Program_Bid_Package_ID) />
      <cfset rBidReqProdObj.setCategoryDesc(Program_Bid_Category_Description) />  
      <cfset rBidReqProdObj.setPackageDesc(Program_Bid_Package_Description) />       
		</cfloop>
		
		<!---set the product list--->
		<cfset rBidReqObj.setLBidRequestProductIds(ValueList(qGetBidRequestProducts.BSA_Foodservice_Items_Master_ID)) />
		
		<cfreturn rBidReqObj />
		
	</cffunction>
	
	<!---setFromForm--->
	<cffunction name="setFromForm" output="false" returntype="components.programs.bid_request.BidRequest">
		
		<!---pass the whole form scope--->
		<cfargument name="formScope" required="false" default="" />
		
		<!---set default values--->
		<cfparam name="arguments.formScope.product_list" default="" />
		<cfparam name="arguments.formScope.sort_by" default="Item" />
		<cfparam name="arguments.formScope.sort_order" default="asc" />

		<!---initialize BidRequest object to return--->
		<cfset rBidReqObj = CreateObject("component", "components.programs.bid_request.BidRequest") />
		
		<!---set program/contract id--->
		<cfset rBidReqObj.setProgramId(arguments.formScope.Program_ID) />
		
		<!---initialize the program object--->
		<cfset oProgram = CreateObject("component", "components.programs.Program") />
		<!---get the program uom --->
		<cfset defaultUom = oProgram.getProgramInfo(arguments.formScope.Program_ID).Contract_Quantity_UOM_IDX />
		<!---get start date--->
		<cfset startDate = oProgram.getProgramInfo(arguments.formScope.Program_ID).Contract_Start_Date />
		
		<!------ Get the application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		<cfset restrictProductUOM = appSettings.getRestrictProductUOM()>
		<cfset productManager = CreateObject("component", "components.products.ProductManager").init() />
			
		<!---run query based on product list and set data if we have a product list--->
		<cfif trim(arguments.formScope.product_list) neq "">
			
			<cfquery name="qGetProducts" datasource="#application.datasource#">
				SELECT 	cfim.BSA_Foodservice_Items_Master_ID,
						cfim.Item,
						cfim.UPC,
						cfim.Description,
						cfim.Inventory_UM
						<cfif appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
						,ITEM_MARGIN_TARGETS.ITEM_FOB_BASE_PRICE as CS_FOB_Price,
						case when ISNULL(cast(cfim.net_weight as float),0) != 0 then
						(ITEM_MARGIN_TARGETS.ITEM_FOB_BASE_PRICE / cast(cfim.net_weight as float)) 
						else 0 end as LB_FOB_Price
						</cfif>
				FROM	BSA_Foodservice_Items_Master cfim	
				<cfif appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
				LEFT JOIN ITEM_MARGIN_TARGETS ON ITEM_MARGIN_TARGETS.product_id = 
					cfim.BSA_Foodservice_Items_Master_ID
				</cfif>
				WHERE	cfim.Deleted = 0
				AND		cfim.BSA_Foodservice_Items_Master_ID in (#replace(listqualify(arguments.formScope.product_list, "'"), '"', "'")#)
				ORDER BY cfim.#arguments.formScope.sort_by# #arguments.formScope.sort_order#
			</cfquery>
			
			<!---determine if this is an indirect bid--->
			<cfset bIsIndirectBid = this.checkIndirectBid(arguments.formScope.Program_ID) />

			<cfloop query="qGetProducts">
			
				<!---replace dashes with underscores for product id--->
				<cfset thisProdId = request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID) />
				
				<!------ Handle for restrict rate/UOM on product UOM ----->
				<cfif restrictProductUOM>
					<cfset productDefaultUom = productManager.getUOMId(Inventory_UM) />
				<cfelse>
					<cfset productDefaultUom = defaultUom />			
				</cfif>
				
				<cfif appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0>
				
					<cfset csPrice = CS_FOB_Price>
					<cfset lbPrice = LB_FOB_Price>
					
				<cfelse>
				
					<!------ get the gillardi price list header id ----->
					<cfif bIsIndirectBid>
						<cfset priceListId = this.getPriceListId("GIL98") />
					<cfelse>
						<cfset priceListId = this.getPriceListId() />
					</cfif>
				
					<cfparam name="priceIdNull" default="no" />
			
					<!---if priceListId is an empty string then set queryparam to null--->
					<cfif trim(priceListId) eq "">
						<cfset priceIdNull = "yes" />
					</cfif>
			
					<!---get CS and LB price--->
					<cfset stPrice = this.getPrice(BSA_Foodservice_Items_Master_ID, priceListId, priceIdNull, startDate, bIsIndirectBid) />
					<cfset csPrice = stPrice.CSPrice />
					<cfset lbPrice = stPrice.LBPrice />
					
				</cfif>
				
				<!---set default values--->
				<cfparam name="arguments.formScope.Bid_Request_Spec_ID_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.Line_ID_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.previous_won_by_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.previous_won_price_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.previous_won_uom_#thisProdId#" default="#defaultUom#" />
				<cfparam name="arguments.formScope.net_#thisProdId#" default=0 />
				<cfparam name="arguments.formScope.uom_#thisProdId#" default="#productDefaultUom#" />
				<cfparam name="arguments.formScope.won_#thisProdId#" default=1 />
				<cfparam name="arguments.formScope.won_by_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.won_price_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.won_uom_#thisProdId#" default="#defaultUom#" />
				<cfparam name="arguments.formScope.won_Delivery_Type_#thisProdId#" default="" />
        <!--- 
        	Dev Notes: 23635/Anand Rao/09-Jun-10
        	Competitive Data, Forge changes
        --->
				<cfparam name="arguments.formScope.won_by_id_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.category_id_#thisProdId#" default="" />
				<cfparam name="arguments.formScope.package_id_#thisProdId#" default="" /> 
                		
				<!---create an instance of BidRequestProduct--->
				<cfset rBidReqProdObj = CreateObject("component", "components.programs.bid_request.BidRequestProduct") />
				<cfset rBidReqProdObj.setItemMasterId(BSA_Foodservice_Items_Master_ID) />
				<cfset rBidReqProdObj.setItem(Item) />
				<cfset rBidReqProdObj.setUpc(UPC) />
				<cfset rBidReqProdObj.setDesc(Description) />
				<cfset rBidReqProdObj.setProductInventoryUOM(Inventory_UM) />
				<cfset rBidReqProdObj.setDefaultLBPrice(lbPrice) />
				<cfset rBidReqProdObj.setDefaultCSPrice(csPrice) />
				<cfset rBidReqProdObj.setSpecId(Evaluate("arguments.formScope.Bid_Request_Spec_ID_#thisProdId#")) />
				<cfset rBidReqProdObj.setPreviousWonBy(Evaluate("arguments.formScope.previous_won_by_#thisProdId#")) />
				<cfset rBidReqProdObj.setLineID(Evaluate("arguments.formScope.Line_ID_#thisProdId#")) />
				<cfset rBidReqProdObj.setPreviousWonPrice(Evaluate("arguments.formScope.previous_won_price_#thisProdId#")) />
				<cfset rBidReqProdObj.setPreviousWonUom(Evaluate("arguments.formScope.previous_won_uom_#thisProdId#")) />
				<cfset rBidReqProdObj.setNet(Evaluate("arguments.formScope.net_#thisProdId#")) />
				<cfset rBidReqProdObj.setUom(Evaluate("arguments.formScope.uom_#thisProdId#")) />				
				<cfset rBidReqProdObj.setWon(Evaluate("arguments.formScope.won_#thisProdId#")) />
				<cfset rBidReqProdObj.setWonBy(Evaluate("arguments.formScope.won_by_#thisProdId#")) />
				<cfset rBidReqProdObj.setWonPrice(Evaluate("arguments.formScope.won_price_#thisProdId#")) />
				<cfset rBidReqProdObj.setWonUom(Evaluate("arguments.formScope.won_uom_#thisProdId#")) />
				<cfset rBidReqProdObj.setWonDeliveryType(Evaluate("arguments.formScope.won_Delivery_Type_#thisProdId#")) />
        <cfset rBidReqProdObj.setWonByID(Evaluate("arguments.formScope.won_by_id_#thisProdId#")) />
        <cfset rBidReqProdObj.setCategoryID(Evaluate("arguments.formScope.category_id_#thisProdId#")) />
        <cfset rBidReqProdObj.setPackageID(Evaluate("arguments.formScope.package_id_#thisProdId#")) />        
        
				<cfset rBidReqObj.setBidRequestProducts(rBidReqProdObj) />
				
			</cfloop>
		
		</cfif>
		
		<!---set the product list--->
		<cfset rBidReqObj.setLBidRequestProductIds(arguments.formScope.product_list) />
		
		<cfreturn rBidReqObj />
			
	</cffunction>
	
<cffunction name="getAllProductsFromDb" output="false" returntype="components.programs.bid_request.BidRequest">
	
		<cfargument name="programId" required="false" default="0" />
		
		<!---initialize BidRequest object to return--->
		<cfset rBidReqObj = CreateObject("component", "components.programs.bid_request.BidRequest") />
		
		<!---set program/contract id--->
		<cfset rBidReqObj.setProgramId(arguments.programId) />
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		
		<!---grab bid request product data from db for this program id. if there is no record then an empty BidRequestProduct object will get returned--->
		<cfquery name="qGetAllProducts" datasource="#application.datasource#">

			SELECT 	DISTINCT 
					cp.contract_main_id Program_ID,
					ISNULL(Program_Product_Bid_Info.Won, 0) Won,
					ISNULL(Program_Bid_Won_By.Program_Bid_Won_By_Description,Program_Product_Bid_Info.Won_By) AS Won_By,
					Program_Product_Bid_Info.Won_Price,
					Program_Product_Bid_Info.Won_Uom,
					Program_Product_Bid_Info.Won_Delivery_Type,
          Program_Product_Bid_Info.Program_Bid_Won_By_ID,
          Program_Product_Bid_Info.Program_Bid_Category_ID,
          Program_Product_Bid_Info.Program_Bid_Package_ID,          
          -- Program_Bid_Won_By.Program_Bid_Won_By_Description,
          Program_Bid_Category.Program_Bid_Category_Description,
          Program_Bid_Package.Program_Bid_Package_Description,
					cfim.BSA_Foodservice_Items_Master_ID,
					cfim.Item,
					cfim.UPC,
					cfim.Description,
					cfim.Inventory_UM,
					cfim.Type_Code_Desc_ID,
					cfim.Pack_Size,
					cfim.Pack_Size_UOM
			FROM 	Contract_Products cp					
					INNER JOIN BSA_Foodservice_Items_Master cfim ON
					cfim.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					LEFT JOIN Program_Product_Bid_Info
					ON	Program_Product_Bid_Info.Deleted = 0
					AND	Program_Product_Bid_Info.Program_ID = cp.contract_main_id
					AND	Program_Product_Bid_Info.Product_ID = cp.BSA_Foodservice_Items_Master_ID
          LEFT JOIN Program_Bid_Won_By ON
            Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Product_Bid_Info.Program_Bid_Won_By_ID
          LEFT JOIN  Program_Bid_Category ON
            Program_Bid_Category.Program_Bid_Category_ID = Program_Product_Bid_Info.Program_Bid_Category_ID
          LEFT JOIN  Program_Bid_Package ON
            Program_Bid_Package.Program_Bid_Package_ID = Program_Product_Bid_Info.Program_Bid_Package_ID
			where 	cp.Deleted = 0
			AND 	cp.contract_main_id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
		   AND   CAST(cp.BSA_foodservice_items_master_id AS NVARCHAR(50)) = 
			CASE (ISNULL(cp.Product_group_id, ''))
				WHEN '' THEN CAST (cp.BSA_foodservice_items_master_id AS NVARCHAR(50))
				ELSE CAST (cp.Product_group_id AS NVARCHAR(50)) 
			END				
			ORDER BY CFIM.Item, CFIM.UPC, CFIM.Description
		
		</cfquery>
		
		<cfloop query="qGetAllProducts">
			
			<!---create an instance of BidRequestProduct--->
			<cfset rBidReqProdObj = CreateObject("component", "components.programs.bid_request.BidRequestProduct") />
			<cfset rBidReqProdObj.setItemMasterId(BSA_Foodservice_Items_Master_ID) />
			<!------ <cfset rBidReqProdObj.setContractProductId(Contract_Products_ID) /> ----->
			<!------ <cfset rBidReqProdObj.setSpecId(Bid_Request_Spec_ID) /> ----->
			<cfset rBidReqProdObj.setItem(Item) />
			<cfset rBidReqProdObj.setUpc(UPC) />
			<cfset rBidReqProdObj.setDesc(Description) />
			<cfset rBidReqProdObj.setProductInventoryUOM(Inventory_UM) />
			<cfset rBidReqProdObj.setWon(Won) />
			<cfset rBidReqProdObj.setWonBy(Won_By) />
			<cfset rBidReqProdObj.setWonPrice(Won_Price) />
			<cfset rBidReqProdObj.setWonUom(Won_Uom) />
			<cfset rBidReqProdObj.setWonDeliveryType(Won_Delivery_Type) />

			<cfset rBidReqObj.setBidRequestProducts(rBidReqProdObj) />
			<cfset rBidReqProdObj.setTypeCodeId(Type_Code_Desc_ID) />
			<cfset rBidReqProdObj.setPackSize(Pack_Size) />
			<cfset rBidReqProdObj.setPackSizeUOM(Pack_Size_UOM) />
			<cfset rBidReqProdObj.setWonByID(Program_Bid_Won_By_ID) />
      <cfset rBidReqProdObj.setCategoryID(Program_Bid_Category_ID) />
      <cfset rBidReqProdObj.setPackageID(Program_Bid_Package_ID) />  
      <cfset rBidReqProdObj.setCategoryDesc(Program_Bid_Category_Description) />  
      <cfset rBidReqProdObj.setPackageDesc(Program_Bid_Package_Description) />     
		</cfloop>
		
		<!---set the product list--->
		<cfset rBidReqObj.setLBidRequestProductIds(ValueList(qGetAllProducts.BSA_Foodservice_Items_Master_ID)) />
		
		<cfreturn rBidReqObj />
		
	</cffunction>	
	
	<cffunction name="saveBidRequestProducts" output="false">
	
		<cfargument name="bidRequestObj" required="false" default="" type="components.programs.bid_request.BidRequest" />
		
		<!---first set deleted = 1 on any existing products that aren't in the product list--->
		<!---open transaction--->
		<cftransaction action="begin">
		
			<!---Contract_Products--->
			<cfquery name="qUpdtCProducts" datasource="#application.datasource#">
				UPDATE 	Contract_Products
				SET		Deleted = 1
				WHERE	Deleted = 0
				AND		Contract_Main_ID = <cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />
				AND		Product_Type_ID = <cfqueryparam value="#arguments.bidRequestObj.getDiscountTypeId()#" cfsqltype="CF_SQL_INTEGER" />
				<!---only filter if we have some item master id's left--->
				<cfif Len(trim(arguments.bidRequestObj.getLBidRequestProductIds()))>
					AND		BSA_Foodservice_Items_Master_ID NOT IN 
							(
								#replace(listqualify(arguments.bidRequestObj.getLBidRequestProductIds(), "'"), '"', "'")#
							)
				</cfif>
			</cfquery>
			
			<cfquery name="qDeleteCProductsMargin" datasource="#application.datasource#">
				DELETE 	FROM 	Contract_Product_Margin
				WHERE	Contract_Main_ID = <cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />
				AND		Product_Type_ID = <cfqueryparam value="#arguments.bidRequestObj.getDiscountTypeId()#" cfsqltype="CF_SQL_INTEGER" />
			</cfquery>
			
			<!---Program_Bid_Request_Product--->
			<cfquery name="qUpdtBRProducts" datasource="#application.datasource#">
				UPDATE 	Program_Bid_Request_Product
				SET		Deleted = 1
				WHERE	Deleted = 0
				AND		Program_ID = <cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />
			</cfquery>
			
			<!---get a list of master item id's from contract products to see what products already exist--->
			<cfquery name="qGetExistingContractProducts" datasource="#application.datasource#">
				SELECT	BSA_Foodservice_Items_Master_ID,
						Contract_Main_Id,
						Contract_Products_ID
				FROM	Contract_Products
				WHERE	Deleted = 0
				AND		Contract_Main_ID = <cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />
				AND		Product_Type_ID = <cfqueryparam value="#arguments.bidRequestObj.getDiscountTypeId()#" cfsqltype="CF_SQL_INTEGER" />
				<!---only filter if we have some item master id's left--->
				<cfif Len(trim(arguments.bidRequestObj.getLBidRequestProductIds()))>
					AND		BSA_Foodservice_Items_Master_ID IN 
							(
								#replace(listqualify(arguments.bidRequestObj.getLBidRequestProductIds(), "'"), '"', "'")#
						)
				</cfif>		
			</cfquery>
			
			<cfset bidRequestProductObj = arguments.bidRequestObj.getBidRequestProducts() />

			<!---now loop over products and insert or update depending if the product already exists--->
			<cfloop index="prodIndx" from="1" to="#ArrayLen(bidRequestProductObj)#">

				<!---check to see if this product exists in contract products--->
				<cfquery name="qCheckForContractProducts" dbtype="query">
					SELECT 	Contract_Products_ID
					FROM	qGetExistingContractProducts
					WHERE	BSA_Foodservice_Items_Master_ID = '#bidRequestProductObj[prodIndx].getItemMasterId()#'
					AND		Contract_Main_Id = #arguments.bidRequestObj.getProgramId()#
				</cfquery>
				
				<!---don't insert into contract products if we have this product in contract product--->
				<cfif qCheckForContractProducts.RecordCount gt 0>
					
					<!---set the contract product id--->
					<cfset bidRequestProductObj[prodIndx].setContractProductId(qCheckForContractProducts.Contract_Products_ID) />
					
				<cfelse>
					
					<!---insert into Contract_Products--->
					<cfquery datasource="#application.datasource#" name="qInsertContractProducts">
					
						SET NOCOUNT ON
						
						INSERT INTO Contract_Products
							(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID)
						VALUES
							(
								<cfqueryparam value="#bidRequestProductObj[prodIndx].getItemMasterId()#" cfsqltype="CF_SQL_VARCHAR" />,
								<cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />,
								<cfqueryparam value="#arguments.bidRequestObj.getDiscountTypeId()#" cfsqltype="CF_SQL_INTEGER" />
							)
						
						SELECT Contract_Products_ID = @@IDENTITY
						SET NOCOUNT OFF
						
					</cfquery>
									
					<!---now set the contract product id--->
					<cfset bidRequestProductObj[prodIndx].setContractProductId(qInsertContractProducts.Contract_Products_ID) />
								
				</cfif>

				<!---insert into Program_Bid_Request_Product--->
				<cfquery datasource="#application.datasource#" name="qInsertBidRequestProducts">
				
					INSERT INTO Program_Bid_Request_Product
						(Program_ID, Contract_Products_ID, Bid_Request_Spec_ID, Line_ID, Previous_Won_By, Previous_Won_Price, Previous_Won_Uom, Allowance, Price, UOM, Won)
					VALUES
						(
							<cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getContractProductId()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getSpecId()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getLineID()#" cfsqltype="CF_SQL_VARCHAR" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getPreviousWonBy()#" cfsqltype="CF_SQL_VARCHAR" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getPreviousWonPrice()#" cfsqltype="CF_SQL_FLOAT" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getPreviousWonUom()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getAllowance()#" cfsqltype="CF_SQL_FLOAT" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getNet()#" cfsqltype="CF_SQL_FLOAT" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getUom()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getWon()#" cfsqltype="CF_SQL_BIT" />
						)
					
				</cfquery>
					
			</cfloop>
			
			<!---call SP to update program product volume --->
			<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.bidRequestObj.getProgramId()#" null="no">
				   
			</cfstoredproc>

			<!---call SP to update program contract quantity --->
			<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#arguments.bidRequestObj.getProgramId()#" null="no">

			</cfstoredproc>
			
			
	
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="getPriceListId" output="false" returntype="string">
	
		<cfargument name="priceListHeaderId" required="false" default="" />
		
		<cfset rPriceListID = "" />
		<!---if a price list header id was passed then use that one--->
		<cfif trim(arguments.priceListHeaderId) neq "">
			<cfset priceListId = arguments.priceListHeaderId />
		<cfelse>
			<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").init().get(1,2) />
			<cfset priceListId = appSettings.getBidRequestPriceListId() />
		</cfif>
		
		<cfset useLakebaseForqGetPriceListHeaderID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_list_header")>
<cfif useLakebaseForqGetPriceListHeaderID>
	<cftry>
		<cfset qGetPriceListHeaderID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("price_list_header", {
				"price_list_id" = "eq.#priceListId#",
				"select" = "price_list_header_id"
			}), "price_list_header_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPriceListHeaderID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPriceListHeaderID>
<cfquery name="qGetPriceListHeaderID" datasource="#application.datasource#">
			SELECT	Price_List_Header.Price_List_Header_ID
			FROM	Price_List_Header
			WHERE	Price_List_Header.Price_List_ID = '#priceListId#'
		</cfquery>
</cfif>
		
		<cfif qGetPriceListHeaderID.recordCount>
			<cfset rPriceListID = qGetPriceListHeaderID.Price_List_Header_ID />
		</cfif>
		
		<cfreturn rPriceListID />
	
	</cffunction>
	
	<cffunction name="getPrice" output="false" returntype="struct">
	
		<cfargument name="productId" required="true" default="" />
		<cfargument name="priceListId" required="false" default="" />
		<cfargument name="priceListIdNull" required="false" default="" />
		<cfargument name="startDate" required="true" default="" />
		<cfargument name="indirectBid" required="true" default="0" />
		
		<cfset rPriceStruct = StructNew() />
		<cfset rPriceStruct.CSPrice = "" />
		<cfset rPriceStruct.LBPrice = "" />
		
		<!---if it's an indirect bid then we have to call the stored procedure and verify that we have a price. if we don't then call it again with the price list id set in app settings--->
		<cfif arguments.indirectBid>
		
			<!---Call the stored proc to get price--->
			<cfstoredproc procedure="SP_GET_PRICE_BY_DATE" datasource="#application.datasource#">
		   
				<!--- cfprocparam tags --->
				<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#arguments.productId#" null="no">
				<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRICE_ID" null="#arguments.priceListIdNull#" value="#arguments.priceListId#">
				<cfprocparam type = "In" CFSQLType ="CF_SQL_DATE" dbVarName = "@@G_DATE" null="no" value="#arguments.startDate#">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="Indirect_CS_Price" dbVarName = "@@CS_PRICE" null="no">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="Indirect_LB_Price" dbVarName = "@@LB_PRICE" null="no">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="Indirect_CS_DEL_Price" dbVarName = "@@CS_DEL_PRICE" null="no">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="Indirect_LB_DEL_Price" dbVarName = "@@LB_DEL_PRICE" null="no">
				<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@@BYPASS_DEFAULT_PRICE_LIST" value="1" null="no">
		
			</cfstoredproc>
			
			<!---if we don't get a price for indirect then get the price with the price list in app settings. Otherwise, set it to what was returned from the stored procedure--->
			<cfif (Indirect_CS_Price eq 0 or Indirect_LB_Price eq 0) AND (Indirect_CS_DEL_Price eq 0 or Indirect_LB_DEL_Price eq 0)>
			
				<!---get new price list id--->
				<cfset newPriceListId = this.getPriceListId() />
				
				<cfif trim(newPriceListId) eq "">
					<cfset newPriceIdNull = "yes" />
				<cfelse>
					<cfset newPriceIdNull = "no" />
				</cfif>
				
				<cfstoredproc procedure="SP_GET_PRICE_BY_DATE" datasource="#application.datasource#">
		   
					<!--- cfprocparam tags --->
					<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#arguments.productId#" null="no">
					<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRICE_ID" null="#newPriceIdNull#" value="#newPriceListId#">
					<cfprocparam type = "In" CFSQLType ="CF_SQL_DATE" dbVarName = "@@G_DATE" null="no" value="#arguments.startDate#">
					<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="CS_FOB_Price" dbVarName = "@@CS_PRICE" null="no">
					<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="LB_FOB_Price" dbVarName = "@@LB_PRICE" null="no">
					<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="CS_DEL_Price" dbVarName = "@@CS_DEL_PRICE" null="no">
					<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="LB_DEL_Price" dbVarName = "@@LB_DEL_PRICE" null="no">
					<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@@BYPASS_DEFAULT_PRICE_LIST" value="0" null="no">
		
				</cfstoredproc>
			
			<cfelse>
				<cfset CS_FOB_Price = Indirect_CS_Price />
				<cfset LB_FOB_Price = Indirect_LB_Price />
				<cfset CS_DEL_Price = Indirect_CS_DEL_Price />
				<cfset LB_DEL_Price = Indirect_LB_DEL_Price />
			</cfif>
			
			
		<cfelse>
		
			<!---Call the stored proc to get price--->
			<cfstoredproc procedure="SP_GET_PRICE_BY_DATE" datasource="#application.datasource#">
		   
				<!--- cfprocparam tags --->
				<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#arguments.productId#" null="no">
				<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRICE_ID" null="#arguments.priceListIdNull#" value="#arguments.priceListId#">
				<cfprocparam type = "In" CFSQLType ="CF_SQL_DATE" dbVarName = "@@G_DATE" null="no" value="#arguments.startDate#">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="CS_FOB_Price" dbVarName = "@@CS_PRICE" null="no">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="LB_FOB_Price" dbVarName = "@@LB_PRICE" null="no">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="CS_DEL_Price" dbVarName = "@@CS_DEL_PRICE" null="no">
				<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="LB_DEL_Price" dbVarName = "@@LB_DEL_PRICE" null="no">
				<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@@BYPASS_DEFAULT_PRICE_LIST" value="0" null="no">
		
			</cfstoredproc>
			
		</cfif>
		
		<cfset rPriceStruct.CSPrice = CS_FOB_Price />
		<cfset rPriceStruct.LBPrice = LB_FOB_Price />
		<cfset rPriceStruct.CSDELPrice = CS_DEL_Price />
		<cfset rPriceStruct.LBDELPrice = LB_DEL_Price />
		
		<cfreturn rPriceStruct />
	
	</cffunction>
	
	<cffunction name="checkIndirectBid" output="false" returntype="boolean" hint="Specific function to handle for Conagras Indirect Bid Templates">
	
		<cfargument name="programId" required="true" default="" />
		<cfset rIsIndirectBid = 0 />
		
		<!---check to see if this is an indirect bid--->
		<cfquery name="qCheckDiscountIdentifier" datasource="#application.datasource#">
			SELECT	Contract_Main.Contract_Main_ID
			FROM	Contract_Main
					INNER JOIN Program_Control_Panel_Options ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					AND Program_Control_Panel_Options.Deleted = 0
					INNER JOIN Discount_Identifier ON
					Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
					AND Discount_Identifier.Deleted = 0
					AND Discount_Identifier.Discount_Identifier_Number IN ('IB1','DB1')
			WHERE	Contract_Main.Deleted = 0
			AND		Contract_Main.Contract_Main_ID = #arguments.programId#
		</cfquery>
		
		<cfif qCheckDiscountIdentifier.RecordCount>
			<cfset rIsIndirectBid = 1 />
		</cfif>
		
		<cfreturn rIsIndirectBid />
	
	</cffunction>
	
	<cffunction name="getBidRequestProducts" output="false" returntype="query">
		<cfargument name="programId" required="false" default="0" />
		<cfargument name="Bidrequest_Comp_ids" required="false" default="" />
		<cfargument name="Product_List" required="false" default="" />
		<cfargument name="sql_Sort_By" required="false" default="Item" />
		<cfargument name="Competitive_Data_Tracking" required="false" default="0" />
		<cfargument name="display_basesales_Data" required="false" default="0" />
		<cfargument name="displayGroupType" required="false" default="0" />
		<cfargument name="displayprogram" required="false" default="0" />
		<cfargument name="displaybasesales" required="false" default="1" />
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
	<CFQUERY NAME="qBidRequestProducts" datasource="#application.datasource#">
		SELECT 	distinct 
				dbo.Program_Bid_Request_Product.Program_Bid_Request_Product_ID, 
				Allowance,
				Program_Bid_Request_Product.Price,
				Program_Bid_Request_Product.UOM,
				Program_Bid_Request_Product.Won,
				Program_Bid_Request_Product.Won_By,
				Program_Bid_Request_Product.Won_Price,
				Program_Bid_Request_Product.Won_Uom,
				BSA_Foodservice_Items_Master.Pack_Size,
				BSA_Foodservice_Items_Master.Pack_Size_Uom,
				isnull(Program_Bid_Request_Product.Approved_Base_Sales, 0) as Approved_Base_Sales,
				ISNULL(dbo.Program_Bid_Request_Product.Price,0.0000) as Bidrequest_Price_Value, dbo.Program_Bid_Request_Product.UOM as Unit_Of_Measure_ID,
				dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
				BSA_Foodservice_Items_Master.Inventory_UM,
				Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id
				,Program_Bidrequest_Component.Program_Bidrequest_Component_Id ,
				Program_Bidrequest_Component_Name.Bidrequest_Component_Type,
				isnull(Program_Bid_Request_Product.Bid_Request_Spec_ID,1) as Bid_Request_Spec_ID,
			<cfif (appSettings.getBidRequestUsePriceByDate() EQ 0 and arguments.displaybasesales EQ 1 and appSettings.getUseItemCustPrice() EQ 0) OR (arguments.display_basesales_Data EQ 1 and appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0)>
				ISNULL(ITEM_MARGIN_TARGETS.ITEM_FOB_BASE_PRICE,0) as FOB_CS_Price,
				case when ISNULL(cast(BSA_Foodservice_Items_Master.net_weight as float),0) != 0 then
					(ISNULL(ITEM_MARGIN_TARGETS.ITEM_FOB_BASE_PRICE,0) / cast(BSA_Foodservice_Items_Master.net_weight as float)) 
				else 0 end as FOB_LB_Price,ISNULL(ITEM_MARGIN_TARGETS.ITEM_DEL_BASE_PRICE,0) as DEL_CS_Price,
				case when ISNULL(cast(BSA_Foodservice_Items_Master.net_weight as float),0) != 0 then
					(ISNULL(ITEM_MARGIN_TARGETS.ITEM_DEL_BASE_PRICE,0) / cast(BSA_Foodservice_Items_Master.net_weight as float)) 
				else 0 end as DEL_LB_Price,
			</cfif>				
			<CFIF arguments.Competitive_Data_Tracking EQ 1 and arguments.displayprogram EQ 0>
				Program_Competitive_Data.Previous_Won_By,
				Program_Competitive_Data.Previous_Won_Price,
				Program_Competitive_Data.Previous_Won_Uom,
				Program_Competitive_Data.Previous_Won_Delivery_Type,
			</cfif>				
			<cfif displayGroupType EQ 3><!------ Q Brand ----->
				Q_Brand_Desc.Q_Brand DisplayGroupName,
			<cfelseif displayGroupType EQ 1><!------ Type Code ----->
				Type_Code_Desc.Type_Code_Desc DisplayGroupName,
			</cfif>
			<cfif arguments.displayprogram EQ 1>
				Net_Weight,
				Units_of_Measure.Abbreviation,
				Bid_Request_Spec.Bid_Request_Key,
			</cfif>
				Program_Bid_Request_Product.Line_ID,
				dbo.BSA_Foodservice_Items_Master.Item, 
				dbo.BSA_Foodservice_Items_Master.UPC, 
				dbo.BSA_Foodservice_Items_Master.Description, 
				dbo.Contract_Products.Contract_Main_ID,
				Contract_Products.EZButton_On_Default
		FROM		
			dbo.BSA_Foodservice_Items_Master
			LEFT join Program_Bidrequest_Component_Name
			ON Program_Bidrequest_Component_Name.deleted = 0
		<CFIF LIstlen(arguments.Bidrequest_Comp_ids) GT 0>
			and Program_Bidrequest_Component_Name_Id IN (#arguments.Bidrequest_Comp_ids#)
		<cfelse>
			<cfif arguments.displayprogram EQ 0>
			and 1 = 2
			</cfif>
		</CFIF>
			LEFT JOIN Program_Bidrequest_Component On
			Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id = Program_Bidrequest_Component.Program_Bidrequest_Component_Name_ID
			AND Program_Bidrequest_Component.program_id = '#arguments.programId#'
			and Program_Bidrequest_Component.deleted = 0
			LEFT JOIN	
			(
				dbo.Contract_Products 
				INNER JOIN dbo.Program_Bid_Request_Product 
				ON dbo.Program_Bid_Request_Product.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID 			
				AND dbo.Program_Bid_Request_Product.Deleted = 0
			)
			ON 	dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			AND	dbo.Contract_Products.Product_Type_ID = 10
			AND	dbo.Contract_Products.Deleted = 0
			and dbo.Contract_Products.Contract_Main_ID = Program_Bidrequest_Component.program_id
			AND Program_Bidrequest_Component.Program_Bidrequest_Component_Id = Program_Bid_Request_Product.Program_Bidrequest_Component_Id
		<CFIF arguments.Competitive_Data_Tracking EQ 1 and arguments.displayprogram EQ 0>
			left join Program_Competitive_Data 
			on	Program_Competitive_Data.program_id = contract_products.contract_main_id
			and contract_products.BSA_Foodservice_Items_Master_id = 
			Program_Competitive_Data.product_id
		</cfif>
		<cfif arguments.displayprogram EQ 1>
			INNER JOIN	Units_of_Measure 
			ON Program_Bid_Request_Product.UOM = Units_of_Measure.Unit_Of_Measure_ID
		</cfif>
		<cfif (appSettings.getBidRequestUsePriceByDate() EQ 0 and arguments.displaybasesales EQ 1 and appSettings.getUseItemCustPrice() EQ 0) OR (arguments.display_basesales_Data EQ 1 and appSettings.getBidRequestUsePriceByDate() EQ 0 and appSettings.getUseItemCustPrice() EQ 0)>
			LEFT JOIN ITEM_MARGIN_TARGETS 
			ON ITEM_MARGIN_TARGETS.product_id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		</cfif>
		<cfif displayGroupType EQ 3><!------ Q Brand ----->
			<CFIF application.returned_customer_setting.use_product_q_brand EQ 1>
				INNER JOIN Line_Of_Business
				ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID  
						
				INNER JOIN	Product_Q_Brand_Desc ON Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND
				Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business AND 
				Product_Q_Brand_Desc.Deleted = 0
				INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
			<CFELSE>
				INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID AND Q_Brand_Desc.Deleted = 0
			</CFIF>
			<!--- Get Q_brand --->
		<cfelseif displayGroupType EQ 1><!------ Type Code ----->
				INNER JOIN Type_Code_Desc ON
				Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
		</cfif>
		<cfif arguments.displayprogram EQ 1>
				inner join Bid_Request_Spec 
				on Bid_Request_Spec.Bid_Request_Spec_ID = Program_Bid_Request_Product.Bid_Request_Spec_ID
		</cfif>
		WHERE    0=0
			<cfif arguments.displayprogram EQ 1>
				and contract_products.contract_main_id = '#arguments.programId#'
				and contract_products.product_type_id = 10
				and contract_products.deleted = 0
			</cfif>
			<CFIF listlen(arguments.Product_List) GT 0>
				and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (#ListQualify(arguments.Product_List, "'", ",")#)
				ORDER BY 	#arguments.sql_Sort_By#,
							Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id,Program_Bidrequest_Component.Program_Bidrequest_Component_Id
			<cfelse>
				<cfif arguments.displayprogram EQ 0>
				and 1 = 2
				</cfif>
			ORDER BY BSA_Foodservice_Items_Master.Item ASC, BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Description
			</CFIF>

</CFQUERY>
		<cfreturn qBidRequestProducts />
	</cffunction>
	
	<cffunction name="Get_Bidrequest_Products" output="false" returntype="query">
	<cfargument name="programId" required="false" default="0" />
	<CFQUERY NAME="qGet_Bidrequest_Products" DATASOURCE="#application.datasource#">
		SELECT	distinct BSA_Foodservice_Items_Master_ID
		FROM	Contract_Products 
				INNER JOIN	dbo.Program_Bid_Request_Product 
				ON 
				Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND
				Program_Bid_Request_Product.Deleted = 0
		WHERE
				Contract_Products.Deleted = 0
				AND 
				Contract_Products.Contract_Main_ID = #arguments.programId#
				AND Contract_Products.product_type_id =10
	</CFQUERY>
	<cfreturn qGet_Bidrequest_Products />
	</cffunction>
	
	<cffunction name="getAllBidrequestComponents" output="false" returntype="query">
	<cfargument name="programId" required="false" default="0" />
	<CFQUERY NAME="qgetAllBidrequestComponents" datasource="#application.datasource#">
SELECT 	Program_Bidrequest_Component.*,(Cast(Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id as nvarchar(50)) + '_' + Program_Bidrequest_Component.Program_Bidrequest_Component_Paid_to) as Bidrequest_Component_Id,Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name,Program_Bidrequest_Component_Name.Bidrequest_Component_Type
FROM 	Program_Bidrequest_Component
inner join Program_Bidrequest_Component_Name on
Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id = 
Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_id
WHERE 	Program_ID = '#arguments.programId#'
		AND Program_Bidrequest_Component.DELETED = 0
ORDER BY Program_Bidrequest_Component.Program_Bidrequest_Component_Name_Id,Program_Bidrequest_Component.Program_Bidrequest_Component_Id
</CFQUERY>
<cfreturn qgetAllBidrequestComponents />
	</cffunction>
	
<cffunction name="getBidrequestComponents" output="false" returntype="query">
	<cfargument name="programId" required="false" default="0" />
	<cfargument name="Bidrequest_Comp_ids" required="false" default="" />
	<CFQUERY NAME="qgetBidrequestComponents" datasource="#application.datasource#">
select  Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_ID,Program_Bidrequest_Component_Name.Bidrequest_Component_Type
,Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name,
Program_Bidrequest_Component.Program_Bidrequest_Component_Id, Program_Bidrequest_Component.Program_Bidrequest_Component_Paid_to
FROM Program_Bidrequest_Component_Name
LEFT JOIN Program_Bidrequest_Component
ON Program_Bidrequest_Component.Program_Bidrequest_Component_Name_ID = 
Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_ID
AND Program_Bidrequest_Component.Program_ID = '#arguments.programId#'
AND Program_Bidrequest_Component.Deleted = 0
WHERE 	
		Program_Bidrequest_Component_Name.Deleted = 0
		<cfif Listlen(arguments.Bidrequest_Comp_ids) NEQ 0>
		AND Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_Id IN (#arguments.Bidrequest_Comp_ids#)
		</cfif>
ORDER BY Program_Bidrequest_Component_Name.Program_Bidrequest_Component_Name_ID,Program_Bidrequest_Component.Program_Bidrequest_Component_Id
</CFQUERY>
<cfreturn qgetBidrequestComponents />
	</cffunction>
	
	<cffunction name="getBidrequestpreviousinfo" output="false" returntype="query">
	<cfargument name="programId" required="false" default="0" />
	<cfargument name="sql_Sort_By" required="false" type="string" default="item"/>
	<cfargument name="Sort_order" required="false" type="string" default="desc"/>
	<CFQUERY NAME="qgetBidrequestpreviousinfo" datasource="#application.datasource#">
	select distinct
			ISNULL(Program_Bid_Won_By.Program_Bid_Won_By_Description,Program_Competitive_Data.Previous_Won_By) AS Previous_Won_By,
			Program_Competitive_Data.Previous_Won_Price,
			Program_Competitive_Data.Previous_Won_Uom,
			Program_Competitive_Data.Previous_Won_Delivery_Type,
      Program_Competitive_Data.Program_Bid_Won_By_ID,
      Program_Competitive_Data.Program_Bid_Category_ID,
      Program_Competitive_Data.Program_Bid_Package_ID,
      Program_Bid_Category.Program_Bid_Category_Description,
      Program_Bid_Package.Program_Bid_Package_Description,
			dbo.BSA_Foodservice_Items_Master.Item, dbo.BSA_Foodservice_Items_Master.UPC, dbo.BSA_Foodservice_Items_Master.Description, contract_products.BSA_Foodservice_Items_Master_id,
			dbo.Contract_Products.Contract_Main_ID
			from contract_products
			inner join BSA_Foodservice_Items_Master on
			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id = 
			contract_products.BSA_Foodservice_Items_Master_id
			left join Program_Competitive_Data on
			Program_Competitive_Data.program_id = 
			contract_products.contract_main_id
			and contract_products.BSA_Foodservice_Items_Master_id = 
			Program_Competitive_Data.product_id
      LEFT JOIN Program_Bid_Won_By ON
        Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Competitive_Data.Program_Bid_Won_By_ID
      LEFT JOIN  Program_Bid_Category ON
        Program_Bid_Category.Program_Bid_Category_ID = Program_Competitive_Data.Program_Bid_Category_ID
      LEFT JOIN  Program_Bid_Package ON
            Program_Bid_Package.Program_Bid_Package_ID = Program_Competitive_Data.Program_Bid_Package_ID
			where contract_products.contract_main_id = '#arguments.programId#'
			and contract_products.deleted = 0
      and contract_products.Is_Group = 0
			order by #arguments.sql_Sort_By# #arguments.Sort_order#
</CFQUERY>
<cfreturn qgetBidrequestpreviousinfo />
</cffunction>

<cffunction name="getCompetitiveData" output="false" returntype="query">
	<cfargument name="programId" required="true"  type="numeric" />
	<cfset useLakebaseForqgetCompetitiveData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_competitive_data")>
<cfif useLakebaseForqgetCompetitiveData>
	<cftry>
		<cfset qgetCompetitiveData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_competitive_data", {
				"program_id" = "eq.#arguments.programId#",
				"select" = "previous_won_by,previous_won_price,previous_won_uom,previous_won_delivery_type,created_by,product_id"
			}), "previous_won_by,previous_won_price,previous_won_uom,previous_won_delivery_type,created_by,product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetCompetitiveData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetCompetitiveData>
<CFQUERY NAME="qgetCompetitiveData" datasource="#application.datasource#">
	SELECT DISTINCT
			Program_Competitive_Data.Previous_Won_By,
			Program_Competitive_Data.Previous_Won_Price,
			Program_Competitive_Data.Previous_Won_Uom,
			Program_Competitive_Data.Previous_Won_Delivery_Type,
			Program_Competitive_Data.Created_By,
			Program_Competitive_Data.Product_ID	
	FROM	Program_Competitive_Data
	WHERE	Program_Competitive_Data.Program_ID = '#arguments.programId#'
	</CFQUERY>
</cfif>
<cfreturn qgetCompetitiveData />
</cffunction>
	
	<cffunction name="getbidrequestproductprice" access="public" returntype="query" output="false">
	
		<cfargument name="BidrequestProducts" type="query" required="true" default=""/>
		<cfargument name="Program_Bidrequest_Component_ID" type="string" required="true" />
		<cfargument name="item_num" type="string" required="true" />
		<!--- For Date Exclusion View Programs Page, Contract_Main_ID is not blank --->
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		

		<cfquery name="qgetbidrequestproductprice" dbtype="query">
			select 	Bidrequest_Price_Value, Net_Weight, Unit_Of_Measure_ID,ABBREVIATION,
					Contract_Main_ID,Approved_Base_Sales
			from 	arguments.BidrequestProducts
			where 	Program_Bidrequest_Component_ID = #arguments.Program_Bidrequest_Component_ID# 
			AND 	BSA_Foodservice_Items_Master_ID = '#arguments.item_num#'
			<cfif Contract_Main_ID neq "">
			AND 	Contract_Main_ID = #arguments.Contract_Main_ID#
			</cfif>
		</cfquery>
		
		<cfreturn qgetbidrequestproductprice />
		
	</cffunction>
	
	<cffunction name="getpreviousinfo" output="false" returntype="query">
	<cfargument name="programId" required="false" default="0" />
	<!--- Dev Note: drachala; D29059: Element PREVIOUS_WON_BY is undefined in GETCOMPETITIVEINFO.  START    
    Added/Changed: Added dbo.Program_Competitive_Data.* to Query--->
	<CFQUERY NAME="qgetpreviousinfo" datasource="#application.datasource#">
SELECT                dbo.Program_Product_Bid_Info.Program_ID, dbo.Program_Product_Bid_Info.Product_ID, dbo.Program_Product_Bid_Info.Won, 
                      dbo.Program_Product_Bid_Info.Won_By AS won_by_client, dbo.Program_Product_Bid_Info.Won_Price AS won_by_client_price, dbo.Program_Product_Bid_Info.Won_Uom AS won_by_client_uom, 
                      dbo.Program_Product_Bid_Info.Won_Delivery_Type AS won_by_client_delivery_type, dbo.Program_Competitive_Data.Won_Price, dbo.Program_Competitive_Data.Won_Uom, 
                      dbo.Program_Competitive_Data.Won_Delivery_Type, dbo.Program_Competitive_Data.Program_Bid_Won_By_ID, 
                      dbo.Program_Bid_Won_By.Program_Bid_Won_By_Description, dbo.Program_Competitive_Data.*
FROM          dbo.Program_Product_Bid_Info LEFT JOIN
                      dbo.Program_Competitive_Data ON dbo.Program_Competitive_Data.Program_ID = dbo.Program_Product_Bid_Info.Program_Id 
                      AND Program_Product_Bid_Info.product_id = Program_Competitive_Data.product_id
                      left JOIN
                      dbo.Program_Bid_Won_By ON dbo.Program_Competitive_Data.Program_Bid_Won_By_ID = dbo.Program_Bid_Won_By.Program_Bid_Won_By_ID
WHERE     dbo.Program_Product_Bid_Info.Program_Id = '#arguments.programId#'
</CFQUERY>


<!--- 	<CFQUERY NAME="qgetpreviousinfo" datasource="#application.datasource#">
	select distinct
			Program_Competitive_Data.Previous_Won_By,
			Program_Competitive_Data.Previous_Won_Price,
			Program_Competitive_Data.Previous_Won_Uom,
			Program_Competitive_Data.Previous_Won_Delivery_Type,
			product_id from Program_Competitive_Data
			where program_id = '#arguments.programId#'
</CFQUERY> --->
<cfreturn qgetpreviousinfo />
</cffunction>

<cffunction name="getbidrequestbaseprice" access="public" returntype="query" output="false">
	
		<cfargument name="BidrequestProducts" type="query" required="true" default=""/>
		<cfargument name="Program_Bidrequest_Component_ID" type="string" required="true" />
		<cfargument name="item_num" type="string" required="true" />
		<!--- For Date Exclusion View Programs Page, Contract_Main_ID is not blank --->
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		<cfquery name="qgetbidrequestbaseprice" dbtype="query">
			select 	distinct Approved_Base_Sales, Bidrequest_Price_Value,Net_Weight, Unit_Of_Measure_ID,ABBREVIATION,
					Contract_Main_ID
			from 	arguments.BidrequestProducts
			where 	Program_Bidrequest_Component_ID = #arguments.Program_Bidrequest_Component_ID# 
			AND 	BSA_Foodservice_Items_Master_ID = '#arguments.item_num#'
			<cfif Contract_Main_ID neq "">
			AND 	Contract_Main_ID = #arguments.Contract_Main_ID#
			</cfif>
		</cfquery>
		
		<cfreturn qgetbidrequestbaseprice />
	</cffunction>
	

	<cffunction name="getItemCustPrice" access="public" returntype="query" output="false">
		<cfargument name="product_id" type="string" required="true" />
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		<cfquery name="qgetItemCustPrice" datasource="#application.datasource#">
			select ISNULL(AVG(ISNULL(CS_FOB_Price,0)),0) as FOB_CS_Price,  ISNULL(AVG(ISNULL(LB_FOB_Price,0)),0) as FOB_LB_Price,  ISNULL(AVG(ISNULL(CS_DEL_Price,0)),0) as DEL_CS_Price, ISNULL(AVG(ISNULL(LB_DEL_Price,0)),0) as DEL_LB_Price from
			contract_distributors 
			inner join gross_margin on gross_margin.customer_id = 
			contract_distributors.BSA_Foodservice_Customers_id 
			where contract_distributors.deleted = 0
			and contract_distributors.contract_main_id =  '#arguments.Contract_Main_ID#'
			and gross_margin.product_id = '#arguments.product_id#'
		</cfquery>
		
		<cfreturn qgetItemCustPrice />
	</cffunction>
	
	<!--- (For Fixed Price) These prices are for base sales column and also for the default values of the fixed price "rate" column --->
	<cffunction name="getItemCustPriceForFP" access="public" returntype="query" output="false">
		<cfargument name="product_id" type="string" required="true" />
		<cfargument name="Contract_Main_ID" type="string" required="false" default =""/>
		<cfargument name="priceListID" type="string" required="true" />

		<cfquery name="qgetItemCustPriceForFP" datasource="#application.datasource#">
			SELECT	CAST(ISNULL(price_list_detail.LB_FOB_Price, 0) as decimal(20, 3)) as FOB_LB_Price, 
				CAST(ISNULL(price_list_detail.CS_FOB_Price, 0) as decimal(20, 3)) as FOB_CS_Price,
				CAST(ISNULL(price_list_detail.LB_Bracket_1, 0) as decimal(20, 3)) as DEL_LB_Price, 
				CAST(ISNULL(price_list_detail.CS_Bracket_1, 0) as decimal(20, 3)) as DEL_CS_Price
		 	FROM price_list_header
			INNER JOIN price_list_detail
			ON	price_list_detail.price_list_header_id = price_list_header.price_list_header_id
			AND	price_list_detail.deleted = 0
			AND	price_list_detail.product_id = '#arguments.product_id#'
			WHERE	price_list_header.price_list_id = '#arguments.priceListID#'
			AND	price_list_header.deleted = 0
		</cfquery>
		<cfif qgetItemCustPriceForFP.RecordCount EQ 0>
			<cfscript>
				qgetItemCustPriceForFP = queryNew('FOB_LB_Price,FOB_CS_Price,DEL_LB_Price,DEL_CS_Price');
				QueryAddRow(qgetItemCustPriceForFP, 1);
				QuerySetCell(qgetItemCustPriceForFP,"FOB_LB_Price",0.000);
				QuerySetCell(qgetItemCustPriceForFP,"FOB_CS_Price",0.000);
				QuerySetCell(qgetItemCustPriceForFP,"DEL_LB_Price",0.000);
				QuerySetCell(qgetItemCustPriceForFP,"DEL_CS_Price",0.000);
			</cfscript>
		</cfif>
		
		<cfreturn qgetItemCustPriceForFP />
	</cffunction>

</cfcomponent>


