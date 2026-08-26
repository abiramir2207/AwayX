<cfoutput>

<cfparam name="url.command" default="dNewProduct" />
<cfparam name="form.command" default="#url.command#" />
<cfparam name="form.ceNewProductState" 	default="0">
<cfparam name="url.itemId" 	default="0">
<cfparam name="form.itemId" 	default="#url.itemId#">
<cfparam name="form.Product_List" 	default="">

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
<script src="common/common.js" language="JavaScript"></script>

<!---initialize new product object--->
<cfset newProductManager = CreateObject("component", "components.futures_pricing.NewProductManager").init() />

<!---///////////////////////////////////////// EDIT NEW PRODUCT ////////////////////////////////////////////--->
<cfif form.command EQ "ceNewProduct">

	<cfparam name="form.itemId" 	default="0">
	
	<cfif form.ceNewProductState>
		<cfset newProduct = newProductManager.set(form)>
	<cfelse>
		<cfset newProduct = newProductManager.get(form.itemId)>
	</cfif>

<!---///////////////////////////////////////// SAVE NEW PRODUCT ////////////////////////////////////////////--->
<cfelseif form.command EQ "sNewProduct">

	<cfset newProduct = newProductManager.set(form)>
	<cfset newProductManager.save()>
	
	<script>
		opener.document.dataForm.submit();
		self.close();
	</script>
	
</cfif>

<cfif form.command EQ "ceNewProduct">
	<cfinclude template="new_product_create_edit.cfm">
<cfelse>
	<cfinclude template="new_product_display.cfm">
</cfif>

</cfoutput>