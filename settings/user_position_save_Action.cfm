<CFIF FORM.new_position_label_id EQ 0>
	<!--- insert new position --->
	<CFQUERY NAME="addNewPosition" datasource="#application.datasource#">
		INSERT INTO User_Positions
		(Position_Label, Position_Description, Position_Zone, Position_Region, Position_Market)
		VALUES
		('#trim(replace(FORM.new_position_label, "'", "''", "ALL"))#', '#trim(replace(FORM.new_position_description, "'", "''", "ALL"))#', #FORM.Service_Zone_ID#, #FORM.Service_Region_ID#, #FORM.Service_Market_ID#)
	</CFQUERY>

<CFELSE>
	<cfset useLakebaseForupdatePosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForupdatePosition>
	<cftry>
		<cfset application.oLakebase.updateRows("user_positions",
			{
				"user_positions_id" = "eq.#FORM.new_position_label_id#"
			},
			{
				"position_label" = "#FORM.new_position_label#",
				"position_description" = "#FORM.new_position_description#",
				"position_zone" = "#FORM.Service_Zone_ID#",
				"position_region" = "#FORM.Service_Region_ID#",
				"position_market" = "#FORM.Service_Market_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatePosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatePosition>
<CFQUERY NAME="updatePosition" datasource="#application.datasource#">
		UPDATE User_Positions
		SET
			Position_Label 			= '#FORM.new_position_label#',
			Position_Description	= '#FORM.new_position_description#',
			Position_Zone			= #FORM.Service_Zone_ID#,
			Position_Region			= #FORM.Service_Region_ID#,
			Position_Market			= #FORM.Service_Market_ID#
		WHERE 
			User_Positions_ID = '#FORM.new_position_label_id#'
	</CFQUERY>
</cfif>	
</CFIF>

<CFLOCATION URL="user_relationships_index.cfm">