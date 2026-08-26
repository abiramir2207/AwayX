<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Futures Pricing - Product Edit</title>
</head>

<body>

<CFSET thisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmFPNewProduct">

<script language="JavaScript">

	function saveItem(searchForm, sCommand, itemId)
	{
	
		//do validation if editing
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
		searchForm.submit();
	}
</script>

<FORM ACTION="#thisPage#" METHOD="post" name="#formName#">

	<table cellpadding="2" cellspacing="0" border="0">
	<caption><font face="Verdana, Arial, Helvetica, sans-serif"><b>Edit New Product</b></font></caption>
		<tr>
			<td><b>Product Description:</b></td>
			<td><input name="Product_Desc" type="text" value="#newProduct.getDesc()#" size="50" maxlength="255"></td>
		</tr>
		<tr>
			<td><b>Customer Request:</b><br><font color="##FF0000">(Max: 1000 characters)</font></td>
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
		<tr>
			<td align="right" valign="top" ID="SCISSOR_ITEM_#prodId#"><b>Comments:</b><br><font color="##FF0000">(Max: 255 characters)</font></td>
			<td>
				<textarea name="Product_Desc_#prodId#" cols="50" rows="2" onKeyUp="textAreaMaxLength(this, '255');">#newProduct.surrogate[surrIndx].getDesc()#</textarea>
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
	<INPUT NAME="command" TYPE="HIDDEN" VALUE="#form.command#">
	<br>
	<div align="center">
	
	<cf_smallLink
		title="save"
		url="##"
		parameters=" onClick=""javascript: saveItem(document.#formName#, 'sNewProduct');"""
	>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cf_smallLink
		title="cancel"
		url="##"
		parameters=" onClick=""javascript: self.close();"""
	>
	</div>

	
</FORM>

</body>
</html>

</cfoutput>