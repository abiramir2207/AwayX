<!------ Authority_Sequence_Delete.cfm ----->

<cfif form.command EQ "deleteHQ">
	<cfset sMsg = HQPositionManager.deleteSequence(form.id, request.AccessStructure)>
	<cfset command = "HQ">
<cfelseif form.command EQ "delete">
	<cfset sMsg = authoritySequenceManager.deleteSequence(form.id, request.AccessStructure)>
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
