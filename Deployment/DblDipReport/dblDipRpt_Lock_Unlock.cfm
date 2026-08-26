 <!-----------------------------------------------------------------------------

FILE NAME:		dblDipRpt_Lock_Unlock.cfm
DESCRIPTION:	Lock/Unlock
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	25-Feb-2021

------------------------------------------------------------------------------>


<cfoutput>
<cfset variables.inEditMode = 0>
<cfset variables.processing = BBDblDipReportMgr.checkIsRunning()>
<style>
	.modeText {
		position: relative;
		margin-left:6px;
	}
	.locked {
		font-size: 12px;
		font-weight: bold;
		color: red;
	}
	img[name="lock"] {
		margin-left: 10px;
	}
</style>
<div style="float:left;">
	<!--- Check to lock/unlock --->
	<cfif (BBDblDipReportMgr.checkDblDipRptLock().RecordCount)
			AND (BBDblDipReportMgr.checkDblDipRptLock().User_ID NEQ request.AccessStructure.User_ID)
			AND (BBDblDipReportMgr.checkDblDipRptLock().Is_Locked)>
		<!--- if locked by other users --->
		<img name="lock" src="/images/readonly_mode.gif" border="0" title="This utility is currently locked by #ucase(BBDblDipReportMgr.checkDblDipRptLock().Locker)#"><br>
		<span class="modeText locked">Locked By <br> #ucase(BBDblDipReportMgr.checkDblDipRptLock().Locker)#</span>
	<cfelse>
		<cfif (BBDblDipReportMgr.checkDblDipRptLock().recordCount)
				AND BBDblDipReportMgr.checkDblDipRptLock().Is_Locked EQ 1 >
			<!--- locked --->
			<a href="/Deployment/DblDipReport/index.cfm?lockUnlock=0" style="text-decoration:none;"><!--- &display=#form.display# --->
				<img name="lock" src="/images/edit_mode.gif" border="0" title="Click for Read Only"><br>
				<span class="modeText">#application.util.string.actionLinkFormat("click for read only")#</span>
			</a>
			<cfset variables.inEditMode = 1>
		<cfelse>
			<!--- unlocked --->
			<a href="/Deployment/DblDipReport/index.cfm?lockUnlock=1" style="text-decoration:none;"> 
				<img name="lock" src="/images/readonly_mode.gif" border="0" title="Click to Edit"><br>
				<span class="modeText">#application.util.string.actionLinkFormat("click to edit")#</span>
			</a>
		</cfif>
	</cfif>
</div>
</cfoutput>