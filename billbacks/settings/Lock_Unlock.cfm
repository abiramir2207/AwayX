<!-----------------------------------------------------------------------------

FILE NAME:		Lock_Unlock.cfm
DESCRIPTION:	Lock/Unlock
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	03-May-2013

------------------------------------------------------------------------------>


<cfoutput>
<cfset variables.inEditMode = 0>
<div style="float:left;margin-bottom:4px">
	<!--- Check to lock/unlock --->
	<cfif (BBManager.checkReprocessLock().RecordCount)
			AND (BBManager.checkReprocessLock().User_ID NEQ request.AccessStructure.User_ID)
			AND (BBManager.checkReprocessLock().Is_Locked)>
		<!--- if locked by other users --->
		<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(BBManager.checkReprocessLock().Locker)#">
		<span class="modeText locked">Locked By #ucase(BBManager.checkReprocessLock().Locker)#</span>
	<cfelse>
		<cfif (BBManager.checkReprocessLock().recordCount)
				AND BBManager.checkReprocessLock().Is_Locked EQ 1 >
			<!--- locked --->
			<a href="reprocess.cfm?lockUnlock=0&display=#form.display#" style="text-decoration:none;">
				<img name="lock" src="/images/edit_mode.gif" border="0" title="Click for Read Only">
				<span class="modeText">#application.util.string.actionLinkFormat("click for read only")#</span>
			</a>
			<cfset variables.inEditMode = 1>
			<cfif form.display EQ "program">
				<a href="##" class="ReProcess modeText">#application.util.string.actionLinkFormat("reprocess")#</a>
			<cfelse>
			  <a href="##" class="save modeText">#application.util.string.actionLinkFormat("save")#</a>
			</cfif>
		<cfelse>
			<!--- unlocked --->
			<a href="reprocess.cfm?lockUnlock=1&display=#form.display#" style="text-decoration:none;">
				<img name="lock" src="/images/readonly_mode.gif" border="0" title="Click to Edit">
				<span class="modeText">#application.util.string.actionLinkFormat("click to edit")#</span>
			</a>
		</cfif>
		<!--- <br/><br/> --->

	</cfif>
</div>
</cfoutput>