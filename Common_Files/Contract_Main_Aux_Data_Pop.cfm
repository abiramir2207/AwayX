<cfset useLakebaseFora = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseFora>
	<cftry>
		<cfset a = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseFora = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFora>
<cfquery name="a" datasource="#Application.Datasource#">
	SELECT Contract_Main_ID
	FROM Contract_Main
</cfquery>
</cfif>


<cfloop query="a">
	<cfquery name="b" datasource="#Application.Datasource#">
		insert into contract_main_aux_data
		(Contract_Main_ID)
		VALUES
		(#a.Contract_Main_ID#)
	</cfquery>
</CFLOOP>
