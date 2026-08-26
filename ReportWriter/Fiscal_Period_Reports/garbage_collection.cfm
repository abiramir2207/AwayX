<!---Delete all database record--->
<cfquery name="DeleteAll" datasource="#application.datasource#">
Truncate Table RP_Billback_Summary
Truncate Table RP_Contract_Main
Truncate Table RP_Billback_Table
Truncate Table RP_Distributor_Summary
Truncate Table RP_Invoice_Detail
Truncate Table RP_Invoice_Summary
Truncate Table RP_Mapping_Table
Truncate Table RP_Payment_Report_Summary

<!--- DELETE FROM RP_Billback_Summary
DELETE FROM RP_Billback_Table
DELETE FROM RP_Distributor_Summary
DELETE FROM RP_Invoice_Detail
DELETE FROM RP_Invoice_Summary
DELETE FROM RP_Mapping_Table
DELETE FROM RP_Payment_Report_Summary --->
</cfquery>