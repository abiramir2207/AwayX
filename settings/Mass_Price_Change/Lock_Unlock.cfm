<cfsilent>
<!---  
       Name:          lock_unlock.cfm           
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.       
       Created Date:  05/30/2013
       Created By:    Kal
       Label:		  34605
       Description:   Mass Price Change Utility
--->
</cfsilent>
<cfoutput>
	<!--- Check to lock/unlock --->
	<cfif (MPCManager.checkLock().recordCount)
			AND (MPCManager.checkLock().User_ID NEQ request.AccessStructure.User_ID) 
			AND (MPCManager.checkLock().IS_LOCKED)> 
		<!--- if locked by other users --->
		<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(MPCManager.checkLock().Locker)#"><br/>
		<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br/>#ucase(MPCManager.checkLock().Locker)#</span>
	<cfelse>		
		<cfif (MPCManager.checkLock().recordCount) 
				AND MPCManager.checkLock().IS_LOCKED EQ 1 >
			<!--- locked --->	
			<a href="index.cfm?lockUnlock=0" style="text-decoration:none;">
				<img name="lock" src="/images/edit_mode.gif" border="0" title="Click for Read Only"><br/>
				<span class="ViewModesBracket">[</span><span class="ViewModes">Click for Read Only</span><span class="ViewModesBracket">]</span>
			</a>
		<cfelse>
			<!--- unlocked --->
			<a href="index.cfm?lockUnlock=1" style="text-decoration:none;">
				<img name="lock" src="/images/readonly_mode.gif" border="0" title="Click to Edit"><br/>
				<span class="ViewModesBracket">[</span><span class="ViewModes">Click to Edit</span><span class="ViewModesBracket">]</span>
			</a>
		</cfif>
		<br/><br/>
	</cfif>
</cfoutput>

