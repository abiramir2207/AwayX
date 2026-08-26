<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>

<CFSET PAGE_TITLE= "Product #Application.RebateLabel# Entry">
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>

<cfparam name="url.cid" default="">
<cfparam name="url.bfrommargin" default="0" type="boolean">
<cfparam name="form.bfrommargin" default="#url.bfrommargin#">
<!---default value to tell us if this is the first time in--->
<cfparam name="init" default="">
<cfparam name="compuuid" default="#createuuid()#">
<cfparam name="form.product_list" default="">
<cfparam name="form.sortby" default="item">
<cfparam name="form.sortorder" default="asc">
<cfparam name="form.discount_rebates_item_level" default="0">
<cfparam name="form.discount_rebates_group_level" default="0">
<cfparam name="form.navigate" default="0">
<cfparam name="form.stopnavigate" default="0">
<cfparam name="form.dynamic_static_groups" default="0">
<cfparam name="form.allow_multi_levels" default="0">
<cfparam name="form.action" default="">
<cfparam name="form.donotallowaddproductsde" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="form.price_protection_on" default="0">
<cfparam name="session.group_rebate_type_search_id" default="" >
<cfparam name="form.like_product" default="">
<cfparam name="form.is_like_product_exist" default="0">
<cfparam name="form.treatment_code" default="0">
<cfparam name="form.basis_code" default="0">
<cfparam name="url.eztemplate" default="0">
<cfparam name="ez_rebate_comp_ids" default="">
<cfparam name="form.rate" default="0.0000">
<cfparam name="form.uom" default="0">
<cfparam name="form.vendorselection" default="0">
<cfparam name="form.payee_selection" default="0">
<cfparam name="form.pagenum" default="1">
<cfparam name="form.curpagenum" default="#form.pagenum#">
<cfparam name="form.locate" default="0">
<cfparam name="request.showrebprod" default="1" />
<cfparam name="variables.editcount" default="0" />
<!--- <cfparam name="variables.savebtnaction" default="save" /> --->
<cfset variables.savebtnaction = "updSave" />
<cfparam name="form.sub_product_list" default="" />
<cfparam name="url.maxcomps" default="0" />
<cfparam name="form.compalertcount" default="0" />
<cfparam name="form.isrestrictlowerlevelbasedonlevel1on" 	default="0">
<cfparam name="ez_comp_check" default="0"><!--- d31949:price protection component not appearing --->
<cfparam name="form.productGrouplist" default="" />
<cfparam name="form.ProductsGroupLevels" default="" />
<cfparam name="FORM.currentTxtPercentage"  default="">
<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<cfparam name="form.level_#levels#" default="">
	<cfparam name="form.grouplevel_#levels#" default="">
</cfloop>
<!---77408 Product Group sequencing END--->
<cfif isDefined("form.txtPercentage") AND FORM.txtPercentage NEQ "">
	<cfset FORM.currentTxtPercentage = form.txtPercentage />
</cfif>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfinclude template="/Script/cf/ListCompare.cfm">
<cfparam name="variables.Profile_EzButtonApproveBeyondMaxRate"  default="#Get_Profile_Settings.EzButton_Approve_Beyond_MaxRate#" />
<cfif url.maxComps eq 1>
	<script>
		alert('Exceeds maximum number of component.');
	</script>
</cfif>
<cfset bAutoAddComponent = 0 />

<cfset Latest_EZ_Contract_ID = 0 />

<cfif form.action neq "save">

	<cfheader name="Cache-Control" value="no-store">
	<cfheader name="expires" value="-100">
	<cfset Cache_Control_Header_Already_Added = 1>
	<!--- Must be removed for CFAJAX to work --->
	<!--- <CFINCLUDE template="/includes/call_please_wait.cfm"> --->

</cfif>

<CFSET thisPage=GetFileFromPath(GetCurrentTemplatePath())>
<CFSET fullUrl="">
<cfloop collection=#URL# item="thisURLItem">
	<CFIF thisURLItem NEQ "Sort_By">
		<CFSET fullUrl=ListAppend(fullUrl, "#thisURLItem#=#StructFind(URL, thisURLItem)#","&")>
	</CFIF>
</cfloop>
<CFIF Len(fullUrl) GT 0>
	<CFSET fullUrl="#thisPage#?#fullUrl#&">
<CFELSE>
	<CFSET fullUrl="#thisPage#?">
</CFIF>

<cfparam name="URL.Sort_By" default="Item">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFIF len(trim(URL.CID)) GT 0>

	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

	<!---Call method to get all contract information--->
	<cfscript>

		contract = CreateObject("component", "components.programs.rebates.Contract");
		GetContractInfo = contract.get(cryp.value);

	</cfscript>

	<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID
			,EzButton_Enter_Beyond_Max_Rates<!--- D40141: restore 6.2 logic in 7.1.  Use EZ_button_settings.cfm to  set this property :: D28783: Release 7 EZ Button Max Rate. Allow users to enter beyond max rate always --->
			,EzButton_Default_Show_ITem_Rates
			,EZ_Contract_Id
			,Source
			,Source_Required
			,Source_Type
			,Source_Type_Required
			,Date_Source_Received
			,Date_Source_Received_Required
			,EZButton_On,Discount_Rebate_Max_Rate_On
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
	</cfquery>

	<!---set the sessionFile param--->
	<cfif not isDefined("Form.sessionFile")>
		<!--- <cfset Form.sessionFile = cryp.value & "_" & request.AccessStructure.user_id /> --->
		<cfset Form.sessionFile = CreateUUID() />
	</cfif>


		<!--- D50074 :: Viewing and Editing prior program versions START --->
		<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<!--- D50074 :: Viewing and Editing prior program versions END --->
		<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0 AND URL.EZTemplate EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>
</CFIF>

<!---//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////Controller Section////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---create instances of components--->
<cfscript>
	product = createObject("component","components.programs.rebates.Product");
	comp = createObject("component","components.programs.rebates.RebateComponent");
	compRate = createObject("component","components.programs.rebates.RebateComponentRate");
	rebate = createObject("component","components.programs.rebates.Rebate");
	compBusRule = createObject("component","components.programs.rebates.RebateComponentBusinessRule");
	GroupDataManager = CreateObject("component","components.products.Group.DataManager");
	paymenttypeManager = CreateObject("component","components.programs.payment_type.paymenttype");
	ProdManager = CreateObject("component", "components.products.ProductManager");
	templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
</cfscript>


<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />

<cfset GetSettings = programManager.getProgramTemplateInfo(GetContractInfo.Contract_Main_ID) />
<!--- Initialize AJAX objects --->

<cfmodule template="/CustomTags/wddxAjax/wddxAjax.cfm" ajaxComponent="components.programs.rebates.Rebate"  className="rebateAjax"  async=false>

<cfset Display_Basis_Treatment_Code = 0 />
<cfif isDefined("GetSettings.Include_Treatment_Basis_Code") AND GetSettings.Include_Treatment_Basis_Code EQ 1>
	<cfset Display_Basis_Treatment_Code = 1 />
</cfif>

<cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />
<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0><!--- AND GetSettings.Discount_Rebate_Max_Rate_On  EQ 0---->
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<cfif EzButton_Disable EQ 1>
  <cfif (GetSettings.isDominant EQ 1)>
	<cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />
  <cfelse>
	<cfquery name="qryGetLatestTemplate" datasource="#application.datasource#">
			SELECT TOP 1 EZ_Contract_ID
			FROM Program_Control_Panel_Options
			WHERE First_Parent_ID = #GetSettings.First_Parent_ID#
			and IsDominant =1
			and deleted = 0
			ORDER BY ProgramControl_Panel_Options_ID desc
	</cfquery>
	<cfset Latest_EZ_Contract_ID = qryGetLatestTemplate.EZ_Contract_ID />
  </cfif>

  <cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />
  <cfset GetEZButtonDefaultComp = EZProgramManager.getRebateEZComponents(Latest_EZ_Contract_ID)>
  <cfif GetEZButtonDefaultComp.recordcount GT 0>
	<cfset EZ_Rebate_Comp_Ids = ValueList(GetEZButtonDefaultComp.Program_Rebates_Component_Name_Id)>
  </cfif>
</cfif>
<!--- D31949:Price Protection Component not Appearing START--->
<cfquery name="compcheck" datasource="#application.datasource#">
	SELECT * FROM Program_Rebates_Component WHERE Program_ID = #VAL(Latest_EZ_Contract_ID)#
</cfquery>
<cfset EZ_comp_check = #compcheck.RecordCount#>
<!--- D31949:Price Protection Component not Appearing END--->
<!--- <cfif isdefined("form.Product_List")>
	<cfset Num = ListLen(form.Product_List) />
	<CFIF Num GT rebate.getMaxProducts() or request.showRebProd eq 0>
		<script>
			alert("Processing... " + <cfoutput>#Num#</cfoutput> + " Products.");
		</script>
	</CFIF>
</cfif> --->
<!---if the rebate isn't initialized then we initialize it--->
<cfif not isDefined("form.init")>

  <!---
		Dev Notes: 21553/Anand Rao/04-Mar-10
		HZ - min/max rates for EZ button
  --->

  <cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0 AND (GetSettings.Discount_Rebate_Max_Rate_On EQ 1)>
	<cfscript>
		  templateRebateData = rebate.loadFromDB(programID=Latest_EZ_Contract_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
		</cfscript>
  </cfif>

	<cfscript>
		//rebate.deleteProgramXML(GetContractInfo.Contract_Main_ID);
		//rebate = createObject("component","components.programs.rebates.Rebate");
		//rebateData = rebate.init(GetContractInfo.Contract_Main_ID, Form.sessionFile, displaygrouptype);
		rebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);

	</cfscript>

	<!--- <cfset desRebateData = rebate.getWddxDataFromFile(Form.sessionFile) /> --->
	<cfset desRebateData = rebateData />

	<cfset init = false />
	<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
		<cfparam name="form.rebateSearch" default="*" />
	<CFELSE>
		<cfset form.Rebatesearch = "*"/>
	</CFIF>
	<!--- Search Products --->
	<cfif form.action NEQ "prod" AND form.action NEQ "addProductGroups" >
	<!---- Removing this condition for now, as the dropdown is populating all components and all products --->
		<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData) />
		<cfset variables.editCount = variables.getRebateProdIds.recordcount />
		<cfset form.Sub_Product_List = valuelist(variables.getRebateProdIds.ItemId) />
	</cfif>
	<!--- End Search Products --->

</cfif>

<cfset CSL_Contract_Main_ID = GetContractInfo.Contract_Main_ID />
<cfinclude template="commonqueries.cfm" />


<!--------------------- REMOVE COMPONENTS / REMOVE ALL PRODUCTS --------------------->
<cfif form.action eq "remComp" or form.action eq "remCompAndProd"  or form.action eq "remAllProd">

	<cfif form.action eq "remComp" or form.action eq "remCompAndProd">
		<!---REMOVE COMPONENTS--->
		<cfset removeComponentID = form.comps />

		<!--- Dev Note(79237) - When a 2nd Component (Child of the first component) exists, they are a pair and so if the first component (parent component) is removed, we need to remove the child component (2nd component) too --->
		<cfquery name="getSecondComponent" datasource="#application.datasource#">
			SELECT	Include_Second_Component, Second_Component_Name_ID
			FROM	Program_Rebates_Component rc
			INNER JOIN Program_Rebates_Component_Name cn
			ON 		cn.Program_Rebates_Component_Name_ID = rc.Program_Rebates_Component_Name_ID
			WHERE 	rc.Program_Rebates_Component_ID = #removeComponentID#
		</cfquery>

		<cfset rebate.remComp(CSL_Contract_Main_ID, removeComponentID) />

		<cfif getSecondComponent.Include_Second_Component eq 1 AND getSecondComponent.Second_Component_Name_ID GT 0>
			<cfquery name="getSecondComponentID" datasource="#application.datasource#">
				SELECT	Program_Rebates_Component_ID
				FROM	Program_Rebates_Component rc
				WHERE 	rc.Program_Rebates_Component.Program_ID = #CSL_Contract_Main_ID#
				AND		rc.Program_Rebates_Component_Name_ID = #getSecondComponent.Second_Component_Name_ID#
				AND		rc.Deleted = 0
			</cfquery>

			<cfset rebate.remComp(CSL_Contract_Main_ID, getSecondComponentID.Program_Rebates_Component_ID) />

		</cfif>
	</cfif>

	<!---REMOVE PRODUCTS--->
	<cfif form.action eq "remCompAndProd" or form.action eq "remAllProd">
		<cfscript>
			arDelete = ArrayNew(1);
			arDelete[1] = CSL_Contract_Main_ID; //programId
			arDelete[2] = ""; // action
			arDelete[3] = 0; // bAutoAddComponent
			rebate.deleteAllProductsFromProgram (arDelete);
		</cfscript>
	</cfif>

	<CFLOCATION url="Contract_Discount_Rebates.cfm?CID=#URL.CID#&EZTemplate=#URL.EZTemplate#">

</cfif>

<!---ADD COMPONENTS--->
<cfif form.action eq "comp">

	<!--- Dev Note(79237) - When a 2nd Component (Child of the first component) exists, we need to make sure that the "paid to", Rate and UOM of the 2nd component matches the first component --->
	<cfquery name="getSecondComponent" datasource="#application.datasource#">
		SELECT	Include_Second_Component,Second_Component_Name_ID,Second_Component_Payment_Type_ID,Second_Component_GL_Account_ID,Second_Component_Payment_Cycle_ID, Is_USDA_NOI_Comp
		FROM	Program_Rebates_Component_Name
		WHERE	Program_Rebates_Component_Name_ID = #form.compNameId#
	</cfquery>

	<!--- If this condition is not satisfied, it will go to the bottom "comp" section which requires loadfromDB --->
	<cfif getsettings.EZButton_On EQ 0 AND getSecondComponent.Is_USDA_NOI_Comp EQ 0 AND Display_Basis_Treatment_Code EQ 0 AND appSettings.get_Setting('Percentage_Of_List_Price') NEQ '1'>

		<cfquery name="getExistingComponent" datasource="#application.datasource#">
			SELECT	1
			FROM	Program_Rebates_Component rc
			WHERE 	rc.Program_ID = #CSL_Contract_Main_ID#
			AND		rc.Program_Rebates_Component_Name_ID = #getSecondComponent.Second_Component_Name_ID#
			AND		rc.Deleted = 0
		</cfquery>

		<cfif isNumeric(appSettings.getRebateMaxComponents()) and (getExistingComponent.recordCount gte appSettings.getRebateMaxComponents())>
			<CFLOCATION url="Contract_Discount_Rebates.cfm?CID=#URL.CID#&EZTemplate=#URL.EZTemplate#&maxComps=1">
			<cfabort />
		</cfif>

		<cfscript>
			rebate.liteAddComponent(programId = CSL_Contract_Main_ID,
					formScope = form,
					componentNameId = form.compNameId);

		if(getSecondComponent.Include_Second_Component EQ 1 AND getSecondComponent.Second_Component_Name_ID GT 0){
			form.compNameId = getSecondComponent.Second_Component_Name_ID; /* From the 2nd component dropdown */
			form.compUUID = createuuid();
			form.Component_Paid_To = form.Component_Paid_To;  /* same as first component */
			form.GL_Account_ID = getSecondComponent.Second_Component_GL_Account_ID;		/* From the 2nd component dropdown */
			form.PaymentCycle = getSecondComponent.Second_Component_Payment_Cycle_ID;	/* From the 2nd component dropdown */
			form.Claim_Mechanics = getSecondComponent.Second_Component_Payment_Type_ID; /* From the 2nd component dropdown */
			form.rate = form.rate; /* same as first component */
			form.uom = form.uom;  /* same as first component */
			form.VendorSelection = 0; /* currently, we cannot create a auto pay component as a second component */
			form.Payee_Selection = 0; /* currently, we cannot create a auto pay component as a second component */

			/* Dev Note(79237) - Add the 2nd component */
			desRebateData = rebate.liteAddComponent(programId = CSL_Contract_Main_ID,
					formScope = form,
					componentNameId = form.compNameId);
		}
		</cfscript>

		<CFLOCATION url="Contract_Discount_Rebates.cfm?CID=#URL.CID#&EZTemplate=#URL.EZTemplate#">

	</cfif>


</cfif>

<!--- D27179:Remove step 2 of fixed and rebate if only one component and one selection
1. If template have Single_Component_Per_Discount_Type = 1
2. Template has a default payment cycle
3. GL Account is OFF
4. Template has rebate components
First rebate component has a claim mechanics which is not auto pay
--->
<cfset iAutoAddComponentNameId = 0 />
<cfset iAutoAddClaimMechOption = 0 />
<cfset iAutoAddDefaultComponentPaidTo = 0 />
<cfif (CSLGetContractInfo.Single_Component_Per_Discount_Type
	and GetSettings.PayCycleDefaultOption neq 0
	and not (appSettings.getGL_Account_On() AND appSettings.getGL_Account_Required_for_Comp()))
	OR (url.EZTemplate)
	> <!--- Rules 1, 2, 3 ---><!--- D31949:Price Protection Component not Appearing --->
	<!--- Get top 1 component --->
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 2, 1) />
	<cfset arComponentAllowList = ArrayNew(1)>
	<cfset arComponentAllowList[1] = ValueList(qComponents.Component_ID) />
	<cfscript>
		qGetActiveComps = comp.getActive(
				profileId=request.AccessStructure.Profiles_ID,
				isUSDA=0,
				Price_Protection_on=getSettings.Price_Protection_on,
				arAllowList=arComponentAllowList,
				ProgramID = GetContractInfo.Contract_Main_ID
				);
			/*
			D31949:Price Protection Component not Appearing.
			THIS TWO ATTRIBUTES ARE COMMENT OUT TO PREVENT FILTERING REBATE COMPONENTS BASED ON EZ RATE.
			,
			EzButton_Disable = EzButton_Disable,
			GetEZButtonComp = EZ_Rebate_Comp_Ids);*/
	</cfscript>

	<cfif qGetActiveComps.recordCount gt 0><!--- Rule 4 --->

		<cfset iAutoAddComponentNameId = qGetActiveComps.Program_Rebates_Component_Name_ID />
		<cfset qryAutoAddDefaultComponentPaidTo = templateManager.getDiscountComponentDefaultPaidTo(GetContractInfo.ProgramType_ID,2,iAutoAddComponentNameId) />
		<cfset iAutoAddDefaultComponentPaidTo = qryAutoAddDefaultComponentPaidTo.Default_Paid_To_CF_Pages>


		<!--- 2. Check if the component has a claim mechanics --->
		<cfset CompDetails = CreateObject("component","components.programcomponents.programcomponents").GetComponentDetails(iAutoAddComponentNameId, 2)>
		<cfset qGetPaymentTypesforTemplate = CreateObject("component", "components.programs.payment_type.paymenttype").GetPaymentTypesforTemplate(
			Template_ID = GetSettings.ProgramControl_Panel_Options_ID,
			Discount_Type_ID = 2,
			Component_Name_ID = iAutoAddComponentNameId,
			Allow_Off_Invoice = CompDetails.Off_Invoice_On,
			Allow_Auto_Payment = 0 <!--- Allow_Auto_Payment is passed as 0 purposely, if the only claim mech available is auto pay, we want user to manually select as payee selection may be involved --->
			) >
		<!--- check if default claim mechanics is not auto pay which requires payee selection --->
		<cfif qGetPaymentTypesforTemplate.recordCount>
			<cfset bAutoAddComponent = 1 />
			<cfset iAutoAddClaimMechOption = qGetPaymentTypesforTemplate.Payment_Type_ID />
		</cfif>
	</cfif>
</cfif>


<!---if inits defined then we have a data structure to read and write to--->
<cfif isDefined("form.init")>

	<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0 AND (GetSettings.Discount_Rebate_Max_Rate_On EQ 1)>
		<cfscript>
			 templateRebateData = rebate.loadFromDB(programID=Latest_EZ_Contract_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID);
		 </cfscript>
	 </cfif>

	<!---first get data from data structure stored on disk--->
	<!--- <cfset desRebateData = rebate.getWddxDataFromFile(Form.sessionFile) /> --->
	<cfscript>
		rebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
	</cfscript>

	<cfset desRebateData = rebateData />
	<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
		<cfparam name="form.rebateSearch" default="" />
	<CFELSE>
		<cfset form.Rebatesearch = "*"/>
	</CFIF>

	<!--- Search Products --->
	<cfif form.action neq "prod">
		<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData) />
		<cfset variables.editCount = variables.getRebateProdIds.recordcount />
		<cfset form.Sub_Product_List = valuelist(variables.getRebateProdIds.ItemId) />
	</cfif>
	<!--- End Search Products --->

	<cfif isDefined("form.action")>
		<!---ADD ALL PRODUCTS--->
		<cfif form.action eq "addGroupProducts">
			<cfif ProductGroupManager.allowSelectAllProducts(2, GetContractInfo.Contract_Main_ID) and Len(form.Product_Level_1) GT 0>
				<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
				<cfset form.Product_List = groupLevelProductId />
				<cfset form.action = "prod" />
			</cfif>
		</cfif>
	</cfif>

	<!---update the data structure with what's in the form scope to maintain state--->
	<cfif form.action EQ "updSave">

		<cfscript>
			desRebateData = rebate.update(
							programID = GetContractInfo.Contract_Main_ID,
							aProd = desRebateData.aProd,
							aComp = desRebateData.aComp,
							aCompVal = desRebateData.aCompVal,
							form = form,
							aGroupLevel = desRebateData.aGroupLevel,
							action = form.action);
		</cfscript>
		<cfif url.EZTemplate eq 1>
			<!--- D28783: Release 7 EZ Button Max Rate
			Run capture routine for ez contract inside the template
			--->
			<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#GetContractInfo.Contract_Main_ID#" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@From_EZ_Template" value = "1" null="no">
			</cfstoredproc>
		</cfif>

		<cfscript>
			desRebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
		</cfscript>


	</cfif>

	<!---if action is defined then handle for each action--->
	<cfif isDefined("form.action")>
		<!---ADD group products--->
		<cfif form.action eq "addProductGroups">

			<cfset GroupManager = CreateObject("component", "components.products.Group.GroupManager") />
			<cfset objGroupManager = GroupManager.set(form,GetTemplateInfo.First_Parent_ID) />

			<cfset desRebateData =  rebate.setGroups(	desRebateData,
														form.Product_List,
														GetContractInfo.Contract_Main_ID,
														objGroupManager,
														form.Level_3,
														url.EZTemplate,
														Latest_EZ_Contract_ID,
														GetSettings.Discount_Rebate_Max_Rate_On) />

			<cfif (bAutoAddComponent and not ArrayLen(desRebateData.aCompVal)) OR (url.EZTemplate AND EZ_comp_check EQ 0 AND (IsDefined("EZ_Button_Rate_ID")) AND ArrayLen(desRebateData.aComp) EQ 0 )><!--- D31949:Price Protection Component not Appearing --->

				<cfscript>
				form.rate = 0.00;
				form.UOM = 0;
				form.compNameId = iAutoAddComponentNameId;
				//form.compUUID
				form.Component_Paid_To = iAutoAddDefaultComponentPaidTo;
				//form.GL_Account_ID
				form.Vendor_Master_ID = 0;
				form.PaymentCycle = GetSettings.PayCycleDefaultOption;
				form.Claim_Mechanics = iAutoAddClaimMechOption;
				//form.VendorSelection,
				//form.Payee_Selection
				desRebateData = rebate.addComp(desRebateData,form,GetContractInfo.Contract_Main_ID, form.IsRestrictLowerLevelBasedonLevel1On, url.EZTemplate, GetSettings.Discount_Rebate_Max_Rate_On,  GetSettings.EZBUTTON_ENTER_BEYOND_MAX_RATES );
				</cfscript>

			</cfif>

			<cfset rebate.commit(
						rebateData = desRebateData,
						fileName = Form.sessionFile,
						dynStatGroup = form.Dynamic_Static_Groups,
						Display_Basis_Treatment_Code = Display_Basis_Treatment_Code) />

		 	<!---77408 Product Group sequencing START--->
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				<!--- BELOW FUNCTION WILL UPDATE LEVELS CORRECTLY--->
				<cfset oProgram = CreateObject("component", "components.programs.program").UpdateProductsPricingLevel(contract_main_id = GetContractInfo.Contract_Main_ID, Product_Type_ID = 2)>
			</cfif>
			<!---77408 Product Group sequencing END--->

			<cfscript>
				desRebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
			</cfscript>

			<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
				<cfset form.Rebatesearch = ""/>
			<CFELSE>
				<cfset form.Rebatesearch = "*"/>
			</CFIF>

		<cfif ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts()>
			<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData,listCompare(PRODUCT_LIST,EXISTINGPRODUCTLIST)) />
		<cfelse>
			<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData) />
		</cfif>

			<cfset variables.editCount = variables.getRebateProdIds.recordcount />
			<cfset form.Sub_Product_List = valuelist(variables.getRebateProdIds.ItemId) />
		</cfif>

		<!--- ADD PRODUCTS - TYPE 2 to handle for products at more than 1 levels --->
			<cfif form.action eq "prodlevel2" OR form.action eq "prodlevel3" OR form.action eq "prodlevel4" OR form.action eq "prodlevel5" OR form.action eq "prodlevel6" OR form.action eq "prodlevel7" OR form.action eq "prodlevel8">

			<!------ In this case, compile the product list from level_1, level_2 and level_3 ----->
			<cfset form.Product_List = "" />

			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				<cfset form.Product_List = ListAppend(form.Product_List, form["Level_#levels#"], ",") />

			<cfif form.action eq "prodlevel#levels#">
				<cfset "form.GroupLevel_#levels#" = "9" />
			</cfif>
			</cfloop>

<cfif ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts()>

	<cfset rebate.liteAddProducts (GetContractInfo.Contract_Main_ID, #listCompare(Form.PRODUCT_LIST,Form.EXISTINGPRODUCTLIST)#, form.Dynamic_Static_Groups)>
			<cfscript>
				desRebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
			</cfscript>
	<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData, listCompare(PRODUCT_LIST,EXISTINGPRODUCTLIST)) />

<cfelse>

			<cfset desRebateData = rebate.addProd(	stDataStructure=desRebateData,
													lProdList=form.Product_List,
													contractMainID=GetContractInfo.Contract_Main_ID,
													group_rebate_type_search_id=session.group_rebate_type_search_id,
													level3List=form.Level_8,
													displayGroupType=displayGroupType,
													EZTemplate=url.EZTemplate,
													Ez_Contract_Id = Latest_EZ_Contract_ID,
													EZMaxRateOn = GetSettings.Discount_Rebate_Max_Rate_On) />


			<cfif (bAutoAddComponent and not ArrayLen(desRebateData.aCompVal)) OR (url.EZTemplate and EZ_comp_check EQ 0 AND (IsDefined("EZ_Button_Rate_ID")) AND ArrayLen(desRebateData.aComp) EQ 0)><!--- D31949:Price Protection Component not Appearing --->

				<cfscript>
				form.rate = 0.00;
				form.UOM = 0;
				form.compNameId = iAutoAddComponentNameId;
				//form.compUUID
				form.Component_Paid_To = iAutoAddDefaultComponentPaidTo;
				//form.GL_Account_ID
				form.Vendor_Master_ID = 0;
				form.PaymentCycle = GetSettings.PayCycleDefaultOption;
				form.Claim_Mechanics = iAutoAddClaimMechOption;
				//form.VendorSelection,
				//form.Payee_Selection
				desRebateData = rebate.addComp(desRebateData,form,GetContractInfo.Contract_Main_ID, form.IsRestrictLowerLevelBasedonLevel1On, url.EZTemplate, GetSettings.Discount_Rebate_Max_Rate_On,  GetSettings.EZBUTTON_ENTER_BEYOND_MAX_RATES );
				</cfscript>

			</cfif>


			<cfset rebate.commit(
						rebateData = desRebateData,
						fileName = Form.sessionFile,
						dynStatGroup = form.Dynamic_Static_Groups,
						Display_Basis_Treatment_Code = Display_Basis_Treatment_Code) />

		 	<!---77408 Product Group sequencing START--->
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				<!--- BELOW FUNCTION WILL UPDATE LEVELS CORRECTLY--->
				<cfset oProgram = CreateObject("component", "components.programs.program").UpdateProductsPricingLevel(contract_main_id = GetContractInfo.Contract_Main_ID, Product_Type_ID = 2)>
			</cfif>
			<!---77408 Product Group sequencing END--->

			<cfscript>
				desRebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
			</cfscript>

			<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
				<cfset form.Rebatesearch = ""/>
			<CFELSE>
				<cfset form.Rebatesearch = "*"/>
			</CFIF>


				<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData) />

</CFIF>

			<cfset variables.editCount = variables.getRebateProdIds.recordcount />
			<cfset form.Sub_Product_List = valuelist(variables.getRebateProdIds.ItemId) />
		</cfif>

		<!---ADD PRODUCTS--->
		<cfif form.action eq "prod">




			<!---make Product_List distinct --->
			<cfif Len(trim(form.Product_List))>
				<cfset variables.tempProductStruct = structNew() />
				<cfloop index="indxList" list="#form.Product_List#">
					<cfset structInsert(variables.tempProductStruct, indxList, "", "true") />
				</cfloop>
				<cfset form.Product_List = StructKeyList(variables.tempProductStruct) />
			</cfif>

			<cfset desRebateData = rebate.addProd(stDataStructure=desRebateData,
													lProdList=form.Product_List,
													contractMainID=GetContractInfo.Contract_Main_ID,
													group_rebate_type_search_id=session.group_rebate_type_search_id,
													level3List="",
													displayGroupType=displayGroupType,
													EZTemplate=url.EZTemplate,
													Ez_Contract_Id = Latest_EZ_Contract_ID,
													EZMaxRateOn = GetSettings.Discount_Rebate_Max_Rate_On) />


			<cfif (bAutoAddComponent and not ArrayLen(desRebateData.aCompVal)) OR (url.EZTemplate and EZ_comp_check EQ 0 AND (IsDefined("EZ_Button_Rate_ID")) AND ArrayLen(desRebateData.aComp) EQ 0)><!--- D31949:Price Protection Component not Appearing --->

				<cfscript>
				form.rate = 0.00;
				form.UOM = 0;
				form.compNameId = iAutoAddComponentNameId;
				//form.compUUID
				form.Component_Paid_To = iAutoAddDefaultComponentPaidTo;
				//form.GL_Account_ID
				form.Vendor_Master_ID = 0;
				form.PaymentCycle = GetSettings.PayCycleDefaultOption;
				form.Claim_Mechanics = iAutoAddClaimMechOption;
				//form.VendorSelection,
				//form.Payee_Selection
				desRebateData = rebate.addComp(desRebateData,form,GetContractInfo.Contract_Main_ID, form.IsRestrictLowerLevelBasedonLevel1On, url.EZTemplate, GetSettings.Discount_Rebate_Max_Rate_On,  GetSettings.EZBUTTON_ENTER_BEYOND_MAX_RATES );
				</cfscript>

			</cfif>


		<cfif ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts()>
			<cfset rebate.liteAddProducts (GetContractInfo.Contract_Main_ID, #listCompare(Form.PRODUCT_LIST,Form.EXISTINGPRODUCTLIST)#, form.Dynamic_Static_Groups)>
		<cfelse>

			<!---  Commit data since we do not display all of it in form --->
			<!--- <CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>--->
			<cfset rebate.commit(
						rebateData = desRebateData,
						fileName = Form.sessionFile,
						dynStatGroup = form.Dynamic_Static_Groups,
						Display_Basis_Treatment_Code = Display_Basis_Treatment_Code) />
			<!--- </CFIF> --->
		</cfif>


		 	<!---77408 Product Group sequencing START--->
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				<!--- BELOW FUNCTION WILL UPDATE LEVELS CORRECTLY--->
				<cfset oProgram = CreateObject("component", "components.programs.program").UpdateProductsPricingLevel(contract_main_id = GetContractInfo.Contract_Main_ID, Product_Type_ID = 2)>
			</cfif>
			<!---77408 Product Group sequencing END--->

			<cfscript>
				desRebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID, EZTemplate=URL.EZTemplate);
			</cfscript>


			<CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0>
				<cfset form.Rebatesearch = ""/>
			<CFELSE>
				<cfset form.Rebatesearch = "*"/>
			</CFIF>

			<cfif ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts()>
			<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData, listCompare(PRODUCT_LIST,EXISTINGPRODUCTLIST)) />
			<cfelse>
			<cfset variables.getRebateProdIds = createObject("component","components.Programs.Rebates.RebateData").getRebateData(form.Rebatesearch,desRebateData) />
			</cfif>

			<cfset variables.editCount = variables.getRebateProdIds.recordcount />
			<cfset form.Sub_Product_List = valuelist(variables.getRebateProdIds.ItemId) />

		</cfif>

		<!--- (Dev Note: Milan; D7226) Delete previous products only if the same product existed in rebate discount type --->
			<cfif form.Is_Like_Product_Exist eq 1>
					<cfloop list="#Product_List#" index="Prod">
						<cfset Existing_LikeProduct = ProdManager.getSimilarExistingProduct(GetContractInfo.Contract_Main_ID, '#Prod#')>
							<cfif Existing_LikeProduct.Recordcount neq 0>
								<cfset ProdManager.setDeleteSimilarExistingProduct(GetContractInfo.Contract_Main_ID,'#Prod#')>
							</cfif>
					</cfloop>

					<!--- Add Products (These products are generic and not related to any discount type) --->
						<cfloop list="#form.Like_Product#" index="LikeProd">
									<cfset ProdManager.setSimilarExistingProduct(GetContractInfo.Contract_Main_ID,'#LikeProd#')>
						</cfloop>
			</cfif>
<!--- End Note: Milan; D7226 --->

		<!---ADD COMPONENTS--->
		<cfif form.action eq "comp">

			<cfparam name="form.IsRestrictLowerLevelBasedonLevel1On" 	default="0">
			<cfif isNumeric(appSettings.getRebateMaxComponents()) and (arrayLen(desRebateData.aComp) gte appSettings.getRebateMaxComponents())>
				<CFLOCATION url="Contract_Discount_Rebates.cfm?CID=#URL.CID#&EZTemplate=#URL.EZTemplate#&maxComps=1">
				<cfabort />
			</cfif>

			<!--- Dev Note(79237) - When a 2nd Component (Child of the first component) exists, we need to make sure that the "paid to", Rate and UOM of the 2nd component matches the first component --->
			<cfquery name="getSecondComponent" datasource="#application.datasource#">
				SELECT	Include_Second_Component,Second_Component_Name_ID,Second_Component_Payment_Type_ID,Second_Component_GL_Account_ID,Second_Component_Payment_Cycle_ID
				FROM	Program_Rebates_Component_Name
				WHERE	Program_Rebates_Component_Name_ID = #form.compNameId#
			</cfquery>

			<cfscript>
				desRebateData = rebate.addComp(desRebateData,form,GetContractInfo.Contract_Main_ID, form.IsRestrictLowerLevelBasedonLevel1On, url.EZTemplate, GetSettings.Discount_Rebate_Max_Rate_On,  GetSettings.EZBUTTON_ENTER_BEYOND_MAX_RATES);

			if(getSecondComponent.Include_Second_Component EQ 1 AND getSecondComponent.Second_Component_Name_ID GT 0){
				form.compNameId = getSecondComponent.Second_Component_Name_ID; /* From the 2nd component dropdown */
				form.compUUID = createuuid();
				form.Component_Paid_To = form.Component_Paid_To;  /* same as first component */
				form.GL_Account_ID = getSecondComponent.Second_Component_GL_Account_ID;		/* From the 2nd component dropdown */
				form.PaymentCycle = getSecondComponent.Second_Component_Payment_Cycle_ID;	/* From the 2nd component dropdown */
				form.Claim_Mechanics = getSecondComponent.Second_Component_Payment_Type_ID; /* From the 2nd component dropdown */
				form.rate = form.rate; /* same as first component */
				form.uom = form.uom;  /* same as first component */
				form.VendorSelection = 0; /* currently, we cannot create a auto pay component as a second component */
				form.Payee_Selection = 0; /* currently, we cannot create a auto pay component as a second component */

				/* Dev Note(79237) - Add the 2nd component */
				desRebateData = rebate.addComp(desRebateData,form,GetContractInfo.Contract_Main_ID, form.IsRestrictLowerLevelBasedonLevel1On, url.EZTemplate, GetSettings.Discount_Rebate_Max_Rate_On,  GetSettings.EZBUTTON_ENTER_BEYOND_MAX_RATES);

			}
			</cfscript>

			 <cfset rebate.commit(
						rebateData = desRebateData,
						fileName = Form.sessionFile,
						dynStatGroup = form.Dynamic_Static_Groups,
						Display_Basis_Treatment_Code = Display_Basis_Treatment_Code) />

			 <CFLOCATION url="Contract_Discount_Rebates.cfm?CID=#URL.CID#&EZTemplate=#URL.EZTemplate#">
			<!---
			<cfscript>
				desRebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID);
			</cfscript>
			--->
		</cfif>


		<!---REMOVE PRODUCTS--->
		<cfif form.action eq "remProd">

<!--- 			<cfif ArrayLen(desRebateData.aProd) EQ 0 AND isdefined("form.comps") and trim(form.comps) NEQ "">
				<cfscript>
					desRebateData = rebate.remComp(desRebateData,form.comps);
				</cfscript>
			</cfif> --->

			<cfscript>
				desRebateData = rebate.remProd(desRebateData,form.Product_List);
			</cfscript>
			<!---flush the level and group level variables, they get rebuilt in the display loop--->
			<!---77408 Product Group sequencing START--->
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				<cfset 'form.Level_#levels#' = "" />
				<cfset 'form.GroupLevel_#levels#' = "" />
			</cfloop>
			<!---77408 Product Group sequencing END--->
		</cfif>

		<!---APPLY VOLUME--->
<!--- 		<cfif form.action eq "appVol">

			<cfscript>
				desRebateData = rebate.applyVol(desRebateData,form.applyVol,form.volume);
			</cfscript>

		</cfif> --->

		<!---APPLY RATE TO COMPONENT PRODUCT COMBINATION--->
		<cfif form.action eq "appVolComp">

			<cfset ar_massApply_check = arraynew(1)>

			<cfparam name="form.apply_basis_code_quantity" 					default="">
			<cfparam name="form.apply_basis_code_quantity_uom" 		default="">
			<cfparam name="form.apply_basis_code_free_goods" 			default="">
			<cfparam name="form.apply_effective_margin_Percent" 		default="">

 			<cfscript>
				desRebateData = rebate.applyVolComp(
												stDataStructure = desRebateData,
												lProd = form.applyVol,
												lComp = form.comps,
												rate = form.apply_rate,
												uom = form.apply_uom,
												apply_basis_code_quantity = form.apply_basis_code_quantity,
												apply_basis_code_quantity_uom = form.apply_basis_code_quantity_uom,
												apply_basis_code_free_goods = form.apply_basis_code_free_goods,
												Display_Basis_Treatment_Code = Display_Basis_Treatment_Code,
												apply_effective_margin_Percent = form.apply_effective_margin_Percent,
												action ='updSave',
												EZMaxRateOn = GetSettings.Discount_Rebate_Max_Rate_On,
												EZbutton = GetSettings.EZBUTTON_ON,
												EZTemplate=URL.EZTemplate,
												EZABOVEMaxRateOn = GetSettings.EzButton_Enter_Beyond_Max_Rates,
												fromMassApply= 1 //D38846 ::  Recapture changes
												,RevisonUOMDisable = form.Revison_UOM_Disable
												);
			</cfscript>
			<!--- <CFIF ArrayLen(desRebateData.aProd) GT rebate.getMaxProducts() or request.showRebProd eq 0><!---  Commit data since we do not display all of it in form --->
				<cfset rebate.commit(
						rebateData = desRebateData,
						fileName = Form.sessionFile,
						dynStatGroup = form.Dynamic_Static_Groups,
						Display_Basis_Treatment_Code = Display_Basis_Treatment_Code) />
			</CFIF>
 --->
<!--- D38846 ::  Recapture changes START --->
<cfscript>
	ARMassApply = rebate.InsertMassApplyAlternateRates(
									stDataStructure = desRebateData,
									ThisForm = form
									);
</cfscript>
<!--- D38846 ::  Recapture changes END --->
		</cfif>

		<!---SORTING--->
		<cfif form.action eq "upc" or form.action eq "item" or form.action eq "description" or form.action eq "GroupID">

			<cfscript>
				if (ArrayLen(desRebateData.aProd))
				{
					desRebateData = rebate.sort(desRebateData,form.sortBy,form.sortOrder);
				}
			</cfscript>

		</cfif>

		<!---SAVE--->
		<cfif form.action eq "save" or (form.action eq "updSave" and form.locate eq 1)>
			<!--- lock checker --->
			<CF_Cryp type="en" key="#request.key#" string="#desRebateData.programId#">
			<cfif url.EZTemplate EQ 0>
				<CFSET LockChecker_CID  = GetContractInfo.Contract_Main_ID >
				<CFINCLUDE TEMPLATE="LockChecker.cfm">
			</cfif>

			<!---commit to database--->
			<!------  remove any products that may have been removed by DHTML ----->
			<!--- <cfset desRebateData = rebate.remProd(desRebateData,form.Product_List) /> --->
			<cfif form.action eq "save"> <!--- upd save already saves data --->
				<cfset rebate.commit(
						rebateData = desRebateData,
						fileName = Form.sessionFile,
						dynStatGroup = form.Dynamic_Static_Groups,
						Display_Basis_Treatment_Code = Display_Basis_Treatment_Code) />


			</cfif>
			<!---now redirect--->
			<cfscript>
				getProgramType = contract.getProgramId(desRebateData.programId);
			</cfscript>

			<cfif form.deletedateexclusions EQ 1>

				<cfif GetSettings.Date_Exclusions_ON EQ 1>
					<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
					<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(desRebateData.programId,0)>
					<cfif form.deletedateexclusions EQ 1>
						<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
						<cfquery name="deletedateexclusions" datasource="#application.datasource#">
							update contract_main
							set deleted = 1
							where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
						</cfquery>
						<cfquery name="deletedateexclusions" datasource="#application.datasource#">
							update program_exclusions
							set deleted = 1
							where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
						</cfquery>
						</CFIF>
					</cfif>
				</cfif>
			</cfif>

			<cfif form.bFromMargin>
				<script>
					window.close();
					window.opener.location.reload();
				</script>
				<cfabort />
			</cfif>
			<!------ Start Clause Code ----->
			<cfset discountTypeId = 2>
			<cfset programId = desRebateData.programId>
			<cfset templateId = getProgramType.ProgramType_ID>
			<cfset addClauseMode = ArrayLen(desRebateData.aProd) NEQ 0>
			<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
			<!------ End  Clause Code ----->
		<cfif url.EZTemplate EQ 0>
			<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
			<CFSET redirector_FromPage_ID = 6>
			<cfinclude template="internal_redirector_based_on_settings.cfm">
			<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.value#">
			<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
			<CFLOCATION url= "#redirectURL#" />
		<cfelse>  <!--- url.EZTemplate EQ 0> --->
			<!--- Tim Ford - WR 45899: 45899 - Planning Groups and EZ Button Settings - Last Saved By and Date.
			Set Updated By and Updated Date for EZ Button when modifying EZ Button Data --->
			<cfif form.action eq "updSave" and url.EZTemplate eq 1>
				<cfquery name="qUpdateEZButtonUpdatedBy" datasource="#application.datasource#">
					UPDATE	Program_Control_Panel_Options
					SET		EZ_Button_Last_Updated_By	= '#request.AccessStructure.User_ID#',
							EZ_Button_Last_Updated_Date	= getDate()
					WHERE	ProgramControl_Panel_Options_ID	=	'#GetContractInfo.ProgramType_ID#'
				</cfquery>
			</cfif>

			<script>
				window.close();
			</script>
		</cfif>   <!--- url.EZTemplate EQ 0> --->
		</cfif>
		<!---now dump data into wddx and pump it out to a file to maintain state--->
		<!--- <cfscript>
			desRebateData = rebate.updateWddxDataFile(desRebateData,Form.sessionFile);
		</cfscript> --->

	</cfif>

</cfif>

<!--- LOAD SEARCH QUERY Fx
		<cfif isdefined("session.qGetItems")>
			<cfset StructDelete(session,"qGetItems",false) />
		</cfif>
			<cfset application.oController.getObject("mvc.models.Item.ItemSearchService") />
			<cfset application.oItemSearchService.getItems(desRebateData.programId,2) />
--->

<!------ Get pricing level descriptions ----->


<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />
<cfset variables.prodData = createObject("component", "components.Programs.Rebates.rebateData").init(desRebateData) />
<!---//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////End Controller Section////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<style>
		.saving { font-weight: bold; color: #00529B; font-size: 1.15em; margin: 0 30pt; }
	</style>
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
	<CFSET CSL_Contract_Main_ID = temp>
	<CFSET CSL_CallingPageCode = "rebates">


	<cfset FORM.Contract_Main_ID = cryp.value>

	<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
		<cfsavecontent variable="vContractStatusLegend">
	<!--- Width for the below div used to be 140px, but needed to be changed to 130px due to the following issue on IE 11.
	- Put the cursor over the scissor for any product (which deletes the product)
	- The cursor should turn into a hand and the scissor should be clickable.
	The above feature did not work on IE 11 for rebate products, with the width of the div being 140px.
	--->
			<div id="Layer2" style="position:absolute; width: 130px; height: 400px; z-index: 5; left: 10px; top: 0px">
				<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
			</div>
		</cfsavecontent>
		<cfif not form.bFromMargin>
			<cfoutput>#vContractStatusLegend#</cfoutput>
		</cfif>
	<cfelse>
		<cfsavecontent variable="vContractStatusLegend">
			<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
		</cfsavecontent>
		<cfif not form.bFromMargin>
			<cfoutput>#vContractStatusLegend#</cfoutput>
		</cfif>
	</cfif>

	<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset form.donotallowaddproductsDE = 1>
</CFIF>
</cfif>

<cfset jQueryUI.version = '1.11.4'/>
<cfinclude template="/common_files/jQuery.cfm">
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.1/jquery-ui.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>

	<script type="text/javascript"> var glAccountLabel = '<cfoutput>#Application.GLAccountLabel#</cfoutput>'; </script>
	<script src="/script/javascript/string_functions.js?v=08182020"></script>
	<cf_include files=#arrayToList( [	 "component_rebates.js"
										,"/script/javascript/dom_common.js"
										,"/billbacks/common/common_js_functions.js"
										,"/script/javascript/queue.js"
										,"/script/javascript/format_functions.js"
										,"/script/javascript/dhtml.js"
										,"/common_files/delete_functions.js"
										,"/common_files/contracts/group_functions.js"
										,"/script/javascript/variable.debugger.js"
									])#>
	<cfif url.EZTemplate EQ 1>
		<script src="/common_files/scripts/demenu.js"></script>
	</cfif>

	<script language="JavaScript">
	//ajaxRebate = new wddxAjax();

	/// This function is redefined later in _rebate_functions.cfm under certain conditions
	function enableDisableIncludeComponentLink(bEnable)
	{
		var someEmptyStrin = "";
	}

	function deleteProduct(prodCompId,bAutoAddComponent) {
				// Calls remote method with string mask as argument
			var ajaxRebate = new rebateAjax();
			var prodCompId = prodCompId;//prodCompId=contract_product_id
			var argument = new Array();
			var btnId = 'save_rate_'+prodCompId+'_All';
			argument[0]	= prodCompId;
			argument[1]	= 1;
			argument[2] = bAutoAddComponent;
			if (document.getElementById(btnId) != null)
				{
					document.getElementById(btnId).src =  '/images/btnSaveBl2_rd.png';
				}
				//call ajax.  response goes to JS delProdResponse() in an array
			var tmpajx = ajaxRebate.call('delSingleProd',delProdResponse,argument);
		  }


	function deleteAllProductsOptions()
	{
		var sHtml;
		var bAllowOptionB = 0;
		var scissorObj = event.srcElement;
		var bDelete = scissorObj.getAttribute('bDelete');

		<CFIF ArrayLen(desRebateData.aProd) EQ 0>
			$.prompt('There are no products to delete' );
			return;
		</cfif>

		<!---- Not from EZ template, (no rebate comp or auto add component) ---->
		<cfif url.EZTemplate EQ 0 AND (ArrayLen(desRebateData.aComp) EQ 0 OR bAutoAddComponent EQ 1)>
			bAllowOptionB = 1;
		</cfif>

		if(bAllowOptionB && bDelete == 'true'){ // bAllowOptionB = 1 and Action=Delete - Option  A and Option B

			sHtml = 'Delete products. Please select one of below choices:';

			//******** Option A - Only deletes checked products
			sHtml += '<br><br>';
			sHtml += 'A. Delete all checked products.';

			//******** Option B - Deletes all products from program
			sHtml += '<br><br>';
			sHtml += 'B. Delete all products from this program.';

			$.prompt(sHtml,
				{
				buttons: {"Option A":1, "Option B":2, Cancel:0 }
				,callback: function(save, m, f){
					if(save == 1){
						//Only deletes checked products
						deleteAllProducts('prodChkBx_','#bAutoAddComponent#', scissorObj);
					}
					else if(save == 2){
						//Deletes all products from program
						deleteAllProductsFromProgram('#bAutoAddComponent#');
					}
					else {
						return false;
					}
				}
			});
		}
		else { // Only one option

			if(bDelete == 'true') {sHtml = 'Delete all checked products?';}
			else  {sHtml = 'Undelete all checked products?';}

			$.prompt(sHtml,
				{
				buttons: {"Yes":1, Cancel:0 }
				,callback: function(save, m, f){
					if(save == 1){
						//Only deletes checked products
						deleteAllProducts('prodChkBx_','#bAutoAddComponent#', scissorObj);
					}
					else {
						return false;
					}
				}
			});
		}


	}


	function deleteAllProductsFromProgram(bAutoAddComponent) {
		$('form[name=dataForm], #save_table').hide();
		document.all.action.value = 'remAllProd';
		document.all.dataForm.submit();
		show_loader( "PLEASE WAIT...");
	}

	function unDeleteProduct(prodCompId,bAutoAddComponent) {
				// Calls remote method with string mask as argument
			var ajaxRebate = new rebateAjax();
			var prodCompId = prodCompId;//prodCompId=contract_product_id
			var argument = new Array();
			var btnId = 'save_rate_'+prodCompId+'_All';
			argument[0]	= prodCompId;
			argument[1]	= 0;
			argument[2] = bAutoAddComponent;
			if (document.getElementById(btnId) != null)
				{
					document.getElementById(btnId).src =  '/images/btnSaveBl2_rd.png';
				}
				//call ajax.  response goes to JS delProdResponse() in an array
			var tmpajx = ajaxRebate.call('unDelSingleProd',delProdResponse,argument);
		  }


	function delProdResponse(argArray){

			var action = argArray[1];
			var prodCompId = argArray[0];
			var btnId = 'save_rate_'+prodCompId+'_All';
			if (document.getElementById(btnId) != null)
				{
					if(action == 1)
					{
						document.getElementById(btnId).src =  '/Images/fill.gif';
					}
					else if(action == 0)
					{
						document.getElementById(btnId).src = '/images/btnSavebl5.png';
					}
				}

		}


	function saveProdRate_All(compVarList,stripProdId, arRateCount, prodid, compNameID, compID)
		{
	// Calls remote method with string mask as argument
			var ajaxRebate = new rebateAjax();
			var srcObj = event.srcElement;
			var argument = new Array();
			var compVarArray = compVarList.split("|");
			//D38536  :: Alternate recapture rates per component START
			var arRatesCountArray = arRateCount.split("|");
			var arRates =  '';
			var arUOM =  '';
			var CompNameIDArray =  compNameID.split("|");
			var compIDArray = compID.split("|");
			//D38536  :: Alternate recapture rates per component END
			var ErrorCount =0;

	 		var thisForm = document.dataForm;
			for(var i=0; i<compVarArray.length; i++){
					//do something by accessing compVarArray[i];
				 	argument[i] = new Array();

					//argument[i][0]	= eval('document.all.dataForm.comp_rate_'+compVarArray[i]+'.value');
					//27063 - use jQuery to get the selected option value since IE is dummed by returning a blank value
					if ($('[name=uom_' + compVarArray[i] + ']').val() == 6) {
						argument[i][0] = $('[name=comp_rate_' + compVarArray[i] + ']').val()/100;
						argument[i][1] = 2;
						argument[i][19]= 6;
					}
					else {
						argument[i][0] = $('[name=comp_rate_' + compVarArray[i] + ']').val();
						argument[i][1] = $('[name=uom_' + compVarArray[i] + ']').val();
						argument[i][19]= 0;
					}
					argument[i][2]	= eval('document.all.dataForm.ProgRebCompId_'+compVarArray[i]+'.value');
					argument[i][3]	= srcObj.id;
					argument[i][4]	= compVarArray[i];
					// pass scan volume D17948
					if(eval('document.all.dataForm.comp_scan_volume_'+compVarArray[i]))
					{
						argument[i][5]	= eval('document.all.dataForm.comp_scan_volume_'+compVarArray[i]+'.value');
					}
					else
					{
						argument[i][5]	= "";
					}
					argument[i][6]	= eval('document.all.dataForm.rebate_type_' + (i+1) + '.value');
					argument[i][7]	= eval('document.all.dataForm.EAConversion_'+compVarArray[i]+'.value');
					argument[i][8]	= eval('document.all.dataForm.productInventoryUOM_'+compVarArray[i]+'.value');
					//Competitor_Price Competitor_Name_ID Competitor_Time_Frame
					argument[i][9]	= eval('document.all.dataForm.Competitor_Name_ID_'+stripProdId+'.value');
					argument[i][10]	= eval('document.all.dataForm.Competitor_Price_'+stripProdId+'.value');
					argument[i][11]	= eval('document.all.dataForm.Competitor_Time_Frame_'+stripProdId+'.value');
					argument[i][12]	= eval('document.all.dataForm.CompetitorSourceOther_'+stripProdId+'.value');

					//D38536  :: Alternate recapture rates per component START
						for(var m = 0; m < arRatesCountArray[i]; m++){
							var j = m+1;

							var arRates= arRates.concat(eval('document.all.dataForm.ARR_'+j+'_'+compVarArray[i]+'.value'));
							if (j < arRatesCountArray[i]) {
								var arRates = arRates.concat('|');
							}
							var arUOM = arUOM.concat(eval('document.all.dataForm.ARR_'+j+'_UOM_'+compVarArray[i]+'.value'));
							if (j < arRatesCountArray[i]) {
								var arUOM = arUOM.concat('|');
							}

						}

						if(arRatesCountArray[i]!= 0){
							argument[i][13]=arRatesCountArray[i];
							argument[i][14]=arRates.split("|");
							argument[i][15]=arUOM.split("|");
						}
						else{
							argument[i][13]='0';
							argument[i][14]='0';
							argument[i][15]='0';
						}
						argument[i][16]=prodid;
						argument[i][17]=CompNameIDArray[i];
						argument[i][18]=compIDArray[i];
						var arRates = '';
						var arUOM = '';
					//D38536  :: Alternate recapture rates per component END

			argument[i][20]	= eval('document.all.dataForm.net_weight_'+compVarArray[i]+'.value');
			argument[i][21]	= eval('document.all.dataForm.Sleeves_Per_Case_'+compVarArray[i]+'.value');

		  // do these checkings only if the below value is 1;
		  if (thisForm.bDoCheckMaxVal.value == 1)
		  {
			tmpItemId = 'comp_rate_' + compVarArray[i];
			tmpTmpltID = 'comp_rate_' + compVarArray[i] + '_Tmplt';
            errorSpan = 'error_' + compVarArray[i];

            var inpVal = document.getElementById(tmpItemId)
                            ? parseFloat(document.getElementById(tmpItemId).value)
                            : 0;
            var inpTmpltVal = document.getElementById(tmpTmpltID)
                                ? parseFloat(document.getElementById(tmpTmpltID).value)
                                : 0;
            var errHolder = document.getElementsByName(errorSpan);
			var bProfile_EzButtonApproveBeyondMaxRate = "<cfoutput>#variables.Profile_EzButtonApproveBeyondMaxRate#</cfoutput>";
			var bTemplate_EzButtonEnterBeyondMaxRates = "<cfoutput>#GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates#</cfoutput>";
			/*  this piece of code will clear out all the error message before setting them */
	        var aSpans = document.body.getElementsByTagName("span");
	        var strSpanName = "";
			if (bTemplate_EzButtonEnterBeyondMaxRates == 1) {
			    eval("document.all.error_" + compVarArray[i]).style.visibility = 'hidden';
			    clearQueue(eval("document.all.error_" + compVarArray[i]));
			}
			else {
 				if(inpVal > inpTmpltVal) {
				  ErrorCount++;
				  eval("document.all.error_" + compVarArray[i]).style.visibility = 'visible';
				  alert ("The value '" +inpVal + "' is greater than the template Rate of: " + inpTmpltVal);
				}
				else {
				  eval("document.all.error_" + compVarArray[i]).style.visibility = 'hidden';
				  clearQueue(eval("document.all.error_" + compVarArray[i]));
				}
			}
		  }
		} // for loop

		if(ErrorCount != 0) {
		}
		else {
			var objectToPass = new Array();
			  ajaxRebate.call('saveProdRate_all',saveProdRateResponse_All,argument, 1);
		}
	}

	function saveProdRateResponse_All(response)
		{   var altText = '';
			for ( var i=response.length-1; i>=0; --i ){
			  try {
				  var srcObj = $('[name=comp_rate_' + response[i][4] + ']');
				  altText = ' Saved: ' + response[i][0];
				  if (response[i][1] == 1) {
					  altText = altText + ' CS'
				  }
				  else
					  if (response[i][1] == 2) {
						  altText = altText + ' LB'
					  }
					  else
						  if (response[i][1] == 3) {
							  altText = altText + ' %'
						  }
				  srcObj.title = altText;
				  if (srcObj.val() != 0) {
					  srcObj.style.background = 'white';
				  }
			  }
			  catch (err) {
			  }
			}
			//document.getElementById(response[0][3]).src = '/images/btnSavebl5.png';
			showmessage();
		}
	function applyWarnBorder(compVar){
				document.getElementById(compVar).src =  '/images/btnSaveBl3_yl.png';
			}
		<cfoutput>
		<!---77408 Product Group sequencing START--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		var Pricing_Level_#levels#_Desc = "#arPricingLevel[levels]#";
		</cfloop>
		<!---77408 Product Group sequencing END--->
		var maxComponentPossible = #appSettings.getRebateMaxComponents()#;
		</cfoutput>
		var my_queue = new Queue();


		function verifyDeleteComponent(component_id, component_name)
		{
			var sHtml;

			//<!---- User is deleting the last component and program has products ---->
			<CFIF ArrayLen(desRebateData.aProd) AND ArrayLen(desRebateData.aComp) EQ 1>
				sHtml = "Delete component " + component_name + "? ";
													 //******** Option A - Only deletes checked products
				sHtml += '<br><br>';
				sHtml += 'A. Delete component and leave the products on the program.';

				//******** Option B - Deletes all products from program
				sHtml += '<br><br>';
				sHtml += 'B. Delete component and all products.';

				$.prompt(sHtml,
				{
					buttons: {"Option A":1, "Option B":2, Cancel:0 }
					,callback: function(save, m, f){
						if(save == 1){
							//Delete component and leave the products on the program
							deleteComponent(component_id, 0);
						}
						else if(save == 2){
							//Delete component and all products
							deleteComponent(component_id, 1);
						}
						else {
							return false;
						}
					}
				});
			<CFELSE>
				sHtml = "Are you sure you want to delete " + component_name + "?";

				$.prompt(sHtml,
				{
					buttons: {"Yes":1, Cancel:0 }
					,callback: function(save, m, f){
						if(save == 1){
							//Delete component and leave the products on the program
							deleteComponent(component_id, 0);
						}
						else {
							return false;
						}
					}
				});
			</CFIF>

		}

		function deleteComponent(component_id, removeProducts)
		{

			$('form[name=dataForm], #save_table').hide();

			document.all.comps.value = component_id;
			if(removeProducts){
				document.all.action.value = 'remCompAndProd';
			}
			else {
				document.all.action.value = 'remComp';
			}
			document.all.dataForm.submit();
			show_loader( "PLEASE WAIT...");

		}



		var startDataCol = 3;
		<cfif application.returned_customer_setting.upc_switch EQ 0>
			startDataCol = startDataCol - 1;
		</cfif>

		function deleteThisRebate(FieldNameRe, prodID, bgCol, grouplevelID, realGroupLevelId, prodCompId, bAutoAddComponent)//prodCompId=contract_product_id
		{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var FINALITEMLIST = document.dataForm.Product_List.value;
		<cfoutput>
		<!---77408 Product Group sequencing START--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					var level#levels#List = document.dataForm.Level_#levels#.value;
					var level#levels#String = ListDeleteItem(level#levels#List, ",", prodID);
		</cfloop>
		<!---77408 Product Group sequencing END--->
			var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
			var bDelete = 'true';
			var objGroupLevel;
			var prodCompId = prodCompId;
			var itemCount = FINALITEMLIST.split(",");
			var compCount = #ArrayLen(desRebateData.aComp)#;
			//don't allow all products to be deleted if there is a component left
			<!--- Dev Note: drachala;  D27947: Deleted Product Groups and Capture START --->
			//ADDED resultString != FINALITEMLIST TO PREVENT ALERTING WHEN UNDELETING A GROUP.
			<cfif url.EZTemplate EQ 0>
				if (itemCount.length <= 1 && compCount > 0 && document.dataForm.compAlertCount.value == "0" && resultString != FINALITEMLIST && bAutoAddComponent == "0" && #url.EZTemplate# == 0){
					document.dataForm.compAlertCount.value = "1";
					alert('Please delete components before deleting all Products.');
					return;
				}
			</cfif>

			<!--- Dev Note: drachala;  D27947: Deleted Product Groups and Capture END --->
			<!---77408 Product Group sequencing START--->
			objGroupLevel = eval("document.all.GroupLevel_" + grouplevelID);
			if(resultString == FINALITEMLIST){
				resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
				bDelete = 'false';
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					if (grouplevelID == #levels#)
					level#levels#String = ListAppendItem(level#levels#String, ",", prodID);
					document.dataForm.Level_#levels#.value = level#levels#String;
				</cfloop>
			}
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				document.dataForm.Level_#levels#.value = level#levels#String;
			</cfloop>
			if (!validateGroups()){
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					document.dataForm.Level_#levels#.value = "";
					document.dataForm.Level_#levels#.value = level#levels#List;
				</cfloop>
				return;
			}
			<!---77408 Product Group sequencing END--->
			</cfoutput>
			document.all.Product_List.value = resultString;
			document.all.ExistingProductList.value = resultString;
			var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
			var saveLink = eval("document.all.save_rate_" + prodCompId + "_All");


			if(trObj){
				if(bDelete == 'true'){
					trObj.height = trObj.offsetHeight;
					//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
					if(saveLink) saveLink.style.display = "none";
					<cfset CompLen = ArrayLen(desRebateData.aComp)>

					for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++){
						//disableDiv(trObj.cells[i+startDataCol], true, false);

						var tdObjects = trObj.cells[i+startDataCol].getElementsByTagName("input");
						for(k=0; k<tdObjects.length; k++){
							if(tdObjects[k].type == "text"){
								tdObjects[k].disabled = true;
							}
						}
						tdObjects = trObj.cells[i+startDataCol].getElementsByTagName("select");
						for(k=0; k<tdObjects.length; k++){
							tdObjects[k].disabled = true;
						}
					}

					trObj.setAttribute('bgcolor', 'DDDDDD');
					propogateProperty(trObj, "style.textDecoration", "line-through", true);

					srcObj.title = "Deleted";
					srcObj.src = undodeleteImg.src;
					//  srcObj.src =  "/Images/fill.gif";
					//resetnavigate();

					deleteProduct(prodCompId,bAutoAddComponent);//prodCompId=contract_product_id
					document.all.deleted.value = Number(document.all.deleted.value) + 1;		//D30231:Deleting Items off a Revised Program

				}	else{

					<cfset CompLen = ArrayLen(desRebateData.aComp)>
					<cfif EzButton_Disable EQ 0>

					for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++){
						//disableDiv(trObj.cells[i+startDataCol], false, false);

						var tdObjects = trObj.cells[i+startDataCol].getElementsByTagName("input");
						for(k=0; k<tdObjects.length; k++){
							if(tdObjects[k].type == "text"){
								tdObjects[k].disabled = false;
							}
						}
						tdObjects = trObj.cells[i+startDataCol].getElementsByTagName("select");
						for(k=0; k<tdObjects.length; k++){
							tdObjects[k].disabled = false;
						}
					}
					</cfif>

					trObj.setAttribute('bgcolor', trObj.getAttribute('origbgcolor'));
					propogateProperty(trObj, "style.textDecoration", "none", false);
					unDeleteProduct(prodCompId,bAutoAddComponent);//prodCompId=contract_product_id
					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;
					if(saveLink) saveLink.style.display = "";

					//propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
					document.all.deleted.value = document.all.deleted.value - 1;		//D30231:Deleting Items off a Revised Program
					if(objGroupLevel.value == "")
						objGroupLevel.value = realGroupLevelId;
				}
				srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
				trObj.setAttribute('bDelete',(bDelete == 'true'?1:0));
				}
			//}
			document.dataForm.compAlertCount.value = "0"

		}
	function populateGrid() {
		if(document.getElementById("Rebatesearch").value == ""){
			alert('Please enter a valid value in the filter field.')
		}else{
		disableActions();
	 document.getElementById("Sub_Product_List").value='';
	 document.getElementById("pageNum").value='1';
	 document.getElementById("action").value='searchProds';
	 document.dataForm.submit();
	 show_loader( "SEARCHING...PLEASE WAIT...");
	}
	}
	function setPageNum(pageNum){
		var thisPageNum = pageNum;
		document.getElementById("pageNum").value =  thisPageNum;
	}
	function setPageLocate(locate){
		oTable.fnFilter('');
		var thisLocate = locate;
		document.getElementById("locate").value =  thisLocate;
	}

function deleteAllProducts(chNameStart,bAutoAddComponent, scissorObj)
{
	var checkCheckbox = 'false';

	var FINALITEMLIST = document.dataForm.Product_List.value;
	var itemCount = FINALITEMLIST.split(",");
	if(chNameStart)
	{
		checkCheckbox = 'true';
	}

	var totalProdLen = <cfoutput>#ArrayLen(desRebateData.aProd)#</cfoutput>;
	var compCount = <cfoutput>#ArrayLen(desRebateData.aComp)#</cfoutput>;
	var deleteObjs = document.getElementsByName("IMG_Delete_Scissor");
	var i, deleteObjLen;
	var bDelete = scissorObj.getAttribute('bDelete');
	var deletedProdCount = 0;


	deleteObjLen = deleteObjs.length;

	if(deleteObjLen)
	{
		for(i=0;i<deleteObjLen;i++)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					/* Count how many products are checked for deletion. */
					deletedProdCount = deletedProdCount + 1;
				}
			}
		}
	}

	/* If the product count to be deleted is the same as the count of all the products, i..e if the user wants to delete
	all the products.
	*/
	<cfif url.EZTemplate EQ 0>
	if ((deletedProdCount != 0 && deletedProdCount == totalProdLen) && compCount > 0 && bAutoAddComponent =="0"  && <cfoutput>#url.EZTemplate#</cfoutput> == 0)
	{
		document.dataForm.compAlertCount.value = "1";
		alert('Please delete components before deleting all Products.');
		return;
	}
	</cfif>

	if(deleteObjLen)
	{
		for(i=deleteObjLen-1;i>=0;i--)
		{
			if(bDelete + "" == deleteObjs[i].getAttribute('bDelete') + "")
			{
				if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs[i]))
				{
					deleteObjs[i].click();
				}
			}
		}
	}
	else
	{
		if(bDelete + "" == deleteObjs.getAttribute('bDelete') + "")
		{
			if(bDelete == 'false' || checkCheckbox == 'false' || checkboxIsChecked(chNameStart, deleteObjs))
			{
				deleteObjs.click();
			}
		}
	}
	if(bDelete == 'true')
	{
		scissorObj.title = "undo " + scissorObj.getAttribute('sMessage');
		scissorObj.src = undodeleteImg.src;
	}
	else
	{
		scissorObj.title = scissorObj.getAttribute('sMessage');
		scissorObj.src = deleteImg.src;
	}
	/* The reason why "bDelete" is a string and not a boolean is because "setAttribute" can only set a string value and not a boolean. */
	scissorObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
}

	</script>

	<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
</HEAD>

<!---set whether to allow multi level groups--->
<cfif appSettings.getAllowMultiLevelGroups()>
	<cfset form.Allow_Multi_Levels = 1 />
</cfif>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getAllowNavigate()>onbeforeunload="verifyNavigate();"</cfif>>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<CFSET GETALLCONTRACTINFO_DISCOUNT_TYPE_ID = 1>

<!---set if groups are static or dynamic--->
<cfif isDefined("GetSettings.Dynamic_Static_Groups")>
	<cfset form.Dynamic_Static_Groups = GetSettings.Dynamic_Static_Groups />
</cfif>
<cfset form.Price_Protection_on = getSettings.Price_Protection_on>

<!---set the group level coming from the GetSettings query in contract_status_legend.cfm include--->
<cfset Form.Discount_Rebates_Item_Level = GetSettings.Discount_Rebates_Item_Level />
<cfset Form.Discount_Rebates_Group_Level = GetSettings.Discount_Rebates_Group_Level />

<!---If search sequences are on, modify what they're allowed to see (product or group) based on search sequences as well as other template settings--->
<cfif appSettings.getSearchSequenceOn() AND len(trim(CSLGETCONTRACTINFO.Search_Sequence_ID)) GT 0>
	<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(CSLGETCONTRACTINFO.Search_Sequence_ID) />
	<cfset 	Form.Discount_Rebates_Item_Level =  SearchSequenceManager.enableProductSelection(Program_Search_Sequence) />
	<cfset 	Form.Discount_Rebates_Group_Level = SearchSequenceManager.enableGroupSelection(Program_Search_Sequence) />
</cfif>

<cfset forceProductSearchAtLowerLevel = 0 />
<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()><!------ If the app setitngs is on for (Program: If pricing level 1 = groups, allow only products at lower level) ----->
	<cfset forceProductSearchAtLowerLevel = 1 />
<cfelse>
	<cfif appSettings.getSearchSequenceOn() EQ 0>
		<!------ If restrict on group level is on and exception/exclusion is checked, enable the product link ----->
		<cfif GetSettings.Restrict_Product_Group_Level eq 1 AND GetSettings.Allow_Lower_Pricing_Level eq 1>
			<cfset forceProductSearchAtLowerLevel = 1 />
		</cfif>
	</cfif>
</cfif>

<cfset restrictLowerLevelBasedonLevel1 = 0 />
<cfset availableLowerLevels = "" />
<cfif forceProductSearchAtLowerLevel>
	<cfif ArrayLen(desRebateData.aProd) GT 0>
		<cfparam name="desRebateData.aGroupLevel" 	default="">
		<cfset aGroupLevel = desRebateData.aGroupLevel />
		<!---77408 Product Group sequencing START--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			<cfset 'level_#levels#_Group_Type' = aGroupLevel[levels] />
		</cfloop>

		<cfif Form.Discount_Rebates_Group_Level EQ 1 AND level_1_Group_Type NEQ "" AND level_1_Group_Type NEQ "0" AND level_1_Group_Type NEQ "9"><!------ If level1 is group, enable product serach ----->
			<cfset restrictLowerLevelBasedonLevel1 = 1 />
			<!---77408 Product Group sequencing START--->
			<cfif level_2_Group_Type NEQ "" AND level_2_Group_Type NEQ "0" AND level_2_Group_Type NEQ "9"><!------ If level2 is group ----->
					<cfif level_3_Group_Type NEQ "" AND level_3_Group_Type NEQ "0" AND level_3_Group_Type NEQ "9"><!------ If level3 is group ----->
							<cfif request.AccessStructure.numberOfProductGroupLevels GT 3><!--- check if there are more than 3 levels --->
								<cfif level_4_Group_Type NEQ "" AND level_4_Group_Type NEQ "0" AND level_4_Group_Type NEQ "9"><!------ If level4 is group ----->
									<cfif level_5_Group_Type NEQ "" AND level_5_Group_Type NEQ "0" AND level_5_Group_Type NEQ "9"><!------ If level5 is group ----->
										<cfif level_6_Group_Type NEQ "" AND level_6_Group_Type NEQ "0" AND level_6_Group_Type NEQ "9"><!------ If level6 is group ----->
											<cfif level_7_Group_Type NEQ "" AND level_7_Group_Type NEQ "0" AND level_7_Group_Type NEQ "9"><!------ If level7 is group ----->
												<cfif level_8_Group_Type NEQ "" AND level_8_Group_Type NEQ "0" AND level_8_Group_Type NEQ "9"><!------ If level8 is group ----->
												<cfelse>
													<cfset availableLowerLevels = ListAppend(availableLowerLevels, "8") />
												</cfif><!------ level8 END ----->
											<cfelse>
												<cfset availableLowerLevels = ListAppend(availableLowerLevels, "7,8") />
											</cfif><!------ level7 END ----->
										<cfelse>
											<cfset availableLowerLevels = ListAppend(availableLowerLevels, "6,7,8") />
										</cfif><!------ level6 END ----->
									<cfelse>
										<cfset availableLowerLevels = ListAppend(availableLowerLevels, "5,6,7,8") />
									</cfif><!------ level5 END ----->
								<cfelse>
									<cfset availableLowerLevels = ListAppend(availableLowerLevels, "4,5,6,7,8") />
								</cfif><!------ level4 END ----->
							</cfif>
					<cfelse>
						<cfset availableLowerLevels = ListAppend(availableLowerLevels, "3,4,5,6,7,8") />
					</cfif><!------ level3 END ----->
			<cfelse>
				<cfset availableLowerLevels = ListAppend(availableLowerLevels, "2,3,4,5,6,7,8") />
			</cfif><!------ level2 END ----->
			<!---77408 Product Group sequencing END--->
			<cfif ListLen(availableLowerLevels) gt 0>
				<cfset Form.Discount_Rebates_Item_Level = 1>
			</cfif>
		</cfif>

	</cfif>
</cfif>

<cfset useLakebaseForGETUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGETUOM>
	<cftry>
		<cfset GETUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGETUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGETUOM>
	<CFQUERY NAME="GETUOM" datasource="#application.datasource#">
		SELECT *
		FROM Units_of_Measure
	</CFQUERY>
</cfif>

<SCRIPT>
	function showProductSearchWindow(addProductAtLevel)
	{
		var bSelectedAllProducts = false;
		var groupLevel = 0;

		// 21306 - disable components link while adding products(say when adding about 1000 products).
		// It will be reenabled when page refreshes
		enableDisableIncludeComponentLink(false);
		disableButton('save_table','true');

		if(document.all.groupLevelProducts)
		{
			if(document.all.groupLevelProducts.value == "1")
			{
				groupLevel = 1;
				bSelectedAllProducts = true;
			}
		}
		if(bSelectedAllProducts)
		{
			if(window.confirm("Your current action will remove 'All Products'." + "\n" + "Do you want to continue?"))
			{
				//if groupLevel = 1
				document.all.groupLevelProducts.value = "0";
				document.all.Product_Level_1.value = "";
				document.all.Product_List.value = "";
				document.all.ExistingProductList.value = "";
				bSelectedAllProducts = false;
			}
		}
		if(!bSelectedAllProducts)
		{  <!--- /Common_Files/SearchScreens/products/ItemSearchFx.cfm   getItemSearch.cfm  /FlexDev/ItemSearch/bin-debug/ItemSearchFx.cfm--->
			var sURL = "/Flex/search/ItemSearchFx.cfm?Formname=dataForm&DiscountType=2&EZTemplate=<cfoutput>#url.EZTemplate#&programId=#FORM.Contract_Main_ID#</cfoutput>";
			if(addProductAtLevel)
			{
				document.all.AllowProductGroupList.value = document.all.Level_1.value;
				sURL = sURL + "&ExistingProductList_Field_Name=Level_" + addProductAtLevel + "&AnotherProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2) + "&Return_Value_Field_Name=Level_" + addProductAtLevel;
				//sURL = sURL + "&ProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2);
				document.all.action.value = "prodlevel" + addProductAtLevel;
			}
			document.all.Rebatesearch.value = "";
			NewWindowTopLeft(sURL, "productwindow", 1000, 715, "yes", "yes")
		}
	}

	function showProductSearchWindow_old(addProductAtLevel)
	{
		var bSelectedAllProducts = false;
		var groupLevel = 0;

		// 21306 - disable components link while adding products(say when adding about 1000 products).
		// It will be reenabled when page refreshes
		enableDisableIncludeComponentLink(false);
		disableButton('save_table','true');

		if(document.all.groupLevelProducts)
		{
			if(document.all.groupLevelProducts.value == "1")
			{
				groupLevel = 1;
				bSelectedAllProducts = true;
			}
		}
		if(bSelectedAllProducts)
		{
			if(window.confirm("Your current action will remove 'All Products'." + "\n" + "Do you want to continue?"))
			{
				//if groupLevel = 1
				document.all.groupLevelProducts.value = "0";
				document.all.Product_Level_1.value = "";
				document.all.Product_List.value = "";
				document.all.ExistingProductList.value = "";
				bSelectedAllProducts = false;
			}
		}
		if(!bSelectedAllProducts)
		{  <!--- /Common_Files/SearchScreens/products/ItemSearchFx.cfm   getItemSearch.cfm  /FlexDev/ItemSearch/bin-debug/ItemSearchFx.cfm--->
			var sURL = "product_Select_V1.cfm?Formname=dataForm&discountype=2&EZTemplate=<cfoutput>#url.EZTemplate#&programId=#FORM.Contract_Main_ID#&FirstParentID=#GetTemplateInfo.First_parent_ID#&prgID=#GetContractInfo.Contract_Main_ID#</cfoutput>";
			if(addProductAtLevel)
			{
				document.all.AllowProductGroupList.value = document.all.Level_1.value;
				sURL = sURL + "&ExistingProductList_Field_Name=Level_" + addProductAtLevel + "&AnotherProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2) + "&Return_Value_Field_Name=Level_" + addProductAtLevel;
				//sURL = sURL + "&ProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2);
				document.all.action.value = "prodlevel" + addProductAtLevel;
			}
			document.all.Rebatesearch.value = "";
			NewWindowTopLeft(sURL, "productwindow_old", 1000, 700, "yes", "yes")
		}
	}

	function showGroupSearchWindow()
	{
		var prodAtLevel1 = document.all.GroupLevel_1.value;

		// 21306 - disable components link while adding products(say when adding about 1000 products).
		// It will be reenabled when page refreshes
		enableDisableIncludeComponentLink(false);
		disableButton('save_table','true');

		//if group level 1 equals 9 then we can't allow groups to be added
		/*76386 :: Ability to add [product group] when items already exist*/
		<cfif appSettings.get_Setting('Product_Group_Sequencing') neq '1'>
		if(prodAtLevel1 == 9)
		{
			alert("Groups cannot be added when products exist at <cfoutput>#arPricingLevel[1]#</cfoutput>.");
			return;
		}
		</cfif>

		NewWindow("Groups/index.cfm?formName=dataForm&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&Discountype=2&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>", "productwindow", 800, 700, "yes", "yes");

	}
	function showCreateProdcutListWindow(){
		var sURL = "/Planners/Create/component_select.cfm?<cfoutput>discountType=2&PaymentCycle=#GetSettings.PayCycleDefaultOption#&EZTemplate=#url.EZTemplate#&templateId=#GetContractInfo.ProgramType_ID#&Program_Upload=1&programId=#FORM.Contract_Main_ID#&FirstParentID=#GetTemplateInfo.First_parent_ID#&ClaimMechanics=#CSLGetContractInfo.ClaimMechanics#&Claim_Mechanics=#CSLGetContractInfo.ClaimMechanics#</cfoutput>";
		NewWindowTopLeft(sURL, "productRateList", "1000", "600", "no","no","yes", "yes");
	}
	function openPopup(url, winW, winH){
		var windowWidth = 200;
		var windowHeight = 210;

		if(winW){
			windowWidth = winW;
		}
		if(winH){
			windowHeight = winH;
		}
		var w = 640/3;
		var h = 480/3;
		var cw = w/2;
		var ch = h/2;

		if (window.screen){
			w = Math.floor(screen.availWidth/3);
			h = Math.floor(screen.availHeight/3);
			cw = Math.floor((screen.availWidth-w)/2);
			ch = Math.floor((screen.availHeight-h)/2);
		}

		myPopup = window.open(url,'popupWindow','resizable=yes,scrollbars=yes,width='+windowWidth+',height='+windowHeight+',top='+ch+',left='+cw);
		if (!myPopup.opener)
			myPopup.opener = self;
	}

	function  validateGroupsDefaultCheckBoxes(){

	var thisForm = document.dataForm;
	<cfoutput>
	<!---77408 Product Group sequencing START--->
	<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		var level#levels# = thisForm.Level_#levels#.value;
		var level#levels#_checked =  false;
	</cfloop>
	</cfoutput>
	var i, arrLen;
	var bIsValid= true;
	<cfif url.EZTemplate EQ 1>
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		<cfoutput>
			if (trim(level#levels#) != ""){
				var Arr#levels# = level#levels#.split(',');
							arrLen = Arr1.length;

				for(i=0; i<arrLen; i++){
					if(typeof("document.all.Prod_Default_"+replaceChar(Arr1[i],'-','_')) == 'object'){
						if (eval("document.all.Prod_Default_"+replaceChar(Arr1[i],'-','_')+".checked")){
							level#levels#_checked = true;
						}
					}
					/*validate group levels*/

					<cfset nextLevel = #levels# + 1>
					<cfset lstring = '! level#levels#_checked' & ' && level#nextLevel#_checked'>
					<cfif nextLevel LTE request.AccessStructure.numberOfProductGroupLevels>
					if ( #lstring#	){
							alert("Level #levels# default should be checked if Groups or Products in below levels default settings are checked.");
							bIsValid = false;
							return bIsValid;
						}
					</cfif>
				}
			}
			</cfoutput>
	</cfloop>

	/*validate group levels
	if ( ! level1_checked && level2_checked && level3_checked && level4_checked && level5_checked && level6_checked && level7_checked && level8_checked){
			alert("Level 1 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level2_checked && level3_checked && level4_checked && level5_checked && level6_checked && level7_checked && level8_checked){
			alert("Level 2 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level3_checked && level4_checked && level5_checked && level6_checked && level7_checked && level8_checked){
			alert("Level 3 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level4_checked && level5_checked && level6_checked && level7_checked && level8_checked){
			alert("Level 4 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level5_checked && level6_checked && level7_checked && level8_checked){
			alert("Level 5 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level6_checked && level7_checked && level8_checked){
			alert("Level 6 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level7_checked && level8_checked){
			alert("Level 7 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}
	*/
	</cfif>
<!---77408 Product Group sequencing END--->
	return bIsValid;
}
function validateForm(btnSaveaction,num,svTemplate ,ezTemplate,ezButton,ezMaxRateProfile,ezMaxRateTemlate){
	/* Dev Note: Milan Start - (For Competitor Info) */
	var frmRebates = document.forms['dataForm'].elements;
	var i=frmRebates.length;
	var name_;
	var elem;
	var value_;
	var CompetitorInfoNotFilled = 0;
	var Competitor_Name_Filled = 1;
	var Competitor_Price_Filled = 1;
	var Competitor_Time_Frame_Filled = 1;
	var Competitor_Info_Complete = 1;
	var deleted_field = document.all.deleted.value; //D30231:Deleting Items off a Revised Program


	/* Make sure that all the competitor info is filled when the user offers a discount on the product */
		for (var i=0, il= frmRebates.length; i<il; i++){

			 elem =frmRebates[i]
			 name_ = elem.name;
			 id_ = elem.id;
			 value_ = elem.value;

				if(elem.type=='select-one' && name_.indexOf('Competitor_Name_ID') != -1)
				{
						compProdIDEndPosition = name_.indexOf('Competitor_Name_ID_');
						compProdID = id_.substring(19,id_.length);

						/* Is discount offered */
						CompetitorInfoNotFilled = $('[name=comp_rate_' + compProdID + ']').val(); //eval('document.all.dataForm.comp_rate_'+compProdID+'.value');
						/* If discount is offered and Competitor name is not filled */
						if(value_ == 0 && CompetitorInfoNotFilled != 0 && deleted_field == 0) //D30231:Deleting Items off a Revised Program
						{
						 Competitor_Name_Filled = 0;
						}
				}

				if(elem.type=='text' && name_.indexOf('Competitor_Price') != -1)
				{
						/* If discount is offered (discount having a value greater than 0 on changing fixed price by the user) and competitor info is not filled */
						if(((value_ == '0.00') || (value_ == '')) && CompetitorInfoNotFilled != 0 && deleted_field == 0) //D30231:Deleting Items off a Revised Program
						{
						 Competitor_Price_Filled = 0;
						}
				}

				if(elem.type=='text' && name_.indexOf('Competitor_Time_Frame') != -1)
				{
						/* If discount is offered (discount having a value greater than 0 on changing fixed price by the user) and competitor time frame is not filled */
						if(value_ == '' && CompetitorInfoNotFilled != 0 && deleted_field == 0)//D30231:Deleting Items off a Revised Program
						{
						 Competitor_Time_Frame_Filled = 0;
						}
				}
		}
		<cfif isDefined("GetTemplateInfo.Source") AND GetTemplateInfo.Source EQ 1 AND GetTemplateInfo.Source_Required EQ 1>
			if(Competitor_Name_Filled == 0 || Competitor_Price_Filled == 0 || Competitor_Time_Frame_Filled == 0)
		 	{
				alert("Please fill in the complete competitor info (Name,Price,Time Frame) for the highlighted rows");
				Competitor_Info_Complete = 0;
		 	}
		 	else
			{ //submit form
		 		submitForm(btnSaveaction,num,svTemplate ,ezTemplate,ezButton,ezMaxRateProfile,ezMaxRateTemlate);
		 	}
		 <cfelse>
		 	submitForm(btnSaveaction,num,svTemplate ,ezTemplate,ezButton,ezMaxRateProfile,ezMaxRateTemlate);
		 </cfif>
		/* Dev Note: Milan End - (For Competitor Info) */

}
</SCRIPT>

<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID />
<CFSET HideProductList = 1 />

<CFSET helpfilenumber=7 />
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>

<div  id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; <cfif not form.bFromMargin> left: 100px;</cfif> top:0px;"> </cfif>
	<cfif url.EZTemplate EQ 0>
	<BLOCKQUOTE><br>
		<cfset width = '1095'>
		<cfinclude template="minimal_contract_info.cfm">
	</cfif>
		<!--- Tim Ford - WR 45899: 45899 - Planning Groups and EZ Button Settings - Last Saved By and Date.
		Display Updated By and Updated Date for EZ Button --->
		<cfif url.EZTemplate eq 1 and LEN(GetSettings.EZ_Button_Last_Updated_Date) and LEN(GetSettings.EZ_Button_Last_Updated_By)>
			<br>
			<table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0"  align="center">
				<tr>
					<td>
						<cfquery name="qGetEzButtonUpdateData" datasource="#application.datasource#">
							SELECT	Name_First, Name_Last
							FROM	_Users
							WHERE	User_ID = '#GetSettings.EZ_Button_Last_Updated_By#'
						</cfquery>
						<cfoutput>
							<font size="2"><b>The settings were last updated on #dateformat(GetSettings.EZ_Button_Last_Updated_Date, 'mm/dd/yyyy')# #timeformat(GetSettings.EZ_Button_Last_Updated_Date, 'hh:mm:ss TT')# by #qGetEzButtonUpdateData.Name_First# #qGetEzButtonUpdateData.Name_Last#</b></font>
						</cfoutput>
					</td>
				</tr>
			</table>
		</cfif>
	<cf_MessageWindow>

		<!---include file containing all rebate ui functionality--->
		<cfinclude template="_rebate_functions.cfm" />
	<cfoutput>
		<div style="padding-left:15px;padding-bottom: 5px;padding-top: 5px;">
			#rebate.getPageLinks(ListLen(form.sub_Product_List),variables.saveBtnAction,form.pageNum)#
		</div>
		</cfoutput><br>
	<CF_button
	button_name		=	"save"
	button_caption	=	"save"
	button_action	=	"setPageLocate(1);disableButton('pageLink','true');validateForm('#variables.saveBtnAction#', 1, 'save_table','#url.EZTemplate#','#EzButton_Disable#','#variables.Profile_EzButtonApproveBeyondMaxRate#','#GetTemplateInfo.EzButton_Enter_Beyond_Max_Rates#');"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"save"
	font_color		=	"White"
	title			=	"  #ListLen(form.sub_Product_List)# Products for Edit.  "
	font_size		=	"12"
	font_weight		=	"bold">

		<cfif form.bFromMargin>
		<CF_button
			button_name		=	"close"
			button_caption	=	"close"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save"
			font_color		=	"White"
			title			=	"Close"
			font_size		=	"12"
			font_weight		=	"bold">
		</cfif>
	</BLOCKQUOTE><cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>

</div>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <cfdump var="#desRebateData#"> --->
<CF_MessageWindow>
<cfsetting showdebugoutput="true" />
<cfinclude template="/common_Files/focus.cfm">
</BODY>
</HTML>