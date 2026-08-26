<cfsilent>
<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<CFPARAM NAME="form.compExternalID" 	DEFAULT="">
<cfparam name="form.Operating_Group_ID" 	default="0">
<cfparam name="form.Allowance_Code_ID" 	default="0">
<cfparam name="form.Template_Select" 	default="">
<cfparam name="form.FOB_PayeeType1_DiscountType" 	default="">
<cfparam name="form.FOB_PayeeType2_DiscountType" 	default="">
<cfparam name="form.FOB_PayeeType3_DiscountType" 	default="">
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added Below 5Param Tags--->
<cfparam name="form.Growth_Percent_Option" 	default="1">
<cfparam name="form.Auto_Pay_Net_Of_Cash_Discount" 	default="0">
<cfparam name="form.Auto_Pay_Net_Of_Freight_Allowance" 	default="0">
<cfparam name="form.Auto_Pay_Exclude_Credit_Type" 	default="0">
<cfparam name="form.Credit_Type_Select" 	default="">
<cfparam name="form.Visibility" default="0">
<cfparam name="form.Template_Paid_To_Default_Rates_Grid_4" default="">
<cfparam name="form.Template_Paid_To_Default_CF_Pages_4" default="">
<cfparam name="form.Template_Select_4" default="">           <!--- 55711 :: template is no longer required --->

<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfparam name="form.displayExternalID" 	default="0">
<cfparam name="form.displayDeductionAccount" 	default="0">
<cfparam name="form.displayPaymentAccount" 	default="0">
<!--- D58135 ::  Additional Component info displaye inside program END--->

<cfparam name="form.TPO_Field"  default="0"><!--- 95126 --->
<cfparam name="form.TPO_Rate_Type"  default="0"><!--- 95126 --->
<cfparam name="form.GLList" default="">
<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "growthComponents"
							selectedIndex = "#selectedIndex#" >

<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/styles/css-loader.css">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /Script/javascript/default.js" />

<cfmodule template="/customTags/include.cfm" file_to_include="/Common_Files/Delete_Functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="growth_component.js"/>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Growth Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<!--- End Dev Note: drachala; D28881: Update growth component settings to include additional elements  --->
<cfscript>
	compRebate = CreateObject("component","components.programs.rebates.RebateComponent");/*D28881: Update growth component settings to include additional elements*/
	compGrowth = CreateObject("component","components.programs.Growth.GrowthComponent");
	compGrowthProfile = CreateObject("component","components.programs.Growth.GrowthComponentProfile");
	templateManager = CreateObject("component","components.programs.template.TemplateManager").init();
</cfscript>
<cfset operatingGroupManager = CreateObject("component","components.Operating_Group.OperatingGroupManager").init() />
<cfset operatingGroupOn = operatingGroupManager.operatingGroupOn() />
<cfset operatingGroupLevel = operatingGroupManager.componentMapLevel() />
<cfset allowanceCodeManager = CreateObject("component","components.Operating_Group.AllowanceCodeManager").init() />
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: get credit type details --->
<cfset application.oController.getObject(path="mvc.Models.Program.CreditTypeManager",name="CreditTypeManager",bReload= 0) />
<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />

<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset ID = LabelComp.getGeneralLabels('Growth External ID')>
<!--- D58135 ::  Additional Component info displaye inside program END --->

<!---****************************** START COMMANDS ***********************************--->
<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added 5 Argumnets from Growth_Percent_Option_ID to Credit_Type_Select--->

	<cfset TemplatePaidToDefaultCFPages = Evaluate("form.Template_Paid_To_Default_CF_Pages_4") />
	<cfset TemplatePaidToDefaultRatesGrid = Evaluate("form.Template_Paid_To_Default_Rates_Grid_4") />
	<cfset structTemplatePaidTo = templateManager.getTemplatePaidToStruct(form)>

	<cfscript>
		stError = StructNew();
		stError.bNameExists = compGrowth.add(
				componentName = form.compName,
				externalID = form.compExternalID,
				operatingGroupId = form.Operating_Group_ID,
				allowanceCodeId = form.Allowance_Code_ID,
				selectedTemplateIdList = form.Template_Select_4,
				Accrual_On = form.Accrual_On,
				Exclude_Brokerage = form.Exclude_Brokerage,
				User_ID = request.AccessStructure.User_ID,
				GLList = form.GLList,
				Deduction_Account = form.Deduction_Account,
				Payment_Account = form.Payment_Account,
				FOB_PayeeType1_DiscountType = form.FOB_PayeeType1_DiscountType,
				FOB_PayeeType2_DiscountType = form.FOB_PayeeType2_DiscountType,
				FOB_PayeeType3_DiscountType = form.FOB_PayeeType3_DiscountType,
				Growth_Percent_Option_ID = form.Growth_Percent_Option,
				Auto_Pay_Net_Of_Cash_Discount= form.Auto_Pay_Net_Of_Cash_Discount,
				Auto_Pay_Net_Of_Freight_Allowance= form.Auto_Pay_Net_Of_Freight_Allowance,
				Auto_Pay_Exclude_Credit_Type= form.Auto_Pay_Exclude_Credit_Type,
				Credit_Type_Select = form.Credit_Type_Select,
				TemplatePaidToDefaultCFPages = TemplatePaidToDefaultCFPages,
				TemplatePaidToDefaultRatesGrid = TemplatePaidToDefaultRatesGrid,
				structTemplatePaidTo = structTemplatePaidTo
				// D58135 ::  Additional Component info displaye inside program START
				,DisplayID = form.displayExternalID
				,DisplayDeductionAccount = form.displayDeductionAccount
				,DisplayPaymentAccount = form.displayPaymentAccount
				// D58135 ::  Additional Component info displaye inside program END
				,ProgramLockTypeID = form.Program_Lock_Type_ID
				,TPO_Field = form.TPO_Field //95126
				,TPO_Rate_Type = form.TPO_Rate_Type //95126
				);

		if(stError.bNameExists NEQ 0 AND stError.bNameExists NEQ 1)
		{
			form.display = "add";
		}
	</cfscript>

<!---/////////////DEACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "deactSel">
 	<cfscript>
		compGrowth.deactivate(form.CID);
	</cfscript>
<!---/////////////DEACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "deact">
	<cfscript>
		compGrowth.deactivate(form.compId);
	</cfscript>
<!---/////////////ACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "actSel">
	<cfscript>
		compGrowth.activate(form.CID);
	</cfscript>
<!---/////////////ACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "act">
	 <cfscript>
		compGrowth.activate(form.compId);
	</cfscript>
<!---/////////////DELETE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "delete">

 	<cfscript>
		compGrowth.delete(form.compId);
	</cfscript>

<!---/////////////UPDATE COMPONENT///////////--->
<cfelseif form.command eq "update">
<!--- Dev Note: drachala; D28881: Update growth component settings to include additional elements  START
Added/Changed: Added 5 Argumnets from Growth_Percent_Option_ID to Credit_Type_Select--->

	<cfset TemplatePaidToDefaultCFPages = Evaluate("form.Template_Paid_To_Default_CF_Pages_4") />
	<cfset TemplatePaidToDefaultRatesGrid = Evaluate("form.Template_Paid_To_Default_Rates_Grid_4") />
	<cfset structTemplatePaidTo = templateManager.getTemplatePaidToStruct(form)>

	<cfscript>
		bNameExists = compGrowth.update(
				compId = form.compId,
				compName = form.compName,
				externalID = form.compExternalID,
				operatingGroupId = form.Operating_Group_ID,
				allowanceCodeId = form.Allowance_Code_ID,
				selectedTemplateIdList = form.Template_Select_4,
				Accrual_On = form.Accrual_On,
				Exclude_Brokerage = form.Exclude_Brokerage,
				User_ID = request.AccessStructure.User_ID,
				GLList = form.GLList,
				Deduction_Account = form.Deduction_Account,
				Payment_Account = form.Payment_Account,
				FOB_PayeeType1_DiscountType = form.FOB_PayeeType1_DiscountType,
				FOB_PayeeType2_DiscountType = form.FOB_PayeeType2_DiscountType,
				FOB_PayeeType3_DiscountType = form.FOB_PayeeType3_DiscountType,
				Growth_Percent_Option_ID = form.Growth_Percent_Option,
				Auto_Pay_Net_Of_Cash_Discount= form.Auto_Pay_Net_Of_Cash_Discount,
				Auto_Pay_Net_Of_Freight_Allowance= form.Auto_Pay_Net_Of_Freight_Allowance,
				Auto_Pay_Exclude_Credit_Type= form.Auto_Pay_Exclude_Credit_Type,
				Credit_Type_Select = form.Credit_Type_Select,
				TemplatePaidToDefaultCFPages = TemplatePaidToDefaultCFPages,
				TemplatePaidToDefaultRatesGrid = TemplatePaidToDefaultRatesGrid,
				structTemplatePaidTo = structTemplatePaidTo
				// D58135 ::  Additional Component info displaye inside program START
				,DisplayID = form.displayExternalID
				,DisplayDeductionAccount = form.displayDeductionAccount
				,DisplayPaymentAccount = form.displayPaymentAccount
				// D58135 ::  Additional Component info displaye inside program END
				,ProgramLockTypeID = form.Program_Lock_Type_ID
				,TPO_Field = form.TPO_Field //95126
				,TPO_Rate_Type = form.TPO_Rate_Type //95126
				);

		if (bNameExists)
		{
			stError = StructNew();
			stError.bNameExists = bNameExists;
			form.display = "edit";
		}
	</cfscript>

<!---/////////////APPLY FOR PROFILES///////////--->
<cfelseif form.command eq "applyProfiles">

	<cfparam name="form.Profiles_ID" default="" />
	<cfset compGrowthProfile.add(form.Profiles_ID, form.compId, form.Visibility) />

</cfif>

<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->
<cfif form.display eq "active">
	<cfscript>
		qGetCompGrowth = compGrowth.getActive();
	</cfscript>
<!---/////////////DISPLAY INACTIVE///////////--->
<cfelseif form.display eq "inActive">
	<cfscript>
		qGetCompGrowth = compGrowth.getInActive();
	</cfscript>
<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">
 	<cfscript>
		qGetCompGrowth = compGrowth.getComp(form.compId);
	</cfscript>
<!---/////////////DISPLAY PROFILES///////////--->
<cfelseif form.display eq "editProfileRestrict">

	<cfscript>

		qGetCompGrowth = compGrowth.getComp(form.compId);
		qGetProfiles = compGrowthProfile.getProfiles();


	</cfscript>
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!--- <cfinclude template="growth_component_header.cfm" /> --->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">

	<cfcase value="active">
		<cfinclude template="growth_component_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="growth_component_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfinclude template="growth_component_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="growth_component_edit.cfm" />
	</cfcase>
<!--- --->
	<cfcase value="editProfileRestrict">
		<cfinclude template="_apply_profile_restriction.cfm" />
	</cfcase>
<!--- --->
</cfswitch>

<cfoutput>
<!---hidden form fields--->
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="compId" type="hidden" value="" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
<cfif IsDefined("listPaidToTypes")>
<input type="hidden" name="listPaidToTypes" value="#listPaidToTypes#">
</cfif>
</cfoutput>
</FORM>

<script>
	function copyComponent(component_name_id,discount_type_id)
	{
		show_loader("COPYING COMPONENT, PLEASE WAIT...");
		$.ajax({type    : "post"
				,url     : "/components/programs/ProgramManager.cfc"
				,dataType: "json"
				,data: { method: "copyComponentFromSettings"
						,component_name_id: component_name_id
						,discount_type_id: discount_type_id
						}
				,success : function (response) {
					/* "response" is the "New Incremental ID" after component copy. Below function
					will take the user to the "component edit screen" for the new component which got created
					after copy.
					*/
					submitDataForm('edit',response);
				}
		});
	}
	function exportAll(){
  	popupInCenter( "/Common_Files/exportAll.cfm?" 	+ "CompType=4"
													+ "&type=Component_Report"
												  	<cfoutput>+ "&friendlyFileName=#urlEncodedFormat('Growth_Component_Report')#"</cfoutput>
													,"", 800, 200 );
	}
</script>

<cfmodule template="/customTags/include.cfm" file_to_include="/program_wizard/component_select_templates_grid_js.js"/>
<div align="center" style="font-size:15px;color:red;font-weight:bold;width:75%" id="msgSave"></div>
<!--- reserve this div for displaying message in long process (e.g. saving changes) --->
</cfmodule>