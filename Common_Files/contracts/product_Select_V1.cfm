<cfparam name="form.include_companion" default="0">
<!--- Dev Note: - Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="">
<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />
</cfif>
<!---26199 load user profile settings if they do not exists--->
<cfif not IsDefined("Get_Profile_Settings")>
  <cfinclude template="/get_access_profile.cfm">
</cfif>
<cfparam name="Discountype" default = "0">
<cfparam name="session.rebateType" default="">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="url.component_id" default="0">
<cfparam name="EZButton_ProductList" default="">
<cfparam name="EzButton_Products" default="0">
<cfparam name="url.isparent" default="0">
<cfparam name="form.includeCustomersInProgram" default="0">
<!---default params for business segments--->
<cfparam name="url.Business_Segment_ID" default="0">
<cfparam name="FORM.Business_Segment_ID" default="#url.Business_Segment_ID#">
<cfparam name="url.businessSegmentsOn" default="0">
<cfparam name="form.businessSegmentsOn" default="#url.businessSegmentsOn#">
<cfparam name="Bus_Segment_Desc" default="" />
<cfparam name="URL.DTPS_Program_ID" default="0" />
<cfparam name="Form.DTPS_Program_ID" default="#URL.DTPS_Program_ID#" />
<cfparam name="Form.Bid_Rule_In_Effect" default="" />
<cfparam name="Form.Only_Show_Products_from_these_Groups" default="" />
<cfparam name="URL.CallingPage" default="Programs" />
<cfparam name="Form.CallingPage" default="#URL.CallingPage#" />
<cfparam name="variables.maxProducts" default="" />
<cfparam name="URL.FirstParentID" default="0" />
<cfparam name="URL.prgID" default="0" />
<cfparam name="Form.ParentFormname" default="" />
<cfparam name="FORM.description_string" default="">
<cfparam name="FORM.item_number" default="">
<cfparam name="FORM.upc_number" default="">
<cfparam name="FORM.Program_ID" default="0">
<cfparam name="FORM.LoadProductsFromThesePrograms" default="0">
<cfparam name="URL.plannerId" default="" />
<cfparam name="FORM.plannerId" default="" />
<cfparam name="PageSource" default="">
<!---BJF: Coming from billbacks the list is pipe delimited --->
<!---TSF: Label 11420 - Commented out to handle for form.FinalUPCList and FORM.ExistingProductList below --->
<!---
<cfif isDefined("form.FinalUPCList")>
	<cfset form.FinalUPCList = replace(form.FinalUPCList, "|", ",", "ALL")>
</cfif>
--->
<cfif url.plannerId neq "">
	<cfset form.plannerId = url.plannerId>
</cfif>


<cfset useLakebaseForgetDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForgetDistributors>
	<cftry>
		<cfset getDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#URL.prgID#",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDistributors>
<cfquery name="getDistributors" datasource="#application.datasource#" >
	SELECT 1
	FROM Contract_Distributors
	Where Deleted = 0
	AND Contract_Main_ID = #URL.prgID#
</cfquery>
</cfif>

<cfset session.Group_Rebate_Type_Search_ID = 0  >

<cfif isDefined("url.formname")>
	<cfset session.rebateType = url.formname>
</cfif>

<cfparam name="form.rebateTypeSelected" default="0">
<!--- fixed price --->
<cfif isDefined("session.rebateType") and session.rebateType EQ Ucase("FixedComponents")>
	<cfset form.rebateTypeSelected = 1 >
<!--- allowance --->
<cfelseif isDefined("session.rebateType") and session.rebateType EQ Ucase("dataForm")>
	<cfset form.rebateTypeSelected = 2>
<!--- fee ---->
<cfelseif isDefined("session.rebateType") and session.rebateType EQ Ucase("MyForm")>
	<cfset form.rebateTypeSelected = 3>
<!--- growth---->
<cfelseif isDefined("session.rebateType") and  session.rebateType EQ Ucase("compProductTierRates")>
	<cfset form.rebateTypeSelected = 4>
</cfif>

<cfparam name="url.Discountype" default = "0">

<cfset form.rebateTypeSelected = #url.Discountype#>

<cfif form.rebateTypeSelected eq 2>
	<cfset variables.maxProducts = createObject("component", "components.programs.rebates.Rebate").getMaxProducts() />
</cfif>

<cfif Discountype neq "0">
	<cfset form.rebateTypeSelected = Discountype>
</cfif>


<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset userClassCodeInThisProductSearch = appSettings.getClassCodesOn() />

<cfset ProductMessagesComponent = createobject("component", "components.programs.Message")>

<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.passed_form" 	default="">
<cfparam name="form.itemList" 		default="">
<cfparam name="URL.SelectSingleSearchResultOnly" 	default="0">
<cfparam name="URL.Return_Value_Field_Name" 		default="Product_List">
<cfparam name="URL.Return_Value_Group_Field_Name" 	default="">
<cfparam name="URL.ExistingProductList_Field_Name" 	default="ExistingProductList">
<cfparam name="URL.ProductListToExcludeFromSelecting_Field_Name" 		default="ProductListToExcludeFromSelecting">
<cfparam name="URL.AnotherProductListToExcludeFromSelecting_Field_Name" default="AnotherProductListToExcludeFromSelecting">
<cfparam name="form.Prod_Name" default="">

<!--- <cfparam name="FORM.getCaptureGroupsOnSave" 	default="0"> --->

<cfparam name="FORM.Group_Rebate_Type_Search_ID" 	default="0">
<cfparam name="FORM.Distributor_List" 				default="">

<cfparam name="Records_To_Show" default=200>
<cfset cacheSpan = APPLICATION.masterDataCacheSpan>
<cfparam name="UserClassCodes" default="">
<!---Includes personal preferences for records to show--->
<cfif application.Personalization EQ 1>
	<cfinclude template="/settings/personalization/records_to_return.cfm">
</cfif>

<cfif appSettings.getAllowNavigate()>
<CFINCLUDE TEMPLATE="comparelist.cfm">
</cfif>

<cfif form.passed_form EQ "searchform">
	<cfset form.passed_form = "">
</cfif>

<!--- Query the 180 day table flag --->
<!---
<cfset FORM.QueryMiniProductTable = genSettingsManager.get().getSearchMiniItemMaster()>
--->
<cfparam name="QueryMasterProductTable" default = "1">

<!--- reformat the itemList --->
<cfif form.passed_form NEQ "" and form.passed_form NEQ "searchform" and form.itemList NEQ "">
	<cfset form.itemList = #trim(replace(ListQualify(form.itemList, "'", ",", "ALL"), "''", "'", "ALL"))#>
</cfif>

		<CFIF FORM.Distributor_List NEQ "">
			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name
				FROM BSA_Foodservice_Customers
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(FORM.Distributor_List, "'")#)
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
			<CFSET Selected_Distributor= Dist_Search_Result.Name>
		</CFIF>

<CFIF isdefined("URL.FormName")>
	<cfparam name="URL.PID" default="">
	<CFOUTPUT>
	<FORM ACTION="product_select_V1.cfm?Discountype=#url.Discountype#&EZTemplate=#url.EZTemplate#&component_id=#url.component_id#&isparent=#url.isparent#&SourceCaller=#URL.FormName#&FirstParentID=#URL.FirstParentID#&prgID=#URL.prgID#&plannerId=#form.plannerId#" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="#URL.FormName#">
		<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="">
		<INPUT NAME="ProductListToExcludeFromSelecting" TYPE="Hidden" VALUE="">
		<INPUT NAME="Sort_By" TYPE="Hidden" VALUE="Item">
		<INPUT NAME="Program_ID" TYPE="Hidden" VALUE="#URL.PID#">
		<INPUT NAME="DTPS_Program_ID" TYPE="Hidden" VALUE="#Form.DTPS_Program_ID#">
		<INPUT NAME="CallingPage" TYPE="Hidden" VALUE="#URL.CallingPage#">
		<INPUT NAME="Bid_Rule_In_Effect" TYPE="Hidden" VALUE="0">
		<INPUT NAME="SudmitFormViaSubmitButton" TYPE="Hidden" VALUE="0"> <!--- when a form is submitted this way; the onsubmit function is called. using form.submit() does not fire it --->
		<INPUT NAME="parent_call_back" TYPE="Hidden" VALUE="">
		<INPUT NAME="Only_Show_Products_From_These_Groups" TYPE="Hidden" VALUE="0">
		<INPUT NAME="LoadProductsFromThesePrograms" TYPE="Hidden" VALUE="">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="#URL.SelectSingleSearchResultOnly#">
		<INPUT NAME="rebateTypeSelected" TYPE="HIDDEN" VALUE="#form.rebateTypeSelected#">
		<INPUT NAME="AllowProductGroupList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="AllowProductGroupLevelId" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="Return_Value_Field_Name" TYPE="HIDDEN" VALUE="#URL.Return_Value_Field_Name#">
		<INPUT NAME="Return_Value_Group_Field_Name" TYPE="HIDDEN" VALUE="#URL.Return_Value_Group_Field_Name#">
		<INPUT TYPE="hidden" NAME="Prod_Name" value="#Prod_Name#">
		<INPUT TYPE="hidden" NAME="Business_Segment_ID" value="#form.Business_Segment_ID#">
		<INPUT TYPE="hidden" NAME="businessSegmentsOn" value="#form.businessSegmentsOn#">
		<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="#FORM.FlexAppName#">
        <INPUT TYPE="hidden" NAME="plannerId" value="#form.plannerId#">
        <INPUT TYPE="hidden" NAME="PageSource" VALUE="#PageSource#">
	</FORM>
	</CFOUTPUT>
	<cfif URL.FormName EQ 'flex' OR PageSource eq "AliasItemSearch">
		<script>
			document.all.MyForm.submit();
		</script>
	<cfelse>
	<script>
		<CFOUTPUT>
		if(window.opener.document.all.#URL.FormName# != null){
			var openerObj = window.opener;
			var openerFormObj = window.opener.#URL.FormName#;
			this.document.all.ExistingProductList.value = opener.document.all.#URL.FormName#.#URL.ExistingProductList_Field_Name#.value;

			if(window.opener.document.all.#URL.FormName#.#URL.ProductListToExcludeFromSelecting_Field_Name# != null){
				this.document.all.ProductListToExcludeFromSelecting.value = opener.document.all.#URL.FormName#.#URL.ProductListToExcludeFromSelecting_Field_Name#.value;
			}

			/* Dev note: 15322 (Milan) - If 'AnotherProductListToExcludeFromSelecting' is not empty, add that to the
				 already existing list of excluded products.'AnotherProductListToExcludeFromSelecting' has either Level2 or Level3 as values
			*/
			if(window.opener.document.all.#URL.FormName#.#URL.AnotherProductListToExcludeFromSelecting_Field_Name# != null){
					if(window.opener.document.all.#URL.FormName#.#URL.ProductListToExcludeFromSelecting_Field_Name# != null)
					{
						this.document.all.ProductListToExcludeFromSelecting.value = this.document.all.ProductListToExcludeFromSelecting.value + ",";
					}
						this.document.all.ProductListToExcludeFromSelecting.value = this.document.all.ProductListToExcludeFromSelecting.value + opener.document.all.#URL.FormName#.#URL.AnotherProductListToExcludeFromSelecting_Field_Name#.value;
			}

			if(opener.document.all.#URL.FormName#.Sort_By)
			{
				this.document.all.Sort_By.value = opener.document.all.#URL.FormName#.Sort_By.value;
			}
            if(opener.document.all.#URL.FormName#.plannerId)
			{
				this.document.all.plannerId.value = opener.document.all.#URL.FormName#.plannerId.value;
			}


			if(opener.document.all.#URL.FormName#.Bid_Rule_In_Effect)
			{
				this.document.all.Bid_Rule_In_Effect.value = opener.document.all.#URL.FormName#.Bid_Rule_In_Effect.value;
			}


			if(opener.document.all.#URL.FormName#.DTPS_On != null && opener.document.all.#URL.FormName#.DTPS_Program_ID != null){

				DTPS_On_temp = opener.document.all.#URL.FormName#.DTPS_On;
				DTPS_Program_ID_temp = opener.document.all.#URL.FormName#.DTPS_Program_ID;


				if(DTPS_On_temp.value.length != 0 && DTPS_Program_ID_temp.value.length != 0 && DTPS_On_temp.value != 0 && DTPS_Program_ID_temp.value != 0){
					this.document.all.DTPS_Program_ID.value = DTPS_Program_ID_temp.value;
				}
			}

			if(opener.document.all.#URL.FormName#.SudmitFormViaSubmitButton)
			{
				this.document.all.SudmitFormViaSubmitButton.value = opener.document.all.#URL.FormName#.SudmitFormViaSubmitButton.value;
			}

			if(opener.document.all.#URL.FormName#.parent_call_back)
			{
				this.document.all.parent_call_back.value = opener.document.all.#URL.FormName#.parent_call_back.value;
			}


			if(opener.document.all.#URL.FormName#.Only_Show_Products_From_These_Groups != null)
			{
				this.document.all.Only_Show_Products_From_These_Groups.value = opener.document.all.#URL.FormName#.Only_Show_Products_From_These_Groups.value;
			}

			if(openerFormObj.AllowProductGroupList)
			{
				this.document.all.AllowProductGroupList.value = openerFormObj.AllowProductGroupList.value;
				this.document.all.AllowProductGroupLevelId.value = openerFormObj.AllowProductGroupLevelId.value;
			}
			document.all.MyForm.submit();
		}
		else{
			alert("An error has occurred. Necessary information is not available. Please inform system administrators. This window will close.")
			window.close();
		}
		</CFOUTPUT>
	</script>
	</cfif>
	<cfabort>
</CFIF>

<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
<!---create and instance of the BusinessSegmentManager--->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() />
<cfset ProdSearchSettingsManager 	= CreateObject("component", "components.settings.Labels.Labels").init() />
<cfset ProdSearchSettings	= ProdSearchSettingsManager.getProductStaticSearchFieldsActive() />
<cfset ProdSearchResultsColumnsDisplaySettings = ProdSearchSettingsManager.getProductSearchFieldsDisplayStatus()>
<cfset ProdSearchResultsColumnsDisplayAdditionalSettings = ProdSearchSettingsManager.getProductStaticSearchFieldsDisplayStatus() />

<!---
	Dev Notes: D27225:EZ Button Changes/Anand Rao
	START EZ Button changes for the template to include Business segment when it is ON in the Template
--->

<cfset bBusinessSettingONinTemplate = 0 />
<cfset qTemplateBusinessSegments = queryNew("") />
<cfif (isBusinessSegEnabledForProduct EQ 1 AND appSettings.Filter_Business_Segments EQ 1)>
	<cfset bBusinessSettingONinTemplate = 1 />
	<cfquery name="qGetTemplateID" datasource="#application.datasource#">
		SELECT ProgramType_ID FROM Contract_Main WHERE Contract_Main_ID = #URL.prgID#
	</cfquery>
	<cfif qGetTemplateID.RecordCount GTE 1 >
		<cfset qTemplateBusinessSegments  = businessSegManager.getBusinessSegmentTemplateSettings(qGetTemplateID.ProgramType_ID) />
	</cfif>
</cfif>

<!--- END EZ Button  --->


<cfif (isBusinessSegEnabledForProduct and form.Business_Segment_Id and URL.EZTemplate NEQ 1) OR (CallingPage EQ "Billbacks" and appSettings.getUseProductGroup5() and form.businessSegmentsOn and URL.EZTemplate NEQ 1)>
	<cfset form.businessSegmentsOn = 1 />
	<!---get the desctiption to display--->
	<cfset qGetThisBusSegment = businessSegManager.get(form.Business_Segment_Id) />
	<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
<cfelseif (URL.EZTemplate EQ 1 AND bBusinessSettingONinTemplate EQ 1)>
	<cfset form.businessSegmentsOn = 1 />
	<!---get the desctiption to display--->
	<cfif (isDefined("qTemplateBusinessSegments") and qTemplateBusinessSegments.RecordCount GTE 1)>
		<cfloop query = "qTemplateBusinessSegments">
			<cfset qGetThisBusSegment = businessSegManager.get(qTemplateBusinessSegments.Business_Segment_Id) />
			<cfif Bus_Segment_Desc EQ "">
				<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
			<cfelse>
				<cfset Bus_Segment_Desc = Bus_Segment_Desc & ", "& qGetThisBusSegment.Business_Unit_Desc />
			</cfif>
		</cfloop>
	</cfif>
</cfif>


<cfset Revision_Settings_Allowed = 0>
<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	<cfset programInfo = programManager.getProgramInfo(FORM.DTPS_Program_ID)>
	<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = programInfo.ProgramType_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = URL.prgID)>
	<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(DTPS_Program_ID)>

	<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number neq "")>
		<cfset Revision_Settings_Allowed = 1>
	</cfif>
<cfelse>

	<cfset RevisionStatus = QueryNew("Is_A_Revision, Contract_Reference_Number")>

</cfif>

<cfif Not IsDefined("ProgramManager")>
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
</cfif>

<cfif NOT IsDefined("ParentprogramInfo")>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(DTPS_Program_ID)>
</cfif>

<cfif NOT IsDefined("ProgramProducts")>
	<cfset ProgramProducts = CreateObject("component", "components.products.products")/>
</cfif>

<cfif Revision_Settings_Allowed eq 1  AND RevisionStatus.Is_A_Revision eq 1>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(DTPS_Program_ID)>
	<cfset getProgramProducts = ProgramProducts.getproducts('',form.rebateTypeSelected,ParentProgramInfo.Revision_of_Contract_main_id)>
</cfif>


<cfset ProductItemList = "">
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
	<cfif getProgramProducts.recordcount neq 0>
		<cfif url.Discountype eq 1>
			<cfset ProductItemList = ValueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
		<cfelseif url.Discountype eq 2>
			<cfset ProductItemList = valueList(getProgramProducts.MasterItemID)>
		<cfelseif url.Discountype eq 4>
			<cfset ProductItemList = valueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
		<cfelseif url.Discountype eq 8>
			<cfset ProductItemList = valueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
		<cfelseif url.Discountype eq 10>
			<cfset ProductItemList = valueList(getProgramProducts.ItemMasterID)>
		</cfif>
	</cfif>
</cfif>

<CFSET PAGE_TITLE= "#application.returned_customer_setting.item_label# Search">

<cfscript>

function isNextRow(maxCols, currCols)
{
	if(currCols LTE 1)
	{
		//WriteOutput(currCols & " " & maxCols & " " & "<br>");
		return 0;
	}
	else
	{
		//WriteOutput(currCols & " " & maxCols & " " & (not(currCols) mod maxCols) & "<br>");
		return (not(currCols) mod maxCols);
	}
}

</cfscript>

<!--- PRODUCT LIST MAINTAINENCE --->
<cfparam name="FORM.SelectedUPCS" default="">
<cfparam name="FORM.FinalUPCList" default="">
<cfparam name="FORM.AlreadySelectedItems" default="">
<cfparam name="FORM.finishedselectingproducts" default="0">
<cfparam name="FORM.LoadExistingProductList" default="1">
<cfparam name="FORM.FirstTimeLoading" default="TRUE">
<cfparam name="FORM.ProductListToExcludeFromSelecting" default="">
<cfparam name="form.SudmitFormViaSubmitButton" default="0">
<cfparam name="form.parent_call_back" default="">
<cfparam name="form.Importallflag" default="0">
<cfparam name="FORM.AllowProductGroupList" default="">
<cfparam name="FORM.AllowProductGroupLevelId" default="">
<cfparam name="FORM.Return_Value_Field_Name" default="">
<cfparam name="FORM.Return_Value_Group_Field_Name" default="">

<!---default params for business segments--->
<cfparam name="FORM.Business_Segment_ID" default="0">
<cfparam name="form.businessSegmentsOn" default="0">

<cfif !isDefined("FORM.SelectSingleSearchResultOnly")>
    <!--- when form name is not passed get the missing parameter from url scope when it exists --->
    <cfset form.SelectSingleSearchResultOnly = url.SelectSingleSearchResultOnly ?: 0>
</cfif>

<!--- BJF: 12195 -- Tim's fix below makes it so that you lose rates/volumes for existing products on the program. I didn't see the error that his label was supposed to fix, but be alert that this data does need to get passed back to billbacks. --->
<!---TSF: Label 11420 - When coming from billbacks form.FinalUPCList and FORM.ExistingProductList will have product/customer
	 combinations seperated by a | delimiter. If we find a | in either one of these lists we have to strip out the | and customer ids--->
<!--- <cfif ListContainsNoCase(form.FinalUPCList, "|")>
	<!---remove | and customer id from form.FinalUPCList--->
	<cfset form.FinalUPCList = REReplace(form.FinalUPCList, "\|[^,]*", "", "All") />
</cfif>
<cfif ListContainsNoCase(form.ExistingProductList, "|")>
	<!---remove | and customer id from form.ExistingProductList--->
	<cfset form.ExistingProductList = REReplace(form.ExistingProductList, "\|[^,]*", "", "All") />
</cfif>
 --->
<CFSET SHOW_INVOICE_FILTER=1>

<CFSET listofitemstodelete = "">
<!--- loop through the pages selected items and if it is not in the selected list that means it was removed to queue it for deletetion --->
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF ListFindNoCase(FORM.SelectedUPCS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>
<CFSET parentselectedlist = Form.FinalUPCList>
<!--- if a selected item isnt already in the final list then add it  --->
<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedUPCS#" DELIMITERS=",">
	<CFIF ListFindNoCase(Form.FinalUPCList, ListItem, ",") EQ 0>
		<CFIF FORM.SelectSingleSearchResultOnly NEQ 1>
			<CFSET Form.FinalUPCList = listappend(FinalUPCList, ListItem, ",")>
		<CFELSE>
			<CFSET Form.FinalUPCList = ListItem />
		</CFIF>
	</CFIF>
</CFLOOP>
<!--- delete the queued products --->
<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF ListFindNoCase(FORM.FinalUPCList,ListItem, ",") GT 0>
		<CFSET Form.FinalUPCList = listdeleteat(FORM.FinalUPCList, ListFindNoCase(FORM.FinalUPCList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>
<!--- FinalUPCList: <CFOUTPUT>#FORM.FinalUPCList#</CFOUTPUT><BR><BR> --->

<CFIF FORM.LoadExistingProductList EQ 1>
	<CFSET Form.FinalUPCList = FORM.ExistingProductList>
</CFIF>

<cfset ProductMessages = ProductMessagesComponent.GetMessageSettings(DTPS_Program_ID,Discountype)>

<!--- ****************************************************************** --->

<cfparam name="StartRow" default="1">
<cfparam name="frompage" default="1">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<script>

		function showDistSearchWindow()
		{
		document.SearchForm.target = "_self";
		document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
		NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchForm", "SearchForm", 800, 400, "yes", "yes");
		}

		function profilePopup(PopupLocation, internal_ID){
			switch (PopupLocation) {

				case "product":
					NewWindow('/profiles/Products/Product_profile.cfm?PID=' + internal_ID,'name','400','450','Yes', 'No');
				break;

			}
		}
		preSelectedProducts = new Object();
		function initPage() {
					}

		var thisPageProductList = "";

		function buildThisPageList() {
			thisPageProductList = "";
			for(var x=0; x<document.all.selected_products.length; x++) {
				thisCheckBox = document.all.selected_products[x];
				if(thisCheckBox.checked){
					thisPageProductList = thisPageProductList + thisCheckBox.value + ",";
				}
			}
			if(thisPageProductList.length > 0) {
			thisPageProductList = thisPageProductList.substring(1, thisPageProductList.length-1);
			}
			return thisPageProductList;
		}

		isSearching = 0
		function doSearch() {
			processingPopUpDisplay('div.customContainer'); //D51575
			var clear = true;
			if (document.all.SearchForm.rebateTypeSelected.value == 3 && (typeof(document.all.SearchForm.Group_Rebate_Type_Search_ID) != "undefined") && document.all.SearchForm.Group_Rebate_Type_Search_ID.value > 0 )
				clear = confirm("Only group products with highest pricing level are going to import, would you like to continue?");
			if (clear) {
				isSearching = 1;
				document.all.SearchForm.startrow.value=1;
				document.all.SearchForm.frompage.value=1;
				document.all.SearchForm.passed_form.value = "searchform";
				document.all.SearchForm.submit();
			}
		}

		function validate(theForm) {
			return theForm.rebateTypeSelected.value;
		}

        ////////////////////////////////////////////////////////////////////
        // return an array of structures for the selected products - 85971
        ////////////////////////////////////////////////////////////////////
        function selected_rows() {
            let closest_tr, selected = [];
            $("input[name=selectedUPCS]:checked").each( function() {
                closest_tr = $(this).closest("tr");
                selected.push( {     bsa_foodservice_items_master_id: $(this).val()
                                   , product:     closest_tr.children("td.item").text().trim()
                                   , description: closest_tr.children("td.description").text().trim()
                                } );
            } );
            return selected;
        }

        ///////////////////////////////////////////////////
        // custom handling before form submission - 85971
        ///////////////////////////////////////////////////
        function before_submit_form() {
            <cfoutput>
            const #toScript(lcase(trim(PageSource)), "page_source")#
            const #toScript(form.Return_Value_Field_Name, "opener_product_input")#
            </cfoutput>
            // custom handling for redistribution page
            if (page_source === "redistribution") {
                // pass back selected rows info to opener call back function for processing
                opener.refresh_item(opener_product_input, selected_rows());
                // close this popup window, skip posting the form for better performance
                window.close();
            }
        }

		function finishedSearching() {
		processingPopUpDisplay('div.customContainer'); //D51575
		<cfoutput>
		<!--- If a message needs to be shown while adding products, show the message in a new window --->
		<cfif ProductMessages.Message_Settings eq 1>
		winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no';
		window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#DTPS_PROGRAM_ID#&Discountype=#Discountype#","ProductMessageWindow",winprops);
		<cfelse>
			SubmitFormOnfinishedSearching();
		</cfif>
		</cfoutput>
		}
		<!--- This function is called either from "finishedSearching()" OR from "Product_Add_Confirmation_Message.cfm"--->
		function SubmitFormOnfinishedSearching()
		{
            before_submit_form();
            disableButton("divLinks", true, false);
            <cfif isDefined("url.callback") and len(url.callback)>
                <cfoutput>
                    if (typeof opener.#url.callback# === "function") {
                        opener.#url.callback#( selected_rows() );
                    }
                </cfoutput>
            </cfif>
			document.all.finishedselectingproducts.value = 1
			document.all.SearchForm.submit();
		}

		function verifyClose() {
			if (document.all.startrow & !document.all.itemList) {
				if(document.all.startrow.value == <CFOUTPUT>#StartRow#</CFOUTPUT> && document.all.finishedselectingproducts.value != 1 && isSearching != 1){
					event.returnValue='Product selections you have not saved will be lost.';
				}
			}
		}

		function selectAll(){
			if(window.checkAllProducts != null){
				if(checkAllProducts.length)
				{
					for(var x=0; x<checkAllProducts.length;x++){
						box = getFirstChild(checkAllProducts[x]);
						box.checked = document.all.checkall.checked;
					}
				}
				else
				{
					box = getFirstChild(checkAllProducts);
					box.checked = document.all.checkall.checked;
				}
			}
		}

		function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{
			isSearching = 1;
			var formObj;
			formObj = document.all.SearchForm;
			formObj.sort_by.value = thisSortItem;
			formObj.sort_Order.value = thisSortOrder;
			formObj.submit();
			return false;
		}
	</script>
</HEAD>

<BODY BGCOLOR="White" ONLOAD="initPage()" ONBEFOREUNLOAD="verifyClose()">
<STYLE>
    #div92a, #div92b, #div92c { margin: 1%; width: 98%; }
    #td92a a { margin-left: 14px; }
    SELECT
    {
        width:97%;
    }
    input[type=checkbox] {
        position: relative;
        top: 2px;
    }
    label {
        user-select: none;
        cursor: pointer;
    }
</STYLE>

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<!-- bid rule -->
<cfif form.Bid_Rule_In_Effect EQ 1>
	<!-- get items with no bid rule association for exclusion from search with no type_code association-->
	<CFQUERY NAME="getItemsForExclusion" DATASOURCE="#application.datasource#">
	SELECT     BSA_Foodservice_Items_Master_ID
	FROM         dbo.BSA_Foodservice_Items_Master
	WHERE     (Deleted = 0) AND (Active_Code = 'A') AND (NOT EXISTS
	                          (SELECT     Type_Item_ID
	                            FROM          Bid_Rule_Items
	                            WHERE      Deleted = 0 AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Bid_Rule_Items.Type_Item_ID))
	</CFQUERY>
	<cfset form.ProductListToExcludeFromSelecting = ValueList(getItemsForExclusion.BSA_Foodservice_Items_Master_ID)>
	</cfif>

<SCRIPT Language = "JavaScript">
function save_Documents()
	{
		document.FormAttach.formcheck.value = "1";
		document.FormAttach.submit();
	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
			if(sObj)
			{
				sObj.selectedIndex = 0;
				callfireEvent(document,sObj,'Change');
			}
	}
</SCRIPT>

<cfsilent>
<cfset restrictOnProductGroup = 0>
<cfset restrictOnProfileProductGroup = 0>

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT 	Program_Control_Panel_Options.Discount_Rebates_Group_Level,
  			Program_Control_Panel_Options.IsDominant,
  			Program_Control_Panel_Options.First_Parent_ID,
			exclude_sig_products, modifying_program, EZButton_On,
			EZ_Contract_Id,
			Distributor_Product_Integrity_Rule_ID,
			Discount_Rebate_Max_Rate_On,
			EzButton_Default_Show_Item_Rates
			,Filter_EZButton_Products <!--- 63628 --->
	FROM 	Contract_Main
	INNER JOIN	Program_Control_Panel_Options
	ON 		(Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
	WHERE 	Contract_Main_ID = #FORM.DTPS_Program_ID#
</cfquery>

<!------ Product Group Restriction ----->
<cfset arrayProductGroupSelection		= ArrayNew(1) />

<!------ Is the search from inside a program? ----->
<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>

	<!------ Operating Group ----->
	<!------ The list of products returned has to be filtered based on the operating group of the program.
	The operating group will have different product group attribute-value pair
	----->
	<cfif appSettings.getOperatingGroupOn()>
		<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
		<!------ Find the operating group level 1 for the program ----->
		<cfset productGroupSelectLevel			= operatingGroupManager.getProductGroupSelectLevel() />
		<cfset productGroupSelectLevelValue		= operatingGroupManager.getProgramOperatingGroupID(level=productGroupSelectLevel, programId=FORM.DTPS_Program_ID) />
		<cfset qGetProductGroupSelection 		= operatingGroupManager.getProductGroupSelection(productGroupSelectLevelValue) />
		<cfset arrayOperatingGroupProductGroupSelection		= operatingGroupManager.convertProductGroupSelectionToArray(qGetProductGroupSelection, 1) />
		<cfset arrayProductGroupSelection = arrayOperatingGroupProductGroupSelection />
	</cfif>
	<!------ Operating Group ----->
	<!---
		Dev Notes: D27225:EZ Button Changes/Anand Rao
		Added logic to check for the EZ button template ON or OFF and set the Business segment
		accordingly
	--->
	<cfif (isBusinessSegEnabledForProduct AND URL.EZTemplate NEQ 1) OR (URL.EZTemplate EQ 1 AND bBusinessSettingONinTemplate EQ 1)>
		<cfif (isBusinessSegEnabledForProduct AND URL.EZTemplate NEQ 1)>
			<cfset form.businessSegmentsOn = 1 />
			<cfset form.Business_Segment_Id = businessSegManager.getSegmentIdByProgram(FORM.DTPS_Program_ID) />
			<!---get the desctiption to display--->
			<cfset qGetThisBusSegment = businessSegManager.get(form.Business_Segment_Id) />
			<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
		<cfelseif (URL.EZTemplate EQ 1 AND bBusinessSettingONinTemplate EQ 1)>
			<cfset form.businessSegmentsOn = 1 />
	<!---get the desctiption to display--->
			<cfif (isDefined("qTemplateBusinessSegments") and qTemplateBusinessSegments.RecordCount GTE 1) AND Bus_Segment_Desc EQ "">
				<cfloop query = "qTemplateBusinessSegments">
					<cfset qGetThisBusSegment = businessSegManager.get(qTemplateBusinessSegments.Business_Segment_Id) />
					<cfif Bus_Segment_Desc EQ "">
						<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
					<cfelse>
						<cfset Bus_Segment_Desc = Bus_Segment_Desc & ", "& qGetThisBusSegment.Business_Unit_Desc />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<!------ get the sales person user id ----->


		<cfset qProgram = CreateObject("component", "components.programs.Program").getProgramInfo(FORM.DTPS_Program_ID) />
		<cfif CallingPage EQ "Billbacks">
			<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes("", 0) />
		<cfelse>
			<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(qProgram.Responsible_User_ID, 0) />
		</cfif>

		<cfif userClassCodeInThisProductSearch>
			<cfset UserClassCodes = ValueList(qgetUserClassCodes.class_code_id)>
		</cfif>
	</cfif>



	<!------ see whther the product selection is to be restricted based on product group ----->

	<cfif programInfo.Restrict_On_Approval_Group OR GetSettings.modifying_program EQ 1>
		<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init()>
		<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(productGroupLevelId=appSettings.getTemplateRestrictGroupLevel()) />
	</cfif>

	<cfif GetSettings.modifying_program EQ 1>
	<cfset restrictOnProfileProductGroup = 1>
		<cfset qRestrictOnModifyingProductGroupList = approvalGroupManager.GetProfileAllowApprovalGroups(request.AccessStructure.Profiles_ID)>
		<cfset restrictOnModifyingProductGroupList = ValueList(qRestrictOnModifyingProductGroupList.Group_ID)>
	</cfif>

	<cfif programInfo.Restrict_On_Approval_Group>
		<cfset restrictOnProductGroup = 1>
		<cfset qRestrictOnProductGroupList = approvalGroupManager.getTemplateAllowApprovalGroups(programInfo.ProgramType_ID)>
		<cfset restrictOnProductGroupList = ValueList(qRestrictOnProductGroupList.Group_ID)>
		<cfif appSettings.getTemplateRestrictGroupLevel() eq 10>
			<cfif NOT isDefined("businessSegManager")>
				<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
			</cfif>
			<cfset restrictOnClassCodeUUIDList = restrictOnProductGroupList>
			<cfset restrictOnProductGroupList = businessSegManager.getClassCodeIDList(restrictOnProductGroupList) />
		</cfif>
	</cfif>

	<!--- IF EZ Button Setting is on the template --->
	<cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />

	<!---
	D28783: Release 7 EZ Button Max Rate
	Do not filter program product search tool based on ez template when it is set as max rate.
	Ezbutton is not for fixed price (AND form.rebateTypeSelected neq 1).
	 --->
	<cfif GetSettings.EZButton_On EQ 1 and url.EZTemplate EQ 0 and (GetSettings.Filter_EZButton_Products EQ 1) AND form.rebateTypeSelected neq 1>
		<cfset EzButton_Products = 1>
	<cfelse>
		<cfset EzButton_Products = 0>
	</cfif>

	<cfif EzButton_Products EQ 1>
    <cfif (GetSettings.isDominant EQ 1)>
      <cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />
    <cfelse>
      <cfset useLakebaseForqryGetLatestTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqryGetLatestTemplate>
	<cftry>
		<cfset qryGetLatestTemplate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"first_parent_id" = "eq.#GetSettings.First_Parent_ID#",
				"isdominant" = "eq.1",
				"deleted" = "eq.0",
				"order" = "programcontrol_panel_options_id.desc",
				"limit" = "1",
				"select" = "ez_contract_id"
			}), "ez_contract_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetLatestTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetLatestTemplate>
<cfquery name="qryGetLatestTemplate" datasource="#application.datasource#">
      SELECT TOP 1 EZ_Contract_ID
			FROM Program_Control_Panel_Options
			WHERE First_Parent_ID = #GetSettings.First_Parent_ID#
			and IsDominant =1
			and deleted = 0
			ORDER BY ProgramControl_Panel_Options_ID desc
      </cfquery>
</cfif>
      <cfset Latest_EZ_Contract_ID = qryGetLatestTemplate.EZ_Contract_ID />
  	</cfif>
  	<cfset EZButtonProgramProductList = ProgramProducts.getEZButtonProductList(Latest_EZ_Contract_ID,url.Discountype,url.component_id,url.isparent,0)/>
	  <cfset EZButton_ProductList = valuelist(EZButtonProgramProductList.BSA_Foodservice_Items_Master_ID)>

	</cfif>

	<!---
	      Dev Note 12344 Ben: if Product Filtering is on while using EZ Button
	      the getCategoryFiltersByProgram() Function fails. This is due to
	      EZ Button creating a dummy program and not populating the ProgramType_ID
	      field in the contract_main table
	--->
	<cfif url.EZTemplate neq 1>
	<!---if product category filter is on then display any product category filters--->
	<cfif isDefined("application.returned_customer_setting.product_category_filter") and application.returned_customer_setting.product_category_filter>
		<cfset lProductCategoryFilter = CreateObject("component", "components.products.Category.ProductCategory").getCategoryFiltersByProgram(FORM.DTPS_Program_ID) />
	 </cfif>
	</cfif>
</CFIF>

<cfif NOT isDefined("form.businessSegmentsOn") OR NOT isDefined("form.Business_Segment_ID")>
	<cfset userClassCodeInThisProductSearch = 0 />
<cfelse>
	<cfif form.businessSegmentsOn neq 1 OR form.Business_Segment_ID eq 0>
		<cfset userClassCodeInThisProductSearch = 0 />
	</cfif>
</cfif>
<cfparam name="form.Line_Of_Business_ID" default="NULL">
<cfparam name="FILTER_BUSINESS_SEGMENT_ID" default="0">
<cfset productGroupFilterBusinessSegmentId = 0 />

<cfif isDefined("programInfo") and programInfo.recordcount GT 0>
	<cfset form.Line_Of_Business_ID = programInfo.Line_Of_Business_ID>
</cfif>

<cfif form.businessSegmentsOn eq 1 and isDefined("form.Business_Segment_Id") AND FORM.Business_Segment_Id NEQ 0>

	<cfset ProductBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(FORM.Business_Segment_Id) />

	<CFSET FILTER_BUSINESS_SEGMENT_ID = ProductBSFilter.Product_BS_Filter>

	<cfset productGroupFilterBusinessSegmentId = ProductBSFilter.Product_Group_BS_Filter />

</cfif>


<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />

<!--- Before PG and Filter Functionality --->
<!--- <cfset qGetProductGroupAttributes = ProductGroupAttributeManager.getProductGroupAttributes(active=1) />  --->
<!--- After PG and Filter Functionality --->
  <cfset qGetProductGroupAttributesGroupTemplateAll = ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1,FirstParentID=URL.FirstParentID) />

<!--- START: D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012
		The URL.prgID will have a +ve value only when called from the programs page
		and from all the other places it will be only "0".  We will need to change
		this logic, if some other page does not need to have the PG displayed but
		still passes a prgID.
---->

<cfif (isDefined("URL.prgID") AND URL.prgID NEQ 0 AND
	   isDefined("URL.FirstParentID") AND URL.FirstParentID NEQ 0) >
	<cfset qGetProductGroupAttributesGroupTemplate = qGetProductGroupAttributesGroupTemplateAll />
<cfelse>
	<cfquery name="qGetProductGroupAttributesGroupTemplate" dbtype="query">
		SELECT
				*
		FROM
				qGetProductGroupAttributesGroupTemplateAll
		WHERE
				PG_Flag = 0 AND 
				Group_Level_ID NOT IN (19,10)
		ORDER BY
				List_Order
	</cfquery>
</cfif>
<!--- <cfdump var="#qGetProductGroupAttributesGroupTemplate#" output="c:\dump.log" /> --->
<!--- END: D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->

<!------ AllowProductGroupList ----->
<cfif Len(form.AllowProductGroupList) GT 0>
	<cfif isNumeric(form.AllowProductGroupLevelId) AND form.AllowProductGroupLevelId NEQ 0>
		<cfset ArrayAppend(arrayProductGroupSelection, ProductGroupAttributeManager.getProductGroupSelectionStruct(form.AllowProductGroupLevelId, form.AllowProductGroupList, 1)) />
	</cfif>
</cfif>

<!------ Make variables ready so that it can be used in the drop down queries ----->
<cfset arrayProductGroupSelectionLen = ArrayLen(arrayProductGroupSelection) />
<cfloop index="counter" from="1" to="#arrayProductGroupSelectionLen#">
	<cfset thisArrayProductGroupSelection = arrayProductGroupSelection[counter] />
	<cfset "restrictOnProductGroup_#thisArrayProductGroupSelection.productGroupType.groupLevelType#" = counter />
</cfloop>

</cfsilent>

<!--- If the user visits from "Manage_Divested_Items" page --->
<cfif (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "Manage_Divested_Items")>
  <cfset varSourceCaller = "Manage_Divested_Items" />
<!--- If the user visits from the "Add products" page in billback --->
<cfelseif (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "KnownProgramForm")>
	<cfset varSourceCaller = "KnownProgramForm" />
<cfelse>

		<!--- If "Search inactive products in programs" is ON --->
		<cfif appSettings.getSearchInactiveProductsInPrograms() OR (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "dataForm")>
					<!--- If the user visits from fixed price page --->
				<cfif (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "FixedComponents")>
					<cfset varSourceCaller = "FixedComponents" />
					<!--- If the user visits from growth page --->
				<cfelseif (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "compProductTierRates")>
					<cfset varSourceCaller = "compProductTierRates" />
					<!--- If the user visits from rebate page --->
				<cfelseif (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "dataForm")>
					<cfset varSourceCaller = "dataForm" />
					<!--- If the user visits from lump sum page --->
				<cfelseif (isDefined("URL.SourceCaller") AND URL.SourceCaller EQ "MyForm")>
					<cfset varSourceCaller = "MyForm" />
				<cfelse>
					<cfset varSourceCaller = "other" />
				</cfif>

		<cfelse>
			<cfset varSourceCaller = "other" />
		</cfif>

</cfif>

<!---<cfif isDefined("URL.SourceCaller") >
	<cfset varSourceCaller = URL.SourceCaller />
<cfelse>
	<cfset varSourceCaller = "other" />
</cfif>--->

<cfparam name="url.callback" default="">
<FORM ACTION="product_Select_V1.cfm?Discountype=<cfoutput>#url.Discountype#</cfoutput>&EZTemplate=<cfoutput>#url.EZTemplate#</cfoutput>&component_id=<cfoutput>#url.component_id#</cfoutput>&isparent=<cfoutput>#url.isparent#</cfoutput>&SourceCaller=<cfoutput>#varSourceCaller#&FirstParentID=#URL.FirstParentID#&prgID=#URL.prgID#&plannerId=#form.plannerId#&callback=#url.callback#</cfoutput>" METHOD="post" NAME="SearchForm" ID="SearchForm" ONKEYPRESS="if(event.keyCode == 13) doSearch()">
    <!--- 85971 :: this hidden element has information of all selected rows in array JSON format--->
<br>&nbsp;&nbsp;&nbsp;<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- <DIV ALIGN="center"> --->
<div id="div92a">
<FIELDSET STYLE="padding:5px; width:95%; border: 1px solid Blue;text-align:left;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Search Criteria</LEGEND>


<cfset maxColsPerRow = 4/>
<cfset currentColCount = 0/>

		<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" style="width:100%;table-layout:fixed;">
		<col width="25%">
		<col width="25%">
		<col width="25%">
		<col width="25%">
			<TR>
			<!------ ************************** Product Hierarchy ************************* ----->
			<cfif appSettings.getUseProductHierarchy()>
				<cfsilent>
				<cfset productGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
				<cfset restrictOnProductHierarchy = 0>
				<cfif restrictOnProductGroup>
				<cfif approvalGroupType.groupLevelType EQ 2>
					<cfset restrictOnProductHierarchy = 1>
				</cfif>
				</cfif>
				<cfset sExcludeLevelList = appSettings.getSearchProductHierarchyExcludeList() />
				<cfif restrictOnProductHierarchy>
					<cfset qGetProductHierarchy = productGroupDataManager.getHierarchyLevel(excludeLevelList=sExcludeLevelList,addParentName=0,getLevelNames=1,restrictOnProductHierarchy=restrictOnProductHierarchy,restrictOnProductHierarchyLevel=approvalGroupType.prodHierLevel,restrictOnProductHierarchyList=restrictOnProductGroupList) />
				<cfelse>
					<cfset qGetProductHierarchy = productGroupDataManager.getHierarchyLevel(excludeLevelList=sExcludeLevelList,addParentName=0,getLevelNames=1) />
				</cfif>
				<cfset qMaxLevel = productGroupDataManager.getDistinctHierarchyLevel(getMaxLevel=1)>
				<cfset maxLevel = qMaxLevel.Product_Hierarchy_Level>
				<cfset maxProductHierarchyLevel = maxLevel>
				<!------ If the approvcalGroup is hierarchy, get the last level ids ----->
				<cfif restrictOnProductHierarchy>
					<cfif approvalGroupType.prodHierLevel NEQ maxLevel>
						<cfset qGetProductHierarchyMaxLevel = productGroupDataManager.getHierarchyLevel(hierarchyLevel=maxLevel,addParentName=0,getLevelNames=0,restrictOnProductHierarchy=restrictOnProductHierarchy,restrictOnProductHierarchyLevel=approvalGroupType.prodHierLevel,restrictOnProductHierarchyList=restrictOnProductGroupList) />
						<cfset restrictOnProductGroupList = ValueList(qGetProductHierarchyMaxLevel.Product_Group_ID)>
					</cfif>
				</cfif>
				<cfset useLakebaseForqGetDistinctLevels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetproducthierarchy")>
<cfif useLakebaseForqGetDistinctLevels>
	<cftry>
		<cfset qGetDistinctLevels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetproducthierarchy", {
				"select" = "hierarchy_level"
			}), "hierarchy_level"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistinctLevels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistinctLevels>
<cfquery name="qGetDistinctLevels" dbtype="query">
					SELECT	DISTINCT Hierarchy_Level
					FROM	qGetProductHierarchy
				</cfquery>
</cfif>
				<cfset productHierarchyLevelList = ValueList(qGetDistinctLevels.Hierarchy_Level, ",") />
				</cfsilent>
				<!--- Dev Note: (48721) - Product hierarchy dropdown is already included in "product attributes" below in the code (If it is active). --->
				<!---<cfoutput query="qGetProductHierarchy" group="Hierarchy_Level">
					<TD NOWRAP ALIGN="left">
						<cfparam name="FORM.Product_Hierarchy_#Hierarchy_Level#" default="0">
						<B>#Group_Level_Name#</B><BR>
						<SELECT NAME="Product_Hierarchy_#trim(Hierarchy_Level)#">
							<OPTION VALUE="0">**All** #Group_Level_Name#</OPTION>
							<CFOUTPUT><OPTION VALUE="#Product_Group_ID#"<cfif Evaluate("FORM.Product_Hierarchy_#Hierarchy_Level#") EQ Product_Group_ID> SELECTED</cfif>>#Trim(Group_Level_Desc)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)>
					</TR>
					<TR>
					</cfif>
				</cfoutput>--->
			</cfif>
			<!------ ************************** Class Code ************************* ----->
			<cfif userClassCodeInThisProductSearch>
			<cfparam name="FORM.Search_Class_Code_ID" default="0">
			<cfif appSettings.getUseProductGroup5() and form.businessSegmentsOn>
				<cfquery name="qGetUserClassCodesForDropDown" dbtype="query">
					SELECT 	*
					FROM	qGetUserClassCodes
					<cfif appSettings.getTemplateRestrictGroupLevel() eq 10 AND restrictOnProductGroup EQ 1 AND IsDefined("restrictOnClassCodeUUIDList") AND Len(restrictOnClassCodeUUIDList) GT 0>
					WHERE	Class_Code_UUID IN (#ListQualify(restrictOnClassCodeUUIDList, "'")#)
					</cfif>
				</cfquery>
				<TD NOWRAP ALIGN="left">
					<cfoutput><B>Class Code</B><BR></cfoutput>
					<SELECT NAME="Search_Class_Code_ID"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
						<cfoutput><OPTION VALUE="0">**All** Class Codes</OPTION></cfoutput>
						<CFOUTPUT QUERY="qGetUserClassCodesForDropDown"><OPTION VALUE="#Class_Code_ID#"<cfif FORM.Search_Class_Code_ID EQ Class_Code_ID> SELECTED</cfif>>#Class_Code_Desc#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
			<cfset currentColCount = currentColCount + 1 />
			</cfif>
			</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>

			<cfquery name="GetLinesOfBiz" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
				SELECT *
				FROM Line_Of_Business WHERE Deleted = 0
				ORDER BY Line_Of_Business_Name
			</cfquery>


			<cfif 	application.returned_customer_setting.lob_search_switch EQ 1
				<!--- ProductGroupAttributeManager.getProductLevelSearchFilterOn(qGetProductGroupAttributes, 13) --->
            <!---   OR	   ProductGroupAttributeManager.getProductLevelSearchFilterOnGroupTemplate(qGetProductGroupAttributes=qGetProductGroupAttributesGroupTemplate, productGroupLevelType=13) --->
			><TD><!--- Line Of Biz --->
				<cfif application.returned_customer_setting.lob_search_switch NEQ application.returned_customer_setting.customer_setting_error_string>
				<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.lob_label_singular#</B></span><BR></cfoutput>

				<cfif Listlen(application.returned_customer_setting.Line_Business_Default) EQ 1>
					<CFQUERY NAME="getFoodserviceLOBID" dbtype="query">
						SELECT Line_Of_Business_ID
						FROM GetLinesOfBiz
						WHERE Line_Of_Business = '#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#'
					</CFQUERY>
					<cfparam name="FORM.Line_Of_Biz" default="#getFoodserviceLOBID.Line_Of_Business_ID#">
				<cfelse>
					<cfparam name="FORM.Line_Of_Biz" default="">
				</cfif>

				<SELECT NAME="Line_Of_Biz" id="Line_Of_Biz" style="width: 185px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
					<cfoutput><OPTION VALUE="0" <CFIF trim(GetLinesOfBiz.Line_Of_Business_ID) EQ 0>selected</CFIF>>**All** #application.returned_customer_setting.lob_label_plural#</OPTION></cfoutput>
					<CFOUTPUT QUERY="GetLinesOfBiz"><OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION></CFOUTPUT>
				</SELECT><cfset currentColCount = currentColCount + 1 />
				</cfif>
			</TD>
			<cfelse>
				<cfparam name="FORM.Line_Of_Biz" default="0">
			</cfif>

			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			<cfset currentColCount = 0 />
			</cfif>
			<!------ Display the drop down for all other active attributes ----->
			<!--- Dev Note: (48723): Group_Level_ID of 10 is "class code". "Class code" already has a dropdown above on this page. So, we do not need to show it twice.
			It would have been better to show this dropdown and hide the one on top, but search using the "class code" dropdown requires an int (class_code_ID) to be the
			dropdown value. The dropdown below uses a GUID ("Class_Code_UUID") instead, which generates an error, as the search expects "class_code_id".
			--->
			<cfset qGetOtherProductGroupAttributes = qGetProductGroupAttributesGroupTemplate />
			<!--- <cfquery name="qGetOtherProductGroupAttributes" dbtype="query">
				SELECT	*
				FROM	qGetProductGroupAttributesGroupTemplate
				WHERE	Group_Level_ID NOT IN (19,10)
				ORDER BY List_order
			</cfquery> --->
			<!---
			SELECT	*
				FROM
				-- qGetProductGroupAttributes
				qGetProductGroupAttributesGroupTemplate
				-- WHERE	Product_Group_Level_Type NOT IN (5,3,6,7,13)
				-- WHERE	Group_Level_ID NOT IN (3,5,6,7,13)
				WHERE	Group_Level_ID NOT IN (11,8,12,13,19)
			--->

		<!--- 	<cfloop query="qGetProductGroupAttributesGroupTemplate"> --->
    <!---
      Loop Through all the selected Product Group from the Group_Template table and display as drop down
      in Search Page. Anand Rao/06-Jan-2011
    --->
      <cfloop query="qGetOtherProductGroupAttributes">
			<cfif (qGetOtherProductGroupAttributes.Allow_In_Search EQ 1)>
      <!--- ProductGroupAttributeManager.getProductLevelSearchFilterOn(qGetProductGroupAttributes, Product_Group_Level_Type) --->
     <!--- ProductGroupAttributeManager.getProductLevelSearchFilterOnGroupTemplate(qGetProductGroupAttributes=qGetProductGroupAttributesGroupTemplate, productGroupLevelType=Group_Level_ID) AND  --->


			<!--- 	<cfset ProductAttributeDropDownName = "Product_Attribute_#Product_Group_Level_Type#" /> --->
      	<cfset ProductAttributeDropDownName = "Product_Attribute_#Group_Level_ID#" />
				<cfparam name="FORM.#ProductAttributeDropDownName#" default="0">

		<!---Brand=appSettings.getUseProductGroup1()=13; Q Brand=getUseProductGroup2()=11; Type Group=appSettings.getUseProductGroup3()=8; Type Code=getUseProductGroup4()=12;--->
        	<cfif qGetOtherProductGroupAttributes.Group_Level_ID eq 13 or qGetOtherProductGroupAttributes.Group_Level_ID eq 11 or qGetOtherProductGroupAttributes.Group_Level_ID eq 8 or qGetOtherProductGroupAttributes.Group_Level_ID eq 12 or qGetOtherProductGroupAttributes.Group_Level_ID eq 19>

		      <cfif 	(qGetOtherProductGroupAttributes.Group_Level_ID eq 13 and appSettings.getUseProductGroup1())
				or (qGetOtherProductGroupAttributes.Group_Level_ID eq 11 and appSettings.getUseProductGroup2())
				or (qGetOtherProductGroupAttributes.Group_Level_ID eq 8  and appSettings.getUseProductGroup3())
				or (qGetOtherProductGroupAttributes.Group_Level_ID eq 12 and appSettings.getUseProductGroup4())
 			>

			<TD>
			<cfmodule 	template="/Customtags/ProductGroupDropDown.cfm"
								groupLevelType = "#qGetOtherProductGroupAttributes.Group_Level_ID#"
								dropDownName = "#ProductAttributeDropDownName#"
								selectedValue = "#Evaluate("FORM.#ProductAttributeDropDownName#")#"
								productGroupFilterBusinessSegmentId = "#productGroupFilterBusinessSegmentId#"
								restrictOnProductGroup = "#restrictOnProductGroup#"
								approvalGroupLevelTypeVar = "approvalGroupType.groupLevelType"
								CACHEDWITHIN="#cacheSpan#"
                						FirstParentID = "#URL.FirstParentID#"
                						groupLevelID = "#qGetOtherProductGroupAttributes.Group_Level_ID#"
                						programID ="#URL.prgID#"
								/>
			</TD>
				<cfset currentColCount = currentColCount + 1 />
				<cfif isNextRow(maxColsPerRow, currentColCount)>
				</TR>
				<TR>
				<cfset currentColCount = 0 />
				</cfif>

			</cfif>

		<cfelse>
		<TD>
					<cfmodule 	template="/Customtags/ProductGroupDropDown.cfm"
								groupLevelType = "#qGetOtherProductGroupAttributes.Group_Level_ID#"
								dropDownName = "#ProductAttributeDropDownName#"
								selectedValue = "#Evaluate("FORM.#ProductAttributeDropDownName#")#"
								productGroupFilterBusinessSegmentId = "#productGroupFilterBusinessSegmentId#"
								restrictOnProductGroup = "#restrictOnProductGroup#"
								approvalGroupLevelTypeVar = "approvalGroupType.groupLevelType"
								CACHEDWITHIN="#cacheSpan#"
                FirstParentID = "#URL.FirstParentID#"
                groupLevelID = "#qGetOtherProductGroupAttributes.Group_Level_ID#"
                programID ="#URL.prgID#"
								/>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				<cfif isNextRow(maxColsPerRow, currentColCount)>
				</TR>
				<TR>
				<cfset currentColCount = 0 />
				</cfif>
		</cfif>
			</cfif>
			</cfloop>

	<cfif application.returned_customer_setting.upc_search_switch NEQ application.returned_customer_setting.customer_setting_error_string>
		<cfif application.returned_customer_setting.upc_search_switch EQ 1>
		<TD NOWRAP ALIGN="left">
			<B><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput> #</B>
			<cfif appSettings.get_Setting('Display_Item_No') eq ''>
				<cfoutput>
				<A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=Product&passForm=SearchForm&programID=#url.prgID#',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >
					#application.util.string.actionLinkFormat('create list')#
				</A>
				</cfoutput>
			</cfif>
			<BR>
			<input TYPE="Text" NAME="upc_number" VALUE="<CFOUTPUT>#FORM.upc_number#</CFOUTPUT>" STYLE="WIDTH:98%"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
		</TD>
		<cfset currentColCount = currentColCount + 1 />
		</cfif>
	</cfif>
			<!------ Special for description field, it needs to 2 columns ----->
			<cfif NOT isNextRow(maxColsPerRow, currentColCount) AND isNextRow(maxColsPerRow, currentColCount+1)><TD>&nbsp;</TD>
			<cfset currentColCount = currentColCount + 1 />
			</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			<cfset currentColCount = 0 />
			</TR>
			<TR>
			</cfif>

<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>
				<cfparam name="FORM.Rebate_Type_Search_ID" default="0">
				<cfquery name="getRebateTypes" datasource="#Application.Datasource#" CACHEDWITHIN="#cacheSpan#">
					SELECT  C.Contract_Main_ID,
							PCPO.Discount_Fixed_Prices,
					        PCPO.Discount_Rebates,
					        PCPO.Discount_Growth,
					        PCPO.Discount_Lump_Sums,
					        PCPO.Discount_Formula_Pricing,
					        PCPO.Generic_Type
					FROM    dbo.Contract_Main C
					INNER JOIN dbo.Program_Control_Panel_Options  PCPO ON
					       C.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID AND
					       PCPO.Deleted = 0
					WHERE     (C.Contract_Main_ID = '#FORM.DTPS_Program_ID#') AND C.Deleted=0
				</cfquery>
</CFIF>

<CFIF SHOW_INVOICE_FILTER EQ 1>
				<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
				<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
				<SCRIPT LANGUAGE="JavaScript">
					//theObj is Input object instead of a combo one
 					function default_Invoice_Days(thisObj, shiptoObj, bObjType)
					{
						var bDisable = true;
						var shiptoVal = trim(shiptoObj.value);
						if(bObjType == 1)
						{
							if(thisObj.value != "")
							{
								shiptoObj.value = "";
							}
						}
						else
						{
							if(shiptoVal != "")
							{
								//thisObj.selectedIndex = 0;
								thisObj.value = "";
							}
						}

						if(thisObj.value != "")
						{
							bDisable = false;
						}
						if(shiptoVal != "")
						{
							bDisable = false;
						}
						/*
							disableDiv("SP_Invoice_Days", bDisable, false);
						*/
					}

					/*function searchPrograms() {
						searchResults = window.showModalDialog('/common_files/contracts/program_search_for_component.cfm','','dialogHeight: 600px; dialogWidth: 940px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;');
						if(searchResults != 0 && searchResults.length != 0) {
							document.all.LoadProductsFromThesePrograms.value = searchResults;
							doSearch();
						}
					}*/

				</SCRIPT>

				<cfparam name="FORM.Distributor" default="0">
				<cfparam name="FORM.Distributor_Name" default="">
				<cfparam name="Selected_Distributor" default="">

				<!--- <cfset currentColCount = currentColCount + 2 />		 --->
		</CFIF>

		<cfloop query="ProdSearchSettings">
			<cfswitch expression = "#ProdSearchSettings.Field_Name#">

				<cfcase value = "Status">

					<TD><!--- Active/Inactive --->
						<span ID="searchItemLabel"><B>Status</B></span><BR>
						<cfparam name="FORM.Product_Status" default="A">
					<SELECT NAME="Product_Status" id="Product_Status"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
						<option VALUE="A" <CFIF FORM.Product_Status EQ "A">SELECTED</CFIF>>Active</option>
            <!---
                 Dev Notes: Anand Rao/22376/22-Feb-10
                 Rework on 21919, divested items
            --->
					<!--- Dev Notes: Milan 22306
								The user should be able to search for inactive products from the program.
								FixedComponents = From fixed price page,compProductTierRates = From Growth Page,
								dataForm = From rebate page, MyForm = From Lumpsum page.
								Milan 23330 - KnownProgramForm = From "Add products" page in billback
					--->
					  <!--26199 allows inactive option based on user profile setting -->
            	<cfif (isdefined("URL.SourceCaller") AND (URL.SourceCaller EQ "Manage_Divested_Items" OR URL.SourceCaller EQ "KnownProgramForm" OR (Get_Profile_Settings.Search_Inactive_Products_Programs eq 1 AND (URL.SourceCaller EQ "FixedComponents"  OR URL.SourceCaller EQ "compProductTierRates"  OR URL.SourceCaller EQ "dataForm"  OR URL.SourceCaller EQ "MyForm"))))
						OR (isDefined("Form.FlexAppName") AND Form.FlexAppName EQ "AliasMain")>
              		<option VALUE="N" <CFIF FORM.Product_Status EQ "N">SELECTED</CFIF>>In-Active</option>
            	</cfif>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value="Product Number">
				<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
				<TD NOWRAP ALIGN="left">
					<B><cfoutput>#application.returned_customer_setting.item_label#</cfoutput> #</B>&nbsp;
						<cfoutput>
						<A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=Product&passForm=SearchForm&programID=#url.prgID#',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >
							#application.util.string.actionLinkFormat('create list')#
						</A>
						</cfoutput>
					<BR>
					<input TYPE="Text" NAME="item_number" VALUE="<CFOUTPUT>#FORM.item_number#</CFOUTPUT>" STYLE="WIDTH:180px"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
			  	</TD>
				<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>

			<cfcase value="Description">
				<cfif NOT isNextRow(maxColsPerRow, currentColCount) AND isNextRow(maxColsPerRow, currentColCount+1)><TD>&nbsp;</TD>
					<cfset currentColCount = currentColCount + 1 />
				</cfif>
				<cfif isNextRow(maxColsPerRow, currentColCount)>
					<cfset currentColCount = 0 />
					</TR>
					<TR>
				</cfif>
				<TD COLSPAN="2" NOWRAP>
					<B>Description</B><BR>
					<INPUT TYPE="Text" NAME="description_string" STYLE="width:99%;" VALUE="<CFOUTPUT>#FORM.description_string#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>

			<cfcase value="Search Product From">
				<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>
				<TD valign="bottom">
					<B>Search <cfoutput>#application.returned_customer_setting.item_label#</cfoutput> From	</B> <span title="Use this feature to retrieve a list of products selected in other discount types." style="cursor:pointer;color:#0000FF;font-size:12px;;font-weight:bold;">?</span><BR>
					<!---  Dev Note: drachala; D28446: Change label for 'Rebate' in Program product search  START
                            What  I did: Added #Application.RebateLabel# instead of rebate and #Application.LumpsumLabel# instead of Lum Sum --->
					<select name="Rebate_Type_Search_ID" id="Rebate_Type_Search_ID" <cfif Not appSettings.getDisableGroupProductSearchINproductSearch() and session.rebateType NEQ UCase("compProductTierRates")>onChange="javascript:if (document.all.Rebate_Type_Search_ID.selectedIndex > 0) {document.all.Group_Rebate_Type_Search_ID.disabled='true';document.all.Group_Rebate_Type_Search_ID.style.backgroundColor ='E9E9E9'} else {document.all.Group_Rebate_Type_Search_ID.disabled='';document.all.Group_Rebate_Type_Search_ID.style.backgroundColor ='FFFFFF'}"</cfif>  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
						<OPTION value="0" <CFIF FORM.Rebate_Type_Search_ID EQ 0 > SELECTED</CFIF>>Default Search</OPTION>
						<CFIF getRebateTypes.Recordcount GT 0>
							<CFIF getRebateTypes.Discount_Fixed_Prices 		EQ 1><OPTION value="1" <CFIF FORM.Rebate_Type_Search_ID EQ 1> SELECTED</CFIF>>Fixed Price		</OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Rebates 			EQ 1><OPTION value="2" <CFIF FORM.Rebate_Type_Search_ID EQ 2> SELECTED</CFIF>><cfoutput>#Application.RebateLabel#</cfoutput></OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Lump_Sums 		EQ 1><OPTION value="3" <CFIF FORM.Rebate_Type_Search_ID EQ 3> SELECTED</CFIF>><cfoutput>#Application.LumpsumLabel#</cfoutput></OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Growth 			EQ 1><OPTION value="4" <CFIF FORM.Rebate_Type_Search_ID EQ 4> SELECTED</CFIF>>Growth			</OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Formula_Pricing 	EQ 1><OPTION value="5" <CFIF FORM.Rebate_Type_Search_ID EQ 5> SELECTED</CFIF>>Formula Pricing	</OPTION></CFIF>
							<CFIF getRebateTypes.generic_type IS	"Bid Request"><OPTION value="10" <CFIF FORM.Rebate_Type_Search_ID EQ 10> SELECTED</CFIF>>Bid Request</OPTION></CFIF>
						</CFIF>
					</SELECT>
					<!--- End Dev Note: drachala; D28446: Change label for 'Rebate' in Program product search  --->
			  </TD>
				<cfinclude template="_incTrSeparator.cfm" />
				</CFIF>
			</cfcase>
			<cfcase value="Search Groups From">
				<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>
					<cfif Not appSettings.getDisableGroupProductSearchINproductSearch() and session.rebateType NEQ UCase("compProductTierRates")>
					<TD valign="bottom">
						<B>Search Groups From</B><BR>
						<select name="Group_Rebate_Type_Search_ID" id="Group_Rebate_Type_Search_ID" <cfif isDefined("session.rebateType") and session.rebateType EQ UCase("FixedComponents")>style="background-color:E9E9E9;" disabled</cfif>  onChange="javascript:if (document.all.Group_Rebate_Type_Search_ID.selectedIndex > 0) {document.all.Rebate_Type_Search_ID.disabled='true';document.all.Rebate_Type_Search_ID.style.backgroundColor ='E9E9E9'} else {document.all.Rebate_Type_Search_ID.disabled='';document.all.Rebate_Type_Search_ID.style.backgroundColor ='FFFFFF'}"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();}">
							<OPTION value="0" <CFIF FORM.Group_Rebate_Type_Search_ID EQ 0> SELECTED</CFIF>>Default Search</OPTION>
							<CFIF getRebateTypes.Recordcount GT 0>
								<CFIF getRebateTypes.Discount_Rebates 			EQ 1><OPTION value="2" <CFIF FORM.Group_Rebate_Type_Search_ID EQ 2> SELECTED</CFIF>>Rebate			</OPTION></CFIF>
								<CFIF getRebateTypes.Discount_Lump_Sums 		EQ 1><OPTION value="3" <CFIF FORM.Group_Rebate_Type_Search_ID EQ 3> SELECTED</CFIF>>Lump Sum			</OPTION></CFIF>
								<!---<CFIF getRebateTypes.Discount_Growth 			EQ 1><OPTION value="4" <CFIF FORM.Group_Rebate_Type_Search_ID EQ 4> SELECTED</CFIF>>Growth			</OPTION></CFIF>--->						</CFIF>
						</SELECT>
					</TD>
					<cfset session.Group_Rebate_Type_Search_ID = FORM.Group_Rebate_Type_Search_ID >
					<cfset currentColCount = currentColCount + 1 />
				<cfelse>
					<input type="hidden" name="Group_Rebate_Type_Search_ID" value="0">
				</cfif>
			</CFIF>
			<cfif isNextRow(maxColsPerRow, currentColCount+1) OR isNextRow(maxColsPerRow, currentColCount)>
			<cfset currentColCount = 0 />
			</TR>
			<TR>
			</cfif>
		</cfcase>
		<cfcase value="Invoices(past N days)">
			<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>
			<!------ Special for links TD, it needs to 2 columns ----->
			<cfif NOT isNextRow(maxColsPerRow, currentColCount) AND isNextRow(maxColsPerRow, currentColCount+1)><TD>&nbsp;</TD>
			<cfset currentColCount = currentColCount + 1 />
			</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)><cfset currentColCount = 0 />
			</TR>
				<td></td><td></td>
			<TR>
			</cfif>
			<cfif Form.ParentFormname EQ "PriceProtection">
				<TD colspan="2"></TD>
			<cfelse>
				<cfif getDistributors.recordCount>
					<TD colspan="1">
						<br><B>Invoices (past <cfoutput>#appSettings.getNumberOfDaysForMiniItemMaster()#</cfoutput> days):</B> &nbsp;<BR>
						<label><input name="includeCustomersInProgram" type="checkbox" value="1" <cfif form.includeCustomersInProgram>checked</cfif>> <b>Customers selected in this program</b></label>
					</TD>
				</cfif>
			</cfif>
			</CFIF>
		</cfcase>
	</cfswitch>
</cfloop>
        <cfif appSettings.get_Setting('custom_rfp_process') neq '1'>
            <input type="hidden" name="include_companion" value="0">
        <cfelse>
            <!--- ~~~~~~~~~~~~ Huhtamaki RFP includes additional companion items feature ~~~~~~~~~~~~~ --->
            <cfset currentColCount = currentColCount + 1>
            <cfif isNextRow(maxColsPerRow, currentColCount)>
                <cfset currentColCount = 0>
                </TR><TR>
            </cfif>
            <td><br>
                <b>Companion Items</b><br>
                <label><input type="checkbox" value="1" name="include_companion" <cfif form.include_companion eq '1'>checked=checked</cfif>> <b>Include Companion Items in Search</b></label>
            </td>
        </cfif>
		</tr>
		<tr>
				<TD colspan="4" align="right" id="td92a">
					<a href="##" onClick="document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();"> <cfoutput>#application.util.string.actionLinkFormat2( "search " & lcase(application.returned_customer_setting.item_label) & "s" )#</cfoutput> </a>
					<a href="##" onClick="javascript: reset_Form_Fields();"> <cfoutput>#application.util.string.actionLinkFormat2( "reset" )#</cfoutput> </a>
					<!---<cfif appSettings.getProductSearchGetProductByProgramOn() is not 0>
						<a href="##" onClick="searchPrograms()"> <cfoutput>#application.util.string.actionLinkFormat2( "get products by program" )#</cfoutput> </a>
					</cfif>
					--->
				</TD>
			</TR>
			<!---if business segements are on then display--->
			<cfif form.businessSegmentsOn eq 1>
			<tr>
				<td colspan="100%" class="notranslate"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:&nbsp;&nbsp;<b><cfoutput>#Bus_Segment_Desc#</cfoutput></b></td>
			</tr>
			</cfif>

			<!--- BJF D11212 Distributor Product Integrity --->
					<cfset RestrictByRule = 0>
					<cfset Rule_Name = "">
					<cfif appsettings.getDistributor_Product_Integrity_On() IS 1 AND len(trim(getSettings.Distributor_Product_Integrity_Rule_ID)) GT 0>
						<cfset useLakebaseForGetIntegrityRuleType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
						<cfif useLakebaseForGetIntegrityRuleType>
							<cftry>
								<cfset GetIntegrityRuleType = application.oLakebase.toQuery(
									application.oLakebase.selectRows("distributor_product_integrity_rule", { "select" = "inclusive_restriction,rule_name", "distributor_product_integrity_rule_id" = "eq.#getSettings.Distributor_Product_Integrity_Rule_ID#" })
								)>
								<cfcatch type="any">
									<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
									<cfset useLakebaseForGetIntegrityRuleType = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForGetIntegrityRuleType>
						<cfquery name="GetIntegrityRuleType" datasource="#application.datasource#">
						SELECT Inclusive_Restriction, Rule_Name
						FROM Distributor_Product_Integrity_Rule
						WHERE Distributor_Product_Integrity_Rule_ID = #getSettings.Distributor_Product_Integrity_Rule_ID#
						</cfquery>
						</cfif>
						<!--- You only restrict the search if the rule is inclusive, otherwise your just pick it up on RFA --->
						<cfif GetIntegrityRuleType.Inclusive_Restriction EQ 1>
							<cfset RestrictByRule = 1>
							<cfset Rule_Name = GetIntegrityRuleType.Rule_Name>
						</cfif>
					</cfif>
					<cfif RestrictByRule IS 1>
					<tr><td colspan="100%">
					<font color="red" size="-2">* The results returned are modified by the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput>/product integrity rule <cfoutput>#Rule_Name#</cfoutput></font>
					</td></tr>
					</cfif>

		</TABLE>
</FIELDSET>
</DIV>

<CFIF FORM.FirstTimeLoading EQ "FALSE">
	<div id="div92b">
		<a href="##" onclick="javascript: finishedSearching()"> <cfoutput>#application.util.string.actionLinkFormat2( "save" )#</cfoutput> </a>
	</div>
</CFIF>

<!------ Build Header List ----->
<CFSET showHideColumnsSetting()>

<!------ Type Group ----->
<cfset RemoveTypeGroup = 1>
<cfif application.returned_customer_setting.type_group_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_group_show_column EQ 1><cfif ProdResults_DisplayTypeGroup eq 1><cfset RemoveTypeGroup = 0></cfif></cfif></cfif>
<cfif appSettings.getUseProductGroup3() NEQ 1>
	<cfset RemoveTypeGroup = 1>
</cfif>
<!------ Type Code ----->
<cfset RemoveTypeCode = 1>
<cfif application.returned_customer_setting.type_code_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_code_show_column EQ 1><cfif ProdResults_DisplayTypeCode eq 1><cfset RemoveTypeCode = 0></cfif></cfif></cfif>
<cfif appSettings.getUseProductGroup4() NEQ 1>
	<cfset RemoveTypeCode = 1>
</cfif>

<!------ UPC ----->
<cfset RemoveUPC = 1>

<cfif application.returned_customer_setting.UPC_Switch NEQ application.returned_customer_setting.customer_setting_error_string>
	<cfif application.returned_customer_setting.UPC_Switch EQ 1>
		<cfif ProdResults_DisplayUPC eq 1>
			<cfset RemoveUPC = 0>
		</cfif>
	</cfif>
</cfif>

<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
	<CFSET HeaderNameList = "#application.returned_customer_setting.item_label#:Item">
<cfelse>
	<CFSET HeaderNameList = "">
</cfif>

<cfif RemoveUPC EQ 0>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.upc_label#:UPC", ",")>
</cfif>

<cfset HeaderNameList = ListAppend(HeaderNameList, "Description:Description", ",")>

<cfif RemoveTypeGroup EQ 0>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.type_group_label_singular#:Type_Group_Desc", ",")>
</cfif>

<cfif RemoveTypeCode EQ 0>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.type_code_label_singular#:Type_Code_Desc", ",")>
</cfif>

<cfif appSettings.getUseProductGroup1() AND ProdResults_DisplayBrand>
<!--- 	<cfset sBrandLabel = ProductGroupAttributeManager.getProductGroupLabelFromQuery(groupLevelId = 13, qAllProductGroupAttributes = qGetProductGroupAttributes) /> --->
	<cfset sBrandLabel = ProductGroupAttributeManager.getProductGroupLabelFromQuery(groupLevelId = 13, qAllProductGroupAttributes = qGetProductGroupAttributesGroupTemplate) />
	<cfset HeaderNameList = ListAppend(HeaderNameList, "#sBrandLabel#:Brand", ",")>
</cfif>
<cfif appSettings.getUseProductHierarchy() AND ProdResults_DisplayHierarchy>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "Hierarchy:Product_Hierarchy_Name", ",")>
</cfif>
<cfif userClassCodeInThisProductSearch>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "Class Code", ",")>
</cfif>

<cfif isBusinessSegEnabledForProduct AND ProdResults_DisplayBusinessSegment>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "#appsettings.Business_Segment_Label#", ",")>
</cfif>

<cfparam name="FORM.sort_by" default="#Trim(ListLast(ListFirst(HeaderNameList), ":"))#">
<cfparam name="FORM.sort_Order" default="ASC">

<cfoutput>
<INPUT type="Hidden" name="sort_by" id="sort_by" value="#FORM.sort_by#">
<INPUT type="Hidden" name="sort_Order" id="sort_Order" value="#FORM.sort_Order#">
</cfoutput>

<cfsilent>
<cfset useLakebaseForgetLOBCharacter = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getlinesofbiz")>
<cfif useLakebaseForgetLOBCharacter>
	<cftry>
		<cfset getLOBCharacter = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getlinesofbiz", {
				"line_of_business_id" = "eq.#FORM.Line_Of_Biz#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetLOBCharacter = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetLOBCharacter>
<CFQUERY NAME="getLOBCharacter" DBTYPE="query">
	SELECT *
	FROM GetLinesOfBiz
	WHERE Line_Of_Business_ID = '#FORM.Line_Of_Biz#' AND Deleted = 0
</CFQUERY>
</cfif>

<CFQUERY NAME="getCategories" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	SELECT Category_ID
	FROM Category
	WHERE Category IN (#ListQualify(application.returned_customer_setting.Category_List, "'", ",")#) AND Deleted = 0
</CFQUERY>

<cfset categoryList = listqualify(valuelist(getCategories.Category_ID), "'", ",")>

<!---add the filter by category logic if it's turned on--->
<cfif isDefined("application.returned_customer_setting.product_category_filter") and application.returned_customer_setting.product_category_filter>

	<cfif isDefined("lProductCategoryFilter") and trim(lProductCategoryFilter) neq "">

		<cfset categoryList = listqualify(lProductCategoryFilter, "'", ",")>

	</cfif>

</cfif>

<CFIF FORM.FirstTimeLoading EQ "FALSE">

	<cfset FORM.Item_Number = trim(replace(FORM.Item_Number, "'", "''", "all"))>
	<cfset FORM.Description_String = trim(replace(FORM.Description_String, "'", "''", "all"))>
	<cfif isdefined("form.LoadProductsFromThesePrograms")>
		<cfif listlen(form.LoadProductsFromThesePrograms) GT 0 AND form.LoadProductsFromThesePrograms NEQ 0>
			<CFSET FORM.Program_ID = form.LoadProductsFromThesePrograms>
			<CFSET FORM.Type_Group_Desc_ID = 0>
			<CFSET FORM.Type_Code_Desc_ID = 0>
			<CFSET FORM.Q_Brand_ID = 0>
			<CFSET FORM.Line_Of_Biz = 0>
			<CFSET FORM.Brand_ID = 0>
			<CFSET FORM.Line_Of_Biz = 0>
			<CFSET FORM.Product_Status = 0>
			<CFSET FORM.Description_String = "">
			<CFSET FORM.item_number = "">
			<CFSET FORM.upc_number = "">
			<CFSET categoryList = "">
			<CFSET SHOW_INVOICE_FILTER = 0>
			<CFSET FORM.Rebate_Type_Search_ID = 0>
			<CFSET form.Only_Show_Products_From_These_Groups = 0>
			<CFSET getLOBCharacter = QueryNew("Line_Of_Business")>
			<CFSET form.passed_form = "">
		</cfif>
	</cfif>

	<!---TSF - Label 11162: If customers selected in this program was seleted then set the distributor list to customers in the program--->
	<cfif form.includeCustomersInProgram>
		<!---get customer for this program--->
			<!--- D41199  ::  Prod Event 2254--->
		<cfif IsDefined("getRebateTypes") AND getRebateTypes.Generic_Type IS NOT "Brokerage" >
			<cfquery name="qGetCustomers" datasource="#application.datasource#">
				SELECT	DISTINCT(BSA_Foodservice_Customers_ID)
				FROM	Contract_Distributors
				WHERE	Deleted = 0
				AND		Contract_Main_ID = <cfqueryparam value="#form.DTPS_Program_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qGetCustomers" datasource="#application.datasource#">
				SELECT	DISTINCT(BSA_Foodservice_Customers_ID)
				FROM	Contract_Brokers CB
				INNER JOIN BSA_FoodService_Customers CM on CM.BSA_FoodService_Brokers_ID = CB.BSA_FoodService_Brokers_ID
				WHERE	CB.Deleted = 0
				AND		Contract_Main_ID = <cfqueryparam value="#form.DTPS_Program_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif> <!--- Brokerage --->
		<cfset form.Distributor_List = ValueList(qGetCustomers.BSA_Foodservice_Customers_ID) />
		<cfif not len(trim(form.Distributor_List))>
			<cfset form.Distributor_List = "00000000-0000-0000-0000-000000000000" />
		</cfif>
	<cfelse>
		<cfset form.Distributor_List = "" />
	</cfif>
	<cfset stStruct = Form>
	<cfset stStruct.appSettings = appSettings>
	<!---
		Dev Notes: D27225:EZ Button Changes/Anand Rao
		Added the EZTemplate and Business_Segment_ID_List in the stStruct structure
		so that the productManager can filter the results based on the Business_Segment_IDs.
	--->
	<cfset stStruct.EzTemplate = URL.EZTemplate />
	<cfif (isDefined("qTemplateBusinessSegments") AND qTemplateBusinessSegments.RecordCount GTE 1)>
		<cfset stStruct.Business_Segment_ID_List = ValueList(qTemplateBusinessSegments.Business_Segment_ID) />
	</cfif>

	<cfif appSettings.getUseProductHierarchy()>
		<cfset stStruct.productHierarchyLevelList = productHierarchyLevelList>
		<cfset stStruct.maxProductHierarchyLevel = maxProductHierarchyLevel>
	</cfif>
	<cfif restrictOnProductGroup>
		<cfset stStruct.restrictOnProductGroup = restrictOnProductGroup>
		<cfset stStruct.restrictOnProductGroupList = restrictOnProductGroupList>
		<cfset stStruct.approvalGroupType = approvalGroupType>
	</cfif>
	<cfif restrictOnProfileProductGroup>
		<cfset stStruct.restrictOnProfileProductGroup = restrictOnProfileProductGroup>
		<cfset stStruct.restrictOnModifyingProductGroupList = restrictOnModifyingProductGroupList>
		<cfset stStruct.approvalGroupType = approvalGroupType>
	</cfif>
	<cfset stStruct.Line_Of_Business_ID 	= Form.Line_Of_Business_ID>
	<cfset stStruct.List_Of_Rebate_Product_ID = "">
	<cfif IsDefined("Form.Rebate_Type_Search_ID") AND Form.Rebate_Type_Search_ID NEQ 0>
		<!--- add product select by rebate type --->
		<cfquery name="getRateTypeProducts" datasource="#Application.Datasource#">
			SELECT     BSA_Foodservice_Items_Master_ID, Product_Type_ID, Contract_Main_ID
			FROM         dbo.Contract_Products
			WHERE     (Deleted = 0) AND (Product_Type_ID = '#FORM.Rebate_Type_Search_ID#') AND (Contract_Main_ID = '#FORM.DTPS_Program_ID#')
		</cfquery>
		<cfset stStruct.List_Of_Rebate_Product_ID = ListQualify(ValueList(getRateTypeProducts.BSA_Foodservice_Items_Master_ID), "'")>
	</cfif>
	<cfset stStruct.UserClassCodes = UserClassCodes>
	<cfset stStruct.categoryList = categoryList />
	<cfset stStruct.exclude_sig_products = getsettings.exclude_sig_products />
	<cfset stStruct.SHOW_INVOICE_FILTER = SHOW_INVOICE_FILTER>
	<cfset stStruct.operatingGroupProductGroupFilter = arrayProductGroupSelection>
	<!--- <cfset stStruct.qGetProductGroupAttributes = qGetOtherProductGroupAttributes> --->

 	<!---<cfset stStruct.qGetProductGroupAttributesGroupTemplate = qGetOtherProductGroupAttributes>--->
	<cfset stStruct.qGetProductGroupAttributesGroupTemplate = qGetProductGroupAttributesGroupTemplate>
	<cfset stStruct.FirstParentID = URL.FirstParentID>
	<cfset stStruct.EZButtonProductList = EZButton_ProductList />
	<cfset stStruct.Filter_EZButton_Products = GetSettings.Filter_EZButton_Products/>
	<cfset stStruct.EZButton_On = EzButton_Products />
    <cfset stStruct.plannerId = plannerId />
	<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
	<cfset searchProducts = productManager.search(search = stStruct, useCache = 1)>
<CFELSE>
	<CFSET SEARCHPRODUCTS = QueryNew("Item")>
</CFIF>
</cfsilent>
<!--- <DIV ALIGN="center"> --->
<div id="div92c">
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<div class="customContainer" style="display:none;"></div>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->
<FIELDSET STYLE="padding:8px; width:95%; border: 1px solid Blue;text-align:left;">
<cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF searchProducts.recordcount EQ 1>is <CFELSE>are</CFIF> #searchProducts.recordcount# <CFIF searchProducts.recordcount EQ 1>#lCase(application.returned_customer_setting.item_label)#<CFELSE>#lCase(application.returned_customer_setting.item_label)#s</CFIF> that <CFIF searchProducts.recordcount EQ 1>matched<CFELSE>match</CFIF> the supplied criteria</LEGEND></cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>

<cfloop list="#Form.FinalUPCList#" index="item_list" >
<cfset item_list = #item_list# >
</cfloop>
<!------------------------------ Get all list - exclude list -------------------------------------->

<CFIF searchProducts.recordCount GT 0 AND ListLen(form.ProductListToExcludeFromSelecting) GT 0>
	<cfquery name="excludeProducts" dbtype="query">
	SELECT *
	FROM searchProducts
	WHERE BSA_Foodservice_Items_Master_ID NOT IN (#ListQualify(form.ProductListToExcludeFromSelecting, "'")#)
	</cfquery>
	<CFSET allList=ValueList(excludeProducts.BSA_Foodservice_Items_Master_ID)>
<CFELSEIF searchProducts.recordCount GT 0>
	<CFSET allList=ValueList(searchProducts.BSA_Foodservice_Items_Master_ID)>
<CFELSE>
	<CFSET allList="">
</CFIF>

<CFIF FORM.finishedselectingproducts EQ 1>
<CFOUTPUT>
	<cfif FORM.PARENTFORMNAME EQ 'flex'>
		<!--- implement call to externalinterface --->
		<script>
			// This function returns the appropriate reference,
			// depending on the browser.
			function getFlexApp(appName)
			{
			  if (navigator.appName.indexOf ("Microsoft") !=-1)
			  {
			    return opener.window[appName];
			  }
			  else
			  {
			    return opener.document[appName];
			  }
			}
			function saveItem()
			{
			  getFlexApp('#FORM.FlexAppName#').saveItem('#form.FinalUPCList#');
			}
			saveItem();
			window.close();
		</script>
	<cfelse>
	<cfif PageSource IS "AliasItemSearch">
	<script>
		window.opener.getItemInfo('#form.FinalUPCList#',1,1);
		window.close();
	</script>
	<cfelse>
        <!--- called from ag-grid may not have these form elements --->
    <script>
        <cfif len(form.parentFormName) and len(form.Return_Value_Field_Name)>
			/******* Set product list *******/
			<cfif FORM.Importallflag EQ 1>
				<!--- compare all list with finalupclist, append those who are not in the all list but in the finalupclist --->
				<CFLOOP INDEX="ListItem" LIST="#allList#" DELIMITERS=",">
					<CFIF ListFindNoCase(FORM.FinalUPCList, ListItem, ",") EQ 0>
						<CFSET FORM.FinalUPCList = listappend(FORM.FinalUPCList, ListItem, ",")>
					</CFIF>
				</CFLOOP>
				opener.document.all.#Form.ParentFormname#.#form.Return_Value_Field_Name#.value = '#FORM.FinalUPCList#'; <!--- allList --->
			<cfelse>
				opener.document.all.#Form.ParentFormname#.#form.Return_Value_Field_Name#.value = '#Form.FinalUPCList#';
			</cfif>
			<!---77408 Product Group sequencing START--->
			<cfif len(form.Return_Value_Group_Field_Name)>
				opener.document.all.#Form.ParentFormname#.#form.Return_Value_Group_Field_Name#.value = 9;
				opener.document.all.#Form.ParentFormname#.Product_List.value = '#Form.FinalUPCList#';
			</cfif>
			<!---77408 Product Group sequencing END--->
			/******* Set sort by *******/
			if(opener.document.all.#Form.ParentFormname#.Sort_By)
			{
				opener.document.all.#Form.ParentFormname#.Sort_By.value = '#Form.Sort_By#';
			}
			/******* Handle for allownavigate *******/
			if(#form.SudmitFormViaSubmitButton# == 0)
			{
				<cfif appSettings.getAllowNavigate()>
				if(opener.document.all.#Form.ParentFormname#.navigate)
				{
					<cfset listcompared1 = ListCompare(Form.FinalUPCList,Form.ExistingProductList)>
					<CFSET listcompared2 = ListCompare(Form.ExistingProductList,Form.FinalUPCList)>
					<cfif listlen(listcompared1) GT 0 OR listlen(listcompared2) GT 0>
						opener.document.all.#Form.ParentFormname#.navigate.value = 1;
					</cfif>
				}
				if(opener.document.all.#Form.ParentFormname#.stopnavigate)
				{
					opener.document.all.#Form.ParentFormname#.stopnavigate.value = 1;
				}
				</cfif>
				if (typeof window.opener.disableActions === "function") {
					window.opener.disableActions();
				}

				<cfif form.parent_call_back neq "">
                    /* execute a call back in parent window */
                    opener.#form.parent_call_back#;
				<cfelse>
					opener.document.all.#Form.ParentFormname#.submit();
				</cfif>
			}
			else
			{
				opener.document.all.#Form.ParentFormname#.submitbutton.click();
				if (typeof window.opener.disableActions === "function") {
					window.opener.disableActions();
				}
			}
        </cfif>


	window.close()
	</script>
	</cfif>
	</cfif>
     </CFOUTPUT>
  <cfabort>
</CFIF>

<!------------------------------ Get all list - exclude list -------------------------------------->

<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
	<TR BGCOLOR="FFCE84">
		<TD ID="header">&nbsp;</TD>
			<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
				<TD ID="header" WIDTH="1"><input TYPE="checkbox" NAME="checkall" ONCLICK="selectAll()"></TD>
			<CFELSE>
				<TD ID="header" WIDTH="1">&nbsp;</TD>
			</CFIF>

		<CFOUTPUT>
		<CFLOOP LIST="#HeaderNameList#" INDEX="original_Header" DELIMITERS=",">
		<CFSET sortImage="">
		<cfset this_Header = ListFirst(original_Header, ":")>
		<cfset this_Header_value = ListLast(original_Header, ":")>
		<CFIF this_Header_value EQ Form.SORT_BY>
			<CFIF FORM.SORT_ORDER EQ "DESC">
				<CFSET New_Sort_Order="ASC">
				<CFSET sortImage="up_1.gif">
			<CFELSE>
				<CFSET New_Sort_Order="DESC">
				<CFSET sortImage="down_1.gif">
			</CFIF>
		<CFELSE>
			<CFSET New_Sort_Order="ASC">
		</CFIF>
		<TD ID="header"><nobr><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header_value#','#New_Sort_Order#');">#this_Header#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A>&nbsp;</nobr> </TD>
		</CFLOOP>
		</CFOUTPUT>
	</TR>
	<CFIF FORM.FirstTimeLoading EQ "TRUE">
	<TR>
		<TD COLSPAN="100%" ALIGN="center"><BR><font SIZE="+1" color="red">Please enter your <cfoutput>#lcase(application.returned_customer_setting.item_label)#</cfoutput> criteria</font><BR><BR></TD>
	</TR>
	</CFIF>
	<cf_Number_of_Rows maxrows= #Records_To_Show#>
<CFSET FORM.AlreadySelectedItems = "">
<CFOUTPUT QUERY="searchProducts" startrow="#StartRow#" maxrows="#MaxRows#">

		<cfset popupCode = " ONCLICK=""profilePopup('product', '#BSA_Foodservice_Items_Master_ID#')"" style=""cursor: pointer;""">
		<CFIF listfindnocase(FORM.ProductListToExcludeFromSelecting,searchProducts.BSA_Foodservice_Items_Master_ID) EQ 0>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD ALIGN="right">#currentrow#</TD>
				<TD>
				<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
					<cfset variables.overMaxProducts = 0 />
					<CFIF ListFindNoCase(Form.FinalUPCList,BSA_Foodservice_Items_Master_ID, ",|") and form.rebateTypeSelected eq 2 and isNumeric(variables.maxProducts)>
						<cfif listLen(Form.FinalUPCList) gt variables.maxProducts>
						  <cfset variables.overMaxProducts = 1 />
						</cfif>
					</CFIF>
					<span ID="checkAllProducts">
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
						<input
							TYPE="checkbox"
							NAME="selectedUPCS"
							VALUE="#BSA_Foodservice_Items_Master_ID#"
							<CFIF ListFindNoCase(Form.FinalUPCList,BSA_Foodservice_Items_Master_ID, ",|")>
								CHECKED="CHECKED"
								<CFSET FORM.AlreadySelectedItems = listappend(AlreadySelectedItems,BSA_Foodservice_Items_Master_ID,",")>
								ONCLICK="if(!this.checked) document.all.checkall.checked = false;"
								<cfif (RevisionSettings.Products_Removed eq 2 AND ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0) or variables.overMaxProducts eq 1>
									DISABLED="DISABLED"
								</cfif>
					<cfelse>
								<cfif RevisionSettings.Products_Added eq 2 or variables.overMaxProducts eq 1>
									DISABLED="DISABLED"
								</cfif>
							</cfif>

						>
						<cfif (RevisionSettings.Products_Removed eq 2 OR RevisionSettings.Products_Added eq 2) or variables.overMaxProducts eq 1>
							<cfif (RevisionSettings.Products_Removed eq 2 AND ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0) or variables.overMaxProducts eq 1>
								<INPUT type="hidden" name="selectedUPCS" value="#BSA_Foodservice_Items_Master_ID#">
						</cfif>
					</cfif>
					<cfelse>
						<input
							TYPE="checkbox"
							NAME="selectedUPCS"
							VALUE="#BSA_Foodservice_Items_Master_ID#"
							<CFIF ListFindNoCase(Form.FinalUPCList,BSA_Foodservice_Items_Master_ID, ",|")>
								CHECKED="CHECKED"
								<CFSET FORM.AlreadySelectedItems = listappend(AlreadySelectedItems,BSA_Foodservice_Items_Master_ID,",")>
								<cfif variables.overMaxProducts eq 1>
									DISABLED="DISABLED"
								</cfif>
							</CFIF>
							ONCLICK="if(!this.checked) document.all.checkall.checked = false;">
						<cfif variables.overMaxProducts eq 1>
							<INPUT type="hidden" name="selectedUPCS" value="#BSA_Foodservice_Items_Master_ID#">
						</cfif>
					</cfif>
					</SPAN>
				<CFELSE>
				<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
					<INPUT type="Radio" NAME="selectedUPCS" VALUE="#BSA_Foodservice_Items_Master_ID#" <CFIF ListFindNoCase(FORM.FinalUPCList,BSA_Foodservice_Items_Master_ID) NEQ 0>CHECKED="CHECKED"<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems,BSA_Foodservice_Items_Master_ID,",")>
					<cfif RevisionSettings.Products_Removed eq 2 AND ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0>DISABLED="DISABLED"
					</cfif>
					<cfelse>
					<cfif RevisionSettings.Products_Added eq 2>DISABLED="DISABLED"</cfif></cfif>>
					<cfif RevisionSettings.Products_Removed eq 2 OR RevisionSettings.Products_Added eq 2>
					<cfif RevisionSettings.Products_Removed eq 2 AND ListFindNoCase(ProductItemList, BSA_Foodservice_Items_Master_ID) NEQ 0>
							<INPUT type="hidden" name="selectedUPCS" value="#BSA_Foodservice_Items_Master_ID#">
					</cfif>
					</cfif>
					<cfelse>
					<INPUT type="Radio" NAME="selectedUPCS" VALUE="#BSA_Foodservice_Items_Master_ID#" <CFIF ListFindNoCase(FORM.FinalUPCList,BSA_Foodservice_Items_Master_ID) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems,BSA_Foodservice_Items_Master_ID,",")></CFIF>>
					</cfif>
				</CFIF>
				</TD>
		<CFELSE>
			<TR BGCOLOR="silver">
				<TD ALIGN="right">#currentrow#</TD>
				<TD><input TYPE="checkbox" CHECKED DISABLED></TD>
		</CFIF>
			<cfif appSettings.get_Setting('Display_Item_No') eq '1'><TD #popupCode# class="item">#Item#&nbsp;</TD></cfif>
			<cfif RemoveUPC EQ 0><TD #popupCode# class="upc">#UPC#&nbsp;</TD></cfif>
			<TD #popupCode# class="description">#trim(Description)#&nbsp;</TD>
			<cfif RemoveTypeGroup EQ 0><TD #popupCode# class="type_group">#Type_Group_Desc#&nbsp;</TD></cfif>
			<cfif RemoveTypeCode EQ 0><TD #popupCode# class="type_code">#Type_Code_Desc#&nbsp;</TD></cfif>
			<cfif appSettings.getUseProductGroup1()><TD #popupCode# class="brand">#Brand_Name#&nbsp;</TD></cfif>
			<cfif appSettings.getUseProductHierarchy()><TD #popupCode# class="hiearchy">#Product_Hierarchy_Name#&nbsp;</TD></cfif>
			<cfif userClassCodeInThisProductSearch><TD #popupCode# class="class_code">#Class_Code_Desc#&nbsp;</TD></cfif>
			<cfif isBusinessSegEnabledForProduct AND ProdResults_DisplayBusinessSegment><TD #popupCode# class="business"><nobr>#Business_Unit_Desc#&nbsp;</nobr></TD></cfif>

		</TR>
		<CFFLUSH>
	</CFOUTPUT>
</TABLE>

</FIELDSET>
<CFIF searchProducts.recordcount GT 0>
<!--- <HR COLOR="Orange" SIZE="2" WIDTH="760px"> --->
<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
&nbsp;&nbsp;&nbsp;<CF_Next_Previous_For_Forms
	formname="SearchForm"
	query="searchProducts"
	maxpages="40"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
</DIV>
</cfif>

<!---This pagination should be here regardless of the number of records returned --->
	<script language="javascript">
		function showstartingWith(sValue)
		{
			document.SearchForm.Prod_Name.value =sValue;
			doSearch();
		}
		</script>
		<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0" ALIGN="CENTER"><TR>
		<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
					<TD class="notranslate">
						<B>
						<CFIF chr(LoopCount) EQ form.Prod_Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
					 <CFIF chr(LoopCount) EQ form.Prod_Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
					<TD class="notranslate">
						<B>
						<CFIF LoopCount EQ form.Prod_Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
						<CFIF LoopCount EQ form.Prod_Name>
							<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
					<TD>
						<B>
						<CFIF "" EQ form.Prod_Name>
						 <FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('');">All</A>
					 <CFIF "" EQ form.Prod_Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
	</cfoutput>
	 </TR>
	</TABLE>

	<CFIF searchProducts.recordcount GT 0>

<DIV ALIGN="center" id="divLinks">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<cfif searchProducts.recordcount GT 0 and FORM.SelectSingleSearchResultOnly EQ 0>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT>
	<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>
	<span style="color:gray">import all returned products</span>
	<cfelse>
	<a STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#searchProducts.recordcount#</CFOUTPUT>)"> import all returned products </a>
	</cfif>
	<FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>

	</cfif>
</DIV>

<!--- <HR COLOR="Orange" SIZE="2"  WIDTH="760px"> --->
<CFELSE>
<BR>
</CFIF>


<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="startrow" 							VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" 							VALUE="#frompage#">
	<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="#FORM.ParentFormname#">
	<INPUT TYPE="hidden" NAME="FinalUPCList" 						VALUE="#Form.FinalUPCList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 				VALUE="#Form.AlreadySelectedItems#">
	<INPUT TYPE="hidden" NAME="ExistingProductList" 				VALUE="#FORM.ExistingProductList#">
	<INPUT TYPE="hidden" NAME="finishedselectingproducts" 			VALUE="0">
	<INPUT TYPE="hidden" NAME="LoadExistingProductList" 			VALUE="0">
	<INPUT TYPE="hidden" NAME="FirstTimeLoading" 					VALUE="FALSE">
	<INPUT TYPE="hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="#form.ProductListToExcludeFromSelecting#">
	<INPUT TYPE="Hidden" NAME="Program_ID"							VALUE="#form.Program_ID#">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID"  					VALUE="#FORM.DTPS_Program_ID#">
	<INPUT TYPE="Hidden" NAME="CallingPage"  						VALUE="#FORM.CallingPage#">
	<INPUT TYPE="Hidden" NAME="Bid_Rule_In_Effect" 					VALUE="#FORM.Bid_Rule_In_Effect#">
	<INPUT TYPE="Hidden" NAME="SudmitFormViaSubmitButton"  			value="#form.SudmitFormViaSubmitButton#">
	<INPUT TYPE="Hidden" NAME="parent_call_back"  					value="#form.parent_call_back#">
	<INPUT TYPE="Hidden" NAME="Only_Show_Products_From_These_Groups"  VALUE="#form.Only_Show_Products_From_These_Groups#">
	<INPUT TYPE="Hidden" NAME="LoadProductsFromThesePrograms"  		VALUE="#form.LoadProductsFromThesePrograms#">
	<INPUT TYPE="hidden" NAME="passed_form" 						VALUE="#form.passed_form#">
	<INPUT TYPE="hidden" NAME="itemList" 							VALUE="#form.itemList#">
	<INPUT TYPE="hidden" NAME="AllowProductGroupList" 				VALUE="#form.AllowProductGroupList#">
	<INPUT TYPE="hidden" NAME="AllowProductGroupLevelId" 			VALUE="#form.AllowProductGroupLevelId#">
	<INPUT TYPE="hidden" NAME="Return_Value_Field_Name" 			VALUE="#form.Return_Value_Field_Name#">
	<INPUT TYPE="hidden" NAME="Return_Value_Group_Field_Name" 			VALUE="#form.Return_Value_Group_Field_Name#">
	<input type="hidden" name="SelectSingleSearchResultOnly"		value="#Form.SelectSingleSearchResultOnly#">
	<INPUT TYPE="hidden" NAME="Line_Of_Business_ID" 				VALUE="#form.Line_Of_Business_ID#">
	<!--- The Distributor_List comes from the PM_Select_Distributors.cfm page --->
	<INPUT TYPE="Hidden" NAME="Distributor_List"					VALUE="#FORM.Distributor_List#">
	<INPUT TYPE="Hidden"  NAME="QueryMasterProductTable"			VALUE="#QueryMasterProductTable#">
	<INPUT NAME="rebateTypeSelected" TYPE="HIDDEN"					VALUE="#form.rebateTypeSelected#">
	<INPUT TYPE="hidden" NAME="Prod_Name"							value="#Prod_Name#">
	<INPUT TYPE="Hidden" NAME="Importallflag"						VALUE="#FORM.Importallflag#">
	<INPUT TYPE="hidden" NAME="Business_Segment_ID"					value="#form.Business_Segment_ID#">
	<INPUT TYPE="hidden" NAME="businessSegmentsOn"					value="#form.businessSegmentsOn#">
	<INPUT TYPE="Hidden" NAME="FlexAppName"							VALUE="#FORM.FlexAppName#">
    <INPUT TYPE="hidden" NAME="plannerId"							value="#form.plannerId#">
	<INPUT TYPE="hidden" NAME="PageSource"							VALUE="#PageSource#">

</CFOUTPUT>

</FORM>

<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->

<SCRIPT>
	<cfif searchProducts.recordcount GT 0>
		function importAllProducts(recordcount){
			processingPopUpDisplay('div.customContainer'); //D51575
			//If a message needs to be shown while adding all products, show the message in a new window
			<cfoutput>
			<cfif ProductMessages.Message_Settings eq 1>
			winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no';
			window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#DTPS_PROGRAM_ID#&Discountype=#Discountype#&ImportAll=1&ImportRecordcount="+recordcount,"ProductMessageWindow",winprops);
			<cfelse>
				SubmitFormOnImportAllProducts(recordcount);
			</cfif>
			</cfoutput>
		}

		function SubmitFormOnImportAllProducts(recordcount){
			var recordcount = <CFOUTPUT>#ListLen(allList)#</CFOUTPUT>;
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";

			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				disableButton("divLinks", true, false);
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				document.all.checkall.checked = checkOrUncheckBeforeFireEvent(1);
				callfireEvent(document,document.all.checkall,'Click');

                before_submit_form();
				document.SearchForm.finishedselectingproducts.value = 1;
				document.SearchForm.Importallflag.value = 1;
				document.SearchForm.submit();
			}
			else
			{

			}
		}

		function removeAllProducts(){

			if(confirm("By pressing OK all selected records will be unselected")){
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'0' as an argument below means "false". */
				document.all.checkall.checked = checkOrUncheckBeforeFireEvent(0);
				callfireEvent(document,document.all.checkall,'Click');

				document.SearchForm.finishedselectingproducts.value = 0;
				document.SearchForm.FinalUPCList.value 	= "";
				document.SearchForm.AlreadySelectedItems.value 	= "";
			}
			else
			{

			}
		}
	</cfif>

	function reset_Form_Fields()
	{
		resetSelect("Q_Brand_ID");
		resetSelect("Type_Group_Desc_ID");
		resetSelect("Type_Code_Desc_ID");
		resetSelect("Brand_ID");
		<cfif application.returned_customer_setting.lob_search_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.lob_search_switch EQ 1>
		resetSelect("Line_Of_Biz");
		</cfif></cfif>
		resetSelect("Product_Status");
		resetSelect("sort_by");
		resetSelect("sort_Order");
		resetSelect("Invoice_Days");
		resetSelect("Rebate_Type_Search_ID");
		if(document.all.item_number)
		{
			document.all.item_number.value = "";
		}
		if(document.all.description_string)
		{
			document.all.description_string.value = "";
		}
		<cfif application.returned_customer_setting.upc_search_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_search_switch EQ 1>
		if(document.all.upc_number)
		{
			document.all.upc_number.value = "";
		}

		</cfif></cfif>
		//document.all.Distributor_Name.value = "";
		<cfoutput>
		<cfloop query="qGetOtherProductGroupAttributes">
<!--- 		<cfset ProductAttributeDropDownName = "Product_Attribute_#Product_Group_Level_Type#" /> --->
      <cfset ProductAttributeDropDownName = "Product_Attribute_#Group_Level_ID#" />

		resetSelect("#ProductAttributeDropDownName#");
		</cfloop>
		<cfif appSettings.getUseProductHierarchy()>
		<cfloop query="qGetDistinctLevels">
		<cfset ProductHierarchyDropDownName = "Product_Hierarchy_#Hierarchy_Level#" />
		resetSelect("#ProductHierarchyDropDownName#");
		</cfloop>
		</cfif>	</cfoutput>
		document.SearchForm.Prod_Name.value ="";//D 29939: Reset
		//showstartingWith('')//D 29939: Reset
	}
</SCRIPT>

<!---
Determines search result column's visibility.
Go to "settings>application settings>Labels>Settings labels" to set visibility
--->
<cffunction name="showHideColumnsSetting" output="false">

	<cfset ProdResults_DisplayUPC = 0>
	<cfset ProdResults_DisplayHierarchy = 0>
	<cfloop query="ProdSearchResultsColumnsDisplayAdditionalSettings">
		<cfif field_name eq "UPC">
			<cfset ProdResults_DisplayUPC = 1>
		</cfif>
		<cfif field_name eq "Hierarchy">
			<cfset ProdResults_DisplayHierarchy = 1>
		</cfif>
	</cfloop>

	<cfset ProdResults_DisplayBusinessSegment = 0>
	<cfset ProdResults_DisplayTypeGroup = 0>
	<cfset ProdResults_DisplayTypeCode = 0>
	<cfset ProdResults_DisplayBrand = 0>
	<cfloop query="ProdSearchResultsColumnsDisplaySettings">
		<cfif form.businessSegmentsOn AND group_internal_label eq "Business Segment">
			<cfset ProdResults_DisplayBusinessSegment = 1>
		</cfif>
		<cfif group_internal_label eq "Type Group">
			<cfset ProdResults_DisplayTypeGroup = 1>
		</cfif>
		<cfif group_internal_label eq "Type Code">
			<cfset ProdResults_DisplayTypeCode = 1>
		</cfif>
		<cfif group_internal_label eq "Brand">
			<cfset ProdResults_DisplayBrand = 1>
		</cfif>
	</cfloop>

</cffunction>

<cfinclude template="/common_files/focus.cfm">
</BODY>
</HTML>