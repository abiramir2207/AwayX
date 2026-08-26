
<!--- Only create the adjustment if the amount is greater than 0 -- following coding standards, don't add GT 0 since bln evaluation will work --->
<cfif GetClosureInfo.DD_Amount>
<cfset useLakebaseForCreateAdjustment = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_adjustment")>
<cfif useLakebaseForCreateAdjustment>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_adjustment", {
			"billback_id" = Deduction_ID,
			"billback_payee_type_id" = 1,
			"payee_id" = GetClosureInfo.Distributor_ID,
			"adjustment_amount" = GetClosureInfo.DD_Amount,
			"adjustment_source" = 2
		})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCreateAdjustment = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreateAdjustment>
<cfquery name="CreateAdjustment" datasource="#application.datasource#">
INSERT INTO BB_Adjustment
	(
		Billback_ID,
		Billback_Payee_Type_ID,
		Payee_ID,
		Adjustment_Amount,
		Adjustment_Source
	)
	VALUES
	(
		'#Deduction_ID#',
		1,
		'#GetClosureInfo.Distributor_ID#',
		'#GetClosureInfo.DD_Amount#', 
		2
	)
</cfquery>
</cfif>
</cfif>

  <!---Update some deduction info--->
<cfset useLakebaseForUpdateDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDeduction>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{
				"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"dd_closed_by" = request.AccessStructure.User_ID,
				"dd_resolution_code" = ReasonCode,
				"dd_status" = 4,
				"dd_closure_method" = 3
			}
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateDeduction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDeduction>
<cfquery name="UpdateDeduction" datasource="#application.datasource#">
UPDATE Deductions
SET DD_Date_Closed = getdate(),
	DD_Closed_By = '#request.AccessStructure.User_ID#',
	DD_Resolution_Code = '#ReasonCode#',
	DD_Status = 4, 
	DD_Closure_Method = 3
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>  
</cfif>

<!---Close any reminders associated with this--->
<cfset useLakebaseForCloseReminders = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
<cfif useLakebaseForCloseReminders>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_reminders",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "deleted" = 1 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCloseReminders = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCloseReminders>
<cfquery name="CloseReminders" datasource="#application.datasource#">
UPDATE DD_Reminders
SET Deleted = 1
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

