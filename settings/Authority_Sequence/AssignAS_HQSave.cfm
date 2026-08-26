
<cfif form.command EQ "AssignHQDelete">
<cfset sMsg = HQPositionManager.DeleteAssignAS(form.HQ_Position_Id)>
<cfelseif form.command EQ "AssignHQSave">
<cfset sMsg = HQPositionManager.InsertAssignAS(form.HQ_Position_Id, form.Authority_Sequence_ID)>
<cfelseif form.command EQ "RTSave">
<cfset sMsg = HQPositionManager.InsertAssignRT(form)>
</cfif>

<cfif form.command EQ "RTSave">
<cfset command = "RT">
<cfelse>
<cfset command = "HQ">
</cfif>

<cflocation addtoken="No" url="index.cfm?command=#command#">