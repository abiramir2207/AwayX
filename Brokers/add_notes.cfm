

<!--- Save the notes --->
<cfset useLakebaseForSaveNotesData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan_notes")>
<cfif useLakebaseForSaveNotesData>
	<cftry>
		<cfset application.oLakebase.insertRow("broker_action_plan_notes", {
			"broker_action_plan_id" = Form.Broker_Action_Plan_ID,
			"date_of_note" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
			"broker_action_plan_notes" = Broker_Action_Plan_Notes
		})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForSaveNotesData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveNotesData>
	<CFQUERY NAME="Save_Notes_Data" datasource="#application.datasource#">
		INSERT INTO Broker_Action_Plan_Notes
			(
				Broker_Action_Plan_ID,
				Date_of_Note,
				Broker_Action_Plan_Notes
			)
		VALUES
			(
				#Form.Broker_Action_Plan_ID#,
				#createodbcdatetime(now())#,
				'#Broker_Action_Plan_Notes#'
			)
	</CFQUERY>
</cfif>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt the ID																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string ="#Broker_Action_Plan_ID#" key="#request.key#">
<CFSET ID = cryp.value>



<CFLOCATION URL="index5.cfm?ID=#ID#" ADDTOKEN="No">