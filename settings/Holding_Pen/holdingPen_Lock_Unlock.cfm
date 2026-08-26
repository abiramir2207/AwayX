<!-----------------------------------------------------------------------------

FILE NAME:		holdingPen_Lock_Unlock.cfm
DESCRIPTION:	Lock/Unlock
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	30-Sep-2014

------------------------------------------------------------------------------>


<cfoutput>
<cfset variables.inEditMode = 0>
<cfset variables.processing = holdingPenManager.checkIsRunning()>
<div style="float:left;margin-bottom:4px">
	<!--- Check to lock/unlock --->
	<cfif (holdingPenManager.checkHoldingPenLock().RecordCount)
			AND (holdingPenManager.checkHoldingPenLock().User_ID NEQ request.AccessStructure.User_ID)
			AND (holdingPenManager.checkHoldingPenLock().Is_Locked)>
		<!--- if locked by other users --->
		<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(holdingPenManager.checkHoldingPenLock().Locker)#"><br>
		<span class="modeText locked">Locked By #ucase(holdingPenManager.checkHoldingPenLock().Locker)#</span>
	<cfelse>
		<cfif (holdingPenManager.checkHoldingPenLock().recordCount)
				AND holdingPenManager.checkHoldingPenLock().Is_Locked EQ 1 >
			<!--- locked --->
			<a href="/settings/Holding_Pen/index.cfm?lockUnlock=0" style="text-decoration:none;"><!--- &display=#form.display# --->
				<img name="lock" src="/images/edit_mode.gif" border="0" title="Click for Read Only"><br>
				<span class="modeText">#application.util.string.actionLinkFormat("click for read only")#</span>
			</a>
			<cfset variables.inEditMode = 1>
		<cfelse>
			<!--- unlocked --->
			<a href="/settings/Holding_Pen/index.cfm?lockUnlock=1" style="text-decoration:none;"><!--- &display=#form.display# --->
				<img name="lock" src="/images/readonly_mode.gif" border="0" title="Click to Edit"><br>
				<span class="modeText">#application.util.string.actionLinkFormat("click to edit")#</span>
			</a>
		</cfif>
	</cfif>
</div>
</cfoutput>