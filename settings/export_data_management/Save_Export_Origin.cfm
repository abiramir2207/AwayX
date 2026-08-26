<cfparam name="form.txtAddLookupOriginDesc" default="">
<cfparam name="form.txtAddLookupOriginCode" default="">

	<cfif Trim(form.txtAddLookupOriginDesc) neq "" AND Trim(form.txtAddLookupOriginCode) neq "">
				<cfset useLakebaseForInsOrigin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_origin")>
<cfif useLakebaseForInsOrigin>
	<cftry>
		<cfset application.oLakebase.insertRow("export_lookup_origin", {
			"export_lookup_origin_desc" = "#form.txtAddLookupOriginDesc#",
			"export_lookup_origin_code" = "#form.txtAddLookupOriginCode#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsOrigin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsOrigin>
<CFQUERY NAME="InsOrigin" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Origin(Export_Lookup_Origin_Desc,Export_Lookup_Origin_Code)
					VALUES('#form.txtAddLookupOriginDesc#','#form.txtAddLookupOriginCode#')
				</CFQUERY>
</cfif>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">
