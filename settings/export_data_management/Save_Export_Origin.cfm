<cfparam name="form.txtAddLookupOriginDesc" default="">
<cfparam name="form.txtAddLookupOriginCode" default="">

	<cfif Trim(form.txtAddLookupOriginDesc) neq "" AND Trim(form.txtAddLookupOriginCode) neq "">
				<CFQUERY NAME="InsOrigin" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Origin(Export_Lookup_Origin_Desc,Export_Lookup_Origin_Code)
					VALUES('#form.txtAddLookupOriginDesc#','#form.txtAddLookupOriginCode#')
				</CFQUERY>
	</cfif>

<cflocation url="index.cfm?Action=#Action#">
