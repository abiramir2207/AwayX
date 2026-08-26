<cfloop index="fieldname" list="#FORM.FIELDNAMES#">
	<cfif left(fieldname, 3) EQ "ODP">
		<cfset Distrib_ID = listgetat(fieldname, 2, "_")>
		<cfset Op_Dev_Pricing_Setting = evaluate(fieldname)>
		
		<cfquery name="UpdateData" datasource="#application.datasource#">
			UPDATE BSA_Foodservice_Customers
			SET Op_Dev_Pricing = '#Op_Dev_Pricing_Setting#'
			WHERE BSA_Foodservice_Customers_ID = '#Distrib_ID#'
		</cfquery>
	</cfif>
</cfloop>

<cflocation url="Op_Dev_Pricing_settings.cfm?ID=#createUUID()#">
