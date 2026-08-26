<cfparam name="form.txtAddLookupDestinationPort" default="">
<cfparam name="form.SelAddLookupNamedPlaceType" default="">
<cfparam name="form.SelAddLookupDestinationCountry" default="">

	<cfif Trim(form.txtAddLookupDestinationPort) neq "" AND Trim(form.SelAddLookupNamedPlaceType) neq "" AND Trim(form.SelAddLookupDestinationCountry) neq "">
				<CFQUERY NAME="InsDestinationPort" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Destination_Ports(Export_Lookup_Destination_Port_Desc,Export_Lookup_Destination_Country_ID,Export_Lookup_Named_Place_Type_ID)
					VALUES('#form.txtAddLookupDestinationPort#','#form.SelAddLookupDestinationCountry#','#val(form.SelAddLookupNamedPlaceType)#')
				</CFQUERY>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">
