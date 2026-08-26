<!---
	Name:
		delete_trade_plan.cfm
	Created By:
		Tim Ford 05/01/2003 
	Description:
		File is responsible for deleting trade plan reports
--->
<cftry>

	<!---Group queries as a transaction to maintain data integrity and prevent partial transactions--->
	<cftransaction>
	
		<!---Update Distributor--->
		<cfquery name="qDeleteTradePlan" datasource="#application.datasource#">
			delete 	Trade_Plan
			WHERE	Trade_Plan_ID = '#Trade_Plan_ID#'	
		</cfquery>
		
		<cfquery name="qDeleteTradePlanItems" datasource="#application.datasource#">
			DELETE Trade_Plan_Items
			where Trade_Plan_ID = '#Trade_Plan_ID#'	
		</cfquery>
		
		<cfquery name="qDeleteTradePlanCosts" datasource="#application.datasource#">
			DELETE Trade_Plan_Costs
			where Trade_Plan_ID = '#Trade_Plan_ID#'	
		</cfquery>
		
		<cfquery name="qDeleteTradePlanCosts" datasource="#application.datasource#">
			DELETE Trade_Plan_Item_Cost
			where Trade_Plan_ID = '#Trade_Plan_ID#'	
		</cfquery>
	
	</cftransaction>
	
	<cfcatch type="database">
		<cfdump label="Database Error" var="#cfcatch#">
	</cfcatch>
	
</cftry>
