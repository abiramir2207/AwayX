<!------ raw_materials_supplier.cfm ----->
<cfoutput>
<cfset procurement = requestObj.getProcurement() />
<cfset rawMaterials = procurement.getRawMaterial() />
<cfset rawMaterialCount = ArrayLen(rawMaterials) />

<cfparam name="form.RecommendedSuppliers" 	default="">
<cfset lRecommendedSupplierIds = procurement.getLRecommendedSupplierIds()>
<cfset qGetSupplier = CreateObject("component", "components.futures_pricing.SupplierManager").getSupplier(lRecommendedSupplierIds) />
	<br><br>
	<table cellpadding="2" cellspacing="0" width="70%" align="center">
	<caption align="left" style="font-size:12px;">
	You can specify recommended suppliers for the following raw materials.
	<CF_smallLink 
			title = "select supplier" 
			url = "##"
			parameters = "onClick=""javascript: return showSupplierSearchWindow('#formName#','RecommendedSuppliers');"""
		><br><br>
	</caption>
	<cfloop index="i" from="1" to="#rawMaterialCount#">
		<cfset rawMaterial = rawMaterials[i] />
		<tr>
			<td><B>[#rawMaterial.getNumber()#] #rawMaterial.getDesc()#</B></td>
			<td>
			<cfif qGetSupplier.recordCount>
			<select name="supplier_#rawMaterial.getId()#" style="width:200px;">
			<cfloop query="qGetSupplier">
				<option value="#FP_Supplier_ID#"<cfif FP_Supplier_ID EQ rawMaterial.getRecommendedSupplierId()> selected</cfif>>#Supplier_Name#</option>
			</cfloop>
			</select>
			</cfif>
			</td>
		</tr>
	</cfloop>
	</table>
	<br><br>
	<div align="center">
	<cf_smallLink
			title="continue"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','sRequestMaterials', #form.page#, #form.bForward#);"""
			>
	</div>
	<input type="Hidden" name="RecommendedSuppliers" value="#lRecommendedSupplierIds#">
</cfoutput>