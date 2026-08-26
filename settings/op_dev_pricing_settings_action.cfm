<cfloop index="fieldname" list="#FORM.FIELDNAMES#">
	<cfif left(fieldname, 3) EQ "ODP">
		<cfset Distrib_ID = listgetat(fieldname, 2, "_")>
		<cfset Op_Dev_Pricing_Setting = evaluate(fieldname)>
		
		<cfset useLakebaseForUpdateData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForUpdateData>
	<cftry>
		<cfset application.oLakebase.updateRows("bsa_foodservice_customers",
			{
				"bsa_foodservice_customers_id" = "eq.#Distrib_ID#"
			},
			{
				"op_dev_pricing" = "#Op_Dev_Pricing_Setting#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateData>
<cfquery name="UpdateData" datasource="#application.datasource#">
			UPDATE BSA_Foodservice_Customers
			SET Op_Dev_Pricing = '#Op_Dev_Pricing_Setting#'
			WHERE BSA_Foodservice_Customers_ID = '#Distrib_ID#'
		</cfquery>
</cfif>
	</cfif>
</cfloop>

<cflocation url="Op_Dev_Pricing_settings.cfm?ID=#createUUID()#">
