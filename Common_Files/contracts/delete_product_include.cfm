<!--- delete product section --->
<script>
	function deleteProduct(CPID) {
		if(confirm("Press OK to delete this product.")) {
			document.all.deleteProductForm.Contract_Products_ID.value = CPID;
			document.all.deleteProductForm.submit();
		}
	}
</script>

<form action="delete_product_from_program_action.cfm" method="post" name="deleteProductForm" id="deleteProductForm">
	<input type="Hidden" name="Contract_Products_ID" value="">
	
	<!--- off invoice custom code --->
	<CFOUTPUT>
		<cfloop index="x" list="SORT_BY,PROGRAM_ID,PRODUCT_LIST,EXISTINGPRODUCTLIST,PROGRAM_OFFINVOICE_PRODUCT_DATA_ID,DTPS_ON,DTPS_PROGRAM_ID,CONTRACT_MAIN_ID,RULE_ID">
			<cfset FieldNameIs = x>
			<cfif isdefined("#FieldNameIs#")><cfif len(evaluate("#FieldNameIs#")) GT 0><input type="Hidden" name="#FieldNameIs#" value="#evaluate("#FieldNameIs#")#"></cfif></cfif>
		</cfloop>

		
		
		<cfif isdefined("contract_main_id") and not isdefined("program_id")>
			<cfif len(contract_main_id) GT 0>
				<cfif isnumeric(contract_main_id)>
					<cf_cryp type="en" key="#request.key#" string="#contract_main_id#">
					<cfset contract_main_id = cryp.value>
				</cfif>
				<input type="Hidden" name="program_id" value="#contract_main_id#">
			</cfif>
		</cfif>

		<cfif isdefined("program_id") and not isdefined("contract_main_id")>
			<cfif len(program_id) GT 0>
				<cfif isnumeric(program_id)>
					<cf_cryp type="en" key="#request.key#" string="#program_id#">
					<cfset program_id = cryp.value>
				</cfif>
				<input type="Hidden" name="contract_main_id" value="#program_id#">
			</cfif>
		</cfif>
		
		<input type="Hidden" name="PreviousScriptName" value="#lcase(cgi.script_name)#">
		<cfif isdefined("URL.COMPID")>
			<input type="Hidden" name="COMPID" value="#URL.COMPID#">
		</cfif>
		
	</CFOUTPUT>
</form>
<!--- delete product section --->