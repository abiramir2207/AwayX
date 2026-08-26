<cfparam name="form.txtAddLookupTermsofSaleDesc" default="">
<cfparam name="form.SelAddLookupNamedPlaceType" default="">

	<cfif Trim(form.txtAddLookupTermsofSaleDesc) neq "" AND Trim(form.SelAddLookupNamedPlaceType) neq "">
				<cfset useLakebaseForInsTermsofSale = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_terms_of_sale")>
<cfif useLakebaseForInsTermsofSale>
	<cftry>
		<cfset application.oLakebase.insertRow("export_lookup_terms_of_sale", {
			"export_lookup_terms_of_sale_desc" = "#form.txtAddLookupTermsofSaleDesc#",
			"export_lookup_named_place_type_id" = "#val(form.SelAddLookupNamedPlaceType)#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsTermsofSale = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsTermsofSale>
<CFQUERY NAME="InsTermsofSale" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Terms_of_Sale(Export_Lookup_Terms_of_Sale_Desc,Export_Lookup_Named_Place_Type_ID)
					VALUES('#form.txtAddLookupTermsofSaleDesc#','#val(form.SelAddLookupNamedPlaceType)#')
				</CFQUERY>
</cfif>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">
