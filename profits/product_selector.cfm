
<CFIF isdefined("URL.FormName")>
	<FORM ACTION="product_selector.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="">
		<INPUT NAME="PRID" TYPE="Hidden" VALUE="">
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.ExistingProductList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.ExistingProductList.value
			this.document.all.PRID.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.PRID.value
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>


<!--- Since the uniqueidentifier does not accept NULLs, we needed to use this trick --->
<CFIF PRID EQ ''>
	<CFSET PRID="NULL">
<CFELSE>
	<CFSET PRID="'#PRID#'">
</CFIF>


<CFSET PAGE_TITLE= "Product Search">

<!--- PRODUCT LIST MAINTAINENCE --->
<CFPARAM NAME="FORM.SelectedUPCS" DEFAULT="">
<CFPARAM NAME="FORM.FinalUPCList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingproducts" DEFAULT="0">
<CFPARAM NAME="FORM.LoadExistingProductList" DEFAULT="1">
<CFPARAM NAME="FORM.FirstTimeLoading" DEFAULT="False">



<CFSET listofitemstodelete = "">
<!--- loop through the pages selected items and if it is no in the selected list that means it was removed to queue it for removal --->
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedUPCS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>
<!--- listofitemstodelete: <CFOUTPUT>#listofitemstodelete#</CFOUTPUT><BR><BR>
AlreadySelectedItems: <CFOUTPUT>#FORM.AlreadySelectedItems#</CFOUTPUT><BR><BR>
SelectedUPCS: <CFOUTPUT>#FORM.SelectedUPCS#</CFOUTPUT><BR><BR>
 ---><!--- if a selected item isnt already in the final list then add it  --->
<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedUPCS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalUPCList, ListItem, ",") EQ 0>
		<CFSET Form.FinalUPCList = listappend(FinalUPCList, ListItem, ",")>
	</CFIF>
</CFLOOP>
<!--- FinalUPCList: <CFOUTPUT>#FORM.FinalUPCList#</CFOUTPUT><BR><BR> --->
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


<CFIF FORM.finishedselectingproducts EQ 1>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Newly_Selected_Products.value = '<CFOUTPUT>#Form.FinalUPCList#</CFOUTPUT>'
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
			width:180 px;
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
				event.returnValue='To Exit The Search Tool Correctly, Press Cancel Below And Press The Continue Button'
			}
		}
		
		function selectAll(){
			if(window.checkAllProducts != null){
				for(var x=0; x<checkAllProducts.length;x++){
					box = checkAllProducts[x].firstChild
					box.checked = document.all.checkall.checked
				}
			}
		}
		
	</script>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="initPage()" ONBEFOREUNLOAD="verifyClose()">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type groups																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---------------
<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT *
	FROM Type_Group_Desc
	WHERE len(Type_Group_Desc) != 0
	ORDER BY Type_Group_Desc
</CFQUERY>
--------------->

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

<SCRIPT language="JavaScript">
function reset_Form_Fields()
	{
		resetSelect("Type_Group_Desc_ID");
		resetSelect("Q_Brand_ID");
		resetSelect("Type_Code_Desc_ID");
		resetSelect("Brand_ID");
		resetSelect("Line_Of_Biz");
		resetSelect("Product_Status");
		resetSelect("sort_by");
		resetSelect("sort_Order");	
		
		document.all.item_number.value = "";
		document.all.upc_number.value = "";
		document.all.description_string.value = "";
	}
	
	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		var opt = sObj.options;
		var optlen = opt.length;
		var i;
		//alert(selName);
		//alert(optlen);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			sObj.fireEvent('onchange');
		}
		if(selName == "sort_by")
		{
			for(i=0; i<optlen; i++)
			{
				if(opt[i].value == "Item")
				{
					sObj.selectedIndex=i;
					break;
				}
			}				
		}
	}
</SCRIPT>
<FORM ACTION="product_selector.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" ONKEYPRESS="if(event.keyCode == 13) doSearch()">


&nbsp;&nbsp;&nbsp;<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<DIV ALIGN="center">
<FIELDSET STYLE="padding:5px; width: 760px; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 12px sans-serif; color: Navy;">Search Criteria</LEGEND>



		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL I</B><BR>
					<CFPARAM NAME="FORM.Type_Group_Desc_ID" DEFAULT="0">
					<!-----------
					<SELECT NAME="Type_Group_Desc_ID">
						<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.type_group_label_singular#</CFOUTPUT><!--- Type Group ---> Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeGroupDesc"><OPTION VALUE="#Type_Group_Desc_ID#" <cfif FORM.Type_Group_Desc_ID EQ GetTypeGroupDesc.Type_Group_Desc_ID> SELECTED</cfif>>#Type_Group_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					--------------->
					<cf_sel_type_group
						company_main_id			= "#request.AccessStructure.company_main_id#"
						dropdown_name			= "Type_Group_Desc_ID"
						selected_id				= "#FORM.Type_Group_Desc_ID#"
						text_before_tag_close	= ""
						default_option_on		= "1"
						default_option_text		= "**ALL** #application.returned_customer_setting.type_group_label_plural#"
						default_option_value	= "0"
					>
					<!--- <BR><BR> --->
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL II</B><BR>
					<CFPARAM NAME="FORM.Q_Brand_ID" DEFAULT="0">
					<SELECT NAME="Q_Brand_ID">
						<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.q_brand_label_singular#</CFOUTPUT><!--- Q Brand ---> Descriptions</OPTION>
						<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#Q_Brand_ID#"<cfif FORM.Q_Brand_ID EQ GetQBrands.Q_Brand_ID> SELECTED</cfif>>#Q_Brand#</OPTION></CFOUTPUT>
					</SELECT>
					<!--- <BR><BR> --->
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL III</B><BR>
					<CFPARAM NAME="FORM.Type_Code_Desc_ID" DEFAULT="0">
					<SELECT NAME="Type_Code_Desc_ID">
						<OPTION VALUE="0">**ALL** <CFOUTPUT>#application.returned_customer_setting.type_code_label_singular#</CFOUTPUT><!--- Type Code ---> Descriptions</OPTION>
						<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#Type_Code_Desc_ID#"<cfif FORM.Type_Code_Desc_ID EQ GetTypeCodeDesc.Type_Code_Desc_ID> SELECTED</cfif>>#Type_Code_Desc#</OPTION></CFOUTPUT>
					</SELECT>
					<!--- <BR><BR> --->
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>LEVEL IV</B><BR>
					<CFPARAM NAME="FORM.Brand_ID" DEFAULT="0">
					<SELECT NAME="Brand_ID">
						<OPTION VALUE="0">**ALL** Brands</OPTION>
						<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#Brand_ID#"<cfif FORM.Brand_ID EQ GetBrands.Brand_ID> SELECTED</cfif>>#Brand_Name#</OPTION></CFOUTPUT>
					</SELECT>
					<!--- <BR><BR> --->
				</TD>
			</TR>
			<TR>
				<TD><!--- Line Of Biz --->
					<span ID="searchItemLabel"><B><CFOUTPUT>#application.returned_customer_setting.lob_label_singular#</CFOUTPUT><!--- Line Of Business ---></B></span><BR>
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
						WHERE Line_Of_Business = '#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#'
					</CFQUERY>
					<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="#getFoodserviceLOBID.Line_Of_Business_ID#">
					<SELECT NAME="Line_Of_Biz" style="width: 185px;">
						<OPTION VALUE="0">**ALL** Lines Of Business</OPTION>
						<CFOUTPUT QUERY="GetLinesOfBiz"><OPTION VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>#trim(GetLinesOfBiz.Line_Of_Business_Name)#</OPTION></CFOUTPUT>
					</SELECT>					
				</TD>
				<TD><!--- Active/Inactive --->
					<span ID="searchItemLabel"><B>Status</B></span><BR>
					<CFPARAM NAME="FORM.Product_Status" DEFAULT="A">
					<SELECT NAME="Product_Status">
						<option VALUE="A" <CFIF FORM.Product_Status EQ "A">SELECTED</CFIF>>Active</option>
						<option VALUE="N" <CFIF FORM.Product_Status EQ "N">SELECTED</CFIF>>Inactive</option>
					</SELECT>
				</TD>
				<CFPARAM NAME="FORM.item_number" DEFAULT="">
				<CFPARAM NAME="FORM.upc_number" DEFAULT="">
				<TD NOWRAP ALIGN="left"><B>Item #</B><BR><input TYPE="Text" NAME="item_number" VALUE="<CFOUTPUT>#FORM.item_number#</CFOUTPUT>" STYLE="WIDTH:180px"></TD>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
				<cfif application.returned_customer_setting.upc_switch EQ 1>
					<TD NOWRAP ALIGN="left"><B>UPC #</B><BR><input TYPE="Text" NAME="upc_number" VALUE="<CFOUTPUT>#FORM.upc_number#</CFOUTPUT>" STYLE="WIDTH:180px"></TD>
				<cfelse>
					<TD>&nbsp;</TD>
				</cfif>
				</cfif>
				<!--- <B>UPC #</B><BR><input TYPE="Text" NAME="upc_number" VALUE="<CFOUTPUT>#FORM.upc_number#</CFOUTPUT>" STYLE="WIDTH:180px"></TD> --->
				
			</TR>
			<TR>
				<TD COLSPAN="100%" COLSPAN="2" NOWRAP>
					<B>Description:</B><BR>
					<CFPARAM NAME="FORM.description_string" DEFAULT="">
					<INPUT TYPE="Text" NAME="description_string" STYLE="width: 725px;" VALUE="<CFOUTPUT>#FORM.description_string#</CFOUTPUT>"><!---&nbsp; <input TYPE="button" VALUE="search" ONCLICK="doSearch()"> --->
				</TD>
			</TR>
			<TR>
				<TD NOWRAP ALIGN="left">
				<B>Sort By</B><BR>
				
				<CFSET sort_By_List = "Item,#application.returned_customer_setting.type_code_label_singular#,Description,Brand">
				
				<CFSET sort_By_List_Value = "Item,Type Code,Description,Brand">
				
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
				<cfif application.returned_customer_setting.upc_switch EQ 1>
					<CFSET sort_By_List = ListAppend(sort_By_List, "UPC", ",")>
					<CFSET sort_By_List_Value = ListAppend(sort_By_List_Value, "UPC", ",")>
				</cfif></cfif>
				
				
				<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
				<CFOUTPUT>
				<CFSET sort_By_List=ListSort(sort_By_List,"Text")>
				<CFSET sort_By_List_Value=ListSort(sort_By_List_Value,"Text")>
				<CFSET sort_Counter = 1>
				<SELECT ID="sort_by" NAME="sort_by">
				<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
					<CFSET thisItem=Trim(thisItem)>
					<CFSET thisItemValue=Trim(ListGetAt(sort_By_List_Value, sort_Counter, ","))>
					<OPTION VALUE="#thisItemValue#"<CFIF thisItemValue EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
					<CFSET sort_Counter = sort_Counter + 1>
				</CFLOOP>
				</SELECT>
				</CFOUTPUT>
				</TD>
				<TD NOWRAP ALIGN="left">
				<B>Order</B><BR>
				<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC1">
				<SELECT ID="sort_Order" NAME="sort_Order">
					<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
					<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
				</SELECT>
				</TD>
				<TD>
					<CFPARAM NAME="FORM.Show_Other_Pricing_Rule_Products" 	DEFAULT="0">
					<BR><INPUT TYPE="checkbox" NAME="Show_Other_Pricing_Rule_Products" VALUE="1"<CFIF FORM.Show_Other_Pricing_Rule_Products> CHECKED</CFIF>>show already assigned products
				</TD>
				<TD>
				<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
				&nbsp;&nbsp;
				<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: reset_Form_Fields();">reset</a><FONT COLOR="#FF0000">]</FONT></B>				
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="doSearch()">search products</a><FONT COLOR="#FF0000">]</FONT></B>
				</TD>
			</TR>
		</TABLE>
		<BR>
</FIELDSET>
</DIV>

<CFQUERY NAME="getLOBCharacter" DBTYPE="query">
	SELECT *
	FROM GetLinesOfBiz
	WHERE Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
</CFQUERY>

<CFQUERY NAME="getCategories" datasource="#application.datasource#">
	SELECT Category_ID
	FROM Category
	WHERE Category IN (#ListQualify(application.returned_customer_setting.Category_List, "'", ",")#)
</CFQUERY>

<cfset categoryList = listqualify(valuelist(getCategories.Category_ID), "'", ",")>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Type Code"><!--- Type Code --->
		<CFSET sql_Sort_By="dbo.Type_Code_Desc.Type_Code_Desc">
	</CFCASE>
	<CFCASE value="Brand">
		<CFSET sql_Sort_By="dbo.Brand.Brand_Name">
	</CFCASE>
	<CFCASE value="ItemNumber">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Item">
	</CFCASE>
	<CFCASE value="UPC">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.UPC">
	</CFCASE>
	<CFCASE value="Description">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Items_Master.Description">
	</CFCASE>
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFQUERY name="Exclude_List" datasource="#application.datasource#">
	Select	Pricing_Rule_Products.Pricing_Rule_Products_Item_ID
	From	Pricing_Rule_Products	
	<CFIF PRID NEQ "NULL">
	Where
	Pricing_Rule_Products.Pricing_Rule_ID	<> #preserveSingleQuotes(PRID)#
	</CFIF>
</CFQUERY>

<CFSET excludeList=ValueList(Exclude_List.Pricing_Rule_Products_Item_ID)>

<CFIF FORM.FirstTimeLoading EQ "FALSE">
	<CFPARAM NAME="FORM.Program_ID" 	DEFAULT="">
	<CFPARAM NAME="SHOW_INVOICE_FILTER" 	DEFAULT=0>
	
	<cfset FORM.Description_String = trim(replace(FORM.Description_String, "'", "''", "all"))>
	<cfset Form.Item_Number = trim(replace(Form.Item_Number, "'", "''", "all"))>
	<cfset Form.UPC_Number = trim(replace(Form.UPC_Number, "'", "''", "all"))>
	
	
	<CFQUERY NAME="MainsearchProducts" datasource="#application.datasource#">
		<cfoutput><cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_product_search_location#"></cfoutput>
	</CFQUERY>
	
	<CFQUERY NAME="searchProducts" DBTYPE="query">
		SELECT	*
		FROM	MainsearchProducts
		<CFIF FORM.Show_Other_Pricing_Rule_Products EQ "0">
		<cfif Len(excludeList) GT 0>
		WHERE	BSA_Foodservice_Items_Master_ID NOT IN (#ListQualify(excludeList, "'", ",")#)
		</cfif>
		</CFIF>
	</CFQUERY>

<CFELSE>	
	<CFSET SEARCHPRODUCTS = QueryNew("Item")>
</CFIF>

<!------------------------------ Get all list - exclude list -------------------------------------->

<CFQUERY NAME="Q_All_List" DBTYPE="query">
	SELECT	BSA_Foodservice_Items_Master_ID
	FROM	searchProducts
	<CFIF excludeList NEQ "">
	WHERE
			searchProducts.BSA_Foodservice_Items_Master_ID
			NOT IN (#ListQualify(excludeList, "'", ",")#)
	</CFIF>
</CFQUERY>
<CFSET allList = ValueList(Q_All_List.BSA_Foodservice_Items_Master_ID, ",")>


<!------<CFSET allList=ValueList(searchProducts.BSA_Foodservice_Items_Master_ID)>
<CFSET excludeList=ValueList(Exclude_List.Pricing_Rule_Products_Item_ID)>
<CFLOOP LIST="#excludeList#" INDEX="item">
	<CFSET excludePos=ListFindNoCase(allList,item,",")>
	<CFIF excludePos GT 0>
		<CFSET allList=ListDeleteAt(allList, excludePos, ",")>
	</CFIF>
</CFLOOP>----->
<!------------------------------ Get all list - exclude list -------------------------------------->


<CFQUERY NAME="Get_All_Pricing_Rule_Details" datasource="#application.datasource#">
	Select		Pricing_Rule.Pricing_Rule_Name, 
				Pricing_Rule.Pricing_Rule_Date, 
				Pricing_Rule.Pricing_Rule_Author,
				_Users.User_ID,
				_Users.Name_First,
				_Users.Name_Last,
				Pricing_Rule_ID
	From		Pricing_Rule,
				_Users
	Where		Pricing_Rule.Deleted = 0
				and
				Pricing_Rule.Pricing_Rule_Author	=	_Users.User_ID
</CFQUERY>
<DIV ALIGN="center">
<FIELDSET STYLE="padding:8px; width: 760px; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 12px sans-serif; color: Navy;">The above criteria returned <FONT COLOR="#FF0000"><CFOUTPUT>#searchProducts.recordcount#</CFOUTPUT></FONT> records (<FONT COLOR="#FF0000"><CFOUTPUT>#ListLen(allList)#</CFOUTPUT></FONT> unassigned)</LEGEND>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px; font-weight: bold;}
</style>

<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
	<TR BGCOLOR="FFCE84">
		<TD ID="header">&nbsp;</TD>
		<TD ID="header" WIDTH="1"><input TYPE="checkbox" NAME="checkall" ONCLICK="selectAll()"></TD>
		<TD ID="header">Item</TD>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
		<cfif application.returned_customer_setting.upc_switch EQ 1><TD ID="header">UPC</TD></cfif></cfif>
		
		<TD ID="header">Description</TD>
		<TD ID="header"><CFOUTPUT>#application.returned_customer_setting.type_code_label_singular#</CFOUTPUT><!--- Type Code ---></TD>
		<TD ID="header">Brand</TD>
	</TR>
	<CFIF FORM.FirstTimeLoading EQ "TRUE">
	<TR>
		<TD COLSPAN="100%" ALIGN="center"><BR><font SIZE="+1" color="red">Please Enter Your Product Criteria</font><BR><BR></TD>
	</TR>
	</CFIF>

	<cf_Number_of_Rows maxrows=25>
	<CFSET FORM.AlreadySelectedItems = "">



<FONT COLOR="#FF0000"><I>Grayed out records, indicate products that are already part of a pricing rule</I></FONT>


<!--- PRID Passed: <CFOUTPUT>#PRID#</CFOUTPUT><BR> --->



				
	<CFOUTPUT QUERY="searchProducts" startrow="#StartRow#" maxrows="#MaxRows#">
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Check if this product has already been used in a pricing rule different from this one --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFQUERY name="Check_for_Products" datasource="#application.datasource#">
			Select	TOP 1 Pricing_Rule_Products.*
			From	Pricing_Rule_Products
			Where	Pricing_Rule_Products.Pricing_Rule_Products_Item_ID	=	'#searchProducts.BSA_Foodservice_Items_Master_ID#'
					<CFIF PRID NEQ "NULL">
					and
					Pricing_Rule_Products.Pricing_Rule_ID	<> #preserveSingleQuotes(PRID)#
					</CFIF>
		</CFQUERY>
		
			<CFIF Check_for_Products.Recordcount GT 0>
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Get the name, author and date of the pricing rule, that this product is part of... --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<CFQUERY NAME="Get_Pricing_Rule_Details" DBTYPE="query">
					Select		Pricing_Rule_Name, 
								Pricing_Rule_Date, 
								Pricing_Rule_Author,
								User_ID,
								Name_First,
								Name_Last
					From		Get_All_Pricing_Rule_Details
					Where		Pricing_Rule_ID = '#Check_for_Products.Pricing_Rule_ID#'
				</CFQUERY>

				<CFSET color="Silver">
			<CFELSE>
				<CFSET color="Black">
			</CFIF>


		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD ALIGN="right"><FONT COLOR="#color#">#currentrow#</FONT></TD>
			<TD>
			
			<CFIF Check_for_Products.Recordcount GT 0>
				<INPUT STYLE="cursor: pointer;" NAME="" TYPE="checkbox" DISABLED="true" VALUE="" CHECKED TITLE="#ucase(Get_Pricing_Rule_Details.Pricing_Rule_Name)# &##10; #Get_Pricing_Rule_Details.Name_First# #Get_Pricing_Rule_Details.Name_Last# &##10; #Get_Pricing_Rule_Details.Pricing_Rule_Date#">
			<CFELSE>
				<span ID="checkAllProducts">
					<input TYPE="checkbox" NAME="selectedUPCS" VALUE="#BSA_Foodservice_Items_Master_ID#" <CFIF listfind(Form.FinalUPCList,BSA_Foodservice_Items_Master_ID)> CHECKED<CFSET FORM.AlreadySelectedItems = listappend(AlreadySelectedItems, BSA_Foodservice_Items_Master_ID,",")></CFIF> ONCLICK="if(!this.checked) document.all.checkall.checked = false;">
				</SPAN>
			</CFIF>
			
			
			
			
			
			
			</TD>
			<TD><FONT COLOR="#color#">#Item#&nbsp;</FONT></TD>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
			<cfif application.returned_customer_setting.upc_switch EQ 1><TD><FONT COLOR="#color#">#UPC#&nbsp;</FONT></TD></cfif></cfif>
			
			<TD><FONT COLOR="#color#">#Description#&nbsp;</FONT></TD>
			<TD><FONT COLOR="#color#">#Type_Code_Desc#&nbsp;</FONT></TD>
			<TD><FONT COLOR="#color#">#Brand_Name#&nbsp;</FONT></TD>
		</TR>		
		<CFFLUSH>
	
	</CFOUTPUT>
</TABLE>
</FIELDSET>
<CFIF searchProducts.recordcount GT 0>
<!--- <HR COLOR="Orange" SIZE="2" WIDTH="760px"> --->
<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
&nbsp;&nbsp;&nbsp;
<CF_Next_Previous_For_Forms
	formname="SearchForm"
	query="searchProducts"
	maxpages="40"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
</DIV>

<BR>

<DIV ALIGN="center">
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

<!--- <HR COLOR="Orange" SIZE="2"  WIDTH="760px"> --->
<CFELSE>
<BR>
</CFIF>
<!--- <DIV ALIGN="center"><input TYPE="button" VALUE="continue" ONCLICK="finishedSearching()"></DIV> --->



<!--- 
<CF_button
	button_name		=	""
	button_caption	=	"continue"
	button_action	=	"javascript: finishedSearching()"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	
 --->
 
 
<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
	
	<INPUT TYPE="hidden" NAME="FinalUPCList" VALUE="#Form.FinalUPCList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="#Form.AlreadySelectedItems#">

	<INPUT TYPE="hidden" NAME="finishedselectingproducts" VALUE="0">
	<INPUT TYPE="hidden" NAME="LoadExistingProductList" VALUE="0">
	<INPUT TYPE="hidden" NAME="FirstTimeLoading" VALUE="FALSE">

	<INPUT TYPE="hidden" NAME="ParentFormname" VALUE="#FORM.ParentFormname#">

	<INPUT NAME="PRID" TYPE="hidden" VALUE="#FORM.PRID#">
	
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
				//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#valuelist(searchProducts.BSA_Foodservice_Items_Master_ID)#</CFOUTPUT>";
				document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#allList#</CFOUTPUT>";
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
				
				//document.SearchForm.submit();
			}
			else
			{
			
			}
		}		
	</cfif>
</SCRIPT>


</BODY>
</HTML>



