<!------ procurement ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "frmReqProcurement">
<cfparam name="form.state" 	default="0">

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// Controller Section //////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---initialize the request manager--->
<cfset reqManager = CreateObject("component", "components.futures_pricing.ProcurementManager").init() />

<!---initialize the supplier manager--->
<cfset suppMang = CreateObject("component", "components.futures_pricing.SupplierManager") />

<cfif form.state>
	
	<!---set data from form--->
	<cfset requestObj = reqManager.setFromForm(id=form.id, stData=form, userId=request.AccessStructure.User_ID)  />

	<cfif ListFindNoCase("sProcurement,sProcurementForward", form.command)>
		
		<!------ save ----->
		<cfset reqManager.save(requestObj)  />
		
		<!---if the action is forward then update status--->
		<cfif requestObj.getForward()>
		
			<cfset reqManager.saveForward(requestObj.getId(), IncrementValue(requestObj.getStatusId()), AccessStructure) />
			
		</cfif>	

		<!---then relocate back to this page--->
		<cflocation addtoken="No" url="#thisPageUrl#">
		
	</cfif>

<!---first time in--->
<cfelse>

	<cfset requestObj = reqManager.getRequestProcurement(id=form.id, userId=request.AccessStructure.User_ID)  />
	
</cfif>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// End Controller Section //////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<SCRIPT>
	
	function submitForm(formName, command) 
	{
		var formObj = eval("document." + formName);
		if (command == 'sProcurementForward')
		{
			if (!validate(formObj, command))
				return false;
			formObj.forward.value = 1;
		}
		formObj.command.value = command;
		formObj.submit();
		return false;
	}
	
</SCRIPT>

<cfinclude template="fp_header.cfm">
<cfset reqManager.getGroupsUserAccess() />
<cfif form.command EQ "ceProcurement" and requestObj.getStatusId() EQ pagePhase and requestObj.getGroupUserAccess(pagePhase)>
	<cfinclude template="procurement_create_edit.cfm">
<cfelse>
	<cfinclude template="procurement_display.cfm">
</cfif>
</cfoutput>