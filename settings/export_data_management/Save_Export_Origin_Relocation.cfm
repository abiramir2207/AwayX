<cfparam name="form.txtAddLookupItemOriginCode" default="">
<cfparam name="form.txtAddLookupExportOriginTo" default="">
<cfparam name="form.txtAddLookupExportRelocationCost" default="">

<cfoutput>
	<cfloop collection="#Form#" item="i">
		<cfif Left(i,29) eq "txtLookupExportRelocationCost">
				<cfset Item_Origin_Code = ListGetAt(i,2,"_")>
				<cfset Export_Origin_To = ListGetAt(i,3,"_")>
				<cfset Relocation_Cost = Evaluate("txtLookupExportRelocationCost_"&Item_Origin_Code&"_"&Export_Origin_To)>

				<CFQUERY NAME="UpdRelocationCost" datasource="#application.datasource#">
					UPDATE Export_Lookup_Origin_Relocation
					SET Export_Origin_Relocation_Cost = <cfif Relocation_Cost eq "">NULL<cfelse>'#Relocation_Cost#'</cfif>
					WHERE Item_Origin_Code = '#Item_Origin_Code#'
					AND Export_Origin_To = '#Export_Origin_To#'
				</CFQUERY>
		</cfif>
	</cfloop>

	<cfif Trim(form.txtAddLookupItemOriginCode) neq "" AND Trim(txtAddLookupExportOriginTo) neq "" AND Trim(txtAddLookupExportRelocationCost) neq "">
				<CFQUERY NAME="InsRelocationCost" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Origin_Relocation(Item_Origin_Code,Export_Origin_To,Export_Origin_Relocation_Cost)
					VALUES('#form.txtAddLookupItemOriginCode#','#form.txtAddLookupExportOriginTo#','#form.txtAddLookupExportRelocationCost#')
				</CFQUERY>
	</cfif>
</cfoutput>

<cflocation url="index.cfm?Action=#Action#">
