<!---	Filename:	C:\Work\Code\base\AwayX\settings\edit_master_data\product_Master_Edit.cfm
	Created:	3/12/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO EDIT MASTER DATA
	Usage:
		SETTING>>ADMINISTRATOR>>EDIT_MASTER_DATA.--->
<style type="text/css"> 
	.bold{
		font-weight: bold;
		}
</style>

<cfif isdefined("form.update")>
<!--- SAVE START --->
		<cfset MasterData = CreateObject("component", "components.products.ItemMaster")>
				<cfscript>
							MasterData.UpdateBSAItemMaster
														(
														BSA_Item_Master_ID 	= #trim(form.bsaid)#,
														Description			= #trim(form.description)#,
														Brand_ID 			= #trim(form.BrandID)#,
														Class_ID			= #trim(form.classID)#,
														Product_ID 			= #trim(form.productID)#,
														Class_Code_UUID		= #trim(form.classUUID)#,
														UserID				= #trim(request.AccessStructure.User_ID)#
														);
				</cfscript>
	<script>
		window.opener.location.reload(false);
		window.close();
	</script>
<!--- SAVE END --->
<cfelse>

<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init()>
<cfset getAllProductAttributes = qLabels.getAllProductAttributes() />

<cfset labelsValue = structNew() />

<cfloop query="getAllProductAttributes">
	<cfset temp = structInsert(labelsValue, replace(GROUP_INTERNAL_LABEL, ' ', '_', 'all'), GROUP_LEVEL_DESC, 'true') />
</cfloop>

<cfset Items = createObject("component", "components.products.ItemMaster").getItems(#url.BSAID#)>

<cfoutput query="items">
	<cfif len(name) or len(date)><br>
		<div style="width:100%; border:solid; border-color:orange; border-width:2px; padding:2px; text-align: center;font-weight: bold;margin-top:5px;">
		Last updated by #name# on #DateFormat(Date, "mmm/d/yy")# at #TimeFormat(Date, "hh:mm:ss tt")#
		</div>
	</cfif>
<!---index.cfm?submit=1&BSAID=#url.BSAID# --->
<cfform name="itemedit" action="product_Master_Edit.cfm" id="itemedit">
	<table width="98%" align="center" border="0">
		<tr id="brandInfo" style="display:none;">
			<td colspan="2" align="center" style="color:red;font-weight:bold;">#structFind(labelsValue,"brand")# ID you entered is invalid.</td>
		</tr>
		<tr id="productInfo" style="display:none;">
			<td colspan="2" align="center" style="color:red;font-weight:bold;">#structFind(labelsValue,"Product_Group")# ID you entered is invalid.</td>
		</tr>
		<tr id="classInfo" style="display:none;">
			<td colspan="2" align="center" style="color:red;font-weight:bold;">#structFind(labelsValue,"Class_Code")# ID you entered is invalid.</td>
		</tr>
		<tr>
			<td class="bold" style="width:150px;">Item</td>
			<td><cfinput type="text" name="item" value="#Item#" style="width:100%;" disabled /></td>
			<cfinput type="hidden" name="bsaid" value="#url.BSAID#">
		</tr>
		<tr>
			<td class="bold">Description</td>
			<td><cfinput type="text" name="description" value="#Description#" style="width:100%;"/></td>
		</tr>
		<tr>
			<td class="bold">#structFind(labelsValue,"brand")# ID</td>
			<td><cfinput type="text" name="brand" value="#Brand_ID#" style="width:100%;" autosuggest="cfc:components.products.ItemMaster.getBrandNames({cfautosuggestvalue})" showAutosuggestLoadingIcon="false"/></td>
				<cfinput type="hidden" name="BrandID" style="width:100%;" bind="cfc:components.products.ItemMaster.getBrandid({brand})" bindonload="true"/>
		</tr>
		<tr>
			<td class="bold">#structFind(labelsValue,"Product_Group")#</td>
			<td><cfinput type="text" name="product" value="#Product#" style="width:100%;" autosuggest="cfc:components.products.ItemMaster.getProductGroup({cfautosuggestvalue})" showAutosuggestLoadingIcon="false"/></td>
	            <cfinput type="hidden" name="productID" style="width:100%;" bind="cfc:components.products.ItemMaster.getProductid({product})" bindonload="true"/>	
		</tr>
		<tr>
			<td class="bold">#structFind(labelsValue,"Class_Code")#</td>
			<td><cfinput type="text" name="classs" value="#Class#" style="width:100%;" autosuggest="cfc:components.products.ItemMaster.getClass({cfautosuggestvalue})" showAutosuggestLoadingIcon="false"/></td>
	            <cfinput type="hidden" name="classID" style="width:100%;" bind="cfc:components.products.ItemMaster.getClassid({classs})" bindonload="true"/>
				<cfinput type="hidden" name="classUUID" style="width:100%;" bind="cfc:components.products.ItemMaster.getClassUUID({classs})" bindonload="true"/>		
		</tr>
	</table>
		<input type="hidden" name="type" value="Product">
		<input type="hidden" name="update" value="1">

</cfform>

<div align="center">
			<a href="javascript:document.getElementById('itemedit').reset();">#application.util.string.actionLinkFormat("reset")# </a>
			<a href="javascript:modify();">#application.util.string.actionLinkFormat("save")#</a>
</div>

</cfoutput>
</cfif>
<script>
function modify(){
	var count = 0;
	if(document.all.brand.value != '' && document.all.BrandID.value == ''){
		document.getElementById("brandInfo").style.display = "block";
		var count = count + 1;
	}
	if(document.all.product.value != '' && document.all.productID.value == ''){
		document.getElementById("productInfo").style.display = "block";
		var count = count + 1;
	}
	if(document.all.classs.value != '' && document.all.classID.value == ''){
		document.getElementById("classInfo").style.display = "block";
		var count = count + 1;
	}

	if(count == 0){
		
			if(document.all.brand.value == '' || document.all.product.value == '' || document.all.classs.value == ''){

				if(confirm("Do you want to submit form with empty values ?")){
					itemedit.submit();
				}

			}
			else{
				itemedit.submit();
			}

		
	}
}
</script>
<style>
 #brandautosuggest {
	z-index:3;
 }
 #brandcontainer{
 	margin-top:5px;
 }
 #productautosuggest {
	z-index:2;
 }
 #productcontainer{
 	margin-top:5px;
 }
 #classautosuggest {
	z-index:1;
 }
 #classcontainer{
 	margin-top:5px;
 }
</style>