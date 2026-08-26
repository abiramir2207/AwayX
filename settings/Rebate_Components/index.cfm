<cfsilent>
<CFPARAM NAME="url.display" 	DEFAULT="active">
<CFPARAM NAME="form.display" 	DEFAULT="#url.display#">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<CFPARAM NAME="form.editMode" 	DEFAULT="0">
<cfparam name="form.Operating_Group_ID" 	default="0">
<cfparam name="form.Allowance_Code_ID" 	default="0">
<cfparam name="form.Required_Effective_Rate_Percent" 	default="0">
<cfparam name="form.Rebate_type" 	default="0">
<cfparam name="form.Interface_as_Rate" 	default="1">
<cfparam name="form.Template_Select" 	default="">
<cfparam name="form.Rebate_Percent_Option" 	default="1">
<cfparam name="form.Rebate_Margin_Percent_Option" 	default="1">
<cfparam name="form.Auto_Pay_Net_Of_Cash_Discount" 	default="0">
<cfparam name="form.Auto_Pay_Net_Of_Freight_Allowance" 	default="0">
<cfparam name="form.Auto_Pay_Exclude_Credit_Type" 	default="0">
<cfparam name="form.Credit_Type_Select" 	default="">
<cfparam name="form.FOB_PayeeType1_DiscountType" 	default="">
<cfparam name="form.FOB_PayeeType2_DiscountType" 	default="">
<cfparam name="form.FOB_PayeeType3_DiscountType" 	default="">
<!--- D38536  :: Alternate recapture rates per component START--->
<cfparam name="form.rate1" 	default="0">
<cfparam name="form.rate2" 	default="0">
<cfparam name="form.rate3" 	default="0">
<cfparam name="form.description1" 	default="">
<cfparam name="form.description2" 	default="">
<cfparam name="form.description3" 	default="">
<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work START--->
<cfparam name="form.Update_BB_Expected_Rate" default="0" >
<cfparam name="form.Expected_Rate" default="0" >
<cfparam name="form.Program_Pays_To" default="0" >
<cfparam name="form.Exclude_From_Recapture" default="0" >
<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END--->
<cfparam name="form.Visibility" default="0">
<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work START--->
<cfparam name="form.Is_Retail" default="0">
<cfparam name="form.Net_Out_of_Fixed_Price" default="0">
<!---D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work END--->
<cfparam name="form.Template_Paid_To_Default_Rates_Grid_2" default="">
<cfparam name="form.Template_Paid_To_Default_CF_Pages_2" default="">

<cfparam name="form.Template_Select_2" default="">           <!--- 55711 :: template is no longer required --->

<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfparam name="form.displayExternalID" 	default="0">
<cfparam name="form.displayDeductionAccount" 	default="0">
<cfparam name="form.displayPaymentAccount" 	default="0">
<!--- D58135 ::  Additional Component info displaye inside program END--->
<cfparam name="form.GLList"  default="">
<cfparam name="form.Include_Second_Component"  default="0">
<cfparam name="form.Second_Component_Name_ID"  default="0">
<cfparam name="form.Second_Component_Payment_Type_ID"  default="0">
<cfparam name="form.Second_Component_GL_Account_ID"  default="0">
<cfparam name="form.Second_Component_Payment_Cycle_ID"  default="0">

<cfparam name="form.TPO_Field"  default="0"><!--- 95126 --->
<cfparam name="form.TPO_Rate_Type"  default="0"><!--- 95126 --->

<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
	<cfcase value="busRule">   <cfset selectedIndex = 3> 	</cfcase>
	<cfcase value="edit">      <cfset selectedIndex = 4> 	</cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "rebateComponents"
							selectedIndex = "#selectedIndex#" >


<cfmodule template="/customTags/include.cfm" file_to_include="/Common_Files/Delete_Functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="rebate_component.js"/>

<!--- D38536  :: Alternate recapture rates per component START--->
<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/styles/css-loader.css">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /Script/javascript/default.js" />
<cfinclude template ="/actionformat.cfm">
<!---D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work --->
			<script>
			function Toggle(type, id) {
						if(type=='show'){
									$('.' + id).show();
						}
						if(type=='hide'){
									$('.' + id).hide();
						}
			    }
			function template(rate,compid,templatesid){
			    window.open ("Template_selection.cfm?discountType=2&fieldname=ExpectedRateTemplateList&rate="+rate+"&compid="+compid+"&templatesid="+templatesid, "Template_selection","location=0,status=0,scrollbars=1,resizable=0, width=850,height=600");
				}
			function templateAlternateRate(rate,compid,templatesid){
			    window.open ("Template_selection.cfm?discountType=2&fieldname=AlternateRateTemplateList&rate="+rate+"&compid="+compid+"&templatesid="+templatesid, "Template_selection","location=0,status=0,scrollbars=1,resizable=0, width=850,height=600");
				}
			</script>
<!--- D38536  :: Alternate recapture rates per component END--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rebate Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<!--- D38536  :: Alternate recapture rates per component END--->
<cfscript>
	compRebate = CreateObject("component","components.programs.rebates.RebateComponent");
	busRule = CreateObject("component", "components.programs.rebates.RebateComponentBusinessRule");
	rebateCompProfit = CreateObject("component","components.programs.rebates.RebateComponentProfile");
	templateManager = CreateObject("component","components.programs.template.TemplateManager").init();
</cfscript>

<cfset operatingGroupManager = CreateObject("component","components.Operating_Group.OperatingGroupManager").init() />
<cfset operatingGroupOn = operatingGroupManager.operatingGroupOn() />
<cfset operatingGroupLevel = operatingGroupManager.componentMapLevel() />
<cfset allowanceCodeManager = CreateObject("component","components.Operating_Group.AllowanceCodeManager").init() />
<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset ID = LabelComp.getGeneralLabels('Rebate External ID')>
<!--- D58135 ::  Additional Component info displaye inside program END --->
<cfset application.oController.getObject(path="mvc.Models.Program.CreditTypeManager",name="CreditTypeManager",bReload= 0) />
<cfset application.oController.getObject(path="mvc.Models.Settings.FOBPriceIndicatorManager",name="FOBPriceIndicatorManager",bReload= 0) />

<!---D79237:  Rebate - OI and Redi START---->
	<cfquery name="qGetPaymentCycles" datasource="#application.datasource#">
		SELECT DISTINCT PC.Payment_Cycle_ID,
						PC.Payment_Cycle
		FROM Payment_Cycle PC
		<cfif application.appsettingsget.get_Setting('Auto_Pay_Use_Calendar_Months') eq '1'>
			WHERE Payment_Cycle_ID NOT IN (10, 11, 12) <!--- Fiscal Month, Fiscal Quarter, Fiscal Year --->
		</cfif>
		ORDER BY Payment_Cycle_ID
	</cfquery>
	<cfquery name="qGetGLs" datasource="#application.datasource#">
		SELECT GL_Account.GL_Account_ID,Gl_Account,Gl_Account_Desc
		FROM GL_Account
		WHERE deleted = 0
		AND Is_Active = 1
		AND LEN(LTRIM(RTRIM(GL_Account))) > 0
		ORDER BY GL_Account.Gl_Account
	</cfquery>
	<cfquery name="GetClaimMechInfo" datasource="#application.datasource#">
		SELECT Payment_Type_ID, Payment_Type_Name
		FROM Payment_Type
		WHERE active = 1
		AND deleted = 0
		AND Is_Auto_Pay = 0
	</cfquery>
<!---D79237:  Rebate - OI and Redi END---->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">

	<cfset TemplatePaidToDefaultCFPages = Evaluate("form.Template_Paid_To_Default_CF_Pages_2") />
	<cfset TemplatePaidToDefaultRatesGrid = Evaluate("form.Template_Paid_To_Default_Rates_Grid_2") />
	<cfset structTemplatePaidTo = templateManager.getTemplatePaidToStruct(form)>

	<cfscript>
		stError = StructNew();

		stError.bNameExists = compRebate.add(
				componentName = form.compName,
				externalID = form.compExternalID,
				Rebate_Percent_Option_ID = form.Rebate_Percent_Option,
				operatingGroupId = form.Operating_Group_ID,
				Rebate_type = form.rebate_type,
				allowanceCodeId = form.Allowance_Code_ID,
				requiredEffectiveRatePercent = form.Required_Effective_Rate_Percent,
				selectedTemplateIdList = form.Template_Select_2,
				Accrual_On = form.Accrual_On,
				Exclude_Brokerage = form.Exclude_Brokerage,
				Off_Invoice_On = form.Off_Invoice_On,
				User_ID = request.AccessStructure.User_ID,
				GLList = form.GLList,
				Rebate_Margin_Percent_Option_ID = form.Rebate_Margin_Percent_Option,
				Interface_as_Rate = form.Interface_as_Rate,
				Deduction_Account = form.Deduction_Account,
				Payment_Account = form.Payment_Account,
				Auto_Pay_Net_Of_Cash_Discount = form.Auto_Pay_Net_Of_Cash_Discount,
				Auto_Pay_Net_Of_Freight_Allowance = form.Auto_Pay_Net_Of_Freight_Allowance,
				Auto_Pay_Exclude_Credit_Type = form.Auto_Pay_Exclude_Credit_Type,
				Credit_Type_Select = form.Credit_Type_Select,
				FOB_PayeeType1_DiscountType = form.FOB_PayeeType1_DiscountType,
				FOB_PayeeType2_DiscountType = form.FOB_PayeeType2_DiscountType,
				FOB_PayeeType3_DiscountType = form.FOB_PayeeType3_DiscountType
				,Recapture_Rate_From_Program_Budget = form.Recapture_Rate_From_Program_Budget
				// D38536  :: Alternate recapture rates per component START
				,Recapture_Rate_From_Program_Budget = form.Recapture_Rate_From_Program_Budget
				,Alternate_Recapture_Rate = form.Alternate_Recapture_Rate
				,rate1= form.rate1
				,rate2= form.rate2
				,rate3= form.rate3
				,description1= form.description1
				,description2= form.description2
				,description3= form.description3
				,AlternateRateTemplateList1=form.AlternateRateTemplateList1
				,AlternateRateTemplateList2=form.AlternateRateTemplateList2
				,AlternateRateTemplateList3=form.AlternateRateTemplateList3
				// D38536  :: Alternate recapture rates per component END
				//D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work START
				,Update_BB_Expected_Rate=form.Update_BB_Expected_Rate
				,Expected_Rate=form.Expected_Rate
				,Program_Pays_To=form.Program_Pays_To
				,Exclude_From_Recapture=form.Exclude_From_Recapture
				,Alternate_Recapture_By_Operator=form.Alternate_Recapture_By_Operator
				//D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END
				//D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work START
				,Is_Retail = form.Is_Retail
				,Net_Out_of_Fixed_Price = form.Net_Out_of_Fixed_Price
				//D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work END
				,TemplatePaidToDefaultCFPages = TemplatePaidToDefaultCFPages
				,TemplatePaidToDefaultRatesGrid = TemplatePaidToDefaultRatesGrid
				,structTemplatePaidTo = structTemplatePaidTo
				// D58135 ::  Additional Component info displaye inside program START
				,DisplayID = form.displayExternalID
				,DisplayDeductionAccount = form.displayDeductionAccount
				,DisplayPaymentAccount = form.displayPaymentAccount
				// D58135 ::  Additional Component info displaye inside program END
				,ProgramLockTypeID = form.Program_Lock_Type_ID
				,Include_Second_Component = form.Include_Second_Component //D79237
				,Second_Component_Name_ID= form.Second_Component_Name_ID //D79237
				,Second_Component_Payment_Type_ID= form.Second_Component_Payment_Type_ID//D79237
				,Second_Component_GL_Account_ID= form.Second_Component_GL_Account_ID
				,Second_Component_Payment_Cycle_ID = form.Second_Component_Payment_Cycle_ID
				,TPO_Field= form.TPO_Field//95126
				,TPO_Rate_Type = form.TPO_Rate_Type//95126
				,Expected_Rate_Affect_Discount_Type = form.Expected_Rate_Affect_Discount_Type //91550
				,Expected_Rate_Apply_All_Templates = form.Expected_Rate_Apply_All_Templates//91550
				,ExpectedRateTemplateList = form.ExpectedRateTemplateList//91550
				);
		if(stError.bNameExists NEQ 0 AND stError.bNameExists NEQ 1)
		{
			form.display = "add";
		}
	</cfscript>

<!---/////////////DEACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "deactSel">

	<cfscript>
		compRebate.deactivate(form.CID);
	</cfscript>

<!---/////////////DEACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "deact">

	<cfscript>
		compRebate.deactivate(form.compId);
	</cfscript>

<!---/////////////ACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "actSel">

	<cfscript>
		compRebate.activate(form.CID);
	</cfscript>

<!---/////////////ACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "act">

	<cfscript>
		compRebate.activate(form.compId);
	</cfscript>

<!---/////////////DELETE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "delete">

	<cfscript>
		compRebate.delete(form.compId);
	</cfscript>

<!---/////////////UPDATE COMPONENT///////////--->
<cfelseif form.command eq "update">

	<cfset TemplatePaidToDefaultCFPages = Evaluate("form.Template_Paid_To_Default_CF_Pages_2") />
	<cfset TemplatePaidToDefaultRatesGrid = Evaluate("form.Template_Paid_To_Default_Rates_Grid_2") />
	<cfset structTemplatePaidTo = templateManager.getTemplatePaidToStruct(form)>

	<cfscript>

		bNameExists = compRebate.update(
				compId = form.compId,
				compName = form.compName,
				externalID = form.compExternalID,
				Rebate_Percent_Option_ID = form.Rebate_Percent_Option,
				operatingGroupId = form.Operating_Group_ID,
				Rebate_type = form.rebate_type,
				allowanceCodeId = form.Allowance_Code_ID,
				requiredEffectiveRatePercent = form.Required_Effective_Rate_Percent,
				selectedTemplateIdList = form.Template_Select_2,
				Accrual_On = form.Accrual_On,
				Exclude_Brokerage = form.Exclude_Brokerage,
				Off_Invoice_On = form.Off_Invoice_On,
				User_ID = request.AccessStructure.User_ID,
				GLList = form.GLList,
				Rebate_Margin_Percent_Option_ID = form.Rebate_Margin_Percent_Option,
				Interface_as_Rate = form.Interface_as_Rate,
				Deduction_Account = form.Deduction_Account,
				Payment_Account = form.Payment_Account,
				Auto_Pay_Net_Of_Cash_Discount = form.Auto_Pay_Net_Of_Cash_Discount,
				Auto_Pay_Net_Of_Freight_Allowance = form.Auto_Pay_Net_Of_Freight_Allowance,
				Auto_Pay_Exclude_Credit_Type = form.Auto_Pay_Exclude_Credit_Type,
				Credit_Type_Select = form.Credit_Type_Select,
				FOB_PayeeType1_DiscountType = form.FOB_PayeeType1_DiscountType,
				FOB_PayeeType2_DiscountType = form.FOB_PayeeType2_DiscountType,
				FOB_PayeeType3_DiscountType = form.FOB_PayeeType3_DiscountType
				// D38536  :: Alternate recapture rates per component START
				,Recapture_Rate_From_Program_Budget = form.Recapture_Rate_From_Program_Budget
				,Alternate_Recapture_Rate = form.Alternate_Recapture_Rate
				,rate1= form.rate1
				,rate2= form.rate2
				,rate3= form.rate3
				,description1= form.description1
				,description2= form.description2
				,description3= form.description3
				,AlternateRateTemplateList1=form.AlternateRateTemplateList1
				,AlternateRateTemplateList2=form.AlternateRateTemplateList2
				,AlternateRateTemplateList3=form.AlternateRateTemplateList3
				// D38536  :: Alternate recapture rates per component END
				//D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work START
				,Update_BB_Expected_Rate=form.Update_BB_Expected_Rate
				,Expected_Rate=form.Expected_Rate
				,Program_Pays_To=form.Program_Pays_To
				,Exclude_From_Recapture=form.Exclude_From_Recapture
				,Alternate_Recapture_By_Operator=form.Alternate_Recapture_By_Operator
				//D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work END
				,Is_Retail = form.Is_Retail
				,Net_Out_of_Fixed_Price = form.Net_Out_of_Fixed_Price
				//D50514 :: Sysco - CF changes needed for enhancement in 45814.  CF Work END
				,TemplatePaidToDefaultCFPages = TemplatePaidToDefaultCFPages
				,TemplatePaidToDefaultRatesGrid = TemplatePaidToDefaultRatesGrid
				,structTemplatePaidTo = structTemplatePaidTo
				// D58135 ::  Additional Component info displaye inside program START
				,DisplayID = form.displayExternalID
				,DisplayDeductionAccount = form.displayDeductionAccount
				,DisplayPaymentAccount = form.displayPaymentAccount
				// D58135 ::  Additional Component info displaye inside program END
				,ProgramLockTypeID = form.Program_Lock_Type_ID
				,Include_Second_Component = form.Include_Second_Component //D79237
				,Second_Component_Name_ID= form.Second_Component_Name_ID //D79237
				,Second_Component_Payment_Type_ID= form.Second_Component_Payment_Type_ID//D79237
				,Second_Component_GL_Account_ID= form.Second_Component_GL_Account_ID
				,Second_Component_Payment_Cycle_ID = form.Second_Component_Payment_Cycle_ID
				,TPO_Field = form.TPO_Field //95126
				,TPO_Rate_Type = form.TPO_Rate_Type //95126
				,Expected_Rate_Affect_Discount_Type = form.Expected_Rate_Affect_Discount_Type //91550
				,Expected_Rate_Apply_All_Templates = form.Expected_Rate_Apply_All_Templates//91550
				,ExpectedRateTemplateList = form.ExpectedRateTemplateList//91550
				);

		if (bNameExists)
		{
			stError = StructNew();
			stError.bNameExists = bNameExists;
			form.display = "edit";
		}
	</cfscript>

<!---/////////////APPLY RULES TO COMPONENT///////////--->
<cfelseif form.command eq "applyRules">

	<cfset busRule.applyRules(form.compId, form.rule_ids, form.required) />

<!---/////////////ADD/UPDATE RULES///////////--->
<cfelseif form.command eq "commitRule">

	<cfset busRule.commitRule(form) />
	<cflocation url="index.cfm?display=busRule" />

<!---/////////////DELETE RULE///////////--->
<cfelseif form.command eq "delRule">

	<cfset busRule.deleteRule(form.ruleId) />

<!---/////////////APPLY FOR PROFILES///////////--->
<cfelseif form.command eq "applyProfiles">

	<cfparam name="form.Profiles_ID" default="" />
	<cfset rebateCompProfit.add(form.Profiles_ID, form.compId, form.Visibility) />

</cfif>

<cfset form.command = "" />


<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->
<cfif form.display eq "active">

	<cfscript>
		qGetCompRebates = compRebate.getActive(get_all_active = 1);
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->
<cfelseif form.display eq "inActive">

	<cfscript>
		qGetCompRebates = compRebate.getInActive();
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">

	<cfscript>
		qGetCompRebates = compRebate.getComp(form.compId);
	</cfscript>

<!---/////////////APPLY BUSINESS RULES///////////--->
<cfelseif form.display eq "applyBusRule">

	<cfscript>
		qGetCompRebate = compRebate.getComp(form.compId);
		qGetCompRules = busRule.getComponentRules(form.compId);
	</cfscript>

<!---/////////////DISPLAY BUSINESS RULES///////////--->
<cfelseif form.display eq "busRule">

	<cfscript>

		qGetRules = busRule.getRules();

		//if editMode is 1 and the ruleId is 0 then we are adding a new rule so add an empty record to the qGetRules query
		if (form.editMode eq 1 and form.ruleId eq 0)
		{
			QueryAddRow(qGetRules);
			QuerySetCell(qGetRules, "Program_Rebates_Component_Rule_ID", 0);
			QuerySetCell(qGetRules, "Unit_Of_Measure_ID", 0);
			QuerySetCell(qGetRules, "Cost_Impact_UOM", 0);
		}

	</cfscript>

<!---/////////////DISPLAY PROFILES///////////--->
<cfelseif form.display eq "editProfileRestrict">

	<cfscript>

		qGetCompRebate = compRebate.getComp(form.compId);
		qGetProfiles = rebateCompProfit.getProfiles();

	</cfscript>

</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">

	<cfcase value="active">
		<cfinclude template="_rebate_component_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="_rebate_component_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfinclude template="_rebate_component_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="_rebate_component_edit.cfm" />
	</cfcase>

	<cfcase value="applyBusRule">
		<cfinclude template="_apply_business_rules.cfm" />
	</cfcase>

	<cfcase value="busRule">
		<cfinclude template="_business_rules.cfm" />
	</cfcase>

	<cfcase value="editProfileRestrict">
		<cfinclude template="_apply_profile_restriction.cfm" />
	</cfcase>

</cfswitch>

<cfoutput>
<!---hidden form fields--->
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="compId" type="hidden" value="" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
<input name="editMode" type="hidden" value=""/>
<input name="ruleId" type="hidden" value="" />
<cfif IsDefined("listPaidToTypes")>
<input type="hidden" name="listPaidToTypes" value="#listPaidToTypes#">
</cfif>
</cfoutput>
</FORM>

<script>
	function showHideAlternateRecapture()
	{
		var alternateRecapture = 0;
		var recaptureByOperator = 0;

		if(document.all.Alternate_Recapture_Rate[1].checked){
			alternateRecapture = 1;
			if(document.all.Alternate_Recapture_By_Operator[1].checked){
				recaptureByOperator = 1;
			}
		}

		if(alternateRecapture){
			//display the check box for recapture By Operator
			//display the first alternate recapture rate row
			Toggle('show','alternateRatesTR1');
			if(recaptureByOperator){
				//hide the template link
				//hide the second and third alternate recapture rate row
				Toggle('hide','alternateRatesTR');
				Toggle('hide','alternateRatesTemplate');

				//uncheck the second and third alternate recapture rate row
				document.all.rate2.checked = false;
				document.all.rate3.checked = false;
			}
			else{
				//display the template link
				//display the second and third alternate recapture rate row
				Toggle('show','alternateRatesTR');
				Toggle('show','alternateRatesTemplate');
			}
		}
		else{
			//hide the check box for recapture By Operator
			//hide the first alternate recapture rate row
			//hide the template link
				//hide the second and third alternate recapture rate row
			Toggle('hide','alternateRatesTR');
			Toggle('hide','alternateRatesTR1');
			Toggle('hide','alternateRatesTemplate');
		}
	}

	function checkNetOutFixedPrice(){

		if (document.all.Is_Retail.checked == false){
			document.all.Net_Out_of_Fixed_Price.checked = false;
			document.all.Net_Out_of_Fixed_Price.disabled = true;
		}
		else{
			document.all.Net_Out_of_Fixed_Price.disabled = false;
		}
	}

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
  	popupInCenter( "/Common_Files/exportAll.cfm?" 	+ "CompType=2"
													+ "&type=Component_Report"
												  <cfoutput>	+ "&friendlyFileName=#urlEncodedFormat('Rebate_Component_Report')#"</cfoutput>
													,"", 800, 200 );
	}
</script>
<cfmodule template="/customTags/include.cfm" file_to_include="/program_wizard/component_select_templates_grid_js.js"/>
<div align="center" style="font-size:15px;color:red;font-weight:bold;width:75%" id="msgSave"></div>
<!--- reserve this div for displaying message in long process (e.g. saving changes) --->
</cfmodule>