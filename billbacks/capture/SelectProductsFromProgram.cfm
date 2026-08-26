<CFPARAM NAME="URL.FromBBProgProdForm" DEFAULT="">
<CFPARAM NAME="URL.PayeeID" DEFAULT="">
<CFPARAM NAME="DiscountList" default="">
<CFPARAM name="url.Business_Segment_ID" default="0">
<CFPARAM name="FORM.Business_Segment_ID" default="#url.Business_Segment_ID#">
<CFPARAM name="url.businessSegmentsOn" default="0">
<CFPARAM name="form.businessSegmentsOn" default="#url.businessSegmentsOn#">

<CFIF isdefined("URL.FormName")>
	<cfparam name="URL.PID" default="">
	<FORM ACTION="SelectProductsFromProgram.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="ExistingProductList" TYPE="hidden" VALUE="">
		<INPUT NAME="ProductListToExcludeFromSelecting" TYPE="Hidden" VALUE="">
		<INPUT NAME="Sort_By" TYPE="Hidden" VALUE="Item">
		<INPUT NAME="Program_ID" TYPE="Hidden" VALUE="<cfoutput>#URL.PID#</cfoutput>">
		<INPUT TYPE="Hidden" NAME="FromBBProgProdForm" VALUE="<CFOUTPUT>#URL.FromBBProgProdForm#</CFOUTPUT>">
		<INPUT TYPE="Hidden" NAME="PayeeID" VALUE="<CFOUTPUT>#URL.PayeeID#</CFOUTPUT>">
		<INPUT TYPE="Hidden" NAME="BBID" VALUE="<CFOUTPUT>#URL.BBID#</CFOUTPUT>">
		<INPUT TYPE="Hidden" NAME="PayType" VALUE="<CFOUTPUT>#URL.PayType#</CFOUTPUT>">
		<input type="Hidden" name="DiscountList" value="<cfoutput>#DiscountList#</cfoutput>">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.ExistingProductList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ExistingProductList.value

			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ProductListToExcludeFromSelecting != null){
				this.document.all.ProductListToExcludeFromSelecting.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ProductListToExcludeFromSelecting.value
			}
		//	payee_id
			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterDataList != null){
				this.document.all.PayeeID.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterDataList.value
			}
			
			if(opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Sort_By)
			{
				this.document.all.Sort_By.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Sort_By.value;				
			}
			
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()

		}
	</script>
	<cfabort>
</CFIF>

<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">

<cfset ProdSearchSettingsManager 	= CreateObject("component", "components.settings.Labels.Labels").init() />
<cfset ProdSearchResultsColumnsDisplaySettings = ProdSearchSettingsManager.getProductSearchFieldsDisplayStatus()>
<cfset ProdSearchResultsColumnsDisplayAdditionalSettings = ProdSearchSettingsManager.getProductStaticSearchFieldsDisplayStatus() />

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<!--- D41328 ::  Prod Event 5457 [Element FILTERDATALIST is undefined in FORM]--->
<cfif businessSegManager.isEnabledForProduct() AND isDefined("Form.Program_ID")>
	<cfset form.businessSegmentsOn = 1 />
	<cfset form.Business_Segment_Id = businessSegManager.getSegmentIdByProgram(Form.Program_ID) />
</cfif>
<!--- D41328 ::  Prod Event 5457 [Element FILTERDATALIST is undefined in FORM]--->
<cfif isDefined("Form.Program_ID")>

<cfset Billback_Contract_Main_ID = Form.Program_ID>
	<cfquery name="getParentIDs" datasource="#application.datasource#">
		select	*
		from	dbo.udf_program_revision_detail(#Form.Program_ID#)
		ORDER By Contract_Main_ID
	</cfquery>
	
	<CFSET getParentIDs_List = valuelist(getParentIDs.contract_main_id)>
	<!------ keep the original one program id, because next statement may set it with alist pf programs ids ----->
	<cfset OriginalProgram_ID = FORM.Program_ID>
	<!--- D19654: billback product search returing all items
	If no program found, set it to 0 so that 0 products are returned instead of all products --->
	<cfif getParentIDs_List eq "">
		<cfset FORM.Program_ID = 0 />
	<cfelse>
		<cfset FORM.Program_ID = getParentIDs_List />	
	</cfif>
	
</cfif>
<cfset Calling_Page = "Highlight">

<!--- include the eligible product queries --->
<cfinclude template="inc_eligible_products.cfm">

<CFSET PAGE_TITLE= "Product Search">

<!--- PRODUCT LIST MAINTAINENCE --->
<CFPARAM NAME="FORM.SelectedUPCS" DEFAULT="">
<CFPARAM NAME="FORM.FinalUPCList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingproducts" DEFAULT="0">
<CFPARAM NAME="FORM.LoadExistingProductList" DEFAULT="1">
<CFPARAM NAME="FORM.ExistingProductList" DEFAULT="">
<CFPARAM NAME="FORM.FirstTimeLoading" DEFAULT="TRUE">
<CFPARAM NAME="FORM.ProductListToExcludeFromSelecting" DEFAULT="">
<CFPARAM NAME="FORM.FromBBProgProdForm" 		DEFAULT="">
<CFPARAM NAME="FORM.theFinalUPCList" DEFAULT="">

<cfset variables.custList = "">
<!---<cfset form.FinalUPCList = "">--->
<cfsilent>
<CFSET listofitemstodelete = "">
<!--- loop through the pages selected items and if it is not in the selected list that means it was removed to queue it for deletetion --->
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfindnocase(FORM.SelectedUPCS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>
<!--- if a selected item isnt already in the final list then add it  --->
<!--- Put the lsist of products in order...first get a list of valid customers --->
<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedUPCS#" DELIMITERS=",">
	<cfset variables.temp = "form.CUSTSEL_" & replace(listitem,"-","_","all")>
	<CFIF isdefined("#variables.temp#")>
		<cfloop list="#evaluate(variables.temp)#" index="cust" delimiters=",">
				<CFIF listfindnocase(variables.custList, cust, ",") EQ 0>
					<cfset variables.custList = listappend(custList,cust)>
				</CFIF>
		</cfloop> 
	</CFIF>
</CFLOOP> 

	<!--- 	Now loop through the customers and create the list of Items to be added to the program.
			This helps the display on program form since these items are displayed before being inserted into the db (can't use sort by) 
	--->
<CFLOOP INDEX="cust" LIST="#variables.custList#" DELIMITERS=",">
	<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedUPCS#" DELIMITERS=",">
		<cfset variables.temp = "form.CUSTSEL_" & replace(listitem,"-","_","all")>
		<CFIF isdefined("#temp#")>
			<CFIF listfindnocase(evaluate(variables.temp),cust)>
				<cfset variables.ListItem2 = ListItem ><!--- & "|" & cust --->
				<CFIF listfindnocase(Form.FinalUPCList, variables.ListItem2, ",") EQ 0>  <!---If the item is not already on the final list then add it--->
					<CFSET Form.FinalUPCList = listappend(FinalUPCList, variables.ListItem2, ",")>
				</CFIF>
			</CFIF>
		</CFIF>
	</CFLOOP>
</CFLOOP> 
<!--- end of add item loops --->

<!--- delete the queued products --->
<!--- since FORM.FinalUPCList is a list of value pairs [item_master_Id|customer_id] seperated by a "|"
we need to loop through to see which value pairs to delete.  the #listofitemstodelete# is a list of item_id's only --->
<CFLOOP INDEX="DelItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFLOOP INDEX="FinItem" LIST="#FORM.FinalUPCList#" DELIMITERS=",">
		<cfset FinItemNum = FinItem><!--- gettoken(FinItem,1,"|")> --->
		<CFIF FinItemNum eq DelItem>
			<CFSET Form.FinalUPCList = listdeleteat(FORM.FinalUPCList, listfindnocase(FORM.FinalUPCList,FinItem, ","), ",")>
		</CFIF>
	</CFLOOP>
</CFLOOP>



	<CFLOOP INDEX="upc" LIST="#FORM.ExistingProductList#" DELIMITERS=",">
		<CFSET Form.theFinalUPCList = listappend(theFinalUPCList, upc, ",")> <!--- gettoken(upc,1,"|") ---><!--- separate value pairs to get a list of item_master_id's theFinalUPCList --->
	</CFLOOP>
<CFIF FORM.LoadExistingProductList EQ 1>
	<CFSET Form.FinalUPCList = FORM.ExistingProductList>
</CFIF>
</cfsilent>


<!--- ****************************************************************** --->
<!---<cfoutput>#Form.FinalUPCList#::::::::::</cfoutput>--->
<CFIF FORM.finishedselectingproducts EQ 1>


<!--- If there's already values, you need to delete them --->
<cfquery name="DeletePriorValues" datasource="#application.datasource#">
DELETE FROM BB_Product_Discount
WHERE Billback_ID = '#Billback_ID#'
AND Program_ID = '#OriginalProgram_ID#'
</cfquery>
<cfif len(trim(Form.TheFinalUPCList)) EQ 0 AND len(trim(form.selectedUPCs)) GT 0>
	<cfset Form.TheFinalUPCList = form.selectedUPCs>
</cfif>

<!--- D12106 Find valid discount types --->
<cfloop list="#FinalUPCList#" index="ProductID">
	 <cfset Product_ID = left(ProductID, 36)>
	<cfset DiscountList = "">

	<cfset useLakebaseForDiscountsForProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alleligibleproducts")>
<cfif useLakebaseForDiscountsForProduct>
	<cftry>
		<cfset DiscountsForProduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alleligibleproducts", {
				"product_id" = "eq.#Product_ID#",
				"select" = "discounttypeid"
			}), "discounttypeid"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDiscountsForProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDiscountsForProduct>
<cfquery name="DiscountsForProduct" dbtype="query">
		SELECT DISTINCT DiscountTypeID
		FROM AllEligibleProducts
		WHERE Product_ID = '#Product_ID#'
	</cfquery>
</cfif>
	
	<cfif DiscountsForProduct.Recordcount GT 0>
		<cfset DiscountList = valuelist(DiscountsForProduct.DiscountTypeID)>
	</cfif>
	
	<cfset useLakebaseForInsertIntoTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_product_discount")>
<cfif useLakebaseForInsertIntoTable>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_product_discount", {
			"discount_list" = "#DiscountList#",
			"product_id" = "#Product_ID#",
			"billback_id" = "#Billback_ID#",
			"program_id" = "#OriginalProgram_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoTable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoTable>
<cfquery name="InsertIntoTable" datasource="#application.datasource#">
	INSERT INTO BB_Product_Discount
	(
		Discount_List,
		Product_ID,
		Billback_ID,
		Program_ID
	)
	VALUES
	(
		'#DiscountList#',
		'#Product_ID#',
		'#Billback_ID#',
		#OriginalProgram_ID#
	)
	</cfquery>
</cfif> 

</cfloop>

	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Product_List.value = '<CFOUTPUT>#Form.FinalUPCList#</CFOUTPUT>'
		if(opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Sort_By)
		{
			opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Sort_By.value = '<CFOUTPUT>#Form.Sort_By#</CFOUTPUT>'
		}
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<cfabort>
</CFIF>

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
			width:240px;
			font-size :10px; 
		}
	</STYLE>
	<script>
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
			document.all.SearchForm.submit()
		}
		function finishedSearching() {
			document.all.finishedselectingproducts.value = 1
			document.all.SearchForm.submit();
		}
		
		
		function verifyClose() {
			if(document.all.startrow.value == <CFOUTPUT>#StartRow#</CFOUTPUT> && document.all.finishedselectingproducts.value != 1 && isSearching != 1){
				event.returnValue='Product selections you have not saved will be lost.'
			}
		}
		
		function gotoAllProducts()
		{
			isSearching = 1;
			ExistingProductList = document.all.ExistingProductList.value;
			//urlLocation = "/common_files/contracts/product_Select_V1.cfm?Formname=KnownProgramForm&ExistingProductList="+ExistingProductList+"&LoadExistingProductList=1&ItemForm="+ExistingProductList;
			urlLocation = "/common_files/contracts/product_Select_V1.cfm?Formname=KnownProgramForm&LoadExistingProductList=1&businessSegmentsOn=<cfoutput>#form.businessSegmentsOn#</cfoutput>&Business_Segment_Id=<cfoutput>#form.Business_Segment_Id#</cfoutput>&DTPS_Program_ID=<cfoutput>#OriginalProgram_ID#</cfoutput>&CallingPage=Billbacks";
			document.location = urlLocation;
		}
		
		function selectAll()
		{
			if(window.checkAllProducts != null)
			{
				if(checkAllProducts.length)
					{
						for(var x=0; x<checkAllProducts.length;x++)
						{
							box = getFirstChild(checkAllProducts[x])
							box.checked = document.all.checkall.checked
						}
					}
				else
					{
						box = getFirstChild(window.checkAllProducts)
						box.checked = document.all.checkall.checked					
					}
			}
			
		}
		function selectAllCusts()
		{
			if(window.checkAllProducts != null)
			{
				if(checkAllCusts.length)
					{ 
						for(var x=0; x<checkAllCusts.length;x++)
						{ 
							box = getFirstChild(checkAllCusts[x])
							box.checked = document.all.allCustsCheck.checked
							var tmpSel = "custSel_" + box.value;
							var tmpChk = box.id;
							SelectallCust(tmpSel,tmpChk);
						}
					}
				else
					{
						box = getFirstChild(window.checkAllCusts)
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
			formObj.sort_order.value = thisSortOrder;
			if(formObj.frompage.value.length == 0)	formObj.frompage.value = 1;
			if(formObj.startrow.value.length == 0)	formObj.startrow.value = 1;
			formObj.submit();
			return false;
		}	
		
		function SelectallCust(item,chkItem)
		{
			var tempObj = document.getElementById(item);
			var tempChk = document.getElementById(chkItem);
			for (i=0;i<tempObj.length;i++)
				{ 
					if(tempChk.checked == true) 
						{
						tempObj.options[i].selected = true;
						}
				   	else 
						{
						tempObj.options[i].selected = false;
						}
				}
		}
 		
	</script>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="initPage()" ONBEFOREUNLOAD="verifyClose()">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type groups																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Type_Group_Desc
	WHERE len(Type_Group_Desc) != 0
	ORDER BY Type_Group_Desc
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get QBrands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetQBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Q_Brand_Desc
	WHERE len(Q_Brand) != 0
	ORDER BY Q_Brand
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type codes																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Type_Code_Desc
	WHERE len(Type_Code_Desc) != 0
	ORDER BY Type_Code_Desc
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get brands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Brand
	WHERE len(brand_name) !=0
	ORDER BY Brand_Name
</CFQUERY>


<FORM ACTION="SelectProductsFromProgram.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" ONKEYPRESS="if(event.keyCode == 13) doSearch()">
<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="FromBBProgProdForm" VALUE="#FORM.FromBBProgProdForm#">
</CFOUTPUT>
<br>&nbsp;&nbsp;&nbsp;<B>

<cfset useLakebaseForGetLinesOfBiz = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("line_of_business")>
<cfif useLakebaseForGetLinesOfBiz>
	<cftry>
		<cfset GetLinesOfBiz = application.oLakebase.toQuery(
			application.oLakebase.selectRows("line_of_business", {
				"order" = "line_of_business_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLinesOfBiz = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLinesOfBiz>
<cfquery name="GetLinesOfBiz" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Line_Of_Business
	ORDER BY Line_Of_Business_Name
</cfquery>
</cfif>

<CFQUERY NAME="getFoodserviceLOBID" DBTYPE="query">
	SELECT Line_Of_Business_ID
	FROM GetLinesOfBiz
	WHERE Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#) 
</CFQUERY>
<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="#ValueList(getFoodserviceLOBID.Line_Of_Business_ID, ",")#">


<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
<CFPARAM NAME="FORM.Product_Status" DEFAULT="A">
<CFPARAM NAME="FORM.Brand_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Type_Code_Desc_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Type_Group_Desc_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Q_Brand_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Type_Group_Desc_ID" DEFAULT="0">
<CFPARAM NAME="FORM.DESCRIPTION_STRING" DEFAULT="">
<CFPARAM NAME="FORM.ITEM_NUMBER" DEFAULT="">
<CFPARAM NAME="FORM.UPC_NUMBER" DEFAULT="">
<CFPARAM NAME="FORM.sort_order" DEFAULT="ASC">



<CFQUERY NAME="getCategories" datasource="#application.datasource#">
	SELECT Category_ID
	FROM Category
	WHERE Category IN (#ListQualify(application.returned_customer_setting.Category_List, "'", ",")#)
</CFQUERY>

<cfset categoryList = listqualify(valuelist(getCategories.Category_ID), "'", ",")>

<!--- sort is handled inside the productmanager component search function --->

<CFSET FORM.FirstTimeLoading = "FALSE">
<CFIF FORM.FirstTimeLoading EQ "FALSE">
<!--- get bb distributor(s) --->
<cfset billbackDevManager = CreateObject("component", "components.billback.BillbackDeviationManager") />
<cfset getDistInfo = billbackDevManager.getBillbackDistributorList(form.BBID,form.payType) />
 <!---no ship to...enter a 0 record--->
<cfif getDistInfo.RecordCount eq 0>
	<cfset qTemp =  QueryAddRow(getDistInfo)>
	<cfset qTemp = QuerysetCell(getDistInfo, 'BSA_Foodservice_Customers_ID','00000000-0000-0000-0000-000000000000')>
	<!---<cfset qTemp = QuerysetCell(getDistInfo, 'name','')>
	<cfset qTemp = QuerysetCell(getDistInfo, 'ship_to','0')>--->
</cfif>
<!------ Get Billback Information ----->

	
	<cfset FORM.Type_Group_Desc_ID 	= 0>
	<cfset FORM.Type_Code_Desc_ID 	= 0>
	<cfset FORM.Q_Brand_ID 			= 0>
	<cfset FORM.Line_Of_Biz 		= 0>
	<cfset FORM.Brand_ID 			= 0>
	<cfset FORM.Line_Of_Biz 		= 0>
	<cfset FORM.Product_Status 		= 0>
	<cfset FORM.Description_String 	= "">
	<cfset FORM.item_number 		= "">
	<cfset FORM.upc_number 			= "">
	<cfset SHOW_INVOICE_FILTER 		= 0>
	<cfset getLOBCharacter.Line_Of_Business = "">
	<cfset FORM.Rebate_Type_Search_ID = 0>
	
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	<cfset stStruct = Form>
	<cfset stStruct.appSettings = appSettings>
	<cfset stStruct.ignoreMasterDeleted = 1>
	<cfif getDistInfo.recordcount lt 4>
		<cfset selectSize = getDistInfo.recordcount>
	<cfelse>
		<cfset selectSize = 4>
	</cfif>
	<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
	
	<cfset searchProducts = productManager.search(stStruct)>

<CFELSE>
	
	<CFSET SEARCHPRODUCTS = QueryNew("Item")>
</CFIF>

<!------ reset the progran id to the original one program id, because now it may be a list of program iss ----->
<cfset FORM.Program_ID = OriginalProgram_ID>
<div align="right">

	<CF_smallLink 
	title = "all products" 
	url = "##"
	parameters = "onClick=""javascript: return gotoAllProducts();"""
>
</div> 

<!--- Search page using keyword(s). --->
<CFINCLUDE TEMPLATE="/includes/Search_on_Page.cfm">

<CFIF appSettings.getUseProductHierarchy() AND FORM.FromBBProgProdForm EQ 1>
<CFELSE>
<FIELDSET ALIGN="Center"  STYLE="padding:8px; width: 760px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF searchProducts.recordcount EQ 1>is <CFELSE>are </CFIF> <CFOUTPUT>#searchProducts.recordcount#</CFOUTPUT> <CFIF searchProducts.recordcount EQ 1>product<CFELSE>products</CFIF> on this program. Check those on the billback.</LEGEND>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>

<!------------------------------ Get all list - exclude list -------------------------------------->
<CFIF appSettings.getUseProductHierarchy() AND FORM.FromBBProgProdForm EQ 1>	
<CFELSE>
	<CFIF searchProducts.recordCount GT 0>
		<cfset allList = "">
		<CFSET theList=ValueList(searchProducts.BSA_Foodservice_Items_Master_ID)>
		<CFLOOP LIST="#theList#" INDEX="x">
			<cfset allList = listappend(allList,x)><!--- &"|"&Form.PayeeId)> --->
		</CFLOOP>
		<CFSET excludeList=FORM.ProductListToExcludeFromSelecting>
		<CFLOOP LIST="#excludeList#" INDEX="item">
			<CFSET excludePos=ListFindNoCase(allList,item)><!--- GetToken(item,1,"|"),",")> --->
			<CFIF excludePos GT 0>
				<CFSET allList=ListDeleteAt(allList, excludePos, ",")>
			</CFIF>
		</CFLOOP>
	<CFELSE>
		<CFSET allList="">
	</CFIF>
</CFIF>
<!------------------------------ Get all list - exclude list -------------------------------------->

	<TABLE CLASS="Maintable" <CFIF appSettings.getUseProductHierarchy() AND FORM.FromBBProgProdForm EQ 1>WIDTH="600" ALIGN="Center"<CFELSE>WIDTH="100%"</CFIF> CELLPADDING="0" CELLSPACING="0">
		<TR BGCOLOR="FFCE84">
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" WIDTH="1"><input TYPE="checkbox" NAME="checkall" ID="checkall" ONCLICK="selectAll()"></TD>
			<CFIF appSettings.getUseProductHierarchy() AND FORM.FromBBProgProdForm EQ 1>
				<CFSET HeaderNameList = "Prod Hierarchy,Prod Hierarchy Name">
			<CFELSE>
				<cfif (appSettings.get_Setting('Display_Item_No') EQ '1')>
					<CFSET HeaderNameList = "#application.returned_customer_setting.item_label#,#application.returned_customer_setting.upc_label#,Description,Type_Code_Desc,Type_Group_Desc,Brand"><!---,#application.returned_customer_setting.Shard_Ship_To_Label#--->
				<cfelse>
					<CFSET HeaderNameList = "#application.returned_customer_setting.upc_label#,Description,Type_Code_Desc,Type_Group_Desc,Brand"><!---,#application.returned_customer_setting.Shard_Ship_To_Label#--->
				</cfif>	
			</CFIF>

			<CFSET showHideColumnsSetting()>

			<cfset RemoveUPC = 1>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfif ProdResults_DisplayUPC eq 1><CFSET RemoveUPC = 0></cfif></cfif></cfif>
	
			<!--- if setting says, remove UPC from header list --->
			<cfif RemoveUPC EQ 1>
				<cfset temp = listfindnocase(lcase(HeaderNameList), "upc")>
				<cfif temp gt 0>
					<cfset HeaderNameList = ListDeleteAt(HeaderNameList,temp)>
				</cfif>
			</cfif> 
	
			<cfset RemoveTypeGroup = 1>
			<cfif application.returned_customer_setting.type_group_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_group_show_column EQ 1><cfif ProdResults_DisplayTypeGroup eq 1><cfset RemoveTypeGroup = 0></cfif></cfif></cfif>
			
			<cfif RemoveTypeGroup EQ 1>
				<cfset temp = listfindnocase(HeaderNameList, "Type_Group_Desc")>
				<cfif temp gt 0>
					<cfset HeaderNameList = ListDeleteAt(HeaderNameList,temp)>
				</cfif>
			</cfif> 
			
			<cfset RemoveTypeCode = 1>
			<cfif application.returned_customer_setting.type_code_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_code_show_column EQ 1><cfif ProdResults_DisplayTypeCode eq 1><cfset RemoveTypeCode = 0></cfif></cfif></cfif>
			
			<cfif RemoveTypeCode EQ 1>
				<cfset temp = listfindnocase(HeaderNameList, "Type_Code_Desc")>
				<cfif temp gt 0>
					<cfset HeaderNameList = ListDeleteAt(HeaderNameList,temp)>
				</cfif>
			</cfif> 
			
			<cfset RemoveBrand = 1>
			<cfif ProdResults_DisplayBrand eq 1>
				<cfset RemoveBrand = 0>
			</cfif>

			<cfif RemoveBrand EQ 1>
				<cfset temp = listfindnocase(HeaderNameList, "Brand")>
				<cfif temp gt 0>
					<cfset HeaderNameList = ListDeleteAt(HeaderNameList,temp)>
				</cfif>
			</cfif> 
			
			<cfoutput>
			<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
			<CFSET sortImage="">				
				<CFIF this_Header EQ Form.SORT_BY>
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
					<TD ID="header" align="left" <cfif this_Header eq application.returned_customer_setting.Shard_Ship_To_Label> colspan="2"</cfif>>
						<!---The select all Customers check Box--->
						<cfif this_Header EQ application.returned_customer_setting.Shard_Ship_To_Label and getDistInfo.recordcount neq 1>
							<input TYPE="checkbox" NAME="allCustsCheck" ONCLICK="selectAllCusts()">
						</cfif>
						<cfset this_header_label = this_Header />
						<cfswitch expression="#this_Header#">
							<cfcase value="Type_Code_Desc">
								<cfset this_header_label = application.returned_customer_setting.type_code_label_singular />
							</cfcase>							
							<cfcase value="Type_Group_Desc">
								<cfset this_header_label = application.returned_customer_setting.type_group_label_singular />
							</cfcase>
							<cfcase value="Brand">
								<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
								<cfset this_header_label = ProductGroupAttributeManager.getProductGroupLabel(groupLevelId=13) />
							</cfcase>
						</cfswitch>
						<A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');">#this_header_label#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A>
					</TD>
			</CFLOOP>
				</cfoutput>
		</TR>
		<CFIF FORM.FirstTimeLoading EQ "TRUE">
		<TR>
			<TD COLSPAN="100%" ALIGN="center"><BR><font SIZE="+1" color="red">Please Enter Your Product Criteria</font><BR><BR></TD>
		</TR>
		</CFIF>
	
		<cf_Number_of_Rows maxrows=100>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFSET ProductGroupCount = 0>
		<cfset tmpItem = 1>
		<CFIF appSettings.getUseProductHierarchy() AND FORM.FromBBProgProdForm EQ 1>			
			<CFSET allList="">
			
			<CFOUTPUT QUERY="searchProducts" GROUP="Product_Hierarchy_ID" startrow="#StartRow#" maxrows="#MaxRows#">
				<cfset tmpname = replace(Product_Hierarchy_ID,"-","_","all")>
				<CFSET allList = LISTAPPEND(allList,Product_Hierarchy_ID,",")>
				<cfset tmpItm = Product_Hierarchy_ID>
				<CFSET ProductGroupCount = ProductGroupCount + 1>
								
				<TR BGCOLOR="#IIf(ProductGroupCount Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD ALIGN="right">#ProductGroupCount#</TD>
					<TD><span ID="checkAllProducts"><input TYPE="checkbox" NAME="selectedUPCS" VALUE="#Product_Hierarchy_ID#" <CFIF listfindnocase(Form.FinalUPCList,Product_Hierarchy_ID)> CHECKED<CFSET FORM.AlreadySelectedItems = listappend(AlreadySelectedItems, Product_Hierarchy_ID,",")></CFIF> ONCLICK="if(!this.checked) document.all.checkall.checked = false;"></SPAN></TD>
					<TD>#Product_Hierarchy#</TD>
					<TD>#Product_Hierarchy_Name#&nbsp;</TD>

					<cfloop query="getDistInfo">
						<INPUT TYPE="Hidden" NAME="custSel_#tmpname#" VALUE="#getDistInfo.BSA_FOODSERVICE_CUSTOMERS_ID#">
					</cfloop>
			
				</TR>
				<CFSET Item_List = "">
				<CFOUTPUT>
					<CFSET Item_List = ListAppend(Item_List,BSA_Foodservice_Items_Master_ID)>				
				</CFOUTPUT>		
				
				<INPUT TYPE="Hidden" NAME="Items_In_#OriginalProgram_ID#_ProdGrp_#Product_Hierarchy_ID#" VALUE="#Item_List#">
			</CFOUTPUT>
		<CFELSE>
			<CFOUTPUT QUERY="searchProducts" startrow="#StartRow#" maxrows="#MaxRows#">
								
				<!--- This query in inc_eligible_products.cfm --->
				<cfset useLakebaseForIsProductEligible = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alleligibleproducts")>
<cfif useLakebaseForIsProductEligible>
	<cftry>
		<cfset IsProductEligible = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alleligibleproducts", {
				"product_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsProductEligible = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsProductEligible>
<cfquery name="IsProductEligible" dbtype="Query">
				SELECT DISTINCT Product_ID
				FROM AllEligibleProducts
				WHERE Product_ID = '#BSA_Foodservice_Items_Master_ID#'
				</cfquery>
</cfif>
				<cfif IsProductEligible.Recordcount GT 0>
					<cfset ProductIsEligible = 1>
				<cfelse>
					<cfset ProductIsEligible = 0>
				</cfif>
				
				<cfset tmpname = replace(BSA_Foodservice_Items_Master_ID,"-","_","all")>	
				<cfset tmpItm = BSA_Foodservice_Items_Master_ID><!---  &"|"& form.payeeID  --->
				<CFIF listfindnocase(FORM.ProductListToExcludeFromSelecting,searchProducts.BSA_Foodservice_Items_Master_ID) EQ 0>
					<TR <cfif ProductIsEligible IS 1>bgcolor="#ValidDiscountBGColor#"<cfelse>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</cfif>>
						<!--- #Product_Hierarchy_Name# -- #Product_Hierarchy_ID# -- #BSA_Foodservice_Items_Master_ID#--- --->
						<TD ALIGN="right">#currentrow#</TD>
						<TD><span ID="checkAllProducts"><input TYPE="checkbox" NAME="selectedUPCS" VALUE="#BSA_Foodservice_Items_Master_ID#" <CFIF listfindnocase(Form.FinalUPCList,tmpItm)> CHECKED<CFSET FORM.AlreadySelectedItems = listappend(AlreadySelectedItems, BSA_Foodservice_Items_Master_ID,",")></CFIF> ONCLICK="if(!this.checked) document.all.checkall.checked = false;"></SPAN></TD>
						 <cfif (appSettings.get_Setting('Display_Item_No') EQ '1')><TD>#Item#&nbsp;</TD></cfif>
						<cfif RemoveUPC EQ 0><TD>#UPC#&nbsp;</TD></cfif>
						<TD>#Description#&nbsp;</TD>
						<cfif RemoveTypeCode EQ 0><TD>#Type_Code_Desc#&nbsp;</TD></cfif>
						<cfif RemoveTypeGroup EQ 0><TD>#Type_Group_Desc#&nbsp;</TD></cfif>
						<cfif RemoveBrand eq 0><TD>#Brand_Name#&nbsp;</TD></cfif>

						<cfloop query="getDistInfo">
							<INPUT TYPE="Hidden" NAME="custSel_#tmpname#" VALUE="#getDistInfo.BSA_FOODSERVICE_CUSTOMERS_ID#">
						</cfloop>

					</TR>
				<CFELSE>
					<TR BGCOLOR="silver">
						<TD ALIGN="right">#currentrow#</TD>
						<TD><input TYPE="checkbox" CHECKED DISABLED></TD>
						<TD>#Item#&nbsp;</TD>
						<cfif RemoveUPC EQ 0><TD>#UPC#&nbsp;</TD></cfif>
						<TD>#Description#&nbsp;</TD>
						<cfif RemoveTypeCode EQ 0><TD>#Type_Code_Desc#&nbsp;</TD></cfif>
						<cfif RemoveTypeGroup EQ 0><TD>#Type_Group_Desc#&nbsp;</TD></cfif>
						<cfif RemoveBrand eq 0><TD>#Brand_Name#&nbsp;</TD></cfif>
						<cfloop query="getDistInfo">
							<INPUT TYPE="Hidden" NAME="custSel_#tmpname#" VALUE="#getDistInfo.BSA_FOODSERVICE_CUSTOMERS_ID#">
						</cfloop>
					</TR>
				</CFIF>			
				<CFFLUSH>
				<cfset tmpItem = tmpItem + 1>
			</CFOUTPUT>
		</CFIF>
		<TR>
			<TD COLSPAN="100%" STYLE="Border-Bottom: None">
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
			</TD>
		</TR>
	</TABLE>

<CFIF appSettings.getUseProductHierarchy() AND FORM.FromBBProgProdForm EQ 1>
<CFELSE>
</FIELDSET>
</CFIF>
<CFIF searchProducts.recordcount GT 0>

<BR><BR>
<DIV ALIGN="Center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<cfif searchProducts.recordcount GT 0>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#searchProducts.recordcount#</CFOUTPUT>)"> import all returned products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected products </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>	
	
	</cfif> 
</DIV>

<CFELSE>
<BR>
</CFIF>

 
<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="startrow" 							VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" 							VALUE="#frompage#">

	<INPUT TYPE="hidden" NAME="ParentFormname" 						VALUE="#FORM.ParentFormname#">	
	<INPUT TYPE="hidden" NAME="FinalUPCList" 						VALUE="#Form.FinalUPCList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 				VALUE="#Form.AlreadySelectedItems#">

	<INPUT TYPE="hidden" NAME="finishedselectingproducts" 			VALUE="0">
	<INPUT TYPE="hidden" NAME="LoadExistingProductList" 			VALUE="0">
	<INPUT TYPE="hidden" NAME="FirstTimeLoading" 					VALUE="FALSE">
	<INPUT TYPE="hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="#form.ProductListToExcludeFromSelecting#">
	<INPUT TYPE="Hidden" NAME="sort_by" 							VALUE="Item">
	<INPUT TYPE="Hidden" NAME="sort_order" 							VALUE="ASC">
	<INPUT NAME="Program_ID" TYPE="hidden" VALUE="#FORM.Program_ID#">
	<INPUT TYPE="Hidden" NAME="PayeeID" VALUE="#Form.PayeeID#">
	<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="#form.ExistingProductList#">
	<INPUT TYPE="Hidden" NAME="BBID" VALUE="<CFOUTPUT>#form.BBID#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="PayType" VALUE="<CFOUTPUT>#form.PayType#</CFOUTPUT>">
	<input type="Hidden" name="DiscountList" value="<cfoutput>#DiscountList#</cfoutput>">
	<INPUT TYPE="hidden" NAME="Business_Segment_ID" value="#form.Business_Segment_ID#">
	<INPUT TYPE="hidden" NAME="businessSegmentsOn" value="#form.businessSegmentsOn#">
</CFOUTPUT>

</FORM>
<SCRIPT>
	<cfif searchProducts.recordcount GT 0>
		function importAllProducts(recordcount){
			var recordcount = <CFOUTPUT>#ListLen(allList)#</CFOUTPUT>;
			if(parseInt(recordcount) == 1) pString = "product";
			else pString = "products and customers";
			
			if(confirm("Press OK to import all " + recordcount + " " + pString + ".")){
				/* true or false based on browser - IE 10 and above or IE 9 and below. 
				'1' as an argument below means "true". */
				document.all.checkall.checked = checkOrUncheckBeforeFireEvent(1);
				callfireEvent(document,document.all.checkall,'Click');
				
				document.SearchForm.finishedselectingproducts.value = 1;
				/*if(document.SearchForm.FinalUPCList.value.length > 0){
					document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#valuelist(searchProducts.BSA_Foodservice_Items_Master_ID)#</CFOUTPUT>";
				}
				else{
					document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#valuelist(searchProducts.BSA_Foodservice_Items_Master_ID)#</CFOUTPUT>";
				}*/
				//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#allList#</CFOUTPUT>";
				
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
</SCRIPT>

<!--- 
Determines search result column's visibility.
Go to "settings>application settings>Labels>Settings labels" to set visibility
--->
<cffunction name="showHideColumnsSetting" output="false">

	<cfset ProdResults_DisplayUPC = 0>
	<cfloop query="ProdSearchResultsColumnsDisplayAdditionalSettings">
		<cfif field_name eq "UPC">
			<cfset ProdResults_DisplayUPC = 1>
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

</BODY>
</HTML>
