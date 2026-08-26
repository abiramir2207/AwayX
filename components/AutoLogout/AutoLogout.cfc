<cfcomponent hint="System Profile Management">

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>

	<cffunction name="initUserReasonArray" output="true">

		<cfset aryReasonArray = ArrayNew(2)>
		
		<cfreturn aryReasonArray />

	</cffunction>
	
	<cffunction name="queueUserLogout" output="false">
	
		<cfargument name="UserReasonArray" type="array" required="yes">
		
		<cfloop index="x" from="1" to="#arraylen(UserReasonArray)#">
			<cfset userId = UserReasonArray[x][1]>
			<cfset reasonTxt = UserReasonArray[x][2]>
			
			<cfif len(trim(userId)) GT 0 AND len(trim(reasonTxt)) GT 0>
				
				<cfset useLakebaseForisUserAlreadyQueued = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_auto_logout_list")>
<cfif useLakebaseForisUserAlreadyQueued>
	<cftry>
		<cfset isUserAlreadyQueued = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_auto_logout_list", {
				"user_id" = "eq.#userId#",
				"select" = "_users_auto_logout_list_id"
			}), "_users_auto_logout_list_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisUserAlreadyQueued = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisUserAlreadyQueued>
<cfquery name="isUserAlreadyQueued" datasource="#application.datasource#">
					SELECT _Users_Auto_Logout_List_ID
					FROM _Users_Auto_Logout_List
					WHERE User_ID = '#userId#'
				</cfquery>
</cfif>
				<cfset this_Users_Auto_Logout_List_ID = isUserAlreadyQueued._Users_Auto_Logout_List_ID>
				
				<cfif isUserAlreadyQueued.recordcount EQ 0>
					<cfquery name="insertUser" datasource="#application.datasource#">
						SET NOCOUNT ON
						INSERT INTO _Users_Auto_Logout_List
						(User_ID)
						VALUES
						('#userId#')
						SELECT _Users_Auto_Logout_List_ID = @@IDENTITY
						SET NOCOUNT OFF
					</cfquery>
					<cfset this_Users_Auto_Logout_List_ID = insertUser._Users_Auto_Logout_List_ID>
				</cfif>
				
				<cfquery name="checkForExistingReason" datasource="#application.datasource#">
					SELECT Reason_Text
					FROM _Users_Auto_Logout_Reason
					WHERE _Users_Auto_Logout_List_ID = '#this_Users_Auto_Logout_List_ID#' AND Reason_Text = '#reasonTxt#'
				</cfquery>
				
				<!--- insert reason if unique --->
				<cfif checkForExistingReason.recordcount EQ 0>
					<cfset useLakebaseForinsertReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_auto_logout_reason")>
<cfif useLakebaseForinsertReason>
	<cftry>
		<cfset application.oLakebase.insertRow("_users_auto_logout_reason", {
			"_users_auto_logout_list_id" = "#this_Users_Auto_Logout_List_ID#",
			"reason_text" = "#reasonTxt#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertReason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertReason>
<cfquery name="insertReason" datasource="#application.datasource#">
						INSERT INTO _Users_Auto_Logout_Reason
						(_Users_Auto_Logout_List_ID, Reason_Text)
						VALUES
						('#this_Users_Auto_Logout_List_ID#', '#reasonTxt#')
					</cfquery>
</cfif>
				</cfif>
				
			</cfif>
		</cfloop>
	
	</cffunction>

	<cffunction name="removeUserFromQueue" output="false">
		
		<cfargument name="userId" type="string" required="yes">
					
			<cfset useLakebaseForget_USERS_AUTO_LOGOUT_LIST_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_auto_logout_list")>
<cfif useLakebaseForget_USERS_AUTO_LOGOUT_LIST_ID>
	<cftry>
		<cfset get_USERS_AUTO_LOGOUT_LIST_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_auto_logout_list", {
				"user_id" = "eq.#userId#",
				"select" = "_users_auto_logout_list_id"
			}), "_users_auto_logout_list_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_USERS_AUTO_LOGOUT_LIST_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_USERS_AUTO_LOGOUT_LIST_ID>
<cfquery name="get_USERS_AUTO_LOGOUT_LIST_ID" datasource="#application.datasource#">
				SELECT _USERS_AUTO_LOGOUT_LIST_ID
				FROM _USERS_AUTO_LOGOUT_LIST
				WHERE User_ID = '#userId#'
			</cfquery>
</cfif>
			
			<cfset this_USERS_AUTO_LOGOUT_LIST_ID = get_USERS_AUTO_LOGOUT_LIST_ID._USERS_AUTO_LOGOUT_LIST_ID>
			
			<cfset useLakebaseFordeleteUserFromAutoLogOut = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_auto_logout_list")>
<cfif useLakebaseFordeleteUserFromAutoLogOut>
	<cftry>
		<cfset application.oLakebase.deleteRows("_users_auto_logout_list", {
			"_users_auto_logout_list_id" = "eq.#this_USERS_AUTO_LOGOUT_LIST_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteUserFromAutoLogOut = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteUserFromAutoLogOut>
<cfquery name="deleteUserFromAutoLogOut" datasource="#application.datasource#">
				DELETE FROM _Users_Auto_Logout_List
				WHERE _Users_Auto_Logout_List_ID = '#this_USERS_AUTO_LOGOUT_LIST_ID#'
			</cfquery>
</cfif>
			
			<cfset useLakebaseFordeleteUserFromAutoLogOutReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_auto_logout_reason")>
<cfif useLakebaseFordeleteUserFromAutoLogOutReason>
	<cftry>
		<cfset application.oLakebase.deleteRows("_users_auto_logout_reason", {
			"_users_auto_logout_list_id" = "eq.#this_USERS_AUTO_LOGOUT_LIST_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteUserFromAutoLogOutReason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteUserFromAutoLogOutReason>
<cfquery name="deleteUserFromAutoLogOutReason" datasource="#application.datasource#">
				DELETE FROM _Users_Auto_Logout_Reason
				WHERE _Users_Auto_Logout_List_ID = '#this_USERS_AUTO_LOGOUT_LIST_ID#'
			</cfquery>
</cfif>					
					
	</cffunction>
	
	




</cfcomponent>