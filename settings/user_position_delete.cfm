<CFQUERY NAME="deletePosition" datasource="#application.datasource#">
	UPDATE User_Positions
	SET Deleted = 1
	WHERE User_Positions_ID = '#FORM.Position_ID#'
</CFQUERY>
<CFLOCATION URL="user_relationships_index.cfm">