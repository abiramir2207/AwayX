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
<cfparam name="form.programRebateComponentRuleIds"	default="" />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
<!--- <cfset rebateData = CreateObject("component","components.programs.rebates.Rebate").getWddxDataFromFile(form.uriLocation) /> --->
<cfset rebateData = CreateObject("component","components.programs.rebates.Rebate").loadFromDB(programID=URL.contract_Main_Id,displayGroupType=displayGroupType,useXML=0,compUUID=URL.compUUID) />
<cfset rebateCompObj = CreateObject("component","components.programs.rebates.RebateComponent") />
<cfset rebateRules = CreateObject("component","components.programs.rebates.RebateComponentBusinessRule").init() />

<cfif form.command eq "save">

	<!---on save, get all the selected rule id's for each product/component combination and set them to the opener--->
	<cfloop index="compIndx" list="#form.compRules#">

		<!---strip hyphens from component uuid to use for varaible--->
		<cfset compUUIDStrip = request.app_general_functions.replaceHyphen(compIndx) />
			
		<cfloop index="compProdIndx" list="#Evaluate("form.compProdRules_#compUUIDStrip#")#">
			
			<cfset prodCompVarReplace = "#request.app_general_functions.replaceHyphen(compProdIndx)#_#compUUIDStrip#"/>
			<cfparam name="form.reb_rule_#prodCompVarReplace#" default="" />
			
			<!---guard against empty strings--->
			<cfif Evaluate(trim("form.reb_rule_#prodCompVarReplace#")) neq "">
			
				<script>
					opener.document.dataForm.reb_rule_#prodCompVarReplace#.value = #Evaluate("form.reb_rule_#prodCompVarReplace#")#;
				</script>
			
			</cfif>

		</cfloop>
		
	</cfloop>

	<script>
		opener.document.dataForm.action.value = 'updSave';
		opener.document.dataForm.submit('updSave', 1, 'save_table');
		window.close();
	</script>

	
</cfif>

<SCRIPT LANGUAGE="JavaScript"><!--

	function save() 
	{
		var thisForm = document.all.popupForm;
		
		//get list of required rules
		var requiredRules = thisForm.reqRules.value;
	
		var aReqList = requiredRules.split(",");
		
		if(!valReqRule(requiredRules, thisForm))
		{
			alert("Some rules are required. Please select required rules.");
			return;
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
			var inpVal = "reb_rule_" + aReqList[i];
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

<FORM action="" method="post" NAME="popupForm">

<cfif form.command eq "init">

	<!---loop over the components and display the form to apply business rules--->
	<cfloop index="compIndx" from="1" to="#ArrayLen(rebateData.aComp)#">
	
		<!---if the component has rules then check to see which uom's have a percent selected in the opener form--->
		<cfif rebateData.aComp[compIndx].hasRules eq 1 and rebateData.aComp[compIndx].rulesRequired eq 0>
		
			<!---strip hyphens from component uuid to use for varaible--->
			<cfset compUUIDStrip = request.app_general_functions.replaceHyphen(rebateData.aComp[compIndx].compUUID) />
			
			<cfset form.compRules = ListAppend(form.compRules, rebateData.aComp[compIndx].compUUID) />
			<cfset form.compRuleIds = ListAppend(form.compRuleIds, rebateData.aComp[compIndx].compNameId) />
			
			<cfparam name="form.lCompRuleUoms_#compUUIDStrip#" default="" />
			<input type="hidden" name="lCompRuleUoms_#compUUIDStrip#" />
				
			<script>
				var opnrUomList = eval("opener.document.dataForm.lCompRuleUoms_#compIndx#.value");
				document.all.popupForm.lCompRuleUoms_#compUUIDStrip#.value = opnrUomList;
			</script>
			
			<!---loop over the products and for each product that has a uom in the rule, display the available rebate rules--->
			<cfloop index="prodIndx" from="1" to="#ArrayLen(rebateData.aProd)#">
			
				<cfset prodCompVarReplace = "#request.app_general_functions.replaceHyphen(rebateData.aProd[prodIndx].masterItemID)#_#compUUIDStrip#"/>
				
				<cfparam name="form.uom_#prodCompVarReplace#" default="" />
				<input type="hidden" name="uom_#prodCompVarReplace#" />
				
				<cfparam name="form.opener_reb_rule_#prodCompVarReplace#" default="" />
				<input type="hidden" name="opener_reb_rule_#prodCompVarReplace#" />
				
				<script>
					var openerForm = opener.document.dataForm;
					var rateVal = eval("openerForm.comp_rate_#prodCompVarReplace#.value");
					//only check uom for rate values that are greater than 0
					if(rateVal > 0)
					{
						var uomSel = eval("openerForm.uom_#prodCompVarReplace#.options[openerForm.uom_#prodCompVarReplace#.selectedIndex].value");
						var opnrRebRule = eval("openerForm.reb_rule_#prodCompVarReplace#.value");
						document.all.popupForm.opener_reb_rule_#prodCompVarReplace#.value = opnrRebRule;
						document.all.popupForm.uom_#prodCompVarReplace#.value = uomSel;
					}
				</script>
	
			</cfloop>
			
		</cfif>
		
	</cfloop>
	
<cfelse>
	
	<!---TSF: Label 10125 - If we don't have any rebate rules then we have to pass 0  to the getComponentRules() function--->
	<cfif not len(trim(form.compRuleIds))>
		<cfset variables.tempComponentRuleIds = 0 />
	<cfelse>
		<cfset variables.tempComponentRuleIds = form.compRuleIds />
	</cfif>
	<!---get just selected rules then query that record set to get a distinct list--->
	<cfset qGetRulesToQuery = rebateRules.getComponentRules(variables.tempComponentRuleIds,1) />
	<cfquery name="qGetRules" dbtype="query">
		SELECT	DISTINCT Program_Rebates_Component_Rule_ID,
				Rebates_Component_Rule_Desc,
				Unit_Of_Measure_ID,
				Joined_Rule_Id
		FROM	qGetRulesToQuery
	</cfquery>
	<!---TSF: Label 10125 - Grab a list of rule id's from this query of a query to perform extra validation below when building the business rule matrix below--->
	<cfset form.programRebateComponentRuleIds = valueList(qGetRules.Program_Rebates_Component_Rule_ID) />
	<font color="##000066" size="3"><b>Apply Business Rules</b></font> 
	<hr color="navy">
	<!--- <font color="##FF0000">R = (Required)&nbsp;&nbsp;&nbsp;O = (Optional)</font>  --->
	<table border="0" cellpadding="1" cellspacing="0" CLASS="Maintable" bgcolor="ffce84" width="700">
	
		<tr>
			<td id="header" valign="top"><b>Product</b></td>
			<td id="header" valign="top"><b>Component</b></td>
			<!--- <td>&nbsp;</td> --->
			<!---loop over component rules--->
			<cfloop query="qGetRules">
				<td id="header" valign="top">
					<b>#Rebates_Component_Rule_Desc#</b>
				</td>
			</cfloop>
		</tr>

		<!---set counter to be used to determine where we are in the list--->
		<cfset compCounter = 1 />
				
		<cfloop index="compIndx" list="#form.compRules#">
			
			<!---strip hyphens from component uuid to use for varaible--->
			<cfset compUUIDStrip = request.app_general_functions.replaceHyphen(compIndx) />
			
			<!---param holder for products that need rules applied--->
			<cfparam name="form.compProdRules_#compUUIDStrip#" default="" />
			
			<cfloop index="prodIndx" from="1" to="#ArrayLen(rebateData.aProd)#">
			
				<cfset prodCompVarReplace = "#request.app_general_functions.replaceHyphen(rebateData.aProd[prodIndx].masterItemID)#_#compUUIDStrip#"/>
				
				<cfparam name="form.uom_#prodCompVarReplace#" default="" />
				<cfset uomVal = Evaluate("form.uom_#prodCompVarReplace#") />
				
				<!---get the compId from the rule id list--->
				<cfset compNameId = ListGetAt(form.compRuleIds, compCounter) />
				
				<!---get component data--->
				<cfset compData = rebateCompObj.getComp(compNameId) />
				
				<!---set required variable--->
				<cfset bIsRequired = compData.Rule_Required />
				
				<!---get rule data--->
				<cfset qRuleData = rebateRules.getComponentRules(compNameId) />
				<cfparam name="form.lCompRuleUoms_#compUUIDStrip#" default="" />

				<!---loop through products with components that have rules that apply to this uom--->
				<cfif ListFindNoCase(Evaluate("form.lCompRuleUoms_#compUUIDStrip#"), uomVal)>
				
					<!---if the uom is percent then add the product id to the component list holding products that have a rebate rule--->
					<cfset "form.compProdRules_#compUUIDStrip#" = ListAppend(Evaluate("form.compProdRules_#compUUIDStrip#"), rebateData.aProd[prodIndx].masterItemID) />
					
					<cfif bIsRequired eq 1>
						<!---append to required list--->
						<cfset form.reqRules = ListAppend(form.reqRules, prodCompVarReplace) />
					</cfif>
							
					<tr bgcolor="##FFFFFF">
						<td>#rebateData.aProd[prodIndx].Description#</td>
						<td>#compData.Program_Rebates_Component_Name#</td>
<!--- 		
						<td>
					<font color="##FF0000">
								<cfif bIsRequired eq 1>
									<!---append to required list--->
									<cfset form.reqRules = ListAppend(form.reqRules, prodCompVarReplace) />
									R
								<cfelse>
									O
								</cfif>
							</font>
						</td> --->
						<cfloop query="qRuleData">
							<!---TSF: Label 10125 - If the rule id isn't in the rule list then don't display the cell with the radio button--->
							<cfif listFindNoCase(form.programRebateComponentRuleIds, Program_Rebates_Component_Rule_ID)>
								<td>
									<!---enable radio only for rebate rules for this component--->
									<cfset joinId = trim(Joined_Rule_Id) />
									<cfif (joinId eq 0 or Len(joinId) eq 0) or uomVal neq Unit_Of_Measure_ID>
										<input name="" type="radio" disabled="true" value="" />
									<cfelse>
										<input name="reb_rule_#prodCompVarReplace#" type="radio" value="#Program_Rebates_Component_Rule_ID#" <cfif Evaluate("form.opener_reb_rule_#prodCompVarReplace#") eq Program_Rebates_Component_Rule_ID>checked</cfif> />
									</cfif>
								</td>
							</cfif>
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