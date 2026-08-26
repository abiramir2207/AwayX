<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
SELECT	dash_budget_expired,

        budget_desc,
        budget_type,
        
        budget_dollars/1000 as budget_dollars,
        
        budget_dollars_commit/1000 as budget_dollars_commit,
        budget_commit_bal/1000 as budget_commit_bal,
        (100*budget_commit_percent) as budget_commit_percent,
        ((1-budget_commit_percent)*100) as budget_commit_bal_percent,
        
        budget_dollars_paid/1000 as budget_dollars_paid,
        budget_paid_bal/1000 as budget_paid_bal,
        (100*budget_paid_percent) as budget_paid_percent,
        (100*(1-budget_paid_percent)) as budget_paid_bal_percent,
        shipto,
        dist_name

FROM	dbo.dashboards_budget_weekly_summary

WHERE	1=1
AND		dist_name <> ''
AND		budget_type = 'Fixed'
<cfif 	user_market_list neq "">
AND		market_id in (#user_market_list#)
<cfelse>
AND		1=2 <!--- Do not return any record if user is below this level --->
</cfif>
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->