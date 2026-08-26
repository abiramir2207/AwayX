<CFPARAM NAME="GP_Supplied_Position" DEFAULT="">
<cfset GP_Position_List_From_My_Position_Down = "">
<CFSET Position_Type = "0">

<cfparam name="getIDList" 	default="0">

<!--- "UseHashTables" is 1 when the user does search from flex --->
<cfparam name="UseHashTables" default="0">



<cfif NOT getIDList>

<cfif UseHashTables eq 1>
<CFQUERY NAME="getThisRegionsSubMarketPostions" datasource="#application.datasource#">
if object_id('tempdb..##Positions_Below_Me') is not null 
drop table ##Positions_Below_Me 

Create  table ##Positions_Below_Me
(
  Below_User_Positions_ID   int          NOT NULL
)

CREATE  CLUSTERED  INDEX [I_Below_User_Positions_ID_tmp] ON [dbo].[##Positions_Below_Me]([Below_User_Positions_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

INSERT INTO ##Positions_Below_Me(Below_User_Positions_ID)
SELECT	DISTINCT Below_User_Positions_ID
FROM	Positions_Below_Me
WHERE	User_Positions_ID IN (#preservesinglequotes(GP_Supplied_Position)#)
</CFQUERY>
</cfif>

<cfoutput>

<cfif UseHashTables eq 0>
<cfsavecontent variable="GP_Position_List_From_My_Position_Down">
SELECT	DISTINCT Below_User_Positions_ID
FROM	Positions_Below_Me
WHERE	User_Positions_ID IN (#preservesinglequotes(GP_Supplied_Position)#)
</cfsavecontent>

<cfelse>

<cfsavecontent variable="GP_Position_List_From_My_Position_Down">
SELECT	*
FROM  ##Positions_Below_Me
</cfsavecontent>
</cfif>

</cfoutput>
<cfelse>
<!--- 
	IN: GP_Supplied_Position
	OUT GP_Position_List_From_My_Position_Down
 --->

<cfset baseObj = CreateObject("component", "components.Base") />

<CFQUERY NAME="getUserInformation" datasource="#application.datasource#">
SELECT     Service_Market_ID, Service_Region_ID, Service_Zone_ID, User_Positions_ID
FROM         dbo.User_Positions
WHERE     (User_Positions_ID IN (#GP_Supplied_Position#)) AND Deleted = 0
</CFQUERY>


<!--- get approver data --->

<cfloop query="getUserInformation">
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
	
	<CFSET GP_Position_List_From_My_Position_Down = baseObj.listAppendIfNotExist(GP_Position_List_From_My_Position_Down,getUserInformation.User_Positions_ID)>
	
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
	
	<CFQUERY NAME="getThisRegionsSubMarketPostions" datasource="#application.datasource#">
		SELECT     dbo.User_Positions.User_Positions_ID
		FROM         dbo.Service_Regions INNER JOIN
		                      dbo.Service_Markets ON dbo.Service_Regions.Service_Region_ID = dbo.Service_Markets.Service_Region_ID INNER JOIN
		                      dbo.User_Positions ON dbo.Service_Regions.Service_Region_ID = dbo.User_Positions.Service_Region_ID AND 
		                      dbo.Service_Markets.Service_Market_ID = dbo.User_Positions.Service_Market_ID
		WHERE     (dbo.User_Positions.Deleted = 0) AND (dbo.Service_Regions.Service_Region_ID = '#getUserInformation.Service_Region_ID#')
	</CFQUERY>
	<CFSET GP_Position_List_From_My_Position_Down = baseObj.listAppendIfNotExist(GP_Position_List_From_My_Position_Down, valuelist(getThisRegionsSubMarketPostions.User_Positions_ID))>
	<CFSET GP_Position_List_From_My_Position_Down = baseObj.listAppendIfNotExist(GP_Position_List_From_My_Position_Down, getUserInformation.User_Positions_ID)>
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

	<CFQUERY NAME="getZoneHolderPosition_ID" datasource="#application.datasource#">
		SELECT     dbo.User_Positions.User_Positions_ID, dbo.Service_Zones.Service_Zone_ID
		FROM         dbo.Service_Zones INNER JOIN
		                      dbo.User_Positions ON dbo.Service_Zones.Service_Zone_ID = dbo.User_Positions.Service_Zone_ID
		WHERE     (dbo.User_Positions.Service_Region_ID IS NULL) AND (dbo.User_Positions.Service_Market_ID IS NULL) AND 
		                      (dbo.Service_Zones.Service_Zone_ID = '#getUserInformation.Service_Zone_ID#')
	</CFQUERY>
	
	<CFSET GP_Position_List_From_My_Position_Down = baseObj.listAppendIfNotExist (GP_Position_List_From_My_Position_Down, valuelist(getZoneHolderPosition_ID.User_Positions_ID))>

	<CFQUERY NAME="getRegionsBelongingToThisZone" datasource="#application.datasource#">
		SELECT     User_Positions_ID, Service_Region_ID
		FROM         dbo.User_Positions
		WHERE     (Service_Zone_ID = '#getUserInformation.Service_Zone_ID#') AND (Service_Market_ID IS NULL)
	</CFQUERY>

	<CFIF getRegionsBelongingToThisZone.recordcount GT 0>
		<CFSET GP_Position_List_From_My_Position_Down  = baseObj.listAppendIfNotExist (GP_Position_List_From_My_Position_Down, valuelist(getRegionsBelongingToThisZone.User_Positions_ID))>	
	</CFIF>
	<CFSET AllRegionsInThisZone = valuelist(getRegionsBelongingToThisZone.Service_Region_ID)>
	
	<CFQUERY NAME="getMarketPositionsInTheseRegions" datasource="#application.datasource#">
		SELECT     dbo.User_Positions.User_Positions_ID
		FROM         dbo.Service_Regions INNER JOIN
		                      dbo.Service_Markets ON dbo.Service_Regions.Service_Region_ID = dbo.Service_Markets.Service_Region_ID INNER JOIN
		                      dbo.User_Positions ON dbo.Service_Regions.Service_Region_ID = dbo.User_Positions.Service_Region_ID AND 
		                      dbo.Service_Markets.Service_Market_ID = dbo.User_Positions.Service_Market_ID
		WHERE     (dbo.User_Positions.Deleted = 0) 
				<!----- here as the condition is an
				"in"
				and not 
				"not in"
				it should not return any record if #AllRegionsInThisZone# is null
				<CFIF AllRegionsInThisZone NEQ "">
					AND (dbo.Service_Regions.Service_Region_ID IN (#replace(listqualify(AllRegionsInThisZone, "'", ","), '"', "'", "ALL")#))	
				</CFIF> 
				------------->
				AND
				(
					1=2					
				<CFIF AllRegionsInThisZone NEQ "">
					OR 
					(dbo.Service_Regions.Service_Region_ID IN (#replace(listqualify(AllRegionsInThisZone, "'", ","), '"', "'", "ALL")#))
				</CFIF>
				)
	</CFQUERY>
	<CFIF getMarketPositionsInTheseRegions.recordcount GT 0>
		<CFSET GP_Position_List_From_My_Position_Down = baseObj.listAppendIfNotExist (GP_Position_List_From_My_Position_Down, valuelist(getMarketPositionsInTheseRegions.User_Positions_ID))>	
	</CFIF>
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
	<CFQUERY NAME="getGODPositions" datasource="#application.datasource#">
		SELECT User_Positions_ID
		FROM User_Positions
		WHERE Deleted = 0
	</CFQUERY>
	<CFSET GP_Position_List_From_My_Position_Down = baseObj.listAppendIfNotExist (GP_Position_List_From_My_Position_Down, valuelist(getGODPositions.User_Positions_ID))>
</CFIF>

<CFSET GP_Position_List_From_My_Position_Down = #GP_Position_List_From_My_Position_Down#>

</cfloop>
<CFSET BaseObj = CreateObject("component", "components.Base")>
<cfset GP_Position_List_From_My_Position_Down = BaseObj.replaceMultipleChars(GP_Position_List_From_My_Position_Down,",") />

</cfif>