<CFPARAM NAME="URL.CID" DEFAULT="">
<!---default value to tell us if this is the first time in--->
<CFPARAM NAME="init" DEFAULT="">
<CFPARAM NAME="compUUID" DEFAULT="#CreateUUID()#">
<CFPARAM NAME="Form.Product_List" DEFAULT="">
<CFPARAM NAME="Form.sortBy" DEFAULT="displaygroupname">
<CFPARAM NAME="Form.sortOrder" DEFAULT="asc">
<CFPARAM NAME="Form.Discount_Rebates_Item_Level" DEFAULT="0">
<CFPARAM NAME="Form.Discount_Rebates_Group_Level" DEFAULT="0">
<CFPARAM NAME="form.Level_1" DEFAULT="">
<CFPARAM NAME="form.Level_2" DEFAULT="">
<CFPARAM NAME="form.Level_3" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_1" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_2" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_3" DEFAULT="">
<CFPARAM name="form.navigate" default="0">
<CFPARAM name="form.stopnavigate" default="0">
<CFPARAM name="form.Dynamic_Static_Groups" default="0">
<CFPARAM name="form.Allow_Multi_Levels" default="0">
<CFPARAM name="form.Action" default="">
<cfparam name="form.donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="marginedit_saved" default="0">
<cfparam name="form.Price_Protection_on" default="0">
<cfparam name="session.group_rebate_type_search_id" default="" >
<cfparam name="form.Like_Product" default="">
<cfparam name="form.Is_Like_Product_Exist" default="0">
<cfparam name="form.Treatment_Code" default="0">
<cfparam name="form.Basis_Code" default="0">
<cfparam name="url.EZTemplate" default="0">

<cfif form.action neq "save">

	<cfheader name="Cache-Control" value="no-store">
	<cfheader name="expires" value="-100">
	<cfset Cache_Control_Header_Already_Added = 1>
	<CFINCLUDE template="/includes/call_please_wait.cfm">

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

<CFIF len(trim(URL.CID)) GT 0>

	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

	<!---Call method to get all contract information--->
	<cfscript>

		contract = CreateObject("component", "components.programs.rebates.Contract");
		GetContractInfo = contract.get(cryp.value);

	</cfscript>

	<!---set the sessionFile param--->
	<cfif not isDefined("Form.sessionFile")>
		<!--- <cfset Form.sessionFile = cryp.value & "_" & request.AccessStructure.user_id /> --->
		<cfset Form.sessionFile = CreateUUID() />
	</cfif>


		<!--- D50074 :: Viewing and Editing prior program versions START --->
		<cfinclude template="/get_access_profile.cfm">
		<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<!--- D50074 :: Viewing and Editing prior program versions END --->
		<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
		<script>
			history.back();
		</script>
		<CFABORT>
	</CFIF>
</CFIF>

<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
<cfset programInfo = programManager.getProgramInfo(GetContractInfo.Contract_Main_ID)>

<!--- Add the Revision Settings Component --->
<cfset Revision_Settings_Allowed = 0>
<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = programInfo.ProgramType_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = GetContractInfo.Contract_Main_ID)>
<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(GetContractInfo.Contract_Main_ID)>

<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number neq "")>
	<cfset Revision_Settings_Allowed = 1>
</cfif>

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
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />

<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset programagreed = programManager.isProgramAgreed(GetContractInfo.Contract_Main_ID)>

<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
</cfif>

<!---if the rebate isn't initialized then we initialize it--->
<cfif not isDefined("form.init")>

	<cfscript>
		//rebate = createObject("component","components.programs.rebates.Rebate");
		rebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID);
	</cfscript>

	<!--- <cfset desRebateData = rebate.getWddxDataFromFile(Form.sessionFile) /> --->
	<cfset desRebateData = rebateData />
	<cfset init = false />

</cfif>

<!---if inits defined then we have a data structure to read and write to--->
<cfif isDefined("form.init")>

	<!---first get data from data structure stored on disk--->
	<!--- <cfset desRebateData = rebate.getWddxDataFromFile(Form.sessionFile) /> --->
	<cfscript>
		rebateData = rebate.loadFromDB(programID=GetContractInfo.Contract_Main_ID,displayGroupType=displaygrouptype,useXML=0,compUUID=compUUID);
	</cfscript>
	<cfset desRebateData = rebateData />

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
	<cfscript>
		desRebateData = rebate.update(
						programID = GetContractInfo.Contract_Main_ID,
						aProd = desRebateData.aProd,
						aComp = desRebateData.aComp,
						aCompVal = desRebateData.aCompVal,
						form = form,
						aGroupLevel = desRebateData.aGroupLevel);
	</cfscript>

	<!---if action is defined then handle for each action--->
	<cfif isDefined("form.action")>

		<!---ADD group products--->
		<cfif form.action eq "addProductGroups">

			<cfset GroupManager = CreateObject("component", "components.products.Group.GroupManager") />
			<cfset objGroupManager = GroupManager.set(form) />
			<cfset desRebateData =  rebate.setGroups(desRebateData,form.Product_List,GetContractInfo.Contract_Main_ID,objGroupManager,form.Level_3) />

		</cfif>

		<!--- ADD PRODUCTS - TYPE 2 to handle for products at more than 1 levels --->
		<cfif form.action eq "prodlevel2" OR form.action eq "prodlevel3">
			<!------ In this case, compile the product list from level_1, level_2 and level_3 ----->
			<cfset form.Product_List = "" />
			<cfset form.Product_List = ListAppend(form.Product_List, form.Level_1, ",") />
			<cfset form.Product_List = ListAppend(form.Product_List, form.Level_2, ",") />
			<cfset form.Product_List = ListAppend(form.Product_List, form.Level_3, ",") />

			<cfif form.action eq "prodlevel2">
				<cfset form.GroupLevel_2 = "9" />
			</cfif>
			<cfif form.action eq "prodlevel3">
				<cfset form.GroupLevel_3 = "9" />
			</cfif>

			<cfset desRebateData = rebate.addProd(stDataStructure=desRebateData,lProdList=form.Product_List,contractMainID=GetContractInfo.Contract_Main_ID,group_rebate_type_search_id=session.group_rebate_type_search_id,level3List=form.Level_3,displayGroupType=displayGroupType) />
		</cfif>

		<!---ADD PRODUCTS--->
		<cfif form.action eq "prod">
			<cfset desRebateData = rebate.addProd(stDataStructure=desRebateData,lProdList=form.Product_List,contractMainID=GetContractInfo.Contract_Main_ID,group_rebate_type_search_id=session.group_rebate_type_search_id,level3List="",displayGroupType=displayGroupType) />
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
			<cfscript>
				desRebateData = rebate.addComp(desRebateData,form,GetContractInfo.Contract_Main_ID, form.IsRestrictLowerLevelBasedonLevel1On);
			</cfscript>
			<cfset compUUID = createUUID() />

		</cfif>

		<!---REMOVE COMPONENTS--->
		<cfif form.action eq "remComp">

			<cfscript>
				desRebateData = rebate.remComp(desRebateData,form.comps);
			</cfscript>

		</cfif>

		<!---REMOVE PRODUCTS--->
		<cfif form.action eq "remProd">

			<cfscript>
				desRebateData = rebate.remProd(desRebateData,form.Product_List);
			</cfscript>

			<!---flush the level and group level variables, they get rebuilt in the display loop--->
			<cfset form.Level_1 = "" />
			<cfset form.Level_2 = "" />
			<cfset form.Level_3 = "" />
			<cfset form.GroupLevel_1 = "" />
			<cfset form.GroupLevel_2 = "" />
			<cfset form.GroupLevel_3 = "" />

		</cfif>

		<!---APPLY VOLUME--->
<!--- 		<cfif form.action eq "appVol">

			<cfscript>
				desRebateData = rebate.applyVol(desRebateData,form.applyVol,form.volume);
			</cfscript>

		</cfif> --->

		<!---APPLY RATE TO COMPONENT PRODUCT COMBINATION--->
		<cfif form.action eq "appVolComp">
			<cfparam name="form.apply_basis_code_quantity" 			default="">
			<cfparam name="form.apply_basis_code_quantity_uom" 		default="">
			<cfparam name="form.apply_basis_code_free_goods" 		default="">
			<cfparam name="form.apply_basis_code_free_goods_uom" 	default="">
			<cfscript>
				desRebateData = rebate.applyVolComp(
						desRebateData,
						form.applyVol,
						form.comps,
						form.apply_rate,
						form.apply_uom,
						form.apply_basis_code_quantity,
						form.apply_basis_code_quantity_uom,
						form.apply_basis_code_free_goods,
						form.apply_basis_code_free_goods_uom
						);
			</cfscript>

		</cfif>

		<!---SORTING--->
		<cfif form.action eq "upc" or form.action eq "item" or form.action eq "description" or form.action eq "displaygroupname">

			<cfscript>
				if (ArrayLen(desRebateData.aProd))
				{
					desRebateData = rebate.sort(desRebateData,form.sortBy,form.sortOrder);
				}
			</cfscript>

		</cfif>

		<!---SAVE--->
		<cfif form.action eq "save">
			<!--- lock checker --->
			<CF_Cryp type="en" key="#request.key#" string="#desRebateData.programId#">

			<CFSET LockChecker_CID  = cryp.value>
			<CFINCLUDE TEMPLATE="LockChecker.cfm">

			<!---commit to database--->
			<!------  remove any products that may have been removed by DHTML ----->
			<cfset desRebateData = rebate.remProd(desRebateData,form.Product_List) />
			<cfset rebate.commit(desRebateData,Form.sessionFile, form.Dynamic_Static_Groups) />

			<!---now redirect--->
			<cfscript>
				getProgramType = contract.getProgramId(desRebateData.programId);
			</cfscript>

			<cfif form.deletedateexclusions EQ 1>
			<cfquery name="GetSettings" datasource="#application.datasource#">
			SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
			FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main ON
			Contract_Main.ProgramType_ID =Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			WHERE 	Contract_Main_ID = #desRebateData.programId#
			</cfquery>

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

			<!------ Start Clause Code ----->
			<cfset discountTypeId = 2>
			<cfset programId = desRebateData.programId>
			<cfset templateId = getProgramType.ProgramType_ID>
			<cfset addClauseMode = ArrayLen(desRebateData.aProd) NEQ 0>
			<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
			<!------ End  Clause Code ----->

			<!------ update discount type payment cycle ----->
			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<!--- <cfset appSettings = genSettingsManager.get()> --->
			<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
			<cfif appSettings.getPaymentCycleAtDiscountType()>
				<cfparam name="FORM.PaymentCycle" 	default="0">
				<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
				<cfset paymentCycleManager.savePaymentCycle(desRebateData.programId, 2, FORM.PaymentCycle) />
			</cfif>

			<!--- <CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
			<CFSET redirector_FromPage_ID = 6>
			<cfinclude template="internal_redirector_based_on_settings.cfm">
			<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.value#"> --->

			<cfset marginedit_saved = 1 />

		</cfif>

		<!---now dump data into wddx and pump it out to a file to maintain state--->
		<cfscript>
			desRebateData = rebate.updateWddxDataFile(desRebateData,Form.sessionFile);
		</cfscript>

	</cfif>

</cfif>

<cfscript>
	if (ArrayLen(desRebateData.aProd))
	{
		desRebateData = rebate.sort(desRebateData,form.sortBy,form.sortOrder);
	}
</cfscript>

<!------ Get pricing level descriptions ----->
<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />


<!---//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////End Controller Section////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<CFOUTPUT>
<CFSET PAGE_TITLE= "Product #Application.RebateLabel# Entry">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<!--- <cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
	<CFSET CSL_Contract_Main_ID = temp>
	<CFSET CSL_CallingPageCode = "rebates">


	<cfset FORM.Contract_Main_ID = cryp.value>

	<cfif application.programlayout EQ 1>
		<div id="Layer2" style="position:absolute; width: 140px; height: 400px; z-index: 1; left: 10px; top: 0px;display:none;">
	  		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
		</div>
	<cfelse>
		<div style="display:none;"><CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
	</cfif>

	<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset form.donotallowaddproductsDE = 1>
</CFIF>
</cfif>

	<SCRIPT SRC="component_rebates.js?v=20060510"></script>

	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
	<SCRIPT SRC="/common_Files/contracts/group_functions.js"></SCRIPT>


	<script language="JavaScript">
		<cfoutput>

		var Pricing_Level_1_Desc = "#arPricingLevel[1]#";
		var Pricing_Level_2_Desc = "#arPricingLevel[2]#";
		var Pricing_Level_3_Desc = "#arPricingLevel[3]#";

		var maxComponentPossible = #appSettings.getRebateMaxComponents()#;
		</cfoutput>
		var my_queue = new Queue();

		function verifyDelete(component_id, component_name)
		{
			if(confirm("Are you sure you want to delete " + component_name + "?"))
			{
				document.all.comps.value = component_id;
				document.all.action.value = 'remComp';
				document.all.dataForm.submit();
			}
		}

		var startDataCol = 3;
		<cfif application.returned_customer_setting.upc_switch EQ 0>
			startDataCol = startDataCol - 1;
		</cfif>

		function deleteThisRebate(FieldNameRe, prodID, bgCol, grouplevelID, realGroupLevelId)
		{
			var srcObj = event.srcElement;
			var trObj = getParentObject(srcObj, "tr");
			var trIndex = trObj.rowIndex;
			var FINALITEMLIST = document.dataForm.Product_List.value;
			var level1List = document.dataForm.Level_1.value;
			var level2List = document.dataForm.Level_2.value;
			var level3List = document.dataForm.Level_3.value;
			var level1String = ListDeleteItem(level1List, ",", prodID);
			var level2String = ListDeleteItem(level2List, ",", prodID);
			var level3String = ListDeleteItem(level3List, ",", prodID);
			var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
			var bDelete = true;
			var objGroupLevel;

			objGroupLevel = eval("document.all.GroupLevel_" + grouplevelID);
			if(resultString == FINALITEMLIST)
			{
				resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
				bDelete = false;
				if (grouplevelID == 1)
					level1String = ListAppendItem(level1String, ",", prodID);
				if (grouplevelID == 2)
					level2String = ListAppendItem(level2String, ",", prodID);
				if (grouplevelID == 3)
					level3String = ListAppendItem(level3String, ",", prodID);
			}

			document.dataForm.Level_1.value = level1String;
			document.dataForm.Level_2.value = level2String;
			document.dataForm.Level_3.value = level3String;

			if (!validateGroups())
			{
				document.dataForm.Level_1.value = "";
				document.dataForm.Level_2.value = "";
				document.dataForm.Level_3.value = "";
				document.dataForm.Level_1.value = level1List;
				document.dataForm.Level_2.value = level2List;
				document.dataForm.Level_3.value = level3List;
				return;
			}

			document.all.Product_List.value = resultString;
			document.all.ExistingProductList.value = resultString;
			var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
			if(trObj)
			{
				if(bDelete)
				{
					trObj.height = trObj.offsetHeight;

					trObj.cells[trObj.cells.length-1].innerHTML = empty_String;

					<cfset CompLen = ArrayLen(desRebateData.aComp)>
					for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
					{
					disableDiv(trObj.cells[i+startDataCol], true, false);
					}

					propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);

					srcObj.title = "undo product deletion";
					srcObj.src = undodeleteImg.src;
					//resetnavigate();


				}
				else
				{

					<cfset CompLen = ArrayLen(desRebateData.aComp)>
					for (i=1; i<=<cfoutput>#CompLen#</cfoutput>; i++)
					{
					disableDiv(trObj.cells[i+startDataCol], false, false);
					}
					/*var bgCol = "FFFFFF";
					if(trObj.rowIndex % 2 == 1)
					{
						bgCol = "C6FFC6";
					}*/
					propogateProperty(trObj, "style.backgroundColor", bgCol, false);
					propogateProperty(trObj, "style.textDecoration", "none", false);

					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;

					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);

					if(objGroupLevel.value == "")
						objGroupLevel.value = realGroupLevelId;
				}
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
			}

		}
			function CA() {
			document.all.allbox.checked = event.srcElement.checked;

			if(0==0) {
				for (var i=0;i<dataForm.elements.length;i++)
					{
						var e = dataForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = dataForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
	</script>

</HEAD>

<!---set whether to allow multi level groups--->
<cfif appSettings.getAllowMultiLevelGroups()>
	<cfset form.Allow_Multi_Levels = 1 />
</cfif>

<!--- Test the below scenario on this page --->
<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0 and GetSettings.Discount_Rebate_Max_Rate_On  EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getAllowNavigate()>onbeforeunload="verifyNavigate();"</cfif>>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
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

<cfset restrictLowerLevelBasedonLevel1 = 0 />
<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()><!------ If the app setitngs is on for (Program: If pricing level 1 = groups, allow only products at lower level) ----->
	<cfif ArrayLen(desRebateData.aProd) GT 0>
		<cfset level_1_Group_Type = desRebateData.aProd[1].productGroupLevel />
		<cfif Form.Discount_Rebates_Group_Level EQ 1 AND level_1_Group_Type NEQ "" AND level_1_Group_Type NEQ "0" AND level_1_Group_Type NEQ "9"><!------ If level1 is group, enable product serach ----->
			<cfset Form.Discount_Rebates_Item_Level = 1>
			<cfset restrictLowerLevelBasedonLevel1 = 1 />
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
		{
			var sURL = "product_Select_V1.cfm?Formname=dataForm&Discountype=2";
			if(addProductAtLevel)
			{
				document.all.AllowProductGroupList.value = document.all.Level_1.value;
				sURL = sURL + "&ExistingProductList_Field_Name=Level_" + addProductAtLevel + "&AnotherProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2) + "&Return_Value_Field_Name=Level_" + addProductAtLevel;
				//sURL = sURL + "&ProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2);
				document.all.action.value = "prodlevel" + addProductAtLevel;
			}
			NewWindow(sURL, "productwindow", 800, 600, "yes", "yes")
		}
	}

	function showGroupSearchWindow()
	{
		var prodAtLevel1 = document.all.GroupLevel_1.value;
		//if group level 1 equals 9 then we can't allow groups to be added
		if(prodAtLevel1 == 9)
		{
			alert("Groups cannot be added when products exist at <cfoutput>#arPricingLevel[1]#</cfoutput>.");
			return;
		}

		NewWindow("Groups/index.cfm?formName=dataForm&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&Discountype=2", "productwindow", 800, 600, "yes", "yes");

	}

	function openPopup(url, winW, winH)
	{
		var windowWidth = 200;
		var windowHeight = 210;

		if(winW)
		{
			windowWidth = winW;
		}
		if(winH)
		{
			windowHeight = winH;
		}
		var w = 640/3;
		var h = 480/3;
		var cw = w/2;
		var ch = h/2;

		if (window.screen)
		{
			w = Math.floor(screen.availWidth/3);
    		h = Math.floor(screen.availHeight/3);
    		cw = Math.floor((screen.availWidth-w)/2);
    		ch = Math.floor((screen.availHeight-h)/2);
		}

    	myPopup = window.open(url,'popupWindow','resizable=yes,width='+windowWidth+',height='+windowHeight+',top='+ch+',left='+cw);
    	if (!myPopup.opener)
        	myPopup.opener = self;
	}

	function  validateGroupsDefaultCheckBoxes()
{

	var thisForm = document.dataForm;
	var level1 = thisForm.Level_1.value;
	var level2 = thisForm.Level_2.value;
	var level3 = thisForm.Level_3.value;
	var level1_checked =  false;
	var level2_checked =  false;
	var level3_checked =  false;
	var i, arrLen;

	var bIsValid= true;
	<cfif url.EZTemplate EQ 1>

	if (trim(level1) != "")
	{
	var Arr1 = level1.split(',');
	arrLen = Arr1.length;

	for(i=0;i<arrLen;i++)
	{
	//alert(eval("document.all.Prod_Default_"+replaceChar(Arr[i],'-','_')+".checked"));
		if (eval("document.all.Prod_Default_"+replaceChar(Arr1[i],'-','_')+".checked"))
		{
			level1_checked = true;
		}
	}
	}

	if (trim(level2) != "")
	{
	var Arr2 = level2.split(',');
	arrLen = Arr2.length;

	for(i=0;i<arrLen;i++)
	{
	//alert(eval("document.all.Prod_Default_"+replaceChar(Arr[i],'-','_')+".checked"));
		if (eval("document.all.Prod_Default_"+replaceChar(Arr2[i],'-','_')+".checked"))
		{
			level2_checked = true;
		}
	}
	}

	if (trim(level3) != "")
	{
	var Arr3 = level3.split(',');
	arrLen = Arr3.length;

	for(i=0;i<arrLen;i++)
	{
	//alert(eval("document.all.Prod_Default_"+replaceChar(Arr[i],'-','_')+".checked"));
		if (eval("document.all.Prod_Default_"+replaceChar(Arr3[i],'-','_')+".checked"))
		{
			level3_checked = true;
		}
	}
	}
	//validate group levels
	//if we have something in level 2 or level 3 make sure something is in level 1
	if (level2_checked && level3_checked)
	{
		if(!level1_checked)
		{
			alert(Pricing_Level_1_Desc + " default should be checked if Groups or Products in " + Pricing_Level_2_Desc + " or " + Pricing_Level_3_Desc + "default settings are checked.");
			bIsValid = false;
			return bIsValid;
		}
	}

	//if we have something in level 3 make sure something is in level 1 and 2
	if (level3_checked)
	{
		if(!level2_checked)
		{
			alert(Pricing_Level_2_Desc + " default should be checked if Groups or Products exist in " + Pricing_Level_3_Desc + " default settings are checked.");
			bIsValid = false;
			return bIsValid;
		}
		else if(!level1_checked)
		{
			alert(Pricing_Level_1_Desc + " default should be checked if Groups or Products exist in " + Pricing_Level_2_Desc + " or " + Pricing_Level_3_Desc + " default settings are checked.");
			bIsValid = false;
			return bIsValid;
		}
	}

	//if we have something in level 2 make sure something is in level 1
	if (level2_checked)
	{
		if(!level1_checked)
		{
			alert(Pricing_Level_1_Desc + " default should be checked if Groups or Products exist in " + Pricing_Level_2_Desc + " default settings are checked..");
			bIsValid = false;
			return bIsValid;
		}
	}
	</cfif>
	return bIsValid;
}
</SCRIPT>

<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID />
<CFSET HideProductList = 1 />

<CFSET helpfilenumber=7 />
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:absolute; height:430px; width:200px; z-index:1; left: 10px; top: 10px;">
<!--- <div id="Layer1" style="position:relative; height:430px; width:130px; z-index:1; left: 100px; top:0px;">  ---></cfif>
  <BLOCKQUOTE>
	<cfinclude template="minimal_contract_info.cfm">
	<cf_MessageWindow>
	<!---include file containing all rebate ui functionality--->
	<cfinclude template="_rebate_functions_margin.cfm" />
	<br>
		<CF_smallLink
			title = "close window"
			url = "##"
			parameters = "onClick=""JavaScript: top.close();if(top.opener){top.opener.focus();};"""
		>
	<br>
<cfif EzButton_Disable EQ 0>
	<CF_button
		button_name		=	"save"
		button_caption	=	"save"
		button_action	=	"checksubmit();"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"close this window"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</cfif>
	</BLOCKQUOTE><cfif application.programlayout EQ 1>
  </div>

</cfif>

<script>
function checksubmit()
{
	<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
	if(confirm("The <cfoutput>#approvalGroupType.Label#</cfoutput>'s which are you responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the <cfoutput>#approvalGroupType.Label#</cfoutput>'s you are responsible for again."))
				{
					submitForm('save');
				}
	<cfelse>
		submitForm('save');
	</cfif>
}


</script>
</form>
<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2 and marginedit_saved>
	<cfset overrideClosure = 1>
	<cfset form.programid = '#URL.CID#' />
	<cfinclude template="reset_program_agreed.cfm" />
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>