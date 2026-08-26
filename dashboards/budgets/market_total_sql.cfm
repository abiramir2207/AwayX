<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
SELECT	dash_budget_expired,

        zone_desc,
        zone_code,

        region_desc,
        region_code,

        market_desc,
        market_code,
        
        budget_desc,
        budget_type,
        
        budget_dollars/1000 as budget_dollars,
        
        budget_dollars_commit/1000 as budget_dollars_commit,
        budget_commit_bal/1000 as budget_commit_bal,
        (100*budget_commit_percent) as budget_commit_percent,
        (100*(1-budget_commit_percent)) as budget_commit_bal_percent,
        
        budget_dollars_paid/1000 as budget_dollars_paid,
        budget_paid_bal/1000 as budget_paid_bal,
        (100*budget_paid_percent) as budget_paid_percent,
        (100*(1-budget_paid_percent)) as budget_paid_bal_percent,
        
        dash_budget_type

FROM	dbo.dashboards_budget_weekly_summary
WHERE	1=1
AND		dash_budget_type = 4
<cfif 	user_market_list neq "">
AND		market_id in (#user_market_list#)
<cfelse>
AND		1=2 <!--- Do not return any record if user is below this level --->
</cfif>
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

