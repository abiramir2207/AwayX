<Cfif ComponentType IS 1>

<!----For normal--->
<cfparam name="HasSeperateVolume" 	default="0">
<cfparam name="TotalVolume"			default="0">

	<cfquery name="DoesThisCompHaveAChild" datasource="#application.datasource#">
	SELECT Program_Growth_Component_ID AS Volume_Component_ID
	FROM Program_Growth_Components
	WHERE Parent_ID = '#ComponentID#'
	AND Deleted = 0
	</cfquery>			

	<cfif DoesThisCompHaveAChild.Recordcount GT 0>
		<cfset HasSeperateVolume = 1>
	</cfif>

	<cfquery name="GetItemIncomeInformation" datasource="#application.datasource#">
	SELECT 	ISNULL(SUM(Cast(Invoice_Detail.Sales_Dollars AS float)), 0) -
			ISNULL(SUM(Cast(Invoice_Detail.Off_Invoice_Dollars AS float)), 0) AS Total_Earned,
			ISNULL(SUM(Cast(Invoice_Detail.Pounds_Invoiced AS float)), 0) AS Total_Pounds,
			ISNULL(SUM(Cast(Invoice_Detail.Cases_Invoiced AS float)), 0) AS Total_Cases
	FROM Program_Growth_Components
		INNER JOIN GetItemsForGrowthComponent
		ON GetItemsForGrowthComponent.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
		INNER JOIN Invoice_Header
		ON BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
		<cfif BB_Tolerance_TET IS 1>
			AND (	
				Invoice_Header.Invoice_Date >= '#dateformat(StartDate)#'
				AND Invoice_Header.Invoice_Date <= '#dateformat(EndDate)#'
			)
			<cfelse>
			AND (	
				Invoice_Header.Ship_Date >= '#dateformat(StartDate)#'
				AND	Invoice_Header.Ship_Date <= '#dateformat(EndDate)#'
			)
			</cfif>
		AND Invoice_Header.Deleted = 0
		INNER JOIN Invoice_Detail
		ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
		<!---Only join on Item ID if the component isn't all items--->
		AND (GetItemsForGrowthComponent.Product_Group_Level_ID = 1
		OR Invoice_Detail.BSA_Foodservice_Items_Master_ID = GetItemsForGrowthComponent.BSA_Foodservice_Items_Master_ID)
		AND Invoice_Detail.Deleted = 0
	WHERE 
	<!---If it has a seperate volume component, use the main component ID as the parent id--->
	<cfif HasSeperateVolume IS 1>Program_Growth_Components.Parent_ID<cfelse>Program_Growth_Components.Program_Growth_Component_ID</cfif> = '#ComponentID#'
	AND Program_Growth_Components.Deleted = 0
	</cfquery>

	
	<cfquery name="GetTier" datasource="#application.datasource#">
	SELECT Program_Growth_Component_Tier_ID, Tier_Number, Range_Start, Range_End, '' AS RS_Detail, '' AS RE_Detail, Growth_Amount
	FROM Program_Growth_Component_Tiers
	WHERE Program_Growth_Component_ID = '#Component_ID#'
	AND Range_Start <= #GetItemIncomeInformation.Total_Earned# 
	ORDER BY Tier_Number
	</cfquery>
	

	<cfset TierCount = GetTier.Recordcount>
	<cfset RateType = GetComponents.Rate_Type>
	<cfset TierAttained = GetTier.Recordcount>
	
	<cfif UOM IS 1>
		<cfset TotalVolume = TotalVolume + GetItemIncomeInformation.Total_Cases>
	<cfelse>
		<cfset TotalVolume = TotalVolume + GetItemIncomeInformation.Total_Pounds>
	</cfif>

</CFIF>