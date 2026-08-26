<!---Delete prio--->
<!--- <cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Distributor_Summary
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
</cfquery>  --->

<!---Want to do this for each set of report types.--->
<cfset useLakebaseForGetTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_type")>
<cfif useLakebaseForGetTypes>
	<cftry>
		<cfset GetTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_type", {
				"deleted" = "eq.0",
				"select" = "rp_type_id"
			}), "rp_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTypes>
<cfquery name="GetTypes" datasource="#application.datasource#">
SELECT DISTINCT RP_Type_ID FROM RP_Type WHERE Deleted = 0
</cfquery>
</cfif>


<cfloop query="GetTypes">

<cfset TYPEID = GetTypes.RP_Type_ID>

<!---Get distributor summary--->
<cfset useLakebaseForGetDistributorSummary = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_mapping_table")>
<cfif useLakebaseForGetDistributorSummary>
	<cftry>
		<cfset GetDistributorSummary = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_mapping_table", {
				"record_type" = "eq.#TYPEID#",
				"select" = "legacy_ship_to,shared_ship_to,distributor_id"
			}), "legacy_ship_to,shared_ship_to,distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributorSummary = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorSummary>
<cfquery name="GetDistributorSummary" datasource="#application.datasource#">
SELECT DISTINCT Legacy_Ship_To, Shared_Ship_To, Distributor_ID
FROM RP_Mapping_Table
WHERE Record_Type = #TYPEID#
</cfquery>
</cfif>
<!--- 
Distributor Summary:
<cfdump var="#GetDistributorSummary#"> --->

<!---Loop through all distinct distributors--->
<cfloop query="GetDistributorSummary">

	<!---Get sum of billbacks for the distributor--->
	<cfquery name="TotalBillback" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Billed_Back, 0)), 0) AS Total_Billed_Back FROM RP_Billback_Table
	WHERE Distributor_ID = '#Distributor_ID#'
	AND BB_Summary_Type = #TYPEID#
	</cfquery>
	
	<!---Get sum of dollars earned for distributor--->
	<cfquery name="TotalEarnings" datasource="#application.datasource#">
	SELECT isnull(SUM(isnull(Payment_Amount, 0)), 0) AS Total_Earned, isnull(SUM(isnull(Rebate_Sum, 0)), 0) AS Total_Allowance
	FROM RP_Mapping_Table
	WHERE Distributor_ID = '#Distributor_ID#'	
	AND RP_Mapping_Table.Record_Type = #TYPEID#		 
	</cfquery>
	
	<cfquery name="TotalSales" datasource="#application.datasource#">
		SELECT isnull(SUM(isnull(Total_Eligible_Trade, 0)), 0) AS Gross_Sales 
		FROM RP_Mapping_Table
		WHERE Distributor_ID = '#Distributor_ID#'	
		AND Record_Type = #TYPEID#
			AND RP_Mapping_Table_ID = (SELECT TOP 1 RMT.RP_Mapping_Table_ID FROM RP_Mapping_Table RMT
						WHERE RMT.Record_Type = #TYPEID#	AND RMT.Invoice_Detail_ID = RP_Mapping_Table.Invoice_Detail_ID
						)	
		</cfquery>
		
		<!--- <cfdump var="#TotalSales#"> --->
	
	<cfset Total_To_Pay = Totalearnings.Total_Earned - TotalBillback.Total_Billed_Back>
	
	<cfset useLakebaseForInsertValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_distributor_summary")>
<cfif useLakebaseForInsertValue>
	<cftry>
		<cfset application.oLakebase.insertRow("rp_distributor_summary", {
			"fiscal_period_start_date" = "#Fiscal_Period_Start_Date#",
			"fiscal_period_end_date" = "#Fiscal_Period_End_Date#",
			"legacy_ship_to" = "#Legacy_Ship_To#",
			"shared_ship_to" = "#Shared_Ship_To#",
			"total_dist_billed_back" = "#TotalBillback.Total_Billed_Back#",
			"total_dist_earned" = "#Totalearnings.Total_Earned#",
			"payment_amount" = "#Total_To_Pay#",
			"distributor_id" = "#Distributor_ID#",
			"total_allowance" = "#Totalearnings.Total_Allowance#",
			"gross_sales" = "#TotalSales.Gross_Sales#",
			"type" = "#TYPEID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertValue>
<cfquery name="InsertValue" datasource="#application.datasource#">
	INSERT INTO RP_Distributor_Summary
	(
		Fiscal_Period_Start_Date,
		Fiscal_Period_End_Date, 
		Legacy_Ship_To,
		Shared_Ship_To,
		Total_Dist_Billed_Back,
		Total_Dist_Earned,
		Payment_Amount,
		Distributor_ID, 
		Total_Allowance,
		Gross_Sales,
		Type
	)
	VALUES
	(
		'#Fiscal_Period_Start_Date#',
		'#Fiscal_Period_End_Date#',
		'#Legacy_Ship_To#',
		'#Shared_Ship_To#',
		'#TotalBillback.Total_Billed_Back#',
		'#Totalearnings.Total_Earned#',
		'#Total_To_Pay#',
		'#Distributor_ID#',
		'#Totalearnings.Total_Allowance#',
		'#TotalSales.Gross_Sales#',
		'#TYPEID#'
	)
	</cfquery>
</cfif>
	
</cfloop>

<!---For each type--->
</cfloop>

