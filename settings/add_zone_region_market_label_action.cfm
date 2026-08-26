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
			Position_Label	= '#FORM.Position_Label#'
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

<cfset useLakebaseForsaveLastUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("zone_region_market_last_edited_by")>
<cfif useLakebaseForsaveLastUpdate>
	<cftry>
		<cfset application.oLakebase.insertRow("zone_region_market_last_edited_by", {
			"users_id" = "#request.AccessStructure.user_id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveLastUpdate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveLastUpdate>
<CFQUERY NAME="saveLastUpdate" datasource="#application.datasource#">
	INSERT INTO Zone_Region_Market_Last_Edited_By
	(Users_ID)
	VALUES
	('#request.AccessStructure.user_id#')
</CFQUERY>
</cfif>

<!--- rebuild approval structure --->
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\Approver_Tree_Build.cfm">

<CFLOCATION URL="zone_region_market_Setup.cfm">