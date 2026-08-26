	<!--- Save default vendor and billback closing method for the list of distributors passed --->
			<CFIF ListLen(AllDistributors) NEQ 0>
				<cfset DistNum = 0>
				<cfloop list="#AllDistributors#" index="CustID">
					<cfset DistNum = DistNum + 1>
				
				  <cfset newVendorID = Evaluate("form.Vendor_ID_" & DistNum)>
				  
					<cfset useLakebaseForUpdate_Dist_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForUpdate_Dist_Info>
	<cftry>
		<cfset application.oLakebase.updateRows("bsa_foodservice_customers",
			{
				"bsa_foodservice_customers_id" = "eq.#CustID#"
			},
			{
				"default_vendor_id" = "#newVendorID#",
				"default_billback_closing_method_id" = "#ListGetAt(form.Default_BB_Closing_Method,DistNum)#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Dist_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Dist_Info>
<CFQUERY NAME="Update_Dist_Info" DATASOURCE = "#Application.Datasource#">
						UPDATE BSA_Foodservice_Customers
						   SET Default_Vendor_ID = '#newVendorID#',
						       Default_Billback_Closing_Method_ID = '#ListGetAt(form.Default_BB_Closing_Method,DistNum)#'
						 WHERE BSA_Foodservice_Customers_ID = '#CustID#'
					</CFQUERY>
</cfif>
					
	
          <!---26298 Feb 28, 2011 - Update/Add Vendor xref table for the same distributor ID--->
          <cfquery NAME="rsCount" DATASOURCE = "#Application.Datasource#">
            SELECT COUNT(*) AS Result
              FROM Vendor_Master 
                    LEFT JOIN Vendor_Dist_Oper ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID
             WHERE Vendor_Dist_Oper.Distributor_ID = '#CustID#'
          </cfquery>
				
				  <cfif rsCount.Result>
            <cfset useLakebaseForrsUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_dist_oper")>
<cfif useLakebaseForrsUpdate>
	<cftry>
		<cfset application.oLakebase.updateRows("vendor_dist_oper",
			{
				"distributor_id" = "eq.#CustID#"
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
               WHERE Distributor_ID = '#CustID#'
            </cfquery>
</cfif>
				  <cfelse>
            <cfquery NAME="rsInsert" DATASOURCE = "#Application.Datasource#">
              INSERT Vendor_Dist_Oper
                    ( Default_Vendor_ID,
                      Vendor_ID,
                      Default_Billback_Closing_Method_ID,
                      Distributor_ID
                     )
              VALUES
                     ( '#newVendorID#',
                       '#newVendorID#',
                       '#ListGetAt(Form.Default_BB_Closing_Method, DistNum)#',
                       '#CustID#'
                     )
            </cfquery>
          </cfif>
				</cfloop>
			</CFIF>

<!--- Pass the list of distributors back to index.cfm --->
<form action="index.cfm" method="post" name="distributor_info_action">
	<cfoutput><input type="hidden" name="AllDistributors" value="#AllDistributors#"></cfoutput>
</form>

<script>
	document.forms["distributor_info_action"].submit();
</script>
