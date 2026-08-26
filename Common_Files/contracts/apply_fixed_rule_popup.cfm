<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<cfoutput>

<cfparam name="url.uriLocation" default="" />
<cfparam name="form.uriLocation" default="#url.uriLocation#" />

<cfparam name="form.command" default="init" />
<cfparam name="form.compRules" default="" />
<cfparam name="form.compRuleIds" default="" />
<cfparam name="form.reqRules" default="" />

<cfparam name="url.CONTRACT_MAIN_ID" default="0" />
<cfparam name="form.CONTRACT_MAIN_ID" default="#url.CONTRACT_MAIN_ID#">

<cfparam name="session.fix_Product_List" default="" />
<cfparam name="form.Product_List" default="#session.fix_Product_List#">

<cfparam name="url.fixedComponentList" default="" />
<cfparam name="form.fixedComponentList" default="#url.fixedComponentList#">

<cfparam name="donotallowaddproductsDE" default="0">
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<cfquery name="GetDateExclusion" datasource="#application.datasource#">
	SELECT Date_Exclusions_ON
	FROM 
		Program_Control_Panel_Options
	WHERE 
		ProgramControl_Panel_Options_ID = '#trim(form.CONTRACT_MAIN_ID)#'
</cfquery>

<cfif GetDateExclusion.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
	<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.CONTRACT_MAIN_ID,0)>
	<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
		<cfset donotallowaddproductsDE = 1>
	</CFIF>
</cfif>


<cfset fixedCompObj = CreateObject("component","components.programs.fixed.fixedComponent") />
<cfset fixedRules = CreateObject("component","components.programs.fixed.fixedComponentBusinessRule").init() />

<cfset fixedData = fixedCompObj.getFixedData(form.CONTRACT_MAIN_ID,form.Product_List)>
<cfset ProgFixComp = fixedCompObj.getProgFixComp(form.CONTRACT_MAIN_ID)>

<cfset i = 1>
<cfif form.command eq "save">

	<!---on save, get all the selected rule id's for each product/component combination and set them to the opener--->
	
	<cfloop index="compIndx" list="#form.fixedComponentList#">
			<cfset CompNameId = gettoken(compIndx,1,"_")> 
			<cfset gotRules = fixedCompObj.hasRules(CompNameId)>
			<cfif gotRules eq 1>
					<cfset compIndx = i>
				<!---strip hyphens from component uuid to use for varaible--->
				<cfset compUUIDStrip = compIndx />
				<cfif isdefined("form.compProdRules_#compUUIDStrip#")>
					<cfloop index="compProdIndx" list="#Evaluate("form.compProdRules_#compUUIDStrip#")#">
						<cfset reproduct_id = replace(compProdIndx, "-", "_", "ALL")>
						<cfset prodCompVarReplace = "#request.app_general_functions.replaceHyphen(compProdIndx)#_#compUUIDStrip#"/>
						<cfparam name="form.fix_rule_#prodCompVarReplace#" default="" />
						<!---guard against empty strings--->
						<cfif Evaluate(trim("form.fix_rule_#prodCompVarReplace#")) neq "">
							<script>
								opener.document.FixedComponents.fix_rule_C#CompNameId#_P#reproduct_id#_#compIndx#.value = #Evaluate("form.fix_rule_#prodCompVarReplace#")#;
							</script>
						<cfelse>
							<script>
								opener.document.FixedComponents.fix_rule_C#CompNameId#_P#reproduct_id#_#compIndx#.value = 0;
							</script>
						</cfif>
					</cfloop>
				</cfif>
				
		    </cfif>
			<cfset i = i + 1>
	</cfloop>

	<script>
				<cfif donotallowaddproductsDE EQ 1>
					if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
				{ opener.document.all.deletedateexclusions.value = 1;</cfif>
				var actionpage;
				actionpage = "contract_fixed_component_save.cfm";
				opener.document.FixedComponents.action = actionpage;
				opener.document.FixedComponents.submit();
				window.close();
				<cfif donotallowaddproductsDE EQ 1>} else {
					return false;
				}</cfif>
	</script>

	
</cfif>

<SCRIPT LANGUAGE="JavaScript"><!--

	function save() 
	{
		var thisForm = document.all.popupForm;
		
		//get list of required rules
		var requiredRules = thisForm.reqRules.value;
		if(requiredRules != "")
		{
			var aReqList = requiredRules.split(",");
			
			if(!valReqRule(requiredRules, thisForm))
			{
				alert("Some rules are required. Please select required rules.");
				return;
			}
		}
		
		thisForm.command.value = "save";
		thisForm.submit();
    	return false;
	}
	
	//validate for required rules
	function valReqRule(list, formVar)
	{
		var rValid = true;
		
		var aReqList = list.split(",");
		
		var elemColctn = formVar.getElementsByTagName("input");
		
		//loop over list and make sure one is checked
		for(var i = 0; i<aReqList.length; i++)
		{
			var inpVal = "fix_rule_" + aReqList[i];
			var rCompChecked = false;
			
			//loop through the inputs and check to see if a rule has been seleted for a required product/combination
			for (var n = 0; n<elemColctn.length; n++) 
			{
				var elemName = elemColctn[n].name.indexOf(inpVal);
				if(elemName > -1)
				{
					if(elemColctn[n].checked)
					{
						rCompChecked = true;
					}
				}
			}
			
			//if this is still false then we know that no required rule was seletected so return false
			if(rCompChecked == false)
			{
				rValid = false;
				return rValid;
			}
		}
		
		return rValid;
	}
	
//--></SCRIPT>

<title>Apply Rule</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<FORM action="" method="post" NAME="popupForm" id="popupForm">

<cfif form.command eq "init">
		<cfset i = 1>
	<!---loop over the components and display the form to apply business rules--->
		<cfloop index="compIndx" list="#form.fixedComponentList#">
			<cfset CompNameId = gettoken(compIndx,1,"_")> 
			<cfset gotRules = fixedCompObj.hasRules(CompNameId)>
			<cfif gotRules EQ 1> 
						<cfset compIndx =  compIndx & "_" & i>
						<cfset form.compRules = ListAppend(form.compRules, trim(compIndx)) />
						<cfset compIndx = i>
						<cfset compUUIDStrip = compIndx />
						<cfset form.compRuleIds = ListAppend(form.compRuleIds, trim(CompNameId)) />
						<cfparam name="form.lCompRuleUoms_#compUUIDStrip#" default="0" />
						<input type="hidden" name="lCompRuleUoms_#compUUIDStrip#" value="#evaluate("form.lCompRuleUoms_#compUUIDStrip#")#" />
							
						<script>
							if(opener.document.FixedComponents.lCompRuleUoms_#compIndx# != null)
							{
							var opnrUomList = eval("opener.document.FixedComponents.lCompRuleUoms_#compIndx#.value");
							document.all.popupForm.lCompRuleUoms_#compUUIDStrip#.value = opnrUomList;
							}
							
						</script>
						<!--- if(opener.document.FixedComponents.lCompRuleUoms_#compIndx# != null)
							{
							var opnrUomList = eval("opener.document.FixedComponents.lCompRuleUoms_#compIndx#.value");
							document.all.popupForm.lCompRuleUoms_#compUUIDStrip#.value = opnrUomList;
							} --->
						<!---loop over the products and for each product that has a uom in the rule, display the available fixed rules--->
						<cfloop index="prodIndx" from="1" to="#ArrayLen(fixedData.aProd)#">
							<cfset reproduct_id = replace(fixedData.aProd[prodIndx].masterItemID, "-", "_", "ALL")>
							<cfset prodCompVarReplace = "#request.app_general_functions.replaceHyphen(fixedData.aProd[prodIndx].masterItemID)#_#compUUIDStrip#"/>
							
							<cfparam name="form.uom_#prodCompVarReplace#" default="" />
							<input type="hidden" name="uom_#prodCompVarReplace#" />
							
							<cfparam name="form.opener_fix_rule_#prodCompVarReplace#" default="" />
							<input type="hidden" name="opener_fix_rule_#prodCompVarReplace#" />
							
							<cfoutput>
							<script>
								var openerForm = opener.document.FixedComponents;
								if(openerForm.fixed_C#CompNameId#_P#reproduct_id#_#compIndx#_rate != null)
								{
								var rateVal = eval("openerForm.fixed_C#CompNameId#_P#reproduct_id#_#compIndx#_rate.value");
								//only check uom for rate values that are greater than 0
								if(rateVal > 0)
								{
									var uomSel = eval("openerForm.fixed_C#CompNameId#_P#reproduct_id#_#compIndx#_uom.options[openerForm.fixed_C#CompNameId#_P#reproduct_id#_#compIndx#_uom.selectedIndex].value");
									var opnrFixRule = eval("openerForm.fix_rule_C#CompNameId#_P#reproduct_id#_#compIndx#.value");
									document.all.popupForm.opener_fix_rule_#prodCompVarReplace#.value = opnrFixRule;
									document.all.popupForm.uom_#prodCompVarReplace#.value = uomSel;
								}
								}
							</script>
							</cfoutput>
				
						</cfloop>
					
			</cfif> 
			<cfset i = i + 1>
	</cfloop>
<cfelse>


	<cfif trim(form.compRuleIds) eq ""><cfset form.compRuleIds = 0></cfif>
	
	<!---get just selected rules then query that record set to get a distinct list--->
	<cfset qGetRulesToQuery = fixedRules.getComponentRules(form.compRuleIds) />
	<cfset useLakebaseForqGetRules = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetrulestoquery")>
<cfif useLakebaseForqGetRules>
	<cftry>
		<cfset qGetRules = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetrulestoquery", {
				"select" = "program_fixed_component_rule_id,fixed_component_rule_desc,unit_of_measure_id,joined_rule_id"
			}), "program_fixed_component_rule_id,fixed_component_rule_desc,unit_of_measure_id,joined_rule_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRules = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRules>
<cfquery name="qGetRules" dbtype="query">
		SELECT	DISTINCT Program_fixed_Component_Rule_ID,
				Fixed_Component_Rule_Desc,
				Unit_Of_Measure_ID,
				Joined_Rule_Id
		FROM	qGetRulesToQuery
	</cfquery>
</cfif>
	<font color="##000066" size="3"><b>Apply Business Rules</b></font> 
	<hr color="navy">
	<table border="0" cellpadding="1" cellspacing="0" CLASS="Maintable" bgcolor="ffce84" width="700">
	
		<tr>
			<td id="header" valign="top"><b>Product</b></td>
			<td id="header" valign="top"><b>Component</b></td>
			<!---loop over component rules--->
			<cfloop query="qGetRules">
				<td id="header" valign="top">
					<b>#fixed_Component_Rule_Desc#</b>
				</td>
			</cfloop>
		</tr>

		<!---set counter to be used to determine where we are in the list--->
		<cfset compCounter = 1 />
				
		<cfloop index="compIndx" list="#form.compRules#">
			<cfset CompNameId = gettoken(compIndx,1,"_")>
			<cfset paidTo = gettoken(compIndx,2,"_")>
			<cfset compIndx = gettoken(compIndx,3,"_")> 
			<!---strip hyphens from component uuid to use for varaible--->
			<cfset compUUIDStrip = request.app_general_functions.replaceHyphen(compIndx) />
			
			<!---param holder for products that need rules applied--->
			<cfparam name="form.compProdRules_#compUUIDStrip#" default="" />
				<!---get the compId from the rule id list--->
				<cfset compNameId = ListGetAt(form.compRuleIds, compCounter) />
				
				<!---get component data--->
				<cfset compData = fixedCompObj.getComp(compNameId) />
				
				<!---set required variable--->
				<cfset bIsRequired = compData.Rule_Required />
				<!---get rule data--->
				<cfset qRuleData = fixedRules.getComponentRules(compNameId) />
				
			<cfloop index="prodIndx" from="1" to="#ArrayLen(fixedData.aProd)#">
			
				<cfset prodCompVarReplace = "#request.app_general_functions.replaceHyphen(fixedData.aProd[prodIndx].masterItemID)#_#compUUIDStrip#"/>
				
				<cfparam name="form.uom_#prodCompVarReplace#" default="" />
				<cfset uomVal = Evaluate("form.uom_#prodCompVarReplace#") />

				<cfparam name="form.lCompRuleUoms_#compUUIDStrip#" default="" />
			
				<!---loop through products with components that have rules that apply to this uom--->
				<cfif ListFindNoCase(Evaluate("form.lCompRuleUoms_#compUUIDStrip#"), uomVal)>
				
					<!---if the uom is percent then add the product id to the component list holding products that have a fixed rule--->
					<cfset "form.compProdRules_#compUUIDStrip#" = ListAppend(Evaluate("form.compProdRules_#compUUIDStrip#"), fixedData.aProd[prodIndx].masterItemID) />
					<cfif bIsRequired eq 1>
						<!---append to required list--->
						<cfset form.reqRules = ListAppend(form.reqRules, prodCompVarReplace) />
					</cfif>
						
					<tr bgcolor="##FFFFFF">
						<td>#fixedData.aProd[prodIndx].Description#</td>
						<td>#left(compData.Program_fixed_Component_Name,20)# 	#templateManager.getPaymentPaidToTypeDesc(paidToID = paid_to, paidToDesc="")#</td>

						<cfloop query="qRuleData">
							<td>
								<!---enable radio only for fixed rules for this component--->
								<cfset joinId = trim(Joined_Rule_Id) />
								<cfif (joinId eq 0 or Len(joinId) eq 0) or uomVal neq Unit_Of_Measure_ID>
									<input name="" type="Checkbox" disabled="true" value="" />
								<cfelseif bIsRequired>
									<input name="fix_rule_#prodCompVarReplace#" type="Checkbox" value="#Program_fixed_Component_Rule_ID#" checked onclick="this.checked=true" title="REQUIRED"/>
								<cfelse>
									<input name="fix_rule_#prodCompVarReplace#" type="Checkbox" value="#Program_fixed_Component_Rule_ID#" <cfif Evaluate("form.opener_fix_rule_#prodCompVarReplace#") eq Program_fixed_Component_Rule_ID>checked</cfif> />
								</cfif>
							</td>
						</cfloop>
					</tr>
			
				</cfif>
				
			</cfloop>
			
			<!---hidden field holder for products that need rules applied for this component--->
			<input type="hidden" name="compProdRules_#compUUIDStrip#" value="#Evaluate("form.compProdRules_#compUUIDStrip#")#" />
					
			<cfset compCounter = compCounter + 1 />
			
		</cfloop>
		
	</table>

	<br>
	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<B><font color="FF0000">[</font> <a href="javascript:save();">save</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:window.close();">cancel</a> <font color="FF0000">]</font></B>&nbsp;
				<B><font color="FF0000">[</font> <a href="javascript:document.all.popupForm.reset();">reset</a> <font color="FF0000">]</font></B>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
	</table>

</cfif>

<input type="hidden" name="command" value="#form.command#" />
<input type="hidden" name="compRules" value="#form.compRules#" />
<input type="hidden" name="compRuleIds" value="#form.compRuleIds#" />
<input type="hidden" name="uriLocation" value="#form.uriLocation#" />
<input type="hidden" name="reqRules" value="#form.reqRules#" />
<input type="hidden" name="CONTRACT_MAIN_ID" value="#form.CONTRACT_MAIN_ID#" />


</form>

<!---resubmit with form data--->
<cfif form.command eq "init">
	
	<script>
		document.all.popupForm.command.value = "";
		document.all.popupForm.submit();
	</script>
	
</cfif>
</body>
</html>

</cfoutput>