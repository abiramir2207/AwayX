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

SELECT	*

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

SELECT	*

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

SELECT	*

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

SELECT	*

FROM	dbo.Snapshot_Distributor_TT_Operator_Accounts

WHERE	distributor_id = '#distributor_id#'
		AND
		ds_date_period = '#ds_date_period#'
		AND
		deleted = 0

</cfquery>




<!--- ----------------------------------------------------------------------------------------- --->
<cfif #get_summary.recordcount# EQ 0>
	<div style="margin:2px 0px 225px 0px; text-align:center">
    <br /><br /><br /><br /><br /><br /><br /><br /><br />
	<strong>NO DETAIL DATA AVAILABLE</strong>
	<br /><br />
	<a href="#" onClick="history.back();">[ review result set ]</a>
	</div>
	<cfabort>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


