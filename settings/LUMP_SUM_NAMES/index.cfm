<cfsilent>
<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<cfparam name="form.SortBy" Default="GL_Account" />
<cfparam name="form.Template_Select_3" default="">           <!--- 55711 :: template is no longer required --->

<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "lumpSumComponents"
							selectedIndex = "#selectedIndex#" >

<cfinclude template="/common_files/jQuery.cfm">
<cf_include files="/styles/css-loader.css">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /Script/javascript/default.js" />

<cfmodule template="/customTags/include.cfm" file_to_include="/Common_Files/Delete_Functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/string_functions.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="ls_name_component.js"/>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rebate Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<cfparam name="form.display" 			default="active">
<cfparam name="form.command" 			default="">
<cfparam name="form.returnto" 			default="">
<cfparam name="form.Operating_Group_ID"	default="0">
<cfparam name="form.Allowance_Code_ID"	default="0">
<cfparam name="form.Template_Select"	default="">
<cfparam name="form.samples_related"	default="0">
<cfparam name="form.exclude_from_tpa"	default="0">
<cfparam name="form.Allow_Negative" 	default="0">
<cfparam name="form.Related_to_Equipment" 	default="0">
<cfparam name="form.Equipment_Value" 	default="0"><!--- D37295 Kraft Equipment LS set up --->
<cfparam name="Lump_Sum_Type"	default="0"><!--- D37295 Kraft Equipment LS set up --->
<cfparam name="form.Allow_Broker_Payee" 	default="0">
<cfparam name="form.Visibility" default="0">
<cfparam name="form.Template_Paid_To_Default_Rates_Grid_3" default="">
<cfparam name="form.Template_Paid_To_Default_CF_Pages_3" default="">
<cfparam name="form.GLList"  default="">

<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfparam name="form.displayExternalID" 	default="0">
<cfparam name="form.displayDeductionAccount" 	default="0">
<cfparam name="form.displayPaymentAccount" 	default="0">
<!--- D58135 ::  Additional Component info displaye inside program END--->

<cfparam name="form.TPO_Field"  default="0"><!--- 95126 --->
<cfparam name="form.TPO_Rate_Type"  default="0"><!--- 95126 --->
<cfparam name="form.Planner_Target_Type"  default="0"><!--- 98880 --->

<cfparam name="form.Accrual_Posting_Options" 	default="0">
<cfparam name="form.Manual_LS_Allocation" 	default="0">

<cfscript>
	compRebate = CreateObject("component","components.programs.lump_sum_names.LumpSumNames");
	lumsumCompProfit = CreateObject("component","components.programs.lump_sum_names.LumpSumComponentProfile");
	templateManager = CreateObject("component","components.programs.template.TemplateManager").init();
</cfscript>

<cfset operatingGroupManager = CreateObject("component","components.Operating_Group.OperatingGroupManager").init() />
<cfset operatingGroupOn = operatingGroupManager.operatingGroupOn() />
<cfset operatingGroupLevel = operatingGroupManager.componentMapLevel() />
<cfset allowanceCodeManager = CreateObject("component","components.Operating_Group.AllowanceCodeManager").init() />

<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset ID = LabelComp.getGeneralLabels('Lump Sum External ID')>
<!--- D58135 ::  Additional Component info displaye inside program END --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">
	<!--- D37295 Kraft Equipment LS set up --->

	<cfset TemplatePaidToDefaultCFPages = Evaluate("form.Template_Paid_To_Default_CF_Pages_3") />
	<cfset TemplatePaidToDefaultRatesGrid = Evaluate("form.Template_Paid_To_Default_Rates_Grid_3") />
	<cfset structTemplatePaidTo = templateManager.getTemplatePaidToStruct(form)>

	<cfscript>
		stError = StructNew();
		stError.bNameExists = compRebate.add(form.compName,
												form.compExternalID,
												form.Operating_Group_ID,
												form.Allowance_Code_ID,
												form.Samples_Related,
												form.Template_Select_3,
												request.AccessStructure.User_ID,
												form.GLList,
												form.Deduction_Account,
												form.Payment_Account,
												form.Exclude_From_TPA,
												form.Lump_Sum_Type,
												form.Allow_Negative,
												form.Related_to_Equipment,
												form.Equipment_Value,
												form.Accrual_On,
												form.Allow_Broker_Payee,
												TemplatePaidToDefaultCFPages,
												TemplatePaidToDefaultRatesGrid,
												structTemplatePaidTo
												// D58135 ::  Additional Component info displaye inside program START
												, form.displayExternalID
												, form.displayDeductionAccount
												, form.displayPaymentAccount
												// D58135 ::  Additional Component info displaye inside program END
												, form.Accrual_Posting_Options //62609
												, form.Program_Lock_Type_ID
												, form.TPO_Field //95126
												, form.TPO_Rate_Type //95126
												, form.Planner_Target_Type //98880
												, form.Manual_LS_Allocation // 96456
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
<!--- D37295 Kraft Equipment LS set up --->

	<cfset TemplatePaidToDefaultCFPages = Evaluate("form.Template_Paid_To_Default_CF_Pages_3") />
	<cfset TemplatePaidToDefaultRatesGrid = Evaluate("form.Template_Paid_To_Default_Rates_Grid_3") />
	<cfset structTemplatePaidTo = templateManager.getTemplatePaidToStruct(form)>

	<cfscript>
		bNameExists = compRebate.update(form.compId,
										form.compName,
										form.compExternalID,
										form.Operating_Group_ID,
										form.Allowance_Code_ID,
										form.Samples_Related,
										form.Template_Select_3,
										request.AccessStructure.User_ID,form.GLList,
										form.Deduction_Account,
										form.Payment_Account,
										form.Exclude_From_TPA,
										form.Lump_Sum_Type,
										form.Allow_Negative,
										form.Related_to_Equipment,
										form.Equipment_Value,
										form.Accrual_On,
										form.Allow_Broker_Payee,
										TemplatePaidToDefaultCFPages,
										TemplatePaidToDefaultRatesGrid,
										structTemplatePaidTo
										// D58135 ::  Additional Component info displaye inside program START
										, form.displayExternalID
										, form.displayDeductionAccount
										, form.displayPaymentAccount
										// D58135 ::  Additional Component info displaye inside program END
										, form.Accrual_Posting_Options //62609
										, form.Program_Lock_Type_ID
										, form.TPO_Field //95126
										, form.TPO_Rate_Type //95126
										, form.Planner_Target_Type
										, form.Manual_LS_Allocation //96456
										);
		if (bNameExists)
		{
			stError = StructNew();
			stError.bNameExists = bNameExists;
			form.display = "edit";
		}
	</cfscript>
		
<!---/////////////UPDATE SAMPLE LABEL///////////--->
<cfelseif form.command eq "updateSampleLabel">

	<!---create a new instance of the LumpSumSampleDAO--->
	<cfscript>
		variables.lumpSumSampleDAO = createObject("component","components.programs.lump_sum_names.LumpSumSampleDAO");
	</cfscript>
	<!---loop over the list of sample ids and built collection to pass to the LumpSumSampleDAO--->
	<cfloop list="#form.sampleIds#" index="indx">
		<cfset variables.lumpSampleStructure = structNew() />
		<cfset variables.sampleTypeLabel = evaluate("form.label_#indx#") />

		<cfset structInsert(variables.lumpSampleStructure, "sampleTypeID", indx) />
		<cfset structInsert(variables.lumpSampleStructure, "sampleTypeLabel", trim(variables.sampleTypeLabel)) />
		<cfset arrayAppend(variables.lumpSumSampleDAO.sampleCollection, variables.lumpSampleStructure) />
	</cfloop>

	<cfscript>
		variables.lumpSumSampleDAO.update(variables.lumpSumSampleDAO);
	</cfscript>

<!---/////////////APPLY FOR PROFILES///////////--->
<cfelseif form.command eq "applyProfiles">

	<cfparam name="form.Profiles_ID" default="" />
	<cfset lumsumCompProfit.add(form.Profiles_ID, form.compId, form.Visibility) />

</cfif>

<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->

<cfif form.display eq "active">

	<cfscript>
		qGetCompRebates = compRebate.getActive();
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

<!---/////////////DISPLAY LABEL SAMPLE///////////--->
<cfelseif form.display eq "labelSample">

	<cfscript>
		variables.lumpSumSampleDatas = createObject("component","components.programs.lump_sum_names.LumpSumSampleDAO").get();
	</cfscript>

<!---/////////////DISPLAY PROFILES///////////--->
<cfelseif form.display eq "editProfileRestrict">

	<cfscript>

		qGetCompRebate = compRebate.getComp(form.compId);
		qGetProfiles = lumsumCompProfit.getProfiles();

	</cfscript>

</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!--- <cfinclude template="ls_name_header.cfm" /> --->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!---switch for each action--->
<cfswitch expression="#form.display#">

	<cfcase value="active">
		<cfinclude template="ls_name_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="ls_name_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfinclude template="ls_name_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="ls_name_edit.cfm" />
	</cfcase>

	<cfcase value="labelSample">
		<cfinclude template="ls_name_label_sample.cfm" />
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
  	popupInCenter( "/Common_Files/exportAll.cfm?" 	+ "CompType=3"
													+ "&type=Component_Report"                                              		
												  <cfoutput>	+ "&friendlyFileName=#urlEncodedFormat('Lump_Sum_Component_Report')#"</cfoutput>
													,"", 800, 200 );
	}		
</script>

<cfmodule template="/customTags/include.cfm" file_to_include="/program_wizard/component_select_templates_grid_js.js"/>
<div align="center" style="font-size:15px;color:red;font-weight:bold;width:75%" id="msgSave"></div>
<!--- reserve this div for displaying message in long process (e.g. saving changes) --->
</cfmodule>