
<!---Edit--->
<cfif action IS "Edit">

	<cfset useLakebaseForUpdateEntry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_checkbook")>
<cfif useLakebaseForUpdateEntry>
	<cftry>
		<cfset application.oLakebase.updateRows("auto_checkbook",
			{
				"auto_checkbook_id" = "eq.#Auto_Checkbook#"
			},
			{
				"program_id" = "#Program_ID#",
				"distributor_id" = "#Distributor_ID#",
				"send_to" = "#Send_To#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateEntry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateEntry>
<cfquery name="UpdateEntry" datasource="##">
	UPDATE Auto_Checkbook
	SET Program_ID = '#Program_ID#',
		Distributor_ID = '#Distributor_ID#',
		Send_To = '#Send_To#'
	WHERE Auto_Checkbook_ID = '#Auto_Checkbook#'
	</cfquery>
</cfif>

<!---Add--->
<cfelse>

	<cfquery name="InsertEntry" datasource="#application.datasource#">
	INSERT INTO Auto_Checkbook
	(
		User_ID,
		Program_ID,
		Distributor_ID,
		Created_Date,
		Deleted,
		Send_To
	)
	VALUES
	(
		'#request.AccessStructure.User_ID#',
		'#Program_ID#',
		'#Distributor_ID#',
		#Now()#,
		0,
		'#Send_To#'
	)
	</cfquery>

</cfif>


<cflocation url="index.cfm">