<CFPARAM NAME="FORM.Region_ID" DEFAULT="">
<CFPARAM NAME="FORM.previously_selected_regions" DEFAULT="">


<!--- save Position  label --->

<CFSET thisPositionZone 	= #listgetat(#FORM.Position_Label_ID#, 1, "_")#>
<CFSET thisPositionRegion 	= #listgetat(#FORM.Position_Label_ID#, 2, "_")#>
<CFSET thisPositionMarket 	= #listgetat(#FORM.Position_Label_ID#, 3, "_")#>

<CFQUERY NAME="checkForExistingLabel" datasource="#application.datasource#">
	SELECT *
	FROM User_Positions
	WHERE 
		Service_Zone_ID 	<CFIF thisPositionZone EQ 0>IS NULL<CFELSE>= '#thisPositionZone#'</CFIF>
		AND
		Service_Region_ID 	<CFIF thisPositionRegion EQ 0>IS NULL<CFELSE>= '#thisPositionRegion#'</CFIF>
		AND
		Service_Market_ID 	<CFIF thisPositionMarket EQ 0>IS NULL<CFELSE>= '#thisPositionMarket#'</CFIF>
		AND
		DELETED = 0
</CFQUERY>

<CFIF checkForExistingLabel.recordcount EQ 0>
	<CFQUERY NAME="saveLabel" datasource="#application.datasource#">
		INSERT INTO User_Positions
		(Position_Label, Service_Zone_ID, Service_Region_ID, Service_Market_ID)
		VALUES
		('#FORM.Position_Label#',<CFIF thisPositionZone EQ 0>NULL<CFELSE>'#thisPositionZone#'</CFIF>,<CFIF thisPositionRegion EQ 0>NULL<CFELSE>'#thisPositionRegion#'</CFIF>,<CFIF thisPositionMarket EQ 0>NULL<CFELSE>'#thisPositionMarket#'</CFIF>)
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="updateLabel" datasource="#application.datasource#">
		UPDATE User_Positions
		SET 
			Position_Label	= '#FORM.Position_Label#',
			Service_Zone_ID		= <CFIF thisPositionZone EQ 0>NULL<CFELSE>'#thisPositionZone#'</CFIF>,
			Service_Region_ID	= <CFIF thisPositionRegion EQ 0>NULL<CFELSE>'#thisPositionRegion#'</CFIF>,
			Service_Market_ID	= <CFIF thisPositionMarket EQ 0>NULL<CFELSE>'#thisPositionMarket#'</CFIF>
		WHERE 
			Service_Zone_ID 	<CFIF thisPositionZone EQ 0>IS NULL<CFELSE>= '#thisPositionZone#'</CFIF>
			AND
			Service_Region_ID 	<CFIF thisPositionRegion EQ 0>IS NULL<CFELSE>= '#thisPositionRegion#'</CFIF>
			AND
			Service_Market_ID 	<CFIF thisPositionMarket EQ 0>IS NULL<CFELSE>= '#thisPositionMarket#'</CFIF>
			AND
			DELETED = 0
	</CFQUERY>
</CFIF>


<CF_List_Compare List1="#FORM.previously_selected_regions#" List2="#FORM.Region_ID#">

<CFIF len(LC_Results1) GT 0>
		<CFQUERY NAME="removeRegionToZoneAssignment" datasource="#application.datasource#">
			UPDATE Service_Regions
			SET Service_Zone_ID = NULL
			WHERE Service_Region_ID IN(#replace(listqualify(LC_Results1, "'"), "''", "'")#)
		</CFQUERY>

	<CFQUERY NAME="UpdateUserPositions" datasource="#application.datasource#">
		UPDATE User_Positions
		SET Service_Zone_ID = NULL
		WHERE Service_Region_ID IN(#replace(listqualify(LC_Results1, "'"), "''", "'")#)
	</CFQUERY>	
</CFIF>

<CFIF len(FORM.Region_ID) NEQ 0>
	<CFQUERY NAME="saveRegionToZoneAssignment" datasource="#application.datasource#">
		UPDATE Service_Regions
		SET Service_Zone_ID = '#FORM.Zone_ID#'
		WHERE Service_Region_ID IN(#replace(listqualify(FORM.Region_ID, "'"), "''", "'")#)
	</CFQUERY>

	<CFQUERY NAME="UpdateUserPositions" datasource="#application.datasource#">
		UPDATE User_Positions
		SET Service_Zone_ID = '#FORM.Zone_ID#'
		WHERE  Service_Region_ID IN(#replace(listqualify(FORM.Region_ID, "'"), "''", "'")#)
	</CFQUERY>		

</CFIF>

<CFQUERY NAME="saveLastUpdate" datasource="#application.datasource#">
	INSERT INTO Zone_Region_Market_Last_Edited_By
	(Users_ID)
	VALUES
	('#request.AccessStructure.user_id#')
</CFQUERY>

<!--- rebuild approval structure --->
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\Approver_Tree_Build.cfm">


<CFLOCATION URL="zone_region_market_Setup.cfm">