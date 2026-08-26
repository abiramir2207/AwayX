<cfcomponent hint="Position">
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>
	<cffunction name="init" output="false" returntype="components.geography.position">

		<cfreturn this />

	</cffunction>

	<cffunction name="getPosition" output="false" returntype="query">

		<cfargument name="id" type="numeric" required="false" default="0" />

		<cfquery name="qGetPosition" datasource="#application.datasource#">
			SELECT	User_Positions.User_Positions_ID, Position_Label,
					Service_Zones.Zone_Name,
					Service_Regions.Region_Name,
					Service_Markets.Market_Name,
					Service_Zones.Service_Zone_ID,
					Service_Regions.Service_Region_ID,
					Service_Markets.Service_Market_ID
			FROM	User_Positions
					LEFT JOIN	Service_Zones
					ON
					Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
					AND
					Service_Zones.Deleted = 0
					LEFT JOIN	Service_Regions
					ON
					Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
					AND
					Service_Regions.Deleted = 0
					LEFT JOIN	Service_Markets
					ON
					Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
					AND
					Service_Markets.Deleted = 0
			WHERE
					User_Positions.Deleted = 0
					<cfif arguments.id>
						AND User_Positions.User_Positions_ID = #arguments.id#
					</cfif>
		</cfquery>

		<cfreturn qGetPosition />

	</cffunction>

	<cffunction name="getPositions" output="false" returntype="query">

		<cfargument name="IDList" type="string" required="false" default="" />
		<!--- 28286	Reassigning from within a program added default value to -1 --->
		<cfargument name="level" type="string" required="false" default="-1" />
		<cfargument name="sortBy" type="string" required="false" default="" />
		<cfargument name="ignoreDeletedFlag" type="boolean" required="false" default="0" />
		<cfargument name="keyword" type="string" required="false" default="" />
    	<cfargument name="segments" type="string" required="false" default="disabled" />   <!---25715--->
		<cfargument name="Position_Level" type="numeric" required="false" default="0" />  <!--- D28864: Budgets and Program Reassign --->
		 
		<cfscript>
      var vars = {};
      vars.keywords = Replace(Trim(arguments.keyword), "  ", " ", "all" );  // remove double blank spaces with single blank space
      vars.keywords = ListToArray(vars.keywords, " ");                // break words and store in an array
    </cfscript>

		<cfquery name="qGetPositions" datasource="#application.datasource#">
      SELECT *
             , Business_Segment.Business_Unit_Desc
      FROM ( SELECT User_Positions.Position_Label
                    , User_Positions.User_Positions_Id
                    , Service_Zones.Zone_Name
                    , Service_Regions.Region_Name
                    , Service_Markets.Market_Name
                    , User_Positions.Service_Zone_Id
                    , User_Positions.Service_Region_Id
                    , User_Positions.Service_Market_Id
                    , User_Positions.Deleted
                    , Position_Number = CASE
                                          WHEN User_Positions.Service_Market_Id IS NOT NULL THEN Service_Markets.Market_Number
                                          WHEN User_Positions.Service_Region_Id IS NOT NULL
                                               AND User_Positions.Service_Market_Id IS NULL THEN Service_Regions.Region_Number
                                          WHEN User_Positions.Service_Zone_Id IS NOT NULL
                                               AND User_Positions.Service_Region_Id IS NULL
                                               AND User_Positions.Service_Market_Id IS NULL THEN Service_Zones.Zone_Number
                                          ELSE 'HQ'
                                        END
                    , Position_Level = CASE
                                         WHEN User_Positions.Service_Market_Id IS NOT NULL THEN 3
                                         WHEN User_Positions.Service_Region_Id IS NOT NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 2
                                         WHEN User_Positions.Service_Zone_Id IS NOT NULL
                                              AND User_Positions.Service_Region_Id IS NULL
                                              AND User_Positions.Service_Market_Id IS NULL THEN 1
                                         ELSE 0
                                       END
                    , Business_Segment_Id = CASE
                                              WHEN User_Positions.Service_Market_Id IS NOT NULL THEN Service_Markets.Business_Segment_Id
                                              WHEN User_Positions.Service_Market_Id IS NULL
                                                   AND User_Positions.Service_Region_Id IS NOT NULL THEN Service_Regions.Business_Segment_Id
                                              WHEN User_Positions.Service_Market_Id IS NULL
                                                   AND User_Positions.Service_Region_Id IS NULL
                                                   AND User_Positions.Service_Zone_Id IS NOT NULL THEN Service_Zones.Business_Segment_Id
                                              ELSE 0
                                            END
               FROM User_Positions
                    LEFT JOIN Service_Zones
                      ON Service_Zones.Service_Zone_Id = User_Positions.Service_Zone_Id
                    LEFT JOIN Service_Regions
                      ON Service_Regions.Service_Region_Id = User_Positions.Service_Region_Id
                    LEFT JOIN Service_Markets
                      ON Service_Markets.Service_Market_Id = User_Positions.Service_Market_Id
              WHERE 1 = 1

                    AND LEN(User_Positions.Position_Label) > 0
                    <!---if finding currently selected positions--->
                    <cfif arguments.IDList neq "">
                      AND User_Positions.User_Positions_ID IN (<cfqueryparam value="#arguments.IDList#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
                    <cfelse>
                      <cfif arguments.ignoreDeletedFlag NEQ 1>
                        AND User_Positions.Deleted = 0
                        AND (User_Positions.Service_Zone_ID   IS NULL OR (Service_Zones.Deleted = 0))
                        AND (User_Positions.Service_Region_ID IS NULL OR (Service_Regions.Deleted = 0))
                        AND (User_Positions.Service_Market_ID IS NULL OR (Service_Markets.Deleted = 0))
                      </cfif>
                      <!---did not select any levels!!--->
					  <!--- 28286	Reassigning from within a program
					  	 level = blank means an argument was passed in and need to filter on it
                      level = -1 means no argument was passed in, do not filter on level
                      level = a value means filter on the level 
                       --->

                      <cfif len(arguments.level) eq 0>
                        AND ( 1 = 0 )
                      </cfif>
                      <!---did not select any segments!!--->
                      <cfif len(arguments.segments) eq 0>
                        AND ( 1 = 0 )
                      </cfif>
                    </cfif>
           ) AS Up
           LEFT JOIN Business_Segment
             ON Business_Segment.Business_Segment_Id = Up.Business_Segment_Id
      WHERE 1 = 1
            <!---if not finding currently selected positions--->
  		  <cfif arguments.Position_Level NEQ 0>
			  	AND Position_Level >= #arguments.Position_Level#
		  </cfif>
            <cfif arguments.IDList eq "">
              <cfif len(trim(arguments.keyword))>
                AND (
                      <cfloop from="1" to="#ArrayLen(vars.keywords)#" index="vars.word_count">
                        <!---add OR operator between word search conditions--->
                        <cfif vars.word_count gt 1> OR </cfif>
                           Position_Label  LIKE <cfqueryparam value="%#vars.keywords[vars.word_count]#%" cfsqltype="cf_sql_varchar">
                        OR Position_Number LIKE <cfqueryparam value="%#vars.keywords[vars.word_count]#%" cfsqltype="cf_sql_varchar">
                      </cfloop>
                    )
              </cfif>
              <!---process multi-selection of sales levels--->
			  	<!--- 28286	Reassigning from within a program : added level argument check for neq -1--->
              <cfif len(arguments.level) and arguments.level neq "-1">
                AND (Position_Level IN (<cfqueryparam value="#arguments.level#" cfsqltype="CF_SQL_INTEGER" list="Yes">))
              </cfif>
              <!---process multi-selection of segments, skip this condition when business segment is disabled--->
              <cfif arguments.segments neq "disabled" and len(arguments.segments)>
                AND ((Up.Service_Zone_Id IS NULL) 
                			OR (Up.Position_Label = 'NONE')      <!---30002--->
                			OR (Up.Business_Segment_Id IN (<cfqueryparam value="#arguments.segments#" cfsqltype="CF_SQL_INTEGER" list="Yes">)))
              </cfif>
              <cfif arguments.sortBy neq "">
              ORDER BY #arguments.sortBy#
              </cfif>
            </cfif>
		</cfquery>

		<cfreturn qGetPositions />

	</cffunction>

	<cffunction name="getPositionLevel" output="false" returntype="numeric">

		<cfargument name="qPosition" type="query" required="true" />

		<cfset var iLevel = -1 />

		<cfif qPosition.recordCount>
			<cfif qPosition.Service_Zone_ID eq "" and qPosition.Service_Region_ID eq "" and qPosition.Service_Market_ID eq "">
				<cfset iLevel = 0 /> <!--- hq --->
			<cfelseif qPosition.Service_Zone_ID neq "" and qPosition.Service_Region_ID eq "" and qPosition.Service_Market_ID eq "">
				<cfset iLevel = 1 /> <!--- zone --->
			<cfelseif qPosition.Service_Zone_ID neq "" and qPosition.Service_Region_ID neq "" and qPosition.Service_Market_ID eq "">
				<cfset iLevel = 2 /> <!--- region --->
			<cfelseif qPosition.Service_Zone_ID neq "" and qPosition.Service_Region_ID neq "" and qPosition.Service_Market_ID neq "">
				<cfset iLevel = 3 /> <!--- market --->
			</cfif>
		</cfif>

		<cfreturn iLevel />

	</cffunction>

	<cffunction name="getHQPosition" output="false" returntype="query">

		<cfset HQPositionId = 0 />

		<cfquery NAME="qGetHQPosition" DATASOURCE="#application.datasource#">
			SELECT	User_Positions.User_Positions_ID, User_Positions.Position_Label
			FROM	User_Positions
			WHERE	User_Positions.Deleted = 0
			AND		User_Positions.Service_Zone_ID IS NULL <!------ Zone ID will be null for a hq positions ----->
			AND		User_Positions.Service_Region_ID IS NULL <!------ Region ID will be null for a hq positions ----->
			AND		User_Positions.Service_Market_ID IS NULL <!------ Market ID will be null for a hq positions ----->

		</cfquery>

		<cfreturn qGetHQPosition />

	</cffunction>

	<cffunction name="getZonePosition" output="false" returntype="string">

		<cfargument name="regionId" type="string" required="true" />

		<cfset zonePositionId = 0 />

		<cfquery NAME="qGetZonePosition" DATASOURCE="#application.datasource#">
			SELECT	User_Positions.User_Positions_ID
			FROM	Service_Regions
					INNER JOIN User_Positions
					ON
					User_Positions.Service_Zone_ID = Service_Regions.Service_Zone_ID
					AND
					User_Positions.Deleted = 0
					AND
					User_Positions.Service_Region_ID IS NULL <!------ Region ID will be null for a zone positions ----->
					AND
					User_Positions.Service_Market_ID IS NULL <!------ Market ID will be null for a zone positions ----->
			WHERE
					Service_Regions.Service_Region_ID = '#arguments.regionId#'
					AND
					Service_Regions.Deleted = 0
		</cfquery>

		<cfloop query="qGetZonePosition">

			<cfset zonePositionId = User_Positions_ID />

		</cfloop>

		<cfreturn zonePositionId />

	</cffunction>

	<cffunction name="getPositionsAbove" output="true" returntype="string">

		<cfargument name="positionIdList" type="string" required="true" />
		<cfargument name="AddCurrentPosition" type="boolean" required="false" default="1" />

		<cfset lPositionsAbove = "" />

		<!------ get position information ----->
		<cfquery NAME="qGetPositionInfo" datasource="#application.datasource#">
			SELECT     	Service_Market_ID, Service_Region_ID, Service_Zone_ID, User_Positions_ID
			FROM      	User_Positions
			WHERE
					<cfif arguments.positionIdList NEQ "">
						User_Positions_ID IN (#arguments.positionIdList#)
					<cfelse>1 = 2
					</cfif>
						AND
						Deleted = 0
		</cfquery>

		<!------ Add current position ----->
		<cfif arguments.AddCurrentPosition IS 1>
		<cfset lPositionsAbove = ValueList(qGetPositionInfo.User_Positions_ID)>
		</cfif>

		<cfloop query="qGetPositionInfo">
			<!--- Current Position is a market  --->
			<cfif
				len(trim(Service_Zone_ID)) GT 0
				AND
				len(trim(Service_Region_ID)) GT 0
				AND
				len(trim(Service_Market_ID)) GT 0
			>

				<!------ Get the regions and zones above this market ----->
				<cfquery NAME="qGetRegionPosition" DATASOURCE="#application.datasource#">
					SELECT	User_Positions.User_Positions_ID, User_Positions.Service_Region_ID
					FROM	Service_Markets
							INNER JOIN User_Positions
							ON
							User_Positions.Service_Region_ID = Service_Markets.Service_Region_ID
							AND
							User_Positions.Deleted = 0
							AND
							User_Positions.Service_Market_ID IS NULL <!------ Market ID will be null for a region positions ----->
					WHERE
							Service_Markets.Service_Market_ID = '#trim(Service_Market_ID)#'
							AND
							Service_Markets.Deleted = 0
				</cfquery>

				<cfif qGetRegionPosition.RecordCount GT 0>
					<cfset lPositionsAbove = ListAppend(lPositionsAbove, qGetRegionPosition.User_Positions_ID)>

					<cfset zonePositionId = this.getZonePosition(trim(qGetRegionPosition.Service_Region_ID)) />

					<cfif zonePositionId>
						<cfset lPositionsAbove = ListAppend(lPositionsAbove, zonePositionId)>
					</cfif>
				</cfif>
			</cfif>

			<!------ Get the zones above this region ----->
			<cfif
				len(trim(Service_Zone_ID)) GT 0
				AND
				len(trim(Service_Region_ID)) GT 0
				AND
				Service_Market_ID 	EQ ""
			>

				<cfset zonePositionId = this.getZonePosition(trim(Service_Region_ID)) />

				<cfif zonePositionId>
					<cfset lPositionsAbove = ListAppend(lPositionsAbove, zonePositionId)>
				</cfif>
			</cfif>


			<!------ There is nothing above zone ----->
			<cfif
				len(trim(Service_Zone_ID)) GT 0
				AND
				Service_Region_ID	EQ	""
				AND
				Service_Market_ID 	EQ	""
			>
				<!------ Nothing to add ----->


			</cfif>

			<!--- GOD --->
			<cfif
				Service_Zone_ID	EQ	""
				AND
				Service_Region_ID	EQ	""
				AND
				Service_Market_ID 	EQ	""
			>
				<!------ Nothing to add, HQ position will be added later ----->
				<cfset lPositionsAbove = "" />

			</cfif>
		</cfloop>


		 <!------ get the HQ position id ----->
		<cfset useLakebaseForqGetHQ = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForqGetHQ>
	<cftry>
		<cfset qGetHQ = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"deleted" = "eq.0",
				"service_market_id" = "is.null",
				"service_region_id" = "is.null",
				"service_zone_id" = "is.null",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetHQ = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetHQ>
<cfquery NAME="qGetHQ" datasource="#application.datasource#">
			SELECT     User_Positions_ID
			FROM       User_Positions
			WHERE
						Deleted = 0
						AND Service_Market_ID IS NULL
						AND Service_Region_ID IS NULL
						AND Service_Zone_ID IS NULL
		</cfquery>
</cfif>

		<Cfif arguments.AddCurrentPosition IS 1 OR NOT Listfind(arguments.positionIdList, qGetHQ.User_Positions_ID)>

			<!------ Add HQ ----->
			<cfset lPositionsAbove = ListAppend(lPositionsAbove, qGetHQ.User_Positions_ID)>

		</CFIF>

		<cfreturn lPositionsAbove />

	</cffunction>

	<!--- Get the position immediatly above current --->
	<cffunction name="getFirstPositionAbove" output="true" returntype="string">

		<cfargument name="positionId" type="numeric" required="true" />

		<CFPARAM NAME="positionId" DEFAULT="">
		<CFPARAM NAME="lPositionsAbove" DEFAULT="-1">


		<!------ get position information ----->
		<cfquery NAME="qGetPositionInfo" datasource="#application.datasource#">
			SELECT     	Service_Market_ID, Service_Region_ID, Service_Zone_ID, User_Positions_ID
			FROM      	User_Positions
			WHERE
						User_Positions_ID = '#positionId#'
						AND
						Deleted = 0
		</cfquery>

		<cfset UserPostionIndicator = "">

		<cfset tempZoneID 	= qGetPositionInfo.Service_Zone_ID>
		<cfset tempRegionID = qGetPositionInfo.Service_Region_ID>
		<cfset tempMarketID = qGetPositionInfo.Service_Market_ID>

		<!--- zone --->
		<cfif len(trim(tempZoneID)) EQ 0>
			<cfset UserPostionIndicator = "0">
		<cfelse>
			<cfset UserPostionIndicator = "1">
		</cfif>

		<!--- region --->
		<cfif len(trim(tempRegionID)) EQ 0>
			<cfset UserPostionIndicator = UserPostionIndicator & "0">
		<cfelse>
			<cfset UserPostionIndicator = UserPostionIndicator & "1">
		</cfif>


		<!--- market --->
		<cfif len(trim(tempMarketID)) EQ 0>
			<cfset UserPostionIndicator = UserPostionIndicator & "0">
		<cfelse>
			<cfset UserPostionIndicator = UserPostionIndicator & "1">
		</cfif>


		<!---
			000 = god
			100 = zone
			110 = region
			111 = market
		 --->

		 <cfswitch expression="#UserPostionIndicator#">
		 	<cfcase value="000">
				<!---<cfset lPositionsAbove = positionId>--->
				<cfset tempZoneID 	= "NULL">
				<cfset tempRegionID = "NULL">
				<cfset tempMarketID = "NULL">
			</cfcase>

		 	<cfcase value="100">
				<cfset tempZoneID 	= "NULL">
				<cfset tempRegionID = "NULL">
				<cfset tempMarketID = "NULL">
			</cfcase>

		 	<cfcase value="110">
				<!---<cfset tempZoneID 	= "'" & tempZoneID & "'">--->
				<cfset tempRegionID = "NULL">
				<cfset tempMarketID = "NULL">
			</cfcase>

		 	<cfcase value="111">
				<!---<cfset tempZoneID 	= "'" & tempZoneID & "'"> --->
				<!---<cfset tempRegionID = "'" & tempRegionID & "'"> --->
				<cfset tempMarketID = "NULL">
			</cfcase>

			<cfdefaultcase>

			</cfdefaultcase>

		 </cfswitch>

		<cfif UserPostionIndicator NEQ "000">
			<cfquery name="getPositionAbove" datasource="#application.datasource#">
				SELECT User_Positions_ID
				FROM User_Positions
				WHERE
					Service_Zone_ID  <cfif tempZoneID EQ "NULL"> is NULL <cfelse> = '#tempZoneID#'</cfif>
					<!--- <cfqueryparam value="#tempZoneID#" cfsqltype="CF_SQL_VARCHAR" null="yes" /> --->
					AND
					Service_Region_ID 	<cfif tempRegionID EQ "NULL"> is NULL <cfelse> = '#tempRegionID#'</cfif>
					<!--- <cfqueryparam value="#tempRegionID#" cfsqltype="CF_SQL_VARCHAR" null="yes" /> --->
					AND
					Service_Market_ID 	<cfif tempMarketID EQ "NULL"> is NULL <cfelse> = '#tempRegionID#'</cfif>
					<!---<cfqueryparam value="#tempMarketID#" cfsqltype="CF_SQL_INTEGER" null="yes" /> --->
					AND
					Deleted = 0
			</cfquery>
			 <cfset lPositionsAbove = valuelist(getPositionAbove.User_Positions_ID)>

		 </cfif>

		<cfreturn lPositionsAbove />

	</cffunction>
	
<!--- Dev Note: drachala; D28728: Email field associated with program announcements  --->	
	<cffunction name="usersemailassociatedtoshipto" output="false" returntype="Query">
		<cfargument name="contract_main_id" type="numeric" required="true">
		<cfquery name="qgetusersemailassociatedtoshipto" datasource="#application.datasource#">
			select distinct _users.user_email from
			contract_distributors
			inner join bsa_foodservice_customers on bsa_foodservice_customers.bsa_foodservice_customers_id =
			contract_distributors.bsa_foodservice_customers_id
			<cfif appSettings.getDistributorMultiPosition()>
			inner join market_distributor 
			on    market_distributor.distributor_id = bsa_foodservice_customers.bsa_foodservice_customers_id
			and   market_distributor.deleted = 0
			inner join user_positions 
			on user_positions.service_market_id = market_distributor.service_market_id
			<cfelse>
			inner join bsa_foodservice_brokers on bsa_foodservice_brokers.bsa_foodservice_brokers_id =
			bsa_foodservice_customers.bsa_foodservice_brokers_id
			inner join user_positions on user_positions.service_market_id =
			bsa_foodservice_brokers.service_market_id
			</cfif>     
			and user_positions.deleted = 0
			inner join user_position_holders on user_position_holders.user_positions_id =
			user_positions.user_positions_id
			and user_positions.service_region_id IS NOT NULL and user_positions.service_zone_id IS NOT NULL
			and user_position_holders.deleted = 0
			inner join _users on _users.user_id = user_position_holders.user_id
			and _users.deleted = 0
			where contract_distributors.deleted =0
			and contract_distributors.contract_main_id = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	<cfreturn qgetusersemailassociatedtoshipto />
	</cffunction>
<!--- End Dev Note: drachala; D28728: Email field associated with program announcements  --->
</cfcomponent>