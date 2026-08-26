<cfcomponent displayname="UserPositionManager" hint="This component is about to handle all the function related to the position">


	<cfproperty name="userPositions" 		type="query"/> 
	<cfproperty name="usersAndPositions" 	type="query"/> 
	<cfset variables.userPositions = "" />
	<cfset variables.usersAndPositions = "" />
	<!--- initialization ---->
	<cffunction name="init" returntype="UserPositionManager" output="false" access="public">
		<cfset loadUserPositions() />
		<cfset loadUsersAndPositions() />
		<cfreturn this />
	</cffunction>
	<!--- getter ---->
	<cffunction name="getUserPositions" returntype="query" access="public" output="false">
		<cfreturn variables.userPositions />
	</cffunction>
	<cffunction name="getUsersAndPositions" returntype="query" access="public" output="false">
		<cfreturn variables.usersAndPositions />
	</cffunction>
	<!--- setter ---->
	<cffunction name="setUserPositions" returntype="void"  access="package" output="false">
		<cfargument name="userPositions" type="query" required="true" />
		<cfset variables.userPositions = arguments.userPositions />
	</cffunction>
	<cffunction name="setUsersAndPositions" returntype="void"  access="package" output="false">
		<cfargument name="usersAndPositions" type="query" required="true" />
		<cfset variables.usersAndPositions = arguments.usersAndPositions />
	</cffunction>
	<!--- methods --->
	<cffunction name="loadUserPositions" access="package" returntype="void" output="false">
		<CFQUERY NAME="Get_User_Positions" DATASOURCE="#application.datasource#">
			SELECT	User_Positions_ID, Position_Label
			FROM	User_Positions
			WHERE
					len(Position_Label) <> 0
					AND
					Deleted = 0
					AND
					(
						User_Positions.Service_Market_ID IS NULL
						OR EXISTS
						(
							SELECT  *
							FROM 	Service_Markets
							WHERE 	
									Deleted = 0
									AND
									Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
						)
					)
					AND
					(
						User_Positions.Service_Region_ID IS NULL
						OR EXISTS
						(
							SELECT  *
							FROM 	Service_Regions
							WHERE 	
									Deleted = 0
									AND
									Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
						)
					)
					AND
					(
						User_Positions.Service_Zone_ID IS NULL
						OR EXISTS
						(
							SELECT  *
							FROM 	Service_Zones
							WHERE 	
									Deleted = 0
									AND
									Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
						)
					)
			ORDER BY Position_Label
		</CFQUERY>
		<cfset setUserPositions(Get_User_Positions) />
	</cffunction>
	<cffunction name="loadUsersAndPositions" access="package" returntype="void" output="false">
	
	
<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
	
		<CFQUERY NAME="Get_Users_And_Positions" DATASOURCE="#application.datasource#">
			SELECT	_Users.User_ID, User_Positions_ID, _Users.Name_First + ' ' +  _Users.Name_Last AS User_Name
			FROM	_Users
					INNER JOIN User_Position_Holders
					ON
					User_Position_Holders.User_ID = _Users.User_ID
					AND
					User_Position_Holders.Deleted = 0
					AND User_Position_Holders.User_Position_Type = 'P'
			WHERE
					_Users.Deleted = 0				
					AND
					Len(_Users.Name_First) > 0
					AND
					Len(_Users.Name_Last) > 0
				<!---Don't show BSA users --->
				<cfif appSettings.getHide_BSA_Users() IS 1>
				AND (_Users.User_Rights_ID IS NULL 
				OR _Users.User_Rights_ID != 9999)
				</cfif>
			ORDER BY _Users.Name_First
		</CFQUERY>
		<cfset setUsersAndPositions(Get_Users_And_Positions) />
	</cffunction>
	
	<cffunction name="getPositionType" returntype="struct" output="false">
		<cfargument name="position_id" type="numeric" required="true">

			<cfset var structPositionType = StructNew()>

			<CFQUERY NAME="qGetPositionType" DATASOURCE="#application.datasource#">
			SELECT 
				CASE WHEN Service_Zone_ID IS NULL AND Service_Region_ID Is NULL AND Service_Market_ID IS NULL
					THEN 'O'<!--- hq --->
				WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID Is NULL AND Service_Market_ID IS NULL
					THEN '1'<!--- zone --->
				WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID Is NOT NULL AND Service_Market_ID IS NULL
					THEN '2'<!--- region --->
				WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID Is NOT NULL AND Service_Market_ID IS NOT NULL
					THEN '3'<!--- market --->
			END
			As position_type,
				CASE WHEN Service_Zone_ID IS NULL AND Service_Region_ID Is NULL AND Service_Market_ID IS NULL
					THEN '' <!--- hq --->
				WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID Is NULL AND Service_Market_ID IS NULL
					THEN CAST(Service_Zone_ID As varchar(50)) <!--- zone --->
				WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID Is NOT NULL AND Service_Market_ID IS NULL
					THEN CAST(Service_Region_ID As varchar(50)) <!--- region --->
				WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID Is NOT NULL AND Service_Market_ID IS NOT NULL
					THEN CAST(Service_Market_ID As varchar(50))<!--- market --->
			END
			As position_guid

			FROM User_Positions
			WHERE User_Positions_ID = <cfqueryparam value="#arguments.position_id#" cfsqltype="CF_SQL_INTEGER">
			</CFQUERY>

			<cfset structPositionType.positionType = qGetPositionType.position_type>
			<cfset structPositionType.positionGUID = qGetPositionType.position_guid>

		<cfreturn structPositionType />
	</cffunction>
</cfcomponent>


	