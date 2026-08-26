<cfparam name="form.txtAddLookupStandardCosts" default="">
<cfparam name="form.txtAddLookupStandardCostsDesc" default="">

<cfoutput>
	<cfloop collection="#Form#" item="i">
		<cfset Export_Lookup_Cost_ID = Mid(i, Find("_",i)+ 1,len(i))>
		<cfif Left(i,26) eq "TxtLookupStandardCostsDesc">
				<CFQUERY NAME="UpdCosts" datasource="#application.datasource#">
					UPDATE Export_Lookup_Costs
					SET Export_Lookup_Cost = '#val(Evaluate("TxtLookupStandardCosts_"&Export_Lookup_Cost_ID))#'
					WHERE Export_Lookup_Cost_ID = '#Export_Lookup_Cost_ID#'
				</CFQUERY>
			</cfif>
	</cfloop>

	<cfif Trim(form.txtAddLookupStandardCostsDesc) neq "" AND Trim(form.txtAddLookupStandardCosts) neq "">
				<cfset useLakebaseForInsCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_lookup_costs")>
<cfif useLakebaseForInsCosts>
	<cftry>
		<cfset application.oLakebase.insertRow("export_lookup_costs", {
			"export_lookup_cost" = "#val(form.txtAddLookupStandardCosts)#",
			"export_lookup_cost_desc" = "#form.txtAddLookupStandardCostsDesc#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsCosts>
<CFQUERY NAME="InsCosts" datasource="#application.datasource#">
					INSERT INTO Export_Lookup_Costs(Export_Lookup_Cost,Export_Lookup_Cost_Desc)
					VALUES('#val(form.txtAddLookupStandardCosts)#','#form.txtAddLookupStandardCostsDesc#')
				</CFQUERY>
</cfif>
	</cfif>
</cfoutput>

<cflocation url="index.cfm?Action=#Action#">