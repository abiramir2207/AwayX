
<!---Update database and redirect home--->

<!---First see if preference record already exists--->

<cfset useLakebaseForIsAlreadyThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_user_preferences")>
<cfif useLakebaseForIsAlreadyThere>
	<cftry>
		<cfset IsAlreadyThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_user_preferences", {
				"user_id" = "eq.#request.AccessStructure.User_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsAlreadyThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsAlreadyThere>
<cfquery name="IsAlreadyThere" datasource="#application.datasource#">
SELECT * FROM _User_Preferences
WHERE User_ID = '#request.AccessStructure.User_ID#'
</cfquery>
</cfif>

<cfif IsAlreadyThere.Recordcount GT 0>
<!---Update--->
	<cfset useLakebaseForUpdateRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_user_preferences")>
<cfif useLakebaseForUpdateRecord>
	<cftry>
		<cfset application.oLakebase.updateRows("_user_preferences",
			{
				"user_id" = "eq.#request.AccessStructure.User_ID#"
			},
			{
				"records_to_show" = "#RecordsToShow#",
				"last_updated" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateRecord>
<cfquery name="UpdateRecord" datasource="#application.datasource#">
	UPDATE _User_Preferences
	SET Records_To_Show = '#RecordsToShow#',
		Last_Updated	= #now()#
	WHERE User_ID = '#request.AccessStructure.User_ID#'
	</cfquery>
</cfif>

<!---Insert--->
<cfelse>
	<cfset useLakebaseForInsertRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_user_preferences")>
<cfif useLakebaseForInsertRecord>
	<cftry>
		<cfset application.oLakebase.insertRow("_user_preferences", {
			"user_id" = "#request.AccessStructure.User_ID#",
			"last_updated" = "#now()#",
			"records_to_show" = "#RecordsToShow#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertRecord>
<cfquery name="InsertRecord" datasource="#application.datasource#">
	INSERT INTO _User_Preferences
	(
		User_ID,
		Last_Updated,
		Records_To_Show
	)
	VALUES
	(
		'#request.AccessStructure.User_ID#',
		#now()#,
		'#RecordsToShow#'
	)
	</cfquery>
</cfif>

</cfif>

<cflocation url="/settings/personalization/index.cfm">