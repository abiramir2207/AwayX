<!------ select_components.cfm ----->
<cfset Action = "edit">
<cfset pageName = "components">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Template - Components</title>
</head>

<body>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFSET PAGETITLE = "PROGRAM TEMPLATES: COMPONENTS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset ThisPage = CGI.SCRIPT_NAME>
<cfparam name="form.command" 	default="">
<cfparam name="form.id" 	default="0">
<cfparam name="url.id" 	default="#form.id#">
<cfparam name="FORM.DispalyPaysToOnViewProgPage" default="0" />
<cfset formName = "frmSelectComponents" />
<cfset tableBorderColor = "##93BEE2">

<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset template = templateManager.get(url.id)>

<cfset Created_Type = template.getCreatedType()>
<cfset Generic_Type = template.getGenericType()>
<cfset Active = template.getActive()>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script language="JavaScript">	
	/* Similar code exists on "program_wizard\component_select_templates_grid_js.js".
	Code change here may require a code change on that file too.
	"program_wizard\select_components.cfm" loops through components and
	"program_wizard\component_select_templates_grid_js.js" loops through templates.
	*/
	function submitForm(oForm, sCommand)
	{
		var ObjDiscountTypeIds = document.all.discountTypeIds.value.split(",");
		var ObjListPaidToTypes = document.all.listPaidToTypes.value.split(",");
		var allGood, anySelected, ObjErr, ObjError, ObjComponents, ObjDiscountTypeId, discountTypeIdLen, i, j, 
		    ObjListPaidToType, compLen, componentId;
		var anyItemChecked = 0;
		var selectedDefaultOption = 0;
		var selectedDefaultCFpagesOption = 0;
		var ObjErrorDefPaidTo = 0;
		var ObjErrorDefPaidToCFPages = 0;
		var selectedComponentPaidTo;
		var selectedDefaultComponentPaidTo = 0;
		allGood = true;
		
		<cfif Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type IS NOT "LSAutoPAy" AND template.Allow_Vendor_Only eq 0>
		if(ObjListPaidToTypes)
		{
			ObjListPaidToLen = ObjListPaidToTypes.length;	

			for(i=0;i<ObjListPaidToLen;i++)
			{
				ObjListPaidToType = ObjListPaidToTypes[i];
					if(eval("document.all.Payment_Paid_To_Type_"+ ObjListPaidToType+".checked") == true)
					{
						anyItemChecked = 1;
					}
			}
		}
		

		if(anyItemChecked == 0){
			allGood = false;
			queueMessage("You must include at least one 'Payment Paid To' option.", document.all.error_Payment_Paid_To);
		}
		else
		{
			clearQueue(document.all.error_Payment_Paid_To);
		}
		</cfif>

		if(ObjDiscountTypeIds)
		{
			discountTypeIdLen = ObjDiscountTypeIds.length;	

			for(i=0;i<discountTypeIdLen;i++)
			{
				ObjDiscountTypeId = ObjDiscountTypeIds[i];
				anySelected = 0;
				ObjComponents = eval("document.all.Component_Select_" + ObjDiscountTypeId);
				ObjErr = eval("document.all.Err_" + ObjDiscountTypeId);
				anySelected = Any_Object_Checked(ObjComponents);

				if(anySelected == 0)
				{
					allGood = false;
					queueMessage("Please select atleast one " + ObjErr.getAttribute('disc_name') + " component", ObjErr);
				}
				else
				{
					clearQueue(ObjErr);
				}

				<cfif template.Allow_Vendor_Only eq 0>
				if(ObjComponents)
				{
					compLen = ObjComponents.length;
					if(compLen)
					{
						for(j=0;j<compLen;j++)
						{
							compID = eval("document.all.Component_Select_" + ObjDiscountTypeId)[j].value;
							ObjError = eval("error_Component_Paid_To_Select_" + ObjDiscountTypeId+ "_" + compID);									
							selectedComponentPaidTo = 0;
							selectedDefaultComponentPaidTo = 0;

							/* If the component has been "included". */
							if(eval("document.all.Component_Select_" + ObjDiscountTypeId)[j].checked == true){
								var checkedPaidTo = false;
								var SelectedDefaultPaidToOptionIsOn = false;

								/* If "Default Rates Grid" select box exists  */
								if(typeof(eval("document.all.Component_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId)) != "undefined"){
									ObjErrorDefPaidTo = eval("error_Component_Paid_To_Default_" + ObjDiscountTypeId+ "_" + compID);	
									selectedDefaultOption = eval("document.all.Component_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId);
									selectedDefaultComponentPaidTo =  selectedDefaultOption[j].value.split("_")[1];
								}

								
								if(selectedDefaultComponentPaidTo == 0){
									/* If "Default "discount type" select box exists */
									if(typeof(eval("document.all.Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"){
										ObjErrorDefPaidTo = eval("error_Component_Paid_To_Default_" + ObjDiscountTypeId+ "_" + compID);	
										selectedDefaultOption = eval("document.all.Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId);
										selectedDefaultComponentPaidTo =  selectedDefaultOption[j].value.split("_")[1];
										ObjErrorDefPaidToCFPages = eval("error_Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId+ "_" + compID);
									}
								}

								if(ObjListPaidToTypes){
									ObjListPaidToLen = ObjListPaidToTypes.length;	
									for(m=0;m<ObjListPaidToLen;m++){
										ObjListPaidToType = ObjListPaidToTypes[m];
									
										if(eval("document.all.Component_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].disabled == false){
											
											/* Once any "paid to" checkbox is found checked, set 'checkedPaidTo" to true, so that we know that we do not
											need to ask the user to select at least one "paid to".
											*/
											if(checkedPaidTo == false){
												checkedPaidTo = eval("document.all.Component_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].checked;
											}
											
											/* Once any "paid to" checkbox is found checked, get the "paid_To_ID" (eg: 1 for dist, 2 for oper etc) of ths selcted option. */											
											if(eval("document.all.Component_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].checked)
											{
												selectedComponentPaidTo = eval("document.all.Component_Paid_To_Select_" + ObjDiscountTypeId + "_" + ObjListPaidToType)[j].name.split("_")[5];
											}
								
											/* If a "default paid to" is selected (using dropdown) for rates grid and/or CF Pages (discount type pages), then we need to make sure that
											those seleted options are also turned ON using the "paid to" checkboxes.
											eg: We cannot have "Default paid to" as "distributor", if "distributor" paid to checkbox is not ON.
											*/
											if((selectedComponentPaidTo == ObjListPaidToType && selectedComponentPaidTo == selectedDefaultComponentPaidTo) || selectedDefaultComponentPaidTo == 0){
												SelectedDefaultPaidToOptionIsOn = true;
											}
										}
										
									}

								}
									
								/* If a component is included, at least one 'paid to' needs to be included. */
								if(checkedPaidTo == false){
									allGood = false;
									queueMessage("Please make at least one 'paid to' selection", ObjError);
								}
								else{
									clearQueue(ObjError);
								}

								if((typeof(eval("document.all.Component_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId)) != "undefined")
								 || (typeof(eval("document.all.Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"))
								{
									/* Eg: If a user has selected "distributor" as the default "paid to" for the component, but the "distributor" option
									is not selected as the "paid to" for the component.
									*/
									if(SelectedDefaultPaidToOptionIsOn == false){
										allGood = false;
										queueMessage("Please make sure that the selected default paid to option is turned ON.", ObjErrorDefPaidTo);
									}
									else{
										clearQueue(ObjErrorDefPaidTo);
									}
								}
								/* Currently, we do not force users to select a default for the component, but the users are forced to select a default when
								"Single Component Per Discount Type" is ON.
								*/
								if(typeof(eval("document.all.Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"
									&& document.all.Single_Component_Per_Discount_Type.value == 1 
									&& selectedDefaultComponentPaidTo == 0
								){
									allGood = false;
									queueMessage("Please select the default 'paid to' for the component", ObjErrorDefPaidToCFPages);
								}
								else{
										clearQueue(ObjErrorDefPaidToCFPages);
								}
														
							}
							else{
								clearQueue(ObjError);
								if((typeof(eval("document.all.Component_Paid_To_Default_Rates_Grid_" + ObjDiscountTypeId)) != "undefined")
								 || (typeof(eval("document.all.Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined"))
								{
									clearQueue(ObjErrorDefPaidTo);
								}
								if(typeof(eval("document.all.Component_Paid_To_Default_CF_Pages_" + ObjDiscountTypeId)) != "undefined")
								{
									clearQueue(ObjErrorDefPaidToCFPages);
								}
								
							}
										
						}
					}
					
				}
				</cfif>
			}
		}


		if(allGood)
		{
			oForm.command.value = "save";
			oForm.submit();
		}
		else
		{
			showMessageWindow();
		}
	}
	
	function selectAll(discId, bCheck)
	{
		event.returnValue = false;
		var ObjComponents = eval("document.all.Component_Select_" + discId);
		var i, compLen;
		if(ObjComponents)
		{
			compLen = ObjComponents.length;
			if(compLen)
			{
				for(i=0;i<compLen;i++)
				{
					if(!ObjComponents[i].disabled)
					{
						ObjComponents[i].checked = bCheck;
					}
				}
			}
			else
			{
				if(!ObjComponents.disabled)
				{
					ObjComponents.checked = bCheck;
				}
			}
		}
	}

	function unselectAllOptions(objChkBox)
	{
		if(objChkBox.checked == false)
		{
			var tr = $(objChkBox).closest("tr");

			/* Find all the checkboxes on the row that was clicked, except the first one (the one that was checked/unchecked). */
			var chkBoxes = tr.find("input[type=checkbox]:not(input[type=checkbox]:first)");

			/* uncheck all the checkboxes */
			chkBoxes.attr("checked", false);

			/* Find all the selectboxes on the row that was clicked. */
			var selectBoxes = tr.find("select");

			/* reset the selectboxes. */
			$(selectBoxes).prop("selectedIndex", 0);
		}
	}

	function selectAllPaidTo(discId,paymentPaidToId,bCheck)
	{
		event.returnValue = false;
		var ObjComponents = eval("document.all.Component_Paid_To_Select_" + discId + "_" + paymentPaidToId);

		var i, compLen;
		if(ObjComponents)
		{
			compLen = ObjComponents.length;
			if(compLen)
			{
				for(i=0;i<compLen;i++)
				{
					if(!ObjComponents[i].disabled)
					{	/* If the "component" is "included" */
						if(eval("document.all.Component_Select_" + discId)[i].checked == true && bCheck == true){
							ObjComponents[i].checked = bCheck;
						}
						else if (bCheck == false){
							ObjComponents[i].checked = bCheck;
						}
					}
				}
			}
			else
			{
				if(!ObjComponents.disabled)
				{
					ObjComponents.checked = bCheck;
				}
			}
		}
	}

	function selectAllDefaultPaidTo(discId,pageType,selectedOption)
	{
		event.returnValue = false;
		if(pageType == 1){
			var ObjApplyComponents = eval("document.all.Component_Paid_To_MassApply_For_CF_Pages_" + discId);
			var ObjComponents = eval("document.all.Component_Paid_To_Default_CF_Pages_" + discId);
		}
		else if(pageType == 2){
			var ObjApplyComponents = eval("document.all.Component_Paid_To_MassApply_For_Rates_Grid_" + discId);
			var ObjComponents = eval("document.all.Component_Paid_To_Default_Rates_Grid_" + discId);
		}
		

		var i, compLen;
		if(ObjComponents)
		{
			compLen = ObjComponents.length;
			if(compLen)
			{
				for(i=0;i<compLen;i++)
				{	
					/* If the "component" is "included" */
					if(eval("document.all.Component_Select_" + discId)[i].checked == true && !ObjComponents[i].disabled)
					{
						ObjComponents[i].selectedIndex = selectedOption;
					}
				}
			}
			else
			{
				if(!ObjComponents.disabled)
				{
					ObjComponents.selectedIndex = selectedOption;
				}
			}
		}
	}

function alert_in_use(component) {
  if ( ! component.checked ) {
    alert('The component(s) selected are not in sync with the components on the EZ Button page.\n\nPlease do one of the following:\n\n1) Update the EZ Button page so it uses a component that is selected on the Components page\n\n2) Update the Components page and select the component which is in use on the EZ Button page.');
  }

}


  function enableDisable(paymentPaidToId,checkedStatus){
 
	var ObjDiscountTypeIds =  document.all.discountTypeIds.value.split(",");

	if(ObjDiscountTypeIds)
	{
		discountTypeIdLen = ObjDiscountTypeIds.length;
		for(i=0;i<discountTypeIdLen;i++)
		{
			var j, compLen;
			
			ObjDiscountTypeId = ObjDiscountTypeIds[i];
			ObjComponents = eval("document.all.Component_Paid_To_Select_" + ObjDiscountTypeId + "_" + paymentPaidToId);
								
			if(ObjComponents)
			{
				compLen = ObjComponents.length;
				if(compLen)
				{
					for(j=0;j<compLen;j++)
					{
						ObjComponents[j].disabled = !checkedStatus;
						/* If the main setting is disabled, then uncheck all related checkboxes.
						eg:If the "distributor" checkbox is unchecked, then all the "Paid to Distributor" checkboxes should be disabled too.
						*/
						if(checkedStatus == false){
							ObjComponents[j].checked = checkedStatus;
						}
					}
				}
				else
				{
					ObjComponents.disabled = !checkedStatus;
					if(checkedStatus == false){
						ObjComponents.checked = checkedStatus;
					}
				}
			}
		}

	}
  }
</script>

<cfif url.id>

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<cfset allow_dup_programs = template.getDuplicate()>
	<cfset fixedprice_freight = template.getFixedFreight()>

	<cfset fixedComponentTypeObj = CreateObject("component", "components.programs.Fixed.FixedComponent") />
	
	<cfif form.command EQ "save">

	<!------ save here ----->
	
		<cfset id = url.id>
		<cfparam name="form.discountTypeIds" 	default="">
		<cfparam name="form.DEFAULT_COMP" 	default="0">
		<cfset defaultComp = left(form.DEFAULT_COMP,1) />

		<!---Payment Paid To types--->
		<cfquery name="Delete_Current_PaidTos" datasource="#application.datasource#">
			DELETE FROM Payment_Paid_To_Template_Mapping 
			WHERE Template_ID = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfset useLakebaseForGetPaymentPaidToTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_paid_to_types")>
<cfif useLakebaseForGetPaymentPaidToTypes>
	<cftry>
		<cfset GetPaymentPaidToTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_paid_to_types", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPaymentPaidToTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPaymentPaidToTypes>
<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
			SELECT distinct *
			FROM Payment_Paid_To_Types
			WHERE Deleted = 0
		</cfquery>
</cfif>

		<cfloop query="GetPaymentPaidToTypes">
		<cfif isDefined("Form.Payment_Paid_To_Type_#Evaluate(Payment_Paid_To_ID)#")>
			<cfquery name="InsertPaymentPaidToRecord" datasource="#application.datasource#">
			INSERT INTO Payment_Paid_To_Template_Mapping
			(
				Template_ID,
				Payment_Paid_To_ID
			)
			VALUES
			(
				<cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Payment_Paid_To_ID#" cfsqltype="cf_sql_integer">
			)
			</cfquery>
		</cfif>
		</cfloop>

		<cfif defaultComp eq 1>
			<cfquery name="updateDefaultComponent" datasource="#application.datasource#">
	        	 UPDATE Program_Control_Panel_Options
				 SET Default_Fixed_Component_Name_Id = #Listgetat(form.DEFAULT_COMP,2,'_')#,
				 	Default_Rebate_Component_Name_Id = 0
				 WHERE ProgramControl_Panel_Options_ID = #id#
			</cfquery>
		<cfelseif defaultComp eq 2>
			<cfquery name="updateDefaultComponent" datasource="#application.datasource#">
	        	 UPDATE Program_Control_Panel_Options
				 SET Default_Rebate_Component_Name_Id = #Listgetat(form.DEFAULT_COMP,2,'_')#,
				 	Default_Fixed_Component_Name_Id = 0
				 WHERE ProgramControl_Panel_Options_ID = #id#
			 </cfquery>
		<cfelseif defaultComp eq 0>
			<cfquery name="updateDefaultComponent" datasource="#application.datasource#">
	        	 UPDATE Program_Control_Panel_Options
				 SET Default_Rebate_Component_Name_Id = 0,
				 	Default_Fixed_Component_Name_Id = 0
				 WHERE ProgramControl_Panel_Options_ID = #id#
			</cfquery>
		</cfif>

		<cfquery name="updateDisplayPaysTo" datasource="#application.datasource#">
		 UPDATE Program_Control_Panel_Options
			SET DispalyPaysToOnViewProgPage = <cfqueryparam value="#FORM.DispalyPaysToOnViewProgPage#"cfsqltype="CF_SQL_BIT" />
			WHERE ProgramControl_Panel_Options_ID = #id#
		</cfquery>

		<cfloop list="#form.discountTypeIds#" index="Current_Discount_Type_ID">
			<cfparam name="Component_Paid_To_Default_CF_Pages_#Current_Discount_Type_ID#" 	default="">
			<cfparam name="Component_Paid_To_Default_Rates_Grid_#Current_Discount_Type_ID#" default="">
			<cfparam name="Component_Paid_To_Select_#Current_Discount_Type_ID#" default="">


			<cfset ComponentSelectList = Evaluate("Component_Select_#Current_Discount_Type_ID#") />
			<cfset ComponentPaidToDefaultCFPages = Evaluate("Component_Paid_To_Default_CF_Pages_#Current_Discount_Type_ID#") />
			<cfset ComponentPaidToDefaultRatesGrid = Evaluate("Component_Paid_To_Default_Rates_Grid_#Current_Discount_Type_ID#") />
			
			<cfset structComponentPaidTo = structNew()>

			<cfset loopInt = 0>
			<cfloop collection="#form#" item="fieldObj">
				
				<!--- If the form field is "paid to distributor", "paid to operator" etc, set the "Component_Paid_To_Select_XXXX" form field value
				in "component_paidto" format.
				Eg:
				When "COMPONENT_PAID_TO_SELECT_1_1" has value of  4  and COMPONENT_PAID_TO_SELECT_1_2 also has value of of 4.
				On "COMPONENT_PAID_TO_SELECT_1_1", the first 1 is discount type (fixed price has id of 1), the second 1 is the "Paid to", 
				1 being paid to (distributor has id of 1). The value of 4 is component name id.
				Below code will make a struct which will have 2 entries 4_1 and 4_2. This is the combination of component and paid to.
				This code is inside a discount type loop and so we do not need to include the discount type.
				--->
				<cfif FindNoCase('Component_Paid_To_Select_#Current_Discount_Type_ID#',fieldObj) neq 0>
					<cfset loopInt = loopInt + 1>
					<cfset InnerloopInt =0>
					<cfloop list="#form[fieldObj]#" index="compID">
					<cfset InnerloopInt = InnerloopInt + 1>
						<cfset structComponentPaidTo[loopInt][InnerloopInt] = compID & "_" & ListLast(fieldObj,'_')>
					</cfloop>
				</cfif>				
			</cfloop>

			<!--- If it's fixed price --->
			<cfif Current_Discount_Type_ID eq 1>
			<!--- Check to see whether it is a freight program template, based on component type --->
				<cfset IsFreightProgram = fixedComponentTypeObj.getIsFreightProgram(ComponentSelectList)>
			<!--- Set the program template to be "freight based" template or not --->
				<cfset fixedComponentTypeObj.SetIsFreightProgram(id,IsFreightProgram)>
			</cfif>
			
			<cfset templateManager.saveTemplateDiscountComponents(id, Current_Discount_Type_ID, ComponentSelectList, ComponentPaidToDefaultCFPages, ComponentPaidToDefaultRatesGrid, structComponentPaidTo) />
		</cfloop>
		
		<!------ Redirect to next page ----->		
		<cfinclude template="Next_Page.cfm" />

	<cfelse>	
		<cfset qGetAllDiscountTypes = templateManager.getAllComponentDiscountTypes(url.id)>
		<cfset discountTypeList = ValueList(qGetAllDiscountTypes.DISCOUNT_TYPE_ID) />	
		<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(templateId=url.id, discountTypeList=discountTypeList,returnSelected=0,fixedprice_freight=fixedprice_freight) />	
		
		<!------ display header ----->		
		<cfinclude template="header.cfm">
		
		<form name="#formName#" method="post" action="#ThisPage#" style="display:inline;" id="components">

		<cfset rdoNoDefChecked = ''/>
		<cfif qGetAllTemplateDiscountComponents.Default_Fixed_Component_Name_Id eq 0 AND qGetAllTemplateDiscountComponents.Default_Rebate_Component_Name_Id eq 0>
					<cfset rdoNoDefChecked = 'checked'/>
		</cfif>
		

	<div style="margin:0 0 10px 0;">    <!--- 42176 --->
	<span style="width:80%;display:inline-block;"><CFINCLUDE TEMPLATE="/includes/Search_on_Page.cfm"></span>
		<cfif LockedBy_Current_User EQ 1>
			<span style="width:19%;text-align:right;"><a href="javascript:submitForm(document.#formName#);">#application.util.string.actionLinkFormat("save and continue")#</a></span>
		</cfif>
	</div>


	<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Payment_Paid_To_Types
	WHERE 	Deleted = 0
	<cfif Generic_Type IS "Brokerage" > and	Payment_Paid_To_ID = 3 </cfif>
	ORDER BY Payment_Paid_To_ID
	</cfquery>

	<cfset listPaidToTypes = valueList(GetPaymentPaidToTypes.Payment_Paid_To_ID)>

	<cfquery name="PaidToTypesInThisTemplate" datasource="#application.datasource#">
	SELECT 	Payment_Paid_To_ID
	FROM 	Payment_Paid_To_Template_Mapping
	WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
	AND 	Payment_Paid_To_ID in (<cfqueryparam value="#valuelist(GetPaymentPaidToTypes.Payment_Paid_To_ID)#" cfsqltype="cf_sql_integer" list="Yes">)
	</cfquery>

	<cfset listPaidToTypesInThisTemplate = valueList(PaidToTypesInThisTemplate.Payment_Paid_To_ID)>

		<cfif template.Allow_Vendor_Only eq 0>
		<cfif Generic_Type IS NOT "Distributor Off-Invoice" AND Generic_Type IS NOT "LSAutoPAy" >

		<!----Payment Paid To--->
		<table cellpadding="1" cellspacing="0" width="50%" border="0">

			<tr bgcolor="FFCE84">
				<td>&nbsp;&nbsp;<b>Payment Paid To</b><span id="error_Payment_Paid_To"></span></td>
				<td><b>Include</b></td>
			</tr>

			<cfquery name="AllTypes" datasource="#application.datasource#">
				SELECT 	*
				FROM 	Payment_Paid_To_Template_Mapping
				WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfloop query="GetPaymentPaidToTypes">

				<cfquery name="TypeInThisTemplate" datasource="#application.datasource#">
					SELECT 	Payment_Paid_To_ID
					FROM 	Payment_Paid_To_Template_Mapping
					WHERE 	Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
					AND 	Payment_Paid_To_ID = <cfqueryparam value="#GetPaymentPaidToTypes.Payment_Paid_To_ID#" cfsqltype="cf_sql_integer">
				</cfquery>

				<tr>
					<td width="50%" style="border-bottom:1px solid ##93BEE2;">
					#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#
					</td>
					<cfsilent>
					<cfset checkbox = "false">
					<cfset checkboxdefault = "false">
					<cfif AllTypes.recordcount EQ 0>
						<cfif Generic_Type EQ "Distributor Trade/Shelter" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "D">
							<cfset checkbox = "true">
							<cfset checkboxdefault = "true">
						<cfelseif Generic_Type EQ "Distributor Trade/Shelter" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "O">
							<cfset checkbox = "false">
							<cfset checkboxdefault = "false">
						<cfelseif Generic_Type EQ "Operator Direct or HQ Programs" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "O">
							<cfset checkbox = "true">
							<cfset checkboxdefault = "true">
						<cfelseif Generic_Type EQ "Operator Direct or HQ Programs" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "D">
							<cfset checkbox = "false">
							<cfset checkboxdefault = "false">
						<cfelseif Generic_Type EQ "Brokerage" and trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "B">
							<cfset checkbox = "true">
							<cfset checkboxdefault = "true">
						<cfelse>
							<cfif trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "D">
								<cfset checkbox = "true">
								<cfset checkboxdefault = "true">
							</cfif>
							<cfif trim(GetPaymentPaidToTypes.Payment_Paid_To_Type_Identifier) eq "O">
								<cfset checkbox = "true">
							</cfif>
						</cfif>
					</cfif>
					</cfsilent>
					<td style="border-bottom:1px solid ##93BEE2;"><input type="checkbox" name="Payment_Paid_To_Type_#Payment_Paid_To_ID#" value="1" onClick="enableDisable('#GetPaymentPaidToTypes.Payment_Paid_To_ID#',this.checked)" <cfif (len(trim(TypeInThisTemplate.Payment_Paid_To_ID)) GT 0 or checkbox EQ "true") >checked</cfif> >
					</td>
				</tr>
			</cfloop>
			<tr>
				<td>Display pays to below component name on View Prog Page</td>
				<td>
					<input type="checkbox" name="DispalyPaysToOnViewProgPage" value="1" <cfif template.DispalyPaysToOnViewProgPage EQ 1>checked</cfif>>
				</td>
				<td>&nbsp;<td>
			</tr>
					
		</table>
		<br />
		</cfif>
		<cfelse>
			<!--- Dev Note: WR 78635 - When vendor is the only payee on the template, set "distributor" as "Payment_paid_to".  --->
			<input type="hidden" name="Payment_Paid_To_Type_1" value="1">
			<input type="hidden" name="DispalyPaysToOnViewProgPage" value="1">
		</cfif>

		<table cellpadding="1" cellspacing="0" width="100%" border="0">

		<cfif template.Fixed_Rebate_Grid_Option>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td><input type="radio" name="default_Comp" value="0" #rdoNoDefChecked#><strong>No Default component for Rates Grid</strong></td>
		<tr>
		</cfif>

		<cfloop query="qGetAllDiscountTypes">
			<cfset Current_Discount_Type_ID = Discount_Type_ID />
			<cfset Default_Component_For_Rates_Grid = 0>
			<cfset Default_Component_For_CF_Pages = 0>
			
			<!--- If "Rates Grid" is ON, and the discount type is "rebates" or "Fixed Price".
			Note:Rates Grid is for rebate and/or fixed price.
			--->
			<cfif template.Fixed_Rebate_Grid_Option AND (Current_Discount_Type_ID EQ 1 OR Current_Discount_Type_ID EQ 2)>
				<cfset Default_Component_For_Rates_Grid = 1>
			</cfif>
			
			<!--- If "Rates Grid" is OFF OR the discount type is NOT "rebates" and "Fixed Price".			
			Note:Rates Grid is for rebate and/or fixed price.
			"Default Paid to" select box at the component level should always be available for non-rebate and non-fixed price discount pages.
			For rebate and fixed price discount pages, the select box should be available, only when the "rates grid" is OFF.
			For rebate, we can still have the select box available, when groups need to be set up from the CF discount pages, even when
			the products rates are set up from the rates grid. This happens when the "group" checkbox is ON on the "details" tab for rebate.
			--->
			<cfif template.Fixed_Rebate_Grid_Option eq 0 OR (Current_Discount_Type_ID NEQ 1 AND Current_Discount_Type_ID NEQ 2)
				OR (Current_Discount_Type_ID EQ 2 AND (template.Discount_Rebates_Group_Level EQ 1 AND appSettings.getTemplateMultipleProductAttrGroups() EQ 0))>
				<cfset Default_Component_For_CF_Pages = 1>
			</cfif>

			<tr bgcolor="FFCE84" style="height:20px">
			<td width="20%" style="border-bottom:1px solid ##93BEE2;">&nbsp;</td>
			
			<td width="11%" style="border-bottom:1px solid ##93BEE2;">
			<CF_smallLink 
				title = "select all" 
				url = "##"
				parameters = "onClick=""javascript: return selectAll('#Current_Discount_Type_ID#', true);"""
			> <br />
			<CF_smallLink 
				title = "deselect all" 
				url = "##"
				parameters = "onClick=""javascript: return selectAll('#Current_Discount_Type_ID#', false);"""
			></td>

			<cfif template.Allow_Vendor_Only eq 0>
			<cfif Default_Component_For_Rates_Grid><td width="11%" style="border-bottom:1px solid ##93BEE2;">&nbsp;</td></cfif>

			<cfloop query="GetPaymentPaidToTypes">
			<td width="11%" style="border-bottom:1px solid ##93BEE2;">			
			<CF_smallLink 
				title = "select all" 
				url = "##"
				parameters = "onClick=""javascript: return selectAllPaidTo('#Current_Discount_Type_ID#', '#Payment_Paid_To_ID#', true);"""
			> <br />
			<CF_smallLink 
				title = "deselect all" 
				url = "##"
				parameters = "onClick=""javascript: return selectAllPaidTo('#Current_Discount_Type_ID#', '#Payment_Paid_To_ID#', false);"""
			></td>
			</cfloop>
			

			<cfif Default_Component_For_CF_Pages>
			<td width="11%" style="border-bottom:1px solid ##93BEE2;">
			<CF_smallLink 
				title = "mass apply" 
				url = "##"
				parameters = "onClick=""javascript: return selectAllDefaultPaidTo('#Current_Discount_Type_ID#',1, document.getElementById('Component_Paid_To_MassApply_For_CF_Pages_#Current_Discount_Type_ID#').selectedIndex);"""
			>
			<br />
			<select name="Component_Paid_To_MassApply_For_CF_Pages_#Current_Discount_Type_ID#" id="Component_Paid_To_MassApply_For_CF_Pages_#Current_Discount_Type_ID#">
				<option value="0">----None----</option>
				<cfloop query="GetPaymentPaidToTypes">
				<option value="#payment_Paid_To_ID#">#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</option>
				</cfloop>
			</select>
			</td>	
			</cfif>

			<cfif Default_Component_For_Rates_Grid>
			<td width="11%" style="border-bottom:1px solid ##93BEE2;">

			<CF_smallLink 
				title = "mass apply" 
				url = "##"
				parameters = "onClick=""javascript: return selectAllDefaultPaidTo('#Current_Discount_Type_ID#',2, document.getElementById('Component_Paid_To_MassApply_For_Rates_Grid_#Current_Discount_Type_ID#').selectedIndex);"""
			>
			<br />
			<select name="Component_Paid_To_MassApply_For_Rates_Grid_#Current_Discount_Type_ID#" id="Component_Paid_To_MassApply_For_Rates_Grid_#Current_Discount_Type_ID#">
				<option value="0">----None----</option>
				<cfloop query="GetPaymentPaidToTypes">
				<option value="#payment_Paid_To_ID#">#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</option>
				</cfloop>
			</select>
			</td>
			</cfif>
			</cfif>
			</tr>

			<tr bgcolor="FFCE84" style="height:20px">
			<td width="20%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;<strong>#Discount_Type_Desc# Components</strong>
			<span id="Err_#Current_Discount_Type_ID#" disc_name="#Discount_Type_Desc#">&nbsp;</span>
			</td>

			<td width="11%"><b>Include</b></td>
			<cfif Default_Component_For_Rates_Grid>
			<td width="11%"><strong>Default component<br />for Rates Grid</strong>
			</cfif>
			<cfif template.Allow_Vendor_Only eq 0>
				<cfloop query="GetPaymentPaidToTypes">
				<td width="11%" style="border-bottom:1px solid ##93BEE2;"><strong>Paid To <br />#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</strong></td>
				</cfloop>

				<cfif Default_Component_For_CF_Pages><td width="11%"><strong>Default Paid To <br />for #Discount_Type_Desc#</strong></td></cfif>
				<cfif Default_Component_For_Rates_Grid><td width="11%"><strong>Default Paid To <br /> for Rates Grid</strong></td></cfif>
			</cfif>
			</tr>

			<tr>
			<td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
			<cfquery name="qGetTemplateComponents" dbtype="query">
				SELECT	*
				FROM	qGetAllTemplateDiscountComponents
				WHERE	DISCOUNT_TYPE_ID = #DISCOUNT_TYPE_ID#
			</cfquery>

			<cfset vars = StructNew()>

			<cfif Template.EZButton_On eq 1>
				  <!--- determine if components are in use in EZ Button 27323 --->
				<cfif len(Template.ez_Contract_Id) EQ 0>	
					<cfset ez_Contract_Id = 0>
				<cfelse>
					<cfset ez_Contract_Id = Template.ez_Contract_Id	>
				</cfif>
					
				<cfquery name="vars.EZButtonRs" datasource="#application.datasource#">
				  SELECT 1, Program_Rebates_Component_Name_ID
				    FROM Program_Rebates_Component prc
				   WHERE prc.Program_Id = #ez_Contract_Id#
					 AND prc.Deleted = 0
					 AND prc.Program_Rebates_Component_Name_Id IN ( #ValueList(qGetTemplateComponents.Component_Id)# )
				</cfquery>
			 </cfif>
			<cfif qGetTemplateComponents.recordCount>
				<cfset colsCount = 0 />	
				<cfset headerCount = 0 />
				<cfloop query="qGetTemplateComponents">				
					<cfset qGetAllTemplateDiscountComponentPaidTo = templateManager.getAllTemplateDiscountComponentPaidTo(qGetTemplateComponents.Program_Template_component_ID)>
					<cfset ListGetAllTemplateDiscountComponentPaidTo = ValueList(qGetAllTemplateDiscountComponentPaidTo.Payment_Paid_To_ID)>

				<tr>
				<cfif Template.EZButton_On neq 1>
				  <cfset vars.isComponentInUse = false>
				<cfelse>
				  <!--- EZ Button is on - determine if this component is in use on EZ Button 27323 --->
				  <cfquery name="vars.componentInUseRs" dbtype="query">
				    SELECT 1
				      FROM vars.EZButtonRs
				     WHERE Program_Rebates_Component_Name_Id = #qGetTemplateComponents.Component_Id# 
				  </cfquery>
				  <cfset vars.isComponentInUse = (vars.ComponentInUseRs.recordCount gt 0)>
				</cfif>
				
				<td width="20%" style="border-bottom:1px solid ##93BEE2;">#Component_Name# <cfif (External_ID NEQ "")>(#External_ID#)</cfif></td>
				
				<cfif template.Single_Component_Per_Discount_Type EQ 1>
					<td width="13%" style="border-bottom:1px solid ##93BEE2;">
					<span id="error_Component_Paid_To_Select_#Current_Discount_Type_ID#_#Component_ID#"></span>
					<span id="error_Component_Paid_To_Default_#Current_Discount_Type_ID#_#Component_ID#"></span>
					<input type="radio" <cfif vars.isComponentInUse>onclick="javascript:alert_in_use(this)"</cfif> name="Component_Select_#Current_Discount_Type_ID#" value="#Component_ID#" <cfif Active EQ 0>disabled title="This component is inactive"</cfif> <cfif Component_Selected EQ 1>checked</cfif>>&nbsp;
					</td>
				<cfelse>
					<cfset rdoChecked = ''/>
					<cfif (Default_Fixed_Component_Name_Id eq Component_ID AND Current_Discount_Type_ID eq 1) OR (Default_Rebate_Component_Name_Id eq Component_ID AND Current_Discount_Type_ID eq 2)>
						<cfset rdoChecked = 'checked'/>
					</cfif>
					<td width="13%" style="border-bottom:1px solid ##93BEE2;">
					<span id="error_Component_Paid_To_Select_#Current_Discount_Type_ID#_#Component_ID#"></span>
					<span id="error_Component_Paid_To_Default_#Current_Discount_Type_ID#_#Component_ID#"></span>
					<input type="checkbox" <cfif vars.isComponentInUse>onclick="javascript:alert_in_use(this);unselectAllOptions(this)"<cfelse>onclick="javascript:unselectAllOptions(this)"</cfif> name="Component_Select_#Current_Discount_Type_ID#" value="#Component_ID#" <cfif Active EQ 0>disabled title="This component is inactive"</cfif> <cfif Component_Selected EQ 1>checked</cfif>>&nbsp;
					<cfif Default_Component_For_Rates_Grid><td width="13%" style="border-bottom:1px solid ##93BEE2;"><input type="radio" name="default_Comp" value="#Current_Discount_Type_ID#_#Component_ID#" #rdoChecked#></td></cfif>
				</cfif>
				
				<cfif template.Allow_Vendor_Only eq 0>
				<cfloop query="GetPaymentPaidToTypes">
				<td width="13%" style="border-bottom:1px solid ##93BEE2;">
				<input type="checkbox" name="Component_Paid_To_Select_#Current_Discount_Type_ID#_#Payment_Paid_To_ID#" value="#qGetTemplateComponents.Component_ID#"<cfif ListFindNoCase(ListGetAllTemplateDiscountComponentPaidTo,Payment_Paid_To_ID)>checked</cfif><cfif NOT ListFindNoCase(listPaidToTypesInThisTemplate,Payment_Paid_To_ID) AND listlen(listPaidToTypesInThisTemplate) GT 0>disabled</cfif>></td>
				</cfloop>

				<cfif Default_Component_For_CF_Pages>
				<td width="13%" style="border-bottom:1px solid ##93BEE2;">
				<span id="error_Component_Paid_To_Default_CF_Pages_#Current_Discount_Type_ID#_#Component_ID#"></span>
				<select name="Component_Paid_To_Default_CF_Pages_#Current_Discount_Type_ID#">
					<option value="0_0">----None----</option>
					<cfloop query="GetPaymentPaidToTypes">
					<option value="#qGetTemplateComponents.Component_ID#_#payment_Paid_To_ID#" <cfif qGetTemplateComponents.Default_Paid_To_CF_Pages eq payment_Paid_To_ID>SELECTED</cfif>>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</option>
					</cfloop>
				</select>
				</td>
				</cfif>

				<cfif Default_Component_For_Rates_Grid>
				<td width="13%"  style="border-bottom:1px solid ##93BEE2;">
				<select name="Component_Paid_To_Default_Rates_Grid_#Current_Discount_Type_ID#">
					<option value="0_0">----None----</option>
					<cfloop query="GetPaymentPaidToTypes">
					<option value="#qGetTemplateComponents.Component_ID#_#payment_Paid_To_ID#" <cfif qGetTemplateComponents.Default_Paid_To_Rates_Grid eq payment_Paid_To_ID>SELECTED</cfif>>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</option>
					</cfloop>
				</select>				
				</td>
				</cfif>

				</td>
				</tr>
				</cfif>
				</cfloop>
			<cfelse>
				No component found
			</cfif>
			</td>
			</tr>
			<tr>
			<td colspan="100%">&nbsp;</td>
			</tr>
		</cfloop>
		</table>
		
		<input type="Hidden" name="discountTypeIds" value="#ValueList(qGetAllDiscountTypes.Discount_Type_ID)#">
		<input type="hidden" name="id" value="#url.id#">
		<input type="hidden" name="command" value="#form.command#">
		<input type="hidden" name="listPaidToTypes" value="#listPaidToTypes#">	
		<input type="hidden" name="Single_Component_Per_Discount_Type" value="#template.Single_Component_Per_Discount_Type#">
		</form>
		<br>
		<table align="center" border="0" cellpadding="0" cellspacing="0">
		<tr>		
		<td>
		
		<cfif LockedBy_Current_User EQ 1 and qGetAllDiscountTypes.recordCount gt 0>			
		<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"submitForm(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</cfif>
		</td>		
		</tr>
		</table>
	</cfif>
</cfif>



<br>
<CF_MessageWindow>

<cfif LockedBy_Current_User NEQ 1>
  <cfinclude template="/common_files/jQuery.cfm">
  <script>
 	  $("##components input[type!=hidden], ##components a").attr("disabled", "disabled");
  </script>
</cfif>
</body>
</html>
</cfoutput>
