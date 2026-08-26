<!------ price_in_sales.cfm ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "frmPriceInSales">
<cfparam name="form.state" 	default="0">

<cfset reqManager = CreateObject("component", "components.futures_pricing.PricingManager").init() />

<!------ if it is form submitted, load data from form ----->
<cfif form.state>
	<cfset requestObj =  reqManager.getPricingRequest(0) />
<cfelse>
	<cfset requestObj = reqManager.getPricingRequest(form.id, request.AccessStructure.User_ID) />
</cfif>

<cfif form.command EQ "sPriceInSales">
	<cfset reqManager.savePricingStatus(form.id, form.FP_Pricing_Status_ID) />
	<cflocation addtoken="No" url="#thisPageUrl#"> 
	<cfabort>
</cfif>

<SCRIPT>
	
	function submitForm(formName, command) 
	{
		var formObj = eval("document." + formName);
		formObj.command.value = command;
		formObj.submit();
		return false;
	}
	
</SCRIPT>

<cfinclude template="fp_header.cfm">
<cfset reqManager.getGroupsUserAccess() />
<cfif form.command EQ "cePriceInSales" and requestObj.getStatusId() EQ pagePhase and requestObj.getGroupUserAccess(pagePhase)>
	<cfset bForm = true>
<cfelse>
	<cfset bForm = false>
</cfif>

<cfinclude template="price_in_sales_create_edit.cfm">		

</cfoutput>