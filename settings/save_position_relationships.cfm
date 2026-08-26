<CFIF isdefined("FORM.Top_Level_Position_ID")>
	<CFQUERY NAME="saveTopLevelPosition" datasource="#application.datasource#">INSERT INTO User_Position_Relationships
		(Primary_User_Positions_ID, Superior_User_Positions_ID, Subordinate_User_Positions_ID)
		VALUES
		(#FORM.Top_Level_Position_ID#, 2, 1)
	</CFQUERY>
</CFIF>
<CFLOCATION URL="user_relationships_index.cfm">