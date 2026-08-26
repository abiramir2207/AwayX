<!-----------------------------------------------------------------------------

FILE NAME:		Automation_Upload_Lock_Unlock.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  18-Jun-2020
Created By   :  Anand Rao
Description  :  Lock/Unlock upload automation screen
------------------------------------------------------------------------------>


<cfoutput>
<cfset variables.inEditMode = 0>
<cfset variables.processing = automationUploadManager.checkIsRunning()>
<div style="float:left;margin-bottom:4px">
	<!--- Check to lock/unlock --->
	<cfif (automationUploadManager.checkAutomationUploadLock().RecordCount)
			AND (automationUploadManager.checkAutomationUploadLock().User_ID NEQ request.AccessStructure.User_ID)
			AND (automationUploadManager.checkAutomationUploadLock().Is_Locked)>
		<!--- if locked by other users --->
		<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(automationUploadManager.checkAutomationUploadLock().Locker)#"><br>
		<span class="modeText locked">Locked By #ucase(automationUploadManager.checkAutomationUploadLock().Locker)#</span>
	<cfelse>
		<cfif (automationUploadManager.checkAutomationUploadLock().recordCount)
				AND automationUploadManager.checkAutomationUploadLock().Is_Locked EQ 1 >
			<!--- locked --->
			<a href="index.cfm?lockUnlock=0" style="text-decoration:none;"><!--- &display=#form.display# --->
				<img name="lock" src="/images/edit_mode.gif" border="0" title="Click for Read Only"><br>
				<span class="modeText">#application.util.string.actionLinkFormat("click for read only")#</span>
			</a>
			<cfset variables.inEditMode = 1>
		<cfelse>
			<!--- unlocked --->
			<a href="index.cfm?lockUnlock=1" style="text-decoration:none;"><!--- &display=#form.display# --->
				<img name="lock" src="/images/readonly_mode.gif" border="0" title="Click to Edit"><br>
				<span class="modeText">#application.util.string.actionLinkFormat("click to edit")#</span>
			</a>
		</cfif>
	</cfif>
</div>
</cfoutput>