<cfset useLakebaseForDeduction_Aging = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForDeduction_Aging>
	<cftry>
		<cfset Deduction_Aging = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"bb_danger_range" = "not.is.null",
				"select" = "bb_danger_range"
			}), "bb_danger_range"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeduction_Aging = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeduction_Aging>
<CFQUERY NAME="Deduction_Aging" DATASOURCE="#application.datasource#">
SELECT	Billback_Settings.BB_Danger_Range
FROM	Billback_Settings
WHERE  Billback_Settings.BB_Danger_Range IS NOT NULL 
</CFQUERY>
</cfif>
<CFIF Deduction_Aging.recordCount Gt 0>
	<CFSET Aging_Days = Deduction_Aging.BB_Danger_Range>
<CFELSE>
	<CFSET Aging_Days = 0>
</CFIF>