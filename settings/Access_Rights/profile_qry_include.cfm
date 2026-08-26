<cfset useLakebaseForGetLumpSums = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForGetLumpSums>
	<cftry>
		<cfset GetLumpSums = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"deleted" = "eq.0",
				"active" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLumpSums = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLumpSums>
<cfquery name="GetLumpSums" datasource="#application.datasource#">
SELECT *
FROM Program_Lump_Sum_Name
WHERE Deleted = 0
AND Active = 1
</cfquery>
</cfif>

<cfloop query="getProfiles">
<cfset i = getProfiles.profiles_id>
	<CFSET Query_Name="Get_"&i&"_Settings">
	<CFQUERY NAME="#Query_Name#" datasource="#application.datasource#">
		Select		*
		From		Profiles_Settings
			INNER JOIN Profiles ON Profiles.Profiles_ID = Profiles_Settings.Profiles_ID
		Where		Profiles_Settings.Profiles_ID		=		#i#
		AND Profiles.Deleted = 0
	</CFQUERY>
</CFLOOP>