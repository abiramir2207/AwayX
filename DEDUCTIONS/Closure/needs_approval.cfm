

<!---Update to RFA--->

<cfset useLakebaseForSetToRFA = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForSetToRFA>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "dd_status" = 3 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForSetToRFA = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSetToRFA>
	<cfquery name="SetToRFA" datasource="#application.datasource#">
	UPDATE Deductions
	SET DD_Status = 3
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<cfset useLakebaseForInsertIntoRFATable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rfa")>
<cfif useLakebaseForInsertIntoRFATable>
	<cftry>
		<cfset application.oLakebase.insertRow("dd_rfa", {
			"deduction_id" = Deduction_ID,
			"date_requested" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
			"requested_by" = request.AccessStructure.User_ID,
			"reason_code" = ReasonCode,
			"closing_method" = ClosingAction,
			"deleted" = 0
		})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForInsertIntoRFATable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoRFATable>
	<cfquery name="InsertIntoRFATable" datasource="#application.datasource#">
	INSERT INTO DD_RFA
	(
		Deduction_ID,
		Date_Requested,
		Requested_By,
		Reason_Code,
		Closing_Method
	)
	VALUES
	(
		'#Deduction_ID#',
		#Now()#,
		'#request.AccessStructure.User_ID#',
		'#ReasonCode#',
		'#ClosingAction#'
	)
	</cfquery>
</cfif>

<cfoutput>
<script>
window.parent.location.href = '/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#'
</script>
</cfoutput>
<cfabort>