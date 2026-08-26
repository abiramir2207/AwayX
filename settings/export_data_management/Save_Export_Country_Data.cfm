<cfparam name="form.txtAddLookupDestinationCountry" default="">
<cfparam name="form.txtAddLookupMaxWeight" default="">
<cfparam name="form.txtAddLookupAllowPallets" default="0">
<cfparam name="form.selAddLookupPalletTypeDesc" default="">

<cfoutput>
	<cfloop collection="#Form#" item="i">
		<cfset Export_Lookup_Destination_Country_ID = Mid(i, Find("_",i)+ 1,len(i))>
		<cfparam name="txtLookupAllowPallets_#Export_Lookup_Destination_Country_ID#" default="0">
		<cfif Left(i,27) eq "txtLookupDestinationCountry">
				<CFQUERY NAME="UpdCountryData" datasource="#application.datasource#">
					UPDATE Export_Lookup_Destination_Country
					SET Export_Lookup_Max_Weight = '#val(Evaluate("txtLookupMaxWeight_"&Export_Lookup_Destination_Country_ID))#'
					,Export_Lookup_Allow_Pallets = '#val(Evaluate("txtLookupAllowPallets_"&Export_Lookup_Destination_Country_ID))#'
					WHERE Export_Lookup_Destination_Country_ID = '#Export_Lookup_Destination_Country_ID#'
				</CFQUERY>
			</cfif>
	</cfloop>

	<cfif Trim(form.selAddLookupDestinationCountry) neq "" AND Trim(form.txtAddLookupMaxWeight) neq "">
				<CFQUERY NAME="GetCountryCode" datasource="#application.datasource#">
					SELECT Country_Code
					FROM _Country
					WHERE Country_Name = '#form.selAddLookupDestinationCountry#'
				</CFQUERY>

		<cfif GetCountryCode.RecordCount eq 1>
				<CFQUERY NAME="InsCountryData" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Destination_Country(Export_Lookup_Destination_Country_Desc,Country_Code,Export_Lookup_Max_Weight,Export_Lookup_Allow_Pallets)
					VALUES('#form.selAddLookupDestinationCountry#','#GetCountryCode.Country_Code#','#val(form.txtAddLookupMaxWeight)#','#form.txtAddLookupAllowPallets#')

					SELECT Export_Lookup_Destination_Country_ID = @@IDENTITY
				</CFQUERY>

			<cfloop list="#form.selAddLookupPalletTypeDesc#" index="i">
				<CFQUERY NAME="InsPalletData" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Pallet_Type_Not_Allowed(Export_Lookup_Destination_Country_ID,Export_Lookup_Pallet_Type_ID)
					VALUES('#InsCountryData.Export_Lookup_Destination_Country_ID#','#i#')
				</CFQUERY>
			</cfloop>
		</cfif>

	</cfif>
</cfoutput>

<cflocation url="index.cfm?Action=#Action#">
