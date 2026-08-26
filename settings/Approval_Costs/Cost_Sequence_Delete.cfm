<!------ Cost_Sequence_Delete.cfm ----->

<cfset sMsg = CostSequenceManager.deleteSequence(form.id)>

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
		url = "index.cfm"
	>
	</center>
	</cfoutput>

<cfelse>

	<cflocation addtoken="No" url="index.cfm">

</cfif>
