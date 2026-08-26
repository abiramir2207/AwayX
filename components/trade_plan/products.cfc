<!---
	Name:
		products.cfc
	Created By:
		Tim Ford 04/29/2003 
	Description:
		Products components
--->

<cfcomponent>

	<cffunction name="getProducts" access="public" returntype="query">
		
		<cfargument name="lProductIds" type="string" required="true" default="">
		
			<cfquery name="qGetProducts" datasource="#application.datasource#">
				SELECT 	Type_Group_Desc.Type_Group_Desc,
						Type_Group_Desc.Type_Group_Desc_ID,
						BSA_Foodservice_Items_Master.Description,
						BSA_Foodservice_Items_Master.Net_Weight,
						BSA_Foodservice_Items_Master.Item,
						BSA_Foodservice_Items_Master.UPC,
						ROUND(BSA_Foodservice_Items_Master.Curr_Cost, 2) as Curr_Cost,
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				FROM	BSA_Foodservice_Items_Master

				INNER JOIN Type_Group_Desc
				ON
				(
					(BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID)
				)
				WHERE 	BSA_Foodservice_Items_Master.Deleted = 0
				AND		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID in (#replace(listqualify(arguments.lProductIds, "'"), '"', "'")#)
				AND		active_code = 'A'
				ORDER BY Type_Group_Desc.Type_Group_Desc
		</cfquery>
			
		<cfreturn qGetProducts>
			
	</cffunction>
	
	<cffunction name="getProductTypes" access="public" returntype="query">
		
		<cfargument name="lProductIds" type="string" required="true" default="">
		
			<cfquery name="qGetProductTypes" datasource="#application.datasource#">
				SELECT 	DISTINCT(Type_Group_Desc.Type_Group_Desc),
						Type_Group_Desc.Type_Group_Desc_ID
				FROM	BSA_Foodservice_Items_Master
				INNER JOIN Type_Group_Desc
				ON
				(
					(BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID)
				)
				WHERE 	BSA_Foodservice_Items_Master.Deleted = 0
				AND	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID in (#replace(listqualify(arguments.lProductIds, "'"), '"', "'")#)
				AND	active_code = 'A'

				ORDER BY Type_Group_Desc.Type_Group_Desc
			</cfquery>
			
		<cfreturn qGetProductTypes>
			
	</cffunction>
	
	<cffunction name="getFormRevTotl" access="public" output="false" returntype="numeric" displayname="Get Revenue Total" hint="Gets the total amount for revenue from the form scope.">
		
		<cfargument name="count" type="numeric" required="true" default="">
		
		<cfset revTotl = 0 />
		
		<!---Get the revenue and volume total for mix columns--->
		<cfloop index="index" from="0" to="#arguments.count#">
			<cfif isDefined("form.proposedPrice#index#") and isDefined("form.qty#index#")>
				<cfset revTotl = revTotl + (Evaluate("form.proposedPrice#index#") * Evaluate("form.qty#index#")) />
			</cfif>
		</cfloop>
		
		<cfreturn revTotl />
		
	</cffunction>
	
	<cffunction name="getFormVolTotl" access="public" output="false" returntype="numeric" displayname="Get Revenue Total" hint="Gets the total amount for revenue from the form scope.">
		
		<cfargument name="count" type="numeric" required="true" default="">
		<cfargument name="items" type="string" required="true" default="">

		<cfset volTotl = 0 />
		
		<!---Get the revenue and volume total for mix columns--->
		<cfloop index="index" from="0" to="#arguments.count#">
			<cfif isDefined("form.qty#index#")>
				<cfset volTotl = volTotl + (Evaluate("qty#index#") * ListGetAt(arguments.items, index+1)) />
			</cfif>
		</cfloop>
		
		<cfreturn volTotl />
		
	</cffunction>
	
	<cffunction access="public" name="getTotals" output="false" returntype="query">
		
		<cfargument name="tradePlanId" type="string" required="true" default="">
		
		<!---get total values--->
		<cfquery name="qGetTotals" datasource="#application.datasource#">
			SELECT	SUM(Trade_Plan_Items.Quantity * CAST(BSA_Foodservice_Items_Master.Net_Weight as float)) as Total_Volume,
					SUM(Trade_Plan_Items.Quantity * Trade_Plan_Items.Proposed_Price) as Total_Revenue,
					SUM(Trade_Plan_Items.Quantity) as Total_Volume_CS
			FROM 	Trade_Plan_Items

			INNER JOIN trade_plan
			ON
			(	
				Trade_Plan.trade_plan_id = Trade_Plan_Items.trade_plan_id
			)

			INNER JOIN BSA_Foodservice_Items_Master
			ON
			(
				Trade_Plan_Items.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			) 
	
			WHERE 	trade_plan.trade_plan_id = '#Trade_Plan_ID#'
	
		</cfquery>
	
		<cfreturn qGetTotals />
		
	</cffunction>
	
	<cffunction name="getProductList" access="public" returntype="query">
	
		<cfargument name="tradePlanId" type="string" required="true" default="">
	
		<cfquery name="qGetProductList" datasource="#application.datasource#">
			SELECT 	Trade_Plan_Items.Type_Group_Desc_ID,	
					Trade_Plan_Items.product_ID,
					Trade_Plan_Items.Proposed_Price,
					Trade_Plan_Items.Quantity
			FROM 	Trade_Plan_Items
		
			INNER JOIN BSA_Foodservice_Items_Master
			ON
			(
				Trade_Plan_Items.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			) 	
			WHERE 	Trade_Plan_Items.trade_plan_id = '#arguments.tradePlanId#'
			<cfif isDefined("form.Product_List") and Len(form.Product_List)>
			AND 	product_ID in (#replace(listqualify(Product_List, "'"), '"', "'")#)
			</cfif>
		</cfquery>
		
		<cfreturn qGetProductList />
	
	</cffunction>
		
</cfcomponent>