<!---Delete prio--->
<!--- <cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Distributor_Summary
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
</cfquery>  --->

<!---Want to do this for each set of report types.--->
<cfquery name="GetTypes" datasource="#application.datasource#">
SELECT DISTINCT RP_Type_ID FROM RP_Type WHERE Deleted = 0
</cfquery>


<cfloop query="GetTypes">

<cfset TYPEID = GetTypes.RP_Type_ID>

<!---Get distributor summary--->
<cfquery name="GetDistributorSummary" datasource="#application.datasource#">
SELECT DISTINCT Legacy_Ship_To, Shared_Ship_To, Distributor_ID
FROM RP_Mapping_Table
WHERE Record_Type = #TYPEID#
</cfquery>
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
	
</cfloop>

<!---For each type--->
</cfloop>

