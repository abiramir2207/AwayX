<cfparam name="form.txtAddLookupPalletTypeDesc" default="">

	<cfif Trim(form.txtAddLookupPalletTypeDesc) neq "">
				<CFQUERY NAME="InsPalletType" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Pallet_Type(Export_Lookup_Pallet_Type_Desc)
					VALUES('#form.txtAddLookupPalletTypeDesc#')
				</CFQUERY>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">