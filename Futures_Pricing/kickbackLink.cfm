<cfsetting enablecfoutputonly="Yes">
<!------ kickbackLink.cfm ----->
<cfparam name="Attributes.id" 	default="0">
<cfparam name="Attributes.statusId" 	default="">
<cfset newStatus = Attributes.statusId - 1 />
<cfif newStatus GT 0>
	<cfset statusManager = CreateObject("component", "components.futures_pricing.StatusManager").init() />
	<cf_smallLink
			title="kick back to #statusManager.getStatusDesc(newStatus)#"
			url="kickback.cfm?id=#Attributes.id#"
			 parameters=" onClick=""JavaScript: return window.confirm('Once you kick back, you will lose all the work you have done in this phase.\nDo you really want to change the status to #statusManager.getStatusDesc(newStatus)# ?');""" 
			>
</cfif>
<cfsetting enablecfoutputonly="No">