<!------ raw_materials ----->
<cfoutput>
<!------ set defaults ----->
<cfset formName = "frmMaterialReq">
<cfparam name="form.state" 	default="0">
<cfparam name="url.page" 	default="1">
<cfparam name="form.page" 	default="#url.page#">
<cfparam name="url.bForward" 	default="0">
<cfparam name="form.bForward" 	default="#url.bForward#">

<cfset reqManager = CreateObject("component", "components.futures_pricing.MatReqManager").init() />

<!------ if it is form submitted, load data from form ----->
<cfif form.state>
	<!------ if it is add edit raw material ----->
	<cfif form.page EQ 1>
		<cfset requestObj =  reqManager.setFromForm(form, request.AccessStructure.User_ID) />
	<!------ if it is select supplier ----->
	<cfelse>
		<cfset requestObj =  reqManager.setProcurementRawMaterialFromForm(form, request.AccessStructure.User_ID) />
	</cfif>
<cfelse>
	<!------ if it is add edit raw material ----->
	<cfif form.page EQ 1>
		<cfset requestObj = reqManager.getMatReq(id=form.id, pagePhase=2, companyId=request.AccessStructure.Company_Main_ID, userId=request.AccessStructure.User_ID) />
	<!------ if it is select supplier ----->
	<cfelse>
		<cfset requestObj = reqManager.getMatReq(id=form.id, pagePhase=3, companyId=request.AccessStructure.Company_Main_ID, userId=request.AccessStructure.User_ID) />
	</cfif>
</cfif>

<cfif form.page EQ 1>
	<!------ if it is add edit raw material ----->
	<!------ get product volume distribution info, to get LTO ----->
	<cfset qGetProductVolDist = reqManager.setVolumeDistributionInfo(requestId=form.id) />
</cfif>

<cfif ListFindNoCase("sRequestMaterials,sRequestMaterialsForward", form.command)>
	<!------ if it is add edit raw material ----->
	<cfif form.page EQ 1>
		<cfset reqManager.save() />
		<cfif form.bForward>
			<!------ goto supplier page ----->
			<cfset thisPageUrl = thisPageUrl & "&page=2&bForward=1" />
		</cfif>
	<!------ if it is select supplier ----->
	<cfelse>
		<cfset reqManager.saveRequestRawMaterialSupplier() />
		<cfif form.bForward>
			<cflocation url="handler.cfm?command=saveForward&id=#requestObj.getId()#" addtoken="no" />
			<!------ <cfset reqManager.saveForward(form.id, IncrementValue(requestObj.getStatusId())) /> ----->
		</cfif>
	</cfif>
	
	
	<cflocation addtoken="No" url="#thisPageUrl#">
	<cfabort>
</cfif>

<cfset qGetDistinctPreservations =  CreateObject("component", "components.futures_pricing.PreservationManager").getAll(active=1) />

<SCRIPT>
	
	function submitForm(formName, command, sPage, bForward) 
	{
		var formObj = eval("document." + formName);
		var proceed = true;
		<cfif form.page EQ 1>
			if(bForward)
			{
				proceed = validateFields(formObj);
			}
		</cfif>
		if(proceed)
		{
			formObj.command.value = command;
			formObj.bForward.value = bForward;
			formObj.submit();
		}
		return false;
	}
	
</SCRIPT>

<cfinclude template="fp_header.cfm">
<cfset reqManager.getGroupsUserAccess() />
<cfif form.command EQ "ceRequestMaterials" and requestObj.getStatusId() EQ pagePhase and requestObj.getGroupUserAccess(pagePhase)>
	<form action="#thisPageUrl#" method="post" name="#formName#" style="display:inline;">	
	<cfif form.page EQ 1>
		<cfinclude template="raw_materials_create_edit.cfm">
	<cfelse>
		<cfinclude template="raw_materials_supplier.cfm">
	</cfif>
		<input type="hidden" name="state" value="1">
		<INPUT NAME="command" TYPE="Hidden" VALUE="#form.command#" />
		<INPUT NAME="page" TYPE="Hidden" VALUE="#form.page#" />
		<INPUT NAME="bForward" TYPE="Hidden" VALUE="#form.bForward#" />
		<INPUT NAME="companyId" TYPE="Hidden" VALUE="#request.AccessStructure.Company_Main_ID#" />
			
	</form>
<cfelse>
	<cfinclude template="raw_materials_display.cfm">
</cfif>
</cfoutput>