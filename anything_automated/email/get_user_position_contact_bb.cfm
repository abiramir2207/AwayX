<!---
Document		:	/ANYTHING_AUTOMATED/EMAIL/get_user_position_contact_bb.cfm
Author			:	Deepa Kunnath
Date Created	:	Nov 08, 2004
Purpose			:	Get the users for the given position
Arguments		:	ContactUserPositionID
Called from		: 
					/ANYTHING_AUTOMATED/EMAIL/rfa_billback_emailer.cfm
									
--->

<cfquery name="userPositionContactInfoBB" datasource="#application.datasource#" maxrows="1">
	SELECT		User_Positions.User_Positions_ID, User_Positions.Position_Label, 
				_Users.Name_First, _Users.Name_Last, _Users.User_Email
	FROM		_Users 
	INNER JOIN	User_Position_Holders 
	ON 			_Users.User_ID = User_Position_Holders.User_ID 
	INNER JOIN	User_Positions 
	ON 			User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
	WHERE     	User_Positions.Deleted = 0
	AND 		User_Position_Holders.deleted = 0
	AND 		_Users.Deleted = 0
	AND 		User_Positions.User_Positions_ID = <cfqueryparam value="#ContactUserPositionID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>