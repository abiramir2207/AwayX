<cfcomponent hint="Group User Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.GroupUserManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.GroupUser">
		
		<cfargument name="id" type="string" required="true" />
		
		<cfset this.groupUser = CreateObject("component", "components.futures_pricing.GroupUser").init() />
		
		<cfif arguments.id>
		
			<cfquery name="qGetGroupUser" datasource="#application.datasource#">
				SELECT	FP_User_Group_Member.FP_User_Group_Member_ID, FP_User_Group_Member.FP_User_Group_ID, 
						FP_User_Group_Member.User_ID, _Users.Name_First + ' ' + _Users.Name_Last AS User_Full_Name
				FROM	FP_User_Group_Member
						INNER JOIN _Users
						ON
						_Users.User_ID = FP_User_Group_Member.User_ID
						AND
						_Users.Deleted = 0
				WHERE
						FP_User_Group_Member.Deleted = 0
						AND
						FP_User_Group_Member.FP_User_Group_Member_ID = #arguments.id#
			</cfquery>
			
			<cfloop query="qGetGroupUser">
			
				<cfset this.groupUser.setId(FP_User_Group_Member_ID)>
				<cfset this.groupUser.setUserId(User_ID)>
				<cfset this.groupUser.setUserGroupId(FP_User_Group_ID)>
				<cfset this.groupUser.setName(User_Full_Name)>
			
			</cfloop>
			
		</cfif>
		
		<cfreturn this.groupUser />
	
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cfargument name="idList" type="string" required="true" />
		<cfargument name="groupId" type="numeric" required="true" />
		<cfargument name="UpdatedByUserId" type="string" required="true" />
		
		<!------ Delete all entries ----->
		<cfset useLakebaseForqDeleteGroupUsers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_user_group_member")>
<cfif useLakebaseForqDeleteGroupUsers>
	<cftry>
		<cfset application.oLakebase.updateRows("fp_user_group_member",
			{
				"fp_user_group_id" = "eq.#arguments.groupId#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteGroupUsers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteGroupUsers>
<cfquery name="qDeleteGroupUsers" datasource="#application.datasource#">
			UPDATE	FP_User_Group_Member
			SET		Deleted = 1
			WHERE
					FP_User_Group_ID = #arguments.groupId#
					AND
					Deleted = 0
		</cfquery>
</cfif>
		
		<!------ insert entries ----->
		<cfloop list="#arguments.idList#" delimiters="," index="thisUserId">
		
			<cfquery name="qInsertGroupUsers" datasource="#application.datasource#">
				INSERT INTO FP_User_Group_Member (FP_User_Group_ID, User_ID)
				VALUES (<cfqueryparam value="#arguments.groupId#" cfsqltype="CF_SQL_NUMERIC">, <cfqueryparam value="#thisUserId#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		
		</cfloop>
		
		<cfquery name="qUpdateLastSavedBy" datasource="#application.datasource#">

			UPDATE	FP_User_Group
			SET		UsersUpdatedBy = <cfqueryparam value="#arguments.UpdatedByUserId#" cfsqltype="CF_SQL_VARCHAR">,
					UsersUpdatedOn = GetDate()
			WHERE
					FP_User_Group_ID = <cfqueryparam value="#arguments.groupId#" cfsqltype="CF_SQL_NUMERIC">
					AND
					Deleted = 0
					
		</cfquery>	
		
	
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
	
		<cfargument name="groupId" type="numeric" required="true" />
		<cfargument name="findRequestExist" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetGroupUsers" datasource="#application.datasource#">
			SELECT	FP_User_Group_Member.FP_User_Group_Member_ID, FP_User_Group_Member.FP_User_Group_ID, 
					FP_User_Group_Member.User_ID, _Users.Name_First + ' ' + _Users.Name_Last AS User_Full_Name
					<cfif arguments.findRequestExist>
					, (
						SELECT 	TOP 1 FP_Request_User_ID
						FROM	FP_Request_User
						WHERE
								FP_Request_User.Deleted = 0
								AND
								FP_Request_User.User_ID = FP_User_Group_Member.User_ID
								AND
								FP_Request_User.FP_User_Group_ID = #arguments.groupId#
					)AS RequestExist
					</cfif>
			FROM	FP_User_Group_Member
					INNER JOIN _Users
					ON
					_Users.User_ID = FP_User_Group_Member.User_ID
					AND
					_Users.Deleted = 0
			WHERE
					FP_User_Group_Member.Deleted = 0
					AND
					FP_User_Group_Member.FP_User_Group_ID = #arguments.groupId#
			ORDER BY _Users.Name_First
		</cfquery>
		
		<cfreturn qGetGroupUsers />
	
	</cffunction>
	
	<cffunction name="getGroupName" output="false" returntype="string">
	
		<cfargument name="groupId" type="numeric" required="true" />
		
		<cfset returnValue = "" />
		
		<cfset useLakebaseForqGetGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_user_group")>
<cfif useLakebaseForqGetGroup>
	<cftry>
		<cfset qGetGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_user_group", {
				"deleted" = "eq.0",
				"fp_user_group_id" = "eq.#arguments.groupId#",
				"select" = "fp_user_group_desc"
			}), "fp_user_group_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroup>
<cfquery name="qGetGroup" datasource="#application.datasource#">
			SELECT	FP_User_Group.FP_User_Group_Desc
			FROM	FP_User_Group					
			WHERE
					FP_User_Group.Deleted = 0
					AND
					FP_User_Group.FP_User_Group_ID = #arguments.groupId#
		</cfquery>
</cfif>
		
		<cfloop query="qGetGroup">
		
			<cfset returnValue = FP_User_Group_Desc />
		
		</cfloop>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	
	<cffunction name="getGroup" output="false" returntype="components.futures_pricing.GroupUserGroup">
		
		<cfargument name="id" type="numeric" required="true" />
		
		<cfset this.groupUserGroup = CreateObject("component", "components.futures_pricing.GroupUserGroup").init() />
		
		<cfif arguments.id>
		
			<cfquery name="qGetGroupUserGroup" datasource="#application.datasource#">
				SELECT	FP_User_Group.FP_User_Group_ID, FP_User_Group.FP_User_Group_Desc,
						FP_User_Group.UsersUpdatedBy, FP_User_Group.UsersUpdatedOn,
						_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName
				FROM	FP_User_Group
						LEFT JOIN _Users
						ON
						_Users.Deleted = 0
						AND
						_Users.User_ID = FP_User_Group.UsersUpdatedBy			
				WHERE
						FP_User_Group.Deleted = 0
						AND
						FP_User_Group.FP_User_Group_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfloop query="qGetGroupUserGroup">
			
				<cfset this.groupUserGroup.setId(FP_User_Group_ID)>
				<cfset this.groupUserGroup.setDesc(FP_User_Group_Desc)>
				<cfset this.groupUserGroup.setUpdatedBy(UsersUpdatedBy)>
				<cfset this.groupUserGroup.setUpdatedByUserName(UpdatedByFullName)>
				<cfset this.groupUserGroup.setUpdatedOn(UsersUpdatedOn)>
			
			</cfloop>
			
		</cfif>
		
		<cfreturn this.groupUserGroup />
	
	</cffunction>
	
	
</cfcomponent>
