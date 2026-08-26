 <!---Deletes any pre-existing information for the period from the table--->
<cfquery name="DeletePrior" datasource="#application.datasource#">
DELETE FROM RP_Billback_Summary
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
</cfquery>

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
	
	</cfloop>
	<!--- <cfquery name="GetAll" datasource="#application.datasource#">
	SELECT * FROM RP_Billback_Summary
	</cfquery>
	
	<cfdump var="#GetAll#"> --->
