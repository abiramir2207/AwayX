<!------ Authority_Sequence_Add_Edit_Save.cfm ----->

<cfif form.command EQ "addEditSaveHQ">
	<cfset sMsg = HQPositionManager.addEditSequence(form.id, form.HQ_Position_Order, form.HQ_Position_Name, Request.AccessStructure)>
	<cfset command = "HQ">
<cfelseif form.command EQ "addEditSave">
	<cfset sMsg = authoritySequenceManager.addEditSequence(form.id, form.Authority_Sequence_Order, form.Authority_Sequence_Name, Request.AccessStructure)>
	<cfset command = "list">
</cfif>
<cfif Len(sMsg) GT 0>

	<cfoutput>
	<center>
	<span style="color:red;">
	<B>#sMsg#</B>
	</span>
	&nbsp;&nbsp;&nbsp;
	<CF_smallLink 
		title = "back" 
		url = "##"
		parameters = "onClick=""javascript: history.back();"""
	>
	&nbsp;&nbsp;&nbsp;
	<CF_smallLink 
		title = "cancel" 
		url = "index.cfm?command=#command#"
	>
	</center>
	</cfoutput>
<cfelse>
	<cflocation addtoken="No" url="index.cfm?command=#command#">
</cfif>
