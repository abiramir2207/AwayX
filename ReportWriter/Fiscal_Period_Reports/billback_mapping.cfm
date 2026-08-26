 <!---Deletes any pre-existing information for the period from the table--->
<cfset useLakebaseForDeletePrior = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_billback_summary")>
<cfif useLakebaseForDeletePrior>
	<cftry>
		<cfset application.oLakebase.deleteRows("rp_billback_summary", {
			"fiscal_period_start_date" = "eq.#Fiscal_Period_Start_Date#",
			"fiscal_period_end_date" = "eq.#Fiscal_Period_End_Date#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDeletePrior = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePrior>
<cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Billback_Summary
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
</cfquery>
</cfif>

<!---Gets all distinct records--->
<!---item/distributor--->
<cfquery name="BillbackSummary" datasource="#application.datasource#">
SELECT DISTINCT Distributor_ID, Shared_Ship_To, Legacy_Ship_To, Item_Number, BB_Summary_Type, sum(Billed_Back) AS Total_Billed_Back
FROM RP_Billback_Table
WHERE RP_Billback_Table.Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND RP_Billback_Table.Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
GROUP BY Distributor_ID, Shared_Ship_To, Legacy_Ship_To, Item_Number, BB_Summary_Type
</cfquery>

<!---Loop through distinct records above--->
	<cfloop query="BillbackSummary">
		<cfset useLakebaseForInsertIntoBillbackSummary = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_billback_summary")>
<cfif useLakebaseForInsertIntoBillbackSummary>
	<cftry>
		<cfset application.oLakebase.insertRow("rp_billback_summary", {
			"fiscal_period_start_date" = "#Fiscal_Period_Start_Date#",
			"fiscal_period_end_date" = "#Fiscal_Period_End_Date#",
			"legacy_ship_to" = "#Legacy_Ship_To#",
			"shared_ship_to" = "#Shared_Ship_To#",
			"distributor_id" = "#Distributor_ID#",
			"item_number" = "#Item_Number#",
			"total_billed_back" = "#Total_Billed_Back#",
			"bb_summary_type" = "#BB_Summary_Type#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoBillbackSummary = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoBillbackSummary>
<cfquery name="InsertIntoBillbackSummary" datasource="#application.datasource#">
		INSERT INTO RP_Billback_Summary
		(
			Fiscal_Period_Start_Date,
			Fiscal_Period_End_Date,
			Legacy_Ship_To,
			Shared_Ship_To,
			Distributor_ID,
			Item_Number,
			Total_Billed_Back,
			BB_Summary_Type
		)
		VALUES
		(
			'#Fiscal_Period_Start_Date#',
			'#Fiscal_Period_End_Date#',
			'#Legacy_Ship_To#',
			'#Shared_Ship_To#',
			'#Distributor_ID#',
			'#Item_Number#',
			'#Total_Billed_Back#',
			'#BB_Summary_Type#'
		)
		</cfquery>
</cfif>
	
	</cfloop>
	<!--- <cfset useLakebaseForGetAll = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_billback_summary")>
<cfif useLakebaseForGetAll>
	<cftry>
		<cfset GetAll = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_billback_summary", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAll = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAll>
<cfquery name="GetAll" datasource="#application.datasource#">
	SELECT * FROM RP_Billback_Summary
	</cfquery>
</cfif>
	
	<cfdump var="#GetAll#"> --->
