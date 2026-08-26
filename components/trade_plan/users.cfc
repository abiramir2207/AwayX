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
		
		<cfquery name="qGetUser" datasource="#application.datasource#">
			SELECT 	name_first,
					name_last 
			FROM 	_users
			WHERE 	user_id = '#arguments.user_id#'
		</cfquery>
		
		<cfreturn qGetUser>
		
	</cffunction>
	
	<!---
	<cffunction access="public" name="getUserPosition" output="false" returntype="string">
	
		<cfargument name="user_id" type="any" required="false" default="" />
		
		<CFQUERY NAME="getUserPosition" DATASOURCE="#application.datasource#">
			SELECT 	User_Positions_ID	
			FROM 	User_Position_Holders
			WHERE 	User_ID = '#arguments.user_id#'
			AND 	Deleted = 0
		</CFQUERY>
		
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