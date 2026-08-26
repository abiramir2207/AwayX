<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Futures Pricing - New Product Display</title>
</head>

<body>

<!---initialize new product object--->
<cfset newProductManager = CreateObject("component", "components.futures_pricing.NewProductManager").init() />

<cfparam name="url.itemId" 	default="0">
<cfparam name="form.itemId" 	default="#url.itemId#">

<cfset newProduct = newProductManager.get(form.itemId)>
	
<table cellpadding="2" cellspacing="0" border="0">
	<tr>
		<td><b>Product Description:</b></td>
		<td>#newProduct.getDesc()#</td>
	</tr>
	<tr>
		<td><b>Customer Request:</b></td>
		<td>
			#newProduct.getCustRequest()#
		</td>
	</tr>
</table>
<br>
<B><FONT SIZE="2" COLOR="##000080">Surrogate Products</FONT></B>
<hr size="1px">
<table cellpadding="2" cellspacing="0" border="0">
	<cfloop index="surrIndx" from="1" to="#ArrayLen(newProduct.surrogate)#">
		<!---strip dashes from prodId UUID--->
		<cfset productId = newProduct.surrogate[surrIndx].getProdId() />
		<cfset prodId = request.app_general_functions.replaceHyphen(productId) />
		<tr bgcolor="##FFCE84">
			<td colspan="100%">
				<b>#newProduct.surrogate[surrIndx].getName()#</b>&nbsp;&nbsp;&nbsp;<b>#newProduct.surrogate[surrIndx].getItem()#</b>&nbsp;&nbsp;&nbsp;<b>#newProduct.surrogate[surrIndx].getUpc()#</b>
			</td>
		</tr>
		<tr>
			<td valign="top"><b>Comments:</b>&nbsp;&nbsp;
				#newProduct.surrogate[surrIndx].getDesc()#
			</td>
		</tr>
	</cfloop>
</table>
<br>
<cf_smallLink
	title="close"
	url="##"
	parameters=" onClick=""javascript: window.close();"""
>
</body>
</html>

</cfoutput>