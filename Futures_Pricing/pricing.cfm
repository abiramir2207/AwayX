<!------ procurement ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "frmReqPricing">
<cfparam name="form.state" 	default="0">

<cfset reqManager = CreateObject("component", "components.futures_pricing.PricingManager").init() />
<cfset requestObj = reqManager.getPricingRequest(form.id, request.AccessStructure.User_ID) />

<cfif ListFindNoCase("sPricing,sPricingForward", form.command)>
	<!------ save code here ----->
	
	<cfset reqManager.savePricingOverheads(form) />
	
	<cfif form.command EQ "sPricingForward">
		<!------ forward ----->
		
		<cfset reqManager.saveForward(form.id, IncrementValue(requestObj.getStatusId()), AccessStructure) />
		
	</cfif>
	<cflocation addtoken="No" url="#thisPageUrl#">
	<cfabort>
</cfif>

<cfset qGetProducts = CreateObject("component", "components.futures_pricing.RequestProductManager").getRequestProducts(form.id) />
<!------ <cfset qGetRawMaterialInfo = reqManager.getRequestRawMaterials(form.id) /> ----->
<cfset qGetPricingOverheads = reqManager.getPricingOverheads(form.id)>
<cfset qGetPricingOverheadUOM = reqManager.getPricingOverheadUOM()>

<SCRIPT>
	
	function submitForm(formName, command) 
	{
		var formObj = eval("document." + formName);
		var proceed = true;
		//if (command == 'sPricingForward')
		{
			proceed = validateFields();
		}
		if(proceed)
		{
			if (command == 'sPricingForward')
			{
				formObj.forward.value = 1;
			}
			formObj.command.value = command;
			formObj.submit();
		}
		return false;
	}
	
</SCRIPT>

<cfinclude template="fp_header.cfm">
<cfset reqManager.getGroupsUserAccess() />
<cfif form.command EQ "cePricing" and requestObj.getStatusId() EQ pagePhase and requestObj.getGroupUserAccess(pagePhase)>
	<cfset bForm = true>	
<cfelse>
	<cfset bForm = false>	
</cfif>
<cfinclude template="pricing_create_edit.cfm">
</cfoutput>