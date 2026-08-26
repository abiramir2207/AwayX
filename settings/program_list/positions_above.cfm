<CFPARAM NAME="GP_Supplied_Position" DEFAULT="">
<CFPARAM NAME="GP_Position_List_From_My_Position_Down" DEFAULT="">

<!--- 
	IN: GP_Supplied_Position
	OUT GP_Position_List_From_My_Position_Down
 --->


<CFQUERY NAME="getUserInformation" datasource="#application.datasource#">
SELECT     Service_Market_ID, Service_Region_ID, Service_Zone_ID, User_Positions_ID
FROM         dbo.User_Positions
WHERE     (User_Positions_ID = '#GP_Supplied_Position#') AND Deleted = 0
</CFQUERY>


	<CFQUERY NAME="getHQ" datasource="#application.datasource#">
	SELECT     User_Positions_ID
	FROM       User_Positions
	WHERE     
				Deleted = 0
				AND (Service_Market_ID IS NULL)
				AND (Service_Region_ID IS NULL)
				AND (Service_Zone_ID IS NULL)
	</CFQUERY>

<!--- get approver data --->


<CFSET Position_Type = "0">
<!--- Market --->
<CFIF 
	len(trim(getUserInformation.Service_Zone_ID)) GT 0
	AND
	len(trim(getUserInformation.Service_Region_ID)) GT 0
	AND
	len(trim(getUserInformation.Service_Market_ID)) GT 0
>
	<CFSET Position_Type = "MARKET">	
	<CFSET GP_Position_List_From_My_Position_Down = getUserInformation.User_Positions_ID>
	
	<CFQUERY NAME="Get_Region_Position" DATASOURCE="#application.datasource#">
		SELECT	User_Positions.User_Positions_ID, User_Positions.Service_Region_ID
		FROM	Service_Markets
				INNER JOIN User_Positions
				ON
				User_Positions.Service_Region_ID = Service_Markets.Service_Region_ID
				AND
				User_Positions.Deleted = 0
		WHERE
				Service_Markets.Service_Market_ID = '#trim(getUserInformation.Service_Market_ID)#'
				AND
				Service_Markets.Deleted = 0
	</CFQUERY>
	
	<CFIF Get_Region_Position.RecordCount GT 0>
		<CFSET GP_Position_List_From_My_Position_Down = ListAppend(GP_Position_List_From_My_Position_Down, Get_Region_Position.User_Positions_ID)>
		
		<CFQUERY NAME="Get_Zone_Position" DATASOURCE="#application.datasource#">
			SELECT	User_Positions.User_Positions_ID
			FROM	Service_Regions
					INNER JOIN User_Positions
					ON
					User_Positions.Service_Zone_ID = Service_Regions.Service_Zone_ID
					AND
					User_Positions.Deleted = 0
			WHERE
					Service_Regions.Service_Region_ID = '#trim(Get_Region_Position.Service_Region_ID)#'
					AND
					Service_Regions.Deleted = 0
		</CFQUERY>
		
		<CFIF Get_Zone_Position.RecordCount GT 0>
			<CFSET GP_Position_List_From_My_Position_Down = ListAppend(GP_Position_List_From_My_Position_Down, Get_Zone_Position.User_Positions_ID)>
		</CFIF>
	</CFIF>
	
	
	
	
	
</CFIF>

<!--- Region --->
<CFIF 
	len(trim(getUserInformation.Service_Zone_ID)) GT 0
	AND
	len(trim(getUserInformation.Service_Region_ID)) GT 0
	AND
	getUserInformation.Service_Market_ID 	EQ ""
>
	<CFSET Position_Type = "REGION">
	<CFSET GP_Position_List_From_My_Position_Down = getUserInformation.User_Positions_ID>
	
	<CFQUERY NAME="Get_Zone_Position" DATASOURCE="#application.datasource#">
		SELECT	User_Positions.User_Positions_ID
		FROM	Service_Regions
				INNER JOIN User_Positions
				ON
				User_Positions.Service_Zone_ID = Service_Regions.Service_Zone_ID
				AND
				User_Positions.Deleted = 0
		WHERE
				Service_Regions.Service_Region_ID = '#trim(getUserInformation.Service_Region_ID)#'
				AND
				Service_Regions.Deleted = 0
	</CFQUERY>
	
	<CFIF Get_Zone_Position.RecordCount GT 0>
		<CFSET GP_Position_List_From_My_Position_Down = ListAppend(GP_Position_List_From_My_Position_Down, Get_Zone_Position.User_Positions_ID)>
	</CFIF>
</CFIF>


<!--- ZONE --->
<CFIF 
	len(trim(getUserInformation.Service_Zone_ID)) GT 0
	AND
	getUserInformation.Service_Region_ID	EQ	""
	AND
	getUserInformation.Service_Market_ID 	EQ	""
>
	<CFSET Position_Type = "ZONE">
	<CFSET GP_Position_List_From_My_Position_Down = getUserInformation.User_Positions_ID>
	
</CFIF>

<!--- GOD --->
<CFIF 
	getUserInformation.Service_Zone_ID		EQ	""
	AND
	getUserInformation.Service_Region_ID	EQ	""
	AND
	getUserInformation.Service_Market_ID 	EQ	""
>
	<CFSET Position_Type = "GOD">
	
	<CFSET GP_Position_List_From_My_Position_Down = "">
</CFIF>
<!------ Add HQ ----->
<CFSET GP_Position_List_From_My_Position_Down = ListAppend(GP_Position_List_From_My_Position_Down, getHQ.User_Positions_ID)>
