	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/ViewModes.css">
<!--- init variables --->
<cfparam name="bblock.bb_id"						default="">
<cfparam name="bblock.bb_lock_action" 				default="0">
<cfparam name="bblock.bb_unlock_action"				default="0">
<cfparam name="bblock.user_id_bb_locker"			default="0">
<cfparam name="bblock.relocate_ability"				default="1">
<cfparam name="bblock.bb_is_locked"					default="0">
<cfparam name="bblock.bb_is_unlocked"				default="0">
<cfparam name="bblock.bb_is_locked_by_other_user"	default="0">
<cfparam name="bblock.bb_is_locked_by_other_user_id"	default="0">
<cfparam name="bblock.bb_is_locked_by_name_first"	default="">
<cfparam name="bblock.bb_is_locked_by_name_last"	default="">
<cfparam name="bblock.valid_bb_id"					default="0">



<!--- interface to lock icon command --->
<cfset bblock.user_id_bb_locker = request.AccessStructure.user_id>

<cfif isdefined("url.bbid")>
	<cfset bblock.bb_id = url.bbid> 
</cfif>

<cfif isdefined("url.Billback_IsLocked")>
	<cfif isnumeric(url.Billback_IsLocked)>
		<cfif url.Billback_IsLocked EQ 1>
			<cfset bblock.bb_lock_action = 1>
		</cfif>
		
		<cfif url.Billback_IsLocked EQ 0>
			<cfset bblock.bb_unlock_action = 1>
		</cfif>
	</cfif>
</cfif>


<!--- validate data --->
<cfif len(trim(bblock.bb_id)) GT 0 AND bblock.bb_id NEQ 0>
	<cfset bblock.valid_bb_id = 1>
</cfif>

<CFIF bblock.valid_bb_id EQ 1>
	<cfquery name="getCurrentStatus" datasource="#application.datasource#">
		SELECT     BB_Is_Locked, BB_Locked_By_User_ID, BB_Locked_By_Match_Central
		FROM         dbo.Billback_Allied
		WHERE     (Billback_id = '#bblock.bb_id#')
	</cfquery>

	<CFIF getCurrentStatus.recordcount GT 0>
		<cfif getCurrentStatus.BB_Is_Locked EQ 1>
			<cfset bblock.bb_is_locked = 1>
		</cfif>
		
		<cfif getCurrentStatus.BB_Is_Locked EQ 0>
			<cfset bblock.bb_is_unlocked = 1>
		</cfif>
		
		<CFIF len(trim(getCurrentStatus.BB_Locked_By_User_ID)) GT 0>
			<cfset bblock.bb_is_locked_by_other_user_id = getCurrentStatus.BB_Locked_By_User_ID>
		</CFIF>
		
		<!--- get user name --->
		<cfif len(trim(bblock.bb_is_locked_by_other_user_id)) GT 0 and bblock.bb_is_locked EQ 1>
			<cfquery name="getLockUser" datasource="#application.datasource#">
				SELECT     Name_First, Name_Last
				FROM         dbo._Users
				WHERE     (User_ID = '#bblock.bb_is_locked_by_other_user_id#')
			</cfquery>

			<cfif getLockUser.recordcount GT 0>
			<!--- If the billback is locked by another user OR the billback is locked by Match Central - no matter who the user is.
						Show the billback as locked, even if the user who accesses the billback is the one who locked it in Match Central.
			--->
				<cfif (bblock.user_id_bb_locker NEQ bblock.bb_is_locked_by_other_user_id) OR getCurrentStatus.BB_Locked_By_Match_Central eq 1>
					<CFSET bblock.bb_is_locked_by_other_user = 1>
				</cfif>
				<CFSET bblock.bb_is_locked_by_name_first = getLockUser.Name_First>
				<CFSET bblock.bb_is_locked_by_name_last = getLockUser.Name_Last>
			</cfif>
		</cfif>
	</CFIF>
</CFIF>


<!--- update the bb status --->
<cfif bblock.bb_lock_action EQ 1 AND bblock.bb_is_locked_by_other_user EQ 0>
	<cfset useLakebaseForlockBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForlockBB>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#bblock.bb_id#"
			},
			{
				"bb_is_locked" = "1",
				"bb_locked_by_user_id" = "#request.AccessStructure.user_id#",
				"bb_lock_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlockBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlockBB>
<cfquery name="lockBB" datasource="#application.datasource#">
		update Billback_Allied
		set BB_Is_Locked = 1,
			BB_Locked_By_User_ID = '#request.AccessStructure.user_id#',
			BB_Lock_Date = Getdate()
		where Billback_id = '#bblock.bb_id#'
	</cfquery>
</cfif>
	<cfset bblock.bb_is_unlocked = 0>
	<cfset bblock.valid_bb_id = 1>
</cfif>

<cfif bblock.bb_unlock_action EQ 1 AND bblock.bb_is_locked_by_other_user EQ 0>
	<cfset useLakebaseForunlockBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForunlockBB>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#bblock.bb_id#",
				"bb_locked_by_match_central" = "eq.0"
			},
			{
				"bb_is_locked" = "0",
				"bb_locked_by_deviation_grid" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunlockBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunlockBB>
<cfquery name="unlockBB" datasource="#application.datasource#">
		update Billback_Allied
		set BB_Is_Locked = 0,
		BB_Locked_By_Deviation_Grid = 0
		where Billback_id = '#bblock.bb_id#'
		AND BB_Locked_By_Match_Central = 0		
	</cfquery>
</cfif>
</cfif>
<cfset local_bbid = bblock.bb_id>

<CFSET InfoBar_BBID = bblock.bb_id>
<cfinclude template="billback_load_infobar.cfm">

<cfinclude template="bb_menu_stats.cfm">
<!--- update icon on main menu --->
<cfoutput>
	<script>
		<!--- LOCKED show  UNLOCK ICON --->
		<cfif bblock.bb_is_locked EQ 0 AND bblock.valid_bb_id EQ 1>
			window.parent.LockCell.innerHTML = '<img src=/images/Readonly_Mode.gif border=0 style="cursor:pointer;" onclick="tabClick(\'lock\')" TITLE="Read-Only Mode"><BR>'+'<span class="ViewModesBracketsm">[</span>'+'<a href="##" onclick="tabClick(\'lock\');"><span class="ViewModessm">Click to Edit</span></a>'+'<span class="ViewModesBracketsm">]</span>'
			window.parent.LockCell.title = ""
		</cfif>

		<!--- UNLOCKED show  LOCK ICON --->
		<cfif bblock.bb_is_unlocked EQ 0 AND bblock.valid_bb_id EQ 1>
			window.parent.LockCell.innerHTML = '<img src=/images/Edit_Mode.gif border=0 style="cursor:pointer;" onclick="tabClick(\'unlock\')" TITLE="Edit Mode"><BR>'+'<span class="ViewModesBracketsm">[</span>'+'<a href="##" onclick="tabClick(\'unlock\');"><span class="ViewModessm">Click for Read Only</span></a>'+'<span class="ViewModesBracketsm">]</span>'
			window.parent.LockCell.title = ""
		</cfif>
	
		<!--- LOCKED BY OTHER USER ICON --->
		<cfif bblock.bb_is_locked_by_other_user EQ 1 AND bblock.valid_bb_id EQ 1>
			<CFSET AllowLockRelocate = 0>
			<cfset lockusername =  bblock.bb_is_locked_by_name_first & "<BR>" & bblock.bb_is_locked_by_name_last>
			<cfset maxLength = 23>
			<cfif len(lockusername) GT maxLength>
				<cfset lockusername = mid(lockusername, 1, maxLength) & "...">
			</cfif>

			window.parent.LockCell.innerHTML = '<img src=/images/Readonly_Mode.gif border=0  onclick="NewWindow(\'/xm/index.cfm?ID=<cfoutput>#bblock.user_id_bb_locker#</cfoutput>\',\'XMessenger\',\'480\',\'410\',\'No\', \'No\');return false;" style="cursor:pointer;"><br />'+'<span style="color:RGB(255,0,0);" class="ViewModessm">Locked By<br />#ucase(bblock.bb_is_locked_by_name_first)#&nbsp;#ucase(bblock.bb_is_locked_by_name_last)#</span>'
			window.parent.LockCell.title = "This billback is currently being viewed by #ucase(bblock.bb_is_locked_by_name_first)# #ucase(bblock.bb_is_locked_by_name_last)#"
		</cfif>
		<!--- relocate the program --->
		<cfif bblock.relocate_ability EQ 1 AND bblock.valid_bb_id EQ 1>
			var relocateToSummaryPage = 1;
			<cfif isDefined("url.relocatePage")>
				if(window.parent.#url.relocatePage#_tab)
				{
					<cfparam name="URL.failureURLType" 	default="">
					<cfparam name="URL.DEDUCTION_ID" 	default="">
					if(window.parent.tabClick("#url.relocatePage#"))
					{
						relocateToSummaryPage = 0;
					}
					<cfif URL.failureURLType EQ "deduction">
					else
					{
						relocateToSummaryPage = 0;
						window.parent.location.href = "/deductions/deduction.cfm?DEDUCTION_ID=#URL.DEDUCTION_ID#&Billback_ID=#bblock.bb_id#&NoAccess=1";
					}
					</cfif>
				}
			</cfif>
			
			if(relocateToSummaryPage)
			{
				location.href = "Billback_Summary.cfm?BBID=#bblock.bb_id#&rand1=#CreateUUID()#&bb_lock_action=#bblock.bb_lock_action#"
			}
		</cfif>
	</script>
</cfoutput>

