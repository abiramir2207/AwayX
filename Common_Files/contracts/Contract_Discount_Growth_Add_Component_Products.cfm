<cfif isDefined("url.Program_ID")>
	<cfset Form.Program_ID = url.Program_ID>
</cfif>
<cfset PAGE_TITLE= "Select Growth Products">

<!---initialize app settings object--->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfparam name="form.navigate" default ="0">
<cfparam name="form.stopnavigate" default ="0">
<cfparam name="defaultselected" default ="1">
<cfparam name="Form.Discount_Growth_Item_Level" default ="0">
<cfparam name="Form.Discount_Growth_Group_Level" default ="0">
<cfparam name="form.Allow_Multi_Levels" default ="0">
<cfparam name="form.Dynamic_Static_Groups" default ="0">
<cfparam name="Product_Key_List" default ="" />
<cfparam name="TierCount" default ="0">
<cfparam name="LOADPRODUCTCOUNT" default ="0">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="restrictLowerLevelBasedonLevel1" default ="0" />
<cfparam name="ChildID" default ="0" />
<cfparam name="url.EZTemplate" default ="0">
<cfparam name="CompID" default ="0">
<cfparam name="url.Growth_Component_name_ID" default ="0">

<!---77408 Product Group sequencing START--->

<cfparam name="form.Num_Levels" default ="#request.AccessStructure.numberOfProductGroupLevels#">
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<cfparam name="form.Level_#levels#" default ="">
	<cfparam name="form.GroupLevel_#levels#" default ="">
</cfloop>
<!---77408 Product Group sequencing END--->

<cfset GrowthComp = CreateObject("component", "components.programs.growth.growthcomponent") />
<cfif ChildID eq 0>
	<cfset GrowthTierPercentUOM = GrowthComp.GetGrowthTierPercentUOM(CompID)>
<cfelse>
	<cfset GrowthTierPercentUOM = GrowthComp.GetGrowthTierPercentUOM(ChildID)>
</cfif>
<!---set whether to allow multi level groups--->
<cfif appSettings.getAllowMultiLevelGroups()>
	<cfset form.Allow_Multi_Levels = 1 />
</cfif>
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0>
	<CFSET temp = 0>
<CFELSE>
	<CFSEt temp = cryp.value>
</CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<cfset Program_ID = temp>
<CFSET CSL_CallingPageCode = "growth">
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfif CSL_Contract_Main_ID NEQ 0>
	<cfscript>
		contract = CreateObject("component", "components.programs.rebates.Contract");
		GetContractInfo = contract.get(cryp.value);
	</cfscript>
  <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id"
			}), "first_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID
    FROM Program_Control_Panel_Options
    WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
  </cfquery>
</cfif>

</cfif>
<cfif isDefined("GetTemplateInfo") AND GetTemplateInfo.RecordCount GTE 1>
	<cfset FirstParentID = GetTemplateInfo.First_parent_ID />
<cfelse>
	<cfset FirstParentID = 0 />
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT>
		function addGroupsLevelProducts(groupLevel, groupId){
			if(window.confirm('Do you want to add all the products?')){
				if(groupLevel != 0){
					var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
					groupIdListObj.value = groupId;
					document.compProductTierRates.submit();
				}
			}
		}
		function showProductSearchWindow_old(addProductAtLevel){
			var bSelectedAllProducts = false;
			var groupLevel = 0;
			if(document.all.groupLevelProducts){
				if(document.all.groupLevelProducts.value == "1"){
					groupLevel = 1;
					bSelectedAllProducts = true;
				}
			}
			if(bSelectedAllProducts){
				if(window.confirm("Your current action will remove 'All Products'." + "\n" + "Do you want to continue?"))
				{
					//if groupLevel = 1
					document.compProductTierRates.groupLevelProducts.value = "0";
					document.compProductTierRates.Product_Level_1.value = "";
					document.compProductTierRates.Product_List.value = "";
					document.compProductTierRates.ExistingProductList.value = "";
					bSelectedAllProducts = false;
				}
			}
			if(!bSelectedAllProducts){

				//validate for groups
				//77408 Product Group sequencing START
				<CFOUTPUT>
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					var grpLevl#levels# = document.all.GroupLevel_#levels#.value;
				</cfloop>
				</CFOUTPUT>
				//77408 Product Group sequencing END

				//if we have product groups at all levels then don't allow adding products

				if((grpLevl1 != "" && grpLevl1 != 9) && (grpLevl2 != "" && grpLevl2 != 9) && (grpLevl3 != "" && grpLevl3 != 9)
					//77408 Product Group sequencing
					<cfif request.AccessStructure.numberOfProductGroupLevels GT 3> && (grpLevl4 != "" && grpLevl4 != 9) && (grpLevl5 != "" && grpLevl5 != 9) && (grpLevl6 != "" && grpLevl6 != 9) && (grpLevl7 != "" && grpLevl7 != 9) && (grpLevl8 != "" && grpLevl8 != 9)</cfif>)
				{
					alert("Products cannot be added when Groups exist in all levels.");
					return;
				}

				var sURL = "product_Select_V1.cfm?Formname=compProductTierRates&Discountype=4&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#url.Growth_Component_name_ID#</cfoutput>&isparent=1<cfif appsettings.getComponent_Product_Restrictions_On() IS 1>&ProductListToExcludeFromSelecting_Field_name=ProductListToExcludeFromSelecting</cfif>&FirstParentID=<cfoutput>#FirstParentID#</cfoutput>&prgID=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>";

				if(addProductAtLevel)
				{
					document.all.AllowProductGroupList.value = document.all.Level_1.value;
					sURL = sURL + "&ExistingProductList_Field_Name=Level_" + addProductAtLevel + "&AnotherProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2) + "&Return_Value_Field_Name=Level_" + addProductAtLevel+ "&Return_Value_Group_Field_Name=GroupLevel_" + addProductAtLevel;
					document.compProductTierRates.Product_Search_Window_Return_Type.value = addProductAtLevel;
				}
				NewWindowTopLeft(sURL, "productwindow", 800, 600, "yes", "yes")
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
					//if groupLevel = 1
					document.compProductTierRates.groupLevelProducts.value = "0";
					document.compProductTierRates.Product_Level_1.value = "";
					document.compProductTierRates.Product_List.value = "";
					document.compProductTierRates.ExistingProductList.value = "";
					bSelectedAllProducts = false;
				}
			}
			if(!bSelectedAllProducts)
			{

				//validate for groups
				//77408 Product Group sequencing START
				<CFOUTPUT>
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					var grpLevl#levels# = document.all.GroupLevel_#levels#.value;
				</cfloop>
				</CFOUTPUT>
				//77408 Product Group sequencing END

				//if we have product groups at all levels then don't allow adding products
				if((grpLevl1 != "" && grpLevl1 != 9) && (grpLevl2 != "" && grpLevl2 != 9) && (grpLevl3 != "" && grpLevl3 != 9)
					//77408 Product Group sequencing
					<cfif request.AccessStructure.numberOfProductGroupLevels GT 3> && (grpLevl4 != "" && grpLevl4 != 9) && (grpLevl5 != "" && grpLevl5 != 9) && (grpLevl6 != "" && grpLevl6 != 9) && (grpLevl7 != "" && grpLevl7 != 9 && (grpLevl8 != "" && grpLevl8 != 9))</cfif>)
				{
					alert("Products cannot be added when Groups exist in all levels.");
					return;
				}

				var sURL = "/Flex/search/ItemSearchFx.cfm?Formname=compProductTierRates&DiscountType=4&programId=<cfoutput>#CSL_Contract_Main_ID#<cfoutput></cfoutput></cfoutput>&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#url.Growth_Component_name_ID#</cfoutput>&isparent=1<cfif appsettings.getComponent_Product_Restrictions_On() IS 1>&ProductListToExcludeFromSelecting_Field_name=ProductListToExcludeFromSelecting</cfif>&FirstParentID=<cfoutput>#FirstParentID#</cfoutput>&prgID=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>";

				if(addProductAtLevel)
				{
					document.all.AllowProductGroupList.value = document.all.Level_1.value;
					sURL = sURL + "&ExistingProductList_Field_Name=Level_" + addProductAtLevel + "&AnotherProductListToExcludeFromSelecting_Field_Name=Level_" + ((addProductAtLevel==2)?3:2) + "&Return_Value_Field_Name=Level_" + addProductAtLevel;
					document.compProductTierRates.Product_Search_Window_Return_Type.value = addProductAtLevel;
				}
				NewWindowTopLeft(sURL, "productwindow", 1024, 715, "yes", "yes")
			}
		}


		<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
		function threeDecimalPlaces(textObject){
			if(event.type == "keyup") {

				if(textObject.value.indexOf(".") != -1) {
					if(textObject.value.length - textObject.value.indexOf(".") >= 4) {
						var validNumber = new NumberFormat();
						validNumber.setCommas(false);
						validNumber.setCurrency(false);
						validNumber.setPlaces(4);
						validNumber.setNumber(textObject.value);
						textObject.value = validNumber.toFormatted();
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
		function ApplyAmountToSelectedBoxes(){
			tier = parseInt(document.all.Rate_Tier[document.all.Rate_Tier.selectedIndex].value)
			rate = document.all.Discount_Amount.value
			if(document.all.dataToErrorCheck != null)
			{
				if(document.all.dataToErrorCheck.length)
				{
					for(var x=0; x<document.all.dataToErrorCheck.length; x++){
						tierRateObject = getFirstChild(document.all.dataToErrorCheck[x]);
						if(tierRateObject.getAttribute('Tier_Number') != null) {
							assignRateFlag = eval("document.all."+tierRateObject.getAttribute('assignRateIndicator'))
							if(tierRateObject.getAttribute('Tier_Number') == tier && assignRateFlag.checked) {
								tierRateObject.value = rate;
								resetnavigate();
							}
						}
					}
				}
				else
				{
					tierRateObject = getFirstChild(document.all.dataToErrorCheck);
					if(tierRateObject.getAttribute('Tier_Number') != null) {
						assignRateFlag = eval("document.all."+tierRateObject.getAttribute('assignRateIndicator'))
						if(tierRateObject.getAttribute('Tier_Number') == tier && assignRateFlag.checked) {
							tierRateObject.value = rate;
							resetnavigate();
						}
					}
				}
			}
		}

		function selectAll(){
			document.all.checkall.checked = event.srcElement.checked;

			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<checkAllProducts.length;x++) {
					box = getFirstChild(checkAllProducts[x]);
					box.checked = document.all.checkall.checked
				}
			}
			else{
				if(document.all.checkAllProducts != null){
					box = getFirstChild(checkAllProducts);
					box.checked = document.all.checkall.checked
				}
			}
		}

		function applyGlobalUOM(){
			gUOM = document.all.Global_UOM.selectedIndex;

			if(document.all.UOMCollection != null){
				if(UOMCollection.length != null){
					for(var x = 0; x<UOMCollection.length;x++){
						getFirstChild(UOMCollection[x]).selectedIndex = gUOM;
						callfireEvent(document,getFirstChild(UOMCollection[x]),'Change');
						resetnavigate();
					}
				}
				else{
					getFirstChild(UOMCollection).selectedIndex = gUOM;
					callfireEvent(document,getFirstChild(UOMCollection),'Change');
					resetnavigate();
				}
			}
		}

	</SCRIPT>

</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getAllowNavigate()>onbeforeunload="verifyNavigate();"</cfif>>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(cryp.value)>
<cfset SimilarExistingProductList = ValueList(SimilarExistingProduct.BSA_Foodservice_Items_Master_ID)>

<!---Revision restrictions --->

<!---Default to always being able to add --->
<cfset ProductsAdded = 1>
<cfset ProductsRemoved = 1>
<cfset ProductsRatesChanges = 1>
<cfset ProductsUOMChanges = 1>

<!---Add products --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	<cfset ProductsAdded = 2>
</cfif>

<!---Delete products --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2>
	<cfset ProductsRemoved = 2>
</cfif>

<!---Change rates --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Rates_Changes eq 2>
	<cfset ProductsRatesChanges = 2>
</cfif>

<!---Change UOM  --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_UOM_Changes eq 2>
	<cfset ProductsUOMChanges = 2>
</cfif>
<!---NOTE: Restrictions on changing componentns made in Contract_Discount_Growth_Navigation.cfm page --->

<!---This is get access to information on the previous version of the revision to help identify which products to restrict and which not to. --->

<cfset DiscountType = 4>
<cfset ProductItemList = "NULL">

<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>

	<cfif Not IsDefined("ProgramManager")>
		<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	</cfif>

	<cfif NOT IsDefined("ParentprogramInfo")>
		<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(cryp.value)>
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

</cfif>

<!---End Revision Restrictions --->


<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>

<!---set if groups are static or dynamic--->
<cfif isDefined("GetSettings.Dynamic_Static_Groups")>
	<cfset form.Dynamic_Static_Groups = GetSettings.Dynamic_Static_Groups />
</cfif>

<!---Modification: Group Deals--->
<cfset form.Discount_Growth_Item_Level = GetSettings.Discount_Growth_Item_Level />
<cfset form.Discount_Growth_Group_Level = GetSettings.Discount_Growth_Group_Level />

<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<!------ Get pricing level descriptions ----->
<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />

<cfif url.EZTemplate EQ 0>
<BLOCKQUOTE><BLOCKQUOTE>
</cfif>

<script>
	function showGroupSearchWindow(){
		//do validation first
		var prodList = document.compProductTierRates.Product_List.value;
		var grpLevel1 = document.compProductTierRates.GroupLevel_1.value;
		NewWindowTopLeft("Groups/index.cfm?formname=compProductTierRates&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&lExcludeFormField=ProductListToExcludeFromSelecting&Discountype=4&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#url.Growth_Component_name_ID#</cfoutput>&isparent=1", "productwindow", 800, 600, "yes", "yes");
	}
</script>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 65px; top: 0px;">
</cfif>

<cfif url.EZTemplate EQ 0>
<cfinclude template="minimal_contract_info.cfm">
</cfif>
<CFPARAM NAME="FORM.Component_ID" 	DEFAULT="">
<CFPARAM NAME="URL.COMPID" 	DEFAULT="#FORM.Component_ID#">
<cfparam name="Component_ID" default="#URL.COMPID#">

<CFQUERY NAME="getComponentTierInfo" datasource="#application.datasource#">
	SELECT	Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID,
			Program_Growth_Component_Tiers.Program_Growth_Component_ID,
				Program_Growth_Component_Tiers.Program_ID,
				Program_Growth_Component_Tiers.Tier_Number,
				Program_Growth_Components.Tier_Count,
				Program_Growth_Components.Component_name,
				Program_Growth_Components.Program_Growth_Component_Type_ID,
				Program_Growth_Components.Rate_Type
		FROM	Program_Growth_Component_Tiers
		INNER JOIN Program_Growth_Components
		ON 	Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
		WHERE	Program_Growth_Component_Tiers.Deleted = 0
		AND 	Program_Growth_Component_Tiers.Program_ID = '#FORM.Contract_Main_ID#'
		AND		Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#URL.COMPID#'
		ORDER BY Program_Growth_Component_Tiers.Tier_Number
</CFQUERY>

<cfif GetComponentTierInfo.Recordcount LT 1>

	There are no tiers, redirect appropriately to get some.

	<!---If the new growth stuff is in, figure out where to redirect. Otherwise redirect to edit components--->
	<cfif appSettings.getGrowthExpansion1()>

		<!---Get component type--->
		<cfset useLakebaseForGetComponentType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
		<cfif useLakebaseForGetComponentType>
			<cftry>
				<cfset GetComponentType = application.oLakebase.toQuery(
					application.oLakebase.selectRows("program_growth_components", { "program_growth_component_id" = "eq.#URL.COMPID#", "select" = "program_growth_component_type_id" })
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetComponentType = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetComponentType>
			<cfquery name="GetComponentType" datasource="#application.datasource#">
				SELECT 	Program_Growth_Component_Type_ID
				FROM 	Program_Growth_Components
				WHERE 	Program_Growth_Component_ID = '#URL.COMPID#'
			</cfquery>
		</cfif>
		<!---If it's normal, go to Contract_Discount_Growth_Add_Component.cfm--->
		<cfif GetComponentType.Program_Growth_Component_Type_ID IS 1>
			<cflocation url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#URL.COMPID#&CID=#URL.CID#&Action=Edit&Component_Type=#GetComponentType.Program_Growth_Component_Type_ID#&EZTemplate=#url.EZTemplate#">
		<!---If it's Stairway or XofY, go to Contract_Discount_Add_Target.cfm--->
		<cfelse>
			<cflocation url="Contract_Discount_Growth_Add_Target.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#URL.COMPID#&CID=#URL.CID#&Component_Type=#GetComponentType.Program_Growth_Component_Type_ID#&EZTemplate=#url.EZTemplate#">"
		</cfif>
	<cfelse>
		<cflocation url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#URL.COMPID#&CID=#URL.CID#&Action=Edit&EZTemplate=#url.EZTemplate#">
	</cfif>
	<cfabort>
</cfif>

<cfset Tier_Count = getComponentTierInfo.Tier_Count>
<cfset Component_Type 	= getComponentTierInfo.Program_Growth_Component_Type_ID>
<cfset Rate_Type 		= getComponentTierInfo.Rate_Type>
<cfset Component_ID 	= URL.COMPID>

<!---In case we never calculated tier number--->
<cfif len(trim(Tier_Count)) IS 0 AND getComponentTierInfo.Program_Growth_Component_Type_ID IS NOT 1>

	<cfquery name="PreviousTiers" datasource="#application.datasource#">
		SELECT 	COUNT(*) AS Previous_Tier_Count
		FROM 	Program_Growth_Components
		WHERE 	Deleted = 0
		AND 	Program_Growth_Components.Parent_ID = '#Component_ID#'
	</cfquery>

	<cfif PreviousTiers.Recordcount GT 0>

		<cfset Tier_Count = PreviousTiers.Recordcount>

		<cfset useLakebaseForUpdateComponentTierInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForUpdateComponentTierInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_components",
			{
				"program_growth_component_id" = "eq.#Component_ID#"
			},
			{
				"tier_count" = "#PreviousTiers.Recordcount#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateComponentTierInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateComponentTierInfo>
<cfquery name="UpdateComponentTierInfo" datasource="#application.datasource#">

			UPDATE 	Program_Growth_Components
			SET 	Tier_Count = #PreviousTiers.Recordcount#
			WHERE 	Program_Growth_Components.Program_Growth_Component_ID = '#Component_ID#'

		</cfquery>
</cfif>

	</cfif>

</cfif>

<!---Include navigation--->
<cfif appSettings.getGrowthExpansion1()>
	<cfinclude template="/common_files/contracts/contract_discount_growth_navigation.cfm">
</cfif>

<cfset useLakebaseForGetContractUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGetContractUOM>
	<cftry>
		<cfset getContractUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", { "unit_of_measure_id" = "eq.#CSLGetContractInfo.Contract_Quantity_UOM_IDX#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetContractUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractUOM>
	<CFQUERY NAME="getContractUOM" datasource="#application.datasource#">
		SELECT 	*
		FROM 	Units_Of_Measure
		WHERE 	Unit_Of_Measure_ID = '#CSLGetContractInfo.Contract_Quantity_UOM_IDX#'
	</CFQUERY>
</cfif>


<!--- load the data into the structure from tables --->
<CFSET LoadedGrowthDataStruct = StructNew()>
<CFSET LoadedComponentID = URL.COMPID>

<!--- holds all the products supplied from the form page --->
<CFSET LoadedGrowthDataStruct.Products = StructNew()>
<CFIF NOT IsDefined("FORM.Product_List")>

	<!------ Load From DB ----->
		<CFQUERY NAME="Get_Growth_Comp_Products" DATASOURCE="#application.datasource#">
			SELECT	BSA_Foodservice_Items_Master_ID,
											Contract_Products.Product_Group_Level_ID,
											Contract_Products.Product_Group_ID,
											Contract_Products.Is_Group,
											Contract_Products.Pricing_Level_ID,
											EZButton_On_Default
				FROM	Contract_Products
				INNER JOIN	Program_Growth_Component_Product_Data
				ON Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
				AND Program_Growth_Component_Product_Data.Deleted = 0
				AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#LoadedComponentID#'
				WHERE	Contract_Products.Deleted = 0
				AND 	Contract_Products.Contract_Main_ID = #FORM.Contract_Main_ID#
				AND	Contract_Products.Discounted_Item = 1
			<!---filter on groups if they exist--->
			AND (
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					)
		</CFQUERY>
	<!---handle for multi level groups--->
	<cfset useLakebaseForqGetGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_growth_comp_products")>
<cfif useLakebaseForqGetGroups>
	<cftry>
		<cfset qGetGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_growth_comp_products", {
				"is_group" = "eq.1",
				"select" = "bsa_foodservice_items_master_id,product_group_level_id,pricing_level_id"
			}), "bsa_foodservice_items_master_id,product_group_level_id,pricing_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroups>
<cfquery name="qGetGroups" dbtype="query">
		SELECT 	BSA_Foodservice_Items_Master_ID, 	Product_Group_Level_ID, Pricing_Level_ID
		FROM	Get_Growth_Comp_Products
		WHERE	Is_Group = 1
	</cfquery>
</cfif>
	<!---if we have a record set then we know we have groups so we have to handle for it--->
	<cfif qGetGroups.RecordCount>

		<cfloop query="qGetGroups">

			<cfif not ListFindNoCase("form.Level_#Pricing_Level_ID#", BSA_Foodservice_Items_Master_ID)>
				<cfset "form.Level_#Pricing_Level_ID#" = ListAppend(Evaluate("form.Level_#Pricing_Level_ID#"), BSA_Foodservice_Items_Master_ID) />
			</cfif>

			<cfif trim(Evaluate("form.GroupLevel_#Pricing_Level_ID#")) eq "">
				<cfset "form.GroupLevel_#Pricing_Level_ID#" = Product_Group_Level_ID />
			</cfif>
		</cfloop>

		<!---if we have groups check to see if there are any products--->
		<cfset useLakebaseForqGetProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_growth_comp_products")>
<cfif useLakebaseForqGetProducts>
	<cftry>
		<cfset qGetProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_growth_comp_products", {
				"is_group" = "eq.0",
				"select" = "bsa_foodservice_items_master_id,product_group_level_id,pricing_level_id"
			}), "bsa_foodservice_items_master_id,product_group_level_id,pricing_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProducts>
<cfquery name="qGetProducts" dbtype="query">
			SELECT 	BSA_Foodservice_Items_Master_ID, Product_Group_Level_ID, Pricing_Level_ID
			FROM	Get_Growth_Comp_Products
			WHERE	Is_Group = 0
		</cfquery>
</cfif>

		<!---77408 Product Group sequencing START--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			<cfparam name="form.level_#levels#" default ="">
			<cfparam name="form.GroupLevel_#levels#" default ="0">
		</cfloop>
		<!---77408 Product Group sequencing END--->

		<cfif qGetProducts.RecordCount and qGetProducts.Pricing_Level_ID gt 0>
			<cfloop query="qGetProducts">
				<cfif not ListFindNoCase("form.Level_#Pricing_Level_ID#", BSA_Foodservice_Items_Master_ID)>
					<cfset "form.Level_#Pricing_Level_ID#" = ListAppend(Evaluate("form.Level_#Pricing_Level_ID#"), BSA_Foodservice_Items_Master_ID) />
				</cfif>

				<cfif trim(Evaluate("form.GroupLevel_#Pricing_Level_ID#")) eq "">
					<cfset "form.GroupLevel_#Pricing_Level_ID#" = Product_Group_Level_ID />
				</cfif>

			</cfloop>

		</cfif>

	</cfif>

	<CFSET FORM.Product_List = ValueList(Get_Growth_Comp_Products.BSA_Foodservice_Items_Master_ID, ",")>
	<cfset useLakebaseForqGetLevel_1_Products = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_growth_comp_products")>
<cfif useLakebaseForqGetLevel_1_Products>
	<cftry>
		<cfset qGetLevel_1_Products = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_growth_comp_products", {
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
		SELECT	Product_Group_ID
		FROM	Get_Growth_Comp_Products
		WHERE	Product_Group_Level_ID = 1
	</cfquery>
</cfif>
	<cfset FORM.Product_Level_1 = ValueList(qGetLevel_1_Products.Product_Group_ID) />
</CFIF>

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<cfif EzButton_Disable EQ 1>
<cfset EZProgramManager = CreateObject("component", "components.programs.EZButton_programManager") />
<cfset GetEZButtonDefaultRates = EZProgramManager.getGrowthEZSettings(getsettings.EZ_Contract_Id,FORM.Product_List,url.Growth_Component_Name_ID)>
</cfif>

<!--- consider the following scenario
	  select one product from group
	  delete it without save
	  add product
--->
<cfif isDefined("form.GroupLevel_1") and form.GroupLevel_1 neq "" and isDefined("form.LEVEL_1") and form.LEVEL_1 eq "" and isDefined("FORM.Product_List") and FORM.Product_List neq "">
	<cfset form.GroupLevel_1 = "" />
</cfif>
<!------ Product Group Code ----->
<cfparam name="FORM.Product_Level_1" 	default="">
<cfparam name="FORM.groupLevelProducts" 	default="0">
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif Len(FORM.Product_Level_1) GT 0>
	<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
	<cfset form.Product_List = groupLevelProductId />
	<cfset FORM.groupLevelProducts = 1 />

</cfif>

<!---
if the product search is returning products to be added to either level 2 or level 3
then we have to set the group level variable to 9 for that level and determine which products go into which buckets
--->
<cfparam name="Form.Product_Search_Window_Return_Type" 	default ="0">
<cfif form.Product_Search_Window_Return_Type  GTE 2>
	<cfset form.Product_List = "" />
	<!---77408 Product Group sequencing START--->
	<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		<cfset form.Product_List = ListAppend(form.Product_List, Evaluate("form.Level_#levels#"), ",") />
	</cfloop>
	<!---77408 Product Group sequencing END--->
	<cfset "form.GroupLevel_#form.Product_Search_Window_Return_Type#" = 9 />
</cfif>

<!--- get the component products --->
<!--- changed 4-30-2005...mws...added everything from union and below to account for same product being added to multiple components --->
<CFQUERY name="getComponentProducts" datasource="#application.datasource#">
SELECT	FIM.BSA_Foodservice_Items_Master_ID,
	FIM.Inventory_UM,
	<cfif FORM.groupLevelProducts EQ 1>
		'' As UPC,
		'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products' As Description,
		'' As Item,
	<cfelse>
	FIM.UPC,
	FIM.Description,
	FIM.Item,
		</cfif>
		PGCPD.Contract_Products_ID,
		PGC.Program_Growth_Component_ID,
		PGCPD.Program_Growth_Component_Product_Data_ID,
		CP.EZButton_On_Default,
		APGT.Group_Number
		FROM	BSA_Foodservice_Items_Master FIM
		INNER JOIN Program_Growth_Components PGC
		ON PGC.Program_Growth_Component_ID = '#LoadedComponentID#'
		AND PGC.IsParent = 1
		AND PGC.Deleted = 0
	<cfif FORM.groupLevelProducts EQ 1>
		LEFT JOIN Business_Segment
		ON Business_Segment.Deleted = 0
		AND Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
	</cfif>
		INNER JOIN Contract_Products CP
		ON CP.BSA_Foodservice_Items_Master_ID = FIM.BSA_Foodservice_Items_Master_ID
		AND CP.Deleted = 0
		AND CP.Discounted_Item = 1
		AND CP.Product_Type_ID = 4
		AND CP.Contract_Main_ID = #FORM.Contract_Main_ID#
		AND ((CP.Product_Group_ID = CAST(CP.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND CP.Is_Group = 1)
		   OR
		(ISNULL(CP.Product_Group_ID, '') = '' AND CP.Is_Group = 0))
		INNER JOIN Program_Growth_Component_Product_Data PGCPD
		ON CP.Contract_Products_ID = PGCPD.Contract_Products_ID
		AND PGCPD.Deleted = 0
		AND PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
		LEFT JOIN All_Product_Group_Types APGT
		ON APGT.Group_GUID = FIM.BSA_Foodservice_Items_Master_ID
		WHERE <cfif FORM.Product_List EQ ""> 	1=2 <CFELSE>	FIM.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)	</cfif>

UNION

		SELECT		FIM.BSA_Foodservice_Items_Master_ID,
		FIM.Inventory_UM,
		<cfif FORM.groupLevelProducts EQ 1>
			'' As UPC,
			'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products' As Description,
			'' As Item,
		<cfelse>
			FIM.UPC,
			FIM.Description,
			FIM.Item,
		</cfif>
		PGCPD.Contract_Products_ID,
		PGC.Program_Growth_Component_ID,
		PGCPD.Program_Growth_Component_Product_Data_ID,
		CP.EZButton_On_Default,
		APGT.Group_Number
		FROM BSA_Foodservice_Items_Master FIM
		INNER JOIN Program_Growth_Components PGC
		ON PGC.Program_Growth_Component_ID = '#LoadedComponentID#'
		AND PGC.IsParent = 1
		AND PGC.Deleted = 0
	<cfif FORM.groupLevelProducts EQ 1>
		LEFT JOIN Business_Segment
		ON Business_Segment.Deleted = 0
		AND Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
	</cfif>
		LEFT JOIN Contract_Products CP
		ON CP.BSA_Foodservice_Items_Master_ID = FIM.BSA_Foodservice_Items_Master_ID
		AND CP.Deleted = 0
		AND CP.Discounted_Item = 1
		AND CP.Product_Type_ID = 4
		AND CP.Contract_Main_ID = #FORM.Contract_Main_ID#
		AND
				(
					(CP.Product_Group_ID = CAST(CP.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND CP.Is_Group = 1)
					OR
					(ISNULL(CP.Product_Group_ID, '') = '' AND CP.Is_Group = 0)
				)
		LEFT JOIN All_Product_Group_Types APGT
		ON APGT.Group_GUID = FIM.BSA_Foodservice_Items_Master_ID
		LEFT JOIN 	Program_Growth_Component_Product_Data PGCPD
		ON CP.Contract_Products_ID = PGCPD.Contract_Products_ID
		AND PGCPD.Deleted = 0
		AND PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
		WHERE
		<cfif FORM.Product_List EQ "">
			1=2
		<CFELSE>
			FIM.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)
		</CFIF>
				and
				(FIM.BSA_Foodservice_Items_Master_ID Not IN
					(SELECT	FIM.BSA_Foodservice_Items_Master_ID
				FROM	BSA_Foodservice_Items_Master FIM
				INNER JOIN
				Program_Growth_Components PGC
				ON PGC.Program_Growth_Component_ID = '#LoadedComponentID#'
				AND PGC.IsParent = 1
				AND PGC.Deleted = 0
			<cfif FORM.groupLevelProducts EQ 1>
					LEFT JOIN Business_Segment
					ON Business_Segment.Deleted = 0
					AND Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
		  </cfif>
				INNER JOIN
				Contract_Products CP
				ON CP.BSA_Foodservice_Items_Master_ID = FIM.BSA_Foodservice_Items_Master_ID
				AND CP.Deleted = 0
				AND CP.Discounted_Item = 1
				AND CP.Product_Type_ID = 4
				AND CP.Contract_Main_ID = #FORM.Contract_Main_ID#
				AND
				(
					(CP.Product_Group_ID = CAST(CP.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND CP.Is_Group = 1)
					OR
					(ISNULL(CP.Product_Group_ID, '') = '' AND CP.Is_Group = 0)
				)
				INNER JOIN Program_Growth_Component_Product_Data PGCPD
				ON CP.Contract_Products_ID = PGCPD.Contract_Products_ID
				AND PGCPD.Deleted = 0
				AND PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
	WHERE <cfif FORM.Product_List EQ "">1=2	<CFELSE>FIM.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)</cfif>))
</CFQUERY>

<!---handle for multi level groups--->
<!---determine what level to put products in--->
<!---77408 Product Group sequencing START--->
<cfloop from="2" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<cfif trim(Evaluate("form.GroupLevel_#levels#")) neq "" and trim(Evaluate("form.GroupLevel_#levels#")) neq 9>

			<cfquery name="qGetProdsForLevel" dbtype="query">
				SELECT	BSA_Foodservice_Items_Master_ID
				FROM	getComponentProducts
				WHERE	1 = 1
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="pl">
				<cfif len(Evaluate("FORM.Level_#pl#")) AND levels NEQ pl>
					AND 	BSA_Foodservice_Items_Master_ID NOT IN (#ListQualify(Evaluate("FORM.Level_#pl#"), "'")#)
				</cfif>
				</cfloop>
			</cfquery>

		<cfset "form.Level_#levels#" = ''>
		<cfif qGetProdsForLevel.RecordCount>
			<cfset "form.Level_#levels#" = ValueList(qGetProdsForLevel.BSA_Foodservice_Items_Master_ID) />
			<cfif trim(Evaluate("form.GroupLevel_#levels#")) eq "">
				<cfset "form.GroupLevel_#levels#" = 9 />
			</cfif>
		</cfif>
	</cfif>
</cfloop>
<!---77408 Product Group sequencing END--->

<cfset FORM.Product_List = ValueList(getComponentProducts.BSA_Foodservice_Items_Master_ID, ",")>

<!--- get this components tiers --->
<CFQUERY name="getComponentTiers" datasource="#application.datasource#">
		SELECT	Program_Growth_Component_Tier_ID,	Tier_Number
		FROM	Program_Growth_Component_Tiers
		WHERE	Program_Growth_Component_ID = '#LoadedComponentID#'
		AND 	Deleted = 0
		ORDER BY CAST(Tier_Number AS FLOAT)
</CFQUERY>

<CFQUERY name="GetAllContractInfo" datasource="#application.datasource#">
	SELECT	*
	FROM	Contract_Main
	INNER JOIN Units_of_Measure ON
	Contract_Main.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID
	WHERE 	Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>

<cfset 	businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
<cfset	bAllowSelectAllProducts = ProductGroupManager.allowSelectAllProducts(4, FORM.Contract_Main_ID) />
<cfset  bGrowthSelectProductsType = ProductGroupManager.growthSelectProductsType(FORM.Contract_Main_ID, LoadedComponentID) />
<cfif bGrowthSelectProductsType GT 0>
	<cfset bAllowSelectAllProducts = 0 />
</cfif>
<cfset bAllowSelectProducts = 1 />
<cfif bGrowthSelectProductsType GT 1>
	<cfset bAllowSelectProducts = 0 />
</cfif>

<!---If search sequences are on, modify what they're allowed to see (product or group) based on search sequences as well as other template settings--->
<cfif appSettings.getSearchSequenceOn()>
	<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(CSLGETCONTRACTINFO.Search_Sequence_ID) />
	<cfset 	Form.Discount_Growth_Item_Level =  SearchSequenceManager.enableProductSelection(Program_Search_Sequence) />
	<cfset 	Form.Discount_Growth_Group_Level = SearchSequenceManager.enableGroupSelection(Program_Search_Sequence) />
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

<cfset availableLowerLevels = "" />
<cfif forceProductSearchAtLowerLevel>
	<cfif form.Level_1 NEQ "">
	<!---77408 Product Group sequencing START--->
	<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
		<cfset "level_#levels#_Group_Type" = Evaluate("form.GroupLevel_#levels#") />
	</cfloop>
	<!---77408 Product Group sequencing END--->

		<cfif Form.Discount_Growth_Group_Level EQ 1 AND level_1_Group_Type NEQ "" AND level_1_Group_Type NEQ "0" AND level_1_Group_Type NEQ "9"><!------ If level1 is group, enable product serach ----->
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
				<cfset Form.Discount_Growth_Item_Level = 1>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<table border="0" width="800px">
	<tr>
		<td class="title2" colspan="100%">Growth Component :<cfoutput>#getComponentTierInfo.Component_Name#</cfoutput></td>
	</tr>
<cfif getComponentProducts.Recordcount LT 1>
	<cfif NOT bAllowSelectProducts>
	<tr>
		<td style="color:red;font-weight: bold;padding:5px;">
			You cannot select products if you already have a component with 'All Products'
		</td>
	</tr>
	<cfelse>
	<tr>
		<td style="font-weight: bold;padding:5px;">1. Select products</td>
	</tr>
	<tr>
		<td>
		<table>
			<tr>
				<td>
					<!----add groups links if it's on--->
					<cfif form.Discount_Growth_Group_Level IS 1>
						<cfset addGroupLabel = "add groups" />
						<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel() AND appSettings.get_Setting('Product_Group_Sequencing') neq '1'>
							<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
						</cfif>

							<CF_button
								button_name		=	""
								button_caption	=	"#addGroupLabel#"
								button_action	=	"javascript: showGroupSearchWindow();"
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
			<cfif form.Discount_Growth_Item_Level>
				<td>
					<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
						<CF_button
							button_name		=	""
							button_caption	=	"select products"
							button_action	=	"javascript: showProductSearchWindow(1);"
							button_type		=	"javascript_link"
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
							button_caption	=	"select products"
							button_action	=	"javascript: showProductSearchWindow_old(1);"
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
			</tr>
		</table>
	</cfif>
	<cfif bAllowSelectAllProducts>
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
	</tr>
</cfif>
</table>

<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaSCript">
	var my_queue = new Queue();
</SCRIPT>

<SCRIPT>
	var arPROGRAM_GROWTH_COMPONENT_TIER_ID = new Array();
	<cfoutput>
	var listPROGRAM_GROWTH_COMPONENT_TIER_ID = "#Replace(valuelist(getComponentTiers.PROGRAM_GROWTH_COMPONENT_TIER_ID), "-", "_", "all")#";
	arPROGRAM_GROWTH_COMPONENT_TIER_ID = listPROGRAM_GROWTH_COMPONENT_TIER_ID.split(",");
	</cfoutput>


	function deleteThisGrowthProd(FieldnameRe, prodID, checkCounter, globalCounter, ComponentID, bckRdColor, grouplevelID, realGroupLevelId)
	{
		var trObj = document.getElementById("TR_" + FieldnameRe);
		var tabObj = document.getElementById("TAB_" + FieldnameRe);
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.compProductTierRates.Product_List.value;
<!---77408 Product Group sequencing START--->
<cfoutput>
	<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			var level#levels#List = document.compProductTierRates.Level_#levels#.value;
			var level#levels#String = ListDeleteItem(level#levels#List, ",", prodID);
	</cfloop>
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = 'true';
		var objGroupLevel;

		if (!validateGroups()){
			return;
		}

		if(resultString == FINALITEMLIST){
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = 'false';
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				if (grouplevelID == #levels#)
					level1String = ListAppendItem(level#levels#String, ",", prodID);
			</cfloop>
		}

		objGroupLevel = eval("document.all.GroupLevel_" + grouplevelID);

		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			document.compProductTierRates.Level_#levels#.value = level#levels#String;
		</cfloop>

		if (!validateGroups()){
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
				document.compProductTierRates.Level_#levels#.value = "";
				document.compProductTierRates.Level_#levels#.value = level#levels#List;
			</cfloop>
			return;
		}
</cfoutput>
<!---77408 Product Group sequencing END--->
		document.compProductTierRates.Product_List.value = resultString;
		document.compProductTierRates.ExistingProductList.value = resultString;

		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		if(trObj){
			var srcObj = event.srcElement;
			//cut
			if(bDelete == 'true'){
				//trObj.cells[0].innerHTML = empty_String;
				trObj.cells[trObj.cells.length - 1].innerHTML = empty_String;

				var j, rowlen
				rowlen = tabObj.rows.length;
				for (j = 1;j < rowlen; j++){
					my_queue.addObjValueToQueue(prodID + "_Tier_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldnameRe);
					tabObj.rows[j].cells[1].innerHTML = "<img src=\"../../Images/fill.gif\"> ";
					my_queue.addObjValueToQueue(prodID + "_Tier_UOM_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldnameRe + "_UOM");
					disableDiv(tabObj.rows[j].cells[2], true, false);
				}

				propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);

				propogateProperty(tabObj, "style.backgroundColor", "#CCCCCC", false);
				propogateProperty(tabObj, "style.textDecoration", "line-through", true);

				srcObj.title = "undo product deletion";
				srcObj.src = undodeleteImg.src;
				resetnavigate();
			}
			//undo
			else
			{
				//trObj.cells[0].innerHTML = "<span ID=\"checkAllProducts\"><input TYPE=\"Checkbox\" NAME=\"RateApplyer_" + checkCounter + "\" ONCLICK=\"if(!this.checked) document.all.checkall.checked = false;\" checked></span>";
				trObj.cells[trObj.cells.length - 1].innerHTML = "<span ID=\"checkAllProducts\"><input TYPE=\"Checkbox\" NAME=\"RateApplyer_" + checkCounter + "\" ONCLICK=\"if(!this.checked) document.all.checkall.checked = false;\" checked></span>";

				//var bgCol = "#FFFFFF";
				var bgCol = bckRdColor;
				var tabCol = "#FFFFCC";

				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				propogateProperty(tabObj, "style.backgroundColor", tabCol, false);
				propogateProperty(tabObj, "style.textDecoration", "none", false);

				var j, rowlen
				rowlen = tabObj.rows.length;
				for (j = 1;j < rowlen; j++){
					globalCounter++;
					tabObj.rows[j].cells[1].innerHTML = "<span ID=\"error_" + globalCounter + "\"></span><span ID=\"dataToErrorCheck\" errorSpanname=\"error_" + globalCounter + "\" errorMessage=\"Enter A Tier Rate\"><input type=\"Text\" SIZE=\"6\" name=\"Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldnameRe + "\" value=\"\" ONKEYUP=\"clenseText(this, '.0123456789');threeDecimalPlaces(this)\" ONBLUR=\"threeDecimalPlaces(this);\" Tier_Number=\"" + j + "\" assignRateIndicator=\"RateApplyer_" + checkCounter + "\"></SPAN>";
					my_queue.deleteAndSetObjValueFromQueue(prodID + "_Tier_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldnameRe);
					disableDiv(tabObj.rows[j].cells[2], false, false);
					my_queue.deleteAndSetObjValueFromQueue(prodID + "_Tier_UOM_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldnameRe + "_UOM");
				}

				propogateProperty(tabObj, "style.backgroundColor", "#ffffff", false, true);

				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;
				/* For level 0, "objGroupLevel" does not exist. */
				if(objGroupLevel){
					if(objGroupLevel.value == ""){
						objGroupLevel.value = realGroupLevelId;
					}
				}
			}
			srcObj.setAttribute('bDelete',(bDelete == 'true'?'false':'true'));
		}
	}

	//validate groups
	function  validateGroups(){
		var thisForm = document.all;
		<!---77408 Product Group sequencing START--->
		<cfoutput>
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			var level#levels# = thisForm.Level_#levels#.value;
		</cfloop>

		var bIsValid= true;

		<cfif request.AccessStructure.numberOfProductGroupLevels EQ 3>
			//if we have something in level 2 or level 3 make sure something is in level 1
			if (trim(level2) != "" || trim(level3) != "")	{
				if(trim(level1) == ""){
					alert("#arPricingLevel[1]# cannot be empty if Groups or Products exist in #arPricingLevel[2]# or #arPricingLevel[3]#.");
					bIsValid = false;
					return bIsValid;
				}
			}
		</cfif>
		</cfoutput>
		return bIsValid;
	}
</SCRIPT>

<CFOUTPUT>

<FORM
ACTION="Contract_Discount_Growth_Add_Component_Products.cfm?CID=#URL.CID#&COMPID=#URL.COMPID#&EZTemplate=#url.EZTemplate#&Growth_Component_name_ID=#url.Growth_Component_name_ID#"
METHOD="post" name="compProductTierRates" ID="compProductTierRates" STYLE="DISPLAY:INLINE;">

<input type="hidden" name="Tier_List" value="#replace(valuelist(getComponentTierInfo.Program_Growth_Component_Tier_ID), "-", "_", "ALL")#">
<input type="hidden" name="Program_ID" value="#URL.CID#">
<input type="hidden" name="Component_ID" value="#URL.COMPID#">
<input type="hidden" name="ChildID" value="#ChildID#">

<cfif getComponentProducts.Recordcount GT 0>
<!---Revision restrictions --->
<cfif ProductsRatesChanges IS NOT 2>
	<table width="800" border="0" cellspacing="0" cellpadding="2">
		<tr VALIGN="top" STYLE="border-bottom:2px solid navy;">
			<td NOWRAP>
				<CF_SmallHelp WIDTH="450">You may choose to apply the same rate to all the items. Select the tier, specify the rate and click apply. <br>Click on the save button when you are done.</CF_SmallHelp>
				&nbsp;&nbsp;&nbsp;
				<FONT SIZE="2">
				<B>Tier:</B>
				<select name="Rate_Tier">
					<cfloop index="LoopCount" FROM="1" TO="#Tier_Count#" STEP="1">
						<option value="#LoopCount#">#LoopCount#</option>
					</cfloop>
				</select>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<B>Rate:</B> <input type="Text" name="Discount_Amount" SIZE="3" ONKEYUP="clenseText(this, '.0123456789');">&nbsp;&nbsp;&nbsp;&nbsp;
				<A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;" <cfif EzButton_Disable EQ 1>disabled</cfif>>#application.util.string.actionLinkFormat2('apply rate')#</A>
				</FONT>
			</td>
		</tr>
	</table>
	<!---Revision restrictions --->
	</cfif>

	<CFQUERY name="getAllLevels" datasource="#application.datasource#">
		select isnull(MAX(Pricing_Level_ID),0) AS Pricing_Level_ID
		from Contract_Products
		where Deleted = 0
		and contract_main_id = #FORM.Contract_Main_ID#
		and Product_Type_ID = 4
		and is_Group = 1
	</CFQUERY>

<table width="800" border= "0">
<tr>
	<td nowrap>
		<a href="javascript: verifyData();">#application.util.string.actionLinkFormat2('save')#</a>
<!---Only show item or group add in revision if it's not restricted --->
<cfif ProductsAdded IS NOT 2>
	<!----add groups links if it's on--->
	<cfif form.Discount_Growth_Group_Level>
		<cfset addGroupLabel = "add groups" />
		<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel() AND appSettings.get_Setting('Product_Group_Sequencing') neq '1'>
			<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
		</cfif>
			<a href="javascript: showGroupSearchWindow();">#application.util.string.actionLinkFormat2(addGroupLabel)#</a>
	</cfif>

	<cfif bAllowSelectProducts>
		<cfset addProductLabel = "add products" />
		<cfset addProductAtLevel = 0 /> <!------ Default, determine by itself ----->
		<cfset provideLevel3Link = 0 />


			<!---77408 Product Group sequencing START--->
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>

				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					<cfif Evaluate("form.GroupLevel_#levels#") EQ 9>
						<cfset nextLevel = levels><cfbreak>
					<cfelseif Evaluate("Form.GroupLevel_#levels#") NEQ ''>
						<cfset nextLevel = levels + 1>
					<cfelse>
						<cfset nextLevel = 1>
					</cfif>
				</cfloop>

				<cfif nextLevel LTE request.AccessStructure.numberOfProductGroupLevels>
					<cfset addProductLabel = "add products" />
					<cfset addProductAtLevel = nextLevel />
					<cfset provideLevel3Link = 1 />
				</cfif>
			<!---77408 Product Group sequencing END--->
		<cfelse>
			<cfif restrictLowerLevelBasedonLevel1>
			<cfif getAllLevels.Pricing_Level_ID LTE 1>
				<cfset addProductLabel = "add #LCase(arPricingLevel[2])# products" />
				<cfset addProductAtLevel = 2 /> <!------ At level 2 ----->
						<cfset provideLevel3Link = 1 />
					<cfelse>
				<cfset addProductLabel = "add #LCase(arPricingLevel[3])# products" />
				<cfset addProductAtLevel = 3 /> <!------ At level 3 ----->
				<cfset provideLevel3Link = 0 />
			</cfif>
		</cfif>
	</cfif>
		<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
			<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
		<cfelse>
			<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
				<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
			<cfelse>
				<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
			</cfif>
			<cfif provideLevel3Link>
				<cfset addProductLabel = "add #LCase(arPricingLevel[addProductAtLevel])# products" />
				<cfset addProductAtLevel = addProductAtLevel />
				<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
					<a href="javascript: showProductSearchWindow(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
				<cfelse>
					<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<cfif bAllowSelectAllProducts>
		<a href="javascript: addGroupsLevelProducts(1, \'0\');">#application.util.string.actionLinkFormat2('add all products')#</a>
	</cfif>
<!---Revision restrictions --->
</cfif>
	</td>
	<td width="100%" align="right">
		<!---revision restrictions --->
		<cfif ProductsUOMChanges IS NOT 2>
			<cfif GrowthTierPercentUOM.Program_Growth_Comparison_Period_UOM_ID eq 2><cfset ListOfAvailUOM="3"></cfif>
			<font style="font-weight:bold; font-size:11px; color: navy;">Global UOM:</font>&nbsp;&nbsp;
			<cf_uom_dropdown
						company_main_id			=	""
						default_option_on		=	""
						setDefaultSelected 		=	"#defaultselected#"
						default_option_text		=	""
						default_option_value	=	"0"
					dropdown_name			=	"Global_UOM"
					option_text_abbreviated	=	""
					plural_uom_display		=	""
					product_type_id			=	""
						program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
						selected_uom_id			=	""
						text_before_tag_close	=	""
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	"#ListOfAvailUOM#"
						>
			<a <cfif EzButton_Disable EQ 0>href="javascript:applyGlobalUOM();"</cfif>>#application.util.string.actionLinkFormat2('apply')#	</a>
		<cfelse>
			&nbsp;
		</cfif>
	</td>
</tr>

	</table>

<cfset ExistingPricingLevelList = "">

	<cfset useLakebaseForgetAllUOMs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForgetAllUOMs>
	<cftry>
		<cfset getAllUOMs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "neq.3"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllUOMs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllUOMs>
<CFQUERY NAME="getAllUOMs" datasource="#application.datasource#">
		SELECT *
		FROM Units_Of_Measure
		where Unit_Of_Measure_ID <> 3
	</CFQUERY>
</cfif>

	<!--- Add products to products collection in the structure --->
	<CFLOOP QUERY="getComponentProducts">
		<!--- create a place holder for the product information --->
		<CFSET LoadProductCount = ListLen(StructKeyList(LoadedGrowthDataStruct.Products))+1>
		<CFSET "LoadedGrowthDataStruct.Products.Product_#LoadProductCount#" = StructNew()>

		<!--- make it easier to access this level structure --->
		<CFSET ThisLevelStruct = evaluate("LoadedGrowthDataStruct.Products.Product_#LoadProductCount#")>
		<!--- Add the contract_product_id to the structure --->
		<CFSET temp = StructInsert(ThisLevelStruct,"Contract_Products_ID", getComponentProducts.Contract_Products_ID)>

		<!--- Add the contract_product_id to the structure --->
		<CFSET temp = StructInsert(ThisLevelStruct,"PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID", getComponentProducts.PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID)>
		<CFSET Current_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = getComponentProducts.PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID>
		<!--- load the product description,upc, and foodservice id --->

		<CFSET temp = StructInsert(ThisLevelStruct,"BSA_Foodservice_Items_Master_ID", getComponentProducts.BSA_Foodservice_Items_Master_ID)>
		<CFSET temp = StructInsert(ThisLevelStruct,"Product_Description", getComponentProducts.Description)>
		<CFSET temp = StructInsert(ThisLevelStruct,"Product_Inventory_UM", getComponentProducts.Inventory_UM)>
		<cfset temp = StructInsert(ThisLevelStruct,"UPC", getComponentProducts.UPC)>
		<cfset temp = StructInsert(ThisLevelStruct,"ITEM", getComponentProducts.ITEM)>
		<cfset temp = StructInsert(ThisLevelStruct,"Group_Number", getComponentProducts.Group_Number)>
<cfif url.EZTemplate EQ 1>
		<cfset temp = StructInsert(ThisLevelStruct,"EZButton_On_Default", getComponentProducts.EZButton_On_Default)>
</cfif>

		<!--- create a Tiers Collection --->
		<cfset ThisLevelStruct.Tier_Rates = StructNew()>

		<!--- loop through the tiers if any --->
		<cfloop QUERY="getComponentTiers">

			<CFSET ThisLevelStruct = evaluate("LoadedGrowthDataStruct.Products.Product_#LoadProductCount#")>
			<cfset TierCount = ListLen(StructKeyList(ThisLevelStruct.Tier_Rates))+1>
			<CFSET "ThisLevelStruct.Tier_Rates.Tier_#TierCount#" = StructNew()>

			<!--- make it easier to access this level structure --->
			<CFSET ThisProductStructTierCollection = ThisLevelStruct.Tier_Rates>
			<CFSET ThisLevelStruct = evaluate("ThisLevelStruct.Tier_Rates.Tier_#TierCount#")>
			<CFSET temp = StructInsert(ThisLevelStruct, "Program_Growth_Component_Tier_ID", getComponentTiers.Program_Growth_Component_Tier_ID)>
			<CFSET temp = StructInsert(ThisLevelStruct, "Tier_Number", getComponentTiers.Tier_Number)>

			<!--- get the product Tier Info if any --->
			<CFQUERY NAME="getProductTierInformation" datasource="#application.datasource#">
				SELECT     	Unit_Of_Measure_ID, Rate
				FROM		Program_Growth_Component_Product_Tier_Data
				WHERE     	(Deleted = 0)
							AND (Program_Growth_Component_Product_Data_ID = '#Current_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID#')
							AND (Program_Growth_Component_Tier_ID = '#ThisLevelStruct.Program_Growth_Component_Tier_ID#')
			</CFQUERY>

			<!--- if there is no tier info dont leave the struct malformed (doesnt have a place holder for the tier information) --->
			<CFIF getProductTierInformation.Recordcount GT 0>
				<!--- load the product tier information into the query --->
				<CFLOOP QUERY="getProductTierInformation">
					<!--- load rate --->
					<CFSET temp = StructInsert(ThisLevelStruct, "Rate", getProductTierInformation.Rate)>
					<!--- load UOM --->
					<CFSET temp = StructInsert(ThisLevelStruct, "Rate_UOM", getProductTierInformation.Unit_Of_Measure_ID)>
				</CFLOOP>
			</CFIF>

			<!--- if thes values do not exist make them --->
			<CFIF NOT structKeyExists(ThisLevelStruct,"Rate")>
				<CFSET temp = StructInsert(ThisLevelStruct, "Rate", "")>
			</CFIF>

			<CFIF NOT structKeyExists(ThisLevelStruct,"Rate_UOM")>
				<CFSET temp = StructInsert(ThisLevelStruct, "Rate_UOM", "")>
			</CFIF>

		</CFLOOP>

		<!---if a product id is in a group level bucket then we know it's a group so set onmouseover menuId--->
		<cfloop index="indx" from="1" to="#form.Num_Levels#">
			<cfparam name="tmp_bucket_#indx#" default="" />
			<cfif ListFindNoCase(Evaluate("form.Level_#indx#"), BSA_Foodservice_Items_Master_ID)>
				<cfset "tmp_bucket_#indx#" = ListAppend(Evaluate("tmp_bucket_#indx#"), "Product_#LoadProductCount#") />
			</cfif>
		</cfloop>
	</cfloop>
<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<cfset Product_Key_List = ListAppend(Product_Key_List, Evaluate("tmp_bucket_#levels#")) />
</cfloop>
<!---77408 Product Group sequencing END--->

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Product Pricing</LEGEND>

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="75%" ALIGN="center">
<tr BGCOLOR="##FFCE84">
	<td>
		<cfif ProductsRemoved IS NOT 2><!---Revision restriction --->
			<img bDelete="true" src="/images/scissor.gif" sMessage="delete all products in this page" title="delete all products in this page" border="0" onClick="deleteAll('RateApplyer_')" style="cursor: pointer;">
		</cfif>
	</td>
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string AND application.returned_customer_setting.upc_switch EQ 1>
	<td><B>#application.returned_customer_setting.upc_label#</B></td>
</cfif>
<cfif application.appSettingsget.get_Setting('Display_Item_No') eq '1'>
	<td width="125px"><B>#application.returned_customer_setting.item_label# / Group ##</B></td>
</cfif>
	<td><B>Description</B></td>
<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
	<td><B>Similar<br />Product</B></td>
</cfif>
<cfif url.EZTemplate EQ 1>
	<td><B>Default</B></td>
</cfif>
<cfif Form.Discount_Growth_Group_Level eq 1 and appSettings.getAllowMultiLevelGroups() and trim(form.Level_1) neq "">
	<td><B>Level</B></td>
</cfif>
	<td><input type="checkbox" name="checkall" ONCLICK="selectAll()" checked></td>
</tr>
<tr>
	<td COLSPAN="100%"><HR SIZE="1" COLOR="Navy"></td>
</tr>
	<cfset globalCounter = 1>
	<cfset rateCounter = 0>
	<cfif Product_Key_List eq "">
		<cfset Product_Key_List = StructKeyList(LoadedGrowthDataStruct.Products) />
			</cfif>

	<cfset currentPricingLevel = "0">
		<cfloop index="LoadedProductData" LIST="#Product_Key_List#">
			<cfset ThisProductData = evaluate("LoadedGrowthDataStruct.Products.#LoadedProductData#")>
			<cfset fieldname = replace(ThisProductData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
			<cfset isInGroupList = 0 />
			<cfparam name="grwthBgColor" default ="whitesmoke" />
				<!---handle bgcolor for growth products that are at different levels--->
				<!---77408 Product Group sequencing START--->
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					<cfif ListFindNoCase(Evaluate("form.Level_#levels#"), ThisProductData.BSA_Foodservice_Items_Master_ID)>
						<cfset currentPricingLevel = levels ><cfbreak>
					<cfelse>
						<cfset currentPricingLevel = 0 >
					</cfif>
				</cfloop>
				<!---77408 Product Group sequencing END--->
				<cfset grwthBgColor = "ccffcc" />
				<!---if a product id is in a group level bucket then we know it's a group so set onmouseover menuId--->
				<cfset current_group_ID = "" />
				<cfset current_group_level_ID = "" />
				<cfloop index="indx" from="1" to="#form.Num_Levels#">
					<cfset group_list = Evaluate("form.Level_#indx#") />
					<cfset group_level = Evaluate("form.GroupLevel_#indx#")  />
					<cfset group_position = ListFindNoCase(group_list, ThisProductData.BSA_Foodservice_Items_Master_ID) />
					<cfif group_position and group_level neq 9>
						<cfset isInGroupList = 1 />
						<cfset current_group_ID = ListGetAt(group_list, group_position) />
						<cfset current_group_level_ID = group_level />
					</cfif>
				</cfloop>
				<cfset CurrentItemUOM	=	ThisProductData.Product_Inventory_UM />
				<cfif isInGroupList>
				  <cfset request.menuId = 11 />
				  <cfset request.theMOId = "#current_group_ID#&Group_Level_ID=#current_group_level_ID#&Program_ID=#FORM.Contract_Main_ID#" />
				  <cfset qProductGroupLevel = GroupDataManager.getProductGroupsData(productGroupId=current_group_level_ID) />
				  <cfif qProductGroupLevel.Product_Group_Level_Type EQ 2>
				  	<cfset qProductHierarchy = GroupDataManager.getHierarchyLevel(prodGroupId = current_group_ID) />
						<cfif qProductHierarchy.Unit_Of_Measure_ID EQ 1>
							<cfset CurrentItemUOM	=	"CS" />
						<cfelseif qProductHierarchy.Unit_Of_Measure_ID EQ 2>
							<cfset CurrentItemUOM	=	"LB" />
						</cfif>
				  </cfif>
				<cfelse>
					<cfset request.menuId = 6 />
					<cfset request.theMOId = ThisProductData.BSA_Foodservice_Items_Master_ID />
				</cfif>

									<cfset thisGroupLevelDesc = GroupDataManager.getProductGroupsData(current_group_level_ID).Group_Level_Desc />
									<cfif len(ThisProductData.Item)>
										 <cfset thisGroupLevelDesc = "Product" />
									</cfif>
										<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to "ExistingPricingLevelList".
										This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
										Note: we set "growthProdMod" back to 1, so that the color coding can restart for a new group.
										thisGroupLevelDesc i.e., "group_level_desc" is shown on a single row.
										--->
										<cfif ListFind(ExistingPricingLevelList,currentPricingLevel) eq 0>
											<cfset growthProdMod = 1 />
											<TR bgcolor="##92B792">
												<TD colspan="100%">#thisGroupLevelDesc#</TD>
											</TR>
											<cfset ExistingPricingLevelList = ListAppend(ExistingPricingLevelList,currentPricingLevel)>
										</cfif>


<TR BGCOLOR="#grwthBgColor#" ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onMouseOut="menuID=0;doNotRelocate=0;" style="cursor: help;"  ID="TR_#FieldName#" height="30">
	<cfset rateCounter = rateCounter + 1>
	<td>
		<cfif ProductsRemoved IS NOT 2 OR  listfind(ProductItemList, ThisProductData.BSA_FOODSERVICE_ITEMS_MASTER_ID) IS 0>
			<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete this product" border="0"  onclick="deleteThisGrowthProd('#Fieldname#', '#ThisProductData.BSA_FOODSERVICE_ITEMS_MASTER_ID#',#rateCounter#,#globalCounter#,'#ThisProductData.Program_Growth_Component_Product_Data_ID#', '#grwthBgColor#', '#currentPricingLevel#',<cfif isDefined("form.GroupLevel_#currentPricingLevel#")>'#Evaluate("form.GroupLevel_#currentPricingLevel#")#'<cfelse>0</cfif>)" style="cursor: pointer;">
		</cfif>
	</td>
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string AND application.returned_customer_setting.upc_switch EQ 1>
	<td STYLE="font-weight:bold;">#ThisProductData.UPC#</td>
</cfif>
<cfif application.appSettingsget.get_Setting('Display_Item_No') eq '1'>
	<td STYLE="font-weight:bold;">
		<cfif len(ThisProductData.Item)>
			#ThisProductData.Item#
		<cfelse>
			#ThisProductData.Group_Number#
		</cfif>
	</td>
</cfif>
	<td STYLE="font-weight:bold;">#ThisProductData.Product_Description#</td>
<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
	<td>
		<input name="Like_Product" type="checkbox" value="#ThisProductData.BSA_Foodservice_Items_Master_ID#" <cfif ListFind(SimilarExistingProductList, ThisProductData.BSA_Foodservice_Items_Master_ID) neq 0 >CHECKED</cfif>>
	</td>
</cfif>
<cfif url.EZTemplate EQ 1>
	<td>
	<input name="Prod_Default_#replace(ThisProductData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")#" type="checkbox" value="1" <cfif ThisProductData.EZButton_On_Default EQ 1>checked</cfif>>
	</td>
</cfif>
<cfif Form.Discount_Growth_Group_Level eq 1 and appSettings.getAllowMultiLevelGroups() and trim(form.Level_1) neq "">
	<td><B>#arPricingLevel[evaluate(currentPricingLevel)]#</B></td>
</cfif>
	<td>
		<span ID="checkAllProducts">
			<input type="Checkbox" name="RateApplyer_#rateCounter#" ONCLICK="if(!this.checked) document.all.checkall.checked = false;" checked>
		</span>
	</td>
				</TR>

				<TR BGCOLOR="whitesmoke">
	<td COLSPAN="100%" ALIGN="center">
	<!--- inner table --->
	<TABLE BORDER="0" width="200" CELLPADDING="5" CELLSPACING="0" ALIGN="center"  ID="TAB_#Fieldname#">
	<tr BGCOLOR="##FFFFCC">
		<td COLSPAN="100%"><B>Product Tier Rates</B><HR SIZE="1" COLOR="Navy"></td>
	</tr>
	<!--- loop through the tiers --->
	<cfset Tier_Len = StructKeyList(ThisProductData.Tier_Rates)>
	<cfset New_Tier_List = "">

	<cfloop index="LoopCount" from="1" to="#ListLen(Tier_Len, ",")#">
		<cfset New_Tier_List = ListAppend(New_Tier_List, "Tier_#LoopCount#", ",")>
	</cfloop>

	<cfloop index="TierDataStruct" LIST="#New_Tier_List#">
		<cfset ThisLevelStruct = evaluate("ThisProductData.Tier_Rates.#TierDataStruct#")>
		<cfset tierfieldname = replace(ThisLevelStruct.PROGRAM_GROWTH_COMPONENT_TIER_ID, "-", "_", "ALL")>
		<cfparam name="FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#" 	default ="#ThisLevelStruct.Rate#">
		<cfparam name="FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM" 	default ="#ThisLevelStruct.Rate_UOM#">
		<cfset thisRate = Evaluate("FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#")>
		<cfset thisUOM = Evaluate("FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM")>

		<cfif EzButton_Disable EQ 1 AND (thisRate EQ 0 or len(trim(thisUOM)) EQ 0)>
			<cfset useLakebaseForgetEZButtonRate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getezbuttondefaultrates")>
<cfif useLakebaseForgetEZButtonRate>
	<cftry>
		<cfset getEZButtonRate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getezbuttondefaultrates", {
				"bsa_foodservice_items_master_id" = "eq.#ThisProductData.BSA_Foodservice_Items_Master_ID#",
				"tier_number" = "eq.#ThisLevelStruct.Tier_Number#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetEZButtonRate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetEZButtonRate>
<cfquery name="getEZButtonRate" dbtype="query">
				select *
				from GetEZButtonDefaultRates
				where BSA_Foodservice_Items_Master_ID = '#ThisProductData.BSA_Foodservice_Items_Master_ID#'
				and tier_number = '#ThisLevelStruct.Tier_Number#'
			</cfquery>
</cfif>
			<cfset thisRate = getEZButtonRate.growth_rate>
			<cfset thisUOM = getEZButtonRate.Unit_Of_Measure_ID>
		</cfif>

		<cfif len(trim(thisUOM)) EQ 0>
			<cfset thisUOM = 0>
			<cfset defaultselected = 1>
		<cfelse>
			<cfset defaultselected = 0>
		</cfif>
		<cfset globalCounter = globalCounter + 1>
	<tr BGCOLOR="##FFFFCC" height="35">
		<td NOWRAP STYLE="font-weight:bold;" width="50">Tier #ThisLevelStruct.Tier_Number#</td>
		<td width="100">
			<!--- 76380 decimal places START--->
			<cfset decimalprecision = programManager.decimalPrecisionByUOM(thisUOM,1)>
			<cfset decimalformatValidation = programManager.decimalPrecisionByUOM(thisUOM,2)>
			<!--- 76380 decimal places END--->
			<span ID="error_#globalCounter#"></span><span ID="dataToErrorCheck" errorSpanname="error_#globalCounter#" errorMessage="Enter A Tier Rate">
											<input TYPE="Text" SIZE="6" NAME="Tier_#tierfieldname#_Product_Rate_#fieldname#" VALUE="#NumberFormat(thisRate, decimalprecision)#" ONKEYUP="clenseText(this, '.0123456789');" Tier_Number="#ThisLevelStruct.Tier_Number#" assignRateIndicator="RateApplyer_#rateCounter#" onChange="this.value = formatToDecimalPlaces(this.value,#decimalformatValidation#);resetnavigate();" <cfif ProductsRatesChanges IS 2 OR EzButton_Disable EQ 1><cfif (listfind(ProductItemList, ThisProductData.BSA_FOODSERVICE_ITEMS_MASTER_ID) IS NOT 0) OR EzButton_Disable EQ 1 >disabled</cfif></cfif>>
	<cfif EzButton_Disable EQ 1>
	<input type="hidden" name="Tier_#tierfieldname#_Product_Rate_#fieldname#" VALUE="#NumberFormat(thisRate, "_.____")#">
	</cfif>
										</SPAN>
									</TD>
									<TD width="50">
									<!---revision restrictions --->
									<cfif (ProductsUOMChanges EQ 2 AND listfind(ProductItemList, ThisProductData.BSA_FOODSERVICE_ITEMS_MASTER_ID) NEQ 0) OR EzButton_Disable EQ 1>
		<input type="hidden" name="Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM" value="#thisUOM#">

										<Cfif thisUOM IS 1>
										per&nbsp;Case
										<cfelseif thisUOM IS 2>
										per&nbsp;Pound
										<cfelseif thisUOM IS 3>
										Percent
										<cfelseif thisUOM IS 4>
										Dollar
										</CFIF>
		<cfelse>
										<cfif GrowthTierPercentUOM.Program_Growth_Comparison_Period_UOM_ID eq 2><cfset ListOfAvailUOM="3"></cfif>
										<span id="UOMCollection">
											<cf_uom_dropdown
												program_id				=	""
												company_main_id			=	""
												default_option_on		=	"0"
												setDefaultSelected 		=	"#defaultselected#"
												default_option_text		=	""
												default_option_value	=	"0"
												dropdown_name			=	"Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM"
												option_text_abbreviated	=	""
												plural_uom_display		=	""
												product_type_id			=	"4"
						program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
						selected_uom_id			=	"#thisUOM#"
						text_before_tag_close	=	"onchange=resetnavigate();"
						uom_id_exclusion_list	=	""
						uom_id_inclusion_list	=	""
						productUom				=	"#CurrentItemUOM#"
						isGroup					=	"#isInGroupList#">
				</span>
		</cfif>
		</td>
	</tr>
</cfloop>
	</TABLE>
	</td>
</tr>
<cfset globalCounter = globalCounter + 1>
</cfloop>
</TABLE>
</FIELDSET>

<table>
<tr>
	<td nowrap><a href="javascript: verifyData();">#application.util.string.actionLinkFormat2('save')#</a></td>
		<!---Revision restrictions --->
		<cfif ProductsAdded IS NOT 2>
		<!----add groups links if it's on--->
		<cfif form.Discount_Growth_Group_Level>
			<cfset addGroupLabel = "add groups" />
			<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel() AND appSettings.get_Setting('Product_Group_Sequencing') neq '1'>
				<cfset addGroupLabel = "add #LCase(arPricingLevel[1])# groups" />
			</cfif>
			<td nowrap><a href="javascript: showGroupSearchWindow();">#application.util.string.actionLinkFormat2(addGroupLabel)#</a></td>
		</cfif>
		<cfif bAllowSelectProducts>
			<cfset addProductLabel = "add products" />
			<cfset addProductAtLevel = 0 /> <!------ Default, determine by itself ----->
			<cfset provideLevel3Link = 0 />

			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					<cfif Evaluate("form.GroupLevel_#levels#") EQ 9>
						<cfset nextLevel = levels><cfbreak>
					<cfelseif Evaluate("Form.GroupLevel_#levels#") NEQ ''>
						<cfset nextLevel = levels + 1>
					<cfelse>
						<cfset nextLevel = 1>
					</cfif>
				</cfloop>
				<cfif nextLevel LTE request.AccessStructure.numberOfProductGroupLevels>
					<cfset addProductLabel = "add products" />
					<cfset addProductAtLevel = nextLevel />
					<cfset provideLevel3Link = 1 />
				</cfif>
			<cfelseif restrictLowerLevelBasedonLevel1>
					<cfif getAllLevels.Pricing_Level_ID LTE 1>
						<cfset addProductLabel = "add #LCase(arPricingLevel[2])# products" />
						<cfset addProductAtLevel = 2 /> <!------ At level 2 ----->
						<cfset provideLevel3Link = 1 />
					<cfelse>
						<cfset addProductLabel = "add #LCase(arPricingLevel[3])# products" />
						<cfset addProductAtLevel = 3 /> <!------ At level 3 ----->
						<cfset provideLevel3Link = 0 />
					</cfif>
				</cfif>
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				<td width="220" nowrap>
					<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
				</td>
			<cfelse>
				<td width="110" nowrap>
					<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
						<a href="javascript: showProductSearchWindow(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
					<cfelse>
						<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
					</cfif>
				</td>
				<cfif provideLevel3Link>
					<cfset addProductLabel = "add #LCase(arPricingLevel[3])# products" />
					<cfset addProductAtLevel = 3 /> <!------ At level 3 ----->
					<td width="110" nowrap>
						<cfif appSettings.getFlexProductSearch() and GetSettings.Group_Deal neq 1>
							<a href="javascript: showProductSearchWindow(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
						<cfelse>
							<a href="javascript: showProductSearchWindow_old(#addProductAtLevel#);">#application.util.string.actionLinkFormat2(addProductLabel)#</a>
					</cfif>
					</td>
				</cfif>
			</cfif>
			</cfif>
			<cfif bAllowSelectAllProducts>
				<td nowrap><a href="javascript: addGroupsLevelProducts(1, \'0\');">#application.util.string.actionLinkFormat2('add all products')#</a>	</td>
			</cfif>
			<!---Revision restrictions --->
			</cfif>
		</tr>
	</table>
</cfif>

<cfparam name="Form.groupLevelProducts" 	default ="0">
<cfparam name="Form.Product_Level_1" 	default ="">

<input type="hidden" name="Product_Level_1" value="#Form.Product_Level_1#">
<input type="hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />

<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(getComponentProducts.BSA_Foodservice_Items_Master_ID)#">
<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#trim(FORM.Product_List)#">
<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
<!---Can now add one item to multiple components. Brenda Flynn, 1/18/05, Heinz request.--->
<!--- <INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="#valuelist(getProductsFromOtherComponents.BSA_Foodservice_Items_Master_ID)#">	 --->

<!--- BJF D11147 -- if component product restrictions in place, populate list of items not to be selected --->

	<Cfif appsettings.getComponent_Product_Restrictions_On() IS 1>

	<cfset useLakebaseForComponentForbiddenProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_products_restricted")>
<cfif useLakebaseForComponentForbiddenProducts>
	<cftry>
		<cfset ComponentForbiddenProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("component_products_restricted", {
				"discount_type_id" = "eq.4 --Growth",
				"component_id" = "eq.#url.Growth_Component_Name_ID#",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForComponentForbiddenProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForComponentForbiddenProducts>
<cfquery name="ComponentForbiddenProducts" datasource="#application.datasource#">
		SELECT Product_ID
		FROM Component_Products_Restricted
		WHERE Discount_Type_ID = 4 --Growth
		AND Component_ID = '#url.Growth_Component_Name_ID#'
	</cfquery>
</cfif>

	<cfset ProductForbiddenList = valuelist(ComponentForbiddenProducts.Product_ID)>
	<input type="hidden" name="ProductListToExcludeFromSelecting" value="#ProductForbiddenList#">
	<cfelse>
	<INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="">
	</CFIF>

<input type="hidden" name="navigate" value="#FORM.navigate#">
<input type="hidden" name="stopnavigate" value="0">
<!---Modification: Group Deals--->
<input type="hidden" name="Discount_Growth_Item_Level" value="#Form.Discount_Growth_Item_Level#" />
<input type="hidden" name="Discount_Growth_Group_Level" value="#Form.Discount_Growth_Group_Level#" />
<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
<!---clean up the group levels--->
<cfif trim(Evaluate("form.Level_#levels#")) eq "">
	<cfset "form.GroupLevel_#levels#" = "" />
</cfif>
	<input type="hidden" name="Level_#levels#" value="#Evaluate("Form.Level_#levels#")#" />
	<input type="hidden" name="GroupLevel_#levels#" value="#Evaluate("Form.GroupLevel_#levels#")#" />
</cfloop>
<!---77408 Product Group sequencing END--->
<input type="hidden" name="Allow_Multi_Levels" value="#form.Allow_Multi_Levels#" />
<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
<input type="hidden" name="TierCount" value="#tiercount#">
<input type="hidden" name="ProductCount" value="#LoadProductCount#">
<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#">
<input type="hidden" name="Product_Search_Window_Return_Type" value="0" />
<cfif restrictLowerLevelBasedonLevel1>
	<input type="hidden" name="AllowProductGroupList" value="#Form.Level_1#" />
	<input type="hidden" name="AllowProductGroupLevelId" value="#Form.GroupLevel_1#" />
<cfelse>
	<input type="hidden" name="AllowProductGroupList" value="" />
	<input type="hidden" name="AllowProductGroupLevelId" value="" />
</cfif>
<input type="hidden" name="Is_Like_Product_Exist" value="#CSLGetContractInfo.Like_Product_Exist#">
<input type="hidden" name="EZTemplate" value="#url.EZTemplate#">
</FORM>
<cfif url.EZTemplate EQ 0>
</BLOCKQUOTE></BLOCKQUOTE>
</cfif>
<FORM ACTION="Contract_Discount_Growth_Add_Component_Products.cfm?CID=#URL.CID#&EZTemplate=#url.EZTemplate#&Growth_Component_name_ID=#url.Growth_Component_name_ID#" METHOD="post" name="compProducts" ID="compProducts">
<!------<FORM ACTION="Contract_Discount_Growth_Add_Component_Products_Action.cfm" METHOD="post" name="compProducts" ID="compProducts">----->
	<input type="hidden" name="ExistingProductList" value="#valuelist(getComponentProducts.BSA_Foodservice_Items_Master_ID)#">
	<input type="hidden" name="Program_ID" 			value="#URL.CID#">
	<input type="hidden" name="Component_ID" 		value="#URL.COMPID#">
	<input type="hidden" name="Product_List" 		value="#FORM.Product_List#">
	<input type="hidden" name="DTPS_On" 			value="1">
	<input type="hidden" name="DTPS_Program_ID" 	value="#FORM.Contract_Main_ID#">
	<input type="hidden" name="ChildID" 				value="#ChildID#">
	<!---Can now add one item to multiple components. Brenda Flynn, 1/18/05, Heinz request.--->
<!--- 	<input type="hidden" name="ProductListToExcludeFromSelecting" 	value="#valuelist(getProductsFromOtherComponents.BSA_Foodservice_Items_Master_ID)#">	 --->
	<input type="hidden" name="ProductListToExcludeFromSelecting" 	value="">
	<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
</FORM>

</CFOUTPUT>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_MessageWindow>

<!---Min/max verification--->
<cfparam name="Min_Growth_Case" default="">
<cfparam name="Max_Growth_Case" default="">
<cfparam name="Min_Growth_Pound" default="">
<cfparam name="Max_Growth_Pound" default="">
<cfparam name="Min_Growth_Percent" default="">
<cfparam name="Max_Growth_Percent" default="">
<cfparam name="ThereisMinorMax" default="0">

<!---Sets min and max values if they exist for the profile--->
<cfif len(trim(getSettings.Min_Growth_Case)) IS NOT 0>
	<cfset Min_Growth_Case = getSettings.Min_Growth_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Growth_Case)) IS NOT 0>
	<cfset Max_Growth_Case = getSettings.Max_Growth_Case>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_Growth_Pound)) IS NOT 0>
	<cfset Min_Growth_Pound = getSettings.Min_Growth_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Growth_Pound)) IS NOT 0>
	<cfset Max_Growth_Pound = getSettings.Max_Growth_Pound>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Min_Growth_Percent)) IS NOT 0>
	<cfset Min_Growth_Percent = getSettings.Min_Growth_Percent>
	<cfset ThereisMinorMax = 1>
</cfif>
<cfif len(trim(getSettings.Max_Growth_Percent)) IS NOT 0>
	<cfset Max_Growth_Percent = getSettings.Max_Growth_Percent>
	<cfset ThereisMinorMax = 1>
</cfif>

<script>
	var TotalWeeklyVolume = 0;
	function verifyData(){
		ErrorCount = 0
		TotalWeeklyVolume  = 0;

		if (!validateGroupsDefaultCheckBoxes())
		return;

		if(document.all.dataToErrorCheck != null)	{
			if(dataToErrorCheck.length){
				for(var x =0; x<dataToErrorCheck.length;x++)	{
					validateCurrentField(dataToErrorCheck[x], getFirstChild(dataToErrorCheck[x]));
				}
			}	else{
				validateCurrentField(dataToErrorCheck,getFirstChild(dataToErrorCheck));
			}
		}

		if(ErrorCount == 0){
			<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{document.all.deletedateexclusions.value = 1;</cfif>
			document.compProductTierRates.action = "Contract_Discount_Growth_Save_Product_Tier_Info_Action.cfm?EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>";
			document.all.navigate.value = 0;
			disableButton("save_table", true, false);
			document.compProductTierRates.submit();
		<cfif donotallowaddproductsDE EQ 1>
			}
	</cfif>
		}	else{
			showMessageWindow();
			document.all.navigate.value = 1;
		}
	}
	function validateCurrentField(objectToErrorCheckSpan, objectToErrorCheck)	{
		var UOM = eval("document.all." + objectToErrorCheck.name + "_UOM");
		var tempPriceObjectSpan = eval("document.all." + objectToErrorCheckSpan.errorSpanname);

		if(trim(objectToErrorCheck.value).length==0)	{
			ErrorCount++
			queueMessage(objectToErrorCheckSpan.errorMessage, eval("document.all." + objectToErrorCheckSpan.errorSpanname))
		}
		<cfif ThereisMinorMax IS 1>
		else if((UOM.value == 2) && (objectToErrorCheck.value != ""))	{
			<cfif len(trim(Min_Growth_Pound)) IS NOT 0>
				<!---Pounds Min--->
				if(objectToErrorCheck.value < <cfoutput>#Min_Growth_Pound#</cfoutput>){
					ErrorCount++
					queueMessage("The allowance must be greater than <cfoutput>#Min_Growth_Pound#</cfoutput>", tempPriceObjectSpan)
				}
			</cfif>

			<cfif len(trim(Max_Growth_Pound)) IS NOT 0 AND Max_Growth_Pound IS NOT 0>
				<!---Pounds Max--->
				if(objectToErrorCheck.value > <cfoutput>#Max_Growth_Pound#</cfoutput>){
					ErrorCount++
					queueMessage("The price must be less than <cfoutput>#Max_Growth_Pound#</cfoutput>", tempPriceObjectSpan)
				}
			</cfif>

		} <!---Cases--->
		else if((UOM.value == 1) && (objectToErrorCheck.value != ""))	{
			<cfif len(trim(Min_Growth_Case)) IS NOT 0>
				<!---Pounds Min--->
				if(objectToErrorCheck.value < <cfoutput>#Min_Growth_Case#</cfoutput>)	{
					ErrorCount++
					queueMessage("The price must be greater than <cfoutput>#Min_Growth_Case#</cfoutput>", tempPriceObjectSpan)
				}
			</cfif>

			<cfif len(trim(Max_Growth_Case)) IS NOT 0 AND Max_Growth_Case IS NOT 0>
				<!---Pounds Max--->
				if(objectToErrorCheck.value > <cfoutput>#Max_Growth_Case#</cfoutput>){
					ErrorCount++
					queueMessage("The price must be less than <cfoutput>#Max_Growth_Case#</cfoutput>", tempPriceObjectSpan)
				}
			</cfif>
		}

		 <!---Percent--->
		else if((UOM.value == 3) && (objectToErrorCheck.value != ""))	{
			<cfif len(trim(Min_Growth_Percent)) IS NOT 0>
				<!---Pounds Min--->
				if(objectToErrorCheck.value < <cfoutput>#Min_Growth_Percent#</cfoutput>){
					ErrorCount++
					queueMessage("The price must be greater than <cfoutput>#Min_Growth_Percent#</cfoutput>", tempPriceObjectSpan)
				}
			</cfif>

		<cfif len(trim(Max_Growth_Percent)) IS NOT 0 AND Max_Growth_Percent IS NOT 0>
				<!---Pounds Max--->
				if(objectToErrorCheck.value > <cfoutput>#Max_Growth_Percent#</cfoutput>)	{
					ErrorCount++
					queueMessage("The price must be less than <cfoutput>#Max_Growth_Percent#</cfoutput>", tempPriceObjectSpan)
				}
			</cfif>
		}
		</cfif>

		else{
			clearQueue(eval("document.all." + objectToErrorCheckSpan.errorSpanname))
		}
	}
	findselectboxes()
	function resetnavigate(){
		document.all.navigate.value = 1;
	}
	function verifyNavigate() {
		if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				event.returnvalue='Product selections you have not saved will be lost.'
		}
	}
function  validateGroupsDefaultCheckBoxes(){
	var thisForm = document.all;
	<!---77408 Product Group sequencing START--->
	<cfoutput>
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
			var Arr#levels# = level#levels#.split(',');
						arrLen = Arr1.length;

			if (trim(level#levels#) != ""){
				for(i=0; i<arrLen; i++){
					if (eval("document.all.Prod_Default_"+replaceChar(Arr1[i],'-','_')+".checked")){
						level#levels#_checked = true;
					}
				}
			}
			</cfoutput>
	</cfloop>

	//validate group levels
		if ( ! level1_checked && level2_checked && level3_checked && level4_checked && level5_checked && level6_checked && level7_checked && level8_checked){
			alert("Level 1 default should be checked if Groups or Products in below levels default settings are checked.");
			bIsValid = false;
			return bIsValid;
	}

	if ( ! level2_checked && && level3_checked && level4_checked && level5_checked && level6_checked && level7_checked && level8_checked){
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
	</cfif>
	<!---77408 Product Group sequencing END--->
	return bIsValid;
}
</script>

<!--- delete product section --->
<cfinclude template="delete_product_include.cfm">
<!--- delete product section --->


</BODY>
</HTML>
