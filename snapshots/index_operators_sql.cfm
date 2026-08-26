<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset operator_id=url.item_id>
<cfset os_date_period=url.date_period>

<cfset date_period=url.date_period>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- summary --------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_summary" datasource="#Application.Datasource#">

SELECT	os_operator_summary_ID,
		os_dollars_approved,
		os_cases_to_date,
		os_dollars_per_case,
		os_forecasted_cases,
		os_forecasted_dollars,
		os_ftg_cases,
		os_ftg_dollars,
		os_ftg_cases_per_month,
		os_ftg_dollars_per_month,
		os_date_period,
		deleted,
		created_date,
		operator_description

FROM	Snapshot_Operator_Summary

WHERE	operator_id = '#operator_id#'
		AND
		os_date_period = '#os_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- distributor sources --------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_distributor_sources" datasource="#Application.Datasource#">

SELECT	ttds_distributor_source_ID,
		os_operator_summary_ID,
		ttds_distributor_sold_to,
		ttds_distributor_name,
		ttds_distributor_region,
		ttds_cases,
		ttds_share,
		ttds_dollars,
		deleted,
		created_date,
		operator_id,
		os_date_period
		
FROM	Snapshot_Operator_TT_Distributor_Sources

WHERE	operator_id = '#operator_id#'
		AND
		os_date_period = '#os_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- items ----------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_items" datasource="#Application.Datasource#">

SELECT	ttit_items_ID,
		os_operator_summary_ID,
		ttit_item_number,
		ttit_item_description,
		ttit_dollars,
		ttit_cases,
		ttit_dollars_per_cases,
		ttit_net,
		ttit_index,
		deleted,
		created_date,
		operator_id,
		os_date_period

FROM	Snapshot_Operator_TT_Items

WHERE	operator_id = '#operator_id#'
		AND
		os_date_period = '#os_date_period#'
		AND
		deleted = 0

</cfquery>



<!--- ----------------------------------------------------------------------------------------- --->
<cfif #get_summary.recordcount# EQ 0>
	<div style="margin:225px 0px 225px 0px; text-align:center">
	<strong>NO DETAIL DATA AVAILABLE</strong>
	<br /><br />
	<a href="#" onClick="history.back();">[ review result set ]</a>
	</div>
	<cfabort>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


