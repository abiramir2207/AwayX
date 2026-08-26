<CFIF FORM.new_position_label_id EQ 0>
	<!--- insert new position --->
	<CFQUERY NAME="addNewPosition" datasource="#application.datasource#">
		INSERT INTO User_Positions
		(Position_Label, Position_Description, Position_Zone, Position_Region, Position_Market)
		VALUES
		('#trim(replace(FORM.new_position_label, "'", "''", "ALL"))#', '#trim(replace(FORM.new_position_description, "'", "''", "ALL"))#', #FORM.Service_Zone_ID#, #FORM.Service_Region_ID#, #FORM.Service_Market_ID#)
	</CFQUERY>

<CFELSE>
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
</CFIF>

<CFLOCATION URL="user_relationships_index.cfm">