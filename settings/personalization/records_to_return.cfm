<!---Checks to see if user preferences exist and are set--->
<cfquery name="DoesTableExist" datasource="#application.datasource#">
SELECT * FROM
INFORMATION_SCHEMA.TABLES 
WHERE TABLE_Name = '_User_Preferences'
</cfquery>

<cfif DoesTableExist.Recordcount GT 0>
<!---Check for preferences if the table exists--->
	<cfset useLakebaseForGetPreferences = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_user_preferences")>
<cfif useLakebaseForGetPreferences>
	<cftry>
		<cfset GetPreferences = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_user_preferences", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "records_to_show"
			}), "records_to_show"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPreferences = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPreferences>
<cfquery name="GetPreferences" datasource="#application.datasource#">
	SELECT Records_To_Show FROM _User_Preferences
	WHERE User_ID = '#request.AccessStructure.User_ID#'
	</cfquery>
</cfif>
	
	<cfif GetPreferences.Recordcount GT 0>
		<cfset Records_To_Show = GetPreferences.Records_To_Show>
	</cfif>

</cfif>
