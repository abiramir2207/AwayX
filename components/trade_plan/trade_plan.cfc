<!---
	Name:
		trade_plan.cfc
	Created By:
		Tim Ford 04/29/2003 
	Description:
		Products components
--->

<cfcomponent>

	<cffunction access="remote" name="getTradePlan" output="false" returntype="query">
		
		<cfargument name="tradePlanId" type="string" required="true" default="">
		<cfargument name="lPositionIds" type="string" required="true" default="">
		
		<cfquery name="qGetTradePlan" datasource="#application.datasource#">
			SELECT 	tp.Trade_Plan_Title,
					tp.Notes,
					tp.Created_Date,	
					tp.Distributor_ID,
					tp.Created_By,
					tp.Updated_By,
					tp.Updated_Date,
					tp.Start_Date,
					tp.End_Date,
					tp.forecast_id
			FROM 	trade_plan tp,
					_users u,
					user_position_holders uph,
					user_positions up,
					BSA_Foodservice_Customers cfc,
					BSA_Foodservice_Brokers cfb
			WHERE 	tp.trade_plan_id = '#arguments.tradePlanId#'
			AND		tp.Created_By = u.user_id
			AND		uph.user_id = u.user_id
			AND		tp.Distributor_ID = cfc.BSA_Foodservice_Customers_ID
			AND		cfc.BSA_Foodservice_Brokers_ID = cfb.BSA_Foodservice_Brokers_ID
			AND		(
						cfb.Service_Market_ID = up.Service_Market_ID
						OR uph.user_positions_id = up.user_positions_id
					)
			AND 		
					up.User_Positions_ID in (#arguments.lPositionIds#)
			AND		tp.Deleted = 0
			
		</cfquery>
			
		<cfreturn qGetTradePlan>
			
	</cffunction>
	

	<cffunction access="remote" name="getTradePlanList" output="false" returntype="query">
		
		<cfargument name="lPositionIds" type="string" required="true" default="">
		
		<cfquery name="qGetTradePlanList" datasource="#application.datasource#">
			SELECT 	distinct	
					tp.Trade_Plan_ID,
					tp.Trade_Plan_Title,
					tp.Created_Date,
					tp.Updated_Date,
					tp.Updated_By,
					u.name_first,
					u.name_last
			FROM	Trade_Plan tp,
					_users u,
					user_position_holders uph,
					user_positions up,
					BSA_Foodservice_Customers cfc,
					BSA_Foodservice_Brokers cfb
			WHERE	tp.Created_By = u.user_id
			AND		uph.user_id = u.user_id
			AND		tp.Distributor_ID = cfc.BSA_Foodservice_Customers_ID
			AND		cfc.BSA_Foodservice_Brokers_ID = cfb.BSA_Foodservice_Brokers_ID
			AND		(
						cfb.Service_Market_ID = up.Service_Market_ID
						OR uph.user_positions_id = up.user_positions_id
					)
			AND 		
					up.User_Positions_ID in (#arguments.lPositionIds#)
			AND		tp.Deleted = 0
	
			ORDER BY tp.Created_Date desc
		</cfquery>
	
		<cfreturn qGetTradePlanList>
			
	</cffunction>
	
	<cffunction access="remote" name="getTradePlanCosts" output="false" returntype="query">
	
		<cfargument name="Trade_Plan_ID" type="string" required="false" default="" />
		<cfargument name="CostType" type="numeric" required="false" default="" />
		
		<!---Query Costs--->
		<cfquery name="qGetCosts" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Trade_Plan_Costs
			WHERE	Trade_Plan_ID = '#arguments.Trade_Plan_ID#'
			AND		Trade_Plan_Cost_Type_ID = '#arguments.CostType#'
			AND		Deleted = 0
		</cfquery>
		
		<cfreturn qGetCosts />
		
	</cffunction>
	
	<cffunction access="remote" name="getTradePlanCostsSum" output="false">
	
		<cfargument name="Trade_Plan_ID" type="string" required="false" default="" />
		<cfargument name="CostType" type="numeric" required="false" default="" />
		
		<!---Query Cost Sum--->
		<cfquery name="qGetCostsSum" datasource="#application.datasource#">
			SELECT 	SUM(Cost) as CostSum
			FROM 	Trade_Plan_Costs
			WHERE	Trade_Plan_ID = '#arguments.Trade_Plan_ID#'
			AND		Trade_Plan_Cost_Type_ID = '#arguments.CostType#'
			AND		Deleted = 0
		</cfquery>
		
		<cfreturn qGetCostsSum.CostSum />
		
	</cffunction>
	
	<cffunction access="remote" name="isChecked" output="false">
	
		<cfargument name="tradePlanID" type="string" required="false" default="" />
		<cfargument name="tradePlanCostsId" type="string" required="false" default="" />
		<cfargument name="typeGroupDescId" type="string" required="false" default="" />
		
		<!---Check for Check_Bit Costs--->
		<cfquery name="qCheckBit" datasource="#application.datasource#">
			SELECT 	Check_Bit 
			FROM 	trade_plan_item_cost
			WHERE 	trade_plan_id = '#arguments.tradePlanID#'
	 		AND		trade_plan_costs_id = #arguments.tradePlanCostsId#
			AND 	Type_Group_Desc_ID = '#arguments.typeGroupDescId#'
		</cfquery>
		
		
		<cfreturn qCheckBit.Check_Bit />
		
	</cffunction>
	
	<cffunction access="remote" name="validateIncentiveCosts" output="false" returntype="boolean">
	
		<cfargument name="tradePlanID" type="string" required="false" default="" />
		
		<!---set boolean value to true--->
		<cfset bIsValid = true />
		
		<cfscript>
			qGetProductTypeGroup = this.getProductTypeGroup(arguments.tradePlanID);
			qGetTradePlanCostsReb = this.getTradePlanCosts(arguments.tradePlanID,1);
		</cfscript>
		
		<!---Loop over each type group and total costs based on check bits--->
		<cfloop query="qGetProductTypeGroup">
		
			<!---Set the type group desc id before going in--->
			<cfset typeGroupDescId = TYPE_GROUP_DESC_ID />
			<cfset tmpCost = 0 /> 
			
			<cfloop query="qGetTradePlanCostsReb">
							
				<cfset tmpChechBit = this.isChecked(Trade_Plan_ID,TRADE_PLAN_COSTS_ID,typeGroupDescId) />
				
				<cfif not tmpChechBit>
					<cfset tmpCost = tmpCost + 0 />
				<cfelse>
					<cfset tmpCost = tmpCost + cost /> 
				</cfif>
				
			</cfloop>
			
			<cfif tmpCost lte 0>
				<cfset bIsValid = false />
			</cfif>

		</cfloop>
		
		<cfreturn bIsValid />
		
	</cffunction>

	<cffunction access="remote" name="getProductTypeGroup" output="false" returntype="query" displayname="GetProductTypeGroup" hint="Gets all of the Product types for a Trade Plan">
	
		<cfargument name="tradePlanID" type="string" required="false" default="" />
		
		<!---Get Product Type Groups--->
		<cfquery name="qGetProductType" datasource="#application.datasource#">
			SELECT DISTINCT(Type_Group_Desc_ID) 
			FROM 	TRADE_PLAN_ITEM_COST
			WHERE 	TRADE_PLAN_ID = <cfqueryparam value="#arguments.tradePlanId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfreturn qGetProductType />
		
	</cffunction>
	
	<cffunction name="convertIntoWIP" output="false" returntype="struct">
	
		<cfargument name="tradePlanId" required="false" default="" />
		<cfargument name="position" required="false" default="" />
		<cfargument name="stProgram" type="struct" required="false" default="" />
		<cfargument name="fileName" required="false" default="" />
		
		<cfscript>

			//initialize all components
			oProgram = CreateObject("component","components.programs.Program");
			oBroker = CreateObject("component","components.programs.brokers.Broker");
			oDistributor = CreateObject("component","components.programs.distributors.Distributor");
			oLumpSumComponents = CreateObject("component","components.programs.lump_sum_components.LumpSumComponent");
			oLumpSumComponentProduct = CreateObject("component","components.programs.lump_sum_components.LumpSumComponentProduct");
			oRebate = CreateObject("component","components.programs.rebates.Rebate");
			oContractProduct = CreateObject("component","components.programs.products.ContractProduct");
			oRebateProduct = CreateObject("component","components.programs.rebates.Product");
			oRebateComponent = CreateObject("component","components.programs.rebates.RebateComponent");
			oRebateComponentRate = CreateObject("component","components.programs.rebates.RebateComponentRate");
			//tradePlan = createObject("component","ReportWriter.trade_plan.components.trade_plan");
			oProduct = createObject("component","components.trade_plan.products");
	
			//Get and set trade plan data
			qGetTradePlan = this.getTradePlan(arguments.tradePlanId,arguments.position);
			qGetTradePlanCostsReb = this.getTradePlanCosts(arguments.tradePlanId,1);
			rebSum = this.getTradePlanCostsSum(arguments.tradePlanId,1);
			qGetTradePlanCostsLumpSum = this.getTradePlanCosts(arguments.tradePlanId,3);
			lumpSumSum = this.getTradePlanCostsSum(arguments.tradePlanId,3);
			qGetProductList = oProduct.getProductList(arguments.tradePlanId);
			qGetTotals = oProduct.getTotals(Trade_Plan_ID);
	
		</cfscript>
		
		<!---set the total volume--->
		<cfset volTotalCS = qGetTotals.Total_Volume_CS />
		
		<!---set the daily volume--->
		<cfset prgmSpan = qGetTradePlan.End_Date - qGetTradePlan.Start_Date+1 />
		<cfset dailVol = volTotalCS / prgmSpan />

<!---
<CFSET DailyContractQuantity = Program_Volume / Contract_Span>
--->

		<!-------********************** PROGRAM ***************************------->
		<cfset oProgram.new(qGetTradePlan.Trade_Plan_Title,qGetTradePlan.notes,qGetTradePlan.Start_Date,qGetTradePlan.End_Date, volTotalCS ,1,dailVol,qGetTradePlan.forecast_id) />	
		
		<!---list of keys to strip--->
		<cfset lKeysToStrip = "new"/>
		
		<!---loop through and strip out keys not needed--->
		<cfloop collection="#oProgram#" item="out">
		
			<!---set boolean type--->
			<cfset bIsKeyToStrip = ListFindNoCase(lKeysToStrip, out) />
	
			<cfif not bIsKeyToStrip>
				<cfset "arguments.stProgram.Basic_Information.#out#" = Evaluate("oProgram.#out#") />
			</cfif>
		
		</cfloop>

	
		<!----------------************************ DISTRIBUTOR *****************************------------->
		<cfset disInfo = oDistributor.getDistributor(qGetTradePlan.Distributor_ID) />
		
		<cfset oDistributor.new(disInfo.BSA_FOODSERVICE_CUSTOMERS_ID,"100",1) />	
		
		<!---list of keys to strip--->
		<cfset lKeysToStrip = "new,GETDISTRIBUTOR"/>
		
		<!---list of keys that need a suffix--->
		<cfset lKeysToSuffix = "BSA_FOODSERVICE_CUSTOMERS_ID,PROGRAM_WEIGHT"/>
		
		<!---make a list ot the struct keys to work with--->
		<cfset lStructKeys = StructKeyList(oDistributor) />
		
		<!---strip out keys to strip--->
		<cfloop index="strpIndx" list="#lKeysToStrip#">
			<cfset lStructKeys = ListDeleteAt(lStructKeys, ListFindNoCase(lStructKeys, strpIndx)) />
		</cfloop>
		
		<cfset lStructKeys = ListDeleteAt(lStructKeys, ListFindNoCase(lStructKeys, "RecordCount")) />
		
		<!---loop through and strip out keys not needed--->
		<cfloop collection="#oDistributor#" item="out">
		
			<!---set counter in case we have multiple instances--->
			<cfset disCount = 1 />

			<!---set boolean type--->
			<cfset bIsKeyToStrip = ListFindNoCase(lKeysToStrip, out) />
		
			<!---set boolean type--->
			<cfset bIsKeyToSuffix = ListFindNoCase(lKeysToSuffix, out) />
		
			<cfif not bIsKeyToStrip>
		
				<cfif bIsKeyToSuffix>
					<cfset "arguments.stProgram.Distributors.#out#_#disCount#" = Evaluate("oDistributor.#out#") />
				<cfelse>
					<cfset "arguments.stProgram.Distributors.#out#" = Evaluate("oDistributor.#out#") />
				</cfif>
			
			</cfif>
		
			<cfset disCount = disCount + 1 />
		
		</cfloop>
	
		<cfset arguments.stProgram.Distributors.ColumnList = lStructKeys />
	
		<!----------------************************** BROKER ******************************------------->
		<cfset oBroker.new(disInfo.BSA_FOODSERVICE_BROKERS_ID,1,1) />	
	
		<!---list of keys to strip--->
		<cfset lKeysToStrip = "new"/>
	
		<!---list of keys that need a suffix--->
		<cfset lKeysToSuffix = "BSA_FOODSERVICE_BROKERS_ID,AUTO_SELECTION"/>
		
		<!---loop through and strip out keys not needed--->
		<cfloop collection="#oBroker#" item="out">
		
			<!---set counter in case we have multiple instances--->
			<cfset brokCount = 1 />

			<!---set boolean type--->
			<cfset bIsKeyToStrip = ListFindNoCase(lKeysToStrip, out) />
		
			<!---set boolean type--->
			<cfset bIsKeyToSuffix = ListFindNoCase(lKeysToSuffix, out) />
		
			<cfif not bIsKeyToStrip>
		
				<cfif bIsKeyToSuffix>
					<cfset "arguments.stProgram.Brokers.#out#_#brokCount#" = #Evaluate("oBroker.#out#")# />
				<cfelse>
					<cfset "arguments.stProgram.Brokers.#out#" = #Evaluate("oBroker.#out#")# />
				</cfif>
			
			</cfif>
		
			<cfset brokCount = brokCount + 1 />
		
		</cfloop>

		<!----------------************************** LUMP SUM ******************************------------->
		
		<!---ignore if we have one record and the cost is 0--->
		<cfset bCreateLumpSum = true />
		
		<cfif qGetTradePlanCostsLumpSum.RecordCount eq 1 and qGetTradePlanCostsLumpSum.Cost lte 0>
			<cfset bCreateLumpSum = false />
		</cfif>
				
		<cfif bCreateLumpSum and lumpSumSum gt 0>
			
			<!---////////Lump Sum Components////---->
	
			<!---list of keys to strip--->
			<cfset lKeysToStrip = "new"/>
		
			<!---list of keys that need a suffix--->
			<cfset lKeysToSuffix = "DELETED,LUMP_SUM_AMOUNT,LUMP_SUM_DESCRIPTION,LUMP_SUM_NAME,PROGRAM_LUMP_SUM_NAME_ID,LUMP_SUM_VOLUME,PROGRAM_LUMP_SUM_ID"/>
	
			<!---set counter in case we have multiple instances--->
			<cfset lumpSumCount = 1 />
			<cfset lumpSumProdIDCount = 1 />
			
			<cfloop query="qGetTradePlanCostsLumpSum">
				
				<!---We have to set a name if one wasn't defined in the trade plan--->
<!--- 				<cfif not CompareNoCase(Name, "")>
					<cfset thisName = "Lump Sum Component" />
				<cfelse>
					<cfset thisName = name />
				</cfif> --->

				<cfset uuId = CreateUUID() />
				<cfset oLumpSumComponents.new(Cost,Program_Lump_Sum_Name_ID,0,"",0,uuId,qGetTradePlanCostsLumpSum.RecordCount) />
		
				<!---loop through and strip out keys not needed--->
				<cfloop collection="#oLumpSumComponents#" item="out">
	
					<!---set boolean type--->
					<cfset bIsKeyToStrip = ListFindNoCase(lKeysToStrip, out) />
			
					<!---set boolean type--->
					<cfset bIsKeyToSuffix = ListFindNoCase(lKeysToSuffix, out) />
			
					<cfif not bIsKeyToStrip>
				
						<cfif bIsKeyToSuffix>
							<cfset "arguments.stProgram.Lump_Sum_Components.#out#_#lumpSumCount#" = #Evaluate("oLumpSumComponents.#out#")# />
						<cfelse>
							<cfset "arguments.stProgram.Lump_Sum_Components.#out#" = #Evaluate("oLumpSumComponents.#out#")# />
						</cfif>
				
					</cfif>
			
				</cfloop>
		
				<cfset lumpSumCount = lumpSumCount + 1 />
		
				<!---////////Lump Sum Component Products////---->
	
				<!---list of keys to strip--->
				<cfset lCompProdKeysToStrip = "new,PROGRAM_LUMP_SUM_ID,PROGRAM_LUMP_SUM_PRODUCT_DATA_ID,CONTRACT_PRODUCTS_ID"/>
		
				<!---list of keys that need a suffix--->
				<cfset lCompProdKeysToSuffix = "CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_LUMP_SUM_ID,VOLUME,IS_GROUP"/>
	
				<!---set counter in case we have multiple instances--->
				<cfset lumpSumProdCount = 1 />
		
				<!---Loop through all products in trade plan--->
				<cfloop query="qGetProductList">
			
					<!---set the description id before going into nested loops--->
					<cfset typeGroupDescId = qGetProductList.TYPE_GROUP_DESC_ID />
					
					<!---set the record count to be product list count times the lump sum count--->
					<cfset compProdCount = qGetProductList.RecordCount * qGetTradePlanCostsLumpSum.RecordCount />
					
					<!---set the program volume for each product--->
					<CFSET prgrmProdVol = (quantity / prgmSpan) * 7>
					
					<cfset oLumpSumComponentProduct.new("#arguments.tradePlanId#_#Product_ID#",0,uuId,compProdCount,prgrmProdVol,0) />
					
					<!---we have to set PROGRAM_LUMP_SUM_ID key outside of the loop to maintain the relationship with Lump_Sum_Components--->
					<cfif isDefined("oLumpSumComponentProduct.PROGRAM_LUMP_SUM_ID")>
						<cfset "arguments.stProgram.Lump_Sum_Components.Products.PROGRAM_LUMP_SUM_ID_#lumpSumProdIDCount#" = oLumpSumComponentProduct.PROGRAM_LUMP_SUM_ID />
					</cfif>
					
					<!---we have to set contract_product_id key outside of the loop to maintain the relationship with Lump_Sum_Components--->
					<cfif isDefined("oLumpSumComponentProduct.CONTRACT_PRODUCTS_ID")>
						<cfset "arguments.stProgram.Lump_Sum_Components.Products.CONTRACT_PRODUCTS_ID_#lumpSumProdIDCount#" = oLumpSumComponentProduct.CONTRACT_PRODUCTS_ID />
					</cfif>
					
					<!---we have to set the volume key outside of the loop to maintain the relationship with Lump_Sum_Components--->
					<cfif isDefined("oLumpSumComponentProduct.VOLUME")>
						<cfset "arguments.stProgram.Lump_Sum_Components.Products.VOLUME_#lumpSumProdIDCount#" = 0 />
					</cfif>
								
					<!---loop through lump sum components and strip out keys not needed--->
					<cfloop collection="#oLumpSumComponentProduct#" item="out">
	
						<!---set boolean type--->
						<cfset bIsCompProdKeyToStrip = ListFindNoCase(lCompProdKeysToStrip, out) />
			
						<!---set boolean type--->
						<cfset bIsCompProdKeyToSuffix = ListFindNoCase(lCompProdKeysToSuffix, out) />
			
						<cfif not bIsCompProdKeyToStrip>
	
							<cfif bIsCompProdKeyToSuffix>
								<cfset "arguments.stProgram.Lump_Sum_Components.Products.#out#_#lumpSumProdCount#" = #Evaluate("oLumpSumComponentProduct.#out#")# />
							<cfelse>
								<cfset "arguments.stProgram.Lump_Sum_Components.Products.#out#" = #Evaluate("oLumpSumComponentProduct.#out#")# />
							</cfif>
							
						</cfif>
						
					</cfloop>
					
					<cfset lumpSumProdCount = lumpSumProdCount + 1 />
					<cfset lumpSumProdIDCount = lumpSumProdIDCount + 1 />
					
				</cfloop>
			
			</cfloop>
			
		</cfif>

		<!----------------************************** REBATES ******************************------------->
		
		<!---ignore if we have one record and the cost is 0--->
		<cfset bCreateRebate = true />
		<cfif qGetTradePlanCostsReb.RecordCount eq 1 and qGetTradePlanCostsReb.Cost lte 0>
			<cfset bCreateRebate = false />
		</cfif>
				
		<cfif bCreateRebate and rebSum gt 0>
			
			<!---loop through incentive costs and set up rebate components--->
			<cfloop query="qGetTradePlanCostsReb">
			
				<cfset rebateComp = oRebateComponent.set(compNameId=Program_Rebates_Component_Name_ID) />
				<cfset oRebate.stRebate.aComp[qGetTradePlanCostsReb.CurrentRow] = rebateComp />
				
				<!---set count--->
				<cfset rebProdCount = 1 />
				
				<!---set cost and uom before going into loop--->
				<cfset rebCost = cost />
				<!---set trade plan cost id before going into loop--->
				<cfset tpCostId = TRADE_PLAN_COSTS_ID />
				
				<!---if the percent id is 1 from trade plan then set it to 3 to conform to the unit of measure id in programs--->
				<cfif TRADE_PLAN_COST_PERCENT_ID eq 1>
					<cfset uomId = 3 />
				<cfelse>
					<cfset uomId = 2 />
				</cfif>
				
				<!---Loop through all products in trade plan--->
				<cfloop query="qGetProductList">
					
					<!---set the program volume for each product--->
					<CFSET prgrmProdVol = (quantity / prgmSpan) * 7>
					
					<!---set up rebate products--->
					<cfset rebateProduct = oRebateProduct.set(masterItemID=product_id,volume=prgrmProdVol,isGroup=0) />
					<cfset oRebate.stRebate.aProd[rebProdCount] = rebateProduct />
						
					<!---
					<cfif not tradePlan.isChecked(Trade_Plan_ID,TRADE_PLAN_COSTS_ID,typeGroupDescId)>
						<cfset setCost = 0 />
					<cfelse>
						<cfset setCost = cost />
					</cfif>
					--->
						
					<!---set up rebate component rates--->
					<!---if cost wasn't checked for this value then set it to zero--->
					<cfset tmpChechBit = this.isChecked(arguments.tradePlanId,tpCostId,TYPE_GROUP_DESC_ID) />
					<cfif not tmpChechBit>
						<cfset tmpRebCost = 0.00 />
					<cfelse>
						<cfset tmpRebCost = rebCost /> 
					</cfif>
					
					<cfset rebateCompRate = oRebateComponentRate.set(tmpRebCost,uomId) />
					<cfset oRebate.stRebate.aCompVal[rebProdCount][qGetTradePlanCostsReb.CurrentRow] = rebateCompRate />
					
					<cfset rebProdCount = rebProdCount +1 />
					
				</cfloop>
				
			</cfloop>
				
		</cfif>
	
		<!---dump data to file to use after program save--->
		<cfset oRebate.updateWddxDataFile(oRebate.stRebate,arguments.fileName) />

		<!----------------************************** PRODUCTS ******************************------------->
		
		<!---list of keys to strip--->
		<cfset lProdKeysToStrip = "new"/>
		
		<!---list of keys that need a suffix--->
		<cfset lProdKeysToSuffix = "CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_LUMP_SUM_ID,PRODUCT_TYPE_ID,BSA_FOODSERVICE_ITEMS_MASTER_ID"/>
		
		<cfset prodCount = 1 />			
		
		<!---Loop through all products in trade plan--->
		<cfloop query="qGetProductList">
		
			<cfset oContractProduct.new(Product_ID,"#arguments.tradePlanId#_#Product_ID#",3,0,qGetProductList.RecordCount) />
			
			<!---make a list ot the struct keys to work with--->
			<cfset lProdStructKeys = StructKeyList(oContractProduct) />
			
			<!---strip out keys to strip--->
			<cfloop index="strpProdIndx" list="#lProdKeysToStrip#">
				<cfset lProdStructKeys = ListDeleteAt(lProdStructKeys, ListFindNoCase(lProdStructKeys, strpProdIndx)) />
			</cfloop>
			
			<cfset lProdStructKeys = ListDeleteAt(lProdStructKeys, ListFindNoCase(lProdStructKeys, "RecordCount")) />
		
			<!---loop through contract products and strip out keys not needed--->
			<cfloop collection="#oContractProduct#" item="out">
				
				<!---set boolean type--->
				<cfset bIsProdKeyToStrip = ListFindNoCase(lProdKeysToStrip, out) />
			
				<!---set boolean type--->
				<cfset bIsProdKeyToSuffix = ListFindNoCase(lProdKeysToSuffix, out) />
			
				<cfif not bIsProdKeyToStrip>
			
					<cfif bIsProdKeyToSuffix>
						<cfset "arguments.stProgram.Products.#out#_#prodCount#" = Evaluate("oContractProduct.#out#") />
					<cfelse>
						<cfset "arguments.stProgram.Products.#out#" = Evaluate("oContractProduct.#out#") />
					</cfif>
				
				</cfif>
			
			</cfloop>
			
			<cfset arguments.stProgram.Products.COLUMNLIST = lProdStructKeys />
			
			<!---strip out process_flag if we find an instance of it--->
			<cfif ListFindNoCase(arguments.stProgram.Products.COLUMNLIST, "PRODUCT_PROCESS_FLAG")>
				<cfset arguments.stProgram.Products.COLUMNLIST = ListDeleteAt(arguments.stProgram.Products.COLUMNLIST, ListFindNoCase(arguments.stProgram.Products.COLUMNLIST, "PRODUCT_PROCESS_FLAG")) />
			</cfif>
			
			<cfset prodCount = prodCount + 1 />
			
		</cfloop>
		
		<cfreturn arguments.stProgram />

	</cffunction>
	
</cfcomponent>