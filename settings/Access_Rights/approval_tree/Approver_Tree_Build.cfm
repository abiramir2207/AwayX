<CFSET UserInQuestion_User_ID=request.AccessStructure.user_id>

<CFSET Approval_Tree = StructNew()>

<CFQUERY NAME="getZones" datasource="#application.datasource#">
SELECT DISTINCT dbo.BSA_Foodservice_Brokers.Service_Zone_ID, dbo.Service_Zones.Zone_Name
FROM         dbo.BSA_Foodservice_Brokers INNER JOIN
                      dbo.Line_Of_Business ON dbo.BSA_Foodservice_Brokers.Line_Of_Business_ID = dbo.Line_Of_Business.Line_Of_Business_ID INNER JOIN
                      dbo.Service_Zones ON dbo.BSA_Foodservice_Brokers.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
WHERE     (dbo.BSA_Foodservice_Brokers.Active_Code = 'A') AND (dbo.BSA_Foodservice_Brokers.Deleted = 0) AND 
                      (dbo.Line_Of_Business.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#))
</CFQUERY>


<CFLOOP QUERY="getZones">
	

	<CFSET thisServiceZone_ID = "Z_"&replace(getZones.Service_Zone_ID, "-", "_", "ALL")>
	<CFSET DB_ServiceZone_ID = getZones.Service_Zone_ID>
	
	<cfset temp = StructInsert(Approval_Tree,thisServiceZone_ID,structnew())>
	
	<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#")>
	<cfset temp =StructInsert(ThisLevelStructure,"aa_Zone_Name",getZones.Zone_Name)>

	<cfset useLakebaseForgetPositionID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForgetPositionID>
	<cftry>
		<cfset getPositionID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"service_zone_id" = "eq.#DB_ServiceZone_ID#",
				"service_region_id" = "is.null",
				"service_market_id" = "is.null"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPositionID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPositionID>
<CFQUERY NAME="getPositionID" datasource="#application.datasource#">
		SELECT *
		FROM User_Positions
		WHERE Service_Zone_ID = '#DB_ServiceZone_ID#' AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL
	</CFQUERY>
</cfif>
	
	<!--- get Approvers --->
	<CFIF getPositionID.Recordcount GT 0>
		<cfset temp =StructInsert(ThisLevelStructure,"AA_Approvers_Position",StructNew())>
		<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.AA_Approvers_Position")>
		<CFLOOP QUERY="getPositionID">
			<cfset temp =StructInsert(ThisLevelStructure,"A_"&getPositionID.User_Positions_ID, structnew())>
			<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.AA_Approvers_Position.A_#getPositionID.User_Positions_ID#")>

			<CFQUERY NAME="getPositionHolders" datasource="#application.datasource#">
				SELECT *
				FROM User_Position_Holders
				WHERE User_Positions_ID = '#getPositionID.User_Positions_ID#' AND len(User_ID) > 0 AND Deleted = 0
			</CFQUERY>
			
			<CFLOOP QUERY="getPositionHolders">
				<cfset temp=StructInsert(ThisLevelStructure,"ID_"&getPositionHolders.User_ID, "")>
			</CFLOOP>
		</CFLOOP>
	</CFIF>

	<cfset useLakebaseForgetRegions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_regions")>
<cfif useLakebaseForgetRegions>
	<cftry>
		<cfset getRegions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_regions", {
				"service_zone_id" = "eq.#DB_ServiceZone_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRegions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRegions>
<CFQUERY NAME="getRegions" datasource="#application.datasource#">
		SELECT *
		FROM Service_Regions
		WHERE Service_Zone_ID = '#DB_ServiceZone_ID#' AND DELETED = 0
	</CFQUERY>
</cfif>
	
		<CFLOOP QUERY="getRegions">

			<CFSET thisServiceRegion_ID = "R_"&replace(getRegions.Service_Region_ID, "-", "_", "ALL")>
			<CFSET DB_ServiceRegion_ID = getRegions.Service_Region_ID>
			
			<CFIF isdefined("Approval_Tree.#thisServiceZone_ID#")>

				<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#")>
				<CFSET temp = StructInsert(ThisLevelStructure,thisServiceRegion_ID, structnew())>

				<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#")>
				<cfset temp =StructInsert(ThisLevelStructure,"aa_Region_Name",getRegions.Region_Name)>

				<!--- get Approvers --->
				<CFQUERY NAME="getPositionID" datasource="#application.datasource#">
					SELECT *
					FROM User_Positions
					WHERE Service_Zone_ID = '#DB_ServiceZone_ID#' AND Service_Region_ID = '#DB_ServiceRegion_ID#' AND Service_Market_ID IS NULL
				</CFQUERY>
				
				<CFIF getPositionID.Recordcount GT 0>
					<cfset temp =StructInsert(ThisLevelStructure,"AA_Approvers_Position",StructNew())>
					<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#.AA_Approvers_Position")>
					<CFLOOP QUERY="getPositionID">
						<cfset temp =StructInsert(ThisLevelStructure,"A_"&getPositionID.User_Positions_ID, structnew())>
						<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#.AA_Approvers_Position.A_#getPositionID.User_Positions_ID#")>
			
						<CFQUERY NAME="getPositionHolders" datasource="#application.datasource#">
							SELECT *
							FROM User_Position_Holders
							WHERE User_Positions_ID = '#getPositionID.User_Positions_ID#' AND len(User_ID) > 0 AND Deleted = 0
						</CFQUERY>
						
						<CFLOOP QUERY="getPositionHolders">
							<cfset temp=StructInsert(ThisLevelStructure,"ID_"&getPositionHolders.User_ID, "")>
						</CFLOOP>
					</CFLOOP>
				</CFIF>
				<!--- end get Approvers --->
				
				<cfset useLakebaseForgetMarkets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_markets")>
<cfif useLakebaseForgetMarkets>
	<cftry>
		<cfset getMarkets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_markets", {
				"service_region_id" = "eq.#DB_ServiceRegion_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetMarkets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetMarkets>
<CFQUERY NAME="getMarkets" datasource="#application.datasource#">
					SELECT *
					FROM Service_Markets
					WHERE Service_Region_ID = '#DB_ServiceRegion_ID#' AND DELETED = 0
				</CFQUERY>
</cfif>
				
					<CFLOOP QUERY="getMarkets">

						<CFSET thisServiceMarket_ID = "M_"&getMarkets.Service_Market_ID>
						<CFSET DB_ServiceMarket_ID = getMarkets.Service_Market_ID>
						<CFIF isdefined("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#")>

							<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#")>
							<CFSET temp = StructInsert(ThisLevelStructure,thisServiceMarket_ID, structnew())>
			
							<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#.#thisServiceMarket_ID#")>
							<cfset temp =StructInsert(ThisLevelStructure,"aa_Market_Name",getMarkets.Market_Name)>
							
							<!--- get Approvers --->
							<CFQUERY NAME="getPositionID" datasource="#application.datasource#">
								SELECT *
								FROM User_Positions
								WHERE Service_Zone_ID = '#DB_ServiceZone_ID#' AND Service_Region_ID = '#DB_ServiceRegion_ID#' AND Service_Market_ID = '#DB_ServiceMarket_ID#'
							</CFQUERY>
							
							<CFIF getPositionID.Recordcount GT 0>
								<cfset temp =StructInsert(ThisLevelStructure,"AA_Approvers_Position",StructNew())>
								<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#.#thisServiceMarket_ID#.AA_Approvers_Position")>
								<CFLOOP QUERY="getPositionID">

									<cfset temp =StructInsert(ThisLevelStructure,"A_"&getPositionID.User_Positions_ID, structnew())>
									<CFSET ThisLevelStructure = evaluate("Approval_Tree.#thisServiceZone_ID#.#thisServiceRegion_ID#.#thisServiceMarket_ID#.AA_Approvers_Position.A_#getPositionID.User_Positions_ID#")>
						
									<CFQUERY NAME="getPositionHolders" datasource="#application.datasource#">
										SELECT *
										FROM User_Position_Holders
										WHERE User_Positions_ID = '#getPositionID.User_Positions_ID#' AND len(User_ID) > 0 AND Deleted = 0
									</CFQUERY>
									
									<CFLOOP QUERY="getPositionHolders">
										<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#getPositionHolders.User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
											SELECT Name_First, Name_Last
											FROM _Users
											WHERE User_ID = '#getPositionHolders.User_ID#'
										</CFQUERY>
</cfif>
										<cfset temp=StructInsert(ThisLevelStructure,"ID_"&getPositionHolders.User_ID, getUserName.Name_First&" "&getUserName.Name_Last)>
									</CFLOOP>
								</CFLOOP>
							</CFIF>
							<!--- end get Approvers --->
							
						</CFIF>

					</CFLOOP>
				
			</CFIF>
		
		</CFLOOP>
</CFLOOP>


<CFWDDX ACTION="CFML2WDDX" INPUT="#Approval_Tree#" OUTPUT="Serialized_Approver_Tree" USETIMEZONEINFO="Yes">
	<!--- get install path --->	
	<!--- END get install path --->
	<!--- create usable directory information --->
	<CFSET The_File_Location = APPLICATIONPATH & "\settings\Access_Rights\approval_tree\Serialized_Approver_Tree.cfm">
	<!--- end create usable directory information --->	
<CFSET FileLocation = The_File_Location>

<CFIF FileExists("#FileLocation#")>
	<CFFILE ACTION="DELETE" FILE="#FileLocation#">
</CFIF>

<CFFILE ACTION="WRITE" FILE="#FileLocation#" OUTPUT="#Serialized_Approver_Tree#" ADDNEWLINE="No">



