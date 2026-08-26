
<cfset useLakebaseForTotalEarn = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_mapping_table")>
<cfif useLakebaseForTotalEarn>
	<cftry>
		<cfset TotalEarn = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_mapping_table", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForTotalEarn = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForTotalEarn>
<cfquery name="TotalEarn" datasource="#application.datasource#">
SELECT * FROM RP_Mapping_Table
</cfquery>
</cfif>
<cfquery name="TotalBB" datasource="#application.datasource#">
<!--- SELECT * FROM RP_Mapping_Table --->
SELECT * FROM RP_Billback_Table
</cfquery>

<!--- <cfdump var="#TotalEarn#"> 
<cfdump var="#TotalBB#">  --->

<!----Build directory structure--->
<cfif DirectoryExists("#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\#FilePath#") IS FALSE>
	<cfdirectory action="create" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\flatfile\#FilePath#">
</cfif>
<cfif DirectoryExists("#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#") IS FALSE>
	<cfdirectory action="create" directory="#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#">
</cfif>