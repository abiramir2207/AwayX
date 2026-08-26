<!-----------------------------------------------------------------------------

FILE NAME:		planner_template_lock_unlock.cfm
DESCRIPTION:	Lock/Unlock
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	31-May-2022

------------------------------------------------------------------------------>

<cfif (isDefined("qGetPlannerTemplate") AND qGetPlannerTemplate.RecordCount NEQ 0)>
	<cfset useLakebaseForgetLockedUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetLockedUser>
	<cftry>
		<cfset getLockedUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetPlannerTemplate.Locked_By_User_ID#",
				"select" = "name_first + ' ' + name_last as locked_user"
			}), "name_first + ' ' + name_last as locked_user"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetLockedUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetLockedUser>
<cfquery name="getLockedUser" datasource="#application.datasource#">
	      SELECT Name_First + ' ' + Name_Last AS Locked_user  FROM _users WHERE USER_ID = '#qGetPlannerTemplate.Locked_By_User_ID#'
	</cfquery>
</cfif>
	<cfoutput>
	<cfset variables.inEditMode = 0>
	<div style="display:flex;width:80%;">
		<div style="flex:1;width:50%;">
			<!--- Check to lock/unlock --->
			<cfif ((qGetPlannerTemplate.Locked_By_User_ID NEQ request.AccessStructure.User_ID)
					AND (qGetPlannerTemplate.Is_Locked))>
				<!--- if locked by other users --->
				<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(getLockedUser.Locked_User)#"><br>
				<span class="modeText locked">Locked By #ucase(getLockedUser.Locked_User)#</span>
			<cfelse>
				<cfif (qGetPlannerTemplate.Is_Locked EQ 1)>
					<!--- locked --->
					<a href="index.cfm?lockUnlock=0&id=#url.id#" style="text-decoration:none;">
						<img name="lock" src="/images/edit_mode.gif" border="0" title="Click for Read Only"><br>
						<span class="modeText">#application.util.string.actionLinkFormat("click for read only")#</span>
					</a>
					<cfset variables.inEditMode = 1>
				<cfelse>
					<!--- unlocked --->
					<a href="index.cfm?lockUnlock=1&id=#url.id#" style="text-decoration:none;">
						<img name="lock" src="/images/readonly_mode.gif" border="0" title="Click to Edit"><br>
						<span class="modeText">#application.util.string.actionLinkFormat("click to edit")#</span>
					</a>
				</cfif>
			</cfif>
		</div>
		</cfoutput>
		<div align="left" class="labelname" style="width:50%;"><br>
		<cfoutput>#qGetPlannerTemplate.Planner_Type#</cfoutput></div>
	</div>
</cfif>
 