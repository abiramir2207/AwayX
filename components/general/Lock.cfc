<!---------------------------------------------------------------------------------------------------------------------
   Template:\components\general\Lock.cfc
   Date:     2015 March
   Author:   Chris Nguyen
   Purpose:  Manage generic LOCK used in the application

   Remarks:     All previous locks stored in separate tables remain the same.
				Going forward any general LOCK should be stored in LOCK table.
---------------------------------------------------------------------------------------------------------------------->
<cfcomponent output="false">

	<cffunction name="getStatus" access="remote" output="false" hint="Return lock status.">
		<cfargument name="main_id" required="true" type="string" hint="">
		<cfargument name="secondary_id" required="false" type="string" default="">

		<cfquery name="local.lock" datasource="#application.datasource#">
			SELECT l.*
				  ,u.Name_First + ' ' + u.Name_Last AS Locked_By_User_Name
		          ,CASE
			          WHEN Locked_By_User_Id = '#request.AccessStructure.User_ID#' THEN 0
			          WHEN Locked_By_User_Id IS NOT NULL THEN 1
			          ELSE 0
			        END AS Locked_By_Other
			  FROM Lock l
					LEFT JOIN _USERS u ON l.Locked_By_User_ID = u.User_ID
			 WHERE Main_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.main_id#">
			 		<cfif arguments.secondary_id neq "">
			 			AND Secondary_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.secondary_id#">
			 		</cfif>
		</cfquery>
		
		<!--- lock record does not exist --->
		<cfif local.lock.recordCount eq 0>
			<!--- single thread execution to prevent a collision --->
			<cflock name="#application.datasource#_lockcfc_#arguments.main_id#_#arguments.secondary_id#" type="exclusive" timeout="7" throwontimeout="false">
				<!--- check again --->
				<cfquery name="local.lock" datasource="#application.datasource#">
					SELECT l.*
						  ,u.Name_First + ' ' + u.Name_Last AS Locked_By_User_Name
					  FROM Lock l
							LEFT JOIN _USERS u ON l.Locked_By_User_ID = u.User_ID
					 WHERE Main_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.main_id#">
					 		<cfif arguments.secondary_id neq "">
					 			AND Secondary_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.secondary_id#">
					 		</cfif>
				</cfquery>

				<!--- lock record still does not exist - create it --->
				<cfif local.lock.recordCount eq 0>
					<cfquery name="local.lock" datasource="#application.datasource#">
						INSERT INTO dbo.Lock ( Main_ID, Secondary_ID
											 )
									 VALUES  ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.main_id#">
											   ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.secondary_id#">
											 )
					</cfquery>
				</cfif>
			</cflock>

			<!--- reread lock record --->
			<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>
		</cfif>


        <!--- ------------------------------------------------------------------------------------------------- --->
        <!--- if record is locked and locked user session is expired then convert the record status as unlocked --->
        <!--- ------------------------------------------------------------------------------------------------- --->
        <cfif local.lock.Locked_by_other and application.util.query.is_session_expired( local.lock.Locked_By_User_ID )>
            <cfquery name="local.lock" datasource="#application.datasource#">
                SELECT l.*
                      ,' ' AS Locked_By_User_Name
                      ,0 AS Locked_By_Other
                  FROM Lock l
                 WHERE Main_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.main_id#">
                         <cfif arguments.secondary_id neq "">
                             AND Secondary_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.secondary_id#">
                         </cfif>
            </cfquery>    
        </cfif>

		<cfreturn local.lock>
	</cffunction>

	<cffunction name="Lock" access="remote" output="false">
		<cfargument name="main_id" required="true" type="string" hint="">
		<cfargument name="secondary_id" required="false" type="string" default="">
		<cfargument name="one_per_user" required="false" default="true" hint="">

		<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>

		<cfif local.lock.locked_by_other eq 0>
			<!--- single thread execution to prevent collisions --->
			<cfoutput>
			<cflock name="#application.datasource#_lockcfc_#arguments.main_id#_#arguments.secondary_id#" type="exclusive" timeout="7" throwontimeout="false">
				<!--- check again --->
				<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>
				
				<!--- if locking planner and user does not have create rights then don't lock --->
				<cfquery name="local.checkPlannerLock" datasource="#application.datasource#">
					SELECT	u.Name_First, u.Name_Last, u.User_Code, pps.*
					FROM	_Users u
							inner join Profiles p on p.Profiles_ID = u.Profiles_ID
							inner join Planner_Profiles_Settings pps on pps.Profiles_ID = p.Profiles_ID
					WHERE	u.User_ID = '#request.AccessStructure.User_ID#'
				</cfquery>
				
				<cfset bCanLock = 1 />
				<cfif arguments.main_id eq 'Planner' and local.checkPlannerLock.Planner_Create neq 2>
					<cfset bCanLock = 0 />
				</cfif>

				<!--- if lock is still not locked try to lock it --->
				<cfif local.lock.locked_by_other eq 0 and bCanLock eq 1>
					<!--- by default release all locks (based on main_id & user_id) to prevent multiple locks then lock --->

					<cfquery name="local.lock" datasource="#application.datasource#">
						<!--- direct planner margin page has an ability to lock multiple indirect planners --->
						<cfif arguments.one_per_user>
							UPDATE Lock
									SET  Is_Locked = 0
										,Locked_By_User_ID = NULL
										,Locked_Date = NULL
								WHERE Main_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.main_id#">
										AND Locked_By_User_ID = '#request.AccessStructure.User_ID#'
						</cfif>
						UPDATE Lock
								SET  Is_Locked = 1
									,Locked_By_User_ID = '#request.AccessStructure.User_ID#'
									,Locked_Date = GETDATE()
							WHERE Main_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.main_id#">
									AND Secondary_ID =  <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.secondary_id#">
					</cfquery>
				</cfif>
			</cflock>
			</cfoutput>
			<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>
		</cfif>

		<!--- if lock was successful return true otherwise return false --->
		<cfreturn (isDefined("local.lock.Locked_By_User_ID") ? local.lock.Locked_By_User_ID eq request.AccessStructure.User_ID : false)>
	</cffunction>


	<cffunction name="unLockByID" access="public" output="false" hint="Unlock locks based on lock ID">
		<cfargument name="main_id" required="true" type="string" hint="">
		<cfargument name="secondary_id" required="false" type="string" default="">

		<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>

		<cfif local.lock.is_Locked eq 1 and local.lock.locked_by_other eq 0>
			<cfoutput>
			<cflock name="#application.datasource#_lockcfc_#arguments.main_id#_#arguments.secondary_id#" type="exclusive" timeout="7" throwontimeout="false">
				<!--- check again --->
				<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>

				<!--- if lock is locked by the current user or admin wants to unlock try to unlock it --->
				<cfif local.lock.is_Locked eq 1 and local.lock.locked_by_other eq 0>
					<cfquery name="local.lock" datasource="#application.datasource#">
						UPDATE Lock
								SET  Is_Locked = 0
									,Locked_By_User_ID = NULL
									,Locked_Date = NULL
							WHERE Main_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.main_id#">
								AND Secondary_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.secondary_id#">
					</cfquery>
				</cfif>
			</cflock>
			</cfoutput>

			<cfset local.lock = getStatus( arguments.main_id, arguments.secondary_id )>
		</cfif>

		<!--- if unlock was successful return true otherwise return false --->
		<cfreturn (isDefined("local.lock.is_Locked") ? local.lock.is_Locked : false)>
	</cffunction>


	<cffunction name="unLockByUser" access="public" output="false" hint="Unlock locks based on user ID">
		<cfargument name="user_id" required="false" type="string" default="#request.AccessStructure.User_ID#">

		<cfquery name="local.lock" datasource="#application.datasource#">
			UPDATE Lock
					SET  Is_Locked = 0
						,Locked_By_User_ID = NULL
						,Locked_Date = NULL
				WHERE Locked_By_User_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.user_id#">
		</cfquery>
	</cffunction>

</cfcomponent>