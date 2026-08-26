<cfset useLakebaseForvariables_qBillBacks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForvariables_qBillBacks>
	<cftry>
		<cfset variables.qBillBacks = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"analyst_user_id" = "is.null"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qBillBacks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qBillBacks>
<cfquery name="variables.qBillBacks" datasource="#application.datasource#">
  SELECT *
    FROM BILLBACK
   WHERE Analyst_User_Id IS NULL
</cfquery>
</cfif>

<!---<cfdump var="#variables.qBillBacks#" abort="true">--->


<cfset billbackAssignmentManager = CreateOBject("component", "components.billback.BillbackAssignmentManager") />

<cfoutput query="variables.qBillBacks">
  <cfset billbackAssignmentManager.saveBillbackAnalyst( variables.qBillBacks.BillBack_Id )>
</cfoutput>
