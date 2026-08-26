<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset distributor_id=url.item_id>
<cfset ds_date_period=url.date_period>

<cfset date_period=url.date_period>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- summary --------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_summary" datasource="#Application.Datasource#">

SELECT	ds_distributor_summary_ID,
		ds_region,
		ds_corporate_parent,
		ds_rank,
		ds_share,
		ds_purchases_cases,
		ds_purchases_dollars,
		ds_street_cases,
		ds_street_dollars,
		ds_street_cases_percent,
		ds_street_dollars_percent,
		ds_operator_discounted_cases,
		ds_operator_discounted_dollars,
		ds_operator_discounted_cases_percent,
		ds_operator_discounted_dollars_percent,
		ds_mrkt_shelter_case_rate,
		ds_mrkt_shelter_dollars,
		ds_operator_discounted_case_rate,
		ds_operator_discounted_dollars_cr,
		ds_investment_case_rate,
		ds_investment_dollars,
		ds_date_period,
		deleted,
		created_date,
		distributor_id,
		distributor_description

FROM	dbo.Snapshot_Distributor_Summary

WHERE	distributor_id = '#distributor_id#'
		AND
		ds_date_period = '#ds_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- categories ------------------------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_categories" datasource="#Application.Datasource#">

SELECT	ttct_categories_ID,
		ds_distributor_summary_ID,
		ttct_category,
		ttct_dollars,
		ttct_13wrt,
		ttct_cases,
		ttct_revenue,
		ttct_trade,
		ttct_operator,
		ttct_total,
		ttct_percent,
		ttct_net_per_cases,
		ttct_index,
		deleted,
		created_date,
		distributor_id

FROM	dbo.Snapshot_Distributor_TT_Categories

WHERE	distributor_id = '#distributor_id#'
		AND
		ds_date_period = '#ds_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- claims -------------------------------------------------------------------------------------->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_claims" datasource="#Application.Datasource#">

SELECT	ttcl_claims_settled_ID,
		ds_distributor_summary_ID,
		ttcl_claim_number,
		ttcl_reference,
		ttcl_contract_title,
		ttcl_claimed_amount,
		ttcl_claimed_amount_vs_expected,
		ttcl_rate,
		deleted,
		created_date,
		distributor_id,
		ds_date_period

FROM	dbo.Snapshot_Distributor_TT_Claims_Settled

WHERE	distributor_id = '#distributor_id#'
		AND
		ds_date_period = '#ds_date_period#'
		AND
		deleted = 0

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- operator accounts  -------------------------------------------------------------------------->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_operator_accounts" datasource="#Application.Datasource#">

SELECT	ttoa_operator_accounts_ID,
		ds_distributor_summary_ID,
		ttoa_contract_number,
		ttoa_contract_title,
		ttoa_contract_type,
		ttoa_cases,
		ttoa_share,
		ttoa_dollars,
		deleted,
		created_date,
		distributor_id,
		ds_date_period

FROM	dbo.Snapshot_Distributor_TT_Operator_Accounts

WHERE	distributor_id = '#distributor_id#'
		AND
		ds_date_period = '#ds_date_period#'
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









