<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Futures Pricing - New Product Search</title>
</head>

<body>

<CFSET thisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmFPNewProduct">
<cfparam name="FORM.AlreadySelectedItems" 	default="">
<cfparam name="FORM.FP_New_Product_ID" 	default="">
<cfparam name="FORM.FinalItemList" 	default="">
<cfparam name="FORM.FinisedSearching" 	default="0">
<CFPARAM NAME="URL.importType" 	DEFAULT="multiple">
<CFPARAM NAME="FORM.importType" 	DEFAULT="#URL.importType#">
<cfparam name="form.command" 	default="search">
<cfparam name="form.Product_List" 	default="">
<cfparam name="form.ceNewProductState" 	default="0">

<CFMODULE template="/Search_Screens/Popup_Search.cfm"
		FirstFormNameVariable="URL.FormName"
		FirstFieldNameVariable="URL.FieldName"
		ActionPage="#thisPage#"
		AlreadySelectedItems="#FORM.AlreadySelectedItems#"
		id="#FORM.FP_New_Product_ID#"
		FinalItemList="#FORM.FinalItemList#"
		ReturnFinalItemListVariable="FORM.FinalItemList"
		FinisedSearching="#FORM.FinisedSearching#"
		LastFormNameVariable="FORM.Formname"
		LastFieldNameVariable="FORM.FieldName"
		importType="#FORM.importType#"
>


<cfparam name="pageLength" 	default="10">
<cf_Number_of_Rows maxrows="#pageLength#">

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<script src="common/common.js" language="JavaScript"></script>

<script language="JavaScript">
	function reset_Form_Fields(searchForm)
	{
		searchForm.reset();
		searchForm.Title.value = "";
		searchForm.Body.value = "";		
	}
	function submitSearch(searchForm)
	{
		searchForm.startrow.value=1;
		searchForm.frompage.value=1;
		searchForm.submit();
		return false;
	}
	function finishedSearching(searchForm)
	{
		searchForm.FinisedSearching.value = 1;
		searchForm.submit();			
	}
	function removeAll(searchForm)
	{
		searchForm.AlreadySelectedItems.value = "";
		searchForm.FinalItemList.value = "";
		if(searchForm.MyCheckAll)
		{
			searchForm.MyCheckAll.checked = true;
			searchForm.MyCheckAll.click();
		}
	}
	function addItem(searchForm, sCommand, itemId)
	{
	
		//do validation if editing/creating
		if (sCommand == 'sNewProduct')
		{
			var prodDesc = trim(searchForm.Product_Desc.value);
			if(!prodDesc.length)
			{
				alert('Please provide a Product Description.');
				return false;
			}
		}
		searchForm.command.value = sCommand;
		if(itemId)
		{
			searchForm.itemId.value = itemId;
		}
		searchForm.submit();
	}
</script>
<CFSET AlreadySelectedItems = "">

<!---initialize new product object--->
<cfset newProductManager = CreateObject("component", "components.futures_pricing.NewProductManager").init() />

<FORM ACTION="#thisPage#" METHOD="post" name="#formName#">

<!---///////////////////////////////////////// CREATE/EDIT NEW PRODUCT ////////////////////////////////////////////--->
<cfif form.command EQ "ceNewProduct">

	<cfparam name="form.itemId" 	default="0">
	
	<cfif form.ceNewProductState>
		<cfset newProduct = newProductManager.set(form)>
	<cfelse>
		<cfset newProduct = newProductManager.get(form.itemId)>
	</cfif>
	
	<table cellpadding="2" cellspacing="0" border="0">
	<caption><font face="Verdana, Arial, Helvetica, sans-serif"><b>Add / Edit New Product</b></font></caption>
		<tr>
			<td><b>Product Description:</b></td>
			<td><input name="Product_Desc" type="text" value="#newProduct.getDesc()#" size="50" maxlength="255"></td>
		</tr>
		<tr>
			<td valign="top"><b>Customer Request:</b><br><font color="##FF0000">(Max: 1000 characters)</font></td>
			<td>
				<textarea name="Customer_Request" cols="60" rows="4" onKeyUp="textAreaMaxLength(this, '1000');">#newProduct.getCustRequest()#</textarea>
			</td>
		</tr>
	</table>
	<br>
	<B><FONT SIZE="2" COLOR="##000080">Products</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;
	<cf_smallLink
		title="select surrogate products"
		url="##"
		parameters = "onClick=""javascript: return showProductSearchWindow('#formName#');"""
	>
	<hr size="1px">
	<table cellpadding="2" cellspacing="0" border="0">
		<cfloop index="surrIndx" from="1" to="#ArrayLen(newProduct.surrogate)#">
		<!---strip dashes from prodId UUID--->
		<cfset productId = newProduct.surrogate[surrIndx].getProdId() />
		<cfset prodId = request.app_general_functions.replaceHyphen(productId) />
		<tr bgcolor="##FFCE84" ID="SCISSOR_ITEM_#prodId#">
			<td colspan="100%">
				<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" onclick="deleteThisRecord('#prodId#', '#productId#', document.#formName#.Product_List, document.#formName#.ExistingProductList)" style="cursor: hand;">&nbsp;<b>#newProduct.surrogate[surrIndx].getName()#</b>&nbsp;&nbsp;&nbsp;<b>#newProduct.surrogate[surrIndx].getItem()#</b>&nbsp;&nbsp;&nbsp;<b>#newProduct.surrogate[surrIndx].getUpc()#</b>
			</td>
		</tr>
		<tr ID="SCISSOR_ITEM_#prodId#">
			<td align="right" valign="top"><b>Comments:</b><br><font color="##FF0000">(Max: 255 characters)</font></td>
			<td>
				<textarea name="Product_Desc_#prodId#" cols="50" rows="2" onKeyUp="textAreaMaxLength(this, '255');">#newProduct.surrogate[surrIndx].getDesc()#</textarea>
			<!--- <input name="Product_Desc_#prodId#" type="text" value="#newProduct.surrogate[surrIndx].getDesc()#"> --->
			</td>
		</tr>
		<!---add product id to product_list if it doesn't exist--->
		<cfif not ListFindNoCase(form.Product_List, productId)>
			<cfset form.Product_List = ListAppend(form.Product_List, productId) />
		</cfif>
		
		</cfloop>
	</table>
	<input type="Hidden" name="id" value="#newProduct.getId()#">
	<INPUT NAME="Product_List" TYPE="Hidden" VALUE="#Form.Product_List#" />
	<INPUT NAME="ExistingProductList" TYPE="Hidden" VALUE="#Form.Product_List#" />
	<INPUT NAME="ceNewProductState" TYPE="Hidden" VALUE="1" />
	<br>
	<div align="center">
	<cf_smallLink
		title="back to search"
		url="##"
		parameters=" onClick=""javascript: addItem(document.#formName#, 'search');"""
	>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cf_smallLink
		title="save new product"
		url="##"
		parameters=" onClick=""javascript: addItem(document.#formName#, 'sNewProduct');"""
	>
	</div>

<!---///////////////////////////////////////// SAVE NEW PRODUCT ////////////////////////////////////////////--->
<cfelseif form.command EQ "sNewProduct">

	<cfset newProduct = newProductManager.set(form)>
	<cfset newProductManager.save()>

<cfelse>
<!---///////////////////////////////////////// SEARCH NEW PRODUCT ////////////////////////////////////////////--->

	<cfset qGetNewProducts = newProductManager.getAll() />
	
	<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="4" class="MainTable">		
		<TR bgcolor="##FFCE84">
			<TD ID="header">
			<CFIF FORM.importType NEQ "single">
			<INPUT NAME="MyCheckAll" TYPE="checkbox" VALUE="" onClick="javaScript: CHSelectAll('FP_New_Product_ID', this.checked);">			
			<CFELSE>&nbsp;</CFIF>
			</TD>
			<TD ID="header"><B>Description</B></TD>
			<TD ID="header">&nbsp;</TD>
		</TR>
		<cfif qGetNewProducts.RecordCount>
		
			<cfloop query="qGetNewProducts" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
			<tr>
				<td>
				<cfset bChecked = "">
				<CFIF listfind(FORM.FinalItemList, FP_New_Product_ID) NEQ 0>
					<cfset bChecked = "CHECKED">
					<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, FP_New_Product_ID, ",")>
				</CFIF>
				<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" NAME="FP_New_Product_ID" VALUE="#FP_New_Product_ID#" #bChecked#>
				</td>
				<td>#Product_Desc#</td>
				<td>
				<cf_smallLink
					title="edit"
					url="##"
					parameters=" onClick=""javascript: addItem(document.#formName#, 'ceNewProduct', #FP_New_Product_ID#);"""
				>
				</td>
			</tr>
			</cfloop>
		
		<cfelse>
			<tr><td colspan="100%">No New Products</td></tr>
		</cfif>
	</TABLE>
		<DIV STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
				formname="#formName#"
				query="qGetNewProducts"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
			<div>
			<cf_smallLink
				title="import selected record(s)"
				url="##"
				parameters=" onClick=""javascript: finishedSearching(document.#formName#);"""
				>
			<cf_smallLink
				title="remove selected record(s)"
				url="##"
				parameters=" onClick=""javascript: removeAll(document.#formName#);"""
				>
			<cf_smallLink
				title="add new product"
				url="##"
				parameters=" onClick=""javascript: addItem(document.#formName#, 'ceNewProduct');"""
				>
			</div>
<!------ Search code ends ----->	
</cfif>
	
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#FORM.importType#">
	<INPUT NAME="command" TYPE="HIDDEN" VALUE="#form.command#">
	<INPUT NAME="itemId" TYPE="Hidden" VALUE="0">
	
</FORM>

<cfif form.command EQ "sNewProduct">
	<script language="JavaScript">
		addItem(document.#formName#, 'search');
	</script>
</cfif>

<cf_MessageWindow />

</body>
</html>

</cfoutput>