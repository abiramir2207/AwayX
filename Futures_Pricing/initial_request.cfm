<!------ initial request ----->
<cfoutput>
<!---styles--->
<STYLE>
    .borderRight { border-right:1px groove ##CCCCCC }
    .borderRightBottom { border-right:1px groove ##CCCCCC;border-bottom:1px groove ##CCCCCC }
</STYLE>

<!------ set defaults ----->
<cfset formName = "dataForm">
<cfparam name="form.state" default="0" />
<cfparam name="volDistIndxLen" default=0 />
<cfparam name="form.Start_Date" default="" />
<cfparam name="form.End_Date" default="" />

<!---initialize the components we need--->
<cfset reqProdManager = CreateObject("component", "components.futures_pricing.RequestProductManager") />
<cfset reqManager = CreateObject("component", "components.futures_pricing.RequestManager") />

<!---set the lead time--->
<cfset leadTime = CreateObject("component", "components.futures_pricing.SettingsManager").get().getLeadTime() />
<!---set restrict customer deadline--->
<cfset restrictCustDL = CreateObject("component", "components.futures_pricing.SettingsManager").get().getRestrictCustDeadline() />

<!---get the list of delivery types--->
<cfset qGetDeliveryType = CreateObject("component","components.products.DeliveryTypeManager").getDeliveryType() />
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// Controller Section //////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<cfif form.state>

	<cfset requestObj =  reqManager.setFromForm(form, request.AccessStructure.User_ID) />

	<!---if the command is sInitialRequest or sInitialRequestForward then save and relocate--->
	<cfif ListFindNoCase("sInitialRequest,sInitialRequestForward", form.command)>
		<cfset reqManager.saveWIP(requestObj) />
		<cfif form.id>
			<cfset gotoFile = "handler.cfm" />
		<cfelse>
			<cfset gotoFile = "view.cfm" />
		</cfif>
		<cfif form.command EQ "sInitialRequestForward">
			<cflocation url="#gotoFile#?command=saveForward&id=#requestObj.getId()#" addtoken="no" />
		<cfelse>		
			<cflocation url="#gotoFile#?command=ceInitialRequest&id=#requestObj.getId()#" addtoken="no" />
		</cfif>
		<!------ 
		has to specificly say the id, because if it is the first time create, it won't have an is in #thisPageUrl#
		 ----->
	</cfif>

<!---first time in--->
<cfelse>
	
	<cfset requestObj =  reqManager.get(id=form.id, pagePhase=pagePhase, companyId=request.AccessStructure.Company_Main_ID,userId=request.AccessStructure.User_ID) />	
	
</cfif>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////// End Controller Section //////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<SCRIPT>
	
	function submitForm(formName, command) 
	{

		if (!validate(document.dataForm, command))
			return false;

		if (command == 'sInitialRequestForward')
		{
			document.dataForm.forward.value = 1;
		}
		if(document.dataForm.id.value == "0" && (command == 'sInitialRequestForward' || command == 'sInitialRequest'))
		{
			document.dataForm.target = "_parent";
		}
		
		document.dataForm.command.value = command;
		document.dataForm.submit();
		return false;
	}
	
</SCRIPT>

<cfinclude template="fp_header.cfm">
<cfset reqManager.getGroupsUserAccess() />

<!------ 
requestObj.getStatusId() eq 0 is for create for the first time :)
 ----->
<cfif form.command EQ "ceInitialRequest" and ((requestObj.getStatusId() EQ pagePhase AND requestObj.getGroupUserAccess(1)) or requestObj.getStatusId() eq 0)>
	<cfinclude template="initial_request_create_edit.cfm">
<cfelse>
	<cfinclude template="initial_request_display.cfm">
</cfif>

</cfoutput>