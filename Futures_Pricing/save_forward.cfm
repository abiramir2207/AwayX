<!------ save_forward.cfm ----->
<cfoutput>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">
<cfparam name="form.state" 	default="0">
<cfset formName = "frmSelectUser">

<cfset reqManager = CreateObject("component", "components.futures_pricing.RequestManager") />
<cfset requestObj =  reqManager.get(form.id) />
<cfif form.state>
	<cfparam name="form.requestUsers" 	default="">
	<cfset reqManager.saveGroupUser(form.requestUsers) />
	<cfset reqManager.saveForward(requestObj.getId(), IncrementValue(requestObj.getStatusId()), AccessStructure) />
	<!------ <cflocation url="handler.cfm?command=ceInitialRequest&id=#requestObj.getId()#" addtoken="no" /> ----->
	<cflocation url="view.cfm?command=ceInitialRequest&id=#requestObj.getId()#" addtoken="no" />
	<cfabort>
</cfif>

<cfset target = "_parent">
<cfset pagePhase = requestObj.getStatusId() />

<cfinclude template="fp_header.cfm">
&nbsp;&nbsp;&nbsp;<span class="Title2">Save & Forward</span><hr color="Navy">
<cfset prevPageURL = "handler.cfm?command=#ListGetAt(statusCECommandList, requestObj.getStatusId())#&id=#form.id#">

<cfinclude template="select_users_form.cfm" />
<table align="center" width="60%">
<tr><td align="center">
<font color="red"><B>Once you save & forward, you will not be able to make any more modifications to this phase of the futures pricing request. Do you want to continue?</B></font>
</td></tr>
</table>

</cfoutput>