<!------ select_users.cfm ----->
<cfoutput>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">
<cfparam name="form.state" 	default="0">
<cfparam name="url.groupId" 	default="">
<cfparam name="form.groupId" 	default="#url.groupId#">
<cfset formName = "frmSelectUser">

<cfset reqManager = CreateObject("component", "components.futures_pricing.RequestManager") />
<cfset requestObj =  reqManager.get(form.id) />
<cfif form.state>
	<cfparam name="form.requestUsers" 	default="">
	<cfset reqManager.saveGroupUser(form.requestUsers, form.groupId) />
	<cflocation url="handler.cfm?command=ceSelectUser&groupId=#form.groupId#&id=#requestObj.getId()#" addtoken="no" />
	<!------ <cflocation url="view.cfm?command=ceInitialRequest&id=#requestObj.getId()#" addtoken="no" /> ----->
	<cfabort>
</cfif>

<cfset target = "_self">

<cfinclude template="select_users_form.cfm" />

</cfoutput>