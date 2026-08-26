<style>
	
	div.note
	{
		color:			#FFFF00;
		font-size:		11px;
		font-style: 	italic;
	}
		
</style>

<cfparam name="form.budget_class_value" default="" type="any">

<!--- If somethign is comign from the form scope use it --->
<cfif form.budget_class_value eq "">
      <!--- if form scope is empty, use cookie --->
      <cfif isdefined("cookie.budget_classes")>
            <cfset form.budget_class_value = cookie.budget_classes />
      </cfif>


		<cfif form.budget_class_value eq ""> <!--- if form scope is empty, and cookie is nto set, use all classes --->

		<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
		SELECT	distinct Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc,
				Budget_Class.start_date
		
		FROM	dbo.dashboards_budget_weekly_summary
				
		
		        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
		        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
		
		WHERE	1=1
		
		        AND     dash_budget_type = 3
		        <cfif 	user_market_list neq "">
		        AND		market_id in (#user_market_list#)
		        <cfelse>
		        AND		1=2 <!--- Do not return any record if user is below this level --->
				Order by Budget_Class.start_date
				</cfif>

		</cfquery>

		<cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_Desc,",") />

      </cfif>

</cfif>

<cfset budget_classes_list = form.budget_class_value />
<BR />
Budget Class(es) presented: <cfoutput>#budget_classes_list#</cfoutput>
<div class="note">The only budget classes used by this dashboard, are the ones set by the "Select Budget Classes"</div>

<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
SELECT	dash_budget_expired,

        dashboards_budget_weekly_summary.zone_desc,
        dashboards_budget_weekly_summary.zone_code,

        dashboards_budget_weekly_summary.region_desc,
        dashboards_budget_weekly_summary.region_code,

        dashboards_budget_weekly_summary.market_desc,
        dashboards_budget_weekly_summary.market_code,
        
        dashboards_budget_weekly_summary.budget_desc,
        dashboards_budget_weekly_summary.budget_type,
        dashboards_budget_weekly_summary.budget_cal,

        Budget_Class.Budget_Class_Desc,

        dashboards_budget_weekly_summary.budget_dollars/1000 as budget_dollars,
        
        dashboards_budget_weekly_summary.budget_dollars_commit/1000 as budget_dollars_commit,
        dashboards_budget_weekly_summary.budget_commit_bal/1000 as budget_commit_bal,
        (100*dashboards_budget_weekly_summary.budget_commit_percent) as budget_commit_percent,
        (100*(1-dashboards_budget_weekly_summary.budget_commit_percent)) as budget_commit_bal_percent,
        
        dashboards_budget_weekly_summary.budget_dollars_paid/1000 as budget_dollars_paid,
        dashboards_budget_weekly_summary.budget_paid_bal/1000 as budget_paid_bal,
        (100*dashboards_budget_weekly_summary.budget_paid_percent) as budget_paid_percent,
        (100*(1-dashboards_budget_weekly_summary.budget_paid_percent)) as budget_paid_bal_percent,
        
        dashboards_budget_weekly_summary.dash_budget_type

FROM	dbo.dashboards_budget_weekly_summary

        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID

WHERE	1=1

		AND		dash_budget_type = 5

<cfif 	user_region_list neq "">
        AND		region_id in (#PreserveSingleQuotes(user_region_list)#)
<cfelse>
AND		1=2 <!--- Do not return any record if user is below this level --->
</cfif>

        <cfif 	budget_classes_list neq "">
        AND Budget_Class.Budget_Class_Desc IN (#ListQualify(budget_classes_list,"'")#)
        <cfelse>
        AND 1=2 <!--- Do not return any record if budget_classes_list is empty --->
        </cfif>


order by region_desc, budget_dollars_commit desc
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->


<br />


<style>

th.column_heading, th.column_heading_text
{
	color:						#FFFFFF;
	background-color:			#006600;
	text-align:					right;
	font-size:					10px;
	font-weight:				bold;
	padding:					15px 10px 5px 5px;
}

th.column_heading_text
{
	text-align:					left;
}

td.data_cell, td.data_cell_text
{
	color:						#aaaaaa;
	text-align:					right;
	font-size:					10px;
	padding:					5px 10px 5px 5px;
}


td.data_cell_text
{
	text-align:					left;
}

td.data_grid_subtotals
{
	color:						#FFFFFF;
	background-color:			#000000;
	text-align:					right;
	font-size:					10px;
	font-weight:				bold;
	padding:					5px 10px 5px 5px;
}

td.data_grid_totals
{
	color:						#000000;
	background-color:			#FFFFFF;
	text-align:					right;
	font-size:					13px;
	font-weight:				bold;
	padding:					10px 10px 10px 5px;
	border-top:					0px #ffffff solid;
}

</style>

<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">

<thead>
<tr>
	<th style="font-size:10px; text-transform:capitalize;">&nbsp;&nbsp;<cfoutput>#label.sub_region.singular#</cfoutput><br />&nbsp;&nbsp;total budget desc</th>
	<th style="text-align:left; padding:0px 0px 0px 0px; font-size:10px; text-transform:capitalize;">budget<br />class</th>
	<th style="text-align:right; padding:0px 5px 0px 0px; font-size:10px; text-transform:capitalize;"><CFOUTPUT>#label.budget_dollar.singular#</CFOUTPUT></th>
	<th style="text-align:right; padding:0px 5px 0px 0px; font-size:10px; text-transform:capitalize;"><CFOUTPUT>Committed </CFOUTPUT><br />%</th>
	<th style="text-align:right; padding:0px 5px 0px 0px; font-size:10px; text-transform:capitalize;"><CFOUTPUT>Committed </CFOUTPUT> bal<br />%</th>
	<th style="text-align:right; padding:0px 10px 0px 0px; font-size:10px; text-transform:capitalize;">paid<br />%</th>
	<th style="text-align:right; padding:0px 10px 0px 0px; font-size:10px; text-transform:capitalize;">paid bal&nbsp;&nbsp;&nbsp;&nbsp;<br />%&nbsp;&nbsp;&nbsp;&nbsp;</th>
</tr>
</thead>

<!--- instanciate the sub totals and totals variables ------------------------------------------ --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>

<cfset grand_sum_budget_dollars=0>
<cfset grand_sum_budget_dollars_commit=0>
<cfset grand_sum_budget_commit_bal=0>
<cfset grand_sum_budget_dollars_paid=0>
<cfset grand_sum_budget_paid_bal=0>


<tbody>
<cfoutput query="Get_Data_1"  group="region_desc">
  <tr>
    <td class="data_grid_level1" align="left" colspan="100%">&nbsp;&nbsp;#region_code# - #region_desc#</td>
  </tr>

<cfoutput>

<!--- calculate the totals ------------------------------------------------------------------ --->
<cfset sum_budget_dollars=sum_budget_dollars+budget_dollars>
<cfset sum_budget_dollars_commit=sum_budget_dollars_commit+budget_dollars_commit>
<cfset sum_budget_commit_bal=sum_budget_commit_bal+budget_commit_bal>
<cfset sum_budget_dollars_paid=sum_budget_dollars_paid+budget_dollars_paid>
<cfset sum_budget_paid_bal=sum_budget_paid_bal+budget_paid_bal>

<!--- calculate the grand totals ------------------------------------------------------------------ --->
<cfset grand_sum_budget_dollars=grand_sum_budget_dollars+budget_dollars>
<cfset grand_sum_budget_dollars_commit=grand_sum_budget_dollars_commit+budget_dollars_commit>
<cfset grand_sum_budget_commit_bal=grand_sum_budget_commit_bal+budget_commit_bal>
<cfset grand_sum_budget_dollars_paid=grand_sum_budget_dollars_paid+budget_dollars_paid>
<cfset grand_sum_budget_paid_bal=grand_sum_budget_paid_bal+budget_paid_bal>  

	<tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
		<td class="data_grid_level3" style="text-align:left; vertical-align:middl2; padding:0px 0px 2px 0px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#budget_desc# - #budget_type# - #budget_cal#</td>

		<td class="data_grid_level3" style="text-align:left;">#Budget_Class_Desc#</td>

		<td class="data_grid_level3" style="text-align:right;">#mydollarformat(budget_dollars)#</td>
		<td class="data_grid_level3" style="text-align:right;">#mydollarformat(budget_dollars_commit)#&nbsp;<br />#numberformat(budget_commit_percent, '()')#%</td>
		<td class="data_grid_level3" style="text-align:right;">#mydollarformat(budget_commit_bal)#&nbsp;<br />#numberformat(budget_commit_bal_percent, '()')#%</td>
		<td class="data_grid_level3" style="text-align:right;">#mydollarformat(budget_dollars_paid)#&nbsp;<br />#numberformat(budget_paid_percent,'()')#%</td>
		<td class="data_grid_level3" style="text-align:right;">#mydollarformat(budget_paid_bal)#&nbsp;<br />#numberformat(budget_paid_bal_percent,'()')#%</td>
	</tr>

</cfoutput>

	<tr bgcolor="##000000">
		<td class="data_grid_subtotals" style="text-align:left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sub Total</td>

		<td class="data_grid_subtotals">&nbsp;</td>

		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars)#</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%</td>
	</tr>

<!--- reset the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>
</cfoutput>

<cfoutput>

<tr bgcolor="##000000">
	<td class="data_grid_totals" style="text-align:left;">&nbsp;&nbsp;&nbsp;&nbsp;Grand Total</td>

	<td class="data_grid_totals">&nbsp;</td>

	<td class="data_grid_totals">#mydollarformat(grand_sum_budget_dollars)#</td>
	<td class="data_grid_totals">#mydollarformat(grand_sum_budget_dollars_commit)#<br />#numberformat(100*grand_sum_budget_dollars_commit/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
	<td class="data_grid_totals">#mydollarformat(grand_sum_budget_commit_bal)#<br />#numberformat(100*grand_sum_budget_commit_bal/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
	<td class="data_grid_totals">#mydollarformat(grand_sum_budget_dollars_paid)#<br />#numberformat(100*grand_sum_budget_dollars_paid/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
	<td class="data_grid_totals">#mydollarformat(grand_sum_budget_paid_bal)#<br />#numberformat(100*grand_sum_budget_paid_bal/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
</tr>

</cfoutput>

</tbody>
  
</table>

<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
<script type="text/javascript" src="../javascript/jquery.tablescroll.js"></script>
<script>
	/*<![CDATA[*/
	jQuery(document).ready(function($)
	{
		$('#thetable').tableScroll({height:400});
	});
	/*]]>*/
</script>
<!--- ----------------------------------------------------------------------------------------- --->

<br />
