<!--- Save default vendor and billback closing method for the list of operators passed --->
<cfif Len(Form.Operator_List)>
  <cfset DistNum = 0>
  
  <cfloop list="#Form.Operator_List#" index="thisOperator">
  
    <cfset DistNum = DistNum + 1>

    <cfset newVendorID = Evaluate("form.Vendor_ID_" & DistNum)>
    
    <cfset useLakebaseForUpdate_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForUpdate_Info>
	<cftry>
		<cfset application.oLakebase.updateRows("bsa_operator",
			{
				"bsa_operator_id" = "eq.#thisOperator#"
			},
			{
				"default_vendor_id" = "#newVendorID#",
				"default_billback_closing_method_id" = "#ListGetAt(Form.Default_BB_Closing_Method, DistNum)#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Info>
<cfquery NAME="Update_Info" DATASOURCE = "#Application.Datasource#">
      UPDATE BSA_Operator
         SET Default_Vendor_ID = '#newVendorID#',
             Default_Billback_Closing_Method_ID = '#ListGetAt(Form.Default_BB_Closing_Method, DistNum)#'
      WHERE BSA_Operator_ID = '#thisOperator#'
    </cfquery>
</cfif>
    
    
    <!---26298 Feb 28, 2011 - Update/Add Vendor xref table for the same operator ID--->
    <cfquery NAME="rsCount" DATASOURCE = "#Application.Datasource#">
      SELECT COUNT(*) AS Result
        FROM Vendor_Master 
              LEFT JOIN Vendor_Dist_Oper ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID
       WHERE Vendor_Dist_Oper.Operator_ID = '#thisOperator#'
    </cfquery>
	
	  <cfif rsCount.Result>
      <cfset useLakebaseForrsUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_dist_oper")>
<cfif useLakebaseForrsUpdate>
	<cftry>
		<cfset application.oLakebase.updateRows("vendor_dist_oper",
			{
				"operator_id" = "eq.#thisOperator#"
			},
			{
				"default_vendor_id" = "#newVendorID#",
				"default_billback_closing_method_id" = "#ListGetAt(Form.Default_BB_Closing_Method, DistNum)#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForrsUpdate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrsUpdate>
<cfquery NAME="rsUpdate" DATASOURCE = "#Application.Datasource#">
        UPDATE Vendor_Dist_Oper
           SET Default_Vendor_ID = '#newVendorID#',
               Default_Billback_Closing_Method_ID = '#ListGetAt(Form.Default_BB_Closing_Method, DistNum)#'
         WHERE Operator_ID = '#thisOperator#'
      </cfquery>
</cfif>
	  <cfelse>
      <cfquery NAME="rsInsert" DATASOURCE = "#Application.Datasource#">
        INSERT Vendor_Dist_Oper
              ( Default_Vendor_ID,
                Vendor_ID,
                Default_Billback_Closing_Method_ID,
                Operator_ID
               )
        VALUES
               ( '#newVendorID#',
                 '#newVendorID#',
                 '#ListGetAt(Form.Default_BB_Closing_Method, DistNum)#',
                 '#thisOperator#'
               )
      </cfquery>
    </cfif>
  </cfloop>
</cfif>

<!--- Pass the list of operators back to index.cfm --->
<cflocation url="index.cfm?Operator_List=#Form.Operator_List#" addtoken="false">