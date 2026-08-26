<cfparam name="form.txtAddLookupTermsofSaleDesc" default="">
<cfparam name="form.SelAddLookupNamedPlaceType" default="">

	<cfif Trim(form.txtAddLookupTermsofSaleDesc) neq "" AND Trim(form.SelAddLookupNamedPlaceType) neq "">
				<CFQUERY NAME="InsTermsofSale" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Terms_of_Sale(Export_Lookup_Terms_of_Sale_Desc,Export_Lookup_Named_Place_Type_ID)
					VALUES('#form.txtAddLookupTermsofSaleDesc#','#val(form.SelAddLookupNamedPlaceType)#')
				</CFQUERY>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">
