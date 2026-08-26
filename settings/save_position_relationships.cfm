<CFIF isdefined("FORM.Top_Level_Position_ID")>
	<cfset useLakebaseForsaveTopLevelPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_relationships")>
<cfif useLakebaseForsaveTopLevelPosition>
	<cftry>
		<cfset application.oLakebase.insertRow("user_position_relationships", {
			"primary_user_positions_id" = "#FORM.Top_Level_Position_ID#",
			"superior_user_positions_id" = "2",
			"subordinate_user_positions_id" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveTopLevelPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveTopLevelPosition>
<CFQUERY NAME="saveTopLevelPosition" datasource="#application.datasource#">INSERT INTO User_Position_Relationships
		(Primary_User_Positions_ID, Superior_User_Positions_ID, Subordinate_User_Positions_ID)
		VALUES
		(#FORM.Top_Level_Position_ID#, 2, 1)
	</CFQUERY>
</cfif>
</CFIF>
<CFLOCATION URL="user_relationships_index.cfm">