<CFSET thisPositionLabelText = "">
<CFQUERY NAME="checkForPositionLabel" datasource="#application.datasource#">
	SELECT *
	FROM User_Positions
	WHERE 
		Service_Zone_ID 	<CFIF thisPositionZone EQ 0>IS NULL<CFELSE>='#thisPositionZone#'</CFIF>
		AND
		Service_Region_ID 	<CFIF thisPositionRegion EQ 0>IS NULL<CFELSE>='#thisPositionRegion#'</CFIF>
		AND
		Service_Market_ID 	<CFIF thisPositionMarket EQ 0>IS NULL<CFELSE>='#thisPositionMarket#'</CFIF>
		AND
		DELETED = 0
</CFQUERY>

<CFIF checkForPositionLabel.recordcount GT 0><CFSET thisPositionLabelText =checkForPositionLabel.Position_Label></CFIF>

<CFSET Position_Holder_Name = "">
<CFQUERY NAME="checkForPositionHolder" datasource="#application.datasource#">
	SELECT     dbo._Users.Name_First, dbo._Users.Name_Last, dbo.User_Position_Holders.deleted, dbo._Users.User_ID
	FROM         dbo._Users INNER JOIN
	                      dbo.User_Position_Holders ON dbo._Users.User_ID = dbo.User_Position_Holders.User_ID
AND  dbo.User_Position_Holders.User_Position_Type = 'P' AND  dbo.User_Position_Holders.Deleted = 0
	WHERE     (dbo.User_Position_Holders.deleted = 0) AND (dbo._Users.User_ID = '#checkForPositionLabel.Position_Holder_User_ID#')
</CFQUERY>

<CFIF checkForPositionHolder.Recordcount GT 0>
	<CFSET Position_Holder_Name = checkForPositionHolder.Name_First & " " & checkForPositionHolder.Name_Last>
</CFIF>

<CFSET thisPositionZone 	= 0>
<CFSET thisPositionRegion 	= 0>
<CFSET thisPositionMarket 	= 0>

