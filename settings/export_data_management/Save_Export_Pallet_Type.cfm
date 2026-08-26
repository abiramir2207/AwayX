<cfparam name="form.txtAddLookupPalletTypeDesc" default="">

	<cfif Trim(form.txtAddLookupPalletTypeDesc) neq "">
				<cfset useLakebaseForInsPalletType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_pallet_type")>
<cfif useLakebaseForInsPalletType>
	<cftry>
		<cfset application.oLakebase.insertRow("export_lookup_pallet_type", {
			"export_lookup_pallet_type_desc" = "#form.txtAddLookupPalletTypeDesc#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsPalletType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsPalletType>
<CFQUERY NAME="InsPalletType" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Pallet_Type(Export_Lookup_Pallet_Type_Desc)
					VALUES('#form.txtAddLookupPalletTypeDesc#')
				</CFQUERY>
</cfif>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">