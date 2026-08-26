<cfsilent>
<!---  
       Name:          lock_unlock.cfm           
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.       
       Created Date:  12/01/2010
       Created By:    Kal
       Label:		  25195
       Description:   Mass Program Change Upload Utility
--->
</cfsilent>
<cfoutput>
	<!--- Check to lock/unlock --->
	<cfif (MPCUManager.checkLock().recordCount)
			AND (MPCUManager.checkLock().User_ID NEQ request.AccessStructure.User_ID) 
			AND (MPCUManager.checkLock().IS_LOCKED)> 
		<!--- if locked by other users --->
		<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(MPCUManager.checkLock().Locker)#"><br/>
		<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br/>#ucase(MPCUManager.checkLock().Locker)#</span>
	<cfelse>		
		<cfif (MPCUManager.checkLock().recordCount) 
				AND MPCUManager.checkLock().IS_LOCKED EQ 1 >
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