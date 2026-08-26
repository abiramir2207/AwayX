<!--- Dev Note: CPM 8605  Please keep logic in sync with Off-Invoice.cfm --->
<CFPARAM NAME="Form.DTPS_Program_ID" DEFAULT="">
<CFPARAM NAME="URL.CID" DEFAULT="#Form.DTPS_Program_ID#">

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>

<cfparam name="hideObjects" default="display:none;" />
<cfset DiscountType = 8>
<cfset ComponentMaxCount = 1 /><!------ when this value is 1,
no need to change logic in other stored proc where we use the rate,
but when we start adding multiple components, the stored procs need to be changed to handle for it. ----->

<cfparam name="form.off_invoice_component_info_list" 	default="">
<cfparam name="form.Component_Rate" 	default="">
<cfparam name="form.Component_uom" 	default="">
<cfparam name="form.Component_Polarity" 	default="0">
<cfparam name="form.command" 	default="display">

<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
<cfset programInfo = programManager.getProgramInfo(cryp.value)>


<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />

<!--- Add the Revision Settings Component --->
<cfset Revision_Settings_Allowed = 0>
<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = programInfo.ProgramType_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = CSL_Contract_Main_ID)>
<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(CSL_Contract_Main_ID)>

<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number neq "")>
	<cfset Revision_Settings_Allowed = 1>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset GetSettings = programManager.getProgramTemplateInfo(CSL_Contract_Main_ID) />

<cfset colsAtComponentSection = 4 />

<cfset Display_Basis_Treatment_Code = 0 />
<cfif GetSettings.Include_Treatment_Basis_Code>
	<cfset Display_Basis_Treatment_Code = 1 />
	<cfset colsAtComponentSection = colsAtComponentSection + 1 />
</cfif>

<!--- If the program is a revision and revision settings has retrictions for this program --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
<cfif Not IsDefined("ProgramManager")>
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
</cfif>

<cfif NOT IsDefined("ParentprogramInfo")>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(CSL_Contract_Main_ID)>
</cfif>

<cfif NOT IsDefined("ProgramProducts")>
	<cfset ProgramProducts = CreateObject("component", "components.products.products")/>
</cfif>

<cfif NOT IsDefined("getProgramProducts")>
		<cfset getProgramProducts = ProgramProducts.getproducts('',DiscountType,ParentProgramInfo.Revision_of_Contract_main_id)>
</cfif>

<cfset ProductItemList = queryNew("")>

<cfif getProgramProducts.recordcount neq 0>
	<cfset ProductItemList = ValueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
<cfelse>
	<cfset ProductItemList = "NULL">
</cfif>

<cfelse>
<!--- to avoid an error --->
	<cfset ProductItemList = queryNew("")>
	<cfset ProductItemList = "NULL">
</cfif>

<CFPARAM NAME="form.Level_1" DEFAULT="">
<CFPARAM NAME="form.Level_2" DEFAULT="">
<CFPARAM NAME="form.Level_3" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_1" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_2" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_3" DEFAULT="">
<cfparam name="form.Dynamic_Static_Groups" default="0" />
<cfparam name="form.Group_Deal" default="0" />
<CFPARAM name="form.Allow_Multi_Levels" default="0">
<cfparam name="form.isGroupDealWithGroups" default="0" />
<cfparam name="this.lGroupLevels" default="" />
<cfparam name="this.lGroups" default="" />
<cfparam name="currentheader_id" default="" />
<cfparam name="currentheader" default="" />
<cfparam name="marginedit_saved" default="0">

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

<cfparam name="FORM.Sort_By" 	default="Item">

<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset OffInvoiceDAO = CreateObject("component", "components.programs.Off_Invoice.OffInvoiceDAO") />

<!---set whether to allow multi level groups--->
<cfif appSettings.getAllowMultiLevelGroups()>
	<cfset form.Allow_Multi_Levels = 1 />
</cfif>

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>
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

<CFSET PAGE_TITLE= "Distributor Off-Invoice">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFSET CSL_CallingPageCode = "off-invoice">
<cfset FORM.Contract_Main_ID = CSL_Contract_Main_ID>

<CFSET Help_URL="/help_files/manual/createprogram/page10.cfm">
<cfif application.programlayout EQ 1>

	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px;display:none;">
  		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</div>

<cfelse>

	<div style="display:none;"><CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>

</cfif>


<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(cryp.value)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>

<CFSET GETALLCONTRACTINFO_DISCOUNT_TYPE_ID = 1>

<cfset OnlyPositive = GetSettings.No_Negative_OI>

<!---set if groups are static or dynamic--->
<cfif isDefined("GetSettings.Dynamic_Static_Groups")>
	<cfset form.Dynamic_Static_Groups = GetSettings.Dynamic_Static_Groups />
</cfif>

<cfif isDefined("GetSettings.Group_Deal")>
	<cfset form.Group_Deal = GetSettings.Group_Deal />
</cfif>

<!---set if it's a group deal with groups--->
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfif GroupDataManager.isGroupDeal(FORM.Contract_Main_ID) and form.Group_Deal eq 1>
	<cfset form.isGroupDealWithGroups = 1 />
</cfif>

<!------ Get pricing level descriptions ----->
<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />

<cfset useLakebaseForGETUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGETUOM>
	<cftry>
		<cfset GETUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
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


<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
SELECT     *, dbo.Units_of_Measure.Unit_Of_Measure_Desc
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Item">
<CFSWITCH expression="#FORM.Sort_By#">
	<CFCASE value="Type Code">
		<CFSET sql_Sort_By="Type_Code_Desc.Type_Code_Desc">
	</CFCASE>
	<!--- <CFCASE value="Brand">
		<CFSET sql_Sort_By="dbo.Brand.Brand_Name">
	</CFCASE> --->
	<CFCASE value="Item">
		<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Item">
	</CFCASE>
	<CFCASE value="UPC">
		<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.UPC">
	</CFCASE>
	<CFCASE value="Description">
		<CFSET sql_Sort_By="BSA_Foodservice_Items_Master.Description">
	</CFCASE>
</CFSWITCH>

<!------
We will be storing all selected component level information in the comma separated list off_invoice_component_info_list
format: component_id_1, component_id_2
off_invoice_component_list will hold just the list of components selected
----->
<cfinclude template="off-invoice-functions.cfm" />

<cfset form.off_invoice_component_list = extractOffInvoiceComponentList(form.off_invoice_component_info_list) />

<cfif form.command EQ "addComponent">
	<cfset componentPos = ListFindNoCase(form.off_invoice_component_list, Component_Program_Off_Invoice_Component_Name_ID) />
	<cfif componentPos EQ 0 AND ListLen(form.off_invoice_component_list) LT ComponentMaxCount AND Component_Program_Off_Invoice_Component_Name_ID NEQ "-1">
		<cfparam name="form.Treatment_Code" 	default="">
		<cfparam name="form.Basis_Code" 	default="">
		<cfset form.off_invoice_component_info_list = ListAppend(form.off_invoice_component_info_list,
					compileOffInvoiceComponentInfo(Component_Program_Off_Invoice_Component_Name_ID, form.Treatment_Code, form.Basis_Code)) />
	</cfif>
</cfif>
<cfparam name="form.Del_Component_ID" 	default="">
<cfif form.command EQ "delComponent" and form.Del_Component_ID NEQ "">
	<cfset componentPos = CheckExistOffInvoiceComponentId(form.off_invoice_component_info_list, form.Del_Component_ID) />
	<cfif componentPos NEQ 0>
		<cfset form.off_invoice_component_info_list = ListDeleteAt(form.off_invoice_component_info_list, componentPos) />
	</cfif>
</cfif>

<cfset form.off_invoice_component_list = extractOffInvoiceComponentList(form.off_invoice_component_info_list) />

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<!--- Get it from the database --->
<cfif NOT isDefined("Form.Product_List")>

	<!------ Load From DB ----->
	<cfset sql_Sort_By =  "Type_Code_Desc.Type_Code_Desc" />
	<cfset TheQuery = OffInvoiceDAO.getOIProgramProducts(FORM.Contract_Main_ID, sql_Sort_By) />
	<cfset qGetOIProgramComponents = OffInvoiceDAO.getOIProgramComponents(FORM.Contract_Main_ID) />

	<cfset form.off_invoice_component_info_list = "" />
	<cfloop query="qGetOIProgramComponents">
		<cfset form.off_invoice_component_info_list = ListAppend(form.off_invoice_component_info_list,
					compileOffInvoiceComponentInfo(Program_OffInvoice_Component_Name_ID, Treatment_Code_Master_ID, Basis_Code_Master_ID)) />
	</cfloop>

	<cfset form.off_invoice_component_list = extractOffInvoiceComponentList(form.off_invoice_component_info_list) />

	<cfset UOM = TheQuery.UOM>

	<cfset Form.Product_List = listqualify(ValueList(TheQuery.BSA_Foodservice_Items_Master_ID), chr(39))>

	<cfset useLakebaseForqGetLevel_1_Products = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("thequery")>
<cfif useLakebaseForqGetLevel_1_Products>
	<cftry>
		<cfset qGetLevel_1_Products = application.oLakebase.toQuery(
			application.oLakebase.selectRows("thequery", {
				"product_group_level_id" = "eq.1",
				"select" = "product_group_id"
			}), "product_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLevel_1_Products = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLevel_1_Products>
<cfquery name="qGetLevel_1_Products" dbtype="query">

		SELECT	DISTINCT Product_Group_ID
		FROM	TheQuery
		WHERE
				Product_Group_Level_ID = 1
	</cfquery>
</cfif>

	<cfset FORM.Product_Level_1 = ValueList(qGetLevel_1_Products.Product_Group_ID) />

	<cfif Len(FORM.Product_Level_1) GT 0>

		<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
		<cfset form.Product_List = groupLevelProductId />
		<cfset FORM.groupLevelProducts = 1 />
		<!------ <cfset productGroupLevel = ProductGroupManager.getGroupFromProduct(BSA_Foodservice_Items_Master_ID, 2) /> ----->
	</cfif>

	<!---handle for group deals--->
	<cfif form.isGroupDealWithGroups eq 1>

		<cfloop index="indx" from="1" to="3">

			<!---get groups first--->
			<cfquery name="qGetLevel" dbtype="query">

				SELECT 	DISTINCT BSA_Foodservice_Items_Master_ID
				FROM	TheQuery
				WHERE	Pricing_Level_ID = #indx#

			</cfquery>

			<cfset useLakebaseForqGetGroupLevelId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("thequery")>
<cfif useLakebaseForqGetGroupLevelId>
	<cftry>
		<cfset qGetGroupLevelId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("thequery", {
				"pricing_level_id" = "eq.#indx#",
				"select" = "product_group_level_id"
			}), "product_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroupLevelId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroupLevelId>
<cfquery name="qGetGroupLevelId" dbtype="query">

				SELECT 	DISTINCT Product_Group_Level_ID
				FROM	TheQuery
				WHERE	Pricing_Level_ID = #indx#

			</cfquery>
</cfif>

			<cfset "FORM.Level_#indx#" = ValueList(qGetLevel.BSA_Foodservice_Items_Master_ID) />

			<cfset "form.GroupLevel_#indx#" = qGetGroupLevelId.Product_Group_Level_ID />

		</cfloop>

	</cfif>

<cfelse><!------ else for NOT isDefined("Form.Product_List") ----->
<!--- Get it from the form --->

	<!------ Product Group Code ----->
	<cfparam name="FORM.Product_Level_1" 	default="">
	<cfif Len(FORM.Product_Level_1) GT 0>

		<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
		<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
		<cfset form.Product_List = groupLevelProductId />
		<cfset FORM.groupLevelProducts = 1 />

	</cfif>

	<cfparam name="Form.Product_Search_Window_Return_Type" 	default="0">
	<cfif form.Product_Search_Window_Return_Type EQ 2 OR form.Product_Search_Window_Return_Type EQ 3>
		<cfset form.Product_List = "" />
		<cfset form.Product_List = ListAppend(form.Product_List, form.Level_1, ",") />
		<cfset form.Product_List = ListAppend(form.Product_List, form.Level_2, ",") />
		<cfset form.Product_List = ListAppend(form.Product_List, form.Level_3, ",") />

		<cfset "form.GroupLevel_#form.Product_Search_Window_Return_Type#" = 9 />

	</cfif>

	<cfquery name="qGetOIProgramComponents" datasource="#application.datasource#">
		SELECT	Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name, Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID
		FROM	Program_OffInvoice_Component_Name
		WHERE	Program_OffInvoice_Component_Name.Deleted = 0
		<cfif ListLen(form.off_invoice_component_list) GT 0>
		AND		Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID IN (#form.off_invoice_component_list#)
		<CFELSE>
		AND		1=2
		</cfif>
	</cfquery>

	<cfset Form.Product_List = listqualify(Form.Product_List, chr(39))>

	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT 		DISTINCT
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					<cfif FORM.groupLevelProducts EQ 1>
					'' As UPC,
		            'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products' As Description,
					'' As Item,
					<cfelse>
					BSA_Foodservice_Items_Master.UPC,
		            BSA_Foodservice_Items_Master.Description,
					BSA_Foodservice_Items_Master.Item,
					</cfif>
					' ' AS Program_OffInvoice_Product_Data_ID,
					null AS Discount_Amount,
					dbo.Type_Code_Desc.Type_Code_Desc AS DisplayGroupName,
					<!------' ' AS Volume, ----->
					0 AS Plus_Minus,
					'' AS UOM,
					'' As Basis_Code_Quantity,
					'' As Basis_Code_Quantity_UOM,
					'' As Basis_Code_Free_Goods,
					BSA_Foodservice_Items_Master.Inventory_UM,
					Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID,
					Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name
		FROM 		BSA_Foodservice_Items_Master
		LEFT JOIN 	Program_OffInvoice_Component_Name
		ON			Program_OffInvoice_Component_Name.Deleted = 0
		<cfif ListLen(form.off_invoice_component_list)>
		AND			Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID IN (#form.off_invoice_component_list#)
		<cfelse>
		AND			1=2
		</cfif>
		<cfif FORM.groupLevelProducts EQ 1>
		LEFT JOIN Business_Segment
		ON			Business_Segment.Deleted = 0
		AND			Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
		</cfif>
					LEFT OUTER JOIN	dbo.Type_Code_Desc
					ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
		WHERE
					<CFIF Len(Form.Product_List) GT 0>
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (#preservesinglequotes(Form.Product_List)#)
					<CFELSE>
					1=2
					</CFIF>
		ORDER BY 	#sql_Sort_By#
	</CFQUERY>

	<cfset UOM = GetAllContractInfo.Unit_Of_Measure_ID>

</cfif>

<BLOCKQUOTE><BLOCKQUOTE>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:absolute; height:430px; width:200px; z-index:1; left: 10px; top: 10px;"></cfif>
<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
<CFSET HideProductList = 1>

<CFSET helpfilenumber=7>
<cfinclude template="minimal_contract_info.cfm">

<cf_MessageWindow>

<SCRIPT SRC="/common_Files/contracts/group_functions.js"></SCRIPT>

<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaSCript">
	var my_queue = new Queue();
</SCRIPT>


<cfparam name="Min_OffInvoice_Case" default="">
<cfparam name="Max_OffInvoice_Case" default="">
<cfparam name="Min_OffInvoice_Pound" default="">
<cfparam name="Max_OffInvoice_Pound" default="">
<cfparam name="Min_OffInvoice_Percent" default="">
<cfparam name="Max_OffInvoice_Percent" default="">
<cfparam name="ThereisMinorMax" default="0">

<!---Sets min and max values if they exist for the profile--->
<cfif len(trim(getSettings.Min_OffInvoice_Case)) IS NOT 0>
	<cfset Min_OffInvoice_Case = getSettings.Min_OffInvoice_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_OffInvoice_Case)) IS NOT 0>
	<cfset Max_OffInvoice_Case = getSettings.Max_OffInvoice_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_OffInvoice_Pound)) IS NOT 0>
	<cfset Min_OffInvoice_Pound = getSettings.Min_OffInvoice_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_OffInvoice_Pound)) IS NOT 0>
	<cfset Max_OffInvoice_Pound = getSettings.Max_OffInvoice_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_OffInvoice_Percent)) IS NOT 0>
	<cfset Min_OffInvoice_Percent = getSettings.Min_OffInvoice_Percent>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_OffInvoice_Percent)) IS NOT 0>
	<cfset Max_OffInvoice_Percent = getSettings.Max_OffInvoice_Percent>
	<cfset ThereisMinorMax = 1>
</cfif>

<!--- <SCRIPT SRC="/common_files/scripts/numberValidation.js"></SCRIPT> --->
<SCRIPT>
	<cfoutput>
	var Pricing_Level_1_Desc = "#arPricingLevel[1]#";
	var Pricing_Level_2_Desc = "#arPricingLevel[2]#";
	var Pricing_Level_3_Desc = "#arPricingLevel[3]#";
	</cfoutput>
	<CFOUTPUT>
	function ApplyAmountToSelectedBoxes()
	{
		var trObj = document.all.TR_Products;
		if(trObj)
		{
			var i, trLen = trObj.length;
			var prodIdRe, objAmount, objUOM, objPolarity, objCheck;
			var massApplyAmountValue = document.all.MultiAssign_Rate.value;
			var massApplyUOMValue = document.all.MultiAssign_UOM.value;
			var massApplyPolarityValue = document.all.MultiAssign_Polarity.value;

			var massApplyBasisCodeQuantity = 0, massApplyBasisCodeQuantityUom = 0, massApplyBasisCodeFreeGoods = 0, massApplyEffectMarginPercent = 0;
			<cfif Display_Basis_Treatment_Code>
			massApplyBasisCodeQuantity = document.all.MultiAssign_Basis_Code_Quantity.value;
			massApplyBasisCodeQuantityUom = document.all.MultiAssign_Basis_Code_Quantity_UOM.value;
			massApplyBasisCodeFreeGoods = document.all.MultiAssign_Basis_Code_Free_Goods.value;
			</cfif>

			if(trLen)
			{
				for(i=0;i<trLen;i++)
				{
					prodIdRe = trObj[i].PRODUCT_ID_RE;
					objCheck = eval("document.all.Product_" + prodIdRe);

					if(objCheck)
					{
						if(objCheck.checked)
						{
							ApplyAmountToSelectedBoxesForTD(prodIdRe, massApplyPolarityValue, massApplyAmountValue, massApplyUOMValue, massApplyBasisCodeQuantity, massApplyBasisCodeQuantityUom, massApplyBasisCodeFreeGoods);
						}
					}

				}
			}
			else
			{
					prodIdRe = trObj.PRODUCT_ID_RE;
					objCheck = eval("document.all.Product_" + prodIdRe);

					if(objCheck)
					{
						if(objCheck.checked)
						{
							ApplyAmountToSelectedBoxesForTD(prodIdRe, massApplyPolarityValue, massApplyAmountValue, massApplyUOMValue, massApplyBasisCodeQuantity, massApplyBasisCodeQuantityUom, massApplyBasisCodeFreeGoods);
						}
					}

			}
		}
	}

	function ApplyAmountToSelectedBoxesForTD(prodIdRe, massApplyPolarityValue, massApplyAmountValue, massApplyUOMValue, massApplyBasisCodeQuantity, massApplyBasisCodeQuantityUom, massApplyBasisCodeFreeGoods)
	{
		var i, tdLen, compProdIdRe, compId, chkComp;
		var tdObj = eval("document.all.TD_" + prodIdRe);
		var objAmount, objUOM, objPolarity, basisCodeQuantity, basisCodeQuantityUOM, basisCodeFreeGoods, basisCodeFreeGoodsUOM;
		if(tdObj)
		{
			tdLen = tdObj.length;
			if(tdLen)
			{
				for(i=0;i<tdLen;i++)
				{
					compProdIdRe = tdObj[i].COMP_PRODUCT_ID_RE;
					compId = tdObj[i].COMP_ID;
					chkComp = eval("document.all.Check_C_" + compId);

					if(chkComp.checked)
					{
						objAmount = eval("document.all.OffInvoice_Value_" + compProdIdRe);
						objUOM = eval("document.all.OffInvoice_UOM_" + compProdIdRe);
						objPolarity = eval("document.all.Plus_Minus_" + compProdIdRe);

						objAmount.value = massApplyAmountValue;
						changeUOMTo(objUOM, massApplyUOMValue);
						changeUOMTo(objPolarity, massApplyPolarityValue);

						basisCodeQuantity = eval("document.all.comp_basis_code_quantity_" + compProdIdRe);
						basisCodeQuantityUOM = eval("document.all.comp_basis_code_quantity_uom_" + compProdIdRe);
						basisCodeFreeGoods = eval("document.all.comp_basis_code_quantity_" + compProdIdRe);
						basisCodeFreeGoodsUOM = eval("document.all.comp_basis_code_quantity_uom_" + compProdIdRe);

						if(basisCodeQuantity) basisCodeQuantity.value = massApplyBasisCodeQuantity;
						if(basisCodeQuantityUOM) changeUOMTo(basisCodeQuantityUOM, massApplyBasisCodeQuantityUom);
						if(basisCodeFreeGoods) basisCodeFreeGoods.value = massApplyBasisCodeFreeGoods;
						if(basisCodeFreeGoodsUOM) changeUOMTo(basisCodeFreeGoodsUOM, massApplyBasisCodeQuantityUom);

					}
				}
			}
			else
			{
					compProdIdRe = tdObj.COMP_PRODUCT_ID_RE;
					compId = tdObj.COMP_ID;
					chkComp = eval("document.all.Check_C_" + compId);

					if(chkComp.checked)
					{
						objAmount = eval("document.all.OffInvoice_Value_" + compProdIdRe);
						objUOM = eval("document.all.OffInvoice_UOM_" + compProdIdRe);
						objPolarity = eval("document.all.Plus_Minus_" + compProdIdRe);
						objAmount.value = massApplyAmountValue;
						changeUOMTo(objUOM, massApplyUOMValue);
						changeUOMTo(objPolarity, massApplyPolarityValue);

						basisCodeQuantity = eval("document.all.comp_basis_code_quantity_" + compProdIdRe);
						basisCodeQuantityUOM = eval("document.all.comp_basis_code_quantity_uom_" + compProdIdRe);
						basisCodeFreeGoods = eval("document.all.comp_basis_code_free_goods_" + compProdIdRe);

						if(basisCodeQuantity) basisCodeQuantity.value = massApplyBasisCodeQuantity;
						if(basisCodeQuantityUOM) changeUOMTo(basisCodeQuantityUOM, massApplyBasisCodeQuantityUom);
						if(basisCodeFreeGoods) basisCodeFreeGoods.value = massApplyBasisCodeFreeGoods;

					}
			}
		}
	}

	function ApplyAmountToSelectedBoxes2()
	{
		if(#TheQuery.recordcount# > 0)
		{
			if(document.all.checkBoxCollection)
			{
				if(document.all.checkBoxCollection.length != null){
					for(var x = 0; x<document.all.MyForm.elements.length; x++)
					{
						e=document.all.MyForm.elements[x]
						if(e.type == "checkbox")
						{
							if(e.APPLYMASSRATE != null)
							{
								if(e.checked)
								{
									eval("document.all." + e.APPLYMASSRATE + ".value=" + "'" + document.all.Discount_Amount.value + "'")
								}
							}
						}
					}
				}
				else
				{
					if(document.all.checkBoxCollection.firstChild.checked)
					{
						eval("document.all." + document.all.checkBoxCollection.firstChild.APPLYMASSRATE).value = document.all.Discount_Amount.value;
					}
				}
			}
		}
	}
	</CFOUTPUT>
	function formatRate(oInput, fne){
		useAlternateFormat = 0;
		tb = oInput;
		us = eval('document.all.OffInvoice_Value_' + fne)

		clenseText(tb,'0123456789.')

		if(us.selectedIndex == 3) {
			decimalCount = 2;
			adjustPlace = 3;
		}
		else{
    		decimalCount = 4
			adjustPlace = 0;
		}

		if(event.type == "keyup") {
			if(tb.value.indexOf(".") != -1) {
				if(tb.value.length - tb.value.indexOf(".") >= (5-adjustPlace)) {
					var validNumber = new NumberFormat();
					validNumber.setCommas(false);
					validNumber.setCurrency(false);
					validNumber.setPlaces(decimalCount);
					validNumber.setNumber(tb.value);
					tb.value = validNumber.toFormatted();
				}
			}
		}

		if(event.type == "blur" || event.type == "change") {
			var validNumber = new NumberFormat();
			validNumber.setCommas(false);
			validNumber.setCurrency(false);
			validNumber.setPlaces(decimalCount);
			validNumber.setNumber(tb.value);
			tb.value = validNumber.toFormatted();
		}

		if(us.selectedIndex == 2) {
			if(parseInt(tb.value) > 100) {
				alert("You cannot exceed 100%")
				tb.value = "0.0"
			}
		}
	}


	var ErrorCount = 0;
	var TotalWeeklyVolume = 0;
	function check_This_Product(trObj)
	{
		var product_Name_Re = trObj.PRODUCT_ID_RE;
		var bDelete = 1;
		if(trObj.bDelete != "undefined")
		{
			bDelete = trObj.bDelete;
		}

		if(product_Name_Re && bDelete == 0)
		{
			var i, tdLen, compProdIdRe;
			var tdObj = eval("document.all.TD_" + product_Name_Re);
			if(tdObj)
			{
			tdLen = tdObj.length;
			if(tdLen)
			{
				for(i=0;i<tdLen;i++)
				{
					check_This_Product_Component(tdObj[i].COMP_PRODUCT_ID_RE);
				}
			}
			else
			{
				check_This_Product_Component(tdObj.COMP_PRODUCT_ID_RE);
			}
		}
	}
	}

	function check_This_Product_Component(COMP_PRODUCT_ID_RE)
	{
		var product_Name_Re = COMP_PRODUCT_ID_RE;

		if(product_Name_Re)
		{
			tempPriceObject			= eval("document.all.OffInvoice_Value_" + product_Name_Re)
			tempUOMObject			= eval("document.all.OffInvoice_UOM_" + product_Name_Re)
			tempPriceObjectSpan		= eval("document.all.error_Price_" + product_Name_Re)

			var BasisCodeTypeId = 0;
			var ObjBasisCodeType = eval("document.all.basisCodeType_" + product_Name_Re)
			if(ObjBasisCodeType)
			{
				if(ObjBasisCodeType.value != "0")
				{
					BasisCodeTypeId = 1;
				}
			}

			if(BasisCodeTypeId == "0")
			{

			if(tempPriceObject.value.length == 0){
				ErrorCount++
				queueMessage("Enter a price", tempPriceObjectSpan)
			}

			<cfif ThereisMinorMax IS 1>
				<!---Pounds first--->
				else if((tempUOMObject.value == 2) && (tempPriceObject.value != ""))
				{
					<Cfif len(trim(Min_OffInvoice_Pound)) IS NOT 0>
					<!---Pounds Min--->
					if(tempPriceObject.value < <cfoutput>#Min_OffInvoice_Pound#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be greater than <cfoutput>#Min_OffInvoice_Pound#</cfoutput>", tempPriceObjectSpan)
					}
					</CFIF>

					<Cfif len(trim(Max_OffInvoice_Pound)) IS NOT 0 AND Max_OffInvoice_Pound IS NOT 0>
					<!---Pounds Max--->
					if(tempPriceObject.value > <cfoutput>#Max_OffInvoice_Pound#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be less than <cfoutput>#Max_OffInvoice_Pound#</cfoutput>", tempPriceObjectSpan)
					}
					</cfif>

				}

				<!---Cases--->
				else if((tempUOMObject.value == 1) && (tempPriceObject.value != ""))
				{
					<Cfif len(trim(Min_OffInvoice_Case)) IS NOT 0>
					<!---Pounds Min--->
					if(tempPriceObject.value < <cfoutput>#Min_OffInvoice_Case#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be greater than <cfoutput>#Min_OffInvoice_Case#</cfoutput>", tempPriceObjectSpan)
					}
					</cfif>

					<Cfif len(trim(Max_OffInvoice_Case)) IS NOT 0 AND Max_OffInvoice_Case IS NOT 0>
					<!---Pounds Max--->
					if(tempPriceObject.value > <cfoutput>#Max_OffInvoice_Case#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be less than <cfoutput>#Max_OffInvoice_Case#</cfoutput>", tempPriceObjectSpan)
					}
					</cfif>

				}

				<!---Percent--->
				else if((tempUOMObject.value == 3) && (tempPriceObject.value != ""))
				{
					<Cfif len(trim(Min_OffInvoice_Percent)) IS NOT 0>
					<!---Pounds Min--->
					if(tempPriceObject.value < <cfoutput>#Min_OffInvoice_Percent#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be greater than <cfoutput>#Min_OffInvoice_Percent#</cfoutput>", tempPriceObjectSpan)
					}
					</CFIF>

					<Cfif len(trim(Max_OffInvoice_Percent)) IS NOT 0 AND Max_OffInvoice_Percent IS NOT 0>
					<!---Pounds Max--->
					if(tempPriceObject.value > <cfoutput>#Max_OffInvoice_Percent#</cfoutput>)
					{
						ErrorCount++
						queueMessage("The price must be less than <cfoutput>#Max_OffInvoice_Percent#</cfoutput>", tempPriceObjectSpan)
					}
					</cfif>

				}

				</cfif>

			else {
				clearQueue(tempPriceObjectSpan)
			}
		}
	}
	}

	function verifyData() {
		var oForm = document.MyForm;
		var tr_Products_obj = document.all.TR_Products;
		ErrorCount = 0;
		TotalWeeklyVolume = 0;
		<!------ TODO ----->

		if(!validateGroups())
		{
			return false;
		}
		if(!validateProductsUnderGroupAtLevel1(document.MyForm))
		{
			return false;
		}
		// check if there are any components selected
		var componentList = oForm.off_invoice_component_list.value;
		if(componentList.length == 0)
		{
			alert("You need to select atleast one component before saving");
			return false;
		}

		if(tr_Products_obj)
		{
			if(tr_Products_obj.length)
			{
				for(var x=0;x<tr_Products_obj.length;x++)
				{
					check_This_Product(tr_Products_obj[x]);
				}

			}
			else
			{
				check_This_Product(tr_Products_obj);
			}
		}


		if(ErrorCount==0){
			disableButton("save_table", true, false);
			document.MyForm.action = "off-invoice_action.cfm";
			document.MyForm.submit();
		}
		else {
			showMessageWindow();
		}
	}

	//function to set all products checkboxes of same type_code to checked
	function checkMatchingProd(type_code,header)
	{
		var elemColctn2 = document.MyForm.getElementsByTagName("input");
		for (var i = 0; i < elemColctn2.length; i++)
		{
			if (elemColctn2[i].id == type_code)
			{
				if (header.checked)
					elemColctn2[i].checked = true;
				else
					elemColctn2[i].checked = false;
			}
		}
	}
	//end check checkmatchingProd()

	function threeDecimalPlaces(textObject){
		if(event.type == "keyup") {

			if(textObject.value.indexOf(".") != -1) {
				if(textObject.value.length - textObject.value.indexOf(".") >= 5) {
					var validNumber = new NumberFormat();
					validNumber.setCommas(false);
					validNumber.setCurrency(false);
					validNumber.setPlaces(4);
					validNumber.setNumber(textObject.value);
					textObject.value = validNumber.toFormatted();
					textObject.select();
				}
			}
		}

		if(event.type == "blur") {
			var validNumber = new NumberFormat();
			validNumber.setCommas(false);
			validNumber.setCurrency(false);
			validNumber.setPlaces(4);
			validNumber.setNumber(textObject.value);
			textObject.value = validNumber.toFormatted();
		}
	}


	//validate groups
	function validateGroups()
	{
		var thisForm = document.MyForm;
		var level1 = thisForm.Level_1.value;
		var level2 = thisForm.Level_2.value;
		var level3 = thisForm.Level_3.value;

		var bIsValid= true;

		//validate group levels
		if (trim(level2) != "" || trim(level3) != "" )
		{
			if(trim(level1) == "")
			{
				alert("<cfoutput>#arPricingLevel[1]#</cfoutput> cannot be empty if Groups or Products exist in <cfoutput>#arPricingLevel[2]#</cfoutput> or <cfoutput>#arPricingLevel[3]#</cfoutput>.");
				bIsValid = false;
				return bIsValid;
			}
		}

		return bIsValid;
	}


</SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT>

		function CA(chNameStart) {
			document.all.allbox.checked = event.srcElement.checked;
			var chNameStartLen = chNameStart.length;
			for (var i=0;i<MyForm.elements.length;i++)
			{
				var e = MyForm.elements[i];
				if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY'))
				{
					if(e.name.substr(0, chNameStartLen) == chNameStart)
					{
						e.checked = MyForm.allbox.checked;
					}
				}
			}

		}

		function applyGlobalUOM()
		{
			gUOM = document.all.Global_UOM.value;

			if(document.all.UOMCollection != null)
			{
				if(UOMCollection.length != null)
				{
					for(var x = 0; x<UOMCollection.length;x++)
					{
						e=document.all.checkBoxCollection[x].firstChild
						if(e.checked)
						{
							changeUOMTo(UOMCollection[x].firstChild, gUOM);
						}
					}
				}
				else
				{
					e=document.all.checkBoxCollection.firstChild
					if(e.checked)
					{
						changeUOMTo(UOMCollection.firstChild, gUOM);
					}
				}
			}
		}
		function changeUOMTo(selObj, selValue)
		{
			var optObj = Get_Object_Property_Match_Collection(selObj.options, "value", selValue)
			if(optObj)
			{
				optObj.selected = true;
				selObj.fireEvent("onchange");
				//?resetnavigate();
			}
		}

		function applyUniversalPolarity(){
			uPolarity = document.all.UniversalPolarity.selectedIndex;

			if(document.all.PolarityCollection != null){
				if(UOMCollection.length != null){
					for(var x = 0; x<PolarityCollection.length;x++){
						e=document.all.checkBoxCollection[x].firstChild
						if(e.checked)
						{
							PolarityCollection[x].firstChild.selectedIndex = uPolarity;
							PolarityCollection[x].firstChild.fireEvent("onchange")
						}
					}
				}
				else{
					e=document.all.checkBoxCollection.firstChild
					if(e.checked)
					{
						PolarityCollection.firstChild.selectedIndex = uPolarity;
						PolarityCollection.firstChild.fireEvent("onchange")
					}
				}
			}
		}

		function sort_by_This(thisVal)
		{
			document.MyForm.Sort_By.value = thisVal;
			document.MyForm.submit();
			return false;
		}
	<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
</SCRIPT>



<SCRIPT>
	function addGroupsLevelProducts(groupLevel, groupId)
	{
		if(window.confirm('Do you want to add all the products?'))
		{
			if(groupLevel != 0)
			{
				var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
				groupIdListObj.value = groupId;
				document.MyForm.submit();
			}
		}
	}

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
				//alert(document.all.ProductList.value);
				//if groupLevel = 1
				var oForm = document.MyForm;
				oForm.groupLevelProducts.value = "0";
				oForm.Product_Level_1.value = "";
				oForm.Product_List.value = "";
				oForm.ProductList.value = "";
				oForm.ExistingProductList.value = "";
				bSelectedAllProducts = false;
			}
		}
		if(!bSelectedAllProducts)
		{

			var sURL = "product_Select_V1.cfm?Formname=MyForm&Discountype=8";

			if(addProductAtLevel)
			{
				document.all.AllowProductGroupList.value = document.all.Level_1.value;
				sURL = sURL + "&ExistingProductList_Field_Name=Level_" + addProductAtLevel + "&AnotherProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2) + "&Return_Value_Field_Name=Level_" + addProductAtLevel;
				document.MyForm.Product_Search_Window_Return_Type.value = addProductAtLevel;
			}
			NewWindow(sURL, "productwindow", 800, 600, "yes", "yes")
		}
	}

	function showGroupSearchWindow()
	{
		//do validation first
		var oForm = document.MyForm;
		var prodList = oForm.Product_List.value;
		var level1List = oForm.Level_1.value;

		//if we have a product list but nothing in level 1 then we can't allow adding groups
		if(prodList != "" && level1List == "")
		{
			alert("Groups cannot be added when products exist in <cfoutput>#arPricingLevel[1]#</cfoutput>.");
			return;
		}
		NewWindow("Groups/index.cfm?formName=MyForm&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&Discountype=8", "productgroupwindow", 800, 600, "yes", "yes");

	}

</SCRIPT>
<cfset businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />

<cfparam name="Show_Products" default="1">


<!------ set revision settings variables ----->
<cfset Revision_Products_Rates_Changes = 1 />
<cfset Revision_Products_UOM_Changes = 1 />
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2>
	<cfset Revision_Products_Rates_Changes = 0 />
</cfif>
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2>
	<cfset Revision_Products_UOM_Changes = 0 />
</cfif>


<!---If search sequences are on, modify what they're allowed to see (product or group) based on search sequences as well as other template settings--->
<cfif appSettings.getSearchSequenceOn()>
	<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(CSLGETCONTRACTINFO.Search_Sequence_ID) />
	<cfset 	Form.Show_Products =  SearchSequenceManager.enableProductSelection(Program_Search_Sequence) />
	<cfset 	Form.Group_Deal = SearchSequenceManager.enableGroupSelection(Program_Search_Sequence) />
</cfif>

<cfset restrictLowerLevelBasedonLevel1 = 0 />
<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()><!------ If the app setitngs is on for (Program: If pricing level 1 = groups, allow only products at lower level) ----->
	<cfif form.Level_1 NEQ "">
		<cfset level_1_Group_Type = GroupLevel_1 />
		<cfif Form.Group_Deal EQ 1 AND level_1_Group_Type NEQ "" AND level_1_Group_Type NEQ "0" AND level_1_Group_Type NEQ "9"><!------ If level1 is group, enable product serach ----->
			<cfset Show_Products = 1>
			<cfset restrictLowerLevelBasedonLevel1 = 1 />
		</cfif>
	</cfif>
</cfif>

<!------
Inorder to make sure that products in level 2 and level 3 are a sub set of Level 1
- 	Product search is filtered against Level 1 using the input fields AllowProductGroupList and AllowProductGroupLevelId
- 	But still user can select group, select product, then use scissors to change/delete the original group selection,
	in that case check this list while submitting the form
----->
<cfset qProductGroupValuesForItem = QueryNew("Product_ID,Group_ID") />
<cfset Real_Product_List = Replace(Form.Product_List, "'", "", "all") />
<cfif ListLen(Real_Product_List) GT 0>
	<cfif restrictLowerLevelBasedonLevel1>
		<cfset productGroupAttributeManager 	= CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
		<cfset productGroupType 				= productGroupAttributeManager.getGroupTypeInfo(groupLevelId=level_1_Group_Type) />
		<cfset qProductGroupValuesForItem 		= productGroupAttributeManager.getProductGroupValuesForItem(
				productGroupType=productGroupType,
				productIDList	=Real_Product_List) />
	</cfif>
</cfif>

<cfset offinvoiceCompObj = CreateObject("component","components.programs.Off_Invoice.OffInvoiceComponent") />

<CFOUTPUT>
<FORM ACTION="off-invoice_margin.cfm?CID=#url.CID#" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
</CFOUTPUT>

<!------ Component selection ----->
<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Off-Invoice Component Information</LEGEND>

<cfset arAllowList = ArrayNew(1) />
<cfset arDisAllowList = ArrayNew(1) />
<cfset bTemplateLevelComponentFilter = 1 />
<!------ Operating Group ----->
<cfset componentsUnderOperatingGroupLevel2 = "" />
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=CSL_Contract_Main_ID) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 8) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2 />
	<cfset bTemplateLevelComponentFilter = 0 />
</cfif>
<!------ Operating Group ----->
<cfif bTemplateLevelComponentFilter>
	<!--- get a list of comps to filter based on template --->
	<cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 8, 1) />
	<cfset lTemplateAllowList = ValueList(qComponents.Component_ID) />
	<cfset arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList />
</cfif>

<cfset arDisAllowList[ArrayLen(arDisAllowList) + 1] = form.off_invoice_component_list />

<cfset GetOffinvoiceComponents = offinvoiceCompObj.getActive(arAllowList, arDisAllowList) />

<cfif Display_Basis_Treatment_Code>
	<cfquery name="qComponentNames" dbtype="query">
		SELECT	Program_OffInvoice_Component_Name_ID Component_Name_ID, Allowance_Code_ID Component_Allowance_Code_ID
		FROM	GetOffinvoiceComponents
	</cfquery>
	<cfinclude template="Contract_Basis_Tratment_Code.cfm" />
</cfif>

<table WIDTH="250" border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td COLSPAN="<cfoutput>#colsAtComponentSection#</cfoutput>" STYLE="border-bottom:solid 1px blue;<cfoutput>#hideObjects#</cfoutput>"><B>Components</B></td>
		<td BGCOLOR="white" ROWSPAN="3" style="<cfoutput>#hideObjects#</cfoutput>">&nbsp;&nbsp;</td>
		  <td COLSPAN="3" STYLE="border-bottom:solid 1px blue;#hideObjects#">
			<B>Multi Assignment Tool</B>&nbsp;&nbsp;&nbsp;
			<font color="#0000FF" size="3" title="Use this feature to make adjustments to the price/uom for any item/component combinations listed below." STYLE="cursor:pointer">
				<b>?</b>
			</font>
		  </td>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
		<td BGCOLOR="white" ROWSPAN="3" style="<cfoutput>#hideObjects#</cfoutput>">&nbsp;&nbsp;</td>
		<td style="<cfoutput>#hideObjects#</cfoutput>"><B>Select Payment Cycle</B></td>
		</cfif>
	</tr>
	<tr BGCOLOR="eeeeee">
		<td style="<cfoutput>#hideObjects#</cfoutput>"> Component Name</td>
		<td style="<cfoutput>#hideObjects#</cfoutput>">+/-</td>
		<td style="<cfoutput>#hideObjects#</cfoutput>">Default Price Adj.</td>
		<td style="<cfoutput>#hideObjects#</cfoutput>">UOM</td>
		<cfif Display_Basis_Treatment_Code>
		<td style="<cfoutput>#hideObjects#</cfoutput>">Treatment Code/Basis Code</td>
		</cfif>
		<td>+/-</td>
		<td>Price Adj.</td>
		<td>UOM</td>
	</tr>
	<TR>
	<TD style="<cfoutput>#hideObjects#</cfoutput>">
	  <cfoutput>
		<select name="Component_Program_Off_Invoice_Component_Name_ID" style="width:180px"
			<cfif Display_Basis_Treatment_Code> onchange="loadDefaultBasisTreatmentCodeForComponentName(this.value);"</cfif>
			>
			<option value="-1" selected>Select Off-Invoice Component</option>
			<cfloop query="GetOffinvoiceComponents">
			<option value="#Program_OffInvoice_Component_Name_ID#" <cfif GetOffinvoiceComponents.recordcount EQ 1>selected</cfif>>#Program_OffInvoice_Component_Name#
			<cfif application.returned_customer_setting.external_id_on EQ 1>
			<cfif Len(External_ID) GT 0>
			(#External_ID#)
			</cfif>
			</cfif>
			</option>
		</cfloop>
		</select>
		</cfoutput>
	</TD>
	<td style="<cfoutput>#hideObjects#</cfoutput>">
	 <select name="Component_Polarity">
	 	<option value="0">-</option>
		<cfif OnlyPositive IS NOT 1>
		<option value="1">+</option>
		</cfif>
	</select>
	</td>
	<td style="<cfoutput>#hideObjects#</cfoutput>"><input name="Component_Rate" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDecimalPlaces(this.value,4)"/></td>
	<td style="<cfoutput>#hideObjects#</cfoutput>">
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"Component_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"8"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1
			>
		</td>
		<cfif Display_Basis_Treatment_Code EQ 1>
		<td style="<cfoutput>#hideObjects#</cfoutput>">
		<select name="Treatment_Code" style="width:140px" onchange="loadBasisCodes(this.value);">
			<option value="0">Select Treatment Code...</option>
			<cfloop query="qGetTreatmentCodes">
			<cfoutput><option value="#Treatment_Code_Master_ID#">#Treatment_Code_Desc#</option></cfoutput>
			</cfloop>
		</select>
		<br>
		<select name="Basis_Code" style="width:140px">
			<option value="0">Select Basis Code...</option>
		</select>
		</td>
		</cfif>
		<script language="JavaScript">
		<cfif GetOffinvoiceComponents.recordcount EQ 1>
		document.all.Component_Program_Off_Invoice_Component_Name_ID.fireEvent("onchange");
		</cfif>
		</script>
		<cfset disabled = 0>
		 <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2>
			<cfset disabled = 1>
		 </cfif>
		<td>
		 <select name="MultiAssign_Polarity" <cfif disabled EQ 1>STYLE="background-color: cccccc" DISABLED</cfif>>
		 	<option value="0">-</option>
			<cfif OnlyPositive IS NOT 1>
			<option value="1">+</option>
			</cfif>
		</select>
		<cfif Display_Basis_Treatment_Code>
		<br>&nbsp;<b>buy</b><br>
		<input name="MultiAssign_Basis_Code_Quantity" type="text" size="1" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDecimalPlaces(this.value,4)"  <cfif disabled eq 1>STYLE="background-color: cccccc" DISABLED</cfif>/>
		</cfif>
		</td>
		<td><input name="MultiAssign_Rate" type="text" size="1" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDecimalPlaces(this.value,4)"  <cfif disabled eq 1>STYLE="background-color: cccccc" DISABLED</cfif>/>
		<cfif Display_Basis_Treatment_Code>
		<br>&nbsp;<br>
		<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"MultiAssign_Basis_Code_Quantity_UOM"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"8"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	"3"
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1
				disabled				=	"#disabled#"
			>
		</cfif>
		</td>
		<td>
			<cf_uom_dropdown
				program_id				=	"#FORM.Contract_Main_ID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	"0"
				dropdown_name			=	"MultiAssign_UOM"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"8"
				program_template_id		=	""
				selected_uom_id			=	""
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	1
				disabled				=	"#disabled#"
			>
		<cfif Display_Basis_Treatment_Code>
			<br>&nbsp;<b>get</b><br>
			<input name="MultiAssign_Basis_Code_Free_Goods" type="text" size="1" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDecimalPlaces(this.value,4)"  <cfif disabled eq 1>STYLE="background-color: cccccc" DISABLED</cfif>/>
		</cfif>
		</td>
		<td>
		&nbsp;<br>&nbsp;
		</td>
	</TR>
	<tr BGCOLOR="eeeeee">
		<td style="<cfoutput>#hideObjects#</cfoutput>" colspan="<cfoutput>#colsAtComponentSection#</cfoutput>"><B><font color="FF0000">[</font> <a onclick="javascript:addComponent();" STYLE="cursor: pointer;">include this off-invoice component</a> <font color="FF0000">]</font></B></td>
		<td width="27" BGCOLOR="White" style="<cfoutput>#hideObjects#</cfoutput>">&nbsp;&nbsp;&nbsp;</td>
		<td colspan="3"><B><font color="FF0000">[</font>
		<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND RevisionSettings.Products_Rates_Changes eq 2)>
		<a onclick="javascript:ApplyAmountToSelectedBoxes();" STYLE="cursor: pointer;">apply this price / uom / +/-</a>
		<cfelse>
		<span style="color:gray">apply this price / uom / +/-</span>
		</cfif>
		<font color="FF0000">]</font></B>
		</td>
	</tr>
</table>
</FIELDSET>

<table>
<tr>
	<td style="display:none;">
		<CF_SmallHelp width="400">Specify the adjustment for each item here. Click on the save button when you are done.</CF_SmallHelp>
	</td>
	<td>
		<CF_button
			button_name		=	"save"
			button_caption	=	"save"
			button_action	=	"verifyData();"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</td>

	<cfif Form.Group_Deal eq 1>
	<cfset addGroupLabel = "add groups" />
	<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()>
		<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
	</cfif>
	<td style="<cfoutput>#hideObjects#</cfoutput>">
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND RevisionSettings.Products_Added eq 2>
		<CF_button
			button_name		=	""
			button_caption	=	"#addGroupLabel#"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			enabled			=	"0"
		>
	<cfelse>
		<CF_button
			button_name		=	""
			button_caption	=	"#addGroupLabel#"
			button_action	=	"javascript: showGroupSearchWindow();"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>

	</cfif>
	</td>
	</cfif>
	<cfif Show_Products IS 1>
	<td  style="<cfoutput>#hideObjects#</cfoutput>">
		<cfset addProductLabel = "add products" />
		<cfset addProductAtLevel = 0 /> <!------ Default, determine by itself ----->
		<cfset provideLevel3Link = 0 />
		<cfif restrictLowerLevelBasedonLevel1>
			<cfset addProductLabel = "add #LCase(arPricingLevel[2])# products" />
			<cfset addProductAtLevel = 2 /> <!------ At level 2 ----->
			<cfset provideLevel3Link = 1 />
<!--- 			<cfif form.Level_2 NEQ "">
				<cfset provideLevel3Link = 1 />
			</cfif> --->
		</cfif>
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND RevisionSettings.Products_Added eq 2>
		<CF_button
			button_name		=	""
			button_caption	=	"#addProductLabel#"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			enabled			=	"0"
		>
	<cfelse>
		<CF_button
			button_name		=	""
			button_caption	=	"#addProductLabel#"
			button_action	=	"showProductSearchWindow(#addProductAtLevel#);"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</cfif>
	</td>
	</cfif>
	<cfif provideLevel3Link>
	<td style="<cfoutput>#hideObjects#</cfoutput>">
		<cfset addProductLabel = "add #LCase(arPricingLevel[3])# products" />
		<cfset addProductAtLevel = 3 /> <!------ At level 3 ----->
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND RevisionSettings.Products_Added eq 2>
		<CF_button
			button_name		=	""
			button_caption	=	"#addProductLabel#"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			enabled			=	"0"
		>
	<cfelse>
		<CF_button
			button_name		=	""
			button_caption	=	"#addProductLabel#"
			button_action	=	"showProductSearchWindow(#addProductAtLevel#);"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</cfif>
	</td>
	</cfif>
	<cfif ProductGroupManager.allowSelectAllProducts(8, FORM.Contract_Main_ID)>
	<td style="<cfoutput>#hideObjects#</cfoutput>">
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND RevisionSettings.Products_Added eq 2>
		<CF_button
			button_name		=	""
			button_caption	=	"add all products"
			button_action	=	"javascript: addGroupsLevelProducts(1, \'#businessSegmentID#\');"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	<cfelse>
		<CF_button
			button_name		=	""
			button_caption	=	"add all products"
			button_action	=	"javascript: addGroupsLevelProducts(1, \'#businessSegmentID#\');"
			button_type		=	"link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</cfif>
	</td>
	</cfif>
</tr>
</table>

<cfscript>

	function checkGroups(lGroupLevels)
	{
		var arg_count = ListLen(lGroupLevels);
		var hasGroups = 0;
		var i = 0;
		for( i = 1 ; i LTE arg_count; i = i + 1 )
		{
	  		if (trim(ListGetAt(lGroupLevels, i)) neq "" and trim(ListGetAt(lGroupLevels, i)) neq 9)
	  		{
				hasGroups = 1;
			}
		}

		return hasGroups;
	}

	count = 3;
	i = 0;
	for( i = 1 ; i LTE count; i = i + 1 )
	{
		if (trim(Evaluate("form.GroupLevel_" & i)) neq "" and trim(Evaluate("form.GroupLevel_" & i)) neq 9)
		{
			this.lGroupLevels = ListAppend(this.lGroupLevels, Evaluate("form.GroupLevel_" & i));
		}
	}

</cfscript>

<cfset isMultiLevelGroups = checkGroups(this.lGroupLevels) and appSettings.getAllowMultiLevelGroups() />

<script language="JavaScript">
	var startDataCol = 4;
	<cfif isMultiLevelGroups>
		startDataCol = startDataCol + 1;
	</cfif>
	<cfif application.returned_customer_setting.upc_switch EQ 0>
		startDataCol = startDataCol - 1;
	</cfif>
	function deleteThisOffInvoice(FieldNameRe, prodID, prodIdUnStripped, grouplevelID, realGroupLevelId)
	{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.MyForm.ProductList.value;
		var LEVEL1BUCKET = document.MyForm.Level_1.value;
		var LEVEL2BUCKET = document.MyForm.Level_2.value;
		var LEVEL3BUCKET = document.MyForm.Level_3.value;
		var level1String = ListDeleteItem(LEVEL1BUCKET, ",", prodIdUnStripped);
		var level2String = ListDeleteItem(LEVEL2BUCKET, ",", prodIdUnStripped);
		var level3String = ListDeleteItem(LEVEL3BUCKET, ",", prodIdUnStripped);
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = true;
		var objGroupLevel;

		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = false;

			if (grouplevelID == 1)
				level1String = ListAppendItem(level1String, ",", prodIdUnStripped);
			if (grouplevelID == 2)
				level2String = ListAppendItem(level2String, ",", prodIdUnStripped);
			if (grouplevelID == 3)
				level3String = ListAppendItem(level3String, ",", prodIdUnStripped);

		}

		objGroupLevel = eval("document.MyForm.GroupLevel_" + grouplevelID);

		document.MyForm.Level_1.value = level1String;
		document.MyForm.Level_2.value = level2String;
		document.MyForm.Level_3.value = level3String;


		if (!validateGroups())
		{
			document.MyForm.Level_1.value = "";
			document.MyForm.Level_2.value = "";
			document.MyForm.Level_3.value = "";
			document.MyForm.Level_1.value = LEVEL1BUCKET;
			document.MyForm.Level_2.value = LEVEL2BUCKET;
			document.MyForm.Level_3.value = LEVEL3BUCKET;
			return;
		}


		//reset group fields
		if (document.MyForm.Level_1.value == "")
		{
			document.MyForm.GroupLevel_1.value = "";
		}
		if (document.MyForm.Level_2.value == "")
		{
			document.MyForm.GroupLevel_2.value = "";
		}
		if (document.MyForm.Level_3.value == "")
		{
			document.MyForm.GroupLevel_3.value = "";
		}

		document.MyForm.ProductList.value = resultString;
		document.MyForm.ExistingProductList.value = resultString.replace(/_/ig, "-");;

		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		var currentTD;
		if(trObj)
		{
			if(bDelete)
			{
				disableDiv(trObj.cells[1], true, false);

				var i, tdLen, compProdIdRe;
				var tdObj = eval("document.all.TD_" + FieldNameRe);
				if(tdObj)
				{
					tdLen = tdObj.length;
					if(tdLen)
					{
						for(i=0;i<tdLen;i++)
						{
							currentTD = tdObj[i];
							compProdIdRe = currentTD.COMP_PRODUCT_ID_RE;

							// store the values for each component in queue
							my_queue.addObjValueToQueue(compProdIdRe + "_Adjustment", "document.all.OffInvoice_Value_" + compProdIdRe);
							my_queue.addObjValueToQueue(compProdIdRe + "_Plus_Minus", "document.all.Plus_Minus_" + compProdIdRe);
							my_queue.addObjValueToQueue(compProdIdRe + "_OffInvoice_UOM", "document.all.OffInvoice_UOM_" + compProdIdRe);

							// disable the imput/select for each component
							disableDiv(currentTD, true, false);
							disableDiv(currentTD.nextSibling, true, false);
							disableDiv(currentTD.nextSibling.nextSibling, true, false);
						}
					}
					else
					{
							currentTD = tdObj;
							compProdIdRe = currentTD.COMP_PRODUCT_ID_RE;

							// store the values for each component in queue
							my_queue.addObjValueToQueue(compProdIdRe + "_Adjustment", "document.all.OffInvoice_Value_" + compProdIdRe);
							my_queue.addObjValueToQueue(compProdIdRe + "_Plus_Minus", "document.all.Plus_Minus_" + compProdIdRe);
							my_queue.addObjValueToQueue(compProdIdRe + "_OffInvoice_UOM", "document.all.OffInvoice_UOM_" + compProdIdRe);

							// disable the imput/select for each component
							disableDiv(currentTD, true, false);
							disableDiv(currentTD.nextSibling, true, false);
							disableDiv(currentTD.nextSibling.nextSibling, true, false);
					}
				}

				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);

				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;

			}
			else
			{

				var bgCol = "#FFFFFF";
				if(trObj.rowIndex % 2 == 1)
				{
					bgCol = "#C6FFC6";
				}

				disableDiv(trObj.cells[1], false, false);

				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);

				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;

				propogateProperty(trObj, "style.backgroundColor", "#FFFFFF", false, true);



				var i, tdLen, compProdIdRe;
				var tdObj = eval("document.all.TD_" + FieldNameRe);
				if(tdObj)
				{
					tdLen = tdObj.length;
					if(tdLen)
					{
						for(i=0;i<tdLen;i++)
						{
							currentTD = tdObj[i];
							compProdIdRe = currentTD.COMP_PRODUCT_ID_RE;

							// enable the imput/select for each component
							disableDiv(currentTD, false, false);
							disableDiv(currentTD.nextSibling, false, false);
							disableDiv(currentTD.nextSibling.nextSibling, false, false);

							// populate values for each component from values stored in queue
							my_queue.deleteAndSetObjValueFromQueue(compProdIdRe + "_Adjustment", "document.all.OffInvoice_Value_" + compProdIdRe);
							my_queue.deleteAndSetObjValueFromQueue(compProdIdRe + "_Plus_Minus", "document.all.Plus_Minus_" + compProdIdRe);
							my_queue.deleteAndSetObjValueFromQueue(compProdIdRe + "_OffInvoice_UOM", "document.all.OffInvoice_UOM_" + compProdIdRe);
						}
					}
					else
					{
							currentTD = tdObj;
							compProdIdRe = currentTD.COMP_PRODUCT_ID_RE;

							// enable the imput/select for each component
							disableDiv(currentTD, false, false);
							disableDiv(currentTD.nextSibling, false, false);
							disableDiv(currentTD.nextSibling.nextSibling, false, false);

							// populate values for each component from values stored in queue
							my_queue.deleteAndSetObjValueFromQueue(compProdIdRe + "_Adjustment", "document.all.OffInvoice_Value_" + compProdIdRe);
							my_queue.deleteAndSetObjValueFromQueue(compProdIdRe + "_Plus_Minus", "document.all.Plus_Minus_" + compProdIdRe);
							my_queue.deleteAndSetObjValueFromQueue(compProdIdRe + "_OffInvoice_UOM", "document.all.OffInvoice_UOM_" + compProdIdRe);
					}
				}

				if(objGroupLevel.value == "")
				{
					objGroupLevel.value = realGroupLevelId;
				}

			}
			srcObj.bDelete = !bDelete;
			trObj.bDelete = (bDelete?1:0);
		}
	}

	function addComponent()
	{
		var oForm = document.MyForm;
		var currList = oForm.off_invoice_component_list.value;
		var addItem = oForm.Component_Program_Off_Invoice_Component_Name_ID.value;
		var sProductList = oForm.ProductList.value;
		var bProceed = true;

		//check if any products are selected
		if(sProductList.length == 0)
		{
			bProceed = false;
			alert("Please select products first");
		}

		//check for max # of components
		if(bProceed)
		{
			var Arr = currList.split(",");
			var arrLen = 0;
			if(currList.length)
			{
				arrLen = Arr.length;
			}
			<cfoutput>
			if(arrLen >= #ComponentMaxCount#)
			{
				bProceed = false;
				alert("Only a maximum of #ComponentMaxCount# component(s) may be applied");
			}
			</cfoutput>
		}
		//check if any component selected
		if(bProceed)
		{
			if(addItem == "-1")
			{
				bProceed = false;
				alert("Please select a component");
			}
		}
		//one component can be added only once
		if(bProceed)
		{
			if(ListFindItem(currList, ",", addItem) >= 0)
			{
				bProceed = false;
				alert("selected component already exists. Select another component");
			}
		}
		// check if basis code and treatment code is selected if applicable
		if(bProceed)
		{
			var treatmentCodeObj = oForm.Treatment_Code;
			if(treatmentCodeObj)
			{
				if(treatmentCodeObj.selectedIndex <= 0)
				{
					alert("Please select a treatment code");
					bProceed = false;
				}
			}
		}

		if(bProceed)
		{
			var basisCodeObj = oForm.Basis_Code;
			if(basisCodeObj)
			{
				if(basisCodeObj.selectedIndex <= 0)
				{
					alert("Please select a basis code");
					bProceed = false;
				}
			}
		}

		if(bProceed)
		{
			oForm.command.value = "addComponent";
			oForm.submit();
		}
		return false;
	}

	function verifyDelete(component_id, component_name)
	{
		if(confirm("Are you sure you want to delete " + component_name + "?"))
		{
			var oForm = document.MyForm;
			oForm.command.value = "delComponent";
			oForm.Del_Component_ID.value = component_id;
			oForm.submit();
		}
	}
</script>

<cfif isMultiLevelGroups>
<br><cfoutput>
	<table WIDTH="300" border="0" cellpadding="0" cellspacing="0">

		<tr valign="middle">

			<td bgcolor="##ccffcc">
				<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
			</td>
			<td>&nbsp;= #arPricingLevel[1]#&nbsp;&nbsp;&nbsp;</td>

			<td bgcolor="##DFE6FF">
				<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
			</td>
			<td>&nbsp;= #arPricingLevel[2]#&nbsp;&nbsp;&nbsp;</td>

			<td bgcolor="##E2CBE4">
				<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
			</td>
			<td>&nbsp;= #arPricingLevel[3]#&nbsp;&nbsp;&nbsp;</td>

		</tr>

	</table>
	</cfoutput>

</cfif>

<cfset headerRowSpan = 1 />
<cfif ListLen(form.off_invoice_component_list) GT 0>
	<cfset headerRowSpan = 2 />
</cfif>
<BR>
<TABLE border="0" cellspacing="0" cellpadding="3" CLASS="Maintable" WIDTH="800">

	<TR ID="header" BGCOLOR="#ffce84" valign="top">
		<TD rowspan="<cfoutput>#headerRowSpan#</cfoutput>" width="15" style="<cfoutput>#hideObjects#</cfoutput>">
		<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2)>
			<img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onclick="deleteAll('Product_')" style="cursor: pointer;">
		<cfelse>
		&nbsp;
		</cfif>
		</TD>
		<TD rowspan="<cfoutput>#headerRowSpan#</cfoutput>" align="center" width="20">
			<INPUT Name="allbox" TYPE="Checkbox" onClick="CA('Product_')" TITLE="Click here to select all Products" checked>
		</TD>
		<TD rowspan="<cfoutput>#headerRowSpan#</cfoutput>" align="left" ID="header" width="65">
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
			<cfif application.returned_customer_setting.upc_switch EQ 1>
						<B>UPC</B>
					<BR>
			</cfif>
		</cfif>
				<B>Item #</B>
		</TD>
		<cfif isMultiLevelGroups>
		<TD rowspan="<cfoutput>#headerRowSpan#</cfoutput>" align="left" ID="header">
				<B>Level</B>
		</TD>
		</cfif>
		<TD nowrap rowspan="<cfoutput>#headerRowSpan#</cfoutput>" align="left" ID="header" width="150">
				<B>Description</B>
		</TD>
	<cfloop list="#form.off_invoice_component_info_list#" index="Current_Component_Info">
		<cfset Current_Component_Name_ID 	= ListFirst(Current_Component_Info, "~") />
		<cfset treatmentCodeId 				= getOffInvoiceComponentTreatmentCodeId(Current_Component_Info) />
		<cfset basisCodeId 					= getOffInvoiceComponentBasisCodeId(Current_Component_Info) />

		<cfset useLakebaseForGet_Program_OffInvoice_Component_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetoiprogramcomponents")>
<cfif useLakebaseForGet_Program_OffInvoice_Component_Name>
	<cftry>
		<cfset Get_Program_OffInvoice_Component_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetoiprogramcomponents", {
				"program_offinvoice_component_name_id" = "eq.#Current_Component_Name_ID#",
				"select" = "program_offinvoice_component_name"
			}), "program_offinvoice_component_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Program_OffInvoice_Component_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Program_OffInvoice_Component_Name>
<cfquery name="Get_Program_OffInvoice_Component_Name" dbtype="query">
			SELECT	Program_OffInvoice_Component_Name
			FROM	qGetOIProgramComponents
			WHERE	Program_OffInvoice_Component_Name_ID = #Current_Component_Name_ID#
		</cfquery>
</cfif>
		<cfset componentColSpan = 3 />
		<cfif Display_Basis_Treatment_Code EQ 1>
		<cfif BasisCodeManager.getBasicCodeType(basisCodeId) EQ "Y">
			<cfset componentColSpan = componentColSpan - 1 />
		</cfif>
		</cfif>

		<cfoutput>
		<TD colspan="#componentColSpan#" ID="header" align="center" style="border-left:solid ##93BEE2 1px;">
		<cfset additionalInfo = "" />
		<!--- display basis code treatment code information ---->
		<cfif Display_Basis_Treatment_Code EQ 1>
		<cfsavecontent variable="additionalInfo">#additionalInfo#
		<br>Treatment Code: #TreatmentCodeManager.getTreatmentCodeDesc(treatmentCodeId)#
		<br>Basis Code: #BasisCodeManager.getBasicCodeDesc(basisCodeId)#
		</cfsavecontent>
		</cfif>
		<!------ Display additional info ----->
<!--- 		<cfif Len(additionalInfo)>
		<CF_SmallHelp
			height = "50"
			width = "200"
			displayShifyX = "-90"
			displayShifyY = "-50"
			imgPath="/Images/i.gif"
			imgWidth="12"
			imgHeight="11"
			>
		<center>#additionalInfo#</center>
		</CF_SmallHelp>&nbsp;
		</cfif>
		<A STYLE="cursor: pointer;" ONCLICK="verifyDelete('#Current_Component_Name_ID#', '#replace(Get_Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name, "'", "\'")#')">
		<img src="/Images/scissor.gif"  title="delete this component" border="0">
		</A> ---><input type="Checkbox" value="1" checked name="Check_C_#Current_Component_Name_ID#">
		<strong>#Get_Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name#</strong></TD>
		</cfoutput>
	</cfloop>
	<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
		<TD rowspan="<cfoutput>#headerRowSpan#</cfoutput>" ID="header"><B>Similar<br />Product</B></TD>
	</cfif>
		<TD rowspan="<cfoutput>#headerRowSpan#</cfoutput>" width="50%">&nbsp;</TD>

	</TR>
	<cfif ListLen(form.off_invoice_component_list) GT 0>
	<TR ID="header" BGCOLOR="#ffce84">
	<cfloop list="#form.off_invoice_component_info_list#" index="Current_Component_Info">
		<cfset Current_Component_Name_ID 	= ListFirst(Current_Component_Info, "~") />
		<cfset treatmentCodeId 				= getOffInvoiceComponentTreatmentCodeId(Current_Component_Info) />
		<cfset basisCodeId 					= getOffInvoiceComponentBasisCodeId(Current_Component_Info) />

		<cfset Basis_Code_Type = 0 />
		<cfif Display_Basis_Treatment_Code EQ 1>
		<cfif BasisCodeManager.getBasicCodeType(basisCodeId) EQ "Y">
			<cfset Basis_Code_Type = 1 />
		</cfif>
		</cfif>
		<cfif Basis_Code_Type EQ 0>
		<TD ID="header" style="border-left:solid #93BEE2 1px;" width="30">
			<cfif OnlyPositive IS NOT 1>
				<strong>+/-</strong>
			<cfelse>
				&nbsp;
			</cfif>
		</TD>
		<TD ID="header" width="60"><B>Price Adj.</B></TD>
		<TD ID="header" width="30"><B>Per</B></TD>
		<cfelse>
		<TD ID="header" width="30"><B>Buy</B></TD>
		<TD ID="header" width="30"><B>Get Free</B></TD>
		</cfif>
	</cfloop>
	</TR>
	</cfif>

	<cfset ProductList = "">
	<cfset prodCounter = 0 />
	<cfset bgcolor_row = 0>

	<CFOUTPUT QUERY="TheQuery" group="BSA_Foodservice_Items_Master_ID">
		<cfset prodCounter = prodCounter + 1 />
		<!---if they are dealing with multi level groups then run logic to figure out what bucket to put the products in if from product search--->
		<cfif isMultiLevelGroups>

			<!------ If restrictLowerLevelBasedonLevel1 is on, that means level 2 and level 3 can have products, if level 1 was a group ----->
			<cfif restrictLowerLevelBasedonLevel1 EQ 0>
				<!---Loop over the group buckets to check and see what bucket to put them items into--->
				<cfif not ListFindNoCase(Evaluate("form.Level_#ListLen(this.lGroupLevels)#"), BSA_Foodservice_Items_Master_ID) and not ListFindNoCase(form.Level_1, BSA_Foodservice_Items_Master_ID)>
					<cfif not ListLen(this.lGroupLevels) gt 2>
						<cfset tmpIndx = ListLen(this.lGroupLevels) + 1 />
						<cfset "form.GroupLevel_#tmpIndx#" = 9 />
						<cfif not ListFindNoCase(Evaluate("form.Level_#tmpIndx#"), BSA_Foodservice_Items_Master_ID)>
							<cfset "form.Level_#tmpIndx#" = ListAppend(Evaluate("form.Level_#tmpIndx#"), BSA_Foodservice_Items_Master_ID) />
						</cfif>
					</cfif>
				</cfif>
			</cfif>

		</cfif>

		<cfset Product_ID_RE = replace(TheQuery.BSA_Foodservice_Items_Master_ID,"-","_", "ALL") />
		<CFSET FieldNameEnd = Product_ID_RE>
		<cfset ProductList = ProductList & FieldNameEnd & ",">

		<!---if we are dealing with groups then change the way BGCOLOR get set--->
		<cfif isMultiLevelGroups>
			<cfset currentLevel = 0 />
			<cfif ListFindNoCase(form.Level_1, BSA_Foodservice_Items_Master_ID)>
				<cfset rowBGColor="##ccffcc" />
				<cfset currentLevel = 1 />
			<cfelseif ListFindNoCase(form.Level_2, BSA_Foodservice_Items_Master_ID)>
				<cfset rowBGColor="##DFE6FF" />
				<cfset currentLevel = 2 />
			<cfelse>
				<cfset rowBGColor="##E2CBE4" />
				<cfset currentLevel = 3 />
			</cfif>
			<cfset LevelDesc = arPricingLevel[currentLevel] />

		<cfelse>
			<cfset currentLevel = 1 />
			<CFIF prodCounter	 mod 2>
				<cfset rowBGColor="white" />
			<CFELSE>
				<cfset rowBGColor="ccffcc" />
			</CFIF>
			<cfset LevelDesc = "" />

		</cfif>

		<!---if Level_1 isn't empty then it's a group so change onmouseover menuId--->
		<!------ <cfif trim(form.Level_1) neq ""> ----->
		<!------ If this level is group use group pop up ----->
		<cfset currentGroupLevel = trim(Evaluate("form.GroupLevel_#currentLevel#")) />
		<cfset currentGroupLevelIsGroup = 0 />
		<cfif currentGroupLevel neq "" and currentGroupLevel neq "0" and currentGroupLevel neq "9">

			  <cfset request.menuId = 11 />
			  <cfset request.theMOId = "#TheQuery.BSA_Foodservice_Items_Master_ID#&Group_Level_ID=#Form.GroupLevel_1#&Program_ID=#FORM.Contract_Main_ID#" />
			  <cfset currentGroupLevelIsGroup = 1 />

		<cfelse>

			<cfset request.menuId = 6 />
			<cfset request.theMOId = TheQuery.BSA_Foodservice_Items_Master_ID />

		</cfif>

		<cfif TheQuery.DisplayGroupName NEQ currentheader>
			<cfset bgcolor_row = 1>
			<cfset currentheader = TheQuery.DisplayGroupName />
			<cfset currentheader_id = #REREPLACE(trim(TheQuery.DisplayGroupName),' ','_','ALL')# />
			<tr><td colspan="100%" style="background-color:##ddddee;color:##000000;font-weight:900;font-size:11px;" id="header"><input type="checkbox" id="#currentheader_id#" name="type_code_header" value="#currentheader_id#" onClick="checkMatchingProd('#JSStringFormat(currentheader_id)#',this);"  checked>&nbsp;#application.returned_customer_setting.TYPE_CODE_LABEL_PLURAL#: #UCASE(TheQuery.DisplayGroupName)#</td></tr>
		<cfelse>
			<cfset bgcolor_row = bgcolor_row + 1 />
		</cfif>
		<cfif Not isMultiLevelGroups>
			<cfset currentLevel = 1 />
			<CFIF bgcolor_row	 mod 2>

				<cfset rowBGColor="white" />
			<CFELSE>
				<cfset rowBGColor="ccffcc" />
			</CFIF>
			<cfset LevelDesc = "" />

		</cfif>

		<TR bgcolor="#rowBGColor#" ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" height="30" ID="TR_Products" PRODUCT_ID_RE="#FieldNameEnd#" bDelete="0">
			<TD style="display:none;">
			<cfif NOT(Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2 AND listfind(ProductItemList, TheQuery.BSA_Foodservice_Items_Master_ID) NEQ 0)>
				<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete this product" border="0" onclick="deleteThisOffInvoice('#FieldNameEnd#', '#FieldNameEnd#', '#BSA_Foodservice_Items_Master_ID#','#currentLevel#','#Evaluate("Form.GroupLevel_#currentLevel#")#')" style="cursor: pointer;">
			<cfelse>
			&nbsp;
			</cfif>
			</TD>
			<TD align="center">
				<span ID="checkBoxCollection">
					<INPUT type="Checkbox" NAME="Product_#FieldNameEnd#" id="#currentheader_id#" APPLYMASSRATE="OffInvoice_Value_#FieldNameEnd#" VALUE="#FieldNameEnd#" checked>
				</SPAN>
			</TD>
			<TD NOWRAP>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
				<cfif application.returned_customer_setting.upc_switch EQ 1>
						#TheQuery.UPC#&nbsp;<BR>
				</cfif>
			</cfif>
			#TheQuery.ITEM#&nbsp;
			</TD>
			<cfif isMultiLevelGroups>
			<TD nowrap>#LevelDesc#</TD>
			</cfif>
			<TD>
				#TheQuery.Description#&nbsp;
				<cfif restrictLowerLevelBasedonLevel1 AND NOT currentGroupLevelIsGroup>
					<cfset productGroupForThisProduct = "" />
					<cfif qProductGroupValuesForItem.recordCount>
						<cfset useLakebaseForqProductGroupForThisProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qproductgroupvaluesforitem")>
<cfif useLakebaseForqProductGroupForThisProduct>
	<cftry>
		<cfset qProductGroupForThisProduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qproductgroupvaluesforitem", {
				"product_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"select" = "group_id"
			}), "group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqProductGroupForThisProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqProductGroupForThisProduct>
<cfquery name="qProductGroupForThisProduct" dbtype="query">
							SELECT 	Group_ID
							FROM	qProductGroupValuesForItem
							WHERE	Product_ID = '#BSA_Foodservice_Items_Master_ID#'
						</cfquery>
</cfif>
						<cfset productGroupForThisProduct = qProductGroupForThisProduct.Group_ID />
					</cfif>
					<input type="hidden" name="productGroupForThisProduct_#request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID)#" value="#productGroupForThisProduct#">
				</cfif>
			</TD>
		<cfloop list="#form.off_invoice_component_info_list#" index="Current_Component_Info">
		<cfset Current_Component_Name_ID 	= ListFirst(Current_Component_Info, "~") />
		<cfset treatmentCodeId 				= getOffInvoiceComponentTreatmentCodeId(Current_Component_Info) />
		<cfset basisCodeId 					= getOffInvoiceComponentBasisCodeId(Current_Component_Info) />
		<cfset ComponentFieldNameEnd = "C_#Current_Component_Name_ID#_P_#Product_ID_RE#" />

		<cfif form.command EQ "addComponent" and Current_Component_Name_ID EQ Component_Program_Off_Invoice_Component_Name_ID>
			<!------ If user is selecting current component as new, use the rate/uom/+- selected by user ----->
			<cfset Plus_Minus2 = form.Component_Polarity>
			<cfset Discount_Amount2 = form.Component_Rate>
			<cfset UOM2 = form.Component_uom>

			<cfset Basis_Code_Quantity2 = "" />
			<cfset Basis_Code_Quantity_UOM2 = "" />
			<cfset Basis_Code_Free_Goods2 = "" />
		<cfelse>
			<cfquery name="ItemInformation" datasource="#application.datasource#">

				SELECT	Program_OffInvoice_Product_Data.Program_OffInvoice_Product_Data_ID,
						Program_OffInvoice_Product_Data.Discount_Amount,
						Program_OffInvoice_Product_Data.Plus_Minus,
						Program_OffInvoice_Product_Data.UOM,
						Program_OffInvoice_Product_Data.Basis_Code_Quantity,
						Program_OffInvoice_Product_Data.Basis_Code_Quantity_UOM,
						Program_OffInvoice_Product_Data.Basis_Code_Free_Goods
				FROM 	Contract_Products
				INNER JOIN Program_OffInvoice_Product_Data
				ON 		Program_OffInvoice_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				INNER JOIN Program_OffInvoice_Component
				ON		Program_OffInvoice_Component.Program_OffInvoice_Component_ID = Program_OffInvoice_Product_Data.Program_OffInvoice_Component_ID
				INNER JOIN Program_OffInvoice_Component_Name
				ON		Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID = Program_OffInvoice_Component.Program_OffInvoice_Component_Name_ID
				AND		Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID = #Current_Component_Name_ID#
				WHERE 	Contract_Products.BSA_Foodservice_Items_Master_ID = '#TheQuery.BSA_Foodservice_Items_Master_ID#'
				AND 	Contract_Products.Contract_Main_ID = #Contract_Main_ID#
				AND 	Contract_Products.Deleted = 0
				AND 	Program_OffInvoice_Product_Data.Deleted = 0

			</cfquery>

			<cfif ItemInformation.Recordcount GT 0>

				<cfset Plus_Minus2 = ItemInformation.Plus_Minus>
				<cfset Discount_Amount2 = ItemInformation.Discount_Amount>
				<cfset UOM2 = ItemInformation.UOM>

				<cfset Basis_Code_Quantity2 = ItemInformation.Basis_Code_Quantity />
				<cfset Basis_Code_Quantity_UOM2 = ItemInformation.Basis_Code_Quantity_UOM />
				<cfset Basis_Code_Free_Goods2 = ItemInformation.Basis_Code_Free_Goods />

			<cfelse>

				<cfset Plus_Minus2 = TheQuery.Plus_Minus>
				<cfset Discount_Amount2 = TheQuery.Discount_Amount>
				<cfset UOM2 = TheQuery.UOM>

				<cfset Basis_Code_Quantity2 = TheQuery.Basis_Code_Quantity />
				<cfset Basis_Code_Quantity_UOM2 = TheQuery.Basis_Code_Quantity_UOM />
				<cfset Basis_Code_Free_Goods2 = TheQuery.Basis_Code_Free_Goods />

			</cfif>
		</cfif>
		<cfset Basis_Code_Type = 0 />
		<cfif Display_Basis_Treatment_Code EQ 1>
		<cfif BasisCodeManager.getBasicCodeType(basisCodeId) EQ "Y">
			<cfset Basis_Code_Type = 1 />
		</cfif>
		</cfif>
		<CFPARAM NAME="FORM.Plus_Minus_#ComponentFieldNameEnd#" 	DEFAULT="#Plus_Minus2#">
		<CFPARAM NAME="FORM.OffInvoice_Value_#ComponentFieldNameEnd#" 	DEFAULT="#Discount_Amount2#">
		<CFPARAM NAME="FORM.OffInvoice_UOM_#ComponentFieldNameEnd#" 	DEFAULT="#UOM2#">

		<cfif Basis_Code_Type EQ 0><!------ for basis code = buy x get y free, the rate/uom is calculated before the margin routine ----->
			<TD style="border-left:solid ##93BEE2 1px;" ID="TD_#FieldNameEnd#" COMP_PRODUCT_ID_RE="#ComponentFieldNameEnd#" COMP_ID="#Current_Component_Name_ID#">
				<cfif OnlyPositive IS NOT 1>
					<CFSET This_Value = Evaluate("FORM.Plus_Minus_#ComponentFieldNameEnd#")>
					<span id="PolarityCollection">
						<select name="Plus_Minus_#ComponentFieldNameEnd#" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, TheQuery.BSA_Foodservice_Items_Master_ID) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>>
							<option value="0"<cfif This_Value IS 0>selected</cfif>>-</option>
							<option value="1" <cfif This_Value IS 1>selected</cfif>>+</option>
						</select>
					</span>
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, TheQuery.BSA_Foodservice_Items_Master_ID) NEQ 0>
						<input type="hidden" name="Plus_Minus_#ComponentFieldNameEnd#" value="#This_Value#">
					</cfif>
				<cfelse>

					<input type="hidden" name="Plus_Minus_#ComponentFieldNameEnd#" value="0">

				</cfif>

			</TD>
			<TD>

				<SPAN ID="error_Price_#ComponentFieldNameEnd#"></SPAN>
				<CFSET This_Value = Evaluate("FORM.OffInvoice_Value_#ComponentFieldNameEnd#")>
				<INPUT TYPE="text" NAME="OffInvoice_Value_#ComponentFieldNameEnd#" SIZE="5" VALUE="#trim(numberformat(This_Value, '_.____'))#" ONKEYUP="formatRate(this,'#ComponentFieldNameEnd#')" onblur="formatRate(this,'#ComponentFieldNameEnd#')" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, TheQuery.BSA_Foodservice_Items_Master_ID) NEQ 0>STYLE="background-color: cccccc" DISABLED</cfif>>
				<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2 AND listfind(ProductItemList, TheQuery.BSA_Foodservice_Items_Master_ID) NEQ 0>
					<input type="hidden" name="OffInvoice_Value_#ComponentFieldNameEnd#" value="#trim(numberformat(This_Value, '_.____'))#">
				</cfif>
			</TD>

			<TD>

				<CFSET temp = Evaluate("FORM.OffInvoice_UOM_#ComponentFieldNameEnd#")>
				<cfif len(trim(temp)) EQ 0>
					<cfset temp = 0>
					<cfset defaultselected = 1>
				<cfelse>
					<cfset defaultselected = 0>
				</cfif>

				<!---stub in percent for now for ICM Dev if it's a group. We'll move this to application settings later --->
				<!--- <cfif form.Level_1 neq "" and Left(trim(application.returned_customer_setting.customer_keyword), 1) eq "C" and Right(trim(application.returned_customer_setting.customer_keyword), 1) eq "a"> --->
				<cfif (isDefined("currentGroupLevelIsGroup") and currentGroupLevelIsGroup eq 1) and Left(trim(application.returned_customer_setting.customer_keyword), 1) eq "C" and Right(trim(application.returned_customer_setting.customer_keyword), 1) eq "a"  and Findnocase("flower",application.returned_customer_setting.company_Name) eq 0>
					%
				  	<input name="OffInvoice_UOM_#ComponentFieldNameEnd#" type="hidden" value="3" />

				<cfelse>
				<cfset Disabled = 0>
				<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2 AND listfind(ProductItemList, TheQuery.BSA_Foodservice_Items_Master_ID) NEQ 0>
					<cfset Disabled = 1>
					<input type="hidden" name="OffInvoice_UOM_#ComponentFieldNameEnd#" value="#temp#">

				  </cfif>
					<span id="UOMCollection">
						<cf_uom_dropdown
							program_id				=	""
							company_main_id			=	""
							default_option_on		=	"0"
							setDefaultSelected 		=	"#defaultselected#"
							default_option_text		=	""
							default_option_value	=	"0"
							dropdown_name			=	"OffInvoice_UOM_#ComponentFieldNameEnd#"
							option_text_abbreviated	=	"1"
							plural_uom_display		=	""
							product_type_id			=	"8"
							program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
							selected_uom_id			=	"#temp#"
							generic_type_restriction = "false"
							text_before_tag_close	=	"onchange=""if(document.all.OffInvoice_Value_#ComponentFieldNameEnd#.disabled==false){formatRate(document.all.OffInvoice_Value_#ComponentFieldNameEnd#,'#ComponentFieldNameEnd#')}"" onblur=""if(document.all.OffInvoice_Value_#ComponentFieldNameEnd#.disabled==false){formatRate(document.all.OffInvoice_Value_#ComponentFieldNameEnd#,'#ComponentFieldNameEnd#')}"""
							uom_id_exclusion_list	=	""
							uom_id_inclusion_list	=	"#ListOfAvailUOM#"
							productUom				=	"#Inventory_UM#"
							disabled				=	"#disabled#"
						>
					</span>
				</cfif>

			</TD>
			</cfif>
				<cfif Basis_Code_Type EQ 1>
					<td nowrap ID="TD_#FieldNameEnd#" COMP_PRODUCT_ID_RE="#ComponentFieldNameEnd#" COMP_ID="#Current_Component_Name_ID#">
					<!------
					add the hidden field for rate, uom etc.
					for basis code = buy x get y free, the rate/uom is calculated before the margin routine
					----->
					<CFSET This_Value = Evaluate("FORM.Plus_Minus_#ComponentFieldNameEnd#")>
					<input type="hidden" name="Plus_Minus_#ComponentFieldNameEnd#" value="#This_Value#">
					<CFSET This_Value = Evaluate("FORM.OffInvoice_Value_#ComponentFieldNameEnd#")>
					<input type="hidden" name="OffInvoice_Value_#ComponentFieldNameEnd#" value="#trim(numberformat(This_Value, '_.____'))#">
					<CFSET This_Value = Evaluate("FORM.OffInvoice_UOM_#ComponentFieldNameEnd#")>
					<input type="hidden" name="OffInvoice_UOM_#ComponentFieldNameEnd#" value="#This_Value#">
					<input type="hidden" name="basisCodeType_#ComponentFieldNameEnd#" value="1">

					<CFPARAM NAME="FORM.comp_basis_code_quantity_#ComponentFieldNameEnd#" 	DEFAULT="#Basis_Code_Quantity2#">
					<CFSET This_Value = Evaluate("FORM.comp_basis_code_quantity_#ComponentFieldNameEnd#")>

					<input name="comp_basis_code_quantity_#ComponentFieldNameEnd#" type="text"  size="1" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
						  value="#LSNumberFormat(This_Value, "(_.____)")#"
						  <cfif Revision_Products_Rates_Changes eq 0>disabled</cfif>
						/>
					<cfif Revision_Products_Rates_Changes eq 0>
					<input type="Hidden" name="comp_basis_code_quantity_#ComponentFieldNameEnd#"
						  value="#This_Value#"
						  />
					</cfif>
					<CFPARAM NAME="FORM.comp_basis_code_quantity_uom_#ComponentFieldNameEnd#" 	DEFAULT="#Basis_Code_Quantity_UOM2#">
					<CFSET This_Value = Evaluate("FORM.comp_basis_code_quantity_uom_#ComponentFieldNameEnd#")>

						 <cf_uom_dropdown
								program_id				=	""
								company_main_id			=	""
								default_option_on		=	"0"
								default_option_text		=	""
								default_option_value	=	""
								dropdown_name			=	"comp_basis_code_quantity_uom_#ComponentFieldNameEnd#"
								option_text_abbreviated	=	"1"
								plural_uom_display		=	""
								product_type_id			=	"8"
								program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
								selected_uom_id			=	"#This_Value#"
								text_before_tag_close	=	""
								uom_id_exclusion_list	=	"3"
								uom_id_inclusion_list	=	""
								productUom				=	""
								Disabled				= 	"#Disabled#"
							>
						<cfif Disabled>
						<input type="Hidden" name="comp_basis_code_quantity_uom_#ComponentFieldNameEnd#"
								  value="#This_Value#"
								  />
						</cfif>
					</td>
					<td nowrap>
					<CFPARAM NAME="FORM.comp_basis_code_free_goods_#ComponentFieldNameEnd#" 	DEFAULT="#Basis_Code_Free_Goods2#">
					<CFSET This_Value = Evaluate("FORM.comp_basis_code_free_goods_#ComponentFieldNameEnd#")>

					<input name="comp_basis_code_free_goods_#ComponentFieldNameEnd#" type="text"  size="1" ONKEYUP="clenseText(this,'0123456789.')" style="font-size:10"
						  value="#LSNumberFormat(This_Value, "(_.____)")#"
						 <cfif Revision_Products_Rates_Changes eq 0>disabled</cfif>
						/>
					<cfif Revision_Products_Rates_Changes eq 0>
					<input type="Hidden" name="comp_basis_code_free_goods_#ComponentFieldNameEnd#"
						 value="#This_Value#"
						  />
					</cfif>
					</td>
				</cfif>
		</cfloop><!------ component loop ----->

			<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
			<TD><input name="Like_Product" id="#currentheader_id#" type="checkbox" value="#BSA_Foodservice_Items_Master_ID#" <cfif ListFind(SimilarExistingProductList,BSA_Foodservice_Items_Master_ID) neq 0>CHECKED</cfif>></TD>
			</cfif>
			<TD>&nbsp;</TD>
		</TR>

	</CFOUTPUT>

	<cfoutput>
		<input type="hidden" name="ProductList" value="#ProductList#">
		<input type="hidden" name="off_invoice_component_list" value="#form.off_invoice_component_list#">
		<input type="hidden" name="off_invoice_component_info_list" value="#form.off_invoice_component_info_list#">
	</cfoutput>

	<TR>
		<TD COLSPAN="100%" ALIGN="center"></TD>
	</TR>

</TABLE>

<BR>
<!--- <cfoutput>#ProductList# - #Product_List#</cfoutput> --->

		<CF_smallLink
			title = "close window"
			url = "##"
			parameters = "onClick=""JavaScript: top.close();if(top.opener){top.opener.focus();};"""
		>

<BR>
<CF_button
	button_name		=	"save"
	button_caption	=	"save"
	button_action	=	"verifyData();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>


<CFOUTPUT>
<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">

<INPUT TYPE="Hidden" NAME="command" VALUE="">
<INPUT TYPE="Hidden" NAME="Del_Component_ID" VALUE="">
<INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
<input type="Hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />

<INPUT TYPE="hidden" NAME="ProductCount" VALUE="#TheQuery.Recordcount#">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="#FORM.Contract_Main_ID#">
<INPUT TYPE="Hidden" NAME="ExistingProductList"	VALUE="#valuelist(TheQuery.BSA_Foodservice_Items_Master_ID)#">
<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#trim(valuelist(TheQuery.BSA_Foodservice_Items_Master_ID))#">
<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#FORM.Sort_By#">
<input type="Hidden" name="Level_1" value="#trim(Form.Level_1)#" />
<input type="Hidden" name="Level_2" value="#trim(Form.Level_2)#" />
<input type="Hidden" name="Level_3" value="#trim(Form.Level_3)#" />
<!---clean up the group levels--->
<cfif trim(form.Level_1) eq "">
	<cfset form.GroupLevel_1 = "" />
</cfif>
<cfif trim(form.Level_2) eq "">
	<cfset Form.GroupLevel_2 = "" />
</cfif>
<cfif trim(form.Level_3) eq "">
	<cfset Form.GroupLevel_3 = "" />
</cfif>
<input type="Hidden" name="GroupLevel_1" value="#Form.GroupLevel_1#" />
<input type="Hidden" name="GroupLevel_2" value="#Form.GroupLevel_2#" />
<input type="Hidden" name="GroupLevel_3" value="#Form.GroupLevel_3#" />
<input type="hidden" name="Allow_Multi_Levels" value="#form.Allow_Multi_Levels#" />
<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
<input type="hidden" name="Group_Deal" value="#form.Group_Deal#" />
<input type="hidden" name="Product_Search_Window_Return_Type" value="0" />
<input type="hidden" NAME="Is_Like_Product_Exist" VALUE="#CSLGetContractInfo.Like_Product_Exist#">
<cfif restrictLowerLevelBasedonLevel1>
	<input type="hidden" name="AllowProductGroupList" value="#Form.Level_1#" />
	<input type="hidden" name="AllowProductGroupLevelId" value="#Form.GroupLevel_1#" />
</cfif>
<!--- Variable controls redirection to "Margin Edit" version of contract rebates --->
	<INPUT TYPE="Hidden" NAME="RedirectPath" 		VALUE="1" />

</CFOUTPUT>
</FORM>

</BLOCKQUOTE></BLOCKQUOTE>



<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- delete product section --->
<cfinclude template="delete_product_include.cfm">
<!--- delete product section --->
<cfif GetContractInfo.modifying_program EQ 0 and marginedit_saved>
	<cfset overrideClosure = 1>
	<cfset form.programid = '#URL.CID#' />
	<cfinclude template="reset_program_agreed.cfm" />
</cfif>

</BODY>
</HTML>
