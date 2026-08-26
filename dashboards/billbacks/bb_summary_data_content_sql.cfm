<!--- ----------------------------------------------------------------------------------------- --->

<!--- 

Record types:

	1	Daily
	2	Weekly
	3	Monthly
	4	Quarterly
	5	Yearly

 --->

<!--- Monthly data ---------------------------------------------------------------------------------- --->
<cfquery name="Monthly" datasource="#Application.Datasource#">

    SELECT
        Dashboards_BB_Summary_ID,	Dashboards_BB_Record_Type_Lookup_ID,	period_desc,
        invoices_processed_count,	dollars_processed_total,				dollars_processed_off_invoice,
        dollars_processed_billback,	dollars_processed_avg_per_billback,		discrepancy_invoices,
        discrepancy_total_dollars,	discrepancy_dollars_as_percent,			deduction_days_outstanding,
        cycle_time_created_to_paid,	cycle_time_end_to_paid,					avg_count_items_per_invoice,
        payment_type_check,			payment_type_deduction,					payment_type_at,
        entry_type_edi,				entry_type_einvoice,					entry_type_manual
    FROM
    	Dashboards_BB_Summary
    WHERE
    	Dashboards_BB_Record_Type_Lookup_ID = 3
	AND	batch_id = 
			(
				select max(A.batch_id) 
				from 	Dashboards_BB_Summary A 
				where 	A.Dashboards_BB_Record_Type_Lookup_ID = Dashboards_BB_Summary.Dashboards_BB_Record_Type_Lookup_ID
			)
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- Quarterly data -------------------------------------------------------------------------- --->
<cfquery name="Quarterly" datasource="#Application.Datasource#">

    SELECT
        Dashboards_BB_Summary_ID,	Dashboards_BB_Record_Type_Lookup_ID,	period_desc,
        invoices_processed_count,	dollars_processed_total,				dollars_processed_off_invoice,
        dollars_processed_billback,	dollars_processed_avg_per_billback,		discrepancy_invoices,
        discrepancy_total_dollars,	discrepancy_dollars_as_percent,			deduction_days_outstanding,
        cycle_time_created_to_paid,	cycle_time_end_to_paid,					avg_count_items_per_invoice,
        payment_type_check,			payment_type_deduction,					payment_type_at,
        entry_type_edi,				entry_type_einvoice,					entry_type_manual
    FROM
    	Dashboards_BB_Summary
    WHERE
    	Dashboards_BB_Record_Type_Lookup_ID = 4
	AND	batch_id = 
			(
				select max(A.batch_id) 
				from 	Dashboards_BB_Summary A 
				where 	A.Dashboards_BB_Record_Type_Lookup_ID = Dashboards_BB_Summary.Dashboards_BB_Record_Type_Lookup_ID
			)
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- YTD data -------------------------------------------------------------------------------- --->
<cfquery name="Yearly" datasource="#Application.Datasource#">

    SELECT
        Dashboards_BB_Summary_ID,	Dashboards_BB_Record_Type_Lookup_ID,	period_desc,
        invoices_processed_count,	dollars_processed_total,				dollars_processed_off_invoice,
        dollars_processed_billback,	dollars_processed_avg_per_billback,		discrepancy_invoices,
        discrepancy_total_dollars,	discrepancy_dollars_as_percent,			deduction_days_outstanding,
        cycle_time_created_to_paid,	cycle_time_end_to_paid,					avg_count_items_per_invoice,
        payment_type_check,			payment_type_deduction,					payment_type_at,
        entry_type_edi,				entry_type_einvoice,					entry_type_manual
    FROM
    	Dashboards_BB_Summary
    WHERE
    	Dashboards_BB_Record_Type_Lookup_ID = 5
	AND	batch_id = 
			(
				select max(A.batch_id) 
				from 	Dashboards_BB_Summary A 
				where 	A.Dashboards_BB_Record_Type_Lookup_ID = Dashboards_BB_Summary.Dashboards_BB_Record_Type_Lookup_ID
			)
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->
