<CFQUERY NAME="Deduction_Aging" DATASOURCE="#application.datasource#">
SELECT	Billback_Settings.BB_Danger_Range
FROM	Billback_Settings
WHERE  Billback_Settings.BB_Danger_Range IS NOT NULL 
</CFQUERY>
<CFIF Deduction_Aging.recordCount Gt 0>
	<CFSET Aging_Days = Deduction_Aging.BB_Danger_Range>
<CFELSE>
	<CFSET Aging_Days = 0>
</CFIF>