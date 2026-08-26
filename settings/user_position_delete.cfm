<cfset useLakebaseFordeletePosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseFordeletePosition>
	<cftry>
		<cfset application.oLakebase.updateRows("user_positions",
			{
				"user_positions_id" = "eq.#FORM.Position_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletePosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletePosition>
<CFQUERY NAME="deletePosition" datasource="#application.datasource#">
	UPDATE User_Positions
	SET Deleted = 1
	WHERE User_Positions_ID = '#FORM.Position_ID#'
</CFQUERY>
</cfif>
<CFLOCATION URL="user_relationships_index.cfm">