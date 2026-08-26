
<cfquery name="TotalEarn" datasource="#application.datasource#">
SELECT * FROM RP_Mapping_Table
</cfquery>
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