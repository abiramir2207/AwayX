<cfif isDefined("url.Program_ID")>
	<cfset Form.Program_ID = url.Program_ID>
</cfif>
<CFSET PAGE_TITLE= "Select Growth Products">
<CFPARAM name="form.navigate" default="0">
<CFPARAM name="form.stopnavigate" default="0">
<CFPARAM name="defaultselected" default="1">
<CFPARAM NAME="Form.Discount_Growth_Item_Level" DEFAULT="0">
<CFPARAM NAME="Form.Discount_Growth_Group_Level" DEFAULT="0">
<CFPARAM NAME="form.Level_1" DEFAULT="">
<CFPARAM NAME="form.Level_2" DEFAULT="">
<CFPARAM NAME="form.Level_3" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_1" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_2" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_3" DEFAULT="">
<CFPARAM name="form.Allow_Multi_Levels" default="0">
<CFPARAM NAME="form.Dynamic_Static_Groups" DEFAULT="0">
<CFPARAM NAME="form.Num_Levels" DEFAULT="3">
<cfparam name="Product_Key_List" default="" />
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<!---initialize app settings object--->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() /> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<!---set whether to allow multi level groups--->
<cfif appSettings.getAllowMultiLevelGroups()>
	<cfset form.Allow_Multi_Levels = 1 />
</cfif>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT>
	
		
		function addGroupsLevelProducts(groupLevel, groupId)
		{
			if(window.confirm('Do you want to add all the products?')) 
			{
				if(groupLevel != 0)
				{
					var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
					groupIdListObj.value = groupId;
					document.compProductTierRates.submit();
				}
			}
		}

		
		function showProductSearchWindow() 
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
				var grpLevl1 = document.all.GroupLevel_1.value;
				var grpLevl2 = document.all.GroupLevel_2.value;
				var grpLevl3 = document.all.GroupLevel_3.value;
			
				//if we have product groups at all levels then don't allow adding products
				if((grpLevl1 != "" && grpLevl1 != 9) && (grpLevl2 != "" && grpLevl2 != 9) && (grpLevl3 != "" && grpLevl3 != 9))
				{
					alert("Products cannot be added when Groups exist in all levels.");
					return;
				}
				
				NewWindow("product_Select_V1.cfm?Formname=compProductTierRates", "productwindow", 800, 600, "yes", "yes")
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
		<!----
/*
		function applyGlobalVolume(volumeAmount){
			if(document.all.checkAllProducts != null){
				if(document.all.checkAllProducts.length == null){
					document.all.VolumeCollection.value = volumeAmount;
				}
				else{
					for(var x=0; x<document.all.checkAllProducts.length; x++){
						cB=document.all.checkAllProducts[x].firstChild.checked
						if(cB == true) {
							document.all.VolumeCollection[x].value = volumeAmount;
						}
					}
				}
			}
		}
		*/
---->
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
	
	//function to set all products checkboxes of same type_code to checked
		function checkMatchingProd(type_code,header)
		{
			var elemColctn2 = document.compProductTierRates.getElementsByTagName("input");
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
		
		function CA() {
			document.all.allbox.checked = event.srcElement.checked;
			
			if(0==0) {
				for (var i=0;i<compProductTierRates.elements.length;i++)
					{
						var e = compProductTierRates.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = compProductTierRates.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
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
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---
<CFSET Help_URL="/help_files/manual/createprogram/page12.cfm">
--->
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
<cfif application.programlayout EQ 1>
<!--- 	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px;display:none;">
  	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"> --->
</cfif>
<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset programagreed = programManager.isProgramAgreed(CSL_Contract_Main_ID)>
<CFINCLUDE TEMPLATE="commonqueries.cfm">

<cfif programagreed GT 0 and CSLGetContractInfo.modifying_program EQ 0 and CSLGetContractInfo.Contract_Status_Type_IDX EQ 2>
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
</cfif>

<cfset ListOfAvailUOM = "">
<cfif GetSettings.RateTypeOption_1 EQ 1>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 2)>
</cfif>
<cfif GetSettings.RateTypeOption_2 EQ 1>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 1)>
</cfif>
<cfif GetSettings.RateTypeOption_3 EQ 1>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 3)>
</cfif>
<cfif listlen(ListOfAvailUOM) EQ 0>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 0)>
</cfif>

<cfset ListOfAvailUOMFF = "">
<cfif GetSettings.RateTypeOption_1 EQ 1>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 2)>
</cfif>
<cfif GetSettings.RateTypeOption_2 EQ 1>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 1)>
</cfif>
<cfif listlen(ListOfAvailUOM) EQ 0>
	<CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 0)>
</cfif>

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

<BLOCKQUOTE><BLOCKQUOTE>



<script>

	function showGroupSearchWindow() 
	{
	
		//do validation first
		var prodList = document.compProductTierRates.Product_List.value;
		var grpLevel1 = document.compProductTierRates.GroupLevel_1.value;
		var lExclude = document.compProductTierRates.ProductListToExcludeFromSelecting.value;
		
		//if we have a product list but nothing in level 1 then we can't allow adding groups
		if(prodList != "" && grpLevel1 == "")
		{
			alert("Groups cannot be added when products exist in level 1.");
			return;
		}
		
		NewWindow("Groups/index.cfm?formName=compProductTierRates&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&lExcludeFormField=ProductListToExcludeFromSelecting", "productwindow", 800, 600, "yes", "yes");
	}
		
</script>

<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:absolute; height:430px; width:200px; z-index:1; left: 10px; top: 10px;">
<!--- 	<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 65px; top: 0px;"> --->
</cfif>

<cfinclude template="minimal_contract_info.cfm">
<CFPARAM NAME="FORM.Component_ID" 	DEFAULT="">
<CFPARAM NAME="URL.COMPID" 	DEFAULT="#FORM.Component_ID#">
<cfparam name="Component_ID" default="#URL.COMPID#">

<CFQUERY NAME="getComponentTierInfo" datasource="#application.datasource#">
	SELECT	Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID, 
			Program_Growth_Component_Tiers.Program_Growth_Component_ID,
			Program_Growth_Component_Tiers.Program_ID, 
			Program_Growth_Component_Tiers.Tier_Number,
			Program_Growth_Components.Tier_Count, 
			Program_Growth_Components.Component_Name, 
			Program_Growth_Components.Program_Growth_Component_Type_ID,
			Program_Growth_Components.Rate_Type
	FROM	Program_Growth_Component_Tiers INNER JOIN Program_Growth_Components ON 
			Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
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
			<cflocation url="Contract_Discount_Growth_Add_Component_margin.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#URL.COMPID#&CID=#URL.CID#&Action=Edit&Component_Type=#GetComponentType.Program_Growth_Component_Type_ID#">	
		<!---If it's Stairway or XofY, go to Contract_Discount_Add_Target.cfm--->
		<cfelse>
			<cflocation url="Contract_Discount_Growth_Add_Target.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#URL.COMPID#&CID=#URL.CID#&Component_Type=#GetComponentType.Program_Growth_Component_Type_ID#">"
		</cfif>
	
	<cfelse>
	
		<cflocation url="Contract_Discount_Growth_Add_Component.cfm?Program_ID=#FORM.Contract_Main_ID#&Component_ID=#URL.COMPID#&CID=#URL.CID#&Action=Edit">
		
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
		
		<cfquery name="UpdateComponentTierInfo" datasource="#application.datasource#">
		
			UPDATE 	Program_Growth_Components
			SET 	Tier_Count = #PreviousTiers.Recordcount#
			WHERE 	Program_Growth_Components.Program_Growth_Component_ID = '#Component_ID#'
		
		</cfquery>
		
	</cfif>

</cfif>

<!---Include navigation--->
<cfif appSettings.getGrowthExpansion1()>
	<cfinclude template="/common_files/contracts/contract_discount_growth_navigation_margin.cfm">
</cfif>

<cfset useLakebaseForGetContractUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGetContractUOM>
	<cftry>
		<cfset getContractUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", { "unit_of_measure_id" = "eq.#GetContractInfo.Contract_Quantity_UOM_IDX#" })
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
		WHERE 	Unit_Of_Measure_ID = '#GetContractInfo.Contract_Quantity_UOM_IDX#'
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
	
		SELECT	Contract_Products.BSA_Foodservice_Items_Master_ID,
				Contract_Products.Product_Group_Level_ID, 
				Contract_Products.Product_Group_ID,
				Contract_Products.Is_Group,
				Contract_Products.Pricing_Level_ID, 
				Type_Code_Desc.Type_Code_Desc AS DisplayGroupName
		FROM	Contract_Products 
				INNER JOIN	Program_Growth_Component_Product_Data ON 
				Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
				AND Program_Growth_Component_Product_Data.Deleted = 0
				AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#LoadedComponentID#'
				LEFT OUTER JOIN BSA_Foodservice_Items_Master
				ON contract_products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				LEFT OUTER JOIN dbo.Type_Code_Desc 
				ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID 
		WHERE	Contract_Products.Deleted = 0
		AND 	Contract_Products.Contract_Main_ID = #FORM.Contract_Main_ID#
		AND		Contract_Products.Discounted_Item = 1
		<!---filter on groups if they exist--->
		AND 
				(
					<!------ Group ----->
					(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
					OR
					<!------ Product ----->
					(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
				) 
		order by Type_Code_Desc.type_code_desc ASC
		
	</CFQUERY>

	<!---handle for multi level groups--->
	<cfquery name="qGetGroups" dbtype="query">
	
		SELECT 	BSA_Foodservice_Items_Master_ID,
				Product_Group_Level_ID,
				Pricing_Level_ID
		FROM	Get_Growth_Comp_Products
		WHERE	Is_Group = 1
		
	</cfquery>
	
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
		<cfquery name="qGetProducts" dbtype="query">
	
			SELECT 	BSA_Foodservice_Items_Master_ID,
					Product_Group_Level_ID,
					Pricing_Level_ID
			FROM	Get_Growth_Comp_Products
			WHERE	Is_Group = 0
		
		</cfquery>
		
		<cfif qGetProducts.RecordCount>
		
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
	
	<cfquery name="qGetLevel_1_Products" dbtype="query">
		SELECT	Product_Group_ID
		FROM	Get_Growth_Comp_Products
		WHERE	Product_Group_Level_ID = 1
	</cfquery>
	
	<cfset FORM.Product_Level_1 = ValueList(qGetLevel_1_Products.Product_Group_ID) />
	
</CFIF>

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
             
<!--- get the component products --->
<!--- changed 4-30-2005...mws...added everything from UNION statement and below to account for same product being added to multiple components --->
<CFQUERY NAME="getComponentProducts" datasource="#application.datasource#">
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
	Type_Code_Desc.Type_Code_Desc
FROM	BSA_Foodservice_Items_Master FIM
		INNER JOIN 
		Program_Growth_Components PGC
		ON PGC.Program_Growth_Component_ID = '#LoadedComponentID#'
		AND PGC.IsParent = 1
		AND PGC.Deleted = 0
		<cfif FORM.groupLevelProducts EQ 1>
				LEFT JOIN Business_Segment
				ON
				Business_Segment.Deleted = 0
				AND
				Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
		</cfif>
		INNER JOIN 
		Contract_Products CP 
		ON CP.BSA_Foodservice_Items_Master_ID = FIM.BSA_Foodservice_Items_Master_ID
		AND CP.Deleted = 0
		AND CP.Discounted_Item = 1
		AND CP.Product_Type_ID = 4
		AND CP.Contract_Main_ID = #FORM.Contract_Main_ID#
		AND 
		((CP.Product_Group_ID = CAST(CP.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND CP.Is_Group = 1)
		   OR
		(ISNULL(CP.Product_Group_ID, '') = '' AND CP.Is_Group = 0)) 
		INNER JOIN	
		Program_Growth_Component_Product_Data PGCPD 
		ON CP.Contract_Products_ID = PGCPD.Contract_Products_ID	
		AND PGCPD.Deleted = 0
		AND PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
		LEFT OUTER JOIN BSA_Foodservice_Items_Master
		ON cp.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		LEFT OUTER JOIN Type_Code_Desc 
		ON .BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID   
	WHERE     
		<CFIF FORM.Product_List EQ "">
			1=2
		<CFELSE>
			FIM.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)
		</CFIF>
			

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
			Type_Code_Desc.Type_Code_Desc
	FROM       	BSA_Foodservice_Items_Master FIM
				INNER JOIN 
				Program_Growth_Components PGC
				ON PGC.Program_Growth_Component_ID = '#LoadedComponentID#'
				AND PGC.IsParent = 1
				AND PGC.Deleted = 0
				<cfif FORM.groupLevelProducts EQ 1>
					LEFT JOIN Business_Segment
					ON
					Business_Segment.Deleted = 0
					AND
					Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
		       </cfif>
				LEFT JOIN 
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
				LEFT JOIN	
				Program_Growth_Component_Product_Data PGCPD ON 
				CP.Contract_Products_ID = PGCPD.Contract_Products_ID	
				AND PGCPD.Deleted = 0
				AND PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
				LEFT OUTER JOIN BSA_Foodservice_Items_Master
				ON cp.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				LEFT OUTER JOIN Type_Code_Desc 
				ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID  
	WHERE     
		<CFIF FORM.Product_List EQ "">
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
					ON
					Business_Segment.Deleted = 0
					AND
					Business_Segment.Business_Segment_ID = #FORM.Product_Level_1#
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
				INNER JOIN	
				Program_Growth_Component_Product_Data PGCPD ON 
				CP.Contract_Products_ID = PGCPD.Contract_Products_ID	
				AND PGCPD.Deleted = 0
				AND PGCPD.Program_Growth_Component_ID = PGC.Program_Growth_Component_ID
	WHERE     
				
		<CFIF FORM.Product_List EQ "">
			1=2
		<CFELSE>
			FIM.BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.Product_List, "'", ",")#)
		</CFIF>))
	ORDER BY Type_Code_Desc.Type_Code_Desc ASC
</CFQUERY>			



<!---handle for multi level groups--->
<!---determine what level to put products in--->
<cfif trim(form.GroupLevel_2) neq "" and trim(form.GroupLevel_2) neq 9>

	<cfquery name="qGetProdsForLevel3" dbtype="query">
	
		SELECT	BSA_Foodservice_Items_Master_ID
		FROM	getComponentProducts
		WHERE	BSA_Foodservice_Items_Master_ID NOT IN
					(#ListQualify(FORM.Level_1, "'")#)
		AND		BSA_Foodservice_Items_Master_ID NOT IN
					(#ListQualify(FORM.Level_2, "'")#)	
	</cfquery>
	
	<cfif qGetProdsForLevel3.RecordCount>
		<cfset form.Level_3 = ValueList(qGetProdsForLevel3.BSA_Foodservice_Items_Master_ID) />
		<cfif trim(form.GroupLevel_3) eq "">
			<cfset form.GroupLevel_3 = 9 />
		</cfif>
	</cfif>
	
<cfelseif trim(form.GroupLevel_1) neq "" and trim(form.GroupLevel_1) neq 9>
	
	<cfquery name="qGetProdsForLevel2" dbtype="query">
	
		SELECT	BSA_Foodservice_Items_Master_ID
		FROM	getComponentProducts
		WHERE	BSA_Foodservice_Items_Master_ID NOT IN
					(#ListQualify(FORM.Level_1, "'")#)	
	</cfquery>
	
	<cfif qGetProdsForLevel2.RecordCount>
		<cfset form.Level_2 = ValueList(qGetProdsForLevel2.BSA_Foodservice_Items_Master_ID) />
		<cfif trim(form.GroupLevel_2) eq "">
			<cfset form.GroupLevel_2 = 9 />
		</cfif>
	</cfif>
	
</cfif>

<CFSET FORM.Product_List = ValueList(getComponentProducts.BSA_Foodservice_Items_Master_ID, ",")>

<!--- get this components tiers --->
<CFQUERY NAME="getComponentTiers" datasource="#application.datasource#">
	SELECT	Program_Growth_Component_Tier_ID,
			Tier_Number
	FROM	Program_Growth_Component_Tiers
	WHERE	(Program_Growth_Component_ID = '#LoadedComponentID#') 
	AND 	(Deleted = 0)
	ORDER BY CAST(Tier_Number AS FLOAT)
</CFQUERY>


<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
	SELECT	*
	FROM	Contract_Main 
			INNER JOIN Units_of_Measure ON 
			Contract_Main.Contract_Quantity_UOM_IDX = Units_of_Measure.Unit_Of_Measure_ID
	WHERE 	Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>
<!------<CFSET Weekly_Volume = GetAllContractInfo.Contract_Daily_Volume * 7>----->

<CFOUTPUT>
<SPAN CLASS="TITLE2"> Growth Component :#getComponentTierInfo.Component_Name#</SPAN>
</CFOUTPUT>
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

<cfif getComponentProducts.Recordcount LT 1>

	<table>
	
		<cfif NOT bAllowSelectProducts>
		
			<tr>
				<td colspan="100%" style="color:red">
					<BR><BR>
					<strong>
					You cannot select products if you already have a component with 'All Products'
					</strong>
				</td>
			</tr>
			
		<cfelse>
			
			<tr>
				<td colspan="100%">
					<BR><BR>
					<strong>1. Select products</strong>
				</td>
			</tr>
			<tr>
				<!----add groups links if it's on--->
				<cfif form.Discount_Growth_Group_Level IS 1>
					<td>
						<CF_button
							button_name		=	""
							button_caption	=	"select groups"
							button_action	=	"javascript: showGroupSearchWindow();"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					</td>
				</cfif>
				<cfif form.Discount_Growth_Item_Level>
					<td>
						<CF_button
							button_name		=	""
							button_caption	=	"select products"
							button_action	=	"javascript: showProductSearchWindow();"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					</td>
				</cfif>
		</cfif>
		
		<cfif bAllowSelectAllProducts>
		
			<td>
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
			</td>
		
		</cfif>
		
		</tr>
		
	</table>

</cfif>

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

	
	function deleteThisGrowthProd(FieldNameRe, prodID, checkCounter, globalCounter, ComponentID, bckRdColor)
	{	
		var trObj = document.getElementById("TR_" + FieldNameRe);
		var tabObj = document.getElementById("TAB_" + FieldNameRe);
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.compProductTierRates.Product_List.value;
		var level1List = document.compProductTierRates.Level_1.value;
		var level2List = document.compProductTierRates.Level_2.value;
		var level3List = document.compProductTierRates.Level_3.value;
		var level1String = ListDeleteItem(level1List, ",", prodID);
		var level2String = ListDeleteItem(level2List, ",", prodID);
		var level3String = ListDeleteItem(level3List, ",", prodID);
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		
		var bDelete = true;
		
		if (!validateGroups())
		{
			return;
		}
			
		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = false;
		}
		
		document.compProductTierRates.Level_1.value = level1String;
		document.compProductTierRates.Level_2.value = level2String;
		document.compProductTierRates.Level_3.value = level3String;
			
		if (!validateGroups())
		{
			document.compProductTierRates.Level_1.value = "";
			document.compProductTierRates.Level_2.value = "";
			document.compProductTierRates.Level_3.value = "";
			document.compProductTierRates.Level_1.value = level1List;
			document.compProductTierRates.Level_2.value = level2List;
			document.compProductTierRates.Level_3.value = level3List;
			return;
		}
			
		document.compProductTierRates.Product_List.value = resultString;
		document.compProductTierRates.ExistingProductList.value = resultString;
		
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		if(trObj)
		{
			var srcObj = event.srcElement;
			//cut
			if(bDelete)
			{ 

				//trObj.cells[0].innerHTML = empty_String;
				trObj.cells[trObj.cells.length - 1].innerHTML = empty_String;
				
				var j, rowlen
				rowlen = tabObj.rows.length;
				for (j = 1;j < rowlen; j++)
				{
					my_queue.addObjValueToQueue(prodID + "_Tier_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldNameRe);
					tabObj.rows[j].cells[1].innerHTML = "<img src=\"../../Images/fill.gif\"> ";
					my_queue.addObjValueToQueue(prodID + "_Tier_UOM_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldNameRe + "_UOM");
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
				for (j = 1;j < rowlen; j++)
				{
					globalCounter++;
					tabObj.rows[j].cells[1].innerHTML = "<span ID=\"error_" + globalCounter + "\"></span><span ID=\"dataToErrorCheck\" errorSpanName=\"error_" + globalCounter + "\" errorMessage=\"Enter A Tier Rate\"><input TYPE=\"Text\" SIZE=\"6\" NAME=\"Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldNameRe + "\" VALUE=\"\" ONKEYUP=\"clenseText(this, '.0123456789');threeDecimalPlaces(this)\" ONBLUR=\"threeDecimalPlaces(this);\" Tier_Number=\"" + j + "\" assignRateIndicator=\"RateApplyer_" + checkCounter + "\"></SPAN>";
					my_queue.deleteAndSetObjValueFromQueue(prodID + "_Tier_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldNameRe);
					disableDiv(tabObj.rows[j].cells[2], false, false);
					my_queue.deleteAndSetObjValueFromQueue(prodID + "_Tier_UOM_" + j, "document.all.Tier_" + arPROGRAM_GROWTH_COMPONENT_TIER_ID[j-1] + "_Product_Rate_" + FieldNameRe + "_UOM");
				}
				
				propogateProperty(tabObj, "style.backgroundColor", "#ffffff", false, true);
				
				
				srcObj.title = "delete this product";
				srcObj.src = deleteImg.src;
				
			}
			srcObj.bDelete = !bDelete;
		}				
	}
	
	//validate groups
	function  validateGroups() 
	{
		var thisForm = document.all;
		var level1 = thisForm.Level_1.value;
		var level2 = thisForm.Level_2.value;
		var level3 = thisForm.Level_3.value;

		var bIsValid= true;
	
		//validate group levels
		//if we have something in level 3 make sure something is in level 1 and 2
		if (trim(level3) != "")
		{
			if(trim(level2) == "")
			{
				alert("Level 2 cannot be empty if Groups or Products exist in Level 3.");
				bIsValid = false;
				return bIsValid;
			}
			else if(trim(level1) == "")
			{
				alert("Level 1 cannot be empty if Groups or Products exist in Level 2 or Level 3.");
				bIsValid = false;
				return bIsValid;
			}
		}
		
		//if we have something in level 2 make sure something is in level 1
		if (trim(level2) != "")
		{
			if(trim(level1) == "")
			{
				alert("Level 1 cannot be empty if Groups or Products exist in Level 2.");
				bIsValid = false;
				return bIsValid;
			}
		}
		
		return bIsValid;
	}
	
</SCRIPT>


<!------<FORM ACTION="Contract_Discount_Growth_Save_Product_Tier_Info_Action.cfm" METHOD="post" NAME="compProductTierRates" ID="compProductTierRates">----->
<FORM ACTION="Contract_Discount_Growth_Add_Component_Products.cfm?CID=<CFOUTPUT>#URL.CID#&COMPID=#URL.COMPID#</CFOUTPUT>" METHOD="post" NAME="compProductTierRates" ID="compProductTierRates" STYLE="DISPLAY:INLINE;">

<INPUT TYPE="Hidden" NAME="Tier_List" VALUE="<CFOUTPUT>#replace(valuelist(getComponentTierInfo.Program_Growth_Component_Tier_ID), "-", "_", "ALL")#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
<INPUT TYPE="Hidden" NAME="Component_ID" VALUE="<CFOUTPUT>#URL.COMPID#</CFOUTPUT>">

<cfif getComponentProducts.Recordcount GT 0>

	<TABLE WIDTH="800" BORDER="0" CELLSPACING="0" CELLPADDING="2">
		<TR VALIGN="top" STYLE="border-bottom:2px solid navy;">
			<TD NOWRAP>
			<font color="#0000FF" size="3" title="You may choose to apply the same rate to all the items. Select the tier, specify the rate and click apply. <br>Click on the save button when you are done." STYLE="cursor:pointer">
				<b>?</b>
			</font>
				&nbsp;&nbsp;&nbsp;
				<FONT SIZE="2">
				<B>Tier:</B> <select NAME="Rate_Tier"><CFLOOP INDEX="LoopCount" FROM="1" TO="#Tier_Count#" STEP="1"><CFOUTPUT><OPTION VALUE="#LoopCount#">#LoopCount#</OPTION></CFOUTPUT></CFLOOP></select></li>			
				&nbsp;&nbsp;&nbsp;&nbsp;
				<B>Rate:</B> <INPUT TYPE="Text" NAME="Discount_Amount" SIZE="3" ONKEYUP="clenseText(this, '.0123456789'); threeDecimalPlaces(this);" onblur="threeDecimalPlaces(this)">
				&nbsp;&nbsp;&nbsp;&nbsp;<FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;">apply rate</A><FONT COLOR="Red"><B> ]</B></FONT>			
				</FONT>
			</TD>
		</TR>	
	</table>
	
	<table width="800">
	
		<tr>
			
			<td width="110">
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"javascript: verifyData();"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
			
			<!----add groups links if it's on--->
			<cfif form.Discount_Growth_Group_Level>
				<td style="display:none;">
					<CF_button
						button_name		=	""
						button_caption	=	"select groups"
						button_action	=	"javascript: showGroupSearchWindow();"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
			</cfif>
				
			<cfif bAllowSelectProducts>
			
				<td width="110" style="display:none;">
					<CF_button
						button_name		=	""
						button_caption	=	"select products"
						button_action	=	"javascript: showProductSearchWindow();"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
				
			</cfif>
	
			<cfif bAllowSelectAllProducts>
			
				<td style="display:none;">
					<CF_button
						button_name		=	""
						button_caption	=	"add all products"
						button_action	=	"javascript: addGroupsLevelProducts(1, \'0\');"
						button_type		=	"link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
				
			</cfif>
	
			<td width="*" align="right">
				
				<font style="font-weight:bold; font-size:11px; color: navy;">Global UOM:</font>
				<br>
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
			
				<span onclick="applyGlobalUOM()"><font style="color:red;font-weight:bold;">[</font><font color="##0000ff" style="cursor:pointer;">apply</font><font style="color:red;font-weight:bold;">]</font></span>
				
			</td>
	
		</tr>
		
	</table>
	
	<CFQUERY NAME="getAllUOMs" datasource="#application.datasource#">
		SELECT *
		FROM Units_Of_Measure
		where Unit_Of_Measure_ID <> 3
	</CFQUERY>

	<!--- Add products to products collection in the structure --->
	

	<cfset ProductKeyList_tmp = "">
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
		<CFSET temp = StructInsert(ThisLevelStruct,"UPC", getComponentProducts.UPC)>
		<CFSET temp = StructInsert(ThisLevelStruct,"ITEM", getComponentProducts.ITEM)>
		<CFSET temp = StructInsert(ThisLevelStruct,"Type_Code_Desc",getComponentProducts.Type_Code_Desc)>

		<!--- Add the weekly volume to the structure --->
	   <!------ <CFSET temp = StructInsert(ThisLevelStruct,"Weekly_Volume", getComponentProducts.Weekly_Volume)>----->
		
		<!--- create a Tiers Collection --->
		<CFSET ThisLevelStruct.Tier_Rates = StructNew()>
		
		<!--- loop through the tiers if any --->
		<CFLOOP QUERY="getComponentTiers">
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
		
		
		<cfset ProductKeyList_tmp = ListAppend(ProductKeyList_tmp, "Product_#LoadProductCount#")>
		<!---if a product id is in a group level bucket then we know it's a group so set onmouseover menuId--->
		<cfloop index="indx" from="1" to="#form.Num_Levels#">
			<cfparam name="tmp_bucket_#indx#" default="" />
			<cfif ListFindNoCase(Evaluate("form.Level_#indx#"), BSA_Foodservice_Items_Master_ID)>
				<cfset "tmp_bucket_#indx#" = ListAppend(Evaluate("tmp_bucket_#indx#"), "Product_#LoadProductCount#") />
			</cfif>
		</cfloop>
		
	</CFLOOP>

	
	
	<cfset Product_Key_List = ListAppend(Product_Key_List, tmp_bucket_1) />
	<cfset Product_Key_List = ListAppend(Product_Key_List, tmp_bucket_2) />
	<cfset Product_Key_List = ListAppend(Product_Key_List, tmp_bucket_3) />
	
	<cfif Form.Discount_Growth_Group_Level eq 1 and appSettings.getAllowMultiLevelGroups() and trim(form.Level_1) neq "">
	
		<br>
		<table WIDTH="300" border="0" cellpadding="0" cellspacing="0">
		
			<tr valign="middle">
			
				<td bgcolor="#ccffcc">
					<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
				</td>
				<td>&nbsp;= Level 1&nbsp;&nbsp;&nbsp;</td>
		
				<td bgcolor="#DFE6FF">
					<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
				</td>
				<td>&nbsp;= Level 2&nbsp;&nbsp;&nbsp;</td>
		
				<td bgcolor="#E2CBE4">
					<table width="13" height="13" border="0" cellpadding="0" cellspacing="1"><tr><td>&nbsp;</td></tr></table>
				</td>
				<td>&nbsp;= Level 3&nbsp;&nbsp;&nbsp;</td>
		
			</tr>
		</table>
	
	</cfif>

	<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Product Pricing</LEGEND>

		<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="75%" ALIGN="center">
		
			<TR BGCOLOR="#FFCE84">
				<td style="display:none;">
					<img bDelete="true" src="/images/scissor.gif" sMessage="delete all products in this page" title="delete all products in this page" border="0" onclick="deleteAll('RateApplyer_')" style="cursor: pointer;">
				</td>					
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
					<cfif application.returned_customer_setting.upc_switch EQ 1>
						<TD>
							<B><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></B>
						</TD>
					</cfif>
				</cfif>
				<TD>
					<B><cfoutput>#application.returned_customer_setting.item_label#</cfoutput></B>
				</TD>
				<TD>
					<B>Description</B>
				</TD>
				<TD>
					<input style="display:none;" TYPE="checkbox" NAME="checkall" ONCLICK="selectAll()" checked>
					<INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products" checked>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="100%">
					<HR SIZE="1" COLOR="Navy">
				</TD>
			</TR>
		
			<CFOUTPUT>
			
			<cfset globalCounter = 1>
			<cfset rateCounter = 0>

			<cfif Product_Key_List eq "">
				<cfset Product_Key_List = ProductKeyList_tmp />
			</cfif>

			<cfparam name="currentheader" default="">
			<cfparam name="currentheader_id" default="">
			
			<CFLOOP INDEX="LoadedProductData" LIST="#Product_Key_List#">
				<CFSET ThisProductData = evaluate("LoadedGrowthDataStruct.Products.#LoadedProductData#")>
				
				<cfquery name="GetDisplayGroupName" dbtype="query">
					select DisplayGroupName from Get_Growth_Comp_Products where BSA_Foodservice_Items_Master_ID = '#ThisProductData.BSA_Foodservice_Items_Master_ID#'
				</cfquery>
				<cfif GetDisplayGroupName.DisplayGroupName NEQ currentheader>
					<cfset currentheader = GetDisplayGroupName.DisplayGroupName />
					<cfset currentheader_id = #REREPLACE(trim(GetDisplayGroupName.DisplayGroupName),' ','_','ALL')# />
					<tr><td colspan="100%" style="background-color:##ddddee;color:##000000;font-weight:900;font-size:11px;" id="header"><input type="checkbox" id="tcHeader_#currentheader_id#" name="type_code_header" value="#currentheader_id#" onClick="checkMatchingProd('#JSStringFormat(currentheader_id)#',this);" checked>&nbsp;#application.returned_customer_setting.TYPE_CODE_LABEL_PLURAL#: #UCASE(GetDisplayGroupName.DisplayGroupName)#</td></tr>
				 </cfif>
				
				<!------<cfset fieldname = replace(ThisProductData.Program_Growth_Component_Product_Data_ID, "-", "_", "ALL")>----->
				<cfset fieldname = replace(ThisProductData.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
				<cfset isInGroupList = 0 />
				<cfparam name="grwthBgColor" default="whitesmoke" />
				<!---handle bgcolor for growth products that are at different levels--->
				<cfif ListFindNoCase(form.Level_1, ThisProductData.BSA_Foodservice_Items_Master_ID)>
					<cfset grwthBgColor = "ccffcc" />
				<cfelseif ListFindNoCase(form.Level_2, ThisProductData.BSA_Foodservice_Items_Master_ID)>
					<cfset grwthBgColor = "DFE6FF" />
				<cfelseif ListFindNoCase(form.Level_3, ThisProductData.BSA_Foodservice_Items_Master_ID)>
					<cfset grwthBgColor = "E2CBE4" />
				<cfelse>
					<cfset grwthBgColor = "whitesmoke" />
				</cfif>
				<!---if a product id is in a group level bucket then we know it's a group so set onmouseover menuId--->
				<cfloop index="indx" from="1" to="#form.Num_Levels#">
					<cfif ListFindNoCase(Evaluate("form.Level_#indx#"), ThisProductData.BSA_Foodservice_Items_Master_ID) and Evaluate("form.GroupLevel_#indx#") neq 9>
						<cfset isInGroupList = 1 />
					</cfif>
				</cfloop>
				
				<cfif isInGroupList>
				  <cfset request.menuId = 11 />
				  <cfset request.theMOId = "#ListGetAt(form.Level_1, isInGroupList)#&Group_Level_ID=#form.GroupLevel_1#&Program_ID=#FORM.Contract_Main_ID#" />
				<cfelse>
					<cfset request.menuId = 6 />
					<cfset request.theMOId = ThisProductData.BSA_Foodservice_Items_Master_ID />
				</cfif>
		  
				<TR BGCOLOR="#grwthBgColor#" ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"  ID="TR_#FieldName#" height="30">
					<cfset rateCounter = rateCounter + 1>
					<TD style="display:none;">
						<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="click here to delete this product" border="0"  onclick="deleteThisGrowthProd('#FieldName#', '#ThisProductData.BSA_FOODSERVICE_ITEMS_MASTER_ID#',#rateCounter#,#globalCounter#,'#ThisProductData.Program_Growth_Component_Product_Data_ID#', '#grwthBgColor#')" style="cursor: pointer;">
					</TD>					
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
						<cfif application.returned_customer_setting.upc_switch EQ 1>
							<TD STYLE="font-weight:bold;">
								#ThisProductData.UPC#
							</TD>
						</cfif>
					</cfif>
					<TD STYLE="font-weight:bold;">
						#ThisProductData.Item#
					</TD>
					<TD STYLE="font-weight:bold;">
						#ThisProductData.Product_Description#
					</TD>
					<TD>
						<span ID="checkAllProducts">
							<input id="#currentheader_id#" TYPE="Checkbox" NAME="RateApplyer_#rateCounter#" ONCLICK="if(!this.checked) document.all.checkall.checked = false;" checked>
						</span>
					</TD>
				</TR>
				
				<TR BGCOLOR="whitesmoke">
				
					<TD COLSPAN="100%" ALIGN="center">

						<!--- inner table --->
						<TABLE BORDER="0" width="200" CELLPADDING="5" CELLSPACING="0" ALIGN="center"  ID="TAB_#FieldName#">
							<TR BGCOLOR="##FFFFCC">
								<TD COLSPAN="100%">
									<B>Product Tier Rates</B><HR SIZE="1" COLOR="Navy">
								</TD>
							</TR>
							
							<!--- loop through the tiers --->
							<CFSET Tier_Len = StructKeyList(ThisProductData.Tier_Rates)>
							<CFSET New_Tier_List = "">
							<cfloop index="LoopCount" from="1" to="#ListLen(Tier_Len, ",")#">
								<CFSET New_Tier_List = ListAppend(New_Tier_List, "Tier_#LoopCount#", ",")>
							</cfloop>
							
							<!------
							<CFLOOP INDEX="TierDataStruct" LIST="#StructKeyList(ThisProductData.Tier_Rates)#">
							-------->
					
							<CFLOOP INDEX="TierDataStruct" LIST="#New_Tier_List#">
						
								<CFSET ThisLevelStruct = evaluate("ThisProductData.Tier_Rates.#TierDataStruct#")>
						
								<cfset tierfieldname = replace(ThisLevelStruct.PROGRAM_GROWTH_COMPONENT_TIER_ID, "-", "_", "ALL")>
						 
								<CFPARAM NAME="FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#" 	DEFAULT="#ThisLevelStruct.Rate#">							
								<CFSET thisRate = Evaluate("FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#")>
								<CFPARAM NAME="FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM" 	DEFAULT="#ThisLevelStruct.Rate_UOM#">
								<CFSET thisUOM = Evaluate("FORM.Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM")>
						 
								<CFIF len(trim(thisUOM)) EQ 0>
									<cfset thisUOM = 0>
									<cfset defaultselected = 1>
								<cfelse>
									<cfset defaultselected = 0>
									<!--- <CFSET thisUOM = CSLGetContractInfo.Contract_Quantity_UOM_IDX> --->
								</CFIF>
						
								<cfset globalCounter = globalCounter + 1>
								<TR BGCOLOR="##FFFFCC" height="35">
									<TD NOWRAP STYLE="font-weight:bold;" width="50">
										Tier #ThisLevelStruct.Tier_Number#
									</TD>
									<TD width="100">
										<span ID="error_#globalCounter#"></span><span ID="dataToErrorCheck" errorSpanName="error_#globalCounter#" errorMessage="Enter A Tier Rate">
											<input TYPE="Text" SIZE="6" NAME="Tier_#tierfieldname#_Product_Rate_#fieldname#" VALUE="#thisRate#" ONKEYUP="clenseText(this, '.0123456789');" Tier_Number="#ThisLevelStruct.Tier_Number#" assignRateIndicator="RateApplyer_#rateCounter#" onchange="this.value = formatToDecimalPlaces(this.value,4);resetnavigate();">
										</SPAN>
									</TD>
									<TD width="50">
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
												uom_id_inclusion_list	=	"#ListOfAvailUOM#"
												productUom				=	"#ThisProductData.Product_Inventory_UM#"
											>
										</span>
<!--- 									<SELECT NAME="Tier_#tierfieldname#_Product_Rate_#fieldname#_UOM">
										<CFLOOP QUERY="getAllUOMs">
											<OPTION VALUE="#getAllUOMs.Unit_Of_Measure_ID#" <CFIF thisUOM EQ getAllUOMs.Unit_Of_Measure_ID>SELECTED</CFIF>>#getAllUOMs.Unit_Of_Measure_Desc#</OPTION>
										</CFLOOP>
									</SELECT> --->
									</TD>
								</TR>
							</CFLOOP>
						</TABLE>
					</TD>
				</TR>
				<TR style="display:none;">
					<TD HEIGHT="2" COLSPAN="100%">&nbsp;</TD>
				</TR>
		
				<cfset globalCounter = globalCounter + 1>
				
			</CFLOOP>
		
			</CFOUTPUT>
	
		</TABLE>

	</FIELDSET>

	<table>
		<tr>
			<td>
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"javascript: verifyData();"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
			
			<!----add groups links if it's on--->
			<cfif form.Discount_Growth_Group_Level>
				<td style="display:none;">
					<CF_button
						button_name		=	""
						button_caption	=	"select groups"
						button_action	=	"javascript: showGroupSearchWindow();"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
			</cfif>
				
			<cfif bAllowSelectProducts>
				<td style="display:none;">
					<CF_button
						button_name		=	""
						button_caption	=	"select products"
						button_action	=	"javascript: showProductSearchWindow();"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				<!---Products have been picked--->
				</td>
			</cfif>
			
			<cfif bAllowSelectAllProducts>
				<td style="display:none;">
					<CF_button
						button_name		=	""
						button_caption	=	"add all products"
						button_action	=	"javascript: addGroupsLevelProducts(1, \'0\');"
						button_type		=	"link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
			</cfif>
		</tr>
	</table>

</cfif>
	
<!---Can now add one item to multiple components. Brenda Flynn, 1/18/05, Heinz request.--->	
<!--- <cfquery name="getProductsFromOtherComponents" datasource="#Application.Datasource#">

	SELECT	Contract_Products.BSA_Foodservice_Items_Master_ID, 
			Program_Growth_Components.Program_Growth_Component_ID, 
			Program_Growth_Components.Program_ID
	FROM	Contract_Products 
			INNER JOIN Program_Growth_Component_Product_Data ON 
			Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID 
			INNER JOIN Program_Growth_Components ON 
			Program_Growth_Component_Product_Data.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
	WHERE	Contract_Products.Deleted = 0
	AND		Program_Growth_Component_Product_Data.Deleted = 0 
	AND 	Program_Growth_Components.Deleted = 0
	AND 	Program_Growth_Components.Program_Growth_Component_ID <> '#LoadedComponentID#'
	AND 	Program_Growth_Components.Program_ID = '#FORM.Contract_Main_ID#'
	AND 	Program_Growth_Components.IsParent = 1
	AND 
			(
				<!------ Group ----->
				(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
				OR
				<!------ Product ----->
				(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
			) 
	<!---filter on groups if it's a group deal--->
<!--- 	<cfif GroupDataManager.isGroupDeal(FORM.Contract_Main_ID)>
	AND 	Contract_Products.Is_Group = 1
	</cfif> --->
	
</cfquery>
		 --->
		
<CFOUTPUT>

<cfparam name="Form.groupLevelProducts" 	default="0">
<cfparam name="Form.Product_Level_1" 	default="">
<INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
<input type="Hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />

<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(getComponentProducts.BSA_Foodservice_Items_Master_ID)#">
<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#trim(FORM.Product_List)#">
<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
<!---Can now add one item to multiple components. Brenda Flynn, 1/18/05, Heinz request.--->	
<!--- <INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="#valuelist(getProductsFromOtherComponents.BSA_Foodservice_Items_Master_ID)#">	 --->
<INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="">	
<INPUT TYPE="Hidden" NAME="navigate" VALUE="#FORM.navigate#">
<INPUT TYPE="Hidden" NAME="stopnavigate" VALUE="0">	

<!---Modification: Group Deals--->
<input type="Hidden" name="Discount_Growth_Item_Level" value="#Form.Discount_Growth_Item_Level#" />
<input type="Hidden" name="Discount_Growth_Group_Level" value="#Form.Discount_Growth_Group_Level#" />
<input type="Hidden" name="Level_1" value="#Form.Level_1#" />
<input type="Hidden" name="Level_2" value="#Form.Level_2#" />
<input type="Hidden" name="Level_3" value="#Form.Level_3#" />
<!--- Variable controls redirection to "Margin Edit" version of contract rebates --->
	<INPUT TYPE="Hidden" NAME="RedirectPath" 		VALUE="1" />

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
<input type="hidden" name="GroupLevel_1" value="#Form.GroupLevel_1#" />
<input type="hidden" name="GroupLevel_2" value="#Form.GroupLevel_2#" />
<input type="hidden" name="GroupLevel_3" value="#Form.GroupLevel_3#" />
<input type="hidden" name="Allow_Multi_Levels" value="#form.Allow_Multi_Levels#" />
<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
<input type="hidden" name="deletedateexclusions" value="#form.deletedateexclusions#" />
</CFOUTPUT>
</FORM>
</BLOCKQUOTE></BLOCKQUOTE>

<FORM ACTION="Contract_Discount_Growth_Add_Component_Products_margin.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="compProducts" ID="compProducts">
<!------<FORM ACTION="Contract_Discount_Growth_Add_Component_Products_Action.cfm" METHOD="post" NAME="compProducts" ID="compProducts">----->
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#valuelist(getComponentProducts.BSA_Foodservice_Items_Master_ID)#">
	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="#URL.CID#">
	<INPUT TYPE="Hidden" NAME="Component_ID" 		VALUE="#URL.COMPID#">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#FORM.Product_List#">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="#FORM.Contract_Main_ID#">
	<!---Can now add one item to multiple components. Brenda Flynn, 1/18/05, Heinz request.--->	
<!--- <INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="#valuelist(getProductsFromOtherComponents.BSA_Foodservice_Items_Master_ID)#">	 --->
<INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="">	
	<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
	</CFOUTPUT>
</FORM>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_MessageWindow>
<script>
	var TotalWeeklyVolume = 0;
	function verifyData()
	{
		ErrorCount = 0
		TotalWeeklyVolume  = 0;
		
		if(document.all.dataToErrorCheck != null) 
		{
			if(dataToErrorCheck.length)
			{
				for(var x =0; x<dataToErrorCheck.length;x++)
				{
					validateCurrentField(dataToErrorCheck[x], getFirstChild(dataToErrorCheck[x]));
				}
			}
			else
			{
				validateCurrentField(dataToErrorCheck,getFirstChild(dataToErrorCheck));
			}
		}
		
		if(ErrorCount == 0)
		{
			<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{document.all.deletedateexclusions.value = 1;</cfif>
			document.compProductTierRates.action = "Contract_Discount_Growth_Save_Product_Tier_Info_Action.cfm";
			document.all.navigate.value = 0;
			//disableButton("save_table", true, false);
			<cfif programagreed GT 0 and GetContractInfo.modifying_program EQ 0 and GetContractInfo.Contract_Status_Type_IDX EQ 2>
				if(confirm("The <cfoutput>#approvalGroupType.Label#</cfoutput>'s which are you responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the <cfoutput>#approvalGroupType.Label#</cfoutput>'s you are responsible for again."))
				{
					document.compProductTierRates.submit();
				}
				<cfelse>
				document.compProductTierRates.submit();
				</cfif>
			
		<cfif donotallowaddproductsDE EQ 1>
			}
	</cfif>
		}
		else
		{
			showMessageWindow();
			document.all.navigate.value = 1;
		}
	
	}
	
	function validateCurrentField(objectToErrorCheckSpan, objectToErrorCheck)
	{
		if(trim(objectToErrorCheck.value).length==0) 
		{
			ErrorCount++				
			queueMessage(objectToErrorCheckSpan.errorMessage, eval("document.all." + objectToErrorCheckSpan.errorSpanName))
		}
		else 
		{
			clearQueue(eval("document.all." + objectToErrorCheckSpan.errorSpanName))
		}
	}
	
<!--- 	findselectboxes() --->
	
	function resetnavigate()
		{
			document.all.navigate.value = 1;
		}
		
	function verifyNavigate() {
			if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				{
					event.returnValue='Product selections you have not saved will be lost.'
			}
		}	
		}
</script>

<!--- delete product section --->
<cfinclude template="delete_product_include.cfm">
<!--- delete product section --->


</BODY>
</HTML>