<cfparam name="form.passed_form" default="">
<cfparam name="form.itemList" default="">
<cfparam name="URL.SelectSingleSearchResultOnly" 	default="0">

<cfparam name="Records_To_Show" default=25>
<cfset cacheSpan = CreateTimeSpan(0,0,0,0)>
<CFPARAM NAME="UserClassCodes" default="">
<!---Includes personal preferences for records to show--->
<cfif application.Personalization EQ 1>
	<cfinclude template="/settings/personalization/records_to_return.cfm">
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif appSettings.getAllowNavigate()>
<CFINCLUDE TEMPLATE="comparelist.cfm">
</cfif>
<cfif form.passed_form EQ "searchform">
	<cfset form.passed_form = "">
</cfif>

<!--- reformat the itemList --->
<cfif form.passed_form NEQ "" and form.passed_form NEQ "searchform" and form.itemList NEQ "">
	<cfset form.itemList = #trim(replace(ListQualify(form.itemList, "'", ",", "ALL"), "''", "'", "ALL"))# > 
</cfif>

<CFIF isdefined("URL.FormName")>
	<cfparam name="URL.PID" default="">
	<FORM ACTION="product_select_V1.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="">
		<INPUT NAME="ProductListToExcludeFromSelecting" TYPE="Hidden" VALUE="">
		<INPUT NAME="Sort_By" TYPE="Hidden" VALUE="Item">
		<INPUT NAME="Program_ID" TYPE="Hidden" VALUE="<cfoutput>#URL.PID#</cfoutput>">
		<INPUT NAME="DTPS_Program_ID" TYPE="Hidden" VALUE="0">
		<INPUT NAME="Bid_Rule_In_Effect" TYPE="Hidden" VALUE="0">
		<INPUT NAME="SudmitFormViaSubmitButton" TYPE="Hidden" VALUE="0"> <!--- when a form is submitted this way; the onsubmit function is called. using form.submit() does not fire it --->
		<INPUT NAME="Only_Show_Products_From_These_Groups" TYPE="Hidden" VALUE="0">
		<INPUT NAME="LoadProductsFromThesePrograms" TYPE="Hidden" VALUE="">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.SelectSingleSearchResultOnly#</CFOUTPUT>">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.ExistingProductList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ExistingProductList.value

			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ProductListToExcludeFromSelecting != null){
				this.document.all.ProductListToExcludeFromSelecting.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ProductListToExcludeFromSelecting.value
			}
			
			if(opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Sort_By)
			{
				this.document.all.Sort_By.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Sort_By.value;				
			}

			if(opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Bid_Rule_In_Effect)
			{
				this.document.all.Bid_Rule_In_Effect.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Bid_Rule_In_Effect.value;				
			}
			
			
			if(opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.DTPS_On != null && opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.DTPS_Program_ID != null){
				
				DTPS_On_temp = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.DTPS_On;
				DTPS_Program_ID_temp = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.DTPS_Program_ID;
				
								
				if(DTPS_On_temp.value.length != 0 && DTPS_Program_ID_temp.value.length != 0 && DTPS_On_temp.value != 0 && DTPS_Program_ID_temp.value != 0){
					this.document.all.DTPS_Program_ID.value = DTPS_Program_ID_temp.value;
				}
			}
			
			if(opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.SudmitFormViaSubmitButton)
			{
				this.document.all.SudmitFormViaSubmitButton.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.SudmitFormViaSubmitButton.value;				
			}

			
			if(opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Only_Show_Products_From_These_Groups != null)
			{
				this.document.all.Only_Show_Products_From_These_Groups.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Only_Show_Products_From_These_Groups.value;				
			}
						
			document.all.MyForm.submit()
		}
		else{
			alert("An error has occurred. Necessary information is not available. Please inform system administrators. This window will close.")
			window.close()
		}
	</script>
	
	<cfabort>
</CFIF>

<CFSET PAGE_TITLE= "Product Search">

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
<CFPARAM NAME="FORM.SelectedUPCS" DEFAULT="">
<CFPARAM NAME="FORM.FinalUPCList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingproducts" DEFAULT="0">
<CFPARAM NAME="FORM.LoadExistingProductList" DEFAULT="1">
<CFPARAM NAME="FORM.FirstTimeLoading" DEFAULT="TRUE">
<CFPARAM NAME="FORM.ProductListToExcludeFromSelecting" DEFAULT="">
<cfparam name="form.SudmitFormViaSubmitButton" default="0">
<cfparam name="form.Importallflag" default="0">


<!---default params for business segments--->
<CFPARAM name="FORM.Business_Segment_ID" default="0">
<CFPARAM name="form.businessSegmentsOn" default="0">

<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">

<CFSET SHOW_INVOICE_FILTER=1>

<CFSET listofitemstodelete = "">
<!--- loop through the pages selected items and if it is not in the selected list that means it was removed to queue it for deletetion --->
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF FORM.SelectSingleSearchResultOnly NEQ 1>
		<CFIF listfind(FORM.SelectedUPCS, ListItem, ",") EQ 0>
			<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
		</CFIF>
	<CFELSE>		
		<CFSET listofitemstodelete= ListItem>
	</CFIF>
	
</CFLOOP>
<CFSET parentselectedlist = Form.FinalUPCList>
<!--- if a selected item isnt already in the final list then add it  --->
<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedUPCS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalUPCList, ListItem, ",") EQ 0>
		<CFSET Form.FinalUPCList = listappend(FinalUPCList, ListItem, ",")>
	</CFIF>
</CFLOOP>
<!--- delete the queued products --->
<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalUPCList,ListItem, ",") GT 0>
		<CFSET Form.FinalUPCList = listdeleteat(FORM.FinalUPCList, listfind(FORM.FinalUPCList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>
<!--- FinalUPCList: <CFOUTPUT>#FORM.FinalUPCList#</CFOUTPUT><BR><BR> --->

<CFIF FORM.LoadExistingProductList EQ 1>
	<CFSET Form.FinalUPCList = FORM.ExistingProductList>
</CFIF>


<!--- ****************************************************************** --->

<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
		SELECT
		{
			width:180 px;
		}
	</STYLE>
	<script>
		
		function profilePopup(PopupLocation, internal_ID){
			switch (PopupLocation) {
		
				case "product":
					NewWindow('/profiles/Products/Product_profile.cfm?PID=' + internal_ID,'name','400','450','Yes', 'No')			
				break;		
							
			}
		}
		preSelectedProducts = new Object();
		function initPage() {

			preSelectedProducts = opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Product_List
		}
	
		var thisPageProductList = "";

		function buildThisPageList() {
			thisPageProductList = "";
			for(var x=0; x<document.all.selected_products.length; x++) {
				thisCheckBox = document.all.selected_products[x]
				if(thisCheckBox.checked){
					thisPageProductList = thisPageProductList + thisCheckBox.value + ","
				}
			}
			if(thisPageProductList.length > 0) {
			thisPageProductList = thisPageProductList.substring(1, thisPageProductList.length-1)
			}
			return thisPageProductList
		}
		
		isSearching = 0
		function doSearch() {
			isSearching = 1
			document.all.SearchForm.startrow.value=1;
			document.all.SearchForm.frompage.value=1;			
			document.all.SearchForm.passed_form.value = "searchform";		
			document.all.SearchForm.submit()
		}
		function finishedSearching() {
			document.all.finishedselectingproducts.value = 1
			document.all.SearchForm.submit();
		}
		
		
		function verifyClose() {
			if (document.all.startrow & !document.all.itemList) {
				if(document.all.startrow.value == <CFOUTPUT>#StartRow#</CFOUTPUT> && document.all.finishedselectingproducts.value != 1 && isSearching != 1){
					event.returnValue='Product selections you have not saved will be lost.'
				}
			}
		}
		
		function selectAll(){
			if(window.checkAllProducts != null){
				if(checkAllProducts.length)
				{
					for(var x=0; x<checkAllProducts.length;x++){
						box = checkAllProducts[x].firstChild
						box.checked = document.all.checkall.checked
					}
				}
				else
				{
					box = checkAllProducts.firstChild
					box.checked = document.all.checkall.checked
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

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="initPage()" ONBEFOREUNLOAD="verifyClose()">
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
		//resetSelect("Distributor");	
		resetSelect("Invoice_Days");	
		resetSelect("Rebate_Type_Search_ID");	
		
		document.all.item_number.value = "";		
		document.all.description_string.value = "";
		<cfif application.returned_customer_setting.upc_search_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_search_switch EQ 1>
		document.all.upc_number.value = "";
		</cfif></cfif>
		document.all.Ship_To.value = "";
		document.all.Visible_Distributor.value = "";
		document.all.Distributor.value="0";
	}
	
	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			sObj.fireEvent('onchange');
		}
	}
</SCRIPT>
<cfset restrictOnProductGroup = 0>
<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>

	<!---check to see if the business segment components exist before we run this--->
	<!---check whether the directory exists or not--->
	<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
	<cfif DirectoryExists(theDir)>
		<!---if the directory exists then check the file--->
		<cfset theFile = "#theDir#BusinessSegmentManager.cfc" />
		<!---it the file exists then we can create the component--->
		<cfif FileExists(theFile)>
			<!---create and instance of the BusinessSegmentManager--->
			<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
			<cfif businessSegManager.isEnabled()>
				<cfset form.businessSegmentsOn = 1 />
				<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(FORM.DTPS_Program_ID) />
				<cfset form.Business_Segment_Id = trim(busSegIdForProgram) />
				<cfset form.businessSegmentsOn = 1 />
				<!---get the desctiption to display--->
				<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
				<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
				<!------ get the sales person user id ----->
				<cfset qProgram = CreateObject("component", "components.programs.Program").getProgramInfo(FORM.DTPS_Program_ID) />				
				<cfset qGetUserClassCodes = businessSegManager.getActiveClassCodes(qProgram.Responsible_User_ID, 0) />
				
				<cfif appSettings.getClassCodesOn()>
					<cfset UserClassCodes = ValueList(qgetUserClassCodes.class_code_id)>
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	
	<!------ see whther the product selection is to be restricted based on product group ----->
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	<cfset programInfo = programManager.getProgramInfo(FORM.DTPS_Program_ID)>
	<cfif programInfo.Restrict_On_Approval_Group>
		<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init()>
		<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />
		<cfset restrictOnProductGroup = 1>
		<cfset qRestrictOnProductGroupList = approvalGroupManager.getTemplateAllowApprovalGroups(programInfo.ProgramType_ID)>
		<cfset restrictOnProductGroupList = ValueList(qRestrictOnProductGroupList.Group_ID)>
	</cfif>
	
	<!---if product category filter is on then display any product category filters--->
	<cfif isDefined("application.returned_customer_setting.product_category_filter") and application.returned_customer_setting.product_category_filter>
		<cfset lProductCategoryFilter = CreateObject("component", "components.products.Category.ProductCategory").getCategoryFiltersByProgram(FORM.DTPS_Program_ID) />
	</cfif>
					
</CFIF>
<cfif NOT isDefined("form.businessSegmentsOn") OR NOT isDefined("form.Business_Segment_ID")>
	<cfset appSettings.setClassCodesOn(0)>
<cfelse>
	<cfif form.businessSegmentsOn neq 1 OR form.Business_Segment_ID eq 0>
		<cfset appSettings.setClassCodesOn(0)>
	</cfif>
</cfif>
<CFPARAM name="form.Line_Of_Business_ID" default="NULL">
<cfparam name="FILTER_BUSINESS_SEGMENT_ID" default="0">

<cfif isDefined("programInfo") and programInfo.recordcount GT 0>
	<cfset form.Line_Of_Business_ID = programInfo.Line_Of_Business_ID>
</cfif>

<cfif form.businessSegmentsOn eq 1 and isDefined("form.Business_Segment_Id")> 

<cfset ProductBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(FORM.Business_Segment_Id) />	

<CFSET FILTER_BUSINESS_SEGMENT_ID = ProductBSFilter.Product_BS_Filter>
	
	<!--- <cfif form.Business_Segment_Id IS NOT 0 and (form.BUSINESS_SEGMENT_ID EQ 3 OR form.BUSINESS_SEGMENT_ID EQ 5)>
		<cfset FILTER_BUSINESS_SEGMENT_ID = 1>
	<cfelse>
		<cfset FILTER_BUSINESS_SEGMENT_ID = form.BUSINESS_SEGMENT_ID>
	</cfif> --->
</cfif> 

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type groups																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- <CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Type_Group_Desc
	WHERE len(Type_Group_Desc) != 0 AND Deleted = 0
	<cfif (isDefined("form.Business_Segment_Id") and form.Business_Segment_Id IS NOT 0)>
	and Business_segment_id = #FILTER_BUSINESS_SEGMENT_ID#
	</cfif>
	ORDER BY Type_Group_Desc
</CFQUERY> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get QBrands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetQBrands" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	SELECT *
	FROM Q_Brand_Desc
	WHERE len(Q_Brand) != 0 AND Deleted = 0
	<cfif (isDefined("form.Business_Segment_Id") and form.Business_Segment_Id IS NOT 0)>
	and Business_segment_id = #FILTER_BUSINESS_SEGMENT_ID#
	</cfif>
	<cfif restrictOnProductGroup AND approvalGroupType.groupType EQ 3>
	and 
	<cfif Len(restrictOnProductGroupList) EQ 0>1=2
	<cfelse>#approvalGroupType.IDField# IN (#ListQualify(restrictOnProductGroupList, "'", ",")#)
	</cfif>
	</cfif>
	ORDER BY Q_Brand
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type codes																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 <CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	SELECT *
	FROM Type_Code_Desc
	WHERE len(Type_Code_Desc) != 0 AND Deleted = 0
	<cfif (isDefined("form.Business_Segment_Id") and form.Business_Segment_Id IS NOT 0)>
	and Business_segment_id = #FILTER_BUSINESS_SEGMENT_ID#
	</cfif>
	<cfif restrictOnProductGroup AND approvalGroupType.groupType EQ 1>
	and 
	<cfif Len(restrictOnProductGroupList) EQ 0>1=2
	<cfelse>#approvalGroupType.IDField# IN (#ListQualify(restrictOnProductGroupList, "'", ",")#)
	</cfif>
	</cfif>
	ORDER BY Type_Code_Desc
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get brands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetBrands" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	SELECT *
	FROM Brand
	WHERE len(brand_name) !=0 AND Deleted = 0
	<cfif (isDefined("form.Business_Segment_Id") and form.Business_Segment_Id IS NOT 0)>
	and Business_segment_id = #FILTER_BUSINESS_SEGMENT_ID#
	</cfif>
	ORDER BY Brand_Name
</CFQUERY>

	
<FORM ACTION="product_Select_V1.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" ONKEYPRESS="if(event.keyCode == 13) doSearch()">
<br>&nbsp;&nbsp;&nbsp;<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/createprogram/page8.cfm" onclick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
<DIV ALIGN="center">
<FIELDSET STYLE="padding:5px; width: 760px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Search Criteria</LEGEND>


<cfset maxColsPerRow = 4/>
<cfset currentColCount = 0/>

		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<!------ ************************** Q Brand ************************* ----->
				<CFPARAM NAME="FORM.Q_Brand_ID" DEFAULT="0">
				<cfif appSettings.getUseProductGroup2()>
				<TD NOWRAP ALIGN="left">
					<cfoutput><B>#application.returned_customer_setting.q_brand_label_singular#</B><BR></cfoutput>					
					<SELECT NAME="Q_Brand_ID">
						<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.q_brand_label_plural#</OPTION></cfoutput>
						<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#Q_Brand_ID#"<cfif FORM.Q_Brand_ID EQ GetQBrands.Q_Brand_ID> SELECTED</cfif>>#Q_Brand#</OPTION></CFOUTPUT>
					</SELECT>
					<!--- <BR><BR> --->
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
			
				<!------ ************************** Type Group ************************* ----->
				<CFPARAM NAME="FORM.Type_Group_Desc_ID" DEFAULT="0">
				<cfif appSettings.getUseProductGroup3()>
				<TD NOWRAP ALIGN="left">					
					<cfif  form.Only_Show_Products_From_These_Groups EQ 0>
					<cfif form.Bid_Rule_In_Effect EQ 0>
					<cfoutput><B>#application.returned_customer_setting.type_group_label_singular#</B><BR></cfoutput>
					<cf_sel_type_group
						company_main_id			= "#request.AccessStructure.company_main_id#"
						business_segment_id 	=  "#FILTER_BUSINESS_SEGMENT_ID#"
						dropdown_name			= "Type_Group_Desc_ID"
						selected_id				= "#FORM.Type_Group_Desc_ID#"
						text_before_tag_close	= ""
						default_option_on		= "1"
						default_option_text		= "**ALL** #application.returned_customer_setting.type_group_label_plural#"
						default_option_value	= "0"
					> 
					</cfif></cfif>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
				
				<!------ ************************** Type Code ************************* ----->
				<CFPARAM NAME="FORM.Type_Code_Desc_ID" DEFAULT="0">
				<cfif appSettings.getUseProductGroup4()>
				<TD NOWRAP ALIGN="left">					
					<cfif  form.Only_Show_Products_From_These_Groups EQ 0>
					<cfif form.Bid_Rule_In_Effect EQ 0>
					<cfoutput><B>#application.returned_customer_setting.type_code_label_singular#</B><BR></cfoutput>
					<SELECT NAME="Type_Code_Desc_ID">
						<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.type_code_label_plural#</OPTION></cfoutput>
						<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#Type_Code_Desc_ID#"<cfif FORM.Type_Code_Desc_ID EQ GetTypeCodeDesc.Type_Code_Desc_ID> SELECTED</cfif>>#Type_Code_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					</cfif></cfif>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>	
				
			<!------ ************************** Product Hierarchy ************************* ----->
			<cfif appSettings.getUseProductHierarchy()>
				<cfset productGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
				<cfset restrictOnProductHierarchy = 0>
				<cfif restrictOnProductGroup>
				<cfif Left(approvalGroupType.groupType, 1) EQ 2>
					<cfset restrictOnProductHierarchy = 1>
				</cfif>
				</cfif>
				<cfif restrictOnProductHierarchy>
					<cfset qGetProductHierarchy = productGroupDataManager.getHierarchyLevel(addParentName=0,getLevelNames=1,restrictOnProductHierarchy=restrictOnProductHierarchy,restrictOnProductHierarchyLevel=approvalGroupType.prodHierLevel,restrictOnProductHierarchyList=restrictOnProductGroupList) />
				<cfelse>
					<cfset qGetProductHierarchy = productGroupDataManager.getHierarchyLevel(addParentName=0,getLevelNames=1) />
				</cfif>
				<!------ If the approvcalGroup is hierarchy, get the last level ids ----->
				<cfif restrictOnProductHierarchy>
					<cfset qMaxLevel = productGroupDataManager.getDistinctHierarchyLevel(getMaxLevel=1)>
					<cfset maxLevel = qMaxLevel.Product_Hierarchy_Level>
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
				<cfset maxProductHierarchyLevel = 0>
				<cfoutput query="qGetProductHierarchy" group="Hierarchy_Level">
					<cfset maxProductHierarchyLevel = Trim(Hierarchy_Level)>
					<TD NOWRAP ALIGN="left">
						<CFPARAM NAME="FORM.Product_Hierarchy_#Hierarchy_Level#" DEFAULT="0">
						<B>#Group_Level_Name#</B><BR>
						<SELECT NAME="Product_Hierarchy_#trim(Hierarchy_Level)#">
							<OPTION VALUE="0">**ALL** #Group_Level_Name#</OPTION>
							<CFOUTPUT><OPTION VALUE="#Product_Group_ID#"<cfif Evaluate("FORM.Product_Hierarchy_#Hierarchy_Level#") EQ Product_Group_ID> SELECTED</cfif>>#Group_Level_Desc#</OPTION></CFOUTPUT>
						</SELECT>					
					</TD>
					<cfset currentColCount = currentColCount + 1 />
					<cfif isNextRow(maxColsPerRow, currentColCount)>
					</TR>
					<TR>
					</cfif>
				</cfoutput>
			</cfif>	
			
				
				<!------ ************************** Brand ************************* ----->
				<CFPARAM NAME="FORM.Brand_ID" DEFAULT="0">
				<cfif appSettings.getUseProductGroup1()>
				<TD NOWRAP ALIGN="left">
					<B>Brand</B><BR>					
					<SELECT NAME="Brand_ID">
						<OPTION VALUE="0">**ALL** Brands</OPTION>
						<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#Brand_ID#"<cfif FORM.Brand_ID EQ GetBrands.Brand_ID> SELECTED</cfif>>#Brand_Name#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
			<!------ REMOVE ----->
			<!------ <cfif appSettings.getUseProductGroup5() AND form.businessSegmentsOn> ----->
			<cfif appSettings.getClassCodesOn()>
			<!------ ************************** Class Code ************************* ----->
			<CFPARAM NAME="FORM.Search_Class_Code_ID" DEFAULT="0">
			<cfif appSettings.getUseProductGroup5() and form.businessSegmentsOn>
				<TD NOWRAP ALIGN="left">					
					<cfoutput><B>Class Code</B><BR></cfoutput>
					<SELECT NAME="Search_Class_Code_ID">
						<cfoutput><OPTION VALUE="0">**ALL** Class Codes</OPTION></cfoutput>
						<CFOUTPUT QUERY="qGetUserClassCodes"><OPTION VALUE="#Class_Code_ID#"<cfif FORM.Search_Class_Code_ID EQ Class_Code_ID> SELECTED</cfif>>#Class_Code_Desc#</OPTION></CFOUTPUT>
					</SELECT>					
				</TD>
			</cfif>
			<cfset currentColCount = currentColCount + 1 />
			</cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
					
			<cfif application.returned_customer_setting.lob_search_switch EQ 1><TD><!--- Line Of Biz --->
				<cfif application.returned_customer_setting.lob_search_switch NEQ application.returned_customer_setting.customer_setting_error_string>
				<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.lob_label_singular#</B></span><BR></cfoutput>
				</cfif></cfif>
				<cfset useLakebaseForGetLinesOfBiz = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("line_of_business")>
<cfif useLakebaseForGetLinesOfBiz>
	<cftry>
		<cfset GetLinesOfBiz = application.oLakebase.toQuery(
			application.oLakebase.selectRows("line_of_business", {
				"deleted" = "eq.0",
				"order" = "line_of_business_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLinesOfBiz = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLinesOfBiz>
<cfquery name="GetLinesOfBiz" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
					SELECT *
					FROM Line_Of_Business WHERE Deleted = 0
					ORDER BY Line_Of_Business_Name
				</cfquery>
</cfif>
				<CFQUERY NAME="getFoodserviceLOBID" dbtype="query">
					SELECT Line_Of_Business_ID
					FROM GetLinesOfBiz
					WHERE Line_Of_Business = '#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#'
				</CFQUERY>					
				<cfif application.returned_customer_setting.lob_search_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.lob_search_switch EQ 1>
				<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="#getFoodserviceLOBID.Line_Of_Business_ID#">
				<SELECT NAME="Line_Of_Biz" style="width: 185px;">
					<cfoutput><OPTION VALUE="0" <CFIF trim(GetLinesOfBiz.Line_Of_Business_ID) EQ 0>selected</CFIF>>**ALL** #application.returned_customer_setting.lob_label_plural#</OPTION></cfoutput>
					<CFOUTPUT QUERY="GetLinesOfBiz"><OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION></CFOUTPUT>
				</SELECT>
				</cfif>
				<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
			</TD></cfif>
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
				<TD><!--- Active/Inactive --->
					<span ID="searchItemLabel"><B>Status</B></span><BR>
					<CFPARAM NAME="FORM.Product_Status" DEFAULT="A">
					<SELECT NAME="Product_Status">
						<option VALUE="A" <CFIF FORM.Product_Status EQ "A">SELECTED</CFIF>>Active</option>
					</SELECT>
				</TD>
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
				<CFPARAM NAME="FORM.item_number" DEFAULT="">
				<CFPARAM NAME="FORM.upc_number" DEFAULT="">
				<TD NOWRAP ALIGN="left">
				<B><cfoutput>#application.returned_customer_setting.item_label#</cfoutput> #</B>&nbsp;
				<B>
					<FONT COLOR="Red">[</FONT>
					<FONT COLOR="Blue"><A HREF="/Common_Files/createList.cfm?passObj=Product&passForm=SearchForm"  onclick="window.showModalDialog(this.href,window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >create list</A></FONT> 
					<FONT COLOR="Red">]</FONT>
				</B>
				<BR><input TYPE="Text" NAME="item_number" VALUE="<CFOUTPUT>#FORM.item_number#</CFOUTPUT>" STYLE="WIDTH:180px">
				</TD>
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
			<cfif application.returned_customer_setting.upc_search_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_search_switch EQ 1>
				<TD NOWRAP ALIGN="left">				
				<B><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput> #</B><BR><input TYPE="Text" NAME="upc_number" VALUE="<CFOUTPUT>#FORM.upc_number#</CFOUTPUT>" STYLE="WIDTH:180px">				
				</TD>
				<cfset currentColCount = currentColCount + 1 />
			</cfif></cfif>
			<cfif isNextRow(maxColsPerRow, currentColCount+1) OR isNextRow(maxColsPerRow, currentColCount)>
			<cfset currentColCount = 0 />
			</TR>
			<TR>
			</cfif>			
				<TD COLSPAN="2" NOWRAP>
					<B>Description</B><BR>
					<CFPARAM NAME="FORM.description_string" DEFAULT="">
					<INPUT TYPE="Text" NAME="description_string" STYLE="width: 365px;" VALUE="<CFOUTPUT>#FORM.description_string#</CFOUTPUT>">							
				</TD>
			<cfset currentColCount = currentColCount + 2 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
			<!------ <TD NOWRAP ALIGN="left">
				<B>Sort By</B> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>Order</B><BR> 
				<CFSET sort_By_List="Item,UPC,Type Code,Description,Brand">
				
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 0>
					<CFSET sort_By_List="Item,Type Code,Description,Brand">	
				</cfif></cfif>
				
				<CFOUTPUT>
				<CFSET sort_By_List=ListSort(sort_By_List,"Text")>
				<SELECT ID="sort_by" NAME="sort_by" style="width: 88px;">
				<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
					<CFSET thisItem=Trim(thisItem)>
					<OPTION VALUE="#thisItem#"<CFIF thisItem EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
				</CFLOOP>
				</SELECT>
				</CFOUTPUT>				
				
				<SELECT ID="sort_Order" NAME="sort_Order" style="width: 88px;">
					<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
					<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
				</SELECT>
			</TD> ----->
			<cfset currentColCount = currentColCount + 1 />
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
			<CFIF FORM.DTPS_Program_ID NEQ 0 AND LEN(trim(FORM.DTPS_Program_ID)) NEQ 0>
				<cfparam name="FORM.Rebate_Type_Search_ID" default="0">
				<cfquery name="getRebateTypes" datasource="#Application.Datasource#">
					SELECT     dbo.Contract_Main.Contract_Main_ID, dbo.Program_Control_Panel_Options.Discount_Fixed_Prices, 
					                      dbo.Program_Control_Panel_Options.Discount_Rebates, dbo.Program_Control_Panel_Options.Discount_Growth, 
					                      dbo.Program_Control_Panel_Options.Discount_Lump_Sums, dbo.Program_Control_Panel_Options.Discount_Formula_Pricing
					FROM         dbo.Contract_Main INNER JOIN
					                      dbo.Program_Control_Panel_Options ON 
					                      dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID AND Program_Control_Panel_Options.Deleted = 0
					WHERE     (dbo.Contract_Main.Contract_Main_ID = '#FORM.DTPS_Program_ID#') AND Contract_Main.Deleted=0
				</cfquery>
				
				<TD>
					<B>Search Products From:</B><BR>
					<select name="Rebate_Type_Search_ID" id="Rebate_Type_Search_ID">
						<OPTION value="0" <CFIF FORM.Rebate_Type_Search_ID EQ 0> SELECTED</CFIF>>Default Search</OPTION>
						<CFIF getRebateTypes.Recordcount GT 0>
							<CFIF getRebateTypes.Discount_Fixed_Prices 		EQ 1><OPTION value="1" <CFIF FORM.Rebate_Type_Search_ID EQ 1> SELECTED</CFIF>>Fixed Price		</OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Rebates 			EQ 1><OPTION value="2" <CFIF FORM.Rebate_Type_Search_ID EQ 2> SELECTED</CFIF>>Rebate			</OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Lump_Sums 		EQ 1><OPTION value="3" <CFIF FORM.Rebate_Type_Search_ID EQ 3> SELECTED</CFIF>>Lump Sum			</OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Growth 			EQ 1><OPTION value="4" <CFIF FORM.Rebate_Type_Search_ID EQ 4> SELECTED</CFIF>>Growth			</OPTION></CFIF>
							<CFIF getRebateTypes.Discount_Formula_Pricing 	EQ 1><OPTION value="5" <CFIF FORM.Rebate_Type_Search_ID EQ 5> SELECTED</CFIF>>Formula Pricing	</OPTION></CFIF>
						</CFIF>
					</SELECT>
				</TD>
				<cfset currentColCount = currentColCount + 1 />
			</CFIF>			
			<cfif isNextRow(maxColsPerRow, currentColCount+2) OR isNextRow(maxColsPerRow, currentColCount) OR isNextRow(maxColsPerRow, currentColCount+1)>
			<cfset currentColCount = 0 />
			</TR>
			<TR>
			</cfif>
			<CFIF SHOW_INVOICE_FILTER EQ 1>
				<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
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
								shiptoObj.value = ""
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
						disableDiv("SP_Invoice_Days", bDisable, false);
					}
							
									
					function disableDiv(divName,bDis,bHide)
					{
						oDiv = document.all.item(divName);	
						oDiv.disabled = bDis;
						//oDiv.onmousedown=new Function ("return false");
						var i,itemLen = oDiv.all.length;
						for(i=0;i<itemLen;i++)
						{
							oDiv.all[i].disabled = bDis;
							if((oDiv.all[i].tagName == "INPUT") && bDis)
							{
								oDiv.all[i].style.backgroundColor='cccccc';
							}
							else if((oDiv.all[i].tagName == "INPUT") && !bDis)
							{
								oDiv.all[i].style.backgroundColor='ffffff';
							}
							
							
							if((oDiv.all[i].tagName == "SELECT") && bDis)
							{
								oDiv.all[i].selectedIndex = 0;
								oDiv.all[i].style.backgroundColor='cccccc';
							}
							/*else if((oDiv.all[i].tagName == "SELECT") && !bDis)
							{
								if(oDiv.all[i].options.length > 0) oDiv.all[i].selectedIndex = 0;
							}*/
							if((oDiv.all[i].tagName == "SELECT") && !bDis)
							{
								oDiv.all[i].style.backgroundColor='ffffff';
							}
						}
						var args = arguments;
						var argLen = args.length;
						if(argLen <3)
						{
							return;
						}
						if(args[2])
						{
							oDiv.style.display = "none";
						}
						else
						{
							oDiv.style.display = "";		
						}
						if(argLen <4)
						{
							return;
						}
						var parObj = document.all.item(args[3]);
						
						if(args[2])
						{
							parObj.style.display = "none";
						}
						else
						{
							parObj.style.display = "";
						}
					}
				
					document.body.onload=new Function ("default_Invoice_Days(document.all.Distributor, document.all.Ship_To, 1);")
					
					function searchPrograms() {
						searchResults = window.showModalDialog('/common_files/contracts/program_search_for_component.cfm','','dialogHeight: 600px; dialogWidth: 940px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;');
						if(searchResults != 0 && searchResults.length != 0) {
							document.all.LoadProductsFromThesePrograms.value = searchResults;
							doSearch();						
						}
					}

				</SCRIPT>

				<TD NOWRAP ALIGN="left" COLSPAN="3">
				<TABLE>
					<TR>
					<TD COLSPAN="2">
						<CFPARAM NAME="FORM.Distributor" DEFAULT="0">
						<CFPARAM NAME="FORM.Visible_Distributor" DEFAULT="">
		
						<B>Invoice Entry for: </B> &nbsp;
						<B>
							<FONT COLOR="Red">[</FONT>
							<FONT COLOR="Blue"><A HREF="listDistributor.cfm" onclick="window.showModalDialog(this.href,window,'dialogHeight:210px;dialogWidth:450px;center:yes;edge:raised'); return false;">select <cfoutput>#Lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput></A></FONT>
							<FONT COLOR="Red">]</FONT>
						</B>
				
						<BR>
						<INPUT TYPE="Text" NAME="Visible_Distributor" VALUE="<cfoutput>#FORM.Visible_Distributor#</cfoutput>" style="font:italic;width:350px;background-color:#CCCCCC" READONLY>
						<INPUT TYPE="Hidden" NAME="Distributor" VALUE="<cfoutput>#FORM.Distributor#</cfoutput>" style="width: 350px;">
						<INPUT TYPE="Hidden" NAME="Importallflag"  VALUE="<cfoutput>#FORM.Importallflag#</cfoutput>">
					</TD>
					<TD>
					<CFSET day_List="90,120,180,365">
					<CFPARAM NAME="FORM.Invoice_Days" DEFAULT="">
					<CFOUTPUT>
					<TABLE cellpadding="0" cellspacing="0" border="0">
					<TR>
					<TD>
					<B>#application.returned_customer_setting.shard_ship_to_label#</B><BR>
					<CFPARAM NAME="FORM.Ship_To" DEFAULT="">
					<INPUT TYPE="Text" NAME="Ship_To" SIZE="10" VALUE="<CFOUTPUT>#FORM.Ship_To#</CFOUTPUT>" OnChange="javaScript: default_Invoice_Days(this.form.Distributor, this, 2);">
					&nbsp;
					</TD>
					<TD>
					<B>within</B><BR>
					<SPAN ID="SP_Invoice_Days">
					<SELECT NAME="Invoice_Days" style="width: 50px;">					
						<CFLOOP LIST="#day_List#" DELIMITERS="," INDEX="this_Day">
						<OPTION VALUE="#this_Day#"<CFIF Trim(this_Day) EQ FORM.Invoice_Days> SELECTED</CFIF>>#trim(this_Day)#</OPTION>
						</CFLOOP>
					</SELECT>
					</SPAN>
					<B>days</B>
					</TD></TR>
					</TABLE>					
					</CFOUTPUT>
					</TD>
					</TR>
				</TABLE>
					
				</TD>
				<cfset currentColCount = currentColCount + 3 />			
				</CFIF>
			<cfif isNextRow(maxColsPerRow, currentColCount)>
			</TR>
			<TR>
			</cfif>
				<TD>
				<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
				&nbsp;&nbsp;
				<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="document.all.LoadProductsFromThesePrograms.value='';document.all.Program_ID.value='';doSearch();">search products</a><FONT COLOR="#FF0000">]</FONT></B>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: reset_Form_Fields();">reset</a><FONT COLOR="#FF0000">]</FONT></B><BR>
				<cfif appSettings.getProductSearchGetProductByProgramOn() is not 0>
					<BR>&nbsp;&nbsp;&nbsp;<B><FONT COLOR="##FF0000">[</FONT><a style="cursor: hand;" onclick="searchPrograms()">get products by program</a><FONT COLOR="##FF0000">]</FONT></B>
				</cfif>
				</TD>
			</TR>
			<!---if business segements are on then display--->
			<cfif form.businessSegmentsOn eq 1>
			<tr>
				<td colspan="100%"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:&nbsp;&nbsp;<b><cfoutput>#Bus_Segment_Desc#</cfoutput></b></td>
			</tr>
			</cfif>
		</TABLE>				
		<BR>
</FIELDSET>
</DIV>

<!------ Build Header List ----->
<!------ Type Group ----->
<cfset RemoveTypeGroup = 1>
<cfif application.returned_customer_setting.type_group_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_group_show_column EQ 1><cfset RemoveTypeGroup = 0></cfif></cfif>
<cfif appSettings.getUseProductGroup3() NEQ 1>
	<cfset RemoveTypeGroup = 1>
</cfif>
<!------ Type Code ----->
<cfset RemoveTypeCode = 1>
<cfif application.returned_customer_setting.type_code_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_code_show_column EQ 1><cfset RemoveTypeCode = 0></cfif></cfif>
<cfif appSettings.getUseProductGroup4() NEQ 1>
	<cfset RemoveTypeCode = 1>
</cfif>

<!------ UPC ----->
<cfset RemoveUPC = 1>
<cfif application.returned_customer_setting.UPC_Switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.UPC_Switch EQ 1><cfset RemoveUPC = 0></cfif></cfif>

<CFSET HeaderNameList = "#application.returned_customer_setting.item_label#:Item">

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

<cfif appSettings.getUseProductGroup1()>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "Brand:Brand", ",")>
</cfif>
<cfif appSettings.getUseProductHierarchy()>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "Hierarchy:Product_Hierarchy_Name", ",")>
</cfif>
<cfif appSettings.getClassCodesOn()>
	<cfset HeaderNameList = ListAppend(HeaderNameList, "Class Code", ",")>
</cfif>

<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListLast(ListFirst(HeaderNameList), ":"))#">
<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
<cfoutput>
<INPUT type="Hidden" name="sort_by" value="#FORM.sort_by#">		
<INPUT type="Hidden" name="sort_Order" value="#FORM.sort_Order#">
</cfoutput>

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

<CFQUERY NAME="getCategories" datasource="#application.datasource#">
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

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->



<!--- add product select by rebate type --->
<CFSET List_Of_Rebate_Product_ID = "">
<CFIF isdefined("FORM.Rebate_Type_Search_ID")>
	<cfquery name="getRateTypeProducts" datasource="#Application.Datasource#">
		SELECT     BSA_Foodservice_Items_Master_ID, Product_Type_ID, Contract_Main_ID
		FROM         dbo.Contract_Products
		WHERE     (Deleted = 0) AND (Product_Type_ID = '#FORM.Rebate_Type_Search_ID#') AND (Contract_Main_ID = '#FORM.DTPS_Program_ID#')
	</cfquery>
	<CFSET List_Of_Rebate_Product_ID = ListQualify(ValueList(getRateTypeProducts.BSA_Foodservice_Items_Master_ID), "'")>
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFIF FORM.FirstTimeLoading EQ "FALSE">
<!--- <cffile action="READ" file="#apppath##application.returned_customer_setting.qry_product_search_location#" variable="qry_product_search_query"> --->

<!--- <cfset temp = replace(qry_product_search_query, "##","####", "ALL")> --->

<cfset FORM.Item_Number = trim(replace(FORM.Item_Number, "'", "''", "all"))>
<cfset FORM.Description_String = trim(replace(FORM.Description_String, "'", "''", "all"))>

<cfif isdefined("form.LoadProductsFromThesePrograms")>
	<cfif listlen(form.LoadProductsFromThesePrograms) GT 0>
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

<cfset stStruct = Form>
<cfset stStruct.appSettings = appSettings>
<cfif appSettings.getUseProductHierarchy()>
	<cfset stStruct.productHierarchyLevelList = productHierarchyLevelList>
	<cfset stStruct.maxProductHierarchyLevel = maxProductHierarchyLevel>
</cfif>
<cfif restrictOnProductGroup>	
	<cfset stStruct.restrictOnProductGroup = restrictOnProductGroup>
	<cfset stStruct.restrictOnProductGroupList = restrictOnProductGroupList>
	<cfset stStruct.approvalGroupType = approvalGroupType>
</cfif>
<cfset stStruct.Line_Of_Business_ID 	= Form.Line_Of_Business_ID>
<cfset stStruct.List_Of_Rebate_Product_ID = List_Of_Rebate_Product_ID>
<cfset stStruct.UserClassCodes = UserClassCodes>
<cfset stStruct.categoryList = categoryList />
<cfset stStruct.SHOW_INVOICE_FILTER = SHOW_INVOICE_FILTER>
<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset searchProducts = productManager.search(stStruct)>

<CFELSE>
	<CFSET SEARCHPRODUCTS = QueryNew("Item")>
</CFIF>
<DIV ALIGN="center">
<FIELDSET STYLE="padding:8px; width: 760px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF searchProducts.recordcount EQ 1>is <CFELSE>Are</CFIF> <CFOUTPUT>#searchProducts.recordcount#</CFOUTPUT> <CFIF searchProducts.recordcount EQ 1>Product<CFELSE>Products</CFIF> That <CFIF searchProducts.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Supplied Criteria</LEGEND>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>

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
<!--- compare all list with finalupclist, append those who are not in the all list but in the finalupclist --->
	<CFLOOP INDEX="ListItem" LIST="#FORM.FinalUPCList#" DELIMITERS=",">
		<CFIF listfind(allList, ListItem, ",") EQ 0>
			<CFSET allList = listappend(allList, ListItem, ",")>
		</CFIF>
	</CFLOOP>
	<script>
		if (document.all.SearchForm.Importallflag.value == 1) {
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Product_List.value = '<CFOUTPUT>#allList#</CFOUTPUT>' }
		else {
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Product_List.value = '<CFOUTPUT>#Form.FinalUPCList#</CFOUTPUT>' }
		if(opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Sort_By)
		{
			opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Sort_By.value = '<CFOUTPUT>#Form.Sort_By#</CFOUTPUT>'
		}
		if(<cfoutput>#form.SudmitFormViaSubmitButton#</cfoutput> == 0){
		<cfif appSettings.getAllowNavigate()>
		if(opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.navigate)
		{
			<cfset listcompared1 = ListCompare(Form.FinalUPCList,Form.ExistingProductList)>
			<CFSET listcompared2 = ListCompare(Form.ExistingProductList,Form.FinalUPCList)>
			<cfif listlen(listcompared1) GT 0 OR listlen(listcompared2) GT 0>
				opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.navigate.value = 1;
			</cfif>
		}
		if(opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.stopnavigate)
		{
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.stopnavigate.value = 1;
		}
		</cfif>
			opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		}
		else {
			opener.document.all.<CFOUTPUT>#Form.ParentFormname#</cfoutput>.submitbutton.click();
		}
		
		window.close()		
	</script>
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
		<TD ID="header"><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header_value#','#New_Sort_Order#');">#this_Header#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
		</CFLOOP>
		</CFOUTPUT>
	</TR>
	<CFIF FORM.FirstTimeLoading EQ "TRUE">
	<TR>
		<TD COLSPAN="100%" ALIGN="center"><BR><font SIZE="+1" color="red">Please Enter Your Product Criteria</font><BR><BR></TD>
	</TR>
	</CFIF>
	
	
	<cf_Number_of_Rows maxrows= #Records_To_Show# >
	<CFSET FORM.AlreadySelectedItems = "">

	<CFOUTPUT QUERY="searchProducts" startrow="#StartRow#" maxrows="#MaxRows#">
		<cfset popupCode = " ONCLICK=""profilePopup('product', '#BSA_Foodservice_Items_Master_ID#')"" style=""cursor: hand;""">
		<CFIF listfindnocase(FORM.ProductListToExcludeFromSelecting,searchProducts.BSA_Foodservice_Items_Master_ID) EQ 0>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD ALIGN="right">#currentrow#</TD>
				<TD>
				<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
					<span ID="checkAllProducts"><input TYPE="checkbox" NAME="selectedUPCS" VALUE="#BSA_Foodservice_Items_Master_ID#" <CFIF listfind(Form.FinalUPCList,BSA_Foodservice_Items_Master_ID)> CHECKED<CFSET FORM.AlreadySelectedItems = listappend(AlreadySelectedItems,BSA_Foodservice_Items_Master_ID,",")></CFIF> ONCLICK="if(!this.checked) document.all.checkall.checked = false;"></SPAN>
				<CFELSE>
					<INPUT type="Radio" NAME="selectedUPCS" VALUE="#BSA_Foodservice_Items_Master_ID#" <CFIF listfind(FORM.FinalUPCList,BSA_Foodservice_Items_Master_ID) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems,BSA_Foodservice_Items_Master_ID,",")></CFIF>>
				</CFIF>
				</TD>
		<CFELSE>
			<TR BGCOLOR="silver">
				<TD ALIGN="right">#currentrow#</TD>
				<TD><input TYPE="checkbox" CHECKED DISABLED></TD>				
		</CFIF>		
			<TD #popupCode#>#Item#&nbsp;</TD>
			<cfif RemoveUPC EQ 0><TD #popupCode#>#UPC#&nbsp;</TD></cfif>
			<TD #popupCode#>#Description#&nbsp;</TD>
			<cfif RemoveTypeGroup EQ 0><TD #popupCode#>#Type_Group_Desc#&nbsp;</TD></cfif>
			<cfif RemoveTypeCode EQ 0><TD #popupCode#>#Type_Code_Desc#&nbsp;</TD></cfif>
			<cfif appSettings.getUseProductGroup1()><TD #popupCode#>#Brand_Name#&nbsp;</TD></cfif>
			<cfif appSettings.getUseProductHierarchy()><TD #popupCode#>#Product_Hierarchy_Name#&nbsp;</TD></cfif>
			<cfif appSettings.getClassCodesOn()><TD #popupCode#>#Class_Code_Desc#&nbsp;</TD></cfif>
		</TR>
		<CFFLUSH>
	</CFOUTPUT>
</TABLE>

</FIELDSET>
<CFIF searchProducts.recordcount GT 0>
<!--- <HR COLOR="Orange" SIZE="2" WIDTH="760px"> --->
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
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

<DIV ALIGN="left">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<cfif searchProducts.recordcount GT 0 and FORM.SelectSingleSearchResultOnly EQ 0>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a STYLE="cursor: hand;" onClick="importAllProducts(<CFOUTPUT>#searchProducts.recordcount#</CFOUTPUT>)"> import all returned products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a STYLE="cursor: hand;" onClick="removeAllProducts()"> remove all selected products </a><FONT COLOR="#FF0000">]</FONT></B>
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
	<INPUT TYPE="Hidden" NAME="Program_ID"							VALUE="#Program_ID#">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID"  					VALUE="#FORM.DTPS_Program_ID#">
	<INPUT TYPE="Hidden" NAME="Bid_Rule_In_Effect" 					VALUE="#FORM.Bid_Rule_In_Effect#">
	<INPUT TYPE="Hidden" NAME="SudmitFormViaSubmitButton"  			value="#form.SudmitFormViaSubmitButton#">
	<INPUT TYPE="Hidden" NAME="Only_Show_Products_From_These_Groups"  VALUE="#form.Only_Show_Products_From_These_Groups#">
	<INPUT TYPE="Hidden" NAME="LoadProductsFromThesePrograms"  		VALUE="#form.LoadProductsFromThesePrograms#">
	<INPUT TYPE="hidden" NAME="passed_form" 						VALUE="#form.passed_form#">
	<INPUT TYPE="hidden" NAME="itemList" 							VALUE="#form.itemList#">
	<input type="hidden" name="SelectSingleSearchResultOnly"		value="#Form.SelectSingleSearchResultOnly#">	
	<INPUT TYPE="hidden" NAME="Line_Of_Business_ID" 				VALUE="#form.Line_Of_Business_ID#">
</CFOUTPUT>

</FORM>
<SCRIPT>
	<cfif searchProducts.recordcount GT 0>
		function importAllProducts(recordcount){
			var recordcount = <CFOUTPUT>#ListLen(allList)#</CFOUTPUT>;
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				document.all.checkall.checked = true;
				document.all.checkall.fireEvent("onclick");
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
				document.all.checkall.checked = false;
				document.all.checkall.fireEvent("onclick");
				
				document.SearchForm.finishedselectingproducts.value = 0;
				document.SearchForm.FinalUPCList.value 	= "";
				document.SearchForm.AlreadySelectedItems.value 	= "";
			}
			else
			{
			
			}
		}		
	</cfif>
</SCRIPT>


</BODY>
</HTML>