<cfparam name="form.txtAddLookupDestinationPort" default="">
<cfparam name="form.SelAddLookupNamedPlaceType" default="">
<cfparam name="form.SelAddLookupDestinationCountry" default="">

	<cfif Trim(form.txtAddLookupDestinationPort) neq "" AND Trim(form.SelAddLookupNamedPlaceType) neq "" AND Trim(form.SelAddLookupDestinationCountry) neq "">
				<cfset useLakebaseForInsDestinationPort = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_destination_ports")>
<cfif useLakebaseForInsDestinationPort>
	<cftry>
		<cfset application.oLakebase.insertRow("export_lookup_destination_ports", {
			"export_lookup_destination_port_desc" = "#form.txtAddLookupDestinationPort#",
			"export_lookup_destination_country_id" = "#form.SelAddLookupDestinationCountry#",
			"export_lookup_named_place_type_id" = "#val(form.SelAddLookupNamedPlaceType)#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsDestinationPort = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsDestinationPort>
<CFQUERY NAME="InsDestinationPort" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Destination_Ports(Export_Lookup_Destination_Port_Desc,Export_Lookup_Destination_Country_ID,Export_Lookup_Named_Place_Type_ID)
					VALUES('#form.txtAddLookupDestinationPort#','#form.SelAddLookupDestinationCountry#','#val(form.SelAddLookupNamedPlaceType)#')
				</CFQUERY>
</cfif>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">
