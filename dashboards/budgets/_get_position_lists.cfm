<!--- <cfoutput>#request.accessstructure.User_ID#</cfoutput> --->
<cfset oAppSettings = application.appsettingsGet />
<cfset businessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentEnabled = businessSegmentManager.isEnabled()/>

<!--- Check if user is HQ ----------------------------------------------- --->
<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
<cfset HQUser = 0>
<cfif listfind(UserPositionList, HQPosition.User_Positions_ID)>
	<cfset HQUser = 1>
</cfif>

<!--- - get the list of Zones that are below me ----------------------------------------------- --->
<cfquery name="Get_Zone_List" datasource="#Application.Datasource#">
SELECT 	DISTINCT positions_below_me.service_zone_id
FROM	positions_below_me
<cfif businessSegmentEnabled eq 1 and oAppSettings.getPositionFieldsFilterOnProgramSegment() eq 1>
inner join service_zones
on		service_zones.service_zone_id = positions_below_me.service_zone_id
and		service_zones.business_segment_id IN
			(
				SELECT	business_segment_id
				FROM	user_business_segment
				WHERE	user_business_segment.user_id = '#request.AccessStructure.User_ID#'
				AND		user_business_segment.deleted = 0
			)
</cfif>
WHERE	user_positions_id IN
			(
				SELECT	user_positions_id
				FROM	user_position_holders
				WHERE	user_position_holders.user_id = '#request.AccessStructure.User_ID#'
				AND		user_position_holders.deleted = 0
			)
AND		positions_below_me.service_zone_id IS NOT NULL
AND		positions_below_me.service_region_id IS NULL
</cfquery>
<cfset user_zone_list = ListQualify(ValueList(Get_Zone_List.service_zone_id), "'") />


<!--- -get the list of regions that are below me ---------------------------------------------- --->
<cfquery name="Get_region_List" datasource="#Application.Datasource#">
SELECT 	DISTINCT positions_below_me.service_region_id
FROM	positions_below_me
<cfif businessSegmentEnabled eq 1 and oAppSettings.getPositionFieldsFilterOnProgramSegment() eq 1>
inner join service_regions
on		service_regions.service_region_id = positions_below_me.service_region_id
and		service_regions.business_segment_id IN
			(
				SELECT	business_segment_id
				FROM	user_business_segment
				WHERE	user_business_segment.user_id = '#request.AccessStructure.User_ID#'
				AND		user_business_segment.deleted = 0
			)
</cfif>
WHERE	user_positions_id IN
			(
				SELECT	user_positions_id
				FROM	user_position_holders
				WHERE	user_position_holders.user_id = '#request.AccessStructure.User_ID#'
				AND		user_position_holders.deleted = 0
			)
AND		positions_below_me.service_region_id IS NOT NULL
AND		positions_below_me.service_market_id IS NULL
</cfquery>
<cfset user_region_list = ListQualify(ValueList(Get_region_List.service_region_id), "'") />
<!--- ----------------------------------------------------------------------------------------- --->


<!--- - get the list of markets that are below me --------------------------------------------- --->
<cfquery name="Get_market_List" datasource="#Application.Datasource#">
SELECT 	DISTINCT positions_below_me.service_market_id
FROM	positions_below_me
<cfif businessSegmentEnabled eq 1 and oAppSettings.getPositionFieldsFilterOnProgramSegment() eq 1>
inner join service_markets
on		service_markets.service_market_id = positions_below_me.service_market_id
and		service_markets.business_segment_id IN
			(
				SELECT	business_segment_id
				FROM	user_business_segment
				WHERE	user_business_segment.user_id = '#request.AccessStructure.User_ID#'
				AND		user_business_segment.deleted = 0
			)
</cfif>
WHERE	user_positions_id IN
			(
				SELECT	user_positions_id
				FROM	user_position_holders
				WHERE	user_position_holders.user_id = '#request.AccessStructure.User_ID#'
				AND		user_position_holders.deleted = 0
			)
AND		positions_below_me.service_market_id IS NOT NULL
</cfquery>
<cfset user_market_list = ValueList(Get_market_List.service_market_id) />
<!--- ----------------------------------------------------------------------------------------- --->


