<cfparam name="form.Contract_Products_ID" default="">
<cfset AllowCPIDDelete = 1>
<cfset relocateViaForm = 0>
<CFSET relocateToOffInvoice = 0>

<!--- only off invoice custom code --->
<cfif isdefined("form.EXISTINGPRODUCTLIST")>
	<CFSET List1 = form.EXISTINGPRODUCTLIST>
	<CFSET List1 = replacenocase(List1, "'", "", "ALL")>
	<CFSET Location1 = ListFindNoCase(List1, form.Contract_Products_ID)>
	<cfif Location1 NEQ 0>
		<CFSET List1 = listdeleteat(List1, Location1)>
	</cfif>
	<CFSET form.EXISTINGPRODUCTLIST = List1>
</cfif>


<cfif isdefined("form.Product_List")>
	<CFSET List2 = form.PRODUCT_LIST>
	<CFSET List2 = replacenocase(List2, "'", "", "ALL")>
	<CFSET Location2 = ListFindNoCase(List2, form.Contract_Products_ID)>
	<cfif Location2 NEQ 0>
		<CFSET List2 = listdeleteat(List2, Location2)>
	</cfif>
	<CFSET form.PRODUCT_LIST 		= List2>
</cfif>

<CFSET relocateViaForm = 1>
<CFSET relocateToOffInvoice = 1>

<cfset NextLocation = listtoarray(form.PreviousScriptName, "\")>
<cfset NextLocation = NextLocation[arraylen(NextLocation)]>


<cfif NextLocation EQ "contract_formula_add_products.cfm">
	<cfquery name="getFormData" datasource="#application.datasource#">
			SELECT
				Program_ID,
				Program_Formula_Pricing_Rule_ID
			FROM
				Program_Formula_Pricing_Rule_Products
			WHERE
				Contract_Product_ID = '#form.Contract_Products_ID#'
	</cfquery>
</cfif>

<cfoutput>

<cfif isdefined("program_id")>
	<cfif len(program_id) GT 0>
		<cfif isnumeric(program_id)>
			<cf_cryp type="en" key="#request.key#" string="#program_id#">
			<cfset program_id = cryp.value>
		</cfif>
	</cfif>
</cfif>

<FORM ACTION="#NextLocation#?CID=#Program_ID#<cfif isdefined("COMPID")>&COMPID=#COMPID#</cfif>" METHOD="post" id="myForm">
	<!--- off invoice custom code --->
	<cfloop index="x" list="SORT_BY,PROGRAM_ID,PRODUCT_LIST,EXISTINGPRODUCTLIST,PROGRAM_OFFINVOICE_PRODUCT_DATA_ID,DTPS_ON,DTPS_PROGRAM_ID,RULE_ID">
		<cfset FieldNameIs = x>
		<cfif isdefined("#FieldNameIs#")>
			<cfif FieldNameIs NEQ "Contract_Products_ID">
				<input type="Hidden" name="#FieldNameIs#" value="#evaluate("form.#FieldNameIs#")#">
			</cfif>
		</cfif>
	</cfloop>
	<cfif isdefined("getFormData")>
		<INPUT TYPE="Hidden" NAME="Rule_ID" VALUE="#getFormData.Program_Formula_Pricing_Rule_ID#">
	</cfif>

</FORM>
</CFOUTPUT>
<cfflush>
<script>
	document.all.myForm.submit();
</script>
<cfflush>

