<!--- unlock this users billbacks --->
<cfparam name="url.filterIds" default="">

<cfset useLakebaseForqGetBBsLockedByMe = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForqGetBBsLockedByMe>
	<cftry>
		<cfset qGetBBsLockedByMe = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"bb_is_locked" = "eq.1",
				"bb_locked_by_user_id" = "eq.#request.AccessStructure.User_ID#",
				"bb_locked_by_match_central" = "eq.0",
				"select" = "bb_is_locked"
			}), "bb_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBBsLockedByMe = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBBsLockedByMe>
<cfquery name="qGetBBsLockedByMe" datasource="#Application.Datasource#">
	SELECT BB_Is_Locked
	FROM Billback_Allied
	WHERE 
		BB_Is_Locked			=	1 AND
		BB_Locked_By_User_ID	= '#request.AccessStructure.User_ID#'
			AND BB_Locked_By_Match_Central = 0
</cfquery>
</cfif>
<CFIF qGetBBsLockedByMe.recordcount GT 0>
	<cfquery name="Unlock_Billbacks" datasource="#application.datasource#">
		UPDATE 	Billback_Allied
		SET 	
				BB_Is_Locked = 0			
		WHERE 
				BB_Is_Locked = 1 AND
				BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
			AND BB_Locked_By_Match_Central = 0
			<!--- Dev Note: (71844) Fix for the following issue:
			- Click on "Request for Approval" from the billback scorecard
			- Click on the "deviation" icon. At this time, the billback gets locked by the user
			- Click on any of the buttons at the top of the deviation screen. eg: "claimed $"
			- WR 55344 had made an enhancement, where on the above click, the selected billback gets removed from
			the billback scorecard, but the issue was that when the user gets directed to the billback, the billback gets
			unlocked by this query as the bb scorecard gets refreshed. below code will prevent that.
			--->
			<cfif url.filterIds neq "">
			AND Billback_id NOT IN (#ListQualify(url.filterIds,"'","," )#)
			</cfif>
	</cfquery>
</CFIF>