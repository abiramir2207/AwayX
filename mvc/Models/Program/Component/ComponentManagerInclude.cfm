		
		
		
<cfoutput query="qGetDistributors" >
	<cfset sVar = "indx2.rateCust_" & qGetDistributors.Shr_Ship_To />
	<cfif isDefined(sVar) AND ISNUMERIC(indx2["rateCust_" & qGetDistributors.Shr_Ship_To]) AND indx2["rateCust_" & qGetDistributors.Shr_Ship_To] GT 0 >
		<!---<cfset this.dmp(indx2["rateCust_" & qGetDistributors.Shr_Ship_To]) />--->
		<!---<cfset this.dmp(indx2["rateCust_" & qGetDistributors.Shr_Ship_To]) />  AND indx2["rateCust_" & qGetDistributors.Shr_Ship_To] GT 0--->	
			<cfquery name="qAddFixedFreightData#qGetDistributors.Shr_Ship_To#" datasource="#application.datasource#">
			INSERT INTO Program_Fixed_Freight_Rates
				(	Product_id,
					Customer_id,
					Program_id,
					Component_Name_Id,
					Delivered_Price,
					Freight_Rate,
					FOB_Price,
					Freight_UOM,
					Deleted
					--Paid_To
					)
			VALUES
				(
					<cfqueryparam value="#indx2.itemGuid#" cfsqltype="cf_sql_varchar" />, 
					<cfqueryparam value="#qGetDistributors.BSA_Foodservice_Customers_ID#" />,
					<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#indx.componentId#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#indx2["rateCust_" & qGetDistributors.Shr_Ship_To]#" cfsqltype="cf_sql_decimal" scale="4" />,
					<!--- Customer Rate - Component Rate(Delivered)  = Freight_Rate --->
					<cfqueryparam value="#indx2["rateCust_" & qGetDistributors.Shr_Ship_To]-indx2.rate#" cfsqltype="cf_sql_decimal" scale="4" />,
					<cfqueryparam value="#indx2.rate#" cfsqltype="cf_sql_decimal" scale="4" />,
					<cfqueryparam value="#indx2.uom.uomId#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="0" cfsqltype="cf_sql_bit" />
					<!--- ,<cfqueryparam value="#indx2.uom.uomId#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />--->
				)
		</cfquery>
	
	</cfif>
</cfoutput>
		
		
		
		
		
	