<!---
	Name:
		user.cfc
	Created By:
		Tim Ford 04/29/2003 
	Description:
		Component used to get users
--->

<cfcomponent>
	
	<cffunction name="getUser" access="public" returntype="query">
	
		<cfargument name="user_id" type="any" required="false" default="" />
		
		<cfset useLakebaseForqGetUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqGetUser>
	<cftry>
		<cfset qGetUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#arguments.user_id#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUser>
<cfquery name="qGetUser" datasource="#application.datasource#">
			SELECT 	name_first,
					name_last 
			FROM 	_users
			WHERE 	user_id = '#arguments.user_id#'
		</cfquery>
</cfif>
		
		<cfreturn qGetUser>
		
	</cffunction>
	
	<!---
	<cffunction access="public" name="getUserPosition" output="false" returntype="string">
	
		<cfargument name="user_id" type="any" required="false" default="" />
		
		<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#arguments.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" DATASOURCE="#application.datasource#">
			SELECT 	User_Positions_ID	
			FROM 	User_Position_Holders
			WHERE 	User_ID = '#arguments.user_id#'
			AND 	Deleted = 0
		</CFQUERY>
</cfif>
		
		<cfreturn getUserPosition.User_Positions_ID>
		
	</cffunction>
	--->

	<cffunction name="getUserPosition" output="false" returntype="string">
	
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="isPrimary" type="numeric" required="false" default="1" />
		
		<cfquery name="getUserPosition" datasource="#application.datasource#">
			SELECT	User_Position_Holders.User_Positions_ID
			FROM	User_Position_Holders			
				INNER JOIN User_Positions
				ON User_Positions.User_Positions_ID	= User_Position_Holders.User_Positions_ID
				AND User_Positions.Deleted = 0
			WHERE
					User_ID = '#arguments.userId#'
					<cfif arguments.isPrimary>
					AND  User_Position_Type = 'P'
					</cfif>
					AND	 User_Position_Holders.Deleted = 0
					AND	 User_Position_Holders.User_Positions_ID <> 0
		</cfquery>
		
		<cfif getUserPosition.recordCount>
			<cfreturn ValueList(getUserPosition.User_Positions_ID, ",") />
		<cfelse>	
			<cfreturn 0 />
		</cfif>
	
	</cffunction>

</cfcomponent>