<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset product_group_id=url.item_id>
<cfset pr_date_period=url.date_period>

<cfset date_period=url.date_period>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- summary --------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_summary" datasource="#Application.Datasource#">

SELECT	pr_product_summary_ID,
		pr_purchases_cases,
		pr_purchases_dollars,
		pr_street_cases,
		pr_street_dollars,
		pr_street_cases_percent,
		pr_street_dollars_percent,
		pr_operator_discounted_cases,
		pr_operator_discounted_dollars,
		pr_operator_discounted_cases_percent,
		pr_operator_discounted_dollars_percent,
		pr_mrkt_shelter_case_rate,
		pr_mrkt_shelter_dollars,
		pr_operator_discounted_case_rate,
		pr_operator_discounted_dollars_cr,
		pr_investment_case_rate,
		pr_investment_dollars,
		pr_date_period,
		deleted,
		created_date,
		product_group_id,
		product_group_description

FROM	Snapshot_Product_Summary

WHERE	product_group_id = '#product_group_id#'
		AND
		pr_date_period = '#pr_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- operators ------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_operators" datasource="#Application.Datasource#">

SELECT	ttop_operators_ID,
		pr_product_summary_ID,
		ttop_contract_number,
		ttop_contract_title,
		ttop_contract_type,
		ttop_cases,
		ttop_share,
		ttop_dollars,
		deleted,
		created_date,
		pr_date_period,
		product_group_id

FROM	Snapshot_Product_TT_Operators

WHERE	product_group_id = '#product_group_id#'
		AND
		pr_date_period = '#pr_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- items ----------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_items" datasource="#Application.Datasource#">

SELECT	ttit_items_ID,
		pr_product_summary_ID,
		ttit_item_number,
		ttit_item_description,
		ttit_dollars,
		ttit_cases,
		ttit_dollars_per_cases,
		ttit_net,
		ttit_index,
		deleted,
		created_date,
		pr_date_period,
		product_group_id

FROM	Snapshot_Product_TT_Items

WHERE	product_group_id = '#product_group_id#'
		AND
		pr_date_period = '#pr_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- distributors ---------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_distributors" datasource="#Application.Datasource#">

SELECT	ttds_distributors_ID,
		pr_product_summary_ID,
		ttds_distributor_sold_to,
		ttds_distributor_name,
		ttds_distributor_region,
		ttds_cases,
		ttds_share,
		ttds_dollars,
		deleted,
		created_date,
		pr_date_period,
		product_group_id

FROM	Snapshot_Product_TT_Distributors
		
WHERE	product_group_id = '#product_group_id#'
		AND
		pr_date_period = '#pr_date_period#'
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


