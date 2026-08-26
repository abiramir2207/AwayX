<!--- unlock this users contracts --->
<cfquery name="unlockTheirPrograms" datasource="#application.datasource#">
	UPDATE Contract_Main
	Set Contract_Is_Locked = 0 
	WHERE 
		Contract_Is_Locked = 1
		AND 
		Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#' 
		AND
		DELETED = 0 
		AND
		Flagged_As_Purged = 0
</cfquery>