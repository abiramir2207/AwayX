<cfset useLakebaseForgetDeductions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_data_detail")>
<cfif useLakebaseForgetDeductions>
	<cftry>
		<cfset getDeductions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_data_detail", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDeductions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDeductions>
<CFQUERY NAME="getDeductions" datasource="#application.datasource#">
	SELECT *
	FROM Deductions_Data_Detail
</CFQUERY>
</cfif>


