<!---
	Name:
		update_trade_plan_save.cfm
	Created By:
		Tim Ford 04/10/2003 
	Description:
		File is responsible for inserting trad plan reports
--->
<cftry>
	<!---TODO: Guard against dup records on page refresh--->

	<!---Group queries as a transaction to maintain data integrity and prevent partial inserts--->
	<cftransaction>


		<cfset TradePlanUUID = #Form.Trade_Plan_ID# />
		
		<!---Update Distributor--->
		<cfquery name="qUpdateTradePlan" datasource="#application.datasource#">
			UPDATE 	Trade_Plan
			SET		Trade_Plan_Title =  '#tradePlanTitle#',		
					Distributor_ID = '#Distributor_List#',
					Updated_Date = #now()#,
					Updated_By = '#request.AccessStructure.user_id#',
					Notes = '#Notes#',
					Start_Date = '#form.start_date#',
					End_Date = '#form.end_date#',
					Forecast_ID = '#form.Forecast_ID#'
			WHERE	Trade_Plan_ID = '#TradePlanUUID#'	
		</cfquery>
		
		<cfquery name="qDeleteTradePlanItems" datasource="#application.datasource#">
			DELETE Trade_Plan_Items
			where Trade_Plan_ID = '#TradePlanUUID#'	
		</cfquery>
		
		<!---Loop through product list an insert for each product--->
		<cfset prodCounter = 0>
		<cfloop index="index" from="0" to="#Evaluate("#prodCount#-1")#">
			
			<cfset tempProd = Evaluate("planProduct#index#")>
			<cfset tempPP = Evaluate("proposedPrice#index#")>
			<cfset tempQty = Evaluate("qty#index#")>
			
			<!---Get item/product class id--->
			<cfquery name="qGetItemClassID" datasource="#application.datasource#">
				SELECT 	Type_Group_Desc.Type_Group_Desc_ID
				FROM	BSA_Foodservice_Items_Master
				INNER JOIN Type_Group_Desc
				ON
				(
					(BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID)
				)
				WHERE 	BSA_Foodservice_Items_Master.Deleted = 0
				AND	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#tempProd#'
			</cfquery>
			
			<cfset prodCounter = prodCounter +1 />
			
			<cfquery name="qInsertTradePlanItems" datasource="#application.datasource#">
				INSERT INTO Trade_Plan_Items
					(Trade_Plan_ID, Product_ID, Type_Group_Desc_ID, Proposed_Price, Quantity)
				VALUES
					('#TradePlanUUID#','#tempProd#', '#qGetItemClassID.Type_Group_Desc_ID#', #tempPP#, #TempQty#)	
			</cfquery>
		
		</cfloop>

		<cfquery name="qDeleteTradePlanCosts" datasource="#application.datasource#">
			DELETE Trade_Plan_Costs
			where Trade_Plan_ID = '#TradePlanUUID#'	
		</cfquery>
		
		<cfquery name="qDeleteTradePlanCosts" datasource="#application.datasource#">
			DELETE Trade_Plan_Item_Cost
			where Trade_Plan_ID = '#TradePlanUUID#'	
		</cfquery>
		
		<!---Create 2 lists for each cost type--->
		<cfset lIncCost = "" />
		<cfset lMiscCost = "" />
		<cfset lLmpSumCost = "" />
		
		<!---Create counters--->
		<cfset incCostCount = 0 />
		<cfset miscCostCount = 0 />
		<cfset lmpSumCostCount = 0 />

		<!---Loop through the form field names to determine how many costs were added--->
		<cfloop index="index" list="#Form.FieldNames#">
		
			<!---find instances of incentive cost--->
			<cfset incCost = ListContainsNoCase(index, "incentiveCostNameId_") />
			<cfif incCost>
				<cfset lIncCost = ListAppend(lIncCost, ListLast(index, "_")) />
				<!--- <cfset incCostCount = incCostCount+1 /> --->
			</cfif>
		
			<!---find instances of misc cost--->
			<cfset miscCost = ListContainsNoCase(index, "miscCostName_") />
			<cfif miscCost>
				<cfset lMiscCost = ListAppend(lMiscCost, ListLast(index, "_")) />
				<!--- <cfset miscCostCount = miscCostCount+1 /> --->		
			</cfif>
			
			<!---find instances of lump sum cost--->
			<cfset lmpSumCost = ListContainsNoCase(index, "lumpSumCostNameId_") />
			<cfif lmpSumCost>
				<cfset lLmpSumCost = ListAppend(lLmpSumCost, ListLast(index, "_")) />
				<!--- <cfset lmpSumCostCount = lmpSumCostCount+1 /> --->		
			</cfif>
			
		</cfloop>
	
		
		<!---Loop through the list count for incentive costs and insert values--->	
		<cfloop index="index" list="#lIncCost#">
	
			<cfset costNameId = Evaluate("incentiveCostNameId_#index#")>
			<cfset cost = Evaluate("incentiveCost_#index#")>
			<cfset percDoll = Evaluate("incentivePercentDollar_#index#")>
			<cfset costType = 1>
			
			<!---check to see if the entry is valid--->
			<cfset bIsValidEntry = true />
			
			<cfif not costNameId or not CompareNoCase(trim(cost), "") or not cost>
				<cfset bIsValidEntry = false />
			</cfif> 
			
			<!---if the cost entry is valid then let's insert--->
			<cfif bIsValidEntry>
			
				<cfquery name="qInsertTradePlanCost" datasource="#application.datasource#">
					INSERT INTO Trade_Plan_Costs
						(Trade_Plan_ID, Program_Rebates_Component_Name_ID, Cost, Trade_Plan_Cost_Percent_ID, Trade_Plan_Cost_Type_ID)
					VALUES
						('#TradePlanUUID#', #costNameId#, '#cost#', '#percDoll#', '#costType#')	
				</cfquery>
					
				<!---Insert check box bits--->
				<cfset typeCount = 0 />
				
				<cfloop index="type" list="#Form.typeGroupList#">
	
	
					<cfif isDefined("incentiveCostCalc#typeCount#_#index#")>
						<cfset Check_Bit = 1 />
					<cfelse>
						<cfset Check_Bit = 0 />
					</cfif>
		
					<cfquery name="qInsertTradePlanItemCost" datasource="#application.datasource#">
						INSERT INTO Trade_Plan_Item_Cost
							(Type_Group_Desc_ID, Trade_Plan_Costs_ID, Trade_Plan_ID, Check_Bit)
						VALUES
							('#type#', '#qInsertTradePlanCost.Trade_Plan_Costs_ID#', '#TradePlanUUID#', #Check_Bit#)
					</cfquery>
						
					<cfset typeCount = typeCount +1 />
					
				</cfloop>	
			
			</cfif>
			
		</cfloop>
	
		<!---Loop through the list count for misc costs and insert values--->
		<cfloop index="index" list="#lMiscCost#">
	
			<cfset costName = Evaluate("miscCostName_#index#")>
			<cfset cost = Evaluate("miscCost_#index#")>
			<cfset percDoll = Evaluate("miscPercentDollar_#index#")>
			<cfset costType = 2>
			
			<!---check to see if the entry is valid--->
			<cfset bIsValidEntry = true />
			
			<cfif not CompareNoCase(trim(costName), "") or not CompareNoCase(trim(cost), "") or not cost>
				<cfset bIsValidEntry = false />
			</cfif> 
			
			<!---if the cost entry is valid then let's insert--->
			<cfif bIsValidEntry>
			
				<cfquery name="qInsertTradePlanCost" datasource="#application.datasource#">
					INSERT INTO Trade_Plan_Costs
						(Trade_Plan_ID, Name, Cost, Trade_Plan_Cost_Percent_ID, Trade_Plan_Cost_Type_ID)
					VALUES
						('#TradePlanUUID#', '#costName#', '#cost#', '#percDoll#', '#costType#')	
				</cfquery>
					
				<!---Insert check box bits--->
				<cfset typeCount = 0 />
				<cfloop index="type" list="#Form.typeGroupList#">
					
					<cfif isDefined("miscCostCalc#typeCount#_#index#")>
						<cfset Check_Bit = 1 />
					<cfelse>
						<cfset Check_Bit = 0 />
					</cfif>
		
					<cfquery name="qInsertTradePlanItemCost" datasource="#application.datasource#">
						INSERT INTO Trade_Plan_Item_Cost
							(Type_Group_Desc_ID, Trade_Plan_Costs_ID, Trade_Plan_ID, Check_Bit)
						VALUES
							('#type#', '#qInsertTradePlanCost.Trade_Plan_Costs_ID#', '#TradePlanUUID#', #Check_Bit#)
					</cfquery>
						
					<cfset typeCount = typeCount +1 />
					
				</cfloop>
				
			</cfif>
			
		</cfloop>
		
		<!---Loop through the list count for lump sum costs and insert values--->	
		<cfloop index="index" list="#lLmpSumCost#">
		
			<!--- <cfset costName = Evaluate("lumpSumCostName_#index#")> --->
			<cfset costNameId = Evaluate("lumpSumCostNameId_#index#")>
			<cfset cost = Evaluate("lumpSumCost_#index#")>
			<cfset costType = 3>
			
			<!---check to see if the entry is valid--->
			<cfset bIsValidEntry = true />
			
			<cfif not costNameId or not CompareNoCase(trim(cost), "") or not cost>
				<cfset bIsValidEntry = false />
			</cfif> 
			
			<!---if the cost entry is valid then let's insert--->
			<cfif bIsValidEntry>
			
				<cfquery name="qInsertTradePlanCost" datasource="#application.datasource#">
					INSERT INTO Trade_Plan_Costs
						(Trade_Plan_ID, Program_Lump_Sum_Name_ID, Cost, Trade_Plan_Cost_Type_ID)
					VALUES
						('#TradePlanUUID#', #costNameId#, '#cost#', '#costType#')	
				</cfquery>
			
			</cfif>
			
		</cfloop>
	
	</cftransaction>
	
	<cfcatch type="database">
		<cfdump label="Database Error" var="#cfcatch#">
	</cfcatch>
	
</cftry>
